// ChatPageViewModel.ets
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction } from '@kit.ArkUI';
import { picker } from '@kit.CoreFileKit';
import { SortedHashMap } from '../utils/SortedHashMap'; // ⭐ 参考 Gramony-dev 使用 SortedHashMap
import { CoreService } from '../services/business/messages/MessagesController';
import { FileDownloadService } from '../services/business/files/DownloadController';
import { Message, MessageType, MessageStatus, ChatType, MediaInfo, FileInfo, MessageContent, PollInfo,
  ForwardInfo, TextEntity, GroupEventType, SystemMessageType, SystemMessageParams,
  PollOption, InlineKeyboardMarkup, ReplyKeyboardMarkup, DiceInfo, PaidMediaInfo, GiftInfo, GiveawayInfo,
  UPDATE_MASK_NEW_MESSAGE, UPDATE_MASK_MESSAGE_SENT, UPDATE_MASK_MESSAGE_FAILED,
  UPDATE_MASK_MESSAGE_EDITED, UPDATE_MASK_MESSAGE_DELETED, UPDATE_MASK_CHAT_ACTION,
  UPDATE_MASK_FILE_PROGRESS, UPDATE_MASK_CONNECTION, UPDATE_MASK_USER_AVATAR,
  FileType, DownloadPriority, DownloadEvent, DownloadCompleteData } from '../models/TDLibData';
import { EventBus } from '../utils/event/EventBus';
import { formatString } from '../utils/i18n/ResourceHelper';

const TAG = 'ChatPageViewModel';
const DOMAIN = 0x0001;
const TYPING_DEBOUNCE_DELAY = 2000;

/**
 * 用户名信息接口（用于异步加载用户信息）
 */
interface UserNameInfo {
  userId: number;
  name: string;
}

// ==================== LazyForEach 数据源 ====================

/**
 * 删除条目信息（用于增量删除时的索引追踪）
 */
interface DeleteEntry {
  id: number;
  index: number;
}

/**
 * 消息数据源 - 用于 LazyForEach 实现按需加载和组件复用
 * ⭐ 参考 Gramony-dev 实现：使用 SortedHashMap 替代数组，避免数组引用问题
 */
@ObservedV2
export class MessageDataSource implements IDataSource {
  private sortedMessages: SortedHashMap<number, Message> = new SortedHashMap<number, Message>(); // ⭐ 使用 SortedHashMap
  private listeners: DataChangeListener[] = [];

  constructor(messages: Message[] = []) {
    for (const msg of messages) {
      this.sortedMessages.set(msg.id, msg);
    }
  }

  /**
   * 获取数据总数
   */
  totalCount(): number {
    return this.sortedMessages.length();
  }

  /**
   * 获取指定索引的数据（⭐ 参考 Gramony-dev）
   */
  getData(index: number): Message {
    const msg = this.sortedMessages.getValueAt(index);
    if (!msg) {
      // 返回空消息对象，避免崩溃
      return {} as Message;
    }
    return msg;
  }

  /**
   * 注册数据变化监听器
   */
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  /**
   * 注销数据变化监听器
   */
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  /**
   * ⭐ Nagram 参考：增量添加消息（追加到末尾）
   * 新消息（更高 ID）自动排序到末尾
   * 使用增量 notifyDataAdd/notifyDataChange 替代全量 reload
   */
  appendMessages(newMessages: Message[]): void {
    if (newMessages.length === 0) return;
    
    const addedPositions: number[] = [];
    const changedPositions: number[] = [];

    for (const msg of newMessages) {
      const isNew = !this.sortedMessages.has(msg.id);
      const index = this.sortedMessages.set(msg.id, msg);
      if (isNew) {
        addedPositions.push(index);
      } else {
        changedPositions.push(index);
      }
    }

    // ⭐ 增量通知（Nagram 风格：精确的局部更新）
    if (addedPositions.length > 0) {
      addedPositions.sort((a, b) => a - b);
      for (const pos of addedPositions) {
        this.notifyDataAdd(pos, 1);
      }
    }
    if (changedPositions.length > 0) {
      changedPositions.sort((a, b) => a - b);
      for (const pos of changedPositions) {
        this.notifyDataChange(pos);
      }
    }
  }

  /**
   * ⭐ Nagram 参考：增量添加消息（插入到开头/任意位置）
   * 旧消息（更低 ID）自动排序到前面
   * 使用增量 notifyDataAdd/notifyDataChange 替代全量 reload
   */
  prependMessages(newMessages: Message[]): void {
    // ⭐ 从 SortedHashMap 角度，prepend 和 append 语义相同
    // 因为 SortedHashMap 自动按 ID 排序
    // 旧消息（低 ID）自然排到前面，新消息（高 ID）排到后面
    this.appendMessages(newMessages);
  }

  /**
   * ⭐ 批量插入消息（按消息ID顺序插入到合适位置）
   * 用于加载被回复的消息，保持消息列表有序
   * SortedHashMap 自动排序，使用增量通知
   */
  insertMessages(newMessages: Message[]): void {
    // ⭐ 与 appendMessages 共享相同的增量逻辑
    this.appendMessages(newMessages);
  }

  /**
   * 更新单条消息
   * ⭐ SortedHashMap 直接替换
   */
  updateMessage(updatedMsg: Message): void {
    const index = this.sortedMessages.indexOf(updatedMsg.id);
    if (index >= 0) {
      this.sortedMessages.set(updatedMsg.id, updatedMsg);
      this.notifyDataChange(index);
    }
  }

  /**
   * 替换单条消息
   */
  replaceMessage(oldId: number, newMsg: Message): void {
    const index = this.sortedMessages.indexOf(oldId);
    if (index >= 0) {
      this.sortedMessages.delete(oldId);
      this.sortedMessages.set(newMsg.id, newMsg);
      this.notifyDataChange(index);
    } else {
      // 旧消息不存在，直接追加
      this.appendMessages([newMsg]);
    }
  }

  /**
   * ⭐ Nagram 参考：增量删除消息
   * 收集删除索引，从右到左删除，避免索引偏移
   */
  deleteMessages(messageIds: number[]): void {
    if (messageIds.length === 0) return;

    // Phase 1: 收集所有待删除元素的索引（删除前状态）
    const entryList: DeleteEntry[] = [];
    for (const id of messageIds) {
      const index = this.sortedMessages.indexOf(id);
      if (index >= 0) {
        const entry: DeleteEntry = { id: id, index: index } as DeleteEntry;
        entryList.push(entry);
      }
    }
    if (entryList.length === 0) return;

    // Phase 2: 从右到左删除（索引后移时前面的索引不受影响）
    entryList.sort((a, b) => b.index - a.index);
    for (const entry of entryList) {
      this.sortedMessages.delete(entry.id);
      this.notifyDataDelete(entry.index);
    }
  }

  /**
   * 重置所有数据
   * ⭐ 参考 Gramony-dev：清空后重新添加
   */
  setMessages(messages: Message[]): void {
    this.sortedMessages.clear();
    for (const msg of messages) {
      this.sortedMessages.set(msg.id, msg);
    }
    this.notifyDataReload();
  }

  /**
   * 获取所有消息
   */
  getAllMessages(): Message[] {
    return this.sortedMessages.getSortedValues();
  }

  /**
   * 获取消息数量
   */
  getCount(): number {
    return this.sortedMessages.length();
  }

  /**
   * 根据ID获取消息
   */
  getMessageById(id: number): Message | undefined {
    return this.sortedMessages.get(id);
  }

  /**
   * 根据消息ID获取索引
   */
  getIndexById(messageId: number): number {
    return this.sortedMessages.indexOf(messageId);
  }

  /**
   * 清空数据
   */
  clear(): void {
    this.sortedMessages.clear();
    this.notifyDataReload();
  }

  // ==================== 数据变化通知 ====================

  private notifyDataAdd(index: number, count: number): void {
    this.listeners.forEach(listener => {
      // 注意：ArkTS IDataSource 的 onDataAdd 只接受一个参数（index）
      // 这里需要为每条数据单独通知
      for (let i = 0; i < count; i++) {
        listener.onDataAdd?.(index + i);
      }
    });
  }

  private notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange?.(index);
    });
  }

  private notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete?.(index);
    });
  }

  private notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove?.(from, to);
    });
  }

  private notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded?.();
    });
  }
}

/**
 * 机器人命令接口
 */
interface BotCommand {
  command: string;
  description: string;
}

export interface ChatPageParams {
  chatId: number;
  chatType: ChatType;
  title: string;
  avatar?: string;
}

interface FileDownloadState {
  progress: number;
  isDownloading: boolean;
  localPath?: string;
}

/**
 * 滚动到消息事件数据
 */
interface ScrollToMessageData {
  messageId: number;
}

/**
 * 聊天页面 ViewModel（响应式）
 */
@ObservedV2
export class ChatPageViewModel {
  // ==================== 响应式数据 ====================
  @Trace chatId: number = 0;
  @Trace chatType: ChatType = ChatType.PRIVATE;
  @Trace chatTitle: string = '';
  @Trace chatAvatar: string = '';
  // 使用 MessageDataSource 替代 Message[]，支持 LazyForEach 按需加载和组件复用
  messageDataSource: MessageDataSource = new MessageDataSource();
  @Trace inputText: string = '';
  @Trace isLoading: boolean = true;
  @Trace isSending: boolean = false;
  @Trace showEmojiPicker: boolean = false;
  @Trace showAttachmentMenu: boolean = false;
  @Trace showTypingIndicator: boolean = false;
  @Trace typingText: string = '';
  @Trace connectionState: string = 'connected';
  @Trace selectedMessageId: number | null = null; // 长按选中的消息ID
  @Trace showContextMenu: boolean = false;

  // 聊天权限相关
  @Trace isChannelAdmin: boolean = false;      // 是否为频道管理员
  @Trace canSendMessages: boolean = true;      // 是否可以发送消息
  @Trace discussionChatId: number | null = null; // 关联的讨论群组ID

  // ⭐ 区分"我的"和"其他人的"频道/群组
  @Trace isMyChat: boolean = false;            // 是否为我创建的/管理的聊天
  @Trace isOwner: boolean = false;             // 是否为创建者/所有者
  @Trace isAdmin: boolean = false;             // 是否为管理员

  // 机器人相关
  @Trace replyKeyboard: ReplyKeyboardMarkup | null = null; // 当前显示的回复键盘
  @Trace showReplyKeyboard: boolean = false;    // 是否显示回复键盘
  @Trace botCommands: BotCommand[] = [];        // 机器人命令列表
  @Trace showCommandSuggestions: boolean = false; // 是否显示命令建议

  // 多选操作相关
  @Trace isMultiSelectMode: boolean = false;    // 是否处于多选模式
  @Trace selectedMessageIds: Set<number> = new Set(); // 选中的消息ID集合
  @Trace showMultiSelectToolbar: boolean = false; // 是否显示多选工具栏

  // ==================== 内部状态 ====================
  private CoreService: CoreService = CoreService.getInstance();
  // ⭐ 优化：移除 messageMap，使用 messageDataSource.getMessageById() 作为单一数据源
  // private messageMap: Map<number, Message> = new Map();
  private fileDownloadMap: Map<number, FileDownloadState> = new Map();
  private typingDebounceTimer: number = -1;
  private oldestMessageId: number = 0;
  private eventBus: EventBus = EventBus.getInstance();
  private contextMenuTimer: number = -1;
  private loadingReplyMessageIds: Set<number> = new Set(); // ⭐ 正在加载的被回复消息ID

  // ⭐ 优化：添加加载状态锁，防止并发加载冲突
  private isLoadingMessages: boolean = false;
  private isRefreshing: boolean = false;
  // ⭐ Nagram 参考：加载中的待处理消息队列
  // 在 loadMessages 执行期间收到的新消息，暂存至此，加载完成后统一处理
  private pendingMessages: Record<string, Object>[] = [];

  // 加载状态（暴露给UI层使用）
  public isLoadingMore: boolean = false;
  public hasMoreMessages: boolean = true;

  constructor() {
    this.registerEventListeners();
  }

