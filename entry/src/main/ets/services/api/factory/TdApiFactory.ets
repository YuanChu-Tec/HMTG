import { TDLibClient } from '../../core/tdlib/TDLibClient';
import { TDLibApi } from '../TDLibApi';

import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'TdApiFactory';
const DOMAIN = 0x0001;

/**
 * TDLib API 类型（直接使用 TDLibApi 类）
 */
export type TDLibAPIs = TDLibApi;

/**
 * TDLib API 工厂
 * 统一创建和管理所有 API 实例
 */
export class TdApiFactory {
  private static instance: TdApiFactory;
  private tdClient: TDLibClient | null = null; // ⭐ 改为可空，延迟初始化
  private apiInstances: TDLibApi | null = null;

  private constructor() {
    // ⚠️ 不在构造函数中初始化 TDLibClient，避免模块加载时崩溃
    // TDLibClient 应该在 EntryAbility 中通过 initialize() 方法初始化
    hilog.info(DOMAIN, TAG, 'TdApiFactory created (lazy initialization)');
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): TdApiFactory {
    if (!TdApiFactory.instance) {
      TdApiFactory.instance = new TdApiFactory();
    }
    return TdApiFactory.instance;
  }

  /**
   * 创建默认的 API 实例集合
   * 使用默认的 TdClient 单例
   * @returns TDLibApi 实例（包含所有方法）
   */
  public createDefault(): TDLibApi {
    // ⭐ 延迟初始化：首次调用时才获取 TDLibClient
    if (!this.tdClient) {
      this.tdClient = TDLibClient.getInstance();
      hilog.info(DOMAIN, TAG, 'TDLibClient lazily initialized');
    }
    
    if (!this.apiInstances) {
      hilog.debug(DOMAIN, TAG, 'Creating default API instance');
      this.apiInstances = new TDLibApi(this.tdClient);
      hilog.info(DOMAIN, TAG, 'Default API instance created');
    }
    return this.apiInstances;
  }

  /**
   * 创建自定义配置的 API 实例
   * @param customTdClient 自定义的 TDLibClient 实例
   * @returns TDLibApi 实例
   */
  public createCustom(customTdClient: TDLibClient): TDLibApi {
    hilog.debug(DOMAIN, TAG, 'Creating custom API instance');
    return new TDLibApi(customTdClient);
  }

  /**
   * 重置 API 实例（强制重新创建）
   */
  public reset(): void {
    hilog.info(DOMAIN, TAG, 'Resetting API instances');
    this.apiInstances = null;
  }

  /**
   * 获取当前 TDLibClient 实例
   */
  public getTdClient(): TDLibClient {
    // ⭐ 延迟初始化：首次调用时才获取 TDLibClient
    if (!this.tdClient) {
      this.tdClient = TDLibClient.getInstance();
      hilog.info(DOMAIN, TAG, 'TDLibClient lazily initialized via getTdClient()');
    }
    return this.tdClient;
  }

  /**
   * 获取现有的 API 实例（如果已创建）
   */
  public getApiInstances(): TDLibAPIs | null {
    return this.apiInstances;
  }
}

/**
 * 导出工厂单例
 * ⚠️ 注意：不要在模块加载时立即调用 getInstance()
 * 应该在使用时才调用，确保 TDLibClient 已初始化
 */
// export const tdApiFactory = TdApiFactory.getInstance(); // ❌ 移除立即实例化

/**
 * 便捷方法：创建默认 API 实例
 * 等同于：TdApiFactory.getInstance().createDefault()
 *
 * 使用示例：
 * ```typescript
 * import { createTdLibAPIs } from '@telegram/tdlib-bridge';
 *
 * const apis = createTdLibAPIs();
 * await apis.setAuthenticationPhoneNumber('+8613800138000');
 * await apis.getUser({ user_id: 123 });
 * ```
 */
export function createTdLibAPIs(): TDLibApi {
  return TdApiFactory.getInstance().createDefault();
}

/**
 * 便捷方法：创建自定义 API 实例
 * 等同于：TdApiFactory.getInstance().createCustom(tdClient)
 *
 * 使用示例：
 * ```typescript
 * import { createCustomTdLibAPIs, TDLibClient } from '@telegram/tdlib-bridge';
 *
 * const customClient = TDLibClient.getInstance(); // 或 new TDLibClient()
 * const apis = createCustomTdLibAPIs(customClient);
 * await apis.getUser({ user_id: 123 });
 * ```
 */
export function createCustomTdLibAPIs(customTdClient: TDLibClient): TDLibApi {
  return TdApiFactory.getInstance().createCustom(customTdClient);
}
