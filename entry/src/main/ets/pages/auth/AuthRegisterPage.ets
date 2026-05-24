

/*
 * AuthRegisterPage.ets
 * 用户注册页面
 */
import { DataValidator } from '../../utils/validation/DataValidator';
import { logPageInfo, logPageError, AppLogger } from '../../utils/log';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { router, promptAction } from '@kit.ArkUI';
import { AuthService } from '../../services/core';
import { TdApiFactory } from '../../services/api/factory/TdApiFactory';
import { TDLibApi } from '../../services/api/TDLibApi';
import type { AuthorizationState } from '../../services/api/factory/tdlib-types';
import type { SetPhoneNumberResult } from '../../models';
import { getAuthErrorDisplayMessage } from '../../utils/AuthErrorHelper';
import { PhoneInputComponent } from '../../components/auth';
import { LoadingIndicator } from '../../ui_kit/components/common';
import { common } from '@kit.AbilityKit';
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

// Telegram URL 常量
const TELEGRAM_TOS_URL = 'https://telegram.org/tos';
const TELEGRAM_PRIVACY_URL = 'https://telegram.org/privacy';

// TAG for logging
const TAG = 'AuthRegisterPage';

@Entry
@Component
export struct AuthRegisterPage {
  @State phoneNumber: string = '';
  @State countryCode: string = '+86';
  @State firstName: string = '';
  @State lastName: string = '';
  @State isLoading: boolean = false;
  @State isPhoneNumberValid: boolean = false;

  private authService = AuthService.getInstance();
  private tdApi: TDLibApi = TdApiFactory.getInstance().createDefault();

  async aboutToAppear(): Promise<void> {
    this.tdApi = TdApiFactory.getInstance().createDefault();
    logPageInfo(TAG, 'aboutToAppear');
    this.checkAuthState();
  }

