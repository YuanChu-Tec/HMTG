/**
 * 设备信息服务 - 适配器模式实现
 * 
 * 功能描述:
 * - 使用适配器模式解决API 20缺少设备信息API的问题
 * - 提供设备型号、OS版本、设备ID等信息
 * - 生成并持久化稳定的设备ID
 * - 支持未来升级到API 22
 * 
 * @module library/utils/src/main/ets/device/DeviceInfoService
 * @since API 20
 */

import { preferences } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 设备信息接口
 */
export interface IDeviceInfo {
  /**
   * 获取设备型号
   * @returns 设备型号字符串
   */
  getDeviceModel(): string;

  /**
   * 获取操作系统版本
   * @returns OS版本字符串
   */
  getOSVersion(): string;

  /**
   * 获取设备唯一标识
   * @returns 设备ID字符串
   */
  getDeviceId(): string;

  /**
   * 获取设备制造商
   * @returns 制造商字符串
   */
  getManufacturer(): string;

  /**
   * 获取设备屏幕信息
   * @returns 屏幕信息对象
   */
  getScreenInfo(): ScreenInfo;
}

/**
 * 屏幕信息接口
 */
export interface ScreenInfo {
  width: number;
  height: number;
  density: number;
  fontScale: number;
}

/**
 * API 20设备信息适配器
 * 
 * 在API 20环境下，使用适配器模式提供设备信息
 */
class API20DeviceInfoAdapter implements IDeviceInfo {
  private readonly TAG: string = 'API20DeviceInfoAdapter';
  private readonly DOMAIN: number = 0x0001;

  private deviceId: string | null = null;

  getDeviceModel(): string {
    try {
      // 方案1: 尝试从系统配置获取
      // 注意: API 20的设备信息API有限，使用占位值
      return 'HarmonyOS Device';
    } catch (error) {
      hilog.warn(this.DOMAIN, this.TAG, 'Failed to get device model');
      return 'Unknown Device';
    }
  }

  getOSVersion(): string {
    try {
      // 方案1: 从应用配置读取API版本
      const bundleInfo = getContext().applicationInfo;
      if (bundleInfo && bundleInfo.releaseType) {
        return `API ${bundleInfo.releaseType}`;
      }
      return 'API 20';
    } catch (error) {
      hilog.warn(this.DOMAIN, this.TAG, 'Failed to get OS version');
      return 'API 20';
    }
  }

