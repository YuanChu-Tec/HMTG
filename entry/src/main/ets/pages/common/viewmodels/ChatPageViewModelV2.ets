// ChatPageViewModelV2.ets
// 重构后的聊天页面 ViewModel - 采用 Gramony-dev 架构模式

// 状态装饰器 @Trace 和 @ObservedV2 是全局可用的，无需导入
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction } from '@kit.ArkUI';
import { picker } from '@kit.CoreFileKit';
import { MessageDataSource } from '../../../datasource/MessageDataSource';
import { MessageEntity, ChatEntity } from '@storage/cache';
import { CoreService } from '../../../services/business/CoreService';
import { TdApiFactory } from '../../../services/api/factory/TdApiFactory';
import { common } from '@kit.AbilityKit';
import { EventBus } from '../../../utils/event/EventBus';
import { 
  Chat, Message, MessageType, MessageStatus, ChatType, 
  MediaInfo, FileInfo, MessageContent, ForwardInfo, TextEntity,
  GroupEventType, SystemMessageType, SystemMessageParams,
  PollOption, InlineKeyboardMarkup, ReplyKeyboardMarkup, 
  DiceInfo, PaidMediaInfo, GiftInfo, GiveawayInfo 
} from '../../../models/TDLibData';
import { formatString } from '../../../utils/i18n/ResourceHelper';

// 定义 CoreService 返回的用户信息类型
interface CoreUserInfo {
  name: string;
  avatar: string;
  isBot?: boolean;
  isPremium?: boolean;
}

/**
 * 用户名信息接口（用于异步加载用户信息）
 */
interface UserNameInfo {
  userId: number;
  name: string;
}

/**
 * 机器人命令接口
 */
interface BotCommand {
  command: string;
  description: string;
}

/**
 * 文件下载状态
 */
interface FileDownloadState {
  progress: number;
  isDownloading: boolean;
  localPath?: string;
}

/**
 * 文件进度更新数据
 */
interface FileProgressUpdate {
  progress: number;
  isCompleted: boolean;
  localPath?: string;
  isDownloading: boolean;
}

/**
 * 滚动到消息事件数据
 */
interface ScrollToMessageData {
  messageId: number;
}


const TAG = 'ChatPageViewModelV2';
const DOMAIN = 0x0001;
const TYPING_DEBOUNCE_DELAY = 2000;

@ObservedV2
export class ChatPageViewModelV2 {
  // ==================== 响应式数据 ====================
  @Trace chatId: number = 0;
  @Trace chatType: ChatType = ChatType.PRIVATE;
  @Trace chatTitle: string = '';
  @Trace chatAvatar: string = '';
  @Trace isLoading: boolean = true;
  @Trace isLoadingMore: boolean = false;
  @Trace isSending: boolean = false;
  @Trace errorMessage: string = '';
  @Trace unreadCount: number = 0;
  @Trace inputText: string = '';
  @Trace showEmojiPicker: boolean = false;
  @Trace showAttachmentMenu: boolean = false;
  @Trace showTypingIndicator: boolean = false;
  @Trace typingText: string = '';
  @Trace connectionState: string = 'connected';
  @Trace selectedMessageId: number | null = null;
  @Trace showContextMenu: boolean = false;

  // 聊天权限相关
  @Trace isChannelAdmin: boolean = false;
  @Trace canSendMessages: boolean = true;
  @Trace discussionChatId: number | null = null;

  // 区分"我的"和"其他人的"频道/群组
  @Trace isMyChat: boolean = false;
  @Trace isOwner: boolean = false;
  @Trace isAdmin: boolean = false;

  // 机器人相关
  @Trace replyKeyboard: ReplyKeyboardMarkup | null = null;
  @Trace showReplyKeyboard: boolean = false;
  @Trace botCommands: BotCommand[] = [];
  @Trace showCommandSuggestions: boolean = false;

  // 多选操作相关
  @Trace isMultiSelectMode: boolean = false;
  @Trace selectedMessageIds: Set<number> = new Set();
  @Trace showMultiSelectToolbar: boolean = false;

  // 核心：DataSource 管理消息数据
  messageDataSource: MessageDataSource;

  // ==================== 内部状态 ====================
  private coreService: CoreService;
  private context: common.UIAbilityContext;
  private messageMap: Map<number, Message> = new Map();
  private fileDownloadMap: Map<number, FileDownloadState> = new Map();
  private typingDebounceTimer: number = -1;
  private oldestMessageId: number = 0;
  private eventBus: EventBus = EventBus.getInstance();
  private contextMenuTimer: number = -1;
  private loadingReplyMessageIds: Set<number> = new Set();
  private loadingUserInfoMessageIds: Set<number> = new Set();

  // 加载状态（暴露给UI层使用）
  public hasMoreMessages: boolean = true;

  // 事件订阅句柄
  private unsubscribeNewMessage?: () => void;
  private unsubscribeMessageUpdate?: () => void;
  private unsubscribeMessageDelete?: () => void;
  private unsubscribeChatUpdate?: () => void;
  private unsubscribeFileDownload?: () => void;
  private unsubscribeConnectionState?: () => void;
  private unsubscribeMessageSent?: () => void;
  private unsubscribeMessageFailed?: () => void;
  private unsubscribeMessageEdited?: () => void;
  private unsubscribeChatAction?: () => void;

  constructor(context: common.UIAbilityContext, chatId: number, chatTitle: string, chatType?: ChatType) {
    this.context = context;
    this.chatId = chatId;
    this.chatTitle = chatTitle;
    this.chatType = chatType || ChatType.PRIVATE;
    
    this.coreService = CoreService.getInstance();
    this.messageDataSource = new MessageDataSource(context, chatId);

    // 设置预加载回调
    this.messageDataSource.onPrefetchNeeded = (oldestId) => {
      this.loadMoreMessages(oldestId);
    };

    this.registerEventListeners();
    this.initialize();

    hilog.info(DOMAIN, TAG, `✅ ChatPageViewModelV2 created for chat ${chatId}`);
  }

