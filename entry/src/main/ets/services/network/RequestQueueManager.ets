/**
 * 请求队列管理器（参考微信/QQ/Bilibili/快手的请求优化策略）
 * 功能：
 * 1. 请求合并：将多个相同类型的请求合并成一个批量请求
 * 2. 请求队列：管理请求优先级和并发控制
 * 3. 请求重试：弱网时自动重试失败请求
 * 4. 请求去重：避免重复请求
 * 
 * 参考：
 * - 微信：请求合并、优先级队列、智能重试
 * - QQ：连接池、请求批处理、增量更新
 * - Bilibili：CDN优化、预加载、数据压缩
 * - 快手：并发控制、请求去重、智能预取
 */
import { TDLibClient, getProp } from '../core/tdlib/TDLibClient';
import { NetworkOptimizer, NetworkType } from '../../utils/network/NetworkOptimizer';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Chat } from '../../models/TDLibData';

const TAG = 'RequestQueueManager';
const DOMAIN = 0x0001;

/** 请求类型 */
export enum RequestType {
  GET_CHAT = 'getChat',
  GET_CHATS = 'getChats',
  GET_USER = 'getUser',
  GET_USERS = 'getUsers',
  GET_MESSAGES = 'getMessages',
  DOWNLOAD_FILE = 'downloadFile',
  UPLOAD_FILE = 'uploadFile'
}

/** 请求优先级 */
export enum RequestPriority {
  LOW = 0,
  NORMAL = 1,
  HIGH = 2,
  URGENT = 3
}

/** 请求状态 */
export enum RequestStatus {
  PENDING = 'pending',
  RUNNING = 'running',
  COMPLETED = 'completed',
  FAILED = 'failed',
  CANCELLED = 'cancelled'
}

/** 请求项接口 */
export interface RequestItem {
  id: string;
  type: RequestType;
  priority: RequestPriority;
  params: Record<string, Object>;
  retryCount: number;
  maxRetries: number;
  status: RequestStatus;
  resolve: (value: Record<string, Object>) => void;
  reject: (error: Error) => void;
  timestamp: number;
}

/** 批量请求配置 */
export interface BatchRequestConfig {
  maxBatchSize: number;
  maxWaitTime: number;
  mergeStrategy: 'same_type' | 'same_params' | 'all';
}

export class RequestQueueManager {
  private static instance: RequestQueueManager;
  private tdClient: TDLibClient;
  private networkOptimizer: NetworkOptimizer;
  
  /** 请求队列（按优先级排序） */
  private requestQueue: RequestItem[] = [];
  
  /** 正在执行的请求 */
  private runningRequests: Map<string, RequestItem> = new Map();
  
  /** 批量请求缓存（用于合并请求） */
  private batchCache: Map<RequestType, RequestItem[]> = new Map();
  
  /** 批量请求定时器 */
  private batchTimer: number = 0;
  
  /** 最大并发数（动态调整，参考华为最佳实践） */
  private maxConcurrent: number = 5;
  
  /** 当前并发数 */
  private currentConcurrent: number = 0;
  
  /** 请求去重缓存（避免重复请求） */
  private requestDedupeCache: Map<string, RequestItem> = new Map();
  
  /** 批量请求配置（动态调整，参考华为最佳实践） */
  private batchConfig: BatchRequestConfig = {
    maxBatchSize: 20,
    maxWaitTime: 50, // 50ms内合并请求
    mergeStrategy: 'same_type'
  };

  private constructor() {
    this.tdClient = TDLibClient.getInstance();
    this.networkOptimizer = NetworkOptimizer.getInstance();
    // 优化：根据网络状态动态调整配置（参考华为最佳实践）
    this.updateConfigByNetworkState();
    // 监听网络状态变化，动态调整配置
    this.networkOptimizer.addListener(() => {
      this.updateConfigByNetworkState();
    });
    this.startQueueProcessor();
  }

  /**
   * 根据网络状态动态调整配置（参考华为最佳实践：弱网时减少并发、增加批量等待时间）
   */
  private updateConfigByNetworkState(): void {
    const networkState = this.networkOptimizer.getNetworkState();
    if (!networkState.connected || this.networkOptimizer.isWeakNetwork()) {
      // 弱网环境：减少并发数，增加批量等待时间
      this.maxConcurrent = 2;
      this.batchConfig.maxWaitTime = 100; // 100ms内合并请求
      this.batchConfig.maxBatchSize = 10; // 减少批量大小
      hilog.info(DOMAIN, TAG, 'Network weak, adjusted config: maxConcurrent=2, maxWaitTime=100ms');
    } else if (networkState.type === NetworkType.WIFI) {
      // WiFi环境：增加并发数，减少批量等待时间
      this.maxConcurrent = 8;
      this.batchConfig.maxWaitTime = 30; // 30ms内合并请求
      this.batchConfig.maxBatchSize = 30; // 增加批量大小
      hilog.info(DOMAIN, TAG, 'WiFi network, adjusted config: maxConcurrent=8, maxWaitTime=30ms');
    } else {
      // 蜂窝网络：中等配置
      this.maxConcurrent = 5;
      this.batchConfig.maxWaitTime = 50;
      this.batchConfig.maxBatchSize = 20;
    }
  }

