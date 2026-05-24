/**
 * 网络优化工具类
 * 华为最佳实践：网络请求优化、弱网适配、并发控制
 * 参考官方文档：https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-net-connection
 */
import connection from '@ohos.net.connection';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0001;
const TAG = 'NetworkOptimizer';

/**
 * 网络类型
 */
export enum NetworkType {
  /** 无网络 */
  NONE = 'none',
  /** WiFi */
  WIFI = 'wifi',
  /** 蜂窝网络 */
  CELLULAR = 'cellular',
  /** 以太网 */
  ETHERNET = 'ethernet',
  /** 未知 */
  UNKNOWN = 'unknown'
}

/**
 * 网络状态信息
 */
export interface NetworkState {
  /** 是否连接 */
  connected: boolean;
  /** 网络类型 */
  type: NetworkType;
  /** 是否计费网络 */
  metered: boolean;
}

/**
 * 网络优化工具类
 * 提供网络状态监听、弱网检测、请求优化等功能
 */
export class NetworkOptimizer {
  private static instance: NetworkOptimizer;
  private networkState: NetworkState = {
    connected: true,
    type: NetworkType.UNKNOWN,
    metered: false
  };
  private listeners: Set<(state: NetworkState) => void> = new Set();
  private netConnection: connection.NetConnection | null = null;

  private constructor() {
    this.initNetworkListener();
  }

  public static getInstance(): NetworkOptimizer {
    if (!NetworkOptimizer.instance) {
      NetworkOptimizer.instance = new NetworkOptimizer();
    }
    return NetworkOptimizer.instance;
  }

