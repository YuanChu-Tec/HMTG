// services/FileDownloadService.ets
import { common } from '@kit.AbilityKit';
import { fileIo as fs, statfs } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { TDLibApi, TdApiFactory } from '../../core/api';
import { EventBus } from '../../../utils/event/EventBus';
import { NetworkMonitor } from '../../../utils/network/NetworkMonitor';
import { FileSizeFormatter } from '../../../utils/formatter/FileSizeFormatter';
import { CacheService, MediaType, MediaMetadata } from '../storage/MessagesStorage';
import { Deferred } from '../../../utils/Deferred';
import {
  FileType, DownloadPriority, DownloadStatus, NetworkPolicy,
  AutoDownloadConfig, DownloadTask, DownloadProgressData,
  DownloadCompleteData, DownloadFailedData, DownloadPausedData,
  DownloadQueuedData, DownloadStartData, DownloadCancelledData,
  PersistedDownloadTask, DownloadEvent, QueueCheckResult,
  PRIORITY_VALUE_MAX, PRIORITY_VALUE_NORMAL, PRIORITY_VALUE_LOW, FileLoaderQueueType
} from '../../../models/TDLibData';

const TAG = 'DownloadController';
const STORAGE_KEY = 'download_tasks';

// 大文件阈值：20MB（与 Nagram 一致）
const BIG_FILE_THRESHOLD = 20 * 1024 * 1024;

// 小文件队列最大并发
const SMALL_QUEUE_MAX_ACTIVE = 5;
// 大文件队列最大并发
const LARGE_QUEUE_MAX_ACTIVE = 2;

function createAutoDownloadConfig(): AutoDownloadConfig {
  return {
    images: NetworkPolicy.WIFI_OR_CELLULAR,
    videos: NetworkPolicy.WIFI_ONLY,
    audios: NetworkPolicy.WIFI_OR_CELLULAR,
    documents: NetworkPolicy.NEVER,
    stickers: NetworkPolicy.WIFI_OR_CELLULAR,
    animations: NetworkPolicy.WIFI_OR_CELLULAR,
    voiceNotes: NetworkPolicy.WIFI_OR_CELLULAR,
    videoNotes: NetworkPolicy.WIFI_ONLY,
    profilePhotos: NetworkPolicy.WIFI_OR_CELLULAR,
    wallpapers: NetworkPolicy.WIFI_ONLY,
    thumbnails: NetworkPolicy.WIFI_OR_CELLULAR,
    maxImageSize: 10 * 1024 * 1024,
    maxVideoSize: 100 * 1024 * 1024,
    maxAudioSize: 50 * 1024 * 1024,
    maxDocumentSize: 100 * 1024 * 1024,
    maxStickerSize: 5 * 1024 * 1024,
    maxAnimationSize: 20 * 1024 * 1024,
    maxVoiceNoteSize: 10 * 1024 * 1024,
    maxVideoNoteSize: 50 * 1024 * 1024,
    maxProfilePhotoSize: 5 * 1024 * 1024,
    maxThumbnailSize: 2 * 1024 * 1024,
    roamingAllowed: false
  };
}

/**
 * ⭐ 文件加载优先级队列（参考 Nagram FileLoaderPriorityQueue）
 * 按优先级降序排列，高优先级任务优先执行
 */
class FileLoaderPriorityQueue {
  private name: string;
  private type: FileLoaderQueueType;
  private allOperations: DownloadTask[] = [];
  private tmpListOperations: DownloadTask[] = [];
  private maxActive: number;

  constructor(name: string, type: FileLoaderQueueType) {
    this.name = name;
    this.type = type;
    this.maxActive = type === FileLoaderQueueType.LARGE ? LARGE_QUEUE_MAX_ACTIVE : SMALL_QUEUE_MAX_ACTIVE;
  }

  add(operation: DownloadTask): void {
    // 移除已存在的相同任务
    for (let i = 0; i < this.allOperations.length; i++) {
      if (this.allOperations[i].id === operation.id) {
        this.allOperations.splice(i, 1);
        i--;
      }
    }

    // 按 priorityValue 降序插入（高优先级在前）
    const opValue = operation.priorityValue ?? operation.priority;
    let index = -1;
    for (let i = 0; i < this.allOperations.length; i++) {
      const existingValue = this.allOperations[i].priorityValue ?? this.allOperations[i].priority;
      if (opValue > existingValue) {
        index = i;
        break;
      }
    }
    if (index >= 0) {
      this.allOperations.splice(index, 0, operation);
    } else {
      this.allOperations.push(operation);
    }
  }

