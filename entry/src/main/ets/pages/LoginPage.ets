/**
 * LoginPage - 登录页面
 * 整合手机号、验证码、密码登录流程，参考 Telegram LoginActivity
 */

import { router, promptAction, window } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { AuthService, TDLibClient } from '../services/core';
import { TdApiFactory, TDLibApi } from '../services/api';
import { AuthState } from '../models';
import { PhoneInputComponent } from '../ui_kit/components/PhoneInputComponent';
import { CountryInfo, CountryCodeHelper } from '../utils/CountryCodeHelper';
import { getAuthErrorDisplayMessage, AUTH_ERROR_SILENT, getAuthErrorLocaleKey } from '../utils/AuthErrorHelper';
import { getString, formatString } from '../utils/i18n/ResourceHelper';
import { logPageInfo, logPageError, logPageWarn } from '../utils/log/LogService';
import { RoutePaths } from '../utils/navigation/NavigationHelper';

import { LottieController, LottieView } from '@ohos/lottie-turbo';

// ============ 硬编码样式常量（Auth 模块不使用主题系统） ============
// 颜色
const COLOR_TEXT_PRIMARY = '#000000';
const COLOR_TEXT_SECONDARY = '#6B7280';
const COLOR_TEXT_TERTIARY = '#9CA3AF';
const COLOR_BACKGROUND = '#FFFFFF';
const COLOR_SURFACE = '#F5F5F5';
const COLOR_DIVIDER = '#E5E7EB';
const COLOR_TELEGRAM_BLUE = '#0088CC';
const COLOR_TELEGRAM_LIGHT_BLUE = '#71AFE5';
const COLOR_QR_COLOR = '#000000';

// 间距
const SPACING_XS = 4;
const SPACING_SM = 8;
const SPACING_MD = 12;
const SPACING_LG = 16;
const SPACING_XL = 24;
const SPACING_XXL = 32;

// 圆角
const RADIUS_SM = 4;
const RADIUS_MD = 8;
const RADIUS_LG = 12;
const RADIUS_XL = 20;

// 字体大小
const FONT_SIZE_H3 = 20;
const FONT_SIZE_TITLE = 18;
const FONT_SIZE_BODY1 = 16;
const FONT_SIZE_BODY2 = 14;
const FONT_SIZE_BODY3 = 12;

const TELEGRAM_TOS_URL = 'https://telegram.org/tos';
const TELEGRAM_PRIVACY_URL = 'https://telegram.org/privacy';
const TAG = 'LoginPage';

/** 登录视图类型 */
enum LoginView {
  VIEW_PHONE_INPUT = 0,
  VIEW_CODE_INPUT = 1,
  VIEW_PASSWORD_INPUT = 2,
  VIEW_REGISTER = 3
}

/** 验证码信息缓存接口 */
interface CodeInfoCache {
  type: string;           // 当前验证码类型
  nextType: string;       // 下一个验证码类型（参考 Nagram nextType）
  length: number;
  timeout: number;        // 原始超时秒数
  remainingMs: number;    // 剩余时间（毫秒级，参考 Nagram）
  startTime: number;      // 开始时间戳（毫秒）
}

const CODE_INFO_CACHE_KEY = 'login_code_info_cache';

@Entry({ routeName: 'LoginPage' })
@ComponentV2
export struct LoginPage {
  // ⭐ 安全区高度（手动订阅 AppStorage）
  @Local topSafeHeight: number = 0;
  @Local bottomSafeHeight: number = 0;
  
  // 当前视图
  @Local currentView: LoginView = LoginView.VIEW_PHONE_INPUT;
  
  // 手机号输入状态
  @Local phoneNumber: string = '';
  @Local countryCode: string = '';
  @Local isPhoneValid: boolean = false;
  @Local isPhoneLoading: boolean = false;
  @Local currentCountry: CountryInfo | null = null;
  
  // 手机号确认状态（参考 Telegram confirmedNumber）
  @Local confirmedPhoneNumber: string = '';
  @Local showPhoneConfirmDialog: boolean = false;
  
  // 验证码输入状态
  @Local code: string = '';
  @Local countdown: number = 0;  // 剩余秒数（用于UI显示）
  @Local isCodeLoading: boolean = false;
  @Local codeInfoType: string = '';  // 当前验证码类型
  @Local nextCodeType: string = '';  // 下一个验证码类型（参考 Nagram nextType）
  @Local codeLength: number = 0;
  private tdlibTimeoutSeconds: number = 0;
  private timeRemainingMs: number = 0;  // 剩余时间（毫秒级，参考 Nagram）
  private lastCurrentTime: number = 0;  // 上次计时时间戳（参考 Nagram）
  
  // 密码输入状态
  @Local password: string = '';
  @Local showPassword: boolean = false;
  @Local passwordHint: string = '您的账户启用了两步验证';
  @Local showRecoveryInput: boolean = false;
  @Local recoveryCode: string = '';
  @Local isPasswordLoading: boolean = false;
  
  // 通用状态
  @Local errorMessage: string = '';
  @Local pageOpacity: number = 0;
  
  // 导航控制
  private hasNavigated: boolean = false;
  private currentPhoneNumber: string = '';
  private lastSentPhoneNumber: string = '';
  
  // Lottie 动画
  private phoneLottieController: LottieController = new LottieController();
  private codeLottieController: LottieController = new LottieController();
  private passwordLottieController: LottieController = new LottieController();
  
  // 定时器
  private countdownTimer: number = 0;
  
  // 服务实例
  private authService = AuthService.getInstance();
  private tdlibClient = TDLibClient.getInstance();
  private tdLibApi: TDLibApi | null = null;
  
  // ============ 二维码登录弹窗状态 ============
  @Local showQrCodeDialog: boolean = false;
  @Local qrCodeUrl: string = '';
  @Local isQrCodeLoading: boolean = true;
  @Local qrCodeError: string = '';
  @Local isQrRefreshing: boolean = false;
  private qrCodeRefreshTimer: number = 0;
  private savedQrCodeLink: string = '';
  // ========================================

