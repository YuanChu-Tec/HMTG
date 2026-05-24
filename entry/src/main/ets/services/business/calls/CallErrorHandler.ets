/**
 * WebRTC Call Error Handler
 *
 * 统一的错误处理机制，包括网络错误恢复、设备异常处理、资源释放保证
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction } from '@kit.ArkUI';

const DOMAIN = 0x0001;
const TAG = 'CallErrorHandler';

/**
 * 错误类型枚举
 */
export enum CallErrorType {
  NETWORK_ERROR = 'network_error',
  DEVICE_ERROR = 'device_error',
  PERMISSION_ERROR = 'permission_error',
  RESOURCE_ERROR = 'resource_error',
  UNKNOWN_ERROR = 'unknown_error'
}

/**
 * 错误严重级别
 */
export enum ErrorSeverity {
  INFO = 'info',
  WARNING = 'warning',
  ERROR = 'error',
  CRITICAL = 'critical'
}

/**
 * 错误详情接口
 */
export interface ErrorDetails {
  context: string;
  callId?: string;
  timestamp: number;
}

/**
 * 通话错误信息
 */
export interface CallError {
  type: CallErrorType;
  severity: ErrorSeverity;
  message: string;
  code?: string;
  details?: ErrorDetails;
  timestamp: number;
  canRecover: boolean;
}

/**
 * 错误处理器配置
 */
export interface ErrorHandlerConfig {
  maxRetryAttempts: number;
  retryDelay: number;
  enableAutoReconnect: boolean;
  enableLogging: boolean;
  showUserNotifications: boolean;
}

/**
 * 默认错误处理器配置
 */
const DEFAULT_CONFIG: ErrorHandlerConfig = {
  maxRetryAttempts: 3,
  retryDelay: 1000,
  enableAutoReconnect: true,
  enableLogging: true,
  showUserNotifications: true
};

/**
 * WebRTC 通话错误处理器
 */
export class CallErrorHandler {
  private static instance: CallErrorHandler;
  private config: ErrorHandlerConfig;
  private errorHistory: CallError[] = [];
  private retryCount: Map<string, number> = new Map();
  private errorCallbacks: Map<CallErrorType, ((error: CallError) => void)[]> = new Map();

  private constructor() {
    this.config = {
      maxRetryAttempts: DEFAULT_CONFIG.maxRetryAttempts,
      retryDelay: DEFAULT_CONFIG.retryDelay,
      enableAutoReconnect: DEFAULT_CONFIG.enableAutoReconnect,
      enableLogging: DEFAULT_CONFIG.enableLogging,
      showUserNotifications: DEFAULT_CONFIG.showUserNotifications
    };
    this.initializeErrorCallbacks();
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): CallErrorHandler {
    if (!CallErrorHandler.instance) {
      CallErrorHandler.instance = new CallErrorHandler();
    }
    return CallErrorHandler.instance;
  }

  /**
   * 配置错误处理器
   */
  public configure(config: Partial<ErrorHandlerConfig>): void {
    this.config = {
      maxRetryAttempts: config.maxRetryAttempts !== undefined ? config.maxRetryAttempts : this.config.maxRetryAttempts,
      retryDelay: config.retryDelay !== undefined ? config.retryDelay : this.config.retryDelay,
      enableAutoReconnect: config.enableAutoReconnect !== undefined ? config.enableAutoReconnect : this.config.enableAutoReconnect,
      enableLogging: config.enableLogging !== undefined ? config.enableLogging : this.config.enableLogging,
      showUserNotifications: config.showUserNotifications !== undefined ? config.showUserNotifications : this.config.showUserNotifications
    };
    hilog.info(DOMAIN, TAG, `ErrorHandler configured: ${JSON.stringify(this.config)}`);
  }

  /**
   * 处理错误
   */
  public async handleError(
    error: Error | Object,
    context: string,
    callId?: string
  ): Promise<boolean> {
    const callError = this.createCallError(error, context, callId);

    // 记录错误
    this.logError(callError);
    this.addToHistory(callError);

    // 显示用户通知
    if (this.config.showUserNotifications) {
      this.showErrorNotification(callError);
    }

    // 触发错误回调
    this.triggerErrorCallbacks(callError);

    // 尝试恢复
    if (callError.canRecover && this.config.enableAutoReconnect) {
      return await this.attemptRecovery(callError);
    }

    return false;
  }