  remove(operation: DownloadTask): boolean {
    const index = this.allOperations.findIndex(op => op.id === operation.id);
    if (index !== -1) {
      this.allOperations.splice(index, 1);
      return true;
    }
    return false;
  }

  getPosition(operation: DownloadTask): number {
    return this.allOperations.findIndex(op => op.id === operation.id);
  }

  getCount(): number {
    return this.allOperations.length;
  }

  /**
   * 检查并调度加载操作
   * 返回需要启动的任务列表和需要暂停的任务列表
   */
  checkLoadingOperations(): QueueCheckResult {
    const start: DownloadTask[] = [];
    const pause: DownloadTask[] = [];

    let activeCount = 0;
    let lastPriorityValue = 0;
    let pauseAllNextOperations = false;

    for (let i = 0; i < this.allOperations.length; i++) {
      const prevOperation = i > 0 ? this.allOperations[i - 1] : null;
      const operation = this.allOperations[i];
      const opValue = operation.priorityValue ?? operation.priority;
      const prevValue = prevOperation ? (prevOperation.priorityValue ?? prevOperation.priority) : 0;

      if (i > 0 && !pauseAllNextOperations) {
        // 大文件队列中，STREAM/HIGH 优先级任务会暂停后续 LOW 优先级任务
        if (this.type === FileLoaderQueueType.LARGE) {
          if (prevOperation && prevValue >= PRIORITY_VALUE_MAX && opValue <= PRIORITY_VALUE_LOW) {
            pauseAllNextOperations = true;
          }
        }
        // 当上一个任务优先级 > LOW 且当前任务优先级 == LOW 时，暂停后续
        if (lastPriorityValue > PRIORITY_VALUE_LOW && opValue <= PRIORITY_VALUE_LOW) {
          pauseAllNextOperations = true;
        }
      }

      if (operation.status === DownloadStatus.COMPLETED) {
        // 已完成的任务不占用并发槽位
        continue;
      } else if (!pauseAllNextOperations && activeCount < this.maxActive) {
        start.push(operation);
        activeCount++;
      } else {
        pause.push(operation);
      }

      lastPriorityValue = opValue;
    }

    return { start, pause };
  }
}

/**
 * Nagram 风格文件下载服务
 * 特性：
 * 1. 小文件/大文件队列分离
 * 2. 5级优先级体系（STREAM/HIGH/NORMAL_UP/NORMAL/LOW）
 * 3. 可见性感知的动态优先级调整
 * 4. 头像使用 NORMAL 优先级（不特殊处理）
 */
export class FileDownloadService {
  private static instance: FileDownloadService;
  private tdApi: TDLibApi;
  private eventBus: EventBus;
  private networkMonitor: NetworkMonitor;
  private cacheService: CacheService;
  private downloadEventBus: EventBus = EventBus.getInstance();

  // 文件ID到本地路径的映射
  private filePathCache: Map<number, string> = new Map();

  // ⭐ 小文件队列（头像、缩略图、小图片）
  private smallFilesQueue: FileLoaderPriorityQueue;
  // ⭐ 大文件队列（视频、大文档）
  private largeFilesQueue: FileLoaderPriorityQueue;

  // 配置
  private autoConfig: AutoDownloadConfig = createAutoDownloadConfig();

  // 当前下载中的任务（不区分队列）
  private currentDownloads: Set<string> = new Set();

  // 任务存储
  private tasks: Map<string, DownloadTask> = new Map();
  private taskDeferreds: Map<string, Deferred<string>> = new Map();

  // 网络状态
  private isWifiConnected: boolean = true;
  private isCellularConnected: boolean = false;
  private isRoaming: boolean = false;

  // UI更新节流
  private pendingProgressEvents: Map<string, DownloadProgressData> = new Map();
  private updateTimerId: number = -1;
  private readonly UPDATE_INTERVAL_MS = 100;

  // ⭐ 可见性感知：记录各任务的可见状态
  private visibleTasks: Set<string> = new Set();

  // ⭐ 优先级递增指针（用于区分相同优先级的任务顺序）
  private priorityIncreasePointer: number = 0;