  /**
   * 初始化网络状态监听（华为最佳实践：监听网络变化）
   */
  private async initNetworkListener(): Promise<void> {
    try {
      // 创建网络连接监听（使用默认网络）
      this.netConnection = connection.createNetConnection();

      // 监听网络状态变化
      this.netConnection.on('netAvailable', (data: connection.NetHandle) => {
        hilog.info(DOMAIN, TAG, 'Network available');
        this.handleNetworkAvailable(data);
      });

      this.netConnection.on('netLost', (data: connection.NetHandle) => {
        hilog.warn(DOMAIN, TAG, 'Network lost');
        this.updateNetworkState(false);
      });

      this.netConnection.on('netUnavailable', () => {
        hilog.warn(DOMAIN, TAG, 'Network unavailable');
        this.updateNetworkState(false);
      });

      // 注册监听（需要传入回调函数）
      this.netConnection.register((err: Error | null) => {
        if (err) {
          hilog.error(DOMAIN, TAG, 'Failed to register net connection: %{public}s', JSON.stringify(err));
        } else {
          hilog.info(DOMAIN, TAG, 'Net connection registered successfully');
          this.refreshNetworkState();
        }
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to init network listener: %{public}s', JSON.stringify(error));
    }
  }

  /**
   * 处理网络可用
   */
  private handleNetworkAvailable(netHandle: connection.NetHandle): void {
    connection.getNetCapabilities(netHandle, (err: Error | null, netCapabilities: connection.NetCapabilities | null) => {
      if (err) {
        hilog.error(DOMAIN, TAG, 'Failed to get net capabilities: %{public}s', JSON.stringify(err));
        return;
      }
      if (netCapabilities) {
        this.updateNetworkStateFromCapabilities(netCapabilities);
      }
    });
  }

  /**
   * 刷新网络状态
   */
  private refreshNetworkState(): void {
    connection.getDefaultNet((err: Error | null, netHandle: connection.NetHandle | null) => {
      if (err || !netHandle) {
        this.updateNetworkState(false);
        return;
      }
      connection.getNetCapabilities(netHandle, (err2: Error | null, netCapabilities: connection.NetCapabilities | null) => {
        if (err2 || !netCapabilities) {
          this.updateNetworkState(false);
          return;
        }
        this.updateNetworkStateFromCapabilities(netCapabilities);
      });
    });
  }

  /**
   * 从网络能力更新网络状态
   */
  private updateNetworkStateFromCapabilities(netCapabilities: connection.NetCapabilities): void {
    const bearerTypes = netCapabilities.bearerTypes;
    if (!bearerTypes || bearerTypes.length === 0) {
      this.updateNetworkState(false);
      return;
    }

    // 网络已连接
    let networkType = NetworkType.UNKNOWN;
    if (bearerTypes.includes(connection.NetBearType.BEARER_WIFI)) {
      networkType = NetworkType.WIFI;
    } else if (bearerTypes.includes(connection.NetBearType.BEARER_CELLULAR)) {
      networkType = NetworkType.CELLULAR;
    } else if (bearerTypes.includes(connection.NetBearType.BEARER_ETHERNET)) {
      networkType = NetworkType.ETHERNET;
    }

    // 判断是否为计费网络（蜂窝网络通常为计费网络）
    // 注意：NetCapabilities API 可能不直接提供 metered 信息，这里通过网络类型判断
    const metered = networkType === NetworkType.CELLULAR;

    this.networkState = {
      connected: true,
      type: networkType,
      metered: metered
    };

    this.notifyListeners();
  }

  /**
   * 更新网络状态
   */
  private updateNetworkState(connected: boolean): void {
    this.networkState.connected = connected;
    if (!connected) {
      this.networkState.type = NetworkType.NONE;
    }
    this.notifyListeners();
    this.refreshNetworkState();
  }

  /**
   * 通知所有监听器
   */
  private notifyListeners(): void {
    this.listeners.forEach(listener => {
      try {
        listener(this.networkState);
      } catch (error) {
        hilog.error(DOMAIN, TAG, 'Listener error: %{public}s', JSON.stringify(error));
      }
    });
  }

  /**
   * 添加网络状态监听器
   */
  public addListener(listener: (state: NetworkState) => void): void {
    this.listeners.add(listener);
    // 立即通知当前状态
    listener(this.networkState);
  }

  /**
   * 移除网络状态监听器
   */
  public removeListener(listener: (state: NetworkState) => void): void {
    this.listeners.delete(listener);
  }

  /**
   * 获取当前网络状态
   */
  public getNetworkState(): NetworkState {
    return {
      connected: this.networkState.connected,
      type: this.networkState.type,
      metered: this.networkState.metered
    };
  }

  /**
   * 是否已连接网络
   */
  public isConnected(): boolean {
    return this.networkState.connected;
  }

  /**
   * 是否为 WiFi 网络
   */
  public isWifi(): boolean {
    return this.networkState.type === NetworkType.WIFI;
  }

  /**
   * 是否为计费网络（蜂窝网络）
   */
  public isMetered(): boolean {
    return this.networkState.metered;
  }

  /**
   * 是否为弱网环境（非 WiFi 或未连接）
   * 华为最佳实践：弱网时减少大流量请求
   */
  public isWeakNetwork(): boolean {
    return !this.networkState.connected || this.networkState.type !== NetworkType.WIFI;
  }

  /**
   * 根据网络状态获取请求超时时间（毫秒）
   * 华为最佳实践：弱网时增加超时时间
   */
  public getRequestTimeout(): number {
    if (!this.networkState.connected) {
      return 30000; // 无网络：30秒
    }
    if (this.isWeakNetwork()) {
      return 20000; // 弱网：20秒
    }
    return 10000; // WiFi：10秒
  }

  /**
   * 根据网络状态判断是否应该下载大文件
   * 华为最佳实践：计费网络时限制大文件下载
   */
  public shouldDownloadLargeFile(fileSize: number, maxSizeOnMetered: number = 10 * 1024 * 1024): boolean {
    if (!this.networkState.connected) {
      return false;
    }
    if (this.isMetered() && fileSize > maxSizeOnMetered) {
      return false; // 计费网络时限制大文件下载
    }
    return true;
  }

  /**
   * 清理资源
   */
  public dispose(): void {
    if (this.netConnection) {
      this.netConnection.unregister((err: Error | null) => {
        if (err) {
          hilog.error(DOMAIN, TAG, 'Failed to unregister net connection: %{public}s', JSON.stringify(err));
        }
      });
      this.netConnection = null;
    }
    this.listeners.clear();
  }
}
