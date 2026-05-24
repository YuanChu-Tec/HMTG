import { connection } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 网络状态监控服务
 * 监听网络连接状态变化
 */
export class NetworkMonitor {
  private static instance: NetworkMonitor;
  private networkStateChangeListener?: (isConnected: boolean) => void;
  private _isConnected: boolean = true;

  private static readonly TAG = 'NetworkMonitor';
  private static readonly DOMAIN = 0x0001;

  private constructor() {}

  public static getInstance(): NetworkMonitor {
    if (!NetworkMonitor.instance) {
      NetworkMonitor.instance = new NetworkMonitor();
    }
    return NetworkMonitor.instance;
  }

  /**
   * 初始化网络监控
   */
  public async initialize(): Promise<void> {
    try {
      // 获取默认网络
      const netConnection = connection.getDefaultNet();
      // 注意: API已变更,需要检查连接可用性

      // 监听网络状态变化（暂不实现，等待API确认）
      // connection.on('networkAvailable', (data: connection.NetHandle) => {
      //   this._isConnected = true;
      //   this.notifyListeners();
      // });

      // connection.on('networkLost', (data: void) => {
      //   this._isConnected = false;
      //   this.notifyListeners();
      // });

      hilog.info(NetworkMonitor.DOMAIN, NetworkMonitor.TAG,
        `Network monitor initialized, current status: ${this._isConnected}`);
    } catch (error) {
      const err = error as Error;
      hilog.error(NetworkMonitor.DOMAIN, NetworkMonitor.TAG,
        `Failed to initialize network monitor: ${err.message}`);
    }
  }

  /**
   * 获取当前网络连接状态
   */
  public isConnected(): boolean {
    return this._isConnected;
  }

  /**
   * 注册网络状态变化监听器
   */
  public onNetworkStateChange(listener: (isConnected: boolean) => void): void {
    this.networkStateChangeListener = listener;
    // 立即通知当前状态
    listener(this._isConnected);
  }

  /**
   * 移除监听器
   */
  public removeListener(): void {
    this.networkStateChangeListener = undefined;
  }

  /**
   * 通知所有监听器
   */
  private notifyListeners(): void {
    if (this.networkStateChangeListener) {
      this.networkStateChangeListener(this._isConnected);
    }
  }

  /**
   * 销毁网络监控
   */
  public destroy(): void {
    this.networkStateChangeListener = undefined;
    hilog.info(NetworkMonitor.DOMAIN, NetworkMonitor.TAG, 'Network monitor destroyed');
  }
}
