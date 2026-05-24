// services/FileDownloadService.ets
import { common } from '@kit.AbilityKit';
import { fileIo as fs, statfs } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { TDLibApi, TdApiFactory } from '../api';
import { EventBus } from '../../utils/event/EventBus';
import { NetworkMonitor } from '../../utils/network/NetworkMonitor';
import { FileSizeFormatter } from '../../utils/formatter/FileSizeFormatter';
import { CacheService, MediaType, MediaMetadata } from '../business/CacheService';
import { Deferred } from '../../utils/Deferred';
import {
  FileType, DownloadPriority, DownloadStatus, NetworkPolicy,
  AutoDownloadConfig, DownloadTask, DownloadProgressData,
  DownloadCompleteData, DownloadFailedData, DownloadPausedData,
  DownloadQueuedData, DownloadStartData, DownloadCancelledData,
  PersistedDownloadTask, DownloadEvent
} from '../../models/TDLibData';

const TAG = 'FileDownloadService';
const STORAGE_KEY = 'download_tasks'; // 用于持久化
const DEFAULT_AUTO_CONFIG: AutoDownloadConfig = {
  // 基础媒体类型
  images: NetworkPolicy.WIFI_OR_CELLULAR,
  videos: NetworkPolicy.WIFI_ONLY,
  audios: NetworkPolicy.WIFI_OR_CELLULAR,
  documents: NetworkPolicy.NEVER,

  // 消息类型
  stickers: NetworkPolicy.WIFI_OR_CELLULAR,
  animations: NetworkPolicy.WIFI_OR_CELLULAR,
  voiceNotes: NetworkPolicy.WIFI_OR_CELLULAR,
  videoNotes: NetworkPolicy.WIFI_ONLY,

  // 特殊类型
  profilePhotos: NetworkPolicy.WIFI_OR_CELLULAR,
  wallpapers: NetworkPolicy.WIFI_ONLY,
  thumbnails: NetworkPolicy.WIFI_OR_CELLULAR,

  // 文件大小限制
  maxImageSize: 10 * 1024 * 1024,      // 10MB
  maxVideoSize: 100 * 1024 * 1024,     // 100MB
  maxAudioSize: 50 * 1024 * 1024,      // 50MB
  maxDocumentSize: 100 * 1024 * 1024,  // 100MB
  maxStickerSize: 5 * 1024 * 1024,     // 5MB
  maxAnimationSize: 20 * 1024 * 1024,  // 20MB
  maxVoiceNoteSize: 10 * 1024 * 1024,  // 10MB
  maxVideoNoteSize: 50 * 1024 * 1024,  // 50MB
  maxProfilePhotoSize: 5 * 1024 * 1024, // 5MB
  maxThumbnailSize: 2 * 1024 * 1024,   // 2MB

  roamingAllowed: false
};

/**
 * 优化版文件下载服务
 */
export class FileDownloadService {
  private static instance: FileDownloadService;
  private tdApi: TDLibApi;
  private eventBus: EventBus;
  private networkMonitor: NetworkMonitor;
  private cacheService: CacheService;
  private downloadEventBus: EventBus = EventBus.getInstance(); // 独立的下载事件总线
  
  // 文件ID到本地路径的映射(用于快速查询)
  private filePathCache: Map<number, string> = new Map();

  // 配置
  private autoConfig: AutoDownloadConfig = {
    images: DEFAULT_AUTO_CONFIG.images,
    videos: DEFAULT_AUTO_CONFIG.videos,
    audios: DEFAULT_AUTO_CONFIG.audios,
    documents: DEFAULT_AUTO_CONFIG.documents,
    stickers: DEFAULT_AUTO_CONFIG.stickers,
    animations: DEFAULT_AUTO_CONFIG.animations,
    voiceNotes: DEFAULT_AUTO_CONFIG.voiceNotes,
    videoNotes: DEFAULT_AUTO_CONFIG.videoNotes,
    profilePhotos: DEFAULT_AUTO_CONFIG.profilePhotos,
    wallpapers: DEFAULT_AUTO_CONFIG.wallpapers,
    thumbnails: DEFAULT_AUTO_CONFIG.thumbnails,
    maxImageSize: DEFAULT_AUTO_CONFIG.maxImageSize,
    maxVideoSize: DEFAULT_AUTO_CONFIG.maxVideoSize,
    maxAudioSize: DEFAULT_AUTO_CONFIG.maxAudioSize,
    maxDocumentSize: DEFAULT_AUTO_CONFIG.maxDocumentSize,
    maxStickerSize: DEFAULT_AUTO_CONFIG.maxStickerSize,
    maxAnimationSize: DEFAULT_AUTO_CONFIG.maxAnimationSize,
    maxVoiceNoteSize: DEFAULT_AUTO_CONFIG.maxVoiceNoteSize,
    maxVideoNoteSize: DEFAULT_AUTO_CONFIG.maxVideoNoteSize,
    maxProfilePhotoSize: DEFAULT_AUTO_CONFIG.maxProfilePhotoSize,
    maxThumbnailSize: DEFAULT_AUTO_CONFIG.maxThumbnailSize,
    roamingAllowed: DEFAULT_AUTO_CONFIG.roamingAllowed
  };
  private maxConcurrentDownloads: number = 3;
  private currentDownloads: Set<string> = new Set(); // 正在下载的任务ID集合
  private downloadQueue: DownloadTask[] = [];

