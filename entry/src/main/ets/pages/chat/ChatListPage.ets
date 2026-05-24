// ChatListPage.ets
import { router, promptAction } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display } from '@kit.ArkUI';
import { ErrorHandler } from '../../utils/error/ErrorHandler';
import { getString } from '../../utils/i18n/ResourceHelper';
import { ImmersiveContainer } from '../../components/common/ImmersiveContainer';
import { ImmersiveMode, ThemeMode } from '../../utils/utils/ImmersiveUtils';
import { EventBus } from '../../utils/event/EventBus';
// ⭐ 优化：从 ViewModel 导入 ChatListDataSource 和 ListItem，遵循单一数据源原则
import { ChatListViewModel, ChatItemDisplay, ChatListDataSource, ListItem } from './viewmodels/ChatListViewModel';
import { ChatType } from '../../models/TDLibData';

const TAG = 'ChatListPage';
const DOMAIN = 0x0001;
const BOTTOM_PADDING = 100;

/**
 * showActionMenu 返回结果类型
 */
interface ActionMenuResult {
  index: number;
}

@Entry
@Component
export struct ChatListPage {
  // ⭐ 平板模式回调：点击聊天时通知父组件
  onChatSelected?: (chatId: number, chatType: ChatType, title: string, avatar: string) => void;

  private viewModel: ChatListViewModel = ChatListViewModel.getInstance();
  private eventBus: EventBus = EventBus.getInstance();

  // UI 状态：订阅 ViewModel 数据
  @State chatItems: ChatItemDisplay[] = [];
  @State isLoading: boolean = true;
  @State showBatchActions: boolean = false;
  @State selectedCount: number = 0;
  @State isSelectionMode: boolean = false; // 是否处于批量选择模式
  @State showMoreMenuPopup: boolean = false; // 是否显示更多操作气泡菜单
  @State private refreshTrigger: number = 0; // 用于强制触发 UI 刷新
  @State selectedChatIds: number[] = []; // 选中的聊天 ID 列表

  // ⭐ 优化：直接使用 ViewModel 中的数据源，遵循单一数据源原则
  // 不再创建新的 ChatDataSource 实例，而是使用 viewModel.chatDataSource

  aboutToAppear(): void {
    hilog.info(DOMAIN, TAG, '🚀 ChatListPage aboutToAppear - START');

    // 设置 ViewModel 数据变更回调，触发 UI 更新
    this.viewModel.onDataChanged = () => {
      hilog.info(DOMAIN, TAG, '📊 onDataChanged callback triggered');
      // 同步 UI 状态（数据源已由 ViewModel 自动更新）
      this.chatItems = [...this.viewModel.chatItems];
      this.isLoading = this.viewModel.isLoading;
      this.showBatchActions = this.viewModel.showBatchActions;
      this.selectedCount = this.viewModel.selectedCount;
      this.isSelectionMode = this.viewModel.isSelectionMode;
      this.selectedChatIds = [...this.viewModel.selectedChatIds]; // ✅ 同步选中状态

      // 强制触发 UI 刷新
      this.refreshTrigger++;
    };

    // 初始化 ViewModel（触发初始数据加载）
    hilog.info(DOMAIN, TAG, 'Calling viewModel.initialize()');
    this.viewModel.initialize();

    // 初始加载数据
    this.updateUIFromViewModel();
    hilog.info(DOMAIN, TAG, '✅ ChatListPage aboutToAppear - END');
  }

  private updateUIFromViewModel(): void {
    // ⭐ 优化：ViewModel 已自动更新数据源，Page 只需同步 UI 状态
    // 创建新数组以触发 @State 响应式更新
    this.chatItems = [...this.viewModel.chatItems];
    this.isLoading = this.viewModel.isLoading;
    this.showBatchActions = this.viewModel.showBatchActions;
    this.selectedCount = this.viewModel.selectedCount;
    this.isSelectionMode = this.viewModel.isSelectionMode;
    this.selectedChatIds = [...this.viewModel.selectedChatIds]; // ✅ 同步选中状态

    // 强制触发 UI 刷新
    this.refreshTrigger++;
  }