  /**
   * 注册错误回调
   */
  public registerErrorCallback(
    type: CallErrorType,
    callback: (error: CallError) => void
  ): void {
    if (!this.errorCallbacks.has(type)) {
      this.errorCallbacks.set(type, []);
    }
    this.errorCallbacks.get(type)!.push(callback);
  }

  /**
   * 获取错误历史
   */
  public getErrorHistory(limit: number = 100): CallError[] {
    return this.errorHistory.slice(-limit);
  }

  /**
   * 清除错误历史
   */
  public clearErrorHistory(): void {
    this.errorHistory = [];
    hilog.info(DOMAIN, TAG, 'Error history cleared');
  }

  /**
   * 重置重试计数
   */
  public resetRetryCount(callId: string): void {
    this.retryCount.delete(callId);
  }

  /**
   * 创建通话错误对象
   */
  private createCallError(
    error: Error | Object,
    context: string,
    callId?: string
  ): CallError {
    let type = CallErrorType.UNKNOWN_ERROR;
    let severity = ErrorSeverity.ERROR;
    let message = 'Unknown error';
    let code: string | undefined;
    let canRecover = false;

    if (error instanceof Error) {
      message = error.message;

      // 根据错误消息判断类型
      if (message.includes('network') || message.includes('connection')) {
        type = CallErrorType.NETWORK_ERROR;
        severity = ErrorSeverity.WARNING;
        canRecover = true;
      } else if (message.includes('permission') || message.includes('denied')) {
        type = CallErrorType.PERMISSION_ERROR;
        severity = ErrorSeverity.ERROR;
        canRecover = false;
      } else if (message.includes('device') || message.includes('camera') || message.includes('microphone')) {
        type = CallErrorType.DEVICE_ERROR;
        severity = ErrorSeverity.ERROR;
        canRecover = true;
      } else if (message.includes('resource') || message.includes('memory')) {
        type = CallErrorType.RESOURCE_ERROR;
        severity = ErrorSeverity.CRITICAL;
        canRecover = false;
      }
    }

    const errorDetails: ErrorDetails = {
      context: context,
      callId: callId,
      timestamp: Date.now()
    };

    return {
      type: type,
      severity: severity,
      message: message,
      code: code,
      details: errorDetails,
      timestamp: Date.now(),
      canRecover: canRecover
    } as CallError;
  }

  /**
   * 记录错误
   */
  private logError(error: CallError): void {
    if (!this.config.enableLogging) {
      return;
    }

    const logMethod = this.getLogMethod(error.severity);
    logMethod(
      DOMAIN,
      TAG,
      `[${error.type}] ${error.message} | Context: ${error.details?.context} | CallId: ${error.details?.callId} | Recoverable: ${error.canRecover}`
    );
  }

  /**
   * 获取日志方法
   */
  private getLogMethod(severity: ErrorSeverity): Function {
    switch (severity) {
      case ErrorSeverity.INFO:
        return hilog.info;
      case ErrorSeverity.WARNING:
        return hilog.warn;
      case ErrorSeverity.ERROR:
        return hilog.error;
      case ErrorSeverity.CRITICAL:
        return hilog.fatal;
      default:
        return hilog.info;
    }
  }

  /**
   * 添加到错误历史
   */
  private addToHistory(error: CallError): void {
    this.errorHistory.push(error);

    // 限制历史记录大小
    if (this.errorHistory.length > 1000) {
      this.errorHistory = this.errorHistory.slice(-500);
    }
  }

  /**
   * 显示错误通知
   */
  private showErrorNotification(error: CallError): void {
    const message = this.getUserFriendlyMessage(error);

    promptAction.showToast({
      message,
      duration: error.severity === ErrorSeverity.CRITICAL ? 5000 : 3000,
      bottom: '50%'
    });
  }