  private constructor(context: common.Context) {
    this.tdApi = TdApiFactory.getInstance().createDefault();
    this.eventBus = EventBus.getInstance();
    this.networkMonitor = NetworkMonitor.getInstance();
    this.cacheService = CacheService.getInstance();
    this.smallFilesQueue = new FileLoaderPriorityQueue('smallFilesQueue', FileLoaderQueueType.SMALL);
    this.largeFilesQueue = new FileLoaderPriorityQueue('largeFilesQueue', FileLoaderQueueType.LARGE);

    this.cacheService.initialize(context).catch((e: Error) => {
      hilog.error(0x0001, TAG, `CacheService init failed: ${e.message}`);
    });
    this.initNetworkMonitor();
    this.initTdLibEvents();
    this.restoreTasksIfNeeded();
  }

  static getInstance(context?: common.Context): FileDownloadService {
    if (!FileDownloadService.instance && context) {
      FileDownloadService.instance = new FileDownloadService(context);
    }
    return FileDownloadService.instance;
  }

  // ==================== 优先级值转换（参考 Nagram FileLoader） ====================

  /**
   * 将内部优先级映射到 TDLib 的 1-32 范围（1 是最高优先级）
   */
  private mapToTDLibPriority(priorityType: DownloadPriority): number {
    switch (priorityType) {
      case DownloadPriority.STREAM:
        return 1;
      case DownloadPriority.HIGH:
        return 2;
      case DownloadPriority.NORMAL_UP:
        return 3;
      case DownloadPriority.NORMAL:
        return 4;
      case DownloadPriority.LOW:
        return 8;
      default:
        return 4;
    }
  }

  /**
   * 将 DownloadPriority 转换为内部优先级值
   */
  private getPriorityValue(priorityType: DownloadPriority): number {
    if (priorityType === DownloadPriority.STREAM) {
      return Number.MAX_VALUE;
    } else if (priorityType === DownloadPriority.HIGH) {
      this.priorityIncreasePointer++;
      return PRIORITY_VALUE_MAX + this.priorityIncreasePointer;
    } else if (priorityType === DownloadPriority.NORMAL_UP) {
      this.priorityIncreasePointer++;
      return PRIORITY_VALUE_NORMAL + this.priorityIncreasePointer;
    } else if (priorityType === DownloadPriority.NORMAL) {
      return PRIORITY_VALUE_NORMAL;
    } else {
      return PRIORITY_VALUE_LOW;
    }
  }

  /**
   * ⭐ 设置任务可见性（用于动态优先级调整）
   * 当任务对应的 UI 组件可见时调用，提升为 NORMAL
   * 当不可见时，降级为 LOW
   */
  setTaskVisible(taskId: string, visible: boolean): void {
    const task = this.tasks.get(taskId);
    if (!task) return;

    if (visible) {
      this.visibleTasks.add(taskId);
      // 可见时提升优先级到 NORMAL（如果不是更高）
      if (task.priority < DownloadPriority.NORMAL) {
        task.priority = DownloadPriority.NORMAL;
        task.priorityValue = this.getPriorityValue(DownloadPriority.NORMAL);
        this.updateQueue(task);
        hilog.debug(0x0001, TAG, `Task ${taskId} priority upgraded to NORMAL (visible)`);
      }
    } else {
      this.visibleTasks.delete(taskId);
      // 不可见时降级到 LOW
      if (task.priority > DownloadPriority.LOW) {
        task.priority = DownloadPriority.LOW;
        task.priorityValue = this.getPriorityValue(DownloadPriority.LOW);
        this.updateQueue(task);
        hilog.debug(0x0001, TAG, `Task ${taskId} priority downgraded to LOW (not visible)`);
      }
    }
  }

  /**
   * ⭐ 设置当前活跃聊天（该聊天的下载任务获得 NORMAL_UP 优先级）
   */
  setCurrentActiveChat(chatId: number | undefined): void {
    if (this.currentActiveChatId !== chatId) {
      const oldChatId = this.currentActiveChatId;
      this.currentActiveChatId = chatId;
      hilog.info(0x0001, TAG, `Active chat changed: ${oldChatId} -> ${chatId}`);

      // 重新评估所有任务的优先级
      for (const task of this.tasks.values()) {
        if (task.status === DownloadStatus.DOWNLOADING || task.status === DownloadStatus.QUEUED) {
          this.recalculateTaskPriority(task);
        }
      }
      this.checkAllQueues();
    }
  }

  private currentActiveChatId: number | undefined = undefined;

