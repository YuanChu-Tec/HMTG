/**
 * 偏好设置封装
 * 基于@ohos.data.preferences的简化封装
 */

import preferences from '@ohos.data.preferences';
import { AppError, ErrorSeverity, ErrorCategory } from '../error/AppError';
import { ErrorCode } from '../error/ErrorCode';

/**
 * 偏好设置管理器
 */
export class Preference {
  private static instances: Map<string, Preference> = new Map();
  private preferencesStore: preferences.Preferences | null = null;
  private storeName: string;
  
  private constructor(storeName: string) {
    this.storeName = storeName;
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(storeName: string): Preference {
    let instance = Preference.instances.get(storeName);
    if (!instance) {
      instance = new Preference(storeName);
      Preference.instances.set(storeName, instance);
    }
    return instance;
  }
  
  /**
   * 初始化
   */
  public async initialize(context: Context): Promise<void> {
    try {
      this.preferencesStore = await preferences.getPreferences(context, this.storeName);
    } catch (error) {
      const err = new AppError(
        String(ErrorCode.STORAGE_IO_ERROR),
        `Failed to initialize preferences: ${this.storeName}`,
        ErrorSeverity.ERROR,
        ErrorCategory.UNKNOWN,
        undefined,
        error as Error
      );
      throw new Error(String(err));
    }
  }
  
  /**
   * 设置值
   */
  public async set(key: string, value: preferences.ValueType): Promise<void> {
    if (!this.preferencesStore) {
      const err = new AppError(
        String(ErrorCode.STORAGE_ACCESS_DENIED),
        'Preferences not initialized',
        ErrorSeverity.ERROR,
        ErrorCategory.UNKNOWN
      );
      throw new Error(String(err));
    }

    try {
      await this.preferencesStore.put(key, value);
      await this.preferencesStore.flush();
    } catch (error) {
      const err = new AppError(
        String(ErrorCode.STORAGE_IO_ERROR),
        `Failed to set preference: ${key}`,
        ErrorSeverity.ERROR,
        ErrorCategory.UNKNOWN,
        undefined,
        error as Error
      );
      throw new Error(String(err));
    }
  }
  
  /**
   * 获取值
   */
  public async get(key: string, defaultValue?: preferences.ValueType): Promise<preferences.ValueType | undefined> {
    if (!this.preferencesStore) {
      throw new AppError(
        String(ErrorCode.STORAGE_ACCESS_DENIED),
        'Preferences not initialized',
        ErrorSeverity.ERROR,
        ErrorCategory.UNKNOWN
      );
    }

    try {
      if (defaultValue !== undefined) {
        return this.preferencesStore.get(key, defaultValue);
      } else {
        const val = this.preferencesStore.get(key, undefined);
        return val !== undefined ? val : undefined;
      }
    } catch (error) {
      throw new AppError(
        String(ErrorCode.STORAGE_IO_ERROR),
        `Failed to get preference: ${key}`,
        ErrorSeverity.ERROR,
        ErrorCategory.UNKNOWN,
        undefined,
        undefined
      );
    }
  }
  
  /**
   * 删除值
   */
  public async remove(key: string): Promise<void> {
    if (!this.preferencesStore) {
      throw new AppError(
        String(ErrorCode.STORAGE_ACCESS_DENIED),
        'Preferences not initialized',
        ErrorSeverity.ERROR,
        ErrorCategory.UNKNOWN
      );
    }

    try {
      await this.preferencesStore.delete(key);
      await this.preferencesStore.flush();
    } catch (error) {
      throw new AppError(
        String(ErrorCode.STORAGE_IO_ERROR),
        `Failed to remove preference: ${key}`,
        ErrorSeverity.ERROR,
        ErrorCategory.UNKNOWN,
        undefined,
        undefined
      );
    }
  }
  
  /**
   * 清空所有
   */
  public async clear(): Promise<void> {
    if (!this.preferencesStore) {
      const err = new AppError(
        String(ErrorCode.STORAGE_ACCESS_DENIED),
        'Preferences not initialized',
        ErrorSeverity.ERROR,
        ErrorCategory.UNKNOWN
      );
      throw new Error(String(err));
    }

    try {
      await this.preferencesStore.clear();
      await this.preferencesStore.flush();
    } catch (error) {
      const err = new AppError(
        String(ErrorCode.STORAGE_IO_ERROR),
        'Failed to clear preferences',
        ErrorSeverity.ERROR,
        ErrorCategory.UNKNOWN,
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
    if (!this.preferencesStore) {
      return false;
    }
    
    try {
      return await this.preferencesStore.has(key);
    } catch (error) {
      return false;
    }
  }
  
  /**
   * 获取所有键
   */
  public async getAll(): Promise<string[]> {
    if (!this.preferencesStore) {
      const result: string[] = [];
      return result;
    }

    try {
      const arr = await this.preferencesStore.getAll();
      return arr as string[];
    } catch (error) {
      const result: string[] = [];
      return result;
    }
  }
}
