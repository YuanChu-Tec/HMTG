// file: SharedMediaPage.ets - 共享媒体页面
/**
 * 共享媒体页面
 * 显示聊天中的所有共享媒体文件（图片、视频、文件等）
 */

import { router } from '@kit.ArkUI';
import { Avatar, ThemeManager, SmartLazyImage } from '../../../ui_kit';
import { logger } from '../../../utils/log/LogService';
import { BusinessError, BusinessErrorCode } from '../../../utils/error/BusinessError';
import { TDLibApi, createTdLibAPIs } from '../../../services/api';
import type { SearchMessagesFilter$Input, MessageSender, MessageTopic$Input } from '../../../services/api/factory/tdlib-types';

/**
 * 媒体类型
 */
type MediaType = 'all' | 'photo' | 'video' | 'file' | 'voice';

/**
 * 媒体项
 */
interface MediaItem {
  id: number;
  messageId: number;
  type: 'photo' | 'video' | 'file' | 'voice';
  url?: string;
  thumbnail?: string;
  fileId?: number;
  timestamp: number;
  size?: number;
  duration?: number;
  caption?: string;
}

/**
 * 文件参数接口
 */
interface FileParams {
  file_id: number;
}

/**
 * 下载文件参数接口
 */
interface DownloadFileParams {
  file_id: number;
  priority: number;
  offset: number;
  limit: number;
  synchronous: boolean;
}

/**
 * 日志域ID
 */
const LOG_DOMAIN = 0x0001;

/**
 * 路由参数接口
 */
interface RouterParams {
  chatId: number;
  chatTitle: string;
}

/**
 * 共享媒体主题颜色接口
 */
interface SharedMediaThemeColors {
  background: string;
  surface: string;
  text: string;
  textSecondary: string;
  primary: string;
  divider: string;
}

@Entry({ routeName: 'SharedMediaPage' })
@ComponentV2
export struct SharedMediaPage {
  @Local chatId: number = 0;
  @Local chatTitle: string = '';
  @Local selectedType: MediaType = 'all';
  @Local mediaItems: MediaItem[] = [];
  @Local isLoading: boolean = true;
  @Local hasMore: boolean = true;
  @Local selectedIndex: number = -1;

  private readonly TAG = 'SharedMediaPage';
  private readonly PAGE_SIZE = 30;

  private tdLibApi: TDLibApi | null = null;
  private currentPage: number = 0;

  private theme: SharedMediaThemeColors = {
    background: '#FFFFFF',
    surface: '#F5F5F5',
    text: '#000000',
    textSecondary: '#666666',
    primary: '#0088CC',
    divider: '#E0E0E0'
  };

  aboutToAppear(): void {
    this.initializeTheme();
    this.initializeTdLibAPIs();
    this.loadRouteParams();
    this.loadMediaItems();
  }

  aboutToDisappear(): void {
    this.cleanup();
  }

  /**
   * 初始化主题
   */
  private initializeTheme(): void {
    const currentTheme = ThemeManager.getInstance().getCurrentTheme();
    const colors = currentTheme.tokens.colors;

    const newTheme: SharedMediaThemeColors = {
      background: colors.surface,
      surface: colors.primary,
      text: colors.text,
      textSecondary: colors.textSecondary,
      primary: colors.primary,
      divider: colors.divider
    };
    this.theme = newTheme;
  }

  /**
   * 初始化 TDLib APIs
   */
  private async initializeTdLibAPIs(): Promise<void> {
    try {
      this.tdLibApi = await createTdLibAPIs();
    } catch (error) {
      logger.error(LOG_DOMAIN, this.TAG, 'Failed to initialize TDLib APIs', error);
    }
  }

  /**
   * 加载路由参数
   */
  private loadRouteParams(): void {
    try {
      const params = router.getParams() as RouterParams;
      if (params) {
        this.chatId = params.chatId;
        this.chatTitle = params.chatTitle || '';
      }
    } catch (error) {
      logger.error(LOG_DOMAIN, this.TAG, 'Failed to load route params', error);
    }
  }

