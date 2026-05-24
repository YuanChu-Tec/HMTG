// file: PinnedMessagesPage.ets - 置顶消息页面
/**
 * 置顶消息页面
 * 显示聊天中的所有置顶消息
 */

import { router } from '@kit.ArkUI';
import { Avatar, ThemeManager, SmartLazyImage } from '../../../ui_kit';
import { logger } from '../../../utils/log/LogService';
import { BusinessError, BusinessErrorCode } from '../../../utils/error/BusinessError';
import { TDLibApi, createTdLibAPIs } from '../../../services/api';
import { ChatType } from '../../../models/TDLibData';

/**
 * 消息项
 */
interface PinnedMessage {
  id: number;
  chatId: number;
  senderId: number;
  senderName: string;
  senderAvatar?: string;
  content: string;
  timestamp: number;
  type: 'text' | 'photo' | 'video' | 'file' | 'voice' | 'sticker';
  mediaUrl?: string;
  mediaThumbnail?: string;
}

/**
 * 路由参数接口
 */
interface RouterParams {
  chatId: number;
  chatTitle: string;
}

/**
 * 主题颜色接口
 */
interface PinnedThemeColors {
  background: string;
  surface: string;
  text: string;
  textSecondary: string;
  textHint: string;
  primary: string;
  divider: string;
}

@Entry({ routeName: 'PinnedMessagesPage' })
@ComponentV2
export struct PinnedMessagesPage {
  @Local chatId: number = 0;
  @Local chatTitle: string = '';
  @Local pinnedMessages: PinnedMessage[] = [];
  @Local isLoading: boolean = true;
  @Local selectedMessage: PinnedMessage | null = null;

  private readonly TAG = 'PinnedMessagesPage';

  private tdLibApi: TDLibApi | null = null;

  private theme: PinnedThemeColors = {
    background: '#FFFFFF',
    surface: '#F5F5F5',
    text: '#000000',
    textSecondary: '#666666',
    textHint: '#999999',
    primary: '#0088CC',
    divider: '#E0E0E0'
  };

  aboutToAppear(): void {
    this.initializeTheme();
    this.initializeTdLibAPIs();
    this.loadRouteParams();
    this.loadPinnedMessages();
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

    const newTheme: PinnedThemeColors = {
      background: colors.surface,
      surface: colors.primary,
      text: colors.text,
      textSecondary: colors.textSecondary,
      textHint: colors.border,
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
      logger.error(0x0001, this.TAG, 'Failed to initialize TDLib APIs', error);
    }
  }

  /**
   * 加载路由参数
   */
  private loadRouteParams(): void {
    try {
      const params = router.getParams() as RouterParams;
      if (params) {
        this.chatId = params.chatId || 0;
        this.chatTitle = params.chatTitle || '';
      }
    } catch (error) {
      logger.error(0x0001, this.TAG, 'Failed to load route params', error);
    }
  }

