/**
 * Services 统一导出入口
 * 
 * 架构说明:
 * - api/: TDLib API 工厂层（21 个 API 模块）
 * - infrastructure/: 基础设施层（Worker、连接管理）
 * - core/: 核心服务层（TDLib Client、认证）
 * - business/: 业务服务层（聊天、群组、用户等）
 * - data/: 数据持久化层（存储、文件、缓存）
 * - network/: 网络通信层（监控、代理、请求队列）
 * - optimization/: 性能优化层
 * - system/: 系统服务层（国际化、推送、密码）
 * 
 * 使用方式:
 * 1. 全量导入：import { CoreService, TdApiFactory } from '../services'
 * 2. 按层导入：import { TdApiFactory } from '../services/api'
 * 3. 按需导入：import { ChatApi } from '../services/api/core-apis/ChatApi'
 */

// ==================== API Layer - API 工厂层 ====================
export { TdApiFactory, createTdLibAPIs, createCustomTdLibAPIs } from './core/api/factory/TdApiFactory';
export type { TDLibAPIs } from './core/api/factory/TdApiFactory';

// Core APIs (13 个)
export { TDLibApi } from './core/api/TDLibApi';

// ==================== Core Layer - 核心服务层 ====================
export { TDLibClient } from './core/tdlib/TDLibClient';
export type { ConnectionEventListener } from './core/tdlib/TDLibClient';
export { ConnectionState as TdConnectionState } from './core/tdlib/TDLibClient';
export { TDLibReceiver } from './core/tdlib/TDLibReceiver';
export { AuthService } from './business/auth/AuthService'; // ⚠️ 导出类,不创建实例
export { AuthCache } from './business/kernel/SecureStorage';
export { TDLibCallbackDispatcher } from './core/callback/TDLibCallbackDispatcher';

// Cache Service - 缓存服务（新增）
export { CacheService } from './business/storage/MessagesStorage';

// Chat Domain
export { CoreService } from './business/messages/MessagesController';

// Contacts Domain (已合并到 CoreService)
export type {
  Contact,
  ContactGroup,
  ContactListItemData,
  ContactSearchResult,
  ContactStats,
  OnlineStatus,
  UserStatus,
  SyncStatus,
  PhoneNumber
} from '../models/TDLibData';

// Settings Domain
export { ThemeService } from './business/theme/ChatThemeController';


// ==================== Network Layer - 网络服务 ====================
export { NetworkMonitorService } from './business/kernel/ConnectionMonitor';
export { MTProtoProxyService } from './network/MTProtoProxyService';
export { Socks5ProxyService } from './network/Socks5ProxyService';

// ==================== System Layer - 系统服务 ====================
export { PushService } from './business/notification/PushController';


// System Layer 类型导出