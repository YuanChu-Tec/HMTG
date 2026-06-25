/**
 * 聊天列表 ViewModel
 * 职责：
 * - 订阅 CoreService 的业务事件，转换为 UI 显示数据
 * - 管理 UI 状态（搜索、筛选、批量选择、加载状态）
 * - 处理用户交互，调用 CoreService 执行操作
 * - 不直接操作数据库或 TDLib
 * 
 * ⭐ 架构优化：使用 ChatListDataSource 作为单一数据源，遵循单一数据源原则
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Chat, ChatType, MessageType, MessageStatus, GroupEventType, Message, UserInfo, UserStatus, UserStatusOnline } from '../models/TDLibData';
import { CoreService } from '../services/business/CoreService';
import { EventBus } from '../utils/event/EventBus';

const TAG = 'ChatListViewModel';
const DOMAIN = 0x0001;

/**
 * ⭐ 列表项类型：聊天项或分隔线
 * 导出供 ChatListPage 使用
 */
export interface ListItem {
  kind: 'chat' | 'divider';
  data?: ChatItemDisplay;
}

/**
 * ⭐ 聊天列表数据源 - 实现 IDataSource 接口供 LazyForEach 使用
 * 这是华为 ArkUI 列表惰性加载的最佳实践
 * 优化：从 ChatListPage 迁移到 ViewModel，遵循单一数据源原则
 */
export class ChatListDataSource implements IDataSource {
  private data: ListItem[] = [];
  private listeners: DataChangeListener[] = [];

  constructor(data: ChatItemDisplay[] = []) {
    this.updateData(data);
  }

  /**
   * 更新数据（复用实例，避免 LazyForEach 重复渲染）
   * ⭐ 关键：对数据进行去重，确保每个聊天只出现一次
   * ⭐ 支持分组分隔线：在置顶和非置顶聊天之间插入分隔线项
   */
  updateData(newData: ChatItemDisplay[]): void {
    // 去重：使用 Map 确保每个 id 只保留一个聊天项
    const uniqueMap = new Map<string, ChatItemDisplay>();
    for (const item of newData) {
      uniqueMap.set(item.id, item);
    }
    const uniqueItems = Array.from(uniqueMap.values());

    // ⭐ 检查是否需要分组分隔线（同时存在置顶和非置顶聊天）
    const hasPinned = uniqueItems.some((c: ChatItemDisplay) => c.isPinned);
    const hasNormal = uniqueItems.some((c: ChatItemDisplay) => !c.isPinned);
    const needsDivider = hasPinned && hasNormal;

    // ⭐ 构建带分隔线的数据列表
    const result: ListItem[] = [];
    let hasAddedDivider = false;

    for (const item of uniqueItems) {
      // 在第一个非置顶聊天前插入分隔线
      if (needsDivider && !hasAddedDivider && !item.isPinned) {
        // 插入分隔线项
        const dividerItem: ListItem = { kind: 'divider' };
        result.push(dividerItem);
        hasAddedDivider = true;
      }
      const chatItem: ListItem = { kind: 'chat', data: item };
      result.push(chatItem);
    }

    this.data = result;
    this.notifyDataReload();
  }

  totalCount(): number {
    return this.data.length;
  }

  getData(index: number): ListItem {
    return this.data[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) === -1) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.listeners.indexOf(listener);
    if (index !== -1) {
      this.listeners.splice(index, 1);
    }
  }

  // 数据变更通知方法
  notifyDataReload(): void {
    this.listeners.forEach(listener => listener.onDataReloaded());
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => listener.onDataAdd(index));
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => listener.onDataChange(index));
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => listener.onDataDelete(index));
  }
}

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
  isBot: boolean; // ⭐ 是否为机器人
  hasDraft: boolean;
  type: ChatType; // ⭐ 改为 ChatType 类型，确保类型一致
  order?: number; // TDLib 排序顺序
  senderName?: string; // ⭐ 发送者名称（用于群组/频道显示蓝色）
  isOutgoing?: boolean; // ⭐ 是否是自己发送的消息
  isMarkedAsUnread?: boolean; // ⭐ 是否标记为未读
  // ⭐ 新增字段
  hasMention?: boolean; // 是否有人提及(@)你
  isArchived?: boolean; // 是否已归档
  hasUnreadMention?: boolean; // 是否有未读的提及
  messageTtlSetting?: number; // 消息自动删除设置(秒)
  isPremium?: boolean; // 是否为Premium用户
  readStatus?: 'none' | 'sent' | 'delivered' | 'read'; // 消息已读状态
}

export class ChatListViewModel {
  private static instance: ChatListViewModel;
  private CoreService = CoreService.getInstance();
  private eventBus = EventBus.getInstance();

  // UI 响应式数据
  private _chatItems: ChatItemDisplay[] = [];
  private _isLoading: boolean = true;
  private _searchKeyword: string = '';
  private _filterType: 'all' | 'pinned' | 'unread' | 'muted' = 'all';
  private _selectedChatIds: number[] = []; // 改用数组以支持响应式更新
  private _showBatchActions: boolean = false;
  private _isSelectionMode: boolean = false; // 是否处于批量选择模式
  private _hasMoreChats: boolean = true; // 是否还有更多聊天
  private _isLoadingMore: boolean = false; // 是否正在加载更多

  // ⭐ 单一数据源：ChatListDataSource 实例，供 LazyForEach 直接使用
  private _chatDataSource: ChatListDataSource = new ChatListDataSource();

  // 回调函数，由 Page 设置以触发 UI 更新（可选，LazyForEach 会自动监听数据源变化）
  public onDataChanged: (() => void) | null = null;

  // ====== 事件去抖机制 ======
  private refreshTimer: number = -1; // 单个聊天刷新定时器
  private pendingRefreshChatIds: Set<number> = new Set(); // 待刷新的聊天ID集合
  private fullRefreshTimer: number = -1; // 全量刷新定时器
  private readonly DEBOUNCE_DELAY = 30; // 单个聊天去抖延迟(ms) - 降低延迟
  private readonly FULL_REFRESH_DEBOUNCE = 50; // 全量刷新去抖延迟(ms) - 降低延迟
  
  // ====== 智能排序优化 ======
  private lastSortedChatIds: string = ''; // 上次排序的聊天ID指纹
  private chatOrderCache: Map<string, number> = new Map(); // 缓存每个聊天的排序键
  
