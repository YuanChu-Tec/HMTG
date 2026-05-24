/**
 * CacheCleaner - 缓存清理工具类
 * 提供自动和手动清理缓存的功能
 */

import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { PathManager } from '../utils/PathManager';
import { CacheStorage } from '@storage/cache';

export interface CacheSizeInfo {
  avatarCache: number;      // 头像缓存大小(字节)
  mediaCache: number;       // 媒体缓存大小(字节)
  thumbnailCache: number;   // 缩略图缓存大小(字节)
  stickerCache: number;     // 贴纸缓存大小(字节)
  voiceCache: number;       // 语音缓存大小(字节)
  gifCache: number;         // GIF缓存大小(字节)
  logFiles: number;         // 日志文件大小(字节)
  totalCache: number;       // 总缓存大小
}

export class CacheCleaner {
  private static context: common.UIAbilityContext | undefined;

  /**
   * 初始化清理器
   */
  static init(context: common.UIAbilityContext): void {
    CacheCleaner.context = context;
  }

  /**
   * 获取各缓存目录的大小信息
   */
  static async getCacheSizes(): Promise<CacheSizeInfo> {
    const sizes: CacheSizeInfo = {
      avatarCache: await CacheCleaner.getDirSize(PathManager.getAvatarCacheDir()),
      mediaCache: await CacheCleaner.getDirSize(PathManager.getMediaCacheDir()),
      thumbnailCache: await CacheCleaner.getDirSize(PathManager.getThumbnailCacheDir()),
      stickerCache: await CacheCleaner.getDirSize(PathManager.getStickerCacheDir()),
      voiceCache: await CacheCleaner.getDirSize(PathManager.getVoiceCacheDir()),
      gifCache: await CacheCleaner.getDirSize(PathManager.getGifCacheDir()),
      logFiles: await CacheCleaner.getDirSize(PathManager.getLogDir()),
      totalCache: 0
    };

    sizes.totalCache = 
      sizes.avatarCache +
      sizes.mediaCache +
      sizes.thumbnailCache +
      sizes.stickerCache +
      sizes.voiceCache +
      sizes.gifCache +
      sizes.logFiles;

    return sizes;
  }

  /**
   * 清除所有缓存(保留聊天记录数据库)
   * 适用于"设置 -> 数据和存储 -> 清除缓存"
   */
  static async clearAllCache(): Promise<void> {
    console.log('[CacheCleaner] Starting cache cleanup...');

    try {
      // ⭐ 使用 CacheStorage 清除所有缓存
      if (CacheCleaner.context) {
        const cacheStorage = CacheStorage.getInstance(CacheCleaner.context);
        await cacheStorage.clearAllCache();
        console.log('[CacheCleaner] CacheStorage cache cleared');
      }

      // 清除日志文件
      await CacheCleaner.clearDirectory(PathManager.getLogDir());
      console.log('[CacheCleaner] Log files cleared');

      console.log('[CacheCleaner] Cache cleanup completed successfully');
    } catch (error) {
      console.error('[CacheCleaner] Cache cleanup failed:', error);
      throw new Error(String(error));
    }
  }

  /**
   * 仅清除媒体缓存(保留头像、贴纸等)
   * 适用于快速释放空间
   */
  static async clearMediaCacheOnly(): Promise<void> {
    console.log('[CacheCleaner] Clearing media cache only...');

    // ⭐ 使用 CacheStorage 清除媒体缓存
    if (CacheCleaner.context) {
      const cacheStorage = CacheStorage.getInstance(CacheCleaner.context);
      // 清理磁盘缓存中的媒体文件
      await cacheStorage.diskCache.cleanExpiredCache();
    }

    console.log('[CacheCleaner] Media cache cleared');
  }

  /**
   * 清除过期缓存(超过指定天数的文件)
   */
  static async clearExpiredCache(maxAgeDays: number = 30): Promise<number> {
    console.log(`[CacheCleaner] Clearing cache older than ${maxAgeDays} days...`);

    // ⭐ 使用 CacheStorage 清理过期缓存
    if (CacheCleaner.context) {
      const cacheStorage = CacheStorage.getInstance(CacheCleaner.context);
      await cacheStorage.diskCache.cleanExpiredCache();
    }

    console.log('[CacheCleaner] Expired cache cleaned');
    return 0;
  }

  /**
   * 清除所有数据(包括数据库、配置、缓存)
   * 适用于退出登录时
   */
  static async clearAllData(): Promise<void> {
    console.log('[CacheCleaner] Starting full data cleanup...');

    try {
      // 1. 先清除缓存
      await CacheCleaner.clearAllCache();

      // 2. 清除数据库文件
      await CacheCleaner.deleteDatabase();
      console.log('[CacheCleaner] Database deleted');

      // 3. 清除 Preferences
      await CacheCleaner.clearPreferences();
      console.log('[CacheCleaner] Preferences cleared');

      // 4. 清除 TDLib 工作目录
      await CacheCleaner.clearTDLibWorkingDir();
      console.log('[CacheCleaner] TDLib working directory cleared');

      console.log('[CacheCleaner] Full data cleanup completed');
    } catch (error) {
      console.error('[CacheCleaner] Full data cleanup failed:', error);
      throw new Error(String(error));
    }
  }

