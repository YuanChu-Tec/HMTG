/**
 * 手机号验证页面
 * 严格遵循 Telegram 认证逻辑：
 * 1. 首次发送手机号调用 setAuthenticationPhoneNumber
 * 2. 若已在等待验证码状态，手机号相同则直接跳转验证码页
 * 3. 若手机号不同，提示用户使用重置按钮重新开始
 * 4. 重置按钮调用 logout 并重新初始化 TDLib
 */
import { common } from '@kit.AbilityKit';
import { router, promptAction } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { AuthService, TDLibClient } from '../../services/core';
import { PhoneInputComponent } from '../../components/auth';
import { getAuthErrorDisplayMessage, AUTH_ERROR_SILENT, getAuthErrorLocaleKey } from '../../utils/AuthErrorHelper';
import { logPageInfo, logPageError } from '../../utils/log';
import { LottieController, LottieView } from '@ohos/lottie-turbo';
import { ThemeTokenFactory } from '../../ui_kit/themes/ThemeTokens';
import { RoutePaths } from '../../utils/navigation/NavigationHelper';
import { ImmersiveContainer } from '../../components/common/ImmersiveContainer';
import { ImmersiveMode, ThemeMode } from '../../utils/utils/ImmersiveUtils';


const theme = ThemeTokenFactory.createLightTokens();
const TEXT_SECONDARY = theme.colors.textSecondary;
const BACKGROUND = theme.colors.background;
const TELEGRAM_BLUE = theme.colors.telegramBlue;

interface GeneratedObjectLiteralInterface_1 {
  TELEGRAM_LIGHT_BLUE: string;
}

const AppColors: GeneratedObjectLiteralInterface_1 = { TELEGRAM_LIGHT_BLUE: theme.colors.telegramLightBlue };
const TEXT_TERTIARY = theme.colors.textTertiary;
const AppSpacing = theme.spacing;
const AppFont = theme.typography;
const AppRadius = theme.borders;

const TELEGRAM_TOS_URL = 'https://telegram.org/tos';
const TELEGRAM_PRIVACY_URL = 'https://telegram.org/privacy';
const TAG = 'AuthPhonePage';

interface PopupStateEvent {
  isVisible: boolean;
}

interface LottieConfig {
  lottieId: string;
  url: string;
}

@Entry
@Component
export struct AuthPhonePage {
  @State private isLoading: boolean = false;
  @State private phoneNumber: string = '';
  @State private countryCode: string = '+86';
  @State private isPhoneValid: boolean = false;
  @State private errorMessage: string = '';
  @State private showErrorPopup: boolean = false;
  // Lottie 动画配置 - 使用本地资源路径
  private readonly LOTTIE_CONFIG: LottieConfig = {
    lottieId: 'auth-phone',
    url: 'resources/rawfile/duck-phone.json'
  };
  private isDestroyed: boolean = false;
  private hasNavigated: boolean = false; // 防止重复跳转
  private currentPhoneNumber: string = ''; // 当前请求的手机号
  private lastSentPhoneNumber: string = ''; // 最后一次成功发送验证码的手机号
  private authService = AuthService.getInstance();
  private tdlibClient = TDLibClient.getInstance();
  private lottieController: LottieController = new LottieController();

  async aboutToAppear(): Promise<void> {
    logPageInfo(TAG, 'aboutToAppear');
    this.isDestroyed = false;
    this.hasNavigated = false;
    this.resetUiState();
    this.setupAuthStateListener();
    this.setupTdlibErrorListener();
    
    // ⭐ TDLib 已在 EntryAbility 中初始化，此处直接检查认证状态
    await this.checkAlreadyWaitingState();
  }

  onPageShow(): void {
    logPageInfo(TAG, 'onPageShow');
    this.hasNavigated = false; // 重置导航锁，允许再次跳转
    // ⭐ 重新播放 Lottie 动画（页面返回时）
    this.lottieController.play();
  }