  // ====== 增量渲染优化 ======
  private changedChatIds: Set<string> = new Set(); // 发生变化的聊天ID
  private incrementalUpdateTimer: number = -1;
  private readonly INCREMENTAL_UPDATE_DELAY = 50; // 增量更新延迟

  private constructor() {
    hilog.info(DOMAIN, TAG, '✅ ChatListViewModel instance created');
    this.subscribeEvents();
    hilog.info(DOMAIN, TAG, '✅ Event subscriptions established');
  }

  public static getInstance(): ChatListViewModel {
    if (!ChatListViewModel.instance) {
      hilog.info(DOMAIN, TAG, 'Creating new ChatListViewModel instance');
      ChatListViewModel.instance = new ChatListViewModel();
    } else {
      hilog.info(DOMAIN, TAG, 'Returning existing ChatListViewModel instance');
    }
    return ChatListViewModel.instance;
  }

  /**
   * 初始化方法（可选，Page 可以调用以触发初始数据加载）
   */
  public initialize(): void {
    // 初始刷新 UI，如果 CoreService 已经就绪会立即显示数据
    this.refreshUI();
  }

  /**
   * ⭐ 刷新聊天列表（用于页面重新显示时）
   */
  public refreshChatList(): void {
    hilog.info(DOMAIN, TAG, '🔄 refreshChatList called');
    // 从 CoreService 获取最新聊天列表
    const allChats: Chat[] = this.CoreService.getAllChats();
    if (allChats && allChats.length > 0) {
      // 转换为显示格式
      const newChatItems: ChatItemDisplay[] = [];
      for (let i = 0; i < allChats.length; i++) {
        const chat: Chat = allChats[i];
        if (!chat.isArchived) {
          newChatItems.push(this.toChatItemDisplay(chat));
        }
      }
      // 更新数据
      this._chatItems = newChatItems;
      this.sortChatItems();
      this._isLoading = false;
      // 通知 UI 更新
      this.onDataChanged?.();
      hilog.info(DOMAIN, TAG, `✅ refreshChatList completed: ${newChatItems.length} chats`);
    } else {
      hilog.warn(DOMAIN, TAG, '⚠️ No chats found in CoreService');
    }
  }

  private subscribeEvents(): void {
    // 订阅聊天列表变更事件（来自 CoreService）- 实时更新
    // ⭐ 这是唯一需要订阅的事件，CoreService 会在完成数据刷新后才触发此事件
    this.eventBus.on('chatListChanged', (data?: Object) => {
      hilog.info(DOMAIN, TAG, '🔄 chatListChanged received, triggering refreshUI');
      
      // ⭐ 实时更新：立即刷新，无防抖延迟
      this.refreshUI();
    });
    
    // 订阅 TDLib 授权就绪事件
    this.eventBus.on('CoreServiceReady', () => {
      this._isLoading = false;
      this.refreshUI();
    });
    
    // ⭐ 注意：不再直接订阅 TDLib 事件（如 updateNewMessage、updateChatLastMessage 等）
    // 这些事件由 CoreService 处理，CoreService 完成数据刷新后会触发 chatListChanged 事件
    // 这样可以确保 ViewModel 总是获取到最新的数据，避免时序竞争问题
    
    // 订阅 CoreService 领域事件（用户信息变化）- 需要特殊处理发送者名称
    this.eventBus.on('core:userUpdated', (data?: Object) => {
      if (!data) return;
      const userId = (data as Record<string, Object>)['userId'] as number;
      if (userId) {
        hilog.debug(DOMAIN, TAG, `core:userUpdated for user ${userId}`);
        // 刷新所有与该用户相关的聊天（用于更新发送者名称）
        this.refreshChatsByUserId(userId);
      }
    });
    
    // 订阅 CoreService 领域事件（用户在线状态变化）
    this.eventBus.on('core:userStatusUpdated', (data?: Object) => {
      if (!data) return;
      const userId = (data as Record<string, Object>)['userId'] as number;
      if (userId) {
        hilog.debug(DOMAIN, TAG, `core:userStatusUpdated for user ${userId}`);
        // 刷新所有与该用户相关的私聊
        this.refreshChatsByUserId(userId);
      }
    });
    
    // 订阅 CoreService 领域事件（头像下载完成）
    this.eventBus.on('core:avatarDownloaded', (data?: Object) => {
      if (!data) return;
      const chatId = (data as Record<string, Object>)['chatId'] as number | undefined;
      if (chatId) {
        // 刷新特定聊天的头像
        this.refreshChat(chatId);
      } else {
        // 如果没有指定 chatId，触发全量刷新
        this.refreshUI();
      }
    });
  }

  /**
   * 刷新单个聊天项（实时更新，无防抖）
   */
  private refreshChat(chatId: number): void {
    // ⭐ 实时更新：立即执行，无防抖延迟
    this.executeSingleRefresh(chatId);
  }
  
  /**
   * 执行单个聊天刷新（实时更新）
   */
  private executeSingleRefresh(chatId: number): void {
    const chat = this.CoreService.getChat(chatId);
    
    if (!chat || chat.isArchived) {
      return;
    }
    
    const index = this._chatItems.findIndex(item => parseInt(item.id) === chatId);
    let hasChanges = false;
    
    if (index !== -1) {
      // 更新已存在的聊天项
      const newItems = [...this._chatItems];
      newItems[index] = this.toChatItemDisplay(chat);
      this._chatItems = newItems;
      hasChanges = true;
      hilog.debug(DOMAIN, TAG, `✅ Real-time refreshed chat ${chatId} (${chat.title})`);
    } else {
      // 新增聊天
      const newChatItem = this.toChatItemDisplay(chat);
      this._chatItems = [...this._chatItems, newChatItem];
      hasChanges = true;
      hilog.info(DOMAIN, TAG, `➕ Added new chat ${chatId} (${chat.title})`);
    }
    
    if (hasChanges) {
      this.sortChatItems();
      this.onDataChanged?.();
    }
  }

