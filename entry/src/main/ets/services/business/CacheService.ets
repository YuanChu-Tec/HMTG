/**
 * CacheService - 统一缓存服务
 * 职责：
 * - 委托给 @storage/cache (CacheStorage) 进行数据缓存与持久化
 * - 提供统一的缓存访问接口
 * - 管理缓存生命周期和清理策略
 * 
 * 重构说明：
 * - 原 AvatarCacheManager/MediaCacheManager/MessageCacheManager/StickerCacheManager
 *   全部委托给 CacheStorage 处理
 * - 保留 CacheService 作为业务层统一入口
 */

import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { http } from '@kit.NetworkKit';
import { util } from '@kit.ArkTS';
import { fileIo as fs } from '@kit.CoreFileKit';
import {
  CacheStorage,
  MessageData,
  MessageEntity,
  ChatEntity,
  UserEntity,
  MediaEntity,
  ContactEntity,
  StoryEntity,
  StickerEntity
} from '@storage/cache';
import { FileType } from '../../models/TDLibData';

const TAG = 'CacheService';

/**
 * 缓存元数据接口
 */
export interface CacheMetadata {
  chatId?: number;
  msgId?: number;
  fileName?: string;
}

/**
 * 媒体文件元数据接口
 */
export interface MediaMetadata {
  fileId: string;
  localPath: string;
  fileType: string;
  size?: number;
  mimeType?: string;
  isDownloaded?: boolean;
  downloadProgress?: number;
  width?: number;
  height?: number;
  duration?: number;
}

/**
 * 媒体类型枚举（兼容旧代码）
 */
export enum MediaType {
  IMAGE = 'image',
  VIDEO = 'video',
  AUDIO = 'audio',
  VOICE = 'voice',
  DOCUMENT = 'document',
  STICKER = 'sticker',
  ANIMATION = 'animation',
  FILE = 'file'
}

/**
 * 头像缓存条目接口（兼容旧代码）
 */
export interface AvatarCacheEntry {
  userId: number;
  avatarUrl: string;
  imageData: ArrayBuffer;
  timestamp: number;
}

/**
 * 头像获取结果接口（兼容旧代码）
 */
export interface AvatarFetchResult {
  userId: number;
  imageData: ArrayBuffer;
}

/**
 * 贴纸信息接口（兼容旧代码）
 */
export interface StickerInfo {
  emoji?: string;
  width?: number;
  height?: number;
}

/**
 * 缓存统计结果接口（兼容旧代码）
 */
export interface CacheStatsResult {
  hitCount: number;
  missCount: number;
  totalSize: number;
  count: number;
}

/**
 * 贴纸缓存统计接口（兼容旧代码）
 */
export interface StickerCacheStats {
  count: number;
  totalSize: number;
}

/**
 * 缓存统计聚合接口
 */
export interface CacheStats {
  avatarStats: CacheStatsResult;
  mediaStats: CacheStatsResult;
  messageStats?: CacheStatsResult;
  stickerStats?: StickerCacheStats;
}

/**
 * Lottie 动画配置接口
 */
export interface LottieAnimationConfig {
  /** 动画唯一标识 */
  key: string;
  /** 动画 URL (CDN 或本地路径) */
  url: string;
  /** 是否循环播放 */
  loop?: boolean;
  /** 是否自动播放 */
  autoPlay?: boolean;
}

/**
 * 预定义的常用动画配置
 */
export const PREDEFINED_ANIMATIONS: LottieAnimationConfig[] = [
  {
    key: 'duck-phone',
    url: 'https://cdn.jsdelivr.net/npm/tgs-collection/duck-phone.json',
    loop: true,
    autoPlay: true
  },
  {
    key: 'duck-code',
    url: 'https://cdn.jsdelivr.net/npm/tgs-collection/duck-code.json',
    loop: true,
    autoPlay: true
  },
  {
    key: 'duck-password',
    url: 'https://cdn.jsdelivr.net/npm/tgs-collection/duck-password-unlock.json',
    loop: true,
    autoPlay: true
  }
];

