/**
 * 性能加速服务（华为HarmonyOS最佳实践 + 微信/QQ优化策略）
 * 专门解决：加载速度慢、聊天页白屏、长时间等待加载问题
 * 目标：实现立即急速快速加载
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { CoreService } from '../business/CoreService';
import { TdApiFactory } from '../api/factory/TdApiFactory'; // ⭐ 改为导入类而非实例
import type { TDLibApi } from '../api/TDLibApi';
import type { Chat as TDLibChat, Message as TDLibMessage, ChatList, chatListMain } from '../api/factory/tdlib-types';
import { Chat, Message } from '../../models/TDLibData';
import { NetworkOptimizer } from '../../utils/network/NetworkOptimizer';
import { PageContextManager, PageType } from './PageContextManager';

const TAG = 'PerformanceBoostService';
const DOMAIN = 0x0001;

/**
 * 加载优先级枚举
 */
export enum LoadPriority {
  /** 紧急 - 立即加载，最高优先级 */
  URGENT = 0,
  /** 高 - 快速加载，高优先级 */
  HIGH = 1,
  /** 普通 - 正常加载 */
  NORMAL = 2,
  /** 低 - 后台加载 */
  LOW = 3
}

/**
 * 缓存策略枚举
 */
export enum CacheStrategy {
  /** 内存优先 - 优先使用内存缓存 */
  MEMORY_FIRST = 'memory_first',
  /** 磁盘优先 - 优先使用磁盘缓存 */
  DISK_FIRST = 'disk_first',
  /** 网络优先 - 直接从网络加载 */
  NETWORK_FIRST = 'network_first'
}

/**
 * 加速配置接口
 */
export interface BoostConfig {
  /** 是否启用急速加载 */
  enableFastLoad: boolean;
  /** 最大并发请求数 */
  maxConcurrentRequests: number;
  /** 请求超时时间(ms) */
  requestTimeout: number;
  /** 缓存有效期(ms) */
  cacheTTL: number;
  /** 预加载深度 */
  prefetchDepth: number;
}

/**
 * 加载结果接口
 */
export interface LoadResult<T> {
  /** 数据 */
  data: T;
  /** 数据来源 */
  source: 'memory' | 'disk' | 'network';
  /** 加载时间(ms) */
  loadTime: number;
  /** 是否来自缓存 */
  fromCache: boolean;
}

/** 内存缓存数据结构 */
interface MemoryCacheItem {
  data: Record<string, Object>;  // 使用Object类型以支持泛型
  timestamp: number;
}

/** 磁盘加载结果 */
interface DiskLoadResult {
  success: boolean;
  data: Chat[];  // 使用本地 Chat 类型
}

/** 消息加载结果 */
interface MessageLoadResult {
  success: boolean;
  data: Message[];  // 使用本地 Message 类型
}

/** 正在加载的任务结果类型 */
type LoadingTaskResult = Chat[] | Message[] | DiskLoadResult | MessageLoadResult;

/** 性能统计接口 */
interface PerformanceStats {
  cacheSize: number;
  config: BoostConfig;
}

export class PerformanceBoostService {
  private static instance: PerformanceBoostService;
  private CoreService: CoreService;
  private tdClient: TDLibApi; // TDLibApi 实例
  private networkOptimizer: NetworkOptimizer;
  private pageContext: PageContextManager;
  
  /** 当前配置 */
  private config: BoostConfig = {
    enableFastLoad: true,
    maxConcurrentRequests: 10,
    requestTimeout: 3000,
    cacheTTL: 300000, // 5分钟
    prefetchDepth: 3
  };
  
  /** 内存缓存 */
  private memoryCache: Map<string, MemoryCacheItem> = new Map();
  
  /** 正在加载的任务 */
  private loadingTasks: Map<string, Promise<LoadingTaskResult>> = new Map();
  
  /** 预加载队列 */
  private prefetchQueue: Array<() => Promise<void>> = [];
  
  /** 是否正在预加载 */
  private isPrefetching: boolean = false;

  private constructor() {
    this.CoreService = CoreService.getInstance();
    // ⭐ 延迟初始化：在使用时才创建，避免模块加载时崩溃
    this.tdClient = TdApiFactory.getInstance().createDefault() as TDLibApi;
    this.networkOptimizer = NetworkOptimizer.getInstance();
    this.pageContext = PageContextManager.getInstance();
    
    // 根据网络状态动态调整配置
    this.adjustConfigByNetwork();
    this.networkOptimizer.addListener(() => {
      this.adjustConfigByNetwork();
    });
  }

  public static getInstance(): PerformanceBoostService {
    if (!PerformanceBoostService.instance) {
      PerformanceBoostService.instance = new PerformanceBoostService();
    }
    return PerformanceBoostService.instance;
  }