  /**
   * ⭐ 页面显示时调用（从其他页面返回时也会触发）
   * 由于 MainTabContainer 使用 Swiper 缓存页面，aboutToAppear 不会重复调用
   * 因此需要在 onPageShow 中刷新数据
   */
  onPageShow(): void {
    hilog.info(DOMAIN, TAG, '📱 ChatListPage onPageShow - refreshing data');
    // 刷新聊天列表数据
    this.viewModel.refreshChatList();
    // 同步 UI 状态
    this.updateUIFromViewModel();
  }

  aboutToDisappear(): void {
    this.viewModel.cleanup();
  }

  /**
   * 处理返回键事件
   */
  onBackPress(): boolean {
    if (this.isSelectionMode) {
      this.viewModel.exitSelectionMode();
      return true; // 消费返回事件，不退出页面
    }
    return false; // 允许退出页面
  }

  // ==================== 辅助方法 ====================
  private getAvatarColor(title: string): string {
    const colors = ['#FF6B35', '#007AFF', '#4CAF50', '#FFA500', '#9C27B0', '#FA2A2D', '#00BCD4', '#E91E63', '#8BC34A', '#FF5722', '#3F51B5', '#009688'];
    let hash = 0;
    for (let i = 0; i < title.length; i++) hash = title.charCodeAt(i) + ((hash << 5) - hash);
    return colors[Math.abs(hash) % colors.length];
  }

  private shouldShowUnreadBadge(chat: ChatItemDisplay): boolean {
    if (chat.type === ChatType.CHANNEL) return false;
    return chat.unreadCount > 0;
  }

  private getMessageTextColor(chat: ChatItemDisplay): string {
    // 有草稿时显示红色
    if (chat.hasDraft) {
      return '#FA2A2D';
    }
    // 有未读消息且非频道显示黑色
    if (chat.unreadCount > 0 && chat.type !== ChatType.CHANNEL) {
      return '#000000';
    }
    // 默认灰色
    return '#8E8E93';
  }

  /**
   * ⭐ 判断是否显示发送者名称（蓝色）
   * 仅在群组/超级群组/频道中，且非本人发送的消息时显示
   */
  private shouldShowSenderName(chat: ChatItemDisplay): boolean {
    // 私聊不显示发送者
    if (chat.type === ChatType.PRIVATE || chat.type === ChatType.SECRET) {
      return false;
    }
    // 本人发送的消息不显示发送者
    if (chat.isOutgoing) {
      return false;
    }
    // 没有发送者名称不显示
    if (!chat.senderName || chat.senderName.length === 0) {
      return false;
    }
    // 群组/超级群组/频道显示发送者
    return chat.type === ChatType.GROUP || chat.type === ChatType.SUPERGROUP || chat.type === ChatType.CHANNEL;
  }

  /**
   * ⭐ 获取聊天类型图标
   */
  private getChatTypeIcon(chat: ChatItemDisplay): string {
    switch (chat.type) {
      case ChatType.GROUP:
      case ChatType.SUPERGROUP:
        return '';
        //return '👥';
      case ChatType.CHANNEL:
        return '';
        //return '📢';
      case ChatType.SECRET:
        return '';
        //return '🔒';
      case ChatType.BOT:
      case ChatType.PRIVATE:
        //if (chat.isBot) return '🤖';
        if (chat.isBot) return '';
        return '';
      default:
        return '';
    }
  }

  /**
   * ⭐ 获取已读状态图标
   */
  private getReadStatusIcon(status: string): string {
    switch (status) {
      case 'sent':
        return '✓'; // 单勾 - 已发送
      case 'delivered':
        return '✓✓'; // 双勾 - 已送达
      case 'read':
        return '✓✓'; // 双勾（蓝色）- 已读
      default:
        return '';
    }
  }

  /**
   * ⭐ 获取已读状态颜色
   */
  private getReadStatusColor(status: string): string {
    switch (status) {
      case 'read':
        return '#007AFF'; // 蓝色 - 已读
      case 'delivered':
        return '#8E8E93'; // 灰色 - 已送达
      case 'sent':
        return '#8E8E93'; // 灰色 - 已发送
      default:
        return '#8E8E93';
    }
  }

