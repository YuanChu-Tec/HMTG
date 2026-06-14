/**
 * 二维码登录页面
 * 参考 Nagram LoginActivity.regenerateLoginToken 实现
 * 
 * 流程：
 * 1. 调用 requestQrCodeAuthentication 获取登录token
 * 2. TDLib 返回 authorizationStateWaitOtherDeviceConfirmation
 * 3. 从状态中获取 link 字段（tg://login?token=xxx）
 * 4. 使用鸿蒙原生 QRCode 组件显示二维码
 * 5. 监听状态变化，等待 authorizationStateReady
 */

import { router } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { AuthService } from '../services/core';
import { TdApiFactory, TDLibApi } from '../services/api';
import type { AuthorizationState, authorizationStateWaitOtherDeviceConfirmation } from '../services/api/factory/tdlib-types';
import { getString } from '../utils/i18n/ResourceHelper';
import { logPageInfo, logPageError } from '../utils/log/LogService';
import { RoutePaths } from '../utils/navigation/NavigationHelper';

/** 认证状态事件数据接口 */
interface AuthStateEventData {
  state: string;
  authState: Record<string, Object>;
}

// 颜色常量
const COLOR_TEXT_PRIMARY = '#000000';
const COLOR_TEXT_SECONDARY = '#6B7280';
const COLOR_TEXT_TERTIARY = '#9CA3AF';
const COLOR_BACKGROUND = '#FFFFFF';
const COLOR_TELEGRAM_BLUE = '#0088CC';
const COLOR_DIVIDER = '#E5E7EB';
const COLOR_QR_BG = '#FFFFFF';
const COLOR_QR_COLOR = '#000000';

// 间距常量
const SPACING_XS = 4;
const SPACING_SM = 8;
const SPACING_MD = 12;
const SPACING_LG = 16;
const SPACING_XL = 24;
const SPACING_XXL = 32;

// 圆角常量
const RADIUS_LG = 12;
const RADIUS_XL = 20;

// 字体大小
const FONT_SIZE_H3 = 20;
const FONT_SIZE_TITLE = 18;
const FONT_SIZE_BODY1 = 16;
const FONT_SIZE_BODY2 = 14;
const FONT_SIZE_BODY3 = 12;

const QR_CODE_SIZE = 280;

const TAG = 'AuthQrCodePage';

@Entry({ routeName: 'AuthQrCodePage' })
@ComponentV2
export struct AuthQrCodePage {
  @Local topSafeHeight: number = 0;
  @Local bottomSafeHeight: number = 0;
  @Local pageOpacity: number = 0;
  @Local qrCodeUrl: string = '';
  @Local isLoading: boolean = true;
  @Local isRefreshing: boolean = false;
  @Local errorMessage: string = '';
  
  private hasNavigated: boolean = false;
  private authService = AuthService.getInstance();
  private tdLibApi: TDLibApi | null = null;
  private refreshTimer: number = 0;
  private savedLink: string = '';

  async aboutToAppear(): Promise<void> {
    logPageInfo(TAG, 'aboutToAppear');
    this.hasNavigated = false;
    
    // 安全区高度
    this.topSafeHeight = AppStorage.get<number>('topSafeHeight') ?? 0;
    this.bottomSafeHeight = AppStorage.get<number>('bottomSafeHeight') ?? 0;
    
    // 淡入动画
    setTimeout(() => {
      this.pageOpacity = 1;
    }, 100);
    
    // 初始化 TDLibApi
    const factory = TdApiFactory.getInstance();
    this.tdLibApi = factory.createDefault();
    
    // 设置监听器（被动接收 updateAuthorizationState 更新）
    this.setupAuthStateListener();
    
    // 检查当前状态，决定是否需要发起请求
    await this.checkAndStartQrCodeAuth();
  }

  aboutToDisappear(): void {
    logPageInfo(TAG, 'aboutToDisappear');
    this.hasNavigated = true;
    emitter.off('tdlib_auth_state');
    
    // 清理定时器
    if (this.refreshTimer) {
      clearTimeout(this.refreshTimer);
      this.refreshTimer = 0;
    }
  }

  private setupAuthStateListener(): void {
    emitter.off('tdlib_auth_state');
    emitter.on('tdlib_auth_state', (event: Record<string, Object>) => {
      if (this.hasNavigated) {
        return;
      }
      
      const eventData = event['data'];
      if (!eventData || typeof eventData !== 'object') {
        return;
      }
      
      const dataRecord = eventData as Record<string, Object>;
      const stateValue = dataRecord['state'];
      const authStateValue = dataRecord['authState'];
      
      if (typeof stateValue !== 'string') {
        return;
      }
      
      logPageInfo(TAG, `Received auth state: ${stateValue}`);
      
      if (stateValue === 'authorizationStateWaitOtherDeviceConfirmation') {
        logPageInfo(TAG, 'Received WAIT_OTHER_DEVICE_CONFIRMATION state');
        const authStateWithLink = authStateValue as authorizationStateWaitOtherDeviceConfirmation;
        if (authStateWithLink && authStateWithLink.link.length > 0) {
          const linkValue = authStateWithLink.link;
          this.savedLink = linkValue;
          this.qrCodeUrl = linkValue;
          this.isLoading = false;
          this.scheduleRefresh();
          return;
        }
        this.isLoading = false;
        this.errorMessage = getString('auth_qr_code_error');
      } else if (stateValue === 'authorizationStateReady') {
        logPageInfo(TAG, 'Received READY state, navigate to Main');
        this.navigateToMain();
      }
    });
  }

