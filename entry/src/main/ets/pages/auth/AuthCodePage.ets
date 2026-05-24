/**
 * 验证码输入页面
 * 支持 4–8 位验证码（与 TDLib code_length 一致）；错误统一经 AuthErrorHelper 展示，避免重复
 */
import { router, promptAction } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { AuthService, TDLibClient } from '../../services/core';
import type { CodeInfoCache } from '../../services/business/AuthService';
import { TdApiFactory, TDLibApi } from '../../services/api';
import { BusinessError } from '@kit.BasicServicesKit';
import { AuthState } from '../../models';
import { LottieController, LottieView } from '@ohos/lottie-turbo';
import { DataValidator, getString, formatString } from '../../utils';
import { getAuthErrorLocaleKey, getAuthErrorDisplayMessage, AUTH_ERROR_SILENT } from '../../utils/AuthErrorHelper';
import { logPageInfo, logPageError, logPageWarn } from '../../utils/log/LogService';
import { ThemeTokenFactory } from '../../ui_kit/themes/ThemeTokens';
import { RoutePaths } from '../../utils/navigation/NavigationHelper';
import { ImmersiveContainer } from '../../components/common/ImmersiveContainer';
import { ImmersiveMode, ThemeMode } from '../../utils/utils/ImmersiveUtils';


// 获取浅色主题 Token
const theme = ThemeTokenFactory.createLightTokens();

// 从主题系统获取常量和颜色
const TEXT_SECONDARY = theme.colors.textSecondary;
const BACKGROUND = theme.colors.background;
const BACKGROUND_SECONDARY = theme.colors.surface;
const TEXT_PRIMARY = theme.colors.text;
const TELEGRAM_BLUE = theme.colors.telegramBlue;
const TEXT_TERTIARY = theme.colors.textTertiary;

// 从主题获取常量
const AppSpacing = theme.spacing;
const AppFont = theme.typography;

// 定义颜色常量（与 AuthPhonePage 一致）
interface AppColorsType {
  TEXT_SECONDARY: string;
  TEXT_TERTIARY: string;
  TELEGRAM_BLUE: string;
}

const AppColors: AppColorsType = {
  TEXT_SECONDARY: TEXT_SECONDARY,
  TEXT_TERTIARY: TEXT_TERTIARY,
  TELEGRAM_BLUE: TELEGRAM_BLUE
};

const TAG = 'AuthCodePage';

/** bindPopup onStateChange 回调参数类型（ArkTS 不允许对象字面量作类型声明） */
interface PopupStateEvent {
  isVisible: boolean;
}

/** Lottie 动画配置接口 */
interface LottieConfig {
  lottieId: string;
  url: string;
}

/** 根据 TDLib code_info 类型返回提示文本 */
function getCodeHintText(codeInfoType: string): string {
  if (!codeInfoType || codeInfoType.length === 0) {
    return '等待 Telegram 发送验证码';
  }
  switch (codeInfoType) {
    case 'authenticationCodeTypeTelegramMessage':
      return '验证码已通过 Telegram 消息发送给您';
    case 'authenticationCodeTypeSms':
      return '验证码已通过短信发送给您';
    case 'authenticationCodeTypeCall':
      return '我们将通过语音电话告知您验证码';
    case 'authenticationCodeTypeFlashCall':
      return '我们将通过闪信告知您验证码';
    case 'authenticationCodeTypeMissedCall':
      return '请留意未接来电，验证码为最后 4 位数字';
    default:
      return '请输入收到的验证码';
  }
}

@Entry
@Component
struct AuthCodePage {
  @State code: string = '';
  @State countdown: number = 0;
  @State isLoading: boolean = false;
  @State codeInfoType: string = '';
  /** 验证码位数：4–8 为服务端指定位数，0 表示不限制（接受 4–8 位任意长度） */
  @State codeLength: number = 0;
  /** ⭐ TDLib 返回的实际超时时间（秒），用于重发时重置倒计时 */
  private tdlibTimeoutSeconds: number = 0;
  @State errorMessage: string = '';
  @State showErrorPopup: boolean = false;
  // Lottie 动画配置 - 使用本地资源路径
  private readonly LOTTIE_CONFIG: LottieConfig = {
    lottieId: 'auth-code',
    url: 'resources/rawfile/duck-passcode-notification.json'
  };

