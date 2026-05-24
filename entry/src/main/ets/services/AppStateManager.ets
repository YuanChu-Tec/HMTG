/**
 * 应用全局状态管理器
 * 职责：
 * - 管理应用启动的各个阶段（状态机）
 * - 协调核心服务（主题、认证、聊天）的初始化时序
 * - 提供全局就绪信号，供 UI 层订阅
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { EventBus } from '../utils/event/EventBus';
import { ThemeService } from './business/ThemeService';
import { CoreService } from './business/CoreService';
import { UpdateService } from './business/UpdateService';
import { FileDownloadService } from './business/FileDownloadService';
import { TDLibClient } from './core/tdlib/TDLibClient';
import { TDLibAuthManager } from './core/tdlib/TDLibAuthManager';
import type { common } from '@kit.AbilityKit';

const TAG = 'AppStateManager';
const DOMAIN = 0x0001;

/**
 * 应用启动状态枚举
 */
export enum AppState {
  /** 初始状态：应用刚启动 */
  INIT = 'INIT',
  /** 主题加载完成：UI 可以开始渲染基础框架 */
  THEME_READY = 'THEME_READY',
  /** 认证检查完成：确定用户是否已登录 */
  AUTH_CHECKED = 'AUTH_CHECKED',
  /** TDLib 连接成功：底层通信库已就绪 */
  TD_LIB_READY = 'TD_LIB_READY',
  /** 数据同步完成：聊天列表已首次加载，应用完全可用 */
  DATA_SYNCED = 'DATA_SYNCED',
  /** 错误状态：启动过程中发生不可恢复错误 */
  ERROR = 'ERROR'
}

/**
 * 状态变更事件负载
 */
export interface StateChangeEvent {
  from: AppState;
  to: AppState;
  timestamp: number;
}

export class AppStateManager {
  private static instance: AppStateManager;
  private currentState: AppState = AppState.INIT;
  private eventBus = EventBus.getInstance();
  private context?: common.Context;

  private constructor() {}

  public static getInstance(): AppStateManager {
    if (!AppStateManager.instance) {
      AppStateManager.instance = new AppStateManager();
    }
    return AppStateManager.instance;
  }

  /**
   * 初始化应用状态机
   * 注意:该方法只能调用一次,重复调用会被忽略
   */
  public async initialize(context: common.Context): Promise<void> {
    // 防止重复初始化:如果状态已经不是 INIT,说明已经初始化过或正在初始化中
    if (this.currentState !== AppState.INIT && this.currentState !== AppState.ERROR) {
      hilog.warn(DOMAIN, TAG, `⚠️ initialize() called but current state is ${this.currentState}, ignoring duplicate call`);
      return;
    }

    this.context = context;
    this.transitionTo(AppState.INIT);

    try {
      // 第一阶段：初始化主题（最优先，确保 UI 颜色正确）
      await this.initTheme();
      
      // ⭐ 第二阶段：等待 TDLib Worker 初始化完成
      hilog.info(DOMAIN, TAG, '⏳ Waiting for TDLib Worker to be ready...');
      await this.waitForTDLibReady();
      hilog.info(DOMAIN, TAG, '✅ TDLib Worker is ready');
      
      // ⭐ 关键：在检查认证状态之前，先初始化 CoreService 和 UpdateService
      // 这样 TDLibAuthManager 才能收到 core:authReady 事件
      hilog.info(DOMAIN, TAG, '⏳ Initializing CoreService and UpdateService...');
      CoreService.getInstance(this.context);
      new UpdateService(); // 创建 UpdateService 实例，它会订阅所有 TDLib 更新
      hilog.info(DOMAIN, TAG, '✅ CoreService and UpdateService initialized');
      
      // 第三阶段：检查认证状态（Worker 就绪后才能准确检查）
      await this.checkAuth();

      // 第四阶段：如果已登录，启动核心业务服务
      const authManager = TDLibAuthManager.getInstance();
      const isLoggedIn = authManager.isReady();
      hilog.info(DOMAIN, TAG, `🔐 After auth check: isLoggedIn=${isLoggedIn}`);
      
      if (isLoggedIn) {
        hilog.info(DOMAIN, TAG, '✅ User is logged in, starting core services...');
        await this.startCoreServices();
      } else {
        hilog.info(DOMAIN, TAG, 'ℹ️ User is NOT logged in, skipping core services');
        // 未登录则直接进入待登录状态
        this.transitionTo(AppState.AUTH_CHECKED);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Initialization failed: ${JSON.stringify(error)}`);
      this.transitionTo(AppState.ERROR);
    }
  }

  /**
   * ⭐ 等待 TDLib Worker 就绪
   * 确保 Worker 初始化完成后再进行后续操作
   */
  private async waitForTDLibReady(): Promise<void> {
    try {
      hilog.info(DOMAIN, TAG, '⏳ Waiting for TDLib Worker to be ready...');
      
      // 使用 TDLibClient 的 getReadyPromise 等待 Worker 真正就绪
      // 这比检查 AuthService.isInitialized 更准确
      await TDLibClient.getInstance().getReadyPromise();
      
      hilog.info(DOMAIN, TAG, '✅ TDLib Worker is ready');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to wait for TDLib Worker: ${JSON.stringify(error)}`);
      // 即使出错也继续，避免卡住启动流程
    }
  }

  /**
   * 获取当前状态
   */
  public getState(): AppState {
    return this.currentState;
  }

  /**
   * 判断应用是否已完全就绪
   */
  public isFullyReady(): boolean {
    return this.currentState === AppState.DATA_SYNCED || 
           (this.currentState === AppState.AUTH_CHECKED && !TDLibAuthManager.getInstance().isReady());
  }

