// ContactListPage.ets
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { ErrorHandler } from '../utils/error/ErrorHandler';
import { eventBus } from '../utils/event/EventBus';
import { pasteboard } from '@kit.BasicServicesKit';
import { ChatType } from '../models/TDLibData';
import { ContactListViewModel, ContactItemDisplay } from '../viewmodels/ContactListViewModel';
import { MainTopBar } from '../ui_kit/components/MainTopBar';

const TAG = 'ContactListPage';
const DOMAIN = 0x0001;
const BOTTOM_PADDING = 80;

@Entry
@ComponentV2
export struct ContactListPage {
  private viewModel: ContactListViewModel = ContactListViewModel.getInstance();
  private scroller: Scroller = new Scroller();
  @Local contactItems: ContactItemDisplay[] = [];
  @Local topSafeHeight: number = 0;

  aboutToAppear(): void {
    hilog.info(DOMAIN, TAG, '⭐ ContactListPage aboutToAppear called');

    // ⭐ 动态获取状态栏高度（与 MainTopBar 相同方式）
    this.loadSafeAreaHeight();

    // 初始化 FileDownloadService（用于头像下载）
    const context = getContext(this) as common.UIAbilityContext;
    this.viewModel.initializeFileDownloadService(context);

    this.viewModel.init();
    hilog.info(DOMAIN, TAG, '⭐ ContactListPage viewModel.init() completed');
    
    // 监听数据更新事件，同步到本地 @Local 状态以触发 UI 刷新
    eventBus.on('contactListUpdated', () => {
      hilog.info(DOMAIN, TAG, 'Received contactListUpdated, syncing UI...');
      this.contactItems = [...this.viewModel.contactItems];
    });

    // 初始同步
    setTimeout(() => {
      this.contactItems = [...this.viewModel.contactItems];
    }, 500);
  }

  /**
   * 动态获取状态栏高度，用于根容器 padding 避让
   */
  private loadSafeAreaHeight(): void {
    try {
      const win = window.getLastWindow(getContext(this));
      win.then((windowClass: window.Window) => {
        const avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        if (avoidArea && avoidArea.topRect) {
          this.topSafeHeight = px2vp(avoidArea.topRect.height);
        }
      }).catch(() => {
        this.topSafeHeight = 24;
      });
    } catch (e) {
      this.topSafeHeight = 24;
    }
  }

  /**
   * ⭐ 页面显示时调用（从其他页面返回时也会触发）
   * 由于 MainTabContainer 使用 Swiper 缓存页面，aboutToAppear 不会重复调用
   */
  onPageShow(): void {
    hilog.info(DOMAIN, TAG, '📱 ContactListPage onPageShow - refreshing data');
    // 刷新联系人列表
    this.viewModel.refreshContacts();
    // 同步 UI 状态
    this.contactItems = [...this.viewModel.contactItems];
  }

  aboutToDisappear(): void {
    this.viewModel.cleanup();
  }

  // ==================== UI 交互 ====================
  private openSearchPage(): void {
    router.pushUrl({ url: 'pages/contacts/ContactSearchPage' })
      .catch(() => promptAction.showToast({ message: '搜索页面开发中', duration: 1500 }));
  }

  private showMenu(): void {
    promptAction.showActionMenu({
      title: '更多操作',
      buttons: [
        { text: '添加联系人', color: '#007AFF' },
        { text: '邀请好友', color: '#007AFF' }
      ]
    }).then((result) => {
      if (result.index === 0) this.handleAddContact();
      else if (result.index === 1) this.handleInviteFriend();
    }).catch(() => {});
  }

  private handleAddContact(): void {
    router.pushUrl({ url: 'feature-contacts/pages/NewContactPage' })
      .catch(() => promptAction.showToast({ message: '功能开发中', duration: 1500 }));
  }