  /**
   * 执行批量刷新(实际刷新逻辑)
   */
  private executeBatchRefresh(): void {
    const chatIds = Array.from(this.pendingRefreshChatIds);
    this.pendingRefreshChatIds.clear();
    this.refreshTimer = -1;
    
    hilog.info(DOMAIN, TAG, `🔄 Batch refreshing ${chatIds.length} chats: [${chatIds.join(', ')}]`);
    
    let hasChanges = false;
    let successCount = 0;
    let addedCount = 0;
    let notFoundCount = 0;
    
    // 遍历所有待刷新的聊天
    for (let i = 0; i < chatIds.length; i++) {
      const chatId = chatIds[i];
      const chat = this.CoreService.getChat(chatId);
      
      if (chat) {
        // 跳过已归档的聊天
        if (chat.isArchived) {
          hilog.debug(DOMAIN, TAG, `Skipping archived chat ${chatId}`);
          continue;
        }
        
        const index = this._chatItems.findIndex(item => parseInt(item.id) === chatId);
        if (index !== -1) {
          // 更新已存在的聊天项
          const newItems = [...this._chatItems];
          newItems[index] = this.toChatItemDisplay(chat);
          this._chatItems = newItems;
          hasChanges = true;
          successCount++;
          hilog.debug(DOMAIN, TAG, `✅ Refreshed chat ${chatId} (${chat.title}) at index ${index}`);
        } else {
          // ⭐ 新增：如果聊天不在列表中，添加它（新聊天）
          const newChatItem = this.toChatItemDisplay(chat);
          this._chatItems = [...this._chatItems, newChatItem];
          hasChanges = true;
          addedCount++;
          hilog.info(DOMAIN, TAG, `➕ Added new chat ${chatId} (${chat.title}) to list`);
        }
      } else {
        hilog.warn(DOMAIN, TAG, `⚠️ Chat ${chatId} not found in CoreService`);
        notFoundCount++;
      }
    }
    
    // 如果有变化,重新排序并通知UI
    if (hasChanges) {
      this.sortChatItems();
      hilog.info(DOMAIN, TAG, `✅ Batch refresh completed: ${successCount} refreshed, ${addedCount} added, ${notFoundCount} failed`);
      this.onDataChanged?.();
    } else {
      hilog.warn(DOMAIN, TAG, `⚠️ Batch refresh completed but no changes detected`);
    }
  }
    
