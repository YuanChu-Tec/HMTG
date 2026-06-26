import { hilog } from '@kit.PerformanceAnalysisKit';
import { worker, MessageEvents } from '@kit.ArkTS';
import { getTdLibParameters } from '../config/TelegramConfig';
import { common } from '@kit.AbilityKit';
import { TDLibReceiver } from './TDLibReceiver';
import { MessageType, ControlCommand, ExecuteResult, Update, BatchUpdateMessage, ErrorMessage, Request, Response, Control } from '../../../workers/TdlibWorkerProtocol';

const TAG = 'TDLibClient';
const DOMAIN = 0x0001;

/**
 * TDLib 连接状态枚举
 */
export enum ConnectionState {
  DISCONNECTED = 'disconnected',
  CONNECTING = 'connecting',
  CONNECTED = 'connected',
  RECONNECTING = 'reconnecting',
  ERROR = 'error'
}

/**
 * 连接事件监听器
 */
export type ConnectionEventListener = (state: ConnectionState, data?: Object) => void;

/**
 * 更新回调类型
 */
export type UpdateCallback = (update: Record<string, Object>) => void;

interface CallbackPair {
  resolve: (value: Object) => void;
  reject: (reason?: Error) => void;
}

interface ErrorInfo {
  code?: number;
  message?: string;
}

// TDLib API 请求参数接口
interface GetChatParams extends Record<string, Object> {
  chat_id: number;
}

export class TDLibClient {
  private static instance: TDLibClient;
  private tdWorker: worker.ThreadWorker | null = null;
  private pendingExecutes: Map<string, CallbackPair> = new Map();
  // ⭐ 新增：pendingRequests 映射表（用于 REQUEST/RESPONSE 机制）
  private pendingRequests: Map<string, CallbackPair> = new Map();
  private updateCallbacks: UpdateCallback[] = [];
  private connectionListeners: Set<ConnectionEventListener> = new Set();
  private readyListeners: Array<() => void> = []; // ⭐ 就绪监听器队列
  private requestIdCounter: number = 0;
  private isWorkerReady: boolean = false;
  private connectionState: ConnectionState = ConnectionState.DISCONNECTED;
  private context?: common.UIAbilityContext;
  
  // ⭐ 心跳检测相关
  private heartbeatTimer: number | null = null;
  private readonly HEARTBEAT_INTERVAL: number = 30000; // 30 秒
  
  // ⭐ 自动重连相关
  private reconnectAttempts: number = 0;
  private readonly MAX_RECONNECT_ATTEMPTS: number = 5;
  private readonly RECONNECT_DELAY: number = 3000;
  private readonly RECONNECT_BACKOFF_MULTIPLIER: number = 1.5;
  private isReconnecting: boolean = false;
  private shouldAutoReconnect: boolean = true;

  private constructor() {
    hilog.info(DOMAIN, TAG, 'TDLibClient proxy created');
  }

  public static getInstance(): TDLibClient {
    if (!TDLibClient.instance) {
      TDLibClient.instance = new TDLibClient();
    }
    return TDLibClient.instance;
  }

  /**
   * 初始化 TDLib Worker（带自动重连逻辑预留）
   * @param context UIAbilityContext
   */
  public async initialize(context: common.UIAbilityContext, customParameters?: Record<string, Object>): Promise<void> {
    if (this.tdWorker) {
      hilog.warn(DOMAIN, TAG, 'Worker already initialized');
      return;
    }

    this.context = context;
    this.setConnectionState(ConnectionState.CONNECTING);

    try {
      // 1. 创建 Worker 实例
      // ⭐ 修复：使用相对于当前文件的路径
      // TDLibClient.ets 在 services/core/tdlib/，需要向上 3 级回到 ets/，然后进入 workers/
      this.tdWorker = new worker.ThreadWorker('../../../workers/TdlibWorker.ets');
      
      // 2. 设置消息监听
      this.tdWorker.onmessage = (e: MessageEvents) => {
        const data = e.data as Record<string, Object>;
        this.handleWorkerMessage(data);
      };
      this.tdWorker.onerror = (): void => {
        hilog.error(DOMAIN, TAG, 'Worker encountered an error');
        this.setConnectionState(ConnectionState.ERROR);
        
        // ⭐ 触发自动重连
        if (this.shouldReconnect()) {
          this.scheduleReconnect();
        }
      };

      // 3. 获取参数并发送给 Worker
      const parameters = await getTdLibParameters(context);
      if (customParameters) {
        const paramKeys: string[] = Object.keys(customParameters);
        for (let i = 0; i < paramKeys.length; i++) {
          const key = paramKeys[i];
          parameters[key] = customParameters[key];
        }
      }

      hilog.info(DOMAIN, TAG, 'Sending init parameters to Worker...');
      
      // ⭐ 关键修复：添加短暂延迟，确保 TDLib 内部状态机完全就绪
      // 原因：Worker 线程刚启动时，TDLib 需要时间初始化内部状态机
      // 如果立即发送 setTdlibParameters，可能会因为时序问题被拒绝
      // 延迟 100ms 可以大幅降低首次失败的概率（从 ~15ms 失败率降至几乎为 0）
      await this.sleep(100);
      
      // ⭐ 使用协议类型发送初始化命令
      this.tdWorker.postMessage({ 
        type: ControlCommand.INIT,  // 直接使用命令类型作为消息类型
        parameters: parameters      // 参数直接在顶层
      });

    } catch (error) {
      this.setConnectionState(ConnectionState.ERROR);
      const err = error as Error;
      hilog.error(DOMAIN, TAG, `Failed to initialize Worker: ${err.message}`);
      throw new Error(`Failed to initialize Worker: ${err.message}`);
    }
  }

