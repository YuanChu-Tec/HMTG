import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'AppStore';
const DOMAIN = 0x0001;

/**
 * 应用全局状态管理
 * 使用@Observed和@Track实现响应式状态
 */
interface GeneratedTypeLiteralInterface_1 {
  id: number;
  name: string;
  phone: string;
}

@Observed
export class AppStore {
  private static instance: AppStore;
  // 认证相关状态
  @Track private _isInitialized: boolean = false;
  @Track private _isLoggedIn: boolean = false;
  @Track private _currentUserId: number = 0;
  @Track private _currentUserName: string = '';
  @Track private _currentUserPhone: string = '';
  // 网络状态
  @Track private _networkConnected: boolean = true;
  @Track private _connectionState: string = 'connecting';
  // UI状态
  @Track private _darkMode: boolean = false;
  @Track private _language: string = 'zh-CN';
  @Track private _notificationEnabled: boolean = true;
  // 功能开关
  @Track private _autoDownloadEnabled: boolean = true;
  @Track private _autoPlayGifs: boolean = false;

  private constructor() {
  }

  public static getInstance(): AppStore {
    if (!AppStore.instance) {
      AppStore.instance = new AppStore();
    }
    return AppStore.instance;
  }

  // ========== Getter ==========

  get isInitialized(): boolean {
    return this._isInitialized;
  }

  get isLoggedIn(): boolean {
    return this._isLoggedIn;
  }

  get currentUserId(): number {
    return this._currentUserId;
  }

  get currentUserName(): string {
    return this._currentUserName;
  }

  get currentUserPhone(): string {
    return this._currentUserPhone;
  }

  get networkConnected(): boolean {
    return this._networkConnected;
  }

  get connectionState(): string {
    return this._connectionState;
  }

  get darkMode(): boolean {
    return this._darkMode;
  }

  get language(): string {
    return this._language;
  }

  get notificationEnabled(): boolean {
    return this._notificationEnabled;
  }

  get autoDownloadEnabled(): boolean {
    return this._autoDownloadEnabled;
  }

  get autoPlayGifs(): boolean {
    return this._autoPlayGifs;
  }

  // ========== Setter ==========

  /**
   * 设置初始化状态
   */
  setInitialized(initialized: boolean): void {
    this._isInitialized = initialized;
    hilog.info(DOMAIN, TAG, `Initialized: ${initialized}`);
  }

  /**
   * 设置登录状态
   */
  setLoggedIn(loggedIn: boolean): void {
    this._isLoggedIn = loggedIn;
    hilog.info(DOMAIN, TAG, `Logged in: ${loggedIn}`);
  }

  /**
   * 设置当前用户
   */
  setCurrentUser(userId: number, userName: string, phone: string): void {
    this._currentUserId = userId;
    this._currentUserName = userName;
    this._currentUserPhone = phone;
    hilog.info(DOMAIN, TAG, `User set: ${userId} - ${userName}`);
  }

  /**
   * 设置网络连接状态
   */
  setNetworkConnected(connected: boolean): void {
    this._networkConnected = connected;
    hilog.info(DOMAIN, TAG, `Network connected: ${connected}`);
  }

  /**
   * 设置连接状态
   */
  setConnectionState(state: string): void {
    this._connectionState = state;
    hilog.debug(DOMAIN, TAG, `Connection state: ${state}`);
  }

  /**
   * 设置深色模式
   */
  setDarkMode(dark: boolean): void {
    this._darkMode = dark;
    hilog.info(DOMAIN, TAG, `Dark mode: ${dark}`);
  }

  /**
   * 设置语言
   */
  setLanguage(lang: string): void {
    this._language = lang;
    hilog.info(DOMAIN, TAG, `Language: ${lang}`);
  }

  /**
   * 设置通知开关
   */
  setNotificationEnabled(enabled: boolean): void {
    this._notificationEnabled = enabled;
    hilog.info(DOMAIN, TAG, `Notifications enabled: ${enabled}`);
  }

  /**
   * 设置自动下载开关
   */
  setAutoDownloadEnabled(enabled: boolean): void {
    this._autoDownloadEnabled = enabled;
    hilog.info(DOMAIN, TAG, `Auto download: ${enabled}`);
  }

  /**
   * 设置GIF自动播放
   */
  setAutoPlayGifs(enabled: boolean): void {
    this._autoPlayGifs = enabled;
  }

  // ========== 用户信息 ==========

  /**
   * 检查是否为当前用户
   */
  isCurrentUser(userId: number): boolean {
    return this._currentUserId === userId;
  }

  /**
   * 获取当前用户完整信息
   */
  getCurrentUserInfo(): GeneratedTypeLiteralInterface_1 | null {
    if (this._currentUserId === 0) {
      return null;
    }
    return {
      id: this._currentUserId,
      name: this._currentUserName,
      phone: this._currentUserPhone
    };
  }

  // ========== 重置 ==========

  /**
   * 重置应用状态（登出时调用）
   */
  reset(): void {
    this._isLoggedIn = false;
    this._currentUserId = 0;
    this._currentUserName = '';
    this._currentUserPhone = '';
    hilog.info(DOMAIN, TAG, 'App store reset');
  }

  /**
   * 清除所有数据
   */
  clearAll(): void {
    this._isInitialized = false;
    this._isLoggedIn = false;
    this._currentUserId = 0;
    this._currentUserName = '';
    this._currentUserPhone = '';
    this._darkMode = false;
    this._language = 'zh-CN';
    hilog.info(DOMAIN, TAG, 'App store cleared');
  }
}