  /**
   * 根据用户ID刷新相关聊天(用于私聊)
   */
  private refreshChatsByUserId(userId: number): void {
    let hasChanges = false;
    const newItems = [...this._chatItems]; // 创建新数组
    
    for (let i = 0; i < newItems.length; i++) {
      const item = newItems[i];
      const chat = this.CoreService.getChat(parseInt(item.id));
      if (chat && chat.userId === userId) {
        newItems[i] = this.toChatItemDisplay(chat);
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      this._chatItems = newItems; // 赋值新数组触发响应式更新
      this.sortChatItems();
      this.onDataChanged?.();
    }
  }
  
  /**
   * 检查并刷新头像更新
   */
  private checkAndRefreshAvatarUpdate(fileObj: Record<string, Object>): void {
    // 简化处理：当文件下载完成时，刷新所有聊天列表以更新头像
    // 实际实现中可以根据 fileId 映射到具体的聊天
    const localPath = fileObj['local'] as Record<string, Object> | undefined;
    if (localPath && localPath['path']) {
      // 触发全量刷新
      this.refreshUI();
    }
  }
  
  /**
   * 对聊天项进行排序（严格遵循 Telegram 的 (order, id) 二元组降序规则）
   * 排序规则：
   * 1. 按 order 降序排列（order 越大越靠前）
   * 2. 如果 order 相同，按 chat.id 降序排列（确保绝对确定性）
   * 
   * 注意：TDLib 保证置顶的 order > 非置顶的 order，因此置顶自然排在前面
   */
  private sortChatItems(): void {
    // 创建新数组并排序，以触发响应式更新
    this._chatItems = [...this._chatItems].sort((a, b) => {
      // 1. 按 TDLib 的 order 降序排列（order 越大越靠前）
      const orderA = a.order ?? 0;
      const orderB = b.order ?? 0;
      
      if (orderA !== orderB) {
        return orderB - orderA; // 降序：大的在前
      }
      
      // 2. 如果 order 相同，按 id 降序排列（确保绝对确定性）
      return parseInt(b.id) - parseInt(a.id);
    });
  }
  
  /**
   * 获取聊天的时间戳（用于排序）
   */
  private getChatTimestamp(item: ChatItemDisplay): number {
    // 尝试从 CoreService 获取原始 chat 对象
    const chat = this.CoreService.getChat(parseInt(item.id));
    if (chat) {
      // 优先使用最后消息时间，如果没有则使用聊天创建时间
      return chat.timestamp || 0;
    }
    return 0;
  }

  private refreshUI(): void {
    hilog.info(DOMAIN, TAG, '🔄 refreshUI called');
    const allChats = this.CoreService.getChatList();
    hilog.info(DOMAIN, TAG, `refreshUI: total chats=${allChats.length}, pinned=${allChats.filter(c => c.isPinned).length}`);

    // 应用过滤
    let filtered = [...allChats];
    // 1. 归档过滤（只显示未归档）
    filtered = filtered.filter(chat => !chat.isArchived);
    // 2. 搜索过滤
    if (this._searchKeyword.trim()) {
      const kw = this._searchKeyword.toLowerCase();
      filtered = filtered.filter(chat => chat.title.toLowerCase().includes(kw));
    }
    // 3. 类型筛选
    switch (this._filterType) {
      case 'pinned':
        filtered = filtered.filter(chat => chat.isPinned);
        break;
      case 'unread':
        filtered = filtered.filter(chat => (chat.unreadCount || 0) > 0);
        break;
      case 'muted':
        filtered = filtered.filter(chat => chat.isMuted);
        break;
    }

    // ⭐ 每次更新都重新排序（确保最新消息排在最前面）
    hilog.debug(DOMAIN, TAG, '📊 Resorting chats...');
    this.performSort(filtered);
    this.updateOrderCache(filtered);

    hilog.debug(DOMAIN, TAG,
      `After sort: pinned=${filtered.filter(c => c.isPinned).length}, total=${filtered.length}`);

    // ⭐ 增量渲染：只更新变化的聊天项
    this.performIncrementalUpdate(filtered);

    // ⭐ 同步更新数据源（供 LazyForEach 使用）
    this._chatDataSource.updateData(this._chatItems);

    hilog.info(DOMAIN, TAG, `✅ refreshUI completed, displaying ${this._chatItems.length} chats`);
    
    // ⭐ 打印前5个聊天的最后消息，用于调试
    if (this._chatItems.length > 0) {
      const previewCount = Math.min(5, this._chatItems.length);
      for (let i = 0; i < previewCount; i++) {
        const item = this._chatItems[i];
        hilog.info(DOMAIN, TAG, `  [${i}] ${item.title}: lastMessage="${item.lastMessage}", time="${item.lastMessageTime}"`);
      }
    }
  }
  
  /**
   * ⭐ 智能排序：检查是否需要重新排序
   */
  private checkIfNeedsResort(chats: Chat[]): boolean {
    // 如果列表为空或长度为0，需要排序
    if (!chats || chats.length === 0) return true;
    
    // 生成当前排序指纹
    const currentFingerprint = this.generateSortFingerprint(chats);
    if (currentFingerprint !== this.lastSortedChatIds) {
      return true;
    }
    
    // 检查每个聊天的排序键是否变化
    for (const chat of chats) {
      const cachedOrder = this.chatOrderCache.get(String(chat.id));
      const currentOrder = this.calculateSortKey(chat);
      if (cachedOrder !== currentOrder) {
        return true;
      }
    }
    
    return false;
  }
  
  /**
   * 生成排序指纹（用于快速比较）
   */
  private generateSortFingerprint(chats: Chat[]): string {
    return chats.map(c => `${c.id}:${c.isPinned ? 1 : 0}:${c.order || c.timestamp || 0}`).join('|');
  }
  
  /**
   * 计算排序键
   */
  private calculateSortKey(chat: Chat): number {
    // 置顶聊天排在最前面，使用一个很大的基数
    if (chat.isPinned) {
      return Number.MAX_SAFE_INTEGER - (chat.order || chat.timestamp || 0);
    }
    return chat.order || chat.timestamp || 0;
  }
  
  /**
   * 执行排序（严格遵循 Telegram 的 (order, id) 二元组降序规则）
   * 排序规则：
   * 1. 按 order 降序排列（order 越大越靠前）
   * 2. 如果 order 相同，按 chat.id 降序排列（确保绝对确定性）
   * 
   * 注意：TDLib 保证置顶的 order > 非置顶的 order，因此置顶自然排在前面
   */
  private performSort(chats: Chat[]): void {
    // 打印排序前的状态（用于调试）
    hilog.debug(DOMAIN, TAG, `🔍 Before sort: ${chats.map(c => `${c.title}(order=${c.order}, id=${c.id})`).join(', ')}`);
    
    chats.sort((a, b) => {
      // 1. 按 TDLib 的 order 降序排列（order 越大越靠前）
      const orderA = a.order ?? 0;
      const orderB = b.order ?? 0;
      
      if (orderA !== orderB) {
        return orderB - orderA; // 降序：大的在前
      }
      
      // 2. 如果 order 相同，按 id 降序排列（确保绝对确定性）
      return b.id - a.id;
    });
    
    // 打印排序后的状态
    hilog.debug(DOMAIN, TAG, `✅ After sort: ${chats.map(c => `${c.title}(order=${c.order}, id=${c.id})`).join(', ')}`);
  }
  
  /**
   * 更新排序缓存
   */
  private updateOrderCache(chats: Chat[]): void {
    this.chatOrderCache.clear();
    for (const chat of chats) {
      this.chatOrderCache.set(String(chat.id), this.calculateSortKey(chat));
    }
    this.lastSortedChatIds = this.generateSortFingerprint(chats);
  }
  
  /**
   * ⭐ 增量渲染：收到更新立即刷新显示，排序只由 order 变化触发
   */
  private performIncrementalUpdate(filteredChats: Chat[]): void {
    // 如果是首次加载或列表为空，全量更新
    if (this._chatItems.length === 0) {
      this._chatItems = filteredChats.map(chat => this.toChatItemDisplay(chat));
      this.onDataChanged?.();
      return;
    }
    
    // 检查是否有新增或删除的聊天
    const currentIds = new Set(this._chatItems.map(item => item.id));
    const newIds = new Set(filteredChats.map(chat => String(chat.id)));
    
    const hasNewChats = filteredChats.some(chat => !currentIds.has(String(chat.id)));
    const hasDeletedChats = this._chatItems.some(item => !newIds.has(item.id));
    
    // 如果有新增或删除，需要全量更新（因为顺序可能变化）
    if (hasNewChats || hasDeletedChats) {
      hilog.debug(DOMAIN, TAG, `🆕 Full update: new=${hasNewChats}, deleted=${hasDeletedChats}`);
      this._chatItems = filteredChats.map(chat => this.toChatItemDisplay(chat));
      this.onDataChanged?.();
      return;
    }
    
    // ⭐ 检查是否有 order 变化（需要重新排序）
    let hasOrderChanged = false;
    for (const chat of filteredChats) {
      const chatId = String(chat.id);
      const existingItem = this._chatItems.find(item => item.id === chatId);
      if (existingItem && existingItem.order !== chat.order) {
        hasOrderChanged = true;
        break;
      }
    }
    
    // 如果 order 变化，按 filteredChats 的顺序（已排序）重建列表
    if (hasOrderChanged) {
      hilog.info(DOMAIN, TAG, '🔄 Order changed, rebuilding list with new sort order');
      this._chatItems = filteredChats.map(chat => this.toChatItemDisplay(chat));
      this.onDataChanged?.();
      return;
    }
    
    // ⭐ 收到任何更新就立即刷新显示，保持原有顺序
    // 直接重新生成所有显示项，不检查是否有变化
    const updatedItems: ChatItemDisplay[] = [];
    
    // 按当前 _chatItems 的顺序重建列表，更新所有显示内容
    for (const existingItem of this._chatItems) {
      const chatId = parseInt(existingItem.id);
      const chat = filteredChats.find(c => c.id === chatId);
      
      if (chat) {
        const newItem = this.toChatItemDisplay(chat);
        updatedItems.push(newItem);
      }
    }
    
    // 始终更新并触发 UI 刷新
    this._chatItems = updatedItems;
    this.onDataChanged?.();
    hilog.info(DOMAIN, TAG, `🔄 Immediate display update: ${updatedItems.length} items refreshed`);
  }
  
  /**
   * 检查聊天项是否有变化（包括 order）
   */
  private hasChatItemChanged(oldItem: ChatItemDisplay, newItem: ChatItemDisplay): boolean {
    return oldItem.lastMessage !== newItem.lastMessage ||
           oldItem.lastMessageTime !== newItem.lastMessageTime ||
           oldItem.unreadCount !== newItem.unreadCount ||
           oldItem.isPinned !== newItem.isPinned ||
           oldItem.isMuted !== newItem.isMuted ||
           oldItem.isOnline !== newItem.isOnline ||
           oldItem.hasDraft !== newItem.hasDraft ||
           oldItem.avatar !== newItem.avatar ||
           oldItem.order !== newItem.order ||
           oldItem.senderName !== newItem.senderName; // ⭐ 检查发送者名称变化
  }
  
  /**
   * 检查显示内容是否有变化（不包括 order，不触发排序）
   */
  private hasDisplayContentChanged(oldItem: ChatItemDisplay, newItem: ChatItemDisplay): boolean {
    return oldItem.lastMessage !== newItem.lastMessage ||
           oldItem.lastMessageTime !== newItem.lastMessageTime ||
           oldItem.unreadCount !== newItem.unreadCount ||
           oldItem.isPinned !== newItem.isPinned ||
           oldItem.isMuted !== newItem.isMuted ||
           oldItem.isOnline !== newItem.isOnline ||
           oldItem.hasDraft !== newItem.hasDraft ||
           oldItem.avatar !== newItem.avatar;
    // 注意：不包括 order，order 变化单独处理
  }

  private toChatItemDisplay(chat: Chat): ChatItemDisplay {
    // 如果是群组/频道/超级群组且有最后消息，异步填充发送者名称
    if ((chat.type === ChatType.GROUP || chat.type === ChatType.SUPERGROUP || chat.type === ChatType.CHANNEL) &&
        chat.lastMessage && !chat.lastMessage.senderName &&
        !chat.lastMessage.isOutgoing && chat.lastMessage.senderId > 0) {
      this.fillSenderNameAsync(chat);
    }

    // ⭐ 检查并填充 senderName（如果缓存中有用户信息）
    this.tryFillSenderNameFromCache(chat);

    // ⭐ 提取发送者名称和 outgoing 状态（用于 UI 显示蓝色发送者）
    const senderName = chat.lastMessage?.senderName;
    const isOutgoing = chat.lastMessage?.isOutgoing;

    let avatarPath = chat.avatar || '';
    if (avatarPath && !avatarPath.startsWith('file://')) {
      avatarPath = 'file://' + avatarPath;
    }
    hilog.info(DOMAIN, TAG, `Chat ${chat.id} (${chat.title}) avatar: "${chat.avatar || 'empty'}" -> "${avatarPath}"`);

    // ⭐ 判断是否为机器人（私聊且对方是机器人）
    const isBot = chat.type === ChatType.PRIVATE && chat.userId ?
      this.CoreService.getCachedUserInfo(chat.userId)?.isBot || false : false;

    const display: ChatItemDisplay = {
      id: String(chat.id),
      title: chat.title,
      avatar: avatarPath,
      lastMessage: this.getLastMessagePreview(chat),
      lastMessageTime: this.formatTime(chat.timestamp),
      unreadCount: chat.unreadCount || 0,
      isPinned: chat.isPinned || false,
      isMuted: chat.isMuted || false,
      isSecret: chat.type === ChatType.SECRET,
      isOnline: this.isUserOnline(chat),
      isVerified: chat.isVerified || false,
      isBot: isBot, // ⭐ 是否为机器人
      hasDraft: !!(chat.draftMessage?.text),
      type: chat.type,
      order: chat.order, // TDLib 排序顺序
      senderName: senderName, // ⭐ 发送者名称
      isOutgoing: isOutgoing, // ⭐ 是否是自己发送的消息
      isMarkedAsUnread: chat.isMarkedAsUnread || false, // ⭐ 是否标记为未读
      // ⭐ 新增字段
      hasMention: chat.unreadMentionCount ? chat.unreadMentionCount > 0 : false, // 是否有未读提及
      isArchived: chat.isArchived || false, // 是否已归档
      hasUnreadMention: chat.unreadMentionCount ? chat.unreadMentionCount > 0 : false, // 是否有未读提及
      messageTtlSetting: chat.messageTtlSetting, // 消息自动删除设置
      // isPremium 字段在 Chat 接口中不存在，暂时注释掉
      readStatus: this.getReadStatus(chat) // 消息已读状态
    };

    if (display.isPinned) {
      hilog.debug(DOMAIN, TAG, `📌 Pinned chat: ${chat.title} (${chat.id})`);
    }

    return display;
  }

  /**
   * ⭐ 尝试从缓存填充发送者名称（同步方式）
   * 在生成显示数据前先检查缓存，避免异步延迟
   */
  private tryFillSenderNameFromCache(chat: Chat): void {
    if (!chat.lastMessage || chat.lastMessage.senderName) {
      return; // 已经有 senderName 或没有最后消息
    }
    if (chat.lastMessage.isOutgoing || chat.lastMessage.senderId <= 0) {
      return; // 是自己发送的消息或 senderId 无效
    }
    if (chat.type !== ChatType.GROUP && chat.type !== ChatType.SUPERGROUP && chat.type !== ChatType.CHANNEL) {
      return; // 不是群组/频道类型
    }

    // 尝试从 CoreService 同步获取缓存的用户信息
    const userInfo = this.CoreService.getCachedUserInfo(chat.lastMessage.senderId);
    if (userInfo && userInfo.name) {
      chat.lastMessage.senderName = userInfo.name;
      hilog.debug(DOMAIN, TAG, `Filled senderName from cache for chat ${chat.id}: ${userInfo.name}`);
    }
  }

  /**
   * 异步填充发送者名称（用于群组/频道的最后消息）
   */
  private async fillSenderNameAsync(chat: Chat): Promise<void> {
    if (!chat.lastMessage || chat.lastMessage.senderId <= 0) return;

    const chatId = chat.id;
    const senderId = chat.lastMessage.senderId;

    try {
      // 从 CoreService 获取用户信息
      const userInfo = await this.CoreService.getUserInfo(senderId);
      if (userInfo && userInfo.name) {
        // ⭐ 重新获取最新的 chat 对象，避免修改过期的引用
        const freshChat = this.CoreService.getChat(chatId);
        if (freshChat && freshChat.lastMessage) {
          freshChat.lastMessage.senderName = userInfo.name;
          hilog.debug(DOMAIN, TAG, `✅ Set senderName for chat ${chatId}: ${userInfo.name}`);
          // 触发 UI 更新 - 使用增量刷新
          this.refreshChat(chatId);
        }
      }
    } catch (error) {
      hilog.warn(DOMAIN, TAG, `Failed to get sender name for user ${senderId}: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 生成消息预览文本（遵循 Telegram 规范）
   * 优先级：草稿 > 最后消息
   * 截断规则：50-80 字符
   */
  private getLastMessagePreview(chat: Chat): string {
    // ⭐ 优先级 1：草稿消息（最高优先级）
    if (chat.draftMessage?.text) {
      const draftText = this.truncateText(chat.draftMessage.text, 70);
      return `[草稿]: ${draftText}`;
    }

    // 检查是否有最后消息
    if (!chat.lastMessage) {
      hilog.debug(DOMAIN, TAG, `No last message for chat ${chat.id} (${chat.title})`);
      return '';
    }

    // 构建前缀（发送者名称）
    let prefix = '';
    
    // 调试日志
    hilog.debug(DOMAIN, TAG, `Chat ${chat.id} type=${chat.type}, senderName="${chat.lastMessage.senderName}", isOutgoing=${chat.lastMessage.isOutgoing}`);

    // ⭐ 群组/超级群组：为所有非本人发送的消息显示发送者姓名
    if (chat.type === ChatType.GROUP || chat.type === ChatType.SUPERGROUP) {
      if (!chat.lastMessage.isOutgoing && chat.lastMessage.senderName) {
        // 他人消息：显示发送者姓名
        prefix = `${chat.lastMessage.senderName}: `;
        hilog.debug(DOMAIN, TAG, `Chat ${chat.id} showing sender name: ${chat.lastMessage.senderName}`);
      } else if (chat.lastMessage.isOutgoing) {
        // 本人消息：不显示发送者（简洁自然）
        prefix = '';
      } else if (!chat.lastMessage.senderName) {
        // senderName 为空，可能是异步获取中
        hilog.debug(DOMAIN, TAG, `Chat ${chat.id} senderName is empty, skipping prefix`);
      }
    } else if (chat.type === ChatType.CHANNEL) {
      // ⭐ 频道：普通频道不显示发送者（体现"广播"属性）
      // 如果频道开启了签名消息，senderName 会有值，此时显示签名
      hilog.info(DOMAIN, TAG, 
        `Channel ${chat.id} senderName: "${chat.lastMessage.senderName || 'empty'}"`);
      if (chat.lastMessage.senderName) {
        prefix = `${chat.lastMessage.senderName}: `;
        hilog.info(DOMAIN, TAG, `Channel ${chat.id} showing sender name: ${chat.lastMessage.senderName}`);
      } else {
        hilog.info(DOMAIN, TAG, `Channel ${chat.id} no sender name (anonymous or no signature)`);
      }
      // 否则不显示前缀（匿名发布）
    } else if (chat.type === ChatType.PRIVATE) {
      // ⭐ 私聊：不显示发送者姓名（对话双方身份已由顶部聊天对象名称明确）
      // 无论是自己发送还是对方发送，都不显示前缀
      prefix = '';
    }
      
    // 根据消息类型显示不同的内容
    const type = chat.lastMessage.type;
    let content = '';
      
    switch (type) {
      case MessageType.TEXT:
        // 文本消息：截取前 80 字符（含前缀后约 50-80 字符）
        const textContent = chat.lastMessage.content;
        content = this.truncateText(typeof textContent === 'string' ? textContent : String(textContent ?? ''), 80);
        break;
      case MessageType.PHOTO:
        content = '[照片]';
        break;
      case MessageType.VIDEO:
        // 视频消息：带时长（优先使用 message.duration）
        const videoDuration = chat.lastMessage.duration ? 
          this.formatDurationFromSeconds(chat.lastMessage.duration) : '';
        content = videoDuration ? `[视频 ${videoDuration}]` : '[视频]';
        break;
      case MessageType.VOICE_NOTE:
        // ⭐ 语音消息：带时长（优先使用 message.duration）
        const voiceDuration = chat.lastMessage.duration ? 
          this.formatDurationFromSeconds(chat.lastMessage.duration) : '';
        content = voiceDuration ? `[语音 ${voiceDuration}]` : '[语音消息]';
        break;
      case MessageType.DOCUMENT:
        // ⭐ 文件消息：显示文件名
        const fileName = this.getFileName(chat.lastMessage);
        content = fileName ? `[文件] ${fileName}` : '[文件]';
        break;
      case MessageType.STICKER:
        content = '[贴纸]';
        break;
      case MessageType.ANIMATION:
        content = '[GIF]';
        break;
      case MessageType.AUDIO:
        // ⭐ 音频消息：带时长（优先使用 message.duration）
        const audioDuration = chat.lastMessage.duration ? 
          this.formatDurationFromSeconds(chat.lastMessage.duration) : '';
        content = audioDuration ? `[音频 ${audioDuration}]` : '[音频]';
        break;
      case MessageType.VIDEO_NOTE:
        // ⭐ 视频笔记：带时长（优先使用 message.duration）
        const videoNoteDuration = chat.lastMessage.duration ? 
          this.formatDurationFromSeconds(chat.lastMessage.duration) : '';
        content = videoNoteDuration ? `[视频笔记 ${videoNoteDuration}]` : '[视频笔记]';
        break;
      case MessageType.LOCATION:
        // ⭐ 位置消息：显示地址
        const locationAddress = this.getLocationAddress(chat.lastMessage);
        content = locationAddress ? `📍 ${locationAddress}` : '[位置]';
        break;
      case MessageType.CONTACT:
        // ⭐ 联系人消息：显示姓名
        const contactName = this.getContactName(chat.lastMessage);
        content = contactName ? `[联系人] ${contactName}` : '[联系人]';
        break;
      case MessageType.POLL:
        // ⭐ 投票消息：显示问题
        const pollQuestion = this.getPollQuestion(chat.lastMessage);
        content = pollQuestion ? `📊 [投票] ${pollQuestion}` : '📊 [投票]';
        break;
      case MessageType.GAME:
        content = '🎮 [游戏]';
        break;
      case MessageType.SYSTEM:
        // 服务消息：直接使用提取的文本（已包含 ℹ️ 等图标）
        content = chat.lastMessage.content as string;
        break;
      case MessageType.GROUP_EVENT:
        // ⭐ 群组事件：生成事件描述文本
        content = this.getGroupEventPreview(chat.lastMessage);
        break;
      default:
        content = '[消息]';
    }
      
    const preview = prefix + content;
    hilog.debug(DOMAIN, TAG, `Last message preview for chat ${chat.id}: ${preview}`);
    return preview;
  }
    
  /**
   * 截断文本，末尾添加 ...
   * @param text 原始文本
   * @param maxLength 最大长度（默认 80）
   */
  private truncateText(text: string | undefined | null, maxLength: number = 80): string {
    if (!text || typeof text !== 'string') return '';
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - 3) + '...';
  }
    
  /**
   * 格式化时长（秒 -> mm:ss）
   * @deprecated 使用 formatDurationFromSeconds 替代
   */
  private formatDuration(content: object | undefined): string {
    if (!content) return '';
    const contentRecord = content as Record<string, number>;
    const duration = contentRecord['duration'];
    if (!duration || duration <= 0) return '';
      
    return this.formatDurationFromSeconds(duration);
  }

  /**
   * ⭐ 格式化时长（秒 -> mm:ss）
   */
  private formatDurationFromSeconds(duration: number): string {
    if (!duration || duration <= 0) return '';
    
    const minutes = Math.floor(duration / 60);
    const seconds = Math.floor(duration % 60);
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  }

  /**
   * ⭐ 获取文件名（用于文件消息预览）
   */
  private getFileName(message: Message | undefined): string {
    if (!message || !message.file) return '';
    return message.file.fileName || '';
  }

  /**
   * ⭐ 获取位置地址（用于位置消息预览）
   */
  private getLocationAddress(message: Message | undefined): string {
    if (!message || !message.location) return '';
    return message.location.address || message.location.title || '';
  }

  /**
   * ⭐ 获取联系人姓名（用于联系人消息预览）
   */
  private getContactName(message: Message | undefined): string {
    if (!message || !message.contact) return '';
    const firstName = message.contact.firstName || '';
    const lastName = message.contact.lastName || '';
    return `${firstName} ${lastName}`.trim();
  }

  /**
   * ⭐ 获取投票问题（用于投票消息预览）
   */
  private getPollQuestion(message: Message | undefined): string {
    if (!message || !message.poll) return '';
    return message.poll.question || '';
  }

  /**
   * ⭐ 获取群组事件预览文本（用于群组事件消息）
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

  private formatTime(timestamp?: number): string {
    if (!timestamp) return '';
    
    const date = new Date(timestamp);
    const now = new Date();
    const isToday = date.getDate() === now.getDate() && 
                    date.getMonth() === now.getMonth() && 
                    date.getFullYear() === now.getFullYear();
    
    // 今天的消息显示时间（HH:mm）
    if (isToday) {
      return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
    }
    
    // 昨天的消息显示"昨天"+时间
    const yesterday = new Date(now);
    yesterday.setDate(yesterday.getDate() - 1);
    const isYesterday = date.getDate() === yesterday.getDate() && 
                        date.getMonth() === yesterday.getMonth() && 
                        date.getFullYear() === yesterday.getFullYear();
    if (isYesterday) {
      return `昨天 ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
    }
    
    // 本周内的消息显示星期几+时间
    const daysDiff = Math.floor((now.getTime() - date.getTime()) / 86400000);
    if (daysDiff < 7) {
      const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      return `${weekdays[date.getDay()]} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
    }
    
    // 今年的消息显示月/日
    if (date.getFullYear() === now.getFullYear()) {
      return `${date.getMonth() + 1}/${date.getDate()}`;
    }
    
    // 往年的消息显示年/月/日
    return `${date.getFullYear()}/${date.getMonth() + 1}/${date.getDate()}`;
  }

  private isUserOnline(chat: Chat): boolean {
    if (chat.type !== ChatType.PRIVATE) return false;
    const status = chat.userStatus;
    if (!status) return false;
    // 检查用户状态类型，判断是否在线
    const typeValue = this.getUserStatusType(status);
    if (typeValue === 'userStatusOnline') {
      // 对于在线状态，检查 expires 字段判断是否在有效期内
      const onlineStatus = status as UserStatusOnline;
      if (onlineStatus.expires && onlineStatus.expires > Date.now() / 1000) {
        return true;
      }
    }
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
   * ⭐ 获取消息已读状态（用于私聊）
   */
  private getReadStatus(chat: Chat): 'none' | 'sent' | 'delivered' | 'read' {
    // 只有私聊且是自己发送的消息才显示已读状态
    if (chat.type !== ChatType.PRIVATE || !chat.lastMessage || !chat.lastMessage.isOutgoing) {
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

  // ==================== 公开 Getters ====================
  /**
   * ⭐ 获取聊天列表数据源（供 LazyForEach 使用）
   * 这是单一数据源，Page 应该直接使用此数据源
   */
  public get chatDataSource(): ChatListDataSource {
    return this._chatDataSource;
  }

  /**
   * ⭐ 获取聊天列表（已去重）
   * @deprecated 推荐使用 chatDataSource 供 LazyForEach 使用
   */
  public get chatItems(): ChatItemDisplay[] {
    // 去重：确保每个 id 只返回一个聊天项
    const uniqueMap = new Map<string, ChatItemDisplay>();
    for (const item of this._chatItems) {
      uniqueMap.set(item.id, item);
    }
    return Array.from(uniqueMap.values());
  }
  public get isLoading(): boolean {
    return this._isLoading;
  }
  public get searchKeyword(): string {
    return this._searchKeyword;
  }
  public get filterType(): string {
    return this._filterType;
  }
  public get selectedChatIds(): number[] {
    return this._selectedChatIds;
  }
  public get showBatchActions(): boolean {
    return this._showBatchActions;
  }
  public get selectedCount(): number {
    return this._selectedChatIds.length;
  }
  public get isSelectionMode(): boolean {
    return this._isSelectionMode;
  }
  public get hasMoreChats(): boolean {
    return this._hasMoreChats;
  }
  public get isLoadingMore(): boolean {
    return this._isLoadingMore;
  }

  /**
   * 检查聊天是否被选中
   */
  public isSelected(chatId: number): boolean {
    return this._selectedChatIds.includes(chatId);
  }

  // ==================== 用户操作 ====================
  public setSearchKeyword(keyword: string): void {
    this._searchKeyword = keyword;
    this.refreshUI();
  }

  public setFilterType(type: 'all' | 'pinned' | 'unread' | 'muted'): void {
    this._filterType = type;
    this.refreshUI();
  }

  public toggleSelectChat(chatId: number): void {
    const index = this._selectedChatIds.indexOf(chatId);
    if (index !== -1) {
      // 已选中，取消选择
      this._selectedChatIds.splice(index, 1);
    } else {
      // 未选中，添加选择
      this._selectedChatIds.push(chatId);
    }
    
    // 更新批量操作栏显示状态
    this._showBatchActions = this._selectedChatIds.length > 0;
    
    // 如果没有选中任何聊天，自动退出批量模式
    if (this._selectedChatIds.length === 0) {
      this.exitSelectionMode();
      return;
    }
    
    // 触发 UI 更新
    this.onDataChanged?.();
  }

  /**
   * 进入批量选择模式
   */
  public enterSelectionMode(chatId: number): void {
    this._isSelectionMode = true;
    this._selectedChatIds = [chatId]; // 直接赋值新数组以触发响应式更新
    this._showBatchActions = true;
    this.onDataChanged?.();
  }

  /**
   * 退出批量选择模式
   */
  public exitSelectionMode(): void {
    this._isSelectionMode = false;
    this._selectedChatIds = []; // 直接赋值空数组
    this._showBatchActions = false;
    this.onDataChanged?.();
  }

  public clearSelection(): void {
    this._selectedChatIds = []; // 直接赋值空数组
    this._showBatchActions = false;
    this.onDataChanged?.();
  }

  public async markAsRead(chatId: number): Promise<void> {
    await this.CoreService.markAsRead(chatId);
    // 更新本地状态
    const index = this._chatItems.findIndex(item => parseInt(item.id) === chatId);
    if (index !== -1) {
      this._chatItems[index].unreadCount = 0;
      this._chatItems[index].isMarkedAsUnread = false;
      this.onDataChanged?.();
    }
  }

  /**
   * ⭐ 标记聊天为未读
   */
  public async markAsUnread(chatId: number): Promise<void> {
    try {
      await this.CoreService.markAsUnread(chatId);
      // 更新本地状态
      const index = this._chatItems.findIndex(item => parseInt(item.id) === chatId);
      if (index !== -1) {
        this._chatItems[index].isMarkedAsUnread = true;
        this.onDataChanged?.();
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to mark chat ${chatId} as unread: ${JSON.stringify(error)}`);
    }
  }

  public async setPinned(chatId: number, pinned: boolean): Promise<void> {
    try {
      await this.CoreService.setPinned(chatId, pinned);
      // UI 会通过 updateChatIsPinned 事件自动刷新
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to set pinned for chat ${chatId}: ${JSON.stringify(error)}`);
    }
  }

  public async setMuted(chatId: number, muted: boolean, muteUntil?: number): Promise<void> {
    try {
      await this.CoreService.setMuted(chatId, muted, muteUntil);
      // UI 会通过 updateChatNotificationSettings 事件自动刷新
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to set muted for chat ${chatId}: ${JSON.stringify(error)}`);
    }
  }