  // ==================== 初始化 ====================
  public async init(params: ChatPageParams): Promise<void> {
    // ⭐ Nagram 参考：立即设置加载锁，防止在 init 过程中到达的事件
    // 与 loadMessages 产生的 setMessages 发生并发竞争
    this.isLoadingMessages = true;

    try {
      // 如果切换到不同的聊天，清空旧数据避免消息错位
      if (this.chatId !== 0 && this.chatId !== params.chatId) {
        this.clearChatData();
      }

      this.chatId = params.chatId || 0;
      this.chatType = params.chatType || ChatType.PRIVATE;
      this.chatTitle = params.title || '';
      const avatarPath = params.avatar || '';
      this.chatAvatar = avatarPath.startsWith('file://') ? avatarPath : 'file://' + avatarPath;

      hilog.info(DOMAIN, TAG, `Init chat: id=${this.chatId}, type=${this.chatType}, title=${this.chatTitle}`);

      // ⭐ 设置当前活跃聊天，让下载服务优先处理该聊天的下载任务
      FileDownloadService.getInstance().setCurrentActiveChat(this.chatId);

      // ⭐ 从 CoreService 获取聊天信息，判断是否为"我的"聊天
      await this.loadChatInfo();

      // 根据聊天类型设置权限
      this.updateChatPermissions();

      // 如果内存中已有消息，只刷新网络数据，避免重复加载导致闪烁
      if (this.messageDataSource.getCount() > 0) {
        hilog.info(DOMAIN, TAG, `Messages already in memory (${this.messageDataSource.getCount()}), skipping cache load, refreshing from network...`);
        await this.refreshMessagesFromNetwork();
      } else {
        await this.loadMessages();
      }
      await this.markMessagesAsRead();
    } finally {
      // ⭐ 释放加载锁并处理等待中的消息
      this.isLoadingMessages = false;
      await this.processPendingMessages();
    }
  }

  /**
   * 从网络刷新消息（用于内存中已有消息时的增量刷新）
   */
  private async refreshMessagesFromNetwork(): Promise<void> {
    // ⭐ 优化：添加刷新状态锁
    if (this.isRefreshing) {
      hilog.info(DOMAIN, TAG, 'refreshMessagesFromNetwork already in progress, skipping');
      return;
    }
    this.isRefreshing = true;
    try {
      const currentMessages = this.messageDataSource.getAllMessages();
      const newestMessageId = currentMessages[currentMessages.length - 1]?.id ?? 0;
      hilog.info(DOMAIN, TAG, `Refreshing from network: fromMessageId=${newestMessageId}`);
      const networkMessages = await this.CoreService.loadHistory(this.chatId, newestMessageId, 50);
      if (networkMessages.length > 0) {
        // 合并网络消息和现有消息
        const messageMap = new Map<number, Message>();
        for (const msg of currentMessages) {
          messageMap.set(msg.id, msg);
        }
        for (const msg of networkMessages) {
          messageMap.set(msg.id, msg);
        }
        const mergedMessages = Array.from(messageMap.values());
        mergedMessages.sort((a, b) => a.id - b.id);
        this.messageDataSource.setMessages(mergedMessages);
        this.oldestMessageId = mergedMessages[0]?.id ?? 0;
        // ⭐ 优化：从 DataSource 同步 messageMap
        this.syncMessageMapFromDataSource();
        hilog.info(DOMAIN, TAG, `Refreshed ${networkMessages.length} messages from network, total: ${this.messageDataSource.getCount()}`);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `refreshMessagesFromNetwork failed: ${error}`);
    } finally {
      this.isRefreshing = false;  // ⭐ 释放刷新锁
      // ⭐ Nagram 参考：刷新完成后处理队列中的待处理消息
      await this.processPendingMessages();
    }
  }

  /**
   * 清空当前聊天数据（切换聊天时调用）
   * ⭐ 关键优化：在清空前将消息保存回 CoreService 的 messagesMap，避免下次进入重新加载
   */
  private clearChatData(): void {
    hilog.info(DOMAIN, TAG, `Clearing chat data for chat ${this.chatId}`);
    
    // ⭐ 关键修复：在清空前，将当前聊天的消息保存回 CoreService 的 messagesMap
    const currentMessages = this.messageDataSource.getAllMessages();
    if (currentMessages.length > 0 && this.chatId !== 0) {
      // 将消息保存到 CoreService 的内存缓存中
      this.CoreService.saveMessagesToMemoryCache(this.chatId, currentMessages);
      hilog.info(DOMAIN, TAG, `Saved ${currentMessages.length} messages to CoreService cache for chat ${this.chatId}`);
    }
    
    this.messageDataSource.clear();
    // ⭐ 优化：messageMap 已移除，无需清理
    // this.messageMap.clear();
    this.fileDownloadMap.clear();
    this.oldestMessageId = 0;
    this.hasMoreMessages = true;
    this.isLoadingMore = false;
    // ⭐ Nagram 参考：切换聊天时清空待处理消息队列
    this.pendingMessages = [];
    this.selectedMessageIds.clear();
    this.isMultiSelectMode = false;
    this.showMultiSelectToolbar = false;
    this.replyKeyboard = null;
    this.showReplyKeyboard = false;
    this.botCommands = [];
    this.showCommandSuggestions = false;
  }

