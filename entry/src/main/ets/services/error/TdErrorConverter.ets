/**
 * TDLib 错误转换器
 * 
 * 将 TDLib 原生错误转换为应用友好的错误格式
 */
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'TdErrorConverter';
const DOMAIN = 0x0001;

/**
 * TDLib 错误代码枚举
 */
export enum TdErrorCode {
  UNKNOWN = -1,
  NETWORK_ERROR = 400,
  UNAUTHORIZED = 401,
  FORBIDDEN = 403,
  NOT_FOUND = 404,
  RATE_LIMITED = 429,
  INTERNAL_ERROR = 500,
  TIMEOUT = 504
}

/**
 * TDLib 错误接口
 */
export interface TdLibError {
  code: TdErrorCode;
  message: string;
  details?: Record<string, Object>;
}

/**
 * TDLib 错误转换器
 */
export class TdErrorConverter {
  /**
   * 将原始错误转换为 TDLib 错误
   * @param error 原始错误对象
   * @returns TDLib 错误
   */
  public static convert(error: any): TdLibError {
    if (!error) {
      return this.createUnknownError('Unknown error occurred');
    }

    // 如果已经是 TDLib 错误，直接返回
    if (this.isTdLibError(error)) {
      return error as TdLibError;
    }

    // 处理 Error 对象
    if (error instanceof Error) {
      return this.convertNativeError(error);
    }

    // 处理字符串错误
    if (typeof error === 'string') {
      return this.createUnknownError(error);
    }

    // 处理对象错误
    if (typeof error === 'object') {
      return this.convertObjectError(error);
    }

    return this.createUnknownError('Unknown error type');
  }

  /**
   * 判断是否为友好的错误消息
   * @param error 错误对象
   * @returns 是否应该显示给用户
   */
  public static isUserFriendlyError(error: TdLibError): boolean {
    // 网络错误、未授权等错误不直接显示给用户
    const hideCodes = [
      TdErrorCode.NETWORK_ERROR,
      TdErrorCode.UNAUTHORIZED,
      TdErrorCode.TIMEOUT
    ];
    
    return !hideCodes.includes(error.code);
  }

  /**
   * 获取用户友好的错误消息
   * @param error TDLib 错误
   * @returns 用户友好的消息
   */
  public static getUserFriendlyMessage(error: TdLibError): string {
    switch (error.code) {
      case TdErrorCode.UNAUTHORIZED:
        return '认证失败，请重新登录';
      case TdErrorCode.NETWORK_ERROR:
        return '网络连接失败，请检查网络';
      case TdErrorCode.TIMEOUT:
        return '请求超时，请稍后重试';
      case TdErrorCode.RATE_LIMITED:
        return '操作过于频繁，请稍后再试';
      case TdErrorCode.NOT_FOUND:
        return '请求的内容不存在';
      case TdErrorCode.FORBIDDEN:
        return '没有权限执行此操作';
      default:
        return error.message || '操作失败，请稍后重试';
    }
  }

  /**
   * 转换原生 Error 对象
   */
  private static convertNativeError(error: Error): TdLibError {
    const message = error.message;

    // 根据错误消息判断类型
    if (message.includes('network') || message.includes('Network')) {
      return {
        code: TdErrorCode.NETWORK_ERROR,
        message: this.getUserFriendlyMessage({ code: TdErrorCode.NETWORK_ERROR, message })
      };
    }

    if (message.includes('timeout') || message.includes('Timeout')) {
      return {
        code: TdErrorCode.TIMEOUT,
        message: this.getUserFriendlyMessage({ code: TdErrorCode.TIMEOUT, message })
      };
    }

    if (message.includes('unauthorized') || message.includes('Unauthorized')) {
      return {
        code: TdErrorCode.UNAUTHORIZED,
        message: this.getUserFriendlyMessage({ code: TdErrorCode.UNAUTHORIZED, message })
      };
    }

    return this.createUnknownError(message);
  }

  /**
   * 转换对象错误
   */
  private static convertObjectError(error: Record<string, any>): TdLibError {
    const code = error['code'] as number | undefined;
    const message = error['message'] as string | undefined;

    if (code !== undefined && message !== undefined) {
      return {
        code: this.mapErrorCode(code),
        message: message
      };
    }

    return this.createUnknownError(JSON.stringify(error));
  }

  /**
   * 映射错误代码
   */
  private static mapErrorCode(code: number): TdErrorCode {
    if (code >= 400 && code < 500) {
      if (code === 401) return TdErrorCode.UNAUTHORIZED;
      if (code === 403) return TdErrorCode.FORBIDDEN;
      if (code === 404) return TdErrorCode.NOT_FOUND;
      if (code === 429) return TdErrorCode.RATE_LIMITED;
      return TdErrorCode.NETWORK_ERROR;
    }

    if (code >= 500) {
      if (code === 504) return TdErrorCode.TIMEOUT;
      return TdErrorCode.INTERNAL_ERROR;
    }

    return TdErrorCode.UNKNOWN;
  }

  /**
   * 创建未知错误
   */
  private static createUnknownError(message: string): TdLibError {
    return {
      code: TdErrorCode.UNKNOWN,
      message: message
    };
  }

  /**
   * 判断是否为 TDLib 错误
   */
  private static isTdLibError(error: any): error is TdLibError {
    return error && 
           typeof error === 'object' && 
           'code' in error && 
           'message' in error &&
           typeof error['code'] === 'number' &&
           typeof error['message'] === 'string';
  }
}
