/**
 * 网络监听服务（华为最佳实践：弱网适配与网络连接管理）
 * - 使用 @ohos.net.connection 监听 netAvailable/netLost/netUnavailable
 * - 通过 bearerTypes 判断网络类型（WiFi/蜂窝/以太网），弱网时 isWeakNetwork=true
 * - 发送 hmtg_network_status_changed 事件，供 TDLib 等模块在断网时清理代理资源
 * 参考：HarmonyOS 网络连接管理、弱网适配最佳实践、GET_NETWORK_INFO 权限
 */
import connection from '@ohos.net.connection';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { emitter } from '@kit.BasicServicesKit';

const TAG = 'NetworkMonitorService';
const DOMAIN = 0x0001;

/** 网络类型 */
export enum NetworkType {
  /** 无网络 */
  NONE = 0,
  /** WiFi */
  WIFI = 1,
  /** 蜂窝网络（2G/3G/4G/5G） */
  CELLULAR = 2,
  /** 以太网 */
  ETHERNET = 3,
  /** 未知 */
  UNKNOWN = 4
}

/** 网络状态变化事件载荷 */
export interface NetworkStatusPayload {
  isConnected: boolean;
  networkType: NetworkType;
  /** 是否为弱网（蜂窝网络或信号较弱） */
  isWeakNetwork: boolean;
}

export class NetworkMonitorService {
  private static instance: NetworkMonitorService | null = null;
  private currentNetworkType: NetworkType = NetworkType.UNKNOWN;
  private isConnected: boolean = false;
  private netConnection: connection.NetConnection | null = null;

  private constructor() {
    // 私有构造函数，单例模式
  }

  public static getInstance(): NetworkMonitorService {
    if (!NetworkMonitorService.instance) {
      NetworkMonitorService.instance = new NetworkMonitorService();
    }
    return NetworkMonitorService.instance;
  }

