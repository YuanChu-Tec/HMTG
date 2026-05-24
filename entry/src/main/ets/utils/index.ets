/**
 * Utils 工具库统一导出入口
 *
 * 架构说明:
 * - common/: 通用工具集合（错误、安全、事件、设备、日志等）
 * - auth/: 认证相关工具
 * - chat/: 聊天相关工具
 * - contacts/: 联系人相关工具
 * - privacy/: 隐私相关工具
 * - bots/: Bot 相关工具
 *
 * 使用方式:
 * 1. 全量导入：import { ErrorHandler, CryptoHelper } from '../utils'
 * 2. 按模块导入：import { ErrorHandler } from '../utils/common'
 * 3. 按需导入：import { AppError } from '../utils/common/error/AppError'
 */

// ==================== Common Utils - 通用工具集 ====================
export { ErrorHandler } from './error/ErrorHandler';
export { EventBus } from './event/EventBus';
export { LogService } from './log/LogService';
export { PerformanceMonitor } from './performance/PerformanceMonitor';

// ==================== Formatter Utils ====================
export { TimeFormatter } from './formatter/TimeFormatter';

// ==================== Validation Utils ====================
export { DataValidator } from './validation/DataValidator';

// ==================== I18n Utils ====================
export { i18n } from './i18n/I18n';
export { getString, formatString } from './i18n/ResourceHelper';

// ==================== File Utils ====================
export { FileHelper } from './file/FileHelper';

// ==================== Privacy Utils - 隐私工具 ====================
export { DataCrypto } from './DataCrypto';


// ==================== System Utils - 系统工具 ====================
export { PathManager } from './PathManager';
export { CacheCleaner } from './CacheCleaner';