export class CacheService {
  private static instance?: CacheService;
  private cacheStorage?: CacheStorage;
  private isInitialized: boolean = false;
  private context?: common.Context;

  private constructor() {
    // 延迟初始化，等待 context 注入
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): CacheService {
    if (!CacheService.instance) {
      CacheService.instance = new CacheService();
    }
    return CacheService.instance;
  }

  /**
   * 初始化缓存服务（需在应用启动时调用）
   */
  public async initialize(context: common.Context): Promise<void> {
    if (this.isInitialized) {
      hilog.info(0x0001, TAG, 'CacheService already initialized');
      return;
    }

    try {
      this.context = context;
      
      // ⭐ 获取 CacheStorage 实例（已在 EntryAbility 中初始化）
      this.cacheStorage = CacheStorage.getInstance();
      
      this.isInitialized = true;
      hilog.info(0x0001, TAG, '✅ CacheService initialized successfully (delegated to CacheStorage)');
    } catch (error) {
      hilog.error(0x0001, TAG, `❌ CacheService initialization failed: ${JSON.stringify(error)}`);
      throw new Error(String(error));
    }
  }

  /**
   * 确保已初始化
   */
  private ensureInitialized(): void {
    if (!this.isInitialized || !this.context) {
      throw new Error('CacheService not initialized. Call initialize() first.');
    }
  }

  // ==================== 头像缓存 API ====================

