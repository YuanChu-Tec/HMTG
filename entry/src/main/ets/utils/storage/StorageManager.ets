import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { AppError, ErrorSeverity, ErrorCategory } from '../error/AppError';
import { ErrorCode } from '../error/ErrorCode';

/**
 * 存储管理器
 */
export class StorageManager {
  private static instances: Map<string, StorageManager> = new Map();
  private preferences?: preferences.Preferences;
  private readonly storeName: string;

  private constructor(storeName: string) {
    this.storeName = storeName;
  }

  /**
   * 获取存储实例（单例模式）
   */
  public static getInstance(storeName: string = 'default'): StorageManager {
    if (!StorageManager.instances.has(storeName)) {
      StorageManager.instances.set(storeName, new StorageManager(storeName));
    }
    return StorageManager.instances.get(storeName)!;
  }

  /**
   * 初始化存储
   */
  public async initialize(context: common.UIAbilityContext): Promise<void> {
    try {
      this.preferences = await preferences.getPreferences(context, this.storeName);
    } catch (error) {
      const err = new AppError(
        String(ErrorCode.STORAGE_ERROR),
        `Failed to initialize storage: ${this.storeName}`,
        ErrorSeverity.ERROR,
        undefined,
        undefined,
        error as Error
      );
      throw new Error(String(err));
    }
  }

  /**
   * 存储数据
   */
  public async put(key: string, value: preferences.ValueType): Promise<void> {
    if (!this.preferences) {
      const err = new AppError(String(ErrorCode.STORAGE_NOT_AVAILABLE), 'Storage not initialized');
      throw new Error(String(err));
    }

    try {
      await this.preferences.put(key, value);
      await this.preferences.flush();
    } catch (error) {
      const err = new AppError(
        String(ErrorCode.STORAGE_ERROR),
        `Failed to put value for key: ${key}`,
        ErrorSeverity.ERROR,
        undefined,
        undefined,
        error as Error
      );
      throw new Error(String(err));
    }
  }

  /**
   * 获取数据
   */
  public async get<T = Object>(
    key: string,
    defaultValue?: T
  ): Promise<T | undefined> {
    if (!this.preferences) {
      const err = new AppError(String(ErrorCode.STORAGE_NOT_AVAILABLE), 'Storage not initialized');
      throw new Error(String(err));
    }

    try {
      if (defaultValue !== undefined) {
        const typedValue: preferences.ValueType = defaultValue as preferences.ValueType;
        return this.preferences.get(key, typedValue) as T;
      } else {
        const emptyDefaultValue: preferences.ValueType = '' as preferences.ValueType;
        const valPromise = this.preferences.get(key, emptyDefaultValue);
        return valPromise.then((val: preferences.ValueType) => {
          return (val !== '' && val !== undefined) ? val as T : undefined;
        });
      }
    } catch (error) {
      const err = new AppError(
        String(ErrorCode.STORAGE_ERROR),
        `Failed to get value for key: ${key}`,
        ErrorSeverity.ERROR,
        undefined,
        undefined,
        error as Error
      );
      throw new Error(String(err));
    }
  }

  /**
   * 删除数据
   */
  public async delete(key: string): Promise<void> {
    if (!this.preferences) {
      const err = new AppError(String(ErrorCode.STORAGE_NOT_AVAILABLE), 'Storage not initialized');
      throw new Error(String(err));
    }

    try {
      await this.preferences.delete(key);
      await this.preferences.flush();
    } catch (error) {
      const err = new AppError(
        String(ErrorCode.STORAGE_ERROR),
        `Failed to delete value for key: ${key}`,
        ErrorSeverity.ERROR,
        undefined,
        undefined,
        error as Error
      );
      throw new Error(String(err));
    }
  }

  /**
   * 检查键是否存在
   */
  public async has(key: string): Promise<boolean> {
    if (!this.preferences) {
      return false;
    }

    try {
      return await this.preferences.has(key);
    } catch (error) {
      return false;
    }
  }

  /**
   * 获取所有键
   */
  public async getAllKeys(): Promise<string[]> {
    if (!this.preferences) {
      const err = new AppError(String(ErrorCode.STORAGE_NOT_AVAILABLE), 'Storage not initialized', ErrorSeverity.ERROR, ErrorCategory.UNKNOWN);
      throw new Error(String(err));
    }

    try {
      const allData = await this.preferences.getAll();
      const keys: string[] = [];
      const entries: Array<[string, Object]> = Array.from(Object.entries(allData));
      for (const entry of entries) {
        const key: string = entry[0] as string;
        keys.push(key);
      }
      return keys;
    } catch (error) {
      const err = new AppError(
        String(ErrorCode.STORAGE_ERROR),
        'Failed to get all keys',
        ErrorSeverity.ERROR,
        ErrorCategory.UNKNOWN,
        undefined,
        undefined
      );
      throw new Error(String(err));
    }
  }

  /**
   * 清除所有数据
   */
  public async clear(): Promise<void> {
    if (!this.preferences) {
      const err = new AppError(String(ErrorCode.STORAGE_NOT_AVAILABLE), 'Storage not initialized');
      throw new Error(String(err));
    }

    try {
      await this.preferences.clear();
      await this.preferences.flush();
    } catch (error) {
      const err = new AppError(
        String(ErrorCode.STORAGE_ERROR),
        'Failed to clear storage',
        ErrorSeverity.ERROR,
        undefined,
        undefined,
        error as Error
      );
      throw new Error(String(err));
    }
  }

  /**
   * 批量存储
   */
  public async putMultiple(items: Map<string, preferences.ValueType>): Promise<void> {
    if (!this.preferences) {
      const err = new AppError(String(ErrorCode.STORAGE_NOT_AVAILABLE), 'Storage not initialized');
      throw new Error(String(err));
    }

    try {
      const entries = Array.from(items.entries());
      for (const entry of entries) {
        const key = entry[0];
        const value = entry[1];
        await this.preferences.put(key, value);
      }
      await this.preferences.flush();
    } catch (error) {
      const err = new AppError(
        String(ErrorCode.STORAGE_ERROR),
        'Failed to put multiple values',
        ErrorSeverity.ERROR,
        undefined,
        undefined,
        error as Error
      );
      throw new Error(String(err));
    }
  }

  /**
   * 批量获取
   */
  public async getMultiple<T = preferences.ValueType>(
    keys: string[]
  ): Promise<Map<string, T | undefined>> {
    const result: Map<string, T | undefined> = new Map();

    for (const key of keys) {
      result.set(key, await this.get<T>(key));
    }

    return result;
  }
}