  // 任务存储
  private tasks: Map<string, DownloadTask> = new Map();
  private taskDeferreds: Map<string, Deferred<string>> = new Map(); // 等待完成的Promise

  // 网络状态
  private isWifiConnected: boolean = true;
  private isCellularConnected: boolean = false;
  private isRoaming: boolean = false;

  // UI更新节流
  private pendingProgressEvents: Map<string, DownloadProgressData> = new Map();
  private updateTimerId: number = -1;
  private readonly UPDATE_INTERVAL_MS = 100;

  // ⭐ 当前活跃聊天上下文（用于优先级调整）
  private currentActiveChatId: number | undefined = undefined;
  private readonly CURRENT_CHAT_PRIORITY_BOOST = 10; // 当前聊天任务的优先级加成
  
  // ⭐ 头像下载特殊优先级（最高优先级，确保头像最先下载）
  private readonly AVATAR_PRIORITY_BOOST = 100; // 头像下载的额外优先级加成
  private readonly MAX_CONCURRENT_AVATAR_DOWNLOADS = 2; // 头像下载专用并发槽位

  private constructor(context: common.Context) {
    this.tdApi = TdApiFactory.getInstance().createDefault();
    this.eventBus = EventBus.getInstance();
    this.networkMonitor = NetworkMonitor.getInstance();
    this.cacheService = CacheService.getInstance();
    // 初始化 CacheService
    this.cacheService.initialize(context).catch((e: Error) => {
      hilog.error(0x0001, TAG, `CacheService init failed: ${e.message}`);
    });
    this.initNetworkMonitor();
    this.initTdLibEvents();
    this.restoreTasksIfNeeded(); // 可选：恢复持久化任务
  }

  static getInstance(context?: common.Context): FileDownloadService {
    if (!FileDownloadService.instance && context) {
      FileDownloadService.instance = new FileDownloadService(context);
    }
    return FileDownloadService.instance;
  }

  /**
   * ⭐ 设置当前活跃聊天（用于下载优先级优化）
   * 当用户进入某个聊天页面时调用，该聊天的下载任务将获得优先级加成
   */
  setCurrentActiveChat(chatId: number | undefined): void {
    if (this.currentActiveChatId !== chatId) {
      const oldChatId = this.currentActiveChatId;
      this.currentActiveChatId = chatId;
      hilog.info(0x0001, TAG, `Active chat changed: ${oldChatId} -> ${chatId}`);
      
      // ⭐ 重新排序下载队列，让新活跃聊天的任务优先
      if (chatId !== undefined) {
        this.prioritizeCurrentChatDownloads(chatId);
      }
    }
  }

  /**
   * ⭐ 优先处理当前聊天的下载任务
   */
  private prioritizeCurrentChatDownloads(chatId: number): void {
    let reprioritizedCount = 0;
    
    // 1. 提升队列中当前聊天任务的优先级
    for (const task of this.downloadQueue) {
      if (task.chatId === chatId && task.priority < DownloadPriority.HIGH + this.CURRENT_CHAT_PRIORITY_BOOST) {
        task.priority += this.CURRENT_CHAT_PRIORITY_BOOST;
        reprioritizedCount++;
      }
    }
    
    // 2. 重新排序队列
    if (reprioritizedCount > 0) {
      this.reorderQueue();
      hilog.info(0x0001, TAG, `Reprioritized ${reprioritizedCount} tasks for chat ${chatId}`);
    }
    
    // 3. 如果当前正在下载的任务不是当前聊天的，考虑暂停并切换
    // 注意：这里不强制中断正在进行的下载，只是让新任务优先入队
  }

  // ==================== 初始化 ====================
  private initNetworkMonitor(): void {
    this.updateNetworkState();
    this.networkMonitor.onNetworkStateChange(() => {
      const oldWifi = this.isWifiConnected;
      const oldCellular = this.isCellularConnected;
      this.updateNetworkState();
      this.onNetworkChanged(oldWifi, oldCellular);
    });
  }

  private updateNetworkState(): void {
    this.isWifiConnected = this.networkMonitor.isConnected(); // 简化处理
    this.isCellularConnected = this.networkMonitor.isConnected(); // 需要根据实际 API 调整
    this.isRoaming = false; // 默认非漫游，需要 NetworkMonitor 支持
  }

  private initTdLibEvents(): void {
    this.eventBus.on('updateFile', (data?: Object) => {
      if (data) {
        this.handleFileUpdate(data as Record<string, Object>);
      }
    });
  }

