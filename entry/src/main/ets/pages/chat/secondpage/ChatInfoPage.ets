// file: ChatInfoPage.ets - 聊天信息页面
/**
 * 聊天信息页面
 * 显示和编辑聊天信息、成员列表、设置等
 */

import { router } from '@kit.ArkUI';
import { Chat } from '../../../models/TDLibData';
import { CoreService } from '../../../services/business/CoreService';
import { Avatar, ThemeManager } from '../../../ui_kit';
import { logger } from '../../../utils/log/LogService';
import { BusinessError, BusinessErrorCode } from '../../../utils/error/BusinessError';
import { TDLibApi, createTdLibAPIs } from '../../../services/api';
import type { ChatList, chatListMain, chatNotificationSettings$Input } from '../../../services/api/factory/tdlib-types';
import { getString } from '../../../utils/i18n/ResourceHelper';

/**
 * 聊天信息接口
 */
interface ChatWithSupergroup extends Chat {
  supergroupId?: number;
}

/**
 * 路由参数接口
 */
interface RouterParams {
  chatId: number;
  chatTitle: string;
}

/**
 * 主题颜色接口
 */
interface ThemeColors {
  background: string;
  surface: string;
  text: string;
  textSecondary: string;
  primary: string;
  divider: string;
  danger: string;
}

/**
 * 成员信息接口
 */
interface MemberInfo {
  id: number;
  name: string;
  avatar?: string;
  status: string;
  role?: string;
}

@Entry({ routeName: 'ChatInfoPage' })
@ComponentV2
export struct ChatInfoPage {
  @Local chatId: number = 0;
  @Local chat: Chat | null = null;
  @Local isLoading: boolean = true;
  @Local isMuted: boolean = false;
  @Local isPinned: boolean = false;
  @Local memberCount: number = 0;
  @Local members: MemberInfo[] = [];
  @Local isLoadingMembers: boolean = false;
  @Local selectedTab: 'info' | 'members' | 'settings' = 'info';
  @Local showPinConfirmation: boolean = false;

  private readonly TAG = 'ChatInfoPage';
  private readonly DOMAIN = 0x0001;
  private CoreService: CoreService = CoreService.getInstance();
  private tdLibApi: TDLibApi | null = null;
  private theme: ThemeColors = {
    background: '#FFFFFF',
    surface: '#F5F5F5',
    text: '#000000',
    textSecondary: '#666666',
    primary: '#0088CC',
    divider: '#E0E0E0',
    danger: '#FF4444'
  };

  aboutToAppear(): void {
    this.initializeTheme();
    this.loadRouteParams();
    this.initializeTdLibAPIs();
    this.loadChatInfo();
  }

  aboutToDisappear(): void {
    this.cleanup();
  }

  /**
   * 初始化主题
   */
  private initializeTheme(): void {
    const currentTheme = ThemeManager.getInstance().getCurrentTheme();
    const colors = currentTheme.tokens.colors;

    const newTheme: ThemeColors = {
      background: colors.surface,
      surface: colors.primary,
      text: colors.text,
      textSecondary: colors.textSecondary,
      primary: colors.primary,
      divider: colors.border,
      danger: colors.error
    };
    this.theme = newTheme;
  }

  /**
   * 加载路由参数
   */
  private loadRouteParams(): void {
    try {
      const params = router.getParams() as RouterParams;
      if (params) {
        this.chatId = params.chatId || 0;
      }
    } catch (error) {
      logger.error(this.DOMAIN, this.TAG, 'Failed to load route params');
    }
  }

  /**
   * 初始化 TDLib APIs
   */
  private async initializeTdLibAPIs(): Promise<void> {
    try {
      this.tdLibApi = createTdLibAPIs();
    } catch (error) {
      logger.error(this.DOMAIN, this.TAG, 'Failed to initialize TDLib APIs', error);
    }
  }

