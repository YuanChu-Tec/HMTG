/**
 * 欢迎页
 * 应用首次启动时的欢迎页面
 */


import { AppLogger } from '../../utils/log/LogService';
import { router } from '@kit.ArkUI';
import { NavigationHelper } from '../../utils/navigation/NavigationHelper';
import { RoutePaths } from '../../utils/navigation/NavigationHelper';
import { ThemeTokenFactory } from '../../ui_kit/themes/ThemeTokens';
import { ImmersiveContainer } from '../../components/common/ImmersiveContainer';
import { ImmersiveMode, ThemeMode } from '../../utils/utils/ImmersiveUtils';

// 获取浅色主题 Token
const theme = ThemeTokenFactory.createLightTokens();

// 从主题系统获取颜色
const TEXT_PRIMARY = theme.colors.text;
const TEXT_SECONDARY = theme.colors.textSecondary;
const TELEGRAM_BLUE = theme.colors.telegramBlue;
const BACKGROUND = theme.colors.background;
const SURFACE = theme.colors.surface;

const TAG = 'WelcomePage';
const DOMAIN = 0x0001;

@Entry({ routeName: 'WelcomePage' })
@ComponentV2
export struct WelcomePage {
  @Local private pageOpacity: number = 0;
  @Local private showButton: boolean = false;

  aboutToAppear(): void {
    AppLogger.logAuthEvent('WelcomePage', 'Welcome Page displayed');

    // 淡入动画
    setTimeout(() => {
      this.pageOpacity = 1;
    }, 100);

    // 显示按钮动画
    setTimeout(() => {
      this.showButton = true;
    }, 600);
  }

  /**
   * 开始使用
   */
  private async startMessaging(): Promise<void> {
    try {
      // 使用 NavigationHelper 替代 AuthRouter
      await NavigationHelper.navigateTo(RoutePaths.AUTH_PHONE_INPUT);
    } catch (error) {
      AppLogger.logError('WelcomePage', 'Start messaging failed', error as Error);
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
          // Logo和标题区域
          Column() {
            // HMTG Logo
            Image($r('app.media.startIcon'))
            .width(100)
            .height(100)
            .borderRadius(50)
            .backgroundColor(theme.colors.telegramLightBlue)
            .margin({ bottom: 24 })

            // 应用名称
            Text($r('app.string.welcome_app_name'))
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor(TELEGRAM_BLUE)
              .margin({ bottom: 8 })

            // 副标题
            Text($r('app.string.welcome_subtitle'))
              .fontSize(theme.typography.body1.fontSize)
              .fontColor(TEXT_SECONDARY)
              .margin({ bottom: 16 })

            // 介绍文本
            Text($r('app.string.welcome_description'))
              .fontSize(theme.typography.caption.fontSize)
              .fontColor(TEXT_SECONDARY)
              .textAlign(TextAlign.Center)
              .margin({ left: 40, right: 40 })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)

          // 功能特点
          Column() {
            this.buildFeatureItem($r('app.string.feature_speed'), $r('app.string.feature_speed_desc'));
            this.buildFeatureItem($r('app.string.feature_encryption'), $r('app.string.feature_encryption_desc'));
            this.buildFeatureItem($r('app.string.feature_files'), $r('app.string.feature_files_desc'));
          }
          .margin({ bottom: 40 })

            // 开始按钮
            if (this.showButton) {
              Button($r('app.string.start_messaging'))
                .fontSize(theme.typography.body1.fontSize)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.White)
                .backgroundColor(TELEGRAM_BLUE)
                .borderRadius(theme.borders.radiusLarge)
                .width('80%')
                .height(50)
                .onClick(() => {
                  this.startMessaging();
                })
                .shadow({
                  radius: 8,
                  color: 'rgba(51, 144, 240, 0.3)',
                  offsetY: 4
                })
            }
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 60, bottom: 40 })
        .opacity(this.pageOpacity)
        .animation({
          duration: 500,
          curve: Curve.EaseInOut
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BACKGROUND)
  }

  /**
   * 构建功能项
   */
  @Builder
  private buildFeatureItem(title: ResourceStr, description: ResourceStr): void {
    Row() {
      Column() {
        Text(title)
          .fontSize(theme.typography.body1.fontSize)
          .fontWeight(FontWeight.Medium)
          .fontColor(TEXT_PRIMARY)
          .margin({ bottom: 4 })

        Text(description)
          .fontSize(theme.typography.caption.fontSize)
          .fontColor(TEXT_SECONDARY)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('80%')
    .padding(theme.spacing.md)
    .margin({ bottom: theme.spacing.sm })
    .backgroundColor(SURFACE)
    .borderRadius(theme.borders.radiusSmall)
  }
}
