import { StorageManager } from './StorageManager';
import { CacheManager } from './CacheManager';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { preferences } from '@kit.ArkData';

const DOMAIN = 0x0001;
const TAG = 'DataManager';

interface OperationResult {
  success: boolean;
  data?: ESObject;
  error?: string;
}

interface DataStatistics {
  totalItems: number;
  totalSize: number;
  hitRate: number;
  lastUpdated: number;
}

export interface ClearDataOptions {
  clearPreferences?: boolean;
  clearCache?: boolean;
  clearDatabase?: boolean;
  clearSecureStorage?: boolean;
  logout?: boolean;
  restartAfterClear?: boolean;
}

export interface ClearResult {
  type: string;
  success: boolean;
  error?: string;
}


/**
 * 数据管理器
 * 负责清除应用的所有数据，包括缓存、首选项、数据库等
 */
export class DataManager {
  private static instance: DataManager;
  private context: common.UIAbilityContext | null = null;

  private constructor() {}

  /**
   * 获取单例
   */
  public static getInstance(): DataManager {
    if (!DataManager.instance) {
      DataManager.instance = new DataManager();
    }
    return DataManager.instance;
  }

  /**
   * 初始化
   */
  public async initialize(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    hilog.info(DOMAIN, TAG, 'DataManager initialized');
  }

