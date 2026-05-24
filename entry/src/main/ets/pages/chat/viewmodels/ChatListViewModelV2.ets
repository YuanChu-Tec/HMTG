// ChatListViewModelV2.ets
// 重构后的聊天列表 ViewModel - 采用 Gramony-dev 架构模式

import { hilog } from '@kit.PerformanceAnalysisKit';
import { ChatListDataSource } from '../../../datasource/ChatListDataSource';
import { ChatEntity } from '@storage/cache';
import { CoreService } from '../../../services/business/CoreService';
import { eventBus } from '../../../utils/event/EventBus';
import { common } from '@kit.AbilityKit';
import { Chat, ChatType, MessageType, Message, MessageStatus, GroupEventType, UserInfo, UserStatus, ChatMemberStatus } from '../../../models/TDLibData';

const TAG = 'ChatListViewModelV2';
const DOMAIN = 0x0001;

export interface ChatItemDisplay {
  id: string;
  title: string;
  avatar: string;
  lastMessage: string;
  lastMessageTime: string;
  unreadCount: number;
  isPinned: boolean;
  isMuted: boolean;
  isSecret: boolean;
  isOnline: boolean;
  isVerified: boolean;
  isBot: boolean;
  hasDraft: boolean;
  type: string;
  order?: number; // TDLib 排序顺序
  senderName?: string;
  isOutgoing?: boolean;
  isMarkedAsUnread?: boolean;
  hasMention?: boolean;
  isArchived?: boolean;
  hasUnreadMention?: boolean; // 是否有未读的提及
  messageTtlSetting?: number; // 消息自动删除设置(秒)
  readStatus?: 'none' | 'sent' | 'delivered' | 'read'; // 消息已读状态
}

export class ChatListViewModelV2 {
  isLoading: boolean = true;
  errorMessage: string = '';
  searchKeyword: string = '';
  filterType: 'all' | 'pinned' | 'unread' | 'muted' = 'all';

  // 核心：DataSource 管理数据
  chatListDataSource: ChatListDataSource;

  // ====== 批量选择模式 ======
  isSelectionMode: boolean = false;
  selectedChatIds: number[] = [];
  hasMoreChats: boolean = true;
  isLoadingMore: boolean = false;

  private coreService: CoreService;
  private context: common.UIAbilityContext;

  // 事件订阅句柄
  private unsubscribeChatListChanged?: () => void;
  private unsubscribeCoreReady?: () => void;
  private unsubscribeUserUpdated?: () => void;
  private unsubscribeUserStatusUpdated?: () => void;
  private unsubscribeAvatarDownloaded?: () => void;
  private unsubscribeMessageReceived?: () => void; // ⭐ 新增：直接监听新消息
  private unsubscribeMessageSent?: () => void;     // ⭐ 新增：直接监听发送消息

  // 同步防抖计时器
  private syncDebounceTimer: number = -1;
  // 同步间隔（毫秒）
  private readonly SYNC_DEBOUNCE_INTERVAL = 100;

  // ⭐ 快速更新防抖（用于新消息实时更新）
  private fastUpdateDebounceTimer: number = -1;
  private readonly FAST_UPDATE_INTERVAL = 50; // 50ms 快速更新间隔
  private pendingFastUpdateChatIds: Set<number> = new Set(); // 待快速更新的聊天ID

  constructor(context: common.UIAbilityContext) {
    this.context = context;
    this.coreService = CoreService.getInstance();
    this.chatListDataSource = new ChatListDataSource(context);

    this.setupEventListeners();
    this.initialize();

    hilog.info(DOMAIN, TAG, '✅ ChatListViewModelV2 created');
  }

