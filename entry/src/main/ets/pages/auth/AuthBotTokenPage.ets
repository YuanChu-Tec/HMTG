/**
 * Bot Token 登录页面
 * 用于通过 @BotFather 获取的 Token 登录
 */
import { AuthService } from '../../services/core';
import { TdApiFactory } from '../../services/api/factory/TdApiFactory';
import { TDLibApi } from '../../services/api/TDLibApi';
import type { Ok } from '../../services/api/factory/tdlib-types';
import { LoadingIndicator } from '../../ui_kit/components/common/LoadingIndicator';
import { router, promptAction } from '@kit.ArkUI';
import { logPageInfo, logPageError } from '../../utils/log/LogService';
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

// 从主题获取常量
const AppSpacing = theme.spacing;
const AppFont = theme.typography;
const AppRadius = theme.borders;

const TAG = 'AuthBotTokenPage';

@Entry
@Component
export struct AuthBotTokenPage {
  @State private token: string = '';
  @State private isLoading: boolean = false;

  private authService = AuthService.getInstance();
  private tdApi: TDLibApi = TdApiFactory.getInstance().createDefault();

  async aboutToAppear(): Promise<void> {
    this.tdApi = TdApiFactory.getInstance().createDefault();
  }

  private async handleLogin(): Promise<void> {
    const trimmed = this.token.trim();
    if (!trimmed) {
      logPageInfo(TAG, 'handleLogin: token empty');
      promptAction.showToast({ message: '请输入 Bot Token', duration: 2000 });
      return;
    }
    logPageInfo(TAG, 'handleLogin: checkAuthenticationBotToken');
    this.isLoading = true;
    try {
      const result: Ok = await this.tdApi.checkAuthenticationBotToken(trimmed);
      const success = result['_'] === 'ok';
      logPageInfo(TAG, `handleLogin: result=${success}`);
      if (success) {
        promptAction.showToast({ message: '登录成功', duration: 2000 });
        router.replaceUrl({ url: RoutePaths.MAIN });
      } else {
        promptAction.showToast({ message: 'Token 无效或登录失败', duration: 2000 });
      }
    } catch (error) {
      logPageError(TAG, `handleLogin error: ${JSON.stringify(error)}`);
      promptAction.showToast({ message: '登录失败，请重试', duration: 2000 });
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
          Row() {
            Button() {
              Image($r('app.media.chevron_back'))
                .width(24)
                .height(24)
                .fillColor(TEXT_PRIMARY)
            }
            .backgroundColor(Color.Transparent)
            .onClick(() => router.back())

            Text('Bot Token 登录')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor(TEXT_PRIMARY)
              .layoutWeight(1)
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })

          if (this.isLoading) {
            this.buildLoadingContent()
          } else {
            Column() {
              Text('请输入从 @BotFather 获取的 Bot Token')
                .fontSize(AppFont.body2.fontSize)
                .fontColor(TEXT_SECONDARY)
                .margin({ top: AppSpacing.xl })

              TextInput({ text: this.token, placeholder: '123456789:ABCdefGHIjklMNOpqrsTUVwxyz' })
                .width('100%')
                .height(48)
                .fontSize(AppFont.body2.fontSize)
                .backgroundColor(BACKGROUND_SECONDARY)
                .borderRadius(AppRadius.radiusSmall)
                .margin({ top: AppSpacing.md })
                .onChange((value: string) => {
                  this.token = value;
                })

              Button('登录')
                .width('100%')
                .height(48)
                .fontSize(AppFont.body1.fontSize)
                .fontColor(Color.White)
                .backgroundColor(TELEGRAM_BLUE)
                .borderRadius(AppRadius.radius)
                .margin({ top: AppSpacing.xxl })
                .onClick(() => {
                  this.handleLogin();
                })
            }
            .width('100%')
            .layoutWeight(1)
            .padding({ left: AppSpacing.lg, right: AppSpacing.lg })
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor(BACKGROUND)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildLoadingContent() {
    Column() {
      LoadingIndicator({
        indicatorSize: 40,
        type: 'spinner'
      })
      Text('登录中...')
        .fontSize(AppFont.body2.fontSize)
        .fontColor(TEXT_SECONDARY)
        .margin({ top: AppSpacing.md })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