  public async deleteChat(chatId: number): Promise<void> {
    try {
      await this.CoreService.deleteChat(chatId);
      // UI 会通过 chatListChanged 事件自动刷新
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to delete chat ${chatId}: ${JSON.stringify(error)}`);
    }
  }

  public async batchPin(): Promise<void> {
    for (const id of this._selectedChatIds) {
      await this.setPinned(id, true);
    }
    this.clearSelection();
  }

  public async batchMute(muteUntil?: number): Promise<void> {
    for (const id of this._selectedChatIds) {
      await this.setMuted(id, true, muteUntil);
    }
    this.clearSelection();
  }

  public async batchArchive(): Promise<void> {
    for (const id of this._selectedChatIds) {
      await this.archiveChat(id);
    }
    this.exitSelectionMode();
  }

  /**
   * 归档单个聊天
   */
  public async archiveChat(chatId: number): Promise<void> {
    try {
      // 调用 CoreService 的归档方法
      await this.CoreService.archiveChat(chatId);
      hilog.info(DOMAIN, TAG, `Chat ${chatId} archived successfully`);
    } catch (error) {
      const err = error as Error;
      hilog.error(DOMAIN, TAG, `Failed to archive chat ${chatId}: ${err.message}`);
      throw new Error(`归档聊天失败: ${err.message}`);
    }
  }

  /**
   * 批量标记已读
   */
  public async batchMarkAsRead(): Promise<void> {
    for (const id of this._selectedChatIds) {
      await this.markAsRead(id);
    }
    this.exitSelectionMode();
  }

  /**
   * 批量取消静音
   */
  public async batchUnmute(): Promise<void> {
    for (const id of this._selectedChatIds) {
      await this.setMuted(id, false);
    }
    this.exitSelectionMode();
  }

  public async batchDelete(): Promise<void> {
    for (const id of this._selectedChatIds) {
      await this.deleteChat(id);
    }
    this.clearSelection();
  }

  /**
   * 加载更多聊天（滚动到底部时调用）
   */
  public async loadMoreChats(): Promise<void> {
    if (!this._hasMoreChats || this._isLoadingMore) {
      hilog.debug(DOMAIN, TAG, 'Skip loading more chats: hasMoreChats=' + this._hasMoreChats + ', isLoadingMore=' + this._isLoadingMore);
      return;
    }

    this._isLoadingMore = true;
    this.onDataChanged?.();

    try {
      const hasMore = await this.CoreService.loadMoreChats(50);
      this._hasMoreChats = hasMore;
      
      // 刷新 UI
      this.refreshUI();
      
      hilog.info(DOMAIN, TAG, `Loaded more chats, hasMore=${hasMore}`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to load more chats: ${JSON.stringify(error)}`);
    } finally {
      this._isLoadingMore = false;
      this.onDataChanged?.();
    }
  }

  public cleanup(): void {
    // ViewModel 是单例，不应该清除事件订阅
    // 订阅应该在应用生命周期内持续有效
    // 只清理回调函数引用，防止内存泄漏
    this.onDataChanged = null;
    
    // 清理去抖定时器，防止内存泄漏
    if (this.refreshTimer !== -1) {
      clearTimeout(this.refreshTimer);
      this.refreshTimer = -1;
    }
    
    if (this.fullRefreshTimer !== -1) {
      clearTimeout(this.fullRefreshTimer);
      this.fullRefreshTimer = -1;
    }
    
    // 清空待刷新集合
    this.pendingRefreshChatIds.clear();
    
    hilog.info(DOMAIN, TAG, '✅ ChatListViewModel cleanup completed');
  }
}