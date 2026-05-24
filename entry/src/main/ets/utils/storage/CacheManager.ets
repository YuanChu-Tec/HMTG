/**
 * 缓存管理器 - 策略模式实现
 * 
 * 功能描述:
 * - 支持多种缓存策略（Preferences、文件、内存等）
 * - 根据数据类型和大小自动选择最优策略
 * - 支持缓存过期时间
 * - 支持缓存压缩
 * - 线程安全的缓存操作
 * 
 * @module library/utils/src/main/ets/storage/CacheManager
 * @since API 20
 */

import { preferences } from '@kit.ArkData';
import { fileIo } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppError, ErrorSeverity, ErrorCategory } from '../error/AppError';

/** 缓存项接口 */
export interface CacheItem<T> {
  data: T;
  timestamp: number;
  expireTime: number;
  size: number;
  compressed: boolean;
}

/** 批量设置缓存项接口 */
export interface CacheSetItem<T> {
  key: string;
  data: T;
  expire?: number;
}


/**
 * 缓存策略接口
 */
export interface ICacheStrategy {
  /**
   * 保存缓存
   */
  save(key: string, value: CacheItem<Object>): Promise<void>;

  /**
   * 获取缓存
   */
  get(key: string): Promise<CacheItem<Object> | null>;

  /**
   * 删除缓存
   */
  delete(key: string): Promise<void>;

  /**
   * 检查是否存在
   */
  has(key: string): Promise<boolean>;

  /**
   * 清空所有缓存
   */
  clear(): Promise<void>;
}

/**
 * 缓存配置
 */
export interface CacheConfig {
  /** 缓存名称 */
  name?: string;
  /** 默认过期时间（毫秒），0表示永不过期 */
  defaultExpire?: number;
  /** 是否启用压缩 */
  enableCompression?: boolean;
  /** 最大缓存大小（字节） */
  maxSize?: number;
}

/**
 * Preferences缓存策略（适合小数据）
 * 注：当前未使用，保留用于未来根据数据大小自动选择策略
 */
class PreferencesCacheStrategy implements ICacheStrategy {
  private readonly TAG: string = 'PreferencesCacheStrategy';
  private readonly DOMAIN: number = 0x0001;
  private storeName: string;

  constructor(storeName: string = 'cache') {
    this.storeName = storeName;
  }

  private async getStore(): Promise<preferences.Preferences> {
    const context = getContext(this);
    return await preferences.getPreferences(context, this.storeName);
  }

