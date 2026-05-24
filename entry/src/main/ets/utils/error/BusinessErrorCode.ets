/**
 * 业务错误码定义
 * 定义应用中所有业务错误的错误码
 */

/**
 * 业务错误码枚举
 */
export enum BusinessErrorCode {
  // 通用错误
  SUCCESS = 0,
  OPERATION_FAILED = 1000,
  INVALID_PARAM = 1001,
  UNKNOWN_ERROR = 1002,

  // 网络错误
  NETWORK_ERROR = 2000,
  NETWORK_TIMEOUT = 2001,
  NETWORK_DISCONNECTED = 2002,

  // 数据库错误
  DATABASE_ERROR = 3000,
  DATABASE_QUERY_FAILED = 3001,
  DATABASE_INSERT_FAILED = 3002,
  DATABASE_UPDATE_FAILED = 3003,
  DATABASE_DELETE_FAILED = 3004,

  // 消息错误
  MESSAGE_NOT_FOUND = 4000,
  MESSAGE_SEND_FAILED = 4001,
  MESSAGE_DECRYPT_FAILED = 4002,
  MESSAGE_ENCRYPT_FAILED = 4003,

  // 文件错误
  FILE_NOT_FOUND = 5000,
  FILE_READ_FAILED = 5001,
  FILE_WRITE_FAILED = 5002,
  FILE_DOWNLOAD_FAILED = 5003,
  FILE_UPLOAD_FAILED = 5004,

  // 认证错误
  AUTH_FAILED = 6000,
  TOKEN_EXPIRED = 6001,
  TOKEN_INVALID = 6002,

  // 权限错误
  PERMISSION_DENIED = 7000,
  PERMISSION_NOT_GRANTED = 7001,

  // 缓存错误
  CACHE_ERROR = 8000,
  CACHE_KEY_NOT_FOUND = 8001,
  CACHE_UPDATE_FAILED = 8002,

  // 聊天错误
  CHAT_NOT_FOUND = 9000,
  CHAT_LOAD_FAILED = 9001,

  // 媒体错误
  MEDIA_ERROR = 10000,
  MEDIA_LOAD_FAILED = 10001,
  MEDIA_DECODE_FAILED = 10002,
  MEDIA_THUMBNAIL_FAILED = 10003,

  // TDLib 错误
  TDLIB_ERROR = 11000,
  TDLIB_INIT_FAILED = 11001,
  TDLIB_SEND_FAILED = 11002,
  TDLIB_RECEIVE_FAILED = 11003
}

/**
 * 获取错误描述
 */
export function getErrorMessage(code: BusinessErrorCode): string {
  const messages: Record<BusinessErrorCode, string> = {
    [BusinessErrorCode.SUCCESS]: '成功',
    [BusinessErrorCode.OPERATION_FAILED]: '操作失败',
    [BusinessErrorCode.INVALID_PARAM]: '参数无效',
    [BusinessErrorCode.UNKNOWN_ERROR]: '未知错误',

    [BusinessErrorCode.NETWORK_ERROR]: '网络错误',
    [BusinessErrorCode.NETWORK_TIMEOUT]: '网络超时',
    [BusinessErrorCode.NETWORK_DISCONNECTED]: '网络未连接',

    [BusinessErrorCode.DATABASE_ERROR]: '数据库错误',
    [BusinessErrorCode.DATABASE_QUERY_FAILED]: '数据库查询失败',
    [BusinessErrorCode.DATABASE_INSERT_FAILED]: '数据库插入失败',
    [BusinessErrorCode.DATABASE_UPDATE_FAILED]: '数据库更新失败',
    [BusinessErrorCode.DATABASE_DELETE_FAILED]: '数据库删除失败',

    [BusinessErrorCode.MESSAGE_NOT_FOUND]: '消息未找到',
    [BusinessErrorCode.MESSAGE_SEND_FAILED]: '消息发送失败',
    [BusinessErrorCode.MESSAGE_DECRYPT_FAILED]: '消息解密失败',
    [BusinessErrorCode.MESSAGE_ENCRYPT_FAILED]: '消息加密失败',

    [BusinessErrorCode.FILE_NOT_FOUND]: '文件未找到',
    [BusinessErrorCode.FILE_READ_FAILED]: '文件读取失败',
    [BusinessErrorCode.FILE_WRITE_FAILED]: '文件写入失败',
    [BusinessErrorCode.FILE_DOWNLOAD_FAILED]: '文件下载失败',
    [BusinessErrorCode.FILE_UPLOAD_FAILED]: '文件上传失败',

    [BusinessErrorCode.AUTH_FAILED]: '认证失败',
    [BusinessErrorCode.TOKEN_EXPIRED]: '令牌已过期',
    [BusinessErrorCode.TOKEN_INVALID]: '令牌无效',

    [BusinessErrorCode.PERMISSION_DENIED]: '权限被拒绝',
    [BusinessErrorCode.PERMISSION_NOT_GRANTED]: '权限未授予',

    [BusinessErrorCode.CACHE_ERROR]: '缓存错误',
    [BusinessErrorCode.CACHE_KEY_NOT_FOUND]: '缓存键未找到',
    [BusinessErrorCode.CACHE_UPDATE_FAILED]: '缓存更新失败',

    [BusinessErrorCode.CHAT_NOT_FOUND]: '聊天未找到',
    [BusinessErrorCode.CHAT_LOAD_FAILED]: '聊天加载失败',

    [BusinessErrorCode.MEDIA_ERROR]: '媒体错误',
    [BusinessErrorCode.MEDIA_LOAD_FAILED]: '媒体加载失败',
    [BusinessErrorCode.MEDIA_DECODE_FAILED]: '媒体解码失败',
    [BusinessErrorCode.MEDIA_THUMBNAIL_FAILED]: '媒体缩略图生成失败',

    [BusinessErrorCode.TDLIB_ERROR]: 'TDLib 错误',
    [BusinessErrorCode.TDLIB_INIT_FAILED]: 'TDLib 初始化失败',
    [BusinessErrorCode.TDLIB_SEND_FAILED]: 'TDLib 发送失败',
    [BusinessErrorCode.TDLIB_RECEIVE_FAILED]: 'TDLib 接收失败'
  };

  return messages[code] || '未知错误';
}