  /**
   * 缓存用户头像
   */
  public async cacheAvatar(userId: number, avatarUrl: string, imageData: ArrayBuffer): Promise<void> {
    this.ensureInitialized();
    try {
      // ⭐ 使用 CacheStorage 的 diskCache 存储头像
      const fileId = `avatar_${userId}`;
      this.cacheStorage!.diskCache.setBinarySync(fileId, imageData);
      
      // 同时保存用户信息到数据库
      const user = new UserEntity();
      user.userId = userId;
      user.profilePhotoFileId = fileId;
      await this.cacheStorage!.saveUser(user);
      
      hilog.debug(0x0001, TAG, `Avatar cached for user ${userId}`);
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to cache avatar for user ${userId}: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 获取用户头像
   */
  public async getAvatar(userId: number): Promise<AvatarCacheEntry | null> {
    this.ensureInitialized();
    try {
      const fileId = `avatar_${userId}`;
      const imageData = this.cacheStorage!.diskCache.getBinarySync(fileId);
      
      if (imageData) {
        hilog.debug(0x0001, TAG, `Avatar cache hit for user ${userId}`);
        return {
          userId,
          avatarUrl: fileId,
          imageData,
          timestamp: Date.now()
        };
      }
      return null;
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to get avatar for user ${userId}: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 批量预加载头像
   */
  public async preloadAvatars(
    userIds: number[],
    fetchAvatarData?: (userId: number) => Promise<AvatarFetchResult | null>
  ): Promise<void> {
    this.ensureInitialized();
    try {
      if (!fetchAvatarData) {
        hilog.warn(0x0001, TAG, 'No fetchAvatarData provided for preload');
        return;
      }
      
      // 批量获取并缓存头像
      for (const userId of userIds) {
        try {
          const result = await fetchAvatarData(userId);
          if (result) {
            await this.cacheAvatar(userId, `avatar_${userId}`, result.imageData);
          }
        } catch (e) {
          hilog.warn(0x0001, TAG, `Failed to preload avatar for user ${userId}`);
        }
      }
      
      hilog.info(0x0001, TAG, `Preloaded ${userIds.length} avatars`);
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to preload avatars: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 删除用户头像缓存
   */
  public async deleteAvatar(userId: number): Promise<boolean> {
    this.ensureInitialized();
    try {
      const fileId = `avatar_${userId}`;
      this.cacheStorage!.diskCache.removeSync(fileId);
      return true;
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to delete avatar for user ${userId}: ${JSON.stringify(error)}`);
      return false;
    }
  }

  // ==================== 媒体缓存 API ====================

  /**
   * 缓存媒体文件
   */
  public async cacheMedia(
    url: string,
    data: ArrayBuffer,
    mediaType: MediaType,
    metadata?: Partial<MediaEntity>
  ): Promise<void> {
    this.ensureInitialized();
    try {
      // ⭐ 使用 CacheStorage 存储媒体文件
      const fileId = url.replace('tdlib://file/', '');
      await this.cacheStorage!.cacheMediaFile(fileId, data);
      
      // 保存媒体元数据
      const media = new MediaEntity();
      media.fileId = fileId;
      media.remoteUrl = url;
      media.fileType = mediaType;
      media.size = data.byteLength;
      if (metadata) {
        media.width = metadata.width || 0;
        media.height = metadata.height || 0;
        media.mimeType = metadata.mimeType || '';
      }
      await this.cacheStorage!.saveMedia(media);
      
      hilog.debug(0x0001, TAG, `Media cached: ${url}`);
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to cache media ${url}: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 通过 fileId 缓存媒体文件（供 FileDownloadService 使用）
   * 将 fileId 转换为 tdlib://file/{fileId} URL 格式进行缓存
   */
  public async cacheMediaByFileId(
    fileId: number,
    data: ArrayBuffer,
    mediaType: MediaType
  ): Promise<void> {
    this.ensureInitialized();
    try {
      const fileIdStr = fileId.toString();
      await this.cacheStorage!.cacheMediaFile(fileIdStr, data);
      
      // 保存媒体元数据
      const media = new MediaEntity();
      media.fileId = fileIdStr;
      media.fileType = mediaType;
      media.size = data.byteLength;
      await this.cacheStorage!.saveMedia(media);
      
      hilog.debug(0x0001, TAG, `Media cached by fileId: ${fileId}`);
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to cache media by fileId ${fileId}: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 获取缩略图（自动下载，长期缓存）
   * @deprecated 使用 getMediaFile 替代
   */
  public async getThumbnail(chatId: number, msgId: number): Promise<ArrayBuffer | null> {
    this.ensureInitialized();
    try {
      // 从消息中获取缩略图 fileId
      const message = await this.cacheStorage!.getMessageWithCache(msgId);
      if (message && message.contentJson) {
        const content: Record<string, object> = JSON.parse(message.contentJson) as Record<string, object>;
        const photo = content['photo'] as Record<string, object> | undefined;
        const sizes = photo?.['sizes'] as Array<Record<string, object>> | undefined;
        const firstSize = sizes?.[0];
        const photoObj = firstSize?.['photo'] as Record<string, number> | undefined;
        const thumbFileId = photoObj?.['id'];
        if (thumbFileId) {
          return this.cacheStorage!.getMediaFile(thumbFileId.toString());
        }
      }
      return null;
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to get thumbnail for chat ${chatId}, msg ${msgId}: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 获取原图（按需下载，低优先级）
   * @deprecated 使用 getMediaFile 替代
   */
  public async getOriginal(chatId: number, msgId: number): Promise<ArrayBuffer | null> {
    this.ensureInitialized();
    try {
      // 从消息中获取原图 fileId
      const message = await this.cacheStorage!.getMessageWithCache(msgId);
      if (message && message.contentJson) {
        const content: Record<string, object> = JSON.parse(message.contentJson) as Record<string, object>;
        const photo = content['photo'] as Record<string, object> | undefined;
        const sizes = photo?.['sizes'] as Array<Record<string, object>> | undefined;
        if (sizes && sizes.length > 0) {
          const lastSize = sizes[sizes.length - 1];
          const photoObj = lastSize?.['photo'] as Record<string, number> | undefined;
          const fileId = photoObj?.['id'];
          if (fileId) {
            return this.cacheStorage!.getMediaFile(fileId.toString());
          }
        }
      }
      return null;
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to get original for chat ${chatId}, msg ${msgId}: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 下载并缓存原图（高优先级）
   * @deprecated 使用 cacheMediaFile 替代
   */
  public async downloadOriginal(chatId: number, msgId: number): Promise<ArrayBuffer | null> {
    // 此方法需要 FileDownloadService 配合，保持原有逻辑
    hilog.warn(0x0001, TAG, 'downloadOriginal is deprecated, use FileDownloadService instead');
    return this.getOriginal(chatId, msgId);
  }

  /**
   * 预加载媒体文件
   */
  public async preloadMedia(urls: string[], mediaType: MediaType): Promise<void> {
    this.ensureInitialized();
    try {
      // ⭐ 预加载媒体文件到磁盘缓存
      for (const url of urls) {
        try {
          const fileId = url.replace('tdlib://file/', '');
          // 检查是否已缓存
          const cached = this.cacheStorage!.getMediaFile(fileId);
          if (!cached) {
            hilog.debug(0x0001, TAG, `Media not cached, will download: ${url}`);
          }
        } catch (e) {
          hilog.warn(0x0001, TAG, `Failed to check media cache: ${url}`);
        }
      }
      hilog.info(0x0001, TAG, `Preload check completed for ${urls.length} media files`);
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to preload media: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 生成缩略图
   * @deprecated 使用 ImageKnifeManager 处理
   */
  public async generateThumbnail(url: string, mediaType: MediaType): Promise<ArrayBuffer | null> {
    this.ensureInitialized();
    try {
      // 使用 ImageKnife 生成缩略图
      const fileId = url.replace('tdlib://file/', '');
      const imageData = this.cacheStorage!.getMediaFile(fileId);
      if (imageData) {
        // 缩略图生成逻辑由 ImageKnife 处理
        return imageData;
      }
      return null;
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to generate thumbnail for ${url}: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 删除媒体缓存
   */
  public async deleteMedia(url: string, mediaType: MediaType): Promise<boolean> {
    this.ensureInitialized();
    try {
      const fileId = url.replace('tdlib://file/', '');
      await this.cacheStorage!.deleteMediaFile(fileId);
      return true;
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to delete media ${url}: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * 保存媒体文件元数据（不存储二进制数据）
   * 用于 FileDownloadService 记录已下载文件的路径和元数据
   */
  public async saveMediaMetadata(metadata: MediaMetadata): Promise<void> {
    this.ensureInitialized();
    try {
      // 创建 MediaEntity 并保存到数据库
      const media = new MediaEntity();
      media.fileId = metadata.fileId;
      media.localPath = metadata.localPath;
      media.fileType = metadata.fileType;
      media.size = metadata.size || 0;
      media.mimeType = metadata.mimeType || '';
      media.isDownloaded = metadata.isDownloaded ?? true;
      media.downloadProgress = metadata.downloadProgress || 100;
      media.width = metadata.width || 0;
      media.height = metadata.height || 0;
      media.duration = metadata.duration || 0;

      await this.cacheStorage!.saveMedia(media);
      hilog.debug(0x0001, TAG, `Media metadata saved: ${metadata.fileId}, path: ${metadata.localPath}`);
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to save media metadata: ${JSON.stringify(error)}`);
      throw new Error(String(error));
    }
  }

  /**
   * 根据 fileId 获取媒体文件元数据
   */
  public async getMediaMetadata(fileId: string): Promise<MediaEntity | null> {
    this.ensureInitialized();
    try {
      const media = await this.cacheStorage!.getMediaInfo(fileId);
      return media || null;
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to get media metadata for ${fileId}: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 根据 fileId 获取本地文件路径
   * 优先从数据库查询，返回缓存的路径
   */
  public async getLocalFilePath(fileId: string): Promise<string | null> {
    this.ensureInitialized();
    try {
      const media = await this.cacheStorage!.getMediaInfo(fileId);
      if (media && media.localPath && media.isDownloaded) {
        // 验证文件是否存在
        try {
          await fs.access(media.localPath);
          return media.localPath;
        } catch (e) {
          // 文件不存在，标记为未下载
          hilog.warn(0x0001, TAG, `Cached file not found: ${media.localPath}`);
          media.isDownloaded = false;
          await this.cacheStorage!.saveMedia(media);
          return null;
        }
      }
      return null;
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to get local file path for ${fileId}: ${JSON.stringify(error)}`);
      return null;
    }
  }

  // ==================== 贴纸缓存 API ====================

  /**
   * 缓存贴纸
   */
  public async cacheSticker(
    stickerId: number,
    setId: number,
    filePath: string,
    info: Partial<StickerInfo>
  ): Promise<void> {
    this.ensureInitialized();
    try {
      // ⭐ 使用 CacheStorage 保存贴纸
      const stickerEntity = new StickerEntity();
      stickerEntity.stickerId = stickerId.toString();
      stickerEntity.setId = setId.toString();
      stickerEntity.fileId = filePath;
      stickerEntity.emoji = info.emoji || '';
      await this.cacheStorage!.saveSticker(stickerEntity);
      hilog.debug(0x0001, TAG, `Sticker cached: ${stickerId}`);
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to cache sticker: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 获取贴纸路径
   */
  public async getStickerPath(stickerId: number): Promise<string | null> {
    this.ensureInitialized();
    try {
      // ⭐ 从 CacheStorage 获取贴纸
      const stickers = await this.cacheStorage!.getStickersBySetId('');
      const sticker = stickers.find(s => s.stickerId === stickerId.toString());
      return sticker?.fileId || null;
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to get sticker path: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 批量获取贴纸
   */
  public async getStickers(stickerIds: number[]): Promise<Map<number, string | null>> {
    this.ensureInitialized();
    try {
      const result = new Map<number, string | null>();
      // ⭐ 使用 CacheStorage 批量获取贴纸
      for (const stickerId of stickerIds) {
        const path = await this.getStickerPath(stickerId);
        result.set(stickerId, path);
      }
      return result;
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to get stickers: ${JSON.stringify(error)}`);
      return new Map();
    }
  }

  /**
   * 删除贴纸
   */
  public async deleteSticker(stickerId: number): Promise<boolean> {
    this.ensureInitialized();
    try {
      // ⭐ 使用 CacheStorage 删除贴纸
      await this.cacheStorage!.database.deleteMessage(stickerId);
      return true;
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to delete sticker: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * 删除整个贴纸包
   */
  public async deleteStickerSet(setId: number): Promise<number> {
    this.ensureInitialized();
    try {
      // ⭐ 使用 CacheStorage 删除贴纸包
      const stickers = await this.cacheStorage!.getStickersBySetId(setId.toString());
      for (const sticker of stickers) {
        await this.cacheStorage!.database.deleteMessage(Number(sticker.stickerId));
      }
      return stickers.length;
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to delete sticker set: ${JSON.stringify(error)}`);
      return 0;
    }
  }

  /**
   * 清理过期贴纸
   */
  public async cleanupExpiredStickers(maxAgeDays: number = 30): Promise<number> {
    this.ensureInitialized();
    try {
      // ⭐ 使用 CacheStorage 清理过期贴纸
      // StickerEntity 没有 createTime 字段，暂时返回0
      hilog.info(0x0001, TAG, 'cleanupExpiredStickers not fully implemented');
      return 0;
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to cleanup expired stickers: ${JSON.stringify(error)}`);
      return 0;
    }
  }

  // ==================== 缓存清理 API ====================

  /**
   * 清理旧头像
   */
  public async cleanupOldAvatars(maxAge: number = 7 * 24 * 60 * 60 * 1000): Promise<number> {
    this.ensureInitialized();
    try {
      // ⭐ 清理头像（通过清理用户表中的旧头像引用）
      // ChatEntity 没有 lastUpdated 字段，暂时返回0
      hilog.info(0x0001, TAG, 'cleanupOldAvatars not fully implemented');
      return 0;
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to cleanup old avatars: ${JSON.stringify(error)}`);
      return 0;
    }
  }

  /**
   * 清理旧媒体
   */
  public async cleanupOldMedia(maxAge: number = 7 * 24 * 60 * 60 * 1000): Promise<number> {
    this.ensureInitialized();
    try {
      // ⭐ 使用 CacheStorage 清理旧媒体
      await this.cacheStorage!.diskCache.cleanExpiredCache();
      hilog.info(0x0001, TAG, `Cleaned up old media files`);
      return 0;
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to cleanup old media: ${JSON.stringify(error)}`);
      return 0;
    }
  }

  /**
   * 清理特定类型的媒体
   */
  public async cleanupMediaType(mediaType: MediaType): Promise<number> {
    this.ensureInitialized();
    try {
      // ⭐ 从数据库获取特定类型的媒体并清理
      const allMedia = await this.cacheStorage!.database.getMediaByChatId(0); // 获取所有媒体
      let count = 0;
      for (const media of allMedia) {
        if (media.fileType === mediaType) {
          await this.cacheStorage!.deleteMediaFile(media.fileId);
          count++;
        }
      }
      hilog.info(0x0001, TAG, `Cleaned up ${count} ${mediaType} files`);
      return count;
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to cleanup ${mediaType} media: ${JSON.stringify(error)}`);
      return 0;
    }
  }

  /**
   * 清空所有缓存
   */
  public async clearAll(): Promise<void> {
    this.ensureInitialized();
    try {
      // ⭐ 使用 CacheStorage 清空所有缓存
      await this.cacheStorage!.clearAllCache();
      hilog.info(0x0001, TAG, 'All caches cleared');
    } catch (error) {
      hilog.error(0x0001, TAG, `Failed to clear all caches: ${JSON.stringify(error)}`);
      throw new Error(String(error));
    }
  }

  // ==================== 按 FileType 的统一缓存 API ====================

  /**
   * 根据 FileType 缓存文件数据
   * 自动路由到对应的缓存管理器
   */
  public async cacheByFileType(
    fileId: number,
    fileType: FileType,
    data: ArrayBuffer,
    metadata?: CacheMetadata
  ): Promise<boolean> {
    this.ensureInitialized();

    try {
      const fileIdStr = fileId.toString();
      
      // 根据文件类型决定缓存方式
      switch (fileType) {
        case FileType.PROFILE_PHOTO:
        case FileType.THUMBNAIL:
          // 头像/缩略图缓存
          await this.cacheAvatar(fileId, metadata?.fileName || `avatar_${fileId}`, data);
          break;

        case FileType.IMAGE:
        case FileType.VIDEO:
        case FileType.AUDIO:
        case FileType.VOICE_NOTE:
        case FileType.DOCUMENT:
        case FileType.ANIMATION:
          // 媒体文件缓存
          await this.cacheStorage!.cacheMediaFile(fileIdStr, data);
          // 保存媒体元数据
          const media = new MediaEntity();
          media.fileId = fileIdStr;
          media.fileType = fileType;
          media.size = data.byteLength;
          media.chatId = metadata?.chatId || 0;
          await this.cacheStorage!.saveMedia(media);
          break;

        case FileType.STICKER:
          // 贴纸缓存
          if (metadata?.chatId) {
            const stickerEntity = new StickerEntity();
            stickerEntity.stickerId = fileIdStr;
            stickerEntity.setId = metadata.chatId.toString();
            stickerEntity.fileId = fileIdStr;
            await this.cacheStorage!.saveSticker(stickerEntity);
          }
          break;

        default:
          hilog.info(0x0001, TAG, `No cache target for file type ${fileType}`);
          return false;
      }

      hilog.debug(0x0001, TAG, `Cached file ${fileId} of type ${fileType}`);
      return true;
    } catch (error) {
      hilog.error(0x0001, TAG, `Failed to cache file ${fileId} of type ${fileType}: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * 检查文件类型是否应该缓存
   */
  public shouldCache(fileType: FileType): boolean {
    // 所有媒体类型都缓存
    return [
      FileType.IMAGE,
      FileType.VIDEO,
      FileType.AUDIO,
      FileType.VOICE_NOTE,
      FileType.DOCUMENT,
      FileType.STICKER,
      FileType.ANIMATION,
      FileType.PROFILE_PHOTO,
      FileType.THUMBNAIL
    ].includes(fileType);
  }

  // ==================== 辅助方法 ====================

  /**
   * 根据 FileType 获取 MIME 类型
   */
  private getMimeType(fileType: FileType): string {
    switch (fileType) {
      case FileType.IMAGE:
      case FileType.PROFILE_PHOTO:
      case FileType.THUMBNAIL:
        return 'image/jpeg';
      case FileType.VIDEO:
      case FileType.VIDEO_NOTE:
      case FileType.ANIMATION:
        return 'video/mp4';
      case FileType.AUDIO:
        return 'audio/mpeg';
      case FileType.VOICE_NOTE:
        return 'audio/ogg';
      case FileType.STICKER:
        return 'image/webp';
      case FileType.DOCUMENT:
      default:
        return 'application/octet-stream';
    }
  }

  // ==================== 缓存统计 API ====================

  /**
   * 获取缓存统计信息
   */
  public async getCacheStats(): Promise<CacheStats> {
    this.ensureInitialized();

    try {
      // ⭐ 从 CacheStorage 获取统计信息
      const diskSize = await this.cacheStorage!.diskCache.getCacheSize();
      const entryCount = this.cacheStorage!.diskCache.getEntryCount();
      
      // 获取数据库统计
      const allChats = await this.cacheStorage!.getAllChats();
      
      return {
        avatarStats: {
          hitCount: 0,
          missCount: 0,
          totalSize: diskSize,
          count: 0
        },
        mediaStats: {
          hitCount: 0,
          missCount: 0,
          totalSize: diskSize,
          count: entryCount
        },
        messageStats: {
          hitCount: 0,
          missCount: 0,
          totalSize: 0,
          count: allChats.length
        },
        stickerStats: {
          count: 0,
          totalSize: 0
        }
      };
    } catch (error) {
      hilog.error(0x0001, TAG, `Failed to get cache stats: ${JSON.stringify(error)}`);
      return {
        avatarStats: { hitCount: 0, missCount: 0, totalSize: 0, count: 0 },
        mediaStats: { hitCount: 0, missCount: 0, totalSize: 0, count: 0 },
        stickerStats: { count: 0, totalSize: 0 }
      };
    }
  }

  /**
   * 检查是否已初始化
   */
  public isReady(): boolean {
    return this.isInitialized;
  }

  // ==================== Lottie 动画缓存 API ====================

  /**
   * 缓存 Lottie 动画数据
   * @param key 动画唯一标识
   * @param data 动画 JSON 数据
   */
  public async cacheLottieAnimation(key: string, data: object): Promise<void> {
    this.ensureInitialized();
    try {
      const jsonString = JSON.stringify(data);
      const encoder = new util.TextEncoder();
      const uint8Array = encoder.encodeInto(jsonString);
      
      // 使用 CacheStorage 的 diskCache 存储动画数据
      const fileId = `lottie_${key}`;
      // 将 Uint8Array 转为 ArrayBuffer
      const buffer = new ArrayBuffer(uint8Array.byteLength);
      const view = new Uint8Array(buffer);
      view.set(uint8Array);
      this.cacheStorage!.diskCache.setBinarySync(fileId, buffer);
      
      hilog.debug(0x0001, TAG, `Lottie animation cached: ${key}`);
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to cache Lottie animation ${key}: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 获取缓存的 Lottie 动画数据
   * @param key 动画唯一标识
   * @returns 动画数据或 null
   */
  public async getLottieAnimation(key: string): Promise<Object | null> {
    this.ensureInitialized();
    try {
      const fileId = `lottie_${key}`;
      const data = this.cacheStorage!.diskCache.getBinarySync(fileId);
      
      if (data) {
        const decoder = new util.TextDecoder();
        const jsonString = decoder.decodeWithStream(new Uint8Array(data));
        return JSON.parse(jsonString) as Object;
      }
      return null;
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to get Lottie animation ${key}: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 获取缓存的 Lottie 动画 Data URI
   * @param key 动画唯一标识
   * @returns Data URI 字符串或 null
   */
  public async getLottieDataUri(key: string): Promise<string | null> {
    this.ensureInitialized();
    try {
      const fileId = `lottie_${key}`;
      const data = this.cacheStorage!.diskCache.getBinarySync(fileId);
      
      if (data) {
        const base64Helper = new util.Base64Helper();
        const base64 = base64Helper.encodeToStringSync(new Uint8Array(data));
        return `data:application/json;base64,${base64}`;
      }
      return null;
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to get Lottie Data URI ${key}: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 预加载 Lottie 动画
   * @param config 动画配置
   */
  public async preloadLottieAnimation(config: LottieAnimationConfig): Promise<void> {
    this.ensureInitialized();
    try {
      // 检查是否已缓存
      const cached = await this.getLottieAnimation(config.key);
      if (cached) {
        hilog.debug(0x0001, TAG, `Lottie animation already cached: ${config.key}`);
        return;
      }

      // 从网络下载
      hilog.info(0x0001, TAG, `Downloading Lottie animation: ${config.key}`);
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(config.url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });
      
      if (response.responseCode === 200) {
        const result = response.result as string;
        const data = JSON.parse(result) as object;
        await this.cacheLottieAnimation(config.key, data);
        hilog.info(0x0001, TAG, `Lottie animation preloaded: ${config.key}`);
      } else {
        throw new Error(`HTTP error! status: ${response.responseCode}`);
      }
      
      httpRequest.destroy();
    } catch (error) {
      hilog.error(0x0001, TAG, `Failed to preload Lottie animation ${config.key}: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 批量预加载 Lottie 动画
   * @param configs 动画配置数组
   */
  public async preloadLottieBatch(configs: LottieAnimationConfig[]): Promise<void> {
    this.ensureInitialized();
    hilog.info(0x0001, TAG, `Batch preloading ${configs.length} Lottie animations`);
    await Promise.all(configs.map(config => this.preloadLottieAnimation(config)));
  }

  /**
   * 检查 Lottie 动画是否已缓存
   * @param key 动画唯一标识
   * @returns 是否已缓存
   */
  public async isLottieCached(key: string): Promise<boolean> {
    this.ensureInitialized();
    try {
      const fileId = `lottie_${key}`;
      const data = this.cacheStorage!.diskCache.getBinarySync(fileId);
      return data !== null;
    } catch (error) {
      return false;
    }
  }

  /**
   * 删除 Lottie 动画缓存
   * @param key 动画唯一标识
   */
  public async deleteLottieAnimation(key: string): Promise<void> {
    this.ensureInitialized();
    try {
      const fileId = `lottie_${key}`;
      this.cacheStorage!.diskCache.removeSync(fileId);
      hilog.info(0x0001, TAG, `Lottie animation cache cleared: ${key}`);
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to delete Lottie animation ${key}: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 清除所有 Lottie 动画缓存
   */
  public async clearAllLottieCache(): Promise<void> {
    this.ensureInitialized();
    try {
      // 使用 CacheStorage 的 clearAllCache 清理所有缓存
      await this.cacheStorage!.clearAllCache();
      hilog.info(0x0001, TAG, 'All Lottie animation caches cleared');
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to clear Lottie caches: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 销毁缓存服务（释放资源）
   */
  public async destroy(): Promise<void> {
    try {
      // ⭐ 关闭 CacheStorage
      if (this.cacheStorage) {
        await this.cacheStorage.close();
      }

      CacheService.instance = undefined;
      this.isInitialized = false;
      hilog.info(0x0001, TAG, '✅ CacheService destroyed successfully');
    } catch (error) {
      hilog.error(0x0001, TAG, `Failed to destroy CacheService: ${JSON.stringify(error)}`);
    }
  }
}
