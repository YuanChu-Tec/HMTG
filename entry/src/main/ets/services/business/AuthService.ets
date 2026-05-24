/**
 * 认证服务
 * 与TDLib桥接层交互的核心服务
 *
 * 使用真实的 TDLib Bridge API (TDLibApi, TDLibClient, TdApiFactory)
 * 迁移日期: 2026-03-15
 */

import { TDLibApi, TdApiFactory } from '../api';
import type { phoneNumberAuthenticationSettings$Input, AuthorizationState, ResendCodeReason$Input } from '../api/factory/tdlib-types';
import { TDLibClient } from '../core';
import { BusinessError as SystemBusinessError, BusinessError, emitter } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { util } from '@kit.ArkTS';
import { preferences } from '@kit.ArkData';
import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';
import { userAuth } from '@kit.UserAuthenticationKit';
import {
  SetPhoneNumberResult,
  CheckCodeResult,
  CheckPasswordResult,
  AuthResult,
  AuthErrorCode,
  AuthState
} from '../../models';
import { authCache } from '../business/AuthCache';
import { SessionEncryption } from '../../utils/SessionEncryption';
import { TDLibAuthManager } from '../core/tdlib/TDLibAuthManager';

/** 验证码信息缓存接口 */
export interface CodeInfoCache {
  type: string;
  length: number;
  timeout?: number; // ⭐ 新增：超时时间(秒)
}

// ==================== Phone Service Types ====================
export interface PhoneValidationResult {
  isValid: boolean;
  errorMessage?: string;
  formattedPhone?: string;
}

// ==================== Permission Manager Types ====================
export enum PermissionStatus {
  GRANTED = 'granted',
  DENIED = 'denied',
  NOT_REQUESTED = 'not_requested'
}

// ==================== Biometric Auth Types ====================
export enum BiometricType {
  FINGERPRINT = 'fingerprint',
  FACE = 'face',
  VOICE = 'voice',
  IRIS = 'iris',
}

export interface BiometricAuthResult {
  success: boolean;
  type?: BiometricType;
  errorCode?: number;
  errorMessage?: string;
  timestamp: number;
}

export interface BiometricAuthConfig {
  type?: BiometricType;
  title?: string;
  description?: string;
  cancelButtonText?: string;
  timeout?: number;
  allowDeviceCredential?: boolean;
  cacheDuration?: number;
  forceAuth?: boolean;
}

// ==================== Token Manager Types ====================
export enum TokenType {
  ACCESS_TOKEN = 'access_token',
  REFRESH_TOKEN = 'refresh_token',
  SESSION_TOKEN = 'session_token',
  TEMPORARY_TOKEN = 'temporary_token',
}

export interface TokenInfo {
  type: TokenType;
  token: string;
  userId?: number;
  deviceId?: string;
  expiresAt: number;
  createdAt: number;
  scopes: string[];
  revoked?: boolean;
}

export interface TokenConfig {
  type: TokenType;
  userId?: number;
  deviceId?: string;
  expiresIn?: number;
  scopes?: string[];
}

export interface TokenValidationResult {
  isValid: boolean;
  tokenInfo?: TokenInfo;
  errorMessage?: string;
}

export interface TokenStats {
  totalTokens: number;
  activeTokens: number;
  expiredTokens: number;
  revokedTokens: number;
  byType: Record<string, number>;
}

// ==================== Code Verification Types ====================
export enum VerificationCodeType {
  SMS = 'sms',
  CALL = 'call',
  FLASH_CALL = 'flash_call'
}

export enum VerificationCodeStatus {
  IDLE = 'idle',
  SENDING = 'sending',
  SENT = 'sent',
  VERIFYING = 'verifying',
  VERIFIED = 'verified',
  FAILED = 'failed',
  EXPIRED = 'expired'
}

export interface VerificationCodeInfo {
  phoneNumber: string;
  codeType: VerificationCodeType;
  sendTime: number;
  expireTime: number;
  attempts: number;
  status: VerificationCodeStatus;
}

export interface VerificationResult {
  success: boolean;
  status: VerificationCodeStatus;
  errorMessage?: string;
  nextStep?: string;
}

interface GeneratedObjectLiteralInterface_1 {
  '_': string;
  'allow_flash_call': boolean;
  'allow_missed_call': boolean;
  'is_current_phone_number': boolean;
}

export class AuthService {
  private static instance?: AuthService;
  private tdClient: TDLibClient | null = null;
  private tdLibApi: TDLibApi | null = null;
  private static readonly TAG: string = 'AuthService';
  private static readonly DOMAIN: number = 0x0001;
  private isInitialized: boolean = false;
  // 认证状态缓存键
  private static readonly AUTH_STATE_KEY = 'auth_state';
  private static readonly AUTH_COMPLETED_KEY = 'auth_completed';
  
  /** 缓存最后一次收到的验证码信息，供 AuthCodePage 启动时同步 */
  public static lastCodeInfo: CodeInfoCache | null = null;
  
  /** ⭐ 新增：首次收到验证码的时间戳（毫秒），用于跨页面恢复倒计时 */
  public static lastCodeTimestamp: number = 0;
  
