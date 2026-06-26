import { hilog } from '@kit.PerformanceAnalysisKit';
import { bundleManager } from '@kit.AbilityKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import i18n from '@ohos.i18n';
import { TELEGRAM_API_ID, TELEGRAM_API_HASH } from './TelegramApiConfig';

const TAG = 'TDLibConfig';
const DOMAIN = 0x0001;

/** 设备信息 V2 接口 */
interface DeviceInfoV2 {
  device_model: string;
  system_version: string;
  application_version: string;
  system_language_code: string;
  api_id: number;
  api_hash: string;
  use_test_dc: boolean;
  database_directory: string;
  files_directory: string;
  use_file_database: boolean;
  use_chat_info_database: boolean;
  use_message_database: boolean;
  use_secret_chats: boolean;
  enable_secret_chats: boolean;
  use_qrcode: boolean;
  enable_storage_optimizer: boolean;
  ignore_file_names: boolean;
}

/** 默认配置接口 */
interface DefaultConfig {
  use_test_dc: boolean;
  database_directory: string;
  files_directory: string;
  use_file_database: boolean;
  use_chat_info_database: boolean;
  use_message_database: boolean;
  use_secret_chats: boolean;
  api_id: number;
  api_hash: string;
  system_language_code: string;
  device_model: string;
  system_version: string;
  application_version: string;
}

/** 配置验证结果接口 */
interface ConfigValidationResult {
  valid: boolean;
  errors: string[];
}

/** 应用名称（显示在登录设备列表中） */
export const TELEGRAM_APP_NAME: string = 'HMTG';

/** 默认系统语言代码 */
export const TELEGRAM_LANGUAGE_CODE_DEFAULT: string = 'zh-CN';

/**
 * 获取系统语言代码（动态获取）
 * @returns 系统语言代码，如 'zh-cn', 'en-us' 等
 */
export function getSystemLanguageCode(): string {
  try {
    // 通过 HarmonyOS i18n API 获取系统语言
    const systemLanguage = i18n.getSystemLanguage();
    if (systemLanguage && systemLanguage.length > 0) {
      // 转换为小写，并替换可能的分隔符
      return systemLanguage.toLowerCase().replace('_', '-');
    }
  } catch (error) {
    hilog.warn(DOMAIN, TAG, `Failed to get system language, using default: ${TELEGRAM_LANGUAGE_CODE_DEFAULT}`);
  }
  // 返回默认值
  return TELEGRAM_LANGUAGE_CODE_DEFAULT;
}

/** 超时配置接口 */
interface TimeoutConfig {
  request: number;
  connect: number;
  receive: number;
}

/** 超时配置（毫秒） */
export const TELEGRAM_TIMEOUT_CONFIG: TimeoutConfig = {
  request: 30000,      // 请求超时
  connect: 10000,      // 连接超时
  receive: 1000        // 接收超时
};

/** 重试配置接口 */
interface RetryConfig {
  maxAttempts: number;
  baseDelay: number;
  maxDelay: number;
}

/** 重试配置 */
export const TELEGRAM_RETRY_CONFIG: RetryConfig = {
  maxAttempts: 3,       // 最大重试次数
  baseDelay: 1000,      // 基础延迟
  maxDelay: 30000       // 最大延迟
};

/** 日志配置接口 */
interface LogConfig {
  enable: boolean;
  level: string;
  tag: string;
}

/** 日志配置 */
export const TELEGRAM_LOG_CONFIG: LogConfig = {
  enable: true,          // 是否启用日志
  level: 'info',        // 日志级别: debug, info, warn, error
  tag: 'TdLib'         // 日志标签
};

/** 数据库配置接口 */
interface DatabaseConfig {
  directory: string;
  useMessageDatabase: boolean;
  enableStats: boolean;
}

/** 数据库配置 */
export const TELEGRAM_DATABASE_CONFIG: DatabaseConfig = {
  directory: '',  // 空字符串，将在运行时动态获取
  useMessageDatabase: true,           // 是否使用消息数据库
  enableStats: false                  // 是否启用统计
};

