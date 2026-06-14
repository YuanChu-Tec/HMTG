import { AbilityConstant, UIAbility, Want, Configuration, common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { LogService, PerformanceMonitor, EventBus, FileHelper } from '../utils';
import { TDLibReceiver } from '../services';
import { TDLibClient } from '../services/core/tdlib/TDLibClient'; // ⭐ 新增导入
import { TDLibAuthManager } from '../services/core/tdlib/TDLibAuthManager'; // ⭐ 授权管理器
import { i18n } from '../utils/i18n/I18n'; // ⭐ 国际化工具
import { fileIo } from '@kit.CoreFileKit';
import { PushService } from '../services';
import { CoreService } from '../services/business/CoreService';
import { FileDownloadService } from '../services/business/FileDownloadService';
import { AppStateManager } from '../services/AppStateManager'; // ⭐ 全局状态机
import { CacheService } from '../services/business/CacheService'; // ⭐ 统一缓存服务
import { CacheStorage } from '@storage/cache'; // ⭐ storage_cache模块

// Temporarily removed: @telegram/database-core

/**
 * 初始化选项接口
 */
interface InitOptions {
  checkPermissions: boolean;
  initDataManager: boolean;
  initTheme: boolean;
}

/**
 * 错误处理选项接口
 */
interface ErrorOptions {
  logError: boolean;
  showUserMessage: boolean;
  retryCount: number;
}

/**
 * 前台事件接口
 */
interface ForegroundEvent {
  timestamp: number;
}

/**
 * 清理事件接口
 */
interface CleanupEvent {
  type: string;
  timestamp: number;
}

/**
 * EntryAbility - 应用主Ability
 * 作用：应用UI入口，管理主窗口和生命周期
 * 集成基础设施服务：LogService、PerformanceMonitor、EventBus
 *
 * 关键职责：
 * 1. 创建主窗口并加载初始页面
 * 2. 管理应用前后台切换
 * 3. 处理窗口配置和资源清理
 * 4. 支持Deep Link和Scheme Link
 * 5. 提供应用重启功能
 */

const DOMAIN = 0x0001;
const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  private static instance: EntryAbility;

  onCreate(want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    const startTime = Date.now();
    hilog.info(0x0001, TAG, 'EntryAbility onCreate');
    hilog.info(0x0001, TAG, 'Launch param: %{public}s', JSON.stringify(want));

    EntryAbility.instance = this;

    // ⭐ 初始化国际化系统（必须在其他服务之前）
    try {
      const ctx = this.context as common.UIAbilityContext;
      i18n.init(ctx);
      hilog.info(DOMAIN, TAG, 'I18n initialized with locale: %{public}s', i18n.getLocale());
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to initialize I18n: ${JSON.stringify(error)}`);
    }

    // 初始化性能监控
    const perfMonitor = PerformanceMonitor.getInstance();
    perfMonitor.startTrace('ability_on_create');
    perfMonitor.endTrace('ability_on_create');

    // 处理 Deep Link 或 Scheme Link
    this.handleDeepLink(want);
        
    // 初始化推送服务
    PushService.getInstance().initialize(this.context as common.UIAbilityContext).then((success) => {
      if (success) {
        hilog.info(DOMAIN, TAG, 'PushService initialized successfully');
      } else {
        hilog.error(DOMAIN, TAG, 'Failed to initialize PushService');
      }
    }).catch((err: Error) => {
      hilog.error(DOMAIN, TAG, `PushService initialization error: ${JSON.stringify(err)}`);
    });

    // ⭐ 初始化 TDLib Worker 并等待就绪后再启动 AppStateManager
    // 确保所有依赖 TDLib 的功能在 Worker 就绪后才可用
    this.initTDLibAndStartAppStateManager();

    const duration = Date.now() - startTime;
    LogService.getInstance().info(0x0001, TAG, `EntryAbility onCreate completed in ${duration}ms`);
    perfMonitor.startTrace('ability_create_time');
    perfMonitor.endTrace('ability_create_time');
    hilog.debug(0x0001, TAG, `EntryAbility onCreate completed in ${duration}ms`);
  }

  /**
   * 获取EntryAbility单例
   */
  public static getInstance(): EntryAbility | null {
    return EntryAbility.instance;
  }

  onDestroy(): void {
    hilog.info(0x0001, TAG, 'EntryAbility onDestroy');

    // 清理全局资源
    this.cleanupWindowResources();

    // 记录销毁事件
    LogService.getInstance().info(0x0001, TAG, 'EntryAbility onDestroy');
    const perfMonitor = PerformanceMonitor.getInstance();
    perfMonitor.startTrace('ability_on_destroy');
    perfMonitor.endTrace('ability_on_destroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0001, TAG, 'EntryAbility onWindowStageCreate');
  
    // ⭐ 获取并存储安全区高度（必须在配置窗口之后）
    this.getAndStoreSafeAreaHeight(windowStage);
  
    // 配置窗口属性
    this.configureWindow(windowStage);
  
    // ⭐ 立即开始预加载 Lottie 动画（不阻塞，但尽早开始）
    this.earlyPreloadResources();
  
    // 加载主页面
    windowStage.loadContent('pages/Index', (err: BusinessError) => {
      if (err.code) {
        hilog.error(0x0001, TAG, 'Failed to load content. Code: %{public}d, message: %{public}s',
          err.code, err.message);
        return;
      }
      hilog.info(0x0001, TAG, 'Succeeded in loading content.');
    });
  }

  /**
   * ⭐ 获取安全区高度并存储到 AppStorage
   * 参考 JMComic EntryAbility 实现
   */
  private getAndStoreSafeAreaHeight(windowStage: window.WindowStage): void {
    try {
      windowStage.getMainWindow((err: BusinessError, windowClass: window.Window) => {
        let errCode: number = err.code;
        if (errCode) {
          hilog.error(DOMAIN, TAG, 'Failed to obtain the main window. Cause: ' + JSON.stringify(err));
          return;
        }

        // 获取状态栏区域高度
        let notificationArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        let topHeight = px2vp(notificationArea.topRect.height);
        AppStorage.setOrCreate('topSafeHeight', topHeight);

        // 获取导航栏区域高度
        let navigationArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        let bottomHeight = px2vp(navigationArea.bottomRect.height);
        AppStorage.setOrCreate('bottomSafeHeight', bottomHeight);

        hilog.info(DOMAIN, TAG, `topSafeHeight=${topHeight}, bottomSafeHeight=${bottomHeight}`);
      });
    } catch (error) {
      const err = error as Error;
      hilog.error(DOMAIN, TAG, `Failed to get safe area height: ${err.message}`);
    }
  }

  /**
   * ⭐ 早期初始化缓存服务（在窗口创建时立即开始）
   */
  private earlyPreloadResources(): void {
    // 立即开始初始化，不等待 setTimeout
    this.doPreloadResources().catch((err: Error) => {
      hilog.error(DOMAIN, TAG, `Early preload failed: ${err.message}`);
    });
  }

  /**
   * 执行实际的缓存初始化
   */
  private async doPreloadResources(): Promise<void> {
    try {
      // ⭐ 初始化 CacheStorage (storage_cache模块)
      if (this.context) {
        const cacheStorage = CacheStorage.getInstance(this.context as common.UIAbilityContext);
        // ⭐ 等待数据库初始化完成（确保表已创建）
        await cacheStorage.waitForReady();
        hilog.info(DOMAIN, TAG, '✅ CacheStorage initialized and ready');
      }
      
      // ⭐ 初始化 CacheService (委托给CacheStorage)
      const cacheService = CacheService.getInstance();
      
      if (this.context) {
        await cacheService.initialize(this.context);
        hilog.info(DOMAIN, TAG, '✅ CacheService initialized');
      }
      
      // ⭐ 打印缓存统计
      const stats = await cacheService.getCacheStats();
      hilog.info(DOMAIN, TAG, `📊 Cache stats: ${JSON.stringify(stats)}`);
      
      // ⭐ 发送预加载完成事件
      interface PreloadCompleteEvent {
        timestamp: number;
      }
      const preloadEvent: PreloadCompleteEvent = { 
        timestamp: Date.now()
      };
      EventBus.getInstance().emit('cache.preload.complete', preloadEvent);
      
    } catch (error) {
      const err = error as Error;
      hilog.error(DOMAIN, TAG, `Failed to preload resources: ${err.message}`);
    }
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0001, TAG, 'EntryAbility onWindowStageDestroy');

    // 清理窗口资源
    this.cleanupWindowResources();
  }

  onForeground(): void {
    const startTime = Date.now();
    hilog.info(0x0001, TAG, 'EntryAbility onForeground');

      // 应用回到前台，恢复任务或刷新数据
    const evtBus = EventBus.getInstance();
    const foregroundEvent: ForegroundEvent = { timestamp: Date.now() };
    evtBus.emit('app.foreground', foregroundEvent);
    const perfMonitor = PerformanceMonitor.getInstance();
    perfMonitor.startTrace('ability_on_foreground');
    perfMonitor.endTrace('ability_on_foreground');

    const duration = Date.now() - startTime;
    LogService.getInstance().info(0x0001, TAG, `EntryAbility onForeground completed in ${duration}ms`);
    hilog.debug(0x0001, TAG, `EntryAbility onForeground completed in ${duration}ms`);
  }

  onBackground(): void {
    const startTime = Date.now();
    hilog.info(0x0001, TAG, 'EntryAbility onBackground');

    // 应用进入后台，暂停非必要任务
    const evtBus = EventBus.getInstance();
    interface BackgroundEvent {
      timestamp: number;
    }
    const backgroundEvent = { timestamp: Date.now() } as BackgroundEvent;
    evtBus.emit('app.background', backgroundEvent);
    const perfMonitor = PerformanceMonitor.getInstance();
    perfMonitor.startTrace('ability_on_background');
    perfMonitor.endTrace('ability_on_background');

    const duration = Date.now() - startTime;
    LogService.getInstance().info(0x0001, TAG, `EntryAbility onBackground completed in ${duration}ms`);
    hilog.debug(0x0001, TAG, `EntryAbility onBackground completed in ${duration}ms`);
  }

  onConfigurationUpdate(_newConfig: Configuration): void {
    hilog.info(0x0001, TAG, 'EntryAbility onConfigurationUpdate');

    // 处理配置变更（如语言、方向等）
    // 注意：具体逻辑将在后续实现中添加
  }

  /**
   * 配置窗口属性
   * 优化内容：
   * 1. 支持沉浸式全屏体验
   * 2. 动态状态栏颜色配置
   * 3. 安全区扩展支持
   * 4. 深色模式适配
   */
  private configureWindow(windowStage: window.WindowStage): void {
    try {
      // 获取主窗口
      const mainWindow = windowStage.getMainWindowSync();

      // 设置窗口布局全屏（沉浸式体验核心）
      mainWindow.setWindowLayoutFullScreen(true);

      // 配置系统栏（状态栏和导航栏）属性
      // 状态栏透明，导航栏透明，支持沉浸式效果
      interface SystemBarProps {
        statusBarColor: string;
        navigationBarColor: string;
        statusBarContentColor: string;
        navigationBarContentColor: string;
      }
      const sysBarProps: SystemBarProps = {
        statusBarColor: '#00000000',  // 完全透明
        navigationBarColor: '#00000000',  // 完全透明
        statusBarContentColor: '#000000',  // 状态栏图标黑色
        navigationBarContentColor: '#000000'  // 导航栏图标黑色
      };
      mainWindow.setWindowSystemBarProperties(sysBarProps);

      // 设置系统栏启用状态
      mainWindow.setWindowSystemBarEnable(['status', 'navigation']);

      // 配置窗口布局避让区域（安全区）
      mainWindow.setWindowLayoutFullScreen(true);

      // 注意：不在这里设置背景色，避免窗口未就绪时的错误
      // 背景色由页面组件自行设置

      hilog.info(DOMAIN, TAG, 'Window configuration completed with immersive mode');
    } catch (error) {
      const businessError = error as BusinessError;
      hilog.error(DOMAIN, TAG, 'Failed to configure window: code=%{public}d, message=%{public}s',
        businessError.code, businessError.message);
    }
  }

  /**
   * 处理 Deep Link 或 Scheme Link
   */
  private handleDeepLink(want: Want): void {
    if (want.uri) {
      hilog.info(0x0001, TAG, 'Received deep link: %{public}s', want.uri);
  
      // TODO: 实现 Telegram 链接处理逻辑
      // 支持的格式：
      // - tg://join/* (Telegram 邀请链接)
      // - telegram:// (Telegram 链接)
      // - https://t.me/* (Telegram 网页链接)
    }
  }
    
  /**
   * 清理窗口资源
   */
  private async cleanupWindowResources(): Promise<void> {
    // 清理与窗口相关的资源
    LogService.getInstance().info(DOMAIN, TAG, 'Cleaning up window resources');
    hilog.debug(DOMAIN, TAG, 'Cleaning up window resources');

    try {
      // 1. 关闭数据库连接
      try {
        // 注释掉 preferences.deleteAll 调用，避免API不兼容
        // await preferences.deleteAll(this.context.preferencesDir);
        LogService.getInstance().info(DOMAIN, TAG, 'Database connections closed');
      } catch (error) {
        const err = error as Error;
        LogService.getInstance().error(DOMAIN, TAG, `Database cleanup failed: ${err.message}`);
      }

      // 2. 清理缓存
      await this.cleanupCache();

      // 3. 取消网络请求
      await this.cancelNetworkRequests();

      // 4. 释放文件句柄
      await this.releaseFileHandles();

      LogService.getInstance().info(DOMAIN, TAG, 'Window resources cleanup completed');
    } catch (error) {
      const err = error as Error;
      LogService.getInstance().error(DOMAIN, TAG, `Failed to cleanup window resources: ${err.message}`);
      hilog.error(DOMAIN, TAG, `Failed to cleanup window resources: %{public}s`, err.message);
    }
  }

  /**
   * 关闭数据库连接
   */
  private async cleanupDatabaseConnections(): Promise<void> {
    try {
      LogService.getInstance().debug(DOMAIN, TAG, 'Closing database connections');

      // 暂时注释掉 databaseManager，因为可能不存在
      // await databaseManager.closeAll();

      LogService.getInstance().info(DOMAIN, TAG, 'Database connections closed');
      hilog.debug(DOMAIN, TAG, 'Database connections closed');
    } catch (error) {
      const err = error as Error;
      LogService.getInstance().error(DOMAIN, TAG, `Database cleanup failed: ${err.message}`);
      hilog.error(DOMAIN, TAG, `Database cleanup failed: %{public}s`, err.message);
    }
  }

  /**
   * 清理缓存
   */
  private async cleanupCache(): Promise<void> {
    try {
      LogService.getInstance().debug(0x0001, TAG, 'Cleaning up cache');

      // ⭐ 清理 CacheStorage
      const cacheStorage = CacheStorage.getInstance();
      await cacheStorage.clearAllCache();
      await cacheStorage.close();

      LogService.getInstance().info(0x0001, TAG, 'Cache cleaned successfully');
      hilog.debug(0x0001, TAG, 'Cache cleaned');
    } catch (error) {
      const err = error as Error;
      LogService.getInstance().error(0x0001, TAG, `Cache cleanup failed: ${err.message}`);
      hilog.error(0x0001, TAG, `Cache cleanup failed: %{public}s`, err.message);
    }
  }

  /**
   * 取消网络请求
   */
  private async cancelNetworkRequests(): Promise<void> {
    try {
      LogService.getInstance().debug(DOMAIN, TAG, 'Cancelling network requests');

      // 1. 关闭TDLib连接
      try {
        // TDLib连接会在TDLib内部自动管理
        // 这里主要是通知事件总线，让相关模块进行清理
        interface CleanupEvent {
          type: string;
          timestamp: number;
        }
        const cleanupEvent = { type: 'network', timestamp: Date.now() } as CleanupEvent;
        EventBus.getInstance().emit('app.cleanup', cleanupEvent);

        LogService.getInstance().info(DOMAIN, TAG, 'TDLib cleanup event emitted');
      } catch (error) {
        const err = error as Error;
        LogService.getInstance().warn(DOMAIN, TAG, `TDLib cleanup warning: ${err.message}`);
      }

      // 2. 关闭WebSocket连接（如果有）
      // WebSocketManager会在收到app.cleanup事件后自动断开

      LogService.getInstance().info(DOMAIN, TAG, 'Network requests cancelled');
      hilog.debug(DOMAIN, TAG, 'Network requests cancelled');
    } catch (error) {
      const err = error as Error;
      LogService.getInstance().error(DOMAIN, TAG, `Cancel network requests failed: ${err.message}`);
      hilog.error(DOMAIN, TAG, `Cancel network requests failed: %{public}s`, err.message);
    }
  }

  /**
   * 释放文件句柄
   */
  private async releaseFileHandles(): Promise<void> {
    try {
      LogService.getInstance().debug(DOMAIN, TAG, 'Releasing file handles');

      // FileHelper已提供文件操作，清理临时文件
      const tempDir = this.context.tempDir;

      try {
        // 尝试列出并删除临时文件
        const tempFiles: string[] = await fileIo.listFile(tempDir);

        for (const file of tempFiles) {
          try {
            const filePath = tempDir.endsWith('/') ? tempDir + file : tempDir + '/' + file;
            await fileIo.unlink(filePath);
            hilog.debug(DOMAIN, TAG, `Temp file deleted: ${file}`);
          } catch (error) {
            // 忽略删除失败的临时文件
            hilog.debug(DOMAIN, TAG, `Failed to delete temp file ${file}, may not exist`);
          }
        }

        LogService.getInstance().info(DOMAIN, TAG, `Released ${tempFiles.length} temp files`);
      } catch (error) {
        // 目录不存在或无权限，忽略
        hilog.debug(DOMAIN, TAG, 'Temp directory not accessible or empty');
      }

      // 发布文件清理事件
      const cleanupObj: CleanupEvent = {
        type: 'files',
        timestamp: Date.now()
      };
      EventBus.getInstance().emit('app.cleanup', cleanupObj);

      LogService.getInstance().info(DOMAIN, TAG, 'File handles released');
      hilog.debug(DOMAIN, TAG, 'File handles released');
    } catch (error) {
      const err = error as Error;
      LogService.getInstance().error(DOMAIN, TAG, `Release file handles failed: ${err.message}`);
      hilog.error(DOMAIN, TAG, `Release file handles failed: %{public}s`, err.message);
    }
  }

  /**
   * 重启应用
   * 使用UIAbilityContext.restartApp()方法重启当前进程
   *
   * 注意：
   * 1. 此方法会重启整个应用进程
   * 2. 所有状态会被重置，需要重新加载数据
   * 3. 应在重要操作前保存必要的持久化数据
   * 4. restartApp接受Want参数来指定重启时的启动参数
   *
   * @param want 重启时的Want参数
   * @returns Promise<boolean> 返回重启是否成功
   */
  public static async restart(want?: Want): Promise<boolean> {
    const instance = EntryAbility.getInstance();
    if (!instance) {
      hilog.error(DOMAIN, TAG, 'Failed to restart: EntryAbility instance not found');
      return false;
    }

    try {
      hilog.info(DOMAIN, TAG, 'Starting application restart...');

      // 获取 UIAbilityContext
      const abilityContext = instance.context as common.UIAbilityContext;

      // 记录重启事件
      LogService.getInstance().info(DOMAIN, TAG, 'Application restart initiated');
      const perfMonitor = PerformanceMonitor.getInstance();
      perfMonitor.startTrace('app_restart');
      perfMonitor.endTrace('app_restart');

      // 调用 restartApp 方法重启应用，传入 want 参数
      abilityContext.restartApp(want || {});

      hilog.info(DOMAIN, TAG, 'Application restart initiated successfully');
      return true;
    } catch (error) {
      const businessError = error as BusinessError;
      hilog.error(DOMAIN, TAG, 'Failed to restart application: code=%{public}d, message=%{public}s',
        businessError.code, businessError.message);
      return false;
    }
  }

  /**
   * ⭐ 初始化 TDLib Worker 并启动 AppStateManager
   * 确保 Worker 就绪后再启动状态机
   */
  private async initTDLibAndStartAppStateManager(): Promise<void> {
    try {
      const ctx = this.context as common.UIAbilityContext;
      const tdClient = TDLibClient.getInstance();
      
      // 1. 初始化 TDLib Worker
      hilog.info(DOMAIN, TAG, '⏳ Initializing TDLib Worker...');
      await tdClient.initialize(ctx);
      hilog.info(DOMAIN, TAG, '✅ TDLib Worker initialized');
      
      // 2. 等待 Worker 就绪（收到 READY 消息）
      hilog.info(DOMAIN, TAG, '⏳ Waiting for TDLib Worker ready signal...');
      await tdClient.getReadyPromise();
      hilog.info(DOMAIN, TAG, '✅ TDLib Worker is ready');
      
      // 3. 初始化授权管理器
      try {
        const authManager = TDLibAuthManager.getInstance();
        hilog.info(DOMAIN, TAG, '✅ TDLibAuthManager initialized');
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Failed to initialize TDLibAuthManager: ${JSON.stringify(error)}`);
      }
      
      // 4. 启动全局应用状态机（此时 Worker 已就绪）
      hilog.info(DOMAIN, TAG, '⏳ Starting AppStateManager...');
      await AppStateManager.getInstance().initialize(ctx);
      hilog.info(DOMAIN, TAG, '✅ AppStateManager initialized');
      
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to initialize TDLib or AppStateManager: ${JSON.stringify(error)}`);
      // 即使失败也尝试启动 AppStateManager，避免应用完全卡住
      AppStateManager.getInstance().initialize(this.context as common.UIAbilityContext).catch((err: Error) => {
        hilog.error(DOMAIN, TAG, `AppStateManager initialization failed: ${JSON.stringify(err)}`);
      });
    }
  }
}