  private getContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext;
  }

  private openUrl(url: string): void {
    this.getContext().startAbility({
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: url
    }).catch((err: Error) => {
      logPageError(TAG, `openUrl failed: ${err}`);
    });
  }

  async aboutToAppear(): Promise<void> {
    logPageInfo(TAG, 'aboutToAppear');
    this.hasNavigated = false;
    
    // ⭐ 动态获取安全区高度
    this.loadSafeAreaHeight();
    
    // 淡入动画
    setTimeout(() => {
      this.pageOpacity = 1;
    }, 100);
    
    // 初始化 TDLibApi
    const factory = TdApiFactory.getInstance();
    this.tdLibApi = factory.createDefault();
    
    // 设置监听器
    this.setupAuthStateListener();
    this.setupNeedCodeListener();
    this.setupNeedPasswordListener();
    this.setupTdlibErrorListener();
    
    // 检查是否已经处于等待验证码状态
    await this.checkAlreadyWaitingState();
  }

  /**
   * 动态获取安全区高度（状态栏 + 导航条），替代已删除的 EntryAbility 分发
   */
  private loadSafeAreaHeight(): void {
    try {
      const win = window.getLastWindow(getContext(this));
      win.then((windowClass: window.Window) => {
        const systemArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        if (systemArea && systemArea.topRect) {
          this.topSafeHeight = px2vp(systemArea.topRect.height);
        }
        const navArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        if (navArea && navArea.bottomRect) {
          this.bottomSafeHeight = px2vp(navArea.bottomRect.height);
        }
      }).catch(() => {
        this.topSafeHeight = 24;
        this.bottomSafeHeight = 0;
      });
    } catch (e) {
      this.topSafeHeight = 24;
      this.bottomSafeHeight = 0;
    }
  }

  aboutToDisappear(): void {
    logPageInfo(TAG, 'aboutToDisappear');
    this.hasNavigated = true;
    
    // 清理定时器
    if (this.countdownTimer) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = 0;
    }
    
    // 清理二维码定时器
    if (this.qrCodeRefreshTimer) {
      clearTimeout(this.qrCodeRefreshTimer);
      this.qrCodeRefreshTimer = 0;
    }
    
    // 清理监听器
    emitter.off('tdlib_auth_state');
    emitter.off('tdlib_need_code');
    emitter.off('tdlib_need_password');
    emitter.off('tdlib_error');
    
    // 销毁动画控制器
    this.phoneLottieController.destroy();
    this.codeLottieController.destroy();
    this.passwordLottieController.destroy();
  }

  /** 检查是否已经处于等待验证码状态 */
  private async checkAlreadyWaitingState(): Promise<void> {
    if (this.hasNavigated) {
      return;
    }
    try {
      const authState = await this.authService.getAuthorizationState();
      const stateType = authState['@type'] as string;
      
      if (stateType === 'authorizationStateWaitCode') {
        logPageInfo(TAG, 'Already waiting for code, switch to code view');
        
        // 从 TDLib 状态中获取 code_info
        if (authState['code_info'] && typeof authState['code_info'] === 'object') {
          const codeInfo = authState['code_info'] as Record<string, Object>;
          
          // 获取手机号
          const phoneNumber = codeInfo['phone_number'];
          if (typeof phoneNumber === 'string' && phoneNumber.length > 0) {
            this.currentPhoneNumber = phoneNumber;
            this.lastSentPhoneNumber = phoneNumber;
            logPageInfo(TAG, `Restored phone number: ${phoneNumber}`);
          }
          
          // 获取超时时间
          const timeoutVal = codeInfo['timeout'];
          if (typeof timeoutVal === 'number' && timeoutVal > 0) {
            this.tdlibTimeoutSeconds = timeoutVal;
            this.countdown = timeoutVal;
          }
          
          // 获取验证码类型（TDLib 返回的是对象，需要获取其 @type 字段和 length 字段）
          const typeObj = codeInfo['type'];
          if (typeObj && typeof typeObj === 'object') {
            const typeRecord = typeObj as Record<string, Object>;
            const typeVal = typeRecord['@type'] as string;
            if (typeof typeVal === 'string') {
              this.codeInfoType = typeVal;
            }
            // 验证码长度在 type 对象中
            const lengthVal = typeRecord['length'];
            if (typeof lengthVal === 'number' && lengthVal >= 4 && lengthVal <= 8) {
              this.codeLength = lengthVal;
              logPageInfo(TAG, `Restored code length from type: ${lengthVal}`);
            }
          }
          
          // 获取下一个验证码类型
          const nextTypeObj = codeInfo['next_type'];
          if (nextTypeObj && typeof nextTypeObj === 'object') {
            const nextTypeRecord = nextTypeObj as Record<string, Object>;
            const nextTypeVal = nextTypeRecord['@type'] as string;
            if (typeof nextTypeVal === 'string') {
              this.nextCodeType = nextTypeVal;
            }
          }
        }
        
        // 如果验证码长度仍未设置，使用默认值
        if (this.codeLength === 0) {
          this.codeLength = 5;
        }
        
        this.currentView = LoginView.VIEW_CODE_INPUT;
        // 恢复状态时传入 isRestore: true，保留已恢复的倒计时值
        this.startCountdown(true);
      } else if (stateType === 'authorizationStateWaitPassword') {
        logPageInfo(TAG, 'Already waiting for password, switch to password view');
        await this.loadPasswordHint();
        this.currentView = LoginView.VIEW_PASSWORD_INPUT;
      }
    } catch (error) {
      logPageError(TAG, `Check waiting state failed: ${error}`);
    }
  }

  /** 设置授权状态监听器 */
  private setupAuthStateListener(): void {
    emitter.off('tdlib_auth_state');
    emitter.on('tdlib_auth_state', (payload: Record<string, Object>) => {
      if (this.hasNavigated) {
        return;
      }
      const data = payload['data'] as Record<string, Object> | undefined;
      const state = data ? (data['state'] as string) : '';
      
      if (state === 'authorizationStateWaitPassword') {
        logPageInfo(TAG, 'Received authorizationStateWaitPassword state');
        // 关闭二维码弹窗
        this.showQrCodeDialog = false;
        this.isCodeLoading = false;
        this.loadPasswordHint().then(() => {
          this.currentView = LoginView.VIEW_PASSWORD_INPUT;
        });
      } else if (state === 'authorizationStateReady') {
        logPageInfo(TAG, 'Received authorizationStateReady state, navigate to Main');
        // 关闭二维码弹窗
        this.showQrCodeDialog = false;
        this.navigateToMain();
      } else if (state === 'authorizationStateWaitOtherDeviceConfirmation') {
        // 二维码登录状态 - 更新弹窗中的二维码
        logPageInfo(TAG, 'Received QR code state, update dialog');
        const authState = data ? (data['authState'] as Record<string, Object>) : null;
        if (authState) {
          const linkValue = authState['link'] as string;
          if (linkValue && linkValue.length > 0) {
            this.savedQrCodeLink = linkValue;
            this.qrCodeUrl = linkValue;
            this.isQrCodeLoading = false;
            this.qrCodeError = '';
            this.scheduleQrCodeRefresh();
          }
        }
      }
    });
  }

  private setupNeedCodeListener(): void {
    emitter.off('tdlib_need_code');
    emitter.on('tdlib_need_code', (data: Record<string, Object>) => {
      if (this.hasNavigated) {
        return;
      }
      const payload = data['data'] as Record<string, Object> | undefined;
      if (payload !== undefined && payload !== null) {
        const typeVal = payload['code_info_type'];
        if (typeof typeVal === 'string') {
          this.codeInfoType = typeVal;
        }
        // 获取下一个验证码类型（参考 Nagram nextType）
        const nextTypeVal = payload['next_type'];
        if (typeof nextTypeVal === 'string') {
          this.nextCodeType = nextTypeVal;
        }
        const lenVal = payload['code_length'];
        if (typeof lenVal === 'number') {
          this.codeLength = (lenVal >= 4 && lenVal <= 8) ? lenVal : 0;
        }
        const timeoutVal = payload['timeout_seconds'];
        if (typeof timeoutVal === 'number' && timeoutVal > 0) {
          this.countdown = timeoutVal;
          this.tdlibTimeoutSeconds = timeoutVal;
        } else {
          this.countdown = 60;
          this.tdlibTimeoutSeconds = 60;
        }
        
        // 保存验证码信息到缓存（参考 Telegram 的状态保存机制）
        this.saveCodeInfoToCache({
          type: this.codeInfoType,
          nextType: this.nextCodeType,
          length: this.codeLength,
          timeout: this.countdown,
          remainingMs: this.timeRemainingMs,
          startTime: Date.now()
        });
      }
      this.isPhoneLoading = false;
      this.currentView = LoginView.VIEW_CODE_INPUT;
      this.startCountdown();
    });
  }

  /**
   * 保存验证码信息到缓存
   * 参考 Telegram: LoginActivitySmsView.saveStateParams
   */
  private saveCodeInfoToCache(info: CodeInfoCache): void {
    try {
      const cacheStr = JSON.stringify(info);
      AppStorage.set(CODE_INFO_CACHE_KEY, cacheStr);
    } catch (e) {
      logPageError(TAG, `Failed to save code info cache: ${e}`);
    }
  }

  /**
   * 从缓存读取验证码信息
   * 参考 Telegram: LoginActivitySmsView.restoreStateParams
   */
  private loadCodeInfoFromCache(): CodeInfoCache | null {
    try {
      const cacheStr = AppStorage.get(CODE_INFO_CACHE_KEY) as string | undefined;
      if (cacheStr) {
        return JSON.parse(cacheStr) as CodeInfoCache;
      }
    } catch (e) {
      logPageError(TAG, `Failed to load code info cache: ${e}`);
    }
    return null;
  }

  /**
   * 清除验证码缓存
   */
  private clearCodeInfoCache(): void {
    AppStorage.delete(CODE_INFO_CACHE_KEY);
  }

  private setupNeedPasswordListener(): void {
    emitter.off('tdlib_need_password');
    emitter.on('tdlib_need_password', (_data: Record<string, Object>) => {
      if (this.hasNavigated) {
        return;
      }
      logPageInfo(TAG, 'Received need_password event');
      this.isCodeLoading = false;
      this.loadPasswordHint().then(() => {
        this.currentView = LoginView.VIEW_PASSWORD_INPUT;
      });
    });
  }

  private setupTdlibErrorListener(): void {
    emitter.off('tdlib_error');
    emitter.on('tdlib_error', (payload: Record<string, Object>) => {
      const data = payload['data'] as Record<string, Object> | undefined;
      if (!data || typeof data !== 'object') {
        return;
      }
      const code = data['code'] as number | undefined;
      const msg = data['message'];
      const msgStr = typeof msg === 'string' ? msg : '';
      
      const key = getAuthErrorLocaleKey(code, msgStr);
      if (key === AUTH_ERROR_SILENT) {
        return;
      }
      
      const displayMsg = getAuthErrorDisplayMessage(code, msgStr);
      if (displayMsg.length > 0) {
        promptAction.showToast({ message: displayMsg, duration: 3000 });
      }
      
      // 关闭加载状态
      this.isPhoneLoading = false;
      this.isCodeLoading = false;
      this.isPasswordLoading = false;
    });
  }

  private async loadPasswordHint(): Promise<void> {
    if (!this.tdLibApi) return;
    try {
      const passwordState = await this.tdLibApi.getPasswordState();
      if (passwordState && passwordState['hint']) {
        const hint = passwordState['hint'] as string;
        if (hint && hint.length > 0) {
          this.passwordHint = hint;
        }
      }
    } catch (error) {
      logPageError(TAG, `loadPasswordHint error: ${JSON.stringify(error)}`);
    }
  }

  private navigateToMain(): void {
    if (this.hasNavigated) return;
    this.hasNavigated = true;
    // 登录成功，清除验证码缓存
    this.clearCodeInfoCache();
    router.replaceUrl({ url: RoutePaths.MAIN }).catch(() => {});
  }

  // ============ 手机号输入相关 ============
  
  private buildFullPhoneNumber(): string {
    let code = this.countryCode.replace(/\s/g, '');
    if (code.length > 0 && code.charAt(0) !== '+') {
      code = '+' + code;
    }
    return code + this.phoneNumber.trim();
  }

  private isFullNumberValid(fullNumber: string): boolean {
    return /^\+\d{7,15}$/.test(fullNumber);
  }

  private updatePhoneValid(): void {
    this.isPhoneValid = this.isFullNumberValid(this.buildFullPhoneNumber());
  }

  private onPhoneChange(phone: string): void {
    this.phoneNumber = phone;
    // 修改手机号时重置确认状态，下次需要重新确认
    this.confirmedPhoneNumber = '';
    this.updatePhoneValid();
  }

  private onCountryCodeChange(code: string): void {
    // 更新 countryCode
    this.countryCode = code;
    // 修改区号时重置确认状态，下次需要重新确认
    this.confirmedPhoneNumber = '';
    
    // 区号为空时重置国家选择
    if (code === '' || code === '+') {
      this.currentCountry = null;
    } else {
      // 区号有效时尝试匹配国家
      const pureCode = code.replace('+', '');
      const countries: Array<CountryInfo> = CountryCodeHelper.findCountriesByCode(pureCode);
      if (countries.length > 0) {
        this.currentCountry = countries[0];
      } else {
        this.currentCountry = null;
      }
    }
    this.updatePhoneValid();
  }

  private onCountryMatched(country: CountryInfo): void {
    this.currentCountry = country;
    logPageInfo(TAG, `Country matched: ${country.name} (+${country.code})`);
  }

  /**
   * 检查手机号位数是否与预期格式匹配
   */
  private isPhoneLengthMatchesPattern(): boolean {
    if (!this.currentCountry || !this.currentCountry.pattern) {
      return true;
    }
    // 计算 pattern 中的数字位数（去除空格和X）
    let patternDigits = 0;
    for (let i = 0; i < this.currentCountry.pattern.length; i++) {
      const ch = this.currentCountry.pattern.charAt(i);
      if (ch === 'X') {
        patternDigits++;
      }
    }
    // 直接使用纯数字的 phoneNumber 长度
    const phoneDigits = this.phoneNumber.length;
    // 允许 ±2 位的偏差
    return Math.abs(phoneDigits - patternDigits) <= 2;
  }

  private async handlePhoneNext(): Promise<void> {
    if (this.isPhoneLoading) {
      return;
    }

    const fullNumber = this.buildFullPhoneNumber();
    
    // 检查基本格式
    if (!this.isFullNumberValid(fullNumber)) {
      this.errorMessage = '手机号格式不正确';
      this.showErrorDialog();
      return;
    }

    // 参考 Telegram：检查是否需要弹出确认对话框
    // 1. 手机号与上次确认的不同
    // 2. 或者手机号位数与预期格式不匹配
    const needConfirm = fullNumber !== this.confirmedPhoneNumber || this.isPhoneLengthMismatch();
    
    if (needConfirm) {
      // 弹出确认对话框
      await this.showPhoneNumberConfirmDialog(fullNumber);
      return;
    }

    // 已确认，发送验证码并等待响应
    this.sendPhoneNumber(fullNumber);
  }

  /**
   * 检查手机号位数是否与预期格式不匹配
   */
  private isPhoneLengthMismatch(): boolean {
    if (!this.currentCountry || !this.currentCountry.pattern) {
      return false;
    }
    let patternDigits = 0;
    for (let i = 0; i < this.currentCountry.pattern.length; i++) {
      if (this.currentCountry.pattern.charAt(i) === 'X') {
        patternDigits++;
      }
    }
    const phoneDigits = this.phoneNumber.length;
    return Math.abs(phoneDigits - patternDigits) > 2;
  }

  /**
   * 确认手机号并继续（参考 Telegram onConfirm）
   */
  private onPhoneConfirm(): void {
    this.showPhoneConfirmDialog = false;
    const fullNumber = this.buildFullPhoneNumber();
    this.confirmedPhoneNumber = fullNumber;
    // 确认后发送验证码，等待响应
    this.sendPhoneNumber(fullNumber);
  }

  /**
   * 取消手机号确认，返回编辑
   */
  private onPhoneEdit(): void {
    this.showPhoneConfirmDialog = false;
  }

  /**
   * 发送手机号（参考 Telegram sendRequest 回调后才跳转）
   */
  private async sendPhoneNumber(fullNumber: string): Promise<void> {
    // 参考 Telegram：确认后不显示发送中状态，直接等待响应
    try {
      const result = await this.authService.setAuthenticationPhoneNumber(fullNumber);
      
      if (!result.success) {
        // 发送失败，使用 AuthErrorHelper 获取友好的错误信息
        // 参考 Telegram 错误处理逻辑
        const errorMsg = result.errorMessage ?? '';
        const errorCode = result.errorCode ?? 0;
        
        // 检查是否是静默错误（如需密码等非失败场景）
        const localeKey = getAuthErrorLocaleKey(errorCode, errorMsg);
        if (localeKey === AUTH_ERROR_SILENT) {
          return;
        }
        
        // 使用 AuthErrorHelper 获取可显示的错误信息
        const displayMsg = getAuthErrorDisplayMessage(errorCode, errorMsg);
        
        if (displayMsg && displayMsg.length > 0) {
          this.errorMessage = displayMsg;
        } else if (errorMsg && errorMsg.length > 0) {
          // 如果没有对应的友好文案，显示原始错误信息
          this.errorMessage = errorMsg;
        } else {
          this.errorMessage = '发送验证码失败，请稍后重试';
        }
        this.showErrorDialog();
        return;
      }
      
      // 发送成功，跳转到验证码页面
      this.currentPhoneNumber = fullNumber;
      this.lastSentPhoneNumber = fullNumber;
      this.currentView = LoginView.VIEW_CODE_INPUT;
      this.startCountdown();
    } catch (error) {
      logPageError(TAG, `sendPhoneNumber error: ${error}`);
      this.errorMessage = '网络异常，请检查后重试';
      this.showErrorDialog();
    }
  }

  /**
   * 显示手机号确认对话框（参考 Telegram PhoneNumberConfirmView）
   */
  private async showPhoneNumberConfirmDialog(fullNumber: string): Promise<void> {
    return new Promise((resolve) => {
      promptAction.showDialog({
        title: '确认手机号',
        message: `此手机号码正确吗？\n\n${fullNumber}`,
        buttons: [
          { text: '编辑', color: '#6B7280' },
          { text: '确定', color: '#0088CC' }
        ]
      }).then((result) => {
        if (result.index === 1) {
          // 用户确认，调用 onPhoneConfirm
          this.onPhoneConfirm();
        }
        resolve();
      }).catch(() => {
        resolve();
      });
    });
  }

  /**
   * 显示验证码页返回确认对话框（参考 Telegram LoginActivitySmsView.onBackPressed）
   */
  private showCodeInputBackConfirmDialog(): void {
    const phone = this.formatPhoneNumber(this.currentPhoneNumber);
    const line1 = getString('auth_edit_number_info_line1');
    const line2 = formatString('auth_edit_number_info_line2', phone);
    const line3 = getString('auth_edit_number_info_line3');
    const message = line1 + '\n\n' + line2 + '\n\n' + line3;

    promptAction.showDialog({
      title: getString('auth_edit_number'),
      message: message,
      buttons: [
        { text: getString('auth_edit_number'), color: COLOR_TELEGRAM_BLUE },
        { text: getString('cancel'), color: COLOR_TEXT_SECONDARY }
      ]
    }).then((result) => {
      if (result.index === 0) {
        // 用户选择编辑，返回手机号输入页
        this.currentView = LoginView.VIEW_PHONE_INPUT;
      }
      // 取消则保持在验证码页
    }).catch(() => {
      // 用户关闭对话框，保持在验证码页
    });
  }

  // ============ 验证码输入相关 ============
  
  private isCodeLengthValid(): boolean {
    if (this.code.length < 4 || this.code.length > 8) {
      return false;
    }
    if (this.codeLength >= 4 && this.codeLength <= 8) {
      return this.code.length === this.codeLength;
    }
    return true;
  }

  private startCountdown(isRestore: boolean = false): void {
    // 清除现有定时器（参考 Nagram destroyTimer）
    if (this.countdownTimer) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = 0;
    }
    
    // 如果是恢复状态且已有有效的剩余时间，则保留原有值
    if (!isRestore || this.timeRemainingMs <= 0) {
      // 初始化毫秒级计时器（参考 Nagram createTimer）
      const baseTimeout = this.tdlibTimeoutSeconds > 0 ? this.tdlibTimeoutSeconds : 60;
      this.timeRemainingMs = baseTimeout * 1000;
    }
    
    // 记录开始计时的时间戳（参考 Nagram lastCurrentTime）
    this.lastCurrentTime = Date.now();
    
    // 设置定时器，每100ms更新一次（参考 Nagram 的高精度计时）
    this.countdownTimer = setInterval(() => {
      const currentTime = Date.now();
      const diff = currentTime - this.lastCurrentTime;
      this.lastCurrentTime = currentTime;
      
      // 使用精确的时间差递减（参考 Nagram time -= diff）
      this.timeRemainingMs -= diff;
      
      if (this.timeRemainingMs >= 1000) {
        // 更新显示的秒数
        this.countdown = Math.ceil(this.timeRemainingMs / 1000);
      } else {
        // 倒计时结束（参考 Nagram 的处理）
        this.countdown = 0;
        if (this.countdownTimer) {
          clearInterval(this.countdownTimer);
          this.countdownTimer = 0;
        }
      }
    }, 100);  // 100ms 精度，参考 Nagram 的实现
  }

  private async submitCode(): Promise<void> {
    if (!this.isCodeLengthValid()) {
      this.errorMessage = (this.codeLength >= 4 && this.codeLength <= 8)
        ? `请输入 ${this.codeLength} 位验证码`
        : '请输入 4-8 位验证码';
      this.showErrorDialog();
      return;
    }

    // 检查当前状态
    if (this.tdLibApi) {
      try {
        const currentState = await this.tdLibApi.getAuthorizationState();
        const currentType = currentState['@type'] as string;
        
        if (currentType === 'authorizationStateWaitPassword') {
          this.loadPasswordHint().then(() => {
            this.currentView = LoginView.VIEW_PASSWORD_INPUT;
          });
          return;
        }
      } catch (err) {
        logPageError(TAG, `Failed to get auth state: ${JSON.stringify(err)}`);
      }
    }

    this.isCodeLoading = true;

    try {
      const result = await this.authService.checkCodeAsync(this.code);
      
      if (result.success) {
        // 等待状态更新
      } else {
        const displayMsg = getAuthErrorDisplayMessage(result.errorCode, result.errorMessage);
        this.errorMessage = displayMsg.length > 0 ? displayMsg : '操作失败，请重试';
        this.showErrorDialog();
        this.isCodeLoading = false;
        
        if (result.errorMessage && result.errorMessage.includes('unexpected')) {
          if (this.tdLibApi) {
            try {
              const currentState = await this.tdLibApi.getAuthorizationState();
              const currentType = currentState['@type'] as string;
              
              if (currentType === 'authorizationStateWaitPassword') {
                this.loadPasswordHint().then(() => {
                  this.currentView = LoginView.VIEW_PASSWORD_INPUT;
                });
              }
            } catch (err) {
              logPageError(TAG, `Failed to check state: ${JSON.stringify(err)}`);
            }
          }
        }
      }
    } catch (error) {
      logPageError(TAG, `submitCode error: ${JSON.stringify(error)}`);
      this.errorMessage = '操作失败，请重试';
      this.showErrorDialog();
      this.isCodeLoading = false;
    }
  }

  private async resendCode(): Promise<void> {
    const result = await this.authService.resendAuthenticationCode();
    
    if (result.success) {
      promptAction.showToast({ message: '验证码已重新发送', duration: 2000 });
      this.startCountdown();
    } else {
      const errorMsg = result.errorMessage || '';
      let displayMsg = '';
      
      if (errorMsg.includes("can't be resend") || errorMsg.includes('cannot be resent')) {
        const remainingTime = Math.max(0, this.countdown);
        if (remainingTime > 5) {
          displayMsg = `请等待约 ${Math.ceil(remainingTime)} 秒后再试`;
        } else {
          displayMsg = '请稍后再试，验证码尚未到重发时间';
        }
      } else if (errorMsg.includes('unexpected')) {
        displayMsg = '验证码尚未下发，请稍候或检查网络后重试';
      } else {
        const fromHelper = getAuthErrorDisplayMessage(undefined, errorMsg);
        displayMsg = fromHelper.length > 0 ? fromHelper : (errorMsg || '重新发送失败，请稍后重试');
      }
      
      promptAction.showToast({ message: displayMsg, duration: 3000 });
    }
  }

  // ============ 密码输入相关 ============
  
  private async handleVerifyPassword(): Promise<void> {
    if (!this.password) {
      this.errorMessage = '请输入密码';
      this.showErrorDialog();
      return;
    }
    
    this.isPasswordLoading = true;
    
    try {
      await this.tdLibApi?.checkAuthenticationPassword(this.password);
      const authState = await this.tdLibApi?.getAuthorizationState();
      const stateType = authState ? (authState['@type'] as string) : '';
      
      if (stateType === 'authorizationStateReady') {
        this.navigateToMain();
      }
    } catch (error) {
      logPageError(TAG, `handleVerifyPassword error: ${JSON.stringify(error)}`);
      this.errorMessage = '密码错误，请重试';
      this.showErrorDialog();
      this.password = '';
    } finally {
      this.isPasswordLoading = false;
    }
  }

  private async handleForgotPassword(): Promise<void> {
    if (this.showRecoveryInput) {
      this.showRecoveryInput = false;
      this.recoveryCode = '';
      return;
    }
    
    try {
      const sent = await this.tdLibApi?.requestAuthenticationPasswordRecovery();
      if (sent) {
        this.showRecoveryInput = true;
        promptAction.showToast({
          message: $r('app.string.recovery_code_sent_hint'),
          duration: 3000
        });
      } else {
        promptAction.showToast({
          message: $r('app.string.email_no_recovery_hint'),
          duration: 2000
        });
      }
    } catch (error) {
      logPageError(TAG, `handleForgotPassword error: ${JSON.stringify(error)}`);
      promptAction.showToast({
        message: $r('app.string.request_recovery_failed_toast'),
        duration: 2000
      });
    }
  }

  private async handleRecoveryCodeSubmit(): Promise<void> {
    if (!this.recoveryCode.trim()) {
      promptAction.showToast({ message: $r('app.string.enter_recovery_code_placeholder'), duration: 2000 });
      return;
    }
    
    this.isPasswordLoading = true;
    
    try {
      const success = await this.tdLibApi?.checkAuthenticationPasswordRecoveryCode(this.recoveryCode.trim());
      if (success) {
        const authState = await this.tdLibApi?.getAuthorizationState();
        const stateType = authState ? (authState['@type'] as string) : '';
        
        if (stateType === 'authorizationStateReady') {
          this.navigateToMain();
        }
      } else {
        this.errorMessage = '恢复码无效';
        this.showErrorDialog();
      }
    } catch (error) {
      logPageError(TAG, `handleRecoveryCodeSubmit error: ${JSON.stringify(error)}`);
      this.errorMessage = '验证恢复码失败';
      this.showErrorDialog();
    } finally {
      this.isPasswordLoading = false;
    }
  }

