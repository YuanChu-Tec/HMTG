import { router, promptAction } from '@kit.ArkUI';
import { TdApiFactory } from '../../services/api/factory/TdApiFactory';
import { TDLibApi } from '../../services/api/TDLibApi';
import type { AuthorizationState } from '../../services/api/factory/tdlib-types';
import { LoadingIndicator } from '../../ui_kit/components/common';
import { logPageInfo, logPageError } from '../../utils/log';
import { ThemeTokenFactory } from '../../ui_kit/themes/ThemeTokens';
import { RoutePaths } from '../../utils/navigation/NavigationHelper';
import { ImmersiveContainer } from '../../components/common/ImmersiveContainer';
import { ImmersiveMode, ThemeMode } from '../../utils/utils/ImmersiveUtils';

// 获取浅色主题 Token
const theme = ThemeTokenFactory.createLightTokens();

// 从主题系统获取颜色
const TEXT_PRIMARY = theme.colors.text;
const TEXT_SECONDARY = theme.colors.textSecondary;
const TEXT_TERTIARY = theme.colors.textTertiary;
const TELEGRAM_BLUE = theme.colors.telegramBlue;
const TELEGRAM_LIGHT_BLUE = theme.colors.telegramLightBlue;
const SUCCESS_GREEN = '#00C853';
const BACKGROUND_WHITE = '#FFFFFF';
const BORDER_GRAY = '#E0E0E0';

const TAG = 'AuthQrCodePage';

/** 二维码认证 URL 信息接口 */
interface QrCodeAuthenticationUrlInfo {
  _: 'qrCodeAuthenticationUrlInfo';
  token?: string;
  expires_in?: number;
}

/** 二维码请求参数中的隐私规则类型（满足 arkts-no-untyped-obj-literals） */
interface UserPrivacySettingRulesPayload {
  '@type': string;
}

/**
 * 二维码登录页面
 * 用于生成二维码供其他设备扫描登录
 */
@Entry
@Component
export struct AuthQrCodePage {
  @State qrCodeUrl: string = '';
  @State isLoading: boolean = true;
  @State loginToken: string = '';
  @State isScanning: boolean = false;

  private tdApi: TDLibApi = TdApiFactory.getInstance().createDefault();
  private timerId: number = -1;

  async aboutToAppear(): Promise<void> {
    logPageInfo(TAG, 'aboutToAppear');
    this.tdApi = TdApiFactory.getInstance().createDefault();
    await this.requestQrCode();
  }