  /**
   * 加载置顶消息
   */
  private async loadPinnedMessages(): Promise<void> {
    if (this.chatId === 0 || !this.tdLibApi) {
      this.isLoading = false;
      return;
    }

    this.isLoading = true;

    try {
      const filter = null;
      const senderId = null;
      const topicId = null;
      
      const result = await this.tdLibApi.searchChatMessages(
        this.chatId,
        topicId,
        '',
        senderId,
        0,
        0,
        100,
        filter
      );
      
      if (result && result.messages) {
        const messagesArray = result.messages as Object[];
        this.pinnedMessages = [];
        for (let i = 0; i < messagesArray.length; i++) {
          const msg = messagesArray[i] as Record<string, Object>;
          const pinnedMsg = this.parsePinnedMessage(msg);
          if (pinnedMsg) {
            this.pinnedMessages.push(pinnedMsg);
          }
        }
      } else {
        this.pinnedMessages = [];
      }
    } catch (error) {
      logger.error(0x0001, this.TAG, 'Failed to load pinned messages', error);
      throw new BusinessError(BusinessErrorCode.OPERATION_FAILED, '加载置顶消息失败', '加载置顶消息失败');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 解析置顶消息
   */
  private parsePinnedMessage(msg: Record<string, Object>): PinnedMessage | null {
    const content = msg['content'] as Record<string, Object>;
    if (!content) {
      return null;
    }

    let type: 'text' | 'photo' | 'video' | 'file' | 'voice' | 'sticker' = 'text';
    let mediaUrl: string | undefined;
    let mediaThumbnail: string | undefined;

    if (content['photo']) {
      type = 'photo';
      const photoObj = content['photo'] as Record<string, Object>;
      const sizes = photoObj['sizes'] as Object[];
      if (sizes && sizes.length > 0) {
        const largestSize = sizes[sizes.length - 1] as Record<string, Object>;
        const sizePhoto = largestSize['photo'] as Record<string, Object>;
        const sizeLocal = sizePhoto['local'] as Record<string, Object>;
        mediaUrl = sizeLocal['path'] as string;
      }
    } else if (content['video']) {
      type = 'video';
      const videoObj = content['video'] as Record<string, Object>;
      const videoVideo = videoObj['video'] as Record<string, Object>;
      const videoLocal = videoVideo['local'] as Record<string, Object>;
      mediaUrl = videoLocal['path'] as string;
    } else if (content['document']) {
      type = 'file';
      const docObj = content['document'] as Record<string, Object>;
      const document = docObj['document'] as Record<string, Object>;
      const docLocal = document['local'] as Record<string, Object>;
      mediaUrl = docLocal['path'] as string;
    } else if (content['voiceNote']) {
      type = 'voice';
    } else if (content['sticker']) {
      type = 'sticker';
      const stickerObj = content['sticker'] as Record<string, Object>;
      const sticker = stickerObj['sticker'] as Record<string, Object>;
      const stickerLocal = sticker['local'] as Record<string, Object>;
      mediaUrl = stickerLocal['path'] as string;
    }

    return {
      id: msg['id'] as number,
      chatId: msg['chatId'] as number,
      senderId: msg['senderId'] as number,
      senderName: this.getSenderName(msg),
      content: this.extractContent(content),
      timestamp: (msg['date'] as number) || 0,
      type: type,
      mediaUrl: mediaUrl,
      mediaThumbnail: mediaThumbnail
    };
  }

  /**
   * 获取发送者名称
   */
  private getSenderName(msg: Record<string, Object>): string {
    const senderId = msg['senderId'] as number;
    if (senderId) {
      return `User ${senderId}`;
    }
    return '未知';
  }

  /**
   * 提取消息内容
   */
  private extractContent(content: Record<string, Object>): string {
    const textObj = content['text'] as Record<string, Object> | undefined;
    if (textObj) {
      const text = textObj['text'] as string | undefined;
      return text || '';
    }
    const caption = content['caption'] as Record<string, Object> | undefined;
    if (caption) {
      const captionText = caption['text'] as string | undefined;
      return captionText || '';
    }
    return '[媒体消息]';
  }

  /**
   * 取消置顶消息
   */
  private async unpinMessage(messageId: number): Promise<void> {
    if (!this.tdLibApi) {
      return;
    }

    try {
      await this.tdLibApi.unpinChatMessage(this.chatId, messageId);
      this.pinnedMessages = this.pinnedMessages.filter(msg => msg.id !== messageId);
    } catch (error) {
      logger.error(0x0001, this.TAG, 'Failed to unpin message', error);
      throw new BusinessError(BusinessErrorCode.OPERATION_FAILED, '取消置顶失败', '取消置顶失败');
    }
  }

  /**
   * 跳转到消息
   */
  private navigateToMessage(message: PinnedMessage): void {
    try {
      router.pushUrl({
        url: 'pages/common/ChatPage',
        params: {
          chatId: this.chatId,
          chatType: ChatType.GROUP,
          title: this.chatTitle,
          messageId: message.id
        }
      });
    } catch (error) {
      logger.error(0x0001, this.TAG, 'Failed to navigate to message', error);
    }
  }

  /**
   * 显示消息详情
   */
  private showMessageDetail(message: PinnedMessage): void {
    this.selectedMessage = message;
  }

  /**
   * 格式化时间
   */
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp * 1000);
    return date.toLocaleString([], {
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    });
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

      // 内容区域
      if (this.isLoading) {
        this.buildLoadingView()
      } else if (this.pinnedMessages.length === 0) {
        this.buildEmptyView()
      } else {
        this.buildMessagesList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.background)
  }