  build() {
    Column() {
      ImmersiveContainer({
        mode: ImmersiveMode.COMPONENT_TOP,
        theme: ThemeMode.AUTO
      }) {
        Stack() {
          Column() {
            // 背景装饰
            this.buildBackground()

            // 主内容区
            Column() {
              // 标题
              this.buildTitle()

              // 手机号（必须在 build 内以便 $phoneNumber 生效）
              Column() {
                Text($r('app.string.phone_number_label'))
                  .fontSize(theme.typography.body1.fontSize)
                  .fontColor(TEXT_SECONDARY)
                  .margin({ bottom: theme.spacing.sm })
                  .alignSelf(ItemAlign.Start)
                PhoneInputComponent({
                  phoneNumber: $phoneNumber,
                  countryCode: $countryCode,
                  placeholder: $r('app.string.enter_phone_placeholder'),
                  countryCodePlaceholder: $r('app.string.auth_country_code_placeholder'),
                  maxLength: 15,
                  onPhoneChange: (phone: string) => this.updatePhoneValid(),
                  onCountryCodeChange: (_code: string) => this.updatePhoneValid()
                })
              }
              .width('100%')

              // 表单（姓名等）
              this.buildForm()

              // 注册按钮
              this.buildRegisterButton()

              // 登录链接
              this.buildLoginLink()
            }
            .width('100%')
            .padding({ left: 32, right: 32 })
          }
          .width('100%')
          .height('100%')

          // 加载指示器
          if (this.isLoading) {
            this.buildLoadingContent()
          }
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BACKGROUND)
  }

  @Builder
  private buildBackground(): void {
    Column()
      .width('100%')
      .height(280)
      .linearGradient({
        angle: 180,
        colors: [[TELEGRAM_BLUE, 0.0], [theme.colors.telegramDarkBlue, 1.0]]
      })
  }

  @Builder
  private buildLoadingContent() {
    Column() {
      LoadingIndicator({
        indicatorSize: 40,
        type: 'spinner'
      })
      Text($r('app.string.loading_text'))
        .fontSize(theme.typography.body1.fontSize)
        .fontColor(TEXT_SECONDARY)
        .margin({ top: theme.spacing.md })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildTitle(): void {
    Column() {
      Text($r('app.string.create_profile_title'))
        .fontSize(theme.typography.h2.fontSize)
        .fontWeight(FontWeight.Bold)
        .fontColor(TEXT_PRIMARY)
        .margin({ bottom: theme.spacing.sm })

      Text($r('app.string.fill_info_hint'))
        .fontSize(theme.typography.body1.fontSize)
        .fontColor(theme.colors.textTertiary)
    }
    .width('100%')
    .margin({ top: 40, bottom: 40 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildForm(): void {
    Column({ space: 20 }) {
      // 姓名输入
      Column() {
        Text($r('app.string.name_label'))
          .fontSize(theme.typography.body1.fontSize)
          .fontColor(TEXT_SECONDARY)
          .margin({ bottom: theme.spacing.sm })
          .alignSelf(ItemAlign.Start)

        Row({ space: 12 }) {
          // 姓
          TextInput({ placeholder: $r('app.string.last_name_placeholder') })
            .width('35%')
            .height(50)
            .padding({ left: theme.spacing.lg })
            .fontSize(theme.typography.body1.fontSize)
            .backgroundColor(BACKGROUND_SECONDARY)
            .borderRadius(theme.borders.radiusSmall)
            .onChange((value: string) => {
              this.lastName = value;
            })

          // 名
          TextInput({ placeholder: $r('app.string.first_name_placeholder') })
            .layoutWeight(1)
            .height(50)
            .padding({ left: theme.spacing.lg })
            .fontSize(theme.typography.body1.fontSize)
            .backgroundColor(BACKGROUND_SECONDARY)
            .borderRadius(theme.borders.radiusSmall)
            .onChange((value: string) => {
              this.firstName = value;
            })
        }
        .width('100%')
      }
      .width('100%')

      // 服务条款提示
      Column({ space: 8 }) {
        Row({ space: 4 }) {
          Text($r('app.string.agree_to_terms'))
            .fontSize(theme.typography.body1.fontSize)
            .fontColor(theme.colors.textTertiary)

          Text($r('app.string.terms_of_service'))
            .fontSize(theme.typography.body1.fontSize)
            .fontColor(TELEGRAM_BLUE)
            .onClick(() => this.openExternalUrl(TELEGRAM_TOS_URL))
        }
        
        Row({ space: 4 }) {
          Text($r('app.string.and'))
            .fontSize(theme.typography.body1.fontSize)
            .fontColor(theme.colors.textTertiary)

          Text($r('app.string.privacy_policy'))
            .fontSize(theme.typography.body1.fontSize)
            .fontColor(TELEGRAM_BLUE)
            .onClick(() => this.openExternalUrl(TELEGRAM_PRIVACY_URL))
        }
        
        // ⭐ 新增：显示简要说明
        Text($r('app.string.terms_summary'))
          .fontSize(theme.typography.caption.fontSize)
          .fontColor(theme.colors.textTertiary)
          .margin({ top: 4 })
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
  }

  @Builder
  private buildRegisterButton(): void {
    Button($r('app.string.continue_button'))
      .width('100%')
      .height(50)
      .fontSize(theme.typography.body1.fontSize)
      .fontWeight(FontWeight.Medium)
      .fontColor(Color.White)
      .backgroundColor(this.isPhoneNumberValid &&
                        this.firstName.length > 0 &&
                        this.lastName.length > 0
        ? TELEGRAM_BLUE
        : '#cccccc')
      .borderRadius(theme.borders.radiusSmall)
      .margin({ top: 32, bottom: 16 })
      .enabled(this.isPhoneNumberValid &&
               this.firstName.length > 0 &&
               this.lastName.length > 0)
      .onClick(() => {
        this.handleRegister();
      })
  }

  @Builder
  private buildLoginLink(): void {
    Row() {
      Text($r('app.string.have_account'))
        .fontSize(theme.typography.body1.fontSize)
        .fontColor(theme.colors.textTertiary)

      Text($r('app.string.login_button'))
        .fontSize(theme.typography.body1.fontSize)
        .fontColor(TELEGRAM_BLUE)
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({ top: 16, bottom: 32 })
  }

  private updatePhoneValid(): void {
    const full = this.buildFullPhoneNumber();
    // 使用 validatePhone 方法，传入国家码进行国际手机号验证
    const numericCode = this.countryCode.replace(/\D/g, '');
    this.isPhoneNumberValid = DataValidator.validatePhone(full, numericCode);
  }

  /**
   * 拼接并规范化完整国际号码（E.164：+国家码+本地号，去空格；区号缺 + 时自动补上）
   */
  private buildFullPhoneNumber(): string {
    let code = this.countryCode.replace(/\s/g, '');
    if (code.length > 0 && code.charAt(0) !== '+') {
      code = '+' + code;
    }
    return code + this.phoneNumber.trim();
  }

  /**
   * 处理注册
   */
  private async handleRegister(): Promise<void> {
    const fullNumber = this.buildFullPhoneNumber();
    logPageInfo(TAG, `handleRegister: countryCode=${this.countryCode} local=${this.phoneNumber} fullNumber=${fullNumber} fullLen=${fullNumber.length}`);

    if (!DataValidator.validatePhone(fullNumber, this.countryCode.replace(/\D/g, ''))) {
      logPageInfo(TAG, 'handleRegister: full number invalid (international check)');
      promptAction.showToast({ message: $r('app.string.AuthErrorInvalidPhone') });
      return;
    }
    if (this.firstName.length === 0 || this.lastName.length === 0) {
      logPageInfo(TAG, 'handleRegister: name empty');
      promptAction.showToast({ message: $r('app.string.AuthErrorEmptyName') });
      return;
    }
    logPageInfo(TAG, `handleRegister: sendPhoneNumber fullNumber=${fullNumber}`);
    this.isLoading = true;
    try {
      const result: SetPhoneNumberResult = await this.authService.setAuthenticationPhoneNumber(fullNumber);
      logPageInfo(TAG, `handleRegister: sendPhoneNumber result.success=${result.success}`);
      if (result.success) {
        logPageInfo(TAG, 'handleRegister: pushUrl AuthCodePage');
        router.pushUrl({
          url: RoutePaths.AUTH_CODE_VERIFICATION,
          params: {
            phoneNumber: fullNumber,
            firstName: this.firstName,
            lastName: this.lastName,
            isRegistration: true
          }
        });
      } else {
        const displayMsg = getAuthErrorDisplayMessage(result.errorCode, result.errorMessage);
        promptAction.showToast({
          message: displayMsg.length > 0 ? displayMsg : $r('app.string.AuthErrorSendFailed'),
          duration: 3000
        });
      }
    } catch (error) {
      logPageError(TAG, `handleRegister error: ${JSON.stringify(error)}`);
      promptAction.showToast({
        message: $r('app.string.AuthRegisterFailed')
      });
    } finally {
      this.isLoading = false;
    }
  }

  private openExternalUrl(url: string): void {
    const ctx = getContext(this) as common.UIAbilityContext;
    ctx.startAbility({
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: url
    }).catch((err: Error) => {
      console.error('打开链接失败:', err);
      promptAction.showToast({ message: $r('app.string.AuthCannotOpenLink'), duration: 2000 });
    });
  }

  private async checkAuthState(): Promise<void> {
    logPageInfo(TAG, 'checkAuthState start');
    try {
      // 直接获取当前授权状态，不等待
      const authState: AuthorizationState = await this.authService.getAuthorizationState();
      if (authState['_'] === 'authorizationStateReady') {
        logPageInfo(TAG, 'checkAuthState: replaceUrl MainTabContainer');
        router.replaceUrl({
          url: RoutePaths.MAIN
        });
      }
    } catch (error) {
      logPageError(TAG, `checkAuthState error: ${JSON.stringify(error)}`);
    }
  }
}
