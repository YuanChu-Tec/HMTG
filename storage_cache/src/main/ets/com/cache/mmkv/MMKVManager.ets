import { MMKV } from '@tencent/mmkv';
import { common } from '@kit.AbilityKit';
import { CryptoHelper } from '../utils/CryptoHelper';
import { CacheLogger } from '../utils/Logger';

const TAG = 'MMKVManager';

export class MMKVManager {
  private static instance: MMKVManager;
  private mmkv: MMKV | null = null;
  private cryptoHelper: CryptoHelper | null = null;
  
  // 键索引：用于跟踪所有存储的键，支持按前缀清理
  private static readonly KEY_INDEX_PREFIX = '__mmkv_key_index__';

  private constructor(context: common.UIAbilityContext) {
    // 确保 MMKV 已初始化 - 需要 ApplicationContext
    try {
      const appContext = context.getApplicationContext();
      MMKV.initialize(appContext);
      CacheLogger.info(TAG, 'MMKV initialized successfully');
    } catch (error) {
      // 可能已经初始化过，忽略错误
      CacheLogger.debug(TAG, 'MMKV initialize skipped or already initialized');
    }
    this.mmkv = MMKV.defaultMMKV();
    this.cryptoHelper = CryptoHelper.getInstance();
  }

  /**
   * 将键添加到索引
   */
  private addKeyToIndex(key: string): void {
    try {
      const indexKey = MMKVManager.KEY_INDEX_PREFIX;
      const index: Set<string> = this.getObject<Set<string>>(indexKey, new Set()) ?? new Set<string>();
      index.add(key);
      this.setObject(indexKey, index);
    } catch (error) {
      CacheLogger.warn(TAG, `Failed to add key to index: ${error}`);
    }
  }

  /**
   * 从索引中移除键
   */
  private removeKeyFromIndex(key: string): void {
    try {
      const indexKey = MMKVManager.KEY_INDEX_PREFIX;
      const index: Set<string> = this.getObject<Set<string>>(indexKey, new Set()) ?? new Set<string>();
      index.delete(key);
      this.setObject(indexKey, index);
    } catch (error) {
      CacheLogger.warn(TAG, `Failed to remove key from index: ${error}`);
    }
  }

  /**
   * 获取所有键（从索引）
   */
  getAllKeys(): string[] {
    try {
      const index: Set<string> = this.getObject<Set<string>>(MMKVManager.KEY_INDEX_PREFIX, new Set()) ?? new Set<string>();
      return Array.from(index);
    } catch (error) {
      CacheLogger.warn(TAG, `Failed to get all keys: ${error}`);
      return [];
    }
  }

  /**
   * 获取指定前缀的所有键
   */
  getKeysWithPrefix(prefix: string): string[] {
    return this.getAllKeys().filter(key => key.startsWith(prefix));
  }

  /**
   * 删除指定前缀的所有键
   */
  deleteKeysWithPrefix(prefix: string): number {
    try {
      const keysToDelete = this.getKeysWithPrefix(prefix);
      for (const key of keysToDelete) {
        this.delete(key);
      }
      CacheLogger.info(TAG, `Deleted ${keysToDelete.length} keys with prefix '${prefix}'`);
      return keysToDelete.length;
    } catch (error) {
      CacheLogger.error(TAG, `Failed to delete keys with prefix '${prefix}': ${error}`);
      return 0;
    }
  }

  public static getInstance(context?: common.UIAbilityContext): MMKVManager {
    if (!MMKVManager.instance && context) {
      MMKVManager.instance = new MMKVManager(context);
    }
    return MMKVManager.instance;
  }

  // 普通字符串
  setString(key: string, value: string): void { 
    this.mmkv?.encodeString(key, value); 
    this.addKeyToIndex(key);
  }
  getString(key: string, defaultValue: string = ''): string {
    return this.mmkv?.decodeString(key, defaultValue) ?? defaultValue;
  }

  // 布尔
  setBoolean(key: string, value: boolean): void { 
    this.mmkv?.encodeBool(key, value); 
    this.addKeyToIndex(key);
  }
  getBoolean(key: string, defaultValue: boolean = false): boolean {
    return this.mmkv?.decodeBool(key, defaultValue) ?? defaultValue;
  }

  // 数值
  setNumber(key: string, value: number): void { 
    this.mmkv?.encodeDouble(key, value); 
    this.addKeyToIndex(key);
  }
  getNumber(key: string, defaultValue: number = 0): number {
    return this.mmkv?.decodeDouble(key, defaultValue) ?? defaultValue;
  }

  setInt64(key: string, value: bigint): void { 
    this.mmkv?.encodeInt64(key, value); 
    this.addKeyToIndex(key);
  }
  getInt64(key: string, defaultValue: bigint = BigInt(0)): bigint {
    return this.mmkv?.decodeInt64(key, defaultValue) ?? defaultValue;
  }

  // 对象（JSON）
  setObject<T>(key: string, value: T): void {
    this.setString(key, JSON.stringify(value));
  }
  getObject<T>(key: string, defaultValue?: T): T | null {
    const str = this.getString(key, '');
    if (!str) return defaultValue ?? null;
    try { return JSON.parse(str) as T; } catch { return defaultValue ?? null; }
  }

  // 加密存储（敏感数据）
  async setEncryptedString(key: string, value: string): Promise<void> {
    if (!this.cryptoHelper) {
      CacheLogger.warn(TAG, 'CryptoHelper not available, storing plain text');
      this.setString(key, value);
      return;
    }
    const encrypted = await this.cryptoHelper.encrypt(value);
    this.setString(key, `enc:${encrypted}`);
  }

  async getDecryptedString(key: string, defaultValue: string = ''): Promise<string> {
    const stored = this.getString(key, '');
    if (!stored || !stored.startsWith('enc:')) return stored || defaultValue;
    const encrypted = stored.substring(4);
    if (!this.cryptoHelper) {
      CacheLogger.warn(TAG, 'CryptoHelper not available, returning encrypted value');
      return encrypted;
    }
    try {
      return await this.cryptoHelper.decrypt(encrypted);
    } catch (err) {
      CacheLogger.error(TAG, `Decrypt failed for ${key}: ${err}`);
      return defaultValue;
    }
  }

  contains(key: string): boolean { return this.mmkv?.containsKey(key) ?? false; }
  delete(key: string): void { 
    this.mmkv?.removeValueForKey(key); 
    this.removeKeyFromIndex(key);
  }
  clear(): void { 
    this.mmkv?.clearAll(); 
    // 清空索引
    this.mmkv?.removeValueForKey(MMKVManager.KEY_INDEX_PREFIX);
  }
}