  /**
   * 加载媒体项
   */
  private async loadMediaItems(): Promise<void> {
    if (this.chatId === 0 || !this.tdLibApi) {
      this.isLoading = false;
      return;
    }
  
    this.isLoading = true;
  
    try {
      const query = this.getSearchQuery();
      const filter: SearchMessagesFilter$Input | null = null;
      const senderId: MessageSender | null = null;
      const topicId: MessageTopic$Input | null = null;
      const fromMessageId = 0;
      const offset = this.currentPage * this.PAGE_SIZE;
      
      const result = await this.tdLibApi.searchChatMessages(
        this.chatId,
        topicId,
        query,
        senderId,
        fromMessageId,
        offset,
        this.PAGE_SIZE,
        filter
      );
      
      if (result && result.messages) {
        const messagesArray = result.messages as Object[];
        const newItems: MediaItem[] = [];
        for (let i = 0; i < messagesArray.length; i++) {
          const msg = messagesArray[i] as Record<string, Object>;
          const mediaItem = this.parseMediaFromMessage(msg);
          if (mediaItem) {
            newItems.push(mediaItem);
          }
        }
        
        this.mediaItems = this.mediaItems.concat(newItems);
        this.hasMore = newItems.length >= this.PAGE_SIZE;
      } else {
        this.mediaItems = [];
        this.hasMore = false;
      }
    } catch (error) {
      logger.error(LOG_DOMAIN, this.TAG, 'Failed to load media items', error);
      throw new BusinessError(BusinessErrorCode.MESSAGE_NOT_FOUND, '加载媒体失败', '加载媒体失败');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 获取搜索查询
   */
  private getSearchQuery(): string {
    switch (this.selectedType) {
      case 'photo':
        return 'photo';
      case 'video':
        return 'video';
      case 'file':
        return 'document';
      case 'voice':
        return 'voice';
      default:
        return '';
    }
  }

  /**
   * 从消息解析媒体项
   */
  private parseMediaFromMessage(msg: Record<string, Object>): MediaItem | null {
    if (!msg.content) {
      return null;
    }

    const content = msg.content as Record<string, Object>;
    let type: 'photo' | 'video' | 'file' | 'voice' | null = null;
    let fileId: number | undefined;
    let thumbnail: string | undefined;
    let duration: number | undefined;

    if (content.photo) {
      type = 'photo';
      const photoData = content.photo as Record<string, Object>;
      const sizesArray = photoData.sizes as Object[];
      if (sizesArray && sizesArray.length > 0) {
        const largestSize = sizesArray[sizesArray.length - 1] as Record<string, Object>;
        const largestPhoto = largestSize.photo as Record<string, Object>;
        fileId = largestPhoto.id as number;
      }
    } else if (content.video) {
      type = 'video';
      const videoData = content.video as Record<string, Object>;
      const video = videoData.video as Record<string, Object>;
      fileId = video.id as number;
      duration = videoData.duration as number;
      if (videoData.thumbnail) {
        const thumbnailData = videoData.thumbnail as Record<string, Object>;
        const file = thumbnailData.file as Record<string, Object>;
        thumbnail = file.path as string;
      }
    } else if (content.document) {
      type = 'file';
      const documentData = content.document as Record<string, Object>;
      const document = documentData.document as Record<string, Object>;
      fileId = document.id as number;
    } else if (content.voiceNote) {
      type = 'voice';
      const voiceNoteData = content.voiceNote as Record<string, Object>;
      const voice = voiceNoteData.voice as Record<string, Object>;
      fileId = voice.id as number;
      duration = voiceNoteData.duration as number;
    }

    if (!type || !fileId) {
      return null;
    }

    return {
      id: msg.id as number,
      messageId: msg.id as number,
      type: type,
      fileId: fileId,
      thumbnail: thumbnail,
      timestamp: msg.date as number || 0,
      caption: (content.caption as Record<string, string>)?.text
    };
  }

  /**
   * 加载文件 URL
   */
  private async loadFileUrl(fileId: number): Promise<string> {
    if (!this.tdLibApi) {
      return '';
    }

    try {
      const fileResult = await this.tdLibApi.getFile(fileId);
      if (fileResult) {
        const localObj = fileResult.local;
        const pathField = localObj.path;
        if (pathField && typeof pathField === 'string') {
          return pathField;
        }
      }
      return '';
    } catch (error) {
      logger.error(LOG_DOMAIN, this.TAG, 'Failed to load file URL', error);
      return '';
    }
  }

  /**
   * 下载文件
   */
  private async downloadFile(fileId: number): Promise<void> {
    if (!this.tdLibApi) {
      return;
    }

    try {
      await this.tdLibApi.downloadFile(fileId, 1, 0, 0, false);
    } catch (error) {
      logger.error(LOG_DOMAIN, this.TAG, 'Failed to download file', error);
      throw new BusinessError(BusinessErrorCode.OPERATION_FAILED, '下载失败', '下载失败');
    }
  }

  /**
   * 加载更多
   */
  private async loadMore(): Promise<void> {
    if (!this.hasMore || this.isLoading) {
      return;
    }

    this.currentPage++;
    await this.loadMediaItems();
  }

  /**
   * 选择媒体类型
   */
  private selectMediaType(type: MediaType): void {
    if (this.selectedType === type) {
      return;
    }

    this.selectedType = type;
    this.currentPage = 0;
    this.mediaItems = [];
    this.hasMore = true;
    this.loadMediaItems();
  }

  /**
   * 预览媒体
   */
  private previewMedia(item: MediaItem): void {
    try {
      router.pushUrl({
        url: 'pages/MediaViewerPage',
        params: {
          chatId: this.chatId,
          messageId: item.messageId,
          type: item.type
        }
      });
    } catch (error) {
      logger.error(LOG_DOMAIN, this.TAG, 'Failed to navigate to media viewer', error);
    }
  }

  /**
   * 格式化文件大小
   */
  private formatFileSize(size: number): string {
    if (size < 1024) {
      return `${size} B`;
    } else if (size < 1024 * 1024) {
      return `${(size / 1024).toFixed(1)} KB`;
    } else {
      return `${(size / (1024 * 1024)).toFixed(1)} MB`;
    }
  }

  /**
   * 格式化时长
   */
  private formatDuration(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }

  /**
   * 清理资源
   */
  private cleanup(): void {
    // 清理逻辑
  }

  build() {
    Column() {
      // 标题栏
      this.buildHeader()

      // 类型筛选栏
      this.buildFilterBar()

      // 内容区域
      if (this.isLoading && this.mediaItems.length === 0) {
        this.buildLoadingView()
      } else if (this.mediaItems.length === 0) {
        this.buildEmptyView()
      } else {
        this.buildMediaGrid()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.background)
  }

  @Builder
  buildHeader() {
    Row() {
      Text('共享媒体')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.theme.text)

      Blank()

      Text(`${this.chatTitle}`)
        .fontSize(14)
        .fontColor(this.theme.textSecondary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ right: 16 })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16 })
    .onClick(() => {
      router.back();
    })
  }