  /**
   * 初始化 - 加载消息
   * 优化策略：分阶段加载，优先显示缓存数据，后台同步服务器数据
   */
  async initialize(): Promise<void> {
    this.isLoading = true;
    try {
      // 阶段1：加载聊天信息（关键路径，必须等待）
      await this.loadChatInfo();
      
      // 更新聊天权限
      this.updateChatPermissions();
      
      // 阶段2：从缓存加载消息（后台执行，不阻塞UI）
      this.loadMessagesFromCacheInBackground();
      
      // 阶段3：后台同步服务器消息（不阻塞UI）
      this.syncWithServerInBackground();
      
      hilog.info(DOMAIN, TAG, `✅ Initialized with ${this.messageDataSource.totalCount()} messages`);
    } catch (error) {
      this.errorMessage = '加载消息失败';
      hilog.error(DOMAIN, TAG, `❌ Initialize failed: ${error}`);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 清理资源
   */
  aboutToDisappear(): void {
    this.unregisterEventListeners();
    this.unsubscribeNewMessage?.();
    this.unsubscribeMessageUpdate?.();
    this.unsubscribeMessageDelete?.();
    this.unsubscribeChatUpdate?.();
    if (this.typingDebounceTimer !== -1) clearTimeout(this.typingDebounceTimer);
    if (this.contextMenuTimer !== -1) clearTimeout(this.contextMenuTimer);
    if (this.fileProgressDebounceTimer !== -1) clearTimeout(this.fileProgressDebounceTimer);
    // 清理消息批处理相关资源
    if (this.messageBatchDebounceTimer !== -1) {
      clearTimeout(this.messageBatchDebounceTimer);
      // 立即处理剩余的消息
      this.flushPendingMessages();
    }
    this.pendingNewMessages = [];
    this.messageMap.clear();
    this.fileDownloadMap.clear();
    this.fileIdToMessageIdMap.clear();
    this.pendingFileProgressUpdates.clear();
    hilog.info(DOMAIN, TAG, `✅ ChatPageViewModelV2 destroyed for chat ${this.chatId}`);
  }

  // ========== 数据加载 ==========

  /**
   * 从缓存加载消息（限制初始加载数量，提高首屏速度）
   */
  private async loadMessagesFromCache(): Promise<void> {
    const messages: Message[] = await this.coreService.getCachedMessages(this.chatId);
    
    // 限制初始加载数量，优先显示最新消息
    const MAX_INITIAL_MESSAGES = 50;
    const recentMessages = messages.length > MAX_INITIAL_MESSAGES 
      ? messages.slice(messages.length - MAX_INITIAL_MESSAGES) 
      : messages;
    
    const entities = recentMessages
      .map((m: Message) => this.convertToEntity(m))
      .filter(Boolean) as MessageEntity[];

    if (entities.length > 0) {
      await this.messageDataSource.setMessages(entities);
      hilog.info(DOMAIN, TAG, `Loaded ${entities.length} messages from cache (total: ${messages.length})`);
    }
  }

  /**
   * 后台从缓存加载消息（不阻塞UI）
   */
  private loadMessagesFromCacheInBackground(): void {
    // 使用 fire-and-forget 模式，避免阻塞页面初始化
    this.loadMessagesFromCache().catch((error: Error) => {
      hilog.warn(DOMAIN, TAG, `Background cache load failed: ${error.message}`);
    });
  }

  /**
   * 后台同步服务器最新消息（不阻塞UI）
   */
  private syncWithServerInBackground(): void {
    // 使用 fire-and-forget 模式，避免阻塞页面初始化
    this.doSyncWithServer().catch((error: Error) => {
      hilog.warn(DOMAIN, TAG, `Background sync failed: ${error.message}`);
    });
  }

  /**
   * 实际同步服务器消息（批量处理）
   * 优化：添加去重检查，避免与缓存消息重复
   */
  private async doSyncWithServer(): Promise<void> {
    try {
      // 使用 getChatHistory 获取最新消息，fromMessageId=0 表示获取最新消息
      const newMessages = await this.coreService.getChatHistory(this.chatId, 0, 0, 20, false);
      
      if (newMessages.length === 0) return;

      // 批量转换消息，过滤已存在的消息
      const entities: MessageEntity[] = [];
      for (const msg of newMessages) {
        const msgRecord = msg as Record<string, Object>;
        const msgId = msgRecord['id'] as number;
        
        // ⭐ 关键修复：检查消息是否已存在（避免重复）
        if (this.messageMap.has(msgId)) {
          continue;
        }
        
        const entity = this.convertToEntity(msgRecord);
        if (entity) {
          entities.push(entity);
          this.messageMap.set(msgId, msg as Message);
        }
      }
      
      // 批量添加到 DataSource（同步，无延迟）
      if (entities.length > 0) {
        this.messageDataSource.appendMessages(entities);
        hilog.info(DOMAIN, TAG, `Background synced ${entities.length} new messages from server`);
      } else {
        hilog.info(DOMAIN, TAG, 'No new messages to sync from server');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to sync with server: ${error}`);
    }
  }

  /**
   * 加载更多历史消息（批量处理优化）
   * 
   * ⭐ 关键优化：使用分片处理避免一次性转换大量消息阻塞 UI
   */
  async loadMoreMessages(fromMessageId?: number): Promise<void> {
    if (this.isLoadingMore) return;
    
    this.isLoadingMore = true;
    try {
      const oldestId = fromMessageId || this.messageDataSource.getOldestMessageId();
      if (oldestId === 0) {
        hilog.info(DOMAIN, TAG, 'No more messages to load');
        return;
      }

      hilog.info(DOMAIN, TAG, `Loading more messages from ${oldestId}`);
      // 减少单次加载数量，提高响应速度
      const messages = await this.coreService.getChatHistory(this.chatId, oldestId, 0, 30, false);
      
      if (messages.length === 0) {
        this.hasMoreMessages = false;
        return;
      }

      // ⭐ 关键优化：分片处理消息转换，避免阻塞 UI
      const CHUNK_SIZE = 10; // 每帧处理 10 条消息
      const entities: MessageEntity[] = [];
      
      for (let i = 0; i < messages.length; i += CHUNK_SIZE) {
        const chunk = messages.slice(i, i + CHUNK_SIZE);
        
        // 处理当前分片
        for (const msg of chunk) {
          const msgRecord = msg as Record<string, Object>;
          const msgId = msgRecord['id'] as number;
          
          // 检查消息是否已存在（避免重复）
          if (this.messageMap.has(msgId)) {
            continue;
          }
          
          const entity = this.convertToEntity(msgRecord);
          if (entity) {
            entities.push(entity);
            this.messageMap.set(msgId, msg as Message);
          }
        }
        
        // ⭐ 让出主线程，避免阻塞 UI
        if (i + CHUNK_SIZE < messages.length) {
          await new Promise<void>(resolve => setTimeout(resolve, 0));
        }
      }
      
      // 批量添加到 DataSource（同步，无延迟）
      if (entities.length > 0) {
        this.messageDataSource.prepend(entities);
        hilog.info(DOMAIN, TAG, `Loaded ${entities.length} more messages`);
      }
      
      // 如果没有返回足够数量的消息，说明已经加载完了
      if (messages.length < 30) {
        this.hasMoreMessages = false;
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to load more messages: ${error}`);
    } finally {
      this.isLoadingMore = false;
    }
  }

  // ========== 消息操作 ==========

  /**
   * 发送文本消息（带文本参数版本）
   */
  async sendTextMessage(text: string): Promise<void> {
    if (!text.trim() || this.isSending) return;

    this.isSending = true;
    try {
      // 创建临时消息
      const tempMsg = this.createTempMessage(text);
      this.messageDataSource.push(tempMsg);

      // 发送消息
      const sentMsg = await this.coreService.sendTextMessage(this.chatId, text);
      const entity = this.convertToEntity(sentMsg);

      // 替换临时消息
      if (entity) {
        this.messageDataSource.replace(tempMsg.messageId, entity);
        hilog.info(DOMAIN, TAG, `Message sent: ${entity.messageId}`);
      }
    } catch (error) {
      this.errorMessage = '发送失败';
      hilog.error(DOMAIN, TAG, `Failed to send message: ${error}`);
    } finally {
      this.isSending = false;
    }
  }

  /**
   * 发送文本消息（使用当前 inputText）
   */
  async sendInputTextMessage(): Promise<void> {
    await this.sendTextMessage(this.inputText);
    this.inputText = ''; // 清空输入
  }

  /**
   * 发送图片消息（带文件路径）
   */
  async sendPhotoMessage(filePath: string, caption?: string): Promise<void> {
    if (this.isSending) return;

    this.isSending = true;
    try {
      const sentMsg: Message = await this.coreService.sendImageMessage(this.chatId, filePath);
      const entity = this.convertToEntity(sentMsg);
      if (entity) {
        this.messageDataSource.push(entity);
      }
    } catch (error) {
      this.errorMessage = '发送图片失败';
      hilog.error(DOMAIN, TAG, `Failed to send photo: ${error}`);
    } finally {
      this.isSending = false;
    }
  }

  /**
   * 发送图片（从相册选择）
   */
  async sendPhoto(): Promise<void> {
    try {
      const options = new picker.PhotoSelectOptions();
      options.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      const result = await new picker.PhotoViewPicker().select(options);
      if (result.photoUris.length) {
        await this.coreService.sendImageMessage(this.chatId, result.photoUris[0]);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `sendPhoto failed: ${error}`);
    }
  }

  /**
   * 发送视频
   */
  async sendVideo(): Promise<void> {
    promptAction.showToast({ message: '视频发送功能开发中', duration: 1500 });
  }

  /**
   * 发送文件
   */
  async sendFile(): Promise<void> {
    promptAction.showToast({ message: '文件发送功能开发中', duration: 1500 });
  }

  /**
   * 发送位置
   */
  async sendLocation(): Promise<void> {
    promptAction.showToast({ message: '位置发送功能开发中', duration: 1500 });
  }

  /**
   * 开始录音
   */
  async startRecording(): Promise<void> {
    promptAction.showToast({ message: '录音功能开发中', duration: 1500 });
  }

  /**
   * 转发消息（带目标聊天ID版本）
   */
  async forwardMessage(toChatId: number, messageId: number): Promise<void> {
    try {
      const tdLibApi = TdApiFactory.getInstance().createDefault();
      await tdLibApi.forwardMessages(toChatId, null, this.chatId, [messageId], null, false, false);
      hilog.info(DOMAIN, TAG, `Message ${messageId} forwarded to ${toChatId}`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to forward message: ${error}`);
    }
  }

  /**
   * 转发消息（显示选择对话框版本）
   */
  async showForwardDialog(messageId: number): Promise<void> {
    // TODO: 实现转发选择对话框
    promptAction.showToast({ message: '转发功能开发中', duration: 1500 });
  }

  /**
   * 删除消息（带参数版本）
   */
  async deleteMessage(messageId: number, forEveryone: boolean = false): Promise<void> {
    try {
      this.messageDataSource.delete(messageId);
      await this.coreService.deleteMessages(this.chatId, [messageId], forEveryone);
      hilog.info(DOMAIN, TAG, `Message ${messageId} deleted`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to delete message: ${error}`);
    }
  }

  /**
   * 删除当前选中的消息（显示确认对话框）
   */
  async deleteSelectedMessage(): Promise<void> {
    if (!this.selectedMessageId) return;

    const result = await promptAction.showDialog({
      title: '删除消息',
      message: '确定要删除这条消息吗？',
      buttons: [{ text: '取消', color: '#8E8E93' }, { text: '删除', color: '#FA2A2D' }]
    });
    if (result.index === 1) {
      await this.deleteMessage(this.selectedMessageId, true);
    }
    this.showContextMenu = false;
    this.selectedMessageId = null;
  }

  /**
   * 回复消息（带文本参数版本）
   */
  async replyMessage(replyToMessageId: number, text: string): Promise<void> {
    if (!text.trim() || this.isSending) return;

    this.isSending = true;
    try {
      // 使用 CoreService 发送带回复的文本消息
      const sentMsg = await this.coreService.sendTextMessageWithReply(this.chatId, text, replyToMessageId);
      const entity = this.convertToEntity(sentMsg);
      if (entity) {
        this.messageDataSource.push(entity);
      }
    } catch (error) {
      this.errorMessage = '回复失败';
      hilog.error(DOMAIN, TAG, `Failed to reply message: ${error}`);
    } finally {
      this.isSending = false;
    }
  }

  /**
   * 设置回复消息（无参数版本 - 兼容V1）
   */
  async replyToMessage(messageId: number): Promise<void> {
    // TODO: 实现回复UI状态设置
    promptAction.showToast({ message: '回复功能开发中', duration: 1500 });
  }

  /**
   * 编辑消息
   */
  async editMessage(messageId: number, newText: string): Promise<void> {
    try {
      const updatedMsg: Message = await this.coreService.editMessageText(this.chatId, messageId, newText);
      const entity = this.convertToEntity(updatedMsg);
      if (entity) {
        this.messageDataSource.update(entity);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to edit message: ${error}`);
    }
  }

  // ========== 聊天操作 ==========

  /**
   * 标记聊天已读
   */
  async markAsRead(): Promise<void> {
    try {
      await this.coreService.markAsRead(this.chatId);
      this.unreadCount = 0;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to mark chat as read: ${error}`);
    }
  }


  /**
   * 加载聊天信息
   */
  private async loadChatInfo(): Promise<void> {
    try {
      const chat = await this.coreService.getChat(this.chatId);
      if (chat) {
        this.chatTitle = chat.title || this.chatTitle;
        this.chatAvatar = chat.avatar || '';
        this.unreadCount = chat.unreadCount || 0;
        
        // 判断是否为"我的"聊天
        if (chat.type === ChatType.CHANNEL || chat.type === ChatType.GROUP) {
          // 从聊天权限判断 - 使用 Chat 接口中的 isOwner 和 isAdmin 属性
          this.isOwner = chat.isOwner || false;
          this.isAdmin = chat.isAdmin || false;
          this.isMyChat = this.isOwner || this.isAdmin;
        }
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to load chat info: ${error}`);
    }
  }

  /**
   * 更新聊天权限
   */
  private updateChatPermissions(): void {
    if (this.chatType === ChatType.CHANNEL) {
      // 频道只有管理员可以发送消息
      this.canSendMessages = this.isAdmin || this.isOwner;
      this.isChannelAdmin = this.isAdmin || this.isOwner;
    } else if (this.chatType === ChatType.GROUP) {
      // 群组根据权限设置
      this.canSendMessages = true; // 默认允许，具体由 CoreService 控制
    } else {
      // 私聊和机器人默认可以发送
      this.canSendMessages = true;
    }
  }

  /**
   * 清空聊天数据（切换聊天时调用）
   */
  public clearChatData(): void {
    this.messageDataSource.clear();
    this.messageMap.clear();
    this.inputText = '';
    this.selectedMessageId = null;
    this.showContextMenu = false;
    this.exitMultiSelectMode();
    this.oldestMessageId = 0;
    this.hasMoreMessages = true;
  }

  /**
   * 获取聊天成员信息
   */
  async getChatMember(userId: number): Promise<CoreUserInfo | null> {
    try {
      return await this.coreService.getUserInfo(userId) as CoreUserInfo;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to get chat member: ${error}`);
      return null;
    }
  }

  // ========== 工具方法 ==========

  private convertToEntity(data: Record<string, Object> | Message): MessageEntity | null {
    if (!data) return null;

    try {
      const msg = new MessageEntity();
      // 使用类型断言统一处理两种类型
      const record = data as Record<string, Object>;
      msg.messageId = (record['id'] || record['messageId']) as number;
      msg.chatId = (record['chatId'] || this.chatId) as number;
      // 获取发送者ID
      const senderId = record['senderId'] as number | undefined;
      const sender = record['sender'] as Record<string, Object> | undefined;
      msg.senderId = senderId || (sender ? sender['id'] as number : 0) || 0;
      msg.date = (record['date'] || Date.now() / 1000) as number;
      // 获取内容类型
      const content = record['content'] as Record<string, Object> | undefined;
      msg.contentType = (content?.['_constructor'] || 'messageText') as string;
      msg.contentJson = JSON.stringify(content || {});
      msg.entitiesJson = record['entities'] ? JSON.stringify(record['entities']) : '';
      // 获取回复消息ID
      const replyToMessageId = record['replyToMessageId'] as number | undefined;
      const replyTo = record['replyTo'] as Record<string, Object> | undefined;
      msg.replyToMsgId = replyToMessageId || (replyTo ? replyTo['messageId'] as number : 0) || 0;
      msg.isOutgoing = (record['isOutgoing'] || false) as boolean;
      msg.isRead = (record['isRead'] || false) as boolean;
      msg.caption = (record['caption'] || '') as string;

      // ⭐ 关键修复：设置发送者名称和头像
      // 1. 优先从数据源中的 senderName/senderAvatar 获取
      let extractedSenderName = (record['senderName'] || record['sender_name'] || '') as string;
      let extractedSenderAvatar = (record['senderAvatar'] || record['sender_avatar'] || '') as string;

      // 2. 如果 senderName 为空但 sender 对象中有名称信息，从中提取
      if (!extractedSenderName && sender) {
        const firstName = (sender['first_name'] || '') as string;
        const lastName = (sender['last_name'] || '') as string;
        extractedSenderName = `${firstName} ${lastName}`.trim() || (sender['username'] as string) || '';
      }

      // 3. 如果仍然没有 senderName，尝试从 CoreService 的用户缓存获取
      if (!extractedSenderName && msg.senderId > 0) {
        const cachedUser = this.coreService.getCachedUserInfo(msg.senderId);
        if (cachedUser && cachedUser.name) {
          extractedSenderName = cachedUser.name;
          extractedSenderAvatar = cachedUser.avatar || '';
          // ⭐ 关键修复：头像路径需要添加 file:// 前缀
          if (extractedSenderAvatar && !extractedSenderAvatar.startsWith('file://') && extractedSenderAvatar.startsWith('/')) {
            extractedSenderAvatar = 'file://' + extractedSenderAvatar;
          }
        } else {
          // 缓存未命中时使用兜底值，并触发异步加载
          extractedSenderName = `User ${msg.senderId}`;
          // ⭐ 关键修复：异步加载用户信息
          this.loadUserInfoForMessageById(msg.messageId, msg.senderId);
        }
      }

      // 4. ⭐ 关键修复：如果已有 senderName 但没有 avatar，尝试获取 avatar
      if (extractedSenderName && !extractedSenderAvatar && msg.senderId > 0) {
        const cachedUser = this.coreService.getCachedUserInfo(msg.senderId);
        if (cachedUser?.avatar) {
          extractedSenderAvatar = cachedUser.avatar;
          // 头像路径需要添加 file:// 前缀
          if (!extractedSenderAvatar.startsWith('file://') && extractedSenderAvatar.startsWith('/')) {
            extractedSenderAvatar = 'file://' + extractedSenderAvatar;
          }
        } else {
          // 异步加载用户信息以获取头像
          this.loadUserInfoForMessageById(msg.messageId, msg.senderId);
        }
      }

      msg.senderName = extractedSenderName;
      msg.senderAvatar = extractedSenderAvatar;

      return msg;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to convert message: ${error}`);
      return null;
    }
  }

  private createTempMessage(text: string): MessageEntity {
    const msg = new MessageEntity();
    msg.messageId = -Date.now(); // 临时负数 ID
    msg.chatId = this.chatId;
    msg.senderId = 0; // 自己
    msg.date = Date.now() / 1000;
    msg.contentType = 'messageText';
    // 直接构建 JSON 字符串避免对象字面量检查
    msg.contentJson = `{"_constructor":"messageText","text":{"text":"${text}"}}`;
    msg.isOutgoing = true;
    msg.isRead = true;
    return msg;
  }

  /**
   * 获取消息发送者名称
   */
  async getSenderName(senderId: number): Promise<string> {
    if (senderId === 0) return '我';
    try {
      const user = await this.coreService.getUserInfo(senderId);
      return user?.name || `User ${senderId}`;
    } catch (error) {
      return `User ${senderId}`;
    }
  }

  /**
   * 获取消息发送者头像
   */
  async getSenderAvatar(senderId: number): Promise<string> {
    try {
      const user = await this.coreService.getUserInfo(senderId);
      return user?.avatar || '';
    } catch (error) {
      return '';
    }
  }

  // ==================== 回复消息功能 ====================

  /**
   * 获取被回复消息的发送者名称
   */
  public getReplySenderName(messageId: number): string {
    hilog.info(DOMAIN, TAG, `getReplySenderName called: messageId=${messageId}, mapSize=${this.messageMap.size}`);
    const msg = this.messageMap.get(messageId);
    if (!msg) {
      hilog.warn(DOMAIN, TAG, `Reply message ${messageId} not found in map, loading...`);
      // 异步加载被回复的消息
      this.loadReplyMessageIfNeeded(messageId);
      return '加载中...';
    }
    
    // 如果有 senderName，直接返回
    if (msg.senderName && msg.senderName.length > 0) {
      hilog.info(DOMAIN, TAG, `Reply message ${messageId} found: senderName=${msg.senderName}`);
      return msg.senderName;
    }
    
    // 如果没有 senderName 但有 senderId，尝试异步加载用户信息
    if (msg.senderId && msg.senderId > 0) {
      hilog.info(DOMAIN, TAG, `Reply message ${messageId} has no senderName, loading user info for senderId=${msg.senderId}`);
      this.loadUserInfoForMessage(msg);
      return '加载中...';
    }
    
    // 如果没有 senderId，可能是频道/群组消息，尝试从聊天信息获取
    if (msg.chatId) {
      const chat = this.coreService.getChat(msg.chatId);
      if (chat && chat.title) {
        return chat.title;
      }
    }
    
    return 'Unknown';
  }

  /**
   * 获取回复消息的预览文本
   */
  public getReplyPreview(messageId: number): string {
    const msg = this.messageMap.get(messageId);
    if (!msg) {
      // 异步加载被回复的消息
      this.loadReplyMessageIfNeeded(messageId);
      return '加载中...';
    }

    switch (msg.type) {
      case MessageType.TEXT:
        const text = typeof msg.content === 'string' ? msg.content : (msg.content as MessageContent).text || '';
        return text.length > 30 ? text.substring(0, 30) + '...' : text;
      case MessageType.PHOTO:
        return '图片';
      case MessageType.VIDEO:
        return '视频';
      case MessageType.AUDIO:
        return '音乐';
      case MessageType.VOICE_NOTE:
        return '语音';
      case MessageType.DOCUMENT:
        return '文件';
      case MessageType.STICKER:
        return '贴纸';
      case MessageType.LOCATION:
        return '位置';
      case MessageType.CONTACT:
        return '联系人';
      case MessageType.POLL:
        return '投票';
      case MessageType.GAME:
        return '游戏';
      case MessageType.CALL:
        return '通话';
      default:
        return '消息';
    }
  }

  /**
   * 异步加载被回复的消息
   */
  private async loadReplyMessageIfNeeded(messageId: number): Promise<void> {
    // 避免重复加载
    if (this.loadingReplyMessageIds.has(messageId)) {
      return;
    }
    this.loadingReplyMessageIds.add(messageId);
    
    try {
      // 从 CoreService 获取消息
      const message: Message | null = await this.coreService.getMessage(messageId);
      if (message) {
        this.messageMap.set(messageId, message);
        hilog.info(DOMAIN, TAG, `Loaded reply message ${messageId}`);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to load reply message ${messageId}: ${error}`);
    } finally {
      this.loadingReplyMessageIds.delete(messageId);
    }
  }

  // ==================== 用户信息异步加载 ====================

  /**
   * 异步加载消息的发送者用户信息
   */
  private async loadUserInfoForMessage(message: Message): Promise<void> {
    if (!message.senderId || message.senderId <= 0) {
      return;
    }
    
    // 避免重复加载
    if (this.loadingUserInfoMessageIds.has(message.id)) {
      return;
    }
    this.loadingUserInfoMessageIds.add(message.id);
    
    try {
      const userInfo = await this.coreService.getUserInfo(message.senderId);
      if (userInfo && userInfo.name && userInfo.name.length > 0) {
        // 更新消息的 senderName
        message.senderName = userInfo.name;
        // 通知数据变化
        this.messageDataSource.updateMessage(message);
        hilog.info(DOMAIN, TAG, `Updated message ${message.id} senderName to ${userInfo.name}`);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to load user info for message ${message.id}: ${error}`);
    } finally {
      this.loadingUserInfoMessageIds.delete(message.id);
    }
  }

  /**
   * 根据 messageId 和 senderId 异步加载用户信息并更新消息
   */
  private async loadUserInfoForMessageById(messageId: number, senderId: number): Promise<void> {
    // 避免重复加载
    if (this.loadingUserInfoMessageIds.has(messageId)) {
      return;
    }
    this.loadingUserInfoMessageIds.add(messageId);
    
    try {
      const userInfo = await this.coreService.getUserInfo(senderId);
      if (userInfo && (userInfo.name || userInfo.avatar)) {
        // 从数据源获取消息
        const allMessages: MessageEntity[] = this.messageDataSource.getAll();
        const message: MessageEntity | undefined = allMessages.find((m: MessageEntity) => m.messageId === messageId);
        if (message) {
          // 更新消息的用户信息
          let updated = false;
          if (userInfo.name && !message.senderName) {
            message.senderName = userInfo.name;
            updated = true;
          }
          if (userInfo.avatar && !message.senderAvatar) {
            // ⭐ 关键修复：头像路径需要添加 file:// 前缀
            let avatarPath = userInfo.avatar;
            if (avatarPath && !avatarPath.startsWith('file://') && avatarPath.startsWith('/')) {
              avatarPath = 'file://' + avatarPath;
            }
            message.senderAvatar = avatarPath;
            updated = true;
          }
          // 通知数据变化
          if (updated) {
            this.messageDataSource.update(message);
            hilog.info(DOMAIN, TAG, `Updated message ${messageId} with user info: name=${userInfo.name}, avatar=${userInfo.avatar ? 'yes' : 'no'}`);
          }
        }
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to load user info for message ${messageId}: ${error}`);
    } finally {
      this.loadingUserInfoMessageIds.delete(messageId);
    }
  }

  /**
   * 异步加载转发消息的用户信息并更新
   */
  private async loadUserInfoForForwardMessage(messageId: number, senderId: number): Promise<void> {
    // 避免重复加载
    if (this.loadingUserInfoMessageIds.has(messageId)) {
      return;
    }
    this.loadingUserInfoMessageIds.add(messageId);
    
    try {
      const userInfo = await this.coreService.getUserInfo(senderId);
      if (userInfo && userInfo.name) {
        // 从数据源获取消息
        const allMessages: MessageEntity[] = this.messageDataSource.getAll();
        const message: MessageEntity | undefined = allMessages.find((m: MessageEntity) => m.messageId === messageId);
        if (message && message.forwardInfo) {
          // 更新转发信息的 senderName
          message.forwardInfo['senderName'] = userInfo.name;
          // 通知数据变化
          this.messageDataSource.update(message);
          hilog.info(DOMAIN, TAG, `Updated forward message ${messageId} senderName to ${userInfo.name}`);
        }
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to load user info for forward message ${messageId}: ${error}`);
    } finally {
      this.loadingUserInfoMessageIds.delete(messageId);
    }
  }

  /**
   * 异步加载聊天信息并更新消息（用于群组关联频道的情况）
   */
  private async loadChatInfoForMessage(messageId: number, chatId: number): Promise<void> {
    // 避免重复加载
    if (this.loadingUserInfoMessageIds.has(messageId)) {
      return;
    }
    this.loadingUserInfoMessageIds.add(messageId);
    
    try {
      // 从 CoreService 获取聊天信息
      const chat = await this.coreService.getChat(chatId);
      if (chat && chat.title) {
        // 从数据源获取消息
        const allMessages: MessageEntity[] = this.messageDataSource.getAll();
        const message: MessageEntity | undefined = allMessages.find((m: MessageEntity) => m.messageId === messageId);
        if (message && !message.senderName) {
          // 更新消息的发送者名称（频道标题）
          message.senderName = chat.title;
          // 通知数据变化
          this.messageDataSource.update(message);
          hilog.info(DOMAIN, TAG, `Updated message ${messageId} senderName to chat title: ${chat.title}`);
        }
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to load chat info for message ${messageId}: ${error}`);
    } finally {
      this.loadingUserInfoMessageIds.delete(messageId);
    }
  }

  // ==================== UI 交互方法 ====================

  /**
   * 处理输入文本变化
   */
  onInputTextChange(value: string): void {
    this.inputText = value;

    // 检测是否输入 / 开头
    if (this.chatType === ChatType.BOT && value.startsWith('/')) {
      this.showCommandSuggestions = true;
    } else {
      this.showCommandSuggestions = false;
    }

    // 隐藏附件菜单
    if (this.showAttachmentMenu) {
      this.showAttachmentMenu = false;
    }
  }

  /**
   * 获取输入框占位符
   */
  getInputPlaceholder(): string {
    if (this.chatType === ChatType.CHANNEL) return '向频道发送消息';
    if (this.chatType === ChatType.BOT) return '向机器人发送消息';
    return '输入消息...';
  }

  /**
   * 获取匹配的命令建议
   */
  public getCommandSuggestions(input: string): BotCommand[] {
    if (!input.startsWith('/')) return [];
    const query = input.substring(1).toLowerCase();
    return this.botCommands.filter(cmd =>
      cmd.command.toLowerCase().includes(query)
    );
  }

  /**
   * 选择命令
   */
  public selectCommand(command: BotCommand): void {
    this.inputText = '/' + command.command + ' ';
    this.showCommandSuggestions = false;
  }

  /**
   * 隐藏回复键盘
   */
  public hideReplyKeyboard(): void {
    this.showReplyKeyboard = false;
    this.replyKeyboard = null;
  }

  /**
   * 显示回复键盘（从消息中）
   */
  public showReplyKeyboardFromMessage(keyboard: ReplyKeyboardMarkup): void {
    this.replyKeyboard = keyboard;
    this.showReplyKeyboard = true;
  }

  /**
   * 显示消息上下文菜单
   */
  showMessageContextMenu(messageId: number): void {
    this.selectedMessageId = messageId;
    this.showContextMenu = true;
    // 自动隐藏菜单
    if (this.contextMenuTimer !== -1) clearTimeout(this.contextMenuTimer);
    this.contextMenuTimer = setTimeout(() => {
      this.showContextMenu = false;
      this.selectedMessageId = null;
      this.contextMenuTimer = -1;
    }, 3000);
  }

  /**
   * 复制消息文本
   */
  async copyMessageText(): Promise<void> {
    const msg = this.messageMap.get(this.selectedMessageId!);
    if (msg && msg.type === MessageType.TEXT) {
      const content = typeof msg.content === 'string' ? msg.content : (msg.content as MessageContent).text || '';
      if (content) {
        await promptAction.showToast({ message: '已复制', duration: 1000 });
      }
    }
    this.showContextMenu = false;
    this.selectedMessageId = null;
  }

  // ==================== 多选操作 ====================

  /**
   * 进入多选模式
   */
  enterMultiSelectMode(messageId: number): void {
    this.isMultiSelectMode = true;
    this.selectedMessageIds.clear();
    this.selectedMessageIds.add(messageId);
    this.showMultiSelectToolbar = true;
  }

  /**
   * 退出多选模式
   */
  exitMultiSelectMode(): void {
    this.isMultiSelectMode = false;
    this.selectedMessageIds.clear();
    this.showMultiSelectToolbar = false;
  }

  /**
   * 切换消息选中状态
   */
  toggleMessageSelection(messageId: number): void {
    if (this.selectedMessageIds.has(messageId)) {
      this.selectedMessageIds.delete(messageId);
    } else {
      this.selectedMessageIds.add(messageId);
    }
    // 如果没有选中任何消息，退出多选模式
    if (this.selectedMessageIds.size === 0) {
      this.exitMultiSelectMode();
    }
  }

  /**
   * 判断是否选中消息
   */
  isMessageSelected(messageId: number): boolean {
    return this.selectedMessageIds.has(messageId);
  }

  /**
   * 获取选中消息数量
   */
  getSelectedCount(): number {
    return this.selectedMessageIds.size;
  }

  /**
   * 删除选中的消息
   */
  async deleteSelectedMessages(): Promise<void> {
    const count = this.selectedMessageIds.size;
    if (count === 0) return;

    const result = await promptAction.showDialog({
      title: '删除消息',
      message: `确定要删除选中的 ${count} 条消息吗？`,
      buttons: [{ text: '取消', color: '#8E8E93' }, { text: '删除', color: '#FA2A2D' }]
    });

    if (result.index === 1) {
      await this.coreService.deleteMessages(this.chatId, Array.from(this.selectedMessageIds), true);
      this.exitMultiSelectMode();
    }
  }

  /**
   * 复制选中的消息（仅文本消息）
   */
  async copySelectedMessages(): Promise<void> {
    const count = this.selectedMessageIds.size;
    if (count === 0) return;

    // 收集所有文本消息内容
    const texts: string[] = [];
    for (const msgId of this.selectedMessageIds) {
      const msg = this.messageMap.get(msgId);
      if (msg && msg.type === MessageType.TEXT) {
        const text = typeof msg.content === 'string' ? msg.content : '';
        if (text) texts.push(text);
      }
    }

    if (texts.length > 0) {
      promptAction.showToast({ message: `已复制 ${texts.length} 条文本`, duration: 1500 });
    } else {
      promptAction.showToast({ message: '没有可复制的文本消息', duration: 1500 });
    }
  }

  /**
   * 转发选中的消息
   */
  public async forwardSelectedMessages(): Promise<void> {
    const count = this.selectedMessageIds.size;
    if (count === 0) return;

    promptAction.showToast({ message: `转发 ${count} 条消息`, duration: 1500 });
    // TODO: 实现实际转发逻辑，需要弹出聊天选择器
    this.exitMultiSelectMode();
  }

  /**
   * 滚动到指定消息
   */
  public scrollToMessage(messageId: number): void {
    // 由 UI 层实现滚动
    const data: ScrollToMessageData = { messageId };
    this.eventBus.emit('scrollToMessage', data);
  }

  // ==================== 文件下载 ====================

  /**
   * 获取文件下载进度
   */
  getFileDownloadProgress(fileId: number): FileDownloadState | undefined {
    return this.fileDownloadMap.get(fileId);
  }

  /**
   * 触发文件下载
   */
  async triggerFileDownload(fileId: number, priority: number = 1): Promise<void> {
    try {
      await this.coreService.downloadFile(fileId, priority, 0, 0, false);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `downloadFile failed: ${error}`);
    }
  }