  aboutToDisappear(): void {
    logPageInfo(TAG, 'aboutToDisappear');
    this.isDestroyed = true;
    this.hasNavigated = true;
    emitter.off('tdlib_auth_state');
    emitter.off('tdlib_need_code');
    emitter.off('tdlib_error');
    this.lottieController.destroy();
  }

  private resetUiState(): void {
    this.isLoading = false;
    this.errorMessage = '';
    this.showErrorPopup = false;
  }

  private async initializeTdlib(): Promise<void> {
    // ⭐ TDLib 已在 EntryAbility 中初始化，此处无需重复
    logPageInfo(TAG, 'TDLib already initialized in EntryAbility');
  }

  /** 检查是否已经处于等待验证码状态（用于页面启动时直接跳转） */
  private async checkAlreadyWaitingState(): Promise<void> {
    if (this.hasNavigated || this.isDestroyed) {
      return;
    }
    try {
      const authState = await this.authService.getAuthorizationState();
      if (authState['@type'] === 'authorizationStateWaitCode') {
        logPageInfo(TAG, 'Already waiting for code, redirect');
        const currentPhone = await this.getCurrentAuthenticatingPhone();
        if (currentPhone) {
          this.currentPhoneNumber = currentPhone;
          this.lastSentPhoneNumber = currentPhone;
        }
        this.navigateToCodePage();
      }
    } catch (error) {
      logPageError(TAG, `Check waiting state failed: ${error}`);
    }
  }

  /** 获取当前正在认证的手机号（兜底使用用户输入） */
  private async getCurrentAuthenticatingPhone(): Promise<string | null> {
    return this.phoneNumber || null;
  }



  /** 跳转到验证码页 */
  private navigateToCodePage(): void {
    if (this.hasNavigated || this.isDestroyed) {
      return;
    }
    this.hasNavigated = true;
    this.isLoading = false;
    router.pushUrl({
      url: RoutePaths.AUTH_CODE_VERIFICATION,
      params: { phoneNumber: this.currentPhoneNumber || this.phoneNumber }
    }).catch((err: Error) => {
      logPageError(TAG, `Navigation failed: ${err.message}`);
      this.hasNavigated = false;
      this.errorMessage = '导航失败';
      this.showErrorPopup = true;
    });
  }

  /** 监听 TDLib 授权状态事件 */
  private setupAuthStateListener(): void {
    emitter.off('tdlib_auth_state');
    emitter.on('tdlib_auth_state', (payload: Record<string, Object>) => {
      if (this.isDestroyed || this.hasNavigated) {
        return;
      }
      const data = payload['data'] as Record<string, Object> | undefined;
      const state = data ? (data['state'] as string) : '';
      if (state === 'authorizationStateWaitCode') {
        // 记录正在认证的手机号
        if (this.currentPhoneNumber) {
          this.lastSentPhoneNumber = this.currentPhoneNumber;
        }
        logPageInfo(TAG, 'Received authorizationStateWaitCode, navigating');
        this.navigateToCodePage();
      }
    });

    emitter.off('tdlib_need_code');
    emitter.on('tdlib_need_code', () => {
      if (this.isDestroyed || this.hasNavigated) {
        return;
      }
      if (this.currentPhoneNumber) {
        this.lastSentPhoneNumber = this.currentPhoneNumber;
      }
      logPageInfo(TAG, 'Received need_code event, navigating');
      this.navigateToCodePage();
    });
  }

  /** 监听 TDLib 错误事件 */
  private setupTdlibErrorListener(): void {
    emitter.off('tdlib_error');
    emitter.on('tdlib_error', (payload: Record<string, Object>) => {
      if (this.isDestroyed) {
        return;
      }
      const data = payload['data'] as Record<string, Object> | undefined;
      if (!data) {
        return;
      }

      const code = data['code'] as number | undefined;
      const msg = typeof data['message'] === 'string' ? data['message'] : '';
      const silent = (getAuthErrorLocaleKey(code, msg) === AUTH_ERROR_SILENT);
      if (silent) {
        return;
      }

      const isPhoneError = code === 400 || msg.includes('PHONE') || msg.includes('phone');
      if (isPhoneError && this.isLoading) {
        this.isLoading = false;
        const displayMsg = getAuthErrorDisplayMessage(code, msg);
        this.errorMessage = displayMsg || '手机号无效';
        this.showErrorPopup = true;
      } else if (!isPhoneError) {
        const displayMsg = getAuthErrorDisplayMessage(code, msg);
        if (displayMsg) {
          promptAction.showToast({ message: displayMsg, duration: 3000 });
        }
      }
    });
  }