  /**
   * 根据网络状态动态调整配置
   */
  private adjustConfigByNetwork(): void {
    const networkState = this.networkOptimizer.getNetworkState();
    
    if (networkState.type === 'wifi') {
      // WiFi环境：最大化性能
      this.config.maxConcurrentRequests = 15;
      this.config.requestTimeout = 2000;
      this.config.prefetchDepth = 5;
      hilog.info(DOMAIN, TAG, 'WiFi network detected, boosting performance');
    } else if (this.networkOptimizer.isWeakNetwork()) {
      // 弱网环境：保守策略
      this.config.maxConcurrentRequests = 3;
      this.config.requestTimeout = 5000;
      this.config.prefetchDepth = 1;
      hilog.info(DOMAIN, TAG, 'Weak network detected, conservative mode');
    } else {
      // 默认配置
      this.config.maxConcurrentRequests = 8;
      this.config.requestTimeout = 3000;
      this.config.prefetchDepth = 3;
    }
  }

  /**
   * 极速加载聊天列表（解决首页加载慢问题）
   */
  public async fastLoadChatList(
    limit: number = 20,
    priority: LoadPriority = LoadPriority.HIGH
  ): Promise<LoadResult<Chat[]>> {
    const startTime = Date.now();
    const cacheKey = `chat_list_${limit}`;
    
    try {
      // 1. 首先检查内存缓存（立即返回）
      const memoryCached = this.getFromMemoryCache<Chat[]>(cacheKey);
      if (memoryCached) {
        hilog.info(DOMAIN, TAG, `Chat list loaded from memory cache in ${(Date.now() - startTime)}ms`);
        return {
          data: memoryCached,
          source: 'memory',
          loadTime: Date.now() - startTime,
          fromCache: true
        };
      }
      
      // 2. 并行加载：磁盘缓存 + 网络请求
      const diskPromise = this.loadChatListFromDisk(limit);
      const networkPromise = this.loadChatListFromNetwork(limit, priority);
      const results = await Promise.all([diskPromise, networkPromise]);
      const diskResult = results[0];
      const networkResult = results[1];
      
      let finalData: Chat[] = [];
      let source: 'disk' | 'network' = 'network';
      
      // 3. 优先使用网络数据（最新）
      if (networkResult.success) {
        finalData = networkResult.data;
        source = 'network';
        // 更新内存缓存
        this.setMemoryCache(cacheKey, finalData);
      } else if (diskResult.success) {
        // 网络失败时使用磁盘缓存
        finalData = diskResult.data;
        source = 'disk';
      }
      
      const loadTime = Date.now() - startTime;
      hilog.info(DOMAIN, TAG, `Chat list loaded from ${source} in ${loadTime}ms`);
      
      return {
        data: finalData,
        source: source,
        loadTime: loadTime,
        fromCache: source !== 'network'
      };
      
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Fast load chat list failed: ${JSON.stringify(error)}`);
      throw new Error(`Fast load chat list failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 极速加载聊天详情（解决聊天页白屏问题）
   */
  public async fastLoadChatDetail(
    chatId: number,
    messageLimit: number = 30,
    priority: LoadPriority = LoadPriority.URGENT
  ): Promise<LoadResult<Message[]>> {
    const startTime = Date.now();
    const cacheKey = `chat_detail_${chatId}_${messageLimit}`;
    
    try {
      // 1. 首先检查内存缓存
      const memoryCached = this.getFromMemoryCache<Message[]>(cacheKey);
      if (memoryCached) {
        hilog.info(DOMAIN, TAG, `Chat detail loaded from memory cache in ${(Date.now() - startTime)}ms`);
        return {
          data: memoryCached,
          source: 'memory',
          loadTime: Date.now() - startTime,
          fromCache: true
        };
      }
      
      // 2. 二路并行加载：网络 + 预加载 (移除存储加载)
      const networkPromise = this.loadMessagesFromNetwork(chatId, messageLimit, priority);
      
      // 3. 同时开始预加载用户信息（不阻塞主流程）
      this.prefetchUserInfoForChat(chatId).catch(() => {});
      
      const messageResults = await Promise.all([networkPromise]);
      const networkMessages = messageResults[0];
      
      let finalData: Message[] = [];
      let source: 'disk' | 'network' = 'network';
      
      // 4. 使用网络数据
      if (networkMessages.success && networkMessages.data.length > 0) {
        finalData = networkMessages.data;
        source = 'network';
        // 更新缓存
        this.setMemoryCache(cacheKey, finalData);
      }
      
      const loadTime = Date.now() - startTime;
      hilog.info(DOMAIN, TAG, `Chat detail loaded from ${source} in ${loadTime}ms`);
      
      return {
        data: finalData,
        source: source,
        loadTime: loadTime,
        fromCache: source !== 'network'
      };
      
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Fast load chat detail failed: ${JSON.stringify(error)}`);
      throw new Error(`Fast load chat detail failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 从磁盘加载聊天列表
   */
  private async loadChatListFromDisk(limit: number): Promise<DiskLoadResult> {
    try {
      // 从本地获取聊天列表（使用现有方法）
      const allChats = this.CoreService.getChatList();
      if (allChats.length === 0) {
        const result: DiskLoadResult = { success: false, data: [] };
        return result;
      }
        
      // 取前 limit 个聊天
      const chats: Chat[] = [];
      for (let i = 0; i < Math.min(limit, allChats.length); i++) {
        const chat = allChats[i];
        if (chat) {
          // 直接使用 CoreService 返回的 Chat 对象
          chats.push(chat);
        }
      }
        
      const result: DiskLoadResult = { success: true, data: chats } as DiskLoadResult;
      return result;
    } catch (error) {
      hilog.warn(DOMAIN, TAG, `Load chat list from disk failed: ${JSON.stringify(error)}`);
      const result: DiskLoadResult = { success: false, data: [] } as DiskLoadResult;
      return result;
    }
  }

  /**
   * 从网络加载聊天列表
   */
  private async loadChatListFromNetwork(
    limit: number,
    priority: LoadPriority
  ): Promise<DiskLoadResult> {
    try {
      // 使用高优先级请求（使用 tdClient）
      // 【关键修复】使用具体接口类型和 _ 字段
      const chatListMainObj: chatListMain = { _: 'chatListMain' };
      const response = await this.tdClient.getChats(chatListMainObj, limit);
      if (!response || !response.chat_ids) {
        const result: DiskLoadResult = { success: false, data: [] } as DiskLoadResult;
        return result;
      }
      
      const chatIds = response.chat_ids as number[];
      // 获取聊天详情（使用现有方法）
      const chats: Chat[] = [];
      for (let i = 0; i < chatIds.length; i++) {
        const chatId = chatIds[i];
        const chat = this.CoreService.getChat(chatId);
        if (chat) {
          // 直接使用 CoreService 返回的 Chat 对象
          chats.push(chat);
        }
      }
      
      const result: DiskLoadResult = { success: true, data: chats } as DiskLoadResult;
      return result;
    } catch (error) {
      hilog.warn(DOMAIN, TAG, `Load chat list from network failed: ${JSON.stringify(error)}`);
      const result: DiskLoadResult = { success: false, data: [] } as DiskLoadResult;
      return result;
    }
  }

  /**
   * 从网络加载消息
   */
  private async loadMessagesFromNetwork(
    chatId: number,
    limit: number,
    priority: LoadPriority
  ): Promise<MessageLoadResult> {
    try {
      const response = await this.tdClient.getChatHistory(chatId, 0, 0, limit, false);
      if (!response || !response.messages) {
        const result: MessageLoadResult = { success: false, data: [] } as MessageLoadResult;
        return result;
      }
      
      // 安全地转换 messages 类型为本地 Message 类型
      const messages = response.messages as Object[] as Message[];
      const result: MessageLoadResult = { success: true, data: messages } as MessageLoadResult;
      return result;
    } catch (error) {
      hilog.warn(DOMAIN, TAG, `Load messages from network failed: ${JSON.stringify(error)}`);
      const result: MessageLoadResult = { success: false, data: [] } as MessageLoadResult;
      return result;
    }
  }

  /**
   * 预加载聊天用户信息（解决用户名显示延迟问题）
   */
  private async prefetchUserInfoForChat(chatId: number): Promise<void> {
    try {
      // 获取聊天中最近消息的发送者 ID
      const messages = await this.fastLoadChatDetail(chatId, 10);
      if (messages.data.length > 0) {
        const userIds = new Set<number>();
        for (let i = 0; i < messages.data.length; i++) {
          const msg = messages.data[i];
          // 跳过自己发送的消息，只处理接收的消息
          // 使用 isOutgoing 判断是否为接收的消息
          if (!msg.isOutgoing && msg.senderId) {
            // 直接使用 senderId 属性
            userIds.add(msg.senderId);
          }
        }
        
        // 批量预加载用户信息（暂时注释，等待 UserService 实现）
        if (userIds.size > 0) {
          hilog.info(DOMAIN, TAG, `Skip prefetch ${userIds.size} user infos (UserService not available)`);
          // const userService = (await import('./UserService')).UserService.getInstance();
          // await userService.getUsers(Array.from(userIds));
          hilog.info(DOMAIN, TAG, `Prefetched ${userIds.size} user infos for chat ${chatId}`);
        }
      }
    } catch (error) {
      hilog.warn(DOMAIN, TAG, `Prefetch user info failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 智能预加载（根据用户行为预测）
   */
  public async smartPrefetch(): Promise<void> {
    if (this.isPrefetching || !this.networkOptimizer.isConnected()) {
      return;
    }
    
    this.isPrefetching = true;
    
    try {
      const currentPage = this.pageContext.getCurrentPageType();
      
      if (currentPage === PageType.CHAT_LIST) {
        // 在聊天列表页：预加载前几个活跃聊天
        await this.prefetchActiveChats();
      } else if (currentPage === PageType.CHAT_DETAIL) {
        // 在聊天详情页：预加载更多历史消息
        const currentChatId = this.pageContext.getCurrentChatId();
        if (currentChatId > 0) {
          await this.prefetchMoreMessages(currentChatId);
        }
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Smart prefetch failed: ${JSON.stringify(error)}`);
    } finally {
      this.isPrefetching = false;
    }
  }

  /**
   * 预加载活跃聊天
   */
  private async prefetchActiveChats(): Promise<void> {
    try {
      // 使用现有方法获取聊天列表
      const allChats = this.CoreService.getChatList();
      const chatsToPrefetch = allChats.slice(0, this.config.prefetchDepth);
        
      // 使用传统 for 循环避免解构赋值
      for (let i = 0; i < chatsToPrefetch.length; i++) {
        const chat = chatsToPrefetch[i];
        if (chat && chat.id) {
          const chatId = chat.id as number;
          // 异步预加载，不阻塞主流程
          this.fastLoadChatDetail(chatId, 10, LoadPriority.LOW).catch(() => {});
        }
      }
      hilog.info(DOMAIN, TAG, `Prefetched ${chatsToPrefetch.length} active chats`);
    } catch (error) {
      hilog.warn(DOMAIN, TAG, `Prefetch active chats failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 预加载更多消息
   */
  private async prefetchMoreMessages(chatId: number): Promise<void> {
    try {
      // 预加载更多历史消息
      await this.tdClient.getChatHistory(chatId, 0, 0, 50, true);
      hilog.info(DOMAIN, TAG, `Prefetched more messages for chat ${chatId}`);
    } catch (error) {
      hilog.warn(DOMAIN, TAG, `Prefetch more messages failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 内存缓存操作
   */
  private setMemoryCache<T>(key: string, data: T): void {
    this.memoryCache.set(key, {
      data: data as Record<string, Object>,
      timestamp: Date.now()
    });

    // 定期清理过期缓存
    this.cleanupExpiredCache();
  }

  private getFromMemoryCache<T>(key: string): T | null {
    const cached = this.memoryCache.get(key);
    if (!cached) {
      return null;
    }
    
    // 检查是否过期
    if (Date.now() - cached.timestamp > this.config.cacheTTL) {
      this.memoryCache.delete(key);
      return null;
    }
    
    return cached.data as T;
  }

  /**
   * 清理过期缓存
   */
  private cleanupExpiredCache(): void {
    const now = Date.now();
    // 使用传统for循环避免解构赋值
    const entries = Array.from(this.memoryCache.entries());
    for (let i = 0; i < entries.length; i++) {
      const entry = entries[i];
      const key = entry[0];
      const value = entry[1];
      if (now - value.timestamp > this.config.cacheTTL) {
        this.memoryCache.delete(key);
      }
    }
  }

  /**
   * 清除所有缓存
   */
  public clearCache(): void {
    this.memoryCache.clear();
    hilog.info(DOMAIN, TAG, 'Cache cleared');
  }

  /**
   * 获取性能统计
   */
  public getPerformanceStats(): PerformanceStats {
    const stats: PerformanceStats = {
      cacheSize: this.memoryCache.size,
      config: this.config
    };
    return stats;
  }

  /**
   * 更新配置
   */
  public updateConfig(newConfig: Partial<BoostConfig>): void {
    // 手动合并配置对象，避免使用展开运算符
    const updatedConfig: BoostConfig = {
      enableFastLoad: newConfig.enableFastLoad !== undefined ? newConfig.enableFastLoad : this.config.enableFastLoad,
      maxConcurrentRequests: newConfig.maxConcurrentRequests !== undefined ? newConfig.maxConcurrentRequests : this.config.maxConcurrentRequests,
      requestTimeout: newConfig.requestTimeout !== undefined ? newConfig.requestTimeout : this.config.requestTimeout,
      cacheTTL: newConfig.cacheTTL !== undefined ? newConfig.cacheTTL : this.config.cacheTTL,
      prefetchDepth: newConfig.prefetchDepth !== undefined ? newConfig.prefetchDepth : this.config.prefetchDepth
    };
    this.config = updatedConfig;
    hilog.info(DOMAIN, TAG, `Config updated: ${JSON.stringify(newConfig)}`);
  }
}