  /**
   * 重新计算任务优先级
   */
  private recalculateTaskPriority(task: DownloadTask): void {
    let basePriority = DownloadPriority.NORMAL;

    // 1. 如果任务属于当前活跃聊天，提升为 NORMAL_UP
    if (task.chatId && task.chatId === this.currentActiveChatId) {
      basePriority = DownloadPriority.NORMAL_UP;
    }

    // 2. 如果任务不可见，降级为 LOW
    if (!this.visibleTasks.has(task.id) && task.messageId) {
      basePriority = DownloadPriority.LOW;
    }

    // 3. 头像不特殊处理，使用默认 NORMAL

    if (task.priority !== basePriority) {
      task.priority = basePriority;
      task.priorityValue = this.getPriorityValue(basePriority);
      this.updateQueue(task);
    }
  }

  /**
   * 更新任务在队列中的位置
   */
  private updateQueue(task: DownloadTask): void {
    const queue = this.getQueueForTask(task);
    queue.remove(task);
    if (task.status === DownloadStatus.QUEUED || task.status === DownloadStatus.DOWNLOADING) {
      queue.add(task);
    }
    this.checkAllQueues();
  }

  /**
   * 获取任务对应的队列
   */
  private getQueueForTask(task: DownloadTask): FileLoaderPriorityQueue {
    if (task.totalBytes > BIG_FILE_THRESHOLD) {
      return this.largeFilesQueue;
    }
    return this.smallFilesQueue;
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
    this.isWifiConnected = this.networkMonitor.isConnected();
    this.isCellularConnected = this.networkMonitor.isConnected();
    this.isRoaming = false;
  }

  private initTdLibEvents(): void {
    this.eventBus.on('updateFile', (data?: Object) => {
      if (data) {
        this.handleFileUpdate(data as Record<string, Object>);
      }
    });
  }

  // ==================== 缓存管理 ====================