  private currentAuthState: string = 'authorizationStateWaitTdlibParameters';
  private sessionEncryption: SessionEncryption;
  private resendTimer: number = -1;

  private constructor() {
    this.sessionEncryption = SessionEncryption.getInstance();
    this.initializeClient();
    this.setupAuthStateListener();
  }

  /**
   * 设置认证状态监听器
   * 
   * 通过 TDLibAuthManager 监听认证状态变化，而非直接监听原始 TDLib 事件
   * 这符合新的架构流程：UpdateService → CoreService → TDLibAuthManager → AuthService
   */
  private setupAuthStateListener(): void {
    const authManager = TDLibAuthManager.getInstance();
    
    // 使用 TDLibAuthManager 提供的回调机制
    authManager.executeWhenReady(() => {
      hilog.info(AuthService.DOMAIN, AuthService.TAG, 'Auth ready callback executed');
      this.currentAuthState = 'authorizationStateReady';
    }, 'AuthService state sync');
    
    hilog.info(AuthService.DOMAIN, AuthService.TAG, 'Auth state listener setup via TDLibAuthManager');
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService();
    }
    return AuthService.instance;
  }

  /**
   * 初始化 TDLib 客户端和 API 实例
   */
  private async initializeClient(): Promise<void> {
    try {
      // 使用 TdApiFactory 获取 TDLib 实例和 API
      const factory = TdApiFactory.getInstance();
      this.tdClient = factory.getTdClient();
      this.tdLibApi = factory.createDefault();

      // 初始化 TDLib 客户端
      // 注意：TDLib 初始化会在应用启动时由入口统一处理
      // 此处不需要重复调用 initialize

      this.isInitialized = true;
      hilog.info(AuthService.DOMAIN, AuthService.TAG, 'AuthService initialized successfully');
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(AuthService.DOMAIN, AuthService.TAG, `Initialize auth service failed: ${err.message}`);
      throw new Error(String(err));
    }
  }

  /**
   * 确保客户端已初始化
   */
  private async ensureClientInitialized(): Promise<void> {
    if (!this.isInitialized) {
      await this.initializeClient();
    }
    if (!this.tdClient || !this.tdLibApi) {
      throw new Error('TDLib 客户端或 API 未初始化');
    }
  }

  /**
   * 设置认证手机号
   * 发送验证码到指定手机号
   */
  public async setAuthenticationPhoneNumber(phoneNumber: string): Promise<SetPhoneNumberResult> {
    await this.ensureClientInitialized();
    hilog.info(AuthService.DOMAIN, AuthService.TAG, `setAuthenticationPhoneNumber: ${phoneNumber}`);

    try {
      if (!this.tdLibApi) {
        throw new Error('TDLibApi not initialized');
      }

      // ⭐ 关键修复：构建认证设置对象，参考 HMTG1.0.2 最佳实践
      // - is_current_phone_number: true，表示当前认证即本机号码，便于服务器下发验证码
      // - allow_flash_call / allow_missed_call: true，允许来电方式，部分地区/运营商下更易收到码
      // - allow_sms_retriever_api: false（非官方应用）
      const authSettings: phoneNumberAuthenticationSettings$Input = {
        '_': 'phoneNumberAuthenticationSettings',
        'allow_flash_call': true,          // ⭐ 修复：允许闪呼
        'allow_missed_call': true,         // 允许未接来电
        'is_current_phone_number': true,   // ⭐ 修复：表示当前设备号码
        'allow_sms_retriever_api': false,  // 非官方应用
        'authentication_tokens': []        // 认证令牌数组
      };

      const response = await this.tdLibApi.setAuthenticationPhoneNumber(phoneNumber, authSettings);

      hilog.debug(AuthService.DOMAIN, AuthService.TAG, `Response: ${JSON.stringify(response)}`);

      // TDLib 成功返回 Ok 类型
      return {
        success: true,
        nextStep: 'code' as AuthState,
        codeType: 'sms'
      };
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(AuthService.DOMAIN, AuthService.TAG, `Set authentication phone number failed: ${error.message}`);
      return this.parseTdError(error);
    }
  }

  /**
   * 检查验证码
   */
  public async checkAuthenticationCode(code: string): Promise<CheckCodeResult> {
    await this.ensureClientInitialized();
    hilog.info(AuthService.DOMAIN, AuthService.TAG, `checkAuthenticationCode: *** (code length: ${code.length})`);

    try {
      if (!this.tdLibApi) {
        throw new Error('TDLibApi not initialized');
      }

      // ⭐ 新增：记录调用前的状态
      const beforeState = await this.tdLibApi.getAuthorizationState();
      hilog.debug(AuthService.DOMAIN, AuthService.TAG, `Before check: ${beforeState['@type']}`);

      // 调用 TDLib API 检查验证码
      await this.tdLibApi.checkAuthenticationCode(code);

      // 获取当前的授权状态以确定下一步
      const authState = await this.tdLibApi.getAuthorizationState();
      const authType = authState['@type'] as string;

      hilog.info(AuthService.DOMAIN, AuthService.TAG, `After check - Auth state: ${authType}`);

      // ⭐ 增强：根据不同状态返回详细信息
      if (authType === 'authorizationStateReady') {
        hilog.info(AuthService.DOMAIN, AuthService.TAG, '✅ Authentication completed successfully');
        return {
          success: true,
          nextStep: AuthState.COMPLETED
        };
      } else if (authType === 'authorizationStateWaitPassword') {
        const passwordHint = authState['password_hint'] as string | undefined;
        const hasRecoveryEmail = authState['has_recovery_email_address'] as boolean | undefined;
        hilog.info(AuthService.DOMAIN, AuthService.TAG, `⚠️ Two-factor authentication required (hint: ${passwordHint || 'none'}, has recovery: ${hasRecoveryEmail})`);
        return {
          success: true,
          nextStep: AuthState.PASSWORD_REQUIRED,
          passwordHint: passwordHint
        };
      } else if (authType === 'authorizationStateWaitRegistration') {
        const termsOfService = authState['terms_of_service'] as Record<string, Object> | undefined;
        hilog.info(AuthService.DOMAIN, AuthService.TAG, `📝 New user registration required${termsOfService ? ' (with ToS)' : ''}`);
        return {
          success: true,
          nextStep: AuthState.SIGNUP_REQUIRED,
          needSignUp: true
        };
      } else if (authType === 'authorizationStateWaitEmailAddress') {
        hilog.info(AuthService.DOMAIN, AuthService.TAG, '📧 Email address required');
        return {
          success: false,
          errorMessage: '需要邮箱地址验证',
          errorCode: 400
        };
      } else if (authType === 'authorizationStateWaitOtherDeviceConfirmation') {
        const link = authState['link'] as string | undefined;
        hilog.info(AuthService.DOMAIN, AuthService.TAG, `🔗 QR code confirmation required: ${link}`);
        return {
          success: false,
          errorMessage: '需要在其他设备上确认',
          errorCode: 400
        };
      } else {
        hilog.warn(AuthService.DOMAIN, AuthService.TAG, `❓ Unexpected auth state: ${authType}`);
        return {
          success: false,
          errorMessage: `Unexpected auth state: ${authType}`,
          errorCode: -1
        };
      }
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(AuthService.DOMAIN, AuthService.TAG, `Check authentication code failed: ${error.message} (code: ${error.code})`);
      return this.parseTdError(error);
    }
  }

  /**
   * 异步检查验证码（兼容旧代码）
   */
  public async checkCodeAsync(code: string): Promise<CheckCodeResult> {
    return this.checkAuthenticationCode(code);
  }

  /**
   * 检查两步验证密码
   */
  public async checkAuthenticationPassword(password: string): Promise<CheckPasswordResult> {
    await this.ensureClientInitialized();
    hilog.info(AuthService.DOMAIN, AuthService.TAG, 'checkAuthenticationPassword: ***');

    try {
      if (!this.tdLibApi) {
        throw new Error('TDLibApi not initialized');
      }

      await this.tdLibApi.checkAuthenticationPassword(password);

      hilog.debug(AuthService.DOMAIN, AuthService.TAG, 'Password verified successfully');

      // 获取用户信息
      const authState = await this.tdLibApi.getAuthorizationState();
      if (authState['@type'] === 'authorizationStateReady') {
        return {
          success: true,
          nextStep: AuthState.COMPLETED
        };
      } else {
        return this.parseTdError(new Error('Password verification failed'));
      }
    } catch (err) {
      const error = err as SystemBusinessError;
      hilog.error(AuthService.DOMAIN, AuthService.TAG, `Check authentication password failed: ${err.message}`);
      return this.parseTdError(err);
    }
  }

  /**
   * 注册新用户
   */
  public async registerUser(firstName: string, lastName: string): Promise<CheckPasswordResult> {
    await this.ensureClientInitialized();
    hilog.info(AuthService.DOMAIN, AuthService.TAG, `registerUser: ${firstName}`);

    try {
      if (!this.tdLibApi) {
        throw new Error('TDLibApi not initialized');
      }

      await this.tdLibApi.registerUser(firstName, lastName, false);

      hilog.debug(AuthService.DOMAIN, AuthService.TAG, 'User registered successfully');

      return {
        success: true,
        nextStep: AuthState.COMPLETED
      };
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(AuthService.DOMAIN, AuthService.TAG, `Register user failed: ${err.message}`);
      return this.parseTdError(err);
    }
  }

  /**
   * 获取授权状态
   */
  public async getAuthorizationState(): Promise<AuthorizationState> {
    await this.ensureClientInitialized();
    hilog.info(AuthService.DOMAIN, AuthService.TAG, 'getAuthorizationState');

    try {
      if (!this.tdLibApi) {
        throw new Error('TDLibApi not initialized');
      }

      const response: AuthorizationState = await this.tdLibApi.getAuthorizationState();
      return response;
    } catch (err) {
      const error = err as SystemBusinessError;
      hilog.error(AuthService.DOMAIN, AuthService.TAG, `Get authorization state failed: ${err.message}`);
      throw new Error(String(err));
    }
  }

  /**
   * 获取认证状态的简化版本（用于页面判断）
   * @returns AuthState 枚举值
   */
  public async getAuthState(): Promise<AuthState> {
    try {
      const authState = await this.getAuthorizationState();
      const authType = authState['@type'] as string;

      switch (authType) {
        case 'authorizationStateReady':
          return AuthState.COMPLETED;
        case 'authorizationStateWaitPassword':
          return AuthState.PASSWORD_REQUIRED;
        case 'authorizationStateWaitRegistration':
          return AuthState.SIGNUP_REQUIRED;
        case 'authorizationStateWaitCode':
          return AuthState.CODE_VERIFICATION;
        default:
          return AuthState.PHONE_INPUT;
      }
    } catch (error) {
      hilog.error(AuthService.DOMAIN, AuthService.TAG, `Get simplified auth state failed: ${error}`);
      return AuthState.PHONE_INPUT;
    }
  }

  /**
   * 退出登录
   */
  public async logout(): Promise<void> {
    await this.ensureClientInitialized();
    hilog.info(AuthService.DOMAIN, AuthService.TAG, 'logout');

    try {
      if (!this.tdLibApi) {
        throw new Error('TDLibApi not initialized');
      }

      await this.tdLibApi.logOut();

      // 清除认证状态缓存
      await this.clearAuthState();

      hilog.info(AuthService.DOMAIN, AuthService.TAG, 'Logout successful');
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(AuthService.DOMAIN, AuthService.TAG, `Logout failed: ${err.message}`);
      throw new Error(String(err));
    }
  }

  /**
   * 重新发送验证码
   */
  public async resendAuthenticationCode(): Promise<AuthResult> {
    await this.ensureClientInitialized();
    hilog.info(AuthService.DOMAIN, AuthService.TAG, 'resendAuthenticationCode');

    try {
      if (!this.tdLibApi) {
        throw new Error('TDLibApi not initialized');
      }
      
      // ⭐ 修复：TDLib resendAuthenticationCode 不需要任何参数
      await this.tdLibApi.resendAuthenticationCode();
      hilog.info(AuthService.DOMAIN, AuthService.TAG, 'Resend code successful');
      return {
        success: true
      };
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(AuthService.DOMAIN, AuthService.TAG, `Resend code failed: ${err.message}`);
      return this.parseTdError(err);
    }
  }

  /**
   * 检查用户名可用性
   *
   * 注意：TDLib 没有 checkChatUsername 在 AuthApi 中
   * 这个功能暂时返回 true，后续需要在 UserApi 中实现
   */
  public async checkUsernameAvailability(username: string): Promise<boolean> {
    await this.ensureClientInitialized();
    hilog.info(AuthService.DOMAIN, AuthService.TAG, `checkUsernameAvailability: ${username}`);

    try {
      // TODO: UserApi 中没有 checkChatUsername 方法，需要在其他地方实现
      // 暂时返回 true
      hilog.warn(AuthService.DOMAIN, AuthService.TAG, 'checkUsernameAvailability not implemented in UserApi');
      return true;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(AuthService.DOMAIN, AuthService.TAG, `Check username availability failed: ${err.message}`);
      throw new Error(String(err));
    }
  }

  /**
   * 检查认证状态
   * @returns 是否已完成认证
   */
  public async isAuthCompleted(): Promise<boolean> {
    try {
      // 首先检查缓存
      const cachedCompleted = await authCache.get<boolean>(AuthService.AUTH_COMPLETED_KEY);
      if (cachedCompleted) {
        hilog.info(AuthService.DOMAIN, AuthService.TAG, 'Auth state from cache: completed');
        return true;
      }

      // 检查 TDLib 认证状态
      const authState = await this.getAuthorizationState();
      const authType = authState['@type'] as string;

      const isCompleted = authType === 'authorizationStateReady';

      // 缓存状态
      if (isCompleted) {
        await authCache.set(AuthService.AUTH_COMPLETED_KEY, true);
      }

      hilog.info(AuthService.DOMAIN, AuthService.TAG, `Auth state: ${authType}, completed: ${isCompleted}`);
      return isCompleted;
    } catch (error) {
      const err = error as SystemBusinessError;
      hilog.error(AuthService.DOMAIN, AuthService.TAG, `Check auth state failed: ${err.message}`);
      return false;
    }
  }

  /**
   * 清除认证状态缓存
   */
  public async clearAuthState(): Promise<void> {
    try {
      await authCache.delete(AuthService.AUTH_COMPLETED_KEY);
      await authCache.delete(AuthService.AUTH_STATE_KEY);
      hilog.info(AuthService.DOMAIN, AuthService.TAG, 'Auth state cache cleared');
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(AuthService.DOMAIN, AuthService.TAG, `Clear auth state failed: ${err.message}`);
    }
  }

  /**
   * 销毁服务（释放资源）
   */
  public destroy(): void {
    this.tdClient = null;
    this.tdLibApi = null;
    this.isInitialized = false;
    AuthService.instance = undefined;
    hilog.info(AuthService.DOMAIN, AuthService.TAG, 'AuthService destroyed');
  }

  // ==================== Phone Service Methods ====================

  /**
   * 格式化手机号为国际标准格式 (E.164)
   */
  public formatInternational(phone: string, dialCode: string): string {
    const cleaned = phone.replace(/\D/g, '');
    let number = cleaned;
    const dialCodeDigits = dialCode.replace(/\D/g, '');
    if (cleaned.startsWith(dialCodeDigits)) {
      number = cleaned.substring(dialCodeDigits.length);
    }
    return `${dialCode}${number}`;
  }




  // ==================== Permission Manager Methods ====================

  private atManager: abilityAccessCtrl.AtManager | null = null;
  private accessTokenId: number = 0;

  /**
   * 初始化权限管理器
   */
  private async initPermissionManager(): Promise<void> {
    if (this.atManager) return;
    try {
      this.atManager = abilityAccessCtrl.createAtManager();
      const bundleInfo = await bundleManager.getBundleInfoForSelf(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
      );
      this.accessTokenId = bundleInfo.appInfo.accessTokenId;
    } catch (error) {
      hilog.error(AuthService.DOMAIN, AuthService.TAG, `Init permission manager failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 检查权限状态
   */
  public async checkPermission(permission: Permissions): Promise<PermissionStatus> {
    await this.initPermissionManager();
    if (!this.atManager || this.accessTokenId === 0) return PermissionStatus.DENIED;
    try {
      const grantStatus = await this.atManager.checkAccessToken(this.accessTokenId, permission);
      return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED ? PermissionStatus.GRANTED : PermissionStatus.DENIED;
    } catch (error) {
      return PermissionStatus.DENIED;
    }
  }

  /**
   * 请求权限
   */
  public async requestPermission(context: common.UIAbilityContext, permission: Permissions): Promise<boolean> {
    await this.initPermissionManager();
    if (!this.atManager) return false;
    try {
      const result = await this.atManager.requestPermissionsFromUser(context, [permission]);
      return result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    } catch (error) {
      return false;
    }
  }

  // ==================== Biometric Auth Methods ====================

  private isAuthenticating: boolean = false;
  private biometricPrefs: preferences.Preferences | null = null;

  /**
   * 初始化生物识别
   */
  public async initBiometricAuth(context: common.UIAbilityContext): Promise<void> {
    try {
      this.biometricPrefs = await preferences.getPreferences(context, 'biometric_auth');
      await this.sessionEncryption.initialize(context);
    } catch (error) {
      hilog.error(AuthService.DOMAIN, AuthService.TAG, `Init biometric auth failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 检查设备是否支持生物识别
   */
  public async isBiometricAvailable(): Promise<boolean> {
    return false; // API 兼容性占位
  }

  /**
   * 检查是否已启用生物识别认证
   */
  public async isBiometricEnabled(): Promise<boolean> {
    if (!this.biometricPrefs) return false;
    try {
      return await this.biometricPrefs.get('biometric_enabled', false) as boolean;
    } catch (error) {
      return false;
    }
  }

  /**
   * 设置生物识别认证启用状态
   */
  public async setBiometricEnabled(enabled: boolean, type?: BiometricType): Promise<void> {
    if (!this.biometricPrefs) throw new Error('BiometricAuthService not initialized');
    try {
      await this.biometricPrefs.put('biometric_enabled', enabled);
      if (type) {
        await this.biometricPrefs.put('biometric_type', type);
      }
      await this.biometricPrefs.flush();
    } catch (error) {
      throw new Error(String(error));
    }
  }

  /**
   * 获取已配置的生物识别类型
   */
  public async getBiometricType(): Promise<BiometricType | null> {
    if (!this.biometricPrefs) return null;
    try {
      const type = await this.biometricPrefs.get('biometric_type', '') as string;
      return type ? (type as BiometricType) : null;
    } catch (error) {
      return null;
    }
  }

  /**
   * 清除缓存的认证结果
   */
  public async clearAuthCache(): Promise<void> {
    if (!this.biometricPrefs) return;
    try {
      await this.biometricPrefs.delete('last_auth_time');
      await this.biometricPrefs.flush();
    } catch (error) {
      // Ignore error
    }
  }

  /**
   * 取消正在进行的认证
   */
  public cancelAuthentication(): void {
    this.isAuthenticating = false;
  }

  /**
   * 执行生物识别认证
   */
  public async authenticateBiometric(config?: BiometricAuthConfig): Promise<BiometricAuthResult> {
    if (this.isAuthenticating) {
      return { success: false, errorCode: -1, errorMessage: '认证正在进行中', timestamp: Date.now() };
    }
    this.isAuthenticating = true;
    try {
      // 检查缓存
      if (!config?.forceAuth && this.biometricPrefs) {
        const lastTime = await this.biometricPrefs.get('last_auth_time', 0) as number;
        const duration = config?.cacheDuration || 5 * 60 * 1000;
        if (Date.now() - lastTime < duration) {
          return { success: true, timestamp: lastTime };
        }
      }
      // 由于 API 兼容性，目前返回模拟结果
      return { success: false, errorCode: -4, errorMessage: '生物识别暂不可用', timestamp: Date.now() };
    } finally {
      this.isAuthenticating = false;
    }
  }

  // ==================== Token Manager Methods ====================

  private tokenPrefs: preferences.Preferences | null = null;
  private static readonly TOKEN_PREFIX = 'token_';
  private static readonly CURRENT_ACCESS_TOKEN_KEY = 'current_access_token';

  /**
   * 初始化令牌管理器
   */
  public async initTokenManager(context: common.UIAbilityContext): Promise<void> {
    try {
      this.tokenPrefs = await preferences.getPreferences(context, 'auth_token_manager');
    } catch (error) {
      hilog.error(AuthService.DOMAIN, AuthService.TAG, `Init token manager failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 生成新令牌
   */
  public async generateToken(config: TokenConfig): Promise<TokenInfo | null> {
    if (!this.tokenPrefs) return null;
    try {
      const expiresIn = config.expiresIn || this.getTokenExpiration(config.type, config.expiresIn);
      const now = Date.now();
      const random = cryptoFramework.createRandom();
      const randomBlob = await random.generateRandom(32);
      const base64Helper = new util.Base64Helper();
      const randomPart = base64Helper.encodeToStringSync(randomBlob.data);
      
      const tokenInfo: TokenInfo = {
        type: config.type,
        token: `${config.type.substring(0, 2).toUpperCase()}.${randomPart}.${config.userId?.toString(16) || '0'}.${now.toString(16)}`,
        userId: config.userId,
        deviceId: config.deviceId,
        expiresAt: now + expiresIn * 1000,
        createdAt: now,
        scopes: config.scopes || [],
        revoked: false,
      };

      await this.storeToken(tokenInfo);
      if (config.type === TokenType.ACCESS_TOKEN) {
        await this.tokenPrefs.put(AuthService.CURRENT_ACCESS_TOKEN_KEY, tokenInfo.token);
        await this.tokenPrefs.flush();
      }
      return tokenInfo;
    } catch (error) {
      hilog.error(AuthService.DOMAIN, AuthService.TAG, `Generate token failed: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 刷新访问令牌
   */
  public async refreshToken(refreshToken: string, maxRetries: number = 3): Promise<TokenInfo | null> {
    // 简化实现：验证并重新生成
    const result = await this.validateToken(refreshToken, TokenType.REFRESH_TOKEN);
    if (!result.isValid || !result.tokenInfo) return null;
    
    const oldInfo: TokenInfo = result.tokenInfo;
    await this.revokeToken(refreshToken);
    
    // 生成新的刷新令牌
    const newRefresh = await this.generateToken({
      type: TokenType.REFRESH_TOKEN,
      userId: oldInfo.userId,
      deviceId: oldInfo.deviceId,
      scopes: oldInfo.scopes
    });
    
    // 生成新的访问令牌
    return await this.generateToken({
      type: TokenType.ACCESS_TOKEN,
      userId: oldInfo.userId,
      deviceId: oldInfo.deviceId,
      scopes: oldInfo.scopes
    });
  }

  /**
   * 验证令牌
   */
  public async validateToken(token: string, type?: TokenType): Promise<TokenValidationResult> {
    try {
      const tokenHash = this.hashToken(token);
      const data = await this.tokenPrefs?.get(AuthService.TOKEN_PREFIX + tokenHash, '') as string;
      if (!data) return { isValid: false, errorMessage: 'Token not found' };
      
      const tokenInfo = JSON.parse(data) as TokenInfo;
      if (type && tokenInfo.type !== type) return { isValid: false, errorMessage: 'Token type mismatch' };
      if (tokenInfo.revoked) return { isValid: false, errorMessage: 'Token has been revoked' };
      if (Date.now() > tokenInfo.expiresAt) return { isValid: false, errorMessage: 'Token has expired' };
      
      return { isValid: true, tokenInfo };
    } catch (error) {
      return { isValid: false, errorMessage: 'Token validation failed' };
    }
  }

  /**
   * 清理过期令牌
   */
  public async cleanExpiredTokens(): Promise<number> {
    if (!this.tokenPrefs) return 0;
    try {
      const keys = await this.tokenPrefs.getAll();
      const now = Date.now();
      let cleanedCount = 0;
      const keyNames = Object.keys(keys);
      
      for (const key of keyNames) {
        if (key.startsWith(AuthService.TOKEN_PREFIX)) {
          const keyValue = (keys as Record<string, string>)[key];
          if (keyValue) {
            try {
              const info = JSON.parse(keyValue) as TokenInfo;
              if (info.expiresAt < now || info.revoked) {
                await this.tokenPrefs.delete(key);
                cleanedCount++;
              }
            } catch (e) {
              await this.tokenPrefs.delete(key);
              cleanedCount++;
            }
          }
        }
      }
      await this.tokenPrefs.flush();
      return cleanedCount;
    } catch (error) {
      return 0;
    }
  }

  /**
   * 撤销用户所有令牌
   */
  public async revokeAllUserTokens(userId: number): Promise<number> {
    if (!this.tokenPrefs) return 0;
    try {
      const keys = await this.tokenPrefs.getAll();
      let revokedCount = 0;
      const keyNames = Object.keys(keys);
      
      for (const key of keyNames) {
        if (key.startsWith(AuthService.TOKEN_PREFIX)) {
          const keyValue = (keys as Record<string, string>)[key];
          if (keyValue) {
            try {
              const info = JSON.parse(keyValue) as TokenInfo;
              if (info.userId === userId) {
                info.revoked = true;
                await this.tokenPrefs.put(key, JSON.stringify(info));
                revokedCount++;
              }
            } catch (e) { /* ignore */ }
          }
        }
      }
      await this.tokenPrefs.flush();
      await this.clearCurrentAccessToken();
      return revokedCount;
    } catch (error) {
      return 0;
    }
  }

  /**
   * 获取令牌统计信息
   */
  public async getTokenStats(): Promise<TokenStats> {
    if (!this.tokenPrefs) {
      return { totalTokens: 0, activeTokens: 0, expiredTokens: 0, revokedTokens: 0, byType: {} };
    }
    try {
      const keys = await this.tokenPrefs.getAll();
      const now = Date.now();
      const stats: TokenStats = { totalTokens: 0, activeTokens: 0, expiredTokens: 0, revokedTokens: 0, byType: {} };
      
      for (const key of Object.keys(keys)) {
        if (key.startsWith(AuthService.TOKEN_PREFIX)) {
          stats.totalTokens++;
          try {
            const info = JSON.parse((keys as Record<string, string>)[key]) as TokenInfo;
            if (info.revoked) stats.revokedTokens++;
            else if (info.expiresAt < now) stats.expiredTokens++;
            else stats.activeTokens++;
            stats.byType[info.type] = (stats.byType[info.type] || 0) + 1;
          } catch (e) { /* ignore */ }
        }
      }
      return stats;
    } catch (error) {
      return { totalTokens: 0, activeTokens: 0, expiredTokens: 0, revokedTokens: 0, byType: {} };
    }
  }

  private async clearCurrentAccessToken(): Promise<void> {
    if (!this.tokenPrefs) return;
    try {
      await this.tokenPrefs.delete(AuthService.CURRENT_ACCESS_TOKEN_KEY);
      await this.tokenPrefs.flush();
    } catch (error) { /* ignore */ }
  }

  private getTokenExpiration(type: TokenType, customExpiresIn?: number): number {
    if (customExpiresIn) return customExpiresIn;
    switch (type) {
      case TokenType.ACCESS_TOKEN: return 3600;
      case TokenType.REFRESH_TOKEN: return 30 * 24 * 3600;
      case TokenType.SESSION_TOKEN: return 24 * 3600;
      case TokenType.TEMPORARY_TOKEN: return 600;
      default: return 3600;
    }
  }

  /**
   * 获取当前访问令牌
   */
  public async getCurrentAccessToken(): Promise<string | null> {
    if (!this.tokenPrefs) return null;
    try {
      return await this.tokenPrefs.get(AuthService.CURRENT_ACCESS_TOKEN_KEY, '') as string || null;
    } catch (error) {
      return null;
    }
  }

  /**
   * 撤销令牌
   */
  public async revokeToken(token: string): Promise<boolean> {
    if (!this.tokenPrefs) return false;
    try {
      const tokenHash = this.hashToken(token);
      const key = AuthService.TOKEN_PREFIX + tokenHash;
      const data = await this.tokenPrefs.get(key, '') as string;
      if (data) {
        const info = JSON.parse(data) as TokenInfo;
        info.revoked = true;
        await this.tokenPrefs.put(key, JSON.stringify(info));
        await this.tokenPrefs.flush();
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }

  private hashToken(token: string): string {
    let hash = 0;
    for (let i = 0; i < token.length; i++) {
      const char = token.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return Math.abs(hash).toString(16);
  }

  private async storeToken(tokenInfo: TokenInfo): Promise<void> {
    if (!this.tokenPrefs) return;
    const tokenHash = this.hashToken(tokenInfo.token);
    await this.tokenPrefs.put(AuthService.TOKEN_PREFIX + tokenHash, JSON.stringify(tokenInfo));
    await this.tokenPrefs.flush();
  }

  // ==================== Code Verification Methods ====================

  private codeInfo: VerificationCodeInfo | null = null;
  private static readonly CODE_EXPIRE_TIME = 5 * 60 * 1000;
  private static readonly MAX_ATTEMPTS = 3;
  private static readonly RESEND_COOLDOWN = 60 * 1000;

  /**
   * 发送验证码
   */
  public async sendVerificationCode(phoneNumber: string, codeType: VerificationCodeType = VerificationCodeType.SMS): Promise<boolean> {
    try {
      const result = await this.setAuthenticationPhoneNumber(phoneNumber);
      if (result.success) {
        this.codeInfo = {
          phoneNumber,
          codeType,
          sendTime: Date.now(),
          expireTime: Date.now() + AuthService.CODE_EXPIRE_TIME,
          attempts: 0,
          status: VerificationCodeStatus.SENT
        };
        await authCache.set('verification_code', this.codeInfo, AuthService.CODE_EXPIRE_TIME);
        this.startResendTimer();
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }

  /**
   * 重新发送验证码
   */
  public async resendCode(): Promise<boolean> {
    if (!this.codeInfo) return false;
    const timeSinceLastSend = Date.now() - this.codeInfo.sendTime;
    if (timeSinceLastSend < AuthService.RESEND_COOLDOWN) return false;
    return await this.sendVerificationCode(this.codeInfo.phoneNumber, this.codeInfo.codeType);
  }

  /**
   * 获取验证码状态
   */
  public getCodeStatus(): VerificationCodeStatus {
    return this.codeInfo?.status || VerificationCodeStatus.IDLE;
  }

  /**
   * 获取剩余尝试次数
   */
  public getRemainingAttempts(): number {
    if (!this.codeInfo) return AuthService.MAX_ATTEMPTS;
    return AuthService.MAX_ATTEMPTS - this.codeInfo.attempts;
  }

  /**
   * 清除验证码信息
   */
  public clearCodeInfo(): void {
    this.codeInfo = null;
    this.clearResendTimer();
    try {
      authCache.delete('verification_code');
    } catch (error) { /* ignore */ }
  }

  private startResendTimer(): void {
    this.clearResendTimer();
    this.resendTimer = setInterval(() => {
      if (this.getResendCooldown() <= 0) this.clearResendTimer();
    }, 1000);
  }

  private clearResendTimer(): void {
    if (this.resendTimer !== -1) {
      clearInterval(this.resendTimer);
      this.resendTimer = -1;
    }
  }

  /**
   * 验证验证码
   */
  public async verifyCode(code: string): Promise<VerificationResult> {
    if (!this.codeInfo) {
      const cached = await authCache.get<VerificationCodeInfo>('verification_code');
      if (cached) this.codeInfo = cached;
    }
    if (!this.codeInfo) {
      return { success: false, status: VerificationCodeStatus.FAILED, errorMessage: '验证码已过期' };
    }
    if (Date.now() > this.codeInfo.expireTime) {
      this.codeInfo.status = VerificationCodeStatus.EXPIRED;
      return { success: false, status: VerificationCodeStatus.EXPIRED, errorMessage: '验证码已过期' };
    }
    if (this.codeInfo.attempts >= AuthService.MAX_ATTEMPTS) {
      return { success: false, status: VerificationCodeStatus.FAILED, errorMessage: '尝试次数过多' };
    }
    this.codeInfo.attempts++;
    this.codeInfo.status = VerificationCodeStatus.VERIFYING;
    
    const result = await this.checkAuthenticationCode(code);
    if (result.success) {
      this.codeInfo.status = VerificationCodeStatus.VERIFIED;
      return { success: true, status: VerificationCodeStatus.VERIFIED, nextStep: result.nextStep };
    } else {
      this.codeInfo.status = VerificationCodeStatus.FAILED;
      await authCache.set('verification_code', this.codeInfo);
      return { success: false, status: VerificationCodeStatus.FAILED, errorMessage: result.errorMessage };
    }
  }

  /**
   * 获取重发倒计时
   */
  public getResendCooldown(): number {
    if (!this.codeInfo) return 0;
    const remaining = AuthService.RESEND_COOLDOWN - (Date.now() - this.codeInfo.sendTime);
    return Math.max(0, Math.ceil(remaining / 1000));
  }

  /**
   * 解析 TDLib 错误
   */
  private parseTdError(error: Error | BusinessError): AuthResult {
    let message = '未知错误';
    let code = AuthErrorCode.SERVER_ERROR;

    if (error && error.message) {
      message = error.message;
    }
    
    let errorCodeNum = 0;
    // 使用显式类型检查代替 typeof
    if (error !== null && error !== undefined) {
      // 检查是否是BusinessError类型
      const businessError = error as BusinessError;
      if (businessError.code !== undefined && typeof businessError.code === 'number') {
        errorCodeNum = businessError.code;
      }
    }
    code = this.mapTdErrorCode(errorCodeNum);

    return {
      success: false,
      errorMessage: message,
      errorCode: code
    };
  }

  /**
   * 映射TDLib错误代码
   */
  private mapTdErrorCode(tdCode: number): AuthErrorCode {
    if (tdCode === 400) {
      return AuthErrorCode.INVALID_PHONE;
    } else if (tdCode === 401) {
      return AuthErrorCode.INVALID_CODE;
    } else if (tdCode === 500) {
      return AuthErrorCode.SERVER_ERROR;
    }
    return AuthErrorCode.SERVER_ERROR;
  }
}

// ⚠️ 注意：不要在模块级别创建实例，避免 TDLibClient 未初始化问题
// 请使用 AuthService.getInstance() 按需获取实例
