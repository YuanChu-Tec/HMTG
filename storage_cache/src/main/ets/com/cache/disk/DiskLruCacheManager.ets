import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { CacheLogger } from '../utils/Logger';

const TAG = 'DiskCache';

interface CacheEntry {
  data: ArrayBuffer;
  expireAt: number;
}

export class DiskLruCacheManager {
  private static instance: DiskLruCacheManager;
  private context: common.UIAbilityContext | null = null;
  private cacheDir: string = '';
  private readonly CACHE_DIR_NAME = 'storage_cache';
  private lruCache: util.LRUCache<string, ArrayBuffer>;

  private constructor(context: common.UIAbilityContext) {
    this.context = context;
    this.cacheDir = `${context.cacheDir}/${this.CACHE_DIR_NAME}`;
    this.lruCache = new util.LRUCache<string, ArrayBuffer>(100);
    this.initCacheDir();
  }

  public static getInstance(context?: common.UIAbilityContext): DiskLruCacheManager {
    if (!DiskLruCacheManager.instance && context) {
      DiskLruCacheManager.instance = new DiskLruCacheManager(context);
    }
    return DiskLruCacheManager.instance;
  }

  private initCacheDir(): void {
    try {
      if (!fs.accessSync(this.cacheDir)) {
        fs.mkdirSync(this.cacheDir);
      }
      CacheLogger.info(TAG, `Cache dir ready: ${this.cacheDir}`);
    } catch (err) {
      CacheLogger.error(TAG, `Init cache dir failed: ${JSON.stringify(err)}`);
    }
  }

  private getFilePath(key: string): string {
    return `${this.cacheDir}/${encodeURIComponent(key)}`;
  }

  // 同步二进制（无TTL）
  setBinarySync(key: string, data: ArrayBuffer): boolean {
    try {
      const path = this.getFilePath(key);
      const file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(file.fd, data);
      fs.closeSync(file);
      this.lruCache.put(key, data);
      return true;
    } catch (err) {
      CacheLogger.error(TAG, `setBinarySync failed: ${err}`);
      return false;
    }
  }

  getBinarySync(key: string): ArrayBuffer | null {
    let data = this.lruCache.get(key);
    if (data) return data;
    try {
      const path = this.getFilePath(key);
      if (!fs.accessSync(path)) return null;
      const file = fs.openSync(path, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(path);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file);
      this.lruCache.put(key, buffer);
      return buffer;
    } catch (err) {
      CacheLogger.error(TAG, `getBinarySync failed: ${err}`);
      return null;
    }
  }

  // 带TTL的存储
  setBinaryWithTTL(key: string, data: ArrayBuffer, ttlMs: number): boolean {
    const entry: CacheEntry = { data, expireAt: Date.now() + ttlMs };
    const encoder = new util.TextEncoder();
    const wrapperStr = JSON.stringify(entry);
    const wrapperData = encoder.encodeInto(wrapperStr);
    return this.setBinarySync(key, wrapperData.buffer as ArrayBuffer);
  }

  getBinaryWithTTL(key: string): ArrayBuffer | null {
    const wrapperData = this.getBinarySync(key);
    if (!wrapperData) return null;
    const decoder = new util.TextDecoder();
    const wrapperStr = decoder.decodeWithStream(new Uint8Array(wrapperData));
    try {
      const entry: CacheEntry = JSON.parse(wrapperStr);
      if (entry.expireAt > Date.now()) {
        this.lruCache.put(key, entry.data);
        return entry.data;
      } else {
        this.removeSync(key);
        CacheLogger.debug(TAG, `Cache expired: ${key}`);
        return null;
      }
    } catch (err) {
      // 兼容旧格式
      return wrapperData;
    }
  }

  setStringSync(key: string, value: string): boolean {
    const encoder = new util.TextEncoder();
    return this.setBinarySync(key, encoder.encodeInto(value));
  }

  getStringSync(key: string): string | null {
    const data = this.getBinarySync(key);
    if (data) {
      const decoder = new util.TextDecoder();
      return decoder.decodeWithStream(new Uint8Array(data));
    }
    return null;
  }

  removeSync(key: string): boolean {
    try {
      const path = this.getFilePath(key);
      if (fs.accessSync(path)) fs.unlinkSync(path);
      this.lruCache.remove(key);
      return true;
    } catch (err) {
      return false;
    }
  }

  clearSync(): void {
    try {
      const files = fs.listFileSync(this.cacheDir);
      for (const f of files) fs.unlinkSync(`${this.cacheDir}/${f}`);
      this.lruCache.clear();
      CacheLogger.info(TAG, `Cleared ${files.length} cache files`);
    } catch (err) {
      CacheLogger.error(TAG, `clearSync failed: ${err}`);
    }
  }

  cleanExpiredCache(): void {
    try {
      const files = fs.listFileSync(this.cacheDir);
      let cleaned = 0;
      for (const file of files) {
        const key = decodeURIComponent(file);
        const data = this.getBinarySync(key);
        if (data) {
          const decoder = new util.TextDecoder();
          const str = decoder.decodeWithStream(new Uint8Array(data));
          if (str.startsWith('{"data":')) {
            try {
              const entry: CacheEntry = JSON.parse(str);
              if (entry.expireAt <= Date.now()) {
                fs.unlinkSync(`${this.cacheDir}/${file}`);
                cleaned++;
              }
            } catch (e) {}
          }
        }
      }
      CacheLogger.info(TAG, `Cleaned ${cleaned} expired entries`);
    } catch (err) {
      CacheLogger.error(TAG, `cleanExpiredCache failed: ${err}`);
    }
  }

  // 异步封装
  async setBinary(key: string, data: ArrayBuffer): Promise<boolean> {
    return this.setBinarySync(key, data);
  }
  async getBinary(key: string): Promise<ArrayBuffer | null> {
    return this.getBinarySync(key);
  }
  async remove(key: string): Promise<boolean> {
    return this.removeSync(key);
  }
  async clear(): Promise<void> {
    this.clearSync();
  }

  // ==================== 缓存信息查询 API ====================

  /**
   * 获取缓存目录路径
   */
  getCacheDir(): string {
    return this.cacheDir;
  }

  /**
   * 获取缓存大小（字节）
   */
  async getCacheSize(): Promise<number> {
    return this.calculateDirSize(this.cacheDir);
  }

  /**
   * 获取缓存条目数量
   */
  getEntryCount(): number {
    try {
      return fs.listFileSync(this.cacheDir).length;
    } catch {
      return 0;
    }
  }

  /**
   * 计算目录大小
   */
  private calculateDirSize(dirPath: string): number {
    try {
      if (!fs.accessSync(dirPath)) {
        return 0;
      }

      const files = fs.listFileSync(dirPath);
      let totalSize = 0;

      for (const fileName of files) {
        const filePath = `${dirPath}/${fileName}`;
        try {
          const stat = fs.statSync(filePath);
          if (stat.isDirectory()) {
            totalSize += this.calculateDirSize(filePath);
          } else {
            totalSize += stat.size;
          }
        } catch {
          // 忽略单个文件错误
        }
      }

      return totalSize;
    } catch (error) {
      CacheLogger.warn(TAG, `Failed to calculate dir size: ${dirPath}, ${error}`);
      return 0;
    }
  }
}