  /**
   * ⭐ 加载聊天信息，判断是否为"我的"聊天
   */
  private async loadChatInfo(): Promise<void> {
    try {
      // 从 CoreService 获取聊天信息
      const chat = this.CoreService.getChat(this.chatId);
      if (chat) {
        this.isOwner = chat.isOwner || false;
        this.isAdmin = chat.isAdmin || false;
        // 判断是否为"我的"聊天（创建者或管理员）
        this.isMyChat = this.isOwner || this.isAdmin;
        this.isChannelAdmin = this.isAdmin;

        hilog.info(DOMAIN, TAG,
          `Chat ${this.chatId} info loaded: isOwner=${this.isOwner}, isAdmin=${this.isAdmin}, isMyChat=${this.isMyChat}`);
      } else {
        hilog.warn(DOMAIN, TAG, `Chat ${this.chatId} not found in CoreService`);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to load chat info: ${error}`);
    }
  }

  /**
   * 根据聊天类型更新权限状态
   */
  private updateChatPermissions(): void {
    switch (this.chatType) {
      case ChatType.CHANNEL:
        // 频道普通用户不能发送消息，只有管理员可以
        // TODO: 从 TDLib 获取实际的频道权限信息
        this.canSendMessages = this.isChannelAdmin;
        break;
      case ChatType.GROUP:
      case ChatType.SUPERGROUP:
        // 群组默认可以发送，但可能被禁言
        this.canSendMessages = true;
        break;
      case ChatType.BOT:
        // 机器人聊天可以发送
        this.canSendMessages = true;
        break;
      case ChatType.PRIVATE:
      case ChatType.SECRET:
      default:
        this.canSendMessages = true;
        break;
    }
  }

  public cleanup(): void {
    this.unregisterEventListeners();
    if (this.typingDebounceTimer !== -1) clearTimeout(this.typingDebounceTimer);
    if (this.contextMenuTimer !== -1) clearTimeout(this.contextMenuTimer);

    // ⭐ 清除当前活跃聊天设置
    FileDownloadService.getInstance().setCurrentActiveChat(undefined);

    // ⭐ 关键修复：在清空前，将当前聊天的消息保存回 CoreService 的 messagesMap
    const currentMessages = this.messageDataSource.getAllMessages();
    if (currentMessages.length > 0 && this.chatId !== 0) {
      // 将消息保存到 CoreService 的内存缓存中
      this.CoreService.saveMessagesToMemoryCache(this.chatId, currentMessages);
      hilog.info(DOMAIN, TAG, `Cleanup: Saved ${currentMessages.length} messages to CoreService cache for chat ${this.chatId}`);
    }

    // ⭐ 优化：彻底清空 DataSource，与 V2 架构一致
    this.messageDataSource.clear();
    // ⭐ 优化：messageMap 已移除
    // this.messageMap.clear();
    this.fileDownloadMap.clear();

    // 重置加载状态
    this.oldestMessageId = 0;
    this.hasMoreMessages = true;
    this.isLoadingMore = false;
    this.pendingMessages = [];
  }

  // ==================== 消息加载 ====================
  private async loadMessages(): Promise<void> {
    this.isLoadingMessages = true;
    this.isLoading = true;
    let shouldScrollToBottom = false;
    let anchorMessageId = 0; // ⭐ Telegram 风格：锚点消息ID
    
    try {
      // ⭐ Telegram 风格：获取上次阅读位置作为锚点
      anchorMessageId = await this.CoreService.getAnchorMessageId(this.chatId);
      hilog.info(DOMAIN, TAG, `⭐ Anchor message ID: ${anchorMessageId}`);
      
      if (anchorMessageId > 0) {
        // ⭐ 有锚点：使用双向加载策略
        hilog.info(DOMAIN, TAG, `🎯 Loading messages around anchor ${anchorMessageId}...`);
        const messages = await this.CoreService.loadMessagesAroundAnchor(this.chatId, anchorMessageId, 50, 20);
        
        if (messages.length > 0) {
          this.messageDataSource.setMessages(messages);
          this.oldestMessageId = messages[0]?.id ?? 0;
          
          // ⭐ 计算锚点索引，用于滚动定位
          const anchorIndex = this.messageDataSource.getIndexById(anchorMessageId);
          hilog.info(DOMAIN, TAG, `✅ Loaded ${messages.length} messages around anchor, anchorIndex=${anchorIndex}`);
          
          // ⭐ 触发滚动到锚点事件（延迟执行，等待 ChatPage 渲染完成）
          const scrollEvent: ScrollToMessageData = { messageId: anchorMessageId };
          setTimeout(() => {
            this.eventBus.emit('scrollToAnchor', scrollEvent);
          }, 100);
          
          shouldScrollToBottom = false; // 禁用自动滚动到底部
        } else {
          hilog.warn(DOMAIN, TAG, 'No messages loaded around anchor, fallback to normal load');
          await this.loadMessagesFallback();
        }
      } else {
        // ⭐ 无锚点：使用普通加载策略（从最新消息开始）
        hilog.info(DOMAIN, TAG, '📱 No anchor found, using normal load strategy');
        await this.loadMessagesFallback();
        shouldScrollToBottom = true;
      }
      
      // 只在最后滚动一次，避免多次滚动造成的抽搐
      if (shouldScrollToBottom && this.messageDataSource.getCount() > 0) {
        this.notifyScrollToBottom();
      }
      
      // ⭐ 优化：批量预加载可见消息的发送者头像
      this.batchPreloadSenderAvatars();
      
    } catch (error) {
      hilog.error(DOMAIN, TAG, `loadMessages failed: ${error}`);
      // ⭐ 关键修复：异常时不清空数据，保留缓存
      if (this.messageDataSource.getCount() === 0) {
        hilog.warn(DOMAIN, TAG, 'loadMessages failed and no cached messages, trying loadMoreMessages');
        await this.loadMoreMessages();
      }
    } finally {
      this.isLoading = false;
      this.isLoadingMessages = false;  // ⭐ 释放加载锁
      // ⭐ Nagram 参考：加载完成后处理队列中的待处理消息
      await this.processPendingMessages();
    }
  }

  /**
   * ⭐ Nagram 参考：处理加载期间累积的待处理消息
   * 在 loadMessages 执行期间，新消息事件被暂存到 pendingMessages 队列
   * 加载完成后统一处理，避免与 setMessages 的并发竞争
   */
  private async processPendingMessages(): Promise<void> {
    if (this.pendingMessages.length === 0) return;
    
    hilog.info(DOMAIN, TAG, `Processing ${this.pendingMessages.length} pending messages after load`);
    const pending = [...this.pendingMessages];
    this.pendingMessages = [];
    
    for (const data of pending) {
      await this.handleCoreNewMessage(data);
    }
  }

  /**
   * ⭐ 回退到普通加载策略（当双向加载失败或无锚点时）
   */
  private async loadMessagesFallback(): Promise<void> {
    // ⭐ Telegram 官方策略：优先显示本地缓存（即时响应）
    const cachedMessages = await this.CoreService.getCachedMessages(this.chatId);
    if (cachedMessages.length > 0 && this.messageDataSource.getCount() === 0) {
      hilog.info(DOMAIN, TAG, `📱 Displaying ${cachedMessages.length} cached messages for chat ${this.chatId}`);
      
      // 直接使用缓存数据（TDLib 保证数据完整性）
      const sortedMessages = [...cachedMessages].sort((a, b) => a.id - b.id);
      this.messageDataSource.setMessages(sortedMessages);
      this.oldestMessageId = sortedMessages[0]?.id ?? 0;
    }

    // ⭐ Telegram 官方策略：从网络加载最新消息（TDLib 返回权威数据）
    let fromMessageId = 0;
    const currentMessages = this.messageDataSource.getAllMessages();
    if (currentMessages.length > 0) {
      // 获取当前最新消息的 ID
      const newestMessageId = currentMessages[currentMessages.length - 1].id;
      fromMessageId = newestMessageId;
    }
    
    hilog.info(DOMAIN, TAG, `🌐 Loading from network: fromMessageId=${fromMessageId}, currentCount=${currentMessages.length}`);
    const networkMessages = await this.CoreService.loadHistory(this.chatId, fromMessageId === 0 ? 0 : fromMessageId, 50);
    
    // ⭐ 关键修复：只有当网络返回的消息数量 > 0 时才更新
    // 避免网络返回空数组时清空已有缓存
    if (networkMessages.length > 0) {
      // ⭐ Telegram 官方策略：合并网络消息和现有缓存（避免丢失旧消息）
      const existingMessages = this.messageDataSource.getAllMessages();
      const messageMap = new Map<number, Message>();
      
      // 先添加现有消息
      for (const msg of existingMessages) {
        messageMap.set(msg.id, msg);
      }
      
      // 再添加/更新网络消息
      for (const msg of networkMessages) {
        messageMap.set(msg.id, msg);
      }
      
      // 重新排序并设置
      const mergedMessages = Array.from(messageMap.values()).sort((a, b) => a.id - b.id);
      this.messageDataSource.setMessages(mergedMessages);
      this.oldestMessageId = mergedMessages[0]?.id ?? 0;

      hilog.info(DOMAIN, TAG, `✅ Merged ${networkMessages.length} network messages with ${existingMessages.length} cached, total: ${mergedMessages.length}, oldestId: ${this.oldestMessageId}, hasMore: ${this.hasMoreMessages}`);
    } else {
      // ⭐ 关键修复：网络返回空数组时，不设置 hasMoreMessages = false
      // hasMoreMessages 仅由 loadMoreMessages（专门加载更早消息的路径）控制
      // 网络刷新阶段（loadHistory 方向是向后查）不能确定是否有更早消息
      if (currentMessages.length === 0) {
        // 既没有缓存也没有网络消息，尝试加载更多历史
        hilog.info(DOMAIN, TAG, 'No cached or network messages, loading history directly');
        await this.loadMoreMessages();
      } else {
        // 有缓存但没有新消息，保留缓存。不设置 hasMoreMessages = false
        // 因为 loadHistory 使用 fromMessageId=最新消息ID 时方向是向后查
        // 不能确定是否有更早的历史消息
        hilog.info(DOMAIN, TAG, `No new messages from network, keeping ${this.messageDataSource.getCount()} cached messages`);
      }
    }
  }
  
  /**
   * ⭐ 批量预加载发送者头像
   * 收集所有消息中需要加载头像的用户ID，批量触发用户信息加载
   * 这样可以利用 FileDownloadService 的头像优先级插队机制
   */
  private batchPreloadSenderAvatars(): void {
    const messages = this.messageDataSource.getAllMessages();
    const senderIds = new Set<number>();
    
    // 收集需要加载头像的发送者ID（只收集没有头像的）
    for (const message of messages) {
      if (message.senderId > 0 && !message.senderAvatar) {
        // 检查缓存中是否已有头像
        const cachedUser = this.CoreService.getCachedUserInfo(message.senderId);
        if (!cachedUser || !cachedUser.avatar) {
          senderIds.add(message.senderId);
        }
      }
    }
    
    if (senderIds.size > 0) {
      hilog.info(DOMAIN, TAG, `Batch preloading avatars for ${senderIds.size} senders`);
      // 批量触发用户信息加载（这会触发头像下载）
      for (const senderId of senderIds) {
        // 使用 fire-and-forget 模式，不等待结果
        this.CoreService.getUserInfo(senderId).then(userInfo => {
          if (userInfo && userInfo.avatar) {
            hilog.debug(DOMAIN, TAG, `Batch preload: avatar ready for user ${senderId}`);
          }
        }).catch((err: Error) => {
          hilog.warn(DOMAIN, TAG, `Batch preload: failed to load user ${senderId}: ${err.message}`);
        });
      }
    }
  }

  private notifyScrollToBottom(): void {
    // 使用 EventBus 通知 ChatPage 滚动到底部
    const eventBus = EventBus.getInstance();
    eventBus.emit('scrollToBottom', new Object());
  }

  // ⭐ 优化：messageMap 已移除，此方法废弃
  // 单一数据源原则：直接使用 messageDataSource.getMessageById()
  // @deprecated 使用 messageDataSource.getMessageById(messageId) 替代
  private syncMessageMapFromDataSource(): void {
    // ⭐ 优化：messageMap 已移除，此方法不再执行任何操作
    // 所有消息查询应直接使用 this.messageDataSource.getMessageById(messageId)
    hilog.debug(DOMAIN, TAG, 'syncMessageMapFromDataSource: messageMap 已移除，使用 DataSource 直接查询');
  }

  /**
   * ⭐ Telegram 官方策略：加载更多历史消息（简单拼接）
   * @returns 返回实际加载的新消息数量，用于UI层调整滚动位置
   */
  public async loadMoreMessages(): Promise<number> {
    if (this.isLoadingMore || !this.hasMoreMessages || this.oldestMessageId === 0) {
      hilog.info(DOMAIN, TAG, `Skip loadMoreMessages: isLoadingMore=${this.isLoadingMore}, hasMore=${this.hasMoreMessages}, oldestId=${this.oldestMessageId}`);
      return 0;
    }
    this.isLoadingMore = true;
    let loadedCount = 0;
    hilog.info(DOMAIN, TAG, `📜 Loading more messages from oldestId=${this.oldestMessageId}`);
    try {
      // ⭐ Telegram 官方策略：从 CoreService 加载更早的消息
      const olderMessagesArray = await this.CoreService.getChatHistory(this.chatId, this.oldestMessageId, 0, 50, false);
      hilog.info(DOMAIN, TAG, `Received ${olderMessagesArray.length} messages from CoreService`);
      
      if (olderMessagesArray && olderMessagesArray.length > 0) {
        const newMessages: Message[] = [];
        for (const raw of olderMessagesArray) {
          const msg = this.convertTdlibMessage(raw as Record<string, Object>);
          // ⭐ 去重：排除已存在的消息和 fromMessageId 本身
          if (msg && msg.id !== this.oldestMessageId && !this.messageDataSource.getMessageById(msg.id)) {
            newMessages.push(msg);
          }
        }
        hilog.info(DOMAIN, TAG, `Converted ${newMessages.length} new messages after dedup`);
        
        if (newMessages.length > 0) {
          // ⭐ Telegram 官方策略：简单拼接到前面（旧消息在前）
          newMessages.sort((a, b) => a.id - b.id);
          this.messageDataSource.prependMessages(newMessages);
          
          // 更新 oldestMessageId 为最早的消息 ID
          this.oldestMessageId = newMessages[0].id;
          this.hasMoreMessages = olderMessagesArray.length >= 50;
          loadedCount = newMessages.length;
          
          hilog.info(DOMAIN, TAG, `✅ Loaded ${newMessages.length} older messages, new oldestId=${this.oldestMessageId}, hasMore=${this.hasMoreMessages}, total=${this.messageDataSource.getCount()}`);

          // ⭐ 优化：批量预加载新消息的头像
          this.batchPreloadSenderAvatars();
        } else {
          // 没有新消息，说明所有返回的消息都是已有的
          // 只有在 TDLib 返回少于请求数量的消息时，才确定没有更多历史
          this.hasMoreMessages = olderMessagesArray.length >= 50;
          hilog.info(DOMAIN, TAG, `No new messages found, hasMore=${this.hasMoreMessages}`);
        }
      } else {
        // ⭐ CoreService.getChatHistory 返回空数组可能是两种原因：
        // 1. TDLib 确认没有更多消息（正确）
        // 2. 网络请求失败或 TDLib 出错，CoreService 吞掉了异常（需要在其他路径恢复）
        // 设置 hasMoreMessages = false 阻止后续加载，但用户重新进入页面可恢复
        this.hasMoreMessages = false;
        hilog.info(DOMAIN, TAG, 'No more older messages from server');
      }
    } catch (error) {
      // ⭐ 关键修复：不要因为异常就永久标记 hasMoreMessages = false
      // 用户可能只是网络暂时波动，应该允许下次尝试
      hilog.error(DOMAIN, TAG, `loadMoreMessages failed: ${error}`);
      // 不设置 hasMoreMessages = false，保留重试机会
    } finally {
      this.isLoadingMore = false;
      // ⭐ 处理加载期间累积的待处理消息
      await this.processPendingMessages();
    }
    return loadedCount;
  }

  private async markMessagesAsRead(): Promise<void> {
    const unreadIds = this.messageDataSource.getAllMessages()
      .filter(m => !m.isOutgoing && m.status !== MessageStatus.READ)
      .map(m => m.id);
    
    hilog.info(DOMAIN, TAG, 
      `⭐ [markMessagesAsRead] chatId=${this.chatId}, unreadCount=${unreadIds.length}, ids=${JSON.stringify(unreadIds.slice(-5))}`);
    
    if (unreadIds.length > 0) {
      await this.CoreService.viewMessages(this.chatId, unreadIds, null, true);
      hilog.info(DOMAIN, TAG, `⭐ viewMessages called with ${unreadIds.length} messages`);
    }
  }

  // ==================== 消息发送 ====================
  public async sendTextMessage(): Promise<void> {
    if (!this.inputText.trim() || this.isSending) return;
    this.isSending = true;
    try {
      await this.CoreService.sendTextMessage(this.chatId, this.inputText.trim());
      this.inputText = '';
    } catch (error) {
      hilog.error(DOMAIN, TAG, `sendTextMessage failed: ${error}`);
      promptAction.showToast({ message: $r('app.string.send_failed'), duration: 1500 });
    } finally {
      this.isSending = false;
    }
  }

  public async sendPhoto(): Promise<void> {
    try {
      const options = new picker.PhotoSelectOptions();
      options.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      const result = await new picker.PhotoViewPicker().select(options);
      if (result.photoUris.length) {
        await this.CoreService.sendImageMessage(this.chatId, result.photoUris[0]);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `sendPhoto failed: ${error}`);
    }
  }

  public async sendVideo(): Promise<void> {
    promptAction.showToast({ message: '视频发送功能开发中', duration: 1500 });
  }

  public async sendFile(): Promise<void> {
    promptAction.showToast({ message: '文件发送功能开发中', duration: 1500 });
  }

  public async sendLocation(): Promise<void> {
    promptAction.showToast({ message: '位置发送功能开发中', duration: 1500 });
  }

  public async startRecording(): Promise<void> {
    promptAction.showToast({ message: '录音功能开发中', duration: 1500 });
  }

  // ==================== 消息操作 ====================
  public showMessageContextMenu(messageId: number): void {
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

  public async copyMessageText(): Promise<void> {
    // ⭐ 优化：使用 DataSource 获取消息
    const msg = this.selectedMessageId ? this.messageDataSource.getMessageById(this.selectedMessageId) : undefined;
    if (msg && msg.type === MessageType.TEXT) {
      const content = typeof msg.content === 'string' ? msg.content : (msg.content as MessageContent).text || '';
      if (content) {
        await promptAction.showToast({ message: '已复制', duration: 1000 });
        // 实际应调用系统剪贴板 API
      }
    }
    this.showContextMenu = false;
    this.selectedMessageId = null;
  }

  public async deleteMessage(): Promise<void> {
    const result = await promptAction.showDialog({
      title: '删除消息',
      message: '确定要删除这条消息吗？',
      buttons: [{ text: '取消', color: '#8E8E93' }, { text: '删除', color: '#FA2A2D' }]
    });
    if (result.index === 1 && this.selectedMessageId) {
      await this.CoreService.deleteMessages(this.chatId, [this.selectedMessageId], true);
    }
    this.showContextMenu = false;
    this.selectedMessageId = null;
  }

  public async replyToMessage(messageId: number): Promise<void> {
    // TODO: 实现回复功能
    promptAction.showToast({ message: '回复功能开发中', duration: 1500 });
  }

  public async forwardMessage(messageId: number): Promise<void> {
    // TODO: 实现转发功能
    promptAction.showToast({ message: '转发功能开发中', duration: 1500 });
  }

  // ==================== 文件下载 ====================
  public getFileDownloadProgress(fileId: number): FileDownloadState | undefined {
    return this.fileDownloadMap.get(fileId);
  }

  public async autoLoadVisibleMedia(startIndex: number, endIndex: number): Promise<void> {
    try {
      for (let i = startIndex; i <= endIndex; i++) {
        const message = this.messageDataSource.getData(i);
        if (!message || !message.media || !message.media.tdlibFileId) {
          continue;
        }

        const fileType = this.mapMessageTypeToFileType(message.type);
        
        if (fileType === FileType.IMAGE || fileType === FileType.VIDEO) {
          await FileDownloadService.getInstance().downloadFile(
            message.media.tdlibFileId,
            fileType,
            DownloadPriority.NORMAL,
            message.id,
            this.chatId,
            message.media.size
          );
        } else if (fileType === FileType.STICKER) {
          await FileDownloadService.getInstance().downloadFile(
            message.media.tdlibFileId,
            fileType,
            DownloadPriority.LOW,
            message.id,
            this.chatId,
            message.media.size
          );
        }
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `autoLoadVisibleMedia failed: ${error}`);
    }
  }

  public async triggerFileDownload(fileId: number, priority: DownloadPriority = DownloadPriority.HIGH, messageType?: MessageType): Promise<void> {
    try {
      const fileType = this.mapMessageTypeToFileType(messageType);
      await FileDownloadService.getInstance().downloadFile(
        fileId,
        fileType,
        priority,
        undefined,
        this.chatId
      );
    } catch (error) {
      hilog.error(DOMAIN, TAG, `downloadFile failed: ${error}`);
    }
  }

  private mapMessageTypeToFileType(messageType?: MessageType): FileType {
    if (!messageType) return FileType.DOCUMENT;
    switch (messageType) {
      case MessageType.PHOTO:
        return FileType.IMAGE;
      case MessageType.VIDEO:
        return FileType.VIDEO;
      case MessageType.AUDIO:
        return FileType.AUDIO;
      case MessageType.VOICE_NOTE:
        return FileType.VOICE_NOTE;
      case MessageType.DOCUMENT:
        return FileType.DOCUMENT;
      case MessageType.STICKER:
        return FileType.STICKER;
      case MessageType.ANIMATION:
        return FileType.ANIMATION;
      case MessageType.VIDEO_NOTE:
        return FileType.VIDEO_NOTE;
      default:
        return FileType.DOCUMENT;
    }
  }

  // ==================== 辅助方法 ====================
  public formatTime(timestamp: number): string {
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

  public formatDuration(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }

  public formatFileSize(bytes: number): string {
    if (bytes < 1024) return `${bytes}B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)}KB`;
    if (bytes < 1024 * 1024 * 1024) return `${(bytes / (1024 * 1024)).toFixed(1)}MB`;
    return `${(bytes / (1024 * 1024 * 1024)).toFixed(1)}GB`;
  }

  public getMessageStatusIcon(message: Message): string {
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

  public getInputPlaceholder(): string {
    if (this.chatType === ChatType.CHANNEL) return '向频道发送消息';
    if (this.chatType === ChatType.BOT) return '向机器人发送消息';
    return '输入消息...';
  }

  /**
   * 处理输入文本变化（检测命令）
   */
  public onInputTextChange(value: string): void {
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

  // ==================== 多选操作 ====================

  /**
   * 进入多选模式
   */
  public enterMultiSelectMode(messageId: number): void {
    this.isMultiSelectMode = true;
    this.selectedMessageIds.clear();
    this.selectedMessageIds.add(messageId);
    this.showMultiSelectToolbar = true;
  }

  /**
   * 退出多选模式
   */
  public exitMultiSelectMode(): void {
    this.isMultiSelectMode = false;
    this.selectedMessageIds.clear();
    this.showMultiSelectToolbar = false;
  }

  /**
   * 切换消息选中状态
   */
  public toggleMessageSelection(messageId: number): void {
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
  public isMessageSelected(messageId: number): boolean {
    return this.selectedMessageIds.has(messageId);
  }

  /**
   * 获取选中消息数量
   */
  public getSelectedCount(): number {
    return this.selectedMessageIds.size;
  }

  /**
   * 转发选中的消息
   */
  public async forwardSelectedMessages(): Promise<void> {
    const count = this.selectedMessageIds.size;
    if (count === 0) return;

    promptAction.showToast({ message: `转发 ${count} 条消息`, duration: 1500 });
    // TODO: 实现实际转发逻辑
    this.exitMultiSelectMode();
  }

  /**
   * 删除选中的消息
   */
  public async deleteSelectedMessages(): Promise<void> {
    const count = this.selectedMessageIds.size;
    if (count === 0) return;

    const result = await promptAction.showDialog({
      title: '删除消息',
      message: `确定要删除选中的 ${count} 条消息吗？`,
      buttons: [{ text: '取消', color: '#8E8E93' }, { text: '删除', color: '#FA2A2D' }]
    });

    if (result.index === 1) {
      await this.CoreService.deleteMessages(this.chatId, Array.from(this.selectedMessageIds), true);
      this.exitMultiSelectMode();
    }
  }

  /**
   * 复制选中的消息（仅文本消息）
   */
  public async copySelectedMessages(): Promise<void> {
    const count = this.selectedMessageIds.size;
    if (count === 0) return;

    // ⭐ 优化：使用 DataSource 获取消息
    // 收集所有文本消息内容
    const texts: string[] = [];
    for (const msgId of this.selectedMessageIds) {
      const msg = this.messageDataSource.getMessageById(msgId);
      if (msg && msg.type === MessageType.TEXT) {
        const text = typeof msg.content === 'string' ? msg.content : '';
        if (text) texts.push(text);
      }
    }

    if (texts.length > 0) {
      promptAction.showToast({ message: `已复制 ${texts.length} 条文本`, duration: 1500 });
      // TODO: 复制到剪贴板
    } else {
      promptAction.showToast({ message: '没有可复制的文本消息', duration: 1500 });
    }
  }

  public scrollToMessage(messageId: number): void {
    // 由 UI 层实现滚动
    const data: ScrollToMessageData = { messageId };
    this.eventBus.emit('scrollToMessage', data);
  }

  /**
   * 获取被回复消息的发送者名称
   */
  public getReplySenderName(messageId: number): string {
    // ⭐ 优化：使用 DataSource 获取消息
    const msg = this.messageDataSource.getMessageById(messageId);
    hilog.info(DOMAIN, TAG, `getReplySenderName called: messageId=${messageId}, found=${msg ? 'yes' : 'no'}`);
    if (!msg) {
      hilog.warn(DOMAIN, TAG, `Reply message ${messageId} not found in DataSource, loading...`);
      // ⭐ 异步加载被回复的消息
      this.loadReplyMessageIfNeeded(messageId);
      return '加载中...';
    }

    // ⭐ 如果有 senderName，直接返回
    if (msg.senderName && msg.senderName.length > 0) {
      hilog.info(DOMAIN, TAG, `Reply message ${messageId} found: senderName=${msg.senderName}`);
      return msg.senderName;
    }

    // ⭐ 如果没有 senderName 但有 senderId，尝试异步加载用户信息
    if (msg.senderId && msg.senderId > 0) {
      hilog.info(DOMAIN, TAG, `Reply message ${messageId} has no senderName, loading user info for senderId=${msg.senderId}`);
      this.loadUserInfoForMessage(msg);
      return '加载中...';
    }

    // ⭐ 如果没有 senderId，可能是频道/群组消息，尝试从聊天信息获取
    if (msg.chatId) {
      const chat = this.CoreService.getChat(msg.chatId);
      if (chat && chat.title) {
        return chat.title;
      }
    }

    return 'Unknown';
  }
  
  // ⭐ 用于跟踪正在加载用户信息的 messageId，避免重复加载
  private loadingUserInfoMessageIds: Set<number> = new Set();

  /**
   * ⭐ 异步加载消息的发送者用户信息
   * 修复：同时加载头像并处理路径格式
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
      const userInfo = await this.CoreService.getUserInfo(message.senderId);
      if (userInfo && (userInfo.name || userInfo.avatar)) {
        let updated = false;
        // 更新消息的 senderName
        if (userInfo.name && userInfo.name.length > 0) {
          message.senderName = userInfo.name;
          updated = true;
        }
        // 更新消息的 senderAvatar
        if (userInfo.avatar && !message.senderAvatar) {
          let avatarPath = userInfo.avatar;
          if (avatarPath && !avatarPath.startsWith('file://')) {
            avatarPath = 'file://' + avatarPath;
          }
          message.senderAvatar = avatarPath;
          updated = true;
        }
        // 通知数据变化
        if (updated) {
          this.messageDataSource.updateMessage(message);
          hilog.info(DOMAIN, TAG, `Updated message ${message.id} senderName to ${userInfo.name}, avatar=${userInfo.avatar ? 'yes' : 'no'}`);
        }
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to load user info for message ${message.id}: ${error}`);
    } finally {
      this.loadingUserInfoMessageIds.delete(message.id);
    }
  }

  /**
   * ⭐ 根据 messageId 和 senderId 异步加载用户信息并更新消息
   * 用于消息转换时缓存未命中的情况
   * 修复：添加 file:// 前缀处理，确保头像路径格式正确
   */
  private async loadUserInfoForMessageById(messageId: number, senderId: number): Promise<void> {
    // 避免重复加载
    if (this.loadingUserInfoMessageIds.has(messageId)) {
      return;
    }
    this.loadingUserInfoMessageIds.add(messageId);
    
    try {
      const userInfo = await this.CoreService.getUserInfo(senderId);
      if (userInfo && (userInfo.name || userInfo.avatar)) {
        // 从数据源获取消息
        const message = this.messageDataSource.getAllMessages().find(m => m.id === messageId);
        if (message) {
          // 更新消息的用户信息
          let updated = false;
          if (userInfo.name && !message.senderName) {
            message.senderName = userInfo.name;
            updated = true;
          }
          if (userInfo.avatar && !message.senderAvatar) {
            let avatarPath = userInfo.avatar;
            if (avatarPath && !avatarPath.startsWith('file://')) {
              avatarPath = 'file://' + avatarPath;
            }
            message.senderAvatar = avatarPath;
            updated = true;
          }
          // 通知数据变化
          if (updated) {
            this.messageDataSource.updateMessage(message);
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
   * ⭐ 异步加载转发消息的用户信息并更新
   */
  private async loadUserInfoForForwardMessage(messageId: number, senderId: number): Promise<void> {
    // 避免重复加载
    if (this.loadingUserInfoMessageIds.has(messageId)) {
      return;
    }
    this.loadingUserInfoMessageIds.add(messageId);
    
    try {
      const userInfo = await this.CoreService.getUserInfo(senderId);
      if (userInfo && userInfo.name) {
        // 从数据源获取消息
        const message = this.messageDataSource.getAllMessages().find(m => m.id === messageId);
        if (message && message.forwardInfo) {
          // 更新转发信息的 senderName
          message.forwardInfo.senderName = userInfo.name;
          // 通知数据变化
          this.messageDataSource.updateMessage(message);
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
   * ⭐ 异步加载聊天信息并更新消息（用于群组关联频道的情况）
   * 当 sender_id 类型为 messageSenderChat 时，需要获取聊天（频道）标题
   */
  private async loadChatInfoForMessage(messageId: number, chatId: number): Promise<void> {
    // 避免重复加载
    if (this.loadingUserInfoMessageIds.has(messageId)) {
      return;
    }
    this.loadingUserInfoMessageIds.add(messageId);
    
    try {
      // 从 CoreService 获取聊天信息
      const chat = await this.CoreService.getChat(chatId);
      if (chat && chat.title) {
        // 从数据源获取消息
        const message = this.messageDataSource.getAllMessages().find(m => m.id === messageId);
        if (message && !message.senderName) {
          // 更新消息的发送者名称（频道标题）
          message.senderName = chat.title;
          // 通知数据变化
          this.messageDataSource.updateMessage(message);
          hilog.info(DOMAIN, TAG, `Updated message ${messageId} senderName to chat title: ${chat.title}`);
        }
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to load chat info for message ${messageId}: ${error}`);
    } finally {
      this.loadingUserInfoMessageIds.delete(messageId);
    }
  }

  /**
   * 获取回复消息的预览文本
   */
  public getReplyPreview(messageId: number): string {
    // ⭐ 优化：使用 DataSource 获取消息
    const msg = this.messageDataSource.getMessageById(messageId);
    if (!msg) {
      // ⭐ 异步加载被回复的消息
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
   * ⭐ 如果被回复的消息不在内存中，尝试加载它
   */
  private async loadReplyMessageIfNeeded(messageId: number): Promise<void> {
    // 避免重复加载
    if (this.loadingReplyMessageIds.has(messageId)) {
      return;
    }

    this.loadingReplyMessageIds.add(messageId);
    hilog.info(DOMAIN, TAG, `Loading reply message ${messageId} from history`);

    try {
      // 从 CoreService 加载包含被回复消息的历史记录
      const messagesArray = await this.CoreService.getChatHistory(this.chatId, messageId, 0, 20, false);

      if (messagesArray && messagesArray.length > 0) {
        const newMessages: Message[] = [];
        for (const raw of messagesArray) {
          const msg = this.convertTdlibMessage(raw as Record<string, Object>);
          // ⭐ 优化：使用 DataSource 检查消息是否已存在
          if (msg && !this.messageDataSource.getMessageById(msg.id)) {
            newMessages.push(msg);
          }
        }

        if (newMessages.length > 0) {
          // 将这些消息添加到数据源（按时间顺序插入到合适位置）
          this.messageDataSource.insertMessages(newMessages);
          // ⭐ 优化：messageMap 已移除，无需更新
          hilog.info(DOMAIN, TAG, `Loaded ${newMessages.length} messages for reply reference`);
        } else {
          hilog.warn(DOMAIN, TAG, `No new messages loaded for reply ${messageId}`);
        }
      } else {
        hilog.warn(DOMAIN, TAG, `No history messages returned for reply ${messageId}`);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to load reply message ${messageId}: ${error}`);
    } finally {
      this.loadingReplyMessageIds.delete(messageId);
    }
  }

  /**
   * 发送内联键盘按钮回调
   */
  public async sendCallbackQuery(messageId: number, callbackData: string): Promise<void> {
    try {
      // TODO: 实现实际的 TDLib 回调发送
      promptAction.showToast({ message: '按钮点击: ' + callbackData, duration: 1500 });
    } catch (error) {
      hilog.error(DOMAIN, TAG, `sendCallbackQuery failed: ${error}`);
    }
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

  // ==================== TDLib 消息转换（增强版） ====================
  private convertTdlibMessage(msgRecord: Record<string, Object>): Message | null {
    try {
      const id = msgRecord['id'] as number;
      const chatId = msgRecord['chat_id'] as number;
      const isOutgoing = msgRecord['is_outgoing'] as boolean || false;
      const date = msgRecord['date'] as number || 0;
      const timestamp = date * 1000;
      const contentObj = msgRecord['content'] as Record<string, Object>;
      if (!contentObj) return null;
      // TDLib 使用 @type 字段标识对象类型
      const contentType = (contentObj['@type'] as string) || (contentObj['_'] as string);

      let messageType = MessageType.TEXT;
      let messageContent: string | object = '';
      let media: MediaInfo | undefined;
      let file: FileInfo | undefined;
      let duration = 0;
      let entities: TextEntity[] = [];
      // ⭐ TDLib 中回复消息的字段是 reply_to（对象），不是 reply_to_message_id
      const replyToRaw = msgRecord['reply_to'] as Record<string, Object> | undefined;
      let replyToMessageId: number | undefined = undefined;
      if (replyToRaw) {
        // reply_to 对象包含 message_id 字段
        const replyMsgId = replyToRaw['message_id'] as number | undefined;
        if (replyMsgId && replyMsgId > 0) {
          replyToMessageId = replyMsgId;
          hilog.info(DOMAIN, TAG, `convertTdlibMessage: message ${id} has replyTo ${replyToMessageId}`);
        }
      }

      // ⭐ 解析互动信息（浏览量、回复数等）
      let views: number | undefined = undefined;
      const interactionInfo = msgRecord['interaction_info'] as Record<string, Object>;
      if (interactionInfo) {
        views = interactionInfo['view_count'] as number;
      }
      let forwardInfo: ForwardInfo | undefined = undefined;

      // 解析转发信息
      const forwardInfoRaw = msgRecord['forward_info'] as Record<string, Object>;
      if (forwardInfoRaw) {
        const forwardOrigin = forwardInfoRaw['origin'] as Record<string, Object>;
        const forwardType = (forwardOrigin?.['@type'] as string) || (forwardOrigin?.['_'] as string) || '';
        
        // ⭐ 检测是否为频道帖子转发到关联群组
        const isChannelPostForward = forwardType === 'messageOriginChannel';
        
        let forwardSenderId = 0;
        let forwardSenderName = '';
        let forwardChatId: number | undefined = undefined;
        let forwardMessageId: number | undefined = undefined;
        let viewCount: number = 0;
        let replyCount: number = 0;
        
        if (isChannelPostForward) {
          // ⭐ 频道帖子转发 - 从 origin 中提取频道信息
          forwardChatId = forwardOrigin?.['chat_id'] as number;
          forwardMessageId = forwardOrigin?.['message_id'] as number;
          
          // ⭐ 从消息的 interaction_info 中获取浏览量和回复数
          const interactionInfo = msgRecord['interaction_info'] as Record<string, Object>;
          if (interactionInfo) {
            viewCount = (interactionInfo['view_count'] as number) || 0;
            replyCount = (interactionInfo['reply_count'] as number) || 0;
          }
          
          // 获取频道标题
          if (forwardChatId) {
            const chat = this.CoreService.getChat(forwardChatId);
            forwardSenderName = chat?.title || '频道';
          }
          
          hilog.debug(DOMAIN, TAG, `Channel post: chatId=${forwardChatId}, msgId=${forwardMessageId}, views=${viewCount}, replies=${replyCount}`);
        } else {
          // 普通转发
          forwardSenderId = (forwardOrigin?.['sender_user_id'] as number) || 0;
          forwardSenderName = forwardOrigin?.['sender_name'] as string || '';
          forwardChatId = forwardInfoRaw['chat_id'] as number;
          forwardMessageId = forwardInfoRaw['message_id'] as number;
          
          // ⭐ 如果 sender_name 为空但有 sender_user_id，尝试从缓存获取
          if (!forwardSenderName && forwardSenderId > 0) {
            const cachedUser = this.CoreService.getCachedUserInfo(forwardSenderId);
            if (cachedUser && cachedUser.name) {
              forwardSenderName = cachedUser.name;
            }
            // 触发异步加载，后续更新
            this.loadUserInfoForForwardMessage(id, forwardSenderId);
          }
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

      // ⭐ 提前解析发送者信息（系统消息需要使用 senderName）
      const senderId = this.extractSenderId(msgRecord['sender_id']);
      const senderName = this.extractSenderName(msgRecord['sender_id']);
      // ⭐ 优化：传入 messageId，如果没有头像会触发异步加载
      const senderAvatar = this.extractSenderAvatar(msgRecord['sender_id'], id);
      
      // ⭐ 如果缓存未命中，触发异步加载用户信息（用于后续更新消息）
      if (senderId > 0 && !senderName) {
        this.loadUserInfoForMessageById(id, senderId);
      }
      
      // ⭐ 检查 sender_id 类型，如果是 messageSenderChat 且没有获取到名称，触发异步加载聊天信息
      const senderObj = msgRecord['sender_id'] as Record<string, Object>;
      if (senderObj) {
        const senderType = (senderObj['@type'] as string) || (senderObj['_'] as string);
        if (senderType === 'messageSenderChat' && !senderName) {
          const chatId = senderObj['chat_id'] as number;
          if (chatId > 0) {
            hilog.info(DOMAIN, TAG, `Message ${id} has messageSenderChat type, loading chat info for chatId=${chatId}`);
            this.loadChatInfoForMessage(id, chatId);
          }
        }
      }

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
              // 选择合适尺寸的图片（优先中等尺寸）
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
        case 'messageAudio':
          messageType = MessageType.AUDIO;
          const audio = contentObj['audio'] as Record<string, Object>;
          if (audio) {
            duration = audio['duration'] as number || 0;
            const audioFile = audio['audio'] as Record<string, Object>;
            if (audioFile) {
              const fileId = audioFile['id'] as number;
              const local = audioFile['local'] as Record<string, Object>;
              const audioTitle = audio['title'] as string || '';
              const audioPerformer = audio['performer'] as string || '';
              media = { 
                tdlibFileId: fileId, 
                duration,
                fileName: audioTitle ? `${audioPerformer} - ${audioTitle}` : (audio['file_name'] as string || '音乐')
              } as MediaInfo;
              file = { id: fileId, path: local?.['path'] as string } as FileInfo;
            }
          }
          break;
        case 'messageVideoNote':
          messageType = MessageType.VIDEO_NOTE;
          const videoNote = contentObj['video_note'] as Record<string, Object>;
          if (videoNote) {
            duration = videoNote['duration'] as number || 0;
            const videoNoteFile = videoNote['video'] as Record<string, Object>;
            if (videoNoteFile) {
              const fileId = videoNoteFile['id'] as number;
              const local = videoNoteFile['local'] as Record<string, Object>;
              const thumb = videoNote['thumbnail'] as Record<string, Object>;
              const thumbFile = thumb?.['file'] as Record<string, Object>;
              const thumbLocal = thumbFile?.['local'] as Record<string, Object>;
              const thumbPath = thumbLocal?.['path'] as string;
              media = { tdlibFileId: fileId, duration, thumbnail: thumbPath } as MediaInfo;
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
            address: loc['address'] as string || '',
            livePeriod: loc['live_period'] as number || 0
          } as MessageContent;
          break;
        case 'messageVenue':
          messageType = MessageType.LOCATION;
          const venue = contentObj['venue'] as Record<string, Object>;
          const venueLocation = venue['location'] as Record<string, Object>;
          messageContent = {
            title: venue['title'] as string,
            address: venue['address'] as string,
            latitude: venueLocation?.['latitude'] as number,
            longitude: venueLocation?.['longitude'] as number
          } as MessageContent;
          break;
        case 'messageContact':
          messageType = MessageType.CONTACT;
          const contact = contentObj['contact'] as Record<string, Object>;
          messageContent = {
            firstName: contact['first_name'] as string || '',
            lastName: contact['last_name'] as string || '',
            phoneNumber: contact['phone_number'] as string || '',
            userId: contact['user_id'] as number || 0
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
            })) || [],
            totalVoterCount: poll['total_voter_count'] as number,
            isAnonymous: poll['is_anonymous'] as boolean,
            allowsMultipleAnswers: poll['allows_multiple_answers'] as boolean,
            closeDate: poll['close_date'] as number
          } as MessageContent;
          break;
        case 'messageGame':
          messageType = MessageType.GAME;
          const game = contentObj['game'] as Record<string, Object>;
          messageContent = {
            title: game['title'] as string,
            description: game['description'] as string,
            gameId: game['id'] as number,
            shortName: game['short_name'] as string
          } as MessageContent;
          break;
        case 'messageCall':
          messageType = MessageType.CALL;
          const call = contentObj['call'] as Record<string, Object>;
          messageContent = {
            isVideo: call['is_video'] as boolean,
            duration: call['duration'] as number,
            isOutgoing: call['is_outgoing'] as boolean,
            isMissed: call['is_missed'] as boolean
          } as MessageContent;
          break;
        case 'messageInvoice':
          messageType = MessageType.INVOICE;
          const invoice = contentObj['invoice'] as Record<string, Object>;
          const invoiceContent: MessageContent = {
            title: invoice['title'] as string,
            description: invoice['description'] as string,
            currency: invoice['currency'] as string,
            totalAmount: invoice['total_amount'] as number
          };
          messageContent = invoiceContent;
          break;
        case 'messagePaymentSuccessful':
          messageType = MessageType.PAYMENT_SUCCESSFUL;
          const payment = contentObj['payment'] as Record<string, Object>;
          const paymentContent: MessageContent = {
            currency: payment?.['currency'] as string,
            totalAmount: payment?.['total_amount'] as number,
            invoiceMessageId: contentObj['invoice_message_id'] as number
          };
          messageContent = paymentContent;
          break;
        case 'messageGiftedPremium':
          messageType = MessageType.GIFT_PREMIUM;
          const giftedPremium = contentObj['gifted_premium'] as Record<string, Object>;
          const giftPremiumContent: MessageContent = {
            text: '',
            caption: (contentObj['caption'] as Record<string, Object>)?.['text'] as string || ''
          };
          messageContent = giftPremiumContent;
          break;
        case 'messageGiftCode':
          messageType = MessageType.GIFT_CODE;
          const giftCodeContent: MessageContent = {
            text: '',
            caption: ((contentObj['gift_code'] as Record<string, Object>)?.['caption'] as Record<string, Object>)?.['text'] as string || ''
          };
          messageContent = giftCodeContent;
          break;
        case 'messageGiveaway':
          messageType = MessageType.GIVEAWAY;
          const giveawayObj = contentObj['giveaway'] as Record<string, Object>;
          const giveawayContent: MessageContent = {
            text: '',
            description: (giveawayObj?.['prize_description'] as string) || ''
          };
          messageContent = giveawayContent;
          break;
        case 'messageGiveawayWinners':
          messageType = MessageType.GIVEAWAY_WINNERS;
          const giveawayWinnersContent: MessageContent = {
            text: ''
          };
          messageContent = giveawayWinnersContent;
          break;
        case 'messageExpiredPhoto':
          messageType = MessageType.EXPIRED_PHOTO;
          messageContent = '照片已过期';
          break;
        case 'messageExpiredVideo':
          messageType = MessageType.EXPIRED_VIDEO;
          messageContent = '视频已过期';
          break;
        case 'messageExpiredVoiceNote':
          messageType = MessageType.EXPIRED_VOICE_NOTE;
          messageContent = '语音已过期';
          break;
        case 'messageExpiredVideoNote':
          messageType = MessageType.EXPIRED_VIDEO_NOTE;
          messageContent = '视频消息已过期';
          break;
        case 'messageDice':
          messageType = MessageType.DICE;
          const diceObj = contentObj['dice'] as Record<string, Object>;
          const diceContent: MessageContent = {
            text: (diceObj?.['emoji'] as string) || '🎲',
            description: String(diceObj?.['value'] as number || 1)
          };
          messageContent = diceContent;
          break;
        case 'messagePinMessage':
          messageType = MessageType.SYSTEM;
          const pinnedMsgId = contentObj['message_id'] as number;
          messageContent = senderName ? `${senderName} 置顶了一条消息` : '置顶了一条消息';
          break;
        case 'messageChatAddMembers':
          messageType = MessageType.SYSTEM;
          const addedMemberIds = contentObj['member_user_ids'] as number[];
          // 获取被添加成员的用户名（优先使用缓存，无缓存时异步加载并更新）
          const addedMemberNames = addedMemberIds?.map(userId => {
            const user = this.CoreService.getCachedUserInfo(userId);
            return user?.name || ''; // 返回空字符串表示未获取到名称
          }) || [];
          // 过滤掉空名称
          const validNames = addedMemberNames.filter(name => name.length > 0);
          // 生成消息文本
          if (validNames.length === 1) {
            messageContent = `${validNames[0]} 已加入群组`;
          } else if (validNames.length > 1) {
            const names = validNames.slice(0, 3).join('、');
            const more = validNames.length > 3 ? `等${validNames.length}人` : '';
            messageContent = `${names}${more} 已加入群组`;
          } else {
            // 无法获取任何用户名时，显示通用文案并触发异步加载
            const memberCount = addedMemberIds?.length || 1;
            messageContent = memberCount > 1 ? `${memberCount}位新成员已加入群组` : '新成员已加入群组';
          }
          // ⭐ 异步加载缺失的用户信息并更新消息（无论是否获取到名称，都尝试加载）
          if (addedMemberIds && addedMemberIds.length > 0) {
            const missingUserIds = addedMemberIds.filter(userId => {
              const user = this.CoreService.getCachedUserInfo(userId);
              return !user || !user.name;
            });
            if (missingUserIds.length > 0) {
              this.loadMissingUserNamesAndUpdateMessage(id, missingUserIds, 'join');
            }
          }
          break;
        case 'messageChatJoinByLink':
          messageType = MessageType.SYSTEM;
          // 使用发送者名称（已通过 extractSenderName 获取）
          messageContent = senderName ? `${senderName} 通过链接加入群组` : '通过链接加入群组';
          break;
        case 'messageChatDeleteMember':
          messageType = MessageType.SYSTEM;
          const removedUserId = contentObj['member_user_id'] as number;
          // ⭐ 获取被移除成员的用户名（优先使用缓存）
          const removedUser = removedUserId ? this.CoreService.getCachedUserInfo(removedUserId) : null;
          const removedUserName = removedUser?.name || '';
          // 根据是否能获取到用户名生成文案
          if (senderName && removedUserName) {
            messageContent = `${senderName} 移除了 ${removedUserName}`;
          } else if (senderName) {
            messageContent = `${senderName} 移除了成员`;
          } else if (removedUserName) {
            messageContent = `${removedUserName} 已离开群组`;
          } else {
            messageContent = '成员已离开群组';
          }
          // ⭐ 异步加载缺失的用户信息并更新消息
          if (removedUserId && !removedUserName) {
            this.loadMissingUserNamesAndUpdateMessage(id, [removedUserId], 'leave', senderId);
          }
          break;
        case 'messageChatChangeTitle':
          messageType = MessageType.SYSTEM;
          const newTitle = contentObj['title'] as string;
          messageContent = senderName 
            ? `${senderName} 将群组名称更改为"${newTitle}"` 
            : `群组名称已更改为"${newTitle}"`;
          break;
        case 'messageChatChangePhoto':
          messageType = MessageType.SYSTEM;
          messageContent = senderName ? `${senderName} 更改了群组头像` : '群组头像已更改';
          break;
        case 'messageChatUpgradeTo':
        case 'messageChatUpgradeFrom':
          messageType = MessageType.SYSTEM;
          messageContent = senderName ? `${senderName} 升级了群组` : '群组已升级';
          break;
        case 'messageChatSetTheme':
          messageType = MessageType.SYSTEM;
          const themeName = contentObj['theme_name'] as string || '';
          messageContent = senderName
            ? `${senderName} 更改了聊天主题为"${themeName}"`
            : `聊天主题已更改为"${themeName}"`;
          break;
        case 'messageChatSetMessageAutoDeleteTime':
          messageType = MessageType.SYSTEM;
          const autoDeleteTime = contentObj['message_auto_delete_time'] as number || 0;
          const timeText = autoDeleteTime === 0 ? '关闭' : `${autoDeleteTime}秒`;
          messageContent = senderName
            ? `${senderName} 将自动删除时间设置为 ${timeText}`
            : `自动删除时间已设置为 ${timeText}`;
          break;
        case 'messageSuggestProfilePhoto':
          messageType = MessageType.SYSTEM;
          messageContent = senderName ? `${senderName} 建议了一个新头像` : '有人建议了一个新头像';
          break;
        case 'messageWebAppDataSent':
        case 'messageWebAppDataReceived':
          messageType = MessageType.SYSTEM;
          messageContent = 'Web App 数据';
          break;
        case 'messageBotWriteAccessAllowed':
          messageType = MessageType.SYSTEM;
          messageContent = '已允许机器人写入权限';
          break;
        case 'messageProximityAlertTriggered':
          messageType = MessageType.SYSTEM;
          const travelerId = contentObj['traveler_id'] as Record<string, Object>;
          const watcherId = contentObj['watcher_id'] as Record<string, Object>;
          const distance = contentObj['distance'] as number || 0;
          messageContent = `接近警报: 距离 ${distance} 米`;
          break;
        default:
          messageType = MessageType.TEXT;
          messageContent = '不支持的消息类型';
      }

      const status = isOutgoing ? MessageStatus.SENT : MessageStatus.READ;

      // ⭐ 判断是否为系统消息并设置相关字段
      let systemType: SystemMessageType | undefined = undefined;
      let systemParams: SystemMessageParams | undefined = undefined;

      if (this.isSystemMessage(contentObj)) {
        systemType = this.mapToSystemMessageType(contentType);
        systemParams = {
          userName: senderName,
          actionerName: senderName,
          message: typeof messageContent === 'string' ? messageContent : undefined
        };
      }

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
        systemType,
        systemParams,
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

  /**
   * ⭐ 从 sender_id 中提取发送者名称
   * 注意：这里只能获取到发送者ID，完整名称需要通过 CoreService 获取用户信息
   * 作为临时方案，先返回空字符串，让 CoreService 处理后的消息来填充正确名称
   */
  private extractSenderName(senderObj: Object | undefined): string {
    if (!senderObj) return '';
    const record = senderObj as Record<string, Object>;
    const senderType = (record['@type'] as string) || (record['_'] as string);
    
    if (senderType === 'messageSenderUser') {
      const userId = record['user_id'] as number;
      // 尝试从 CoreService 的缓存中获取用户信息
      const cachedUser = this.CoreService.getCachedUserInfo(userId);
      if (cachedUser && cachedUser.name) {
        return cachedUser.name;
      }
    } else if (senderType === 'messageSenderChat') {
      const chatId = record['chat_id'] as number;
      // 尝试获取聊天信息（用于群组关联频道的情况）
      const chat = this.CoreService.getChat(chatId);
      if (chat && chat.title) {
        return chat.title;
      }
      // ⭐ 如果本地缓存没有，尝试从 CoreService 获取聊天信息（异步）
      // 这里返回空字符串，让后续的异步加载来处理
      hilog.debug(DOMAIN, TAG, `extractSenderName: chat ${chatId} not found in cache, will load async`);
    }
    return '';
  }

  /**
   * ⭐ 从 sender_id 中提取发送者头像
   * 修复：添加 file:// 前缀处理，确保头像路径格式正确
   * 优化：如果没有头像，触发异步加载用户信息
   */
  private extractSenderAvatar(senderObj: Object | undefined, messageId?: number): string {
    if (!senderObj) return '';
    const record = senderObj as Record<string, Object>;
    const senderType = (record['@type'] as string) || (record['_'] as string);
    
    if (senderType === 'messageSenderUser') {
      const userId = record['user_id'] as number;
      // 尝试从 CoreService 的缓存中获取用户信息
      const cachedUser = this.CoreService.getCachedUserInfo(userId);
      if (cachedUser && cachedUser.avatar) {
        let avatarPath = cachedUser.avatar;
        if (avatarPath && !avatarPath.startsWith('file://')) {
          avatarPath = 'file://' + avatarPath;
        }
        return avatarPath;
      }
      
      // ⭐ 如果缓存中没有头像，主动触发用户信息加载（这会触发头像下载）
      if (messageId && userId > 0) {
        hilog.debug(DOMAIN, TAG, `extractSenderAvatar: no avatar in cache for user ${userId}, triggering load`);
        this.loadUserInfoForMessageById(messageId, userId);
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
   * ⭐ 判断消息是否为系统消息（服务消息）
   * 根据 TDlib 返回的 message.content._type 是否属于服务消息类型
   */
  private isSystemMessage(content: Record<string, Object> | undefined): boolean {
    if (!content) return false;

    const type = (content['@type'] as string) || (content['_'] as string);
    if (!type) return false;

    // 定义系统消息类型前缀
    const systemPrefixes = [
      'messageChat',      // 所有聊天事件：messageChatAddMembers, messageChatDeleteMember 等
      'messagePinMessage',
      'messageCall',
      'messageGameScore',
      'messagePayment',
      'messageInvoice',
      'messageBasicGroupChatCreate',
      'messageSupergroupChatCreate',
      'messageChatSetMessageAutoDeleteTime',
      'messageCustomServiceAction',
      'messageWebsiteConnected'
    ];

    return systemPrefixes.some(prefix => type.startsWith(prefix));
  }

  /**
   * ⭐ 将 TDlib 内容类型映射为 SystemMessageType
   */
  private mapToSystemMessageType(contentType: string): SystemMessageType {
    switch (contentType) {
      // 成员加入相关
      case 'messageChatAddMembers':
      case 'messageChatInviteUsers':
        return SystemMessageType.MEMBER_JOINED;
      case 'messageChatJoinByLink':
      case 'messageChatJoinByRequest':
        return SystemMessageType.MEMBER_JOINED_BY_LINK;

      // 成员离开/移除相关
      case 'messageChatDeleteMember':
      case 'messageChatLeaveMember':
        return SystemMessageType.MEMBER_LEFT;

      // 群组设置变更
      case 'messageChatChangeTitle':
        return SystemMessageType.TITLE_CHANGED;
      case 'messageChatChangePhoto':
        return SystemMessageType.PHOTO_CHANGED;
      case 'messageChatDeletePhoto':
        return SystemMessageType.PHOTO_CHANGED;
      case 'messageChatSetTtl':
        return SystemMessageType.SLOW_MODE_CHANGED;

      // 消息置顶
      case 'messagePinMessage':
        return SystemMessageType.MESSAGE_PINNED;
      case 'messageUnpinMessage':
        return SystemMessageType.MESSAGE_UNPINNED;

      // 群组创建和升级
      case 'messageBasicGroupChatCreate':
      case 'messageSupergroupChatCreate':
      case 'messageChannelChatCreate':
        return SystemMessageType.CHAT_CREATED;
      case 'messageChatUpgradeTo':
      case 'messageChatUpgradeFrom':
        return SystemMessageType.LINKED_CHAT_CHANGED;

      // 其他系统消息类型兜底处理为成员加入（最常见的情况）
      case 'messageChatSetMessageAutoDeleteTime':
      case 'messageChatSetTheme':
      case 'messageChatSetVideoChatDefaultParticipant':
      case 'messageChatToggleAutoDelete':
      case 'messageChatToggleJoinToSend':
      case 'messageChatToggleJoinRequest':
      case 'messageChatToggleSignatures':
      case 'messageChatToggleSlowMode':
        return SystemMessageType.MEMBER_JOINED;

      default:
        // 如果是以 messageChat 开头的，大概率是成员相关操作
        if (contentType.startsWith('messageChat')) {
          return SystemMessageType.MEMBER_JOINED;
        }
        return SystemMessageType.UNKNOWN;
    }
  }

  /**
   * ⭐ 异步加载缺失的用户名并更新系统消息
   * 当系统消息中的用户名不在缓存中时，异步获取并更新消息显示
   */
  private async loadMissingUserNamesAndUpdateMessage(
    messageId: number,
    userIds: number[],
    actionType: 'join' | 'leave',
    senderId?: number
  ): Promise<void> {
    try {
      // 并行加载所有缺失的用户信息
      const userPromises = userIds.map(async (userId): Promise<UserNameInfo> => {
        const userInfo = await this.CoreService.getUserInfo(userId);
        return { userId: userId, name: userInfo?.name || '' };
      });

      const users = await Promise.all(userPromises);
      const validNames = users.filter((u: UserNameInfo) => u.name.length > 0).map(u => u.name);

      if (validNames.length === 0) {
        hilog.warn(DOMAIN, TAG, `loadMissingUserNames: no valid names found for message ${messageId}`);
        return;
      }

      // 获取消息
      const message = this.messageDataSource.getAllMessages().find(m => m.id === messageId);
      if (!message) {
        hilog.warn(DOMAIN, TAG, `loadMissingUserNames: message ${messageId} not found`);
        return;
      }

      // 根据动作类型生成新文本
      let newContent = '';
      if (actionType === 'join') {
        if (validNames.length === 1) {
          newContent = `${validNames[0]} 已加入群组`;
        } else {
          const names = validNames.slice(0, 3).join('、');
          const more = validNames.length > 3 ? `等${validNames.length}人` : '';
          newContent = `${names}${more} 已加入群组`;
        }
      } else if (actionType === 'leave') {
        const senderName = senderId ? this.CoreService.getCachedUserInfo(senderId)?.name : '';
        const removedName = validNames[0] || '成员';
        if (senderName && senderName !== removedName) {
          newContent = `${senderName} 移除了 ${removedName}`;
        } else {
          newContent = `${removedName} 已离开群组`;
        }
      }

      // 更新消息内容
      if (newContent && newContent !== message.content) {
        message.content = newContent;
        // 更新 systemParams
        if (message.systemParams) {
          message.systemParams.userName = validNames[0];
          message.systemParams.message = newContent;
        }
        // 通知数据变化
        this.messageDataSource.updateMessage(message);
        hilog.info(DOMAIN, TAG, `loadMissingUserNames: updated message ${messageId} with names: ${validNames.join(', ')}`);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `loadMissingUserNames failed for message ${messageId}: ${error}`);
    }
  }

  // ==================== 系统消息处理 ====================

  /**
   * ⭐ 格式化系统消息文本
   * 根据系统消息类型和参数生成显示文本
   */
  public formatSystemMessageText(type: SystemMessageType, params: SystemMessageParams): string {
    switch (type) {
      // 成员相关
      case SystemMessageType.MEMBER_JOINED:
        return `${params.userName || '新成员'} 加入了群组`;
      case SystemMessageType.MEMBER_JOINED_BY_LINK:
        return `${params.userName || '新成员'} 通过邀请链接加入`;
      case SystemMessageType.MEMBER_INVITED:
        return `${params.inviterName || '管理员'} 邀请 ${params.userName || '新成员'} 加入了群组`;
      case SystemMessageType.MEMBER_LEFT:
        return `${params.userName || '成员'} 离开了群组`;
      case SystemMessageType.MEMBER_REMOVED:
        return `${params.actionerName || '管理员'} 将 ${params.userName || '成员'} 移出了群组`;
      case SystemMessageType.MEMBER_PROMOTED:
        return `${params.actionerName || '管理员'} 将 ${params.userName || '成员'} 设为管理员`;
      case SystemMessageType.MEMBER_DEMOTED:
        return `${params.actionerName || '管理员'} 撤销了 ${params.userName || '成员'} 的管理员权限`;
      case SystemMessageType.MEMBER_RESTRICTED:
        return `${params.actionerName || '管理员'} 禁言了 ${params.userName || '成员'}`;
      case SystemMessageType.MEMBER_UNRESTRICTED:
        return `${params.actionerName || '管理员'} 解除了 ${params.userName || '成员'} 的禁言`;
      case SystemMessageType.MEMBER_BANNED:
        return `${params.actionerName || '管理员'} 封禁了 ${params.userName || '成员'}`;

      // 聊天设置
      case SystemMessageType.CHAT_CREATED:
        return `群组已创建`;
      case SystemMessageType.TITLE_CHANGED:
        return `${params.actionerName || '管理员'} 将群组名称更改为"${params.newTitle || '新名称'}"`;
      case SystemMessageType.PHOTO_CHANGED:
        return `${params.actionerName || '管理员'} 更新了群组头像`;
      case SystemMessageType.DESCRIPTION_CHANGED:
        return `${params.actionerName || '管理员'} 更新了群组描述`;
      case SystemMessageType.SLOW_MODE_CHANGED:
        const duration = params.duration === 0 ? '关闭' : `${params.duration}秒`;
        return `${params.actionerName || '管理员'} 将慢速模式设置为 ${duration}`;
      case SystemMessageType.SIGN_MESSAGES_CHANGED:
        return `${params.actionerName || '管理员'} ${params.enabled ? '开启' : '关闭'}了匿名消息`;
      case SystemMessageType.LINKED_CHAT_CHANGED:
        return `群组已升级为超级群组`;

      // 消息操作
      case SystemMessageType.MESSAGE_EDITED:
        return `${params.userName || '用户'} 编辑了一条消息`;
      case SystemMessageType.MESSAGE_DELETED:
        return `${params.userName || '用户'} 删除了一条消息`;
      case SystemMessageType.MESSAGE_PINNED:
        return `${params.userName || '用户'} 置顶了一条消息`;
      case SystemMessageType.MESSAGE_UNPINNED:
        return `${params.userName || '用户'} 取消置顶了一条消息`;

      // 其他
      case SystemMessageType.POLL_CREATED:
        return `${params.userName || '用户'} 发起了投票：${params.question || ''}`;
      case SystemMessageType.GAME_STARTED:
        return `${params.userName || '用户'} 开始了游戏"${params.gameTitle || ''}"`;
      case SystemMessageType.INVOICE_SENT:
        return `${params.userName || '用户'} 发起了收款：${params.title || ''}`;
      case SystemMessageType.PAYMENT_SUCCESSFUL:
        return `${params.userName || '用户'} 已成功支付`;

      default:
        return params.message || '群组信息已更新';
    }
  }

  /**
   * ⭐ 获取系统消息图标
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

  // ==================== CoreService 领域事件处理 ====================
  private handleCoreFileDownloadProgress = (data?: Object): void => {
    if (!data) return;
    const fileId = (data as Record<string, Object>)['fileId'] as number;
    const progress = (data as Record<string, Object>)['progress'] as number;
    const isCompleted = (data as Record<string, Object>)['isCompleted'] as boolean;
    const localPath = (data as Record<string, Object>)['localPath'] as string | undefined;
    const isDownloading = (data as Record<string, Object>)['isDownloading'] as boolean;
    
    if (!fileId) return;
    
    this.fileDownloadMap.set(fileId, { progress, isDownloading, localPath });
    
    // 更新对应消息
    for (const msg of this.messageDataSource.getAllMessages()) {
      const msgFileId = msg.media?.tdlibFileId || msg.file?.id;
      if (msgFileId === fileId) {
        if (isCompleted && localPath) {
          if (msg.file) msg.file.path = localPath;
          if (msg.media) msg.media.localPath = localPath;
          msg.downloadProgress = 100;
          msg.isDownloading = false;
        } else if (isDownloading) {
          msg.downloadProgress = progress;
          msg.isDownloading = true;
        }
        this.updateMessage(msg);
        break;
      }
    }
  };

  private handleCoreConnectionState = (data?: Object): void => {
    if (!data) return;
    const state = (data as Record<string, Object>)['state'] as string;
    if (state === 'connectionStateReady') this.connectionState = 'connected';
    else if (state === 'connectionStateConnecting' || state === 'connectionStateUpdating') this.connectionState = 'connecting';
    else this.connectionState = 'disconnected';
    this.refreshUI();
  };

  // ⭐ Nagram 参考：批量更新事件处理（位掩码驱动增量刷新）
  // 等价于 Nagram 的 updateInterfaceWithMessages + updateInterfaces(mask)
  private handleBatchUpdate = (data?: Object): void => {
    if (!data) return;
    const mask = (data as Record<string, Object>)['mask'] as number;
    if (!mask) return;

    // ⭐ 细粒度增量刷新：按位掩码决定刷新哪些部分
    // 相当于 Nagram 中 postNotificationName(updateInterfaces, mask) 的处理逻辑
    if ((mask & UPDATE_MASK_CONNECTION) !== 0) {
      this.refreshUI();
    }
    if ((mask & UPDATE_MASK_USER_AVATAR) !== 0) {
      this.refreshUI();
    }
    if ((mask & UPDATE_MASK_FILE_PROGRESS) !== 0) {
      // 文件下载进度由 handleCoreFileDownloadProgress 处理
    }
  };

  // ==================== CoreService 领域事件处理 ====================
  private handleCoreNewMessage = async (data?: Object): Promise<void> => {
    if (!data) return;
    const chatId = (data as Record<string, Object>)['chatId'] as number;
    const message = (data as Record<string, Object>)['message'] as Record<string, Object>;
    if (chatId !== this.chatId || !message) return;

    const msgId = message['id'] as number;
    const isOutgoing = message['is_outgoing'] as boolean;

    // ⭐ Nagram 参考：如果加载/刷新正在进行，暂存消息到队列
    // 避免与 loadMessages 中的 setMessages 并发竞争造成数据丢失
    if (this.isLoadingMessages || this.isRefreshing) {
      this.pendingMessages.push(data as Record<string, Object>);
      hilog.info(DOMAIN, TAG, `Load in progress, queued message ${msgId} for later (pendingQueue=${this.pendingMessages.length})`);
      return;
    }

    hilog.info(DOMAIN, TAG, `handleCoreNewMessage: chatId=${chatId}, msgId=${msgId}, isOutgoing=${isOutgoing}`);

    // ⭐ 优化：使用 DataSource 检查消息是否已存在
    if (this.messageDataSource.getMessageById(msgId)) {
      hilog.info(DOMAIN, TAG, `Message ${msgId} already exists, skipping`);
      return;
    }

    // ⭐ 关键修复：如果是自己发送的消息，只尝试替换临时消息，不直接添加
    // 因为发出的消息应该由 handleCoreMessageSent 处理
    if (isOutgoing) {
      // 查找相同内容的临时消息（发送中的消息）
      const content = message['content'] as Record<string, Object>;
      const textContent = content?.['text'] as Record<string, Object>;
      const messageText = textContent?.['text'] as string || '';

      // ⭐ 优化：遍历 DataSource 查找匹配的临时消息
      const allMessages = this.messageDataSource.getAllMessages();
      let foundTempMessage = false;
      for (const existingMsg of allMessages) {
        if (existingMsg.isOutgoing && existingMsg.status === MessageStatus.SENDING) {
          const existingText = typeof existingMsg.content === 'string'
            ? existingMsg.content
            : (existingMsg.content as MessageContent)?.text || '';

          if (existingText === messageText) {
            hilog.info(DOMAIN, TAG, `Found matching temp message ${existingMsg.id}, replacing with ${msgId}`);
            const newMsg = this.convertTdlibMessage(message);
            if (newMsg) {
              this.replaceMessage(existingMsg.id, newMsg);
              foundTempMessage = true;
              return;
            }
          }
        }
      }

      // 如果没有找到匹配的临时消息，不添加（等待 handleCoreMessageSent 处理）
      if (!foundTempMessage) {
        hilog.info(DOMAIN, TAG, `No matching temp message found for outgoing message ${msgId}, skipping (will be handled by handleCoreMessageSent)`);
        return;
      }
    }

    // 只有非发出的消息才直接添加
    const newMsg = this.convertTdlibMessage(message);
    if (newMsg) {
      hilog.info(DOMAIN, TAG, `Appending new message ${msgId}`);
      this.appendMessage(newMsg);
      // ⭐ 滚动到底部显示新消息
      this.notifyScrollToBottom();
      // 自动标记已读
      if (!newMsg.isOutgoing) {
        await this.CoreService.viewMessages(this.chatId, [newMsg.id], null, true);
      }
    }
  };

  private handleCoreMessageSent = (data?: Object): void => {
    if (!data) return;
    const chatId = (data as Record<string, Object>)['chatId'] as number;
    const messageId = (data as Record<string, Object>)['messageId'] as number;
    const message = (data as Record<string, Object>)['message'] as Record<string, Object>;

    hilog.info(DOMAIN, TAG, `handleCoreMessageSent: chatId=${chatId}, messageId=${messageId}`);

    if (chatId !== this.chatId || !message) return;

    // ⭐ 优化：使用 DataSource 检查消息是否已存在
    if (this.messageDataSource.getMessageById(messageId)) {
      hilog.info(DOMAIN, TAG, `Message ${messageId} already exists in handleCoreMessageSent, skipping`);
      return;
    }

    // 查找对应的临时消息并替换
    // 临时消息的特征：isOutgoing=true, status=SENDING, 内容匹配
    const content = message['content'] as Record<string, Object>;
    const textContent = content?.['text'] as Record<string, Object>;
    const messageText = textContent?.['text'] as string || '';

    // ⭐ 优化：遍历 DataSource 查找匹配的临时消息
    const allMessages = this.messageDataSource.getAllMessages();
    for (const existingMsg of allMessages) {
      if (existingMsg.isOutgoing && existingMsg.status === MessageStatus.SENDING) {
        const existingText = typeof existingMsg.content === 'string'
          ? existingMsg.content
          : (existingMsg.content as MessageContent)?.text || '';

        if (existingText === messageText) {
          hilog.info(DOMAIN, TAG, `Found matching temp message ${existingMsg.id} in handleCoreMessageSent, replacing with ${messageId}`);
          const newMsg = this.convertTdlibMessage(message);
          if (newMsg) {
            this.replaceMessage(existingMsg.id, newMsg);
            // ⭐ 滚动到底部显示新消息
            this.notifyScrollToBottom();
            return;
          }
        }
      }
    }

    // 如果没有找到匹配的临时消息，直接添加
    hilog.info(DOMAIN, TAG, `No matching temp message found, appending message ${messageId}`);
    const newMsg = this.convertTdlibMessage(message);
    if (newMsg) {
      this.appendMessage(newMsg);
      // ⭐ 滚动到底部显示新消息
      this.notifyScrollToBottom();
    }
  };

  private handleCoreMessageFailed = (data?: Object): void => {
    if (!data) return;
    const chatId = (data as Record<string, Object>)['chatId'] as number;
    const messageId = (data as Record<string, Object>)['messageId'] as number;

    if (chatId !== this.chatId) return;

    // ⭐ 优化：使用 DataSource 获取消息
    const msg = this.messageDataSource.getMessageById(messageId);
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
    if (!data) {
      hilog.warn(DOMAIN, TAG, 'handleCoreMessageDeleted: data is null');
      return;
    }
    const chatId = (data as Record<string, Object>)['chatId'] as number;
    const messageIds = (data as Record<string, Object>)['messageIds'] as number[];
    const isPermanent = (data as Record<string, Object>)['isPermanent'] as boolean;

    hilog.info(DOMAIN, TAG, `handleCoreMessageDeleted: chatId=${chatId}, currentChatId=${this.chatId}, messageIds=${JSON.stringify(messageIds)}, isPermanent=${isPermanent}`);

    if (chatId !== this.chatId) {
      hilog.info(DOMAIN, TAG, `handleCoreMessageDeleted: chatId mismatch, skipping. Received=${chatId}, Current=${this.chatId}`);
      return;
    }

    if (!messageIds || messageIds.length === 0) {
      hilog.warn(DOMAIN, TAG, 'handleCoreMessageDeleted: messageIds is empty');
      return;
    }

    // ⭐ 安全验证：防止误删大量消息（超过100条可能是异常）
    if (messageIds.length > 100) {
      hilog.error(DOMAIN, TAG, `handleCoreMessageDeleted: WARNING! Attempting to delete ${messageIds.length} messages, possible error. Aborting.`);
      return;
    }

    // ⭐ 关键修复：无论 isPermanent 值如何，都从 UI 移除消息
    // 因为 TDLib 已经将其删除，UI 应该同步
    hilog.info(DOMAIN, TAG, `Deleting messages from UI: ${JSON.stringify(messageIds)}`);

    // ⭐ 优化：messageMap 已移除，直接从 DataSource 删除消息
    const originalCount = this.messageDataSource.getCount();
    this.messageDataSource.deleteMessages(messageIds);
    const newCount = this.messageDataSource.getCount();
    hilog.info(DOMAIN, TAG, `Messages deleted from dataSource: ${originalCount} -> ${newCount} (deleted ${originalCount - newCount})`);

    // ⭐ 修复：如果 oldestMessageId 被删除，从 DataSource 重新获取最早的消息 ID
    if (this.oldestMessageId > 0 && messageIds.indexOf(this.oldestMessageId) >= 0) {
      const allMessages = this.messageDataSource.getAllMessages();
      if (allMessages.length > 0) {
        // 消息按 ID 升序排列，第一个就是最旧的
        const newOldestId = allMessages[0].id;
        hilog.info(DOMAIN, TAG, `oldestMessageId ${this.oldestMessageId} was deleted, updating to ${newOldestId}`);
        this.oldestMessageId = newOldestId;
      } else {
        // 所有消息都被删除，重置状态
        this.oldestMessageId = 0;
        this.hasMoreMessages = true;
        hilog.info(DOMAIN, TAG, 'All messages deleted, resetting oldestMessageId and hasMoreMessages');
      }
    }

    // ⭐ 修复：当消息被删除后，恢复 hasMoreMessages 以便可以重试加载更早的消息
    if (!this.hasMoreMessages && newCount > 0) {
      // 如果之前 hasMoreMessages=false 是因为 TDLib 找不到被删除的 oldestMessageId，
      // 现在 oldestMessageId 已更新，可以重新尝试加载
      this.hasMoreMessages = true;
      hilog.info(DOMAIN, TAG, 'Recovering hasMoreMessages to true after message deletion');
    }
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
    this.refreshUI();
  };

  /**
   * ⭐ 处理用户头像下载完成事件
   * 当用户头像下载完成后，更新消息列表中对应发送者的头像
   */
  private handleCoreUserAvatarDownloaded = (data?: Object): void => {
    if (!data) return;
    const userId = (data as Record<string, Object>)['userId'] as number;
    const path = (data as Record<string, Object>)['path'] as string;
    
    if (!userId || !path) return;
    
    hilog.info(DOMAIN, TAG, `User avatar downloaded for user ${userId}, updating messages`);
    
    // 添加 file:// 前缀（如果缺少）
    let avatarPath = path;
    if (avatarPath && !avatarPath.startsWith('file://') && avatarPath.startsWith('/')) {
      avatarPath = 'file://' + avatarPath;
    }
    
    // 更新所有该用户发送的消息的头像
    let updated = false;
    const allMessages = this.messageDataSource.getAllMessages();
    for (const message of allMessages) {
      if (message.senderId === userId && !message.senderAvatar) {
        message.senderAvatar = avatarPath;
        this.messageDataSource.updateMessage(message);
        updated = true;
        hilog.info(DOMAIN, TAG, `Updated avatar for message ${message.id} from user ${userId}`);
      }
    }
    
    if (updated) {
      hilog.info(DOMAIN, TAG, `Updated avatar for user ${userId} in ${allMessages.length} messages`);
    }
  };

  private handleFileDownloadComplete = (data?: Object): void => {
    if (!data) {
      return;
    }
    const downloadData = data as DownloadCompleteData;
    const messages = this.messageDataSource.getAllMessages();
    let updated = false;
    
    for (let i = 0; i < messages.length; i++) {
      const msg = messages[i];
      if (msg.media?.tdlibFileId === downloadData.fileId && !msg.file?.path) {
        msg.file = {
          id: downloadData.fileId,
          remoteId: '',
          size: msg.media.size || 0,
          path: downloadData.localPath.startsWith('file://') ? downloadData.localPath : 'file://' + downloadData.localPath,
          mimeType: msg.media.mimeType,
          fileName: msg.media.fileName
        };
        this.messageDataSource.updateMessage(msg);
        updated = true;
        hilog.info(DOMAIN, TAG, `Updated file path for message ${msg.id}`);
      }
    }
    
    if (updated) {
      hilog.info(DOMAIN, TAG, `Updated ${updated} messages with downloaded file path`);
    }
  };

  // ==================== 消息列表操作（不可变更新） ====================
  private appendMessage(msg: Message): void {
    // 追加新消息到列表尾部（不限制缓存数量，保留所有消息）
    this.messageDataSource.appendMessages([msg]);
    // ⭐ 优化：messageMap 已移除，DataSource 是单一数据源
  }

  private replaceMessage(oldId: number, newMsg: Message): void {
    this.messageDataSource.replaceMessage(oldId, newMsg);
    // ⭐ 优化：messageMap 已移除，DataSource 是单一数据源
  }

  private updateMessage(updatedMsg: Message): void {
    this.messageDataSource.updateMessage(updatedMsg);
    // ⭐ 优化：messageMap 已移除，DataSource 是单一数据源
  }

  private refreshUI(): void {
    // 触发响应式更新 - MessageDataSource 会自动通知 UI 更新
    // 无需手动操作，IDataSource 接口会处理数据变化通知
  }

  // ==================== 事件注册/取消 ====================
  private registerEventListeners(): void {
    // ⭐ 使用 CoreService 领域事件替代 TDLib 原始事件
    this.eventBus.on('core:messageReceived', this.handleCoreNewMessage);
    this.eventBus.on('core:messageSent', this.handleCoreMessageSent);
    this.eventBus.on('core:messageFailed', this.handleCoreMessageFailed);
    this.eventBus.on('core:messageEdited', this.handleCoreMessageEdited);
    this.eventBus.on('core:messageDeleted', this.handleCoreMessageDeleted);
    this.eventBus.on('core:chatAction', this.handleCoreChatAction);
    // ⭐ 使用 CoreService 领域事件替代 TDLib 原始事件
    this.eventBus.on('core:fileDownloadProgress', this.handleCoreFileDownloadProgress);
    this.eventBus.on('core:connectionStateUpdated', this.handleCoreConnectionState);
    // ⭐ 监听用户头像下载完成事件（从 FileDownloadService）
    this.eventBus.on('file:userAvatarDownloaded', this.handleCoreUserAvatarDownloaded);
    // ⭐ Nagram 参考：监听批量更新事件（位掩码驱动增量刷新）
    this.eventBus.on('core:batchUpdate', this.handleBatchUpdate);
    
    // ⭐ 监听文件下载完成事件，更新消息对象的文件路径
    FileDownloadService.getInstance().on(DownloadEvent.COMPLETE, this.handleFileDownloadComplete);
  }

  private unregisterEventListeners(): void {
    this.eventBus.off('core:messageReceived', this.handleCoreNewMessage);
    this.eventBus.off('core:messageSent', this.handleCoreMessageSent);
    this.eventBus.off('core:messageFailed', this.handleCoreMessageFailed);
    this.eventBus.off('core:messageEdited', this.handleCoreMessageEdited);
    this.eventBus.off('core:messageDeleted', this.handleCoreMessageDeleted);
    this.eventBus.off('core:chatAction', this.handleCoreChatAction);
    this.eventBus.off('core:fileDownloadProgress', this.handleCoreFileDownloadProgress);
    this.eventBus.off('core:connectionStateUpdated', this.handleCoreConnectionState);
    // ⭐ 取消监听用户头像下载完成事件（从 FileDownloadService）
    this.eventBus.off('file:userAvatarDownloaded', this.handleCoreUserAvatarDownloaded);
    // ⭐ Nagram 参考：取消监听批量更新事件
    this.eventBus.off('core:batchUpdate', this.handleBatchUpdate);
    
    // ⭐ 取消监听文件下载完成事件
    FileDownloadService.getInstance().off(DownloadEvent.COMPLETE, this.handleFileDownloadComplete);
  }

}