  /**
   * 清除所有数据
   * @param options 清除选项
   * @returns Promise<boolean> 清除是否成功
   */
  public async clearAllData(options: ClearDataOptions = {}): Promise<boolean> {
    try {
      // 默认选项：清除所有内容
      const defaultOptions: ClearDataOptions = {
        clearPreferences: true,
        clearCache: true,
        clearDatabase: true,
        clearSecureStorage: true,
        logout: true,
        restartAfterClear: true
      };

      // 合并选项（不使用扩展运算符）
      const clearOptions: ClearDataOptions = {
        clearPreferences: options.clearPreferences !== undefined ? options.clearPreferences : defaultOptions.clearPreferences,
        clearCache: options.clearCache !== undefined ? options.clearCache : defaultOptions.clearCache,
        clearDatabase: options.clearDatabase !== undefined ? options.clearDatabase : defaultOptions.clearDatabase,
        clearSecureStorage: options.clearSecureStorage !== undefined ? options.clearSecureStorage : defaultOptions.clearSecureStorage,
        logout: options.logout !== undefined ? options.logout : defaultOptions.logout,
        restartAfterClear: options.restartAfterClear !== undefined ? options.restartAfterClear : defaultOptions.restartAfterClear
      };

      hilog.info(DOMAIN, TAG, `Starting data clear with options: ${JSON.stringify(clearOptions)}`);

      const results: Array<ClearResult> = [];

      // 1. 清除首选项
      if (clearOptions.clearPreferences) {
        const result = await this.clearPreferences();
        const clearResult: ClearResult = { type: 'Preferences', success: result.success, error: result.error };
        results.push(clearResult);
      }

      // 2. 清除缓存
      if (clearOptions.clearCache) {
        const result = await this.clearCache();
        const clearResult: ClearResult = { type: 'Cache', success: result.success, error: result.error };
        results.push(clearResult);
      }

      // 3. 清除数据库
      if (clearOptions.clearDatabase) {
        const result = await this.clearDatabase();
        const clearResult: ClearResult = { type: 'Database', success: result.success, error: result.error };
        results.push(clearResult);
      }

      // 4. 清除安全存储
      if (clearOptions.clearSecureStorage) {
        const result = await this.clearSecureStorage();
        const clearResult: ClearResult = { type: 'SecureStorage', success: result.success, error: result.error };
        results.push(clearResult);
      }

      // 5. 退出登录
      if (clearOptions.logout) {
        const result = await this.logout();
        const clearResult: ClearResult = { type: 'Logout', success: result.success, error: result.error };
        results.push(clearResult);
      }

      // 记录清除结果
      const allSuccess = results.every((r: ClearResult) => r.success);
      const failureCount = results.filter((r: ClearResult) => !r.success).length;

      if (allSuccess) {
        hilog.info(DOMAIN, TAG, 'All data cleared successfully');
      } else {
        hilog.warn(DOMAIN, TAG, `Data clear completed with ${failureCount} failures`);
        results.forEach((r: ClearResult) => {
          if (!r.success) {
            hilog.error(DOMAIN, TAG, `${r.type} clear failed: ${r.error}`);
          }
        });
      }

      return allSuccess;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to clear all data: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * 清除首选项
   */
  private async clearPreferences(): Promise<OperationResult> {
    try {
      hilog.info(DOMAIN, TAG, 'Clearing preferences...');

      // 清除所有Preferences存储
      const storageNames = ['default', 'user_settings', 'app_config', 'chat_settings'];
      let clearedCount = 0;

      for (const name of storageNames) {
        try {
          const storage = StorageManager.getInstance(name);
          await storage.clear();
          clearedCount++;
          hilog.debug(DOMAIN, TAG, `Cleared preferences: ${name}`);
        } catch (error) {
          hilog.warn(DOMAIN, TAG, `Failed to clear preferences ${name}: ${JSON.stringify(error)}`);
        }
      }

      hilog.info(DOMAIN, TAG, `Cleared ${clearedCount}/${storageNames.length} preferences`);
      return { success: true };
    } catch (error) {
      const err = error as Error;
      return { success: false, error: err.message };
    }
  }

  /**
   * 清除缓存
   */
  private async clearCache(): Promise<OperationResult> {
    try {
      hilog.info(DOMAIN, TAG, 'Clearing cache...');

      // 使用CacheManager清除所有缓存
      // const cacheManager = CacheManager.getInstance();
      // await cacheManager.clear();

      // 清除文件系统缓存
      if (this.context) {
        try {
          // 清除图片缓存目录
          const imageCacheDir = `${this.context.cacheDir}/images`;
          if (fileIo.accessSync(imageCacheDir)) {
            const files = fileIo.listFileSync(imageCacheDir);
            let deleteCount = 0;
            for (const fileName of files) {
              try {
                const filePath = `${imageCacheDir}/${fileName}`;
                fileIo.unlinkSync(filePath);
                deleteCount++;
              } catch (e) {
                hilog.warn(DOMAIN, TAG, `Failed to delete image cache ${fileName}: ${JSON.stringify(e)}`);
              }
            }
            hilog.debug(DOMAIN, TAG, `Deleted ${deleteCount} image cache files`);
          }

          // 清除缩略图缓存目录
          const thumbnailCacheDir = `${this.context.cacheDir}/thumbnails`;
          if (fileIo.accessSync(thumbnailCacheDir)) {
            const files = fileIo.listFileSync(thumbnailCacheDir);
            let deleteCount = 0;
            for (const fileName of files) {
              try {
                const filePath = `${thumbnailCacheDir}/${fileName}`;
                fileIo.unlinkSync(filePath);
                deleteCount++;
              } catch (e) {
                hilog.warn(DOMAIN, TAG, `Failed to delete thumbnail cache ${fileName}: ${JSON.stringify(e)}`);
              }
            }
            hilog.debug(DOMAIN, TAG, `Deleted ${deleteCount} thumbnail cache files`);
          }

          // 清除临时文件目录
          const tempDir = `${this.context.tempDir}`;
          if (fileIo.accessSync(tempDir)) {
            const files = fileIo.listFileSync(tempDir);
            let deleteCount = 0;
            for (const fileName of files) {
              try {
                const filePath = `${tempDir}/${fileName}`;
                fileIo.unlinkSync(filePath);
                deleteCount++;
              } catch (e) {
                hilog.warn(DOMAIN, TAG, `Failed to delete temp file ${fileName}: ${JSON.stringify(e)}`);
              }
            }
            hilog.debug(DOMAIN, TAG, `Deleted ${deleteCount} temp files`);
          }

          hilog.debug(DOMAIN, TAG, 'File system cache cleared');
        } catch (e) {
          hilog.warn(DOMAIN, TAG, `Failed to clear some file system cache: ${JSON.stringify(e)}`);
        }
      }

      hilog.info(DOMAIN, TAG, 'Cache cleared successfully');
      return { success: true };
    } catch (error) {
      const err = error as Error;
      hilog.error(DOMAIN, TAG, `Failed to clear cache: ${err.message}`);
      return { success: false, error: err.message };
    }
  }

  /**
   * 清除数据库
   */
  private async clearDatabase(): Promise<OperationResult> {
    try {
      hilog.info(DOMAIN, TAG, 'Clearing database...');

      // 关闭所有数据库连接并删除数据库文件
      // 注意：实际数据库文件路径需要根据项目配置确定
      const databaseDir = `${this.context?.filesDir}/databases`;

      // 使用fileIo删除数据库目录
      if (this.context) {
        try {
          // 删除数据库目录下的所有文件
          const files = fileIo.listFileSync(databaseDir);

          let deleteCount = 0;
          for (const fileName of files) {
            try {
              const filePath = `${databaseDir}/${fileName}`;
              fileIo.unlinkSync(filePath);
              deleteCount++;
              hilog.debug(DOMAIN, TAG, `Deleted database file: ${fileName}`);
            } catch (e) {
              hilog.warn(DOMAIN, TAG, `Failed to delete ${fileName}: ${JSON.stringify(e)}`);
            }
          }

          hilog.info(DOMAIN, TAG, `Deleted ${deleteCount} database files`);
        } catch (e) {
          hilog.warn(DOMAIN, TAG, `Database directory may not exist: ${JSON.stringify(e)}`);
        }
      }

      hilog.info(DOMAIN, TAG, 'Database cleared successfully');
      return { success: true };
    } catch (error) {
      const err = error as Error;
      hilog.error(DOMAIN, TAG, `Failed to clear database: ${err.message}`);
      return { success: false, error: err.message };
    }
  }

  /**
   * 清除安全存储
   */
  private async clearSecureStorage(): Promise<OperationResult> {
    try {
      hilog.info(DOMAIN, TAG, 'Clearing secure storage...');

      // 清除加密存储中的敏感数据
      const secureStorageNames = ['secure_credentials', 'tokens', 'encryption_keys'];
      let clearedCount = 0;

      for (const name of secureStorageNames) {
        try {
          const storage = StorageManager.getInstance(name);
          await storage.clear();
          clearedCount++;
          hilog.debug(DOMAIN, TAG, `Cleared secure storage: ${name}`);
        } catch (error) {
          hilog.warn(DOMAIN, TAG, `Failed to clear secure storage ${name}: ${JSON.stringify(error)}`);
        }
      }

      hilog.info(DOMAIN, TAG, `Cleared ${clearedCount}/${secureStorageNames.length} secure storage instances`);
      const result: OperationResult = { success: true };
      return result;
    } catch (error) {
      const err = error as Error;
      hilog.error(DOMAIN, TAG, `Failed to clear secure storage: ${err.message}`);
      const result: OperationResult = { success: false, error: err.message };
      return result;
    }
  }

  /**
   * 退出登录
   */
  private async logout(): Promise<OperationResult> {
    try {
      hilog.info(DOMAIN, TAG, 'Logging out...');

      // 清除TDLib认证状态
      try {
        // 导入tdlib-bridge
        // const { TdClient } = await import('@telegram/tdlib-bridge');
        // const tdClient = TdClient.getInstance(); // TODO: TdClient import issue
        // await tdClient.logOut();
        hilog.debug(DOMAIN, TAG, 'TDLib logout skipped (tdClient not available)');
      } catch (error) {
        hilog.warn(DOMAIN, TAG, `TDLib logout failed: ${JSON.stringify(error)}`);
      }

      // 清除认证相关的首选项
      const authStorage = StorageManager.getInstance('auth_storage');
      if (this.context) {
        await authStorage.initialize(this.context);
        await authStorage.clear();
        hilog.debug(DOMAIN, TAG, 'Auth storage cleared');
      }

      // 清除用户相关的首选项
      const userStorage = StorageManager.getInstance('user_storage');
      if (this.context) {
        await userStorage.initialize(this.context);
        await userStorage.clear();
        hilog.debug(DOMAIN, TAG, 'User storage cleared');
      }

      // 重置全局登录状态 - 暂时注释掉，因为GlobalData模块可能不存在
      /*
      try {
        const { GlobalData } = await import('@entry/src/main/ets/model/GlobalData');
        const globalData = GlobalData.getInstance();
        await globalData.clearUserData();
        hilog.debug(DOMAIN, TAG, 'GlobalData cleared');
      } catch (error) {
        hilog.warn(DOMAIN, TAG, `Failed to clear GlobalData: ${JSON.stringify(error)}`);
      }
       */

      hilog.info(DOMAIN, TAG, 'Logout completed successfully');
      return { success: true };
    } catch (error) {
      const err = error as Error;
      hilog.error(DOMAIN, TAG, `Failed to logout: ${err.message}`);
      return { success: false, error: err.message };
    }
  }

  /**
   * 获取数据统计信息
   */
  public async getDataStatistics(): Promise<DataStatistics> {
    try {
      hilog.info(DOMAIN, TAG, 'Collecting data statistics...');

      // 统计首选项大小
      let preferencesSize = 0;
      const storageNames = ['default', 'user_settings', 'app_config', 'chat_settings'];
      for (const name of storageNames) {
        try {
          const storage = StorageManager.getInstance(name);
          const keys = await storage.getAllKeys();
          preferencesSize += keys.length;
        } catch (error) {
          hilog.warn(DOMAIN, TAG, `Failed to get keys for ${name}: ${JSON.stringify(error)}`);
        }
      }

      // 统计缓存大小
      let cacheSize: number = 0;
      try {
        const cacheManager = CacheManager.getInstance();
        // CacheManager 没有getStatistics方法，暂时设置为0
        // 当CacheManager添加统计功能时，可以在这里调用
        hilog.debug(DOMAIN, TAG, `Cache size: ${cacheSize} bytes`);
      } catch (error) {
        hilog.warn(DOMAIN, TAG, `Failed to get cache statistics: ${JSON.stringify(error)}`);
      }

      // 统计数据库大小
      let databaseSize: number = 0;
      try {
        databaseSize = await this.calculateDatabaseSize();
        hilog.debug(DOMAIN, TAG, `Database size: ${databaseSize} bytes`);
      } catch (error) {
        hilog.warn(DOMAIN, TAG, `Failed to calculate database size: ${JSON.stringify(error)}`);
      }

      // 统计安全存储大小
      let secureStorageSize: number = 0;
      try {
        secureStorageSize = await this.calculateSecureStorageSize();
        hilog.debug(DOMAIN, TAG, `Secure storage size: ${secureStorageSize} bytes`);
      } catch (error) {
        hilog.warn(DOMAIN, TAG, `Failed to calculate secure storage size: ${JSON.stringify(error)}`);
      }

      const totalSize = preferencesSize + cacheSize + databaseSize + secureStorageSize;

      hilog.info(DOMAIN, TAG, `Data statistics collected: total=${totalSize}`);

      const stats: DataStatistics = {
        totalItems: 0,
        totalSize: totalSize,
        hitRate: 0,
        lastUpdated: Date.now()
      };
      return stats;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to collect data statistics: ${JSON.stringify(error)}`);
      const errStats: DataStatistics = {
        totalItems: 0,
        totalSize: 0,
        hitRate: 0,
        lastUpdated: 0
      };
      return errStats;
    }
  }

  /**
   * 重置为默认设置
   */
  public async resetToDefaults(): Promise<boolean> {
    try {
      hilog.info(DOMAIN, TAG, 'Resetting to default settings...');

      // 清除所有首选项
      const result = await this.clearPreferences();
      if (!result.success) {
        hilog.error(DOMAIN, TAG, 'Failed to clear preferences during reset');
        return false;
      }

      // 保存默认设置
      const defaultSettings = new Map<string, preferences.ValueType>();
      defaultSettings.set('debugMode', false);
      defaultSettings.set('logLevel', 'ERROR');
      defaultSettings.set('networkTimeout', 30);
      defaultSettings.set('maxCacheSize', 500);
      defaultSettings.set('dataSaver', false);
      defaultSettings.set('lowDataMode', false);
      defaultSettings.set('theme', 'system');
      defaultSettings.set('language', 'zh-CN');

      const storage = StorageManager.getInstance('app_config');
      await storage.putMultiple(defaultSettings);

      hilog.info(DOMAIN, TAG, 'Reset to defaults completed');
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to reset to defaults: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * 计算数据库大小
   */
  private async calculateDatabaseSize(): Promise<number> {
    try {
      if (!this.context) {
        return 0;
      }

      const databaseDir = `${this.context.filesDir}/databases`;
      if (!fileIo.accessSync(databaseDir)) {
        return 0;
      }

      const files = fileIo.listFileSync(databaseDir);
      let totalSize = 0;

      for (const fileName of files) {
        try {
          const filePath = `${databaseDir}/${fileName}`;
          const stat = fileIo.statSync(filePath);
          totalSize += stat.size;
        } catch (e) {
          hilog.warn(DOMAIN, TAG, `Failed to get size for ${fileName}: ${JSON.stringify(e)}`);
        }
      }

      return totalSize;
    } catch (error) {
      return 0;
    }
  }

  /**
   * 计算安全存储大小
   */
  private async calculateSecureStorageSize(): Promise<number> {
    try {
      const secureStorageNames = ['secure_credentials', 'tokens', 'encryption_keys'];
      let totalSize = 0;

      for (const name of secureStorageNames) {
        try {
          const storage = StorageManager.getInstance(name);
          const keys = await storage.getAllKeys();
          // 估算每个key-value对的大小（每个约100字节）
          totalSize += keys.length * 100;
        } catch (error) {
          hilog.warn(DOMAIN, TAG, `Failed to get keys for ${name}: ${JSON.stringify(error)}`);
        }
      }

      return totalSize;
    } catch (error) {
      return 0;
    }
  }
}

// 导出单例实例
export const dataManager = DataManager.getInstance();