  /**
   * ⭐ 获取消息内容（不含发送者前缀）
   * 当发送者名称单独显示为蓝色时，需要提取纯消息内容
   */
  private getMessageContentOnly(chat: ChatItemDisplay): string {
    if (!chat.lastMessage) {
      return '';
    }
    // 如果 lastMessage 包含发送者前缀，移除它
    if (chat.senderName && chat.lastMessage.startsWith(`${chat.senderName}: `)) {
      return chat.lastMessage.substring(`${chat.senderName}: `.length);
    }
    // 检查是否包含其他可能的发送者前缀格式（如 "[草稿]: "）
    if (chat.lastMessage.startsWith('[草稿]: ')) {
      return chat.lastMessage.substring('[草稿]: '.length);
    }
    // 否则返回完整的 lastMessage
    return chat.lastMessage;
  }
  private openSearchPage(): void {
    router.pushUrl({ url: 'pages/SearchPage' }).catch((e: Error) => ErrorHandler.getInstance().handle(e));
  }

  private openNewChatMenu(): void {
    router.pushUrl({ url: 'pages/NewChatPage' }).catch((e: Error) => ErrorHandler.getInstance().handle(e));
  }

  private onChatClick(chat: ChatItemDisplay): void {
    const chatId = parseInt(chat.id);
    if (isNaN(chatId)) return;
    
    // 如果处于批量选择模式，切换选中状态
    if (this.isSelectionMode) {
      this.viewModel.toggleSelectChat(chatId);
      return;
    }
    
    // 标记已读
    this.viewModel.markAsRead(chatId);
    
    // ⭐ 平板模式：直接调用回调函数通知父组件
    if (this.onChatSelected) {
      hilog.info(DOMAIN, TAG, `⭐ Calling onChatSelected callback: id=${chatId}, title=${chat.title}`);
      this.onChatSelected(chatId, chat.type, chat.title, chat.avatar || '');
      return; // 平板模式下不执行路由跳转
    }
    
    // 手机模式：路由跳转到 ChatPage
    router.pushUrl({
      url: 'pages/common/ChatPage',
      params: { 
        chatId, 
        chatType: chat.type, 
        title: chat.title, 
        avatar: chat.avatar 
      }
    }).catch((e: Error) => ErrorHandler.getInstance().handle(e));
  }

  private onChatLongPress(chat: ChatItemDisplay): void {
    const chatId = parseInt(chat.id);
    if (!isNaN(chatId)) {
      // 进入批量选择模式，并自动选中当前聊天的
      this.viewModel.enterSelectionMode(chatId);
    }
  }

  private async showMuteOptions(chatId: number): Promise<void> {
    const result = await promptAction.showActionMenu({
      title: '静音通知',
      buttons: [
        { text: '1小时', color: '#007AFF' },
        { text: '8小时', color: '#007AFF' },
        { text: '1周', color: '#007AFF' },
        { text: '永久静音', color: '#007AFF' },
        { text: '取消静音', color: '#8E8E93' }
      ]
    });
    if (result.index === -1) return;
      
    const shouldMute = result.index !== 4;
    if (shouldMute) {
      let muteUntil = Date.now();
      switch (result.index) {
        case 0: muteUntil += 60 * 60 * 1000; break;
        case 1: muteUntil += 8 * 60 * 60 * 1000; break;
        case 2: muteUntil += 7 * 24 * 60 * 60 * 1000; break;
        case 3: muteUntil = Number.MAX_SAFE_INTEGER; break;
      }
      await this.viewModel.setMuted(chatId, true, muteUntil);
    } else {
      await this.viewModel.setMuted(chatId, false);
    }
  }
  
  private async confirmDeleteChat(chatId: number): Promise<void> {
    const result = await promptAction.showDialog({
      title: '删除聊天',
      message: '删除后将清空该聊天的所有消息记录。此操作不可撤销。',
      buttons: [{ text: '取消', color: '#8E8E93' }, { text: '删除', color: '#FA2A2D' }]
    });
    if (result.index === 1) {
      await this.viewModel.deleteChat(chatId);
    }
  }
  
  private async confirmBatchArchive(): Promise<void> {
    const count = this.selectedCount;
    const result = await promptAction.showDialog({
      title: `归档 ${count} 个聊天`,
      message: '归档的聊天将移至"归档聊天"文件夹。',
      buttons: [{ text: '取消', color: '#8E8E93' }, { text: '归档', color: '#007AFF' }]
    });
    if (result.index === 1) {
      await this.viewModel.batchArchive();
    }
  }
  