  // UI 辅助方法
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
    this.updatePhoneValid();
  }

  private onCountryCodeChange(_code: string): void {
    this.updatePhoneValid();
  }

  /** 处理“下一步”点击 - 严格遵循 Telegram 逻辑 */
  private async handleNext(): Promise<void> {
    if (this.isLoading) {
      return;
    }

    const fullNumber = this.buildFullPhoneNumber();
    if (!this.isFullNumberValid(fullNumber)) {
      this.errorMessage = '手机号格式不正确';
      this.showErrorPopup = true;
      return;
    }

    // ⭐ 检查 TDLib Worker 是否就绪（不再依赖 getClientId）
    if (!this.tdlibClient.checkWorkerReady()) {
      this.errorMessage = '服务尚未就绪，请稍后重试';
      this.showErrorPopup = true;
      return;
    }

    // 检查当前授权状态
    try {
      const authState = await this.authService.getAuthorizationState();
      const stateType = authState['@type'] as string;
          
      if (stateType === 'authorizationStateReady') {
        // ⭐ 关键修复：如果已经登录，不能调用 setAuthenticationPhoneNumber
        logPageInfo(TAG, `⚠️ Already logged in (state=${stateType}), cannot set phone number`);
        this.errorMessage = '当前已处于登录状态，如需更换账号请先退出登录';
        this.showErrorPopup = true;
        return;
      }
          
      if (stateType === 'authorizationStateWaitCode') {
        if (fullNumber === this.lastSentPhoneNumber) {
          // 手机号相同，直接跳转验证码页（符合 Telegram 行为）
          logPageInfo(TAG, 'Already waiting for code, same phone, navigating directly');
          this.currentPhoneNumber = fullNumber;
          this.navigateToCodePage();
          return;
        } else {
          // 手机号已变，按照 Telegram 逻辑：提示用户需要先重置
          logPageInfo(TAG, 'Phone number changed while waiting for code, show reset hint');
          this.errorMessage = '请先点击上方"更换手机号"后重试';
          this.showErrorPopup = true;
          return;
        }
      }
    } catch (e) {
      // 忽略检查错误，继续正常发送
    }

    // 正常发送流程（首次或已处于等待手机号状态）
    this.currentPhoneNumber = fullNumber;
    this.resetUiState();
    this.isLoading = true;

    try {
      const result = await this.authService.setAuthenticationPhoneNumber(fullNumber);
      if (this.isDestroyed) {
        return;
      }
      if (!result.success) {
        this.isLoading = false;
        if (result.errorMessage) {
          this.errorMessage = result.errorMessage;
          this.showErrorPopup = true;
        }
      }
      // 成功时等待事件跳转，事件中会记录 lastSentPhoneNumber
    } catch (error) {
      if (this.isDestroyed) {
        return;
      }
      this.isLoading = false;
      logPageError(TAG, `setAuthenticationPhoneNumber error: ${error}`);
      this.errorMessage = '网络异常，请检查后重试';
      this.showErrorPopup = true;
    }
  }

  private openExternalUrl(url: string): void {
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
    ctx.startAbility({
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: url
    }).catch(() => {
      promptAction.showToast({ message: $r('app.string.auth_cannot_open_link'), duration: 2000 });
    });
  }

  build() {
    Column() {
      ImmersiveContainer({
        mode: ImmersiveMode.COMPONENT_TOP,
        theme: ThemeMode.AUTO,
        excludeBottom: true
      }) {
        // ⭐ 关键修复：使用 Scroll 组件实现软键盘避让
        Scroll() {
          Column() {
            this.buildHeader();

            if (this.isLoading) {
              this.buildLoadingContent();
            } else {
              Column() {
                PhoneInputComponent({
                  phoneNumber: $phoneNumber,
                  countryCode: $countryCode,
                  placeholder: $r('app.string.enter_phone_placeholder'),
                  countryCodePlaceholder: $r('app.string.auth_country_code_placeholder'),
                  maxLength: 15,
                  onPhoneChange: (phone: string) => this.onPhoneChange(phone),
                  onCountryCodeChange: (code: string) => this.onCountryCodeChange(code)
                })
                  .margin({ top: AppSpacing.xl });

                Button($r('app.string.auth_next'))
                  .width(150)
                  .height(48)
                  .fontSize(AppFont.body2.fontSize)
                  .fontColor(Color.White)
                  .backgroundColor(this.isPhoneValid ? TELEGRAM_BLUE : AppColors.TELEGRAM_LIGHT_BLUE)
                  .borderRadius(AppRadius.radius)
                  .margin({ top: AppSpacing.xl })
                  .enabled(this.isPhoneValid && !this.isLoading)
                  .onClick(() => this.handleNext());
              }
              .width('100%')
              .padding(AppSpacing.lg)
              .constraintSize({ maxWidth: 400 });
            }

            this.buildFooter();
          }
          .width('100%')
          .justifyContent(FlexAlign.Start) // ⭐ 改为 Start，让 Scroll 控制滚动
          .alignItems(HorizontalAlign.Center)
          .backgroundColor(BACKGROUND);
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off) // ⭐ 隐藏滚动条
        .edgeEffect(EdgeEffect.None) // ⭐ 禁用边缘效果
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]); // ⭐ 扩展安全区域
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
    });
  }

  @Builder
  private buildHeader() {
    Column() {
      // Lottie 动画（使用 lottie-turbo）
      LottieView({
        lottieId: this.LOTTIE_CONFIG.lottieId,
        path: $rawfile('duck-phone.json'),
        autoplay: true,
        loop: true,
        autoSkip: false,
        useCache: true,
        contentMode: 'Contain',
        controller: this.lottieController
      })
        .width(160)
        .height(160)
        .margin({ top: AppSpacing.xxl * 2 });

      Text($r('app.string.auth_phone_hint'))
        .fontSize(AppFont.body2.fontSize)
        .fontColor(TEXT_SECONDARY)
        .margin({ top: AppSpacing.lg });
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  private buildLoadingContent() {
    Column() {
      Text($r('app.string.auth_sending'))
        .fontSize(AppFont.body2.fontSize)
        .fontColor(TEXT_SECONDARY);
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  private buildFooter() {
    Column() {
      Text($r('app.string.auth_agree_prefix'))
        .fontSize(AppFont.caption.fontSize)
        .fontColor(TEXT_TERTIARY);

      Row() {
        Text($r('app.string.auth_terms'))
          .fontSize(AppFont.caption.fontSize)
          .fontColor(TELEGRAM_BLUE)
          .onClick(() => this.openExternalUrl(TELEGRAM_TOS_URL));
        Text($r('app.string.auth_and'))
          .fontSize(AppFont.caption.fontSize)
          .fontColor(TEXT_TERTIARY);
        Text($r('app.string.auth_privacy'))
          .fontSize(AppFont.caption.fontSize)
          .fontColor(TELEGRAM_BLUE)
          .onClick(() => this.openExternalUrl(TELEGRAM_PRIVACY_URL));
      }
      .margin({ top: 4 });

      Text($r('app.string.auth_login_with_bot'))
        .fontSize(AppFont.caption.fontSize)
        .fontColor(TELEGRAM_BLUE)
        .margin({ top: AppSpacing.lg })
        .onClick(() => router.pushUrl({ url: RoutePaths.AUTH_BOT_TOKEN }));
    }
    .margin({ bottom: AppSpacing.lg });
  }
}