  /**
   * 初始化 - 从缓存加载数据
   * 优化策略：分阶段加载，优先显示缓存，后台同步
   */
  async initialize(): Promise<void> {
    this.isLoading = true;
    try {
      // 阶段1：从缓存加载（快速显示）
      await this.chatListDataSource.loadFromCache();

      // ⭐ 关键修复：立即过滤掉非成员聊天（数据库缓存可能没有成员状态）
      await this.filterNonMemberChats();

      // 阶段2：后台同步 CoreService 数据（不阻塞UI）
      this.syncWithCoreServiceInBackground();

      hilog.info(DOMAIN, TAG, `✅ Initialized with ${this.chatListDataSource.totalCount()} chats`);
    } catch (error) {
      this.errorMessage = '加载聊天列表失败';
      hilog.error(DOMAIN, TAG, `❌ Initialize failed: ${error}`);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * ⭐ 关键修复：过滤掉非成员聊天
   * 数据库缓存的 ChatEntity 没有成员状态，需要根据 CoreService 的 Chat 列表过滤
   */
  private async filterNonMemberChats(): Promise<void> {
    const coreChats = this.coreService.getAllChats();
    const coreChatIds = new Set(coreChats.map(c => c.id));

    // 获取当前 DataSource 中的所有聊天
    const allEntities = this.chatListDataSource.getAll();
    let removedCount = 0;

    for (const entity of allEntities) {
      if (!coreChatIds.has(entity.chatId)) {
        // 这个聊天不在 CoreService 的有效列表中，删除它
        await this.chatListDataSource.delete(entity.chatId);
        removedCount++;
        hilog.debug(DOMAIN, TAG, `Removed non-member chat ${entity.chatId} (${entity.title}) from DataSource`);
      }
    }

    if (removedCount > 0) {
      hilog.info(DOMAIN, TAG, `🧹 Filtered out ${removedCount} non-member chats from cache`);
    }
  }

  /**
   * 清理资源
   */
  aboutToDisappear(): void {
    this.unsubscribeChatListChanged?.();
    this.unsubscribeCoreReady?.();
    this.unsubscribeUserUpdated?.();
    this.unsubscribeUserStatusUpdated?.();
    this.unsubscribeAvatarDownloaded?.();
    this.unsubscribeMessageReceived?.(); // ⭐ 清理新消息监听
    this.unsubscribeMessageSent?.();     // ⭐ 清理发送消息监听
    // 清理同步防抖计时器
    if (this.syncDebounceTimer !== -1) {
      clearTimeout(this.syncDebounceTimer);
      this.syncDebounceTimer = -1;
    }
    // ⭐ 清理快速更新防抖
    if (this.fastUpdateDebounceTimer !== -1) {
      clearTimeout(this.fastUpdateDebounceTimer);
      this.fastUpdateDebounceTimer = -1;
    }
    hilog.info(DOMAIN, TAG, '✅ ChatListViewModelV2 destroyed');
  }

  // ========== 事件监听 ==========

  private setupEventListeners(): void {
    // 聊天列表变化
    this.unsubscribeChatListChanged = eventBus.on('chatListChanged', () => {
      hilog.debug(DOMAIN, TAG, 'chatListChanged received');
      this.syncWithCoreServiceInBackground();
    });

    // CoreService 就绪
    this.unsubscribeCoreReady = eventBus.on('CoreServiceReady', () => {
      hilog.info(DOMAIN, TAG, 'CoreServiceReady received');
      this.isLoading = false;
      this.syncWithCoreServiceInBackground();
    });

    // 用户信息更新
    this.unsubscribeUserUpdated = eventBus.on('core:userUpdated', (data?: Object) => {
      if (!data) return;
      const userId = (data as Record<string, Object>)['userId'] as number;
      if (userId) {
        hilog.debug(DOMAIN, TAG, `core:userUpdated for user ${userId}`);
        this.refreshChatsByUserId(userId);
      }
    });

    // 用户在线状态更新
    this.unsubscribeUserStatusUpdated = eventBus.on('core:userStatusUpdated', (data?: Object) => {
      if (!data) return;
      const userId = (data as Record<string, Object>)['userId'] as number;
      if (userId) {
        hilog.debug(DOMAIN, TAG, `core:userStatusUpdated for user ${userId}`);
        this.refreshChatsByUserId(userId);
      }
    });

    // 头像下载完成
    this.unsubscribeAvatarDownloaded = eventBus.on('core:avatarDownloaded', (data?: Object) => {
      if (!data) return;
      const chatId = (data as Record<string, Object>)['chatId'] as number | undefined;
      if (chatId) {
        this.refreshChat(chatId);
      } else {
        this.syncWithCoreServiceInBackground();
      }
    });

    // ⭐ 优化：直接监听新消息，快速更新 DataSource
    this.unsubscribeMessageReceived = eventBus.on('core:messageReceived', (data?: Object) => {
      if (!data) return;
      const chatId = (data as Record<string, Object>)['chatId'] as number;
      if (chatId) {
        this.scheduleFastUpdate(chatId);
      }
    });

    // ⭐ 优化：直接监听发送消息，快速更新 DataSource
    this.unsubscribeMessageSent = eventBus.on('core:messageSent', (data?: Object) => {
      if (!data) return;
      const chatId = (data as Record<string, Object>)['chatId'] as number;
      if (chatId) {
        this.scheduleFastUpdate(chatId);
      }
    });
  }

  // ⭐ 优化：快速更新指定聊天（50ms 防抖）
  private scheduleFastUpdate(chatId: number): void {
    this.pendingFastUpdateChatIds.add(chatId);

    if (this.fastUpdateDebounceTimer !== -1) {
      clearTimeout(this.fastUpdateDebounceTimer);
    }

    this.fastUpdateDebounceTimer = setTimeout(() => {
      this.flushFastUpdates();
      this.fastUpdateDebounceTimer = -1;
    }, this.FAST_UPDATE_INTERVAL);
  }

  // ⭐ 优化：执行快速更新
  private async flushFastUpdates(): Promise<void> {
    if (this.pendingFastUpdateChatIds.size === 0) return;

    const chatIds = Array.from(this.pendingFastUpdateChatIds);
    this.pendingFastUpdateChatIds.clear();

    hilog.debug(DOMAIN, TAG, `🚀 Fast updating ${chatIds.length} chats`);

    for (const chatId of chatIds) {
      try {
        const chat = this.coreService.getChat(chatId);
        if (!chat || !this.shouldShowChat(chat)) continue;

        const entity = this.convertToEntity(chat);
        const existing = this.chatListDataSource.get(chatId);

        if (existing) {
          // 检查是否有实质性变化
          if (this.hasChatChanged(existing, entity)) {
            await this.chatListDataSource.modify(entity);
            hilog.debug(DOMAIN, TAG, `✅ Fast updated chat ${chatId}`);
          }
        } else {
          // 新聊天，添加到列表
          await this.chatListDataSource.add(entity);
          hilog.debug(DOMAIN, TAG, `✅ Fast added new chat ${chatId}`);
        }
      } catch (error) {
        hilog.warn(DOMAIN, TAG, `Failed to fast update chat ${chatId}: ${error}`);
      }
    }
  }

  // ========== 数据同步 ==========

  /**
   * 后台同步 CoreService 数据（不阻塞UI）
   */
  private syncWithCoreServiceInBackground(): void {
    // 防抖处理：避免频繁同步
    if (this.syncDebounceTimer !== -1) {
      clearTimeout(this.syncDebounceTimer);
    }

    this.syncDebounceTimer = setTimeout(() => {
      this.doSyncWithCoreService().catch((error: Error) => {
        hilog.warn(DOMAIN, TAG, `Background sync failed: ${error.message}`);
      });
      this.syncDebounceTimer = -1;
    }, this.SYNC_DEBOUNCE_INTERVAL);
  }

  /**
   * 实际执行同步（批量处理）
   */
  private async doSyncWithCoreService(): Promise<void> {
    const allChats = this.coreService.getAllChats();
    hilog.debug(DOMAIN, TAG, `Syncing ${allChats.length} chats from CoreService`);

    // 批量收集需要添加和更新的聊天
    const chatsToAdd: ChatEntity[] = [];
    const chatsToUpdate: ChatEntity[] = [];
    let filteredCount = 0;

    for (const chat of allChats) {
      // ⭐ 关键修复：使用 shouldShowChat 过滤不应该显示的聊天
      if (!this.shouldShowChat(chat)) {
        filteredCount++;
        continue;
      }

      const entity = this.convertToEntity(chat);
      const existing = this.chatListDataSource.get(chat.id);

      if (existing) {
        // 检查是否有实质性变化，避免不必要的更新
        if (this.hasChatChanged(existing, entity)) {
          chatsToUpdate.push(entity);
        }
      } else {
        chatsToAdd.push(entity);
      }
    }

    if (filteredCount > 0) {
      hilog.debug(DOMAIN, TAG, `Filtered out ${filteredCount} chats that should not be displayed`);
    }

    // 批量执行添加和更新
    if (chatsToAdd.length > 0) {
      await this.chatListDataSource.addBatch(chatsToAdd);
      hilog.debug(DOMAIN, TAG, `Batch added ${chatsToAdd.length} chats`);
    }

    if (chatsToUpdate.length > 0) {
      await this.chatListDataSource.modifyBatch(chatsToUpdate);
      hilog.debug(DOMAIN, TAG, `Batch updated ${chatsToUpdate.length} chats`);
    }
  }

  /**
   * 检查聊天数据是否有实质性变化
   */
  private hasChatChanged(existing: ChatEntity, newEntity: ChatEntity): boolean {
    return existing.lastMessageId !== newEntity.lastMessageId ||
           existing.lastMessageDate !== newEntity.lastMessageDate ||
           existing.unreadCount !== newEntity.unreadCount ||
           existing.title !== newEntity.title ||
           existing.photoJson !== newEntity.photoJson;
  }

  /**
   * ⭐ 关键修复：检查聊天是否应该显示在列表中
   * 根据 TDLib 文档，只显示用户当前是成员的聊天
   */
  private shouldShowChat(chat: Chat): boolean {
    // 1. 已归档的聊天不显示在主列表
    if (chat.isArchived) return false;

    // 2. 对于群组/超级群组/频道，检查成员状态
    // 只有明确知道用户已离开或被禁言时才过滤
    // 无状态或有效状态都允许显示
    if (chat.type === ChatType.GROUP || chat.type === ChatType.SUPERGROUP || chat.type === ChatType.CHANNEL) {
      if (chat.memberStatus) {
        const invalidStatuses = ['left', 'banned'];
        if (invalidStatuses.includes(chat.memberStatus.type)) {
          hilog.debug(DOMAIN, TAG, `Filtering out chat ${chat.id} (${chat.title}) - status: ${chat.memberStatus.type}`);
          return false;
        }
      }
    }

    return true;
  }

  /**
   * 刷新指定聊天
   */
  private async refreshChat(chatId: number): Promise<void> {
    const chat = this.coreService.getChat(chatId);
    if (!chat || chat.isArchived) return;

    const entity = this.convertToEntity(chat);
    await this.chatListDataSource.modify(entity);
  }

  /**
   * 根据用户 ID 刷新相关聊天
   */
  private async refreshChatsByUserId(userId: number): Promise<void> {
    // 获取所有聊天并筛选
    const allChats = this.coreService.getAllChats();
    for (const chat of allChats) {
      if (chat.userId === userId && this.shouldShowChat(chat)) {
        await this.refreshChat(chat.id);
      }
    }
  }

  // ========== 用户交互 ==========

  /**
   * 设置搜索关键词
   */
  setSearchKeyword(keyword: string): void {
    this.searchKeyword = keyword;
    // 搜索过滤由 UI 层处理
  }

  /**
   * 设置筛选类型
   */
  setFilterType(type: 'all' | 'pinned' | 'unread' | 'muted'): void {
    this.filterType = type;
    // 筛选过滤由 UI 层处理
  }

  /**
   * 置顶/取消置顶聊天
   */
  async togglePinChat(chatId: number, isPinned: boolean): Promise<void> {
    const chat = this.chatListDataSource.get(chatId);
    if (chat) {
      chat.isPinned = isPinned;
      await this.chatListDataSource.modify(chat);
      
      // 同步到服务器
      await this.coreService.setPinned(chatId, isPinned);
    }
  }

  /**
   * 标记已读/未读
   */
  async toggleMarkAsUnread(chatId: number, isUnread: boolean): Promise<void> {
    if (isUnread) {
      await this.coreService.markAsUnread(chatId);
    } else {
      // 标记为已读，使用 markAsRead 方法
      await this.coreService.markAsRead(chatId);
    }
    await this.refreshChat(chatId);
  }

  /**
   * 静音/取消静音
   */
  async toggleMuteChat(chatId: number, isMuted: boolean, muteUntil?: number): Promise<void> {
    await this.coreService.setMuted(chatId, isMuted, muteUntil);
    await this.refreshChat(chatId);
  }

  /**
   * 归档聊天
   */
  async archiveChat(chatId: number): Promise<void> {
    await this.coreService.archiveChat(chatId);
    await this.chatListDataSource.delete(chatId);
  }

  /**
   * 删除聊天
   */
  async deleteChat(chatId: number): Promise<void> {
    await this.chatListDataSource.delete(chatId);
    await this.coreService.deleteChat(chatId);
  }

  /**
   * 加载更多聊天（分页加载）
   */
  async loadMoreChats(): Promise<void> {
    if (!this.hasMoreChats || this.isLoadingMore) {
      hilog.debug(DOMAIN, TAG, 'Skip loading more chats');
      return;
    }

    this.isLoadingMore = true;
    try {
      const hasMore = await this.coreService.loadMoreChats(50);
      this.hasMoreChats = hasMore;
      // 使用后台同步，不阻塞UI
      this.syncWithCoreServiceInBackground();
      hilog.info(DOMAIN, TAG, `Loaded more chats, hasMore=${hasMore}`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to load more chats: ${error}`);
    } finally {
      this.isLoadingMore = false;
    }
  }

  // ========== 批量选择操作 ==========

  /**
   * 进入批量选择模式
   */
  enterSelectionMode(chatId: number): void {
    this.isSelectionMode = true;
    this.selectedChatIds = [chatId];
    hilog.debug(DOMAIN, TAG, `Enter selection mode with chat ${chatId}`);
  }

  /**
   * 退出批量选择模式
   */
  exitSelectionMode(): void {
    this.isSelectionMode = false;
    this.selectedChatIds = [];
    hilog.debug(DOMAIN, TAG, 'Exit selection mode');
  }

  /**
   * 切换聊天选择状态
   */
  toggleSelectChat(chatId: number): void {
    const index = this.selectedChatIds.indexOf(chatId);
    if (index > -1) {
      this.selectedChatIds.splice(index, 1);
      // 如果没有选中任何聊天，自动退出选择模式
      if (this.selectedChatIds.length === 0) {
        this.exitSelectionMode();
      }
    } else {
      this.selectedChatIds.push(chatId);
    }
    hilog.debug(DOMAIN, TAG, `Toggle select chat ${chatId}, selected count: ${this.selectedChatIds.length}`);
  }

  /**
   * 检查聊天是否被选中
   */
  isSelected(chatId: number): boolean {
    return this.selectedChatIds.includes(chatId);
  }

  /**
   * 获取选中数量
   */
  get selectedCount(): number {
    return this.selectedChatIds.length;
  }

  /**
   * 清空选择
   */
  clearSelection(): void {
    this.selectedChatIds = [];
    hilog.debug(DOMAIN, TAG, 'Clear selection');
  }

  // ========== 批量操作 ==========

  /**
   * 批量置顶
   */
  async batchPin(): Promise<void> {
    hilog.info(DOMAIN, TAG, `Batch pin ${this.selectedChatIds.length} chats`);
    for (const chatId of this.selectedChatIds) {
      try {
        await this.togglePinChat(chatId, true);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Failed to pin chat ${chatId}: ${error}`);
      }
    }
    this.exitSelectionMode();
  }

  /**
   * 批量取消置顶
   */
  async batchUnpin(): Promise<void> {
    hilog.info(DOMAIN, TAG, `Batch unpin ${this.selectedChatIds.length} chats`);
    for (const chatId of this.selectedChatIds) {
      try {
        await this.togglePinChat(chatId, false);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Failed to unpin chat ${chatId}: ${error}`);
      }
    }
    this.exitSelectionMode();
  }

  /**
   * 批量静音
   */
  async batchMute(muteUntil?: number): Promise<void> {
    hilog.info(DOMAIN, TAG, `Batch mute ${this.selectedChatIds.length} chats`);
    for (const chatId of this.selectedChatIds) {
      try {
        await this.toggleMuteChat(chatId, true, muteUntil);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Failed to mute chat ${chatId}: ${error}`);
      }
    }
    this.exitSelectionMode();
  }

