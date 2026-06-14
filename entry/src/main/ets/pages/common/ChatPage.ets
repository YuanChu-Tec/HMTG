// ChatPage.ets
import { router, promptAction } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { TopImmersiveContainer } from '../../components/common/ImmersiveContainer';
import { ThemeMode } from '../../utils/utils/ImmersiveUtils';
import { ChatPageViewModel, ChatPageParams, MessageDataSource } from './viewmodels/ChatPageViewModel';
import { ChatType, Message, MessageType, MessageContent, TextEntity, ForwardInfo,
  PollOption, GroupEventType, MessageReaction, InlineKeyboardMarkup, InlineKeyboardRow,
  InlineKeyboardButton, ReplyKeyboardMarkup, KeyboardButton, FormattedText, SystemMessageType } from '../../models/TDLibData';
import { EventBus } from '../../utils/event/EventBus';

const TAG = 'ChatPage';
const DOMAIN = 0x0001;
const INPUT_AREA_HEIGHT = 72;
const BUBBLE_MAX_WIDTH = '75%';

/**
 * 文本片段接口（用于富文本渲染）
 */
interface TextSpan {
  text: string;
  style: string;
  url?: string;
  userId?: number;
}

@Entry({ routeName: 'ChatPage' })
@ComponentV2
export struct ChatPage {
  // ⭐ 支持作为子组件直接传入参数（平板模式）
  @Param chatId: number = 0;
  @Param chatType: ChatType = ChatType.PRIVATE;
  @Param title: string = '';
  @Param avatar: string = '';
  
  // ⭐ 平板模式回调：点击返回时通知父组件取消选中
  @Param onChatDeselected: () => void = () => {};

  // 使用 @Local 装饰器确保每次进入页面都创建新的 ViewModel 实例
  // 避免不同聊天之间的消息错位问题
  @Local viewModel: ChatPageViewModel = new ChatPageViewModel();
  private listScroller: Scroller = new Scroller();
  private eventBus: EventBus = EventBus.getInstance();
  private scrollToMessageHandler: (data?: Object) => void = (data?: Object) => {
    if (!data) return;
    const msgId = (data as Record<string, Object>)['messageId'] as number;
    this.scrollToMessage(msgId);
  };
  private scrollToBottomHandler: (data?: Object) => void = () => {
    // 延迟滚动，确保 List 已渲染
    setTimeout(() => {
      this.scrollToBottom();
    }, 50);
  };
  
  /**
   * ⭐ Telegram 风格：滚动到锚点消息
   */
  private scrollToAnchorHandler: (data?: Object) => void = (data?: Object) => {
    if (!data) return;
    const anchorMessageId = (data as Record<string, Object>)['anchorMessageId'] as number;
    if (anchorMessageId > 0) {
      hilog.info(0x0001, 'ChatPage', `⭐ Scrolling to anchor message ${anchorMessageId}`);
      // 延迟滚动，确保 List 已渲染完成
      setTimeout(() => {
        this.scrollToMessage(anchorMessageId);
      }, 150); // 比普通的 scrollToBottom 多等一点时间，确保双向加载完成
    }
  };

  aboutToAppear(): void {
    hilog.info(0x0001, 'ChatPage', `aboutToAppear called`);
    
    // ⭐ 优先使用 @Param 属性传参（平板模式），否则从 router.getParams 获取（手机模式）
    let params: ChatPageParams;
    if (this.chatId !== 0) {
      // 平板模式：直接使用 @Param 属性
      params = {
        chatId: this.chatId,
        chatType: this.chatType,
        title: this.title,
        avatar: this.avatar
      };
      hilog.info(0x0001, 'ChatPage', `Using @Param props: chatId=${params.chatId}, title=${params.title}`);
    } else {
      // 手机模式：从 router 获取参数
      params = router.getParams() as ChatPageParams;
      hilog.info(0x0001, 'ChatPage', `Using router params: chatId=${params.chatId}`);
    }
    
    hilog.info(0x0001, 'ChatPage', `Current chatId: ${this.viewModel.chatId}, new chatId: ${params.chatId}, messages count: ${this.viewModel.messageDataSource.totalCount()}`);
    
    // 确保进入页面时重新创建 ViewModel，避免消息错位
    // 注意：@Local 会在组件创建时自动初始化，但这里显式重新创建以确保隔离
    if (this.viewModel.chatId !== 0 && this.viewModel.chatId !== params.chatId) {
      // 如果 chatId 不同，需要清理并重新初始化
      hilog.info(0x0001, 'ChatPage', `Switching chat from ${this.viewModel.chatId} to ${params.chatId}, cleaning up...`);
      this.viewModel.cleanup();
    }
    this.viewModel.init(params);
    // 监听滚动到消息事件
    this.eventBus.on('scrollToMessage', this.scrollToMessageHandler);
    // 监听滚动到底部事件
    this.eventBus.on('scrollToBottom', this.scrollToBottomHandler);
    // ⭐ 监听滚动到锚点事件（Telegram 风格）
    this.eventBus.on('scrollToAnchor', this.scrollToAnchorHandler);
  }

  // 页面显示时调用（从其他页面返回时也会触发）
  onPageShow(): void {
    hilog.info(0x0001, 'ChatPage', `onPageShow called, chatId: ${this.viewModel.chatId}, messages count: ${this.viewModel.messageDataSource.totalCount()}`);
    // 如果消息突然变少，可能是数据被意外清空，尝试重新加载
    if (this.viewModel.chatId !== 0 && this.viewModel.messageDataSource.totalCount() === 0) {
      hilog.warn(0x0001, 'ChatPage', 'Messages empty on page show, reloading...');
      
      // ⭐ 优先使用 @Param 属性传参（平板模式），否则从 router.getParams 获取（手机模式）
      let params: ChatPageParams;
      if (this.chatId !== 0) {
        params = {
          chatId: this.chatId,
          chatType: this.chatType,
          title: this.title,
          avatar: this.avatar
        };
      } else {
        params = router.getParams() as ChatPageParams;
      }
      this.viewModel.init(params);
    }
  }

  private scrollToBottom(): void {
    const messageCount = this.viewModel.messageDataSource.totalCount();
    if (messageCount > 0) {
      // ⭐ 滚动到底部占位项（索引 = 消息总数），让最后一条消息显示在输入框上方
      const placeholderIndex = messageCount;
      hilog.info(0x0001, 'ChatPage', `Scrolling to placeholder index: ${placeholderIndex}, messages: ${messageCount}`);
      setTimeout(() => {
        this.listScroller.scrollToIndex(placeholderIndex, false, ScrollAlign.END);
      }, 100);
    }
  }

  aboutToDisappear(): void {
    this.viewModel.cleanup();
    this.eventBus.off('scrollToMessage', this.scrollToMessageHandler);
    this.eventBus.off('scrollToBottom', this.scrollToBottomHandler);
    // ⭐ 取消监听滚动到锚点事件
    this.eventBus.off('scrollToAnchor', this.scrollToAnchorHandler);
    // 清理预加载防抖计时器
    if (this.preloadDebounceTimer !== -1) {
      clearTimeout(this.preloadDebounceTimer);
      this.preloadDebounceTimer = -1;
    }
    // 清理富文本片段缓存
    this.textSpansCache.clear();
  }

  private scrollToMessage(messageId: number): void {
    const index = this.viewModel.messageDataSource.getIndexById(messageId);
    if (index !== -1) {
      this.listScroller.scrollToIndex(index, true);
    }
  }

  /**
   * 加载更多历史消息并保持锚点位置
   * 在加载前记录当前可见区域锚点，加载完成后滚动回该位置
   */
  private loadMoreWithAnchor(): void {
    // 记录当前可见区域第一条消息的ID作为锚点
    const totalCount = this.viewModel.messageDataSource.totalCount();
    const anchorMessageId = totalCount > 0 && this.currentStartIndex < totalCount
      ? this.viewModel.messageDataSource.getData(this.currentStartIndex).id
      : 0;
    const anchorIndex = this.currentStartIndex;

    this.viewModel.loadMoreMessages().then((newMessageCount: number) => {
      // 如果加载到了新消息，需要调整滚动位置到锚点消息的新索引
      if (newMessageCount > 0 && anchorMessageId > 0) {
        // 新消息插入到了前面，锚点消息的索引会增加
        const newAnchorIndex = anchorIndex + newMessageCount;
        if (newAnchorIndex < this.viewModel.messageDataSource.totalCount()) {
          // 使用 scrollToIndex 滚动到锚点位置，false 表示无动画
          this.listScroller.scrollToIndex(newAnchorIndex, false, ScrollAlign.START);
        }
      }
    });
  }

  // ==================== UI 构建 ====================
  @Builder
  private buildTopBar() {
    // 多选模式和普通模式使用条件渲染
    if (this.viewModel.isMultiSelectMode) {
      this.buildMultiSelectToolbar()
    } else {
      this.buildNormalTopBar()
    }
  }