  @Builder
  buildFilterBar() {
    Row() {
      this.buildFilterItem('all', '全部')
      this.buildFilterItem('photo', '图片')
      this.buildFilterItem('video', '视频')
      this.buildFilterItem('file', '文件')
      this.buildFilterItem('voice', '语音')
    }
    .width('100%')
    .height(44)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.theme.surface)
  }

  @Builder
  buildFilterItem(type: MediaType, label: string) {
    Column() {
      Text(label)
        .fontSize(14)
        .fontColor(this.selectedType === type ? this.theme.primary : this.theme.textSecondary)

      if (this.selectedType === type) {
        Divider()
          .color(this.theme.primary)
          .strokeWidth(2)
          .margin({ top: 8 })
      }
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.selectMediaType(type);
    })
  }

  @Builder
  buildLoadingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color(this.theme.primary)

      Text('加载中...')
        .fontSize(16)
        .fontColor(this.theme.textSecondary)
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildEmptyView() {
    Column() {
      Text('暂无共享媒体')
        .fontSize(16)
        .fontColor(this.theme.textSecondary)
        .margin({ top: 100 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildMediaGrid() {
    Grid() {
      ForEach(this.mediaItems, (item: MediaItem, index: number) => {
        GridItem() {
          this.buildMediaItem(item)
        }
      }, (item: MediaItem) => item.id.toString())
    }
    .columnsTemplate('1fr 1fr 1fr')
    .columnsGap(2)
    .rowsGap(2)
    .layoutWeight(1)
    .width('100%')
    .onReachEnd(() => {
      this.loadMore();
    })
  }

  @Builder
  buildMediaItem(item: MediaItem) {
    Column() {
      if (item.type === 'photo' || item.type === 'video') {
        if (item.thumbnail || item.url) {
          Image(item.thumbnail || item.url || '')
            .width('100%')
            .aspectRatio(1)
            .objectFit(ImageFit.Cover)
            .onClick(() => {
              this.previewMedia(item);
            })
        } else {
          Column() {
            if (item.type === 'video') {
              Text('▶')
                .fontSize(32)
                .fontColor(Color.White)
            } else {
              Text('📷')
                .fontSize(32)
            }
          }
          .width('100%')
          .aspectRatio(1)
          .backgroundColor(this.theme.surface)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.downloadFile(item.fileId!);
          })
        }
      } else {
        Column() {
          Text(this.getMediaIcon(item.type))
            .fontSize(32)
            .margin({ bottom: 8 })

          if (item.size) {
            Text(this.formatFileSize(item.size))
              .fontSize(12)
              .fontColor(this.theme.textSecondary)
          }

          if (item.duration) {
            Text(this.formatDuration(item.duration))
              .fontSize(12)
              .fontColor(this.theme.textSecondary)
          }
        }
        .width('100%')
        .aspectRatio(1)
        .backgroundColor(this.theme.surface)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.downloadFile(item.fileId!);
        })
      }
    }
    .width('100%')
    .backgroundColor(this.theme.surface)
  }

  /**
   * 获取媒体图标
   */
  private getMediaIcon(type: string): string {
    switch (type) {
      case 'file':
        return '📄';
      case 'voice':
        return '🎤';
      default:
        return '📎';
    }
  }
}