  /**
   * 状态转换逻辑
   */
  private transitionTo(newState: AppState): void {
    const oldState = this.currentState;
    if (oldState === newState) return;

    this.currentState = newState;
    hilog.info(DOMAIN, TAG, `🔄 State changed: ${oldState} -> ${newState}`);

    // 发布状态变更事件
    const event: StateChangeEvent = {
      from: oldState,
      to: newState,
      timestamp: Date.now()
    };
    this.eventBus.emit('appStateChanged', event);
  }

  // ==================== 内部初始化步骤 ====================

  private async initTheme(): Promise<void> {
    hilog.info(DOMAIN, TAG, '⏳ Initializing ThemeService...');
    // 假设 ThemeService 需要同步配置
    ThemeService.getInstance(); 
    this.transitionTo(AppState.THEME_READY);
  }

  private async checkAuth(): Promise<void> {
    hilog.info(DOMAIN, TAG, '⏳ Checking authentication status...');

    // ⭐ 关键修复：不等待授权完成，而是等待授权状态确定
    // 等待一小段时间让 TDLib 状态初始化，然后检查当前状态
    await this.waitForAuthStateDetermined();

    const authManager = TDLibAuthManager.getInstance();
    const isLoggedIn = authManager.isReady();
    hilog.info(DOMAIN, TAG, `🔐 Auth check result: isLoggedIn=${isLoggedIn}, authState=${authManager.getAuthState()}`);

    // 无论是否已登录，都进入 AUTH_CHECKED 状态
    // 如果未登录，Index 页面会处理跳转到登录流程
    this.transitionTo(AppState.AUTH_CHECKED);
  }

  /**
   * ⭐ 等待授权状态确定（关键修复）
   * 不等待授权完成，而是等待 TDLib 返回一个明确的状态
   * 如果用户未登录，状态会是 WAIT_PHONE_NUMBER，这也算"确定"的状态
   */
  private async waitForAuthStateDetermined(): Promise<void> {
    const authManager = TDLibAuthManager.getInstance();

    // 如果已经授权完成，直接返回
    if (authManager.isReady()) {
      hilog.info(DOMAIN, TAG, '✅ Already authorized');
      return;
    }

    // 等待一段时间让 TDLib 状态初始化
    // 使用轮询检查状态是否从初始状态变化
    const maxWaitTime = 5000; // 最多等待 5 秒
    const checkInterval = 100; // 每 100ms 检查一次
    const startTime = Date.now();

    return new Promise((resolve) => {
      const checkState = () => {
        const currentState = authManager.getAuthState();

        // 如果已经授权完成
        if (authManager.isReady()) {
          hilog.info(DOMAIN, TAG, '✅ Auth state determined: authorized');
          resolve();
          return;
        }

        // 如果状态表明需要登录（非初始状态），也算确定状态
        if (currentState !== 'authorizationStateWaitTdlibParameters' &&
            currentState !== 'authorizationStateWaitEncryptionKey') {
          hilog.info(DOMAIN, TAG, `✅ Auth state determined: ${currentState} (needs login)`);
          resolve();
          return;
        }

        // 检查是否超时
        if (Date.now() - startTime >= maxWaitTime) {
          hilog.warn(DOMAIN, TAG, '⚠️ Auth state check timeout, proceeding anyway');
          resolve();
          return;
        }

        // 继续等待
        setTimeout(checkState, checkInterval);
      };

      // 开始检查
      checkState();
    });
  }

  /**
   * ⭐ 启动核心服务（已登录用户）
   * 公开方法，允许外部触发（如 Index 页面在延迟检测到登录状态后调用）
   */
  public async startCoreServices(): Promise<void> {
    hilog.info(DOMAIN, TAG, '⏳ Starting Core Services...');
    
    // 注意：CoreService 和 UpdateService 已经在 initialize() 中初始化
    // 这里只需要等待 TDLib 就绪并设置文件下载服务
    const authManager = TDLibAuthManager.getInstance();
    
    if (authManager.isReady()) {
      // TDLib 已经就绪，直接转换状态
      this.transitionTo(AppState.TD_LIB_READY);
      
      if (this.context) {
        // 初始化并注入文件下载服务
        try {
          const fileDownloadService = FileDownloadService.getInstance(this.context);
          CoreService.getInstance().setFileDownloadService(fileDownloadService);
          hilog.info(DOMAIN, TAG, '✅ FileDownloadService injected');
        } catch (error) {
          hilog.error(DOMAIN, TAG, `Failed to inject FileDownloadService: ${JSON.stringify(error)}`);
        }
      }
      
      // 监听聊天列表首次同步完成
      this.eventBus.once('CoreServiceReady', () => {
        this.transitionTo(AppState.DATA_SYNCED);
        hilog.info(DOMAIN, TAG, '✅ Application is fully ready!');
      });
    } else {
      // 等待 TDLib 就绪
      authManager.executeWhenReady(() => {
        this.transitionTo(AppState.TD_LIB_READY);
        
        if (this.context) {
          try {
            const fileDownloadService = FileDownloadService.getInstance(this.context);
            CoreService.getInstance().setFileDownloadService(fileDownloadService);
            hilog.info(DOMAIN, TAG, '✅ FileDownloadService injected');
          } catch (error) {
            hilog.error(DOMAIN, TAG, `Failed to inject FileDownloadService: ${JSON.stringify(error)}`);
          }
        }
        
        // 监听聊天列表首次同步完成
        this.eventBus.once('CoreServiceReady', () => {
          this.transitionTo(AppState.DATA_SYNCED);
          hilog.info(DOMAIN, TAG, '✅ Application is fully ready!');
        });
      }, 'AppStateManager core startup');
    }
  }
}