  @Builder
  private buildNormalTopBar() {
    Row() {
      Text('←')
        .fontSize(28)
        .fontColor('#007AFF')
        .onClick(() => {
          // ⭐ 平板模式：调用回调函数通知父组件取消选中
          if (this.chatId !== 0 && this.onChatDeselected) {
            hilog.info(0x0001, 'ChatPage', 'Tablet mode: calling onChatDeselected callback');
            this.onChatDeselected();
            return;
          }
          // 手机模式：正常返回
          router.back();
        })

      Stack() {
        if (this.viewModel.chatAvatar) {
          Image(this.viewModel.chatAvatar)
            .width(36)
            .height(36)
            .borderRadius(18)
            .objectFit(ImageFit.Cover)
        } else {
          Circle()
            .width(36)
            .height(36)
            .fill(this.getAvatarColor(this.viewModel.chatTitle))
          Text(this.viewModel.chatTitle.charAt(0).toUpperCase())
            .fontSize(18)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }

        // 秘密聊天加密标识
        if (this.viewModel.chatType === ChatType.SECRET) {
          Text('🔒')
            .fontSize(14)
            .position({ x: 22, y: 22 })
            .backgroundColor('#4CAF50')
            .borderRadius(10)
            .padding(2)
        }
      }
        .margin({ left: 12, right: 12 })

      Column() {
        Row() {
          Text(this.viewModel.chatTitle)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#000000')
          if (this.viewModel.chatType === ChatType.BOT) {
            Text(' 🤖').fontSize(14).fontColor('#8E8E93')
          } else if (this.viewModel.chatType === ChatType.GROUP) {
            Text(' 👥').fontSize(14).fontColor('#8E8E93')
          } else if (this.viewModel.chatType === ChatType.CHANNEL) {
            Text(' 📢').fontSize(14).fontColor('#8E8E93')
          }
        }
        if (this.viewModel.showTypingIndicator) {
          Text(this.viewModel.typingText)
            .fontSize(12)
            .fontColor('#8E8E93')
            .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
        } else if (this.viewModel.connectionState === 'connecting') {
          Text($r('app.string.auth_code_wait_hint')).fontSize(12).fontColor('#8E8E93')
        } else {
          Text('').fontSize(12)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.viewModel.chatType !== ChatType.CHANNEL && this.viewModel.chatType !== ChatType.BOT) {
        SymbolGlyph($r('sys.symbol.phone'))
          .width(24)
          .height(24)
          .fontColor(['#007AFF'])
          .margin({ right: 16 })
          .onClick(() => this.startCall())
      }

      SymbolGlyph($r('sys.symbol.more'))
        .width(24)
        .height(24)
        .fontColor(['#007AFF'])
        .onClick(() => router.pushUrl({ url: 'pages/ChatInfoPage', params: { chatId: this.viewModel.chatId } }))
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .alignItems(VerticalAlign.Center)
  }

  private async startCall(): Promise<void> {
    promptAction.showToast({ message: $r('app.string.starting_voice_call'), duration: 1500 });
  }

  /**
   * 构建多选工具栏
   */
  @Builder
  private buildMultiSelectToolbar() {
    Row() {
      // 关闭按钮
      Text('✕')
        .fontSize(24)
        .fontColor('#007AFF')
        .onClick(() => this.viewModel.exitMultiSelectMode())

      // 选中数量
      Text(`${this.viewModel.getSelectedCount()} 条消息`)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#000000')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 全选按钮
      Text('全选')
        .fontSize(16)
        .fontColor('#007AFF')
        .onClick(() => {
          // TODO: 实现全选
          promptAction.showToast({ message: '全选功能即将上线', duration: 1500 });
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .alignItems(VerticalAlign.Center)
  }

  /**
   * 构建多选底部操作栏
   */
  @Builder
  private buildMultiSelectBottomBar() {
    Row() {
      Column() {
        Text('📤').fontSize(24)
        Text('转发').fontSize(12).margin({ top: 4 })
      }
      .layoutWeight(1)
      .onClick(() => this.viewModel.forwardSelectedMessages())

      Column() {
        Text('📋').fontSize(24)
        Text('复制').fontSize(12).margin({ top: 4 })
      }
      .layoutWeight(1)
      .onClick(() => this.viewModel.copySelectedMessages())

      Column() {
        Text('🗑️').fontSize(24)
        Text('删除').fontSize(12).margin({ top: 4 }).fontColor('#FA2A2D')
      }
      .layoutWeight(1)
      .onClick(() => this.viewModel.deleteSelectedMessages())
    }
    .width('100%')
    .height(72)
    .padding({ left: 24, right: 24 })
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 0.5 }, color: '#E5E5EA' })
  }

  private getAvatarColor(title: string): string {
    const colors = ['#FF6B35', '#007AFF', '#4CAF50', '#FFA500', '#9C27B0', '#FA2A2D'];
    let hash = 0;
    for (let i = 0; i < title.length; i++) hash = title.charCodeAt(i) + ((hash << 5) - hash);
    return colors[Math.abs(hash) % colors.length];
  }

  @Builder
  private buildAttachmentItem(icon: string, label: Resource, action: () => void) {
    Column() {
      Text(icon).fontSize(28)
      Text(label).fontSize(12).fontColor('#8E8E93').margin({ top: 4 })
    }
    .onClick(() => {
      this.viewModel.showAttachmentMenu = false;
      action();
    })
  }

  @Builder
  private buildFloatingInputArea() {
    Column() {
      // 机器人命令建议
      if (this.viewModel.showCommandSuggestions && this.viewModel.chatType === ChatType.BOT) {
        this.buildCommandSuggestions()
      }

      // 回复键盘（机器人）
      if (this.viewModel.showReplyKeyboard && this.viewModel.replyKeyboard) {
        this.buildReplyKeyboard(this.viewModel.replyKeyboard)
      }

      if (this.viewModel.showAttachmentMenu && this.viewModel.canSendMessages) {
        Column() {
          Row() {
            this.buildAttachmentItem('📷', $r('app.string.media_image_title'), () => this.viewModel.sendPhoto())
            this.buildAttachmentItem('🎥', $r('app.string.media_video_title'), () => this.viewModel.sendVideo())
            this.buildAttachmentItem('📎', $r('app.string.shared_media_files'), () => this.viewModel.sendFile())
            this.buildAttachmentItem('📍', $r('app.string.location'), () => this.viewModel.sendLocation())
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)
          .padding(12)
        }
        .width('90%')
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetY: -2 })
        .margin({ bottom: 8 })
      }

      // 频道提示（当无法发送消息时）
      if (!this.viewModel.canSendMessages && this.viewModel.chatType === ChatType.CHANNEL) {
        Row() {
          Text('📢 频道消息')
            .fontSize(14)
            .fontColor('#8E8E93')
          if (this.viewModel.discussionChatId) {
            Button('进入讨论')
              .fontSize(12)
              .fontColor('#007AFF')
              .backgroundColor('transparent')
              .onClick(() => {
                // 跳转到讨论群组
                router.pushUrl({
                  url: 'pages/common/ChatPage',
                  params: {
                    chatId: this.viewModel.discussionChatId,
                    chatType: ChatType.GROUP,
                    title: '讨论群组'
                  } as ChatPageParams
                });
              })
          }
        }
        .width('90%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#F5F5F5')
        .borderRadius(28)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
      } else {
        Row() {
          Text('📎')
            .fontSize(24)
            .fontColor(this.viewModel.canSendMessages ? '#8E8E93' : '#C7C7CC')
            .onClick(() => {
              if (this.viewModel.canSendMessages) {
                this.viewModel.showAttachmentMenu = !this.viewModel.showAttachmentMenu;
                this.viewModel.showEmojiPicker = false;
              }
            })

          TextInput({ placeholder: this.viewModel.getInputPlaceholder(), text: this.viewModel.inputText })
            .type(InputType.Normal)
            .layoutWeight(1)
            .height(40)
            .backgroundColor('#F5F5F5')
            .borderRadius(20)
            .padding({ left: 16, right: 16 })
            .enabled(this.viewModel.canSendMessages && !this.viewModel.isSending)
            .onChange((value: string) => { this.viewModel.onInputTextChange(value); })
            .onSubmit(() => this.viewModel.sendTextMessage())
            .margin({ left: 8, right: 8 })

          if (this.viewModel.chatType !== ChatType.CHANNEL && this.viewModel.canSendMessages) {
            Text('😊')
              .fontSize(24)
              .fontColor('#8E8E93')
              .margin({ right: 8 })
              .onClick(() => { this.viewModel.showEmojiPicker = !this.viewModel.showEmojiPicker; this.viewModel.showAttachmentMenu = false; })
          }

          if (this.viewModel.inputText.trim() && this.viewModel.canSendMessages) {
            Button($r('app.string.send_button'))
              .type(ButtonType.Normal)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#007AFF')
              .borderRadius(20)
              .height(40)
              .padding({ left: 16, right: 16 })
              .onClick(() => this.viewModel.sendTextMessage())
          } else if (this.viewModel.chatType !== ChatType.CHANNEL && this.viewModel.canSendMessages) {
            SymbolGlyph($r('sys.symbol.mic'))
              .width(24)
              .height(24)
              .fontColor(['#007AFF'])
              .onClick(() => this.viewModel.startRecording())
          }
        }
        .width('90%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        .borderRadius(28)
        .shadow({ radius: 16, color: 'rgba(0,0,0,0.15)', offsetY: 4 })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
      }
    }
    .width('100%')
    .position({ x: 0, y: '100%' })
    .translate({ x: 0, y: -INPUT_AREA_HEIGHT })
    .alignItems(HorizontalAlign.Center)
  }

  // 当前可见区域第一条消息的索引（用于加载更多时保持位置）
  private currentStartIndex: number = 0;
  // 提前加载阈值：当距离顶部还有几条消息时开始加载
  private readonly PRELOAD_THRESHOLD: number = 5;
  // 预加载防抖计时器
  private preloadDebounceTimer: number = -1;
  // 富文本片段缓存，避免每次重新计算
  private textSpansCache: Map<number, TextSpan[]> = new Map();

  @Builder
  private buildMessageList() {
    if (this.viewModel.isLoading) {
      Column() {
        LoadingProgress().width(40).height(40).color('#3390F0')
        Text($r('app.string.loading_text')).fontSize(14).fontColor('#8E8E93').margin({ top: 12 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.viewModel.messageDataSource.totalCount() === 0) {
      Column() {
        SymbolGlyph($r('sys.symbol.message')).width(100).height(100).fontColor(['#C7C7CC']).opacity(0.3)
        Text($r('app.string.no_messages_yet')).fontSize(14).fontColor('#C7C7CC').margin({ top: 12 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List({ scroller: this.listScroller }) {
        // 使用 LazyForEach 替代 ForEach，实现按需加载和组件复用
        // 大幅提升长列表性能，万条数据首屏加载从6秒降至1.7秒
        LazyForEach(this.viewModel.messageDataSource, (message: Message, index: number) => {
          ListItem() {
            this.buildMessageItemWithPrev(message, index)
          }
        }, (message: Message) => message.id.toString())

        // ⭐ 底部占位：让最后一条消息可以滚动到输入框上方可见，同时消息列表可延伸到输入框背后
        ListItem() {
          Row()
            .width('100%')
            .height(INPUT_AREA_HEIGHT + 16)
            .backgroundColor(Color.Transparent)
        }
      }
      .layoutWeight(1)
      .width('100%')
      .cachedCount(20)
      // 禁用 maintainVisibleContentPosition，使用手动滚动控制
      // 避免与初始滚动到底部的逻辑冲突
      // .maintainVisibleContentPosition(true)
      // 监听滚动索引变化，记录当前可见区域并提前触发加载
      .onScrollIndex((start: number, end: number) => {
        this.currentStartIndex = start;
        // 提前加载：当滚动到距离顶部还有 PRELOAD_THRESHOLD 条消息时触发加载
        // 注意：消息数组是 [旧消息, ..., 新消息] 顺序
        // start=0 表示显示的是最旧的消息（顶部），需要加载更早的历史
        if (start <= this.PRELOAD_THRESHOLD &&
            this.viewModel.hasMoreMessages &&
            !this.viewModel.isLoadingMore &&
            this.preloadDebounceTimer === -1) {
          hilog.info(0x0001, 'ChatPage', `Approaching top (index=${start}), preloading more messages...`);
          // 设置防抖，避免频繁触发
          this.preloadDebounceTimer = setTimeout(() => {
            this.loadMoreWithAnchor();
            this.preloadDebounceTimer = -1;
          }, 200);
        }
      })
      // 当滚动到顶部时触发加载更多历史消息（作为备用触发机制）
      // 注意：消息按时间顺序排列（旧消息在前，新消息在后）
      // 滚动到顶部意味着用户想查看更早的历史消息
      .onReachStart(() => {
        hilog.info(0x0001, 'ChatPage', 'List reached start (oldest messages), loading more history...');
        this.loadMoreWithAnchor();
      })
    }

    // 上下文菜单（长按显示）
    if (this.viewModel.showContextMenu && this.viewModel.selectedMessageId) {
      this.buildContextMenu()
    }
  }

  @Builder
  private buildContextMenu() {
    Column() {
      Column() {
        Text($r('app.string.copy')).fontSize(16).padding(12).width('100%').onClick(() => this.viewModel.copyMessageText())
        Divider().height(0.5).color('#E5E5EA')
        Text($r('app.string.reply')).fontSize(16).padding(12).width('100%').onClick(() => this.viewModel.replyToMessage(this.viewModel.selectedMessageId!))
        Divider().height(0.5).color('#E5E5EA')
        Text($r('app.string.forward')).fontSize(16).padding(12).width('100%').onClick(() => this.viewModel.forwardMessage(this.viewModel.selectedMessageId!))
        Divider().height(0.5).color('#E5E5EA')
        Text('多选').fontSize(16).padding(12).width('100%').onClick(() => {
          this.viewModel.enterMultiSelectMode(this.viewModel.selectedMessageId!);
          this.viewModel.showContextMenu = false;
        })
        Divider().height(0.5).color('#E5E5EA')
        Text($r('app.string.delete')).fontSize(16).fontColor('#FA2A2D').padding(12).width('100%').onClick(() => this.viewModel.deleteMessage())
      }
      .width(200)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.2)' })
    }
    .position({ x: '50%', y: '50%' })
    .translate({ x: '-50%', y: '-50%' })
    .onClick(() => { this.viewModel.showContextMenu = false; })
  }

  /**
   * ⭐ 辅助 Builder：处理前一条消息逻辑并构建消息项
   */
  @Builder
  private buildMessageItemWithPrev(message: Message, index: number) {
    Column() {
      this.buildMessageItem(message, index > 0 ? this.viewModel.messageDataSource.getData(index - 1) : null)
    }
    .width('100%')
    .gesture(
      LongPressGesture()
        .onAction(() => {
          this.viewModel.showMessageContextMenu(message.id);
        })
    )
  }

  @Builder
  private buildMessageItem(message: Message, prevMessage: Message | null) {
    // ⭐ 使用条件渲染：系统消息居中显示，普通消息左右显示
    if (message.type === MessageType.SYSTEM || message.type === MessageType.GROUP_EVENT) {
      this.buildSystemMessageItem(message)
    } else {
      this.buildNormalMessageItem(message, prevMessage)
    }
  }

  /**
   * ⭐ 构建普通消息项（左右气泡样式）
   */
  @Builder
  private buildNormalMessageItem(message: Message, prevMessage: Message | null) {
    Row() {
      // 多选复选框
      if (this.viewModel.isMultiSelectMode) {
        Checkbox()
          .select(this.viewModel.isMessageSelected(message.id))
          .selectedColor('#3390F0')
          .width(24)
          .height(24)
          .margin({ right: 8 })
          .onChange((selected: boolean) => {
            this.viewModel.toggleMessageSelection(message.id);
          })
      }

      // ⭐ 判断消息是否显示在左侧
      // 对于频道消息，即使 isOutgoing=true（以频道身份发送），也显示在左侧
      if (this.shouldShowOnLeft(message)) {
        // ⭐ 群组消息显示头像和用户名（包括 SUPERGROUP）
        // ⭐ 连续消息折叠：只有第一条或发送者变化时才显示头像
        if ((this.viewModel.chatType === ChatType.GROUP || this.viewModel.chatType === ChatType.SUPERGROUP) && !message.isOutgoing) {
          if (this.shouldShowAvatar(message, prevMessage)) {
            this.buildMessageWithAvatar(message, true)
          } else {
            // 连续消息：隐藏头像，但保留缩进以保持对齐
            this.buildMessageBubbleWithSenderName(message, true, false)
          }
        } else {
          this.buildMessageBubble(message, true)
        }
        Blank().layoutWeight(1)
      } else {
        Blank().layoutWeight(1)
        this.buildMessageBubble(message, false)
      }
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
    .onClick(() => {
      if (this.viewModel.isMultiSelectMode) {
        this.viewModel.toggleMessageSelection(message.id);
      }
    })
  }

  /**
   * ⭐ 构建系统消息项（居中显示，不带头像、无左右之分）
   */
  @Builder
  private buildSystemMessageItem(message: Message) {
    Row() {
      // 根据消息类型渲染不同内容
      if (message.type === MessageType.SYSTEM) {
        this.renderSystemMessage(message)
      } else if (message.type === MessageType.GROUP_EVENT) {
        this.renderGroupEventMessageCentered(message)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
  }

  /**
   * ⭐ 构建带头像的消息（用于群组中其他人的消息）
   */
  @Builder
  private buildMessageWithAvatar(message: Message, isLeft: boolean) {
    Row() {
      // 头像（左侧）
      Stack() {
        if (message.senderAvatar) {
          Image(message.senderAvatar)
            .width(36)
            .height(36)
            .borderRadius(18)
            .objectFit(ImageFit.Cover)
        } else {
          Circle()
            .width(36)
            .height(36)
            .fill(this.getAvatarColor(message.senderName || ''))
          Text((message.senderName || '?').charAt(0).toUpperCase())
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
      }
      .margin({ right: 8 })

      // 消息气泡（包含用户名在内部）
      this.buildMessageBubbleWithSenderName(message, isLeft, true)
    }
    .alignItems(VerticalAlign.Top)
  }

  /**
   * ⭐ 构建带用户名的消息气泡（用户名在气泡内部顶部）
   * @param showAvatar 是否显示头像（用于连续消息折叠）
   */
  @Builder
  private buildMessageBubbleWithSenderName(message: Message, isLeft: boolean, showAvatar: boolean = true) {
    Column() {
      // 转发来源标识
      if (message.forwardInfo) {
        this.buildForwardInfo(message.forwardInfo, isLeft)
      }

      Stack() {
        Column() {
          // ⭐ 用户名（在气泡内部顶部，连续消息时隐藏）
          if (showAvatar && message.senderName) {
            Text(message.senderName)
              .fontSize(13)
              .fontColor(isLeft ? '#3390F0' : 'rgba(255,255,255,0.9)')
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ bottom: 6 })
              .width('100%')
              .textAlign(TextAlign.Start)
          }

          // ⭐ 回复引用（在气泡内部，消息内容上方）
          if (message.replyToMessageId && message.replyToMessageId > 0) {
            this.buildReplyQuote(message, isLeft)
          }

          this.renderMessageContent(message, isLeft)

          // 作者签名（频道消息）
          if (message.authorSignature) {
            Text(message.authorSignature)
              .fontSize(11)
              .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
              .margin({ top: 4 })
              .width('100%')
              .textAlign(TextAlign.Start)
          }

          Row() {
            Text(this.viewModel.formatTime(message.timestamp))
              .fontSize(11)
              .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
            if (message.isEdited) {
              Text(' ' + $r('app.string.edited'))
                .fontSize(11)
                .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
                .margin({ left: 4 })
            }
            if (message.isOutgoing && message.status) {
              Text(this.viewModel.getMessageStatusIcon(message))
                .fontSize(11)
                .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
                .margin({ left: 4 })
            }
            // 频道消息阅读数
            if (message.views !== undefined && this.viewModel.chatType === ChatType.CHANNEL) {
              Text(` 👁 ${this.formatViews(message.views)}`)
                .fontSize(11)
                .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
                .margin({ left: 4 })
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
          .margin({ top: 4 })
        }
        .width('100%')
        .padding(12)
        .backgroundColor(isLeft ? '#F0F0F0' : '#3390F0')
        .borderRadius({
          topLeft: isLeft ? 4 : 20,
          topRight: isLeft ? 20 : 4,
          bottomLeft: 20,
          bottomRight: 20
        })
        .alignItems(HorizontalAlign.Start)
      }
      .width(BUBBLE_MAX_WIDTH)

      // 频道帖子底部互动栏（浏览量 + 评论按钮）
      if (message.forwardInfo && message.forwardInfo.isChannelPost) {
        this.buildChannelPostFooter(message, isLeft)
      }

      // 消息反应（表情）
      if (message.reactions && message.reactions.length > 0) {
        this.buildReactions(message.reactions, isLeft)
      }

      // 内联键盘（机器人消息）
      if (message.inlineKeyboard && message.inlineKeyboard.rows.length > 0) {
        this.buildInlineKeyboard(message.inlineKeyboard, message.id)
      }
    }
    .alignItems(isLeft ? HorizontalAlign.Start : HorizontalAlign.End)
  }

  /**
   * ⭐ 判断消息是否应该显示在左侧
   * - 非自己发送的消息显示在左侧
   * - 频道中以频道身份发送的消息（isChannelPost=true）显示在左侧
   */
  private shouldShowOnLeft(message: Message): boolean {
    // 非自己发送的消息显示在左侧
    if (!message.isOutgoing) {
      return true;
    }
    // 频道中以频道身份发送的消息显示在左侧（作为接收方视角）
    if (message.isChannelPost && this.viewModel.chatType === ChatType.CHANNEL) {
      return true;
    }
    return false;
  }

  /**
   * ⭐ 判断是否显示发送者头像（仅群组且非自己发送且不是连续相同发送者）
   */
  private shouldShowAvatar(message: Message, prevMessage: Message | null): boolean {
    if (message.isOutgoing) return false; // 自己发送的不显示头像
    if (this.viewModel.chatType !== ChatType.GROUP && this.viewModel.chatType !== ChatType.SUPERGROUP) {
      return false;
    }
    // 只有第一条或发送者变化时才显示头像
    if (!prevMessage || prevMessage.senderId !== message.senderId) return true;
    return false;
  }

  /**
   * ⭐ 判断是否显示发送者名称（群组且非自己发送且不是连续相同发送者）
   */
  private shouldShowSenderName(message: Message, prevMessage: Message | null): boolean {
    if (message.isOutgoing) return false;
    if (this.viewModel.chatType !== ChatType.GROUP && this.viewModel.chatType !== ChatType.SUPERGROUP) {
      return false;
    }
    // 只有第一条或发送者变化时才显示名称
    if (!prevMessage || prevMessage.senderId !== message.senderId) return true;
    return false;
  }

  @Builder
  private buildMessageBubble(message: Message, isLeft: boolean) {
    Column() {
      // 转发来源标识
      if (message.forwardInfo) {
        this.buildForwardInfo(message.forwardInfo, isLeft)
      }
      // 消息内容
      Stack() {
        Column() {
          // ⭐ 回复引用（在气泡内部，消息内容上方）
          if (message.replyToMessageId && message.replyToMessageId > 0) {
            this.buildReplyQuote(message, isLeft)
          }

          // ⭐ API 24: Text 组件支持根据坐标获取字符位置信息，优化富文本交互
          this.renderMessageContent(message, isLeft)

          // 作者签名（频道消息）
          if (message.authorSignature) {
            Text(message.authorSignature)
              .fontSize(11)
              .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
              .margin({ top: 4 })
              .width('100%')
              .textAlign(TextAlign.Start)
          }

          Row() {
            Text(this.viewModel.formatTime(message.timestamp))
              .fontSize(11)
              .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
            if (message.isEdited) {
              Text(' ' + $r('app.string.edited'))
                .fontSize(11)
                .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
                .margin({ left: 4 })
            }
            if (message.isOutgoing && message.status) {
              Text(this.viewModel.getMessageStatusIcon(message))
                .fontSize(11)
                .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
                .margin({ left: 4 })
            }
            // 频道消息阅读数
            if (message.views !== undefined && this.viewModel.chatType === ChatType.CHANNEL) {
              Text(` 👁 ${this.formatViews(message.views)}`)
                .fontSize(11)
                .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
                .margin({ left: 4 })
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
          .margin({ top: 4 })
        }
        .width('100%')
        .padding(12)
        .backgroundColor(isLeft ? '#F0F0F0' : '#3390F0')
        .borderRadius({
          topLeft: isLeft ? 4 : 20,
          topRight: isLeft ? 20 : 4,
          bottomLeft: 20,
          bottomRight: 20
        })
        .alignItems(HorizontalAlign.Start)
      }
      .width(BUBBLE_MAX_WIDTH)

      // ⭐ 频道帖子底部互动栏（浏览量 + 评论按钮）
      if (message.forwardInfo && message.forwardInfo.isChannelPost) {
        this.buildChannelPostFooter(message, isLeft)
      }

      // 消息反应（表情）
      if (message.reactions && message.reactions.length > 0) {
        this.buildReactions(message.reactions, isLeft)
      }

      // 内联键盘（机器人消息）
      if (message.inlineKeyboard && message.inlineKeyboard.rows.length > 0) {
        this.buildInlineKeyboard(message.inlineKeyboard, message.id)
      }
    }
    .alignItems(isLeft ? HorizontalAlign.Start : HorizontalAlign.End)
  }

  /**
   * 构建命令建议列表
   */
  @Builder
  private buildCommandSuggestions() {
    // 简化版本，避免在 Builder 中使用变量声明
    Column() {
      Text('命令建议').fontSize(14).fontColor('#3390F0').padding(12)
    }
    .width('90%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetY: -2 })
    .margin({ bottom: 8 })
    .height(100)
  }

  /**
   * 构建回复键盘（显示在输入区上方）
   */
  @Builder
  private buildReplyKeyboard(keyboard: ReplyKeyboardMarkup) {
    // 简化版本，避免在 ForEach 中使用复杂类型
    Column() {
      Text('回复键盘').fontSize(14).fontColor('#3390F0').padding(12)
    }
    .width('90%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetY: -2 })
    .margin({ bottom: 8 })
  }

  /**
   * 渲染富文本消息（使用 FormattedText + TextEntity 完整支持所有格式）
   */
  @Builder
  private renderRichTextMessage(message: Message, isLeft: boolean) {
    // 使用辅助 Builder 方法避免在 Builder 中声明变量
    this.renderFormattedText(message, isLeft)
  }

  /**
   * 辅助 Builder 方法 - 根据是否有富文本格式决定如何渲染
   */
  @Builder
  private renderFormattedText(message: Message, isLeft: boolean) {
    // 检查是否有富文本格式
    if (!message.formattedText || message.formattedText.entities.length === 0) {
      // 没有富文本格式，直接渲染纯文本
      this.renderPlainText(message, isLeft)
    } else {
      // 有富文本格式，使用 Span 渲染
      this.renderRichTextSpans(message, isLeft)
    }
  }

  /**
   * 渲染纯文本消息
   */
  @Builder
  private renderPlainText(message: Message, isLeft: boolean) {
    Text(this.getMessageText(message))
      .fontSize(16)
      .fontColor(isLeft ? '#000000' : '#FFFFFF')
      .width(BUBBLE_MAX_WIDTH)
  }

  /**
   * 获取消息文本内容（普通方法，处理类型转换）
   */
  private getMessageText(message: Message): string {
    if (typeof message.content === 'string') {
      return message.content;
    }
    const content = message.content as Record<string, string>;
    return content.text || '';
  }

  /**
   * 渲染富文本 Span 列表
   */
  @Builder
  private renderRichTextSpans(message: Message, isLeft: boolean) {
    // 预处理文本片段数据，使用 Text 组件包裹 Span
    Text() {
      ForEach(this.buildTextSpans(message), (span: TextSpan, index: number) => {
        this.buildStyledSpan(span, isLeft)
      }, (span: TextSpan, index: number) => `${index}-${span.style}-${span.text.substring(0, 10)}`)
    }
    .fontSize(16)
    .fontColor(isLeft ? '#000000' : '#FFFFFF')
    .width(BUBBLE_MAX_WIDTH)
  }

  /**
   * 构建文本片段数组（在普通方法中执行逻辑）
   */
  private buildTextSpans(message: Message): TextSpan[] {
    // 检查缓存
    if (this.textSpansCache.has(message.id)) {
      return this.textSpansCache.get(message.id)!;
    }

    const formattedText: FormattedText | undefined = message.formattedText;
    if (!formattedText || formattedText.entities.length === 0) {
      return [];
    }

    const text = formattedText.text;
    const entities = formattedText.entities.slice().sort((a, b) => a.offset - b.offset);
    const spans: TextSpan[] = [];
    let currentPos = 0;

    for (const entity of entities) {
      // 添加实体前的普通文本
      if (entity.offset > currentPos) {
        spans.push({
          text: text.substring(currentPos, entity.offset),
          style: 'normal'
        });
      }

      // 根据实体类型创建对应的片段
      const entityText = text.substring(entity.offset, entity.offset + entity.length);
      const span: TextSpan = {
        text: entityText,
        style: this.getEntityStyle(entity.type),
        url: entity.url,
        userId: entity.userId
      };
      spans.push(span);

      currentPos = entity.offset + entity.length;
    }

    // 添加剩余文本
    if (currentPos < text.length) {
      spans.push({
        text: text.substring(currentPos),
        style: 'normal'
      });
    }

    // 存入缓存
    this.textSpansCache.set(message.id, spans);
    return spans;
  }

  /**
   * 获取实体对应的样式类型
   */
  private getEntityStyle(type: string): string {
    switch (type) {
      case 'textEntityTypeBold': return 'bold';
      case 'textEntityTypeItalic': return 'italic';
      case 'textEntityTypeUnderline': return 'underline';
      case 'textEntityTypeStrikethrough': return 'strikethrough';
      case 'textEntityTypeCode': return 'code';
      case 'textEntityTypePre':
      case 'textEntityTypePreCode': return 'pre';
      case 'textEntityTypeUrl': return 'url';
      case 'textEntityTypeTextUrl': return 'textUrl';
      case 'textEntityTypeMention':
      case 'textEntityTypeMentionName': return 'mention';
      case 'textEntityTypeHashtag': return 'hashtag';
      case 'textEntityTypeBotCommand': return 'botCommand';
      case 'textEntityTypeSpoiler': return 'spoiler';
      default: return 'normal';
    }
  }

  /**
   * 根据样式类型构建 Span
   */
  @Builder
  private buildStyledSpan(span: TextSpan, isLeft: boolean) {
    if (span.style === 'bold') {
      Span(span.text)
        .fontWeight(FontWeight.Bold)
    } else if (span.style === 'italic') {
      Span(span.text)
        .fontStyle(FontStyle.Italic)
    } else if (span.style === 'underline') {
      Span(span.text)
        .decoration({ type: TextDecorationType.Underline })
    } else if (span.style === 'strikethrough') {
      Span(span.text)
        .decoration({ type: TextDecorationType.LineThrough })
    } else if (span.style === 'code' || span.style === 'pre') {
      Span(span.text)
        .fontFamily('monospace')
        .backgroundColor('rgba(0,0,0,0.1)')
    } else if (span.style === 'url' || span.style === 'textUrl') {
      Span(span.text)
        .fontColor('#3390F0')
        .decoration({ type: TextDecorationType.Underline })
    } else if (span.style === 'mention' || span.style === 'hashtag' || span.style === 'botCommand') {
      Span(span.text)
        .fontColor('#3390F0')
    } else if (span.style === 'spoiler') {
      Span(span.text)
        .fontColor(isLeft ? '#808080' : '#A0A0A0')
        .backgroundColor(isLeft ? '#808080' : '#A0A0A0')
    } else {
      Span(span.text)
    }
  }

  /**
   * 格式化阅读数
   */
  private formatViews(views: number): string {
    if (views >= 1000000) return (views / 1000000).toFixed(1) + 'M';
    if (views >= 1000) return (views / 1000).toFixed(1) + 'K';
    return views.toString();
  }

  /**
   * 构建消息反应（表情）
   */
  @Builder
  private buildReactions(reactions: MessageReaction[], isLeft: boolean) {
    Row() {
      ForEach(reactions, (reaction: MessageReaction) => {
        Row() {
          Text(reaction.emoji).fontSize(14)
          if (reaction.count > 1) {
            Text(reaction.count.toString())
              .fontSize(11)
              .fontColor(isLeft ? '#8E8E93' : '#3390F0')
              .margin({ left: 2 })
          }
        }
        .padding({ left: 6, right: 6, top: 3, bottom: 3 })
        .backgroundColor(reaction.isSelected ? 'rgba(51,144,240,0.2)' : 'rgba(0,0,0,0.05)')
        .borderRadius(12)
        .margin({ right: 4 })
      }, (reaction: MessageReaction) => reaction.emoji)
    }
    .margin({ top: 4 })
  }

  /**
   * 构建内联键盘
   */
  @Builder
  private buildInlineKeyboard(keyboard: InlineKeyboardMarkup, messageId: number) {
    Column() {
      ForEach(keyboard.rows, (row: InlineKeyboardRow, rowIndex: number) => {
        Row() {
          ForEach(row.buttons, (button: InlineKeyboardButton, btnIndex: number) => {
            Button(button.text)
              .fontSize(13)
              .fontColor('#3390F0')
              .backgroundColor('#FFFFFF')
              .border({ width: 1, color: '#E0E0E0' })
              .borderRadius(4)
              .height(32)
              .layoutWeight(1)
              .margin({ left: btnIndex > 0 ? 4 : 0, right: btnIndex < row.buttons.length - 1 ? 4 : 0 })
              .onClick(() => {
                if (button.callbackData) {
                  this.viewModel.sendCallbackQuery(messageId, button.callbackData);
                } else if (button.url) {
                  // TODO: 打开链接
                  promptAction.showToast({ message: '链接: ' + button.url, duration: 1500 });
                }
              })
          }, (button: InlineKeyboardButton) => button.text)
        }
        .width('100%')
        .margin({ top: rowIndex > 0 ? 4 : 0 })
      }, (row: InlineKeyboardRow, index: number) => index.toString())
    }
    .width(BUBBLE_MAX_WIDTH)
    .margin({ top: 4 })
    .padding(4)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
  }

  @Builder
  private buildForwardInfo(info: ForwardInfo, isLeft: boolean) {
    // ⭐ 频道帖子转发使用特殊渲染
    if (info.isChannelPost) {
      this.buildChannelPostHeader(info, isLeft)
    } else {
      // 普通转发
      Row() {
        Text('↪️ ').fontSize(12).fontColor('#8E8E93')
        Text($r('app.string.forward_from') + ' ' + (info.senderName || $r('app.string.unknown')))
          .fontSize(12)
          .fontColor('#8E8E93')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .margin({ bottom: 4 })
      .padding({ left: 4, right: 4, top: 2, bottom: 2 })
      .backgroundColor('rgba(0,0,0,0.05)')
      .borderRadius(4)
    }
  }

  /**
   * ⭐ 构建频道帖子头部（用于关联群组中的频道帖子转发）
   */
  @Builder
  private buildChannelPostHeader(info: ForwardInfo, isLeft: boolean) {
    Column() {
      // 频道来源标识
      Row() {
        Text('📢')
          .fontSize(16)
          .margin({ right: 6 })
        Text('频道 · ' + (info.senderName || '未知频道'))
          .fontSize(14)
          .fontColor('#3390F0')
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .margin({ bottom: 6 })

      // 通过频道发布提示
      Row() {
        Text('通过 ')
          .fontSize(12)
          .fontColor('#666666')
        Text(info.senderName || '频道')
          .fontSize(12)
          .fontColor('#3390F0')
          .fontWeight(FontWeight.Medium)
        Text(' 发布')
          .fontSize(12)
          .fontColor('#666666')
      }
      .width('100%')
      .margin({ bottom: 4 })
    }
    .margin({ bottom: 8 })
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .backgroundColor('#E8F4FD')
    .borderRadius(12)
    .border({ width: { left: 4 }, color: '#3390F0' })
  }

  /**
   * ⭐ 构建频道帖子底部互动栏（浏览量 + 评论按钮）
   */
  @Builder
  private buildChannelPostFooter(message: Message, isLeft: boolean) {
    // 使用条件渲染，ArkTS @Builder中不能使用变量声明
    this.buildChannelPostFooterContent(message, isLeft)
  }

  /**
   * ⭐ 频道帖子底部内容（辅助Builder）
   */
  @Builder
  private buildChannelPostFooterContent(message: Message, isLeft: boolean) {
    if (message.forwardInfo && message.forwardInfo.isChannelPost) {
      Row() {
        // 浏览量
        Row() {
          Text('👁 ')
            .fontSize(12)
          Text(this.formatNumber(message.forwardInfo.viewCount || 0))
            .fontSize(11)
            .fontColor('#8E8E93')
        }

        Blank().layoutWeight(1)

        // 评论按钮（如果有评论）
        if (message.forwardInfo.replyCount && message.forwardInfo.replyCount > 0) {
          Row() {
            Text('💬 ')
              .fontSize(12)
            Text(message.forwardInfo.replyCount.toString())
              .fontSize(11)
              .fontColor('#3390F0')
              .fontWeight(FontWeight.Medium)
          }
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('rgba(51,144,240,0.1)')
          .borderRadius(12)
          .onClick(() => {
            // 跳转到频道帖子详情
            this.openChannelPost(message.forwardInfo!.originalChatId!, message.forwardInfo!.originalMessageId!)
          })
        } else {
          // 无评论时显示"评论"按钮
          Row() {
            Text('💬 评论')
              .fontSize(11)
              .fontColor('#3390F0')
          }
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .onClick(() => {
            this.openChannelPost(message.forwardInfo!.originalChatId!, message.forwardInfo!.originalMessageId!)
          })
        }
      }
      .width('100%')
      .margin({ top: 8 })
      .padding({ top: 8 })
      .border({ width: { top: 0.5 }, color: 'rgba(0,0,0,0.08)' })
    }
  }

  /**
   * ⭐ 格式化数字（超过1000显示为1k）
   */
  private formatNumber(num: number): string {
    if (num >= 1000000) {
      return (num / 1000000).toFixed(1) + 'M';
    } else if (num >= 1000) {
      return (num / 1000).toFixed(1) + 'k';
    }
    return num.toString();
  }

  /**
   * ⭐ 打开频道帖子详情
   */
  private openChannelPost(channelId: number, messageId: number): void {
    hilog.info(0x0001, 'ChatPage', `Opening channel post: channelId=${channelId}, messageId=${messageId}`);
    // 跳转到频道页面并定位到指定消息
    router.pushUrl({
      url: 'pages/common/ChatPage',
      params: {
        chatId: channelId,
        chatType: ChatType.CHANNEL,
        title: this.viewModel.chatTitle,
        highlightMessageId: messageId
      }
    }).catch((error: Error) => {
      hilog.error(0x0001, 'ChatPage', `Failed to open channel post: ${error.message}`);
      promptAction.showToast({ message: '无法打开频道帖子', duration: 1500 });
    });
  }

  @Builder
  private buildReplyQuote(message: Message, isLeft: boolean) {
    Row() {
      // 左侧装饰条
      Column()
        .width(3)
        .height(36)
        .backgroundColor('#3390F0')
        .margin({ right: 8 })
        .borderRadius(1.5)

      Column() {
        // 被回复者名称
        Text(this.viewModel.getReplySenderName(message.replyToMessageId!))
          .fontSize(12)
          .fontColor('#3390F0')
          .fontWeight(FontWeight.Medium)
          .maxLines(1)

        // 被回复消息内容预览
        Text(this.viewModel.getReplyPreview(message.replyToMessageId!))
          .fontSize(12)
          .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(8)
    .backgroundColor(isLeft ? 'rgba(51,144,240,0.1)' : 'rgba(255,255,255,0.15)')
    .borderRadius(8)
    .margin({ bottom: 8 })
    .onClick(() => this.viewModel.scrollToMessage(message.replyToMessageId!))
  }

  @Builder
  private renderMessageContent(message: Message, isLeft: boolean) {
    // ArkTS @Builder 中不支持 switch-case，使用 if-else 链或辅助方法调用
    this.renderMessageContentByType(message, isLeft)
  }

  /**
   * 辅助方法：根据消息类型渲染内容（普通方法，支持 switch-case）
   */
  @Builder
  private renderMessageContentByType(message: Message, isLeft: boolean) {
    if (message.type === MessageType.TEXT) {
      this.renderTextMessage(message, isLeft)
    } else if (message.type === MessageType.PHOTO) {
      this.renderImageMessage(message, isLeft)
    } else if (message.type === MessageType.VIDEO) {
      this.renderVideoMessage(message, isLeft)
    } else if (message.type === MessageType.AUDIO) {
      this.renderAudioMessage(message, isLeft)
    } else if (message.type === MessageType.DOCUMENT) {
      this.renderFileMessage(message, isLeft)
    } else if (message.type === MessageType.VOICE_NOTE) {
      this.renderVoiceMessage(message, isLeft)
    } else if (message.type === MessageType.VIDEO_NOTE) {
      this.renderVideoNoteMessage(message, isLeft)
    } else if (message.type === MessageType.STICKER) {
      this.renderStickerMessage(message, isLeft)
    } else if (message.type === MessageType.ANIMATION) {
      this.renderGifMessage(message, isLeft)
    } else if (message.type === MessageType.LOCATION || message.type === MessageType.LIVE_LOCATION) {
      this.renderLocationMessage(message, isLeft)
    } else if (message.type === MessageType.CONTACT) {
      this.renderContactMessage(message, isLeft)
    } else if (message.type === MessageType.POLL) {
      this.renderPollMessage(message, isLeft)
    } else if (message.type === MessageType.CALL) {
      this.renderCallMessage(message, isLeft)
    } else if (message.type === MessageType.GAME) {
      this.renderGameMessage(message, isLeft)
    } else if (message.type === MessageType.INVOICE) {
      this.renderInvoiceMessage(message, isLeft)
    } else if (message.type === MessageType.PAYMENT_SUCCESSFUL) {
      this.renderPaymentSuccessfulMessage(message, isLeft)
    } else if (message.type === MessageType.EXPIRED_PHOTO || message.type === MessageType.EXPIRED_VIDEO) {
      this.renderExpiredMediaMessage(message, isLeft)
    } else if (message.type === MessageType.EXPIRED_VOICE_NOTE) {
      this.renderExpiredVoiceMessage(message, isLeft)
    } else if (message.type === MessageType.EXPIRED_VIDEO_NOTE) {
      this.renderExpiredVideoNoteMessage(message, isLeft)
    } else if (message.type === MessageType.DICE) {
      this.renderDiceMessage(message, isLeft)
    } else if (message.type === MessageType.GIFT_PREMIUM || message.type === MessageType.GIFT_CODE) {
      this.renderGiftMessage(message, isLeft)
    } else if (message.type === MessageType.GIVEAWAY || message.type === MessageType.GIVEAWAY_WINNERS) {
      this.renderGiveawayMessage(message, isLeft)
    } else if (message.type === MessageType.SYSTEM) {
      this.renderSystemMessage(message, isLeft)
    } else if (message.type === MessageType.GROUP_EVENT) {
      this.renderGroupEventMessage(message, isLeft)
    } else {
      this.renderUnsupportedMessage(message, isLeft)
    }
  }

  @Builder
  private renderTextMessage(message: Message, isLeft: boolean) {
    // 使用条件表达式替代if语句，ArkTS @Builder中不允许普通TypeScript语句
    this.renderTextMessageContent(message, isLeft)
  }

  @Builder
  private renderTextMessageContent(message: Message, isLeft: boolean) {
    // 根据是否有文本实体选择渲染方式
    if (message.formattedText && message.formattedText.entities && message.formattedText.entities.length > 0) {
      this.renderRichTextMessage(message, isLeft)
    } else {
      // 普通文本 - 使用 getMessageText 正确处理 content 类型
      Text(this.getMessageText(message))
        .fontSize(16)
        .fontColor(isLeft ? '#000000' : '#FFFFFF')
        .maxLines(10)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
  }

  @Builder
  private renderImageMessage(message: Message, isLeft: boolean) {
    Column() {
      Stack() {
        Image(message.file?.path || message.media?.thumbnail)
          .width(200)
          .height(200)
          .objectFit(ImageFit.Cover)
          .borderRadius(12)
          .blur(message.media?.hasSpoiler ? 20 : 0)
          .backgroundColor('#E0E0E0')

        // 剧透遮罩层
        if (message.media?.hasSpoiler) {
          Column() {
            Text('⚠️')
              .fontSize(32)
              .margin({ bottom: 8 })
            Text('剧透')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
          }
          .width(200)
          .height(200)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(0,0,0,0.6)')
          .borderRadius(12)
        }
      }
      .width(200)
      .height(200)

      if (typeof message.content !== 'string' && (message.content as MessageContent)?.caption) {
        Text((message.content as MessageContent).caption!)
          .fontSize(14)
          .fontColor(isLeft ? '#000000' : '#FFFFFF')
          .margin({ top: 4 })
      }
      if (message.isDownloading) {
        Progress({ value: message.downloadProgress || 0, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(4)
          .margin({ top: 4 })
          .color('#3390F0')
      }
    }
    .onClick(() => {
      if (message.media?.hasSpoiler) {
        // 点击剧透消息，移除遮罩
        message.media.hasSpoiler = false;
        return;
      }
      if (!message.file?.path && message.media?.tdlibFileId) {
        this.viewModel.triggerFileDownload(message.media.tdlibFileId);
      } else {
        promptAction.showToast({ message: $r('app.string.cannot_preview'), duration: 1500 });
      }
    })
  }

  @Builder
  private renderVideoMessage(message: Message, isLeft: boolean) {
    Column() {
      Stack() {
        Image(message.file?.path || message.media?.thumbnail)
          .width(200)
          .height(200)
          .objectFit(ImageFit.Cover)
          .borderRadius(12)
          .blur(message.media?.hasSpoiler ? 20 : 0)
          .backgroundColor('#E0E0E0')

        // 播放按钮（仅在非剧透模式下显示）
        if (!message.media?.hasSpoiler) {
          Column() { Text('▶️').fontSize(30) }
          .width(50)
          .height(50)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(0,0,0,0.5)')
          .borderRadius(25)
        }

        // 剧透遮罩层
        if (message.media?.hasSpoiler) {
          Column() {
            Text('⚠️')
              .fontSize(32)
              .margin({ bottom: 8 })
            Text('剧透')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
          }
          .width(200)
          .height(200)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(0,0,0,0.6)')
          .borderRadius(12)
        }
      }
      .width(200)
      .height(200)
      Row() { Text(` ${this.viewModel.formatDuration(message.duration || 0)}`).fontSize(12).fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)') }
      .margin({ top: 4 })
      if (typeof message.content !== 'string' && (message.content as MessageContent)?.caption) {
        Text((message.content as MessageContent).caption!)
          .fontSize(14)
          .fontColor(isLeft ? '#000000' : '#FFFFFF')
          .margin({ top: 4 })
      }
      if (message.isDownloading) {
        Progress({ value: message.downloadProgress || 0, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(4)
          .margin({ top: 4 })
          .color('#3390F0')
      }
    }
    .onClick(() => {
      if (message.media?.hasSpoiler) {
        // 点击剧透消息，移除遮罩
        message.media.hasSpoiler = false;
        return;
      }
      promptAction.showToast({ message: $r('app.string.video_play_coming'), duration: 1500 });
    })
  }

  @Builder
  private renderFileMessage(message: Message, isLeft: boolean) {
    Column() {
      Row() {
        Text('📎').fontSize(20)
        Column() {
          Text(message.media?.fileName || $r('app.string.shared_media_files'))
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(isLeft ? '#000000' : '#FFFFFF')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          if (message.media?.size) {
            Text(this.viewModel.formatFileSize(message.media.size))
              .fontSize(11)
              .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
              .margin({ top: 2 })
          }
        }
        .margin({ left: 8 })
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        if (!message.file?.path) {
          Text('⬇️').fontSize(20).margin({ left: 8 })
        }
      }
      if (message.isDownloading) {
        Progress({ value: message.downloadProgress || 0, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(4)
          .margin({ top: 8 })
          .color('#3390F0')
        Text(`${(message.downloadProgress || 0).toFixed(0)}%`)
          .fontSize(10)
          .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
          .margin({ top: 2 })
      }
    }
    .padding(12)
    .onClick(() => {
      if (!message.file?.path && message.media?.tdlibFileId) {
        this.viewModel.triggerFileDownload(message.media.tdlibFileId);
      } else {
        promptAction.showToast({ message: $r('app.string.file_open_coming'), duration: 1500 });
      }
    })
  }

  @Builder
  private renderVoiceMessage(message: Message, isLeft: boolean) {
    Column() {
      Row() {
        Text('🎤').fontSize(20)
        Column() {
          Text($r('app.string.voice_message')).fontSize(14).fontWeight(FontWeight.Medium).fontColor(isLeft ? '#000000' : '#FFFFFF')
          Text(this.viewModel.formatDuration(message.duration || 0)).fontSize(11).fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)').margin({ top: 2 })
        }
        .margin({ left: 8 })
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        if (!message.file?.path) {
          Text('⬇️').fontSize(16).margin({ left: 8 })
        } else {
          Text('▶️').fontSize(20).margin({ left: 8 })
        }
      }
      if (message.isDownloading) {
        Progress({ value: message.downloadProgress || 0, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(3)
          .margin({ top: 6 })
          .color('#3390F0')
      }
    }
    .padding(10)
    .onClick(() => {
      if (!message.file?.path && message.media?.tdlibFileId) {
        this.viewModel.triggerFileDownload(message.media.tdlibFileId);
      } else {
        promptAction.showToast({ message: $r('app.string.voice_play_coming'), duration: 1500 });
      }
    })
  }

  @Builder
  private renderStickerMessage(message: Message, isLeft: boolean) {
    // ⭐ 贴纸消息不显示气泡背景，直接对齐
    Image(message.file?.path || message.media?.thumbnail)
      .width(120)
      .height(120)
      .objectFit(ImageFit.Contain)
      .backgroundColor('#E0E0E0')
      .onClick(() => {
        if (!message.file?.path && message.media?.tdlibFileId) {
          this.viewModel.triggerFileDownload(message.media.tdlibFileId);
        }
      })
  }

  @Builder
  private renderGifMessage(message: Message, isLeft: boolean) {
    Column() {
      Stack() {
        Image(message.file?.path || message.media?.thumbnail)
          .width(200)
          .height(200)
          .objectFit(ImageFit.Cover)
          .borderRadius(12)
          .backgroundColor('#E0E0E0')
        Text('GIF')
          .fontSize(10)
          .fontColor('#FFFFFF')
          .backgroundColor('rgba(0,0,0,0.6)')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .position({ x: 8, y: 8 })
          .borderRadius(4)
      }
      .width(200)
      .height(200)
      if (message.duration) {
        Text(this.viewModel.formatDuration(message.duration))
          .fontSize(11)
          .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
          .margin({ top: 4 })
      }
      if (message.isDownloading) {
        Progress({ value: message.downloadProgress || 0, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(4)
          .margin({ top: 4 })
          .color('#3390F0')
      }
    }
    .onClick(() => {
      if (!message.file?.path && message.media?.tdlibFileId) {
        this.viewModel.triggerFileDownload(message.media.tdlibFileId);
      }
    })
  }

  @Builder
  private renderLocationMessage(message: Message, isLeft: boolean) {
    Column() {
      Row() {
        Text('📍').fontSize(20)
        Column() {
          Text((message.content as MessageContent)?.title || $r('app.string.location')).fontSize(14).fontWeight(FontWeight.Medium).fontColor(isLeft ? '#000000' : '#FFFFFF')
          if ((message.content as MessageContent)?.address) Text((message.content as MessageContent).address).fontSize(11).fontColor('#8E8E93').margin({ top: 2 })
        }
        .margin({ left: 8 })
        .alignItems(HorizontalAlign.Start)
      }
      if (message.media?.thumbnail) {
        Image(message.media.thumbnail).width('100%').height(120).objectFit(ImageFit.Cover).borderRadius(8).margin({ top: 8 })
      }
    }
    .padding(10)
    .onClick(() => promptAction.showToast({ message: $r('app.string.map_coming'), duration: 1500 }))
  }

  @Builder
  private renderContactMessage(message: Message, isLeft: boolean) {
    Column() {
      Row() {
        Circle().width(40).height(40).fill('#3390F0')
        Column() {
          Text(`${(message.content as MessageContent)?.firstName || ''} ${(message.content as MessageContent)?.lastName || ''}`.trim() || $r('app.string.contact'))
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(isLeft ? '#000000' : '#FFFFFF')
          if ((message.content as MessageContent)?.phoneNumber) {
            Text((message.content as MessageContent).phoneNumber).fontSize(11).fontColor('#8E8E93').margin({ top: 2 })
          }
        }
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      Row() {
        Text($r('app.string.send_first_reply')).fontSize(12).fontColor('#3390F0').padding({ left: 12, right: 12, top: 6, bottom: 6 }).backgroundColor('rgba(51,144,240,0.1)').borderRadius(16)
        Text($r('app.string.add_contact')).fontSize(12).fontColor('#3390F0').padding({ left: 12, right: 12, top: 6, bottom: 6 }).backgroundColor('rgba(51,144,240,0.1)').borderRadius(16).margin({ left: 8 })
      }
      .margin({ top: 12 })
      .justifyContent(FlexAlign.Start)
    }
    .padding(12)
  }

  @Builder
  private renderPollMessage(message: Message, isLeft: boolean) {
    Column() {
      Text((message.content as MessageContent)?.question || '').fontSize(16).fontWeight(FontWeight.Medium).fontColor(isLeft ? '#000000' : '#FFFFFF')
      ForEach((message.content as MessageContent)?.options || [], (opt: PollOption) => {
        Row() {
          Text(opt.text).fontSize(14).fontColor(isLeft ? '#000000' : '#FFFFFF').layoutWeight(1)
          Text(`${opt.voterCount || 0}`).fontSize(12).fontColor('#8E8E93')
        }
        .width('100%')
        .padding(8)
        .backgroundColor('rgba(0,0,0,0.05)')
        .borderRadius(8)
        .margin({ top: 4 })
      }, (opt: PollOption) => opt.text)
      Text($r('app.string.total_votes') + ': ' + ((message.content as MessageContent)?.totalVoterCount || 0))
        .fontSize(11)
        .fontColor('#8E8E93')
        .margin({ top: 8 })
    }
    .padding(12)
  }

  @Builder
  private renderCallMessage(message: Message, isLeft: boolean) {
    Row() {
      Text((message.content as MessageContent)?.isVideo ? '📹' : '📞').fontSize(20)
      Column() {
        Text((message.content as MessageContent)?.isVideo ? $r('app.string.video_call') : $r('app.string.voice_call')).fontSize(14).fontWeight(FontWeight.Medium).fontColor(isLeft ? '#000000' : '#FFFFFF')
        Text((message.content as MessageContent)?.isMissed ? $r('app.string.missed_call') : ((message.content as MessageContent)?.duration ? $r('app.string.duration') + ': ' + this.viewModel.formatDuration((message.content as MessageContent).duration) : '')).fontSize(12).fontColor('#8E8E93').margin({ top: 2 })
      }
      .margin({ left: 8 })
    }
    .padding(10)
  }

  /**
   * ⭐ 渲染系统消息（居中胶囊样式，Telegram 风格）
   */
  @Builder
  private renderSystemMessage(message: Message, isLeft?: boolean) {
    Row() {
      Text(this.getSystemMessageIcon(message))
        .fontSize(14)
        .margin({ right: 6 })
      Text(this.getSystemMessageText(message))
        .fontSize(13)
        .fontColor('#8E8E93')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
    .backgroundColor('rgba(0,0,0,0.05)')
    .borderRadius(16)
    .constraintSize({ maxWidth: '90%' })
    .margin({ top: 4, bottom: 4 })
  }

  /**
   * 渲染群组事件消息
   */
  @Builder
  private renderGroupEventMessage(message: Message, isLeft: boolean) {
    Row() {
      // 根据事件类型显示不同图标
      Text(this.getGroupEventIcon(message.groupEventType))
        .fontSize(16)
        .margin({ right: 6 })

      Text(this.viewModel.getGroupEventText(message))
        .fontSize(13)
        .fontColor('#8E8E93')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
    .backgroundColor('rgba(0,0,0,0.03)')
    .borderRadius(12)
    .margin({ top: 4, bottom: 4 })
  }

  /**
   * ⭐ 渲染居中显示的群组事件消息（Telegram 风格）
   */
  @Builder
  private renderGroupEventMessageCentered(message: Message) {
    Row() {
      // 根据事件类型显示不同图标
      Text(this.getGroupEventIcon(message.groupEventType))
        .fontSize(14)
        .margin({ right: 6 })

      Text(this.viewModel.getGroupEventText(message))
        .fontSize(13)
        .fontColor('#8E8E93')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
    .backgroundColor('rgba(0,0,0,0.05)')
    .borderRadius(16)
    .constraintSize({ maxWidth: '90%' })
    .margin({ top: 4, bottom: 4 })
  }

  /**
   * ⭐ 获取系统消息图标
   * 优先使用 message.systemType，如果没有则根据内容关键词匹配
   */
  private getSystemMessageIcon(message: Message): string {
    // 优先使用新的 systemType 字段
    if (message.systemType) {
      return this.viewModel.getSystemMessageIcon(message.systemType)
    }
    
    // 降级：根据内容关键词匹配
    const content = typeof message.content === 'string' ? message.content : ''
    
    // 成员管理类
    if (content.includes('加入') || content.includes('邀请')) {
      return '👋'
    }
    if (content.includes('离开') || content.includes('移出')) {
      return '👋'
    }
    if (content.includes('移除') || content.includes('封禁')) {
      return '🚫'
    }
    
    // 管理员与权限类
    if (content.includes('管理员') || content.includes('权限')) {
      return '👑'
    }
    if (content.includes('禁言') || content.includes('限制')) {
      return '🔇'
    }
    
    // 聊天设置类
    if (content.includes('创建')) {
      return '🎉'
    }
    if (content.includes('名称') || content.includes('标题')) {
      return '✏️'
    }
    if (content.includes('头像') || content.includes('照片')) {
      return '🖼️'
    }
    if (content.includes('描述')) {
      return '📝'
    }
    if (content.includes('慢速')) {
      return '🐌'
    }
    if (content.includes('匿名')) {
      return '🎭'
    }
    if (content.includes('升级')) {
      return '⬆️'
    }
    
    // 消息操作类
    if (content.includes('置顶')) {
      return '📌'
    }
    if (content.includes('取消置顶')) {
      return '📍'
    }
    if (content.includes('编辑')) {
      return '✏️'
    }
    if (content.includes('删除')) {
      return '🗑️'
    }
    
    // 互动与付费类
    if (content.includes('投票')) {
      return '📊'
    }
    if (content.includes('游戏')) {
      return '🎮'
    }
    if (content.includes('支付') || content.includes('收款')) {
      return '💳'
    }
    
    // 默认图标
    return 'ℹ️'
  }

  /**
   * ⭐ 获取系统消息文本
   * 优先根据 systemType 生成文本，确保显示正确的系统消息类型
   */
  private getSystemMessageText(message: Message): string {
    // ⭐ 只要有 systemType（包括 UNKNOWN），都优先根据类型生成文本
    if (message.systemType) {
      return this.getDefaultSystemMessageText(message)
    }

    // 如果没有 systemType，尝试使用 content（兼容旧数据）
    if (typeof message.content === 'string' && message.content.length > 0 &&
        message.content !== 'members_added' && message.content !== 'system') {
      return message.content
    }

    // 最终兜底
    return this.getDefaultSystemMessageText(message)
  }

  /**
   * ⭐ 获取默认系统消息文本（根据消息类型）
   */
  private getDefaultSystemMessageText(message: Message): string {
    // 获取用户名，优先使用 senderName，尝试从 content 中提取
    let userName = message.senderName || ''

    // 如果没有 senderName，尝试从 content 中提取用户名
    if (!userName && typeof message.content === 'string') {
      // 匹配 "某某 加入了群组"、"某某 更新了群组信息" 等格式
      const match = message.content.match(/^(\S+)\s+(加入了群组|更新了群组信息|离开了群组|被移出群组)/)
      if (match) {
        userName = match[1]
      }
    }

    // 如果还是没有用户名，使用默认值
    if (!userName) {
      userName = '用户'
    }

    // ⭐ 根据 systemType 生成具体的文本
    switch (message.systemType) {
      case SystemMessageType.MEMBER_JOINED:
      case SystemMessageType.MEMBER_JOINED_BY_LINK:
        return `${userName} 加入了群组`
      case SystemMessageType.MEMBER_LEFT:
        return `${userName} 离开了群组`
      case SystemMessageType.MEMBER_REMOVED:
        return `${userName} 被移出群组`
      case SystemMessageType.MEMBER_PROMOTED:
        return `${userName} 被设为管理员`
      case SystemMessageType.MEMBER_DEMOTED:
        return `${userName} 被撤销管理员权限`
      case SystemMessageType.MEMBER_RESTRICTED:
        return `${userName} 被限制发言`
      case SystemMessageType.MEMBER_UNRESTRICTED:
        return `${userName} 的限制已解除`
      case SystemMessageType.MEMBER_BANNED:
        return `${userName} 被封禁`
      case SystemMessageType.CHAT_CREATED:
        return `${userName} 创建了群组`
      case SystemMessageType.TITLE_CHANGED:
        return `${userName} 更改了群组名称`
      case SystemMessageType.PHOTO_CHANGED:
        return `${userName} 更改了群组头像`
      case SystemMessageType.DESCRIPTION_CHANGED:
        return `${userName} 更改了群组描述`
      case SystemMessageType.SLOW_MODE_CHANGED:
        return `${userName} 更改了慢速模式设置`
      case SystemMessageType.MESSAGE_PINNED:
        return `${userName} 置顶了一条消息`
      case SystemMessageType.MESSAGE_UNPINNED:
        return `${userName} 取消置顶了一条消息`
      case SystemMessageType.LINKED_CHAT_CHANGED:
        return '群组已升级'
      case SystemMessageType.UNKNOWN:
      default:
        // UNKNOWN 或其他未知类型：尝试从 content 推断，或显示默认成员加入
        if (typeof message.content === 'string' && message.content.length > 0 &&
            message.content !== 'members_added' && message.content !== 'system') {
          // 如果 content 包含"加入"关键词，显示为加入
          if (message.content.includes('加入')) {
            return `${userName} 加入了群组`
          }
          // 如果 content 包含"离开"关键词，显示为离开
          if (message.content.includes('离开')) {
            return `${userName} 离开了群组`
          }
          // 其他情况返回原始 content
          return message.content
        }
        // 默认显示为成员加入（最常见的情况）
        return `${userName} 加入了群组`
    }
  }

  /**
   * 获取群组事件图标
   */
  private getGroupEventIcon(eventType?: GroupEventType): string {
    switch (eventType) {
      case GroupEventType.MEMBER_JOINED:
        return '👋';
      case GroupEventType.MEMBER_LEFT:
        return '👋';
      case GroupEventType.MEMBER_REMOVED:
        return '🚫';
      case GroupEventType.ADMIN_PROMOTED:
        return '👑';
      case GroupEventType.GROUP_CREATED:
        return '🎉';
      case GroupEventType.GROUP_UPGRADED:
        return '⬆️';
      case GroupEventType.GROUP_RENAMED:
        return '✏️';
      case GroupEventType.GROUP_PHOTO_CHANGED:
        return '🖼️';
      case GroupEventType.MESSAGE_PINNED:
        return '📌';
      case GroupEventType.SLOW_MODE_ENABLED:
        return '🐌';
      case GroupEventType.RESTRICTED_MODE_ENABLED:
        return '🔒';
      case GroupEventType.MEMBER_RESTRICTED:
        return '🔇';
      default:
        return '📢';
    }
  }

  // ==================== 新增消息类型渲染器 ====================

  @Builder
  private renderAudioMessage(message: Message, isLeft: boolean) {
    Column() {
      Row() {
        Text('🎵').fontSize(20)
        Column() {
          Text(message.media?.fileName || '音乐')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(isLeft ? '#000000' : '#FFFFFF')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.viewModel.formatDuration(message.duration || 0))
            .fontSize(11)
            .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
            .margin({ top: 2 })
        }
        .margin({ left: 8 })
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        if (!message.file?.path) {
          Text('⬇️').fontSize(20).margin({ left: 8 })
        } else {
          Text('▶️').fontSize(20).margin({ left: 8 })
        }
      }
      if (message.isDownloading) {
        Progress({ value: message.downloadProgress || 0, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(3)
          .margin({ top: 6 })
          .color('#3390F0')
      }
    }
    .padding(12)
    .onClick(() => {
      if (!message.file?.path && message.media?.tdlibFileId) {
        this.viewModel.triggerFileDownload(message.media.tdlibFileId);
      } else {
        promptAction.showToast({ message: '音乐播放功能即将上线', duration: 1500 });
      }
    })
  }

  @Builder
  private renderVideoNoteMessage(message: Message, isLeft: boolean) {
    Column() {
      Stack() {
        Image(message.file?.path || message.media?.thumbnail)
          .width(120)
          .height(120)
          .borderRadius(60)
          .objectFit(ImageFit.Cover)
          .backgroundColor('#E0E0E0')
        if (!message.file?.path) {
          Text('⬇️').fontSize(24).backgroundColor('rgba(0,0,0,0.6)').borderRadius(20).padding(8)
        } else {
          Text('▶️').fontSize(24).backgroundColor('rgba(0,0,0,0.6)').borderRadius(20).padding(8)
        }
      }
      .width(120)
      .height(120)
      if (message.duration) {
        Text(this.viewModel.formatDuration(message.duration))
          .fontSize(11)
          .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
          .margin({ top: 4 })
      }
      if (message.isDownloading) {
        Progress({ value: message.downloadProgress || 0, total: 100, type: ProgressType.Linear })
          .width(100)
          .height(3)
          .margin({ top: 6 })
          .color('#3390F0')
      }
    }
    .onClick(() => {
      if (!message.file?.path && message.media?.tdlibFileId) {
        this.viewModel.triggerFileDownload(message.media.tdlibFileId);
      } else {
        promptAction.showToast({ message: $r('app.string.video_play_coming'), duration: 1500 });
      }
    })
  }

  @Builder
  private renderGameMessage(message: Message, isLeft: boolean) {
    Column() {
      Row() {
        Text('🎮').fontSize(24)
        Column() {
          Text((message.content as MessageContent)?.title || '游戏')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(isLeft ? '#000000' : '#FFFFFF')
          Text((message.content as MessageContent)?.description || '')
            .fontSize(11)
            .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .margin({ left: 8 })
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      Button('开始游戏')
        .fontSize(12)
        .fontColor('#3390F0')
        .backgroundColor('rgba(51,144,240,0.1)')
        .borderRadius(16)
        .margin({ top: 8 })
        .onClick(() => {
          promptAction.showToast({ message: '游戏功能即将上线', duration: 1500 });
        })
    }
    .padding(12)
  }

  @Builder
  private renderInvoiceMessage(message: Message, isLeft: boolean) {
    Column() {
      Row() {
        Text('💳').fontSize(24)
        Column() {
          Text((message.content as MessageContent)?.title || '支付请求')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(isLeft ? '#000000' : '#FFFFFF')
          Text((message.content as MessageContent)?.description || '')
            .fontSize(11)
            .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .margin({ left: 8 })
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      Button('立即支付')
        .fontSize(12)
        .fontColor('#3390F0')
        .backgroundColor('rgba(51,144,240,0.1)')
        .borderRadius(16)
        .margin({ top: 8 })
        .onClick(() => {
          promptAction.showToast({ message: '支付功能即将上线', duration: 1500 });
        })
    }
    .padding(12)
  }

  @Builder
  private renderPaymentSuccessfulMessage(message: Message, isLeft: boolean) {
    Column() {
      Row() {
        Text('✅').fontSize(24)
        Column() {
          Text('支付成功')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(isLeft ? '#000000' : '#FFFFFF')
          Text((message.content as MessageContent)?.description || '')
            .fontSize(11)
            .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
        }
        .margin({ left: 8 })
        .alignItems(HorizontalAlign.Start)
      }
    }
    .padding(12)
  }

  @Builder
  private renderExpiredMediaMessage(message: Message, isLeft: boolean) {
    Column() {
      Row() {
        Text('⏱️').fontSize(24)
        Text('媒体已过期')
          .fontSize(14)
          .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
          .margin({ left: 8 })
      }
    }
    .padding(12)
  }

  @Builder
  private renderUnsupportedMessage(message: Message, isLeft: boolean) {
    Row() {
      Text('⚠️').fontSize(14).fontColor('#8E8E93')
      Text($r('app.string.unsupported_message_type'))
        .fontSize(13)
        .fontColor('#8E8E93')
        .margin({ left: 4 })
    }
    .padding(8)
    .backgroundColor('rgba(0,0,0,0.05)')
    .borderRadius(8)
    .margin({ top: 4, bottom: 4 })
  }

  // ==================== 扩展消息类型渲染器 ====================

  /**
   * 渲染过期语音消息
   */
  @Builder
  private renderExpiredVoiceMessage(message: Message, isLeft: boolean) {
    Column() {
      Row() {
        Text('🎤').fontSize(20).fontColor('#8E8E93')
        Text('语音已过期')
          .fontSize(14)
          .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
          .margin({ left: 8 })
      }
    }
    .padding(12)
  }

  /**
   * 渲染过期视频消息（圆形视频）
   */
  @Builder
  private renderExpiredVideoNoteMessage(message: Message, isLeft: boolean) {
    Column() {
      Row() {
        Text('📹').fontSize(20).fontColor('#8E8E93')
        Text('视频消息已过期')
          .fontSize(14)
          .fontColor(isLeft ? '#8E8E93' : 'rgba(255,255,255,0.7)')
          .margin({ left: 8 })
      }
    }
    .padding(12)
  }

  /**
   * 渲染骰子/随机数消息
   */
  @Builder
  private renderDiceMessage(message: Message, isLeft: boolean) {
    Column() {
      // 获取骰子信息
      this.renderDiceContent(message, isLeft)
    }
    .padding(12)
  }

  /**
   * 获取骰子消息的emoji
   */
  private getDiceEmoji(message: Message): string {
    const content = message.content as MessageContent;
    return content?.text || '🎲';
  }

  /**
   * 获取骰子消息的值
   */
  private getDiceValue(message: Message): number {
    const content = message.content as MessageContent;
    return parseInt(content?.description || '1', 10);
  }

  @Builder
  private renderDiceContent(message: Message, isLeft: boolean) {
    Column() {
      Text(this.getDiceEmoji(message))
        .fontSize(48)
        .margin({ bottom: 4 })
      Text(this.getDiceValue(message).toString())
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(isLeft ? '#000000' : '#FFFFFF')
    }
    .width(80)
    .height(80)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 渲染礼物消息（Premium/礼品码）
   */
  @Builder
  private renderGiftMessage(message: Message, isLeft: boolean) {
    Column() {
      this.renderGiftContent(message, isLeft)
    }
    .padding(12)
  }

  /**
   * 获取礼物消息的标题
   */
  private getGiftTitle(message: Message): string {
    const content = message.content as MessageContent;
    return content?.caption ? '赠送 Premium' : '礼品码';
  }

  /**
   * 获取礼物消息的图标
   */
  private getGiftIcon(message: Message): string {
    const content = message.content as MessageContent;
    return content?.caption ? '🎁' : '🎫';
  }

  /**
   * 获取礼物消息的说明文字
   */
  private getGiftCaption(message: Message): string {
    const content = message.content as MessageContent;
    return content?.caption || '';
  }

  @Builder
  private renderGiftContent(message: Message, isLeft: boolean) {
    Column() {
      Row() {
        Text(this.getGiftIcon(message))
          .fontSize(32)
          .margin({ right: 12 })
        Column() {
          Text(this.getGiftTitle(message))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(isLeft ? '#000000' : '#FFFFFF')
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      if (this.getGiftCaption(message).length > 0) {
        Text(this.getGiftCaption(message))
          .fontSize(14)
          .fontColor(isLeft ? '#000000' : '#FFFFFF')
          .margin({ top: 8 })
          .width('100%')
      }
    }
    .backgroundColor(isLeft ? '#F0F0F0' : '#3390F0')
    .borderRadius(16)
    .padding(16)
    .width(BUBBLE_MAX_WIDTH)
  }

  /**
   * 渲染赠品/抽奖消息
   */
  @Builder
  private renderGiveawayMessage(message: Message, isLeft: boolean) {
    Column() {
      this.renderGiveawayContent(message, isLeft)
    }
    .padding(12)
  }

  /**
   * 获取赠品消息的标题
   */
  private getGiveawayTitle(message: Message): string {
    return '赠品活动';
  }

  /**
   * 获取赠品消息的图标
   */
  private getGiveawayIcon(): string {
    return '🎉';
  }

  /**
   * 获取赠品消息的奖品描述
   */
  private getGiveawayPrizeDescription(message: Message): string {
    const content = message.content as MessageContent;
    return content?.description || '';
  }

  @Builder
  private renderGiveawayContent(message: Message, isLeft: boolean) {
    Column() {
      Row() {
        Text(this.getGiveawayIcon())
          .fontSize(32)
          .margin({ right: 12 })
        Column() {
          Text(this.getGiveawayTitle(message))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(isLeft ? '#000000' : '#FFFFFF')
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      if (this.getGiveawayPrizeDescription(message).length > 0) {
        Text(`奖品: ${this.getGiveawayPrizeDescription(message)}`)
          .fontSize(14)
          .fontColor(isLeft ? '#000000' : '#FFFFFF')
          .margin({ top: 8 })
          .width('100%')
      }

      Button('参与抽奖')
        .fontSize(12)
        .fontColor('#3390F0')
        .backgroundColor('rgba(51,144,240,0.1)')
        .borderRadius(16)
        .margin({ top: 12 })
        .onClick(() => {
          promptAction.showToast({ message: '抽奖功能即将上线', duration: 1500 });
        })
    }
    .backgroundColor(isLeft ? '#F0F0F0' : '#3390F0')
    .borderRadius(16)
    .padding(16)
    .width(BUBBLE_MAX_WIDTH)
  }

  build() {
    Column() {
      TopImmersiveContainer({ theme: ThemeMode.LIGHT }) {
        Stack() {
          Column() {
            this.buildTopBar()
            this.buildMessageList()
          }
          .width('100%')
          .height('100%')
          .backgroundColor('#FFFFFF')

          // 多选模式下显示底部操作栏，否则显示输入区
          if (this.viewModel.isMultiSelectMode) {
            // 多选底部栏使用 Stack 定位
            Stack() {
              this.buildMultiSelectBottomBar()
            }
            .width('100%')
            .height(72)
            .align(Alignment.Bottom)
          } else {
            this.buildFloatingInputArea()
          }
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}