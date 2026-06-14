/**
 * 欢迎页
 * 应用首次启动时的欢迎页面
 */

import { AppLogger } from '../utils/log/LogService';
import { router } from '@kit.ArkUI';
import { NavigationHelper } from '../utils/navigation/NavigationHelper';
import { RoutePaths } from '../utils/navigation/NavigationHelper';

// 硬编码颜色常量
const TEXT_PRIMARY = '#000000';
const TEXT_SECONDARY = '#6B7280';
const TELEGRAM_BLUE = '#0088CC';
const TELEGRAM_LIGHT_BLUE = '#71AFE5';
const BACKGROUND = '#FFFFFF';
const SURFACE = '#F5F5F5';

// 硬编码间距常量
const SPACING_SM = 8;
const SPACING_MD = 12;
const SPACING_LG = 16;
const SPACING_XL = 24;
const SPACING_XXL = 32;

// 硬编码字体大小
const FONT_SIZE_BODY1 = 16;
const FONT_SIZE_BODY2 = 14;
const FONT_SIZE_CAPTION = 12;
const FONT_SIZE_H1 = 32;

// 硬编码圆角
const RADIUS_SMALL = 8;
const RADIUS_LARGE = 16;

const TAG = 'WelcomePage';
const DOMAIN = 0x0001;

@Entry({ routeName: 'WelcomePage' })
@ComponentV2
export struct WelcomePage {
  @Local private pageOpacity: number = 0;
  @Local private showButton: boolean = false;

  // 安全区高度
  @Local topSafeHeight: number = 0;
  @Local bottomSafeHeight: number = 0;

  aboutToAppear(): void {
    AppLogger.logAuthEvent('WelcomePage', 'Welcome Page displayed');

    // 安全区高度 - 读取初始值
    this.topSafeHeight = AppStorage.get<number>('topSafeHeight') ?? 0;
    this.bottomSafeHeight = AppStorage.get<number>('bottomSafeHeight') ?? 0;

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
      // 使用 NavigationHelper 导航到新的整合登录页面
      await NavigationHelper.navigateTo(RoutePaths.AUTH_LOGIN);
    } catch (error) {
      AppLogger.logError('WelcomePage', 'Start messaging failed', error as Error);
    }
  }

  build() {
    Column() {
      // Logo和标题区域
      Column() {
        // HMTG Logo
        Image($r('app.media.startIcon'))
          .width(100)
          .height(100)
          .borderRadius(50)
          .backgroundColor(TELEGRAM_LIGHT_BLUE)
          .margin({ bottom: SPACING_XL })

        // 应用名称
        Text($r('app.string.welcome_app_name'))
          .fontSize(FONT_SIZE_H1)
          .fontWeight(FontWeight.Bold)
          .fontColor(TELEGRAM_BLUE)
          .margin({ bottom: SPACING_SM })

        // 副标题
        Text($r('app.string.welcome_subtitle'))
          .fontSize(FONT_SIZE_BODY1)
          .fontColor(TEXT_SECONDARY)
          .margin({ bottom: SPACING_LG })

        // 介绍文本
        Text($r('app.string.welcome_description'))
          .fontSize(FONT_SIZE_CAPTION)
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
          .fontSize(FONT_SIZE_BODY1)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .backgroundColor(TELEGRAM_BLUE)
          .borderRadius(RADIUS_LARGE)
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
      } else {
        // 占位，保持布局稳定
        Column()
          .width('80%')
          .height(50)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BACKGROUND)
    .opacity(this.pageOpacity)
    .animation({
      duration: 500,
      curve: Curve.EaseInOut
    })
    // 安全区适配
    .padding({ top: this.topSafeHeight, bottom: this.bottomSafeHeight })
  }

  /**
   * 构建功能项
   */
  @Builder
  private buildFeatureItem(title: ResourceStr, description: ResourceStr): void {
    Row() {
      Column() {
        Text(title)
          .fontSize(FONT_SIZE_BODY1)
          .fontWeight(FontWeight.Medium)
          .fontColor(TEXT_PRIMARY)
          .margin({ bottom: 4 })

        Text(description)
          .fontSize(FONT_SIZE_CAPTION)
          .fontColor(TEXT_SECONDARY)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('80%')
    .padding(SPACING_MD)
    .margin({ bottom: SPACING_SM })
    .backgroundColor(SURFACE)
    .borderRadius(RADIUS_SMALL)
  }
}