/**
   * 显示错误对话框（参考 Telegram AlertsCreator.processError）
   * 标题：帮助，中间：具体提示，左下角：帮助，右下角：确定
   */
  private showErrorDialog(message?: string): void {
    const msg = message ?? this.errorMessage;
    if (!msg || msg.length === 0) {
      return;
    }
    promptAction.showDialog({
      title: '帮助',
      message: msg,
      buttons: [
        { text: '帮助', color: '#6B7280' },
        { text: '确定', color: '#0088CC' }
      ]
    }).then((result) => {
      if (result.index === 0) {
        // 用户点击帮助按钮
        // TODO: 打开帮助页面或显示帮助信息
      }
    }).catch(() => {
      // 对话框关闭
    });
  }

  // ============ UI 构建 ============

  build() {
    Column() {
      // 头部导航（固定不动，不避让键盘）
      this.buildHeader();
      
      // 主内容区（随键盘上移）
      Scroll() {
        Column() {
          if (this.currentView === LoginView.VIEW_PHONE_INPUT) {
            this.buildPhoneInputView();
          } else if (this.currentView === LoginView.VIEW_CODE_INPUT) {
            this.buildCodeInputView();
          } else if (this.currentView === LoginView.VIEW_PASSWORD_INPUT) {
            this.buildPasswordInputView();
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BACKGROUND)
    .opacity(this.pageOpacity)
    .animation({
      duration: 500,
      curve: Curve.EaseInOut
    })
    // ⭐ 安全区适配：顶部避开状态栏，底部避开导航手势条 + 额外边距
    .padding({ top: this.topSafeHeight, bottom: this.bottomSafeHeight })
    // 二维码登录弹窗
    .bindSheet(this.showQrCodeDialog, this.buildQrCodeSheet(), {
      showInSubWindow: false,
      dragBar: true,
      onWillDismiss: () => {
        // 用户尝试关闭弹窗时清理定时器
        this.closeQrCodeDialog();
      }
    })
  }

  /**
   * 二维码登录弹窗内容
   */
  @Builder
  buildQrCodeSheet() {
    Column() {
      // 标题栏
      Row() {
        Text($r('app.string.auth_qr_code'))
          .fontSize(FONT_SIZE_TITLE)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLOR_TEXT_PRIMARY);
        
        Blank().layoutWeight(1);
        
        // 关闭按钮
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.xmark'))
            .width(20)
            .height(20)
            .fontColor([COLOR_TEXT_PRIMARY]);
        }
        .width(32)
        .height(32)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.closeQrCodeDialog());
      }
      .width('100%')
      .padding({ left: SPACING_LG, right: SPACING_LG, top: SPACING_MD, bottom: SPACING_MD });
      
      Divider().color(COLOR_DIVIDER);
      
      // 二维码内容区
      if (this.isQrCodeLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color(COLOR_TELEGRAM_BLUE);
          
          Text($r('app.string.auth_qr_code_loading'))
            .fontSize(FONT_SIZE_BODY2)
            .fontColor(COLOR_TEXT_SECONDARY)
            .margin({ top: SPACING_MD });
        }
        .width('100%')
        .padding({ top: SPACING_XXL, bottom: SPACING_XXL })
        .alignItems(HorizontalAlign.Center);
      } else if (this.qrCodeError.length > 0) {
        // 错误状态
        Column() {
          SymbolGlyph($r('sys.symbol.exclamationmark_triangle'))
            .width(48)
            .height(48)
            .fontColor([COLOR_TEXT_TERTIARY]);
          
          Text(this.qrCodeError)
            .fontSize(FONT_SIZE_BODY2)
            .fontColor(COLOR_TEXT_SECONDARY)
            .margin({ top: SPACING_MD });
          
          Button($r('app.string.auth_qr_code_retry'))
            .width(150)
            .height(44)
            .fontSize(FONT_SIZE_BODY2)
            .fontColor(Color.White)
            .backgroundColor(COLOR_TELEGRAM_BLUE)
            .borderRadius(RADIUS_LG)
            .margin({ top: SPACING_LG })
            .onClick(() => this.refreshQrCode());
        }
        .width('100%')
        .padding({ top: SPACING_XXL, bottom: SPACING_XXL })
        .alignItems(HorizontalAlign.Center);
      } else {
        // 二维码显示
        Column() {
          // 提示文本
          Text($r('app.string.auth_qr_code_hint'))
            .fontSize(FONT_SIZE_BODY2)
            .fontColor(COLOR_TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
            .margin({ top: SPACING_MD, left: SPACING_XL, right: SPACING_XL });
          
          // 二维码
          Stack({ alignContent: Alignment.Center }) {
            Column() {
              Blank()
                .width(280 + SPACING_XL * 2)
                .height(280 + SPACING_XL * 2);
            }
            .backgroundColor(COLOR_BACKGROUND)
            .borderRadius(RADIUS_XL)
            .border({
              width: 2,
              color: COLOR_DIVIDER
            });
            
            QRCode(this.qrCodeUrl)
              .width(280)
              .height(280)
              .color(COLOR_QR_COLOR)
              .backgroundColor(COLOR_BACKGROUND);
          }
          .margin({ top: SPACING_LG });
          
          // 刷新按钮
          Row({ space: SPACING_LG }) {
            Button({ type: ButtonType.Normal }) {
              Text($r('app.string.refresh'))
                .fontSize(FONT_SIZE_BODY2)
                .fontColor(COLOR_TELEGRAM_BLUE)
            }
            .height(40)
            .padding({ left: SPACING_LG, right: SPACING_LG })
            .backgroundColor(Color.Transparent)
            .borderRadius(RADIUS_LG)
            .border({
              width: 1,
              color: COLOR_TELEGRAM_BLUE
            })
            .enabled(!this.isQrRefreshing)
            .onClick(() => this.refreshQrCode());
          }
          .margin({ top: SPACING_LG, bottom: SPACING_XXL });
        }
      }
    }
    .width('100%')
    .backgroundColor(COLOR_BACKGROUND);
  }

  @Builder
  private buildHeader() {
    Row() {
      // 返回按钮（仅非手机号页面显示）
      if (this.currentView !== LoginView.VIEW_PHONE_INPUT) {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.arrow_left'))
            .width(24)
            .height(24)
            .fontColor([COLOR_TEXT_PRIMARY])
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          if (this.currentView === LoginView.VIEW_CODE_INPUT) {
            // 参考 Telegram：验证码页返回时显示确认对话框
            this.showCodeInputBackConfirmDialog();
          } else if (this.currentView === LoginView.VIEW_PASSWORD_INPUT) {
            this.currentView = LoginView.VIEW_CODE_INPUT;
          }
        });
      } else {
        Blank().width(40);
      }

      // 占位
      Blank().layoutWeight(1);
      
      // 菜单按钮 - 始终显示
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.more'))
          .width(24)
          .height(24)
          .fontColor([COLOR_TEXT_PRIMARY])
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.showMenu();
      });
    }
    .width('100%')
    .height(56)
    .padding({ left: SPACING_SM, right: SPACING_SM })
    .backgroundColor(COLOR_BACKGROUND)
    // ⭐ 键盘避让：头部固定不动，不随键盘上移
    .expandSafeArea([SafeAreaType.KEYBOARD])
    .zIndex(1);
  }

  private showMenu(): void {
    // 使用 showActionMenu API
    promptAction.showActionMenu({
      title: '更多选项',
      buttons: [
        { text: '代理', color: '#333333' },
        { text: '语言', color: '#333333' },
        { text: '机器人登录', color: COLOR_TELEGRAM_BLUE },
        { text: '二维码登录', color: COLOR_TELEGRAM_BLUE },
        { text: '自定义API', color: '#333333' },
        { text: '自定义后端', color: '#333333' }
      ]
    }).then((result) => {
      switch (result.index) {
        case 0:
          promptAction.showToast({ message: '代理设置功能开发中', duration: 2000 });
          break;
        case 1:
          promptAction.showToast({ message: '语言设置功能开发中', duration: 2000 });
          break;
        case 2:
          router.pushUrl({ url: RoutePaths.AUTH_BOT_TOKEN });
          break;
        case 3:
          // 显示二维码登录弹窗
          this.showQrCodeLoginDialog();
          break;
        case 4:
          promptAction.showToast({ message: '自定义API功能开发中', duration: 2000 });
          break;
        case 5:
          promptAction.showToast({ message: '自定义后端功能开发中', duration: 2000 });
          break;
      }
    }).catch(() => {
      // 用户取消菜单
    });
  }

  @Builder
  private buildPhoneInputView() {
    Column() {
      // Lottie 动画
      LottieView({
        lottieId: 'auth-phone',
        path: $rawfile('duck-phone.json'),
        autoplay: true,
        loop: true,
        autoSkip: false,
        useCache: true,
        contentMode: 'Contain',
        controller: this.phoneLottieController
      })
        .width(160)
        .height(160)
        .margin({ top: SPACING_XXL });

      // 标题（参考 Telegram YourNumber）
      Text($r('app.string.auth_your_number'))
        .fontSize(FONT_SIZE_H3)
        .fontWeight(FontWeight.Medium)
        .fontColor(COLOR_TEXT_PRIMARY)
        .textAlign(TextAlign.Center)
        .margin({ top: SPACING_LG, left: SPACING_XL, right: SPACING_XL });

      // 副标题（参考 Telegram StartText）
      Text($r('app.string.auth_start_text'))
        .fontSize(FONT_SIZE_BODY2)
        .fontColor(COLOR_TEXT_SECONDARY)
        .textAlign(TextAlign.Center)
        .margin({ top: SPACING_SM, left: SPACING_XL, right: SPACING_XL });

      if (this.isPhoneLoading) {
        Column() {
          Text($r('app.string.auth_sending'))
            .fontSize(FONT_SIZE_BODY2)
            .fontColor(COLOR_TEXT_SECONDARY);
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      } else {
        Column() {
          // 国家选择按钮（参考 Telegram countryButton + countryOutlineView）
          this.buildCountrySelectButton();

          // 手机号输入框（参考 Telegram phoneOutlineView + codeField + phoneField）
          PhoneInputComponent({
            maxLength: 15,
            countryCode: this.countryCode,
            phoneNumber: this.phoneNumber,
            onPhoneChange: (phone: string) => this.onPhoneChange(phone),
            onCountryCodeChange: (code: string) => this.onCountryCodeChange(code),
            onCountryClick: () => this.showCountrySelect(),
            onCountryMatched: (country: CountryInfo) => this.onCountryMatched(country)
          })
            .margin({ top: SPACING_SM });

          // 下一步按钮（参考 TransformableLoginButtonView）- 恒亮可点击
          Button($r('app.string.auth_next'))
            .width(150)
            .height(48)
            .fontSize(FONT_SIZE_BODY2)
            .fontColor(Color.White)
            .backgroundColor(COLOR_TELEGRAM_BLUE)
            .borderRadius(RADIUS_LG)
            .margin({ top: SPACING_XL })
            .enabled(!this.isPhoneLoading)
            .onClick(() => this.handlePhoneNext())
            .shadow({
              radius: 8,
              color: 'rgba(51, 144, 240, 0.3)',
              offsetY: 4
            });
        }
        .width('100%')
        .padding(SPACING_LG)
        .constraintSize({ maxWidth: 400 });
      }

      // 同步联系人选项（参考 Telegram syncContactsBox）
      this.buildSyncContactsOption();

      // 底部链接区域
      Column() {
        // 服务条款和隐私政策
        Column() {
          Text($r('app.string.auth_agree_prefix'))
            .fontSize(FONT_SIZE_BODY3)
            .fontColor(COLOR_TEXT_TERTIARY);

          Row() {
            Text($r('app.string.auth_terms'))
              .fontSize(FONT_SIZE_BODY3)
              .fontColor(COLOR_TELEGRAM_BLUE)
              .onClick(() => this.openUrl(TELEGRAM_TOS_URL));
            Text($r('app.string.auth_and'))
              .fontSize(FONT_SIZE_BODY3)
              .fontColor(COLOR_TEXT_TERTIARY);
            Text($r('app.string.auth_privacy'))
              .fontSize(FONT_SIZE_BODY3)
              .fontColor(COLOR_TELEGRAM_BLUE)
              .onClick(() => this.openUrl(TELEGRAM_PRIVACY_URL));
          }
          .margin({ top: 4 });
        }
        .margin({ top: SPACING_XL });
      }
      .margin({ bottom: SPACING_LG });
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }

  /**
   * 构建国家选择按钮（参考 Telegram PhoneView.countryButton）
   */
  @Builder
  private buildCountrySelectButton() {
    Row() {
      // 显示当前匹配的国家信息
      if (this.currentCountry) {
        // 国旗 + 国家名称 + 区号
        Row() {
          Text(this.currentCountry.flag)
            .fontSize(20)
            .margin({ right: SPACING_SM });
          Text(this.currentCountry.name)
            .fontSize(FONT_SIZE_BODY1)
            .fontColor(COLOR_TEXT_PRIMARY);
        }
        .layoutWeight(1);
      } else {
        Text($r('app.string.auth_country'))
          .fontSize(FONT_SIZE_BODY1)
          .fontColor(COLOR_TEXT_PRIMARY)
          .layoutWeight(1);
      }

      SymbolGlyph($r('sys.symbol.arrow_right'))
        .width(24)
        .height(24)
        .fontColor([COLOR_TEXT_TERTIARY]);
    }
    .width('100%')
    .height(56)
    .backgroundColor(COLOR_BACKGROUND)
    .borderRadius(RADIUS_LG)
    .border({
      width: 1,
      color: COLOR_DIVIDER
    })
    .padding({ left: SPACING_MD, right: SPACING_MD })
    .onClick(() => this.showCountrySelect());
  }

  /**
   * 构建同步联系人选项（参考 Telegram LoginActivity）
   */
  @Builder
  private buildSyncContactsOption() {
    // 简化实现：根据新账户状态显示同步联系人选项
    if (false) { // TODO: 后续根据实际需求实现新账户判断
      Row() {
        Checkbox()
          .select(false)
          .onChange((isChecked: boolean) => {
            // TODO: 处理同步联系人开关
          });
        Text($r('app.string.auth_sync_contacts'))
          .fontSize(FONT_SIZE_BODY3)
          .fontColor(COLOR_TEXT_SECONDARY)
          .margin({ left: SPACING_SM });
      }
      .margin({ top: SPACING_MD });
    }
  }

  /**
   * 显示国家选择弹窗
   */
  private showCountrySelect(): void {
    promptAction.showToast({
      message: '国家选择功能开发中',
      duration: 2000
    });
  }

  @Builder
  private buildCodeInputView() {
    Stack() {
      Column() {
        // Lottie 动画
        LottieView({
          lottieId: 'auth-code',
          path: $rawfile('duck-passcode-notification.json'),
          autoplay: true,
          loop: true,
          autoSkip: false,
          useCache: true,
          contentMode: 'Contain',
          controller: this.codeLottieController
        })
          .width(128)
          .height(128)
          .margin({ top: SPACING_XXL });

        // 标题（参考 Telegram LoginActivitySmsView）
        Text(this.getCodeTitle())
          .fontSize(FONT_SIZE_TITLE)
          .fontWeight(600)
          .fontColor(COLOR_TEXT_PRIMARY)
          .margin({ top: SPACING_LG })
          .textAlign(TextAlign.Center);

        // 提示文本（参考 Telegram confirmTextView）
        Text(this.getCodeHintText())
          .fontSize(FONT_SIZE_BODY2)
          .fontColor(COLOR_TEXT_SECONDARY)
          .margin({ top: SPACING_MD })
          .textAlign(TextAlign.Center)
          .padding({ left: SPACING_XL, right: SPACING_XL });

        // 验证码输入框容器（参考 Telegram CodeFieldContainer）
        Stack() {
          // 1. 真实的输入框 - 透明化隐藏UI
          TextInput({ text: $$this.code })
            .id('codeInput')
            .width('100%')
            .height(42)
            .opacity(0)
            .maxLength(this.codeLength >= 4 && this.codeLength <= 8 ? this.codeLength : 8)
            .type(InputType.Number)
            .onChange((value: string) => {
              // 只保留数字
              let cleaned = '';
              for (let i = 0; i < value.length; i++) {
                const ch = value.charAt(i);
                if (ch >= '0' && ch <= '9') {
                  cleaned += ch;
                }
              }
              this.code = cleaned;
              // 自动提交验证码
              if (this.codeLength >= 4 && this.codeLength <= 8 &&
                  cleaned.length === this.codeLength) {
                this.submitCode();
              }
            });

          // 2. 视觉上的格子 - Row布局
          Row({ space: 7 }) {
            ForEach(this.getCodeFieldArray(), (_: number, index: number) => {
              Text(this.code.charAt(index) || '')
                .width(34)
                .height(42)
                .textAlign(TextAlign.Center)
                .fontSize(24)
                .fontWeight(700)
                .fontColor(COLOR_TEXT_PRIMARY)
                .backgroundColor(COLOR_BACKGROUND)
                .border({
                  width: index === this.getCurrentCodeFocusIndex() ? 2 : 1.5,
                  color: index === this.getCurrentCodeFocusIndex() ? COLOR_TELEGRAM_BLUE : COLOR_DIVIDER,
                  radius: 4
                })
                .onClick(() => {
                  // 点击格子时聚焦到真实输入框，呼出软键盘
                  focusControl.requestFocus('codeInput');
                });
            }, (index: number) => index.toString())
          }
          .justifyContent(FlexAlign.Center);
        }
        .margin({ top: SPACING_XL });

        // 底部区域（参考 Telegram problemFrame / timeText）
        Column() {
          // problemText - "没收到验证码？"（初始状态根据类型决定显示）
          if (this.shouldShowProblemText()) {
            Text(this.getProblemText())
              .fontSize(FONT_SIZE_BODY2)
              .fontColor(COLOR_TELEGRAM_BLUE)
              .margin({ top: SPACING_XL })
              .onClick(() => this.showDidNotGetCodeDialog());
          }
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.End)
        .alignItems(HorizontalAlign.Center)
        .margin({ bottom: SPACING_XXL });
      }
      .width('100%')
      .height('100%')
      .padding(SPACING_LG)
      .constraintSize({ maxWidth: 400 })
      .alignItems(HorizontalAlign.Center);
    }
    .width('100%')
    .height('100%');
  }

  /**
   * 获取验证码标题（参考 Telegram LoginActivitySmsView）
   */
  private getCodeTitle(): string {
    switch (this.codeInfoType) {
      case 'authenticationCodeTypeTelegramMessage':
        return getString('auth_code_title_telegram');
      case 'authenticationCodeTypeSms':
        return getString('auth_code_title_sms');
      case 'authenticationCodeTypeCall':
      case 'authenticationCodeTypeFlashCall':
      case 'authenticationCodeTypeMissedCall':
        return getString('auth_code_title_phone');
      default:
        return getString('auth_code_title_sms');
    }
  }

  /**
   * 获取验证码提示文本（参考 Telegram confirmTextView）
   */
  private getCodeHintText(): string {
    // 格式化手机号（参考 Nagram PhoneFormat.getInstance().format）
    const phone = this.formatPhoneNumber(this.currentPhoneNumber);
    
    switch (this.codeInfoType) {
      case 'authenticationCodeTypeTelegramMessage':
        return formatString('auth_code_sent_telegram', phone);
      case 'authenticationCodeTypeSms':
        return formatString('auth_code_sent_sms', phone);
      case 'authenticationCodeTypeCall':
        return formatString('auth_code_sent_call', phone);
      case 'authenticationCodeTypeFlashCall':
        return formatString('auth_code_sent_flash_call', phone);
      case 'authenticationCodeTypeMissedCall':
        return formatString('auth_code_sent_missed_call', phone);
      default:
        return getString('auth_code_hint_default');
    }
  }

  /**
   * 判断是否应该显示问题文本（参考 Nagram problemText）
   * 始终显示"没收到验证码？"
   */
  private shouldShowProblemText(): boolean {
    return true;
  }

  /**
   * 判断是否应该显示时间按钮（倒计时结束且有 nextType）
   */
  private shouldShowTimeButton(): boolean {
    if (this.countdown > 0) {
      return false;  // 还在倒计时中
    }
    
    // 倒计时结束且有 nextType
    return this.nextCodeType !== undefined && this.nextCodeType !== '' && this.nextCodeType !== 'undefined';
  }

  /**
   * 获取时间按钮文本（倒计时结束后显示的可点击按钮）
   */
  private getTimeButtonText(): string {
    if (this.isCallType(this.nextCodeType)) {
      return getString('auth_code_request_call');
    } else if (this.nextCodeType === 'authenticationCodeTypeSms') {
      return getString('auth_code_resend_sms');
    }
    return getString('auth_code_resend_sms');
  }

  /**
   * 时间按钮点击处理
   */
  private onTimeButtonClick(): void {
    // 根据 nextType 处理不同的重发请求
    this.resendCode();
  }

  /**
   * 显示"未收到验证码"弹窗（参考 Nagram DidNotGetTheCodeInfo 对话框）
   */
  private showDidNotGetCodeDialog(): void {
    const phone = this.formatPhoneNumber(this.currentPhoneNumber);
    const line1 = getString('auth_code_did_not_get_info_line1');
    const line2 = formatString('auth_code_did_not_get_info_line2', phone);
    const line3 = getString('auth_code_did_not_get_info_line3');
    const message = line1 + '\n\n' + line2 + '\n\n' + line3;

    promptAction.showDialog({
      title: getString('auth_code_did_not_get_info_title'),
      message: message,
      buttons: [
        { text: getString('auth_code_did_not_get_help'), color: COLOR_TELEGRAM_BLUE },
        { text: getString('auth_code_did_not_get_edit_number'), color: COLOR_TEXT_SECONDARY },
        { text: getString('auth_code_did_not_get_close'), color: COLOR_TEXT_SECONDARY }
      ]
    }).then((result) => {
      if (result.index === 0) {
        // 获取帮助 - 目前暂未实现
      } else if (result.index === 1) {
        // 修改手机号 - 直接返回手机号输入页
        this.currentView = LoginView.VIEW_PHONE_INPUT;
      }
      // index === 2 或取消：不作处理
    }).catch(() => {
      // 用户取消
    });
  }

  /**
   * 获取倒计时文本（参考 Nagram timeText）
   */
  private getTimeText(): string {
    const minutes = Math.floor(this.countdown / 60);
    const seconds = this.countdown % 60;
    
    // 判断下一个类型是否为电话类型
    const nextIsCallType = this.isCallType(this.nextCodeType);
    
    if (this.codeInfoType === 'authenticationCodeTypeSms') {
      // 当前是短信类型
      if (nextIsCallType) {
        return formatString('auth_code_call_available_in', minutes.toString(), seconds.toString());
      } else {
        return formatString('auth_code_resend_sms_available_in', minutes.toString(), seconds.toString());
      }
    } else if (this.isCallType(this.codeInfoType)) {
      // 当前是电话类型
      if (nextIsCallType) {
        return formatString('auth_code_call_available_in', minutes.toString(), seconds.toString());
      } else {
        return formatString('auth_code_sms_available_in', minutes.toString(), seconds.toString());
      }
    }
    
    // 默认情况
    return `${this.countdown} 秒后可重新发送`;
  }

  /**
   * 获取问题文本（参考 Nagram problemText）
   * 始终显示"未收到验证码？"
   */
  private getProblemText(): string {
    return getString('auth_code_did_not_get');
  }

  /**
   * 判断是否为电话类型验证码（参考 Nagram AUTH_TYPE_CALL 等）
   */
  private isCallType(codeType: string): boolean {
    return codeType === 'authenticationCodeTypeCall' ||
           codeType === 'authenticationCodeTypeFlashCall' ||
           codeType === 'authenticationCodeTypeMissedCall';
  }

  /**
   * 格式化手机号 - 直接返回原始格式，不做分隔
   */
  private formatPhoneNumber(phone: string): string {
    if (!phone) {
      return '';
    }
    // 移除空格但保留+号
    let cleaned = phone.replace(/\s/g, '');
    return cleaned;
  }

  /**
   * 获取验证码输入框数组
   */
  private getCodeFieldArray(): number[] {
    const length = (this.codeLength >= 4 && this.codeLength <= 8) ? this.codeLength : 5;
    const arr: number[] = [];
    for (let i = 0; i < length; i++) {
      arr.push(i);
    }
    return arr;
  }

  /**
   * 获取验证码输入框当前聚焦的索引（用于样式高亮）
   */
  private getCurrentCodeFocusIndex(): number {
    const len = this.code.length;
    const maxLen = this.codeLength >= 4 && this.codeLength <= 8 ? this.codeLength : 8;
    if (len >= maxLen) {
      return -1; // 已满，无焦点
    }
    return len;
  }

  @Builder
  private buildPasswordInputView() {
    Column() {
      // Lottie 动画
      LottieView({
        lottieId: 'auth-password',
        path: $rawfile('duck-password-unlock.json'),
        autoplay: true,
        loop: true,
        autoSkip: false,
        useCache: true,
        contentMode: 'Contain',
        controller: this.passwordLottieController
      })
        .width(160)
        .height(160)
        .margin({ top: SPACING_XXL });

      Text($r('app.string.enter_password_label'))
        .fontSize(FONT_SIZE_BODY1)
        .fontColor(COLOR_TEXT_PRIMARY)
        .margin({ top: 20 });

      Text(this.passwordHint)
        .fontSize(FONT_SIZE_BODY3)
        .fontColor(COLOR_TEXT_TERTIARY)
        .margin({ top: SPACING_SM });

      TextInput({
        placeholder: $r('app.string.enter_password_placeholder'),
        text: this.password
      })
        .type(this.showPassword ? InputType.Normal : InputType.Password)
        .fontSize(20)
        .fontColor(COLOR_TEXT_PRIMARY)
        .placeholderColor(COLOR_TEXT_TERTIARY)
        .width('100%')
        .height(56)
        .backgroundColor(COLOR_SURFACE)
        .borderRadius(RADIUS_MD)
        .padding({ left: SPACING_MD, right: SPACING_MD })
        .margin({ top: SPACING_LG })
        .onChange((value: string) => {
          this.password = value;
        })
        .onSubmit(() => {
          this.handleVerifyPassword();
        });

      Button($r('app.string.verify_button'))
        .width(150)
        .height(48)
        .fontSize(FONT_SIZE_BODY1)
        .fontColor(Color.White)
        .backgroundColor(this.password.length > 0 ? COLOR_TELEGRAM_BLUE : COLOR_TELEGRAM_LIGHT_BLUE)
        .borderRadius(RADIUS_MD)
        .margin({ top: 20 })
        .enabled(this.password.length > 0)
        .onClick(() => {
          this.handleVerifyPassword();
        });

      // 忘记密码 / 恢复码输入
      if (this.showRecoveryInput) {
        Column() {
          Text($r('app.string.enter_recovery_code_placeholder'))
            .fontSize(FONT_SIZE_BODY3)
            .fontColor(COLOR_TEXT_TERTIARY)
            .margin({ top: SPACING_LG });
          TextInput({ placeholder: $r('app.string.enter_recovery_code_placeholder'), text: this.recoveryCode })
            .fontSize(FONT_SIZE_BODY1)
            .margin({ top: SPACING_SM })
            .onChange((value: string) => {
              this.recoveryCode = value;
            });
          Button($r('app.string.use_recovery_code_button'))
            .fontSize(FONT_SIZE_BODY3)
            .fontColor(COLOR_TELEGRAM_BLUE)
            .backgroundColor(Color.Transparent)
            .margin({ top: SPACING_SM })
            .onClick(() => {
              this.handleRecoveryCodeSubmit();
            });
          Text($r('app.string.cancel_button'))
            .fontSize(FONT_SIZE_BODY3)
            .fontColor(COLOR_TEXT_TERTIARY)
            .margin({ top: SPACING_SM })
            .onClick(() => {
              this.showRecoveryInput = false;
              this.recoveryCode = '';
            });
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start);
      } else {
        Text($r('app.string.forgot_password_label'))
          .fontSize(FONT_SIZE_BODY3)
          .fontColor(COLOR_TELEGRAM_BLUE)
          .margin({ top: SPACING_LG })
          .onClick(() => {
            this.handleForgotPassword();
          });
      }
    }
    .width('100%')
    .padding(SPACING_LG)
    .constraintSize({ maxWidth: 400 })
    .alignItems(HorizontalAlign.Center);
  }

  // ============ 二维码登录弹窗相关方法 ============
  
  /**
   * 显示二维码登录弹窗
   */
  private async showQrCodeLoginDialog(): Promise<void> {
    logPageInfo(TAG, 'Opening QR code dialog');
    
    // 重置状态
    this.qrCodeUrl = '';
    this.isQrCodeLoading = true;
    this.qrCodeError = '';
    this.isQrRefreshing = false;
    
    // 清理之前的定时器
    if (this.qrCodeRefreshTimer) {
      clearTimeout(this.qrCodeRefreshTimer);
      this.qrCodeRefreshTimer = 0;
    }
    
    // 显示弹窗
    this.showQrCodeDialog = true;
    
    // 发起二维码认证请求
    await this.requestQrCodeAuth();
  }

  /**
   * 关闭二维码登录弹窗
   */
  private closeQrCodeDialog(): void {
    logPageInfo(TAG, 'Closing QR code dialog');
    
    if (this.qrCodeRefreshTimer) {
      clearTimeout(this.qrCodeRefreshTimer);
      this.qrCodeRefreshTimer = 0;
    }
    
    this.showQrCodeDialog = false;
  }

  /**
   * 发起二维码认证请求
   */
  private async requestQrCodeAuth(): Promise<void> {
    if (!this.tdLibApi) {
      return;
    }
    
    this.isQrCodeLoading = true;
    this.qrCodeError = '';
    
    try {
      logPageInfo(TAG, 'Requesting QR code authentication');
      
      // 先检查当前状态
      const authState = await this.authService.getAuthorizationState();
      const stateType = authState['@type'] as string;
      
      // 如果已经是等待确认状态，使用现有链接
      if (stateType === 'authorizationStateWaitOtherDeviceConfirmation') {
        const linkValue = authState['link'] as string;
        if (linkValue && linkValue.length > 0) {
          logPageInfo(TAG, 'Using existing QR code link');
          this.savedQrCodeLink = linkValue;
          this.qrCodeUrl = linkValue;
          this.isQrCodeLoading = false;
          this.scheduleQrCodeRefresh();
          return;
        }
      }
      
      // 如果已经是 Ready 状态，直接跳转
      if (stateType === 'authorizationStateReady') {
        logPageInfo(TAG, 'Already authenticated, navigating to Main');
        this.closeQrCodeDialog();
        this.navigateToMain();
        return;
      }
      
      // 请求新的二维码
      await this.tdLibApi.requestQrCodeAuthentication([]);
      
      // 设置超时处理
      setTimeout(() => {
        if (this.isQrCodeLoading && !this.qrCodeUrl) {
          logPageInfo(TAG, 'QR code timeout');
          this.isQrCodeLoading = false;
          this.qrCodeError = '获取二维码超时，请重试';
        }
      }, 5000);
      
    } catch (error) {
      logPageError(TAG, `Failed to request QR code: ${error}`);
      this.isQrCodeLoading = false;
      this.qrCodeError = '获取二维码失败，请重试';
    }
  }

  /**
   * 刷新二维码
   */
  private async refreshQrCode(): Promise<void> {
    if (this.qrCodeRefreshTimer) {
      clearTimeout(this.qrCodeRefreshTimer);
      this.qrCodeRefreshTimer = 0;
    }
    
    this.isQrRefreshing = true;
    
    try {
      await this.requestQrCodeAuth();
    } finally {
      this.isQrRefreshing = false;
    }
  }

  /**
   * 安排二维码刷新定时器
   */
  private scheduleQrCodeRefresh(): void {
    if (this.qrCodeRefreshTimer) {
      clearTimeout(this.qrCodeRefreshTimer);
      this.qrCodeRefreshTimer = 0;
    }
    
    // 二维码约20秒过期，提前2秒刷新
    const refreshDelay = 18000;
    
    const timerId = setTimeout(() => {
      logPageInfo(TAG, 'Auto refreshing QR code');
      this.refreshQrCode();
    }, refreshDelay);
    
    this.qrCodeRefreshTimer = Number(timerId);
  }

  // ==========================================
}