  /**
   * 加载聊天信息
   */
  private async loadChatInfo(): Promise<void> {
    if (this.chatId === 0) {
      this.isLoading = false;
      return;
    }

    this.isLoading = true;

    try {
      const chatResult = this.CoreService.getChat(this.chatId);
      if (chatResult) {
        const chatObj = chatResult as Chat;
        this.chat = chatObj;
        this.isMuted = chatObj.isMuted;
        this.isPinned = chatObj.isPinned;
        this.memberCount = chatObj.membersCount || 0;
      }
    } catch (error) {
      logger.error(this.DOMAIN, this.TAG, 'Failed to load chat info');
      throw new BusinessError(BusinessErrorCode.CHAT_NOT_FOUND, '加载聊天信息失败', '加载聊天信息失败');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 加载成员列表
   */
  private async loadMembers(): Promise<void> {
    if (!this.tdLibApi || this.chatId === 0) {
      return;
    }

    this.isLoadingMembers = true;

    try {
      // 获取超级群组成员
      const chat = this.CoreService.getChat(this.chatId);
      if (chat && chat.type === 'channel') {
        // 频道类型需要从 chat 对象获取 supergroupId
        const chatWithSuper = chat as ChatWithSupergroup;
        const supergroupId = chatWithSuper.supergroupId || 0;
        if (supergroupId !== 0) {
          const result = await this.tdLibApi.getSupergroupMembers(supergroupId, null, 0, 100);
          if (result && result.members) {
            // 将成员数组转换为 MemberInfo 数组
            const membersList = result.members;
            this.members = membersList.map((member, index): MemberInfo => {
              return {
                id: index + 1,
                name: `成员${index + 1}`,
                status: '成员',
                role: '成员'
              };
            });
            this.memberCount = this.members.length;
          }
        }
      }
    } catch (error) {
      logger.error(this.DOMAIN, this.TAG, 'Failed to load members');
    } finally {
      this.isLoadingMembers = false;
    }
  }

  /**
   * 切换静音状态
   */
  private async toggleMute(): Promise<void> {
    if (!this.tdLibApi || this.chatId === 0) {
      return;
    }

    try {
      const notificationSettingsObj: chatNotificationSettings$Input = {
        _: 'chatNotificationSettings',
        mute_for: this.isMuted ? 0 : 0xFFFFFFFF,
        use_default_mute_for: true,
        use_default_sound: true,
        use_default_show_preview: true
      };

      await this.tdLibApi.setChatNotificationSettings(this.chatId, notificationSettingsObj);
      this.isMuted = !this.isMuted;

      if (this.chat) {
        this.chat.isMuted = this.isMuted;
      }
    } catch (error) {
      logger.error(this.DOMAIN, this.TAG, 'Failed to toggle mute');
      throw new BusinessError(BusinessErrorCode.CHAT_SEND_FAILED, '切换静音失败', '切换静音失败');
    }
  }

  /**
   * 切换置顶状态
   */
  private async togglePin(): Promise<void> {
    if (!this.tdLibApi || this.chatId === 0) {
      return;
    }

    try {
      // 【关键修复】使用具体接口类型和 _ 字段
      const chatListObj: chatListMain = { _: 'chatListMain' };
      await this.tdLibApi.toggleChatIsPinned(chatListObj, this.chatId, !this.isPinned);
      this.isPinned = !this.isPinned;

      if (this.chat) {
        this.chat.isPinned = this.isPinned;
      }
    } catch (error) {
      logger.error(this.DOMAIN, this.TAG, 'Failed to toggle pin');
      throw new BusinessError(BusinessErrorCode.CHAT_SEND_FAILED, '切换置顶失败', '切换置顶失败');
    }
  }

  /**
   * 显示置顶确认对话框
   */
  private showPinDialog(): void {
    this.showPinConfirmation = true;
  }

  /**
   * 清理资源
   */
  private cleanup(): void {
    // 清理逻辑
  }

  /**
   * 获取聊天类型文本
   */
  private getChatTypeText(): string {
    if (!this.chat) return '';
    
    switch (this.chat.type) {
      case 'group':
        return '群组';
      case 'channel':
        return '频道';
      case 'private':
        return '私聊';
      case 'bot':
        return '机器人';
      default:
        return this.chat.type;
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        this.buildLoadingView()
      } else if (!this.chat) {
        this.buildEmptyView()
      } else {
        this.buildContentView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.background)
  }

  @Builder
  buildLoadingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color(this.theme.primary)

      Text($r('app.string.loading'))
        .fontSize(16)
        .fontColor(this.theme.textSecondary)
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildEmptyView() {
    Column() {
      Text($r('app.string.chat_not_found'))
        .fontSize(16)
        .fontColor(this.theme.textSecondary)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildContentView() {
    Column() {
      // 标题栏
      this.buildHeader()

      // Tab栏
      this.buildTabBar()

      // 内容区域
      if (this.selectedTab === 'info') {
        this.buildInfoTab()
      } else if (this.selectedTab === 'members') {
        this.buildMembersTab()
      } else {
        this.buildSettingsTab()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildHeader() {
    Row() {
      Text($r('app.string.chat_info_title'))
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.theme.text)

      Blank()
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .onClick(() => {
      router.back();
    })
  }

  @Builder
  buildTabBar() {
    Row() {
      this.buildTabItem('info', '信息')
      this.buildTabItem('members', '成员')
      this.buildTabItem('settings', '设置')
    }
    .width('100%')
    .height(48)
    .backgroundColor(this.theme.surface)
  }

  @Builder
  buildTabItem(tab: 'info' | 'members' | 'settings', label: string) {
    Column() {
      Text(label)
        .fontSize(16)
        .fontColor(this.selectedTab === tab ? this.theme.primary : this.theme.textSecondary)
        .fontWeight(this.selectedTab === tab ? FontWeight.Medium : FontWeight.Normal)

      if (this.selectedTab === tab) {
        Divider()
          .color(this.theme.primary)
          .strokeWidth(2)
          .margin({ top: 8 })
      }
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.selectedTab = tab;
      if (tab === 'members' && this.members.length === 0) {
        this.loadMembers();
      }
    })
  }

  @Builder
  buildInfoTab() {
    Scroll() {
      Column() {
        // 头像和标题
        this.buildChatHeader()

        Divider()
          .color(this.theme.divider)
          .margin({ top: 16 })

        // 基本信息
        this.buildBasicInfo()

        Divider()
          .color(this.theme.divider)
          .margin({ top: 16 })

        // 操作按钮
        this.buildActionButtons()
      }
      .padding({ left: 16, right: 16 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  @Builder
  buildChatHeader() {
    Column() {
      if (this.chat && this.chat.avatar) {
        Avatar({
          source: this.chat.avatar,
          name: this.chat.title,
          avatarSize: 80
        })
          .margin({ top: 16, bottom: 16 })
      } else {
        Text(this.chat?.title?.charAt(0) || '?')
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.theme.primary)
          .width(80)
          .height(80)
          .textAlign(TextAlign.Center)
          .borderRadius(40)
          .backgroundColor(this.theme.surface)
          .margin({ top: 16, bottom: 16 })
      }

      Text(this.chat?.title || '')
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.theme.text)
        .margin({ bottom: 8 })

      if (this.chat?.description) {
        Text(this.chat.description)
          .fontSize(14)
          .fontColor(this.theme.textSecondary)
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildBasicInfo() {
    Column() {
      this.buildInfoRow('类型', this.getChatTypeText())
      this.buildInfoRow('成员数', this.memberCount > 0 ? this.memberCount.toString() : '-')
    }
    .width('100%')
  }

  @Builder
  buildInfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor(this.theme.textSecondary)
        .width(80)

      Text(value)
        .fontSize(14)
        .fontColor(this.theme.text)
        .layoutWeight(1)
    }
    .width('100%')
    .height(48)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildActionButtons() {
    Column() {
      this.buildActionButton(
        this.isMuted ? '取消静音' : '静音',
        () => {
          this.toggleMute();
        }
      )

      this.buildActionButton(
        this.isPinned ? '取消置顶' : '置顶',
        () => {
          this.showPinDialog();
        }
      )

      this.buildActionButton('清空历史', () => {
        // 清空历史逻辑
      })
    }
    .width('100%')
  }

  @Builder
  buildActionButton(text: string, action: () => void) {
    Button(text)
      .fontSize(16)
      .fontColor(this.theme.primary)
      .backgroundColor(Color.Transparent)
      .width('100%')
      .height(48)
      .onClick(action)
  }

  @Builder
  buildMembersTab() {
    Column() {
      if (this.isLoadingMembers) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color(this.theme.primary)
      } else if (this.members.length === 0) {
        Text($r('app.string.no_members_yet'))
          .fontSize(16)
          .fontColor(this.theme.textSecondary)
      } else {
        List() {
          ForEach(this.members, (member: MemberInfo) => {
            ListItem() {
              this.buildMemberItem(member)
            }
          }, (member: MemberInfo) => member.id.toString())
        }
        .layoutWeight(1)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
  }

  @Builder
  buildMemberItem(member: MemberInfo) {
    Row() {
      if (member.avatar) {
        Avatar({
          source: member.avatar,
          name: member.name,
          avatarSize: 48
        })
      } else {
        Text(member.name.charAt(0))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.theme.primary)
          .width(48)
          .height(48)
          .textAlign(TextAlign.Center)
          .borderRadius(24)
          .backgroundColor(this.theme.surface)
      }

      Column() {
        Text(member.name)
          .fontSize(16)
          .fontColor(this.theme.text)
          .margin({ bottom: 4 })

        Text(member.status)
          .fontSize(12)
          .fontColor(this.theme.textSecondary)
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)

      if (member.role) {
        Text(member.role)
          .fontSize(12)
          .fontColor(this.theme.primary)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
          .backgroundColor(`${this.theme.primary}20`)
      }
    }
    .width('100%')
    .height(64)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      // 跳转到用户详情
    })
  }

  @Builder
  buildSettingsTab() {
    Column() {
      Text($r('app.string.settings_developing'))
        .fontSize(16)
        .fontColor(this.theme.textSecondary)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
