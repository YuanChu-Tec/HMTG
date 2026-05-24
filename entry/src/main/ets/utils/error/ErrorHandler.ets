import { AppError, ErrorSeverity, ErrorCategory, ErrorContext } from './AppError';
import { ErrorCode } from './ErrorCode';
import { NetworkErrorStrategy } from './NetworkErrorStrategy';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'ErrorHandler';
const DOMAIN = 0x0001;

/**
 * 错误处理器 - 统一错误处理和上报
 */
export class ErrorHandler {
  private static instance: ErrorHandler;
  private errorCallbacks: Map<string, (error: AppError) => void> = new Map();
  private globalCallback?: (error: AppError) => void;
  private enableLogging: boolean = true;

  private constructor() {}

  public static getInstance(): ErrorHandler {
    if (!ErrorHandler.instance) {
      ErrorHandler.instance = new ErrorHandler();
    }
    return ErrorHandler.instance;
  }

  /**
   * 处理错误
   */
  public handle(error: Error | AppError): void {
    const appError = this.normalizeError(error);

    // 记录日志
    if (this.enableLogging) {
      this.logError(appError);
    }

    // 执行特定错误码的回调
    const callback = this.errorCallbacks.get(appError.code);
    if (callback) {
      callback(appError);
    }

    // 执行全局回调
    if (this.globalCallback) {
      this.globalCallback(appError);
    }

    // 网络错误自动重试
    if (appError.code === 'NETWORK_ERROR') {
      NetworkErrorStrategy.getInstance().handleError(appError);
    }
  }

  /**
   * 注册错误回调
   */
  public registerErrorCallback(code: ErrorCode, callback: (error: AppError) => void): void {
    this.errorCallbacks.set(String(code), callback);
  }

  /**
   * 注册全局错误回调
   */
  public registerGlobalCallback(callback: (error: AppError) => void): void {
    this.globalCallback = callback;
  }

  /**
   * 规范化错误对象
   */
  private normalizeError(error: Error | AppError): AppError {
    if (error instanceof AppError) {
      return error;
    }
    return new AppError(
      'UNKNOWN',
      error.message,
      ErrorSeverity.ERROR,
      ErrorCategory.UNKNOWN,
      undefined,
      error
    );
  }

  /**
   * 记录错误日志
   */
  private logError(error: AppError): void {
    hilog.error(DOMAIN, TAG, `${error.toString()}`);
    if (error.stack) {
      hilog.error(DOMAIN, TAG, `Stack: ${error.stack}`);
    }
  }

  /**
   * 设置是否启用日志
   */
  public setEnableLogging(enable: boolean): void {
    this.enableLogging = enable;
  }

  /**
   * 清除所有回调
   */
  public clearCallbacks(): void {
    this.errorCallbacks.clear();
    this.globalCallback = undefined;
  }
}
