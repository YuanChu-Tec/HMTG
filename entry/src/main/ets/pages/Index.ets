import { hilog } from '@kit.PerformanceAnalysisKit';
import { NavigationHelper, RoutePaths } from '../utils/navigation/NavigationHelper';
// import { MigrationManager } from '../database/chat/MigrationManager';
// import relationalStore from '@ohos.data.relationalStore';
import { AppStateManager, AppState, StateChangeEvent } from '../services/AppStateManager';
import { EventBus } from '../utils/event/EventBus';
import { TDLibAuthManager } from '../services/core/tdlib/TDLibAuthManager';
import { abilityAccessCtrl, bundleManager, Permissions, common } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';

/**
 * 应用启动入口页
 * 作用: 整合品牌 Splash 展示与全局状态机路由分发
 */
@Entry
@ComponentV2
export struct Index {
  private readonly TAG: string = 'Index';
  private readonly DOMAIN: number = 0x0001;
  
  // UI 状态
  @Local currentAppState: AppState = AppState.INIT;
  @Local isNavigated: boolean = false;
  @Local permissionsRequested: boolean = false; // 标记是否已申请权限

  async aboutToAppear(): Promise<void> {
    hilog.info(this.DOMAIN, this.TAG, 'Index page appeared');
      
    // 1. ⭐ 首次启动申请所有必要权限
    await this.requestAllPermissions();
    
    // 2. 初始化 storage_cache 模块已在 EntryAbility 中完成
    hilog.info(this.DOMAIN, this.TAG, 'Storage cache module initialized in EntryAbility');
  
    // 3. 订阅全局状态变化
    EventBus.getInstance().on('appStateChanged', (data?: Object) => {
      if (data) {
        const event = data as StateChangeEvent;
        this.currentAppState = event.to;
        this.handleStateTransition(event.to);
      }
    });

    // 4. ⭐ 关键修复:主动检查当前状态(防止错过已发生的状态变化)
    // 状态机在 EntryAbility.onCreate 中启动,可能在 Index.aboutToAppear 之前已完成
    const currentState = AppStateManager.getInstance().getState();
    hilog.info(this.DOMAIN, this.TAG, `Current app state on Index load: ${currentState}`);
    
    if (currentState !== AppState.INIT) {
      // 状态已经变化,立即处理
      this.currentAppState = currentState;
      this.handleStateTransition(currentState);
    }
  }