  private authService: AuthService = AuthService.getInstance();
  private tdLibClient: TDLibClient = TDLibClient.getInstance();
  private tdLibApi: TDLibApi | null = null;
  private countdownTimer: number = 0;
  private lottieController: LottieController = new LottieController();
  /** 防止重复跳转 */
  private hasNavigated: boolean = false;

  async aboutToAppear(): Promise<void> {
    // 初始化 TDLibApi
    const factory = TdApiFactory.getInstance();
    this.tdLibApi = factory.createDefault();
    

    
    // 【对齐 HMTG1.0.2】优先从 AuthService 缓存中同步验证码信息
    const cachedInfo = AuthService.lastCodeInfo;
    if (cachedInfo) {
      this.codeInfoType = cachedInfo.type;
      this.codeLength = cachedInfo.length;
      // ⭐ 关键修复：从缓存恢复timeout，确保倒计时使用正确的值
      if (typeof cachedInfo.timeout === 'number' && cachedInfo.timeout > 0) {
        this.tdlibTimeoutSeconds = cachedInfo.timeout;
        logPageInfo(TAG, `Synced timeout from cache: ${this.tdlibTimeoutSeconds}s`);
      }
      logPageInfo(TAG, `Synced from AuthService cache: type=${this.codeInfoType}, length=${this.codeLength}, timeout=${this.tdlibTimeoutSeconds}`);
    }
    
    // ⭐ 新增：尝试从时间戳恢复倒计时（跨页面场景）
    this.restoreCountdownFromTimestamp();
    
    logPageInfo(TAG, `aboutToAppear; codeInfoType=${this.codeInfoType || '(empty)'} codeLength=${this.codeLength}`);
    
    // 如果没有从时间戳恢复，则启动新的倒计时
    if (this.countdown <= 0) {
      this.startCountdown();
    }
    
    this.setupAuthStateListener();
    this.setupNeedCodeListener();
    this.setupNeedPasswordListener();
    this.setupTdlibErrorListener();
  }

  onPageShow(): void {
    logPageInfo(TAG, 'onPageShow');
    // ⭐ 重新播放 Lottie 动画（页面返回时）
    this.lottieController.play();
  }

  aboutToDisappear(): void {
    logPageInfo(TAG, 'aboutToDisappear');
    // 【关键修复】页面销毁时清除定时器并清理缓存，防止内存泄漏和状态冲突
    if (this.countdownTimer) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = 0;
    }
    // 清除缓存，确保下次进入时能重新同步最新状态
    AuthService.lastCodeInfo = null;
    this.hasNavigated = false;
    
