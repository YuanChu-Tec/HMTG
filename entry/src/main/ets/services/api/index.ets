
// Factory
export { TdApiFactory, createTdLibAPIs, createCustomTdLibAPIs } from './factory/TdApiFactory';
export type { TDLibAPIs } from './factory/TdApiFactory';

// Core API
export { TDLibApi } from './TDLibApi';

// TDLib Event Names
export class TdLibEventNames {
  // TDLib 生命周期事件
  static readonly TDLIB_INITIALIZED = 'tdlib.initialized';
  static readonly TDLIB_DESTROYED = 'tdlib.destroyed';

  // 连接事件
  static readonly TDLIB_CONNECTED = 'tdlib.connected';
  static readonly TDLIB_DISCONNECTED = 'tdlib.disconnected';
  static readonly TDLIB_RECONNECTING = 'tdlib.reconnecting';
  static readonly TDLIB_CONNECTION_ERROR = 'tdlib.connection_error';

  // 用户认证事件
  static readonly TDLIB_AUTH_STARTED = 'tdlib.auth.started';
  static readonly TDLIB_AUTH_COMPLETED = 'tdlib.auth.completed';
  static readonly TDLIB_AUTH_FAILED = 'tdlib.auth.failed';
  static readonly TDLIB_USER_LOGGED_OUT = 'tdlib.user.logged_out';

  // 认证状态事件
  static readonly AUTH_STATE_CHANGED = 'auth.state.changed';

  // 连接状态事件
  static readonly CONNECTION_STATE_CHANGED = 'connection.state.changed';

  // 消息事件
  static readonly MESSAGE_RECEIVED = 'message.received';
  static readonly MESSAGE_SENT = 'message.sent';
  static readonly MESSAGE_EDITED = 'message.edited';
  static readonly MESSAGE_DELETED = 'message.deleted';
  static readonly MESSAGE_READ = 'message.read';

  // 聊天事件
  static readonly CHAT_CREATED = 'chat.created';
  static readonly CHAT_UPDATED = 'chat.updated';
  static readonly CHAT_DELETED = 'chat.deleted';
  static readonly CHAT_PHOTO_UPDATED = 'chat.photo_updated';
  static readonly CHAT_TITLE_UPDATED = 'chat.title_updated';
  static readonly CHAT_PERMISSIONS_UPDATED = 'chat.permissions.updated';

  // 用户事件
  static readonly USER_STATUS_UPDATED = 'user.status.updated';
  static readonly USER_PROFILE_PHOTO_UPDATED = 'user.profile_photo.updated';
  static readonly USER_INFO_UPDATED = 'user.info.updated';

  // 联系人事件
  static readonly CONTACT_ADDED = 'contact.added';
  static readonly CONTACT_UPDATED = 'contact.updated';
  static readonly CONTACT_DELETED = 'contact.deleted';

  // 文件事件
  static readonly FILE_DOWNLOAD_STARTED = 'file.download.started';
  static readonly FILE_DOWNLOAD_COMPLETED = 'file.download.completed';
  static readonly FILE_DOWNLOAD_FAILED = 'file.download.failed';
  static readonly FILE_UPLOAD_STARTED = 'file.upload.started';
  static readonly FILE_UPLOAD_COMPLETED = 'file.upload.completed';
  static readonly FILE_UPLOAD_FAILED = 'file.upload.failed';

  // 网络事件
  static readonly NETWORK_TYPE_CHANGED = 'network.type.changed';
  static readonly NETWORK_STATUS_CHANGED = 'network.status.changed';
}
