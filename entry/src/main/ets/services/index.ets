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
export { TdApiFactory, createTdLibAPIs, createCustomTdLibAPIs } from './api/factory/TdApiFactory';
export type { TDLibAPIs } from './api/factory/TdApiFactory';

// Core APIs (13 个)
export { TDLibApi } from './api/TDLibApi';


// ==================== Infrastructure Layer - 基础设施层 ====================
export { ConnectionManager } from './infrastructure/connection/ConnectionManager';
export { ConnectionState as InfraConnectionState } from './infrastructure/connection/ConnectionState';

// ==================== Core Layer - 核心服务层 ====================
export { TDLibClient } from './core/tdlib/TDLibClient';
export type { ConnectionEventListener } from './core/tdlib/TDLibClient';
export { ConnectionState as TdConnectionState } from './core/tdlib/TDLibClient';
export { TDLibReceiver } from './core/tdlib/TDLibReceiver';
export { AuthService } from './business/AuthService';  // ⚠️ 导出类,不创建实例
export { AuthCache } from './business/AuthCache';
export { TDLibCallbackDispatcher } from './core/callback/TDLibCallbackDispatcher';

// Cache Service - 缓存服务（新增）
export { CacheService } from './business/CacheService';




// Calls Domain
export { CallServiceImpl as CallService } from './business/calls/CallServiceImpl';

// Chat Domain
export { CoreService } from './business/CoreService';

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
export { ThemeService } from './business/ThemeService';


// ==================== Network Layer - 网络服务 ====================
export { NetworkMonitorService } from './network/NetworkMonitorService';
export { MTProtoProxyService } from './network/MTProtoProxyService';
export { Socks5ProxyService } from './network/Socks5ProxyService';
export { RequestQueueManager } from './network/RequestQueueManager';

// Network Layer 类型导出
export type {
  RequestType,
  RequestPriority,
  RequestStatus,
  RequestItem,
  BatchRequestConfig
} from './network/RequestQueueManager';

// ==================== Optimization Layer - 优化服务 ====================
export { PerformanceBoostService } from './optimization/PerformanceBoostService';
export { PageContextManager } from './optimization/PageContextManager';

// Optimization Layer 类型导出
export type {
  PageType
} from './optimization/PageContextManager';

// ==================== System Layer - 系统服务 ====================
export { PasscodeHelper } from './system/PasscodeHelper';
export { PushService } from './system/PushService';
export { RemoteNotificationExtAbility } from './system/RemoteNotificationExtAbility';

// System Layer 类型导出