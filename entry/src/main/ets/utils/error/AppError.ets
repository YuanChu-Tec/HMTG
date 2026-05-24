/**
 * 错误上下文类型
 */
export class ErrorContext {
  private data: Map<string, Object> = new Map();

  constructor(data?: Map<string, Object>) {
    if (data) {
      this.data = data;
    }
  }

  set(key: string, value: Object): void {
    this.data.set(key, value);
  }

  get(key: string): Object | undefined {
    return this.data.get(key);
  }

  has(key: string): boolean {
    return this.data.has(key);
  }

  toMap(): Map<string, Object> {
    return this.data;
  }

  static fromMap(data: Map<string, Object>): ErrorContext {
    return new ErrorContext(data);
  }
}

/**
 * 统一错误基类
 * 所有自定义错误都应继承此类
 */

/**
 * 错误严重程度
 */
export enum ErrorSeverity {
  INFO = 'INFO',
  WARNING = 'WARNING',
  ERROR = 'ERROR',
  CRITICAL = 'CRITICAL'
}

/**
 * 错误分类
 */
export enum ErrorCategory {
  NETWORK = 'NETWORK',
  AUTH = 'AUTH',
  DATABASE = 'DATABASE',
  VALIDATION = 'VALIDATION',
  PERMISSION = 'PERMISSION',
  UNKNOWN = 'UNKNOWN'
}

/**
 * 应用统一错误基类
 */
export class AppError extends Error {
  readonly code: string;
  readonly severity: ErrorSeverity;
  readonly category: ErrorCategory;
  readonly timestamp: number;
  readonly userMessage?: ResourceStr;
  readonly originalError?: Error;
  readonly context?: ErrorContext;

  constructor(
    code: string,
    message: string,
    severity: ErrorSeverity = ErrorSeverity.ERROR,
    category: ErrorCategory = ErrorCategory.UNKNOWN,
    userMessage?: ResourceStr,
    originalError?: Error,
    context?: ErrorContext
  ) {
    super(message);
    this.name = 'AppError';
    this.code = code;
    this.severity = severity;
    this.category = category;
    this.timestamp = Date.now();
    this.userMessage = userMessage;
    this.originalError = originalError;
    this.context = context;
  }

  /**
   * 检查是否为网络错误
   */
  isNetworkError(): boolean {
    return this.category === ErrorCategory.NETWORK;
  }

  /**
   * 检查是否为认证错误
   */
  isAuthError(): boolean {
    return this.category === ErrorCategory.AUTH;
  }

  /**
   * 转换为JSON
   */
  toJSON(): Object {
    let result: Map<string, Object> = new Map();
    result.set('code', this.code);
    result.set('message', this.message);
    result.set('severity', this.severity);
    result.set('category', this.category);
    result.set('timestamp', this.timestamp);

    if (this.context) {
      let contextMap: Map<string, Object> = this.context.toMap();
      // 合并上下文数据到结果对象
      if (contextMap.has('code')) {
        let codeValue = contextMap.get('code');
        if (codeValue !== undefined) {
          result.set('code', codeValue);
        }
      }
    }
    return result;
  }

  /**
   * 获取日志字符串
   */
  toLogString(): string {
    let contextStr = '';
    if (this.context) {
      contextStr = JSON.stringify(this.context);
    }
    return `[${this.code}] ${this.category}: ${this.message} ${contextStr}`;
  }
}
