/**
 * TDLib 授权管理器
 * 
 * 职责：
 * 1. 作为 CoreService 认证状态变化的消费者
 * 2. 提供授权完成后的回调机制
 * 3. 确保所有依赖 TDLib 的功能等待授权成功后才执行
 * 
 * 架构说明：
 * - 认证状态的原始更新由 UpdateService 接收
 * - UpdateService 调用 CoreService.onUpdateAuthorizationState 处理
 * - CoreService 发布领域事件（core:authStateChanged, core:authReady 等）
 * - TDLibAuthManager 监听这些领域事件，提供便捷的回调机制
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { EventBus } from '../../../utils/event/EventBus';

const TAG = 'TDLibAuthManager';
const DOMAIN = 0x0001;

/**
 * 授权状态枚举
 */
export enum AuthState {
  WAIT_PARAMETERS = 'authorizationStateWaitTdlibParameters',
  WAIT_ENCRYPTION_KEY = 'authorizationStateWaitEncryptionKey',
  WAIT_PHONE_NUMBER = 'authorizationStateWaitPhoneNumber',
  WAIT_CODE = 'authorizationStateWaitCode',
  WAIT_PASSWORD = 'authorizationStateWaitPassword',
  WAIT_REGISTRATION = 'authorizationStateWaitRegistration',
  WAIT_OTHER_DEVICE_CONFIRMATION = 'authorizationStateWaitOtherDeviceConfirmation',
  READY = 'authorizationStateReady',
  CLOSED = 'authorizationStateClosed',
  LOGGING_OUT = 'authorizationStateLoggingOut'
}

/**
 * 授权监听器接口
 */
export interface AuthListener {
  onAuthStateChanged(state: AuthState): void;
  onAuthReady(): void;
}

/**
 * TDLib 授权管理器（单例）
 * 
 * 注意：此类现在作为 CoreService 的领域事件消费者，
 * 不再直接监听 TDLib 原始事件，而是监听 CoreService 发布的业务事件
 */
export class TDLibAuthManager {
  private static instance: TDLibAuthManager;
  private currentAuthState: AuthState = AuthState.WAIT_PARAMETERS;
  private authListeners: Set<AuthListener> = new Set();
  private pendingCallbacks: Array<() => void> = [];
  private isAuthReady: boolean = false;

  private constructor() {
    this.setupAuthStateListener();
    hilog.info(DOMAIN, TAG, '✅ TDLibAuthManager initialized (listening to CoreService events)');
  }

  public static getInstance(): TDLibAuthManager {
    if (!TDLibAuthManager.instance) {
      TDLibAuthManager.instance = new TDLibAuthManager();
    }
    return TDLibAuthManager.instance;
  }

  /**
   * 设置授权状态监听器
   * 
   * 监听 CoreService 发布的领域事件，而非原始 TDLib 事件
   */
  private setupAuthStateListener(): void {
    const eventBus = EventBus.getInstance();

    // 监听 CoreService 发布的认证状态变更事件
    eventBus.on('core:authStateChanged', (data: Object | undefined) => {
      const eventData = data as Record<string, Object> | undefined;
      if (eventData) {
        const newState = eventData['newState'] as string;
        if (newState) {
          this.handleAuthStateChange(newState);
        }
      }
    });

    // 监听 CoreService 发布的认证就绪事件
    eventBus.on('core:authReady', () => {
      hilog.info(DOMAIN, TAG, '🎉 Received core:authReady event from CoreService');
      this.setAuthReady();
    });

    // 保持向后兼容：也监听旧的 tdlib.auth.completed 事件
    eventBus.on('tdlib.auth.completed', () => {
      hilog.info(DOMAIN, TAG, '🎉 Received tdlib.auth.completed event (legacy)');
      this.setAuthReady();
    });
  }

