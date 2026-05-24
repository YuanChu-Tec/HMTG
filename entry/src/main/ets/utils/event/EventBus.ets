/**
 * 事件总线 - 观察者模式实现
 * 
 * 功能描述:
 * - 提供组件间解耦的事件通信机制
 * - 支持一对一、一对多的订阅和发布
 * - 支持一次性订阅（只触发一次）
 * - 支持事件命名空间（如'user.login'）
 * - 自动清理订阅者，防止内存泄漏
 * 
 * @module library/utils/src/main/ets/event/EventBus
 * @since API 20
 */

import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 事件历史项接口
 */
interface EventHistoryItem {
  eventName: string;
  data: Object;
  timestamp: number;
}

/**
 * 事件处理器类型定义
 */
export type EventHandler = (data?: Object) => void;

/**
 * 订阅选项
 */
export interface SubscribeOptions {
  /** 是否只触发一次，默认为false */
  once?: boolean;
  /** 订阅者标识，用于调试和清理 */
  subscriber?: string;
  /** 优先级，数值越大优先级越高，默认为0 */
  priority?: number;
}

/**
 * 订阅信息
 */
interface Subscription {
  handler: EventHandler;
  once: boolean;
  subscriber?: string;
  priority: number;
}

/**
 * 事件总线类（单例模式）
 */
export class EventBus {
  private static instance: EventBus;
  private readonly TAG: string = 'EventBus';
  private readonly DOMAIN: number = 0x0001;

  /** 事件监听器映射表 */
  private listeners: Map<string, Set<Subscription>> = new Map();

  /** 订阅者统计（用于调试） */
  private subscriberStats: Map<string, number> = new Map();

  /** 事件历史（用于调试，最多保留100条） */
  private eventHistory: EventHistoryItem[] = [];

  private constructor() {
    hilog.info(this.DOMAIN, this.TAG, 'EventBus initialized');
  }

  /**
   * 获取EventBus单例
   * 
   * @returns EventBus实例
   */
  public static getInstance(): EventBus {
    if (!EventBus.instance) {
      EventBus.instance = new EventBus();
    }
    return EventBus.instance;
  }

  /**
   * 订阅事件
   * 
   * @param eventName - 事件名称，支持命名空间如'user.login'
   * @param handler - 事件处理函数
   * @param options - 订阅选项
   * 
   * @returns 取消订阅的函数
   * 
   * @example
   * ```typescript
   * const bus = EventBus.getInstance();
   * const unsubscribe = bus.on('user.login', (data) => {
   *   console.log('User logged in:', data);
   * });
   * 
   * // 取消订阅
   * unsubscribe();
   * ```
   */
  public on(eventName: string, handler: EventHandler, options?: SubscribeOptions): () => void {
    if (!eventName || typeof eventName !== 'string') {
      hilog.error(this.DOMAIN, this.TAG, `Invalid event name: ${eventName}`);
      return () => {};
    }

    if (typeof handler !== 'function') {
      hilog.error(this.DOMAIN, this.TAG, 'Event handler must be a function');
      return () => {};
    }

    const opts: SubscribeOptions = {
      once: options?.once || false,
      subscriber: options?.subscriber || 'anonymous',
      priority: options?.priority || 0
    };

    // 确保事件存在
    if (!this.listeners.has(eventName)) {
      this.listeners.set(eventName, new Set());
    }

    const subscription: Subscription = {
      handler,
      once: opts.once || false,
      subscriber: opts.subscriber,
      priority: opts.priority || 0
    };

    const listeners = this.listeners.get(eventName)!;
    listeners.add(subscription);

    // 更新订阅者统计
    const subscriberCount = this.subscriberStats.get(opts.subscriber || 'anonymous') || 0;
    this.subscriberStats.set(opts.subscriber || 'anonymous', subscriberCount + 1);

    hilog.debug(this.DOMAIN, this.TAG,
      `Subscribed to event: ${eventName}, subscriber: ${opts.subscriber}, once: ${opts.once}`);

    // 返回取消订阅函数
    return () => {
      this.off(eventName, handler);
    };
  }

  /**
   * 订阅一次性事件（只触发一次）
   * 
   * @param eventName - 事件名称
   * @param handler - 事件处理函数
   * @param subscriber - 订阅者标识
   * 
   * @returns 取消订阅的函数
   * 
   * @example
   * ```typescript
   * bus.once('app.ready', () => {
   *   console.log('App is ready!');
   * });
   * ```
   */
  public once(eventName: string, handler: EventHandler, subscriber?: string): () => void {
    return this.on(eventName, handler, { once: true, subscriber });
  }

