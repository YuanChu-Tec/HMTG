/**
 * 聊天服务 - 唯一数据源
 * 职责：
 * - 与 TDLib API 通信
 * - 维护内存中的 chatList 和 messagesMap 作为唯一 truth
 * - 通过 Repository 协调持久化
 * - 发布业务事件（chatListChanged, messageReceived 等）
 * - 处理用户动作（发送消息、标记已读等）
 */
import { common } from '@kit.AbilityKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { Message, Chat, MessageType, MessageStatus, ChatType, DraftMessage, UserStatus, MessageContent, Contact, ContactGroup, ContactListItemData, ContactSearchResult, ContactStats, OnlineStatus, SyncStatus, PhoneNumber, FileInfo, LocationInfo, ContactInfo, PollInfo, PollOption, ChatMemberStatus, ChatPermissions, Usernames } from '../../models/TDLibData';
import { AppLogger } from '../../utils/log/LogService';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { TdApiFactory } from '../api/factory/TdApiFactory';
import { TDLibApi } from '../api/TDLibApi';
import type { File, Messages, inputMessageText$Input as inputMessageText, inputMessagePhoto$Input as inputMessagePhoto, formattedText, inputFileLocal$Input as inputFileLocal, fileTypePhoto, inputThumbnail$Input as inputThumbnail, InputFile$Input as InputFile, inputPhoto$Input as inputPhoto, MessageSelfDestructType, messageSelfDestructTypeImmediately, chatListMain$Input, Chats, ChatList, Ok, User, importedContact$Input, chatNotificationSettings$Input, callProtocol, messageStory } from '../api/factory/tdlib-types';
import { EventBus } from '../../utils/event/EventBus';
import { FileDownloadService } from './FileDownloadService';
import { FileType, DownloadPriority, UPDATE_MASK_MESSAGE_SENT, UPDATE_MASK_MESSAGE_FAILED, UPDATE_MASK_MESSAGE_EDITED, UPDATE_MASK_MESSAGE_DELETED, UPDATE_MASK_MESSAGE_STATUS, UPDATE_MASK_CHAT_ACTION, UPDATE_MASK_FILE_PROGRESS, UPDATE_MASK_CONNECTION, UPDATE_MASK_USER_AVATAR, UPDATE_MASK_NEW_MESSAGE, UPDATE_MASK_CHAT_LIST } from '../../models/TDLibData';
import { CacheService } from './CacheService'; // 缓存服务
import { CacheStorage, ChatEntity, MessageEntity } from '@storage/cache'; // ⭐ storage_cache模块

const eventBus = EventBus.getInstance();

// ⭐ Nagram 参考：批量更新 flush 延迟（毫秒）
// 与 Nagram 的 processUpdateArray 批处理窗口一致
const FLUSH_DELAY_MS = 50;

/**
 * UserInfo - 用户信息接口
 */
interface UserInfo {
  name: string;
  avatar: string;
  isBot?: boolean; // ⭐ 是否为机器人
  isPremium?: boolean; // ⭐ 是否为Premium用户
}

/**
 * CoreServiceReadyEvent - 聊天服务就绪事件
 */
interface CoreServiceReadyEvent {
  ready: boolean;
}

/**
 * ChatListChangedEvent - 聊天列表变更事件
 */
interface ChatListChangedEvent {
  chats: Chat[];
}

/**
 * ChatListMain - TDLib chatListMain 类型
 */
interface ChatListMain {
  _: 'chatListMain';
}

/**
 * ⭐ 消息处理操作类型 - Nagram 风格的消息队列
 */
class MessageQueueTask {
  type: 'load' | 'append' | 'delete' | 'replace';
  chatId: number;
  // 回调在队列执行完毕后被调用
  execute: () => Promise<void> | void;
  resolve?: () => void;

  constructor(type: string, chatId: number, execute: () => Promise<void> | void) {
    this.type = type as 'load' | 'append' | 'delete' | 'replace';
    this.chatId = chatId;
    this.execute = execute;
  }
}

export class CoreService {
  private static instance: CoreService;
  private chatList: Chat[] = [];
  private messagesMap: Map<number, Message[]> = new Map();
  private tdLibApi: TDLibApi;
  private userCache: Map<number, UserInfo> = new Map();
  private isInitialized: boolean = false;
  private isLoadingChats: boolean = false;
  private fileDownloadService?: FileDownloadService;
  private cacheService: CacheService;
  private cacheStorage?: CacheStorage;

  // ==================== 消息处理队列（Nagram 风格） ====================
  private messageQueue: MessageQueueTask[] = [];
  private isProcessingQueue: boolean = false;
  
  // ⭐ Nagram 参考：批量更新累积器 (processUpdateArray 风格)
  // 累积更新事件位掩码，批量刷新 UI，避免逐条通知造成多次重绘
  private pendingUpdateMask: number = 0;
  private batchFlushTimer: number = -1;
  
  // ==================== 用户发起的删除跟踪 ====================
  // Nagram 参考：区分用户操作 vs TDLib 内部清理
  private userInitiatedDeletions: Set<string> = new Set(); // key = `${chatId}_${msgId}`

  // ==================== 已处理删除去重 ====================
  private processedDeletions: Set<string> = new Set();
  // ⭐ 已删除消息 ID 集合（用于过滤 TDLib 已删除消息）
  private deletedMessageIds: Set<number> = new Set();
  
  // ==================== 联系人管理 ====================
  private contacts: Map<number, Contact> = new Map();
  private contactGroups: Map<number, ContactGroup> = new Map();
  private contactsInitialized: boolean = false;
  
  // ==================== 防抖刷新管理 ====================
  private chatUpdateDebounceTimers: Map<number, number> = new Map();
  private readonly CHAT_UPDATE_DEBOUNCE_MS = 50;

  // ==================== 认证状态管理 ====================
  private currentAuthState: string = 'authorizationStateWaitTdlibParameters';
  private isAuthReady: boolean = false;
  private pendingAuthCallbacks: Array<() => void> = [];

  private constructor(context?: common.Context) {
    const apiFactory = TdApiFactory.getInstance();
    this.tdLibApi = apiFactory.createDefault();
    this.cacheService = CacheService.getInstance(); // 初始化缓存服务
    
    if (context) {
      this.cacheService.initialize(context).catch((e: Error) => {
        hilog.error(0x0001, 'CoreService', `CacheService init failed: ${JSON.stringify(e)}`);
      });
      // ⭐ 获取 CacheStorage 实例
      this.cacheStorage = CacheStorage.getInstance(context as common.UIAbilityContext);
    }
    
    this.initDatabaseAndCache(); // 先加载本地缓存
    this.setupInitialization();   // 等待 TDLib 授权后同步网络
    this.registerEventListeners();
  }

  public static getInstance(context?: common.Context): CoreService {
    if (!CoreService.instance) {
      CoreService.instance = new CoreService(context);
    }
    return CoreService.instance;
  }

  // ==================== 消息处理队列（Nagram 风格：processLoadedMessages 顺序处理） ====================

  /**
   * ⭐ Nagram 参考：将消息操作加入队列，确保顺序处理
   * 所有消息的 append/delete/replace 操作都通过此方法排队
   * 避免并发操作导致的时序竞争
   */
  enqueueMessageTask(task: MessageQueueTask): Promise<void> {
    return new Promise<void>((resolve) => {
      task.resolve = resolve;
      this.messageQueue.push(task);
      if (!this.isProcessingQueue) {
        this.processQueue();
      }
    });
  }

  private async processQueue(): Promise<void> {
    if (this.isProcessingQueue || this.messageQueue.length === 0) return;
    this.isProcessingQueue = true;

    while (this.messageQueue.length > 0) {
      const task = this.messageQueue.shift();
      if (!task) continue;
      try {
        await task.execute();
      } catch (error) {
        hilog.error(0x0001, 'CoreService',
          `❌ MessageQueue task ${task.type} failed for chat ${task.chatId}: ${JSON.stringify(error)}`);
      }
      if (task.resolve) {
        task.resolve();
      }
    }
    this.isProcessingQueue = false;
  }

  // ==================== 初始化 ====================
  private async initDatabaseAndCache(): Promise<void> {
    try {
      // ⭐ 使用 CacheStorage 加载聊天列表
      if (this.cacheStorage) {
        const chatEntities = await this.cacheStorage.getAllChats();
        if (chatEntities.length > 0) {
          // 将 ChatEntity 转换为 Chat
          const cachedChats = chatEntities.map(e => this.convertEntityToChat(e));
          this.chatList = cachedChats;
          this.publishChatListChanged();
          hilog.info(0x0001, 'CoreService', `Loaded ${cachedChats.length} chats from CacheStorage`);
        }
      }
    } catch (error) {
      hilog.warn(0x0001, 'CoreService', `Load from CacheStorage failed: ${JSON.stringify(error)}`);
    }
  }

  private setupInitialization(): void {
    // 优化时序：如果 TDLib 已经就绪，立即执行；否则注册回调
    if (this.isAuthReady) {
      hilog.info(0x0001, 'CoreService', '✅ TDLib already ready, initializing chat list immediately');
      this.initializeChatList();
    } else {
      hilog.info(0x0001, 'CoreService', '⏳ Waiting for TDLib authorization...');
      this.executeWhenReady(() => {
        hilog.info(0x0001, 'CoreService', '🚀 TDLib authorized, starting chat initialization');
        this.initializeChatList();
      }, 'CoreService initialization');
    }
  }

