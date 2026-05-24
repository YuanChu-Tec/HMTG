/**
 * PathManager - Telegram 路径管理工具类
 * 统一管理 filesDir 和 cacheDir 下的各类子目录路径
 */

import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';

export interface TDLibPaths {
  database_directory: string;
  files_directory: string;
}

export class PathManager {
  private static context: common.UIAbilityContext;

  /**
   * 初始化路径管理器
   */
  static init(context: common.UIAbilityContext): void {
    PathManager.context = context;
  }

  /**
   * 获取应用沙箱的 filesDir
   */
  static getFilesDir(): string {
    return PathManager.context.filesDir;
  }

  /**
   * 获取应用沙箱的 cacheDir
   */
  static getCacheDir(): string {
    return PathManager.context.cacheDir;
  }

  // ==================== filesDir 路径 (持久化) ====================

  /**
   * Telegram 主目录 (filesDir)
   */
  static getTelegramFilesDir(): string {
    return `${PathManager.getFilesDir()}/telegram`;
  }

  /**
   * 数据库目录
   */
  static getDatabaseDir(): string {
    return `${PathManager.getTelegramFilesDir()}/db`;
  }

  /**
   * 主数据库文件路径
   */
  static getMainDatabasePath(): string {
    return `${PathManager.getDatabaseDir()}/telegram.db`;
  }

  /**
   * TDLib 数据库目录
   */
  static getTDLibDatabaseDir(): string {
    return `${PathManager.getFilesDir()}/tdlib/db`;
  }

  /**
   * Preferences 配置目录
   */
  static getPreferencesDir(): string {
    return `${PathManager.getTelegramFilesDir()}/preferences`;
  }

  /**
   * 用户主动保存的文件目录
   */
  static getSavedFilesDir(): string {
    return `${PathManager.getTelegramFilesDir()}/saved`;
  }

  /**
   * 保存的照片目录
   */
  static getSavedPhotosDir(): string {
    return `${PathManager.getSavedFilesDir()}/photos`;
  }

  /**
   * 保存的视频目录
   */
  static getSavedVideosDir(): string {
    return `${PathManager.getSavedFilesDir()}/videos`;
  }

  /**
   * 保存的文档目录
   */
  static getSavedDocumentsDir(): string {
    return `${PathManager.getSavedFilesDir()}/documents`;
  }

  // ==================== cacheDir 路径 (可清理) ====================

  /**
   * Telegram 缓存主目录 (cacheDir)
   */
  static getTelegramCacheDir(): string {
    return `${PathManager.getCacheDir()}/telegram`;
  }

  /**
   * 头像缓存目录
   */
  static getAvatarCacheDir(): string {
    return `${PathManager.getTelegramCacheDir()}/avatars`;
  }

  /**
   * 缩略图缓存目录
   */
  static getThumbnailCacheDir(): string {
    return `${PathManager.getTelegramCacheDir()}/thumbnails`;
  }

  /**
   * 媒体原图缓存目录
   */
  static getMediaCacheDir(): string {
    return `${PathManager.getTelegramCacheDir()}/media`;
  }

  /**
   * 贴纸缓存目录
   */
  static getStickerCacheDir(): string {
    return `${PathManager.getTelegramCacheDir()}/stickers`;
  }

  /**
   * 语音消息缓存目录
   */
  static getVoiceCacheDir(): string {
    return `${PathManager.getTelegramCacheDir()}/voice`;
  }

  /**
   * GIF 动画缓存目录
   */
  static getGifCacheDir(): string {
    return `${PathManager.getTelegramCacheDir()}/gifs`;
  }

  /**
   * 自动下载的文件缓存目录
   */
  static getDocumentCacheDir(): string {
    return `${PathManager.getTelegramCacheDir()}/documents`;
  }

  /**
   * 日志文件目录
   */
  static getLogDir(): string {
    return `${PathManager.getTelegramCacheDir()}/logs`;
  }

  /**
   * TDLib 临时文件目录
   */
  static getTDLibTempFilesDir(): string {
    return `${PathManager.getCacheDir()}/tdlib/files`;
  }

  // ==================== TDLib 配置路径 ====================

  /**
   * 获取 TDLib 初始化参数中的路径配置
   */
  static getTDLibPaths(): TDLibPaths {
    return {
      database_directory: PathManager.getTDLibDatabaseDir(),
      files_directory: PathManager.getTDLibTempFilesDir()
    };
  }

  // ==================== 工具方法 ====================

  /**
   * 确保目录存在(同步)
   */
  static ensureDirSync(path: string): void {
    if (!fileIo.accessSync(path)) {
      fileIo.mkdirSync(path, true);
    }
  }

  /**
   * 确保所有必要目录存在
   */
  static ensureAllDirs(): void {
    const dirs: string[] = [
      PathManager.getDatabaseDir(),
      PathManager.getPreferencesDir(),
      PathManager.getSavedFilesDir(),
      PathManager.getSavedPhotosDir(),
      PathManager.getSavedVideosDir(),
      PathManager.getSavedDocumentsDir(),
      PathManager.getTelegramCacheDir(),
      PathManager.getAvatarCacheDir(),
      PathManager.getThumbnailCacheDir(),
      PathManager.getMediaCacheDir(),
      PathManager.getStickerCacheDir(),
      PathManager.getVoiceCacheDir(),
      PathManager.getGifCacheDir(),
      PathManager.getDocumentCacheDir(),
      PathManager.getLogDir(),
      PathManager.getTDLibDatabaseDir(),
      PathManager.getTDLibTempFilesDir()
    ];

    dirs.forEach(dir => {
      if (!fileIo.accessSync(dir)) {
        fileIo.mkdirSync(dir, true);
      }
    });
  }
}