  /**
   * 处理来自 Worker 的消息
   */
  private handleWorkerMessage(msg: Record<string, Object>): void {
    const type = msg['type'] as string;
    switch (type) {
      case MessageType.CONTROL: {
        // ⭐ 处理控制消息（如 READY、HEARTBEAT_ACK）
        const command = msg['command'] as string | undefined;
        if (command === ControlCommand.READY) {
          this.isWorkerReady = true;
          this.setConnectionState(ConnectionState.CONNECTED);
          hilog.info(DOMAIN, TAG, 'TDLib Worker is ready');
          
          // ⭐ 通知所有等待就绪的监听器
          this.readyListeners.forEach(cb => cb());
          this.readyListeners = []; // 清空监听器，避免内存泄漏
          
          // ⭐ 启动心跳
          this.startHeartbeat();
        } else if (command === ControlCommand.HEARTBEAT_ACK) {
          // 心跳响应正常
          hilog.debug(DOMAIN, TAG, 'Heartbeat ACK received');
        }
        break;
      }

      // ⭐ 新增：处理 RESPONSE 消息（异步请求响应）
      case MessageType.RESPONSE: {
        const requestId = msg['requestId'] as string;
        const success = msg['success'] as boolean;
        const result = msg['result'] as Record<string, Object> | undefined;
        const error = msg['error'] as ErrorInfo | undefined;
        
        // ⭐ 先查找 pendingRequests（call 方法注册的回调）
        let callback = this.pendingRequests.get(requestId);
        if (callback) {
          this.pendingRequests.delete(requestId);
          if (success && result) {
            callback.resolve(result);
          } else {
            const errorMsg = error?.message || 'Unknown error';
            callback.reject(new Error(errorMsg));
          }
          break;
        }
        
        // ⭐ 再查找 pendingExecutes（execute 方法注册的回调）
        const executeCallback = this.pendingExecutes.get(requestId);
        if (executeCallback) {
          this.pendingExecutes.delete(requestId);
          if (success && result) {
            executeCallback.resolve(result);
          } else {
            const errorMsg = error?.message || 'Unknown error';
            executeCallback.reject(new Error(errorMsg));
          }
          break;
        }
        
        // 都没找到，记录警告
        hilog.warn(DOMAIN, TAG, `No callback found for request: ${requestId}`);
        break;
      }

      case MessageType.EXECUTE_RESULT: {
        // ⭐ 处理 execute 请求的响应
        const id = msg['id'] as string;
        const result = msg['result'] as Record<string, Object> | null;
        const error = msg['error'] as string | undefined;
        this.handleExecuteResult(id, result, error);
        break;
      }

      case MessageType.UPDATE: {
        const updateType = msg['updateType'] as string;
        const data = msg['data'] as Record<string, Object> | undefined;
        if (data && typeof data === 'object') {
          this.notifyUpdate(data);
        }
        break;
      }

      case MessageType.BATCH_UPDATE: {
        const updates = msg['updates'] as Array<Record<string, Object>> | undefined;
        if (updates && Array.isArray(updates)) {
          for (let i = 0; i < updates.length; i++) {
            this.notifyUpdate(updates[i]);
          }
        }
        break;
      }

      case MessageType.ERROR: {
        const errorMessage = msg['message'] as string;
        hilog.error(DOMAIN, TAG, `Worker reported error: ${errorMessage}`);
        break;
      }

      default:
        hilog.warn(DOMAIN, TAG, `Unknown message type from Worker: ${type}`);
    }
  }