  async getCachedPath(fileId: number): Promise<string | null> {
    const cachedPath = this.filePathCache.get(fileId);
    if (cachedPath) {
      return cachedPath;
    }

    try {
      const fileInfo = await this.tdApi.getFile(fileId);
      const local = fileInfo.local;
      if (local && local.is_downloading_completed === true) {
        const path = local.path;
        if (path && path.length > 0) {
          this.filePathCache.set(fileId, path);
          return path;
        }
      }
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to get file info for ${fileId}: ${JSON.stringify(error)}`);
    }

    return null;
  }

  addCachedFile(fileId: number, filePath: string, fileType: FileType, fileSize?: number): void {
    this.filePathCache.set(fileId, filePath);
    this.saveFileMetadata(fileId, filePath, fileType, fileSize).catch((err: Error) => {
      hilog.warn(0x0001, TAG, `Failed to save file metadata for ${fileId}: ${err.message}`);
    });
    hilog.debug(0x0001, TAG, `Cached file ${fileId} metadata, path: ${filePath}`);
  }

  private async saveFileMetadata(
    fileId: number,
    filePath: string,
    fileType: FileType,
    fileSize?: number
  ): Promise<void> {
    try {
      let size = fileSize || 0;
      if (size === 0) {
        try {
          const stat = await fs.stat(filePath);
          size = stat.size;
        } catch (e) {
          hilog.warn(0x0001, TAG, `Failed to stat file ${filePath}`);
        }
      }

      const metadata: MediaMetadata = {
        fileId: fileId.toString(),
        localPath: filePath,
        fileType: this.convertFileTypeToString(fileType),
        size: size,
        mimeType: this.inferMimeType(filePath, fileType),
        isDownloaded: true,
        downloadProgress: 100
      };
      await this.cacheService.saveMediaMetadata(metadata);
      hilog.debug(0x0001, TAG, `Saved file ${fileId} metadata to CacheService`);
    } catch (error) {
      hilog.warn(0x0001, TAG, `Failed to save file metadata: ${JSON.stringify(error)}`);
    }
  }

  private inferMimeType(filePath: string, fileType: FileType): string {
    const ext = filePath.split('.').pop()?.toLowerCase() || '';
    const mimeMap: Record<string, string> = {
      'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'png': 'image/png',
      'gif': 'image/gif', 'webp': 'image/webp', 'mp4': 'video/mp4',
      'mov': 'video/quicktime', 'mp3': 'audio/mpeg', 'ogg': 'audio/ogg',
      'oga': 'audio/ogg', 'pdf': 'application/pdf', 'txt': 'text/plain'
    };
    if (mimeMap[ext]) return mimeMap[ext];

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

  clearCachedFile(fileId: number): void {
    this.filePathCache.delete(fileId);
    hilog.debug(0x0001, TAG, `Cleared cache for file ${fileId}`);
  }

  clearAllCachedFiles(): void {
    this.filePathCache.clear();
    hilog.info(0x0001, TAG, 'Cleared all file caches');
  }

  // ==================== 公共 API ====================

  /**
   * 下载文件
   * @param fileId 文件ID
   * @param type 文件类型
   * @param priority 下载优先级（默认 NORMAL）
   * @param messageId 关联消息ID（用于可见性感知）
   * @param chatId 关联聊天ID（用于活跃聊天优先级）
   * @param fileSize 文件大小（用于队列选择，如未提供会查询）
   */
  async downloadFile(
    fileId: number,
    type: FileType,
    priority: DownloadPriority = DownloadPriority.NORMAL,
    messageId?: number,
    chatId?: number,
    fileSize?: number
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
      if (task.status === DownloadStatus.COMPLETED && task.localPath) {
        return task.localPath;
      }
      if (task.status === DownloadStatus.DOWNLOADING || task.status === DownloadStatus.QUEUED) {
        if (task.priority < priority) {
          task.priority = priority;
          task.priorityValue = this.getPriorityValue(priority);
          this.updateQueue(task);
          hilog.info(0x0001, TAG, `Priority upgraded for ${fileId} to ${priority}`);
        }
        const deferred = this.taskDeferreds.get(taskId);
        if (deferred) {
          return deferred.promise;
        }
      }
      if (task.status === DownloadStatus.PAUSED) {
        task.priority = priority;
        task.priorityValue = this.getPriorityValue(priority);
        this.resumeDownload(fileId);
        const deferred = this.taskDeferreds.get(taskId);
        if (deferred) return deferred.promise;
      }
    }

    // 3. 创建新任务
    const actualFileSize = fileSize || await this.getFileSize(fileId);
    const fileName = await this.getFileName(fileId);

    // ⭐ 根据活跃聊天调整优先级
    let finalPriority = priority;
    if (chatId && chatId === this.currentActiveChatId && priority < DownloadPriority.NORMAL_UP) {
      finalPriority = DownloadPriority.NORMAL_UP;
    }

    task = {
      id: taskId,
      fileId,
      type,
      priority: finalPriority,
      priorityValue: this.getPriorityValue(finalPriority),
      status: DownloadStatus.PENDING,
      progress: 0,
      downloadedBytes: 0,
      totalBytes: actualFileSize,
      createTime: Date.now(),
      messageId,
      chatId,
      fileName,
      formattedSize: FileSizeFormatter.format(actualFileSize)
    };
    this.tasks.set(taskId, task);

    // 4. 检查网络策略
    if (!this.shouldAutoDownload(task)) {
      task.status = DownloadStatus.PAUSED;
      const pausedData: DownloadPausedData = { taskId, fileId, reason: 'network_policy' };
      this.emitEvent(DownloadEvent.PAUSED, pausedData);
      const deferred = new Deferred<string>();
      this.taskDeferreds.set(taskId, deferred);
      return deferred.promise;
    }

    // 5. 检查磁盘空间
    const freeSpace = await this.getFreeDiskSpace();
    if (freeSpace < actualFileSize * 1.1) {
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
    this.checkAllQueues();
    return deferred.promise;
  }

  /**
   * 预下载多个文件（后台加载，使用 LOW 优先级）
   */
  async preloadFiles(fileIds: number[], type: FileType): Promise<void> {
    const promises = fileIds.map(id =>
      this.downloadFile(id, type, DownloadPriority.LOW).catch((err: Error) =>
        hilog.warn(0x0001, TAG, `Preload failed for ${id}: ${err.message}`)
      )
    );
    await Promise.all(promises);
  }

  async pauseDownload(fileId: number): Promise<void> {
    const taskId = this.getTaskId(fileId);
    const task = this.tasks.get(taskId);
    if (!task || task.status !== DownloadStatus.DOWNLOADING) return;

    try {
      await this.tdApi.cancelDownloadFile(fileId, false);
    } catch (error) {
      hilog.error(0x0001, TAG, `Pause failed for ${fileId}: ${JSON.stringify(error)}`);
    }
  }

  async resumeDownload(fileId: number): Promise<void> {
    const taskId = this.getTaskId(fileId);
    const task = this.tasks.get(taskId);
    if (!task || task.status !== DownloadStatus.PAUSED) return;

    if (!this.shouldAutoDownload(task)) {
      hilog.debug(0x0001, TAG, `Cannot resume ${fileId}: network policy not met`);
      return;
    }

    task.status = DownloadStatus.PENDING;
    this.enqueueTask(task);
    this.checkAllQueues();
  }

  async cancelDownload(fileId: number): Promise<void> {
    const taskId = this.getTaskId(fileId);
    const task = this.tasks.get(taskId);
    if (!task) return;

    if (task.status === DownloadStatus.DOWNLOADING) {
      await this.tdApi.cancelDownloadFile(fileId, false);
      this.currentDownloads.delete(taskId);
    }
    this.cleanupTask(taskId, false);
    const cancelledData: DownloadCancelledData = { taskId, fileId };
    this.emitEvent(DownloadEvent.CANCELLED, cancelledData);
    this.checkAllQueues();
  }

  async cancelDownloadsForMessage(messageId: number): Promise<void> {
    const tasksToCancel = Array.from(this.tasks.values())
      .filter(task => task.messageId === messageId);
    for (const task of tasksToCancel) {
      await this.cancelDownload(task.fileId);
    }
    hilog.info(0x0001, TAG, `Cancelled ${tasksToCancel.length} downloads for message ${messageId}`);
  }

  async cancelDownloadsForChat(chatId: number): Promise<void> {
    const tasksToCancel = Array.from(this.tasks.values())
      .filter(task => task.chatId === chatId);
    for (const task of tasksToCancel) {
      await this.cancelDownload(task.fileId);
    }
  }

  getTask(fileId: number): DownloadTask | undefined {
    return this.tasks.get(this.getTaskId(fileId));
  }

  getAllTasks(): DownloadTask[] {
    return Array.from(this.tasks.values());
  }

  updateAutoDownloadConfig(config: Partial<AutoDownloadConfig>): void {
    if (config.images !== undefined) this.autoConfig.images = config.images;
    if (config.videos !== undefined) this.autoConfig.videos = config.videos;
    if (config.audios !== undefined) this.autoConfig.audios = config.audios;
    if (config.documents !== undefined) this.autoConfig.documents = config.documents;
    if (config.stickers !== undefined) this.autoConfig.stickers = config.stickers;
    if (config.animations !== undefined) this.autoConfig.animations = config.animations;
    if (config.voiceNotes !== undefined) this.autoConfig.voiceNotes = config.voiceNotes;
    if (config.videoNotes !== undefined) this.autoConfig.videoNotes = config.videoNotes;
    if (config.profilePhotos !== undefined) this.autoConfig.profilePhotos = config.profilePhotos;
    if (config.wallpapers !== undefined) this.autoConfig.wallpapers = config.wallpapers;
    if (config.thumbnails !== undefined) this.autoConfig.thumbnails = config.thumbnails;
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

    for (const task of this.tasks.values()) {
      if (task.status === DownloadStatus.PAUSED && this.shouldAutoDownload(task)) {
        this.resumeDownload(task.fileId);
      }
    }
  }

  on(event: DownloadEvent, handler: (data?: Object) => void): void {
    this.downloadEventBus.on(event, handler);
  }

  off(event: DownloadEvent, handler: (data?: Object) => void): void {
    hilog.debug(0x0001, TAG, `Unregister listener for event: ${event}`);
    this.downloadEventBus.off(event, handler);
  }

  // ==================== 私有方法 ====================

  private getTaskId(fileId: number): string {
    return `download_${fileId}`;
  }

  private async getFileName(fileId: number): Promise<string> {
    try {
      const fileInfo = await this.tdApi.getFile(fileId);
      const remote = fileInfo.remote;
      return remote?.unique_id || `file_${fileId}`;
    } catch {
      return `file_${fileId}`;
    }
  }

  private async getFileSize(fileId: number): Promise<number> {
    try {
      const fileInfo = await this.tdApi.getFile(fileId);
      return fileInfo.size || 0;
    } catch {
      return 0;
    }
  }

  private async getFreeDiskSpace(): Promise<number> {
    try {
      const path = '/data/storage/el2/base/haps/entry';
      const free = await statfs.getFreeSize(path);
      return free;
    } catch (error) {
      hilog.error(0x0001, TAG, 'Failed to get disk space');
      return 1024 * 1024 * 1024;
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
        maxSize = this.autoConfig.maxDocumentSize;
        break;
      case FileType.SECRET:
      case FileType.SECRET_THUMBNAIL:
      case FileType.SECURE:
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

  /**
   * ⭐ 将任务加入对应队列
   */
  private enqueueTask(task: DownloadTask): void {
    const queue = this.getQueueForTask(task);
    queue.add(task);
    task.status = DownloadStatus.QUEUED;
    const queuedData: DownloadQueuedData = { taskId: task.id, fileId: task.fileId };
    this.emitEvent(DownloadEvent.QUEUED, queuedData);
  }

  /**
   * ⭐ 检查所有队列并调度下载
   */
  private checkAllQueues(): void {
    // 检查小文件队列
    const smallResult = this.smallFilesQueue.checkLoadingOperations();
    this.applyQueueResult(smallResult);

    // 检查大文件队列
    const largeResult = this.largeFilesQueue.checkLoadingOperations();
    this.applyQueueResult(largeResult);
  }

  /**
   * 应用队列调度结果
   */
  private applyQueueResult(result: QueueCheckResult): void {
    // 启动新任务
    for (const task of result.start) {
      if (!this.currentDownloads.has(task.id)) {
        this.startDownload(task);
      }
    }

    // 暂停低优先级任务
    for (const task of result.pause) {
      if (this.currentDownloads.has(task.id)) {
        this.pauseDownload(task.fileId);
      }
    }
  }

  private async startDownload(task: DownloadTask): Promise<void> {
    this.currentDownloads.add(task.id);
    task.status = DownloadStatus.DOWNLOADING;
    task.startTime = Date.now();
    const startData: DownloadStartData = { taskId: task.id, fileId: task.fileId };
    this.emitEvent(DownloadEvent.START, startData);

    try {
      const offset = task.downloadedBytes;
      // ⭐ 将内部优先级映射到 TDLib 的 1-32 范围（1 是最高）
      const tdlibPriority = this.mapToTDLibPriority(task.priority);
      await this.tdApi.downloadFile(task.fileId, tdlibPriority, offset, 0, false);
    } catch (error) {
      hilog.error(0x0001, TAG, `Start download failed for ${task.fileId}: ${JSON.stringify(error)}`);
      task.status = DownloadStatus.FAILED;
      task.error = error instanceof Error ? error.message : String(error);
      const failedData: DownloadFailedData = { taskId: task.id, fileId: task.fileId, error: task.error };
      this.emitEvent(DownloadEvent.FAILED, failedData);
      this.cleanupTask(task.id, true);
      this.checkAllQueues();
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

    if (local.is_downloading_active === true) {
      const downloaded = local.downloaded_size as number;
      const total = file.size as number;
      task.downloadedBytes = downloaded;
      task.totalBytes = total;
      task.progress = total > 0 ? downloaded / total : 0;
      task.formattedDownloaded = FileSizeFormatter.format(downloaded);
      task.formattedTotal = FileSizeFormatter.format(total);

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
    } else if (local.is_downloading_completed === true) {
      task.status = DownloadStatus.COMPLETED;
      task.progress = 1;
      task.downloadedBytes = task.totalBytes;
      task.localPath = local.path as string;
      task.endTime = Date.now();
      const durationMs = (task.endTime - (task.startTime || task.endTime));

      this.addCachedFile(task.fileId, task.localPath, task.type, task.totalBytes);

      const completeData: DownloadCompleteData = {
        taskId: task.id,
        fileId: task.fileId,
        localPath: task.localPath,
        durationMs,
        formattedDuration: this.formatDuration(durationMs)
      };
      this.emitEvent(DownloadEvent.COMPLETE, completeData);

      const deferred = this.taskDeferreds.get(task.id);
      if (deferred) {
        deferred.resolve(task.localPath);
        this.taskDeferreds.delete(task.id);
      }
      this.cleanupTask(task.id, true);
      this.checkAllQueues();
    } else if (local.is_downloading_active === false && !local.is_downloading_completed) {
      if (local.can_be_deleted === false && local.path === '') {
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
        task.status = DownloadStatus.PAUSED;
        const pausedData: DownloadPausedData = { taskId: task.id, fileId: task.fileId, reason: 'user' };
        this.emitEvent(DownloadEvent.PAUSED, pausedData);
        this.cleanupTask(task.id, true);
      }
      this.checkAllQueues();
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
    const task = this.tasks.get(taskId);
    if (task) {
      const queue = this.getQueueForTask(task);
      queue.remove(task);
    }
  }

  private onNetworkChanged(oldWifi: boolean, oldCellular: boolean): void {
    for (const task of this.tasks.values()) {
      if (task.status === DownloadStatus.PAUSED && this.shouldAutoDownload(task)) {
        this.resumeDownload(task.fileId);
      } else if (task.status === DownloadStatus.DOWNLOADING && !this.shouldAutoDownload(task)) {
        this.pauseDownload(task.fileId);
      }
    }
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

  private async persistTasks(): Promise<void> {
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
  }

  private async restoreTasksIfNeeded(): Promise<void> {
    // 简化实现，略
  }

  public cleanup(): void {
    if (this.updateTimerId !== -1) clearTimeout(this.updateTimerId);
    for (const task of this.tasks.values()) {
      if (task.status === DownloadStatus.DOWNLOADING) {
        this.tdApi.cancelDownloadFile(task.fileId, false);
      }
    }
    this.tasks.clear();
    this.smallFilesQueue = new FileLoaderPriorityQueue('smallFilesQueue', FileLoaderQueueType.SMALL);
    this.largeFilesQueue = new FileLoaderPriorityQueue('largeFilesQueue', FileLoaderQueueType.LARGE);
    this.taskDeferreds.clear();
    this.pendingProgressEvents.clear();
    this.currentDownloads.clear();
    this.visibleTasks.clear();
    hilog.info(0x0001, TAG, 'Service cleaned up');
  }

  // ==================== 头像下载方法（从 CoreService 迁移） ====================

  /**
   * 触发聊天头像异步下载
   * @param fileId 文件ID
   * @param chatId 聊天ID
   */
  public async triggerChatAvatarDownload(fileId: number, chatId: number): Promise<void> {
    try {
      hilog.info(0x0001, TAG, `Triggering chat avatar download for chat ${chatId}, fileId: ${fileId}`);
      
      const path = await this.downloadFile(
        fileId,
        FileType.PROFILE_PHOTO,
        DownloadPriority.NORMAL,
        undefined,
        chatId
      );
      
      hilog.info(0x0001, TAG, `✅ Chat avatar downloaded for chat ${chatId}: ${path}`);
      
      // 从文件读取数据并缓存到 CacheService
      try {
        const file = await fs.open(path, fs.OpenMode.READ_ONLY);
        const stat = await fs.stat(path);
        const buffer = new ArrayBuffer(stat.size);
        await fs.read(file.fd, buffer, { offset: 0, length: stat.size });
        await fs.close(file);
        
        await this.cacheService.cacheAvatar(chatId, path, buffer);
        hilog.info(0x0001, TAG, `✅ Chat avatar cached for chat ${chatId}`);
      } catch (cacheErr) {
        hilog.warn(0x0001, TAG, `Failed to cache chat avatar: ${JSON.stringify(cacheErr)}`);
      }
      
      // 发布聊天头像下载完成事件
      const eventData: Record<string, Object> = new Object() as Record<string, Object>;
      eventData['fileId'] = fileId as Object;
      eventData['path'] = path as Object;
      eventData['chatId'] = chatId as Object;
      this.eventBus.emit('file:chatAvatarDownloaded', eventData);
      
    } catch (error) {
      hilog.error(0x0001, TAG, `❌ Trigger chat avatar download error: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 触发用户头像异步下载
   * @param fileId 文件ID
   * @param userId 用户ID
   * @param associatedChatId 关联的私聊ID（用于优先级优化）
   */
  public async triggerUserAvatarDownload(fileId: number, userId: number, associatedChatId?: number): Promise<void> {
    try {
      hilog.info(0x0001, TAG, `Triggering user avatar download for user ${userId}, fileId: ${fileId}`);
      
      const path = await this.downloadFile(
        fileId,
        FileType.PROFILE_PHOTO,
        DownloadPriority.HIGH,
        undefined,
        associatedChatId
      );
      
      hilog.info(0x0001, TAG, `✅ User avatar downloaded for user ${userId}: ${path}`);
      
      // 添加 file:// 前缀
      const avatarPath = path.startsWith('file://') ? path : 'file://' + path;
      
      // 发布用户头像下载完成事件
      const eventData: Record<string, Object> = new Object() as Record<string, Object>;
      eventData['fileId'] = fileId as Object;
      eventData['path'] = avatarPath as Object;
      eventData['userId'] = userId as Object;
      this.eventBus.emit('file:userAvatarDownloaded', eventData);
      
    } catch (error) {
      hilog.error(0x0001, TAG, `❌ Trigger user avatar download error: ${JSON.stringify(error)}`);
    }
  }
}
