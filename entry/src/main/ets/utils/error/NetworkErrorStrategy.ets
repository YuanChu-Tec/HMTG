import { AppError, ErrorSeverity, ErrorCategory, ErrorContext } from './AppError';
import { ErrorCode } from './ErrorCode';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'NetworkErrorStrategy';
const DOMAIN = 0x0001;

/**
 * 重试策略配置
 */
export interface RetryConfig {
  maxAttempts: number;
  baseDelay: number;
  maxDelay: number;
  backoffMultiplier: number;
}

/**
 * 默认重试配置
 */
const DEFAULT_RETRY_CONFIG: RetryConfig = {
  maxAttempts: 3,
  baseDelay: 1000,
  maxDelay: 30000,
  backoffMultiplier: 2
};

/**
 * 网络错误处理策略
 */
export class NetworkErrorStrategy {
  private static instance: NetworkErrorStrategy;
  private retryConfig: RetryConfig = DEFAULT_RETRY_CONFIG;
  private retryCallbacks: Map<string, Function[]> = new Map();

  private constructor() {}

  public static getInstance(): NetworkErrorStrategy {
    if (!NetworkErrorStrategy.instance) {
      NetworkErrorStrategy.instance = new NetworkErrorStrategy();
    }
    return NetworkErrorStrategy.instance;
  }

  /**
   * 处理网络错误
   */
  public async handleError(error: AppError): Promise<void> {
    hilog.warn(DOMAIN, TAG, `Network error occurred: ${error.message}`);
  }

  /**
   * 执行带重试的操作
   */
  public async executeWithRetry<T>(
    operation: () => Promise<T>,
    config?: RetryConfig
  ): Promise<T> {
    const finalConfig: RetryConfig = {
      maxAttempts: config?.maxAttempts || this.retryConfig.maxAttempts,
      baseDelay: config?.baseDelay || this.retryConfig.baseDelay,
      maxDelay: config?.maxDelay || this.retryConfig.maxDelay,
      backoffMultiplier: config?.backoffMultiplier || this.retryConfig.backoffMultiplier
    };
    let lastError: Error | undefined;

    for (let attempt = 1; attempt <= finalConfig.maxAttempts; attempt++) {
      try {
        return await operation();
      } catch (error) {
        lastError = error as Error;

        if (attempt < finalConfig.maxAttempts) {
          const delay = this.calculateDelay(attempt, finalConfig);
          hilog.info(DOMAIN, TAG, `Retry attempt ${attempt}/${finalConfig.maxAttempts} after ${delay}ms`);
          await this.sleep(delay);
        }
      }
    }

    throw new AppError(
      'NETWORK_ERROR',
      `Operation failed after ${finalConfig.maxAttempts} attempts`,
      ErrorSeverity.ERROR,
      ErrorCategory.NETWORK,
      undefined,
      lastError
    );
  }

  /**
   * 指数退避计算延迟
   */
  private calculateDelay(attempt: number, config: RetryConfig): number {
    const delay = config.baseDelay * Math.pow(config.backoffMultiplier, attempt - 1);
    return Math.min(delay, config.maxDelay);
  }

  /**
   * 睡眠指定毫秒
   */
  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * 设置重试配置
   */
  public setRetryConfig(config: RetryConfig): void {
    this.retryConfig.maxAttempts = config.maxAttempts;
    this.retryConfig.baseDelay = config.baseDelay;
    this.retryConfig.maxDelay = config.maxDelay;
    this.retryConfig.backoffMultiplier = config.backoffMultiplier;
  }

  /**
   * 注册重试回调
   */
  public registerRetryCallback(key: string, callback: Function): void {
    if (!this.retryCallbacks.has(key)) {
      this.retryCallbacks.set(key, []);
    }
    this.retryCallbacks.get(key)?.push(callback);
  }
}

/**
 * 重试策略工具类
 */
export class RetryStrategy {
  /**
   * 指数退避重试
   */
  static exponentialBackoff<T>(
    operation: () => Promise<T>,
    maxAttempts: number = 3
  ): Promise<T> {
    return NetworkErrorStrategy.getInstance().executeWithRetry(operation, {
      maxAttempts,
      baseDelay: 1000,
      maxDelay: 30000,
      backoffMultiplier: 2
    });
  }

  /**
   * 固定延迟重试
   */
  static fixedDelay<T>(
    operation: () => Promise<T>,
    maxAttempts: number = 3,
    delay: number = 1000
  ): Promise<T> {
    return NetworkErrorStrategy.getInstance().executeWithRetry(operation, {
      maxAttempts,
      baseDelay: delay,
      maxDelay: delay,
      backoffMultiplier: 1
    });
  }
}
