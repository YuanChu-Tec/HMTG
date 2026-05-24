import { AuthService } from '../../services/core';
import { TdApiFactory } from '../../services/api/factory/TdApiFactory';
import { TDLibApi } from '../../services/api/TDLibApi';
import type { AuthorizationState, authorizationStateReady } from '../../services/api/factory/tdlib-types';
import { logPageInfo, logPageError } from '../../utils/log/LogService';
import { LottieController, LottieView } from '@ohos/lottie-turbo';
import { router, promptAction } from '@kit.ArkUI';
import { AuthState } from '../../models';
import { ThemeTokenFactory } from '../../ui_kit/themes/ThemeTokens';
import { RoutePaths } from '../../utils/navigation/NavigationHelper';
import { getString } from '../../utils/i18n/ResourceHelper';
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
const AppRadius = theme.borders;

interface AppColorsType {
  TELEGRAM_LIGHT_BLUE: string;
}

const AppColors: AppColorsType = {
  TELEGRAM_LIGHT_BLUE: theme.colors.telegramLightBlue
};


const TAG = 'AuthPasswordPage';

/** bindPopup onStateChange 回调参数类型（ArkTS 不允许对象字面量作类型声明） */
interface PopupStateEvent {
  isVisible: boolean;
}

/** Lottie 动画配置接口 */
interface LottieConfig {
  lottieId: string;
  url: string;
}

@Entry
@Component
export struct AuthPasswordPage {
  @State private isLoading: boolean = false;
  @State private password: string = '';
  @State private showPassword: boolean = false;
  @State private passwordHint: string = '您的账户启用了两步验证';
  @State private showRecoveryInput: boolean = false;
  @State private recoveryCode: string = '';
  @State private errorMessage: string = '';
  @State private showErrorPopup: boolean = false;
  // Lottie 动画配置 - 使用本地资源路径
  private readonly LOTTIE_CONFIG: LottieConfig = {
    lottieId: 'auth-password',
    url: 'resources/rawfile/duck-password-unlock.json'
  };

  private authService = AuthService.getInstance();
  private tdApi: TDLibApi = TdApiFactory.getInstance().createDefault();
  private lottieController: LottieController = new LottieController();

  async aboutToAppear(): Promise<void> {
    this.tdApi = TdApiFactory.getInstance().createDefault();

    try {
      const passwordState = await this.tdApi.getPasswordState();
      if (passwordState && passwordState['hint']) {
        const hint = passwordState['hint'] as string;
        if (hint && hint.length > 0) {
          this.passwordHint = hint;
          logPageInfo(TAG, `passwordHint set, len=${hint.length}`);
        }
      }
    } catch (error) {
      logPageError(TAG, `aboutToAppear getPasswordState: ${JSON.stringify(error)}`);
    }
  }

  onPageShow(): void {
    logPageInfo(TAG, 'onPageShow');
    // ⭐ 重新播放 Lottie 动画（页面返回时）
    this.lottieController.play();
  }

  private async handleVerifyPassword(): Promise<void> {
    if (!this.password) {
      logPageInfo(TAG, 'handleVerifyPassword: password empty');
      this.errorMessage = '请输入密码';
      this.showErrorPopup = true;
      return;
    }
    logPageInfo(TAG, 'handleVerifyPassword: checkAuthenticationPassword');
    this.isLoading = true;
    try {
      await this.tdApi.checkAuthenticationPassword(this.password);
      logPageInfo(TAG, `handleVerifyPassword: password verified`);
      const authState: AuthorizationState = await this.tdApi.getAuthorizationState();
      // ⭐ 兼容 @type 和 _ 两种字段格式
      const stateType = (authState['@type'] as string) || (authState['_'] as string);
      if (stateType === 'authorizationStateReady') {
        logPageInfo(TAG, '✅ navigate to MainTabContainer');
        router.replaceUrl({ url: RoutePaths.MAIN });
      } else {
        logPageInfo(TAG, `⚠️ Auth state is ${stateType}, not ready yet`);
      }
    } catch (error) {
      logPageError(TAG, `handleVerifyPassword error: ${JSON.stringify(error)}`);
      this.errorMessage = '密码错误，请重试';
      this.showErrorPopup = true;
      this.password = '';
    } finally {
      this.isLoading = false;
    }
  }

