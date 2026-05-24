/**
 * 认证错误提示助手
 * 根据 TDLib/Telegram 返回的 code 与 message 映射为国际化友好文案（参考 core.telegram.org/api/errors）
 * 统一接口：所有登录流程错误均通过 getAuthErrorDisplayMessage 取文案，避免重复与硬编码
 */

import { getString, formatString } from './i18n/ResourceHelper';

/** 静默错误：不向用户展示（如"需输入密码"等非失败场景） */
export const AUTH_ERROR_SILENT = '';

/**
 * 根据错误码与消息返回国际化资源 key；静默错误返回 AUTH_ERROR_SILENT
 * 覆盖 Telegram auth 可能返回的全部错误码与 message 关键字
 */
export function getAuthErrorLocaleKey(errorCode?: number, errorMessage?: string): string {
  const code = errorCode ?? 0;
  const msg = (errorMessage ?? '').trim();

  // 406 / 要求更新应用
  if (code === 406 || msg.includes('UPDATE_APP_TO_LOGIN')) {
    return 'auth_update_app';
  }
  // API 未配置
  if (msg.includes('Valid api_id must be provided') || msg.includes('Valid api_id')) {
    return 'auth_config_api';
  }
  // 未初始化 / 需先 setTdlibParameters
  if (msg.includes('setTdlibParameters first') || msg.includes('Initialization parameters are needed')) {
    return 'auth_init_failed';
  }
  // ⭐ 新增：号码/账号受限与格式（完整覆盖 Telegram 所有错误码）
  if (msg.includes('PHONE_NUMBER_BANNED')) {
    return 'auth_phone_banned';
  }
  if (msg.includes('PHONE_NUMBER_INVALID')) {
    return 'auth_phone_invalid';
  }
  if (msg.includes('PHONE_NUMBER_FLOOD')) {
    return 'auth_phone_flood';
  }
  if (msg.includes('PHONE_NUMBER_APP_SIGNUP_FORBIDDEN')) {
    return 'auth_phone_app_signup_forbidden';
  }
  if (msg.includes('PHONE_PASSWORD_PROTECTED')) {
    return 'auth_phone_password_protected';
  }
  if (msg.includes('PHONE_PASSWORD_FLOOD')) {
    return 'auth_phone_password_flood';
  }
  if (msg.includes('PHONE_MIGRATE') || code === 303) {
    return 'auth_phone_migrate';
  }
  // ⭐ 新增：验证码相关错误（完整覆盖）
  if (msg.includes('PHONE_CODE_EXPIRED')) {
    return 'auth_phone_code_expired';
  }
  if (msg.includes('PHONE_CODE_INVALID')) {
    return 'auth_phone_code_invalid';
  }
  if (msg.includes('PHONE_CODE_HASH_EMPTY')) {
    return 'auth_code_hash_empty';
  }
  // 重新发送时验证码尚未下发（400 + unexpected）
  if (msg.includes('验证码尚未下发') || (code === 400 && msg.includes('unexpected'))) {
    return 'auth_code_not_ready';
  }
  // ⭐ 新增：注册相关错误
  if (msg.includes('FIRSTNAME_INVALID')) {
    return 'auth_firstname_invalid';
  }
  if (msg.includes('LASTNAME_INVALID')) {
    return 'auth_lastname_invalid';
  }
  if (msg.includes('USERNAME_INVALID')) {
    return 'auth_username_invalid';
  }
  if (msg.includes('USERNAME_OCCUPIED')) {
    return 'auth_username_occupied';
  }
  // 429 / FLOOD_WAIT：由 getDisplayMessage 解析秒数并格式化
  if (code === 429 || msg.includes('FLOOD_WAIT') || msg.includes('Too Many Requests')) {
    return 'auth_flood_wait';
  }
  // ⭐ 新增：两步验证密码错误（完整覆盖）
  if (msg.includes('PASSWORD_HASH_INVALID') || msg.includes('PASSWORD_RECOVERY_NA')) {
    return 'auth_password_invalid';
  }
  if (msg.includes('PASSWORD_EMPTY')) {
    return 'auth_password_empty';
  }
  if (msg.includes('PASSWORD_REQUIRED')) {
    return 'auth_password_required';
  }
  if (msg.includes('PASSWORD_RECOVERY_EXPIRED')) {
    return 'auth_recovery_code_expired';
  }
  if (msg.includes('PASSWORD_RECOVERY_FAILED')) {
    return 'auth_recovery_code_failed';
  }
  // ⭐ 新增：账号状态相关错误
  if (msg.includes('USER_DEACTIVATED') || msg.includes('USER_DEACTIVATED_BAN')) {
    return 'auth_user_deactivated';
  }
  if (msg.includes('SESSION_REVOKED') || msg.includes('AUTH_KEY_UNREGISTERED')) {
    return 'auth_session_revoked';
  }
  if (msg.includes('SESSION_PASSWORD_NEEDED')) {
    return 'auth_session_password_needed';
  }
  // 网络/连接类
  if (msg.includes('Connection') || msg.includes('connection') || msg.includes('NETWORK')) {
    return 'auth_network_error';
  }
  if (msg.includes('Timeout') || msg.includes('timeout')) {
    return 'auth_timeout';
  }
  // ⭐ 新增：数据库相关错误
  if (msg.includes('DATABASE_FILE_INVALID') || msg.includes('ENCRYPTION_KEY_INVALID')) {
    return 'auth_database_error';
  }
  // 静默：重复 setTdlibParameters、验证码通过需输入密码等
  if (msg.includes('Unexpected setTdlibParameters')) {
    return AUTH_ERROR_SILENT;
  }
  if (msg.includes('password') || msg.includes('PASSWORD') ||
      msg.includes('incomplete') || msg.includes('Login attempt')) {
    return AUTH_ERROR_SILENT;
  }

  return 'auth_op_failed';
}

/**
 * 返回可直接展示的友好文案；若为静默错误则返回空字符串（调用方可不弹 Toast）
 */
export function getAuthErrorDisplayMessage(errorCode?: number, errorMessage?: string): string {
  const code = errorCode ?? 0;
  const msg = (errorMessage ?? '').trim();
  const key = getAuthErrorLocaleKey(code, msg);
  if (key === AUTH_ERROR_SILENT) {
    return '';
  }

  // 429 / FLOOD_WAIT：解析 retry_after 秒数并格式化
  if (code === 429 || msg.includes('FLOOD_WAIT') || msg.includes('Too Many Requests')) {
    const matchRetry = msg.match(/retry\s+after\s+(\d+)/i) || msg.match(/FLOOD_WAIT_(\d+)/i) || msg.match(/(\d{2,})/);
    if (matchRetry && matchRetry[1]) {
      const seconds = parseInt(matchRetry[1], 10);
      if (seconds >= 3600) {
        const hours = Math.ceil(seconds / 3600);
        return formatString('auth_flood_wait_hours', hours);
      }
      if (seconds > 0) {
        return formatString('auth_flood_wait_seconds', seconds);
      }
    }
    return getString('auth_flood_wait');
  }

  return getString(key);
}