  /**
   * 申请所有必要的运行时权限
   */
  private async requestAllPermissions(): Promise<void> {
    if (this.permissionsRequested) {
      hilog.info(this.DOMAIN, this.TAG, 'Permissions already requested, skipping');
      return;
    }

    try {
      const context = getContext(this) as common.UIAbilityContext;
      const atManager = abilityAccessCtrl.createAtManager();
      
      // 获取应用的 accessTokenId
      const bundleInfo = await bundleManager.getBundleInfoForSelf(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
      );
      const accessTokenId = bundleInfo.appInfo.accessTokenId;

      // 定义需要申请的权限列表(使用字符串常量)
      const permissionsToRequest: string[] = [
        'ohos.permission.CAMERA',           // 相机权限(扫码、拍照)
        'ohos.permission.MICROPHONE',       // 麦克风权限(语音消息、通话)
        'ohos.permission.READ_MEDIA',       // 读取媒体权限(选择图片/视频)
        'ohos.permission.WRITE_MEDIA',      // 写入媒体权限(保存图片/视频)
      ];

      hilog.info(this.DOMAIN, this.TAG, 'Starting permission requests...');

      // 检查并申请每个权限
      for (const permission of permissionsToRequest) {
        try {
          // 检查权限状态
          const grantStatus = await atManager.checkAccessToken(accessTokenId, permission as Permissions);
          
          if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
            hilog.info(this.DOMAIN, this.TAG, `✅ Permission ${permission} already granted`);
          } else {
            hilog.info(this.DOMAIN, this.TAG, `⏳ Requesting permission: ${permission}`);
            // 申请权限
            const result = await atManager.requestPermissionsFromUser(context, [permission as Permissions]);
            
            if (result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
              hilog.info(this.DOMAIN, this.TAG, `✅ Permission ${permission} granted by user`);
            } else {
              hilog.warn(this.DOMAIN, this.TAG, `⚠️ Permission ${permission} denied by user`);
            }
          }
        } catch (error) {
          hilog.error(this.DOMAIN, this.TAG, `Failed to check/request permission ${permission}: ${JSON.stringify(error)}`);
        }
      }

      // ⭐ 单独处理通知权限(使用 NotificationKit API)
      await this.requestNotificationPermission(context);

      this.permissionsRequested = true;
      hilog.info(this.DOMAIN, this.TAG, '✅ All permission checks completed');
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Permission request failed: ${JSON.stringify(error)}`);
      this.permissionsRequested = true; // 即使失败也标记为已尝试,避免重复请求
    }
  }

  /**
   * 申请通知权限(使用 NotificationKit API)
   */
  private async requestNotificationPermission(context: common.UIAbilityContext): Promise<void> {
    try {
      hilog.info(this.DOMAIN, this.TAG, '🔔 Requesting notification permission...');
      
      // 发起通知权限请求(首次调用会弹出系统弹窗)
      await notificationManager.requestEnableNotification(context);
      hilog.info(this.DOMAIN, this.TAG, 'Notification permission request sent');
      
      // 检查通知权限状态
      const isEnabled = await notificationManager.isNotificationEnabled();
      if (isEnabled) {
        hilog.info(this.DOMAIN, this.TAG, '✅ Notification permission granted');
      } else {
        hilog.warn(this.DOMAIN, this.TAG, '⚠️ Notification permission denied - user needs to enable in Settings');
      }
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to request notification permission: ${JSON.stringify(error)}`);
      // 不阻塞应用启动,允许用户稍后在设置中手动开启
    }
  }

  /**
   * 处理状态转换逻辑 - 立即跳转,无延迟
   */
  private handleStateTransition(state: AppState): void {
    if (this.isNavigated) return;

    switch (state) {
      case AppState.AUTH_CHECKED:
        // AppStateManager 已经等待 Worker 就绪后才进入此状态
        // 直接检查登录状态即可
        const isLoggedIn = TDLibAuthManager.getInstance().isReady();
        hilog.info(this.DOMAIN, this.TAG, `AUTH_CHECKED: isLoggedIn=${isLoggedIn}`);
        if (!isLoggedIn) {
          hilog.info(this.DOMAIN, this.TAG, 'User not logged in, navigating to WelcomePage');
          this.safeNavigate(RoutePaths.AUTH_WELCOME);
        } else {
          hilog.info(this.DOMAIN, this.TAG, 'User already logged in, waiting for DATA_SYNCED');
        }
        break;
      case AppState.DATA_SYNCED:
        hilog.info(this.DOMAIN, this.TAG, 'App fully ready, navigating to MainTabContainer');
        this.safeNavigate(RoutePaths.MAIN);
        break;
      case AppState.ERROR:
        hilog.error(this.DOMAIN, this.TAG, 'Application entered ERROR state');
        // 错误时允许用户点击重试
        break;
    }
  }

  /**
   * 安全导航：防止重复跳转
   * 增加1秒延迟，让启动页UI多显示一段时间
   */
  private safeNavigate(path: string): void {
    if (!this.isNavigated) {
      this.isNavigated = true;
      // 延迟1秒后跳转，让启动页UI多显示一段时间
      setTimeout(() => {
        NavigationHelper.replacePage(path);
      }, 650);
    }
  }

  build() {
    Column() {
      // Logo 区域 - 居中显示品牌信息
      Column() {
        Image($r('app.media.startIcon'))
          .width('40%')
          .height('40%')
          .objectFit(ImageFit.Contain)

        Text($r('app.string.welcome_app_name'))
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ top: 16 })

        Text($r('app.string.welcome_subtitle'))
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 6 })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .layoutWeight(1)

      // 底部占位区域 - 错误时显示重试按钮
      if (this.currentAppState === AppState.ERROR) {
        Column() {
          Text('启动失败,点击重试')
            .fontSize(14)
            .fontColor('#FF5252')
            .onClick(() => {
              hilog.info(this.DOMAIN, this.TAG, 'Retrying initialization from ERROR state');
              this.isNavigated = false;
              AppStateManager.getInstance().initialize(getContext(this));
            })
        }
        .padding({ bottom: 60 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
