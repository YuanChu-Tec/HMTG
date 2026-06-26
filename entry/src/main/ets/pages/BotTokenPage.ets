/**
 * Bot Token 登录页面
 * 用于通过 @BotFather 获取的 Token 登录
 */
import { AuthService } from '../services/core';
import { TdApiFactory } from '../services/core/api/factory/TdApiFactory';
import { TDLibApi } from '../services/core/api/TDLibApi';
import type { Ok, AuthorizationState } from '../services/core/api/factory/tdlib-types';
import { LoadingIndicator } from '../ui_kit/components/LoadingIndicator';
import { router, promptAction } from '@kit.ArkUI';
import { logPageInfo, logPageError } from '../utils/log/LogService';
import { RoutePaths } from '../utils/navigation/NavigationHelper';

// 硬编码颜色常量
const TEXT_PRIMARY = '#000000';
const TEXT_SECONDARY = '#6B7280';
const BACKGROUND = '#FFFFFF';
const BACKGROUND_SECONDARY = '#F5F5F5';
const TELEGRAM_BLUE = '#0088CC';

// 硬编码间距常量
const SPACING_SM = 8;
const SPACING_MD = 12;
const SPACING_LG = 16;
const SPACING_XL = 24;
const SPACING_XXL = 32;

// 硬编码字体大小
const FONT_SIZE_BODY1 = 16;
const FONT_SIZE_BODY2 = 14;
const FONT_SIZE_TITLE = 20;

// 硬编码圆角
const RADIUS_SMALL = 8;
const RADIUS = 12;

const TAG = 'AuthBotTokenPage';

@Entry({ routeName: 'AuthBotTokenPage' })
@ComponentV2
export struct AuthBotTokenPage {
  @Local private token: string = '';
  @Local private isLoading: boolean = false;

  // 安全区高度
  @Local topSafeHeight: number = 0;
  @Local bottomSafeHeight: number = 0;

  private authService = AuthService.getInstance();
  private tdApi: TDLibApi = TdApiFactory.getInstance().createDefault();

  async aboutToAppear(): Promise<void> {
    this.tdApi = TdApiFactory.getInstance().createDefault();

    // 安全区高度
    this.topSafeHeight = AppStorage.get<number>('topSafeHeight') ?? 0;
    this.bottomSafeHeight = AppStorage.get<number>('bottomSafeHeight') ?? 0;
  }

  private async handleLogin(): Promise<void> {
    const trimmed = this.token.trim();
    if (!trimmed) {
      logPageInfo(TAG, 'handleLogin: token empty');
      promptAction.showToast({ message: '请输入 Bot Token', duration: 2000 });
      return;
    }
    logPageInfo(TAG, 'handleLogin: importBotAuthorization');
    this.isLoading = true;
    try {
      const result: AuthorizationState = await this.tdApi.importBotAuthorization(trimmed);
      const resultType: string = result._;
      logPageInfo(TAG, `handleLogin: result type=${resultType}`);
      if (resultType === 'authorizationStateReady') {
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
      Column() {
        // 头部导航栏
        Row() {
          Button() {
            SymbolGlyph($r('sys.symbol.arrow_left'))
              .width(24)
              .height(24)
              .fontColor([TEXT_PRIMARY])
          }
          .backgroundColor(Color.Transparent)
          .onClick(() => router.back())

          Text('Bot Token 登录')
            .fontSize(FONT_SIZE_TITLE)
            .fontWeight(FontWeight.Medium)
            .fontColor(TEXT_PRIMARY)
            .layoutWeight(1)
        }
        .width('100%')
        .height(56)
        .padding({ left: SPACING_LG, right: SPACING_LG })

        if (this.isLoading) {
          this.buildLoadingContent()
        } else {
          Column() {
            Text('请输入从 @BotFather 获取的 Bot Token')
              .fontSize(FONT_SIZE_BODY2)
              .fontColor(TEXT_SECONDARY)
              .margin({ top: SPACING_XL })

            TextInput({ text: this.token, placeholder: '123456789:ABCdefGHIjklMNOpqrsTUVwxyz' })
              .width('100%')
              .height(48)
              .fontSize(FONT_SIZE_BODY2)
              .backgroundColor(BACKGROUND_SECONDARY)
              .borderRadius(RADIUS_SMALL)
              .margin({ top: SPACING_MD })
              .onChange((value: string) => {
                this.token = value;
              })

            Button('登录')
              .width('100%')
              .height(48)
              .fontSize(FONT_SIZE_BODY1)
              .fontColor(Color.White)
              .backgroundColor(TELEGRAM_BLUE)
              .borderRadius(RADIUS)
              .margin({ top: SPACING_XXL })
              .onClick(() => {
                this.handleLogin();
              })
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: SPACING_LG, right: SPACING_LG })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(BACKGROUND)
    }
    .width('100%')
    .height('100%')
    .padding({ top: this.topSafeHeight, bottom: this.bottomSafeHeight })
  }

  @Builder
  private buildLoadingContent() {
    Column() {
      LoadingIndicator({
        indicatorSize: 40,
        type: 'spinner'
      })
      Text('登录中...')
        .fontSize(FONT_SIZE_BODY2)
        .fontColor(TEXT_SECONDARY)
        .margin({ top: SPACING_MD })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