    emitter.off('tdlib_auth_state');
    emitter.off('tdlib_need_code');
    emitter.off('tdlib_need_password');
    emitter.off('tdlib_error');
  }

  /** 统一错误展示：仅通过 AuthErrorHelper 取文案，静默错误不弹 Toast */
  private setupTdlibErrorListener(): void {
    emitter.on('tdlib_error', (payload: Record<string, Object>) => {
      const data = payload['data'] as Record<string, Object> | undefined;
      if (!data || typeof data !== 'object') {
        return;
      }
      const code = data['code'] as number | undefined;
      const msg = data['message'];
      const msgStr = typeof msg === 'string' ? msg : '';
      
      logPageInfo(TAG, `tdlib_error received: code=${code}, msg=${msgStr}`);
      
      const key = getAuthErrorLocaleKey(code, msgStr);
      if (key === AUTH_ERROR_SILENT) {
        logPageInfo(TAG, 'Silent error, skip display');
        return;
      }
      
      const displayMsg = getAuthErrorDisplayMessage(code, msgStr);
      logPageInfo(TAG, `displayMsg: "${displayMsg}" (key: ${key})`);
      
      if (displayMsg.length > 0) {
        promptAction.showToast({ message: displayMsg, duration: 3000 });
      } else {
        logPageWarn(TAG, 'displayMsg is empty, not showing toast');
      }
    });
  }

  private setupAuthStateListener(): void {
    emitter.on('tdlib_auth_state', (data: Record<string, Object>) => {
      const payload = data['data'] as Record<string, Object> | undefined;
      const state = payload ? (payload['state'] as string) : undefined;
      logPageInfo(TAG, `🔔 tdlib_auth_state received: ${state}, hasNavigated=${this.hasNavigated}`);
      
      if (state === AuthState.WAITING_PASSWORD) {
        if (this.hasNavigated) {
          logPageInfo(TAG, '⏭️ WAITING_PASSWORD: already navigated, skip');
          return;
        }
        logPageInfo(TAG, '🔐 navigate to AuthPasswordPage (from auth_state)');
        this.hasNavigated = true;
        this.isLoading = false; // 关闭 loading
        router.replaceUrl({ url: RoutePaths.AUTH_PASSWORD_INPUT });
      } else if (state === AuthState.READY) {
        if (this.hasNavigated) {
          logPageInfo(TAG, '✅ READY: already navigated, skip');
          return;
        }
        logPageInfo(TAG, '✅ navigate to MainTabContainer');
        this.hasNavigated = true;
        this.isLoading = false; // 关闭 loading
        router.replaceUrl({ url: RoutePaths.MAIN });
      }
    });
  }

  private setupNeedPasswordListener(): void {
    emitter.on('tdlib_need_password', (_data: Record<string, Object>) => {
      if (this.hasNavigated) {
        logPageInfo(TAG, 'tdlib_need_password: already navigated, skip');
        return;
      }
      logPageInfo(TAG, 'tdlib_need_password received, navigate to AuthPasswordPage');
      this.hasNavigated = true;
      router.replaceUrl({ url: RoutePaths.AUTH_PASSWORD_INPUT });
    });
  }

  private setupNeedCodeListener(): void {
    emitter.on('tdlib_need_code', (data: Record<string, Object>) => {
      const payload = data['data'] as Record<string, Object> | undefined;
      if (payload !== undefined && payload !== null) {
        const typeVal = payload['code_info_type'];
        if (typeof typeVal === 'string') {
          this.codeInfoType = typeVal;
          logPageInfo(TAG, `code_info_type=${typeVal}`);
        }
        const lenVal = payload['code_length'];
        if (typeof lenVal === 'number') {
          this.codeLength = (lenVal >= 4 && lenVal <= 8) ? lenVal : 0;
          logPageInfo(TAG, `code_length=${this.codeLength} (raw=${lenVal})`);
        }
        
        // ⭐ 关键修复：使用 TDLib 返回的实际超时时间
        const timeoutVal = payload['timeout_seconds'];
        if (typeof timeoutVal === 'number' && timeoutVal > 0) {
          this.countdown = timeoutVal;
          this.tdlibTimeoutSeconds = timeoutVal; // ⭐ 保存以便重发时使用
          logPageInfo(TAG, `countdown set to TDLib timeout: ${timeoutVal}s`);
        } else {
          // 降级为默认60秒
          this.countdown = 60;
          this.tdlibTimeoutSeconds = 60;
          logPageInfo(TAG, `countdown using default: 60s`);
        }
        
        // 【关键】同步更新 AuthService 缓存，确保页面重建时也能拿到最新信息
        const info: CodeInfoCache = { 
          type: this.codeInfoType, 
          length: this.codeLength,
          timeout: this.tdlibTimeoutSeconds // ⭐ 保存timeout到缓存
        };
        AuthService.lastCodeInfo = info;
      }
    });
  }

  /** 当前输入是否有效：有指定位数时须恰好该位数，未指定时 4–8 位均可 */
  private isCodeLengthValid(): boolean {
    if (this.code.length < 4 || this.code.length > 8) {
      return false;
    }
    if (this.codeLength >= 4 && this.codeLength <= 8) {
      return DataValidator.validateCodeByLength(this.code, this.codeLength);
    }
    return DataValidator.validateCodeByLength(this.code, this.code.length);
  }

  /**
   * ⭐ 新增：从时间戳恢复倒计时（跨页面场景）
   * 当用户离开页面再回来时，根据缓存的时间戳计算剩余时间
   */
  private restoreCountdownFromTimestamp(): void {
    if (AuthService.lastCodeTimestamp <= 0 || this.tdlibTimeoutSeconds <= 0) {
      logPageInfo(TAG, 'Cannot restore countdown: timestamp or timeout not available');
      return;
    }
    
    const SAFETY_BUFFER = 20; // 与 startCountdown 中保持一致
    const totalDuration = this.tdlibTimeoutSeconds + SAFETY_BUFFER;
    const elapsedSeconds = Math.floor((Date.now() - AuthService.lastCodeTimestamp) / 1000);
    const remainingSeconds = Math.max(0, totalDuration - elapsedSeconds);
    
    if (remainingSeconds > 0) {
      this.countdown = remainingSeconds;
      this.startCountdownTimer(); // 只启动定时器，不重置 countdown
      logPageInfo(TAG, `Restored countdown from timestamp: ${remainingSeconds}s remaining (elapsed=${elapsedSeconds}s, total=${totalDuration}s)`);
    } else {
      logPageInfo(TAG, `Countdown expired: elapsed=${elapsedSeconds}s >= total=${totalDuration}s`);
      this.countdown = 0;
    }
  }

  /**
   * 仅启动定时器（用于恢复倒计时场景）
   */
  private startCountdownTimer(): void {
    if (this.countdownTimer) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = 0;
    }
    
    this.countdownTimer = setInterval(() => {
      if (this.countdown > 0) {
        this.countdown--;
      } else {
        if (this.countdownTimer) {
          clearInterval(this.countdownTimer);
          this.countdownTimer = 0;
        }
      }
    }, 1000);
  }

  private startCountdown(): void {
    if (this.countdownTimer) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = 0;
    }
    // ⭐ 关键修复：使用 TDLib 返回的实际超时时间，而非硬编码60秒
    // ⭐ 额外增加20秒安全缓冲，避免前端倒计时结束但TDLib仍在冷却期
    // ⭐ 根据实际测试，某些情况下(如+86号码、短信通道拥堵)冷却期可能超过70秒
    const SAFETY_BUFFER = 20; // 秒
    this.countdown = this.tdlibTimeoutSeconds + SAFETY_BUFFER;
    
    // ⭐ 增强日志：详细记录倒计时信息
    logPageInfo(TAG, `
      ===== Countdown Started =====
      TDLib timeout: ${this.tdlibTimeoutSeconds}s
      Safety buffer: ${SAFETY_BUFFER}s
      Total countdown: ${this.countdown}s
      Current time: ${new Date().toISOString()}
      Expected enable time: ${new Date(Date.now() + this.countdown * 1000).toISOString()}
      ===========================
    `);
    
    // 启动定时器
    this.startCountdownTimer();
  }

  build() {
    Column() {
      ImmersiveContainer({
        mode: ImmersiveMode.COMPONENT_TOP,
        theme: ThemeMode.AUTO,
        excludeBottom: true
      }) {
        // ⭐ 使用 Flex 布局实现完美居中
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
          Column() {
            // Lottie 动画（使用 lottie-turbo）
            LottieView({
              lottieId: this.LOTTIE_CONFIG.lottieId,
              path: $rawfile('duck-passcode-notification.json'),
              autoplay: true,
              loop: true,
              autoSkip: false,
              useCache: true,
              contentMode: 'Contain',
              controller: this.lottieController
            })
              .width(160)
              .height(160);

            Text(getCodeHintText(this.codeInfoType))
              .fontSize(AppFont.body2.fontSize)
              .fontColor(AppColors.TEXT_SECONDARY)
              .margin({ top: 20, bottom: 8 })
              .textAlign(TextAlign.Center)

            TextInput({
              // ⭐ 直接使用字符串拼接，避免 getString() 在 build() 中调用失败
              placeholder: (this.codeLength >= 4 && this.codeLength <= 8)
                ? `请输入${this.codeLength}位验证码`
                : '请输入 4-8 位验证码',
              text: this.code
            })
              .type(InputType.Number)
              .maxLength(this.codeLength >= 4 && this.codeLength <= 8 ? this.codeLength : 8)
              .fontSize(28)
              .fontWeight(700)
              .letterSpacing(8)
              .textAlign(TextAlign.Center)
              .height(72)
              .onChange((value: string) => {
                this.code = value;
                this.showErrorPopup = false;
                if (this.codeLength >= 4 && this.codeLength <= 8 &&
                    value.length === this.codeLength &&
                    DataValidator.validateCodeByLength(value, this.codeLength)) {
                  this.submitCode();
                }
              })
              .margin({ top: 20, bottom: 20 })

            if (this.countdown <= 0) {
              Button('重新发送验证码')
                .fontSize(14)
                .backgroundColor(Color.Transparent)
                .fontColor(AppColors.TELEGRAM_BLUE)
                .enabled(true)
                .onClick(() => this.resendCode())
            } else {
              Text(`请等待 ${this.countdown} 秒后重试`)
                .fontSize(14)
                .fontColor(AppColors.TEXT_TERTIARY)
            }
          }
          .width('100%')
          .padding(20)
          .constraintSize({ maxWidth: 400 })

          // ⭐ 下一步按钮独立放置，确保底部对齐
          Button('下一步')
            .width(150)
            .height(48)
            .fontSize(16)
            .backgroundColor(AppColors.TELEGRAM_BLUE)
            .opacity(this.isCodeLengthValid() && !this.isLoading ? 1 : 0.5)
            .onClick(() => {
              if (!this.isCodeLengthValid() || this.isLoading) {
                if (!this.isCodeLengthValid()) {
                  this.errorMessage = (this.codeLength >= 4 && this.codeLength <= 8)
                    ? `请输入 ${this.codeLength} 位验证码`
                    : '请输入 4-8 位验证码';
                  this.showErrorPopup = true;
                }
                return;
              }
              this.submitCode();
            })
            .margin({ top: 40, bottom: 24 })
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .bindPopup(this.showErrorPopup, {
      message: this.errorMessage,
      onStateChange: (e: PopupStateEvent) => {
        if (!e.isVisible) {
          this.showErrorPopup = false;
        }
      }
    })
  }

  private async submitCode(): Promise<void> {
    const expectedLen = (this.codeLength >= 4 && this.codeLength <= 8) ? this.codeLength : this.code.length;
    if (!DataValidator.validateCodeByLength(this.code, expectedLen)) {
      this.errorMessage = (this.codeLength >= 4 && this.codeLength <= 8)
        ? `请输入 ${this.codeLength} 位验证码`
        : '请输入 4-8 位验证码';
      this.showErrorPopup = true;
      return;
    }
    if (this.codeInfoType.length === 0) {
      logPageInfo(TAG, 'submitCode: codeInfoType not set yet, submitting anyway');
    }
    
    // ⭐ 关键修复：检查当前状态，避免在等待密码状态下重复调用checkAuthenticationCode
    if (this.tdLibApi) {
      try {
        const currentState = await this.tdLibApi.getAuthorizationState();
        const currentType = currentState['@type'] as string;
        logPageInfo(TAG, `🔍 Before submitCode: current auth state = ${currentType}`);
        
        if (currentType === 'authorizationStateWaitPassword') {
          logPageInfo(TAG, '⚠️ Already waiting for password, skip checkAuthenticationCode and jump directly');
          if (!this.hasNavigated) {
            this.hasNavigated = true;
            this.isLoading = false;
            router.replaceUrl({ url: RoutePaths.AUTH_PASSWORD_INPUT });
          }
          return;
        }
      } catch (err) {
        logPageError(TAG, `Failed to get auth state before submit: ${JSON.stringify(err)}`);
        // 继续执行，让后续的错误处理捕获
      }
    }
    
    this.isLoading = true;
    logPageInfo(TAG, `📤 submitCode: code len=${this.code.length} expected=${expectedLen}`);
    
    try {
      const result = await this.authService.checkCodeAsync(this.code);
      
      if (result.success) {
        // 成功：等待 TDLib 状态更新触发跳转
        logPageInfo(TAG, '✅ 验证码正确，等待状态更新跳转');
        // 注意：不在这里关闭 isLoading，由事件处理器负责关闭
        
        // ⭐ 双重保险：主动检查状态，防止事件丢失
        setTimeout(() => {
          if (!this.hasNavigated && this.tdLibApi) {
            this.tdLibApi.getAuthorizationState().then((state) => {
              const stateType = state['@type'] as string;
              logPageInfo(TAG, `🔄 Timeout check: auth state = ${stateType}`);
              
              if (stateType === 'authorizationStateWaitPassword' && !this.hasNavigated) {
                logPageInfo(TAG, '🔐 Timeout fallback: jump to AuthPasswordPage');
                this.hasNavigated = true;
                this.isLoading = false;
                router.replaceUrl({ url: RoutePaths.AUTH_PASSWORD_INPUT });
              } else if (stateType === 'authorizationStateReady' && !this.hasNavigated) {
                logPageInfo(TAG, '✅ Timeout fallback: jump to MainTabContainer');
                this.hasNavigated = true;
                this.isLoading = false;
                router.replaceUrl({ url: RoutePaths.MAIN });
              }
            }).catch((err: Error) => {
              logPageError(TAG, `Timeout check failed: ${JSON.stringify(err)}`);
            });
          }
        }, 2000); // 2秒后检查
      } else {
        // 失败：显示错误，允许重试
        const displayMsg = getAuthErrorDisplayMessage(result.errorCode, result.errorMessage);
        this.errorMessage = displayMsg.length > 0 ? displayMsg : '操作失败，请重试';
        this.showErrorPopup = true;
        this.isLoading = false;
        
        // ⭐ 特殊处理：如果是 "unexpected" 错误，检查是否需要跳转到密码页
        if (result.errorMessage && result.errorMessage.includes('unexpected')) {
          logPageInfo(TAG, '⚠️ Detected "unexpected" error, checking current state...');
          if (this.tdLibApi) {
            try {
              const currentState = await this.tdLibApi.getAuthorizationState();
              const currentType = currentState['@type'] as string;
              
              if (currentType === 'authorizationStateWaitPassword') {
                logPageInfo(TAG, '🔐 State is WaitPassword after unexpected error, jumping to password page');
                this.hasNavigated = true;
                this.isLoading = false;
                router.replaceUrl({ url: RoutePaths.AUTH_PASSWORD_INPUT });
                return;
              }
            } catch (err) {
              logPageError(TAG, `Failed to check state after error: ${JSON.stringify(err)}`);
            }
          }
        }
      }
    } catch (error) {
      logPageError(TAG, `submitCode error: ${JSON.stringify(error)}`);
      this.errorMessage = '操作失败，请重试';
      this.showErrorPopup = true;
      this.isLoading = false;
    }
  }

  private async resendCode(): Promise<void> {
    // ⭐ 增强日志：记录重发尝试的详细信息
    logPageInfo(TAG, `
      ===== Resend Attempt =====
      Current countdown: ${this.countdown}s
      TDLib timeout: ${this.tdlibTimeoutSeconds}s
      Is enabled: ${this.countdown <= 0}
      Timestamp: ${new Date().toISOString()}
      =========================
    `);
    
    const result = await this.authService.resendAuthenticationCode();
    
    if (result.success) {
      promptAction.showToast({ message: '验证码已重新发送', duration: 2000 });
      // ⭐ 修复：重置倒计时为 TDLib 返回的 timeout 值（如果有的话）
      // 如果没有，则使用默认60秒
      this.startCountdown();
      
      logPageInfo(TAG, `
        ===== Resend Success =====
        New countdown: ${this.countdown}s
        ==========================
      `);
    } else {
      // ⭐ 关键修复：处理 "can't be resend" 错误
      const errorMsg = result.errorMessage || '';
      let displayMsg = '';
      
      if (errorMsg.includes("can't be resend") || errorMsg.includes('cannot be resent')) {
        // TDLib 认为还在冷却期内
        // ⭐ 注意：TDLib 通常不返回 FLOOD_WAIT_X 格式，而是通用拒绝消息
        // 使用缓存的 timeout 估算剩余时间会更准确
        const SAFETY_BUFFER = 20; // 与 startCountdown 中保持一致
        const elapsedTime = SAFETY_BUFFER - this.countdown; // 已经过去的缓冲时间
        const remainingTime = Math.max(0, this.countdown); // 当前剩余的倒计时就是需要等待的时间
        
        if (remainingTime > 5) {
          displayMsg = `请等待约 ${Math.ceil(remainingTime)} 秒后再试`;
          logPageInfo(TAG, `Resend rejected by TDLib (cooldown), countdown remaining: ${remainingTime}s`);
        } else {
          displayMsg = '请稍后再试，验证码尚未到重发时间';
          logPageInfo(TAG, `Resend rejected by TDLib (cooldown): ${errorMsg}`);
        }
      } else if (errorMsg.includes('unexpected')) {
        // 状态异常
        displayMsg = '验证码尚未下发，请稍候或检查网络后重试';
        logPageInfo(TAG, `Resend rejected (unexpected state): ${errorMsg}`);
      } else {
        // 其他错误，尝试从 AuthErrorHelper 获取友好文案
        const fromHelper = getAuthErrorDisplayMessage(undefined, errorMsg);
        displayMsg = fromHelper.length > 0 ? fromHelper : (errorMsg || '重新发送失败，请稍后重试');
      }
      
      promptAction.showToast({ message: displayMsg, duration: 3000 });
    }
  }

}
