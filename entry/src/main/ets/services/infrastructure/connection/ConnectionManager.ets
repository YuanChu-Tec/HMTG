/**
 * 连接管理器
 * 
 * 负责 TDLib 连接状态管理：
 * - 监控连接状态
 * - 自动重连
 * - 网络状态监听
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ConnectionState } from './ConnectionState';

const TAG = 'ConnectionManager';
const DOMAIN = 0x0001;

export class ConnectionManager {
  private static instance: ConnectionManager;
  private currentState: ConnectionState = ConnectionState.NONE;
  private listeners: Set<(state: ConnectionState) => void> = new Set();
  private reconnectAttempts: number = 0;
  private maxReconnectAttempts: number = 5;
  private reconnectDelay: number = 3000; // 3 秒
  private reconnectTimer: number | null = null;

  private constructor() {}

  public static getInstance(): ConnectionManager {
    if (!ConnectionManager.instance) {
      ConnectionManager.instance = new ConnectionManager();
    }
    return ConnectionManager.instance;
  }

  /**
   * 获取当前连接状态
   */
  public getState(): ConnectionState {
    return this.currentState;
  }

  /**
   * 设置连接状态
   */
  public setState(state: ConnectionState): void {
    const previousState = this.currentState;
    this.currentState = state;
    
    hilog.info(DOMAIN, TAG, `Connection state changed: ${previousState} -> ${state}`);
    
    // 通知所有监听器
    this.listeners.forEach(listener => listener(state));
    
    // 根据状态处理重连逻辑
    if (state === ConnectionState.FAILED) {
      this.scheduleReconnect();
    } else if (state === ConnectionState.CONNECTED) {
      this.reconnectAttempts = 0;
      if (this.reconnectTimer) {
        clearTimeout(this.reconnectTimer);
        this.reconnectTimer = null;
      }
    }
  }

  /**
   * 注册连接状态变化监听器
   */
  public onStateChange(listener: (state: ConnectionState) => void): () => void {
    this.listeners.add(listener);
    
    // 返回取消订阅函数
    return () => {
      this.listeners.delete(listener);
    };
  }

  /**
   * 计划重连
   */
  private scheduleReconnect(): void {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      hilog.error(DOMAIN, TAG, `Max reconnect attempts reached (${this.maxReconnectAttempts})`);
      return;
    }

    this.reconnectAttempts++;
    const delay = this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1); // 指数退避
    
    hilog.info(DOMAIN, TAG, `Scheduling reconnect attempt ${this.reconnectAttempts}/${this.maxReconnectAttempts} in ${delay}ms`);
    
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
    }
    
    this.reconnectTimer = setTimeout(() => {
      hilog.info(DOMAIN, TAG, 'Attempting to reconnect...');
      this.setState(ConnectionState.CONNECTING);
    }, delay);
  }

  /**
   * 重置重连计数器
   */
  public resetReconnectCounter(): void {
    this.reconnectAttempts = 0;
  }

  /**
   * 检查是否已连接
   */
  public isConnected(): boolean {
    return this.currentState === ConnectionState.CONNECTED;
  }

  /**
   * 检查是否可以发送请求
   */
  public canSendRequest(): boolean {
    return this.isConnected();
  }

  /**
   * 销毁连接管理器
   */
  public destroy(): void {
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = null;
    }
    
    this.listeners.clear();
    this.currentState = ConnectionState.NONE;
  }
}