  aboutToDisappear(): void {
    logPageInfo(TAG, 'aboutToDisappear');
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private async requestQrCode(): Promise<void> {
    logPageInfo(TAG, 'requestQrCode start');
    try {
      const otherUserIds: number[] = [];
      const result = await this.tdApi.requestQrCodeAuthentication(otherUserIds);
      if (result['_'] === 'qrCodeAuthenticationUrlInfo') {
        const token: string = result['token'] as string || '';
        const expiresIn: number = result['expires_in'] as number || 0;
        this.loginToken = token;
        this.qrCodeUrl = `tg://login?token=${encodeURIComponent(token)}&expires_in=${expiresIn}`;
        this.isLoading = false;
        this.startMonitoring();
      }
    } catch (error) {
      logPageError(TAG, `requestQrCode error: ${JSON.stringify(error)}`);
      promptAction.showToast({ message: $r('app.string.auth_op_failed') });
    }
  }

  private startMonitoring(): void {
    this.timerId = setInterval(async () => {
      await this.checkLoginStatus();
    }, 2000);
  }

  private async checkLoginStatus(): Promise<void> {
    try {
      const result = await this.tdApi.getCurrentState();
      // getCurrentState 返回 Record<string, Object>，需要从中提取 authorizationState
      if (result && result['_'] === 'authorizationStateReady') {
        const updateList = result['updates'] as Array<Record<string, Object>> | undefined;
        if (updateList) {
          for (const update of updateList) {
            if (update['_'] === 'updateAuthorizationState') {
              const authState = update['authorization_state'] as Record<string, Object>;
              if (authState && authState['_'] === 'authorizationStateReady') {
                logPageInfo(TAG, 'checkLoginStatus: ready, navigate to MainTabContainer');
                clearInterval(this.timerId);
                this.isScanning = true;
                setTimeout(() => {
                  router.replaceUrl({ url: RoutePaths.MAIN });
                }, 1000);
                return;
              }
            }
          }
        }
      }
    } catch (error) {
      logPageError(TAG, `checkLoginStatus error: ${JSON.stringify(error)}`);
    }
  }

  private handleCancel(): void {
    router.back();
  }

  build() {
    Column() {
      ImmersiveContainer({
        mode: ImmersiveMode.COMPONENT_TOP,
        theme: ThemeMode.AUTO
      }) {
        Column() {
          // 顶部导航
          Row() {
            Button() {
              Image($r('app.media.chevron_back'))
                .width(24)
                .height(24)
                .fillColor(TEXT_PRIMARY)
            }
            .type(ButtonType.Normal)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.handleCancel();
            })

            Text($r('app.string.qr_login_title'))
              .fontSize(theme.typography.body1.fontSize)
              .fontColor(TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)

            Text(' ')
              .width(24)
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })

          // 主内容区
          Scroll() {
            Column() {
              if (this.isLoading) {
                this.buildLoadingContent()
              } else if (this.isScanning) {
                Column() {
                  Image($r('app.media.startIcon'))
                    .width(80)
                    .height(80)
                    .fillColor(SUCCESS_GREEN)

                  Text($r('app.string.login_success'))
                    .fontSize(theme.typography.h3.fontSize)
                    .fontColor(TEXT_PRIMARY)
                    .fontWeight(FontWeight.Medium)
                    .margin({ top: 24 })

                  Text($r('app.string.jumping_text'))
                    .fontSize(theme.typography.body2.fontSize)
                    .fontColor(TEXT_TERTIARY)
                    .margin({ top: 8 })
                }
                .width('100%')
                .padding({ top: 80 })
              } else {
                Column() {
                  // 说明文字
                  Text($r('app.string.scan_qr_hint'))
                    .fontSize(theme.typography.body1.fontSize)
                    .fontColor(TEXT_PRIMARY)
                    .textAlign(TextAlign.Center)
                    .margin({ top: 40 })

                  Text($r('app.string.open_telegram_hint'))
                    .fontSize(theme.typography.body2.fontSize)
                    .fontColor(TEXT_TERTIARY)
                    .textAlign(TextAlign.Center)
                    .margin({ top: 12 })

                  // 二维码区域
                  Column() {
                    // 二维码显示（这里简化为占位符，实际需要使用二维码生成库）
                    Column() {
                      Text('QR')
                        .fontSize(theme.typography.h1.fontSize)
                        .fontColor(TEXT_PRIMARY)
                        .fontWeight(FontWeight.Bold)
                      
                      Text('CODE')
                        .fontSize(theme.typography.caption.fontSize)
                        .fontColor(TEXT_SECONDARY)
                        .margin({ top: 8 })
                    }
                    .width(200)
                    .height(200)
                    .backgroundColor(BACKGROUND_WHITE)
                    .borderRadius(theme.borders.radiusLarge)
                    .border({ width: 2, color: BORDER_GRAY })
                    .justifyContent(FlexAlign.Center)
                  }
                  .margin({ top: 48 })

                  // 分享功能
                  Button($r('app.string.share_login_link'))
                    .fontSize(theme.typography.body1.fontSize)
                    .fontColor(TELEGRAM_BLUE)
                    .backgroundColor(TELEGRAM_LIGHT_BLUE)
                    .borderRadius(theme.borders.radiusSmall)
                    .padding({ left: 24, right: 24, top: 12, bottom: 12 })
                    .margin({ top: 32 })
                    .onClick(() => {
                      // 分享登录链接
                      promptAction.showToast({ message: $r('app.string.share_login_link') });
                    })

                  // 提示信息
                  Column() {
                    Text('提示：')
                      .fontSize(14)
                      .fontColor('#666666')
                      .fontWeight(FontWeight.Medium)
                    
                    Text($r('app.string.qrcode_expire_hint'))
                      .fontSize(12)
                      .fontColor('#999999')
                      .margin({ top: 4 })
                  }
                  .width('100%')
                  .alignItems(HorizontalAlign.Start)
                  .margin({ top: 32 })
                }
                .width('100%')
                .padding({ left: 32, right: 32 })
              }
            }
            .width('100%')
          }
          .layoutWeight(1)

          // 底部按钮
          Row() {
            Button($r('app.string.cancel_button'))
              .fontSize(16)
              .fontColor('#FF5252')
              .backgroundColor(Color.Transparent)
              .layoutWeight(1)
              .onClick(() => {
                this.handleCancel();
              })
          }
          .width('100%')
          .padding({ left: 24, right: 24, bottom: 24 })
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  private buildLoadingContent() {
    Column() {
      LoadingIndicator({
        indicatorSize: 40,
        type: 'spinner'
      })
      Text($r('app.string.loading_text'))
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
