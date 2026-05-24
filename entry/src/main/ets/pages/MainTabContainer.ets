/**
 * 主标签容器页面 - 使用 Swiper 实现平滑滑动 + 自定义悬浮导航栏
 * ⭐ 支持平板分栏模式：左侧导航+列表，右侧聊天详情
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { display } from '@kit.ArkUI';
import { EventBus } from '../utils/event/EventBus';
import { BadgeManager } from '../utils/storage/BadgeManager';
import { TdLibEventNames } from '../services/api';
import { Badge } from '../ui_kit';

import { ChatListPage } from './chat/ChatListPage';
import { ContactListPage } from './contacts/ContactListPage';
import { SettingsPage } from './settings/SettingsPage';
import { ProfilePage } from './Profile/ProfilePage';
import { ChatPage } from './common/ChatPage';
import { ChatType } from '../models/TDLibData';

const DOMAIN = 0x0001;
const TAG = 'MainTabContainer';

export enum TabType {
  CHAT = 'chat',
  CONTACTS = 'contacts',
  SETTINGS = 'settings',
  PROFILE = 'profile'
}

interface TabItem {
  type: TabType;
  title: ResourceStr;
  icon: ResourceStr;
  iconSelected: ResourceStr;
}

const TABS: TabItem[] = [
  { type: TabType.CHAT, title: $r('app.string.tab_chat'), icon: '💬', iconSelected: '💬' },
  { type: TabType.CONTACTS, title: $r('app.string.tab_contacts'), icon: '👥', iconSelected: '👥' },
  { type: TabType.SETTINGS, title: $r('app.string.tab_settings'), icon: '⚙️', iconSelected: '⚙️' },
  { type: TabType.PROFILE, title: $r('app.string.tab_profile'), icon: '👤', iconSelected: '👤' }
];

@Entry({ routeName: 'MainTabContainer' })
@ComponentV2
export struct MainTabContainer {
  @Local currentIndex: number = 0;
  @Local chatBadge: number = 0;
  @Local contactsBadge: number = 0;
  @Local settingsBadge: number = 0;
  @Local profileBadge: number = 0;
  
  // ⭐ 平板模式状态
  @Local isTabletMode: boolean = false;
  @Local selectedChatId: number = 0;
  @Local selectedChatType: ChatType = ChatType.PRIVATE;
  @Local selectedChatTitle: string = '';
  @Local selectedChatAvatar: string = '';

  private swiperController: SwiperController = new SwiperController();
  private messageReceivedListener: ((data?: Object) => void) | null = null;
  private authCompletedListener: ((data?: Object) => void) | null = null;
  private messageReadListener: ((data?: Object) => void) | null = null;
  private contactAddedListener: ((data?: Object) => void) | null = null;
  private eventBus: EventBus = EventBus.getInstance();
  private badgeManager: BadgeManager = BadgeManager.getInstance();

  aboutToAppear(): void {
    this.checkScreenSize();
    this.loadBadgeData().then(() => this.setupEventListeners());
  }

  aboutToDisappear(): void {
    this.cleanupEventListeners();
  }

  /**
   * ⭐ 检测屏幕尺寸，判断是否为平板模式
   */
  private checkScreenSize(): void {
    try {
      const displayInfo = display.getDefaultDisplaySync();
      if (displayInfo) {
        const width = displayInfo.width / displayInfo.densityPixels;
        this.isTabletMode = width >= 600; // 平板断点：600vp
        
        // ⭐ API 24: 支持运行时获取平行视界分栏状态（针对折叠屏/大屏）
        // 如果系统支持平行视界，可以根据分栏状态进一步优化布局
        hilog.info(DOMAIN, TAG, `Screen width: ${width}vp, isTabletMode: ${this.isTabletMode}`);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `checkScreenSize error: ${JSON.stringify(error)}`);
      this.isTabletMode = false;
    }
  }

  private async loadBadgeData(): Promise<void> {
    try {
      const badgeData = await this.badgeManager.loadBadges();
      this.chatBadge = badgeData.chatBadge;
      this.contactsBadge = badgeData.contactsBadge;
      this.settingsBadge = badgeData.settingsBadge;
      this.profileBadge = badgeData.profileBadge;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `loadBadgeData error: ${JSON.stringify(error)}`);
    }
  }

  private setupEventListeners(): void {
    this.messageReceivedListener = () => {
      this.badgeManager.incrementChatBadge(1).then(v => this.chatBadge = v);
    };
    this.eventBus.on(TdLibEventNames.MESSAGE_RECEIVED, this.messageReceivedListener);

    this.authCompletedListener = () => this.loadBadgeData();
    this.eventBus.on(TdLibEventNames.TDLIB_AUTH_COMPLETED, this.authCompletedListener);

    this.messageReadListener = (data?: Object) => {
      if (data && (data as Record<string, Object>)['chatId'] !== undefined) {
        this.badgeManager.decrementChatBadge(1).then(v => this.chatBadge = v);
      }
    };
    this.eventBus.on(TdLibEventNames.MESSAGE_READ, this.messageReadListener);

    this.contactAddedListener = (data?: Object) => {
      if (data && (data as Record<string, Object>)['userId'] !== undefined) {
        this.badgeManager.incrementContactsBadge(1).then(v => this.contactsBadge = v);
      }
    };
    this.eventBus.on(TdLibEventNames.CONTACT_ADDED, this.contactAddedListener);
  }

  private cleanupEventListeners(): void {
    if (this.messageReceivedListener) this.eventBus.off(TdLibEventNames.MESSAGE_RECEIVED, this.messageReceivedListener);
    if (this.authCompletedListener) this.eventBus.off(TdLibEventNames.TDLIB_AUTH_COMPLETED, this.authCompletedListener);
    if (this.messageReadListener) this.eventBus.off(TdLibEventNames.MESSAGE_READ, this.messageReadListener);
    if (this.contactAddedListener) this.eventBus.off(TdLibEventNames.CONTACT_ADDED, this.contactAddedListener);
  }

  private getBadge(type: TabType): number {
    switch (type) {
      case TabType.CHAT: return this.chatBadge;
      case TabType.CONTACTS: return this.contactsBadge;
      case TabType.SETTINGS: return this.settingsBadge;
      case TabType.PROFILE: return this.profileBadge;
      default: return 0;
    }
  }

  @Builder
  private customTabBar() {
    Row() {
      ForEach(TABS, (tab: TabItem, index: number) => {
        Stack() {
          Column() {
            Text(this.currentIndex === index ? tab.iconSelected : tab.icon)
              .fontSize(24)
            Text(tab.title)
              .fontSize(12)
              .fontColor(this.currentIndex === index ? '#007AFF' : '#8E8E93')
              .margin({ top: 4 })
          }
          .width(64)
          .height(56)
          .borderRadius(28)
          .backgroundColor(this.currentIndex === index ? '#E8F4FF' : Color.Transparent)
          .justifyContent(FlexAlign.Center)

          if (this.getBadge(tab.type) > 0) {
            Badge({ count: this.getBadge(tab.type), maxCount: 99, type: 'danger' })
              .position({ x: 44, y: 0 })
          }
        }
        .width(64)
        .height(64)
        .onClick(() => {
          if (this.currentIndex !== index) {
            this.swiperController.changeIndex(index, true);
          }
        })
      }, (item: TabItem) => item.type)
    }
    .width('90%')
    .height(64)
    .backgroundColor('#FFFFFF')
    .borderRadius(32)
    .shadow({ radius: 16, color: 'rgba(0, 0, 0, 0.15)', offsetY: 4 })
    .margin({ bottom: 24 })
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  build() {
    if (this.isTabletMode) {
      // ⭐ 平板模式：左右分栏
      this.buildTabletLayout()
    } else {
      // 手机模式：底部导航 + Swiper
      this.buildPhoneLayout()
    }
  }

  /**
   * ⭐ 平板布局：左侧导航+列表，右侧聊天详情
   */
  @Builder
  private buildTabletLayout() {
    Row() {
      // 左侧：标签页内容（固定宽度）
      Stack({ alignContent: Alignment.Bottom }) {
        // ⭐ API 24: 新增动态布局容器，可响应式调整子组件排列
        GridRow() {
          GridCol({ span: 24 }) {
            Swiper(this.swiperController) {
              ChatListPage({
                onChatSelected: (chatId: number, chatType: ChatType, title: string, avatar: string) => {
                  hilog.info(DOMAIN, TAG, `⭐ Received callback from ChatListPage: id=${chatId}, title=${title}`);
                  this.selectedChatId = chatId;
                  this.selectedChatType = chatType;
                  this.selectedChatTitle = title;
                  this.selectedChatAvatar = avatar;
                }
              })
              ContactListPage({})
              SettingsPage({})
              ProfilePage({})
            }
            .width('100%')
            .height('100%')
            .loop(false)
            .indicator(false)
            .index(this.currentIndex)
            .cachedCount(2)
            .duration(150)
            .curve('ease-out')
            .onChange((index: number) => {
              this.currentIndex = index;
              // 切换标签时清空右侧选中状态
              if (index !== 0) {
                this.selectedChatId = 0;
              }
            })
          }
        }

        this.customTabBar()
      }
      .width(360)
      .height('100%')

      Divider().color('#E5E5EA').width(1).height('100%')

      // 右侧：聊天详情或占位符
      Stack() {
        if (this.selectedChatId !== 0 && this.currentIndex === 0) {
          ChatPage({
            chatId: this.selectedChatId,
            chatType: this.selectedChatType,
            title: this.selectedChatTitle,
            avatar: this.selectedChatAvatar,
            onChatDeselected: () => {
              hilog.info(DOMAIN, TAG, '⭐ Received callback from ChatPage: deselecting');
              this.selectedChatId = 0;
            }
          })
          .key(`chat_${this.selectedChatId}`) // ⭐ 使用 key 强制重建组件，确保切换聊天时重新初始化
        } else {
          Column() {
            Image($r('app.media.ic_none_message'))
              .width(120)
              .height(120)
              .opacity(0.3)
            Text('选择一个聊天开始对话')
              .fontSize(16)
              .fontColor('#C7C7CC')
              .margin({ top: 16 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#FFFFFF')
        }
      }
      .layoutWeight(1)
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 手机布局：底部导航 + Swiper
   */
  @Builder
  private buildPhoneLayout() {
    Stack({ alignContent: Alignment.Bottom }) {
      Swiper(this.swiperController) {
        ChatListPage({})
        ContactListPage({})
        SettingsPage({})
        ProfilePage({})
      }
      .width('100%')
      .height('100%')
      .loop(false)
      .indicator(false)
      .index(this.currentIndex)
      .cachedCount(2)
      .duration(150)
      .curve('ease-out')
      .onChange((index: number) => {
        this.currentIndex = index;
      })

      this.customTabBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}