  private async handleForgotPassword(): Promise<void> {
    if (this.showRecoveryInput) {
      this.showRecoveryInput = false;
      this.recoveryCode = '';
      logPageInfo(TAG, 'handleForgotPassword: hide recovery input');
      return;
    }
    logPageInfo(TAG, 'handleForgotPassword: requestAuthenticationPasswordRecovery');
    try {
      const sent = await this.tdApi.requestAuthenticationPasswordRecovery();
      logPageInfo(TAG, `handleForgotPassword: sent=${sent}`);
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
      logPageInfo(TAG, 'handleRecoveryCodeSubmit: recoveryCode empty');
      promptAction.showToast({ message: $r('app.string.enter_recovery_code_placeholder'), duration: 2000 });
      return;
    }
    logPageInfo(TAG, 'handleRecoveryCodeSubmit: checkAuthenticationPasswordRecoveryCode');
    this.isLoading = true;
    try {
      const success = await this.tdApi.checkAuthenticationPasswordRecoveryCode(this.recoveryCode.trim());
      logPageInfo(TAG, `handleRecoveryCodeSubmit: result=${success}`);
      if (success) {
        const authState: AuthorizationState = await this.tdApi.getAuthorizationState();
        // ⭐ 兼容 @type 和 _ 两种字段格式
        const stateType = (authState['@type'] as string) || (authState['_'] as string);
        if (stateType === 'authorizationStateReady') {
          logPageInfo(TAG, '✅ navigate to MainTabContainer');
          router.replaceUrl({ url: RoutePaths.MAIN });
        } else {
          logPageInfo(TAG, `⚠️ Auth state is ${stateType}, not ready yet`);
        }
      } else {
        this.errorMessage = '恢复码无效';
        this.showErrorPopup = true;
      }
    } catch (error) {
      logPageError(TAG, `handleRecoveryCodeSubmit error: ${JSON.stringify(error)}`);
      this.errorMessage = '验证恢复码失败';
      this.showErrorPopup = true;
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      ImmersiveContainer({
        mode: ImmersiveMode.COMPONENT_TOP,
        theme: ThemeMode.AUTO,
        excludeBottom: true
      }) {
        Column() {
          this.buildHeader();

          if (this.isLoading) {
            this.buildLoadingContent()
          } else {
            Column() {
              // Lottie 动画（使用 lottie-turbo）
              LottieView({
                lottieId: this.LOTTIE_CONFIG.lottieId,
                path: $rawfile('duck-password-unlock.json'),
                autoplay: true,
                loop: true,
                autoSkip: false,
                useCache: true,
                contentMode: 'Contain',
                controller: this.lottieController
              })
                .width(160)
                .height(160)
                .margin({ top: AppSpacing.xxl });

              Text($r('app.string.enter_password_label'))
                .fontSize(AppFont.body1.fontSize)
                .fontColor(TEXT_PRIMARY)
                .margin({ top: 20 })

              Text(this.passwordHint)
                .fontSize(AppFont.caption.fontSize)
                .fontColor(TEXT_TERTIARY)
                .margin({ top: AppSpacing.sm })

              TextInput({
                placeholder: $r('app.string.enter_password_placeholder'),
                text: this.password
              })
                .type(this.showPassword ? InputType.Normal : InputType.Password)
                .fontSize(20)
                .fontColor(TEXT_PRIMARY)
                .placeholderColor(TEXT_TERTIARY)
                .width('100%')
                .height(56)
                .backgroundColor(BACKGROUND_SECONDARY)
                .borderRadius(AppRadius.radius)
                .padding({ left: AppSpacing.md, right: AppSpacing.md })
                .margin({ top: AppSpacing.lg })
                .onChange((value: string) => {
                  this.password = value;
                })
                .onSubmit(() => {
                  this.handleVerifyPassword();
                })

              Button($r('app.string.verify_button'))
                .width(150)
                .height(48)
                .fontSize(AppFont.body1.fontSize)
                .fontColor(Color.White)
                .backgroundColor(this.password.length > 0 ? TELEGRAM_BLUE : AppColors.TELEGRAM_LIGHT_BLUE)
                .borderRadius(AppRadius.radius)
                .margin({ top: 20 })
                .enabled(this.password.length > 0)
                .onClick(() => {
                  this.handleVerifyPassword();
                })

              // 忘记密码 / 恢复码输入
              if (this.showRecoveryInput) {
                Column() {
                  Text($r('app.string.enter_recovery_code_placeholder'))
                    .fontSize(AppFont.caption.fontSize)
                    .fontColor(TEXT_TERTIARY)
                    .margin({ top: AppSpacing.lg })
                  TextInput({ placeholder: $r('app.string.enter_recovery_code_placeholder'), text: this.recoveryCode })
                    .fontSize(AppFont.body1.fontSize)
                    .margin({ top: AppSpacing.sm })
                    .onChange((value: string) => {
                      this.recoveryCode = value;
                    })
                  Button($r('app.string.use_recovery_code_button'))
                    .fontSize(AppFont.caption.fontSize)
                    .fontColor(TELEGRAM_BLUE)
                    .backgroundColor(Color.Transparent)
                    .margin({ top: AppSpacing.sm })
                    .onClick(() => {
                      this.handleRecoveryCodeSubmit();
                    })
                  Text($r('app.string.cancel_button'))
                    .fontSize(AppFont.caption.fontSize)
                    .fontColor(TEXT_TERTIARY)
                    .margin({ top: AppSpacing.sm })
                    .onClick(() => {
                      this.showRecoveryInput = false;
                      this.recoveryCode = '';
                    })
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              } else {
                Text($r('app.string.forgot_password_label'))
                  .fontSize(AppFont.caption.fontSize)
                  .fontColor(TELEGRAM_BLUE)
                  .margin({ top: AppSpacing.lg })
                  .onClick(() => {
                    this.handleForgotPassword();
                  })
              }
            }
            .width('100%')
            .layoutWeight(1)
            .padding(AppSpacing.lg)
            .constraintSize({ maxWidth: 400 })
            .expandSafeArea([SafeAreaType.KEYBOARD], [SafeAreaEdge.BOTTOM]) // ⭐ 扩展安全区域，避让软键盘
          }
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(BACKGROUND)
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

  @Builder
  private buildHeader() {
    Row() {
      // 返回按钮
      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.chevron_back'))
          .width(24)
          .height(24)
          .fillColor(TEXT_SECONDARY)
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        router.back();
      })

      Text($r('app.string.two_factor_password_title'))
        .fontSize(AppFont.body1.fontSize)
        .fontWeight(FontWeight.Medium)
        .fontColor(TEXT_PRIMARY)
        .layoutWeight(1)
    }
    .width('100%')
    .height(56)
    .padding({ left: AppSpacing.sm, right: AppSpacing.md })
    .backgroundColor(BACKGROUND)
  }

  @Builder
  private buildLoadingContent() {
    Column() {
      // 验证密码时的加载状态
      Text($r('app.string.verifying_text'))
        .fontSize(AppFont.body2.fontSize)
        .fontColor(TEXT_SECONDARY)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

}