  /**
   * 批量取消静音
   */
  async batchUnmute(): Promise<void> {
    hilog.info(DOMAIN, TAG, `Batch unmute ${this.selectedChatIds.length} chats`);
    for (const chatId of this.selectedChatIds) {
      try {
        await this.toggleMuteChat(chatId, false);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Failed to unmute chat ${chatId}: ${error}`);
      }
    }
    this.exitSelectionMode();
  }

  /**
   * 批量归档
   */
  async batchArchive(): Promise<void> {
    hilog.info(DOMAIN, TAG, `Batch archive ${this.selectedChatIds.length} chats`);
    for (const chatId of this.selectedChatIds) {
      try {
        await this.archiveChat(chatId);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Failed to archive chat ${chatId}: ${error}`);
      }
    }
    this.exitSelectionMode();
  }

  /**
   * 批量标记已读
   */
  async batchMarkAsRead(): Promise<void> {
    hilog.info(DOMAIN, TAG, `Batch mark as read ${this.selectedChatIds.length} chats`);
    for (const chatId of this.selectedChatIds) {
      try {
        await this.toggleMarkAsUnread(chatId, false);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Failed to mark chat ${chatId} as read: ${error}`);
      }
    }
    this.exitSelectionMode();
  }

  /**
   * 批量标记未读
   */
  async batchMarkAsUnread(): Promise<void> {
    hilog.info(DOMAIN, TAG, `Batch mark as unread ${this.selectedChatIds.length} chats`);
    for (const chatId of this.selectedChatIds) {
      try {
        await this.toggleMarkAsUnread(chatId, true);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Failed to mark chat ${chatId} as unread: ${error}`);
      }
    }
    this.exitSelectionMode();
  }

  /**
   * 批量删除
   */
  async batchDelete(): Promise<void> {
    hilog.info(DOMAIN, TAG, `Batch delete ${this.selectedChatIds.length} chats`);
    for (const chatId of this.selectedChatIds) {
      try {
        await this.deleteChat(chatId);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Failed to delete chat ${chatId}: ${error}`);
      }
    }
    this.clearSelection();
  }

  // ========== Getter 供 UI 绑定 ==========

  /**
   * 获取聊天列表（已过滤和排序）
   * 供 UI 直接绑定使用
   */
  get chatItems(): ChatItemDisplay[] {
    return this.getFilteredChats();
  }

  /**
   * 是否显示批量操作栏
   */
  get showBatchActions(): boolean {
    return this.selectedChatIds.length > 0;
  }

  // ========== 工具方法 ==========

  /**
   * 转换为显示格式（供 UI 层使用）
   */
  public toChatItemDisplay(entity: ChatEntity): ChatItemDisplay {
    const chat = this.coreService.getChat(entity.chatId);
    
    // 处理头像路径，确保格式正确
    let avatarPath = chat?.avatar || '';
    if (avatarPath && !avatarPath.startsWith('file://') && avatarPath.startsWith('/')) {
      avatarPath = 'file://' + avatarPath;
    }

    // 判断是否为机器人（私聊且对方是机器人）
    const isBot = chat?.type === ChatType.PRIVATE && chat?.userId ?
      this.coreService.getCachedUserInfo(chat.userId)?.isBot || false : false;
    
    // ⭐ 关键修复：统一使用秒级时间戳
    // Chat.lastMessage?.timestamp 和 Chat.timestamp 是毫秒（TDLib 原始数据）
    // ChatEntity.lastMessageDate 是秒（数据库存储）
    // formatTime 期望秒级时间戳
    let lastMessageTimestamp: number;
    if (chat?.lastMessage?.timestamp) {
      // 优先使用最后消息的毫秒时间戳，转换为秒
      lastMessageTimestamp = Math.floor(chat.lastMessage.timestamp / 1000);
    } else if (chat?.timestamp) {
      // 其次使用聊天的毫秒时间戳，转换为秒
      lastMessageTimestamp = Math.floor(chat.timestamp / 1000);
    } else {
      // 最后使用 entity 的秒级时间戳（已经是秒，无需转换）
      lastMessageTimestamp = entity.lastMessageDate || 0;
    }
    
    return {
      id: entity.chatId.toString(),
      title: entity.title || 'Unknown',
      avatar: avatarPath,
      lastMessage: this.formatLastMessage(chat),
      lastMessageTime: this.formatTime(lastMessageTimestamp),
      unreadCount: chat?.unreadCount || entity.unreadCount || 0,
      isPinned: entity.isPinned,
      isMuted: entity.isMuted,
      isSecret: chat?.type === ChatType.SECRET,
      isOnline: this.isUserOnline(chat),
      isVerified: chat?.isVerified || false,
      isBot: isBot,
      hasDraft: !!(chat?.draftMessage?.text),
      type: entity.type || 'private',
      order: chat?.order, // TDLib 排序顺序
      senderName: chat?.lastMessage?.senderName,
      isOutgoing: chat?.lastMessage?.isOutgoing,
      isMarkedAsUnread: chat?.isMarkedAsUnread || false,
      hasMention: chat?.unreadMentionCount ? chat.unreadMentionCount > 0 : false,
      isArchived: chat?.isArchived || false,
      hasUnreadMention: chat?.unreadMentionCount ? chat.unreadMentionCount > 0 : false,
      messageTtlSetting: chat?.messageTtlSetting,
      readStatus: this.getReadStatus(chat)
    };
  }

  /**
   * 获取过滤后的聊天列表（供 UI 使用）
   */
  getFilteredChats(): ChatItemDisplay[] {
    const result: ChatItemDisplay[] = [];
    const total = this.chatListDataSource.totalCount();

    for (let i = 0; i < total; i++) {
      const entity = this.chatListDataSource.getData(i);
      const display = this.toChatItemDisplay(entity);

      // 应用搜索过滤
      if (this.searchKeyword.trim()) {
        const kw = this.searchKeyword.toLowerCase();
        if (!display.title.toLowerCase().includes(kw)) {
          continue;
        }
      }

      // 应用类型筛选
      switch (this.filterType) {
        case 'pinned':
          if (!display.isPinned) continue;
          break;
        case 'unread':
          if (display.unreadCount === 0) continue;
          break;
        case 'muted':
          if (!display.isMuted) continue;
          break;
      }

      result.push(display);
    }

    return result;
  }

  // ========== 私有方法 ==========

  private convertToEntity(chat: Chat): ChatEntity {
    const entity = new ChatEntity();
    entity.chatId = chat.id;
    entity.title = chat.title || '';
    entity.type = chat.type || 'private';
    entity.lastMessageId = chat.lastMessage?.id || 0;
    // ⭐ 关键修复：ChatEntity.lastMessageDate 存储秒级时间戳
    const timestampMs = chat.lastMessage?.timestamp || chat.timestamp || 0;
    entity.lastMessageDate = timestampMs > 0 ? Math.floor(timestampMs / 1000) : 0;
    entity.unreadCount = chat.unreadCount || 0;
    entity.isPinned = chat.isPinned || false;
    entity.isMuted = chat.isMuted || false;
    entity.draftMessage = chat.draftMessage ? chat.draftMessage.text : '';
    // 注意：ChatEntity 没有 isArchived 字段，归档状态通过其他方式处理
    return entity;
  }

  private formatLastMessage(chat: Chat | undefined): string {
    if (!chat?.lastMessage) return '';
    const msg = chat.lastMessage;

    // 构建前缀（发送者名称）
    let prefix = '';
    if (chat.type === ChatType.GROUP || chat.type === ChatType.SUPERGROUP) {
      if (!msg.isOutgoing && msg.senderName) {
        prefix = `${msg.senderName}: `;
      }
    } else if (chat.type === ChatType.CHANNEL && msg.senderName) {
      prefix = `${msg.senderName}: `;
    }

    // 根据消息类型显示不同内容
    const content = this.formatMessageContent(msg);
    return prefix + content;
  }

  private formatMessageContent(msg: Message): string {
    switch (msg.type) {
      case MessageType.TEXT:
        return typeof msg.content === 'string' ? msg.content : (msg.content?.text || '');
      case MessageType.PHOTO:
        return '[照片]';
      case MessageType.VIDEO:
        return msg.duration ? `[视频 ${this.formatDuration(msg.duration)}]` : '[视频]';
      case MessageType.VOICE_NOTE:
        return msg.duration ? `[语音 ${this.formatDuration(msg.duration)}]` : '[语音]';
      case MessageType.DOCUMENT:
        return msg.file?.fileName ? `[文件] ${msg.file.fileName}` : '[文件]';
      case MessageType.STICKER:
        return '[贴纸]';
      case MessageType.ANIMATION:
        return '[GIF]';
      case MessageType.AUDIO:
        return msg.duration ? `[音频 ${this.formatDuration(msg.duration)}]` : '[音频]';
      case MessageType.VIDEO_NOTE:
        return msg.duration ? `[视频笔记 ${this.formatDuration(msg.duration)}]` : '[视频笔记]';
      case MessageType.LOCATION:
        return msg.location?.title ? `📍 ${msg.location.title}` : '[位置]';
      case MessageType.CONTACT:
        const contactName = msg.contact ? `${msg.contact.firstName || ''} ${msg.contact.lastName || ''}`.trim() : '';
        return contactName ? `[联系人] ${contactName}` : '[联系人]';
      case MessageType.POLL:
        return msg.poll?.question ? `📊 [投票] ${msg.poll.question}` : '📊 [投票]';
      case MessageType.GAME:
        return '🎮 [游戏]';
      case MessageType.SYSTEM:
        // 服务消息：直接使用提取的文本（已包含 ℹ️ 等图标）
        return typeof msg.content === 'string' ? msg.content : 'ℹ️ 系统消息';
      case MessageType.GROUP_EVENT:
        // 群组事件：生成事件描述文本
        return this.getGroupEventPreview(msg);
      default:
        return '[消息]';
    }
  }

  /**
   * 获取群组事件预览文本（用于群组事件消息）
   */
  private getGroupEventPreview(message: Message | undefined): string {
    if (!message || message.type !== MessageType.GROUP_EVENT || !message.groupEventType) {
      return 'ℹ️ 系统消息';
    }

    const data = message.groupEventData;
    const userName = data?.userName || '用户';
    const adminName = data?.adminName || '管理员';

    switch (message.groupEventType) {
      case GroupEventType.MEMBER_JOINED:
        return `ℹ️ ${userName} 加入了群组`;
      case GroupEventType.MEMBER_LEFT:
        return `ℹ️ ${userName} 退出了群组`;
      case GroupEventType.MEMBER_REMOVED:
        return `ℹ️ ${userName} 被移除`;
      case GroupEventType.ADMIN_PROMOTED:
        return `ℹ️ ${userName} 被设为管理员`;
      case GroupEventType.GROUP_CREATED:
        return `ℹ️ ${userName} 创建了群组`;
      case GroupEventType.GROUP_UPGRADED:
        return 'ℹ️ 群组已升级为超级群组';
      case GroupEventType.GROUP_RENAMED:
        return `ℹ️ 群组名称已更改为 "${data?.newTitle || ''}"`;
      case GroupEventType.GROUP_PHOTO_CHANGED:
        return 'ℹ️ 群组头像已更新';
      case GroupEventType.MESSAGE_PINNED:
        return `ℹ️ ${adminName} 置顶了一条消息`;
      case GroupEventType.SLOW_MODE_ENABLED:
        return 'ℹ️ 慢速模式已开启';
      case GroupEventType.RESTRICTED_MODE_ENABLED:
        return 'ℹ️ 仅管理员可发送消息';
      case GroupEventType.MEMBER_RESTRICTED:
        if (data?.isRestricted) {
          const until = data?.restrictedUntil ? 
            new Date(data.restrictedUntil * 1000).toLocaleString() : '';
          return until ? `ℹ️ ${userName} 被禁言至 ${until}` : `ℹ️ ${userName} 被禁言`;
        } else {
          return `ℹ️ ${userName} 的禁言已解除`;
        }
      default:
        return 'ℹ️ 系统消息';
    }
  }

  private formatDuration(seconds: number): string {
    if (!seconds || seconds <= 0) return '';
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }

  /**
   * 检查用户是否在线
   */
  private isUserOnline(chat: Chat | undefined): boolean {
    if (chat?.type !== ChatType.PRIVATE) return false;
    const status = chat?.userStatus;
    if (!status) return false;
    // 检查用户状态类型，判断是否在线
    const typeValue = this.getUserStatusType(status);
    if (typeValue === 'userStatusOnline') return true;
    // 如果状态类型为空，检查 expires 字段判断是否在有效期内
    const expires = status.expires;
    if (expires && expires > Date.now() / 1000) return true;
    return false;
  }

  /**
   * 获取用户状态类型的辅助函数
   */
  private getUserStatusType(status: UserStatus): string {
    const statusJson = JSON.stringify(status);
    const statusObj = JSON.parse(statusJson) as Record<string, Object>;
    return statusObj['@type'] as string;
  }

  /**
   * 获取消息已读状态（用于私聊）
   */
  private getReadStatus(chat: Chat | undefined): 'none' | 'sent' | 'delivered' | 'read' {
    // 只有私聊且是自己发送的消息才显示已读状态
    if (chat?.type !== ChatType.PRIVATE || !chat?.lastMessage || !chat?.lastMessage.isOutgoing) {
      return 'none';
    }
    
    // 根据消息状态判断
    const status = chat.lastMessage.status;
    switch (status) {
      case MessageStatus.SENDING:
        return 'none';
      case MessageStatus.SENT:
        return 'sent';
      case MessageStatus.DELIVERED:
        return 'delivered';
      case MessageStatus.READ:
        return 'read';
      default:
        return 'none';
    }
  }

  private formatTime(timestamp: number): string {
    if (!timestamp) return '';
    const date = new Date(timestamp * 1000);
    const now = new Date();
    
    // 格式化时间为 24 小时制 HH:mm
    const formatTime24 = (d: Date): string => {
      const hours = d.getHours().toString().padStart(2, '0');
      const minutes = d.getMinutes().toString().padStart(2, '0');
      return `${hours}:${minutes}`;
    };
    
    if (date.toDateString() === now.toDateString()) {
      return formatTime24(date);
    }
    
    const yesterday = new Date(now);
    yesterday.setDate(yesterday.getDate() - 1);
    if (date.toDateString() === yesterday.toDateString()) {
      return '昨天';
    }
    
    return date.toLocaleDateString('zh-CN', { month: 'short', day: 'numeric' });
  }
}

export default ChatListViewModelV2;
