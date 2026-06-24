/**
 * ChatListItem - 聊天列表项组件
 * 提取自 ChatListPage，支持批量选择模式和滑动操作
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { ChatItemDisplay } from '../../viewmodels/ChatListViewModel';
import { ChatType } from '../../models/TDLibData';

const DOMAIN = 0x0001;
const TAG = 'ChatListItem';

@ComponentV2
export struct ChatListItem {
  @Param chat: ChatItemDisplay | null = null;
  @Param isSelectionMode: boolean = false;
  @Param selectedChatIds: number[] = [];
  @Param private onItemClick?: (chat: ChatItemDisplay) => void = undefined;
  @Param private onItemLongPress?: (chat: ChatItemDisplay) => void = undefined;
  @Param private onToggleSelect?: (chatId: number) => void = undefined;
  @Param private onArchive?: (chatId: number) => void = undefined;
  @Param private onSetPinned?: (chatId: number, isPinned: boolean) => void = undefined;
  @Param private onMute?: (chatId: number) => void = undefined;
  @Param private onUnmute?: (chatId: number) => void = undefined;
  @Param private onMarkAsRead?: (chatId: number) => void = undefined;
  @Param private onMarkAsUnread?: (chatId: number) => void = undefined;

  // 颜色常量
  private readonly COLOR_TEXT_PRIMARY = '#000000';
  private readonly COLOR_TEXT_SECONDARY = '#8E8E93';
  private readonly COLOR_ACCENT = '#007AFF';
  private readonly COLOR_DANGER = '#FA2A2D';
  private readonly COLOR_WARNING = '#FFA500';
  private readonly COLOR_AVATAR_BG = ['#FF6B35', '#007AFF', '#4CAF50', '#FFA500', '#9C27B0', '#FA2A2D', '#00BCD4', '#E91E63', '#8BC34A', '#FF5722', '#3F51B5', '#009688'];

  aboutToAppear(): void {
    // 初始化逻辑
  }

  /**
   * 获取头像背景色（根据标题生成一致的哈希颜色）
   */
  private getAvatarColor(title: string): string {
    let hash = 0;
    for (let i = 0; i < title.length; i++) {
      hash = title.charCodeAt(i) + ((hash << 5) - hash);
    }
    return this.COLOR_AVATAR_BG[Math.abs(hash) % this.COLOR_AVATAR_BG.length];
  }

  /**
   * 判断是否显示未读角标
   */
  private shouldShowUnreadBadge(chat: ChatItemDisplay): boolean {
    if (chat.type === ChatType.CHANNEL) return false;
    return chat.unreadCount > 0;
  }

  /**
   * 获取消息文字颜色
   */
  private getMessageTextColor(chat: ChatItemDisplay): string {
    if (chat.hasDraft) {
      return this.COLOR_DANGER;
    }
    if (chat.unreadCount > 0 && chat.type !== ChatType.CHANNEL) {
      return this.COLOR_TEXT_PRIMARY;
    }
    return this.COLOR_TEXT_SECONDARY;
  }

  /**
   * 判断是否显示发送者名称（蓝色）
   */
  private shouldShowSenderName(chat: ChatItemDisplay): boolean {
    if (chat.type === ChatType.PRIVATE || chat.type === ChatType.SECRET) {
      return false;
    }
    if (chat.isOutgoing) {
      return false;
    }
    if (!chat.senderName || chat.senderName.length === 0) {
      return false;
    }
    return chat.type === ChatType.GROUP || chat.type === ChatType.SUPERGROUP || chat.type === ChatType.CHANNEL;
  }

  /**
   * 获取聊天类型图标
   */
  private getChatTypeIcon(chat: ChatItemDisplay): string {
    return '';
  }

  /**
   * 获取消息内容（不含发送者前缀）
   */
  private getMessageContentOnly(chat: ChatItemDisplay): string {
    if (!chat.lastMessage) {
      return '';
    }
    if (chat.senderName && chat.lastMessage.startsWith(`${chat.senderName}: `)) {
      return chat.lastMessage.substring(`${chat.senderName}: `.length);
    }
    if (chat.lastMessage.startsWith('[草稿]: ')) {
      return chat.lastMessage.substring('[草稿]: '.length);
    }
    return chat.lastMessage;
  }

  /**
   * 处理聊天项点击
   */
  private handleClick(): void {
    if (this.chat && this.onItemClick) {
      this.onItemClick(this.chat);
    }
  }

  /**
   * 处理聊天项长按
   */
  private handleLongPress(): void {
    if (this.chat && this.onItemLongPress) {
      this.onItemLongPress(this.chat);
    }
  }

  /**
   * 处理选择切换
   */
  private handleToggleSelect(): void {
    if (this.chat) {
      const chatId = parseInt(this.chat.id);
      if (!isNaN(chatId) && this.onToggleSelect) {
        this.onToggleSelect(chatId);
      }
    }
  }

  /**
   * 判断当前聊天是否被选中
   */
  private isChatSelected(): boolean {
    if (!this.chat) return false;
    const chatId = parseInt(this.chat.id);
    return this.selectedChatIds.includes(chatId);
  }

  /**
   * 构建聊天项主体
   */
  @Builder
  private buildChatItem() {
    Row() {
      // 批量选择模式下显示复选框
      if (this.isSelectionMode) {
        Row() {
          Text(this.isChatSelected() ? '✓' : '○')
            .fontSize(24)
            .fontColor(this.isChatSelected() ? this.COLOR_ACCENT : this.COLOR_TEXT_SECONDARY)
            .width(24)
            .height(24)
            .textAlign(TextAlign.Center)
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .margin({ right: 8 })
        .onClick(() => this.handleToggleSelect())
      }

      // 头像
      Stack() {
        if (this.chat?.avatar) {
          Image(this.chat.avatar)
            .width(56)
            .height(56)
            .borderRadius(28)
            .objectFit(ImageFit.Cover)
            .onError(() => {
              hilog.warn(DOMAIN, TAG, `Failed to load avatar for chat ${this.chat?.id}`);
            })
        } else if (this.chat) {
          Circle()
            .width(56)
            .height(56)
            .fill(this.getAvatarColor(this.chat.title))
          Text(this.chat.title.charAt(0).toUpperCase())
            .fontSize(24)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }

        if (this.chat?.isSecret) {
          Text('🔒')
            .fontSize(14)
            .position({ x: 38, y: 38 })
        }

        if (this.chat?.type === 'private' && this.chat?.isOnline) {
          Circle()
            .width(14)
            .height(14)
            .fill('#4CAF50')
            .stroke(Color.White)
            .strokeWidth(2)
            .position({ x: 42, y: 42 })
        }

        if (this.chat?.messageTtlSetting && this.chat?.messageTtlSetting > 0) {
          Text('⏱️')
            .fontSize(12)
            .position({ x: 42, y: 0 })
        }
      }
      .margin({ right: 12 })

      // 聊天内容
      Column({ space: 4 }) {
        Row() {
          if (this.getChatTypeIcon(this.chat!)) {
            Text(this.getChatTypeIcon(this.chat!))
              .fontSize(14)
              .margin({ right: 4 })
          }
          Text(this.chat?.title ?? '')
            .fontSize(16)
            .fontWeight(this.chat?.unreadCount && this.chat.unreadCount > 0 ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.COLOR_TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          if (this.chat?.isVerified) {
            Text('✓')
              .fontSize(14)
              .fontColor(this.COLOR_ACCENT)
              .margin({ left: 4, right: 4 })
          }

          if (this.chat?.isPinned) {
            Text('📌')
              .fontSize(14)
              .fontColor(this.COLOR_TEXT_SECONDARY)
              .margin({ right: 8 })
          }

          if (this.chat?.isMuted) {
            Text('🔇')
              .fontSize(14)
              .fontColor(this.COLOR_TEXT_SECONDARY)
              .margin({ right: 8 })
          }

          if (this.chat?.hasUnreadMention) {
            Text('@')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.COLOR_DANGER)
              .margin({ right: 8 })
          }

          if (this.chat?.isPremium) {
            Text('⭐')
              .fontSize(14)
              .margin({ right: 8 })
          }

          Text(this.chat?.lastMessageTime ?? '')
            .fontSize(12)
            .fontColor(this.COLOR_TEXT_SECONDARY)
        }
        .width('100%')

        Row() {
          if (this.shouldShowSenderName(this.chat!)) {
            Text(`${this.chat?.senderName}: `)
              .fontSize(14)
              .fontColor(this.COLOR_ACCENT)
              .maxLines(1)
            Text(this.getMessageContentOnly(this.chat!))
              .fontSize(14)
              .fontColor(this.getMessageTextColor(this.chat!))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          } else {
            Text(this.chat?.lastMessage ?? '')
              .fontSize(14)
              .fontColor(this.getMessageTextColor(this.chat!))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }

          if (this.shouldShowUnreadBadge(this.chat!)) {
            if (this.chat?.isMuted) {
              Circle()
                .width(8)
                .height(8)
                .fill(this.COLOR_DANGER)
                .margin({ left: 8 })
            } else {
              Text((this.chat?.unreadCount ?? 0) > 99 ? '99+' : `${this.chat?.unreadCount}`)
                .fontSize(12)
                .fontColor(Color.White)
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .backgroundColor(this.COLOR_DANGER)
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
    .onClick(() => this.handleClick())
    .gesture(LongPressGesture().onAction(() => this.handleLongPress()))
  }

  /**
   * 构建左侧滑动菜单（归档）
   */
  @Builder
  private buildLeftSwipeMenu() {
    Row() {
      Button('归档')
        .fontSize(14)
        .backgroundColor(this.COLOR_TEXT_SECONDARY)
        .height(78)
        .borderRadius(0)
        .onClick(() => {
          if (this.chat && this.onArchive) {
            this.onArchive(parseInt(this.chat.id));
          }
        })
    }
    .width('100%')
    .height(78)
  }

  /**
   * 构建右侧滑动菜单（置顶、静音、标记已读/未读）
   */
  @Builder
  private buildRightSwipeMenu() {
    Row() {
      Button(this.chat?.isPinned ? '取消置顶' : '置顶')
        .fontSize(14)
        .backgroundColor(this.COLOR_WARNING)
        .height(78)
        .borderRadius(0)
        .onClick(() => {
          if (this.chat && this.onSetPinned) {
            this.onSetPinned(parseInt(this.chat.id), !this.chat.isPinned);
          }
        })

      Button(this.chat?.isMuted ? '取消静音' : '静音')
        .fontSize(14)
        .backgroundColor(this.COLOR_TEXT_SECONDARY)
        .height(78)
        .borderRadius(0)
        .onClick(() => {
          if (this.chat) {
            const chatId = parseInt(this.chat.id);
            if (this.chat.isMuted && this.onUnmute) {
              this.onUnmute(chatId);
            } else if (!this.chat.isMuted && this.onMute) {
              this.onMute(chatId);
            }
          }
        })

      Button((this.chat?.unreadCount && this.chat.unreadCount > 0) || this.chat?.isMarkedAsUnread ? '标记已读' : '标记未读')
        .fontSize(14)
        .backgroundColor(this.COLOR_ACCENT)
        .height(78)
        .borderRadius(0)
        .onClick(() => {
          if (this.chat) {
            const chatId = parseInt(this.chat.id);
            if ((this.chat.unreadCount && this.chat.unreadCount > 0) || this.chat.isMarkedAsUnread) {
              if (this.onMarkAsRead) {
                this.onMarkAsRead(chatId);
              }
            } else if (this.onMarkAsUnread) {
              this.onMarkAsUnread(chatId);
            }
          }
        })
    }
    .width('100%')
    .height(78)
  }

  build() {
    ListItem() {
      this.buildChatItem()
    }
    .swipeAction(this.isSelectionMode ? {} : {
      start: { builder: () => this.buildRightSwipeMenu(), actionAreaDistance: 80 },
      end: { builder: () => this.buildLeftSwipeMenu(), actionAreaDistance: 80 }
    })
  }
}