  private async initializeChatList(): Promise<void> {
    if (this.isLoadingChats) {
      hilog.warn(0x0001, 'CoreService', '⚠️ Chat list initialization already in progress');
      return;
    }

    this.isLoadingChats = true;
    try {
      await this.loadInitialChats();
      this.isInitialized = true;
      // ⭐ 异步持久化到 CacheStorage
      if (this.cacheStorage) {
        for (const chat of this.chatList) {
          const entity = this.convertChatToEntity(chat);
          this.cacheStorage.saveChat(entity).catch((e: Error) =>
            hilog.error(0x0001, 'CoreService', `Save chat to CacheStorage failed: ${e}`)
          );
        }
      }
      this.publishChatListChanged();
      const readyEvent: CoreServiceReadyEvent = { ready: true };
      eventBus.emit('CoreServiceReady', readyEvent);
      hilog.info(0x0001, 'CoreService', '✅ Chat service fully initialized');
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `Initialize failed: ${JSON.stringify(error)}`);
      this.isInitialized = true; // 即使失败也标记为已处理，避免死循环
    } finally {
      this.isLoadingChats = false;
    }
  }

  // ==================== 事件监听 ====================
  /**
   * 注意：所有 updateXxx 事件的订阅已迁移到 UpdateService
   * UpdateService 接收原始 TDLib 更新，解析后调用 CoreService 的公共方法
   * 依赖方向：UpdateService -> CoreService
   */
  private registerEventListeners(): void {
    // 事件订阅已移至 UpdateService，此处保留方法用于未来可能的内部事件订阅
    hilog.info(0x0001, 'CoreService', '✅ CoreService initialized (event listeners moved to UpdateService)');
  }

  /**
   * 处理新消息（由 UpdateService 调用）
   * @param messageObj 消息对象
   */
  public async onNewMessage(messageObj: Record<string, Object>): Promise<void> {
    if (!messageObj) return;
    const chatId = messageObj['chat_id'] as number;
    const isOutgoing = messageObj['is_outgoing'] as boolean;
    const msgId = messageObj['id'] as number;

    hilog.info(0x0001, 'CoreService', `📩 [SERVICE] Received new message for chat ${chatId}, id=${msgId}, outgoing=${isOutgoing}`);

    // ⭐ Nagram 参考：先写数据库（putMessages），再更新内存（updateInterface）
    // 数据库是唯一事实源，服务器数据必须先持久化再到内存
    if (this.cacheStorage) {
      try {
        await this.saveMessageToDatabase(messageObj, chatId);
        hilog.info(0x0001, 'CoreService', `💾 [DB-FIRST] Message ${msgId} saved to database`);
      } catch (error) {
        hilog.error(0x0001, 'CoreService', `Failed to save message to database: ${JSON.stringify(error)}`);
      }

      // ⭐ Nagram 参考：同步更新 Chat 实体的最后消息和未读数到 DB
      const date = messageObj['date'] as number;
      try {
        const chatEntity = await this.cacheStorage.getChatWithCache(chatId);
        if (chatEntity) {
          chatEntity.lastMessageId = msgId;
          chatEntity.lastMessageDate = date;
          if (!isOutgoing) {
            chatEntity.unreadCount = (chatEntity.unreadCount || 0) + 1;
          }
          await this.cacheStorage.updateChat(chatEntity);
          hilog.info(0x0001, 'CoreService', `💾 [DB-FIRST] Chat ${chatId} lastMessage/readState updated in DB`);
        }
      } catch (dbError) {
        hilog.warn(0x0001, 'CoreService', `Update chat in DB failed: ${JSON.stringify(dbError)}`);
      }
    }

    // ⭐ Nagram 参考：再更新内存缓存（updateInterface）
    // refreshChat 内部会从 TDLib 重新获取最新数据并同步到内存
    this.refreshChat(chatId);
    hilog.info(0x0001, 'CoreService', `✅ [SERVICE] Refreshed chat ${chatId} via unified channel`);

    // 触发领域事件通知 ViewModel
    const eventType = isOutgoing ? 'core:messageSent' : 'core:messageReceived';
    const eventData: Record<string, Object> = new Object() as Record<string, Object>;
    eventData['chatId'] = chatId as Object;
    eventData['messageId'] = msgId as Object;
    eventData['message'] = messageObj as Object;
    eventBus.emit(eventType, eventData);
    // ⭐ Nagram 参考：累积批量变更通知
    const mask = isOutgoing ? UPDATE_MASK_MESSAGE_SENT : UPDATE_MASK_NEW_MESSAGE;
    this.scheduleBatchFlush(mask);
  }

  /**
   * 处理聊天收件箱已读状态（由 UpdateService 调用）
   * @param chatId 聊天ID
   * @param unreadCount 未读数
   * @param lastReadInboxMessageId 最后已读的入站消息ID
   */
  public onChatInboxRead(chatId: number, unreadCount: number, lastReadInboxMessageId?: number): void {
    hilog.info(0x0001, 'CoreService', 
      `⭐ [onChatInboxRead] chatId=${chatId}, unreadCount=${unreadCount}, lastReadInboxMessageId=${lastReadInboxMessageId}`);
    
    // ⭐ 使用统一更新通道：刷新完整聊天数据
    this.refreshChat(chatId);
    
    // ⭐ 同步到 CacheStorage：更新未读数和最后已读消息ID
    if (this.cacheStorage) {
      this.cacheStorage.getChatWithCache(chatId).then(chatEntity => {
        if (chatEntity) {
          chatEntity.unreadCount = unreadCount || 0;
          // ⭐ 关键修复：保存最后已读消息ID，用于锚点加载
          if (lastReadInboxMessageId && lastReadInboxMessageId > 0) {
            chatEntity.lastReadMsgId = lastReadInboxMessageId;
            hilog.debug(0x0001, 'CoreService', 
              `Updated lastReadMsgId to ${lastReadInboxMessageId} for chat ${chatId}`);
            
            // ⭐ 添加额外日志：验证是否保存成功
            setTimeout(async () => {
              const verifyEntity = await this.cacheStorage!.getChatWithCache(chatId);
              hilog.info(0x0001, 'CoreService', 
                `✅ Verification: chat ${chatId} lastReadMsgId is now ${verifyEntity?.lastReadMsgId}`);
            }, 100);
          }
          this.cacheStorage!.updateChat(chatEntity).catch((e: Error) =>
            hilog.warn(0x0001, 'CoreService', `Update chat in CacheStorage failed: ${e}`)
          );
        }
      }).catch((e: Error) =>
        hilog.warn(0x0001, 'CoreService', `Get chat from CacheStorage failed: ${e}`)
      );
    }
  }

  // ... 其他事件处理器类似（更新内存 + 调用 repository）

  // ==================== 公开 API ====================
  public getChatList(): Chat[] {
    // 返回副本，不在此处排序（由 ViewModel 负责排序）
    return [...this.chatList];
  }

  /**
   * 获取当前是否已初始化完成
   */
  public getIsInitialized(): boolean {
    return this.isInitialized;
  }

  public getChat(chatId: number): Chat | undefined {
    return this.chatList.find(c => c.id === chatId);
  }

  /**
   * ⭐ 获取所有聊天列表
   */
  public getAllChats(): Chat[] {
    return this.chatList;
  }

  public async sendTextMessage(chatId: number, text: string): Promise<Message> {
    const tempMessage: Message = {
      id: Date.now(),
      chatId,
      senderId: 0,
      senderName: '我',
      type: MessageType.TEXT,
      content: { text },
      timestamp: Date.now(),
      status: MessageStatus.SENDING,
      isOutgoing: true,
      reactions: [],
      isPinned: false,
      canBeEdited: false,
      canBeDeleted: false,
      hasProtectedContent: false
    };
    this.addMessage(chatId, tempMessage);
    try {
      const inputMessage = this.buildInputMessageTextObject(text);
      await this.tdLibApi.sendMessage(chatId, null, null, null, null, inputMessage);
      // 成功发送后，TDLib 会通过 updateNewMessage 事件更新，无需手动改状态
      return tempMessage;
    } catch (error) {
      tempMessage.status = MessageStatus.FAILED;
      this.updateMessage(chatId, tempMessage);
      throw error as Error;
    }
  }

  /**
   * 发送图片消息
   */
  public async sendImageMessage(chatId: number, imagePath: string): Promise<Message> {
    const tempMessage: Message = {
      id: Date.now(),
      chatId,
      senderId: 0,
      senderName: '我',
      type: MessageType.PHOTO,
      content: {},
      timestamp: Date.now(),
      status: MessageStatus.SENDING,
      isOutgoing: true,
      reactions: [],
      isPinned: false,
      canBeEdited: false,
      canBeDeleted: false,
      hasProtectedContent: false
    };
    this.addMessage(chatId, tempMessage);
    try {
      const inputMessage = this.buildInputMessagePhotoObject(imagePath);
      await this.tdLibApi.sendMessage(chatId, null, null, null, null, inputMessage);
      // 成功发送后，TDLib 会通过 updateNewMessage 事件更新，无需手动改状态
      return tempMessage;
    } catch (error) {
      tempMessage.status = MessageStatus.FAILED;
      this.updateMessage(chatId, tempMessage);
      throw error as Error;
    }
  }

  public async markAsRead(chatId: number, lastReadMessageId?: number): Promise<void> {
    // ⭐ 使用统一更新通道：刷新完整聊天数据
    await this.refreshChat(chatId);
    // ⭐ 清除未读数到 CacheStorage
    if (this.cacheStorage) {
      const chatEntity = await this.cacheStorage.getChatWithCache(chatId);
      if (chatEntity) {
        chatEntity.unreadCount = 0;
        await this.cacheStorage.updateChat(chatEntity);
      }
    }
    try {
      const messageIds = lastReadMessageId ? [lastReadMessageId] : [];
      await this.tdLibApi.viewMessages(chatId, messageIds, null, false);
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `Mark as read failed: ${JSON.stringify(error)}`);
      throw error as Error;
    }
  }

  /**
   * ⭐ 标记聊天为未读
   */
  public async markAsUnread(chatId: number): Promise<void> {
    try {
      // 使用 TDLib 的 toggleChatIsMarkedAsUnread 方法
      await this.tdLibApi.toggleChatIsMarkedAsUnread(chatId, true);
      // 更新本地聊天状态
      const chat = this.chatList.find(c => c.id === chatId);
      if (chat) {
        chat.isMarkedAsUnread = true;
        this.publishChatListChanged();
      }
      hilog.info(0x0001, 'CoreService', `Chat ${chatId} marked as unread`);
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `Mark as unread failed: ${JSON.stringify(error)}`);
      throw error as Error;
    }
  }
  
  /**
   * 设置聊天置顶状态
   */
  public async setPinned(chatId: number, pinned: boolean): Promise<void> {
    try {
      // 创建 chatListMain 对象（使用明确的类型）
      const chatListMain: ChatListMain = { _: 'chatListMain' };
      await this.tdLibApi.toggleChatIsPinned(chatListMain, chatId, pinned);
      // TDLib 会通过 updateChatIsPinned 事件自动更新 UI
      hilog.info(0x0001, 'CoreService', `Chat ${chatId} pinned state set to ${pinned}`);
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `Set pinned failed: ${JSON.stringify(error)}`);
      throw error as Error;
    }
  }

  /**
   * 设置聊天静音状态
   * @param chatId 聊天ID
   * @param muted 是否静音
   * @param muteUntil 静音截止时间戳（毫秒），0表示永久静音
   */
  public async setMuted(chatId: number, muted: boolean, muteUntil?: number): Promise<void> {
    try {
      // 计算静音时长（秒）
      let muteFor = 0;
      if (muted) {
        if (muteUntil && muteUntil > 0) {
          // 计算从现在到截止时间的秒数
          muteFor = Math.floor((muteUntil - Date.now()) / 1000);
          if (muteFor < 0) muteFor = 0;
        } else {
          // 永久静音（使用一个很大的值）
          muteFor = 2147483647; // 约68年
        }
      }
      
      await this.tdLibApi.setChatNotificationSettings(chatId, {
        _: 'chatNotificationSettings',
        use_default_mute_for: false,
        mute_for: muteFor,
        use_default_sound: true,
        use_default_show_preview: true,
        show_preview: true,
        use_default_disable_pinned_message_notifications: true,
        disable_pinned_message_notifications: false,
        use_default_disable_mention_notifications: true,
        disable_mention_notifications: false
      });
      
      hilog.info(0x0001, 'CoreService', `Chat ${chatId} muted state set to ${muted}, muteFor=${muteFor}s`);
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `Set muted failed: ${JSON.stringify(error)}`);
      throw error as Error;
    }
  }

  /**
   * 删除聊天
   * @param chatId 聊天ID
   * @param deleteFromCache 是否从缓存中删除
   */
  public async deleteChat(chatId: number, deleteFromCache: boolean = true): Promise<void> {
    try {
      await this.tdLibApi.deleteChatHistory(chatId, true, deleteFromCache);
      
      // 从内存中移除
      const index = this.chatList.findIndex(c => c.id === chatId);
      if (index !== -1) {
        this.chatList.splice(index, 1);
        this.publishChatListChanged();
      }
      
      // ⭐ 从 CacheStorage 中删除
      if (this.cacheStorage) {
        await this.cacheStorage.deleteChat(chatId);
      }
      
      hilog.info(0x0001, 'CoreService', `Chat ${chatId} deleted successfully`);
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `Delete chat failed: ${JSON.stringify(error)}`);
      throw error as Error;
    }
  }

  /**
   * 归档聊天
   * @param chatId 聊天ID
   */
  public async archiveChat(chatId: number): Promise<void> {
    try {
      // 将聊天移动到归档列表
      await this.tdLibApi.addChatToList(chatId, { _: 'chatListArchive' });
      
      // 从内存中移除（UI 会通过事件自动更新）
      const index = this.chatList.findIndex(c => c.id === chatId);
      if (index !== -1) {
        this.chatList.splice(index, 1);
        this.publishChatListChanged();
      }
      
      hilog.info(0x0001, 'CoreService', `Chat ${chatId} archived successfully`);
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `Archive chat failed: ${JSON.stringify(error)}`);
      throw error as Error;
    }
  }

  /**
   * ⭐ Telegram 风格：以锚点为中心双向加载消息
   * @param chatId 聊天ID
   * @param anchorMessageId 锚点消息ID（上次阅读位置）
   * @param upLimit 向上加载的历史消息数量（默认50）
   * @param downLimit 向下加载的新消息数量（默认20）
   * @returns 合并后的消息数组（按时间升序）
   */
  public async loadMessagesAroundAnchor(
    chatId: number,
    anchorMessageId: number,
    upLimit: number = 50,
    downLimit: number = 20
  ): Promise<Message[]> {
    try {
      hilog.info(0x0001, 'CoreService', 
        `⭐ Loading messages around anchor ${anchorMessageId} for chat ${chatId} (up=${upLimit}, down=${downLimit})`);

      // 1. 获取锚点消息本身
      const anchorMessagesResult = await this.tdLibApi.getMessages(chatId, [anchorMessageId]);
      let anchorMessage: Message | undefined = undefined;
      if (anchorMessagesResult && (anchorMessagesResult as Messages).messages?.length > 0) {
        // ⭐ Nagram 参考：先保存锚点消息到数据库
        const anchorTdMessages = (anchorMessagesResult as Messages).messages;
        await this.batchSaveMessagesToDatabase(anchorTdMessages, chatId);

        const chat = this.getChat(chatId);
        const chatType = chat?.type || ChatType.PRIVATE;
        const converted = await this.convertTdMessages(anchorTdMessages, chatType);
        if (converted.length > 0) {
          anchorMessage = converted[0];
        }
      }

      if (!anchorMessage) {
        hilog.warn(0x0001, 'CoreService', `Anchor message ${anchorMessageId} not found, fallback to latest messages`);
        return await this.loadHistory(chatId, 0, upLimit + downLimit);
      }

      // ⭐ 此时 anchorMessage 一定不为 null/undefined，转换为非空类型
      const validAnchorMessage: Message = anchorMessage;

      // 2. 向上加载历史消息（锚点之前）
      const historyMessages = await this.loadHistory(chatId, anchorMessageId, upLimit);
      
      // 3. 向下加载新消息（锚点之后）
      // TDLib 的 getChatHistory 只能从某消息向前加载，不能向后
      // 所以我们需要先获取最新消息，然后过滤出比锚点新的消息
      const latestMessages = await this.loadHistory(chatId, 0, downLimit + 10); // 多加载一些用于过滤
      const futureMessages = latestMessages.filter(m => m.id > validAnchorMessage.id).slice(0, downLimit);

      // 4. 合并：历史消息（已排序）+ 锚点 + 新消息
      const allMessages = [...historyMessages];
      
      // 检查锚点是否已在历史消息中
      const hasAnchor = allMessages.some(m => m.id === validAnchorMessage.id);
      if (!hasAnchor) {
        allMessages.push(validAnchorMessage);
      }
      
      allMessages.push(...futureMessages);
      
      // 5. 去重并按 ID 升序排序
      const uniqueMessages = Array.from(new Map(allMessages.map(m => [m.id, m])).values());
      uniqueMessages.sort((a, b) => a.id - b.id);

      hilog.info(0x0001, 'CoreService', 
        `✅ Loaded ${uniqueMessages.length} messages around anchor (history=${historyMessages.length}, anchor=1, future=${futureMessages.length})`);

      return uniqueMessages;
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `loadMessagesAroundAnchor failed: ${JSON.stringify(error)}`);
      // 失败时回退到普通加载
      return await this.loadHistory(chatId, 0, upLimit + downLimit);
    }
  }

  /**
   * ⭐ 获取聊天的锚点消息ID（上次阅读位置）
   * @param chatId 聊天ID
   * @returns 锚点消息ID，如果没有记录返回0
   */
  public async getAnchorMessageId(chatId: number): Promise<number> {
    try {
      // 从缓存中获取聊天的 lastReadMsgId
      if (this.cacheStorage) {
        const chatEntity = await this.cacheStorage.getChatWithCache(chatId);
        hilog.info(0x0001, 'CoreService', 
          `⭐ [getAnchorMessageId] chatId=${chatId}, lastReadMsgId=${chatEntity?.lastReadMsgId || 0}`);
        
        if (chatEntity && chatEntity.lastReadMsgId > 0) {
          hilog.info(0x0001, 'CoreService', `Found anchor messageId ${chatEntity.lastReadMsgId} from cache for chat ${chatId}`);
          return chatEntity.lastReadMsgId;
        }
      }

      // 如果没有阅读记录，返回0（表示从最新消息开始）
      hilog.info(0x0001, 'CoreService', `No anchor found for chat ${chatId}, will load from latest`);
      return 0;
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `getAnchorMessageId failed: ${JSON.stringify(error)}`);
      return 0;
    }
  }

  /**
   * ⭐ 更新聊天的阅读位置
   * @param chatId 聊天ID
   * @param messageId 最后阅读的消息ID
   */
  public async updateReadPosition(chatId: number, messageId: number): Promise<void> {
    try {
      if (this.cacheStorage) {
        const chatEntity = await this.cacheStorage.getChatWithCache(chatId);
        if (chatEntity) {
          chatEntity.lastReadMsgId = messageId;
          await this.cacheStorage.updateChat(chatEntity);
          hilog.debug(0x0001, 'CoreService', `Updated read position to message ${messageId} for chat ${chatId}`);
        }
      }
    } catch (error) {
      hilog.warn(0x0001, 'CoreService', `updateReadPosition failed: ${JSON.stringify(error)}`);
    }
  }

  public async loadHistory(chatId: number, fromMessageId?: number, limit: number = 20): Promise<Message[]> {
    // ⭐ Nagram 参考：先写入数据库，再从数据库读取返回
    // 流程：TDLib → DB（事实源） → Memory Cache → 返回 Message[]
    try {
      hilog.info(0x0001, 'CoreService', `Loading history for chat ${chatId}, fromMessageId: ${fromMessageId || 0}, limit: ${limit}`);

      // ⭐ 获取聊天类型
      const chat = this.getChat(chatId);
      const chatType = chat?.type || ChatType.PRIVATE;

      const result = await this.tdLibApi.getChatHistory(chatId, fromMessageId || 0, 0, limit, false);
      if (result && (result as Messages).messages) {
        const tdMessages = (result as Messages).messages;
        hilog.info(0x0001, 'CoreService', `Loaded ${tdMessages.length} messages from TDLib for chat ${chatId}`);

        // ⭐ Nagram 参考：Phase 1 - 先批量写入数据库（确保持久化）
        const savedCount = await this.batchSaveMessagesToDatabase(tdMessages, chatId);
        hilog.info(0x0001, 'CoreService', `Phase 1: Saved ${savedCount}/${tdMessages.length} messages to DB for chat ${chatId}`);

        // ⭐ Nagram 参考：Phase 2 - 从数据库加载（数据库是唯一事实源）
        // 先尝试从数据库读取最新数据，确保与 DB 一致
        let dbMessages: Message[] = [];
        if (this.cacheStorage && savedCount > 0) {
          const limitForRead = Math.max(limit, savedCount);
          const dbEntities = await this.cacheStorage.database.queryMessagesByChat(chatId, limitForRead, 0);
          if (dbEntities && dbEntities.length > 0) {
            dbMessages = dbEntities.map(entity => this.convertEntityToMessage(entity));
            dbMessages.sort((a, b) => a.id - b.id);
            hilog.info(0x0001, 'CoreService', `Phase 2: Loaded ${dbMessages.length} messages from DB for chat ${chatId}`);
          }
        }

        // ⭐ Nagram 参考：Phase 3 - 从 TDLib 原始数据构建 Message[]（用于内存缓存和返回）
        const convertedMessages = await this.convertTdMessages(tdMessages, chatType);

        // ⭐ Nagram 参考：Phase 4 - 合并数据（优先使用 DB 数据，TDLib 转换数据补充）
        let resultMessages: Message[];
        if (dbMessages.length > 0) {
          // 以 DB 数据为主，用 TDLib 转换数据补充字段（如 senderName）
          const resultMap = new Map<number, Message>();
          for (const msg of dbMessages) resultMap.set(msg.id, msg);
          for (const msg of convertedMessages) {
            if (resultMap.has(msg.id)) {
              // 保留 DB 消息，但用 TDLib 数据补充字段
              const existing = resultMap.get(msg.id)!;
              if (msg.senderName && !existing.senderName) existing.senderName = msg.senderName;
              if (msg.media && !existing.media) existing.media = msg.media;
            } else {
              resultMap.set(msg.id, msg);
            }
          }
          resultMessages = Array.from(resultMap.values()).sort((a, b) => a.id - b.id);
        } else {
          resultMessages = convertedMessages;
        }

        // ⭐ Phase 5：更新内存缓存（messagesMap 作为 DB 的读缓存）
        const existing = this.messagesMap.get(chatId) || [];
        const merged = new Map<number, Message>();
        for (const msg of existing) merged.set(msg.id, msg);
        for (const msg of resultMessages) merged.set(msg.id, msg);
        const mergedArray = Array.from(merged.values()).sort((a, b) => a.id - b.id);
        this.messagesMap.set(chatId, mergedArray);
        hilog.info(0x0001, 'CoreService', `Phase 5: Updated memory cache: ${mergedArray.length} messages`);

        // ⭐ 返回按 ID 升序排序的消息
        return resultMessages;
      }
      return [];
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `Load history failed: ${JSON.stringify(error)}`);
      return [];
    }
  }

  // ==================== 私有辅助 ====================
  private async refreshChat(chatId: number): Promise<void> {
    try {
      hilog.info(0x0001, 'CoreService', `🔄 refreshChat START: chatId=${chatId}`);
      const chatData = await this.tdLibApi.getChat(chatId);
      if (chatData) {
        const updatedChat = this.mapChatFromTDLib(chatData);
        const index = this.chatList.findIndex(c => c.id === chatId);
        if (index !== -1) {
          this.chatList[index] = updatedChat;
          hilog.info(0x0001, 'CoreService', `✅ Updated existing chat ${chatId} at index ${index}, lastMessage=${updatedChat.lastMessage?.content || 'none'}`);
        } else {
          this.chatList.push(updatedChat);
          hilog.info(0x0001, 'CoreService', `➕ Added new chat ${chatId} to list`);
        }
        
        hilog.info(0x0001, 'CoreService', `📢 Publishing chatListChanged event for chat ${chatId}`);
        this.publishChatListChanged();
        
        // ⭐ 持久化到 CacheStorage
        if (this.cacheStorage) {
          const entity = this.convertChatToEntity(updatedChat);
          await this.cacheStorage.saveChat(entity);
          hilog.info(0x0001, 'CoreService', `💾 Saved chat ${chatId} to cache storage`);
        }
      } else {
        hilog.warn(0x0001, 'CoreService', `⚠️ refreshChat: getChat returned null for chatId=${chatId}`);
      }
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `❌ Refresh chat ${chatId} failed: ${JSON.stringify(error)}`);
    }
  }

  private addMessage(chatId: number, message: Message): void {
    const messages = this.messagesMap.get(chatId) || [];
    messages.push(message);
    this.messagesMap.set(chatId, messages);
    this.updateChatLastMessage(chatId, message);
  }

  private updateMessage(chatId: number, message: Message): void {
    const messages = this.messagesMap.get(chatId);
    if (messages) {
      const index = messages.findIndex(m => m.id === message.id);
      if (index !== -1) messages[index] = message;
    }
  }

  private updateChatLastMessage(chatId: number, message: Message): void {
    const chat = this.getChat(chatId);
    if (chat) {
      // ⭐ 使用统一的更新通道：直接触发完整刷新
      // 这会重新从 TDLib 获取完整的聊天数据（包括 lastMessage、timestamp、order）
      // 避免手动更新字段导致的不同步问题
      this.refreshChatWithDebounce(chatId);
    }
  }

  private publishChatListChanged(): void {
    // ⭐ 实时更新：立即发布，无防抖延迟
    const changedEvent: ChatListChangedEvent = { chats: this.chatList };
    // ⭐ Nagram 参考：累积批量变更通知
    this.scheduleBatchFlush(UPDATE_MASK_CHAT_LIST);
    eventBus.emit('chatListChanged', changedEvent);
    
    // 更新最后已知状态，供迟到的订阅者查询
    this.lastKnownChatList = [...this.chatList];
  }
  private publishTimer: number | null = null;
  private lastKnownChatList: Chat[] = []; // 新增：状态快照

  // ==================== TDLib 数据加载 ====================
  /**
   * 加载更多聊天（分页加载）
   * @param limit 每次加载的数量
   * @returns 是否还有更多数据
   */
  public async loadMoreChats(limit: number = 50): Promise<boolean> {
    try {
      hilog.info(0x0001, 'CoreService', `📡 Loading more chats (limit=${limit})...`);
      
      // 获取当前聊天列表的最后一个 order 值
      const currentChats = this.getChatList();
      if (currentChats.length === 0) {
        // 如果没有聊天，调用初始加载
        await this.loadInitialChats();
        return true;
      }
      
      // 找到最小的 order 值（列表末尾）
      let minOrder: number | undefined = undefined;
      for (const chat of currentChats) {
        if (chat.order !== undefined) {
          if (minOrder === undefined || chat.order < minOrder) {
            minOrder = chat.order;
          }
        }
      }
      
      if (minOrder === undefined) {
        hilog.warn(0x0001, 'CoreService', '⚠️ No order value found in current chats');
        return false;
      }
      
      // 使用 TDLib 的 loadChats API 加载更多
      // 注意：TDLib 的 loadChats 需要 offset_order 参数
      const chatListMain: chatListMain$Input = { _: 'chatListMain' };
      await this.tdLibApi.loadChats(chatListMain, limit);
      
      // loadChats 只返回 ok，需要通过 getChats 获取实际的聊天列表
      const chatsResult: Chats = await this.tdLibApi.getChats(chatListMain, limit);
      
      if (!chatsResult || !chatsResult.chat_ids || chatsResult.chat_ids.length === 0) {
        hilog.info(0x0001, 'CoreService', '✅ No more chats to load');
        return false; // 没有更多数据
      }
      
      hilog.info(0x0001, 'CoreService', `📋 Loaded ${chatsResult.chat_ids.length} new chat IDs`);
      
      // 加载新的聊天详情
      let loadedCount = 0;
      for (const chatId of chatsResult.chat_ids) {
        // 检查是否已存在
        const existingIndex = this.chatList.findIndex(c => c.id === chatId);
        if (existingIndex !== -1) {
          continue;
        }
        
        try {
          const chatData = await this.tdLibApi.getChat(chatId);
          if (chatData) {
            const chat: Chat = this.mapChatFromTDLib(chatData);
            this.chatList.push(chat);
            loadedCount++;
          }
        } catch (err) {
          hilog.warn(0x0001, 'CoreService', `Failed to load chat ${chatId}: ${JSON.stringify(err)}`);
        }
      }
      
      hilog.info(0x0001, 'CoreService', `✅ Successfully loaded ${loadedCount} new chats, total: ${this.chatList.length}`);
      
      // 触发 UI 更新
      this.publishChatListChanged();
      
      return chatsResult.chat_ids.length >= limit; // 如果返回的数量等于 limit，可能还有更多
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `❌ Load more chats failed: ${JSON.stringify(error)}`);
      return false;
    }
  }
  
  /**
   * 初始加载聊天列表（优化时序：分批更新 UI）
   */
  private async loadInitialChats(): Promise<void> {
    try {
      hilog.info(0x0001, 'CoreService', '📡 Calling tdLibApi.getChats(chatListMain, 50)...');
      const chatListMain: chatListMain$Input = { _: 'chatListMain' };
      const result: Chats = await this.tdLibApi.getChats(chatListMain, 50);
      
      if (!result) {
        hilog.warn(0x0001, 'CoreService', '⚠️ getChats returned null/undefined');
        return;
      }
      
      const chatIds: number[] = result.chat_ids || [];
      hilog.info(0x0001, 'CoreService', `📋 Got ${chatIds.length} chat IDs`);
      
      // 优化：并行获取详情，但限制并发数以避免阻塞
      const batchSize = 10; // 每批处理 10 个
      for (let i = 0; i < chatIds.length; i += batchSize) {
        const batch = chatIds.slice(i, i + batchSize);
        const promises = batch.map(async (chatId) => {
          try {
            const chatData = await this.tdLibApi.getChat(chatId);
            if (chatData) {
              return this.mapChatFromTDLib(chatData);
            }
          } catch (err) {
            hilog.warn(0x0001, 'CoreService', `Failed to load chat ${chatId}: ${JSON.stringify(err)}`);
          }
          return null;
        });
        
        const results = await Promise.all(promises);
        const validChats: Chat[] = [];
        for (const c of results) {
          if (c !== null) {
            validChats.push(c);
          }
        }
        
        // 关键时序优化：每批数据到达后立即合并并触发 UI 更新
        if (validChats.length > 0) {
          this.chatList = [...this.chatList, ...validChats];
          this.publishChatListChanged(); // 触发防抖更新
        }

        // 呼吸间隙：让出主线程，确保 UI 有机会渲染
        if (i + batchSize < chatIds.length) {
          await new Promise<void>(resolve => setTimeout(resolve, 10));
        }
      }
      
      hilog.info(0x0001, 'CoreService', `✅ Successfully loaded ${this.chatList.length} chats total`);
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `❌ Load chats from TDLib failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 将 TDLib Chat 对象映射为应用 Chat 模型
   */
  private mapChatFromTDLib(tdLibChat: Object): Chat {
    const chatRecord = tdLibChat as Record<string, Object>;
    
    const chatId = chatRecord['id'] as number;
    const title = chatRecord['title'] as string || '';
    const unreadCount = chatRecord['unread_count'] as number || 0;
    // 🔧 TDLib 通过 positions 数组返回置顶状态和顺序
    // positions[0].is_pinned 表示是否置顶
    // positions[0].order 表示排序顺序（数值越大越靠前）
    const positions = chatRecord['positions'] as Array<Object> || [];
    let isPinned = false;
    let order: number | undefined = undefined;
    if (positions.length > 0) {
      const firstPos = positions[0] as Record<string, Object>;
      isPinned = firstPos['is_pinned'] as boolean || false;
      // TDLib 的 order 是字符串格式的大整数，需要转换为 number
      const orderStr = firstPos['order'] as string | undefined;
      if (orderStr) {
        order = parseFloat(orderStr);
      }
    }
    
    // ⭐ 如果 order 缺失或为0，使用 timestamp 作为后备排序依据
    // 注意：这里不使用负数，而是使用正数，确保与 TDLib 的 order 方向一致
    // TDLib 的 order 越大越靠前，timestamp 也是越大越新
    if (order === undefined || order === 0) {
      // 先获取 last_message 的时间戳
      const lastMessageObjForOrder = chatRecord['last_message'] as Record<string, Object> | undefined;
      let syntheticTimestamp = 0;
      if (lastMessageObjForOrder) {
        const date = lastMessageObjForOrder['date'] as number || 0;
        syntheticTimestamp = date * 1000; // 转换为毫秒
      }
      // 使用正的时间戳作为后备 order（与 TDLib 的 order 方向一致）
      // 如果无消息，使用0（排在最后）
      order = syntheticTimestamp > 0 ? syntheticTimestamp : 0;
      hilog.debug(0x0001, 'CoreService',
        `🔄 Fallback order for chat ${chatId} (${title}): ${order} (from timestamp=${syntheticTimestamp})`);
    }
    
    const isMarkedAsUnread = chatRecord['is_marked_as_unread'] as boolean || false;
    
    // 🔍 调试：打印完整的聊天记录键名
    const keys = Object.keys(chatRecord);
    hilog.info(0x0001, 'CoreService',
      `🔍 Chat ${chatId} (${title}) keys: ${keys.join(', ')}`);
    hilog.info(0x0001, 'CoreService',
      `📌 Chat ${chatId} isPinned=${isPinned}, order=${order}`);
    if (positions.length > 0) {
      const firstPos = positions[0] as Record<string, Object>;
      hilog.info(0x0001, 'CoreService',
        `📍 First position: ${JSON.stringify(firstPos)}`);
    }
    
    // 映射聊天类型
    const typeObjRaw = chatRecord['type'];
    hilog.debug(0x0001, 'CoreService', `Chat ${chatId} typeObjRaw: ${typeof typeObjRaw}, ${typeObjRaw ? 'exists' : 'undefined'}`);
    
    let chatType: ChatType = ChatType.PRIVATE;
    let typeObj: Record<string, Object> | undefined = undefined;
    if (typeObjRaw && typeof typeObjRaw === 'object') {
      // TDLib 返回的对象需要序列化再解析才能正确访问属性
      const typeObjJson = JSON.stringify(typeObjRaw);
      typeObj = JSON.parse(typeObjJson) as Record<string, Object>;
      
      // TDLib 可能使用 @type 或 _ 作为类型字段
      const typeField = (typeObj['@type'] || typeObj['_']) as string | undefined;
      hilog.info(0x0001, 'CoreService', `Chat ${chatId} typeField: ${typeField}, type keys: ${Object.keys(typeObj).join(',')}`);
      
      if (typeField === 'chatTypePrivate') {
        chatType = ChatType.PRIVATE;
      } else if (typeField === 'chatTypeBasicGroup') {
        chatType = ChatType.GROUP;
      } else if (typeField === 'chatTypeSupergroup') {
        const isChannel = typeObj['is_channel'] as boolean || false;
        chatType = isChannel ? ChatType.CHANNEL : ChatType.SUPERGROUP;
        hilog.info(0x0001, 'CoreService', `Chat ${chatId} is supergroup, isChannel: ${isChannel}`);
      } else if (typeField === 'chatTypeSecret') {
        chatType = ChatType.SECRET;
      } else {
        hilog.warn(0x0001, 'CoreService', `Chat ${chatId} unknown typeField: ${typeField}`);
      }
    } else {
      hilog.warn(0x0001, 'CoreService', `Chat ${chatId} typeObjRaw is null or not object`);
    }
    
    // 获取静音状态
    let isMuted = false;
    const notifSettings = chatRecord['notification_settings'] as Record<string, Object> | undefined;
    if (notifSettings) {
      const muteFor = notifSettings['mute_for'] as number || 0;
      isMuted = muteFor > 0;
    }
    
    // 获取头像
    let avatar = '';
    const photo = chatRecord['photo'] as Record<string, Object> | undefined;
    hilog.info(0x0001, 'CoreService', `Chat ${chatId} photo data: ${photo ? 'exists' : 'null'}`);
    
    if (photo) {
      const small = photo['small'] as Record<string, Object> | undefined;
      hilog.info(0x0001, 'CoreService', `Chat ${chatId} photo.small: ${small ? 'exists' : 'null'}`);
      
      if (small) {
        const fileId = small['id'] as number | undefined;
        const local = small['local'] as Record<string, Object> | undefined;
        
        hilog.info(0x0001, 'CoreService', `Chat ${chatId} fileId: ${fileId}, local: ${local ? 'exists' : 'null'}`);
        
        // 如果已有本地路径，直接使用
        if (local) {
          const localPath = local['path'] as string | undefined;
          hilog.info(0x0001, 'CoreService', `Chat ${chatId} local path: ${localPath || 'empty'}`);
          if (localPath && localPath.length > 0) {
            avatar = localPath;
          }
        }
        
        // 如果没有本地路径但有 fileId，触发异步下载
        if (!avatar && fileId && fileId > 0) {
          hilog.info(0x0001, 'CoreService', `Chat ${chatId} triggering avatar download for fileId: ${fileId}`);
          this.triggerAvatarDownload(fileId, chatId);
        }
      }
    }
    
    hilog.info(0x0001, 'CoreService', `Chat ${chatId} (${title}) final avatar: ${avatar || 'empty'}`);
    
    const isVerified = chatRecord['is_verified'] as boolean || false;
    
    // ⭐ 获取未读提及数量
    const unreadMentionCount = chatRecord['unread_mention_count'] as number || 0;
    
    // ⭐ 获取消息自动删除设置
    const messageTtlSetting = chatRecord['message_ttl_setting'] as number | undefined;
    
    // 获取用户ID（私聊）- 必须在获取 Premium 状态之前声明
    let userId: number | undefined = undefined;
    if (chatType === ChatType.PRIVATE && typeObj) {
      userId = typeObj['user_id'] as number | undefined;
    }
    
    // ⭐ 获取 Premium 状态（从用户缓存或 TDLib 数据）
    let isPremium = false;
    if (chatType === ChatType.PRIVATE && userId) {
      const userInfo = this.userCache.get(userId);
      if (userInfo) {
        isPremium = userInfo.isPremium || false;
      }
    }
    
    // 获取草稿
    const draftMessageObj = chatRecord['draft_message'] as Record<string, Object> | undefined;
    let draftMessage: DraftMessage | undefined = undefined;
    if (draftMessageObj) {
      const inputMsgText = draftMessageObj['input_message_text'] as Record<string, Object> | undefined;
      if (inputMsgText) {
        const textContent = inputMsgText['text'] as Record<string, Object> | undefined;
        if (textContent) {
          const text = textContent['text'] as string || '';
          if (text) {
            draftMessage = { text, entities: [], date: Date.now() };
          }
        }
      }
    }
    
    // 获取时间戳和最后消息
    const lastMessageObj = chatRecord['last_message'] as Record<string, Object> | undefined;
    let timestamp = 0;
    let lastMessage: Message | undefined = undefined;
    
    if (lastMessageObj) {
      const date = lastMessageObj['date'] as number || 0;
      timestamp = date * 1000; // 转换为毫秒
      
      // 映射最后消息对象
      try {
        const msgId = lastMessageObj['id'] as number;
        const isOutgoing = lastMessageObj['is_outgoing'] as boolean || false;
        const senderIdRaw = lastMessageObj['sender_id'];
        
        // 提取发送者ID和名称
        let senderUserId = 0;
        let senderName = '';
        if (senderIdRaw) {
          // TDLib 返回的对象需要序列化再解析才能正确访问属性
          const senderIdJson = JSON.stringify(senderIdRaw);
          const senderId = JSON.parse(senderIdJson) as Record<string, Object>;
          
          // 调试：打印完整的 sender_id 对象
          hilog.info(0x0001, 'CoreService', `Chat ${chatId} sender_id raw: ${senderIdJson}`);
          
          // TDLib 可能使用 @type 或 _ 作为类型字段
          const senderType = (senderId['@type'] || senderId['_']) as string | undefined;
          hilog.info(0x0001, 'CoreService', `Chat ${chatId} senderType: ${senderType}, chatType: ${chatType}, keys: ${Object.keys(senderId).join(',')}`);
          
          if (senderType === 'messageSenderUser') {
            senderUserId = senderId['user_id'] as number || 0;
            hilog.debug(0x0001, 'CoreService', `Chat ${chatId} senderUserId: ${senderUserId}, isOutgoing: ${isOutgoing}`);
            
            // 对于私聊，使用聊天标题作为发送者名称
            if (chatType === ChatType.PRIVATE) {
              senderName = title;
            } else {
              // ⭐ 对于群组/频道，获取用户名称
              const userInfo = this.userCache.get(senderUserId);
              if (userInfo && userInfo.name) {
                senderName = userInfo.name;
                hilog.debug(0x0001, 'CoreService', `Chat ${chatId} senderName from cache: ${senderName}`);
              } else {
                // 异步获取用户信息
                this.getUserInfo(senderUserId).then(info => {
                  if (info.name) {
                    hilog.info(0x0001, 'CoreService', `Chat ${chatId} fetched sender name for user ${senderUserId}: ${info.name}`);
                    // 触发聊天列表刷新以更新发送者名称
                    this.publishChatListChanged();
                  }
                }).catch(() => {
                  // 忽略错误
                });
              }
            }
          } else if (senderType === 'messageSenderChat') {
            // ⭐ 频道消息发送者（messageSenderChat）
            senderUserId = senderId['chat_id'] as number || 0;
            // 对于频道，尝试从缓存获取聊天标题作为签名
            const chatInfo = this.getChat(senderUserId);
            if (chatInfo) {
              senderName = chatInfo.title || '';
              hilog.debug(0x0001, 'CoreService', `Chat ${chatId} senderName from chat cache: ${senderName}`);
            } else {
              // 异步获取聊天信息
              this.tdLibApi.getChat(senderUserId).then(chatData => {
                if (chatData) {
                  const chatJson = JSON.stringify(chatData);
                  const chatRecord = JSON.parse(chatJson) as Record<string, string>;
                  const title = chatRecord['title'] || '';
                  if (title) {
                    hilog.info(0x0001, 'CoreService', `Chat ${chatId} senderName from TDLib: ${title}`);
                    this.publishChatListChanged();
                  }
                }
              }).catch(() => {
                // 忽略错误
              });
            }
          }
        }
        
        // ⭐ 提取作者签名（频道消息特有）
        // TDLib 可能使用 author_signature 或 _author_signature 作为字段名
        const authorSignature = (lastMessageObj['author_signature'] || lastMessageObj['_author_signature']) as string | undefined;
        
        // ⭐ 调试：打印 lastMessageObj 的所有字段，帮助排查签名问题
        if (chatType === ChatType.CHANNEL) {
          hilog.info(0x0001, 'CoreService',
            `Channel ${chatId} lastMessage keys: ${Object.keys(lastMessageObj).join(', ')}`);
          hilog.info(0x0001, 'CoreService',
            `Channel ${chatId} author_signature: "${authorSignature || 'empty'}"`);
        }
        
        // ⭐ 对于频道，如果有作者签名，使用签名作为发送者名称
        if (chatType === ChatType.CHANNEL && authorSignature) {
          senderName = authorSignature;
          hilog.info(0x0001, 'CoreService', `Channel ${chatId} using author signature: ${senderName}`);
        }
        
        hilog.debug(0x0001, 'CoreService', `Chat ${chatId} final senderName: "${senderName}"`);
        
        // 提取消息内容
        const content = this.extractMessageText(lastMessageObj);
        const msgType = this.mapTdMessageType(lastMessageObj);
        
        lastMessage = {
          id: msgId,
          chatId: chatId,
          senderId: senderUserId,
          senderName: senderName,
          type: msgType,
          content: content,
          timestamp: timestamp,
          status: MessageStatus.READ,
          isOutgoing: isOutgoing,
          authorSignature: authorSignature,
          isChannelPost: chatType === ChatType.CHANNEL,
          reactions: [],
          isPinned: false,
          canBeEdited: false,
          canBeDeleted: false,
          hasProtectedContent: false
        };
        
        hilog.debug(0x0001, 'CoreService',
          `Mapped last message for chat ${chatId}: type=${msgType}, content="${content}", outgoing=${isOutgoing}`);
      } catch (err) {
        hilog.warn(0x0001, 'CoreService', `Failed to map last message for chat ${chatId}: ${JSON.stringify(err)}`);
      }
    } else {
      hilog.debug(0x0001, 'CoreService', `No last message for chat ${chatId} (${title})`);
    }
    
    // ⭐ 获取群组/频道的成员状态（用于区分"我的"和"其他人的"）
    let memberStatus: ChatMemberStatus | undefined = undefined;
    let isOwner = false;
    let isAdmin = false;

    // 从 chatRecord 中获取成员状态信息
    const chatMemberStatus = chatRecord['status'] as Record<string, Object> | undefined;
    if (chatMemberStatus) {
      const statusType = (chatMemberStatus['@type'] || chatMemberStatus['_']) as string | undefined;
      if (statusType) {
        // 根据状态类型设置成员状态
        switch (statusType) {
          case 'chatMemberStatusCreator':
            memberStatus = { type: 'creator', customTitle: chatMemberStatus['custom_title'] as string | undefined };
            isOwner = true;
            isAdmin = true;
            break;
          case 'chatMemberStatusAdministrator':
            const rights = chatMemberStatus['rights'] as Record<string, boolean> | undefined;
            memberStatus = {
              type: 'administrator',
              rights: {
                canBeEdited: rights?.['can_be_edited'] ?? false,
                canChangeInfo: rights?.['can_change_info'] ?? false,
                canPostMessages: rights?.['can_post_messages'] ?? false,
                canEditMessages: rights?.['can_edit_messages'] ?? false,
                canDeleteMessages: rights?.['can_delete_messages'] ?? false,
                canInviteUsers: rights?.['can_invite_users'] ?? false,
                canRestrictMembers: rights?.['can_restrict_members'] ?? false,
                canPinMessages: rights?.['can_pin_messages'] ?? false,
                canPromoteMembers: rights?.['can_promote_members'] ?? false,
                canManageVideoChats: rights?.['can_manage_video_chats'] ?? false
              }
            };
            isAdmin = true;
            break;
          case 'chatMemberStatusMember':
            memberStatus = { type: 'member' };
            break;
          case 'chatMemberStatusRestricted':
            const permissions = chatMemberStatus['permissions'] as ChatPermissions | undefined;
            memberStatus = {
              type: 'restricted',
              rights: permissions ?? {
                canSendMessages: false,
                canSendMedia: false,
                canSendPolls: false,
                canSendOtherMessages: false,
                canAddWebPagePreviews: false,
                canChangeInfo: false,
                canInviteUsers: false,
                canPinMessages: false
              },
              untilDate: chatMemberStatus['until_date'] as number || 0
            };
            break;
          case 'chatMemberStatusLeft':
            memberStatus = { type: 'left' };
            break;
          case 'chatMemberStatusBanned':
            memberStatus = {
              type: 'banned',
              untilDate: chatMemberStatus['until_date'] as number || 0
            };
            break;
        }
      }
    }

    const chat: Chat = {
      id: chatId,
      type: chatType,
      title: title,
      avatar: avatar,
      unreadCount: unreadCount,
      unreadMentionCount: unreadMentionCount,
      isPinned: isPinned,
      isMuted: isMuted,
      isArchived: false,
      isMarkedAsUnread: isMarkedAsUnread,
      hasProtectedContent: false,
      hasScheduledMessages: false,
      order: order ?? 0,
      positions: [],
      isVerified: isVerified,
      isScam: false,
      isFake: false,
      canBeDeletedOnlyForSelf: false,
      canBeDeletedForAllUsers: false,
      canBeReported: false,
      defaultDisableNotification: false,
      hasActiveStories: false,
      storyIds: [],
      timestamp: timestamp,
      lastMessage: lastMessage,
      draftMessage: draftMessage,
      userId: userId,
      messageTtlSetting: messageTtlSetting,
      hasLinkedChat: false,
      // ⭐ 成员状态信息
      memberStatus: memberStatus,
      isOwner: isOwner,
      isAdmin: isAdmin
    };

    hilog.info(0x0001, 'CoreService',
      `Chat ${chatId} (${title}) mapped: type=${chatType}, isOwner=${isOwner}, isAdmin=${isAdmin}, memberStatus=${memberStatus?.type || 'undefined'}`);

    return chat;
  }

  /**
   * 转换 TDLib 消息数组为应用 Message 数组
   * @param tdMessages TDLib 消息数组
   * @param chatType 聊天类型（用于判断频道消息）
   */
  private async convertTdMessages(tdMessages: Array<Object | null>, chatType: ChatType = ChatType.PRIVATE): Promise<Message[]> {
    const messages: Message[] = [];
    const userIdsArray: number[] = [];
    
    // 提取用户 ID 和聊天 ID（群组关联的频道消息使用 chat_id）
    const chatIdsArray: number[] = [];
    for (const msg of tdMessages) {
      const msgJson = JSON.stringify(msg);
      const messageObj = JSON.parse(msgJson) as Record<string, Object>;
      const senderId = messageObj['sender_id'];
      if (senderId && typeof senderId === 'object') {
        const senderRecord = senderId as Record<string, Object>;
        const senderType = (senderRecord['@type'] || senderRecord['_']) as string;
        
        if (senderType === 'messageSenderUser') {
          const userId = senderRecord['user_id'] as number;
          if (userId && userIdsArray.indexOf(userId) === -1) {
            userIdsArray.push(userId);
          }
        } else if (senderType === 'messageSenderChat') {
          // ⭐ 群组关联的频道消息，使用 chat_id
          const chatId = senderRecord['chat_id'] as number;
          if (chatId && chatIdsArray.indexOf(chatId) === -1) {
            chatIdsArray.push(chatId);
          }
        }
      }
    }
    
    // 批量获取用户信息
    const userInfoMap = new Map<number, UserInfo>();
    for (const userId of userIdsArray) {
      const userInfo = await this.getUserInfo(userId);
      userInfoMap.set(userId, userInfo);
    }
    
    // ⭐ 批量获取聊天信息（用于群组关联的频道消息）
    interface ChatInfo { name: string; avatar: string }
    const chatInfoMap = new Map<number, ChatInfo>();
    for (const chatId of chatIdsArray) {
      const chat = this.getChat(chatId);
      if (chat) {
        const chatInfo: ChatInfo = { name: chat.title || '', avatar: chat.avatar || '' };
        chatInfoMap.set(chatId, chatInfo);
      } else {
        // 异步获取聊天信息
        try {
          const chatData = await this.tdLibApi.getChat(chatId);
          if (chatData) {
            const chatJson = JSON.stringify(chatData);
            const chatRecord = JSON.parse(chatJson) as Record<string, string>;
            const title = chatRecord['title'] || '';
            const chatInfo: ChatInfo = { name: title, avatar: '' };
            chatInfoMap.set(chatId, chatInfo);
          }
        } catch (e) {
          hilog.warn(0x0001, 'CoreService', `Failed to get chat info for ${chatId}: ${JSON.stringify(e)}`);
        }
      }
    }
    
    // 构建消息列表
    for (const msg of tdMessages) {
      const msgJson = JSON.stringify(msg);
      const msgRecord = JSON.parse(msgJson) as Record<string, Object>;
      const senderId = msgRecord['sender_id'];
      let userId = 0;
      let chatId = 0;
      let senderType: string | undefined = undefined;
      
      if (senderId && typeof senderId === 'object') {
        const senderRecord = senderId as Record<string, Object>;
        senderType = (senderRecord['@type'] || senderRecord['_']) as string;
        
        if (senderType === 'messageSenderUser') {
          userId = (senderRecord['user_id'] as number) || 0;
        } else if (senderType === 'messageSenderChat') {
          chatId = (senderRecord['chat_id'] as number) || 0;
        }
      }
      
      // ⭐ 根据发送者类型获取对应的信息
      let finalUserInfo: UserInfo;
      if (senderType === 'messageSenderChat' && chatId > 0) {
        // 群组关联的频道消息，使用聊天信息
        const chatInfo = chatInfoMap.get(chatId);
        if (chatInfo !== undefined) {
          finalUserInfo = { name: chatInfo.name, avatar: chatInfo.avatar };
        } else {
          finalUserInfo = { name: '', avatar: '' };
        }
      } else {
        // 普通用户消息
        const userInfo = userInfoMap.get(userId);
        finalUserInfo = userInfo !== undefined ? userInfo : { name: '', avatar: '' };
      }
      
      const msgId = msgRecord['id'] as number;
      const msgChatId = msgRecord['chat_id'] as number;
      const msgDate = msgRecord['date'] as number;
      const msgIsOutgoing = msgRecord['is_outgoing'] as boolean;
      
      // ⭐ 提取回复消息ID - TDLib 中字段是 reply_to（对象），不是 reply_to_message_id
      const replyToRaw = msgRecord['reply_to'] as Record<string, Object> | undefined;
      let replyToMessageId: number | undefined = undefined;
      if (replyToRaw) {
        const replyMsgId = replyToRaw['message_id'] as number | undefined;
        if (replyMsgId && replyMsgId > 0) {
          replyToMessageId = replyMsgId;
          hilog.info(0x0001, 'CoreService', `Message ${msgId} has replyTo: ${replyToMessageId}`);
        }
      }
      
      // ⭐ 提取消息附加信息（文件、位置、联系人、投票等）
      const fileInfo = this.extractFileInfo(msgRecord);
      const locationInfo = this.extractLocationInfo(msgRecord);
      const contactInfo = this.extractContactInfo(msgRecord);
      const pollInfo = this.extractPollInfo(msgRecord);
      const duration = this.extractDuration(msgRecord);

      // ⭐ 提取作者签名和频道帖子标记（用于区分频道身份和个人身份）
      const authorSignature = (msgRecord['author_signature'] || msgRecord['_author_signature']) as string | undefined;
      // TDLib 可能使用 is_channel_post 或 isChannelPost 作为字段名
      const isChannelPost = (msgRecord['is_channel_post'] as boolean) ?? (msgRecord['isChannelPost'] as boolean) ?? false;

      // ⭐ 调试：打印频道消息相关信息
      if (chatType === ChatType.CHANNEL) {
        hilog.info(0x0001, 'CoreService',
          `Channel message ${msgId}: chatType=${chatType}, isChannelPost=${isChannelPost}, authorSignature=${authorSignature || 'none'}, isOutgoing=${msgIsOutgoing}`);
      }

      // ⭐ 如果是频道消息且有作者签名，使用签名作为发送者名称
      let senderName = finalUserInfo.name;
      // ⭐ 如果用户名为空，尝试使用作者签名或显示默认名称
      if (!senderName || senderName.trim() === '') {
        senderName = authorSignature || 'Unknown';
      }
      if (isChannelPost && authorSignature) {
        senderName = authorSignature;
      }

      const message: Message = {
        id: msgId,
        chatId: msgChatId,
        senderId: senderType === 'messageSenderChat' ? chatId : userId,
        senderName: senderName,
        senderAvatar: finalUserInfo.avatar, // ⭐ 添加发送者头像
        type: this.mapTdMessageType(msgRecord),
        content: this.mapTdMessageContent(msgRecord),
        timestamp: msgDate * 1000,
        status: MessageStatus.READ,
        isOutgoing: msgIsOutgoing,
        reactions: [],
        isPinned: false,
        canBeEdited: false,
        canBeDeleted: false,
        hasProtectedContent: false,
        // ⭐ 新增字段
        file: fileInfo,
        location: locationInfo,
        contact: contactInfo,
        poll: pollInfo,
        duration: duration,
        // ⭐ 频道消息身份标识
        authorSignature: authorSignature,
        isChannelPost: isChannelPost,
        // ⭐ 回复消息ID
        replyToMessageId: replyToMessageId
      };
      messages.push(message);
    }
    
    // ⭐ 关键修复：过滤掉已删除的消息（防止 TDLib 重启后返回已删除的消息）
    const originalCount = messages.length;
    const filteredMessages = messages.filter(msg => !this.deletedMessageIds.has(msg.id));
    if (filteredMessages.length < originalCount) {
      hilog.info(0x0001, 'CoreService', `🗑️ Filtered out ${originalCount - filteredMessages.length} deleted messages from TDLib response`);
    }
    
    return filteredMessages;
  }

  /**
   * 获取用户信息（公开方法）
   * 优先从内存缓存获取，其次从数据库获取，最后从 TDLib 获取并持久化
   */
  public async getUserInfo(userId: number): Promise<UserInfo> {
    // 1. 优先从内存缓存获取
    const cached = this.userCache.get(userId);
    if (cached) {
      return cached;
    }

    // 2. 从数据库获取
    if (this.cacheStorage) {
      try {
        const dbUser = await this.cacheStorage.getUserWithCache(userId);
        if (dbUser) {
          const userInfo: UserInfo = {
            name: `${dbUser.firstName} ${dbUser.lastName}`.trim(),
            avatar: '',
            isBot: dbUser.isBot,
            isPremium: dbUser.isPremium
          };
          // 尝试获取头像路径
          if (dbUser.profilePhotoFileId) {
            // 头像路径需要从本地文件系统获取，这里简化处理
            userInfo.avatar = dbUser.profilePhotoFileId;
          }
          this.userCache.set(userId, userInfo);
          hilog.debug(0x0001, 'CoreService', `User ${userId} loaded from database`);
          return userInfo;
        }
      } catch (error) {
        hilog.warn(0x0001, 'CoreService', `Failed to load user ${userId} from database: ${JSON.stringify(error)}`);
      }
    }

    // 3. 从 TDLib 获取并保存到数据库
    try {
      const userResult = await this.tdLibApi.getUser(userId);
      if (userResult) {
        const userJson = JSON.stringify(userResult);
        const userRecord = JSON.parse(userJson) as Record<string, Object>;

        const firstName = userRecord['first_name'] as string || '';
        const lastName = userRecord['last_name'] as string || '';
        const userName = firstName + (lastName ? ` ${lastName}` : '');

        const userInfo: UserInfo = {
          name: userName,
          avatar: '',
          isBot: (userRecord['type'] as Record<string, string>)?.['@type'] === 'userTypeBot',
          isPremium: userRecord['is_premium'] as boolean || false
        };

        const profilePhoto = userRecord['profile_photo'] as Record<string, Object> | undefined;
        if (profilePhoto) {
          const small = profilePhoto['small'] as Record<string, Object> | undefined;
          if (small) {
            const fileId = small['id'] as number | undefined;
            const local = small['local'] as Record<string, Object> | undefined;
            if (local) {
              const localPath = (local['path'] as string) || '';
              userInfo.avatar = localPath;
              
              // ⭐ 如果本地没有头像但有 fileId，触发异步下载
              if (!localPath && fileId && fileId > 0) {
                hilog.info(0x0001, 'CoreService', `User ${userId} avatar not downloaded, triggering download for fileId: ${fileId}`);
                this.triggerUserAvatarDownload(fileId, userId);
              }
            }
          }
        }

        // 保存到内存缓存
        this.userCache.set(userId, userInfo);

        // ⭐ 保存到数据库（异步，不阻塞返回）
        if (this.cacheStorage) {
          try {
            const tdlibConverterModule = await import('../core/TdlibConverter');
            const userEntity = tdlibConverterModule.TdlibConverter.convertToUser(userRecord);
            await this.cacheStorage.saveUser(userEntity);
            hilog.debug(0x0001, 'CoreService', `User ${userId} saved to database`);
          } catch (saveError) {
            hilog.warn(0x0001, 'CoreService', `Failed to save user ${userId} to database: ${JSON.stringify(saveError)}`);
          }
        }

        hilog.debug(0x0001, 'CoreService', `Cached user ${userId}: ${userName}, isBot=${userInfo.isBot}, isPremium=${userInfo.isPremium}`);
        return userInfo;
      }
    } catch (error) {
      AppLogger.error('CoreService', `Get user info failed for userId: ${userId}`, error as Error);
    }

    return { name: '', avatar: '' };
  }

  /**
   * ⭐ 同步获取缓存中的用户信息（用于聊天列表显示优化）
   * @param userId 用户ID
   * @returns 用户信息（如果缓存中存在），否则返回 null
   */
  public getCachedUserInfo(userId: number): UserInfo | null {
    const cached = this.userCache.get(userId);
    if (cached) {
      return cached;
    }
    return null;
  }

  /**
   * 映射 TDLib 消息类型
   */
  private mapTdMessageType(msg: Object): MessageType {
    const content = (msg as Record<string, Object>)['content'];
    if (!content || typeof content !== 'object') {
      return MessageType.TEXT;
    }

    const contentType = (content as Record<string, string>)['@type'];
    switch (contentType) {
      case 'messageText':
        return MessageType.TEXT;
      case 'messagePhoto':
        return MessageType.PHOTO;
      case 'messageVideo':
        return MessageType.VIDEO;
      case 'messageVoiceNote':
        return MessageType.VOICE_NOTE;
      case 'messageDocument':
        return MessageType.DOCUMENT;
      case 'messageSticker':
        return MessageType.STICKER;
      case 'messageAnimation':
        return MessageType.ANIMATION;
      case 'messageLocation':
        return MessageType.LOCATION;
      case 'messageContact':
        return MessageType.CONTACT;
      case 'messagePoll':
        return MessageType.POLL;
      case 'messageGame':
        return MessageType.GAME;
      case 'messageAudio':
        return MessageType.AUDIO;
      // 服务消息
      case 'messageChatAddMembers':
      case 'messageChatDeleteMember':
      case 'messageChatChangeTitle':
      case 'messageChatChangePhoto':
      case 'messagePinMessage':
        return MessageType.SYSTEM;
      default:
        return MessageType.TEXT;
    }
  }

  /**
   * 映射 TDLib 消息内容
   */
  private mapTdMessageContent(msg: Object): MessageContent {
    const content = (msg as Record<string, Object>)['content'];
    if (!content || typeof content !== 'object') {
      return {};
    }

    const contentType = (content as Record<string, string>)['@type'];

    switch (contentType) {
      case 'messageText': {
        const textContent = (content as Record<string, Object>)['text'];
        let text = '';
        if (textContent && typeof textContent === 'object') {
          text = (textContent as Record<string, string>)['text'] || '';
        }
        const messageContent: MessageContent = { text };
        return messageContent;
      }
      case 'messagePhoto': {
        const captionContent = (content as Record<string, Object>)['caption'];
        let caption = '';
        if (captionContent && typeof captionContent === 'object') {
          caption = (captionContent as Record<string, string>)['text'] || '';
        }
        const messageContent: MessageContent = { caption };
        return messageContent;
      }
      case 'messageVideo': {
        const captionContent = (content as Record<string, Object>)['caption'];
        let caption = '';
        if (captionContent && typeof captionContent === 'object') {
          caption = (captionContent as Record<string, string>)['text'] || '';
        }
        const messageContent: MessageContent = { caption };
        return messageContent;
      }
      default:
        return {};
    }
  }

  /**
   * 从 TDLib 内容对象提取 MessageContent
   * 用于消息编辑更新时转换新内容
   */
  private extractContentFromTdlib(content: Record<string, Object>): MessageContent {
    if (!content) return {};
    
    const contentType = content['@type'] as string | undefined;
    
    switch (contentType) {
      case 'messageText': {
        const textContent = content['text'] as Record<string, Object> | undefined;
        let text = '';
        if (textContent && typeof textContent === 'object') {
          text = (textContent['text'] as string) || '';
        }
        return { text };
      }
      case 'messagePhoto': {
        const captionContent = content['caption'] as Record<string, Object> | undefined;
        let caption = '';
        if (captionContent && typeof captionContent === 'object') {
          caption = (captionContent['text'] as string) || '';
        }
        return { caption };
      }
      case 'messageVideo': {
        const captionContent = content['caption'] as Record<string, Object> | undefined;
        let caption = '';
        if (captionContent && typeof captionContent === 'object') {
          caption = (captionContent['text'] as string) || '';
        }
        return { caption };
      }
      case 'messageDocument': {
        const captionContent = content['caption'] as Record<string, Object> | undefined;
        let caption = '';
        if (captionContent) {
          caption = (captionContent['text'] as string) || '';
        }
        return { caption };
      }
      default:
        return {};
    }
  }

  /**
   * 提取消息文本内容（用于预览）
   */
  private extractMessageText(messageObj: Record<string, Object>): string {
    const content = messageObj['content'] as Record<string, Object> | undefined;
    if (!content) return '';
    
    const contentType = content['@type'] as string | undefined;
    
    // 1. 文本消息
    if (contentType === 'messageText') {
      const textContent = content['text'] as Record<string, Object> | undefined;
      if (textContent) {
        return (textContent['text'] as string) || '';
      }
    }
    // 2. 图片/视频（带配文）
    else if (contentType === 'messagePhoto' || contentType === 'messageVideo') {
      const captionContent = content['caption'] as Record<string, Object> | undefined;
      if (captionContent) {
        return (captionContent['text'] as string) || '';
      }
    }
    // 3. 文档（文件名 + 配文）
    else if (contentType === 'messageDocument') {
      const document = content['document'] as Record<string, Object> | undefined;
      if (document) {
        const fileName = (document['file_name'] as string) || '文件';
        const captionContent = content['caption'] as Record<string, Object> | undefined;
        const caption = captionContent ? (captionContent['text'] as string) : '';
        return caption ? `${fileName}: ${caption}` : fileName;
      }
    }
    // 4. 联系人
    else if (contentType === 'messageContact') {
      const contactFirstName = (content['first_name'] as string) || '';
      const contactLastName = (content['last_name'] as string) || '';
      return contactFirstName + (contactLastName ? ` ${contactLastName}` : '');
    }
    // 5. 投票
    else if (contentType === 'messagePoll') {
      const question = (content['question'] as string) || '投票';
      return `📊 投票: ${question}`;
    }
    // 6. 游戏
    else if (contentType === 'messageGame') {
      const game = content['game'] as Record<string, Object> | undefined;
      if (game) {
        const title = (game['title'] as string) || '游戏';
        return `🎮 ${title}`;
      }
    }
    // 7. 服务消息 - 成员加入
    else if (contentType === 'messageChatAddMembers') {
      const memberIds = content['member_user_ids'] as Array<number> | undefined;
      if (memberIds && memberIds.length > 0) {
        // 简化处理：显示“用户加入了群组”
        return 'ℹ️ 用户加入了群组';
      }
    }
    // 8. 服务消息 - 成员离开
    else if (contentType === 'messageChatDeleteMember') {
      return 'ℹ️ 用户离开了群组';
    }
    // 9. 服务消息 - 标题更改
    else if (contentType === 'messageChatChangeTitle') {
      const newTitle = (content['title'] as string) || '';
      return `ℹ️ 群名称已更改为 ${newTitle}`;
    }
    
    return '';
  }

  /**
   * ⭐ 提取文件信息（用于文件消息）
   */
  private extractFileInfo(msgRecord: Record<string, Object>): FileInfo | undefined {
    const content = msgRecord['content'] as Record<string, Object> | undefined;
    if (!content) return undefined;
    
    const contentType = content['@type'] as string | undefined;
    
    // 文档消息
    if (contentType === 'messageDocument') {
      const document = content['document'] as Record<string, Object> | undefined;
      if (document) {
        const documentId = document['id'] as number || 0;
        const remoteId = document['remote'] as Record<string, Object> | undefined;
        const remoteUniqueId = remoteId ? (remoteId['unique_id'] as string) || '' : '';
        const size = document['size'] as number || 0;
        const local = document['local'] as Record<string, Object> | undefined;
        const path = local ? (local['path'] as string) || '' : '';
        const fileName = (document['file_name'] as string) || '';
        
        return {
          id: documentId,
          remoteId: remoteUniqueId,
          size: size,
          path: path,
          fileName: fileName
        };
      }
    }
    
    return undefined;
  }

  /**
   * ⭐ 提取位置信息（用于位置消息）
   */
  private extractLocationInfo(msgRecord: Record<string, Object>): LocationInfo | undefined {
    const content = msgRecord['content'] as Record<string, Object> | undefined;
    if (!content) return undefined;
    
    const contentType = content['@type'] as string | undefined;
    
    if (contentType === 'messageLocation') {
      const location = content['location'] as Record<string, Object> | undefined;
      if (location) {
        const latitude = location['latitude'] as number || 0;
        const longitude = location['longitude'] as number || 0;
        
        // 尝试获取场所信息
        const venue = content['venue'] as Record<string, Object> | undefined;
        let title = '';
        let address = '';
        
        if (venue) {
          title = (venue['title'] as string) || '';
          address = (venue['address'] as string) || '';
        }
        
        return {
          latitude: latitude,
          longitude: longitude,
          title: title,
          address: address
        };
      }
    }
    
    return undefined;
  }

  /**
   * ⭐ 提取联系人信息（用于联系人消息）
   */
  private extractContactInfo(msgRecord: Record<string, Object>): ContactInfo | undefined {
    const content = msgRecord['content'] as Record<string, Object> | undefined;
    if (!content) return undefined;
    
    const contentType = content['@type'] as string | undefined;
    
    if (contentType === 'messageContact') {
      const contact = content['contact'] as Record<string, Object> | undefined;
      if (contact) {
        const phoneNumber = (contact['phone_number'] as string) || '';
        const firstName = (contact['first_name'] as string) || '';
        const lastName = (contact['last_name'] as string) || '';
        const userId = contact['user_id'] as number | undefined;
        
        return {
          phoneNumber: phoneNumber,
          firstName: firstName,
          lastName: lastName,
          userId: userId
        };
      }
    }
    
    return undefined;
  }

  /**
   * ⭐ 提取投票信息（用于投票消息）
   */
  private extractPollInfo(msgRecord: Record<string, Object>): PollInfo | undefined {
    const content = msgRecord['content'] as Record<string, Object> | undefined;
    if (!content) return undefined;
    
    const contentType = content['@type'] as string | undefined;
    
    if (contentType === 'messagePoll') {
      const poll = content['poll'] as Record<string, Object> | undefined;
      if (poll) {
        const pollId = (poll['id'] as string) || '';
        const question = (poll['question'] as string) || '';
        const options = poll['options'] as Array<Record<string, Object>> || [];
        const totalVoterCount = poll['total_voter_count'] as number || 0;
        const isClosed = poll['is_closed'] as boolean || false;
        const isAnonymous = poll['is_anonymous'] as boolean || true;
        const pollType = (poll['type'] as Record<string, Object>)?.['@type'] === 'pollTypeQuiz' ? 'quiz' : 'regular';
        const allowsMultipleAnswers = poll['type'] as Record<string, Object> !== undefined ? 
          ((poll['type'] as Record<string, Object>)['allow_multiple_answers'] as boolean || false) : false;
        
        const pollOptions: PollOption[] = options.map((opt: Record<string, Object>) => {
          const option: PollOption = {
            text: (opt['text'] as string) || '',
            voterCount: opt['voter_count'] as number || 0,
            isSelected: opt['is_chosen'] as boolean || false
          };
          return option;
        });
        
        return {
          id: pollId,
          question: question,
          options: pollOptions,
          totalVoterCount: totalVoterCount,
          isClosed: isClosed,
          isAnonymous: isAnonymous,
          type: pollType as 'regular' | 'quiz',
          allowsMultipleAnswers: allowsMultipleAnswers
        };
      }
    }
    
    return undefined;
  }

  /**
   * ⭐ 提取时长（用于语音、视频、音频消息）
   */
  private extractDuration(msgRecord: Record<string, Object>): number | undefined {
    const content = msgRecord['content'] as Record<string, Object> | undefined;
    if (!content) return undefined;
    
    const contentType = content['@type'] as string | undefined;
    
    if (contentType === 'messageVoiceNote') {
      const voiceNote = content['voice_note'] as Record<string, Object> | undefined;
      if (voiceNote) {
        return voiceNote['duration'] as number | undefined;
      }
    } else if (contentType === 'messageVideo') {
      const video = content['video'] as Record<string, Object> | undefined;
      if (video) {
        return video['duration'] as number | undefined;
      }
    } else if (contentType === 'messageAudio') {
      const audio = content['audio'] as Record<string, Object> | undefined;
      if (audio) {
        return audio['duration'] as number | undefined;
      }
    } else if (contentType === 'messageVideoNote') {
      const videoNote = content['video_note'] as Record<string, Object> | undefined;
      if (videoNote) {
        return videoNote['duration'] as number | undefined;
      }
    }
    
    return undefined;
  }

  /**
   * 构建 InputMessageText 对象
   */
  private buildInputMessageTextObject(text: string): inputMessageText {
    const formattedTextObj: formattedText = {
      _: 'formattedText',
      text: text,
      entities: []
    };
    
    const inputMsg: inputMessageText = {
      _: 'inputMessageText',
      text: formattedTextObj,
      clear_draft: false
    };
    
    return inputMsg;
  }

  /**
   * 构建 InputMessagePhoto 对象
   */
  private buildInputMessagePhotoObject(imagePath: string): inputMessagePhoto {
    const inputFile: inputFileLocal = {
      _: 'inputFileLocal',
      path: imagePath
    };
    
    // 创建空的 caption
    const emptyCaption: formattedText = {
      _: 'formattedText',
      text: '',
      entities: []
    };
    
    // 创建默认的自毁类型（无自毁）
    // 使用 messageSelfDestructTypeImmediately 作为默认值，设置时间为 0
    const noSelfDestruct: messageSelfDestructTypeImmediately = {
      _: 'messageSelfDestructTypeImmediately'
    };
    
    // 创建缩略图对象
    const inputThumbnailObj: inputThumbnail = {
      _: 'inputThumbnail',
      thumbnail: inputFile,
      width: 0,
      height: 0
    };
    
    // ⭐ 创建 inputPhoto 对象（TDLib 更新后需要这层包装）
    const inputPhotoObj: inputPhoto = {
      _: 'inputPhoto',
      photo: inputFile,
      thumbnail: inputThumbnailObj,
      width: 0,
      height: 0
    };
    
    const inputMsg: inputMessagePhoto = {
      _: 'inputMessagePhoto',
      photo: inputPhotoObj,
      caption: emptyCaption,
      show_caption_above_media: false,
      self_destruct_type: noSelfDestruct,
      has_spoiler: false
    };
    
    return inputMsg;
  }

  // ==================== 事件处理器（由 UpdateService 调用） ====================
  /**
   * 处理聊天最后消息变更（由 UpdateService 调用）
   * @param chatId 聊天ID
   */
  public onChatLastMessageChanged(chatId: number): void {
    if (chatId) {
      // ⭐ 使用防抖刷新，避免 updateChatLastMessage 和 updateChatOrder 快速连续触发导致的排序抖动
      this.refreshChatWithDebounce(chatId);
    }
  }

  /**
   * 处理聊天草稿消息变更（由 UpdateService 调用）
   * ⭐ Nagram 参考：先写数据库（putChats），再更新内存 + UI
   * @param chatId 聊天ID
   * @param draftMessageObj 草稿消息对象
   */
  public async onChatDraftMessageChanged(chatId: number, draftMessageObj: Record<string, Object> | null | undefined): Promise<void> {
    if (chatId) {
      const chat = this.getChat(chatId);
      if (chat) {
        if (draftMessageObj && draftMessageObj['_']) {
          const inputMsgText = draftMessageObj['input_message_text'] as Record<string, Object> | undefined;
          if (inputMsgText) {
            const textContent = inputMsgText['text'] as Record<string, Object> | undefined;
            if (textContent) {
              const text = textContent['text'] as string || '';
              const draftMessage: DraftMessage = {
                text,
                entities: [],
                date: Date.now()
              };
              chat.draftMessage = draftMessage;
            }
          }
        } else {
          chat.draftMessage = undefined;
        }
        
        // ⭐ Nagram 参考：先保存到数据库
        if (this.cacheStorage) {
          try {
            const entity = this.convertChatToEntity(chat);
            await this.cacheStorage.saveChat(entity);
            hilog.info(0x0001, 'CoreService', `💾 [DB-FIRST] Chat ${chatId} draft message saved to DB`);
          } catch (error) {
            hilog.warn(0x0001, 'CoreService', `Failed to save chat ${chatId} draft to DB: ${JSON.stringify(error)}`);
          }
        }
        
        this.publishChatListChanged();
      }
    }
  }

  /**
   * 处理用户状态更新（由 UpdateService 调用）
   * @param userId 用户ID
   * @param statusObj 状态对象
   */
  public onUserStatusUpdated(userId: number, statusObj: Record<string, Object>): void {
    if (userId && statusObj) {
      for (const chat of this.chatList) {
        if (chat.userId === userId) {
          const statusType = statusObj['_'] as string | undefined;
          let userStatus: UserStatus;
          
          switch (statusType) {
            case 'userStatusOnline':
              userStatus = { _: 'userStatusOnline', expires: statusObj['expires'] as number };
              break;
            case 'userStatusOffline':
              userStatus = { _: 'userStatusOffline', was_online: statusObj['was_online'] as number };
              break;
            case 'userStatusRecently':
              userStatus = { _: 'userStatusRecently', by_my_privacy_settings: statusObj['by_my_privacy_settings'] as boolean || false };
              break;
            case 'userStatusLastWeek':
              userStatus = { _: 'userStatusLastWeek', by_my_privacy_settings: statusObj['by_my_privacy_settings'] as boolean || false };
              break;
            case 'userStatusLastMonth':
              userStatus = { _: 'userStatusLastMonth', by_my_privacy_settings: statusObj['by_my_privacy_settings'] as boolean || false };
              break;
            default:
              userStatus = { _: 'userStatusEmpty' };
          }
          
          chat.userStatus = userStatus;
          
          this.publishChatListChanged();
          break;
        }
      }
      
      // 发送领域事件通知 ViewModel
      const eventData: Record<string, Object> = new Object() as Record<string, Object>;
      eventData['userId'] = userId as Object;
      eventData['status'] = statusObj as Object;
      eventBus.emit('core:userStatusUpdated', eventData);
    }
  }

  /**
   * 处理聊天标题变更（由 UpdateService 调用）
   * ⭐ Nagram 参考：先写数据库（putChats），再更新内存 + UI
   * @param chatId 聊天ID
   * @param title 新标题
   */
  public async onChatTitleChanged(chatId: number, title: string): Promise<void> {
    if (chatId && title) {
      const chat = this.getChat(chatId);
      if (chat) {
        chat.title = title;
        
        // ⭐ Nagram 参考：先保存到数据库
        if (this.cacheStorage) {
          try {
            const entity = this.convertChatToEntity(chat);
            await this.cacheStorage.saveChat(entity);
            hilog.info(0x0001, 'CoreService', `💾 [DB-FIRST] Chat ${chatId} title saved to DB: "${title}"`);
          } catch (error) {
            hilog.warn(0x0001, 'CoreService', `Failed to save chat ${chatId} title to DB: ${JSON.stringify(error)}`);
          }
        }
        
        this.publishChatListChanged();
      }
    }
  }

  /**
   * 处理聊天头像变更（由 UpdateService 调用）
   * @param chatId 聊天ID
   */
  public onChatPhotoChanged(chatId: number): void {
    if (chatId) {
      this.refreshChat(chatId);
    }
  }

  /**
   * 处理聊天未读提及数变更（由 UpdateService 调用）
   * @param chatId 聊天ID
   * @param unreadMentionCount 未读提及数
   */
  public onChatUnreadMentionCountChanged(chatId: number, unreadMentionCount: number): void {
    if (chatId) {
      const chat = this.getChat(chatId);
      if (chat) {
        chat.unreadMentionCount = unreadMentionCount || 0;
        this.publishChatListChanged();
      }
    }
  }
  
  /**
   * 立即刷新聊天信息（实时更新，无防抖）
   * @param chatId 聊天ID
   */
  private refreshChatWithDebounce(chatId: number): void {
    // ⭐ 实时更新：立即执行，无防抖延迟
    this.refreshChat(chatId).catch((err: Error) => {
      hilog.error(0x0001, 'CoreService', `refreshChat failed: ${err.message}`);
    });
  }

  /**
   * 处理聊天顺序变更（由 UpdateService 调用）
   * @param chatId 聊天ID
   */
  public onChatOrderChanged(chatId: number): void {
    if (chatId) {
      // ⭐ 使用防抖刷新，与 onChatLastMessageChanged 共享防抖计时器
      this.refreshChatWithDebounce(chatId);
    }
  }
  
  /**
   * 处理聊天置顶状态变更（由 UpdateService 调用）
   * @param chatId 聊天ID
   */
  public onChatIsPinnedChanged(chatId: number): void {
    // 🔧 TDLib updateChatIsPinned 事件也不直接返回 is_pinned
    // 需要刷新聊天信息从 positions 判断
    
    hilog.info(0x0001, 'CoreService',
      `📌 onChatIsPinnedChanged: chatId=${chatId}`);
    
    if (chatId) {
      // 刷新该聊天的完整信息（包括 positions）
      this.refreshChat(chatId);
    }
  }
  
  /**
   * 处理聊天通知设置变更（由 UpdateService 调用）
   * ⭐ Nagram 参考：先写数据库（putChats），再更新内存 + UI
   * @param chatId 聊天ID
   * @param settings 通知设置
   */
  public async onChatNotificationSettingsChanged(chatId: number, settings: Record<string, Object> | undefined): Promise<void> {
    if (chatId && settings) {
      const chat = this.getChat(chatId);
      if (chat) {
        const muteFor = settings['mute_for'] as number || 0;
        chat.isMuted = muteFor > 0;
        
        // ⭐ Nagram 参考：先保存到数据库
        if (this.cacheStorage) {
          try {
            const entity = this.convertChatToEntity(chat);
            await this.cacheStorage.saveChat(entity);
            hilog.info(0x0001, 'CoreService', `💾 [DB-FIRST] Chat ${chatId} notification settings saved to DB`);
          } catch (error) {
            hilog.warn(0x0001, 'CoreService', `Failed to save chat ${chatId} notification settings to DB: ${JSON.stringify(error)}`);
          }
        }
        
        this.publishChatListChanged();
      }
    }
  }
  
  /**
   * 处理用户信息更新（由 UpdateService 调用）
   * @param userId 用户ID
   */
  public onUserUpdated(userId: number): void {
    if (userId) {
      // 清除用户缓存，下次获取时会重新拉取
      this.userCache.delete(userId);
      
      // 刷新所有与该用户相关的私聊
      for (const chat of this.chatList) {
        if (chat.userId === userId) {
          this.refreshChat(chat.id);
          break;
        }
      }
      
      // 发送领域事件通知 ViewModel
      const userEventData: Record<string, Object> = new Object() as Record<string, Object>;
      userEventData['userId'] = userId as Object;
      eventBus.emit('core:userUpdated', userEventData);
    }
  }
  
  /**
   * 触发头像异步下载（通过 FileDownloadService + CacheService）
   */
  private triggerAvatarDownload(fileId: number, chatId: number): void {
    try {
      // 延迟初始化 FileDownloadService
      if (!this.fileDownloadService) {
        hilog.warn(0x0001, 'CoreService', 'FileDownloadService not initialized yet, skipping avatar download');
        return;
      }
      
      // 异步触发下载，不阻塞当前流程
      // 使用 PROFILE_PHOTO 类型，头像有独立的下载策略和大小限制
      this.fileDownloadService.downloadFile(
        fileId,
        FileType.PROFILE_PHOTO,
        DownloadPriority.HIGH  // 头像优先下载
      ).then(async (path: string) => {
        hilog.info(0x0001, 'CoreService', `✅ Avatar downloaded for chat ${chatId}: ${path}`);
        
        // 从文件读取数据并缓存到 CacheService
        try {
          const file = await fs.open(path, fs.OpenMode.READ_ONLY);
          const stat = await fs.stat(path);
          const buffer = new ArrayBuffer(stat.size);
          await fs.read(file.fd, buffer, { offset: 0, length: stat.size });
          await fs.close(file);
          
          await this.cacheService.cacheAvatar(chatId, path, buffer);
          hilog.info(0x0001, 'CoreService', `✅ Avatar cached for chat ${chatId}`);
        } catch (cacheErr) {
          hilog.warn(0x0001, 'CoreService', `Failed to cache avatar: ${JSON.stringify(cacheErr)}`);
        }
        
        // ⭐ 直接更新本地缓存中的头像路径，而不是重新从 TDLib 获取
        // 因为 TDLib 可能还没有更新 photo.small.local.path
        const chat = this.getChat(chatId);
        if (chat) {
          chat.avatar = path;
          hilog.info(0x0001, 'CoreService', `✅ Updated avatar path in cache for chat ${chatId}: ${path}`);
          this.publishChatListChanged();
        } else {
          // 如果缓存中没有，尝试刷新
          this.refreshChat(chatId);
        }
      }).catch((err: Error) => {
        hilog.warn(0x0001, 'CoreService', `⚠️ Avatar download failed for chat ${chatId}: ${err.message}`);
      });
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `❌ Trigger avatar download error: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * ⭐ 触发用户头像异步下载（通过 FileDownloadService）
   * 与聊天头像下载类似，但更新用户缓存而非聊天缓存
   * 优化：传入当前活跃聊天 ID，让该聊天的头像下载获得优先级加成
   * 优化2：使用最高优先级确保头像优先下载
   */
  private triggerUserAvatarDownload(fileId: number, userId: number): void {
    try {
      // 延迟初始化 FileDownloadService
      if (!this.fileDownloadService) {
        hilog.warn(0x0001, 'CoreService', 'FileDownloadService not initialized yet, skipping user avatar download');
        return;
      }
      
      // ⭐ 尝试找到该用户对应的私聊 chatId，用于优先级优化
      let associatedChatId: number | undefined = undefined;
      for (const chat of this.chatList) {
        if (chat.type === ChatType.PRIVATE && chat.userId === userId) {
          associatedChatId = chat.id;
          break;
        }
      }
      
      // 异步触发下载，不阻塞当前流程
      // 传入 associatedChatId，让当前活跃聊天的头像下载获得优先级加成
      // 使用 URGENT 优先级确保头像最先下载
      this.fileDownloadService.downloadFile(
        fileId,
        FileType.PROFILE_PHOTO,
        DownloadPriority.URGENT, // ⭐ 使用最高优先级
        undefined, // messageId
        associatedChatId // chatId for priority boost
      ).then(async (path: string) => {
        hilog.info(0x0001, 'CoreService', `✅ User avatar downloaded for user ${userId}: ${path}`);
        
        // ⭐ 更新用户缓存中的头像路径
        const cachedUser = this.userCache.get(userId);
        if (cachedUser) {
          cachedUser.avatar = path;
          hilog.info(0x0001, 'CoreService', `✅ Updated avatar path in user cache for user ${userId}: ${path}`);
        }
        
        // ⭐ 发送用户头像下载完成事件，通知 ViewModel 刷新
        const userAvatarEventData: Record<string, Object> = new Object() as Record<string, Object>;
        userAvatarEventData['fileId'] = fileId as Object;
        userAvatarEventData['path'] = path as Object;
        userAvatarEventData['userId'] = userId as Object;
        eventBus.emit('core:userAvatarDownloaded', userAvatarEventData);
      }).catch((err: Error) => {
        hilog.warn(0x0001, 'CoreService', `⚠️ User avatar download failed for user ${userId}: ${err.message}`);
      });
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `❌ Trigger user avatar download error: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 设置 FileDownloadService 实例（由外部调用）
   */
  public setFileDownloadService(service: FileDownloadService): void {
    this.fileDownloadService = service;
    hilog.info(0x0001, 'CoreService', '✅ FileDownloadService registered in CoreService');
  }
  
  /**
   * 处理文件更新（由 UpdateService 调用）
   * @param fileObj 文件对象
   */
  public onFileUpdated(fileObj: Record<string, Object>): void {
    if (fileObj) {
      const fileId = fileObj['id'] as number;
      const localPath = fileObj['local'] as Record<string, Object> | undefined;
      
      if (fileId && localPath) {
        const path = localPath['path'] as string | undefined;
        const isCompleted = localPath['is_downloading_completed'] as boolean;
        const isDownloading = localPath['is_downloading_active'] as boolean;
        const downloadedSize = localPath['downloaded_size'] as number || 0;
        const totalSize = fileObj['size'] as number || 0;
        const progress = totalSize > 0 ? (downloadedSize / totalSize) * 100 : 0;
        
        // 检查是否有聊天使用该文件作为头像
        let needsRefresh = false;
        let avatarChatId: number | undefined;
        for (const chat of this.chatList) {
          // 简化判断：如果聊天有头像且正在更新，则刷新
          if (chat.avatar && chat.avatar.includes(String(fileId))) {
            needsRefresh = true;
            avatarChatId = chat.id;
            break;
          }
        }
        
        if (needsRefresh) {
          this.publishChatListChanged();
        }
        
        // 发送头像下载完成的领域事件
        if (isCompleted && path) {
          const avatarEventData: Record<string, Object> = new Object() as Record<string, Object>;
          avatarEventData['fileId'] = fileId as Object;
          avatarEventData['path'] = path as Object;
          avatarEventData['chatId'] = avatarChatId as Object;
          eventBus.emit('core:avatarDownloaded', avatarEventData);
          // ⭐ Nagram 参考：累积批量变更通知
          this.scheduleBatchFlush(UPDATE_MASK_USER_AVATAR);
        }
        
        // 发送文件下载进度领域事件
        const fileProgressData: Record<string, Object> = new Object() as Record<string, Object>;
        fileProgressData['fileId'] = fileId as Object;
        fileProgressData['progress'] = progress as Object;
        fileProgressData['isCompleted'] = isCompleted as Object;
        fileProgressData['isDownloading'] = isDownloading as Object;
        fileProgressData['localPath'] = path as Object;
        // ⭐ Nagram 参考：累积批量变更通知
        this.scheduleBatchFlush(UPDATE_MASK_FILE_PROGRESS);
        eventBus.emit('core:fileDownloadProgress', fileProgressData);
      }
    }
  }

  /**
   * 处理消息发送成功（由 UpdateService 调用）
   * ⭐ Nagram 参考：先写数据库（putMessages），再更新内存 + UI
   * @param oldMessageId 旧消息ID
   * @param message 消息对象
   */
  public async onMessageSendSucceeded(oldMessageId: number, message: Record<string, Object>): Promise<void> {
    if (!message) return;
    
    const chatId = message['chat_id'] as number;
    const newMessageId = message['id'] as number;
    
    hilog.info(0x0001, 'CoreService', `Message send succeeded: ${oldMessageId} -> ${newMessageId} in chat ${chatId}`);
    
    // ⭐ Nagram 参考：先保存消息到数据库（putMessages 等价）
    if (this.cacheStorage) {
      try {
        await this.saveMessageToDatabase(message, chatId);
        hilog.info(0x0001, 'CoreService', `💾 [DB-FIRST] Message ${newMessageId} saved to database (send success)`);
      } catch (error) {
        hilog.error(0x0001, 'CoreService', `Failed to save message to database: ${JSON.stringify(error)}`);
      }
    }
    
    // 更新本地消息缓存
    const chatMessages = this.messagesMap.get(chatId);
    if (chatMessages) {
      const oldMsg = chatMessages.find(m => m.id === oldMessageId);
      if (oldMsg) {
        oldMsg.id = newMessageId;
        oldMsg.status = MessageStatus.SENT;
        // 触发领域事件通知 ViewModel
        const messageSentData: Record<string, Object> = new Object() as Record<string, Object>;
        messageSentData['chatId'] = chatId as Object;
        messageSentData['oldMessageId'] = oldMessageId as Object;
        messageSentData['newMessageId'] = newMessageId as Object;
        messageSentData['message'] = oldMsg as Object;
        // ⭐ Nagram 参考：累积批量变更通知
        this.scheduleBatchFlush(UPDATE_MASK_MESSAGE_SENT);
        eventBus.emit('core:messageSent', messageSentData);
      }
    }
    
    // 刷新聊天列表
    this.refreshChat(chatId);
  }

  /**
   * 处理消息发送失败（由 UpdateService 调用）
   * @param messageId 消息ID
   * @param chatId 聊天ID
   * @param error 错误对象
   */
  public onMessageSendFailed(messageId: number, chatId: number, error: Record<string, Object>): void {
    hilog.warn(0x0001, 'CoreService', `Message send failed: ${messageId} in chat ${chatId}, error: ${JSON.stringify(error)}`);
    
    // 更新本地消息状态
    const chatMessages = this.messagesMap.get(chatId);
    if (chatMessages) {
      const msg = chatMessages.find(m => m.id === messageId);
      if (msg) {
        msg.status = MessageStatus.FAILED;
        // 触发领域事件通知 ViewModel
        const messageFailedData: Record<string, Object> = new Object() as Record<string, Object>;
        messageFailedData['chatId'] = chatId as Object;
        messageFailedData['messageId'] = messageId as Object;
        messageFailedData['error'] = error as Object;
        // ⭐ Nagram 参考：累积批量变更通知
        this.scheduleBatchFlush(UPDATE_MASK_MESSAGE_FAILED);
        eventBus.emit('core:messageFailed', messageFailedData);
      }
    }
  }

  /**
   * 处理消息内容编辑（由 UpdateService 调用）
   * ⭐ Nagram 参考：先写数据库（putMessages），再更新内存 + UI
   * @param chatId 聊天ID
   * @param messageId 消息ID
   * @param newContent 新内容
   */
  public async onMessageContentEdited(chatId: number, messageId: number, newContent: Record<string, Object>): Promise<void> {
    hilog.info(0x0001, 'CoreService', `Message content updated: ${messageId} in chat ${chatId}`);
    
    // 更新本地消息缓存
    const chatMessages = this.messagesMap.get(chatId);
    if (chatMessages) {
      const msg = chatMessages.find(m => m.id === messageId);
      if (msg && newContent) {
        // 更新消息内容
        msg.content = this.extractContentFromTdlib(newContent);
        msg.isEdited = true;
        
        // ⭐ Nagram 参考：先保存消息更新到数据库
        if (this.cacheStorage && this.cacheStorage.database) {
          try {
            // 将内存中的 Message 转为数据库实体
            const tdlibConverterModule = await import('../core/TdlibConverter');
            const msgJson = JSON.stringify({
              'id': messageId,
              'chat_id': chatId,
              'content': newContent,
              'edit_date': Math.floor(Date.now() / 1000)
            });
            const msgRecord = JSON.parse(msgJson) as Record<string, Object>;
            const entity = tdlibConverterModule.TdlibConverter.convertToMessage(msgRecord, chatId);
            entity.editDate = Math.floor(Date.now() / 1000);
            await this.cacheStorage.database.updateMessage(entity);
            hilog.info(0x0001, 'CoreService', `💾 [DB-FIRST] Message ${messageId} content updated in DB`);
          } catch (error) {
            hilog.warn(0x0001, 'CoreService', `Failed to update message ${messageId} in DB: ${JSON.stringify(error)}`);
          }
        }
        
        // 触发领域事件通知 ViewModel
        const messageEditedData: Record<string, Object> = new Object() as Record<string, Object>;
        messageEditedData['chatId'] = chatId as Object;
        messageEditedData['messageId'] = messageId as Object;
        messageEditedData['message'] = msg as Object;
        // ⭐ Nagram 参考：累积批量变更通知
        this.scheduleBatchFlush(UPDATE_MASK_MESSAGE_EDITED);
        eventBus.emit('core:messageEdited', messageEditedData);
      }
    }
    
    // 刷新聊天
    this.refreshChat(chatId);
  }

  /**
   * 处理聊天动作（由 UpdateService 调用）
   * @param chatId 聊天ID
   * @param action 动作对象
   */
  public onChatAction(chatId: number, action: Record<string, Object>): void {
    if (chatId && action) {
      const actionType = action['@type'] as string;
      // 转发给所有订阅者（ViewModel 可以订阅此事件）
      const chatActionData: Record<string, Object> = new Object() as Record<string, Object>;
      chatActionData['chatId'] = chatId as Object;
      chatActionData['actionType'] = actionType as Object;
      chatActionData['action'] = action as Object;
      // ⭐ Nagram 参考：累积批量变更通知
      this.scheduleBatchFlush(UPDATE_MASK_CHAT_ACTION);
      eventBus.emit('core:chatAction', chatActionData);
    }
  }

  /**
   * 处理消息删除（由 UpdateService 调用）
   * @param chatId 聊天ID
   * @param messageIds 消息ID数组
   * @param isPermanent 是否永久删除
   */
  // ⭐ 已删除消息 ID 集合（已被 onMessagesDeleted 处理过的消息ID）
  // 用于过滤 TDLib 返回的消息列表中已删除的消息

  public async onMessagesDeleted(chatId: number, messageIds: number[], isPermanent: boolean): Promise<void> {
    if (!chatId) {
      hilog.warn(0x0001, 'CoreService', 'onMessagesDeleted: chatId is empty');
      return;
    }
    if (!messageIds || messageIds.length === 0) {
      hilog.warn(0x0001, 'CoreService', `onMessagesDeleted: messageIds is empty for chat ${chatId}`);
      return;
    }

    // ⭐ 防重检查：如果已经在处理相同的删除请求，跳过
    const deletionKey = `${chatId}_${messageIds.sort().join(',')}`;
    if (this.processedDeletions.has(deletionKey)) {
      hilog.info(0x0001, 'CoreService', `⚠️ Skipping duplicate deletion for chat ${chatId}, messages ${JSON.stringify(messageIds)}`);
      return;
    }
    // ⭐ 先标记为处理中，防止并发重复
    this.processedDeletions.add(deletionKey);
    
    // ⭐ 添加到已删除消息 ID 集合（用于过滤 TDLib 返回的已删除消息）
    for (const msgId of messageIds) {
      this.deletedMessageIds.add(msgId);
    }
    hilog.info(0x0001, 'CoreService', `🗑️ Added ${messageIds.length} message IDs to deleted set, total: ${this.deletedMessageIds.size}`);

    hilog.info(0x0001, 'CoreService', `🗑️ onMessagesDeleted: chatId=${chatId}, messageIds=${JSON.stringify(messageIds)}, isPermanent=${isPermanent}`);

    try {
      // 从本地缓存中删除消息
      const chatMessages = this.messagesMap.get(chatId);
      if (chatMessages) {
        const remainingMessages = chatMessages.filter(m => !messageIds.includes(m.id));
        if (remainingMessages.length !== chatMessages.length) {
          this.messagesMap.set(chatId, remainingMessages);
          hilog.info(0x0001, 'CoreService', `Removed ${chatMessages.length - remainingMessages.length} messages from cache, remaining=${remainingMessages.length}`);
        } else {
          hilog.info(0x0001, 'CoreService', `No messages removed from cache (already deleted), cache size=${chatMessages.length}`);
        }
      } else {
        hilog.info(0x0001, 'CoreService', `No cache found for chat ${chatId}`);
      }

      // ⭐ 从数据库中删除消息
      if (this.cacheStorage) {
        try {
          hilog.info(0x0001, 'CoreService', `💾 Starting database deletion for ${messageIds.length} messages in chat ${chatId}`);
          const result = await this.cacheStorage.database.deleteMessages(chatId, messageIds);
          if (result.success) {
            hilog.info(0x0001, 'CoreService', `✅ Database deletion succeeded: deleted ${result.data} rows for chat ${chatId}`);
          } else {
            hilog.error(0x0001, 'CoreService', `❌ Database deletion FAILED: code=${result.errorCode}, message=${result.errorMessage}`);
            // ⭐ 关键修复：数据库删除失败时，移除防重标记，允许重试
            this.processedDeletions.delete(deletionKey);
            return;
          }
        } catch (dbError) {
          hilog.error(0x0001, 'CoreService', `❌ Database deletion EXCEPTION: ${JSON.stringify(dbError)}`);
          // ⭐ 关键修复：数据库删除异常时，移除防重标记，允许重试
          this.processedDeletions.delete(deletionKey);
          return;
        }
      } else {
        hilog.warn(0x0001, 'CoreService', `⚠️ cacheStorage is null, skipping database deletion`);
      }

      // 触发领域事件通知 ViewModel
      const messageDeletedData: Record<string, Object> = new Object() as Record<string, Object>;
      messageDeletedData['chatId'] = chatId as Object;
      messageDeletedData['messageIds'] = messageIds as Object;
      messageDeletedData['isPermanent'] = isPermanent as Object;
      hilog.info(0x0001, 'CoreService', `📢 Emitting core:messageDeleted event for chat ${chatId}`);
      // ⭐ Nagram 参考：累积批量变更通知
      this.scheduleBatchFlush(UPDATE_MASK_MESSAGE_DELETED);
      eventBus.emit('core:messageDeleted', messageDeletedData);

      // 刷新聊天列表（最后消息可能变化）
      this.refreshChat(chatId);
    } finally {
      // ⭐ 清理防重记录（5秒后自动过期，防止内存泄漏）
      setTimeout(() => {
        this.processedDeletions.delete(deletionKey);
        hilog.debug(0x0001, 'CoreService', `Cleaned up deletion record for ${deletionKey}`);
      }, 5000);
    }
  }

  /**
   * 处理用户详细信息更新（由 UpdateService 调用）
   * @param userId 用户ID
   */
  public onUserFullInfoUpdated(userId: number): void {
    if (userId) {
      hilog.info(0x0001, 'CoreService', `User full info updated: ${userId}`);
      // 清除用户缓存
      this.userCache.delete(userId);
      // 发送领域事件
      const userFullInfoData: Record<string, Object> = new Object() as Record<string, Object>;
      userFullInfoData['userId'] = userId as Object;
      eventBus.emit('core:userFullInfoUpdated', userFullInfoData);
    }
  }

  /**
   * 处理新联系人（由 UpdateService 调用）
   * @param userId 用户ID
   */
  public onNewContact(userId: number): void {
    if (userId) {
      hilog.info(0x0001, 'CoreService', `New contact: ${userId}`);
      // 发送领域事件
      const newContactData: Record<string, Object> = new Object() as Record<string, Object>;
      newContactData['userId'] = userId as Object;
      eventBus.emit('core:newContact', newContactData);
    }
  }

  /**
   * 处理联系人列表更新（由 UpdateService 调用）
   */
  public onContactsUpdated(): void {
    hilog.info(0x0001, 'CoreService', 'Contacts list updated');
    // 发送领域事件
    const contactsUpdatedData: Record<string, Object> = new Object() as Record<string, Object>;
    eventBus.emit('core:contactsUpdated', contactsUpdatedData);
  }

  /**
   * 处理连接状态更新（由 UpdateService 调用）
   * @param state 状态对象
   */
  public onConnectionStateUpdated(state: Record<string, Object>): void {
    if (state) {
      const stateType = state['@type'] as string;
      hilog.info(0x0001, 'CoreService', `Connection state updated: ${stateType}`);
      // 转发领域事件
      const connectionStateData: Record<string, Object> = new Object() as Record<string, Object>;
      connectionStateData['state'] = stateType as Object;
      // ⭐ Nagram 参考：累积批量变更通知
      this.scheduleBatchFlush(UPDATE_MASK_CONNECTION);
      eventBus.emit('core:connectionStateUpdated', connectionStateData);
    }
  }

  /**
   * 处理选项更新（由 UpdateService 调用）
   * @param name 选项名
   * @param value 选项值
   */
  public onOptionUpdated(name: string, value: Record<string, Object>): void {
    hilog.debug(0x0001, 'CoreService', `Option updated: ${name}`);
    // 转发领域事件
    const optionData: Record<string, Object> = new Object() as Record<string, Object>;
    optionData['name'] = name as Object;
    optionData['value'] = value as Object;
    eventBus.emit('core:optionUpdated', optionData);
  }

  /**
   * 处理密码状态更新（由 UpdateService 调用）
   * @param passwordState 密码状态
   */
  public onPasswordStateUpdated(passwordState: Record<string, Object>): void {
    hilog.info(0x0001, 'CoreService', 'Password state updated');
    // 转发领域事件
    const passwordStateData: Record<string, Object> = new Object() as Record<string, Object>;
    passwordStateData['passwordState'] = passwordState as Object;
    eventBus.emit('core:passwordStateUpdated', passwordStateData);
  }

  /**
   * 处理已连接网站更新（由 UpdateService 调用）
   */
  public onConnectedWebsitesUpdated(): void {
    hilog.info(0x0001, 'CoreService', 'Connected websites updated');
    // 转发领域事件
    const connectedWebsitesData: Record<string, Object> = new Object() as Record<string, Object>;
    eventBus.emit('core:connectedWebsitesUpdated', connectedWebsitesData);
  }
  
  // ==================== 联系人管理方法 ====================
  
  /**
   * 初始化联系人服务
   * 优先从数据库加载，其次从 TDLib 获取并持久化
   */
  public async initializeContacts(): Promise<void> {
    if (this.contactsInitialized) {
      return;
    }

    try {
      // ⭐ 优先从数据库加载联系人（通过联系人表）
      let loadedFromDb = false;
      if (this.cacheStorage) {
        try {
          // TODO: 需要添加 getAllContacts 方法到 DatabaseManager
          // 暂时跳过数据库加载，直接从 TDLib 获取
          hilog.debug(0x0001, 'CoreService', 'Contacts database loading skipped (getAllContacts not implemented)');
        } catch (dbError) {
          hilog.warn(0x0001, 'CoreService', `Failed to load contacts from database: ${JSON.stringify(dbError)}`);
        }
      }

      // 从 TDLib 获取联系人（增量更新或全量加载）
      const contactsResult = await this.tdLibApi.getContacts();

      if (contactsResult && contactsResult.user_ids) {
        const userIds = contactsResult.user_ids;
        const tdlibConverterModule = await import('../core/TdlibConverter');

        for (let i = 0; i < userIds.length; i++) {
          const userId = userIds[i];
          const userResult = await this.tdLibApi.getUser(userId);

          if (userResult) {
            const contact: Contact = this.convertToContact(userResult);
            this.contacts.set(userId, contact);

            // ⭐ 保存到数据库（异步，不阻塞）
            if (this.cacheStorage) {
              try {
                const userJson = JSON.stringify(userResult);
                const userRecord = JSON.parse(userJson) as Record<string, Object>;

                // 保存用户实体
                const userEntity = tdlibConverterModule.TdlibConverter.convertToUser(userRecord);
                await this.cacheStorage.saveUser(userEntity);

                // 保存联系人实体
                const contactEntity = tdlibConverterModule.TdlibConverter.convertToContact(userRecord);
                await this.cacheStorage.saveContact(contactEntity);
              } catch (saveError) {
                hilog.warn(0x0001, 'CoreService', `Failed to save contact ${userId} to database: ${JSON.stringify(saveError)}`);
              }
            }
          }
        }
      }

      this.contactsInitialized = true;
      hilog.info(0x0001, 'CoreService', `✅ Contacts initialized: ${this.contacts.size} contacts loaded (fromDb=${loadedFromDb})`);

      const payload: Record<string, boolean> = {};
      payload['ready'] = true;
      eventBus.emit('contactServiceReady', payload);
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `❌ Contacts initialization failed: ${JSON.stringify(error)}`);
      this.contactsInitialized = true;
    }
  }

  /**
   * 将 UserEntity 转换为 Contact
   * 使用 Record 类型避免动态导入类型问题
   */
  private convertUserEntityToContact(userEntity: Record<string, Object | string | number | boolean>): Contact {
    const fullName = `${userEntity['firstName'] as string || ''} ${userEntity['lastName'] as string || ''}`.trim();

    // 解析在线状态
    let userStatus: UserStatus = { _: 'userStatusEmpty' };
    let onlineStatus: OnlineStatus = OnlineStatus.OFFLINE;
    try {
      const statusJson = (userEntity['statusJson'] as string) || '{}';
      const statusObj = JSON.parse(statusJson) as Record<string, Object>;
      const statusType = statusObj['@type'] as string;
      if (statusType === 'userStatusOnline') {
        userStatus = { _: 'userStatusOnline', expires: (statusObj['expires'] as number) || 0 };
        onlineStatus = OnlineStatus.ONLINE;
      } else if (statusType === 'userStatusOffline') {
        userStatus = { _: 'userStatusOffline', was_online: (statusObj['was_online'] as number) || 0 };
        onlineStatus = OnlineStatus.OFFLINE;
      } else if (statusType === 'userStatusRecently') {
        userStatus = { _: 'userStatusRecently', by_my_privacy_settings: false };
        onlineStatus = OnlineStatus.RECENTLY;
      } else if (statusType === 'userStatusLastWeek') {
        userStatus = { _: 'userStatusLastWeek', by_my_privacy_settings: false };
        onlineStatus = OnlineStatus.WEEK_AGO;
      } else if (statusType === 'userStatusLastMonth') {
        userStatus = { _: 'userStatusLastMonth', by_my_privacy_settings: false };
        onlineStatus = OnlineStatus.MONTH_AGO;
      }
    } catch (e) {
      // 解析失败使用默认状态
    }

    const userId = (userEntity['userId'] as number) || 0;
    const firstName = (userEntity['firstName'] as string) || '';
    const lastName = (userEntity['lastName'] as string) || '';
    const username = (userEntity['username'] as string) || '';
    const phoneNumber = (userEntity['phoneNumber'] as string) || '';
    const profilePhotoFileId = (userEntity['profilePhotoFileId'] as string) || '';
    const lastUpdated = (userEntity['lastUpdated'] as number) || Date.now();

    // 构建 Usernames 对象
    const usernamesObj: Usernames | undefined = username ? {
      _: 'usernames',
      active_usernames: [username],
      disabled_usernames: [],
      editable_username: username,
      collectible_usernames: []
    } : undefined;

    // 构建 PhoneNumber 对象
    const phoneItem: PhoneNumber = {
      number: phoneNumber,
      label: 'mobile',
      normalizedNumber: phoneNumber.replace(/\D/g, '')
    };

    const contact: Contact = {
      id: userId,
      userId: userId,
      usernames: usernamesObj,
      isVerified: (userEntity['isVerified'] as boolean) || false,
      isPremium: (userEntity['isPremium'] as boolean) || false,
      isBot: (userEntity['isBot'] as boolean) || false,
      status: userStatus,
      firstName: firstName,
      lastName: lastName,
      fullName: fullName,
      avatarPath: '',
      avatarFileId: Number(profilePhotoFileId) || 0,
      phones: phoneNumber ? [phoneItem] : [],
      emails: [],
      phone: phoneNumber,
      syncSource: 'tdlib',
      lastUpdated: lastUpdated,
      syncStatus: SyncStatus.SYNCED,
      isFavorite: false,
      displayOrder: 0,
      sectionKey: (firstName || '').charAt(0).toUpperCase()
    };

    return contact;
  }

  /**
   * 将 TDLib User 转换为 Contact
   */
  private convertToContact(userResult: User): Contact {
    let userStatus: UserStatus = { _: 'userStatusEmpty' };
    let onlineStatus: OnlineStatus = OnlineStatus.OFFLINE;

    if (userResult.status) {
      const statusJson = JSON.stringify(userResult.status);
      const statusObj = JSON.parse(statusJson) as Record<string, Object>;
      const statusType = statusObj['@type'] as string;

      if (statusType === 'userStatusOnline') {
        const expires = statusObj['expires'] as number;
        userStatus = { _: 'userStatusOnline', expires: expires || 0 };
        onlineStatus = OnlineStatus.ONLINE;
      } else if (statusType === 'userStatusOffline') {
        const wasOnline = statusObj['was_online'] as number;
        userStatus = { _: 'userStatusOffline', was_online: wasOnline || 0 };
        onlineStatus = OnlineStatus.OFFLINE;
      } else if (statusType === 'userStatusRecently') {
        userStatus = { _: 'userStatusRecently', by_my_privacy_settings: false };
        onlineStatus = OnlineStatus.RECENTLY;
      } else if (statusType === 'userStatusLastWeek') {
        userStatus = { _: 'userStatusLastWeek', by_my_privacy_settings: false };
        onlineStatus = OnlineStatus.WEEK_AGO;
      } else if (statusType === 'userStatusLastMonth') {
        userStatus = { _: 'userStatusLastMonth', by_my_privacy_settings: false };
        onlineStatus = OnlineStatus.MONTH_AGO;
      }
    }

    let avatarPath = '';
    let avatarFileId = 0;
    const photo = userResult.profile_photo as Object | undefined;
    if (photo && typeof photo === 'object') {
      const photoRecord = photo as Record<string, Object>;
      const small = photoRecord['small'] as Object | undefined;
      if (small && typeof small === 'object') {
        const smallRecord = small as Record<string, Object>;
        // 获取头像文件ID
        avatarFileId = (smallRecord['id'] as number) || 0;
        const local = smallRecord['local'] as Object | undefined;
        if (local && typeof local === 'object') {
          const localRecord = local as Record<string, string>;
          avatarPath = localRecord['path'] || '';
        }
      }
    }
    hilog.info(0x0001, 'CoreService', `convertToContact: user=${userResult.first_name} ${userResult.last_name}, avatarPath=${avatarPath || 'empty'}, avatarFileId=${avatarFileId}`);

    let isBot = false;
    if (userResult.type) {
      const typeJson = JSON.stringify(userResult.type);
      const typeObj = JSON.parse(typeJson) as Record<string, Object>;
      const typeValue = typeObj['@type'] as string;
      isBot = typeValue === 'userTypeBot';
    }

    // 处理 usernames，从 TDLib 原始数据转换为 Usernames 对象
    const rawUsernames = userResult.usernames as Object | undefined;
    let usernames: Usernames | undefined;
    if (rawUsernames && typeof rawUsernames === 'object') {
      const usernamesRecord = rawUsernames as Record<string, Object>;
      usernames = {
        _: 'usernames',
        active_usernames: (usernamesRecord['active_usernames'] as string[]) || [],
        disabled_usernames: (usernamesRecord['disabled_usernames'] as string[]) || [],
        editable_username: (usernamesRecord['editable_username'] as string) || '',
        collectible_usernames: (usernamesRecord['collectible_usernames'] as string[]) || []
      };
    }

    // 构建 PhoneNumber 对象
    const phoneNumberItem: PhoneNumber = {
      number: userResult.phone_number || '',
      label: 'mobile',
      normalizedNumber: (userResult.phone_number || '').replace(/\D/g, '')
    };

    const contact: Contact = {
      id: userResult.id,
      userId: userResult.id,
      usernames: usernames,
      isVerified: !!userResult.verification_status,
      isPremium: userResult.is_premium || false,
      isBot: isBot,
      status: userStatus,
      firstName: userResult.first_name || '',
      lastName: userResult.last_name || '',
      fullName: `${userResult.first_name || ''} ${userResult.last_name || ''}`.trim(),
      avatarPath: avatarPath,
      avatarFileId: avatarFileId,
      phones: userResult.phone_number ? [phoneNumberItem] : [],
      emails: [],
      phone: userResult.phone_number || '',
      syncSource: 'tdlib',
      lastUpdated: Date.now(),
      syncStatus: SyncStatus.SYNCED,
      isFavorite: false,
      displayOrder: 0,
      sectionKey: (userResult.first_name || '').charAt(0).toUpperCase()
    };

    return contact;
  }

  /**
   * 获取所有联系人
   */
  public async getContacts(): Promise<Contact[]> {
    if (!this.contactsInitialized) {
      await this.initializeContacts();
    }
    return Array.from(this.contacts.values());
  }

  /**
   * 根据ID获取联系人
   */
  public async getContactById(contactId: number): Promise<Contact | null> {
    if (!this.contactsInitialized) {
      await this.initializeContacts();
    }
    return this.contacts.get(contactId) || null;
  }

  /**
   * 搜索联系人
   */
  public async searchContacts(query: string): Promise<ContactSearchResult> {
    if (!query.trim()) {
      return { contacts: [], globalContacts: [] };
    }

    const allContacts = await this.getContacts();
    const lowerQuery = query.toLowerCase();

    const contacts = allContacts.filter(contact => {
      const fullName = `${contact.firstName} ${contact.lastName || ''}`.toLowerCase();
      const phone = contact.phone.toLowerCase();
      const activeUsernames = contact.usernames?.active_usernames || [];
      const username = activeUsernames.length > 0 ? activeUsernames[0].toLowerCase() : '';

      return fullName.includes(lowerQuery) ||
      phone.includes(lowerQuery) ||
      username.includes(lowerQuery);
    });

    const globalContacts: Contact[] = [];
    try {
      const result = await this.tdLibApi.searchContacts(query, 20);

      if (result) {
        // Users 类型有 user_ids 属性
        const userIdsArray = result.user_ids || [];
        
        for (let i = 0; i < userIdsArray.length; i++) {
          const userId = userIdsArray[i];
          if (userId !== undefined) {
            const userResult = await this.tdLibApi.getUser(userId);

            if (userResult) {
              const contact: Contact = this.convertToContact(userResult);
              globalContacts.push(contact);
            }
          }
        }
      }
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `Search global contacts failed: ${JSON.stringify(error)}`);
    }

    const exactMatch = contacts.find(contact => {
      const fullName = `${contact.firstName} ${contact.lastName || ''}`.toLowerCase();
      const activeUsernames = contact.usernames?.active_usernames || [];
      const username = activeUsernames.length > 0 ? activeUsernames[0].toLowerCase() : '';
      return fullName === lowerQuery || username === lowerQuery;
    });

    return { contacts, globalContacts, exactMatch };
  }

  /**
   * 添加联系人
   * ArkTS: 使用 Object 类型参数以避免结构类型检查问题
   */
  public async addContact(contactObj: Object): Promise<boolean> {
    try {
      // 将 Object 转换为 Record 以安全访问属性
      const contact = contactObj as Record<string, Object>;
      const importedContact: importedContact$Input = {
        _: 'importedContact',
        phone_number: (contact['phone'] as string) || '',
        first_name: (contact['firstName'] as string) || '',
        last_name: (contact['lastName'] as string) || ''
      };
      await this.tdLibApi.addContact(
        (contact['userId'] as number) || 0,
        importedContact,
        true
      );

      // 转换为 Contact 类型后存储
      const contactToStore: Contact = contactObj as Contact;
      this.contacts.set((contact['id'] as number) || 0, contactToStore);
      hilog.info(0x0001, 'CoreService', `✅ Contact added: ${contact['firstName']} ${contact['lastName']}`);
      return true;
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `❌ Add contact failed: ${JSON.stringify(error)}`);
      throw error as Error;
    }
  }

  /**
   * 删除联系人
   */
  public async deleteContact(contactId: number): Promise<boolean> {
    try {
      if (!this.contacts.has(contactId)) {
        throw new Error('Contact not found');
      }

      const contact = this.contacts.get(contactId);
      if (!contact) {
        throw new Error('Contact not found');
      }

      await this.tdLibApi.removeContacts([contact.userId]);

      this.contacts.delete(contactId);
      hilog.info(0x0001, 'CoreService', `✅ Contact deleted: ${contact.firstName} ${contact.lastName}`);
      return true;
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `❌ Delete contact failed: ${JSON.stringify(error)}`);
      throw error as Error;
    }
  }

  /**
   * 导入联系人
   */
  public async importContacts(phoneNumbers: string[]): Promise<Contact[]> {
    try {
      const contactsArray: importedContact$Input[] = [];
      for (let i = 0; i < phoneNumbers.length; i++) {
        contactsArray.push({
          _: 'importedContact',
          phone_number: phoneNumbers[i],
          first_name: '',
          last_name: ''
        });
      }

      await this.tdLibApi.importContacts(contactsArray);

      hilog.info(0x0001, 'CoreService', `✅ Import contacts requested: ${phoneNumbers.length} numbers`);

      return [];
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `❌ Import contacts failed: ${JSON.stringify(error)}`);
      throw error as Error;
    }
  }

  /**
   * 获取联系人统计信息
   */
  public async getContactStats(): Promise<ContactStats> {
    const contacts = await this.getContacts();
    const onlineCount: number = contacts.filter((c: Contact) => {
      const status = c.status;
      if (!status) return false;
      return status._ === 'userStatusOnline';
    }).length;
    const stats: ContactStats = {
      totalContacts: contacts.length,
      onlineContacts: onlineCount,
      verifiedContacts: contacts.filter((c: Contact) => c.isVerified).length,
      botContacts: contacts.filter((c: Contact) => c.isBot).length
    };
    return stats;
  }

  // ==================== 聊天消息操作 ====================

  /**
   * ⭐ Nagram：获取聊天历史消息（先写入数据库）
   * @param chatId 聊天ID
   * @param fromMessageId 起始消息ID
   * @param offset 偏移量
   * @param limit 限制数量
   * @param onlyLocal 是否只获取本地消息
   * @returns 消息数组（TDLib 原始对象）
   */
  public async getChatHistory(
    chatId: number,
    fromMessageId: number,
    offset: number,
    limit: number,
    onlyLocal: boolean = false
  ): Promise<Object[]> {
    try {
      const history = await this.tdLibApi.getChatHistory(chatId, fromMessageId, offset, limit, onlyLocal);
      if (!history) return [];
      const historyObj = JSON.parse(JSON.stringify(history)) as Record<string, Object>;
      const messages = historyObj['messages'] as Array<Object> || [];

      // ⭐ Nagram 参考：先批量写入数据库，再返回数据
      if (!onlyLocal && messages.length > 0) {
        const savedCount = await this.batchSaveMessagesToDatabase(messages, chatId);
        hilog.info(0x0001, 'CoreService', `getChatHistory: saved ${savedCount}/${messages.length} messages to DB for chat ${chatId}`);
      }

      return messages;
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `Get chat history failed: ${JSON.stringify(error)}`);
      return [];
    }
  }

  /**
   * 标记消息已读
   * @param chatId 聊天ID
   * @param messageIds 消息ID数组
   * @param source 来源
   * @param forceRead 是否强制标记为已读
   */
  public async viewMessages(
    chatId: number,
    messageIds: number[],
    source: messageStory | null,
    forceRead: boolean
  ): Promise<void> {
    hilog.info(0x0001, 'CoreService', 
      `⭐ [viewMessages] chatId=${chatId}, messageIds=${JSON.stringify(messageIds)}, forceRead=${forceRead}`);
    try {
      await this.tdLibApi.viewMessages(chatId, messageIds, source, forceRead);
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `View messages failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 删除消息
   * @param chatId 聊天ID
   * @param messageIds 消息ID数组
   * @param revoke 是否撤回
   */
  public async deleteMessages(
    chatId: number,
    messageIds: number[],
    revoke: boolean
  ): Promise<void> {
    try {
      hilog.info(0x0001, 'CoreService', `🗑️ [START] Deleting ${messageIds.length} messages in chat ${chatId}, revoke=${revoke}`);
      hilog.info(0x0001, 'CoreService', `🗑️ Message IDs: ${JSON.stringify(messageIds)}`);
      
      // ⭐ Nagram 参考：将用户发起的删除标记记录下来
      // 防止 TDLib 的 updateDeleteMessages 事件被重复处理
      for (const msgId of messageIds) {
        const key = `${chatId}_${msgId}`;
        this.userInitiatedDeletions.add(key);
      }
      
      // ⭐ 先调用 TDLib API
      await this.tdLibApi.deleteMessages(chatId, messageIds, revoke);
      hilog.info(0x0001, 'CoreService', `✅ TDLib API call succeeded for deleting ${messageIds.length} messages`);
      
      // ⭐ 立即执行本地数据清理，不等待 TDLib 事件
      hilog.info(0x0001, 'CoreService', `🧹 Starting local cleanup...`);
      await this.onMessagesDeleted(chatId, messageIds, revoke);
      hilog.info(0x0001, 'CoreService', `✅ Local cleanup completed for ${messageIds.length} messages`);
      
      // ⭐ 验证：检查数据库中是否还存在这些消息
      if (this.cacheStorage) {
        for (const msgId of messageIds) {
          const existing = await this.cacheStorage.database.getMessageByMessageId(msgId);
          if (existing) {
            hilog.error(0x0001, 'CoreService', `⚠️ WARNING: Message ${msgId} still exists in database after deletion!`);
          } else {
            hilog.debug(0x0001, 'CoreService', `✓ Message ${msgId} confirmed deleted from database`);
          }
        }
      }
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `❌ Delete messages failed: ${JSON.stringify(error)}`);
      throw error as Error;
    }
  }

  /**
   * 下载文件
   * @param fileId 文件ID
   * @param priority 优先级
   * @param offset 偏移量
   * @param limit 限制
   * @param synchronous 是否同步
   */
  public async downloadFile(
    fileId: number,
    priority: number = 1,
    offset: number = 0,
    limit: number = 0,
    synchronous: boolean = false
  ): Promise<void> {
    try {
      await this.tdLibApi.downloadFile(fileId, priority, offset, limit, synchronous);
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `Download file failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 保存消息到本地数据库
   * @param message TDLib 消息对象
   * @param chatId 聊天ID
   */
  public async saveMessageToDatabase(message: Record<string, Object>, chatId: number): Promise<void> {
    try {
      // 转换消息实体
      const tdlibConverterModule = await import('../core/TdlibConverter');
      const entity = tdlibConverterModule.TdlibConverter.convertToMessage(message, chatId);
      
      // 使用 CacheStorage 保存消息
      if (this.cacheStorage) {
        await this.cacheStorage.database.insertMessage(entity);
        hilog.debug(0x0001, 'CoreService', `Message saved to CacheStorage: ${entity.messageId}`);
      } else {
        hilog.warn(0x0001, 'CoreService', 'CacheStorage not initialized, message not saved');
      }
    } catch (error) {
      hilog.warn(0x0001, 'CoreService', `Save message to database failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * ⭐ Nagram 参考：批量保存消息到数据库（先写入数据库，再返回数据）
   * 所有消息在返回给调用方之前必须写入数据库，确保数据库是唯一事实源
   * @param tdMessages TDLib 原始消息对象数组
   * @param chatId 聊天ID
   * @returns 成功保存的消息数量
   */
  private async batchSaveMessagesToDatabase(tdMessages: Array<Object | null>, chatId: number): Promise<number> {
    if (!this.cacheStorage || tdMessages.length === 0) return 0;

    try {
      const tdlibConverterModule = await import('../core/TdlibConverter');
      const entities: MessageEntity[] = [];

      for (const msg of tdMessages) {
        if (!msg) continue;
        const msgJson = JSON.stringify(msg);
        const msgRecord = JSON.parse(msgJson) as Record<string, Object>;
        const entity = tdlibConverterModule.TdlibConverter.convertToMessage(msgRecord, chatId);
        entities.push(entity);
      }

      if (entities.length === 0) return 0;

      // ⭐ 批量写入数据库（使用优化后的批量插入方法）
      const result = await this.cacheStorage.database.insertMessagesBatchOptimized(entities);
      if (result.success) {
        hilog.info(0x0001, 'CoreService', `💾 Batch saved ${entities.length} messages to DB for chat ${chatId}`);
        return entities.length;
      } else {
        hilog.error(0x0001, 'CoreService', `Batch save to DB failed: ${result.errorCode}`);
        return 0;
      }
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `Batch save to DB exception: ${JSON.stringify(error)}`);
      return 0;
    }
  }

  /**
   * 获取缓存的联系人列表（同步）
   * @returns 联系人数组，如果没有缓存返回空数组
   */
  public getCachedContacts(): Contact[] {
    if (!this.contactsInitialized) {
      return [];
    }
    return Array.from(this.contacts.values());
  }

  /**
   * 检查联系人是否已初始化
   */
  public isContactsInitialized(): boolean {
    return this.contactsInitialized;
  }

  /**
   * 获取当前登录用户的完整信息
   * @returns 用户详细信息
   */
  public async getCurrentUserFullInfo(): Promise<Record<string, Object> | null> {
    try {
      // 获取当前用户ID（通过 getMe 或从缓存中推断）
      const meResult = await this.tdLibApi.getMe();
      if (!meResult) {
        hilog.warn(0x0001, 'CoreService', 'getMe returned null');
        return null;
      }

      const meJson = JSON.stringify(meResult);
      const meRecord = JSON.parse(meJson) as Record<string, Object>;
      const userId = meRecord['id'] as number;

      if (!userId) {
        hilog.warn(0x0001, 'CoreService', 'Current user ID not found');
        return null;
      }

      // 获取完整用户信息
      const fullInfo = await this.tdLibApi.getUserFullInfo(userId);
      if (!fullInfo) {
        hilog.warn(0x0001, 'CoreService', `getUserFullInfo returned null for user ${userId}`);
        return meRecord;
      }

      // 合并基本信息和完整信息
      // 使用 JSON 序列化/反序列化合并对象（ArkTS 不支持展开运算符和 Object.assign）
      const combinedJson = JSON.stringify({
        id: meRecord['id'],
        first_name: meRecord['first_name'],
        last_name: meRecord['last_name'],
        username: meRecord['username'],
        usernames: meRecord['usernames'] || meRecord['usernames_'],
        phone_number: meRecord['phone_number'],
        profile_photo: meRecord['profile_photo'] || meRecord['profile_photo_'],
        full_info: fullInfo
      });
      return JSON.parse(combinedJson) as Record<string, Object>;
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `Get current user full info failed: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * ⭐ Nagram 参考：获取指定聊天的缓存消息（数据库优先，内存次之）
   * @param chatId 聊天ID
   * @returns 消息数组，如果没有缓存返回空数组
   */
  public async getCachedMessages(chatId: number): Promise<Message[]> {
    // ⭐ Nagram 参考：数据库是唯一事实源，优先从数据库加载
    if (this.cacheStorage) {
      try {
        const dbMessages = await this.cacheStorage.getMessages(chatId, 50, 0);
        if (dbMessages && dbMessages.length > 0) {
          const convertedMessages = dbMessages.map(entity => this.convertEntityToMessage(entity));
          convertedMessages.sort((a, b) => a.id - b.id);
          // ⭐ 更新内存缓存，保持一致性
          this.messagesMap.set(chatId, convertedMessages);
          hilog.info(0x0001, 'CoreService', `getCachedMessages: ${convertedMessages.length} messages from DB for chat ${chatId}`);
          return convertedMessages;
        }
      } catch (error) {
        hilog.error(0x0001, 'CoreService', `Failed to load messages from database: ${JSON.stringify(error)}`);
      }
    }

    // ⭐ 数据库没有时，从内存缓存获取（可能是未持久化的新消息）
    const memoryMessages = this.messagesMap.get(chatId);
    if (memoryMessages && memoryMessages.length > 0) {
      hilog.info(0x0001, 'CoreService', `getCachedMessages: ${memoryMessages.length} messages from memory for chat ${chatId} (DB empty)`);
      return memoryMessages;
    }

    return [];
  }

  /**
   * ⭐ 保存消息到内存缓存（用于切换聊天时保留已加载的历史消息）
   * @param chatId 聊天ID
   * @param messages 消息数组
   */
  public saveMessagesToMemoryCache(chatId: number, messages: Message[]): void {
    if (messages.length === 0) {
      return;
    }
    
    // 直接覆盖内存缓存
    this.messagesMap.set(chatId, messages);
    hilog.debug(0x0001, 'CoreService', `Saved ${messages.length} messages to memory cache for chat ${chatId}`);
  }

  /**
   * ⭐ Nagram 参考：累积变更并调度批量刷新
   * 等价于 Nagram processUpdateArray 中的 interfaceUpdateMask |= MASK
   * @param maskBit 更新的位掩码
   */
  private scheduleBatchFlush(maskBit: number): void {
    this.pendingUpdateMask |= maskBit;
    if (this.batchFlushTimer === -1) {
      this.batchFlushTimer = setTimeout(() => {
        this.flushUpdates();
      }, FLUSH_DELAY_MS);
    }
  }

  /**
   * ⭐ Nagram 参考：刷新累积的更新到 ViewModel
   * 等价于 Nagram 中收集所有变更后 postNotificationName
   */
  private flushUpdates(): void {
    this.batchFlushTimer = -1;
    if (this.pendingUpdateMask === 0) return;

    const mask = this.pendingUpdateMask;
    this.pendingUpdateMask = 0;

    // ⭐ 发送 batchUpdate 事件
    // ViewModel 订阅此事件，按位掩码决定刷新哪些部分
    const batchUpdateData: Record<string, Object> = new Object() as Record<string, Object>;
    batchUpdateData['mask'] = mask as Object;
    eventBus.emit('core:batchUpdate', batchUpdateData);
  }

  /**
   * 将 MessageEntity 转换为 Message
   */
  private convertEntityToMessage(entity: MessageEntity): Message {
    // ⭐ 解析内容：如果是系统消息，需要特殊处理
    let content: string | Object = entity.contentJson ? JSON.parse(entity.contentJson) : entity.caption || '';
    const messageType = this.parseMessageType(entity.contentType);
    
    // ⭐ 为系统消息生成合适的文本内容
    if (messageType === MessageType.SYSTEM) {
      content = this.generateSystemMessageContent(entity, content);
    }
    
    // ⭐ 尝试获取发送者名称
    let senderName = '';
    if (entity.senderId) {
      const cachedUser = this.getCachedUserInfo(entity.senderId);
      senderName = cachedUser?.name || '';
    }
    
    const message: Message = {
      id: entity.messageId,
      chatId: entity.chatId,
      senderId: entity.senderId,
      senderName: senderName, // 从缓存获取发送者名称
      type: messageType,
      content: content,
      timestamp: entity.date * 1000, // 转换为毫秒
      status: MessageStatus.SENT,
      isOutgoing: entity.senderId === this.getCurrentUserId(),
      replyToMessageId: entity.replyToMsgId || undefined,
      isEdited: !!entity.editDate,
      downloadProgress: 0,
      isDownloading: false,
      reactions: [],
      isPinned: false,
      canBeEdited: false,
      canBeDeleted: false,
      hasProtectedContent: false
    };
    return message;
  }

  /**
   * ⭐ 生成系统消息的内容文本
   */
  private generateSystemMessageContent(entity: MessageEntity, parsedContent: Object | string): string {
    // 如果 content 已经是字符串，直接返回
    if (typeof parsedContent === 'string' && parsedContent.length > 0) {
      return parsedContent;
    }
    
    // 根据内容类型生成默认文本
    switch (entity.contentType) {
      case 'messageChatAddMembers':
        return '成员已加入群组';
      case 'messageChatDeleteMember':
        return '成员已离开群组';
      case 'messageChatJoinByLink':
        return '通过链接加入群组';
      case 'messageChatChangeTitle':
        // 尝试从 contentJson 中提取标题
        if (typeof parsedContent === 'object' && parsedContent !== null) {
          const title = (parsedContent as Record<string, string>)['title'];
          if (title) {
            return `群组名称已更改为"${title}"`;
          }
        }
        return '群组名称已更改';
      case 'messageChatChangePhoto':
        return '群组头像已更改';
      case 'messagePinMessage':
        return '置顶了一条消息';
      case 'messageChatUpgradeTo':
      case 'messageChatUpgradeFrom':
        return '群组已升级';
      default:
        return '系统消息';
    }
  }

  /**
   * 解析消息类型
   * 支持两种格式：
   * 1. TDLib 原始格式：messageText, messagePhoto 等
   * 2. 数据库简化格式：text, photo 等（由 TdlibConverter 转换）
   */
  private parseMessageType(contentType: string): MessageType {
    switch (contentType) {
      // TDLib 原始格式
      case 'messageText': return MessageType.TEXT;
      case 'messagePhoto': return MessageType.PHOTO;
      case 'messageVideo': return MessageType.VIDEO;
      case 'messageAudio': return MessageType.AUDIO;
      case 'messageVoiceNote': return MessageType.VOICE_NOTE;
      case 'messageDocument': return MessageType.DOCUMENT;
      case 'messageSticker': return MessageType.STICKER;
      case 'messageLocation': return MessageType.LOCATION;
      case 'messageContact': return MessageType.CONTACT;
      case 'messagePoll': return MessageType.POLL;
      case 'messageGame': return MessageType.GAME;
      case 'messageCall': return MessageType.CALL;
      // ⭐ 系统消息/服务消息
      case 'messageChatAddMembers':
      case 'messageChatDeleteMember':
      case 'messageChatChangeTitle':
      case 'messageChatChangePhoto':
      case 'messageChatPinMessage':
      case 'messageChatJoinByLink':
      case 'messageChatUpgradeTo':
      case 'messageChatUpgradeFrom':
        return MessageType.SYSTEM;
      // 数据库简化格式（由 TdlibConverter.convertToMessage 生成）
      case 'text': return MessageType.TEXT;
      case 'photo': return MessageType.PHOTO;
      case 'video': return MessageType.VIDEO;
      case 'audio': return MessageType.AUDIO;
      case 'voicenote': return MessageType.VOICE_NOTE;
      case 'document': return MessageType.DOCUMENT;
      case 'sticker': return MessageType.STICKER;
      case 'location': return MessageType.LOCATION;
      case 'contact': return MessageType.CONTACT;
      case 'poll': return MessageType.POLL;
      case 'game': return MessageType.GAME;
      case 'call': return MessageType.CALL;
      // ⭐ 数据库简化格式的系统消息
      case 'system': return MessageType.SYSTEM;
      default: return MessageType.TEXT;
    }
  }

  /**
   * 获取当前用户 ID（简化实现）
   */
  private currentUserId: number = 0;
  private getCurrentUserId(): number {
    return this.currentUserId;
  }

  /**
   * 刷新联系人列表
   */
  public async refreshContacts(): Promise<void> {
    try {
      const contactsResult = await this.tdLibApi.getContacts();

      if (contactsResult && contactsResult.user_ids) {
        const userIds = contactsResult.user_ids;
        for (let i = 0; i < userIds.length; i++) {
          const userId = userIds[i];
          if (!this.contacts.has(userId)) {
            try {
              const userResult = await this.tdLibApi.getUser(userId);

              if (userResult) {
                const contact: Contact = this.convertToContact(userResult);
                this.contacts.set(userId, contact);
              }
            } catch (error) {
              hilog.error(0x0001, 'CoreService', `Get user info failed userId=${userId}: ${JSON.stringify(error)}`);
            }
          }
        }

        const currentContactIds = Array.from(this.contacts.keys());
        const newContactIds = contactsResult.user_ids;

        for (let i = 0; i < currentContactIds.length; i++) {
          const id = currentContactIds[i];
          if (!newContactIds.includes(id)) {
            this.contacts.delete(id);
          }
        }

        hilog.info(0x0001, 'CoreService', `✅ Contacts refreshed: ${this.contacts.size} contacts`);
      }
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `❌ Refresh contacts failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 获取与指定用户的共同群组数量
   */
  async getMutualGroupsCount(userId: number): Promise<number> {
    try {
      const result = await this.tdLibApi.getGroupsInCommon(userId, 0, 100);
      const chatIds = result.chat_ids || [];
      return chatIds.length;
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `Get mutual groups count failed: ${JSON.stringify(error)}`);
      return 0;
    }
  }

  /**
   * 获取与指定用户的共同群组列表
   */
  async getMutualGroups(userId: number, offset: number = 0, limit: number = 50): Promise<Object[]> {
    try {
      const result = await this.tdLibApi.getGroupsInCommon(userId, offset, limit);
      const chatIds = result.chat_ids || [];

      const groups: Object[] = [];
      for (const chatId of chatIds) {
        const chat = await this.tdLibApi.getChat(chatId);
        groups.push(chat as Object);
      }

      return groups;
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `Get mutual groups failed: ${JSON.stringify(error)}`);
      return [];
    }
  }

  /**
   * 发起语音通话
   */
  async startVoiceCall(userId: number): Promise<boolean> {
    try {
      const protocol: callProtocol = {
        _: 'callProtocol',
        udp_p2p: true,
        udp_reflector: true,
        min_layer: 65,
        max_layer: 92,
        library_versions: []
      };
  
      await this.tdLibApi.createCall(userId, protocol, false);
  
      hilog.info(0x0001, 'CoreService', `✅ Voice call started: ${userId}`);
      return true;
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `❌ Start voice call failed: ${JSON.stringify(error)}`);
      throw error as Error;
    }
  }

  /**
   * 发起视频通话
   */
  async startVideoCall(userId: number): Promise<boolean> {
    try {
      const protocol: callProtocol = {
        _: 'callProtocol',
        udp_p2p: true,
        udp_reflector: true,
        min_layer: 65,
        max_layer: 92,
        library_versions: []
      };
  
      await this.tdLibApi.createCall(userId, protocol, true);
  
      hilog.info(0x0001, 'CoreService', `✅ Video call started: ${userId}`);
      return true;
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `❌ Start video call failed: ${JSON.stringify(error)}`);
      throw error as Error;
    }
  }

  /**
   * 将 TDLib UserStatus 转换为 Contact UserStatus
   */
  private convertUserStatus(tdlibStatus: Object): UserStatus {
    const statusRecord = tdlibStatus as Record<string, Object>;
    const statusType = statusRecord['@type'] as string;

    switch (statusType) {
      case 'userStatusOnline':
        const onlineStatus: UserStatus = {
          _: 'userStatusOnline',
          expires: statusRecord['expires'] as number || 0
        };
        return onlineStatus;
      case 'userStatusOffline':
        const offlineStatus: UserStatus = {
          _: 'userStatusOffline',
          was_online: statusRecord['was_online'] as number || 0
        };
        return offlineStatus;
      case 'userStatusRecently':
        const recentlyStatus: UserStatus = { _: 'userStatusRecently', by_my_privacy_settings: false };
        return recentlyStatus;
      case 'userStatusLastWeek':
        const lastWeekStatus: UserStatus = { _: 'userStatusLastWeek', by_my_privacy_settings: false };
        return lastWeekStatus;
      case 'userStatusLastMonth':
        const lastMonthStatus: UserStatus = { _: 'userStatusLastMonth', by_my_privacy_settings: false };
        return lastMonthStatus;
      default:
        const emptyStatus: UserStatus = { _: 'userStatusEmpty' };
        return emptyStatus;
    }
  }

  /**
   * 处理已发送消息已读状态更新（由 UpdateService 调用）
   * @param chatId 聊天ID
   */
  public onChatOutboxRead(chatId: number): void {
    if (chatId) {
      // 更新该聊天中所有已发送消息的状态为已读
      const messages = this.messagesMap.get(chatId);
      if (messages) {
        let hasChanges = false;
        for (const msg of messages) {
          if (msg.isOutgoing && msg.status !== MessageStatus.READ) {
            msg.status = MessageStatus.READ;
            hasChanges = true;
          }
        }
        
        if (hasChanges) {
          // 触发消息列表更新事件
          const payload: Record<string, Object> = {};
          payload['chatId'] = chatId as Object;
          eventBus.emit('messageStatusUpdated', payload);
        }
      }
    }
  }

  /**
   * 更新联系人
   * ArkTS: 使用 Object 类型参数以避免结构类型检查问题
   */
  public async updateContact(contactObj: Object): Promise<boolean> {
    try {
      // 将 Object 转换为 Record 以安全访问属性
      const contact = contactObj as Record<string, Object>;
      const importedContact: importedContact$Input = {
        _: 'importedContact',
        phone_number: (contact['phone'] as string) || '',
        first_name: (contact['firstName'] as string) || '',
        last_name: (contact['lastName'] as string) || ''
      };
      await this.tdLibApi.addContact(
        (contact['userId'] as number) || 0,
        importedContact,
        true
      );

      // 转换为 Contact 类型后存储
      const contactToStore: Contact = contactObj as Contact;
      this.contacts.set((contact['id'] as number) || 0, contactToStore);
      hilog.info(0x0001, 'CoreService', `✅ Contact updated: ${contact['firstName']} ${contact['lastName']}`);
      return true;
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `❌ Update contact failed: ${JSON.stringify(error)}`);
      throw error as Error;
    }
  }

  /**
   * 检查用户是否被拉黑
   */
  public async isUserBlocked(userId: number): Promise<boolean> {
    try {
      // TODO: TDLibApi需要添加getBlockedUsers方法
      hilog.warn(0x0001, 'CoreService', `getBlockedUsers not implemented in TDLibApi`);
      return false;
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `Check user blocked failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * 检查聊天是否静音
   */
  public async isChatMuted(chatId: number): Promise<boolean> {
    try {
      const chat = await this.tdLibApi.getChat(chatId);
      const notificationSettings = chat.notification_settings;
      if (notificationSettings && notificationSettings.mute_for !== undefined) {
        return notificationSettings.mute_for > 0;
      }
      return false;
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `Check chat muted failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * 拉黑用户
   */
  public async blockUser(userId: number): Promise<boolean> {
    try {
      // TODO: TDLibApi需要添加blockUser方法
      hilog.warn(0x0001, 'CoreService', `blockUser not implemented in TDLibApi`);
      return false;
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `❌ Block user failed: ${JSON.stringify(error)}`);
      throw error as Error;
    }
  }

  /**
   * 取消拉黑用户
   */
  public async unblockUser(userId: number): Promise<boolean> {
    try {
      // TODO: TDLibApi需要添加unblockUser方法
      hilog.warn(0x0001, 'CoreService', `unblockUser not implemented in TDLibApi`);
      return false;
    } catch (error) {
      hilog.error(0x0001, 'CoreService', `❌ Unblock user failed: ${JSON.stringify(error)}`);
      throw error as Error;
    }
  }

  // ==================== UpdateService 调用入口（90+ 种 TDLib 更新事件）====================

  /**
   * 处理新消息更新（UpdateService 入口）
   */
  public async onUpdateNewMessage(update: Record<string, Object>): Promise<void> {
    const messageObj = update['message'] as Record<string, Object>;
    if (messageObj) {
      await this.onNewMessage(messageObj);
    }
  }

  /**
   * 处理消息发送成功（UpdateService 入口）
   */
  public onUpdateMessageSendSucceeded(update: Record<string, Object>): void {
    const oldMessageId = update['old_message_id'] as number;
    const message = update['message'] as Record<string, Object>;
    this.onMessageSendSucceeded(oldMessageId, message);
  }

  /**
   * 处理消息发送失败（UpdateService 入口）
   */
  public onUpdateMessageSendFailed(update: Record<string, Object>): void {
    const messageId = update['message_id'] as number;
    const chatId = update['chat_id'] as number;
    const error = update['error'] as Record<string, Object>;
    this.onMessageSendFailed(messageId, chatId, error);
  }

  /**
   * 处理消息内容更新（UpdateService 入口）
   */
  public onUpdateMessageContent(update: Record<string, Object>): void {
    const chatId = update['chat_id'] as number;
    const messageId = update['message_id'] as number;
    const newContent = update['new_content'] as Record<string, Object>;
    this.onMessageContentEdited(chatId, messageId, newContent);
  }

  /**
   * 处理消息编辑（UpdateService 入口）
   */
  public onUpdateMessageEdited(update: Record<string, Object>): void {
    // 复用消息内容更新逻辑
    this.onUpdateMessageContent(update);
  }

  /**
   * ⭐ Nagram 参考：处理消息删除（UpdateService 入口）
   * 区分用户发起的删除 vs TDLib 内部清理
   * - 用户发起的删除：已通过 deleteMessages() 内的标记，此时跳过避免重复
   * - TDLib 内部清理：只对 isPermanent 的删除进行处理
   * - 非 permanent 的 TDLib 删除事件忽略（可能是过期消息等临时清理）
   */
  public async onUpdateDeleteMessages(update: Record<string, Object>): Promise<void> {
    const chatId = update['chat_id'] as number;
    const messageIds = update['message_ids'] as number[];
    const isPermanent = update['is_permanent'] as boolean;

    // ⭐ 检查：这些删除是用户发起的吗？
    const userInitiatedIds: number[] = [];
    const otherIds: number[] = [];
    for (const msgId of messageIds) {
      const key = `${chatId}_${msgId}`;
      if (this.userInitiatedDeletions.has(key)) {
        userInitiatedIds.push(msgId);
        // 清理标记
        this.userInitiatedDeletions.delete(key);
      } else {
        otherIds.push(msgId);
      }
    }

    // ⭐ 用户发起的删除：直接处理（已在 deleteMessages 中执行过 onMessagesDeleted）
    // 但 TDLib 的 updateDeleteMessages 是可靠事件，再次执行确保一致性
    if (userInitiatedIds.length > 0) {
      hilog.info(0x0001, 'CoreService',
        `User-initiated deletion confirmed: ${userInitiatedIds.length} messages in chat ${chatId}`);
      // 不重复执行 onMessagesDeleted，因为 deleteMessages 已执行
      // 仅清理追踪标记
    }

    // ⭐ 非用户发起的删除：仅当 isPermanent 时才处理
    if (otherIds.length > 0) {
      if (isPermanent) {
        hilog.info(0x0001, 'CoreService',
          `Processing TDLib permanent deletion: ${otherIds.length} messages in chat ${chatId}`);
        await this.onMessagesDeleted(chatId, otherIds, isPermanent);
      } else {
        hilog.info(0x0001, 'CoreService',
          `Skipping non-permanent TDLib deletion: ${otherIds.length} messages in chat ${chatId} (server-side cleanup)`);
      }
    }
  }

  /**
   * 处理消息查看次数更新（UpdateService 入口）
   */
  public onUpdateMessageViews(update: Record<string, Object>): void {
    // TODO: 实现消息查看次数更新
    hilog.debug(0x0001, 'CoreService', 'Message views updated');
  }

  /**
   * 处理消息交互信息更新（UpdateService 入口）
   */
  public onUpdateMessageInteractionInfo(update: Record<string, Object>): void {
    // TODO: 实现消息交互信息更新
    hilog.debug(0x0001, 'CoreService', 'Message interaction info updated');
  }

  /**
   * 处理消息内容已打开（UpdateService 入口）
   */
  public onUpdateMessageContentOpened(update: Record<string, Object>): void {
    // TODO: 实现消息内容已打开
    hilog.debug(0x0001, 'CoreService', 'Message content opened');
  }

  /**
   * 处理消息提及已读（UpdateService 入口）
   */
  public onUpdateMessageMentionRead(update: Record<string, Object>): void {
    // TODO: 实现消息提及已读
    hilog.debug(0x0001, 'CoreService', 'Message mention read');
  }

  /**
   * 处理消息实时位置已查看（UpdateService 入口）
   */
  public onUpdateMessageLiveLocationViewed(update: Record<string, Object>): void {
    // TODO: 实现消息实时位置已查看
    hilog.debug(0x0001, 'CoreService', 'Message live location viewed');
  }

  /**
   * 处理消息事实核查（UpdateService 入口）
   */
  public onUpdateMessageFactCheck(update: Record<string, Object>): void {
    // TODO: 实现消息事实核查
    hilog.debug(0x0001, 'CoreService', 'Message fact check updated');
  }

  /**
   * 处理新聊天（UpdateService 入口）
   */
  public onUpdateNewChat(update: Record<string, Object>): void {
    const chatId = update['chat_id'] as number;
    if (chatId) {
      this.refreshChat(chatId);
    }
  }

  /**
   * 处理聊天最后消息更新（UpdateService 入口）
   */
  public onUpdateChatLastMessage(update: Record<string, Object>): void {
    const chatId = update['chat_id'] as number;
    this.onChatLastMessageChanged(chatId);
  }

  /**
   * 处理聊天位置更新（UpdateService 入口）
   */
  public onUpdateChatPosition(update: Record<string, Object>): void {
    const chatId = update['chat_id'] as number;
    if (chatId) {
      this.refreshChat(chatId);
    }
  }

  /**
   * 处理聊天收件箱已读（UpdateService 入口）
   */
  public onUpdateChatReadInbox(update: Record<string, Object>): void {
    const chatId = update['chat_id'] as number;
    const unreadCount = update['unread_count'] as number;
    const lastReadInboxMessageId = update['last_read_inbox_message_id'] as number;
    
    hilog.info(0x0001, 'CoreService', 
      `⭐ [onUpdateChatReadInbox] chatId=${chatId}, unreadCount=${unreadCount}, lastReadInboxMessageId=${lastReadInboxMessageId}`);
    
    this.onChatInboxRead(chatId, unreadCount, lastReadInboxMessageId);
  }

  /**
   * 处理聊天发件箱已读（UpdateService 入口）
   */
  public onUpdateChatReadOutbox(update: Record<string, Object>): void {
    const chatId = update['chat_id'] as number;
    this.onChatOutboxRead(chatId);
  }

  /**
   * 处理聊天标题更新（UpdateService 入口）
   * ⭐ Nagram 参考：先写数据库，再更新内存
   */
  public async onUpdateChatTitle(update: Record<string, Object>): Promise<void> {
    const chatId = update['chat_id'] as number;
    const title = update['title'] as string;
    await this.onChatTitleChanged(chatId, title);
  }

  /**
   * 处理聊天头像更新（UpdateService 入口）
   */
  public onUpdateChatPhoto(update: Record<string, Object>): void {
    const chatId = update['chat_id'] as number;
    this.onChatPhotoChanged(chatId);
  }

  /**
   * 处理聊天权限更新（UpdateService 入口）
   */
  public onUpdateChatPermissions(update: Record<string, Object>): void {
    const chatId = update['chat_id'] as number;
    if (chatId) {
      this.refreshChat(chatId);
    }
  }

  /**
   * 处理聊天主题更新（UpdateService 入口）
   */
  public onUpdateChatThemes(update: Record<string, Object>): void {
    // TODO: 实现聊天主题更新
    hilog.debug(0x0001, 'CoreService', 'Chat themes updated');
  }

  /**
   * 处理聊天草稿消息更新（UpdateService 入口）
   */
  public onUpdateChatDraftMessage(update: Record<string, Object>): void {
    const chatId = update['chat_id'] as number;
    const draftMessage = update['draft_message'] as Record<string, Object> | null | undefined;
    this.onChatDraftMessageChanged(chatId, draftMessage);
  }

  /**
   * 处理聊天置顶状态更新（UpdateService 入口）
   */
  public onUpdateChatIsPinned(update: Record<string, Object>): void {
    const chatId = update['chat_id'] as number;
    this.onChatIsPinnedChanged(chatId);
  }

  /**
   * 处理聊天屏蔽状态更新（UpdateService 入口）
   */
  public onUpdateChatIsBlocked(update: Record<string, Object>): void {
    // TODO: 实现聊天屏蔽状态更新
    hilog.debug(0x0001, 'CoreService', 'Chat blocked status updated');
  }

  /**
   * 处理聊天定时消息更新（UpdateService 入口）
   */
  public onUpdateChatHasScheduledMessages(update: Record<string, Object>): void {
    // TODO: 实现聊天定时消息更新
    hilog.debug(0x0001, 'CoreService', 'Chat scheduled messages updated');
  }

  /**
   * 处理聊天消息发送者更新（UpdateService 入口）
   */
  public onUpdateChatMessageSender(update: Record<string, Object>): void {
    // TODO: 实现聊天消息发送者更新
    hilog.debug(0x0001, 'CoreService', 'Chat message sender updated');
  }

  /**
   * 处理消息自毁时间更新（UpdateService 入口）
   */
  public onUpdateChatMessageTtl(update: Record<string, Object>): void {
    // TODO: 实现消息自毁时间更新
    hilog.debug(0x0001, 'CoreService', 'Chat message TTL updated');
  }

  /**
   * 处理聊天通知设置更新（UpdateService 入口）
   */
  public onUpdateChatNotificationSettings(update: Record<string, Object>): void {
    const chatId = update['chat_id'] as number;
    const settings = update['notification_settings'] as Record<string, Object> | undefined;
    this.onChatNotificationSettingsChanged(chatId, settings);
  }

  /**
   * 处理聊天操作栏更新（UpdateService 入口）
   */
  public onUpdateChatActionBar(update: Record<string, Object>): void {
    // TODO: 实现聊天操作栏更新
    hilog.debug(0x0001, 'CoreService', 'Chat action bar updated');
  }

  /**
   * 处理聊天待处理加入请求更新（UpdateService 入口）
   */
  public onUpdateChatPendingJoinRequests(update: Record<string, Object>): void {
    // TODO: 实现聊天待处理加入请求更新
    hilog.debug(0x0001, 'CoreService', 'Chat pending join requests updated');
  }

  /**
   * 处理聊天回复标记更新（UpdateService 入口）
   */
  public onUpdateChatReplyMarkup(update: Record<string, Object>): void {
    // TODO: 实现聊天回复标记更新
    hilog.debug(0x0001, 'CoreService', 'Chat reply markup updated');
  }

  /**
   * 处理聊天可用反应更新（UpdateService 入口）
   */
  public onUpdateChatAvailableReactions(update: Record<string, Object>): void {
    // TODO: 实现聊天可用反应更新
    hilog.debug(0x0001, 'CoreService', 'Chat available reactions updated');
  }

  /**
   * 处理聊天视频通话更新（UpdateService 入口）
   */
  public onUpdateChatVideoChat(update: Record<string, Object>): void {
    // TODO: 实现聊天视频通话更新
    hilog.debug(0x0001, 'CoreService', 'Chat video chat updated');
  }

  /**
   * 处理聊天默认禁用通知更新（UpdateService 入口）
   */
  public onUpdateChatDefaultDisableNotification(update: Record<string, Object>): void {
    // TODO: 实现聊天默认禁用通知更新
    hilog.debug(0x0001, 'CoreService', 'Chat default disable notification updated');
  }

  /**
   * 处理聊天受保护内容更新（UpdateService 入口）
   */
  public onUpdateChatHasProtectedContent(update: Record<string, Object>): void {
    // TODO: 实现聊天受保护内容更新
    hilog.debug(0x0001, 'CoreService', 'Chat protected content updated');
  }

  /**
   * 处理聊天标记为未读状态更新（UpdateService 入口）
   */
  public onUpdateChatIsMarkedAsUnread(update: Record<string, Object>): void {
    const chatId = update['chat_id'] as number;
    if (chatId) {
      this.refreshChat(chatId);
    }
  }

  /**
   * 处理聊天在线成员数更新（UpdateService 入口）
   */
  public onUpdateChatOnlineMemberCount(update: Record<string, Object>): void {
    // TODO: 实现聊天在线成员数更新
    hilog.debug(0x0001, 'CoreService', 'Chat online member count updated');
  }

  /**
   * 处理聊天背景更新（UpdateService 入口）
   */
  public onUpdateChatBackground(update: Record<string, Object>): void {
    // TODO: 实现聊天背景更新
    hilog.debug(0x0001, 'CoreService', 'Chat background updated');
  }

  /**
   * 处理聊天建议更新（UpdateService 入口）
   */
  public onUpdateChatSuggestion(update: Record<string, Object>): void {
    // TODO: 实现聊天建议更新
    hilog.debug(0x0001, 'CoreService', 'Chat suggestion updated');
  }

  /**
   * 处理聊天助力更新（UpdateService 入口）
   */
  public onUpdateChatBoost(update: Record<string, Object>): void {
    // TODO: 实现聊天助力更新
    hilog.debug(0x0001, 'CoreService', 'Chat boost updated');
  }

  /**
   * 处理聊天助力状态更新（UpdateService 入口）
   */
  public onUpdateChatBoostStatus(update: Record<string, Object>): void {
    // TODO: 实现聊天助力状态更新
    hilog.debug(0x0001, 'CoreService', 'Chat boost status updated');
  }

  /**
   * 处理聊天赞助状态更新（UpdateService 入口）
   */
  public onUpdateChatIsSponsored(update: Record<string, Object>): void {
    // TODO: 实现聊天赞助状态更新
    hilog.debug(0x0001, 'CoreService', 'Chat sponsored status updated');
  }

  /**
   * 处理聊天统计更新（UpdateService 入口）
   */
  public onUpdateChatStatistics(update: Record<string, Object>): void {
    // TODO: 实现聊天统计更新
    hilog.debug(0x0001, 'CoreService', 'Chat statistics updated');
  }

  /**
   * 处理聊天动作更新（UpdateService 入口）
   */
  public onUpdateChatAction(update: Record<string, Object>): void {
    const chatId = update['chat_id'] as number;
    const action = update['action'] as Record<string, Object>;
    this.onChatAction(chatId, action);
  }

  /**
   * 处理用户更新（UpdateService 入口）
   * ⭐ Nagram 参考：先写数据库（putUsers），再更新内存
   */
  public async onUpdateUser(update: Record<string, Object>): Promise<void> {
    const userId = update['user_id'] as number;
    
    // ⭐ Nagram 参考：先保存用户数据到数据库
    // TDLib updateUser 包含完整 user 对象，直接持久化
    const userObj = update['user'] as Record<string, Object> | undefined;
    if (userObj && this.cacheStorage) {
      try {
        const tdlibConverterModule = await import('../core/TdlibConverter');
        const userEntity = tdlibConverterModule.TdlibConverter.convertToUser(userObj);
        await this.cacheStorage.saveUser(userEntity);
        hilog.info(0x0001, 'CoreService', `💾 [DB-FIRST] User ${userId} saved to database`);
      } catch (error) {
        hilog.warn(0x0001, 'CoreService', `Failed to save user ${userId} to DB: ${JSON.stringify(error)}`);
      }
    }
    
    this.onUserUpdated(userId);
  }

  /**
   * 处理用户完整信息更新（UpdateService 入口）
   */
  public onUpdateUserFullInfo(update: Record<string, Object>): void {
    const userId = update['user_id'] as number;
    this.onUserFullInfoUpdated(userId);
  }

  /**
   * 处理用户状态更新（UpdateService 入口）
   * ⭐ Nagram 参考：先写数据库，再更新内存
   */
  public async onUpdateUserStatus(update: Record<string, Object>): Promise<void> {
    const userId = update['user_id'] as number;
    const status = update['status'] as Record<string, Object>;
    
    // ⭐ Nagram 参考：同步用户状态到数据库
    if (this.cacheStorage && userId) {
      try {
        const existingEntity = await this.cacheStorage.database.getUserByUserId(userId);
        if (existingEntity) {
          existingEntity.statusJson = JSON.stringify(status);
          await this.cacheStorage.database.updateUser(existingEntity);
          hilog.debug(0x0001, 'CoreService', `💾 [DB-FIRST] User ${userId} status updated in DB`);
        }
      } catch (error) {
        hilog.warn(0x0001, 'CoreService', `Failed to update user ${userId} status in DB: ${JSON.stringify(error)}`);
      }
    }
    
    this.onUserStatusUpdated(userId, status);
  }

  /**
   * 处理用户隐私设置规则更新（UpdateService 入口）
   */
  public onUpdateUserPrivacySettingRules(update: Record<string, Object>): void {
    // TODO: 实现用户隐私设置规则更新
    hilog.debug(0x0001, 'CoreService', 'User privacy setting rules updated');
  }

  /**
   * 处理用户用户名更新（UpdateService 入口）
   */
  public onUpdateUserUsername(update: Record<string, Object>): void {
    // TODO: 实现用户用户名更新
    hilog.debug(0x0001, 'CoreService', 'User username updated');
  }

  /**
   * 处理基础群组更新（UpdateService 入口）
   */
  public onUpdateBasicGroup(update: Record<string, Object>): void {
    // TODO: 实现基础群组更新
    hilog.debug(0x0001, 'CoreService', 'Basic group updated');
  }

  /**
   * 处理基础群组完整信息更新（UpdateService 入口）
   */
  public onUpdateBasicGroupFullInfo(update: Record<string, Object>): void {
    // TODO: 实现基础群组完整信息更新
    hilog.debug(0x0001, 'CoreService', 'Basic group full info updated');
  }

  /**
   * 处理超级群组更新（UpdateService 入口）
   */
  public onUpdateSupergroup(update: Record<string, Object>): void {
    // TODO: 实现超级群组更新
    hilog.debug(0x0001, 'CoreService', 'Supergroup updated');
  }

  /**
   * 处理超级群组完整信息更新（UpdateService 入口）
   */
  public onUpdateSupergroupFullInfo(update: Record<string, Object>): void {
    // TODO: 实现超级群组完整信息更新
    hilog.debug(0x0001, 'CoreService', 'Supergroup full info updated');
  }

  /**
   * 处理超级群组反应设置更新（UpdateService 入口）
   */
  public onUpdateSupergroupReactionSetting(update: Record<string, Object>): void {
    // TODO: 实现超级群组反应设置更新
    hilog.debug(0x0001, 'CoreService', 'Supergroup reaction setting updated');
  }

  /**
   * 处理秘密聊天更新（UpdateService 入口）
   */
  public onUpdateSecretChat(update: Record<string, Object>): void {
    // TODO: 实现秘密聊天更新
    hilog.debug(0x0001, 'CoreService', 'Secret chat updated');
  }

  /**
   * 处理秘密聊天已读（UpdateService 入口）
   */
  public onUpdateSecretChatRead(update: Record<string, Object>): void {
    // TODO: 实现秘密聊天已读
    hilog.debug(0x0001, 'CoreService', 'Secret chat read');
  }

  /**
   * 处理授权状态更新（UpdateService 入口）
   * 
   * 职责：处理 TDLib 认证状态机，驱动整个登录流程
   * 状态流转：WaitTdlibParameters → WaitEncryptionKey → WaitPhoneNumber → WaitCode → [WaitPassword] → Ready
   */
  public onUpdateAuthorizationState(update: Record<string, Object>): void {
    const authState = update['authorization_state'] as Record<string, Object>;
    if (!authState) {
      hilog.warn(0x0001, 'CoreService', 'Invalid authorization state update');
      return;
    }

    const authType = authState['@type'] as string;
    const oldState = this.currentAuthState;
    this.currentAuthState = authType;

    hilog.info(0x0001, 'CoreService', `🔐 Auth state changed: ${oldState} → ${authType}`);

    // 发布领域事件：认证状态变更
    const stateChangedEvent: Record<string, Object> = {
      'oldState': oldState as Object,
      'newState': authType as Object,
      'authState': authState as Object
    };
    eventBus.emit('core:authStateChanged', stateChangedEvent);

    // 处理各状态的具体业务逻辑
    switch (authType) {
      case 'authorizationStateWaitTdlibParameters':
        this.handleWaitTdlibParameters(authState);
        break;
      case 'authorizationStateWaitEncryptionKey':
        this.handleWaitEncryptionKey(authState);
        break;
      case 'authorizationStateWaitPhoneNumber':
        this.handleWaitPhoneNumber(authState);
        break;
      case 'authorizationStateWaitCode':
        this.handleWaitCode(authState);
        break;
      case 'authorizationStateWaitPassword':
        this.handleWaitPassword(authState);
        break;
      case 'authorizationStateWaitRegistration':
        this.handleWaitRegistration(authState);
        break;
      case 'authorizationStateWaitOtherDeviceConfirmation':
        this.handleWaitOtherDeviceConfirmation(authState);
        break;
      case 'authorizationStateReady':
        this.handleAuthReady(authState);
        break;
      case 'authorizationStateLoggingOut':
        this.handleLoggingOut(authState);
        break;
      case 'authorizationStateClosed':
        this.handleAuthClosed(authState);
        break;
      default:
        hilog.warn(0x0001, 'CoreService', `Unhandled auth state: ${authType}`);
    }
  }

  // ==================== 认证状态处理器 ====================

  /**
   * 处理等待 TDLib 参数状态
   */
  private handleWaitTdlibParameters(authState: Record<string, Object>): void {
    hilog.info(0x0001, 'CoreService', '📋 Waiting for TDLib parameters');
    // 发布事件通知 UI 层或初始化服务设置参数
    const eventData: Record<string, Object> = { 'authState': authState };
    eventBus.emit('core:authWaitTdlibParameters', eventData);
  }

  /**
   * 处理等待加密密钥状态
   */
  private handleWaitEncryptionKey(authState: Record<string, Object>): void {
    hilog.info(0x0001, 'CoreService', '🔑 Waiting for encryption key');
    // 发布事件通知设置数据库加密密钥
    const eventData: Record<string, Object> = { 'authState': authState };
    eventBus.emit('core:authWaitEncryptionKey', eventData);
  }

  /**
   * 处理等待手机号状态
   */
  private handleWaitPhoneNumber(authState: Record<string, Object>): void {
    hilog.info(0x0001, 'CoreService', '📱 Waiting for phone number');
    // 发布事件通知 UI 层显示手机号输入界面
    const eventData: Record<string, Object> = { 'authState': authState };
    eventBus.emit('core:authWaitPhoneNumber', eventData);
  }

  /**
   * 处理等待验证码状态
   */
  private handleWaitCode(authState: Record<string, Object>): void {
    const codeInfo = authState['code_info'] as Record<string, Object>;
    let codeInfoType = '';
    let codeLength = 0;
    let timeoutSeconds = 60;

    if (codeInfo) {
      const typeObj = codeInfo['type'] as Record<string, Object>;
      if (typeObj) {
        codeInfoType = typeObj['@type'] as string || '';
        const lenVal = typeObj['length'] as number;
        if (typeof lenVal === 'number' && lenVal >= 4 && lenVal <= 8) {
          codeLength = lenVal;
        }
      }
      timeoutSeconds = codeInfo['timeout'] as number || 60;
    }

    hilog.info(0x0001, 'CoreService', `📲 Waiting for code (type: ${codeInfoType}, length: ${codeLength}, timeout: ${timeoutSeconds}s)`);

    // 发布事件通知 UI 层显示验证码输入界面
    const eventData: Record<string, Object> = {
      'authState': authState as Object,
      'codeInfoType': codeInfoType as Object,
      'codeLength': codeLength as Object,
      'timeoutSeconds': timeoutSeconds as Object
    };
    eventBus.emit('core:authWaitCode', eventData);
  }

  /**
   * 处理等待密码状态（两步验证）
   */
  private handleWaitPassword(authState: Record<string, Object>): void {
    const passwordHint = authState['password_hint'] as string || '';
    const hasRecoveryEmail = authState['has_recovery_email_address'] as boolean || false;

    hilog.info(0x0001, 'CoreService', `🔒 Waiting for password (hint: ${passwordHint}, hasRecovery: ${hasRecoveryEmail})`);

    // 发布事件通知 UI 层显示密码输入界面
    const eventData: Record<string, Object> = {
      'authState': authState as Object,
      'passwordHint': passwordHint as Object,
      'hasRecoveryEmail': hasRecoveryEmail as Object
    };
    eventBus.emit('core:authWaitPassword', eventData);
  }

  /**
   * 处理等待注册状态（新用户）
   */
  private handleWaitRegistration(authState: Record<string, Object>): void {
    const termsOfService = authState['terms_of_service'] as Record<string, Object>;

    hilog.info(0x0001, 'CoreService', '📝 Waiting for registration');

    // 发布事件通知 UI 层显示注册界面
    const termsObj: Record<string, Object> = termsOfService || {};
    const eventData: Record<string, Object> = {
      'authState': authState as Object,
      'termsOfService': termsObj as Object
    };
    eventBus.emit('core:authWaitRegistration', eventData);
  }

  /**
   * 处理等待其他设备确认状态（二维码登录）
   */
  private handleWaitOtherDeviceConfirmation(authState: Record<string, Object>): void {
    const link = authState['link'] as string || '';

    hilog.info(0x0001, 'CoreService', `🔗 Waiting for other device confirmation: ${link}`);

    // 发布事件通知 UI 层显示二维码
    const eventData: Record<string, Object> = {
      'authState': authState as Object,
      'link': link as Object
    };
    eventBus.emit('core:authWaitOtherDeviceConfirmation', eventData);
  }

  /**
   * 处理认证就绪状态
   */
  private handleAuthReady(authState: Record<string, Object>): void {
    hilog.info(0x0001, 'CoreService', '✅ Authorization ready');

    this.isAuthReady = true;

    // 发布领域事件：认证完成
    const eventData: Record<string, Object> = { 'authState': authState };
    eventBus.emit('core:authReady', eventData);

    // 执行待处理的回调
    this.executePendingAuthCallbacks();
  }

  /**
   * 处理登出中状态
   */
  private handleLoggingOut(authState: Record<string, Object>): void {
    hilog.info(0x0001, 'CoreService', '🚪 Logging out');
    const eventData: Record<string, Object> = { 'authState': authState };
    eventBus.emit('core:authLoggingOut', eventData);
  }

  /**
   * 处理认证关闭状态
   */
  private handleAuthClosed(authState: Record<string, Object>): void {
    hilog.info(0x0001, 'CoreService', '🔒 Authorization closed');
    this.isAuthReady = false;
    this.currentAuthState = 'authorizationStateWaitTdlibParameters';
    const eventData: Record<string, Object> = { 'authState': authState };
    eventBus.emit('core:authClosed', eventData);
  }

  // ==================== 认证辅助方法 ====================

  /**
   * 在授权完成后执行回调
   */
  public executeWhenReady(callback: () => void, description?: string): void {
    if (this.isAuthReady) {
      hilog.info(0x0001, 'CoreService', `✅ Auth ready, executing immediately: ${description || 'unnamed'}`);
      setTimeout(() => {
        try {
          callback();
        } catch (error) {
          hilog.error(0x0001, 'CoreService', `Callback failed: ${JSON.stringify(error)}`);
        }
      }, 0);
    } else {
      hilog.info(0x0001, 'CoreService', `⏳ Queuing callback: ${description || 'unnamed'}`);
      this.pendingAuthCallbacks.push(callback);
    }
  }

  /**
   * 异步等待授权完成
   */
  public waitForAuth(): Promise<void> {
    return new Promise((resolve) => {
      if (this.isAuthReady) {
        resolve();
      } else {
        this.executeWhenReady(() => resolve(), 'waitForAuth');
      }
    });
  }

  /**
   * 执行待处理的认证回调
   */
  private executePendingAuthCallbacks(): void {
    const callbacks = this.pendingAuthCallbacks;
    this.pendingAuthCallbacks = [];

    callbacks.forEach((callback, index) => {
      hilog.info(0x0001, 'CoreService', `Executing pending callback #${index + 1}`);
      try {
        callback();
      } catch (error) {
        hilog.error(0x0001, 'CoreService', `Callback #${index + 1} failed: ${JSON.stringify(error)}`);
      }
    });
  }

  /**
   * 获取当前授权状态
   */
  public getAuthState(): string {
    return this.currentAuthState;
  }

  /**
   * 检查是否已授权完成
   */
  public isReady(): boolean {
    return this.isAuthReady;
  }

  /**
   * 重置授权状态（用于登出后重新登录）
   */
  public resetAuthState(): void {
    this.isAuthReady = false;
    this.currentAuthState = 'authorizationStateWaitTdlibParameters';
    this.pendingAuthCallbacks = [];
    hilog.info(0x0001, 'CoreService', '🔄 Auth state reset');
  }

  /**
   * 处理连接状态更新（UpdateService 入口）
   */
  public onUpdateConnectionState(update: Record<string, Object>): void {
    const state = update['state'] as Record<string, Object>;
    this.onConnectionStateUpdated(state);
  }

  /**
   * 处理选项更新（UpdateService 入口）
   */
  public onUpdateOption(update: Record<string, Object>): void {
    const name = update['name'] as string;
    const value = update['value'] as Record<string, Object>;
    this.onOptionUpdated(name, value);
  }

  /**
   * 处理服务通知更新（UpdateService 入口）
   */
  public onUpdateServiceNotification(update: Record<string, Object>): void {
    // TODO: 实现服务通知更新
    hilog.debug(0x0001, 'CoreService', 'Service notification updated');
  }

  /**
   * 处理服务条款更新（UpdateService 入口）
   */
  public onUpdateTermsOfService(update: Record<string, Object>): void {
    // TODO: 实现服务条款更新
    hilog.debug(0x0001, 'CoreService', 'Terms of service updated');
  }

  /**
   * 处理活动通知更新（UpdateService 入口）
   */
  public onUpdateActiveNotifications(update: Record<string, Object>): void {
    // TODO: 实现活动通知更新
    hilog.debug(0x0001, 'CoreService', 'Active notifications updated');
  }

  /**
   * 处理通知更新（UpdateService 入口）
   */
  public onUpdateNotification(update: Record<string, Object>): void {
    // TODO: 实现通知更新
    hilog.debug(0x0001, 'CoreService', 'Notification updated');
  }

  /**
   * 处理通知组更新（UpdateService 入口）
   */
  public onUpdateNotificationGroup(update: Record<string, Object>): void {
    // TODO: 实现通知组更新
    hilog.debug(0x0001, 'CoreService', 'Notification group updated');
  }

  /**
   * 处理未读消息数更新（UpdateService 入口）
   */
  public onUpdateUnreadMessageCount(update: Record<string, Object>): void {
    // TODO: 实现未读消息数更新
    hilog.debug(0x0001, 'CoreService', 'Unread message count updated');
  }

  /**
   * 处理未读聊天数更新（UpdateService 入口）
   */
  public onUpdateUnreadChatCount(update: Record<string, Object>): void {
    // TODO: 实现未读聊天数更新
    hilog.debug(0x0001, 'CoreService', 'Unread chat count updated');
  }

  /**
   * 处理文件更新（UpdateService 入口）
   */
  public onUpdateFile(update: Record<string, Object>): void {
    const file = update['file'] as Record<string, Object>;
    this.onFileUpdated(file);
  }

  /**
   * 处理文件生成开始（UpdateService 入口）
   */
  public onUpdateFileGenerationStart(update: Record<string, Object>): void {
    // TODO: 实现文件生成开始
    hilog.debug(0x0001, 'CoreService', 'File generation started');
  }

  /**
   * 处理文件生成停止（UpdateService 入口）
   */
  public onUpdateFileGenerationStop(update: Record<string, Object>): void {
    // TODO: 实现文件生成停止
    hilog.debug(0x0001, 'CoreService', 'File generation stopped');
  }

  /**
   * 处理新通话（UpdateService 入口）
   */
  public onUpdateNewCall(update: Record<string, Object>): void {
    // TODO: 实现新通话
    hilog.debug(0x0001, 'CoreService', 'New call received');
  }

  /**
   * 处理通话更新（UpdateService 入口）
   */
  public onUpdateCall(update: Record<string, Object>): void {
    // TODO: 实现通话更新
    hilog.debug(0x0001, 'CoreService', 'Call updated');
  }

  /**
   * 处理群组通话更新（UpdateService 入口）
   */
  public onUpdateGroupCall(update: Record<string, Object>): void {
    // TODO: 实现群组通话更新
    hilog.debug(0x0001, 'CoreService', 'Group call updated');
  }

  /**
   * 处理群组通话参与者更新（UpdateService 入口）
   */
  public onUpdateGroupCallParticipant(update: Record<string, Object>): void {
    // TODO: 实现群组通话参与者更新
    hilog.debug(0x0001, 'CoreService', 'Group call participant updated');
  }

  /**
   * 处理新自定义查询（UpdateService 入口）
   */
  public onUpdateNewCustomQuery(update: Record<string, Object>): void {
    // TODO: 实现新自定义查询
    hilog.debug(0x0001, 'CoreService', 'New custom query received');
  }

  /**
   * 处理新回调查询（UpdateService 入口）
   */
  public onUpdateNewCallbackQuery(update: Record<string, Object>): void {
    // TODO: 实现新回调查询
    hilog.debug(0x0001, 'CoreService', 'New callback query received');
  }

  /**
   * 处理新内联查询（UpdateService 入口）
   */
  public onUpdateNewInlineQuery(update: Record<string, Object>): void {
    // TODO: 实现新内联查询
    hilog.debug(0x0001, 'CoreService', 'New inline query received');
  }

  /**
   * 处理新预结账查询（UpdateService 入口）
   */
  public onUpdateNewPreCheckoutQuery(update: Record<string, Object>): void {
    // TODO: 实现新预结账查询
    hilog.debug(0x0001, 'CoreService', 'New pre-checkout query received');
  }

  /**
   * 处理新选择的内联结果（UpdateService 入口）
   */
  public onUpdateNewChosenInlineResult(update: Record<string, Object>): void {
    // TODO: 实现新选择的内联结果
    hilog.debug(0x0001, 'CoreService', 'New chosen inline result received');
  }

  /**
   * 处理新配送查询（UpdateService 入口）
   */
  public onUpdateNewShippingQuery(update: Record<string, Object>): void {
    // TODO: 实现新配送查询
    hilog.debug(0x0001, 'CoreService', 'New shipping query received');
  }

  /**
   * 处理投票更新（UpdateService 入口）
   */
  public onUpdatePoll(update: Record<string, Object>): void {
    // TODO: 实现投票更新
    hilog.debug(0x0001, 'CoreService', 'Poll updated');
  }

  /**
   * 处理投票答案更新（UpdateService 入口）
   */
  public onUpdatePollAnswer(update: Record<string, Object>): void {
    // TODO: 实现投票答案更新
    hilog.debug(0x0001, 'CoreService', 'Poll answer updated');
  }

  /**
   * 处理新故事（UpdateService 入口）
   */
  public onUpdateNewStory(update: Record<string, Object>): void {
    // TODO: 实现新故事
    hilog.debug(0x0001, 'CoreService', 'New story received');
  }

  /**
   * 处理故事更新（UpdateService 入口）
   */
  public onUpdateStory(update: Record<string, Object>): void {
    // TODO: 实现故事更新
    hilog.debug(0x0001, 'CoreService', 'Story updated');
  }

  /**
   * 处理故事删除（UpdateService 入口）
   */
  public onUpdateStoryDeleted(update: Record<string, Object>): void {
    // TODO: 实现故事删除
    hilog.debug(0x0001, 'CoreService', 'Story deleted');
  }

  /**
   * 处理聊天活动故事更新（UpdateService 入口）
   */
  public onUpdateChatActiveStories(update: Record<string, Object>): void {
    // TODO: 实现聊天活动故事更新
    hilog.debug(0x0001, 'CoreService', 'Chat active stories updated');
  }

  /**
   * 处理聊天发送故事更新（UpdateService 入口）
   */
  public onUpdateChatSentStory(update: Record<string, Object>): void {
    // TODO: 实现聊天发送故事更新
    hilog.debug(0x0001, 'CoreService', 'Chat sent story updated');
  }

  /**
   * 处理聊天故事更新（UpdateService 入口）
   */
  public onUpdateChatStory(update: Record<string, Object>): void {
    // TODO: 实现聊天故事更新
    hilog.debug(0x0001, 'CoreService', 'Chat story updated');
  }

  /**
   * 处理故事交互信息更新（UpdateService 入口）
   */
  public onUpdateStoryInteractionInfo(update: Record<string, Object>): void {
    // TODO: 实现故事交互信息更新
    hilog.debug(0x0001, 'CoreService', 'Story interaction info updated');
  }

  /**
   * 处理故事列表更新（UpdateService 入口）
   */
  public onUpdateStoryList(update: Record<string, Object>): void {
    // TODO: 实现故事列表更新
    hilog.debug(0x0001, 'CoreService', 'Story list updated');
  }

  /**
   * 处理聊天接收故事更新（UpdateService 入口）
   */
  public onUpdateChatReceiveStory(update: Record<string, Object>): void {
    // TODO: 实现聊天接收故事更新
    hilog.debug(0x0001, 'CoreService', 'Chat receive story updated');
  }

  /**
   * 处理聊天故事交互区域更新（UpdateService 入口）
   */
  public onUpdateChatStoryInteractiveArea(update: Record<string, Object>): void {
    // TODO: 实现聊天故事交互区域更新
    hilog.debug(0x0001, 'CoreService', 'Chat story interactive area updated');
  }

  /**
   * 处理已安装贴纸集更新（UpdateService 入口）
   */
  public onUpdateInstalledStickerSets(update: Record<string, Object>): void {
    // TODO: 实现已安装贴纸集更新
    hilog.debug(0x0001, 'CoreService', 'Installed sticker sets updated');
  }

  /**
   * 处理热门贴纸集更新（UpdateService 入口）
   */
  public onUpdateTrendingStickerSets(update: Record<string, Object>): void {
    // TODO: 实现热门贴纸集更新
    hilog.debug(0x0001, 'CoreService', 'Trending sticker sets updated');
  }

  /**
   * 处理最近贴纸更新（UpdateService 入口）
   */
  public onUpdateRecentStickers(update: Record<string, Object>): void {
    // TODO: 实现最近贴纸更新
    hilog.debug(0x0001, 'CoreService', 'Recent stickers updated');
  }

  /**
   * 处理收藏贴纸更新（UpdateService 入口）
   */
  public onUpdateFavoriteStickers(update: Record<string, Object>): void {
    // TODO: 实现收藏贴纸更新
    hilog.debug(0x0001, 'CoreService', 'Favorite stickers updated');
  }

  /**
   * 处理最近表情状态更新（UpdateService 入口）
   */
  public onUpdateRecentEmojiStatuses(update: Record<string, Object>): void {
    // TODO: 实现最近表情状态更新
    hilog.debug(0x0001, 'CoreService', 'Recent emoji statuses updated');
  }

  /**
   * 处理表情反应更新（UpdateService 入口）
   */
  public onUpdateEmojiReaction(update: Record<string, Object>): void {
    // TODO: 实现表情反应更新
    hilog.debug(0x0001, 'CoreService', 'Emoji reaction updated');
  }

  /**
   * 处理表情状态更新（UpdateService 入口）
   */
  public onUpdateEmojiStatus(update: Record<string, Object>): void {
    // TODO: 实现表情状态更新
    hilog.debug(0x0001, 'CoreService', 'Emoji status updated');
  }

  /**
   * 处理骰子表情更新（UpdateService 入口）
   */
  public onUpdateDiceEmojis(update: Record<string, Object>): void {
    // TODO: 实现骰子表情更新
    hilog.debug(0x0001, 'CoreService', 'Dice emojis updated');
  }

  /**
   * 处理动画表情消息点击（UpdateService 入口）
   */
  public onUpdateAnimatedEmojiMessageClicked(update: Record<string, Object>): void {
    // TODO: 实现动画表情消息点击
    hilog.debug(0x0001, 'CoreService', 'Animated emoji message clicked');
  }

  /**
   * 处理动画搜索参数更新（UpdateService 入口）
   */
  public onUpdateAnimationSearchParameters(update: Record<string, Object>): void {
    // TODO: 实现动画搜索参数更新
    hilog.debug(0x0001, 'CoreService', 'Animation search parameters updated');
  }

  /**
   * 处理聊天筛选器更新（UpdateService 入口）
   */
  public onUpdateChatFilters(update: Record<string, Object>): void {
    // TODO: 实现聊天筛选器更新
    hilog.debug(0x0001, 'CoreService', 'Chat filters updated');
  }

  /**
   * 处理聊天筛选器项更新（UpdateService 入口）
   */
  public onUpdateChatFilter(update: Record<string, Object>): void {
    // TODO: 实现聊天筛选器项更新
    hilog.debug(0x0001, 'CoreService', 'Chat filter updated');
  }

  /**
   * 处理聊天筛选器聊天列表更新（UpdateService 入口）
   */
  public onUpdateChatFilterChats(update: Record<string, Object>): void {
    // TODO: 实现聊天筛选器聊天列表更新
    hilog.debug(0x0001, 'CoreService', 'Chat filter chats updated');
  }

  /**
   * 处理聊天筛选器默认设置更新（UpdateService 入口）
   */
  public onUpdateChatFilterDefault(update: Record<string, Object>): void {
    // TODO: 实现聊天筛选器默认设置更新
    hilog.debug(0x0001, 'CoreService', 'Chat filter default updated');
  }

  /**
   * 处理聊天筛选器顺序更新（UpdateService 入口）
   */
  public onUpdateChatFilterOrder(update: Record<string, Object>): void {
    // TODO: 实现聊天筛选器顺序更新
    hilog.debug(0x0001, 'CoreService', 'Chat filter order updated');
  }

  /**
   * 处理聊天筛选器置顶状态更新（UpdateService 入口）
   */
  public onUpdateChatFilterIsPinned(update: Record<string, Object>): void {
    // TODO: 实现聊天筛选器置顶状态更新
    hilog.debug(0x0001, 'CoreService', 'Chat filter pinned status updated');
  }

  /**
   * 处理聊天筛选器邀请更新（UpdateService 入口）
   */
  public onUpdateChatFilterHasMyInvites(update: Record<string, Object>): void {
    // TODO: 实现聊天筛选器邀请更新
    hilog.debug(0x0001, 'CoreService', 'Chat filter invites updated');
  }

  /**
   * 处理自动保存设置更新（UpdateService 入口）
   */
  public onUpdateAutosaveSettings(update: Record<string, Object>): void {
    // TODO: 实现自动保存设置更新
    hilog.debug(0x0001, 'CoreService', 'Autosave settings updated');
  }

  /**
   * 处理范围通知设置更新（UpdateService 入口）
   */
  public onUpdateScopeNotificationSettings(update: Record<string, Object>): void {
    // TODO: 实现范围通知设置更新
    hilog.debug(0x0001, 'CoreService', 'Scope notification settings updated');
  }

  /**
   * 处理国家列表更新（UpdateService 入口）
   */
  public onUpdateCountriesList(update: Record<string, Object>): void {
    // TODO: 实现国家列表更新
    hilog.debug(0x0001, 'CoreService', 'Countries list updated');
  }

  /**
   * 处理电话号码代码更新（UpdateService 入口）
   */
  public onUpdatePhoneNumberCode(update: Record<string, Object>): void {
    // TODO: 实现电话号码代码更新
    hilog.debug(0x0001, 'CoreService', 'Phone number code updated');
  }

  /**
   * 处理附近用户更新（UpdateService 入口）
   */
  public onUpdateUsersNearby(update: Record<string, Object>): void {
    // TODO: 实现附近用户更新
    hilog.debug(0x0001, 'CoreService', 'Users nearby updated');
  }

  /**
   * 处理语言包字符串更新（UpdateService 入口）
   */
  public onUpdateLanguagePackStrings(update: Record<string, Object>): void {
    // TODO: 实现语言包字符串更新
    hilog.debug(0x0001, 'CoreService', 'Language pack strings updated');
  }

  /**
   * 处理已保存消息主题更新（UpdateService 入口）
   */
  public onUpdateSavedMessagesTopic(update: Record<string, Object>): void {
    // TODO: 实现已保存消息主题更新
    hilog.debug(0x0001, 'CoreService', 'Saved messages topic updated');
  }

  /**
   * 处理已保存消息主题消息更新（UpdateService 入口）
   */
  public onUpdateSavedMessagesTopicMessages(update: Record<string, Object>): void {
    // TODO: 实现已保存消息主题消息更新
    hilog.debug(0x0001, 'CoreService', 'Saved messages topic messages updated');
  }

  /**
   * 处理已保存消息主题列表更新（UpdateService 入口）
   */
  public onUpdateSavedMessagesTopics(update: Record<string, Object>): void {
    // TODO: 实现已保存消息主题列表更新
    hilog.debug(0x0001, 'CoreService', 'Saved messages topics updated');
  }

  /**
   * 处理附件菜单机器人更新（UpdateService 入口）
   */
  public onUpdateAttachmentMenuBots(update: Record<string, Object>): void {
    // TODO: 实现附件菜单机器人更新
    hilog.debug(0x0001, 'CoreService', 'Attachment menu bots updated');
  }

  /**
   * 处理 Web 应用更新（UpdateService 入口）
   */
  public onUpdateWebApp(update: Record<string, Object>): void {
    // TODO: 实现 Web 应用更新
    hilog.debug(0x0001, 'CoreService', 'Web app updated');
  }

  /**
   * 处理 Premium 促销更新（UpdateService 入口）
   */
  public onUpdatePremiumPromo(update: Record<string, Object>): void {
    // TODO: 实现 Premium 促销更新
    hilog.debug(0x0001, 'CoreService', 'Premium promo updated');
  }

  /**
   * 处理 Premium 状态更新（UpdateService 入口）
   */
  public onUpdatePremiumState(update: Record<string, Object>): void {
    // TODO: 实现 Premium 状态更新
    hilog.debug(0x0001, 'CoreService', 'Premium state updated');
  }

  /**
   * 处理 Premium 礼品码更新（UpdateService 入口）
   */
  public onUpdatePremiumGiftCode(update: Record<string, Object>): void {
    // TODO: 实现 Premium 礼品码更新
    hilog.debug(0x0001, 'CoreService', 'Premium gift code updated');
  }

  /**
   * 处理 Premium 支付验证更新（UpdateService 入口）
   */
  public onUpdatePremiumPaymentVerification(update: Record<string, Object>): void {
    // TODO: 实现 Premium 支付验证更新
    hilog.debug(0x0001, 'CoreService', 'Premium payment verification updated');
  }

  /**
   * 处理事实核查更新（UpdateService 入口）
   */
  public onUpdateFactCheck(update: Record<string, Object>): void {
    // TODO: 实现事实核查更新
    hilog.debug(0x0001, 'CoreService', 'Fact check updated');
  }

  /**
   * 处理贴纸集更新（UpdateService 入口）
   */
  public onUpdateStickerSet(update: Record<string, Object>): void {
    // TODO: 实现贴纸集更新
    hilog.debug(0x0001, 'CoreService', 'Sticker set updated');
  }

  /**
   * 处理热门贴纸集更新（UpdateService 入口）
   */
  public onUpdateTrendingStickerSet(update: Record<string, Object>): void {
    // TODO: 实现热门贴纸集更新
    hilog.debug(0x0001, 'CoreService', 'Trending sticker set updated');
  }

  /**
   * 处理应用验证更新（UpdateService 入口）
   */
  public onUpdateApplicationVerification(update: Record<string, Object>): void {
    // TODO: 实现应用验证更新
    hilog.debug(0x0001, 'CoreService', 'Application verification updated');
  }

  /**
   * 处理验证状态更新（UpdateService 入口）
   */
  public onUpdateVerificationStatus(update: Record<string, Object>): void {
    // TODO: 实现验证状态更新
    hilog.debug(0x0001, 'CoreService', 'Verification status updated');
  }

  /**
   * 处理验证状态提供者更新（UpdateService 入口）
   */
  public onUpdateVerificationStatusProvider(update: Record<string, Object>): void {
    // TODO: 实现验证状态提供者更新
    hilog.debug(0x0001, 'CoreService', 'Verification status provider updated');
  }

  /**
   * 处理快速回复快捷方式更新（UpdateService 入口）
   */
  public onUpdateQuickReplyShortcuts(update: Record<string, Object>): void {
    // TODO: 实现快速回复快捷方式更新
    hilog.debug(0x0001, 'CoreService', 'Quick reply shortcuts updated');
  }

  /**
   * 处理快速回复快捷方式项更新（UpdateService 入口）
   */
  public onUpdateQuickReplyShortcut(update: Record<string, Object>): void {
    // TODO: 实现快速回复快捷方式项更新
    hilog.debug(0x0001, 'CoreService', 'Quick reply shortcut updated');
  }

  /**
   * 处理快速回复快捷方式消息更新（UpdateService 入口）
   */
  public onUpdateQuickReplyShortcutMessages(update: Record<string, Object>): void {
    // TODO: 实现快速回复快捷方式消息更新
    hilog.debug(0x0001, 'CoreService', 'Quick reply shortcut messages updated');
  }

  /**
   * 处理消息统计更新（UpdateService 入口）
   */
  public onUpdateMessageStatistics(update: Record<string, Object>): void {
    // TODO: 实现消息统计更新
    hilog.debug(0x0001, 'CoreService', 'Message statistics updated');
  }

  /**
   * 处理网络统计更新（UpdateService 入口）
   */
  public onUpdateNetworkStatistics(update: Record<string, Object>): void {
    // TODO: 实现网络统计更新
    hilog.debug(0x0001, 'CoreService', 'Network statistics updated');
  }

  /**
   * 处理同步状态更新（UpdateService 入口）
   */
  public onUpdateSyncState(update: Record<string, Object>): void {
    // TODO: 实现同步状态更新
    hilog.debug(0x0001, 'CoreService', 'Sync state updated');
  }

  /**
   * 处理密码状态更新（UpdateService 入口）
   */
  public onUpdatePasswordState(update: Record<string, Object>): void {
    const passwordState = update['password_state'] as Record<string, Object>;
    this.onPasswordStateUpdated(passwordState);
  }

  /**
   * 处理恢复邮箱地址更新（UpdateService 入口）
   */
  public onUpdateRecoveryEmailAddress(update: Record<string, Object>): void {
    // TODO: 实现恢复邮箱地址更新
    hilog.debug(0x0001, 'CoreService', 'Recovery email address updated');
  }

  /**
   * 处理登录码更新（UpdateService 入口）
   */
  public onUpdateLoginCode(update: Record<string, Object>): void {
    // TODO: 实现登录码更新
    hilog.debug(0x0001, 'CoreService', 'Login code updated');
  }

  /**
   * 处理关闭更新（UpdateService 入口）
   */
  public onUpdateClose(update: Record<string, Object>): void {
    hilog.info(0x0001, 'CoreService', 'TDLib connection closed');
  }

  /**
   * 处理确认更新（UpdateService 入口）
   */
  public onUpdateOk(update: Record<string, Object>): void {
    // 确认收到，无需处理
  }

  /**
   * 处理错误更新（UpdateService 入口）
   */
  public onUpdateError(update: Record<string, Object>): void {
    const error = update['error'] as Record<string, Object>;
    hilog.error(0x0001, 'CoreService', `TDLib error: ${JSON.stringify(error)}`);
  }

  // ==================== 实体转换方法 ====================

  /**
   * 将 Chat 转换为 ChatEntity
   */
  private convertChatToEntity(chat: Chat): ChatEntity {
    const entity = new ChatEntity();
    entity.chatId = chat.id;
    entity.title = chat.title;
    entity.type = chat.type;
    entity.lastMessageId = chat.lastMessage?.id || 0;
    entity.lastMessageDate = chat.timestamp ? Math.floor(chat.timestamp / 1000) : 0;
    entity.unreadCount = chat.unreadCount || 0;
    entity.isMuted = chat.isMuted || false;
    entity.isPinned = chat.isPinned || false;
    if (chat.draftMessage) {
      entity.draftMessage = chat.draftMessage.text;
      entity.draftMessageDate = chat.draftMessage.date;
    }
    return entity;
  }

  /**
   * 将 ChatEntity 转换为 Chat
   */
  private convertEntityToChat(entity: ChatEntity): Chat {
    const chat: Chat = {
      id: entity.chatId,
      type: entity.type as ChatType,
      title: entity.title,
      avatar: entity.photoJson || '',
      unreadCount: entity.unreadCount || 0,
      unreadMentionCount: 0,
      isPinned: entity.isPinned || false,
      isMuted: entity.isMuted || false,
      isArchived: false,
      isMarkedAsUnread: false,
      hasProtectedContent: false,
      hasScheduledMessages: false,
      order: 0,
      positions: [],
      isVerified: false,
      isScam: false,
      isFake: false,
      timestamp: entity.lastMessageDate ? entity.lastMessageDate * 1000 : 0,
      canBeDeletedOnlyForSelf: false,
      canBeDeletedForAllUsers: false,
      canBeReported: false,
      defaultDisableNotification: false,
      hasActiveStories: false,
      storyIds: [],
      hasLinkedChat: false
    };

    // 可选字段
    if (entity.lastMessageId) {
      chat.lastMessage = {
        id: entity.lastMessageId,
        chatId: entity.chatId,
        senderId: 0,
        senderName: '',
        type: MessageType.TEXT,
        content: { text: '' },
        timestamp: entity.lastMessageDate ? entity.lastMessageDate * 1000 : 0,
        status: MessageStatus.READ,
        isOutgoing: false,
        reactions: [],
        isPinned: false,
        canBeEdited: false,
        canBeDeleted: false,
        hasProtectedContent: false
      };
    }

    if (entity.draftMessage) {
      chat.draftMessage = {
        text: entity.draftMessage,
        entities: [],
        date: entity.draftMessageDate || Date.now()
      };
    }

    return chat;
  }
}