  public static getInstance(): RequestQueueManager {
    if (!RequestQueueManager.instance) {
      RequestQueueManager.instance = new RequestQueueManager();
    }
    return RequestQueueManager.instance;
  }

  /**
   * 添加请求到队列（参考微信/QQ的请求合并策略）
   * @param type 请求类型
   * @param params 请求参数
   * @param priority 优先级
   * @returns Promise<响应数据>
   */
  public async enqueue(
    type: RequestType,
    params: Record<string, Object>,
    priority: RequestPriority = RequestPriority.NORMAL
  ): Promise<Record<string, Object>> {
    return new Promise<Record<string, Object>>((resolve, reject) => {
      const requestId = this.generateRequestId(type, params);
      
      // 请求去重：如果已有相同请求在队列中，复用该请求
      const existingRequest = this.requestDedupeCache.get(requestId);
      if (existingRequest && existingRequest.status === RequestStatus.PENDING) {
        // 复用现有请求的Promise
        existingRequest.resolve = (value: Record<string, Object>) => {
          resolve(value);
          existingRequest.resolve(value);
        };
        existingRequest.reject = (error: Error) => {
          reject(error);
          existingRequest.reject(error);
        };
        return;
      }
      
      const request: RequestItem = {
        id: requestId,
        type: type,
        priority: priority,
        params: params,
        retryCount: 0,
        maxRetries: this.getMaxRetries(type),
        status: RequestStatus.PENDING,
        resolve: resolve,
        reject: reject,
        timestamp: Date.now()
      };
      
      // 添加到去重缓存
      this.requestDedupeCache.set(requestId, request);
      
      // 根据合并策略决定是否加入批量缓存
      if (this.shouldBatch(type)) {
        this.addToBatchCache(request);
      } else {
        this.requestQueue.push(request);
        this.requestQueue.sort((a, b) => b.priority - a.priority);
      }
      
      this.processQueue();
    });
  }

  /**
   * 生成请求ID（用于去重）
   */
  private generateRequestId(type: RequestType, params: Record<string, Object>): string {
    const key = JSON.stringify({ type, params });
    return `${type}_${this.hashString(key)}`;
  }

  /**
   * 简单字符串哈希
   */
  private hashString(str: string): number {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return hash;
  }

  /**
   * 判断是否应该批量处理
   */
  private shouldBatch(type: RequestType): boolean {
    return type === RequestType.GET_CHAT ||
           type === RequestType.GET_USER ||
           type === RequestType.GET_MESSAGES;
  }

  /**
   * 添加到批量缓存
   */
  private addToBatchCache(request: RequestItem): void {
    if (!this.batchCache.has(request.type)) {
      this.batchCache.set(request.type, []);
    }
    const batch = this.batchCache.get(request.type);
    if (batch) {
      batch.push(request);
      
      // 如果达到批量大小，立即处理
      if (batch.length >= this.batchConfig.maxBatchSize) {
        this.processBatch(request.type);
      } else {
        // 否则启动定时器，等待更多请求
        this.scheduleBatchProcess(request.type);
      }
    }
  }

  /**
   * 安排批量处理（延迟处理，等待更多请求）
   */
  private scheduleBatchProcess(type: RequestType): void {
    if (this.batchTimer) {
      clearTimeout(this.batchTimer);
    }
    this.batchTimer = setTimeout(() => {
      this.processBatch(type);
      this.batchTimer = 0;
    }, this.batchConfig.maxWaitTime) as number;
  }

  /**
   * 处理批量请求（参考微信/QQ的批量请求策略）
   */
  private async processBatch(type: RequestType): Promise<void> {
    const batch = this.batchCache.get(type);
    if (!batch || batch.length === 0) {
      return;
    }
    
    // 清空批量缓存
    this.batchCache.set(type, []);
    
    // 根据类型执行批量请求
    if (type === RequestType.GET_CHAT) {
      await this.processBatchGetChats(batch);
    } else if (type === RequestType.GET_USER) {
      await this.processBatchGetUsers(batch);
    } else {
      // 其他类型逐个处理
      for (const request of batch) {
        this.requestQueue.push(request);
      }
      this.requestQueue.sort((a, b) => b.priority - a.priority);
    }
    
    this.processQueue();
  }