  private async confirmBatchDelete(): Promise<void> {
    const count = this.selectedCount;
    const result = await promptAction.showDialog({
      title: `删除 ${count} 个聊天`,
      message: '删除后将清空所选聊天的所有消息记录。此操作不可撤销。',
      buttons: [{ text: '取消', color: '#8E8E93' }, { text: '删除', color: '#FA2A2D' }]
    });
    if (result.index === 1) {
      await this.viewModel.batchDelete();
    }
  }
  
  /**
   * 归档单个聊天（左滑归档）
   */
  private async archiveSingleChat(chatId: number): Promise<void> {
    try {
      await this.viewModel.archiveChat(chatId);
      // UI 会通过事件自动刷新
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to archive chat ${chatId}: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 显示批量静音选项
   */
  private async showBatchMuteOptions(): Promise<void> {
    const result = await promptAction.showActionMenu({
      title: '静音通知',
      buttons: [
        { text: '1小时', color: '#007AFF' },
        { text: '8小时', color: '#007AFF' },
        { text: '1周', color: '#007AFF' },
        { text: '永久静音', color: '#007AFF' },
        { text: '取消静音', color: '#8E8E93' }
      ]
    });
    if (result.index === -1) return;
      
    const shouldMute = result.index !== 4;
    if (shouldMute) {
      let muteUntil = Date.now();
      switch (result.index) {
        case 0: muteUntil += 60 * 60 * 1000; break;
        case 1: muteUntil += 8 * 60 * 60 * 1000; break;
        case 2: muteUntil += 7 * 24 * 60 * 60 * 1000; break;
        case 3: muteUntil = Number.MAX_SAFE_INTEGER; break;
      }
      await this.viewModel.batchMute(muteUntil);
    } else {
      await this.viewModel.batchUnmute();
    }
  }
  
  /**
   * 切换更多操作气泡菜单显示状态
   */
  private toggleMoreMenu(): void {
    this.showMoreMenuPopup = !this.showMoreMenuPopup;
  }
  
  /**
   * 隐藏更多操作气泡菜单
   */
  private hideMoreMenu(): void {
    this.showMoreMenuPopup = false;
  }
  
  /**
   * 批量标记已读
   */
  private async batchMarkAsRead(): Promise<void> {
    await this.viewModel.batchMarkAsRead();
  }
  
  /**
   * 批量清除缓存
   */
  private async batchClearCache(): Promise<void> {
    // TODO: 实现清除缓存逻辑
    promptAction.showToast({ message: '已清除缓存', duration: 1500 });
    this.hideMoreMenu();
  }
  
  /**
   * 构建更多操作气泡菜单
   */
  @Builder
  private buildMoreMenuPopup() {
    Row() {
      Column({ space: 0 }) {
        // 归档
        Row() {
          Text('📥')
            .fontSize(20)
            .margin({ right: 12 })
          Text('归档')
            .fontSize(16)
            .fontColor('#000000')
            .layoutWeight(1)
        }
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.confirmBatchArchive();
          this.hideMoreMenu();
        })

        // 分隔线
        Divider()
          .color('#E5E5EA')
          .strokeWidth(0.5)

        // 标记已读
        Row() {
          Text('✓')
            .fontSize(20)
            .fontColor('#007AFF')
            .margin({ right: 12 })
          Text('标记已读')
            .fontSize(16)
            .fontColor('#000000')
            .layoutWeight(1)
        }
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.batchMarkAsRead();
          this.hideMoreMenu();
        })

        // 分隔线
        Divider()
          .color('#E5E5EA')
          .strokeWidth(0.5)

        // 删除缓存
        Row() {
          Text('🗑️')
            .fontSize(20)
            .margin({ right: 12 })
          Text('删除缓存')
            .fontSize(16)
            .fontColor('#000000')
            .layoutWeight(1)
        }
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.batchClearCache();
          this.hideMoreMenu();
        })
      }
      .width(200)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .shadow({
        radius: 10,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetY: 4
      })
      .margin({ top: 4, right: 16 })
      .alignSelf(ItemAlign.End)
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
  }

  // ==================== UI 构建 ====================
  @Builder
  private buildTopBar() {
    Row() {
      Text(getString('chats_title'))
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .layoutWeight(1)
      Image($r('app.media.ic_search'))
        .width(24)
        .height(24)
        .fillColor('#007AFF')
        .onClick(() => this.openSearchPage())
        .margin({ right: 16 })
      Image($r('app.media.ic_menu'))
        .width(24)
        .height(24)
        .fillColor('#007AFF')
        .onClick(() => this.openNewChatMenu())
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private chatItemBuilder(chat: ChatItemDisplay) {
    Row() {
      // 批量选择模式下显示复选框（增加点击区域）
      if (this.isSelectionMode) {
        Row() {
          Text(this.selectedChatIds.includes(parseInt(chat.id)) ? '✓' : '○')
            .fontSize(24)
            .fontColor(this.selectedChatIds.includes(parseInt(chat.id)) ? '#007AFF' : '#8E8E93')
            .width(24)
            .height(24)
            .textAlign(TextAlign.Center)
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .margin({ right: 8 })
        .onClick(() => {
          const chatId = parseInt(chat.id);
          if (!isNaN(chatId)) {
            this.viewModel.toggleSelectChat(chatId);
          }
        })
      }
      
      Stack() {
        if (chat.avatar) {
          Image(chat.avatar)
            .width(56)
            .height(56)
            .borderRadius(28)
            .objectFit(ImageFit.Cover)
            .onError(() => {
              // 头像加载失败时记录日志
              hilog.warn(DOMAIN, TAG, `Failed to load avatar for chat ${chat.id}`);
            })
        } else {
          Circle().width(56).height(56).fill(this.getAvatarColor(chat.title))
          Text(chat.title.charAt(0).toUpperCase())
            .fontSize(24)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        // 秘密聊天锁图标
        if (chat.isSecret) {
          Text('🔒')
            .fontSize(14)
            .position({ x: 38, y: 38 })
        }
        // 私聊在线状态绿点
        if (chat.type === 'private' && chat.isOnline) {
          Circle()
            .width(14)
            .height(14)
            .fill('#4CAF50')
            .stroke(Color.White)
            .strokeWidth(2)
            .position({ x: 42, y: 42 })
        }
        // ⭐ 自动删除计时器图标（消息自动删除功能）
        if (chat.messageTtlSetting && chat.messageTtlSetting > 0) {
          Text('⏱️')
            .fontSize(12)
            .position({ x: 42, y: 0 })
        }
      }
      .margin({ right: 12 })

      Column({ space: 4 }) {
        Row() {
          // 聊天类型图标（群组、频道、密聊、机器人）
          if (this.getChatTypeIcon(chat)) {
            Text(this.getChatTypeIcon(chat))
              .fontSize(14)
              .margin({ right: 4 })
          }
          Text(chat.title)
            .fontSize(16)
            .fontWeight(chat.unreadCount > 0 ? FontWeight.Medium : FontWeight.Normal)
            .fontColor('#000000')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          // 验证徽章
          if (chat.isVerified) {
            Text('✓')
              .fontSize(14)
              .fontColor('#007AFF')
              .margin({ left: 4, right: 4 })
          }
          // 置顶图标
          if (chat.isPinned) {
            Text('📌')
              .fontSize(14)
              .fontColor('#8E8E93')
              .margin({ right: 8 })
          }
          // ⭐ 静音图标
          if (chat.isMuted) {
            Text('🔇')
              .fontSize(14)
              .fontColor('#8E8E93')
              .margin({ right: 8 })
          }
          // ⭐ 提及图标 (@)
          if (chat.hasUnreadMention) {
            Text('@')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FA2A2D')
              .margin({ right: 8 })
          }
          // ⭐ Premium 用户星星图标
          if (chat.isPremium) {
            Text('⭐')
              .fontSize(14)
              .margin({ right: 8 })
          }
          Text(chat.lastMessageTime)
            .fontSize(12)
            .fontColor('#8E8E93')
        }
        .width('100%')

        Row() {
          // ⭐ 发送者名称显示为蓝色（仅群组/频道且非本人消息时）
          if (this.shouldShowSenderName(chat)) {
            Text(`${chat.senderName}: `)
              .fontSize(14)
              .fontColor('#007AFF') // 蓝色
              .maxLines(1)
            Text(this.getMessageContentOnly(chat))
              .fontSize(14)
              .fontColor(this.getMessageTextColor(chat))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          } else {
            // ⭐ 显示已读状态图标（仅私聊且自己发送的消息）
            if (chat.readStatus && chat.readStatus !== 'none') {
              Text(this.getReadStatusIcon(chat.readStatus))
                .fontSize(12)
                .fontColor(this.getReadStatusColor(chat.readStatus))
                .margin({ right: 4 })
            }
            Text(chat.lastMessage)
              .fontSize(14)
              .fontColor(this.getMessageTextColor(chat))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }
          // 未读消息角标
          if (this.shouldShowUnreadBadge(chat)) {
            if (chat.isMuted) {
              // 静音状态显示红点
              Circle()
                .width(8)
                .height(8)
                .fill('#FA2A2D')
                .margin({ left: 8 })
            } else {
              // 非静音显示数字
              Text(chat.unreadCount > 99 ? '99+' : `${chat.unreadCount}`)
                .fontSize(12)
                .fontColor(Color.White)
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .backgroundColor('#FA2A2D')
                .borderRadius(12)
                .margin({ left: 8 })
            }
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height(78)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Center)
    .onClick(() => this.onChatClick(chat))
    .gesture(LongPressGesture().onAction(() => this.onChatLongPress(chat)))
  }

  @Builder
  private buildLeftSwipeMenu(chat: ChatItemDisplay) {
    Row() {
      Button('归档')
        .fontSize(14)
        .backgroundColor('#8E8E93')
        .height(78)
        .borderRadius(0)
        .onClick(() => this.archiveSingleChat(parseInt(chat.id)))
    }
    .width('100%')
    .height(78)
  }

  @Builder
  private buildRightSwipeMenu(chat: ChatItemDisplay) {
    Row() {
      Button(chat.isPinned ? '取消置顶' : '置顶')
        .fontSize(14)
        .backgroundColor('#FFA500')
        .height(78)
        .borderRadius(0)
        .onClick(() => this.viewModel.setPinned(parseInt(chat.id), !chat.isPinned))
      Button(chat.isMuted ? '取消静音' : '静音')
        .fontSize(14)
        .backgroundColor('#8E8E93')
        .height(78)
        .borderRadius(0)
        .onClick(() => {
          const id = parseInt(chat.id);
          if (!chat.isMuted) this.showMuteOptions(id);
          else this.viewModel.setMuted(id, false);
        })
      // ⭐ 标记已读/未读按钮
      Button((chat.unreadCount > 0 || chat.isMarkedAsUnread) ? '标记已读' : '标记未读')
        .fontSize(14)
        .backgroundColor('#007AFF')
        .height(78)
        .borderRadius(0)
        .onClick(() => {
          const id = parseInt(chat.id);
          if (chat.unreadCount > 0 || chat.isMarkedAsUnread) {
            // 标记为已读
            this.viewModel.markAsRead(id);
          } else {
            // 标记为未读
            this.viewModel.markAsUnread(id);
          }
        })
    }
    .width('100%')
    .height(78)
  }

  @Builder
  private swipeableChatItem(chat: ChatItemDisplay) {
    ListItem() {
      this.chatItemBuilder(chat)
    }
    // 批量选择模式下禁用滑动操作
    .swipeAction(this.isSelectionMode ? {} : {
      start: { builder: () => this.buildRightSwipeMenu(chat), actionAreaDistance: 80 },
      end: { builder: () => this.buildLeftSwipeMenu(chat), actionAreaDistance: 80 }
    })
  }

  @Builder
  private buildChatList() {
    // ⭐ 优化：直接使用 ViewModel 中的数据源
    // 注意：ArkTS @Builder 中不能使用 const，直接使用 this.viewModel.chatDataSource

    if (this.isLoading && this.viewModel.chatDataSource.totalCount() === 0) {
      // 加载中状态
      Column() {
        LoadingProgress().width(40).height(40).color('#3390F0')
        Text('加载中...').fontSize(14).fontColor('#8E8E93').margin({ top: 12 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.viewModel.chatDataSource.totalCount() === 0) {
      // 空状态
      Column() {
        Image($r('app.media.ic_none_message')).width(100).height(100).opacity(0.3)
        Text(getString('no_chats')).fontSize(14).fontColor('#C7C7CC').margin({ top: 12 })
        Text(getString('start_chatting_hint')).fontSize(12).fontColor('#D1D1D6').margin({ top: 6 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else {
      // ⭐ 使用 LazyForEach 渲染聊天列表，实现虚拟列表性能优化
      List({ space: 0 }) {
        // ⭐ 关键修复：key 只使用 chat.id，不使用 index，避免重新排序时产生重复 key
        // ⭐ 优化：直接使用 ViewModel.chatDataSource，遵循单一数据源原则
        LazyForEach(this.viewModel.chatDataSource, (item: ListItem, index: number) => {
          ListItem() {
            // ⭐ 根据类型渲染不同内容：分隔线或聊天项
            if (item.kind === 'divider') {
              // 分组分隔线
              Row().width('100%').height(8).backgroundColor('#F5F5F5')
            } else if (item.data) {
              this.swipeableChatItem(item.data)
            }
          }
        }, (item: ListItem, index: number) => item.kind === 'divider' ? `__divider__${index}` : `chat_${item.data?.id ?? index}`)

        // 加载更多提示
        if (this.viewModel.isLoadingMore) {
          ListItem() {
            Row() {
              LoadingProgress().width(24).height(24).color('#3390F0')
              Text('加载中...').fontSize(14).fontColor('#8E8E93').margin({ left: 8 })
            }
            .width('100%')
            .height(60)
            .justifyContent(FlexAlign.Center)
          }
        }

        // 底部占位（批量操作时不显示）
        if (!this.showBatchActions) {
          ListItem() { Row().width('100%').height(BOTTOM_PADDING).backgroundColor(Color.Transparent) }
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      .cachedCount(10) // 保持缓存数量
      .divider({ strokeWidth: 0.5, color: '#E5E5EA', startMargin: 84, endMargin: 0 })
      .onReachEnd(() => {
        this.viewModel.loadMoreChats(); // 滚动到底部加载更多
      })
    }
  }

  @Builder
  private buildBatchActions() {
    Stack() {
      Column() {
        // 批量操作栏
        Row() {
          // 左侧：取消按钮
          Text('取消')
            .fontSize(17)
            .fontColor('#007AFF')
            .onClick(() => this.viewModel.exitSelectionMode())

          // 中间：已选中数量
          Text(`${this.selectedCount} 个聊天已选`)
            .layoutWeight(1)
            .fontSize(17)
            .fontColor('#000000')
            .textAlign(TextAlign.Center)

          // 右侧：四个操作按钮
          Row({ space: 16 }) {
            // 1. 置顶（使用 emoji）
            Text('📌')
              .fontSize(24)
              .onClick(() => this.viewModel.batchPin())

            // 2. 静音（使用 emoji）
            Text('🔕')
              .fontSize(24)
              .onClick(() => this.showBatchMuteOptions())

            // 3. 删除（使用原图标，蓝色）
            Image($r('app.media.ic_delete'))
              .width(24)
              .height(24)
              .fillColor('#007AFF')
              .onClick(() => this.confirmBatchDelete())

            // 4. 更多展开（使用原图标）
            Image($r('app.media.ic_more'))
              .width(24)
              .height(24)
              .fillColor('#007AFF')
              .onClick(() => this.toggleMoreMenu())
          }
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        .alignItems(VerticalAlign.Center)

        // 更多操作气泡菜单（在按钮下方展开）
        if (this.showMoreMenuPopup) {
          this.buildMoreMenuPopup()
        }
      }
    }
  }

  build() {
    Stack() {
      ImmersiveContainer({ mode: ImmersiveMode.COMPONENT_TOP, theme: ThemeMode.AUTO, excludeBottom: true }) {
        Column() {
          // 批量模式下显示批量操作栏，否则显示普通顶栏
          if (this.isSelectionMode) {
            this.buildBatchActions()
          } else {
            this.buildTopBar()
          }
          this.buildChatList()
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#FFFFFF')
      }
    }
    .width('100%')
    .height('100%')
  }
}