  /**
   * 按类型清除缓存
   */
  static async clearCacheByType(type: 'avatars' | 'media' | 'stickers' | 'voice' | 'gifs' | 'logs'): Promise<void> {
    // ⭐ 使用 CacheStorage 按类型清除缓存
    if (CacheCleaner.context) {
      const cacheStorage = CacheStorage.getInstance(CacheCleaner.context);

      switch (type) {
        case 'avatars':
          // 清理头像缓存
          await cacheStorage.clearAllCache();
          break;
        case 'media':
          // 清理媒体缓存
          await cacheStorage.diskCache.cleanExpiredCache();
          break;
        case 'stickers':
        case 'voice':
        case 'gifs':
          // 这些类型在 CacheStorage 中统一处理
          await cacheStorage.diskCache.cleanExpiredCache();
          break;
        case 'logs':
          await CacheCleaner.clearDirectory(PathManager.getLogDir());
          break;
      }
    }

    console.log(`[CacheCleaner] ${type} cache cleared`);
  }

  // ==================== 私有方法 ====================

  /**
   * 获取目录大小(字节)
   */
  private static async getDirSize(dirPath: string): Promise<number> {
    try {
      if (!fileIo.accessSync(dirPath)) {
        return 0;
      }

      const files = fileIo.listFileSync(dirPath);
      let totalSize = 0;

      for (const fileName of files) {
        const filePath = `${dirPath}/${fileName}`;
        try {
          const stat = fileIo.statSync(filePath);
          if (stat.isDirectory()) {
            totalSize += await CacheCleaner.getDirSize(filePath);
          } else {
            totalSize += stat.size;
          }
        } catch (e) {
          // 忽略单个文件错误
        }
      }

      return totalSize;
    } catch (error) {
      console.warn(`[CacheCleaner] Failed to get dir size: ${dirPath}`, error);
      return 0;
    }
  }

  /**
   * 清空目录(删除所有文件和子目录)
   */
  private static async clearDirectory(dirPath: string): Promise<void> {
    try {
      if (!fileIo.accessSync(dirPath)) {
        return;
      }

      const files = fileIo.listFileSync(dirPath);
      for (const fileName of files) {
        const filePath = `${dirPath}/${fileName}`;
        try {
          const stat = fileIo.statSync(filePath);
          if (stat.isDirectory()) {
            await CacheCleaner.clearDirectory(filePath);
            fileIo.rmdirSync(filePath);
          } else {
            fileIo.unlinkSync(filePath);
          }
        } catch (e) {
          console.warn(`[CacheCleaner] Failed to delete: ${filePath}`, e);
        }
      }
    } catch (error) {
      console.warn(`[CacheCleaner] Failed to clear directory: ${dirPath}`, error);
    }
  }

  /**
   * 清理过期文件
   */
  private static async cleanOldFiles(dirPath: string, cutoffTime: number): Promise<number> {
    let cleanedCount = 0;

    try {
      if (!fileIo.accessSync(dirPath)) {
        return 0;
      }

      const files = fileIo.listFileSync(dirPath);
      for (const fileName of files) {
        const filePath = `${dirPath}/${fileName}`;
        try {
          const stat = fileIo.statSync(filePath);
          if (stat.isDirectory()) {
            cleanedCount += await CacheCleaner.cleanOldFiles(filePath, cutoffTime);
          } else if (stat.mtime < cutoffTime) {
            fileIo.unlinkSync(filePath);
            cleanedCount++;
          }
        } catch (e) {
          // 忽略单个文件错误
        }
      }
    } catch (error) {
      console.warn(`[CacheCleaner] Failed to clean old files: ${dirPath}`, error);
    }

    return cleanedCount;
  }

  /**
   * 删除数据库文件
   */
  private static async deleteDatabase(): Promise<void> {
    const dbDir = PathManager.getDatabaseDir();
    if (fileIo.accessSync(dbDir)) {
      const files = fileIo.listFileSync(dbDir);
      for (const fileName of files) {
        const filePath = `${dbDir}/${fileName}`;
        try {
          fileIo.unlinkSync(filePath);
        } catch (e) {
          console.warn(`[CacheCleaner] Failed to delete database file: ${filePath}`, e);
        }
      }
    }
  }

  /**
   * 清除 Preferences
   */
  private static async clearPreferences(): Promise<void> {
    const prefsDir = PathManager.getPreferencesDir();
    if (fileIo.accessSync(prefsDir)) {
      await CacheCleaner.clearDirectory(prefsDir);
    }
  }

  /**
   * 清除 TDLib 工作目录
   */
  private static async clearTDLibWorkingDir(): Promise<void> {
    if (CacheCleaner.context) {
      const tdlibDir = `${CacheCleaner.context.filesDir}/tdlib`;
      if (fileIo.accessSync(tdlibDir)) {
        await CacheCleaner.clearDirectory(tdlibDir);
      }
    }
  }
}