  @Builder
  buildHeader() {
    Row() {
      Text('置顶消息')
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

      Text(`${this.pinnedMessages.length}`)
        .fontSize(14)
        .fontColor(this.theme.textSecondary)
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
      Text('📌')
        .fontSize(64)
        .margin({ bottom: 16 })

      Text('暂无置顶消息')
        .fontSize(16)
        .fontColor(this.theme.textSecondary)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildMessagesList() {
    List({ space: 8 }) {
      ForEach(this.pinnedMessages, (message: PinnedMessage) => {
        ListItem() {
          this.buildMessageItem(message)
        }
      }, (message: PinnedMessage) => message.id.toString())
    }
    .layoutWeight(1)
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
  }

  @Builder
  buildMessageItem(message: PinnedMessage) {
    Row() {
      // 发送者头像
      if (message.senderAvatar) {
        Avatar({
          source: message.senderAvatar,
          name: message.senderName,
          avatarSize: 48
        })
      } else {
        Text(message.senderName.charAt(0))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.theme.primary)
          .width(48)
          .height(48)
          .textAlign(TextAlign.Center)
          .borderRadius(24)
          .backgroundColor(this.theme.surface)
      }

      // 消息内容
      Column() {
        Row() {
          Text(message.senderName)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.theme.text)
            .layoutWeight(1)

          Text('📌')
            .fontSize(16)

          Text(this.formatTime(message.timestamp))
            .fontSize(12)
            .fontColor(this.theme.textSecondary)
            .margin({ left: 8 })
        }
        .width('100%')
        .margin({ bottom: 4 })

        Row() {
          if (message.type === 'text') {
            Text(message.content)
              .fontSize(14)
              .fontColor(this.theme.textSecondary)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          } else if (message.mediaUrl || message.mediaThumbnail) {
            Image(message.mediaThumbnail || message.mediaUrl || '')
              .width(60)
              .height(60)
              .objectFit(ImageFit.Cover)
              .borderRadius(4)
              .margin({ right: 8 })

            Text(this.getMessageTypeLabel(message.type))
              .fontSize(14)
              .fontColor(this.theme.textSecondary)
          } else {
            Text(`${this.getMessageTypeLabel(message.type)}: ${message.content}`)
              .fontSize(14)
              .fontColor(this.theme.textSecondary)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)

      // 操作按钮
      Column() {
        Button()
          .width(32)
          .height(32)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.unpinMessage(message.id);
          })

        Button()
          .width(32)
          .height(32)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.navigateToMessage(message);
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 8, bottom: 8 })
    .borderRadius(8)
    .backgroundColor(this.theme.surface)
    .alignItems(VerticalAlign.Top)
    .onClick(() => {
      this.navigateToMessage(message);
    })
  }

  /**
   * 获取消息类型标签
   */
  private getMessageTypeLabel(type: string): string {
    switch (type) {
      case 'photo':
        return '📷 图片';
      case 'video':
        return '🎬 视频';
      case 'file':
        return '📎 文件';
      case 'voice':
        return '🎤 语音';
      case 'sticker':
        return '😊 贴纸';
      default:
        return '💬 消息';
    }
  }
}