  private handleInviteFriend(): void {
    const inviteLink = 'https://t.me/your_bot?start=invite';
    const pasteboardObj = pasteboard.getSystemPasteboard();
    const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, inviteLink);
    pasteboardObj.setData(pasteData);
    promptAction.showToast({ message: '邀请链接已复制', duration: 1500 });
  }

  // ==================== 辅助方法 ====================
  private getAvatarColor(title: string): string {
    const colors = ['#FF6B35', '#007AFF', '#4CAF50', '#FFA500', '#9C27B0', '#FA2A2D', '#00BCD4', '#E91E63', '#8BC34A', '#FF5722', '#3F51B5', '#009688'];
    let hash = 0;
    for (let i = 0; i < title.length; i++) hash = title.charCodeAt(i) + ((hash << 5) - hash);
    return colors[Math.abs(hash) % colors.length];
  }

  private handleContactClick(contact: ContactItemDisplay): void {
    const fullContact = this.viewModel.getContactById(contact.id);
    if (!fullContact) return;
    const chatType: ChatType = fullContact.isBot ? ChatType.BOT : ChatType.PRIVATE;
    router.pushUrl({
      url: 'pages/ChatPage',
      params: {
        chatId: fullContact.userId,
        chatType: chatType as string,
        title: fullContact.fullName,
        avatar: fullContact.avatarPath || '',
      }
    }).catch((error: Error) => {
      hilog.error(DOMAIN, TAG, `Navigate to chat failed: ${error.message}`);
      router.pushUrl({
        url: 'pages/ContactDetailPage',
        params: { contactId: fullContact.id }
      }).catch(() => {
        promptAction.showToast({ message: '功能暂时不可用', duration: 1500 });
      });
    });
  }

  // ==================== UI 构建 ====================
  /**
   * ⭐ 处理头像路径，确保格式正确
   */
  @Builder
  private buildContactItem(contact: ContactItemDisplay) {
    Row() {
      Stack() {
        // 头像路径已在 ViewModel 层处理，直接使用
        if (contact.avatarPath) {
          Image(contact.avatarPath)
            .width(56)
            .height(56)
            .borderRadius(28)
            .objectFit(ImageFit.Cover)
            .onError(() => {
              hilog.warn(DOMAIN, TAG, `Failed to load avatar for contact ${contact.id}`);
            })
        } else {
          Circle().width(56).height(56).fill(this.getAvatarColor(contact.fullName))
          Text(contact.fullName.charAt(0).toUpperCase())
            .fontSize(24)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
      }
        .margin({ right: 12 })

      Column({ space: 4 }) {
        Text(contact.fullName)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(contact.statusText)
          .fontSize(14)
          .fontColor(contact.statusColor)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(72)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Center)
    .onClick(() => this.handleContactClick(contact))
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        // ⭐ 内容区：全尺寸铺满 Stack，滚动到顶部栏后方实现沉浸模糊效果
        if (this.viewModel.isLoading && this.contactItems.length === 0) {
          Column() {
            LoadingProgress().width(40).height(40).color('#007AFF')
            Text('加载中...').fontSize(14).fontColor('#8E8E93').margin({ top: 12 })
          }
          .width('100%')
          .height('100%')
          .padding({ top: 56 + this.topSafeHeight })
          .justifyContent(FlexAlign.Center)
        } else if (this.contactItems.length === 0) {
          Column() {
            Text('👥').fontSize(60).opacity(0.3)
            Text('暂无联系人').fontSize(16).fontColor('#8E8E93').margin({ top: 16 })
            Text('点击右上角"添加联系人"开始').fontSize(14).fontColor('#C7C7CC').margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .padding({ top: 56 + this.topSafeHeight })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          List({ scroller: this.scroller }) {
            ForEach(this.contactItems, (contact: ContactItemDisplay, index: number) => {
              ListItem() {
                this.buildContactItem(contact)
              }
            }, (contact: ContactItemDisplay, index: number) => `${contact.id}_${index}`)
          }
          .width('100%')
          .height('100%')
          .padding({ top: 56 + this.topSafeHeight })
          .divider({ strokeWidth: 0.5, color: '#E5E5EA', startMargin: 84, endMargin: 0 })
          .scrollBar(BarState.Auto)
          .cachedCount(20)
        }

        // ⭐ 顶部栏：浮层叠加在内容上方，毛玻璃效果模糊列表内容
        MainTopBar({
          title: '联系人',
          icons: [
            { name: 'search', action: () => this.openSearchPage() },
            { name: 'more', action: () => this.showMenu() }
          ],
          immersiveTopPadding: this.topSafeHeight
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}