  /**
   * 获取缓存的文件路径
   */
  async getCachedPath(fileId: number): Promise<string | null> {
    // 1. 先查内存缓存
    const cachedPath = this.filePathCache.get(fileId);
    if (cachedPath) {
      return cachedPath;
    }

    // 2. 尝试从 TDLib 获取文件信息
    try {
      const fileInfo = await this.tdApi.getFile(fileId);
      // File 类型有 local 属性，直接访问
      const local = fileInfo.local;
      if (local && local.is_downloading_completed === true) {
        const path = local.path;
        if (path && path.length > 0) {
          // 缓存路径
          this.filePathCache.set(fileId, path);
          return path;
        }
      }
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to get file info for ${fileId}: ${JSON.stringify(error)}`);
    }

    return null;
  }

  /**
   * 转换 FileType 为 MediaType
   */
  private convertFileTypeToMediaType(fileType: FileType): MediaType {
    switch (fileType) {
      case FileType.IMAGE:
      case FileType.PROFILE_PHOTO:
      case FileType.WALLPAPER:
      case FileType.THUMBNAIL:
        return MediaType.IMAGE;
      case FileType.VIDEO:
      case FileType.VIDEO_NOTE:
      case FileType.ANIMATION:
        return MediaType.VIDEO;
      case FileType.AUDIO:
      case FileType.VOICE_NOTE:
        return MediaType.AUDIO;
      case FileType.STICKER:
        // 贴纸可能为静态图片或动画，统一按图片处理
        return MediaType.IMAGE;
      default:
        return MediaType.FILE;
    }
  }

  /**
   * 添加缓存文件记录
   * 优化策略：不再重复存储二进制数据，只缓存文件元数据
   * TDLib 已经管理本地文件存储，我们只需记录路径和元数据
   */
  addCachedFile(fileId: number, filePath: string, fileType: FileType, fileSize?: number): void {
    // 1. 更新内存缓存
    this.filePathCache.set(fileId, filePath);

    // 2. 异步保存文件元数据到 CacheService（不存储二进制数据）
    this.saveFileMetadata(fileId, filePath, fileType, fileSize).catch((err: Error) => {
      hilog.warn(0x0001, TAG, `Failed to save file metadata for ${fileId}: ${err.message}`);
    });

    hilog.debug(0x0001, TAG, `Cached file ${fileId} metadata, path: ${filePath}`);
  }

  /**
   * 保存文件元数据到 storage_cache
   * 只存储文件路径和元数据，不存储二进制数据
   */
  private async saveFileMetadata(
    fileId: number,
    filePath: string,
    fileType: FileType,
    fileSize?: number
  ): Promise<void> {
    try {
      // 获取文件信息（如果未提供）
      let size = fileSize || 0;
      let mimeType = '';

      if (size === 0) {
        try {
          const stat = await fs.stat(filePath);
          size = stat.size;
        } catch (e) {
          hilog.warn(0x0001, TAG, `Failed to stat file ${filePath}`);
        }
      }

      // 推断 MIME 类型
      mimeType = this.inferMimeType(filePath, fileType);

      // 通过 CacheService 保存媒体元数据（不读取文件内容）
      const metadata: MediaMetadata = {
        fileId: fileId.toString(),
        localPath: filePath,
        fileType: this.convertFileTypeToString(fileType),
        size: size,
        mimeType: mimeType,
        isDownloaded: true,
        downloadProgress: 100
      };
      await this.cacheService.saveMediaMetadata(metadata);

      hilog.debug(0x0001, TAG, `Saved file ${fileId} metadata to CacheService`);
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to save file metadata: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 推断 MIME 类型
   */
  private inferMimeType(filePath: string, fileType: FileType): string {
    const ext = filePath.split('.').pop()?.toLowerCase() || '';

    const mimeMap: Record<string, string> = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'mp4': 'video/mp4',
      'mov': 'video/quicktime',
      'mp3': 'audio/mpeg',
      'ogg': 'audio/ogg',
      'oga': 'audio/ogg',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'txt': 'text/plain'
    };

    if (mimeMap[ext]) {
      return mimeMap[ext];
    }

    // 根据 FileType 推断
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
      default:
        return 'application/octet-stream';
    }
  }

  /**
   * 转换 FileType 为字符串
   */
  private convertFileTypeToString(fileType: FileType): string {
    switch (fileType) {
      case FileType.IMAGE: return 'image';
      case FileType.VIDEO: return 'video';
      case FileType.AUDIO: return 'audio';
      case FileType.VOICE_NOTE: return 'voice';
      case FileType.DOCUMENT: return 'document';
      case FileType.STICKER: return 'sticker';
      case FileType.ANIMATION: return 'animation';
      case FileType.PROFILE_PHOTO: return 'profile_photo';
      case FileType.THUMBNAIL: return 'thumbnail';
      default: return 'file';
    }
  }

  /**
   * 清除文件缓存
   */
  clearCachedFile(fileId: number): void {
    this.filePathCache.delete(fileId);
    hilog.debug(0x0001, TAG, `Cleared cache for file ${fileId}`);
  }

  /**
   * 清空所有缓存
   */
  clearAllCachedFiles(): void {
    this.filePathCache.clear();
    hilog.info(0x0001, TAG, 'Cleared all file caches');
  }

  // ==================== 公共 API ====================

  /**
   * 下载文件（支持优先级动态提升）
   */
  async downloadFile(
    fileId: number,
    type: FileType,
    priority: DownloadPriority = DownloadPriority.NORMAL,
    messageId?: number,
    chatId?: number
  ): Promise<string> {
    // 1. 检查缓存
    const cachedPath = await this.getCachedPath(fileId);
    if (cachedPath) {
      hilog.debug(0x0001, TAG, `Cache hit for ${fileId}`);
      return cachedPath;
    }

    const taskId = this.getTaskId(fileId);
    let task = this.tasks.get(taskId);

    // 2. 如果任务已存在
    if (task) {
      // 已完成：直接返回路径
      if (task.status === DownloadStatus.COMPLETED && task.localPath) {
        return task.localPath;
      }
      // 下载中或队列中：提升优先级
      if (task.status === DownloadStatus.DOWNLOADING || task.status === DownloadStatus.QUEUED) {
        if (task.priority < priority) {
          task.priority = priority;
          this.reorderQueue(); // 重新排序队列
          hilog.info(0x0001, TAG, `Priority upgraded for ${fileId} to ${priority}`);
        }
        // 等待现有任务完成
        const deferred = this.taskDeferreds.get(taskId);
        if (deferred) {
          return deferred.promise;
        }
      }
      // 暂停状态：可以恢复，同样提升优先级
      if (task.status === DownloadStatus.PAUSED) {
        task.priority = priority;
        this.resumeDownload(fileId); // 自动恢复
        const deferred = this.taskDeferreds.get(taskId);
        if (deferred) return deferred.promise;
      }
    }

    // 3. 创建新任务
    const fileSize = await this.getFileSize(fileId);
    const fileName = await this.getFileName(fileId);
    task = {
      id: taskId,
      fileId,
      type,
      priority,
      status: DownloadStatus.PENDING,
      progress: 0,
      downloadedBytes: 0,
      totalBytes: fileSize,
      createTime: Date.now(),
      messageId,
      chatId,
      fileName,
      formattedSize: FileSizeFormatter.format(fileSize)
    };
    this.tasks.set(taskId, task);

    // 4. 检查网络策略（不符合则进入暂停，不抛错）
    if (!this.shouldAutoDownload(task)) {
      task.status = DownloadStatus.PAUSED;
      const pausedData: DownloadPausedData = { taskId, fileId, reason: 'network_policy' };
      this.emitEvent(DownloadEvent.PAUSED, pausedData);
      // 仍返回一个 Promise，但会等待网络恢复后自动开始
      const deferred = new Deferred<string>();
      this.taskDeferreds.set(taskId, deferred);
      // 不加入队列，等网络恢复时再入队
      return deferred.promise;
    }

    // 5. 检查磁盘空间
    const freeSpace = await this.getFreeDiskSpace();
    if (freeSpace < fileSize * 1.1) {
      task.status = DownloadStatus.FAILED;
      task.error = 'Insufficient disk space';
      const failedData: DownloadFailedData = { taskId, fileId, error: task.error };
      this.emitEvent(DownloadEvent.FAILED, failedData);
      throw new Error(task.error);
    }

    // 6. 入队并调度
    this.enqueueTask(task);
    const deferred = new Deferred<string>();
    this.taskDeferreds.set(taskId, deferred);
    this.scheduleDownloads();
    return deferred.promise;
  }

  /**
   * 预下载多个文件
   */
  async preloadFiles(fileIds: number[], type: FileType): Promise<void> {
    const promises = fileIds.map(id =>
      this.downloadFile(id, type, DownloadPriority.LOW).catch((err: Error) =>
        hilog.warn(0x0001, TAG, `Preload failed for ${id}: ${err.message}`)
      )
    );
    await Promise.all(promises);
  }

  /**
   * 暂停下载
   */
  async pauseDownload(fileId: number): Promise<void> {
    const taskId = this.getTaskId(fileId);
    const task = this.tasks.get(taskId);
    if (!task || task.status !== DownloadStatus.DOWNLOADING) return;

    try {
      // TDLib API 不支持 pauseFileDownload，使用 cancelDownloadFile 替代
      await this.tdApi.cancelDownloadFile(fileId, false);
      // 注意：TDLib 会触发 updateFile，其中 local.is_downloading_active 变为 false
      // 我们在 handleFileUpdate 中处理状态变更
    } catch (error) {
      hilog.error(0x0001, TAG, `Pause failed for ${fileId}: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 恢复下载（断点续传）
   */
  async resumeDownload(fileId: number): Promise<void> {
    const taskId = this.getTaskId(fileId);
    const task = this.tasks.get(taskId);
    if (!task || task.status !== DownloadStatus.PAUSED) return;

    // 重新检查网络策略
    if (!this.shouldAutoDownload(task)) {
      hilog.debug(0x0001, TAG, `Cannot resume ${fileId}: network policy not met`);
      return;
    }

    task.status = DownloadStatus.PENDING;
    this.enqueueTask(task);
    this.scheduleDownloads();
  }

  /**
   * 取消下载
   */
  async cancelDownload(fileId: number): Promise<void> {
    const taskId = this.getTaskId(fileId);
    const task = this.tasks.get(taskId);
    if (!task) return;

    if (task.status === DownloadStatus.DOWNLOADING) {
      await this.tdApi.cancelDownloadFile(fileId, false); // priority, synchronous
      this.currentDownloads.delete(taskId);
    }
    this.cleanupTask(taskId, false);
    const cancelledData: DownloadCancelledData = { taskId, fileId };
    this.emitEvent(DownloadEvent.CANCELLED, cancelledData);
    this.scheduleDownloads();
  }

  /**
   * 根据消息 ID 取消所有相关下载（消息删除时调用）
   */
  async cancelDownloadsForMessage(messageId: number): Promise<void> {
    const tasksToCancel = Array.from(this.tasks.values())
      .filter(task => task.messageId === messageId);
    for (const task of tasksToCancel) {
      await this.cancelDownload(task.fileId);
    }
    hilog.info(0x0001, TAG, `Cancelled ${tasksToCancel.length} downloads for message ${messageId}`);
  }

  /**
   * 根据聊天 ID 取消所有下载（可选）
   */
  async cancelDownloadsForChat(chatId: number): Promise<void> {
    const tasksToCancel = Array.from(this.tasks.values())
      .filter(task => task.chatId === chatId);
    for (const task of tasksToCancel) {
      await this.cancelDownload(task.fileId);
    }
  }

  /**
   * 获取任务信息
   */
  getTask(fileId: number): DownloadTask | undefined {
    return this.tasks.get(this.getTaskId(fileId));
  }

  /**
   * 获取所有任务
   */
  getAllTasks(): DownloadTask[] {
    return Array.from(this.tasks.values());
  }

  /**
   * 更新自动下载配置
   */
  updateAutoDownloadConfig(config: Partial<AutoDownloadConfig>): void {
    // ArkTS 不支持展开运算符，需要手动合并属性
    // 基础媒体类型
    if (config.images !== undefined) this.autoConfig.images = config.images;
    if (config.videos !== undefined) this.autoConfig.videos = config.videos;
    if (config.audios !== undefined) this.autoConfig.audios = config.audios;
    if (config.documents !== undefined) this.autoConfig.documents = config.documents;

    // 消息类型
    if (config.stickers !== undefined) this.autoConfig.stickers = config.stickers;
    if (config.animations !== undefined) this.autoConfig.animations = config.animations;
    if (config.voiceNotes !== undefined) this.autoConfig.voiceNotes = config.voiceNotes;
    if (config.videoNotes !== undefined) this.autoConfig.videoNotes = config.videoNotes;

    // 特殊类型
    if (config.profilePhotos !== undefined) this.autoConfig.profilePhotos = config.profilePhotos;
    if (config.wallpapers !== undefined) this.autoConfig.wallpapers = config.wallpapers;
    if (config.thumbnails !== undefined) this.autoConfig.thumbnails = config.thumbnails;

    // 文件大小限制
    if (config.maxImageSize !== undefined) this.autoConfig.maxImageSize = config.maxImageSize;
    if (config.maxVideoSize !== undefined) this.autoConfig.maxVideoSize = config.maxVideoSize;
    if (config.maxAudioSize !== undefined) this.autoConfig.maxAudioSize = config.maxAudioSize;
    if (config.maxDocumentSize !== undefined) this.autoConfig.maxDocumentSize = config.maxDocumentSize;
    if (config.maxStickerSize !== undefined) this.autoConfig.maxStickerSize = config.maxStickerSize;
    if (config.maxAnimationSize !== undefined) this.autoConfig.maxAnimationSize = config.maxAnimationSize;
    if (config.maxVoiceNoteSize !== undefined) this.autoConfig.maxVoiceNoteSize = config.maxVoiceNoteSize;
    if (config.maxVideoNoteSize !== undefined) this.autoConfig.maxVideoNoteSize = config.maxVideoNoteSize;
    if (config.maxProfilePhotoSize !== undefined) this.autoConfig.maxProfilePhotoSize = config.maxProfilePhotoSize;
    if (config.maxThumbnailSize !== undefined) this.autoConfig.maxThumbnailSize = config.maxThumbnailSize;

    if (config.roamingAllowed !== undefined) this.autoConfig.roamingAllowed = config.roamingAllowed;

    // 网络策略变更，重新评估所有暂停任务
    for (const task of this.tasks.values()) {
      if (task.status === DownloadStatus.PAUSED && this.shouldAutoDownload(task)) {
        this.resumeDownload(task.fileId);
      }
    }
  }

  /**
   * 设置最大并发数
   */
  setMaxConcurrentDownloads(max: number): void {
    this.maxConcurrentDownloads = Math.max(1, Math.min(10, max));
    this.scheduleDownloads();
  }

  /**
   * 注册业务事件监听
   */
  on(event: DownloadEvent, handler: (data?: Object) => void): void {
    this.downloadEventBus.on(event, handler);
  }

  off(event: DownloadEvent, handler: (data?: Object) => void): void {
    // EventBus 的 off 需要传入 handler，这里简化处理
    hilog.debug(0x0001, TAG, `Unregister listener for event: ${event}`);
  }

  // ==================== 私有方法 ====================

  private getTaskId(fileId: number): string {
    return `download_${fileId}`;
  }

  private async getFileName(fileId: number): Promise<string> {
    try {
      const fileInfo = await this.tdApi.getFile(fileId);
      // File 类型有 remote 属性
      const remote = fileInfo.remote;
      return remote?.unique_id || `file_${fileId}`;
    } catch {
      return `file_${fileId}`;
    }
  }

  private async getFileSize(fileId: number): Promise<number> {
    try {
      const fileInfo = await this.tdApi.getFile(fileId);
      // File 类型有 size 属性
      return fileInfo.size || 0;
    } catch {
      return 0;
    }
  }

  private async getFreeDiskSpace(): Promise<number> {
    try {
      const path = '/data/storage/el2/base/haps/entry'; // 应用沙箱路径
      // HarmonyOS 使用 statfs.getFreeSize 获取可用空间
      const free = await statfs.getFreeSize(path);
      return free;
    } catch (error) {
      hilog.error(0x0001, TAG, 'Failed to get disk space');
      return 1024 * 1024 * 1024; // fallback 1GB
    }
  }

  private shouldAutoDownload(task: DownloadTask): boolean {
    const type = task.type;
    const totalBytes = task.totalBytes;
    let policy: NetworkPolicy;
    let maxSize: number;

    switch (type) {
      case FileType.IMAGE:
      case FileType.THUMBNAIL:
        policy = this.autoConfig.images;
        maxSize = this.autoConfig.maxImageSize;
        break;
      case FileType.VIDEO:
        policy = this.autoConfig.videos;
        maxSize = this.autoConfig.maxVideoSize;
        break;
      case FileType.AUDIO:
        policy = this.autoConfig.audios;
        maxSize = this.autoConfig.maxAudioSize;
        break;
      case FileType.DOCUMENT:
        policy = this.autoConfig.documents;
        maxSize = this.autoConfig.maxDocumentSize;
        break;
      case FileType.STICKER:
        policy = this.autoConfig.stickers;
        maxSize = this.autoConfig.maxStickerSize;
        break;
      case FileType.ANIMATION:
        policy = this.autoConfig.animations;
        maxSize = this.autoConfig.maxAnimationSize;
        break;
      case FileType.VOICE_NOTE:
        policy = this.autoConfig.voiceNotes;
        maxSize = this.autoConfig.maxVoiceNoteSize;
        break;
      case FileType.VIDEO_NOTE:
        policy = this.autoConfig.videoNotes;
        maxSize = this.autoConfig.maxVideoNoteSize;
        break;
      case FileType.PROFILE_PHOTO:
        policy = this.autoConfig.profilePhotos;
        maxSize = this.autoConfig.maxProfilePhotoSize;
        break;
      case FileType.WALLPAPER:
        policy = this.autoConfig.wallpapers;
        maxSize = this.autoConfig.maxDocumentSize; // 壁纸使用文档大小限制
        break;
      case FileType.SECRET:
      case FileType.SECRET_THUMBNAIL:
      case FileType.SECURE:
        // 安全类型文件默认不自动下载，需要用户手动确认
        policy = NetworkPolicy.NEVER;
        maxSize = 0;
        break;
      default:
        policy = this.autoConfig.documents;
        maxSize = this.autoConfig.maxDocumentSize;
    }

    if (policy === NetworkPolicy.NEVER) return false;
    if (policy === NetworkPolicy.WIFI_ONLY && !this.isWifiConnected) return false;
    if (policy === NetworkPolicy.CELLULAR_ONLY && !this.isCellularConnected) return false;
    if (this.isRoaming && !this.autoConfig.roamingAllowed) return false;
    if (maxSize > 0 && totalBytes > maxSize) return false;
    return true;
  }

  private enqueueTask(task: DownloadTask): void {
    // 移除可能已存在的相同任务（避免重复入队）
    const existingIndex = this.downloadQueue.findIndex(t => t.id === task.id);
    if (existingIndex !== -1) this.downloadQueue.splice(existingIndex, 1);
    
    // ⭐ 头像下载特殊处理：给予最高优先级
    if (task.type === FileType.PROFILE_PHOTO) {
      task.priority += this.AVATAR_PRIORITY_BOOST;
      hilog.debug(0x0001, TAG, `Avatar task ${task.id} boosted to priority ${task.priority}`);
    }
    
    // ⭐ 如果任务属于当前活跃聊天，提升优先级
    if (task.chatId && task.chatId === this.currentActiveChatId) {
      task.priority += this.CURRENT_CHAT_PRIORITY_BOOST;
      hilog.debug(0x0001, TAG, `Priority boosted for task ${task.id} in active chat ${task.chatId}`);
    }
    
    // 按优先级插入
    const index = this.downloadQueue.findIndex(t => t.priority < task.priority);
    if (index === -1) this.downloadQueue.push(task);
    else this.downloadQueue.splice(index, 0, task);
    task.status = DownloadStatus.QUEUED;
    const queuedData: DownloadQueuedData = { taskId: task.id, fileId: task.fileId };
    this.emitEvent(DownloadEvent.QUEUED, queuedData);
  }

  private reorderQueue(): void {
    this.downloadQueue.sort((a, b) => b.priority - a.priority);
  }

  private scheduleDownloads(): void {
    // ⭐ 统计当前正在下载的头像任务数量
    let currentAvatarDownloads = 0;
    for (const taskId of this.currentDownloads) {
      const task = this.tasks.get(taskId);
      if (task && task.type === FileType.PROFILE_PHOTO) {
        currentAvatarDownloads++;
      }
    }
    
    // ⭐ 优先调度头像下载任务（插队机制）
    // 如果还有头像在等待队列中，优先启动它们
    const avatarTasksInQueue = this.downloadQueue.filter(t => t.type === FileType.PROFILE_PHOTO && t.status !== DownloadStatus.PAUSED);
    
    // 先处理头像任务（最多占用 MAX_CONCURRENT_AVATAR_DOWNLOADS 个槽位）
    while (currentAvatarDownloads < this.MAX_CONCURRENT_AVATAR_DOWNLOADS && 
           avatarTasksInQueue.length > 0 && 
           this.currentDownloads.size < this.maxConcurrentDownloads) {
      const avatarTask = avatarTasksInQueue.shift()!;
      // 从队列中移除
      const index = this.downloadQueue.findIndex(t => t.id === avatarTask.id);
      if (index !== -1) {
        this.downloadQueue.splice(index, 1);
      }
      this.startDownload(avatarTask);
      currentAvatarDownloads++;
      hilog.debug(0x0001, TAG, `Avatar task ${avatarTask.id} started with priority scheduling`);
    }
    
    // 处理其他类型的下载任务
    while (this.currentDownloads.size < this.maxConcurrentDownloads && this.downloadQueue.length > 0) {
      const task = this.downloadQueue.shift()!;
      if (task.status === DownloadStatus.PAUSED) continue;
      this.startDownload(task);
    }
  }

  private async startDownload(task: DownloadTask): Promise<void> {
    this.currentDownloads.add(task.id);
    task.status = DownloadStatus.DOWNLOADING;
    task.startTime = Date.now();
    const startData: DownloadStartData = { taskId: task.id, fileId: task.fileId };
    this.emitEvent(DownloadEvent.START, startData);

    try {
      // 真正支持断点续传：传入已下载的字节数作为 offset
      const offset = task.downloadedBytes;
      // limit = 0 表示下载剩余全部
      await this.tdApi.downloadFile(task.fileId, task.priority, offset, 0, false);
      // 实际完成由 updateFile 事件驱动
    } catch (error) {
      hilog.error(0x0001, TAG, `Start download failed for ${task.fileId}: ${JSON.stringify(error)}`);
      task.status = DownloadStatus.FAILED;
      task.error = error instanceof Error ? error.message : String(error);
      const failedData: DownloadFailedData = { taskId: task.id, fileId: task.fileId, error: task.error };
      this.emitEvent(DownloadEvent.FAILED, failedData);
      this.cleanupTask(task.id, true);
      this.scheduleDownloads();
    }
  }

  private handleFileUpdate(update: Record<string, Object>): void {
    const file = update.file as Record<string, Object>;
    if (!file) return;
    const fileId = file.id as number;
    const taskId = this.getTaskId(fileId);
    const task = this.tasks.get(taskId);
    if (!task) return;

    const local = file.local as Record<string, Object>;
    if (!local) return;

    // 下载中
    if (local.is_downloading_active === true) {
      const downloaded = local.downloaded_size as number;
      const total = file.size as number;
      // 更新已下载字节（用于断点续传）
      task.downloadedBytes = downloaded;
      task.totalBytes = total;
      task.progress = total > 0 ? downloaded / total : 0;
      task.formattedDownloaded = FileSizeFormatter.format(downloaded);
      task.formattedTotal = FileSizeFormatter.format(total);

      // 计算速度
      const elapsed = (Date.now() - (task.startTime || Date.now())) / 1000;
      const speed = elapsed > 0 ? downloaded / elapsed : 0;
      const remaining = speed > 0 ? (total - downloaded) / speed : 0;
      const progressData: DownloadProgressData = {
        taskId: task.id,
        fileId: task.fileId,
        progress: task.progress,
        downloadedBytes: downloaded,
        totalBytes: total,
        formattedDownloaded: task.formattedDownloaded,
        formattedTotal: task.formattedTotal,
        speedBytesPerSec: speed,
        formattedSpeed: this.formatSpeed(speed),
        estimatedTimeLeftMs: remaining * 1000,
        formattedTimeLeft: this.formatTimeLeft(remaining)
      };
      this.throttleProgressUpdate(progressData);
    }
    // 下载完成
    else if (local.is_downloading_completed === true) {
      task.status = DownloadStatus.COMPLETED;
      task.progress = 1;
      task.downloadedBytes = task.totalBytes;
      task.localPath = local.path as string;
      task.endTime = Date.now();
      const durationMs = (task.endTime - (task.startTime || task.endTime));
      
      // 添加缓存记录（传入文件大小）
      this.addCachedFile(task.fileId, task.localPath, task.type, task.totalBytes);

      const completeData: DownloadCompleteData = {
        taskId: task.id,
        fileId: task.fileId,
        localPath: task.localPath,
        durationMs,
        formattedDuration: this.formatDuration(durationMs)
      };
      this.emitEvent(DownloadEvent.COMPLETE, completeData);

      // 通知等待的 Promise
      const deferred = this.taskDeferreds.get(task.id);
      if (deferred) {
        deferred.resolve(task.localPath);
        this.taskDeferreds.delete(task.id);
      }
      this.cleanupTask(task.id, true);
      this.scheduleDownloads();
    }
    // 暂停或失败
    else if (local.is_downloading_active === false && !local.is_downloading_completed) {
      // 检查是否有错误
      if (local.can_be_deleted === false && local.path === '') {
        // 可能失败
        task.status = DownloadStatus.FAILED;
        task.error = local.download_error as string || 'Download failed';
        const failedData: DownloadFailedData = { taskId: task.id, fileId: task.fileId, error: task.error };
        this.emitEvent(DownloadEvent.FAILED, failedData);
        const deferred = this.taskDeferreds.get(task.id);
        if (deferred) {
          deferred.reject(new Error(task.error));
          this.taskDeferreds.delete(task.id);
        }
        this.cleanupTask(task.id, true);
      } else if (task.status === DownloadStatus.DOWNLOADING) {
        // 主动暂停
        task.status = DownloadStatus.PAUSED;
        const pausedData: DownloadPausedData = { taskId: task.id, fileId: task.fileId, reason: 'user' };
        this.emitEvent(DownloadEvent.PAUSED, pausedData);
        this.cleanupTask(task.id, true);
      }
      this.scheduleDownloads();
    }
  }

  private throttleProgressUpdate(data: DownloadProgressData): void {
    this.pendingProgressEvents.set(data.taskId, data);
    if (this.updateTimerId === -1) {
      this.updateTimerId = setTimeout(() => {
        for (const progressData of this.pendingProgressEvents.values()) {
          this.emitEvent(DownloadEvent.PROGRESS, progressData);
        }
        this.pendingProgressEvents.clear();
        this.updateTimerId = -1;
      }, this.UPDATE_INTERVAL_MS);
    }
  }

  private cleanupTask(taskId: string, decrementConcurrent: boolean): void {
    if (decrementConcurrent && this.currentDownloads.has(taskId)) {
      this.currentDownloads.delete(taskId);
    }
    // 注意：不删除 tasks 中的任务，保留用于查询和断点续传
    // 如果希望完全清理，可以调用 cancelDownload
  }

  private onNetworkChanged(oldWifi: boolean, oldCellular: boolean): void {
    // 对于所有暂停的任务，重新评估是否满足网络策略
    for (const task of this.tasks.values()) {
      if (task.status === DownloadStatus.PAUSED && this.shouldAutoDownload(task)) {
        this.resumeDownload(task.fileId);
      } else if (task.status === DownloadStatus.DOWNLOADING && !this.shouldAutoDownload(task)) {
        this.pauseDownload(task.fileId);
      }
    }
    this.scheduleDownloads();
  }

  private formatSpeed(bytesPerSec: number): string {
    if (bytesPerSec < 1024) return `${bytesPerSec.toFixed(0)} B/s`;
    if (bytesPerSec < 1024 * 1024) return `${(bytesPerSec / 1024).toFixed(1)} KB/s`;
    return `${(bytesPerSec / (1024 * 1024)).toFixed(1)} MB/s`;
  }

  private formatTimeLeft(seconds: number): string {
    if (!isFinite(seconds) || seconds <= 0) return '--';
    if (seconds < 60) return `${Math.ceil(seconds)}秒`;
    const minutes = Math.floor(seconds / 60);
    const secs = Math.ceil(seconds % 60);
    return `${minutes}分${secs}秒`;
  }

  private formatDuration(ms: number): string {
    const sec = Math.floor(ms / 1000);
    const minutes = Math.floor(sec / 60);
    const seconds = sec % 60;
    return minutes > 0 ? `${minutes}m ${seconds}s` : `${seconds}s`;
  }

  private emitEvent(event: DownloadEvent, data?: Object): void {
    this.downloadEventBus.emit(event, data);
  }

  // ==================== 可选：任务持久化 ====================
  private async persistTasks(): Promise<void> {
    // 将 tasks 中未完成的任务转为 PersistedDownloadTask 存储
    const allTasks = Array.from(this.tasks.values());
    const filteredTasks = allTasks.filter(t => t.status !== DownloadStatus.COMPLETED);
    const pending: PersistedDownloadTask[] = [];
    
    for (const t of filteredTasks) {
      const persistedTask: PersistedDownloadTask = {
        id: t.id,
        fileId: t.fileId,
        type: t.type,
        priority: t.priority,
        status: t.status,
        downloadedBytes: t.downloadedBytes,
        totalBytes: t.totalBytes,
        localPath: t.localPath,
        createTime: t.createTime,
        messageId: t.messageId,
        chatId: t.chatId,
        fileName: t.fileName,
        mimeType: t.mimeType
      };
      pending.push(persistedTask);
    }
    
    // 使用 preferences 或 数据库存储
    // await Preferences.put(STORAGE_KEY, JSON.stringify(pending));
  }

  private async restoreTasksIfNeeded(): Promise<void> {
    // 读取存储，重新创建任务（但不会自动启动，除非网络策略允许）
    // 简化实现，略
  }

  // ==================== 清理 ====================
  public cleanup(): void {
    if (this.updateTimerId !== -1) clearTimeout(this.updateTimerId);
    for (const task of this.tasks.values()) {
      if (task.status === DownloadStatus.DOWNLOADING) {
        this.tdApi.cancelDownloadFile(task.fileId, false); // priority, synchronous
      }
    }
    this.tasks.clear();
    this.downloadQueue = [];
    this.taskDeferreds.clear();
    this.pendingProgressEvents.clear();
    this.currentDownloads.clear();
    // EventBus 没有 removeAllListeners，这里简化处理
    hilog.info(0x0001, TAG, 'Service cleaned up');
  }
}