  /**
   * 初始化网络监听（应用启动时调用）
   * 华为最佳实践：在 UIAbility onCreate 中初始化
   */
  public async initialize(): Promise<void> {
    try {
      // 创建网络连接监听（使用默认网络）
      this.netConnection = connection.createNetConnection();

      // 注册网络状态变化监听
      this.netConnection.on('netAvailable', (data: connection.NetHandle) => {
        const netHandleObj: Record<string, Object> = {};
        netHandleObj['netHandle'] = data;
        this.handleNetworkAvailable(netHandleObj);
      });

      this.netConnection.on('netLost', (data: connection.NetHandle) => {
        const netHandleObj: Record<string, Object> = {};
        netHandleObj['netHandle'] = data;
        this.handleNetworkLost(netHandleObj);
      });

      this.netConnection.on('netUnavailable', () => {
        this.handleNetworkUnavailable();
      });

      // 注册监听（需要传入回调函数）
      this.netConnection.register((err: Error | null) => {
        if (err) {
          hilog.error(DOMAIN, TAG, `Failed to register net connection: ${JSON.stringify(err)}`);
        } else {
          hilog.info(DOMAIN, TAG, 'Net connection registered successfully');
        }
      });

      // 获取当前网络状态
      connection.getDefaultNet((err: Error | null, netHandle: connection.NetHandle | null) => {
        if (err) {
          hilog.error(DOMAIN, TAG, `Failed to get default net: ${JSON.stringify(err)}`);
          return;
        }
        if (netHandle) {
          connection.getNetCapabilities(netHandle, (err2: Error | null, netCapabilities: connection.NetCapabilities | null) => {
            if (err2) {
              hilog.error(DOMAIN, TAG, `Failed to get net capabilities: ${JSON.stringify(err2)}`);
              return;
            }
            if (netCapabilities) {
              this.updateNetworkStatus(netCapabilities);
            }
          });
        }
      });

      hilog.info(DOMAIN, TAG, 'NetworkMonitorService initialized');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to initialize NetworkMonitorService: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 处理网络可用
   */
  private handleNetworkAvailable(data: Record<string, Object>): void {
    try {
      const netHandle = data['netHandle'] as connection.NetHandle | undefined;
      if (netHandle) {
        connection.getNetCapabilities(netHandle, (err: Error | null, netCapabilities: connection.NetCapabilities | null) => {
          if (err) {
            hilog.error(DOMAIN, TAG, `Failed to get net capabilities: ${JSON.stringify(err)}`);
            return;
          }
          if (netCapabilities) {
            this.updateNetworkStatus(netCapabilities);
          }
        });
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Error handling network available: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 处理网络丢失
   */
  private handleNetworkLost(data: Record<string, Object>): void {
    try {
      this.isConnected = false;
      this.currentNetworkType = NetworkType.NONE;
      this.emitNetworkStatusChange();
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Error handling network lost: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 处理网络不可用
   */
  private handleNetworkUnavailable(): void {
    try {
      this.isConnected = false;
      this.currentNetworkType = NetworkType.NONE;
      this.emitNetworkStatusChange();
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Error handling network unavailable: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 更新网络状态
   */
  private updateNetworkStatus(netCapabilities: connection.NetCapabilities): void {
    // 华为最佳实践：通过 bearerTypes 判断网络类型
    const bearerTypes = netCapabilities.bearerTypes;
    if (!bearerTypes || bearerTypes.length === 0) {
      this.isConnected = false;
      this.currentNetworkType = NetworkType.NONE;
      this.emitNetworkStatusChange();
      return;
    }

    // 网络已连接
    this.isConnected = true;

    // 判断网络类型（优先 WiFi，然后是蜂窝网络，最后是以太网）
    if (bearerTypes.includes(connection.NetBearType.BEARER_WIFI)) {
      this.currentNetworkType = NetworkType.WIFI;
    } else if (bearerTypes.includes(connection.NetBearType.BEARER_CELLULAR)) {
      this.currentNetworkType = NetworkType.CELLULAR;
    } else if (bearerTypes.includes(connection.NetBearType.BEARER_ETHERNET)) {
      this.currentNetworkType = NetworkType.ETHERNET;
    } else {
      this.currentNetworkType = NetworkType.UNKNOWN;
    }

    this.emitNetworkStatusChange();
  }

  /**
   * 发送网络状态变化事件
   */
  private emitNetworkStatusChange(): void {
    const payload: NetworkStatusPayload = {
      isConnected: this.isConnected,
      networkType: this.currentNetworkType,
      isWeakNetwork: this.isWeakNetwork()
    };

    hilog.info(DOMAIN, TAG, `Network status changed: connected=${this.isConnected}, type=${this.currentNetworkType}, weak=${payload.isWeakNetwork}`);

    // 发送事件
    emitter.emit('hmtg_network_status_changed', { priority: emitter.EventPriority.HIGH }, { data: payload });
  }

  /**
   * 判断是否为弱网
   * 华为最佳实践：蜂窝网络或信号较弱时视为弱网
   */
  private isWeakNetwork(): boolean {
    return !this.isConnected || this.currentNetworkType === NetworkType.CELLULAR;
  }

  /**
   * 获取当前网络类型
   */
  public getNetworkType(): NetworkType {
    return this.currentNetworkType;
  }

  /**
   * 是否已连接网络
   */
  public isNetworkConnected(): boolean {
    return this.isConnected;
  }

  /**
   * 是否为弱网
   */
  public isWeakNetworkNow(): boolean {
    return this.isWeakNetwork();
  }

  /**
   * 清理资源（应用退出时调用）
   */
  public dispose(): void {
    if (this.netConnection) {
      try {
        this.netConnection.unregister((err: Error | null) => {
          if (err) {
            hilog.error(DOMAIN, TAG, `Failed to unregister net connection: ${JSON.stringify(err)}`);
          }
        });
        this.netConnection = null;
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Failed to unregister net connection: ${JSON.stringify(error)}`);
      }
    }
    hilog.info(DOMAIN, TAG, 'NetworkMonitorService disposed');
  }
}