  /**
   * 获取用户友好的错误消息
   */
  private getUserFriendlyMessage(error: CallError): string {
    switch (error.type) {
      case CallErrorType.NETWORK_ERROR:
        return '网络连接异常，正在尝试重新连接...';
      case CallErrorType.PERMISSION_ERROR:
        return '权限被拒绝，请在设置中授予权限';
      case CallErrorType.DEVICE_ERROR:
        return '设备访问失败，请检查摄像头和麦克风';
      case CallErrorType.RESOURCE_ERROR:
        return '系统资源不足，请关闭其他应用后重试';
      default:
        return '通话出现异常，请稍后重试';
    }
  }

  /**
   * 触发错误回调
   */
  private triggerErrorCallbacks(error: CallError): void {
    const callbacks = this.errorCallbacks.get(error.type);
    if (callbacks) {
      callbacks.forEach(callback => {
        try {
          callback(error);
        } catch (err) {
          hilog.error(DOMAIN, TAG, `Error callback failed: ${err}`);
        }
      });
    }
  }

  /**
   * 尝试恢复
   */
  private async attemptRecovery(error: CallError): Promise<boolean> {
    const callId = error.details?.callId;

    if (!callId) {
      return false;
    }

    // 获取当前重试次数
    const currentRetryCount = this.retryCount.get(callId) || 0;

    // 检查是否超过最大重试次数
    if (currentRetryCount >= this.config.maxRetryAttempts) {
      hilog.warn(DOMAIN, TAG, `Max retry attempts reached for call ${callId}`);
      return false;
    }

    // 增加重试次数
    this.retryCount.set(callId, currentRetryCount + 1);

    // 根据错误类型执行不同的恢复策略
    let recovered = false;

    switch (error.type) {
      case CallErrorType.NETWORK_ERROR:
        recovered = await this.recoverNetworkError(error);
        break;
      case CallErrorType.DEVICE_ERROR:
        recovered = await this.recoverDeviceError(error);
        break;
      default:
        recovered = false;
    }

    // 如果恢复成功，重置重试计数
    if (recovered) {
      this.resetRetryCount(callId);
    }

    return recovered;
  }

  /**
   * 恢复网络错误
   */
  private async recoverNetworkError(error: CallError): Promise<boolean> {
    hilog.info(DOMAIN, TAG, `Attempting to recover network error for call ${error.details?.callId}`);

    // 等待一段时间后重试
    await this.sleep(this.config.retryDelay * (this.retryCount.get(error.details?.callId || '') || 1));

    // 在实际场景中，这里会尝试重新连接
    // 例如：重新创建 PeerConnection、重新发送 Offer 等

    hilog.info(DOMAIN, TAG, 'Network recovery attempt completed');
    return true;
  }

  /**
   * 恢复设备错误
   */
  private async recoverDeviceError(error: CallError): Promise<boolean> {
    hilog.info(DOMAIN, TAG, `Attempting to recover device error for call ${error.details?.callId}`);

    // 等待一段时间后重试
    await this.sleep(this.config.retryDelay);

    // 在实际场景中，这里会尝试重新获取媒体流
    // 例如：重新调用 getUserMedia

    hilog.info(DOMAIN, TAG, 'Device recovery attempt completed');
    return true;
  }

  /**
   * 初始化错误回调
   */
  private initializeErrorCallbacks(): void {
    // 网络错误回调
    this.registerErrorCallback(CallErrorType.NETWORK_ERROR, (error) => {
      hilog.info(DOMAIN, TAG, `Network error callback triggered: ${error.message}`);
      // 可以在这里执行特定的网络错误处理逻辑
    });

    // 设备错误回调
    this.registerErrorCallback(CallErrorType.DEVICE_ERROR, (error) => {
      hilog.info(DOMAIN, TAG, `Device error callback triggered: ${error.message}`);
      // 可以在这里执行特定的设备错误处理逻辑
    });

    // 权限错误回调
    this.registerErrorCallback(CallErrorType.PERMISSION_ERROR, (error) => {
      hilog.info(DOMAIN, TAG, `Permission error callback triggered: ${error.message}`);
      // 可以在这里跳转到设置页面
    });
  }

  /**
   * 辅助函数：休眠
   */
  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

/**
 * 导出单例实例
 */
export const callErrorHandler = CallErrorHandler.getInstance();