/**
 * 获取应用版本 - 从项目配置读取
 * 优先级：build-profile.json5 > 默认值
 */
export const getTelegramAppVersion = async (): Promise<string> => {
  try {
    const bundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    const versionName = bundleInfo.versionName;
    return versionName || 'unknown';
  } catch (error) {
    console.warn('Failed to get app version, using default:', error);
    return 'unknown';
  }
};

/**
 * 获取设备型号（用于 TDLib 回执显示）
 * 优先使用品牌名称（如 HUAWEI），其次使用产品型号
 * @returns 设备型号字符串
 */
export function getDeviceModel(): string {
  try {
    // 优先使用品牌名称，其次使用产品型号
    const brand: string = deviceInfo.brand;
    if (brand && brand.length > 0) {
      // 转换为大写，如 'HUAWEI'
      return brand.toUpperCase(); 
    }
    // 如果获取不到品牌，尝试获取产品型号
    const productModel: string = deviceInfo.productModel;
    if (productModel && productModel.length > 0) {
      return productModel;
    }
    return deviceInfo.productModel || 'HarmonyOS Device';
  } catch (error) {
    hilog.warn(DOMAIN, TAG, 'Failed to get device model, using default:', error);
    return 'HarmonyOS Device';
  }
}

/**
 * 获取系统版本（用于 TDLib 回执显示）
 * 目标格式: "PLR-AL00 6.0.0.328(SP52C00E105R7P4)"
 * @returns 系统版本字符串
 */
export function getSystemVersion(): string {
  try {
    // ⭐ 直接使用 displayVersion，它已经包含了完整的版本信息
    // 例如: "PLR-AL00 6.0.0.328(SP52C00E105R7P4)"
    const displayVersion = deviceInfo.displayVersion;
    if (displayVersion && displayVersion.length > 0) {
      return displayVersion;
    }

    return displayVersion;
  } catch (error) {
    hilog.warn(DOMAIN, TAG, 'Failed to get system version, using default:', error);
    return 'HarmonyOS';
  }
}

/**
 * 获取 Telegram 设备信息（完整配置）
 * 动态获取设备模型、系统版本、应用版本和 TDLib 配置参数
 * @param context UIAbilityContext，用于获取应用沙箱路径（必需）
 */
export async function getTelegramDeviceInfo(context: common.UIAbilityContext): Promise<Record<string, Object>> {
  try {
    // 获取基础设备信息
    const systemVersion = getSystemVersion();
    const deviceModel = getDeviceModel();
    const appVersion = await getTelegramAppVersion();
    const systemLanguageCode = getSystemLanguageCode(); // 动态获取系统语言

    hilog.info(DOMAIN, TAG, `Device Info - Model: ${deviceModel}, System: ${systemVersion}, App: ${appVersion}`);

    // 构建完整的设备信息（兼容 tdlib_bridge 格式）
    const deviceInfo: Record<string, Object> = {};
    // 手动设置属性，避免对象字面量
    deviceInfo['device_model'] = deviceModel || 'HarmonyOS Device';
    deviceInfo['system_version'] = systemVersion || 'HarmonyOS';
    deviceInfo['application_version'] = appVersion || 'unknown';
    deviceInfo['system_language_code'] = systemLanguageCode; // 使用动态获取的语言代码
    deviceInfo['api_id'] = TELEGRAM_API_ID;
    deviceInfo['api_hash'] = TELEGRAM_API_HASH;
    deviceInfo['use_test_dc'] = false;

    // 使用应用沙箱内的正确目录（必须通过 context 获取）
    deviceInfo['database_directory'] = context.filesDir + '/tdlib';
    deviceInfo['files_directory'] = context.filesDir;

    // 【调试优化】如果数据库目录有问题，可以临时设置为空字符串，让 TDLib 使用当前工作目录
    // deviceInfo['database_directory'] = ''; // 取消注释以启用调试模式

    deviceInfo['use_file_database'] = true;
    deviceInfo['use_chat_info_database'] = true;
    deviceInfo['use_message_database'] = TELEGRAM_DATABASE_CONFIG.useMessageDatabase;
    deviceInfo['use_secret_chats'] = true;
    deviceInfo['enable_storage_optimizer'] = true;
    deviceInfo['ignore_file_names'] = false;

    hilog.info(DOMAIN, TAG, `TDLib Config - API ID: ${deviceInfo['api_id']}, Hash: ${(deviceInfo['api_hash'] as string).length}chars, DB: ${deviceInfo['database_directory']}`);
    return deviceInfo;
  } catch (error) {
    hilog.error(DOMAIN, TAG, `Failed to get device info:`, error);
    throw new Error(`Failed to get device info: ${error}`);
  }
}