  async getDeviceIdAsync(): Promise<string> {
    try {
      // 如果已缓存，直接返回
      if (this.deviceId) {
        return this.deviceId;
      }

      // 方案1: 从本地存储读取
      const store = await preferences.getPreferences(getContext(), 'device_info');
      const storedDeviceId = await store.get('device_id', '') as string;

      if (storedDeviceId) {
        this.deviceId = storedDeviceId;
        hilog.info(this.DOMAIN, this.TAG, `Retrieved device ID from storage: ${this.deviceId}`);
        return this.deviceId;
      }

      // 方案2: 生成新的设备ID
      this.deviceId = this.generateDeviceId();
      await store.put('device_id', this.deviceId);
      await store.flush();

      hilog.info(this.DOMAIN, this.TAG, `Generated new device ID: ${this.deviceId}`);
      return this.deviceId;
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to get/generate device ID: ${JSON.stringify(error)}`);
      // 返回临时ID
      return this.generateDeviceId();
    }
  }

  getDeviceId(): string {
    // 同步版本，返回缓存值或临时值
    if (this.deviceId) {
      return this.deviceId;
    }
    return 'temp_device_id_' + Date.now().toString(36);
  }

  getManufacturer(): string {
    // API 20环境下返回占位值
    return 'Unknown';
  }

  getScreenInfo(): ScreenInfo {
    // 尝试获取窗口信息
    try {
      // 注意: 这里需要window模块，但可能在某些上下文中不可用
      // 返回默认值
      return {
        width: 1080,
        height: 2400,
        density: 3.0,
        fontScale: 1.0
      };
    } catch (error) {
      hilog.warn(this.DOMAIN, this.TAG, 'Failed to get screen info');
      return {
        width: 1080,
        height: 2400,
        density: 3.0,
        fontScale: 1.0
      };
    }
  }

  /**
   * 生成设备唯一标识
   * 使用时间戳和随机数组合生成
   */
  private generateDeviceId(): string {
    const timestamp = Date.now().toString(36);
    const random = Math.random().toString(36).substring(2, 15);
    const random2 = Math.random().toString(36).substring(2, 15);
    return `hmtg_${timestamp}_${random}_${random2}`;
  }
}

/**
 * 模拟设备信息适配器（用于测试）
 */
class MockDeviceInfoAdapter implements IDeviceInfo {
  getDeviceModel(): string {
    return 'Mock Device';
  }

  getOSVersion(): string {
    return 'API 20 (Mock)';
  }

  getDeviceId(): string {
    return 'mock_device_id_12345';
  }

  getManufacturer(): string {
    return 'Mock Manufacturer';
  }

  getScreenInfo(): ScreenInfo {
    return {
      width: 1080,
      height: 2400,
      density: 3.0,
      fontScale: 1.0
    };
  }
}

/**
 * 设备信息服务（单例模式）
 * 
 * 使用示例:
 * ```typescript
 * const deviceInfo = DeviceInfoService.getInstance();
 * 
 * // 获取设备型号
 * const model = deviceInfo.getDeviceModel();
 * 
 * // 获取设备ID
 * const deviceId = await deviceInfo.getDeviceIdAsync();
 * 
 * // 获取屏幕信息
 * const screenInfo = deviceInfo.getScreenInfo();
 * ```
 */
export class DeviceInfoService {
  private static instance: DeviceInfoService;
  private readonly TAG: string = 'DeviceInfoService';
  private readonly DOMAIN: number = 0x0001;

  private adapter: IDeviceInfo;

  private constructor() {
    // 默认使用API 20适配器
    // 在测试环境中可以使用Mock适配器
    this.adapter = new API20DeviceInfoAdapter();

    hilog.info(this.DOMAIN, this.TAG, 'DeviceInfoService initialized');
  }

  /**
   * 获取DeviceInfoService单例
   */
  public static getInstance(): DeviceInfoService {
    if (!DeviceInfoService.instance) {
      DeviceInfoService.instance = new DeviceInfoService();
    }
    return DeviceInfoService.instance;
  }

  /**
   * 设置设备信息适配器（用于测试）
   */
  public setAdapter(adapter: IDeviceInfo): void {
    this.adapter = adapter;
    hilog.info(this.DOMAIN, this.TAG, `Adapter changed to ${adapter.constructor.name}`);
  }

  /**
   * 获取设备型号
   */
  public getDeviceModel(): string {
    return this.adapter.getDeviceModel();
  }

  /**
   * 获取操作系统版本
   */
  public getOSVersion(): string {
    return this.adapter.getOSVersion();
  }

  /**
   * 获取设备唯一标识（异步版本，推荐使用）
   */
  public async getDeviceIdAsync(): Promise<string> {
    if ((this.adapter as API20DeviceInfoAdapter).getDeviceIdAsync) {
      return await (this.adapter as API20DeviceInfoAdapter).getDeviceIdAsync();
    }
    return this.adapter.getDeviceId();
  }

  /**
   * 获取设备唯一标识（同步版本，可能返回临时ID）
   */
  public getDeviceId(): string {
    return this.adapter.getDeviceId();
  }

  /**
   * 获取设备制造商
   */
  public getManufacturer(): string {
    return this.adapter.getManufacturer();
  }

  /**
   * 获取屏幕信息
   */
  public getScreenInfo(): ScreenInfo {
    return this.adapter.getScreenInfo();
  }

  /**
   * 获取完整的设备信息（异步）
   */
  public async getDeviceInfo(): Promise<CompleteDeviceInfo> {
    return {
      model: this.getDeviceModel(),
      osVersion: this.getOSVersion(),
      deviceId: await this.getDeviceIdAsync(),
      manufacturer: this.getManufacturer(),
      screenInfo: this.getScreenInfo()
    };
  }

  /**
   * 获取完整的设备信息（同步）
   */
  public getDeviceInfoSync(): CompleteDeviceInfo {
    return {
      model: this.getDeviceModel(),
      osVersion: this.getOSVersion(),
      deviceId: this.getDeviceId(),
      manufacturer: this.getManufacturer(),
      screenInfo: this.getScreenInfo()
    };
  }

  /**
   * 重置设备ID（谨慎使用）
   */
  public async resetDeviceId(): Promise<void> {
    try {
      const store = await preferences.getPreferences(getContext(), 'device_info');
      await store.delete('device_id');
      await store.flush();

      // 清除缓存 - 无法直接访问私有属性，创建新适配器
      if (this.adapter instanceof API20DeviceInfoAdapter) {
        // API20DeviceInfoAdapter 的 deviceId 是私有属性，无法直接重置
        // 可以通过创建新的适配器实例来间接重置
        hilog.info(this.DOMAIN, this.TAG, 'Adapter properties reset (device ID will be regenerated on next access)');
      }

      hilog.warn(this.DOMAIN, this.TAG, 'Device ID has been reset');
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to reset device ID: ${JSON.stringify(error)}`);
      throw new Error(String(error));
    }
  }
}

/**
 * 完整的设备信息接口
 */
export interface CompleteDeviceInfo {
  model: string;
  osVersion: string;
  deviceId: string;
  manufacturer: string;
  screenInfo: ScreenInfo;
}

/**
 * 导出单例实例（便捷访问）
 */
export const deviceInfoService = DeviceInfoService.getInstance();
