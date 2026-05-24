import { AppError, ErrorSeverity, ErrorCategory, ErrorContext } from './AppError';
import { ErrorCode } from './ErrorCode';

/**
 * 业务错误码
 */
export enum BusinessErrorCode {
  // 认证错误
  AUTH_INVALID_PHONE = 10101,
  AUTH_INVALID_CODE = 10102,
  AUTH_INVALID_PASSWORD = 10103,
  AUTH_SESSION_EXPIRED = 10104,

  // 聊天错误
  CHAT_NOT_FOUND = 10201,
  CHAT_PERMISSION_DENIED = 10202,
  CHAT_SEND_FAILED = 10203,

  // 消息错误
  MESSAGE_NOT_FOUND = 10301,
  MESSAGE_SEND_FAILED = 10302,
  MESSAGE_DELETE_FAILED = 10303,

  // 文件错误
  FILE_UPLOAD_FAILED = 10401,
  FILE_DOWNLOAD_FAILED = 10402,
  FILE_TYPE_NOT_SUPPORTED = 10403,

  // 用户错误
  USER_NOT_FOUND = 10501,
  USER_BLOCKED = 10502,
  USER_DELETED = 10503,

  // 通用错误
  OPERATION_FAILED = 10600,
  UNKNOWN_ERROR = 10601
}

/**
 * 业务错误类
 */
export class BusinessError extends AppError {
  readonly businessCode: BusinessErrorCode;

  constructor(
    businessCode: BusinessErrorCode,
    message: string,
    userMessage: string,
    context?: ErrorContext,
    originalError?: Error
  ) {
    // 将业务错误码映射到系统错误码
    let systemCode: string = 'UNKNOWN_ERROR';
    let category = ErrorCategory.UNKNOWN;

    if (businessCode >= 10100 && businessCode < 10200) {
      systemCode = String(ErrorCode.AUTH_INVALID_CREDENTIALS);
      category = ErrorCategory.AUTH;
    } else if (businessCode >= 10200 && businessCode < 10300) {
      systemCode = String(ErrorCode.UNKNOWN_ERROR);
      category = ErrorCategory.UNKNOWN;
    } else if (businessCode >= 10400 && businessCode < 10500) {
      systemCode = String(ErrorCode.FILE_WRITE_ERROR);
      category = ErrorCategory.UNKNOWN;
    } else if (businessCode >= 10500 && businessCode < 10600) {
      systemCode = String(ErrorCode.AUTH_USER_NOT_FOUND);
      category = ErrorCategory.AUTH;
    }

    super(
      systemCode,
      message,
      ErrorSeverity.ERROR,
      category,
      userMessage,
      originalError,
      context
    );
    this.name = 'BusinessError';
    this.businessCode = businessCode;
  }

  /**
   * 获取用户可读的错误信息
   */
  getUserMessage(): ResourceStr {
    return this.userMessage || this.message;
  }

  /**
   * 转换为JSON对象
   */
  toJSON(): Object {
    let superResult: Object = super.toJSON();
    let resultMap: Map<string, Object> = new Map<string, Object>();
    resultMap.set('businessCode', this.businessCode);
    return resultMap;
  }
}

/**
 * 业务错误工厂
 */
export class BusinessErrorFactory {
  /**
   * 创建认证错误
   */
  static createAuthError(
    code: BusinessErrorCode,
    userMessage: string,
    context?: ErrorContext,
    originalError?: Error
  ): BusinessError {
    const messageMap: Map<number, string> = new Map();
    messageMap.set(BusinessErrorCode.AUTH_INVALID_PHONE, 'Invalid phone number');
    messageMap.set(BusinessErrorCode.AUTH_INVALID_CODE, 'Invalid verification code');
    messageMap.set(BusinessErrorCode.AUTH_INVALID_PASSWORD, 'Invalid password');
    messageMap.set(BusinessErrorCode.AUTH_SESSION_EXPIRED, 'Session expired');

    const message = messageMap.get(code) || 'Authentication error';

    return new BusinessError(
      code,
      message,
      userMessage,
      context,
      originalError
    );
  }

  /**
   * 创建聊天错误
   */
  static createChatError(
    code: BusinessErrorCode,
    userMessage: string,
    context?: ErrorContext,
    originalError?: Error
  ): BusinessError {
    const messageMap: Map<number, string> = new Map();
    messageMap.set(BusinessErrorCode.CHAT_NOT_FOUND, 'Chat not found');
    messageMap.set(BusinessErrorCode.CHAT_PERMISSION_DENIED, 'Permission denied');
    messageMap.set(BusinessErrorCode.CHAT_SEND_FAILED, 'Failed to send message');

    const message = messageMap.get(code) || 'Chat error';

    return new BusinessError(
      code,
      message,
      userMessage,
      context,
      originalError
    );
  }

  /**
   * 创建文件错误
   */
  static createFileError(
    code: BusinessErrorCode,
    userMessage: string,
    context?: ErrorContext,
    originalError?: Error
  ): BusinessError {
    const messageMap: Map<number, string> = new Map();
    messageMap.set(BusinessErrorCode.FILE_UPLOAD_FAILED, 'File upload failed');
    messageMap.set(BusinessErrorCode.FILE_DOWNLOAD_FAILED, 'File download failed');
    messageMap.set(BusinessErrorCode.FILE_TYPE_NOT_SUPPORTED, 'File type not supported');

    const message = messageMap.get(code) || 'File error';

    return new BusinessError(
      code,
      message,
      userMessage,
      context,
      originalError
    );
  }
}