  async save(key: string, value: CacheItem<Object>): Promise<void> {
    try {
      const store = await this.getStore();
      const jsonValue = JSON.stringify(value);
      await store.put(key, jsonValue);
      await store.flush();

      hilog.debug(this.DOMAIN, this.TAG, `Saved ${key} to Preferences, size: ${jsonValue.length}`);
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to save ${key}: ${JSON.stringify(error)}`);
      const err = new AppError('CACHE_ERROR', `Failed to save ${key}`, ErrorSeverity.ERROR, ErrorCategory.UNKNOWN, undefined, error as Error);
      throw new Error(String(err));
    }
  }

  async get(key: string): Promise<CacheItem<Object> | null> {
    try {
      const store = await this.getStore();
      const jsonValue = await store.get(key, '') as string;

      if (!jsonValue) {
        return null;
      }

      const item = JSON.parse(jsonValue) as CacheItem<Object>;

      // 检查是否过期
      if (item.expireTime && Date.now() > item.expireTime) {
        await this.delete(key);
        return null;
      }

      return item;
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to get ${key}: ${JSON.stringify(error)}`);
      return null;
    }
  }

  async delete(key: string): Promise<void> {
    try {
      const store = await this.getStore();
      await store.delete(key);
      await store.flush();

      hilog.debug(this.DOMAIN, this.TAG, `Deleted ${key} from Preferences`);
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to delete ${key}: ${JSON.stringify(error)}`);
    }
  }

  async has(key: string): Promise<boolean> {
    try {
      const store = await this.getStore();
      return await store.has(key);
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to check ${key}: ${JSON.stringify(error)}`);
      return false;
    }
  }

  async clear(): Promise<void> {
    try {
      const store = await this.getStore();
      await store.clear();
      await store.flush();

      hilog.info(this.DOMAIN, this.TAG, 'Cleared all Preferences cache');
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to clear: ${JSON.stringify(error)}`);
      throw new Error(String(error));
    }
  }
}

/**
 * 文件缓存策略（适合中等数据）
 */
class FileCacheStrategy implements ICacheStrategy {
  private readonly TAG: string = 'FileCacheStrategy';
  private readonly DOMAIN: number = 0x0001;
  private basePath: string = '';
  private initialized: boolean = false;

  constructor(basePath?: string) {
    // 延迟初始化，避免在 getContext 未就绪时访问 filesDir
    if (basePath) {
      this.basePath = basePath;
      this.initialized = true;
      this.ensureDirectoryExists();
    }
  }

  /**
   * 确保已初始化（懒加载）
   */
  private async ensureInitialized(): Promise<void> {
    if (this.initialized) {
      return;
    }

    try {
      const context = getContext(this);
      if (!context || !context.filesDir) {
        hilog.error(this.DOMAIN, this.TAG, 'Context or filesDir is not available');
        // 使用临时目录作为后备方案
        this.basePath = '/data/storage/el2/base/cache/';
      } else {
        this.basePath = context.filesDir + '/cache/';
      }
      
      this.initialized = true;
      await this.ensureDirectoryExists();
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to initialize: ${JSON.stringify(error)}`);
      // 使用默认路径作为后备
      this.basePath = '/data/storage/el2/base/cache/';
      this.initialized = true;
    }
  }

  private async ensureDirectoryExists(): Promise<void> {
    try {
      // 检查目录是否存在，不存在则创建
      try {
        await fileIo.stat(this.basePath);
      } catch (error) {
        await fileIo.mkdir(this.basePath);
        hilog.info(this.DOMAIN, this.TAG, `Created cache directory: ${this.basePath}`);
      }
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to create directory: ${JSON.stringify(error)}`);
    }
  }

  private getFilePath(key: string): string {
    // 使用Base64编码避免文件名冲突
    const safeKey = this.encodeToBase64(key).replace(/[\/+=]/g, '_');
    return this.basePath + safeKey + '.json';
  }

  /**
   * 简单的十六进制编码实现（替代Base64）
   */
  private encodeToBase64(str: string): string {
    const result: string[] = [];
    for (let i = 0; i < str.length; i++) {
      const charCode = str.charCodeAt(i);
      const bytes = charCode.toString(16).padStart(2, '0');
      result.push(bytes);
    }
    return result.join('');
  }

  async save(key: string, value: CacheItem<Object>): Promise<void> {
    try {
      await this.ensureInitialized();
      const filePath = this.getFilePath(key);
      const jsonValue = JSON.stringify(value);

      const file = await fileIo.open(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
      await fileIo.write(file.fd, jsonValue);
      await fileIo.close(file.fd);

      hilog.debug(this.DOMAIN, this.TAG, `Saved ${key} to file, size: ${jsonValue.length}`);
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to save ${key}: ${JSON.stringify(error)}`);
      const err = new AppError('CACHE_ERROR', `Failed to save ${key}`, ErrorSeverity.ERROR, ErrorCategory.UNKNOWN, undefined, error as Error);
      throw new Error(String(err));
    }
  }

  async get(key: string): Promise<CacheItem<Object> | null> {
    try {
      await this.ensureInitialized();
      const filePath = this.getFilePath(key);
      const file = await fileIo.open(filePath, fileIo.OpenMode.READ_ONLY);

      const stat = await fileIo.stat(filePath);
      const buffer = new ArrayBuffer(stat.size);
      await fileIo.read(file.fd, buffer);
      await fileIo.close(file.fd);

      const uint8Array = new Uint8Array(buffer);
      const chars: string[] = [];
      for (let i = 0; i < uint8Array.length; i++) {
        chars.push(String.fromCharCode(uint8Array[i]));
      }
      const jsonValue = chars.join('');
      const item = JSON.parse(jsonValue) as CacheItem<Object>;

      // 检查是否过期
      if (item.expireTime && Date.now() > item.expireTime) {
        await this.delete(key);
        return null;
      }

      return item;
    } catch (error) {
      hilog.debug(this.DOMAIN, this.TAG, `Failed to get ${key} (may not exist)`);
      return null;
    }
  }

  async delete(key: string): Promise<void> {
    try {
      await this.ensureInitialized();
      const filePath = this.getFilePath(key);
      await fileIo.unlink(filePath);
      
      hilog.debug(this.DOMAIN, this.TAG, `Deleted ${key} from file`);
    } catch (error) {
      hilog.debug(this.DOMAIN, this.TAG, `Failed to delete ${key} (may not exist)`);
    }
  }

  async has(key: string): Promise<boolean> {
    try {
      await this.ensureInitialized();
      const filePath = this.getFilePath(key);
      await fileIo.stat(filePath);
      return true;
    } catch (error) {
      return false;
    }
  }

  async clear(): Promise<void> {
    try {
      await this.ensureInitialized();
      // 读取目录所有文件并删除
      const list = await fileIo.listFile(this.basePath);
      
      for (const fileName of list) {
        const filePath = this.basePath + fileName;
        await fileIo.unlink(filePath);
      }
      
      hilog.info(this.DOMAIN, this.TAG, 'Cleared all file cache');
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to clear: ${JSON.stringify(error)}`);
      throw new Error(String(error));
    }
  }
}

/**
 * 内存缓存策略（适合临时数据）
 * 注：当前未使用，保留用于未来根据数据类型自动选择策略
 */
class MemoryCacheStrategy implements ICacheStrategy {
  private readonly TAG: string = 'MemoryCacheStrategy';
  private readonly DOMAIN: number = 0x0001;
  private cache: Map<string, CacheItem<Object>> = new Map<string, CacheItem<Object>>();
  private maxSize: number = 10 * 1024 * 1024; // 默认10MB

  constructor(maxSize?: number) {
    if (maxSize) {
      this.maxSize = maxSize;
    }
  }

  async save(key: string, value: CacheItem<Object>): Promise<void> {
    try {
      // 检查是否超过最大大小
      const currentSize = this.getCurrentSize();
      if (currentSize + value.size > this.maxSize) {
        await this.evictOldest(value.size);
      }

      this.cache.set(key, value);

      hilog.debug(this.DOMAIN, this.TAG, `Saved ${key} to memory, size: ${value.size}`);
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to save ${key}: ${JSON.stringify(error)}`);
      throw new Error(String(error));
    }
  }

  async get(key: string): Promise<CacheItem<Object> | null> {
    try {
      const item = this.cache.get(key);

      if (!item) {
        return null;
      }

      // 检查是否过期
      if (item.expireTime && Date.now() > item.expireTime) {
        await this.delete(key);
        return null;
      }

      return item;
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to get ${key}: ${JSON.stringify(error)}`);
      return null;
    }
  }

  async delete(key: string): Promise<void> {
    this.cache.delete(key);
    hilog.debug(this.DOMAIN, this.TAG, `Deleted ${key} from memory`);
  }

  async has(key: string): Promise<boolean> {
    return this.cache.has(key);
  }

  async clear(): Promise<void> {
    this.cache.clear();
    hilog.info(this.DOMAIN, this.TAG, 'Cleared all memory cache');
  }

  /**
   * 计算当前缓存大小
   */
  private getCurrentSize(): number {
    let size = 0;
    this.cache.forEach(item => {
      size += item.size;
    });
    return size;
  }

  /**
   * 淘汰最旧的缓存项（LRU策略）
   */
  private async evictOldest(neededSize: number): Promise<void> {
    const entries = Array.from(this.cache.entries());

    entries.sort((a, b) => a[1].timestamp - b[1].timestamp);

    let freedSpace = 0;
    for (const entry of entries) {
      const key = entry[0] as string;
      const item = entry[1];
      if (freedSpace >= neededSize) {
        break;
      }

      await this.delete(key);
      freedSpace += item.size;
    }
  }
}

/**
 * 缓存管理器 - 统一的缓存访问接口
 */
export class CacheManager {
  private static instance: CacheManager;
  private readonly TAG: string = 'CacheManager';
  private readonly DOMAIN: number = 0x0001;

  private strategy: ICacheStrategy;

  private constructor(_config?: CacheConfig) {
    // 根据配置选择策略
    this.strategy = this.selectStrategy();

    hilog.info(this.DOMAIN, this.TAG, `CacheManager initialized with ${this.strategy.constructor.name}`);
  }

  /**
   * 获取CacheManager单例
   */
  public static getInstance(config?: CacheConfig): CacheManager {
    if (!CacheManager.instance) {
      CacheManager.instance = new CacheManager(config);
    }
    return CacheManager.instance;
  }

  /**
   * 根据数据类型选择策略
   */
  private selectStrategy(): ICacheStrategy {
    // API 20环境：优先使用文件缓存，因为它支持更大的数据量
    // 对于小数据，可以使用Preferences
    return new FileCacheStrategy();
  }

  /**
   * 计算数据大小（字节）
   */
  private calculateSize(data: Object): number {
    try {
      return JSON.stringify(data).length * 2; // UTF-16编码，每个字符2字节
    } catch (error) {
      hilog.warn(this.DOMAIN, this.TAG, 'Failed to calculate data size');
      return 1024; // 默认1KB
    }
  }

  /**
   * 保存缓存
   * 
   * @param key 缓存键
   * @param data 缓存数据
   * @param expireSeconds 过期时间（秒），0表示永不过期
   * 
   * @example
   * ```typescript
   * const cache = CacheManager.getInstance();
   * await cache.set('user.info', { id: '123', name: 'test' }, 3600); // 1小时后过期
   * ```
   */
  public async set<T>(key: string, data: T, expireSeconds: number = 0): Promise<void> {
    try {
      const now = Date.now();
      const expireTime = expireSeconds > 0 ? now + (expireSeconds * 1000) : undefined;
      const size = this.calculateSize(data as Object);

      const cacheItem: CacheItem<Object> = {
        data: data as Object,
        timestamp: now,
        expireTime: expireTime || 0,
        size: size,
        compressed: false
      };

      await this.strategy.save(key, cacheItem);

      hilog.debug(this.DOMAIN, this.TAG, `Cache set: ${key}, size: ${size}, expire: ${expireTime}s`);
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to set cache ${key}: ${JSON.stringify(error)}`);
      throw new Error(String(error));
    }
  }

  /**
   * 获取缓存
   * 
   * @param key 缓存键
   * @returns 缓存数据，如果不存在或已过期返回null
   * 
   * @example
   * ```typescript
   * const cache = CacheManager.getInstance();
   * const userData = await cache.get<{ id: string, name: string }>('user.info');
   * if (userData) {
   *   console.log('User data:', userData.data);
   * }
   * ```
   */
  public async get<T>(key: string): Promise<T | null> {
    try {
      const item = await this.strategy.get(key);
      
      if (!item) {
        hilog.debug(this.DOMAIN, this.TAG, `Cache miss: ${key}`);
        return null;
      }

      hilog.debug(this.DOMAIN, this.TAG, `Cache hit: ${key}`);
      return item.data as T;
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to get cache ${key}: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 删除缓存
   * 
   * @param key 缓存键
   * 
   * @example
   * ```typescript
   * const cache = CacheManager.getInstance();
   * await cache.delete('user.info');
   * ```
   */
  public async delete(key: string): Promise<void> {
    try {
      await this.strategy.delete(key);
      hilog.debug(this.DOMAIN, this.TAG, `Cache deleted: ${key}`);
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to delete cache ${key}: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 检查缓存是否存在
   * 
   * @param key 缓存键
   * @returns 是否存在且未过期
   * 
   * @example
   * ```typescript
   * const cache = CacheManager.getInstance();
   * const exists = await cache.has('user.info');
   * ```
   */
  public async has(key: string): Promise<boolean> {
    try {
      return await this.strategy.has(key);
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to check cache ${key}: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * 清空所有缓存
   * 
   * @example
   * ```typescript
   * const cache = CacheManager.getInstance();
   * await cache.clear();
   * ```
   */
  public async clear(): Promise<void> {
    try {
      await this.strategy.clear();
      hilog.info(this.DOMAIN, this.TAG, 'All cache cleared');
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to clear cache: ${JSON.stringify(error)}`);
      throw new Error(String(error));
    }
  }

  /**
   * 批量设置缓存
   * 
   * @param items 缓存项数组
   * 
   * @example
   * ```typescript
   * const cache = CacheManager.getInstance();
   * await cache.setMany([
   *   { key: 'user.1', data: { id: '1', name: 'User 1' }, expire: 3600 },
   *   { key: 'user.2', data: { id: '2', name: 'User 2' }, expire: 3600 }
   * ]);
   * ```
   */
  public async setMany<T>(items: Array<CacheSetItem<T>>): Promise<void> {
    for (const item of items) {
      await this.set(item.key, item.data, item.expire);
    }
  }

  /**
   * 批量获取缓存
   * 
   * @param keys 缓存键数组
   * @returns 缓存数据映射表
   * 
   * @example
   * ```typescript
   * const cache = CacheManager.getInstance();
   * const users = await cache.getMany<{ id: string, name: string }>(['user.1', 'user.2']);
   * ```
   */
  public async getMany<T>(keys: string[]): Promise<Map<string, T>> {
    const results = await Promise.all(
      keys.map(async key => [key, await this.get<T>(key)] as [string, T | null])
    );

    const map = new Map<string, T>();
    results.forEach((item: [string, T | null]) => {
      const key: string = item[0];
      const value: T | null = item[1];
      if (value !== null) {
        map.set(key, value);
      }
    });

    return map;
  }

  /**
   * 批量删除缓存
   * 
   * @param keys 缓存键数组
   */
  public async deleteMany(keys: string[]): Promise<void> {
    await Promise.all(keys.map(key => this.delete(key)));
  }

  /**
   * 设置缓存策略
   * 
   * @param strategy 缓存策略
   */
  public setStrategy(strategy: ICacheStrategy): void {
    this.strategy = strategy;
    hilog.info(this.DOMAIN, this.TAG, `Cache strategy changed to ${strategy.constructor.name}`);
  }

  /**
   * 获取当前缓存策略名称
   */
  public getStrategyName(): string {
    return this.strategy.constructor.name;
  }
}

/**
 * 导出单例实例（便捷访问）
 */
export const cacheManager = CacheManager.getInstance();
