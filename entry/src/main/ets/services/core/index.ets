/**
 * Core Layer - 核心服务
 * 
 * TDLib 核心封装与认证服务：
 * - TDLib Client: TDLib 客户端单例，管理连接和请求
 * - TDLib Executor: TDLib 请求执行器，处理请求优先级和重试
 * - TDLib Receiver: TDLib 更新接收器，轮询接收更新
 * - Auth Service: 认证流程管理
 * - Callback Dispatcher: 回调分发器
 */

// TDLib Core
export { TDLibClient } from './tdlib/TDLibClient';
export type { ConnectionEventListener } from './tdlib/TDLibClient';
export { ConnectionState as TdConnectionState } from './tdlib/TDLibClient';
export { getProp } from './tdlib/TDLibClient';
export { TDLibExecutor } from './tdlib/TDLibExecutor';
export { RequestPriority } from './tdlib/TDLibExecutor';
export type { RequestConfig } from './tdlib/TDLibExecutor';
export { TDLibReceiver } from './tdlib/TDLibReceiver';

// Auth
export { AuthService } from '../business/auth/AuthService';
export { AuthCache } from '../business/kernel/SecureStorage';
// Auth 相关类型（从 AuthService 统一导出）
export type {
  TokenType,
  TokenInfo,
  TokenConfig,
  TokenStats,
  TokenValidationResult,
  BiometricType,
  BiometricAuthResult,
  BiometricAuthConfig,
  VerificationCodeType,
  VerificationCodeStatus,
  VerificationCodeInfo,
  VerificationResult,
  PermissionStatus,
  PhoneValidationResult
} from '../business/auth/AuthService';

// Callback
export { TDLibCallbackDispatcher } from './callback/TDLibCallbackDispatcher';