/**
 * 验证配置是否有效
 * @param config 配置对象
 * @returns 验证结果和错误信息
 */
export function validateConfig(config: Record<string, Object>): ConfigValidationResult {
  const errors: string[] = [];

  // 检查必需字段
  const requiredFields = ['api_id', 'api_hash', 'database_directory', 'files_directory'];
  for (const field of requiredFields) {
    if (!config[field]) {
      errors.push(`Missing required field: ${field}`);
    }
  }

  // 检查字段类型
  if (config.api_id && typeof config.api_id !== 'number') {
    errors.push('api_id must be a number');
  }

  if (config.api_hash && typeof config.api_hash !== 'string') {
    errors.push('api_hash must be a string');
  }

  if (config.database_directory && typeof config.database_directory !== 'string') {
    errors.push('database_directory must be a string');
  }

  if (config.files_directory && typeof config.files_directory !== 'string') {
    errors.push('files_directory must be a string');
  }

  return {
    valid: errors.length === 0,
    errors
  };
}

/**
 * 获取 TDLib 参数配置（主函数）
 * 返回完整的 TDLib 初始化参数
 * @param context UIAbilityContext，用于获取应用沙箱路径（必需）
 */
export async function getTdLibParameters(context: common.UIAbilityContext): Promise<Record<string, Object>> {
  try {
    const deviceInfo = await getTelegramDeviceInfo(context);

    // 构建 TDLib 参数（与 TDLibApi.setTdlibParameters 保持严格一致）
    const parameters: Record<string, Object> = {};
    parameters['@type'] = 'setTdlibParameters';
    parameters['use_test_dc'] = deviceInfo.use_test_dc as boolean;
    parameters['database_directory'] = deviceInfo.database_directory as string;
    parameters['files_directory'] = deviceInfo.files_directory as string;
    // ⭐ 关键修复：TDLib 要求 database_encryption_key 为空字符串，而非 Uint8Array
    // 参考 Nekogram 实现：空字符串表示不加密数据库
    parameters['database_encryption_key'] = '';
    parameters['use_file_database'] = deviceInfo.use_file_database as boolean;
    parameters['use_chat_info_database'] = deviceInfo.use_chat_info_database as boolean;
    parameters['use_message_database'] = deviceInfo.use_message_database as boolean;
    parameters['use_secret_chats'] = deviceInfo.use_secret_chats as boolean;
    parameters['api_id'] = deviceInfo.api_id as number;
    parameters['api_hash'] = deviceInfo.api_hash as string;
    parameters['system_language_code'] = deviceInfo.system_language_code as string;
    parameters['device_model'] = deviceInfo.device_model as string;
    parameters['system_version'] = deviceInfo.system_version as string;
    parameters['application_version'] = deviceInfo.application_version as string;

    hilog.info(DOMAIN, TAG, `TDLib Paths - DB: ${parameters['database_directory']}, Files: ${parameters['files_directory']}`);
    return parameters;
  } catch (error) {
    hilog.error(DOMAIN, TAG, `Failed to get TDLib parameters:`, error);
    throw new Error(`Failed to get TDLib parameters: ${error}`);
  }
}