  /**
   * 检查当前授权状态并决定是否需要发起二维码认证请求
   * 优先使用 updateAuthorizationState 被动接收状态更新
   */
  private async checkAndStartQrCodeAuth(): Promise<void> {
    if (!this.tdLibApi) {
      return;
    }
    
    this.isLoading = true;
    this.errorMessage = '';
    
    try {
      logPageInfo(TAG, 'Checking current authorization state');
      
      // 获取当前授权状态
      const authState = await this.authService.getAuthorizationState();
      const stateType: string = authState['@type'] as string;
      
      logPageInfo(TAG, `Current auth state: ${stateType}`);
      
      // ⭐ 关键修复：如果已经认证完成，直接跳转到主页
      if (stateType === 'authorizationStateReady') {
        logPageInfo(TAG, 'Already authenticated, navigating to Main');
        this.navigateToMain();
        return;
      }
      
      // 如果已经处于等待其他设备确认状态，直接使用现有的链接
      if (stateType === 'authorizationStateWaitOtherDeviceConfirmation') {
        const linkValue = (authState as authorizationStateWaitOtherDeviceConfirmation).link;
        if (linkValue && linkValue.length > 0) {
          logPageInfo(TAG, 'Already in WAIT_OTHER_DEVICE_CONFIRMATION with valid link');
          // 直接使用现有链接，不发起新请求
          this.savedLink = linkValue;
          this.qrCodeUrl = linkValue;
          this.isLoading = false;
          this.scheduleRefresh();
          return;
        }
        // 如果状态是等待确认但没有链接，需要发起请求
        logPageInfo(TAG, 'WAIT_OTHER_DEVICE_CONFIRMATION state but no link, will request');
      }
      
      // 如果不是等待确认状态，或者状态异常，则发起二维码认证请求
      // 链接将通过 updateAuthorizationState 事件被动接收
      await this.requestQrCodeAuth();
      
    } catch (error) {
      logPageError(TAG, `Failed to check auth state: ${error}`);
      this.isLoading = false;
      this.errorMessage = getString('auth_qr_code_error');
    }
  }
  
  /**
   * 发起二维码认证请求
   * 链接将通过 updateAuthorizationState 事件被动接收
   */
  private async requestQrCodeAuth(): Promise<void> {
    if (!this.tdLibApi) {
      return;
    }
    
    try {
      logPageInfo(TAG, 'Requesting QR code authentication (will wait for updateAuthorizationState)');
      await this.tdLibApi.requestQrCodeAuthentication([]);
      
      // 设置超时处理：如果5秒内没有收到状态更新，显示错误
      setTimeout(() => {
        if (this.isLoading && !this.qrCodeUrl) {
          logPageInfo(TAG, 'Timeout waiting for QR code link');
          this.isLoading = false;
          this.errorMessage = getString('auth_qr_code_error');
        }
      }, 5000);
      
    } catch (error) {
      logPageError(TAG, `Failed to request QR code: ${error}`);
      this.isLoading = false;
      this.errorMessage = getString('auth_qr_code_error');
    }
  }

  private async startQrCodeAuthentication(): Promise<void> {
    // 保持旧方法兼容性，调用新的检查方法
    await this.checkAndStartQrCodeAuth();
  }

  private handleWaitOtherDeviceState(authState: AuthorizationState): void {
    const stateType: string = authState['@type'] as string;
    if (stateType === 'authorizationStateWaitOtherDeviceConfirmation') {
      const authStateWithLink = authState as authorizationStateWaitOtherDeviceConfirmation;
      const linkValue = authStateWithLink.link;
      if (linkValue.length > 0) {
        logPageInfo(TAG, `Received QR code link: ${linkValue}`);
        this.savedLink = linkValue;
        this.qrCodeUrl = linkValue;
        this.isLoading = false;
        this.scheduleRefresh();
        return;
      }
    }
    this.isLoading = false;
    this.errorMessage = getString('auth_qr_code_error');
  }

  private scheduleRefresh(): void {
    if (this.refreshTimer) {
      clearTimeout(this.refreshTimer);
      this.refreshTimer = 0;
    }
    
    // 二维码约20秒过期，提前2秒刷新
    const refreshDelay = 18000;
    
    const timerId = setTimeout(() => {
      logPageInfo(TAG, 'Refreshing QR code due to expiration');
      this.refreshQRCode();
    }, refreshDelay);
    this.refreshTimer = Number(timerId);
  }