  /**
   * 批量获取聊天（参考微信/QQ的批量请求策略）
   */
  private async processBatchGetChats(requests: RequestItem[]): Promise<void> {
    try {
      // 提取所有聊天ID
      const chatIds: number[] = [];
      const requestMap: Map<number, RequestItem> = new Map();
      
      for (const request of requests) {
        const chatId = request.params['chat_id'] as number | undefined;
        if (chatId !== undefined) {
          chatIds.push(chatId);
          requestMap.set(chatId, request);
        }
      }
      
      if (chatIds.length === 0) {
        return;
      }
      
      // 批量获取聊天信息
      const CoreService = (await import('../business/CoreService')).CoreService.getInstance();
            
      // 为每个请求解析响应（逐个获取）
      for (const entry of requestMap.entries()) {
        const chatId = entry[0];
        const request = entry[1];
        try {
          const chatResult = await CoreService.getChat(chatId);
          if (chatResult) {
            const chat = chatResult;
            // 将 Chat 对象转换为 Record<string, Object>（使用项目中定义的 Chat 接口属性）
            const response: Record<string, Object> = {
              '@type': 'chat',
              'id': chat.id,
              'type': chat.type,
              'title': chat.title,
              'unread_count': chat.unreadCount,
              'is_pinned': chat.isPinned,
              'timestamp': chat.timestamp
            };
            // 添加可选属性
            if (chat.avatar !== undefined) {
              response['avatar'] = chat.avatar;
            }
            if (chat.lastMessage !== undefined) {
              response['last_message'] = chat.lastMessage as ESObject;
            }
            if (chat.isMuted !== undefined) {
              response['is_muted'] = chat.isMuted;
            }
            if (chat.membersCount !== undefined) {
              response['members_count'] = chat.membersCount;
            }
            // ArkTS: 使用类型安全的方式访问属性
            if (chat.lastReadMessageId !== undefined) {
              response['last_read_message_id'] = chat.lastReadMessageId;
            }
            if (chat.description !== undefined) {
              response['description'] = chat.description;
            }
            if (chat.secretChatId !== undefined) {
              response['secret_chat_id'] = chat.secretChatId;
            }
            request.status = RequestStatus.COMPLETED;
            request.resolve(response);
            this.requestDedupeCache.delete(request.id);
          } else {
            request.status = RequestStatus.FAILED;
            request.reject(new Error(`Chat ${chatId} not found`));
            this.requestDedupeCache.delete(request.id);
          }
        } catch (error) {
          request.status = RequestStatus.FAILED;
          request.reject(error instanceof Error ? error : new Error(String(error)));
          this.requestDedupeCache.delete(request.id);
        }
      }
    } catch (error) {
      // 批量请求失败，逐个重试
      for (const request of requests) {
        request.status = RequestStatus.FAILED;
        request.reject(error instanceof Error ? error : new Error(String(error)));
        this.requestDedupeCache.delete(request.id);
      }
    }
  }

  /**
   * 批量获取用户（参考微信/QQ 的批量请求策略）
   */
  private async processBatchGetUsers(requests: RequestItem[]): Promise<void> {
    try {
      // 提取所有用户 ID
      const userIds: number[] = [];
      const requestMap: Map<number, RequestItem> = new Map();
        
      for (const request of requests) {
        const userId = request.params['user_id'] as number | undefined;
        if (userId !== undefined) {
          userIds.push(userId);
          requestMap.set(userId, request);
        }
      }
        
      if (userIds.length === 0) {
        return;
      }
        
      // 逐个获取用户信息
      for (const entry of requestMap.entries()) {
        const userId = entry[0];
        const request = entry[1];
        try {
          // 使用 TDLib API 获取用户信息
          const userResult = await this.tdClient.execute<Record<string, Object>>({ '@type': 'getUser', 'user_id': userId } as Record<string, Object>);
            
          if (userResult && (userResult as Record<string, string>)['@type'] === 'user') {
            request.status = RequestStatus.COMPLETED;
            request.resolve(userResult as Record<string, Object>);
            this.requestDedupeCache.delete(request.id);
          } else {
            request.status = RequestStatus.FAILED;
            request.reject(new Error(`User ${userId} not found`));
            this.requestDedupeCache.delete(request.id);
          }
        } catch (error) {
          request.status = RequestStatus.FAILED;
          request.reject(error instanceof Error ? error : new Error(String(error)));
          this.requestDedupeCache.delete(request.id);
        }
      }
    } catch (error) {
      // 批量请求失败，逐个重试
      for (const request of requests) {
        request.status = RequestStatus.FAILED;
        request.reject(error instanceof Error ? error : new Error(String(error)));
        this.requestDedupeCache.delete(request.id);
      }
    }
  }