  /**
   * 处理授权状态变更
   */
  private handleAuthStateChange(newState: string): void {
    const oldState = this.currentAuthState;
    this.currentAuthState = newState as AuthState;
    
    hilog.info(DOMAIN, TAG, `🔐 Auth state changed: ${oldState} → ${newState}`);

    // 通知所有监听器
    this.authListeners.forEach(listener => {
      try {
        listener.onAuthStateChanged(this.currentAuthState);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Error notifying listener: ${JSON.stringify(error)}`);
      }
    });

    // 如果状态变为 READY，触发授权完成
    if (this.currentAuthState === AuthState.READY) {
      this.setAuthReady();
    }
  }

  /**
   * 设置授权就绪状态
   */
  private setAuthReady(): void {
    if (this.isAuthReady) {
      hilog.info(DOMAIN, TAG, 'Already in ready state, skip');
      return;
    }

    this.isAuthReady = true;
    hilog.info(DOMAIN, TAG, '✅ TDLib authorization ready! Executing pending callbacks...');

    // 执行所有待处理的回调
    const callbacks = this.pendingCallbacks;
    this.pendingCallbacks = [];

    callbacks.forEach((callback, index) => {
      hilog.info(DOMAIN, TAG, `Executing pending callback #${index + 1}...`);
      try {
        callback();
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Callback #${index + 1} failed: ${JSON.stringify(error)}`);
      }
    });

    // 通知所有监听器
    this.authListeners.forEach(listener => {
      try {
        listener.onAuthReady();
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Error notifying ready: ${JSON.stringify(error)}`);
      }
    });
  }

  /**
   * 获取当前授权状态
   */
  public getAuthState(): AuthState {
    return this.currentAuthState;
  }

  /**
   * 检查是否已授权完成
   */
  public isReady(): boolean {
    return this.isAuthReady;
  }

  /**
   * 添加授权监听器
   */
  public addAuthListener(listener: AuthListener): void {
    this.authListeners.add(listener);
    hilog.info(DOMAIN, TAG, `Auth listener added, total: ${this.authListeners.size}`);
  }

  /**
   * 移除授权监听器
   */
  public removeAuthListener(listener: AuthListener): void {
    this.authListeners.delete(listener);
    hilog.info(DOMAIN, TAG, `Auth listener removed, total: ${this.authListeners.size}`);
  }

  /**
   * 在授权完成后执行回调
   * 
   * 如果已经授权完成，立即执行；否则加入等待队列
   * @param callback 要执行的回调函数
   * @param description 回调描述（用于日志）
   */
  public executeWhenReady(callback: () => void, description?: string): void {
    if (this.isAuthReady) {
      hilog.info(DOMAIN, TAG, `✅ Auth ready, executing immediately: ${description || 'unnamed callback'}`);
      setTimeout(() => {
        try {
          callback();
        } catch (error) {
          hilog.error(DOMAIN, TAG, `Immediate callback failed: ${JSON.stringify(error)}`);
        }
      }, 0);
    } else {
      hilog.info(DOMAIN, TAG, `⏳ Queuing callback for when auth is ready: ${description || 'unnamed callback'}`);
      this.pendingCallbacks.push(callback);
    }
  }

  /**
   * 异步等待授权完成
   * 
   * @returns Promise，授权完成后 resolve
   */
  public waitForAuth(): Promise<void> {
    return new Promise((resolve) => {
      if (this.isAuthReady) {
        hilog.info(DOMAIN, TAG, '✅ Already authorized, resolving immediately');
        resolve();
      } else {
        hilog.info(DOMAIN, TAG, '⏳ Waiting for authorization...');
        this.executeWhenReady(() => {
          resolve();
        }, 'waitForAuth resolver');
      }
    });
  }

  /**
   * 重置授权状态（用于登出后重新登录）
   */
  public reset(): void {
    this.isAuthReady = false;
    this.currentAuthState = AuthState.WAIT_PARAMETERS;
    this.pendingCallbacks = [];
    hilog.info(DOMAIN, TAG, '🔄 Auth manager reset');
  }

  /**
   * 获取授权状态描述
   */
  public getStateDescription(): string {
    const descriptions: Map<AuthState, string> = new Map([
      [AuthState.WAIT_PARAMETERS, '等待 TDLib 参数'],
      [AuthState.WAIT_ENCRYPTION_KEY, '等待加密密钥'],
      [AuthState.WAIT_PHONE_NUMBER, '等待手机号'],
      [AuthState.WAIT_CODE, '等待验证码'],
      [AuthState.WAIT_PASSWORD, '等待密码'],
      [AuthState.WAIT_REGISTRATION, '等待注册'],
      [AuthState.WAIT_OTHER_DEVICE_CONFIRMATION, '等待其他设备确认'],
      [AuthState.READY, '已就绪'],
      [AuthState.CLOSED, '已关闭'],
      [AuthState.LOGGING_OUT, '正在登出']
    ]);

    return descriptions.get(this.currentAuthState) || '未知状态';
  }
}