  /**
   * 处理 execute 响应
   */
  private handleExecuteResult(id: string, result: Object | null, error: string | undefined): void {
    const callback = this.pendingExecutes.get(id);
    if (callback) {
      this.pendingExecutes.delete(id);
      if (error) {
        callback.reject(new Error(error));
      } else {
        callback.resolve(result ? result : {} as Record<string, Object>);
      }
    }
  }

  /**
   * 通知所有更新监听器
   */
  private notifyUpdate(update: Record<string, Object>): void {
    // ⭐ 关键修复：将 Worker 更新转发给 TDLibReceiver 处理
    try {
      const receiver = TDLibReceiver.getInstance();
      receiver.handleWorkerUpdate(update);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Forward to TDLibReceiver failed: ${error}`);
    }
    
    // 同时通知其他注册的监听器
    this.updateCallbacks.forEach(cb => {
      try {
        cb(update);
      } catch (e) {
        hilog.error(DOMAIN, TAG, `Update callback error: ${e}`);
      }
    });
  }

  /**
   * 注册就绪回调（如果已就绪则立即执行）
   */
  public onReady(callback: () => void): void {
    if (this.isWorkerReady) {
      callback();
    } else {
      this.readyListeners.push(callback);
    }
  }

  /**
   * 获取就绪 Promise
   */
  public getReadyPromise(): Promise<void> {
    return new Promise((resolve) => {
      if (this.isWorkerReady) {
        resolve();
      } else {
        this.readyListeners.push(resolve);
      }
    });
  }

  /**
   * 发送请求到 TDLib（不等待响应）
   */
  public sendRequest(request: Record<string, Object>): void {
    if (!this.tdWorker || !this.isWorkerReady) {
      hilog.warn(DOMAIN, TAG, 'Worker not ready, request dropped');
      return;
    }
    // ⭐ 使用 REQUEST 消息类型
    this.tdWorker.postMessage({ 
      type: MessageType.REQUEST,
      id: `req_noresp_${++this.requestIdCounter}`,  // ⭐ 简化 ID 格式
      timestamp: Date.now(),
      method: request['@type'] as string,
      params: request,
      expectResponse: false
    });
  }

  /**
   * ⭐ 新增：call 方法（Promise 化的异步调用，支持响应）
   * @param method TDLib API 方法名
   * @param params 方法参数
   * @param timeout 超时时间 (毫秒)，默认 30 秒
   * @returns Promise<T> 返回结果
   */
  public async call<T>(method: string, params: Record<string, Object>, timeout?: number): Promise<T> {
    return new Promise((resolve: (value: T) => void, reject: (reason?: Error) => void) => {
      if (!this.tdWorker || !this.isWorkerReady) {
        reject(new Error('TDLib Worker is not ready'));
        return;
      }
      
      // ⭐ 修复：使用简洁的 requestId 格式，避免被 TDLib 截断
      const requestId = `req_${++this.requestIdCounter}`;
      const actualTimeout = timeout ?? 30000; // 默认 30 秒
      
      // 设置超时处理
      const timeoutId = setTimeout(() => {
        if (this.pendingRequests.has(requestId)) {
          this.pendingRequests.delete(requestId);
          reject(new Error(`Request timeout after ${actualTimeout}ms`));
        }
      }, actualTimeout);
      
      // 注册回调
      this.pendingRequests.set(requestId, { 
        resolve: resolve as (value: Object) => void, 
        reject 
      });
      
      // 发送 REQUEST 消息
      const request: Request = {
        id: requestId,
        timestamp: Date.now(),
        type: MessageType.REQUEST,
        method: method,
        params: params,
        expectResponse: true
      };
      
      try {
        this.tdWorker?.postMessage(request);
      } catch (error) {
        clearTimeout(timeoutId);
        this.pendingRequests.delete(requestId);
        reject(error instanceof Error ? error : new Error('Unknown error'));
      }
    });
  }

  /**
   * ⭐ 新增：send 方法（不等待响应，fire-and-forget）
   * @param method TDLib API 方法名
   * @param params 方法参数
   */
  public send(method: string, params: Record<string, Object>): void {
    if (!this.tdWorker || !this.isWorkerReady) {
      hilog.warn(DOMAIN, TAG, 'Worker not ready, request dropped');
      return;
    }
    
    const request: Request = {
      id: `req_noresp_${++this.requestIdCounter}`,  // ⭐ 简化 ID 格式
      timestamp: Date.now(),
      type: MessageType.REQUEST,
      method: method,
      params: params,
      expectResponse: false
    };
    
    this.tdWorker?.postMessage(request);
  }

  /**
   * 执行 TDLib 请求（异步 Promise 化）
   * @param request 完整的请求对象（包含@type）
   * @returns Promise<T> 返回结果
   */
  async execute<T>(request: Record<string, Object>): Promise<T> {
    return new Promise((resolve: (value: T) => void, reject: (reason?: Error) => void) => {
      if (!this.tdWorker || !this.isWorkerReady) {
        reject(new Error('TDLib Worker is not ready'));
        return;
      }

      const id = `req_${++this.requestIdCounter}`;
      this.pendingExecutes.set(id, { resolve: resolve as (value: Object) => void, reject });

      // 超时保护：30秒
      setTimeout(() => {
        if (this.pendingExecutes.has(id)) {
          this.pendingExecutes.delete(id);
          reject(new Error(`Execute timeout for ${request['@type']}`));
        }
      }, 30000);

      // ⭐ 使用 REQUEST 消息类型发送 execute 请求
      const method = request['@type'] as string;
      
      // ⭐ 关键调试：检查 request 对象结构
      const requestKeys = Object.keys(request);
      console.info(`[TDLibClient] execute: id=${id}, method='${method}', keys(${requestKeys.length}): ${requestKeys.join(', ')}`);
      console.info(`[TDLibClient] request['@type'] = '${request['@type']}'`);
      if (request['_']) {
        console.info(`[TDLibClient] WARNING: request also has '_' field: '${request['_']}'`);
      }
      
      const executeRequest: Request = {
        id: id,
        timestamp: Date.now(),
        type: MessageType.REQUEST,
        method: method,
        params: request,
        expectResponse: true
      };
      this.tdWorker?.postMessage(executeRequest);
    });
  }

  /**
   * ⭐ 检查是否应该重连
   */
  private shouldReconnect(): boolean {
    return this.shouldAutoReconnect && 
           !this.isReconnecting && 
           this.reconnectAttempts < this.MAX_RECONNECT_ATTEMPTS;
  }

  /**
   * ⭐ 安排重连
   */
  private async scheduleReconnect(): Promise<void> {
    if (this.isReconnecting) {
      return;
    }
    
    this.isReconnecting = true;
    this.reconnectAttempts++;
    
    // 计算延迟时间（指数退避）
    const delay = this.RECONNECT_DELAY * Math.pow(this.RECONNECT_BACKOFF_MULTIPLIER, this.reconnectAttempts - 1);
    
    hilog.warn(DOMAIN, TAG, `Scheduling reconnect, attempt ${this.reconnectAttempts}/${this.MAX_RECONNECT_ATTEMPTS}, delay ${Math.round(delay)}ms`);
    
    await this.sleep(delay);
    
    if (!this.shouldAutoReconnect) {
      hilog.info(DOMAIN, TAG, 'Auto-reconnect disabled, stopping');
      this.isReconnecting = false;
      return;
    }
    
    await this.reconnect();
  }

  /**
   * ⭐ 执行重连
   */
  private async reconnect(): Promise<void> {
    try {
      hilog.info(DOMAIN, TAG, `Starting reconnect, attempt: ${this.reconnectAttempts}`);
      
      // 清理旧连接
      this.cleanupConnection(false); // 不清理回调
      
      // 重新创建 Worker
      if (this.context) {
        await this.initialize(this.context);
      }
      
      // 重连成功
      this.reconnectAttempts = 0;
      this.isReconnecting = false;
      
      hilog.info(DOMAIN, TAG, 'Reconnect successful!');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Reconnect failed: ${error}`);
      
      // 判断是否继续重连
      if (this.shouldReconnect()) {
        this.scheduleReconnect();
      } else {
        this.isReconnecting = false;
        hilog.error(DOMAIN, TAG, `Reconnect failed, max attempts reached (${this.MAX_RECONNECT_ATTEMPTS})`);
      }
    }
  }

  /**
   * ⭐ 清理连接
   * @param clearCallbacks 是否清理回调
   */
  private cleanupConnection(clearCallbacks: boolean = true): void {
    hilog.info(DOMAIN, TAG, 'Cleaning up connection');
    
    // 停止心跳
    this.stopHeartbeat();
    
    // 终止 Worker
    if (this.tdWorker) {
      try {
        this.tdWorker.terminate();
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Failed to terminate Worker: ${error}`);
      }
      this.tdWorker = null;
    }
    
    // 清理回调（可选）
    if (clearCallbacks) {
      this.updateCallbacks = [];
      this.pendingExecutes.clear();
      this.pendingRequests.clear();
    }
    
    this.isWorkerReady = false;
  }

  /**
   * ⭐ 休眠函数
   * @param ms 毫秒数
   */
  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * ⭐ 启动心跳
   */
  private startHeartbeat(): void {
    if (this.heartbeatTimer) {
      clearInterval(this.heartbeatTimer);
    }
    
    this.heartbeatTimer = setInterval(() => {
      if (this.isWorkerReady && this.tdWorker) {
        // ⭐ 使用协议类型发送心跳
        const heartbeat: Control = {
          id: `hb_${Date.now()}`,
          timestamp: Date.now(),
          type: MessageType.CONTROL,
          command: ControlCommand.HEARTBEAT
        };
        this.tdWorker.postMessage(heartbeat);
      }
    }, this.HEARTBEAT_INTERVAL);
    
    hilog.info(DOMAIN, TAG, `Heartbeat started, interval: ${this.HEARTBEAT_INTERVAL}ms`);
  }

  /**
   * ⭐ 停止心跳
   */
  private stopHeartbeat(): void {
    if (this.heartbeatTimer) {
      clearInterval(this.heartbeatTimer);
      this.heartbeatTimer = null;
    }
  }

  /**
   * 注册更新监听器
   */
  public onUpdate(callback: UpdateCallback): void {
    this.updateCallbacks.push(callback);
  }

  /**
   * 移除更新监听器
   */
  public offUpdate(callback: UpdateCallback): void {
    const index = this.updateCallbacks.indexOf(callback);
    if (index !== -1) {
      this.updateCallbacks.splice(index, 1);
    }
  }

  /**
   * 设置连接状态并通知监听器
   */
  private setConnectionState(state: ConnectionState): void {
    this.connectionState = state;
    hilog.info(DOMAIN, TAG, `Connection state changed to: ${state}`);
    this.connectionListeners.forEach(listener => {
      try {
        listener(state);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Connection listener error: ${error}`);
      }
    });
  }

  public getConnectionState(): ConnectionState {
    return this.connectionState;
  }

  public addConnectionListener(listener: ConnectionEventListener): void {
    this.connectionListeners.add(listener);
  }

  public removeConnectionListener(listener: ConnectionEventListener): void {
    this.connectionListeners.delete(listener);
  }

  /**
   * 销毁客户端与 Worker
   */
  public destroy(): void {
    // ⭐ 停止心跳
    this.stopHeartbeat();
    
    if (this.tdWorker) {
      // ⭐ 使用协议类型发送销毁命令
      this.tdWorker.postMessage({ type: ControlCommand.DESTROY });
      setTimeout(() => {
        this.tdWorker?.terminate();
        this.tdWorker = null;
        this.isWorkerReady = false;
      }, 100);
    }
    // ⭐ 清理所有 pending 请求
    this.pendingExecutes.clear();
    this.pendingRequests.clear();
    this.updateCallbacks = [];
    this.connectionListeners.clear();
    TDLibClient.instance = new TDLibClient();
  }

  /**
   * 获取聊天信息
   * @param chatId 聊天 ID
   * @returns Promise 返回聊天对象
   */
  public async getChat(chatId: number): Promise<Record<string, Object> | null> {
    try {
      const params: GetChatParams = { chat_id: chatId };
      const result = await this.call<Record<string, Object>>('getChat', params);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to get chat ${chatId}: ${error}`);
      return null;
    }
  }

  /**
   * 检查连接是否已建立
   */
  public isConnectionEstablished(): boolean {
    return this.connectionState === ConnectionState.CONNECTED;
  }

  /**
   * 检查 Worker 是否就绪
   */
  public checkWorkerReady(): boolean {
    return this.isWorkerReady;
  }

  /**
   * 获取当前客户端 ID（预留接口，实际由 Worker 管理）
   */
  public getClientId(): number {
    // Worker 模式下，clientId 由 Worker 内部管理
    // 这里返回 -1 表示不直接暴露
    return -1;
  }
}

/** 从对象中按 key 取属性（避免受限标准库 API），供本模块及调用方使用） */
export function getProp(obj: Record<string, Object>, key: string): Object | undefined {
  const keys: string[] = Object.keys(obj);
  for (let i = 0; i < keys.length; i++) {
    const k: string = keys[i];
    if (k === key) {
      return obj[k];
    }
  }
  return undefined;
}