  /**
   * 启动队列处理器（参考微信/QQ的请求队列策略）
   */
  private startQueueProcessor(): void {
    // 每50ms处理一次队列
    setInterval(() => {
      this.processQueue();
    }, 50);
  }

  /**
   * 处理请求队列（参考微信/QQ的并发控制策略）
   */
  private async processQueue(): Promise<void> {
    // 检查并发限制
    if (this.currentConcurrent >= this.maxConcurrent) {
      return;
    }
    
    // 检查网络状态
    if (!this.networkOptimizer.isConnected()) {
      return;
    }
    
    // 从队列中取出请求
    if (this.requestQueue.length === 0) {
      return;
    }
    
    const request = this.requestQueue.shift();
    if (!request) {
      return;
    }
    
    // 执行请求
    this.currentConcurrent++;
    request.status = RequestStatus.RUNNING;
    this.runningRequests.set(request.id, request);
    
    this.executeRequest(request).finally(() => {
      this.currentConcurrent--;
      this.runningRequests.delete(request.id);
      this.processQueue();
    });
  }

  /**
   * 执行请求（带重试机制，参考微信/QQ的智能重试策略）
   */
  private async executeRequest(request: RequestItem): Promise<void> {
    try {
      const response: Record<string, Object> = await this.tdClient.execute(request.params) as Record<string, Object>;
      
      if (response) {
        request.status = RequestStatus.COMPLETED;
        request.resolve(response);
        this.requestDedupeCache.delete(request.id);
      } else {
        throw new Error('Request returned null');
      }
    } catch (error) {
      // 重试逻辑（参考微信/QQ的智能重试策略）
      if (request.retryCount < request.maxRetries) {
        request.retryCount++;
        
        // 根据网络状态决定重试延迟
        const retryDelay = this.getRetryDelay(request.retryCount);
        
        setTimeout(() => {
          request.status = RequestStatus.PENDING;
          this.requestQueue.push(request);
          this.requestQueue.sort((a, b) => b.priority - a.priority);
          this.processQueue();
        }, retryDelay);
      } else {
        request.status = RequestStatus.FAILED;
        request.reject(error instanceof Error ? error : new Error(String(error)));
        this.requestDedupeCache.delete(request.id);
        hilog.error(DOMAIN, TAG, `Request failed after ${request.maxRetries} retries: ${request.id}`);
      }
    }
  }

  /**
   * 获取重试延迟（指数退避，参考微信/QQ的重试策略）
   */
  private getRetryDelay(retryCount: number): number {
    const baseDelay = 1000; // 1秒
    const maxDelay = 10000; // 10秒
    const delay = Math.min(baseDelay * Math.pow(2, retryCount - 1), maxDelay);
    
    // 弱网时增加延迟
    if (this.networkOptimizer.isWeakNetwork()) {
      return delay * 2;
    }
    
    return delay;
  }

  /**
   * 获取最大重试次数（根据请求类型和网络状态）
   */
  private getMaxRetries(type: RequestType): number {
    // 弱网时增加重试次数
    if (this.networkOptimizer.isWeakNetwork()) {
      return 5;
    }
    
    // 根据请求类型设置重试次数
    switch (type) {
      case RequestType.DOWNLOAD_FILE:
      case RequestType.UPLOAD_FILE:
        return 3; // 文件操作重试3次
      default:
        return 2; // 普通请求重试2次
    }
  }

  /**
   * 取消请求
   */
  public cancelRequest(requestId: string): void {
    const request = this.requestDedupeCache.get(requestId);
    if (request) {
      request.status = RequestStatus.CANCELLED;
      request.reject(new Error('Request cancelled'));
      this.requestDedupeCache.delete(requestId);
      
      // 从队列中移除
      const index = this.requestQueue.indexOf(request);
      if (index >= 0) {
        this.requestQueue.splice(index, 1);
      }
      
      // 从运行中移除
      this.runningRequests.delete(requestId);
    }
  }

  /**
   * 清理资源
   */
  public dispose(): void {
    if (this.batchTimer) {
      clearTimeout(this.batchTimer);
      this.batchTimer = 0;
    }
    this.requestQueue = [];
    this.runningRequests.clear();
    this.batchCache.clear();
    this.requestDedupeCache.clear();
  }
}