  /**
   * 取消订阅
   * 
   * @param eventName - 事件名称
   * @param handler - 事件处理函数
   * 
   * @example
   * ```typescript
   * bus.off('user.login', myHandler);
   * ```
   */
  public off(eventName: string, handler: EventHandler): void {
    const listeners = this.listeners.get(eventName);
    if (!listeners) {
      return;
    }

    listeners.forEach(subscription => {
      if (subscription.handler === handler) {
        // 更新订阅者统计
        if (subscription.subscriber) {
          const count = this.subscriberStats.get(subscription.subscriber) || 0;
          if (count > 0) {
            this.subscriberStats.set(subscription.subscriber, count - 1);
          }
        }
        listeners.delete(subscription);
      }
    });

    // 如果没有监听器了，删除事件
    if (listeners.size === 0) {
      this.listeners.delete(eventName);
    }

    hilog.debug(this.DOMAIN, this.TAG, `Unsubscribed from event: ${eventName}`);
  }

  /**
   * 发布事件
   * 
   * @param eventName - 事件名称
   * @param data - 事件数据
   * 
   * @example
   * ```typescript
   * bus.emit('user.login', { userId: '123', username: 'test' });
   * ```
   */
  public emit(eventName: string, data?: Object): void {
    if (!eventName) {
      hilog.error(this.DOMAIN, this.TAG, 'Event name cannot be empty');
      return;
    }

    // 记录事件历史
    const historyItem: EventHistoryItem = {
      eventName: eventName,
      data: data !== undefined ? data : new Object(),
      timestamp: Date.now()
    };
    this.eventHistory.push(historyItem);

    // 限制历史记录数量
    if (this.eventHistory.length > 100) {
      this.eventHistory.shift();
    }

    const listeners = this.listeners.get(eventName);
    if (!listeners || listeners.size === 0) {
      hilog.debug(this.DOMAIN, this.TAG, `No listeners for event: ${eventName}`);
      return;
    }

    // 按优先级排序
    const sortedListeners = Array.from(listeners).sort((a, b) => b.priority - a.priority);

    let errorCount = 0;

    sortedListeners.forEach(subscription => {
      try {
        subscription.handler(data);

        // 如果是一次性订阅，触发后自动移除
        if (subscription.once) {
          this.off(eventName, subscription.handler);
        }
      } catch (error) {
        errorCount++;
        hilog.error(this.DOMAIN, this.TAG,
          `Event handler error for ${eventName}: ${JSON.stringify(error)}`);
      }
    });

    if (errorCount > 0) {
      hilog.warn(this.DOMAIN, this.TAG,
        `Event ${eventName} had ${errorCount} handler error(s) out of ${sortedListeners.length} total`);
    }
  }

  /**
   * 清空指定事件的所有订阅
   * 
   * @param eventName - 事件名称，如果不传则清空所有事件
   * 
   * @example
   * ```typescript
   * // 清空特定事件
   * bus.clear('user.login');
   * 
   * // 清空所有事件
   * bus.clear();
   * ```
   */
  public clear(eventName?: string): void {
    if (eventName) {
      const listeners = this.listeners.get(eventName);
      if (listeners) {
        listeners.forEach(subscription => {
          if (subscription.subscriber) {
            const count = this.subscriberStats.get(subscription.subscriber) || 0;
            if (count > 0) {
              this.subscriberStats.set(subscription.subscriber, count - 1);
            }
          }
        });
        this.listeners.delete(eventName);
        hilog.info(this.DOMAIN, this.TAG, `Cleared all listeners for event: ${eventName}`);
      }
    } else {
      // 清空所有事件
      this.listeners.clear();
      this.subscriberStats.clear();
      this.eventHistory = [];
      hilog.info(this.DOMAIN, this.TAG, 'Cleared all events');
    }
  }

  /**
   * 清空指定订阅者的所有订阅
   * 
   * @param subscriber - 订阅者标识
   * 
   * @example
   * ```typescript
   * bus.clearSubscriber('MyComponent');
   * ```
   */
  public clearSubscriber(subscriber: string): void {
    if (!subscriber) {
      hilog.warn(this.DOMAIN, this.TAG, 'Subscriber name cannot be empty');
      return;
    }

    let clearedCount = 0;

    this.listeners.forEach((listeners, eventName) => {
      const toDelete: Subscription[] = [];

      listeners.forEach(subscription => {
        if (subscription.subscriber === subscriber) {
          toDelete.push(subscription);
        }
      });

      toDelete.forEach(subscription => {
        listeners.delete(subscription);
        clearedCount++;
      });

      // 如果没有监听器了，删除事件
      if (listeners.size === 0) {
        this.listeners.delete(eventName);
      }
    });

    this.subscriberStats.delete(subscriber);

    hilog.info(this.DOMAIN, this.TAG,
      `Cleared ${clearedCount} subscriptions for subscriber: ${subscriber}`);
  }