  private async refreshQRCode(): Promise<void> {
    this.isRefreshing = true;
    
    if (this.refreshTimer) {
      clearTimeout(this.refreshTimer);
      this.refreshTimer = 0;
    }
    
    try {
      await this.startQrCodeAuthentication();
    } finally {
      this.isRefreshing = false;
    }
  }

  private navigateToMain(): void {
    if (this.hasNavigated) {
      return;
    }
    this.hasNavigated = true;
    
    if (this.refreshTimer) {
      clearTimeout(this.refreshTimer);
      this.refreshTimer = 0;
    }
    
    router.replaceUrl({ url: RoutePaths.MAIN }).catch(() => {});
  }

  build() {
    Column() {
      // 头部
      this.buildHeader();
      
      // 主内容区
      Column() {
        if (this.isLoading) {
          // 加载状态
          Column() {
            LoadingProgress()
              .width(48)
              .height(48)
              .color(COLOR_TELEGRAM_BLUE);
            
            Text(getString('auth_qr_code_loading'))
              .fontSize(FONT_SIZE_BODY2)
              .fontColor(COLOR_TEXT_SECONDARY)
              .margin({ top: SPACING_MD });
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center);
        } else if (this.errorMessage.length > 0) {
          // 错误状态
          Column() {
            SymbolGlyph($r('sys.symbol.exclamationmark_triangle'))
              .width(48)
              .height(48)
              .fontColor([COLOR_TEXT_TERTIARY]);
            
            Text(this.errorMessage)
              .fontSize(FONT_SIZE_BODY2)
              .fontColor(COLOR_TEXT_SECONDARY)
              .textAlign(TextAlign.Center)
              .margin({ top: SPACING_MD });
              
            Button(getString('auth_qr_code_retry'))
              .width(150)
              .height(48)
              .fontSize(FONT_SIZE_BODY2)
              .fontColor(Color.White)
              .backgroundColor(COLOR_TELEGRAM_BLUE)
              .borderRadius(RADIUS_LG)
              .margin({ top: SPACING_XL })
              .onClick(() => this.refreshQRCode());
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center);
        } else {
          // 二维码显示状态
          Column() {
            // 标题
            Text(getString('auth_qr_code_title'))
              .fontSize(FONT_SIZE_H3)
              .fontWeight(FontWeight.Medium)
              .fontColor(COLOR_TEXT_PRIMARY)
              .margin({ top: SPACING_LG })
              .textAlign(TextAlign.Center);
            
            // 提示文本
            Text(getString('auth_qr_code_hint'))
              .fontSize(FONT_SIZE_BODY2)
              .fontColor(COLOR_TEXT_SECONDARY)
              .margin({ top: SPACING_SM, left: SPACING_XL, right: SPACING_XL })
              .textAlign(TextAlign.Center);
            
            // 二维码显示区域 - 使用鸿蒙原生 QRCode 组件
            Stack({ alignContent: Alignment.Center }) {
              // 外层背景 - 使用 Column 包裹 Blank
              Column() {
                Blank()
                  .width(QR_CODE_SIZE + SPACING_XL * 2)
                  .height(QR_CODE_SIZE + SPACING_XL * 2);
              }
              .backgroundColor(COLOR_QR_BG)
              .borderRadius(RADIUS_XL)
              .border({
                width: 2,
                color: COLOR_DIVIDER
              });
              
              // 鸿蒙原生 QRCode 组件
              QRCode(this.qrCodeUrl)
                .width(QR_CODE_SIZE)
                .height(QR_CODE_SIZE)
                .color(COLOR_QR_COLOR)
                .backgroundColor(COLOR_QR_BG);
            }
            .margin({ top: SPACING_XL });
            
            // 操作按钮
            Row({ space: SPACING_LG }) {
              // 刷新按钮
              Button({ type: ButtonType.Normal }) {
                Text(getString('refresh'))
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
              .enabled(!this.isRefreshing)
              .onClick(() => this.refreshQRCode());
            }
            .margin({ top: SPACING_XL });
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center);
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BACKGROUND)
    .opacity(this.pageOpacity)
    .animation({
      duration: 500,
      curve: Curve.EaseInOut
    })
    .padding({ top: this.topSafeHeight, bottom: this.bottomSafeHeight });
  }

  @Builder
  private buildHeader() {
    Row() {
      // 返回按钮
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.arrow_left'))
          .width(24)
          .height(24)
          .fontColor([COLOR_TEXT_PRIMARY]);
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        router.back();
      });
      
      // 标题
      Text(getString('auth_qr_code'))
        .fontSize(FONT_SIZE_BODY1)
        .fontWeight(FontWeight.Medium)
        .fontColor(COLOR_TEXT_PRIMARY)
        .layoutWeight(1);
      
      // 占位
      Blank().width(40);
    }
    .width('100%')
    .height(56)
    .padding({ left: SPACING_SM, right: SPACING_SM })
    .backgroundColor(COLOR_BACKGROUND);
  }
}