  // ==================== 格式化工具 ====================

  /**
   * 格式化时间
   */
  formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    if (diffMins < 1) return '刚刚';
    if (diffMins < 60) return formatString('minutes_ago', diffMins.toString());
    if (date.toDateString() === now.toDateString())
      return date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });
    return date.toLocaleDateString('zh-CN', { month: '2-digit', day: '2-digit' });
  }

  /**
   * 格式化时长
   */
  formatDuration(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }

  /**
   * 格式化文件大小
   */
  formatFileSize(bytes: number): string {
    if (bytes < 1024) return `${bytes}B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)}KB`;
    if (bytes < 1024 * 1024 * 1024) return `${(bytes / (1024 * 1024)).toFixed(1)}MB`;
    return `${(bytes / (1024 * 1024 * 1024)).toFixed(1)}GB`;
  }

  /**
   * 获取群组事件显示文本
   */
  public getGroupEventText(message: Message): string {
    if (message.type !== MessageType.GROUP_EVENT || !message.groupEventType) {
      return message.content as string || '系统消息';
    }

    const data = message.groupEventData;
    const userName = data?.userName || '用户';
    const adminName = data?.adminName || '管理员';

    switch (message.groupEventType) {
      case GroupEventType.MEMBER_JOINED:
        return `${userName} 加入了群组`;
      case GroupEventType.MEMBER_LEFT:
        return `${userName} 退出了群组`;
      case GroupEventType.MEMBER_REMOVED:
        return `${userName} 被移除`;
      case GroupEventType.ADMIN_PROMOTED:
        return `${userName} 被设为管理员`;
      case GroupEventType.GROUP_CREATED:
        return `${userName} 创建了群组`;
      case GroupEventType.GROUP_UPGRADED:
        return '群组已升级为超级群组';
      case GroupEventType.GROUP_RENAMED:
        return `群组名称已更改为 "${data?.newTitle || ''}"`;
      case GroupEventType.GROUP_PHOTO_CHANGED:
        return '群组头像已更新';
      case GroupEventType.MESSAGE_PINNED:
        return `${adminName} 置顶了一条消息`;
      case GroupEventType.SLOW_MODE_ENABLED:
        return '慢速模式已开启';
      case GroupEventType.RESTRICTED_MODE_ENABLED:
        return '仅管理员可发送消息';
      case GroupEventType.MEMBER_RESTRICTED:
        return data?.isRestricted
          ? `${userName} 被禁言 ${data?.restrictedUntil ? '至 ' + new Date(data.restrictedUntil * 1000).toLocaleString() : ''}`
          : `${userName} 的禁言已解除`;
      default:
        return message.content as string || '系统消息';
    }
  }

  /**
   * 根据系统消息类型返回对应的 emoji 图标
   */
  public getSystemMessageIcon(type: SystemMessageType): string {
    switch (type) {
      // 成员相关
      case SystemMessageType.MEMBER_JOINED:
      case SystemMessageType.MEMBER_JOINED_BY_LINK:
        return '👋';
      case SystemMessageType.MEMBER_INVITED:
        return '✉️';
      case SystemMessageType.MEMBER_LEFT:
        return '👋';
      case SystemMessageType.MEMBER_REMOVED:
        return '🚫';
      case SystemMessageType.MEMBER_PROMOTED:
        return '👑';
      case SystemMessageType.MEMBER_DEMOTED:
        return '👤';
      case SystemMessageType.MEMBER_RESTRICTED:
        return '🔇';
      case SystemMessageType.MEMBER_UNRESTRICTED:
        return '🔊';
      case SystemMessageType.MEMBER_BANNED:
        return '🚷';

      // 聊天设置
      case SystemMessageType.CHAT_CREATED:
        return '🎉';
      case SystemMessageType.TITLE_CHANGED:
        return '✏️';
      case SystemMessageType.PHOTO_CHANGED:
        return '🖼️';
      case SystemMessageType.DESCRIPTION_CHANGED:
        return '📝';
      case SystemMessageType.SLOW_MODE_CHANGED:
        return '🐌';
      case SystemMessageType.SIGN_MESSAGES_CHANGED:
        return '🎭';
      case SystemMessageType.LINKED_CHAT_CHANGED:
        return '⬆️';

      // 消息操作
      case SystemMessageType.MESSAGE_EDITED:
        return '✏️';
      case SystemMessageType.MESSAGE_DELETED:
        return '🗑️';
      case SystemMessageType.MESSAGE_PINNED:
        return '📌';
      case SystemMessageType.MESSAGE_UNPINNED:
        return '📍';

      // 其他
      case SystemMessageType.POLL_CREATED:
        return '📊';
      case SystemMessageType.GAME_STARTED:
        return '🎮';
      case SystemMessageType.INVOICE_SENT:
        return '💰';
      case SystemMessageType.PAYMENT_SUCCESSFUL:
        return '✅';

      default:
        return 'ℹ️';
    }
  }

  /**
   * 获取消息状态图标
   */
  getMessageStatusIcon(message: Message): string {
    if (!message.isOutgoing) return '';
    switch (message.status) {
      case MessageStatus.SENDING: return '⏱';
      case MessageStatus.SENT: return '✓';
      case MessageStatus.DELIVERED: return '✓✓';
      case MessageStatus.READ: return '✓✓';
      case MessageStatus.FAILED: return '✗';
      default: return '';
    }
  }

  // ==================== 事件处理 ====================

  /**
   * 注册事件监听器
   */
  private registerEventListeners(): void {
    // 使用 CoreService 领域事件替代 TDLib 原始事件
    this.eventBus.on('core:messageReceived', this.handleCoreNewMessage);
    this.eventBus.on('core:messageSent', this.handleCoreMessageSent);
    this.eventBus.on('core:messageFailed', this.handleCoreMessageFailed);
    this.eventBus.on('core:messageEdited', this.handleCoreMessageEdited);
    this.eventBus.on('core:messageDeleted', this.handleCoreMessageDeleted);
    this.eventBus.on('core:chatAction', this.handleCoreChatAction);
    this.eventBus.on('core:fileDownloadProgress', this.handleCoreFileDownloadProgress);
    this.eventBus.on('core:connectionStateUpdated', this.handleCoreConnectionState);
  }

  /**
   * 注销事件监听器
   */
  private unregisterEventListeners(): void {
    this.eventBus.off('core:messageReceived', this.handleCoreNewMessage);
    this.eventBus.off('core:messageSent', this.handleCoreMessageSent);
    this.eventBus.off('core:messageFailed', this.handleCoreMessageFailed);
    this.eventBus.off('core:messageEdited', this.handleCoreMessageEdited);
    this.eventBus.off('core:messageDeleted', this.handleCoreMessageDeleted);
    this.eventBus.off('core:chatAction', this.handleCoreChatAction);
    this.eventBus.off('core:fileDownloadProgress', this.handleCoreFileDownloadProgress);
    this.eventBus.off('core:connectionStateUpdated', this.handleCoreConnectionState);
  }

  // ==================== CoreService 领域事件处理 ====================

  private handleCoreNewMessage = (data?: Object): void => {
    if (!data) return;
    const chatId = (data as Record<string, Object>)['chatId'] as number;
    const message = (data as Record<string, Object>)['message'] as Record<string, Object>;
    if (chatId !== this.chatId || !message) return;

    const msgId = message['id'] as number;

    // 检查消息是否已存在
    if (this.messageMap.has(msgId)) {
      hilog.info(DOMAIN, TAG, `Message ${msgId} already exists, skipping`);
      return;
    }

    // ⭐ 简化方案：直接同步转换消息并添加，无批处理延迟
    const newMsg = this.convertTdlibMessage(message);
    if (!newMsg) return;

    // ⭐ 如果是自己发送的消息，尝试替换临时消息
    if (newMsg.isOutgoing) {
      this.handleOutgoingNewMessage(newMsg);
      return;
    }

    // ⭐ 非自己发送的消息：直接添加到 DataSource（同步，无延迟）
    this.appendMessage(newMsg);
    this.notifyScrollToBottom();

    // ⭐ 标记已读延后处理（fire-and-forget）
    if (!newMsg.isOutgoing) {
      setTimeout(() => {
        this.coreService.viewMessages(this.chatId, [newMsg.id], null, true).catch(() => {});
      }, 100);
    }
  };

  /**
   * ⭐ 处理自己发送的消息：尝试替换临时消息
   */
  private handleOutgoingNewMessage(newMsg: Message): void {
    // 查找匹配的临时消息
    let foundTempMessage = false;
    const entries = this.messageMap.entries();
    let entry = entries.next();

    while (!entry.done) {
      const existingId = entry.value[0];
      const existingMsg = entry.value[1];

      if (existingMsg.isOutgoing && existingMsg.status === MessageStatus.SENDING) {
        // 检查内容是否匹配
        const existingText = typeof existingMsg.content === 'string'
          ? existingMsg.content
          : (existingMsg.content as MessageContent)?.text || '';
        const newText = typeof newMsg.content === 'string'
          ? newMsg.content
          : (newMsg.content as MessageContent)?.text || '';

        if (existingText === newText) {
          hilog.info(DOMAIN, TAG, `Found matching temp message ${existingId}, replacing with ${newMsg.id}`);
          this.replaceMessage(existingId, newMsg);
          foundTempMessage = true;
          break;
        }
      }
      entry = entries.next();
    }

    // 如果没有找到匹配的临时消息，直接追加
    if (!foundTempMessage) {
      hilog.info(DOMAIN, TAG, `No matching temp message found for outgoing message ${newMsg.id}, appending directly`);
      this.appendMessage(newMsg);
      this.notifyScrollToBottom();
    }
  }

  /**
   * 批量处理待处理的新消息
   */
  private async flushPendingMessages(): Promise<void> {
    if (this.pendingNewMessages.length === 0) return;

    // 批量添加到 DataSource
    const messagesToProcess = [...this.pendingNewMessages];
    this.pendingNewMessages = [];

    // 异步分片处理消息，避免阻塞 UI
    await this.processNewMessagesBatch(messagesToProcess);
  }

  /**
   * 批量处理新消息（异步分片处理，避免阻塞UI）
   * 
   * ⭐ 关键优化：使用分片处理避免一次性转换大量消息阻塞 UI
   */
  private async processNewMessagesBatch(messages: Message[]): Promise<void> {
    if (messages.length === 0) return;

    const CHUNK_SIZE = 5; // 每帧处理 5 条消息
    const allEntities: MessageEntity[] = [];
    const messageIdsToMarkAsRead: number[] = [];

    // 分片处理消息转换
    for (let i = 0; i < messages.length; i += CHUNK_SIZE) {
      const chunk = messages.slice(i, i + CHUNK_SIZE);
      
      // 处理当前分片
      for (const msg of chunk) {
        const entity = this.convertToEntity(msg);
        if (entity) {
          allEntities.push(entity);
          this.messageMap.set(msg.id, msg);

          // 维护文件ID到消息ID的映射
          const fileId = msg.media?.tdlibFileId || msg.file?.id;
          if (fileId) {
            this.fileIdToMessageIdMap.set(fileId, msg.id);
          }

          // 收集需要标记为已读的消息ID
          if (!msg.isOutgoing) {
            messageIdsToMarkAsRead.push(msg.id);
          }
        }
      }
      
      // ⭐ 让出主线程，避免阻塞 UI
      if (i + CHUNK_SIZE < messages.length) {
        await new Promise<void>(resolve => setTimeout(resolve, 0));
      }
    }

    // 批量添加到 DataSource（同步，无延迟）
    if (allEntities.length > 0) {
      this.messageDataSource.appendMessages(allEntities);
      this.notifyScrollToBottom();
      hilog.info(DOMAIN, TAG, `Batch processed ${allEntities.length} new messages`);
    }

    // 批量标记已读（fire-and-forget）
    if (messageIdsToMarkAsRead.length > 0) {
      this.coreService.viewMessages(this.chatId, messageIdsToMarkAsRead, null, true).catch((error: Error) => {
        hilog.warn(DOMAIN, TAG, `Failed to mark messages as read: ${error.message}`);
      });
    }
  }

  private handleCoreMessageSent = (data?: Object): void => {
    if (!data) return;
    const chatId = (data as Record<string, Object>)['chatId'] as number;
    const messageId = (data as Record<string, Object>)['messageId'] as number;
    const message = (data as Record<string, Object>)['message'] as Record<string, Object>;

    if (chatId !== this.chatId || !message) return;
    if (this.messageMap.has(messageId)) return;

    const newMsg = this.convertTdlibMessage(message);
    if (newMsg) {
      this.appendMessage(newMsg);
      this.notifyScrollToBottom();
    }
  };

  private handleCoreMessageFailed = (data?: Object): void => {
    if (!data) return;
    const chatId = (data as Record<string, Object>)['chatId'] as number;
    const messageId = (data as Record<string, Object>)['messageId'] as number;
    
    if (chatId !== this.chatId) return;
    
    const msg = this.messageMap.get(messageId);
    if (msg) {
      msg.status = MessageStatus.FAILED;
      this.updateMessage(msg);
    }
  };

  private handleCoreMessageEdited = (data?: Object): void => {
    if (!data) return;
    const chatId = (data as Record<string, Object>)['chatId'] as number;
    const messageId = (data as Record<string, Object>)['messageId'] as number;
    const message = (data as Record<string, Object>)['message'] as Message;
    
    if (chatId !== this.chatId || !message) return;
    
    this.replaceMessage(messageId, message);
  };

  private handleCoreMessageDeleted = (data?: Object): void => {
    if (!data) return;
    const chatId = (data as Record<string, Object>)['chatId'] as number;
    const messageIds = (data as Record<string, Object>)['messageIds'] as number[];

    if (chatId !== this.chatId || !messageIds || messageIds.length === 0) return;

    // 从 messageMap 中删除消息
    for (const msgId of messageIds) {
      this.messageMap.delete(msgId);
    }

    // 从 MessageDataSource 中删除消息
    this.messageDataSource.deleteMessages(messageIds);
  };

  private handleCoreChatAction = (data?: Object): void => {
    if (!data) return;
    const chatId = (data as Record<string, Object>)['chatId'] as number;
    const actionType = (data as Record<string, Object>)['actionType'] as string;
    
    if (chatId !== this.chatId) return;
    
    if (this.typingDebounceTimer !== -1) clearTimeout(this.typingDebounceTimer);
    this.showTypingIndicator = true;
    this.typingText = actionType === 'chatActionTyping' ? '正在输入...' : '操作中';
    this.typingDebounceTimer = setTimeout(() => {
      this.showTypingIndicator = false;
      this.typingText = '';
      this.typingDebounceTimer = -1;
    }, TYPING_DEBOUNCE_DELAY);
  };

  // 文件ID到消息ID的映射，用于快速查找
  private fileIdToMessageIdMap: Map<number, number> = new Map();
  // 文件下载进度防抖计时器
  private fileProgressDebounceTimer: number = -1;
  // 待处理的文件进度更新
  private pendingFileProgressUpdates: Map<number, FileProgressUpdate> = new Map();

  // ==================== 消息批处理机制 ====================
  // 待处理的新消息队列（用于批量处理）
  private pendingNewMessages: Message[] = [];
  // 消息批处理防抖计时器
  private messageBatchDebounceTimer: number = -1;
  // 消息批处理间隔（毫秒）
  private readonly MESSAGE_BATCH_INTERVAL = 50;
  // 最大批量处理消息数
  private readonly MAX_BATCH_SIZE = 10;

  private handleCoreFileDownloadProgress = (data?: Object): void => {
    if (!data) return;
    const fileId = (data as Record<string, Object>)['fileId'] as number;
    const progress = (data as Record<string, Object>)['progress'] as number;
    const isCompleted = (data as Record<string, Object>)['isCompleted'] as boolean;
    const localPath = (data as Record<string, Object>)['localPath'] as string | undefined;
    const isDownloading = (data as Record<string, Object>)['isDownloading'] as boolean;
    
    if (!fileId) return;
    
    // 缓存进度信息
    this.fileDownloadMap.set(fileId, { progress, isDownloading, localPath });
    
    // 收集待处理的更新
    this.pendingFileProgressUpdates.set(fileId, { progress, isCompleted, localPath, isDownloading });
    
    // 防抖处理：延迟批量更新UI，避免频繁重绘
    if (this.fileProgressDebounceTimer !== -1) {
      clearTimeout(this.fileProgressDebounceTimer);
    }
    
    this.fileProgressDebounceTimer = setTimeout(() => {
      this.processPendingFileProgressUpdates();
      this.fileProgressDebounceTimer = -1;
    }, 100); // 100ms 防抖间隔
  };
  
  /**
   * 批量处理文件进度更新
   */
  private processPendingFileProgressUpdates(): void {
    if (this.pendingFileProgressUpdates.size === 0) return;
    
    // 批量处理所有待更新的文件进度
    const updates = Array.from(this.pendingFileProgressUpdates.entries());
    for (let i = 0; i < updates.length; i++) {
      const fileId = updates[i][0];
      const update = updates[i][1];
      const messageId = this.fileIdToMessageIdMap.get(fileId);
      if (messageId) {
        const msg = this.messageMap.get(messageId);
        if (msg) {
          if (update.isCompleted && update.localPath) {
            if (msg.file) msg.file.path = update.localPath;
            if (msg.media) msg.media.localPath = update.localPath;
            msg.downloadProgress = 100;
            msg.isDownloading = false;
          } else if (update.isDownloading) {
            msg.downloadProgress = update.progress;
            msg.isDownloading = true;
          }
          // 直接更新 DataSource，避免重复查找
          this.messageDataSource.updateMessage(msg);
        }
      }
    }
    
    // 清空待处理队列
    this.pendingFileProgressUpdates.clear();
  }

  private handleCoreConnectionState = (data?: Object): void => {
    if (!data) return;
    const state = (data as Record<string, Object>)['state'] as string;
    if (state === 'connectionStateReady') this.connectionState = 'connected';
    else if (state === 'connectionStateConnecting' || state === 'connectionStateUpdating') this.connectionState = 'connecting';
    else this.connectionState = 'disconnected';
  };

  // ==================== 消息列表操作 ====================

  private appendMessage(msg: Message): void {
    const entity = this.convertToEntity(msg);
    if (entity) {
      // ⭐ 简化方案：使用同步方法直接添加，无延迟
      this.messageDataSource.push(entity);
    }
    this.messageMap.set(msg.id, msg);
    
    // 维护文件ID到消息ID的映射
    const fileId = msg.media?.tdlibFileId || msg.file?.id;
    if (fileId) {
      this.fileIdToMessageIdMap.set(fileId, msg.id);
    }
  }

  private replaceMessage(oldId: number, newMsg: Message): void {
    this.messageDataSource.replaceMessage(oldId, newMsg);
    this.messageMap.delete(oldId);
    this.messageMap.set(newMsg.id, newMsg);
    
    // 更新文件ID映射
    const fileId = newMsg.media?.tdlibFileId || newMsg.file?.id;
    if (fileId) {
      this.fileIdToMessageIdMap.set(fileId, newMsg.id);
    }
  }

  private updateMessage(updatedMsg: Message): void {
    this.messageDataSource.updateMessage(updatedMsg);
    this.messageMap.set(updatedMsg.id, updatedMsg);
    
    // 更新文件ID映射
    const fileId = updatedMsg.media?.tdlibFileId || updatedMsg.file?.id;
    if (fileId) {
      this.fileIdToMessageIdMap.set(fileId, updatedMsg.id);
    }
  }

  private notifyScrollToBottom(): void {
    this.eventBus.emit('scrollToBottom', new Object());
  }

  // ==================== TDLib 消息转换 ====================

  private convertTdlibMessage(msgRecord: Record<string, Object>): Message | null {
    try {
      const id = msgRecord['id'] as number;
      const chatId = msgRecord['chat_id'] as number;
      const isOutgoing = msgRecord['is_outgoing'] as boolean || false;
      const date = msgRecord['date'] as number || 0;
      const timestamp = date * 1000;
      const contentObj = msgRecord['content'] as Record<string, Object>;
      if (!contentObj) return null;
      const contentType = (contentObj['@type'] as string) || (contentObj['_'] as string);

      let messageType = MessageType.TEXT;
      let messageContent: string | object = '';
      let media: MediaInfo | undefined;
      let file: FileInfo | undefined;
      let duration = 0;
      let entities: TextEntity[] = [];
      
      // 解析回复消息
      const replyToRaw = msgRecord['reply_to'] as Record<string, Object> | undefined;
      let replyToMessageId: number | undefined = undefined;
      if (replyToRaw) {
        const replyMsgId = replyToRaw['message_id'] as number | undefined;
        if (replyMsgId && replyMsgId > 0) {
          replyToMessageId = replyMsgId;
        }
      }

      // 解析互动信息
      let views: number | undefined = undefined;
      const interactionInfo = msgRecord['interaction_info'] as Record<string, Object>;
      if (interactionInfo) {
        views = interactionInfo['view_count'] as number;
      }

      // 解析转发信息
      let forwardInfo: ForwardInfo | undefined = undefined;
      const forwardInfoRaw = msgRecord['forward_info'] as Record<string, Object>;
      if (forwardInfoRaw) {
        const forwardOrigin = forwardInfoRaw['origin'] as Record<string, Object>;
        const forwardType = (forwardOrigin?.['@type'] as string) || (forwardOrigin?.['_'] as string) || '';
        const isChannelPostForward = forwardType === 'messageOriginChannel';
        
        let forwardSenderId = 0;
        let forwardSenderName = '';
        let forwardChatId: number | undefined = undefined;
        let forwardMessageId: number | undefined = undefined;
        let viewCount: number = 0;
        let replyCount: number = 0;
        
        if (isChannelPostForward) {
          forwardChatId = forwardOrigin?.['chat_id'] as number;
          forwardMessageId = forwardOrigin?.['message_id'] as number;
          const interactionInfo = msgRecord['interaction_info'] as Record<string, Object>;
          if (interactionInfo) {
            viewCount = (interactionInfo['view_count'] as number) || 0;
            replyCount = (interactionInfo['reply_count'] as number) || 0;
          }
          if (forwardChatId) {
            const chat = this.coreService.getChat(forwardChatId);
            forwardSenderName = chat?.title || '频道';
          }
        } else {
          forwardSenderId = (forwardOrigin?.['sender_user_id'] as number) || 0;
          forwardSenderName = forwardOrigin?.['sender_name'] as string || '';
          forwardChatId = forwardInfoRaw['chat_id'] as number;
          forwardMessageId = forwardInfoRaw['message_id'] as number;
        }
        
        forwardInfo = {
          senderName: forwardSenderName,
          senderId: forwardSenderId,
          date: forwardInfoRaw['date'] as number || 0,
          originalChatId: forwardChatId,
          originalMessageId: forwardMessageId,
          isChannelPost: isChannelPostForward,
          viewCount: viewCount,
          replyCount: replyCount
        };
      }

      // 解析发送者信息
      const senderId = this.extractSenderId(msgRecord['sender_id']);
      const senderName = this.extractSenderName(msgRecord['sender_id']);
      const senderAvatar = this.extractSenderAvatar(msgRecord['sender_id']);

      // 根据内容类型解析
      switch (contentType) {
        case 'messageText':
          messageType = MessageType.TEXT;
          const textObj = contentObj['text'] as Record<string, Object>;
          messageContent = textObj?.['text'] as string || '';
          entities = this.parseTextEntities(textObj);
          break;
        case 'messagePhoto':
          messageType = MessageType.PHOTO;
          const photo = contentObj['photo'] as Record<string, Object>;
          const hasPhotoSpoiler = contentObj['has_spoiler'] as boolean || false;
          if (photo) {
            const sizes = photo['sizes'] as Array<Record<string, Object>>;
            if (sizes?.length) {
              const bestSize = sizes[Math.min(1, sizes.length - 1)];
              const photoFile = bestSize['photo'] as Record<string, Object>;
              if (photoFile) {
                const fileId = photoFile['id'] as number;
                const local = photoFile['local'] as Record<string, Object>;
                media = {
                  tdlibFileId: fileId,
                  thumbnail: local?.['path'] as string,
                  hasSpoiler: hasPhotoSpoiler
                } as MediaInfo;
                file = { id: fileId, path: local?.['path'] as string } as FileInfo;
              }
            }
          }
          const caption = contentObj['caption'] as Record<string, Object>;
          messageContent = { caption: caption?.['text'] as string || '', entities: this.parseTextEntities(caption) } as MessageContent;
          break;
        case 'messageVideo':
          messageType = MessageType.VIDEO;
          const video = contentObj['video'] as Record<string, Object>;
          const hasVideoSpoiler = contentObj['has_spoiler'] as boolean || false;
          if (video) {
            duration = video['duration'] as number || 0;
            const videoFile = video['video'] as Record<string, Object>;
            if (videoFile) {
              const fileId = videoFile['id'] as number;
              const local = videoFile['local'] as Record<string, Object>;
              const thumbnailPath = this.getVideoThumbnailPath(video);
              media = {
                tdlibFileId: fileId,
                thumbnail: thumbnailPath,
                duration,
                hasSpoiler: hasVideoSpoiler
              } as MediaInfo;
              file = { id: fileId, path: local?.['path'] as string } as FileInfo;
            }
          }
          const videoCaption = contentObj['caption'] as Record<string, Object>;
          messageContent = { caption: videoCaption?.['text'] as string || '', entities: this.parseTextEntities(videoCaption) } as MessageContent;
          break;
        case 'messageDocument':
          messageType = MessageType.DOCUMENT;
          const doc = contentObj['document'] as Record<string, Object>;
          if (doc) {
            const docFile = doc['document'] as Record<string, Object>;
            if (docFile) {
              const fileId = docFile['id'] as number;
              const local = docFile['local'] as Record<string, Object>;
              media = { tdlibFileId: fileId, fileName: doc['file_name'] as string, size: docFile['size'] as number } as MediaInfo;
              file = { id: fileId, path: local?.['path'] as string } as FileInfo;
            }
          }
          break;
        case 'messageVoiceNote':
          messageType = MessageType.VOICE_NOTE;
          const voice = contentObj['voice_note'] as Record<string, Object>;
          if (voice) {
            duration = voice['duration'] as number || 0;
            const voiceFile = voice['voice'] as Record<string, Object>;
            if (voiceFile) {
              const fileId = voiceFile['id'] as number;
              const local = voiceFile['local'] as Record<string, Object>;
              media = { tdlibFileId: fileId, duration } as MediaInfo;
              file = { id: fileId, path: local?.['path'] as string } as FileInfo;
            }
          }
          break;
        case 'messageSticker':
          messageType = MessageType.STICKER;
          const sticker = contentObj['sticker'] as Record<string, Object>;
          if (sticker) {
            const thumb = sticker['thumbnail'] as Record<string, Object>;
            if (thumb) {
              const thumbFile = thumb['file'] as Record<string, Object>;
              if (thumbFile) {
                const fileId = thumbFile['id'] as number;
                const local = thumbFile['local'] as Record<string, Object>;
                media = { tdlibFileId: fileId, thumbnail: local?.['path'] as string, width: sticker['width'] as number, height: sticker['height'] as number } as MediaInfo;
              }
            }
          }
          break;
        case 'messageAnimation':
          messageType = MessageType.ANIMATION;
          const anim = contentObj['animation'] as Record<string, Object>;
          if (anim) {
            duration = anim['duration'] as number || 0;
            const animFile = anim['animation'] as Record<string, Object>;
            if (animFile) {
              const fileId = animFile['id'] as number;
              const local = animFile['local'] as Record<string, Object>;
              media = { tdlibFileId: fileId, thumbnail: this.getAnimationThumbnail(anim), duration } as MediaInfo;
              file = { id: fileId, path: local?.['path'] as string } as FileInfo;
            }
          }
          break;
        case 'messageLocation':
          messageType = MessageType.LOCATION;
          const loc = contentObj['location'] as Record<string, Object>;
          messageContent = {
            latitude: loc['latitude'] as number,
            longitude: loc['longitude'] as number,
            address: loc['address'] as string || ''
          } as MessageContent;
          break;
        case 'messageContact':
          messageType = MessageType.CONTACT;
          const contact = contentObj['contact'] as Record<string, Object>;
          messageContent = {
            firstName: contact['first_name'] as string || '',
            lastName: contact['last_name'] as string || '',
            phoneNumber: contact['phone_number'] as string || ''
          } as MessageContent;
          break;
        case 'messagePoll':
          messageType = MessageType.POLL;
          const poll = contentObj['poll'] as Record<string, Object>;
          messageContent = {
            question: poll['question'] as string,
            options: (poll['options'] as Array<Record<string, Object>>)?.map((opt): PollOption => ({
              text: opt['text'] as string,
              voterCount: opt['voter_count'] as number,
              isChosen: opt['is_chosen'] as boolean
            })) || []
          } as MessageContent;
          break;
        case 'messageDice':
          messageType = MessageType.DICE;
          const diceObj = contentObj['dice'] as Record<string, Object>;
          messageContent = {
            text: (diceObj?.['emoji'] as string) || '🎲',
            description: String(diceObj?.['value'] as number || 1)
          } as MessageContent;
          break;
        default:
          messageType = MessageType.TEXT;
          messageContent = '不支持的消息类型';
      }

      const status = isOutgoing ? MessageStatus.SENT : MessageStatus.READ;

      const msg: Message = {
        id,
        chatId,
        senderId,
        senderName,
        senderAvatar,
        type: messageType,
        content: messageContent,
        timestamp,
        status,
        isOutgoing,
        media,
        file,
        duration,
        replyToMessageId,
        forwardInfo,
        isEdited: msgRecord['edit_date'] !== undefined,
        downloadProgress: 0,
        isDownloading: false,
        reactions: [],
        isPinned: false,
        canBeEdited: false,
        canBeDeleted: false,
        hasProtectedContent: false,
        views
      };
      return msg;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `convertTdlibMessage error: ${error}`);
      return null;
    }
  }

  private parseTextEntities(formattedObj?: Record<string, Object>): TextEntity[] {
    if (!formattedObj) return [];
    const entities = formattedObj['entities'] as Array<Record<string, Object>> || [];
    return entities.map((e): TextEntity => ({
      offset: e['offset'] as number,
      length: e['length'] as number,
      type: e['_'] as string,
      url: e['url'] as string,
      userId: e['user_id'] as number
    }));
  }

  private extractSenderId(senderObj: Object | undefined): number {
    if (!senderObj) return 0;
    const record = senderObj as Record<string, Object>;
    return (record['user_id'] as number) || (record['chat_id'] as number) || 0;
  }

  private extractSenderName(senderObj: Object | undefined): string {
    if (!senderObj) return '';
    const record = senderObj as Record<string, Object>;
    const senderType = (record['@type'] as string) || (record['_'] as string);
    
    if (senderType === 'messageSenderUser') {
      const userId = record['user_id'] as number;
      const cachedUser = this.coreService.getCachedUserInfo(userId);
      if (cachedUser && cachedUser.name) {
        return cachedUser.name;
      }
    } else if (senderType === 'messageSenderChat') {
      const chatId = record['chat_id'] as number;
      const chat = this.coreService.getChat(chatId);
      if (chat && chat.title) {
        return chat.title;
      }
    }
    return '';
  }

  private extractSenderAvatar(senderObj: Object | undefined): string {
    if (!senderObj) return '';
    const record = senderObj as Record<string, Object>;
    const senderType = (record['@type'] as string) || (record['_'] as string);
    
    if (senderType === 'messageSenderUser') {
      const userId = record['user_id'] as number;
      const cachedUser = this.coreService.getCachedUserInfo(userId);
      if (cachedUser && cachedUser.avatar) {
        return cachedUser.avatar;
      }
    }
    return '';
  }

  private getVideoThumbnailPath(video: Record<string, Object>): string | undefined {
    const thumbnail = video['thumbnail'] as Record<string, Object>;
    if (!thumbnail) return undefined;
    const local = thumbnail['local'] as Record<string, Object>;
    return local?.['path'] as string;
  }

  private getAnimationThumbnail(anim: Record<string, Object>): string | undefined {
    const thumbnail = anim['thumbnail'] as Record<string, Object>;
    if (!thumbnail) return undefined;
    const local = thumbnail['local'] as Record<string, Object>;
    return local?.['path'] as string;
  }

  /**
   * 发送回调查询（用于内联键盘按钮）
   * @param messageId 消息ID
   * @param callbackData 回调数据
   */
  async sendCallbackQuery(messageId: number, callbackData: string): Promise<void> {
    try {
      const tdLibApi = TdApiFactory.getInstance().createDefault();
      await tdLibApi.getCallbackQueryAnswer(this.chatId, messageId, { _: 'callbackQueryPayloadData', data: callbackData });
      hilog.info(DOMAIN, TAG, `Callback query sent for message ${messageId}`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to send callback query: ${error}`);
      promptAction.showToast({ message: '操作失败，请重试', duration: 1500 });
    }
  }
}

export default ChatPageViewModelV2;