  /**
   * 获取指定事件的订阅者数量
   * 
   * @param eventName - 事件名称
   * @returns 订阅者数量
   * 
   * @example
   * ```typescript
   * const count = bus.listenerCount('user.login');
   * console.log(`There are ${count} listeners for user.login`);
   * ```
   */
  public listenerCount(eventName: string): number {
    const listeners = this.listeners.get(eventName);
    return listeners ? listeners.size : 0;
  }

  /**
   * 获取所有事件名称
   * 
   * @returns 事件名称数组
   * 
   * @example
   * ```typescript
   * const events = bus.eventNames();
   * console.log('All events:', events);
   * ```
   */
  public eventNames(): string[] {
    return Array.from(this.listeners.keys());
  }

  /**
   * 获取订阅者统计信息（用于调试）
   * 
   * @returns 订阅者统计映射表
   * 
   * @example
   * ```typescript
   * const stats = bus.getSubscriberStats();
   * console.table(stats);
   * ```
   */
  public getSubscriberStats(): Map<string, number> {
    return new Map(this.subscriberStats);
  }

  /**
   * 获取事件历史（用于调试）
   *
   * @param limit - 返回的最大数量，默认10条
   * @returns 事件历史数组
   *
   * @example
   * ```typescript
   * const history = bus.getEventHistory(20);
   * console.table(history);
   * ```
   */
  public getEventHistory(limit: number = 10): EventHistoryItem[] {
    return this.eventHistory.slice(-limit);
  }

  /**
   * 导出事件总线状态（用于调试）
   *
   * @returns 状态对象
   *
   * @example
   * ```typescript
   * const state = bus.exportState();
   * console.log('EventBus state:', state);
   * ```
   */
  public exportState(): object {
    const eventDetails: Map<string, EventDetail> = new Map();

    this.listeners.forEach((listeners, eventName) => {
      const detail: EventDetail = {
        count: listeners.size,
        subscribers: new Array<SubscriberInfo>()
      };

      const listenerArray = Array.from(listeners);
      listenerArray.forEach(s => {
        const subscriberInfo: SubscriberInfo = {
          subscriber: s.subscriber,
          once: s.once,
          priority: s.priority
        };
        detail.subscribers.push(subscriberInfo);
      });

      eventDetails.set(eventName, detail);
    });

    const result: ExportState = {
      totalEvents: this.listeners.size,
      events: eventDetails,
      subscriberStats: Array.from(this.subscriberStats.entries()),
      historySize: this.eventHistory.length
    };

    return result;
  }
}

/**
 * 导出EventBus实例（便捷访问）
 */
export const eventBus = EventBus.getInstance();

/**
 * 订阅者信息接口
 */
interface SubscriberInfo {
  subscriber: string | undefined;
  once: boolean;
  priority: number;
}

/**
 * 事件详情接口
 */
interface EventDetail {
  count: number;
  subscribers: SubscriberInfo[];
}

/**
 * 导出状态接口
 */
interface ExportState {
  totalEvents: number;
  events: Map<string, EventDetail>;
  subscriberStats: Array<[string, number]>;
  historySize: number;
}

/**
 * 事件名称常量（建议集中管理所有事件名称）
 */
export const AppEvents: Readonly<AppEventConstants> = {
  // 应用生命周期
  APP_READY: 'app.ready',
  APP_FOREGROUND: 'app.foreground',
  APP_BACKGROUND: 'app.background',

  // 用户相关
  USER_LOGIN: 'user.login',
  USER_LOGOUT: 'user.logout',
  USER_INFO_UPDATE: 'user.info.update',

  // 聊天相关
  CHAT_MESSAGE: 'chat.message',
  CHAT_READ: 'chat.read',
  CHAT_TYPING: 'chat.typing',

  // 缓存相关
  CACHE_UPDATE: 'cache.update',
  CACHE_CLEAR: 'cache.clear',

  // 主题相关
  THEME_CHANGE: 'theme.change',

  // 网络相关
  NETWORK_CHANGE: 'network.change',

  // 错误相关
  ERROR: 'error',

  // 性能相关
  PERFORMANCE_UPDATE: 'performance.update'
};

/**
 * AppEvent常量接口
 */
interface AppEventConstants {
  APP_READY: string;
  APP_FOREGROUND: string;
  APP_BACKGROUND: string;
  USER_LOGIN: string;
  USER_LOGOUT: string;
  USER_INFO_UPDATE: string;
  CHAT_MESSAGE: string;
  CHAT_READ: string;
  CHAT_TYPING: string;
  CACHE_UPDATE: string;
  CACHE_CLEAR: string;
  THEME_CHANGE: string;
  NETWORK_CHANGE: string;
  ERROR: string;
  PERFORMANCE_UPDATE: string;
}
