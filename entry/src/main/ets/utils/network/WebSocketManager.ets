import { AppError, ErrorSeverity, ErrorCategory } from '../error/AppError';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { webSocket } from '@kit.NetworkKit';

const TAG = 'WebSocketManager';
const DOMAIN = 0x0001;

/**
 * WebSocket消息类型
 */
export type WebSocketMessageType = 'text' | 'binary';

/**
 * WebSocket消息
 */
export interface WebSocketMessage {
  type: WebSocketMessageType;
  data: string | ArrayBuffer;
  timestamp: number;
}

/**
 * WebSocket事件
 */
export type WebSocketEvent =
  | 'open'
  | 'message'
  | 'error'
  | 'close';

/**
 * WebSocket事件处理器
 */
type WebSocketEventHandler = (data: Object) => void;

/**
 * WebSocket管理器
 */
export class WebSocketManager {
  private ws: webSocket.WebSocket | null = null;
  private url: string = '';
  private isConnected: boolean = false;
  private isReconnecting: boolean = false;
  private reconnectAttempts: number = 0;
  private maxReconnectAttempts: number = 5;
  private reconnectDelay: number = 1000;
  private listeners: Map<WebSocketEvent, Set<WebSocketEventHandler>> = new Map();
  private messageQueue: WebSocketMessage[] = [];
  private maxQueueSize: number = 100;

  /**
   * 连接WebSocket
   */
  public connect(url: string, protocols?: string[]): Promise<void> {
    return new Promise((resolve, reject) => {
      if (this.isConnected) {
        resolve();
        return;
      }

      this.url = url;

      try {
        this.ws = webSocket.createWebSocket();

        this.ws.on('open', () => {
          this.isConnected = true;
          this.isReconnecting = false;
          this.reconnectAttempts = 0;
          hilog.info(DOMAIN, TAG, `WebSocket connected: ${url}`);
          this.emit('open', null);

          // 发送队列中的消息
          this.flushQueue();
          resolve();
        });

        this.ws.on('message', (error, data) => {
          const message: WebSocketMessage = {
            type: 'text',
            data: data as string,
            timestamp: Date.now()
          };
          this.emit('message', message);
        });

        this.ws.on('error', (error) => {
          hilog.error(DOMAIN, TAG, `WebSocket error: ${error}`);
          this.emit('error', error);
          reject(error);
        });

        this.ws.on('close', () => {
          this.isConnected = false;
          hilog.info(DOMAIN, TAG, `WebSocket closed`);
          this.emit('close', null);

          // 自动重连
          if (!this.isReconnecting) {
            this.scheduleReconnect();
          }
        });

        // 连接WebSocket
        const protocol = protocols && protocols.length > 0 ? protocols[0] : '';
        this.ws.connect(url, { protocol: protocol });
      } catch (error) {
        reject(new AppError(
          'NETWORK_ERROR',
          `Failed to create WebSocket: ${url}`,
          ErrorSeverity.ERROR,
          ErrorCategory.UNKNOWN,
          undefined,
          error as Error
        ));
      }
    });
  }

  /**
   * 发送消息
   */
  public send(data: string | ArrayBuffer): boolean {
    if (!this.isConnected || !this.ws) {
      // 加入队列
      if (this.messageQueue.length < this.maxQueueSize) {
        this.messageQueue.push({
          type: typeof data === 'string' ? 'text' : 'binary',
          data,
          timestamp: Date.now()
        });
        return true;
      }
      return false;
    }

    try {
      this.ws.send(data);
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to send message: ${error}`);
      return false;
    }
  }

  /**
   * 发送JSON消息
   */
  public sendJSON(data: Record<string, Object>): boolean {
    return this.send(JSON.stringify(data));
  }

  /**
   * 关闭连接
   */
  public close(code?: number, reason?: string): void {
    if (this.ws) {
      const closeOptions: webSocket.WebSocketCloseOptions = {
        code: code ?? 1000,
        reason: reason ?? ''
      };
      this.ws.close(closeOptions);
      this.ws = null;
      this.isConnected = false;
      this.isReconnecting = false;
      this.messageQueue = [];
    }
  }

  /**
   * 添加事件监听器
   */
  public on(event: WebSocketEvent, handler: WebSocketEventHandler): void {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, new Set<WebSocketEventHandler>());
    }
    const handlers = this.listeners.get(event);
    if (handlers) {
      handlers.add(handler);
    }
  }

  /**
   * 移除事件监听器
   */
  public off(event: WebSocketEvent, handler: WebSocketEventHandler): void {
    const handlers = this.listeners.get(event);
    if (handlers) {
      handlers.delete(handler);
    }
  }

  /**
   * 触发事件
   */
  private emit(event: WebSocketEvent, data: Object | null): void {
    const handlers = this.listeners.get(event);
    if (handlers) {
      handlers.forEach(handler => {
        try {
          if (data !== null) {
        handler(data);
      }
        } catch (error) {
          hilog.error(DOMAIN, TAG, `Handler error: ${error}`);
        }
      });
    }
  }

  /**
   * 安排重连
   */
  private scheduleReconnect(): void {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      hilog.error(DOMAIN, TAG, 'Max reconnection attempts reached');
      return;
    }

    this.isReconnecting = true;
    this.reconnectAttempts++;

    const delay = this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1);

    hilog.info(DOMAIN, TAG, `Scheduling reconnect in ${delay}ms (attempt ${this.reconnectAttempts})`);

    setTimeout(() => {
      if (this.isReconnecting) {
        this.connect(this.url).catch((error: Error) => {
          hilog.error(DOMAIN, TAG, `Reconnect failed: ${error.message}`);
        });
      }
    }, delay);
  }

  /**
   * 清空消息队列
   */
  private flushQueue(): void {
    while (this.messageQueue.length > 0) {
      const message = this.messageQueue.shift();
      if (message) {
        if (!this.send(message.data)) {
          // 发送失败，重新加入队列
          this.messageQueue.unshift(message);
          break;
        }
      }
    }
  }

  /**
   * 获取连接状态
   */
  public getConnectedState(): boolean {
    return this.isConnected;
  }

  /**
   * 获取重连状态
   */
  public getReconnectingState(): boolean {
    return this.isReconnecting;
  }

  /**
   * 设置最大重连次数
   */
  public setMaxReconnectAttempts(maxAttempts: number): void {
    this.maxReconnectAttempts = maxAttempts;
  }

  /**
   * 设置重连延迟
   */
  public setReconnectDelay(delay: number): void {
    this.reconnectDelay = delay;
  }
}
