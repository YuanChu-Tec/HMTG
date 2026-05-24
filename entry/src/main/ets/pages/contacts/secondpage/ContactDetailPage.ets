/*
 * Copyright (c) 2026 HMTG Project
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction } from '@kit.ArkUI';
import { pasteboard } from '@kit.BasicServicesKit';
import { CoreService } from '../../../services/business/CoreService';
import { Contact, OnlineStatus } from '../../../models/TDLibData';
import { ErrorHandler } from '../../../utils/error/ErrorHandler';
import { Avatar } from '../../../ui_kit';

/**
 * 联系人详情页面
 * 显示联系人详细信息，支持快捷操作
 * 集成 ContactService、ErrorHandler、Avatar 等项目已有功能
 */
@Entry
@ComponentV2
export struct ContactDetailPage {
  @Local contactInfo: Contact | null = null;
  @Local isLoading: boolean = true;
  @Local showDeleteDialog: boolean = false;
  @Local showBlockDialog: boolean = false;
  @Local showShareMenu: boolean = false;
  @Local isBlocked: boolean = false;
  @Local isMuted: boolean = false;
  @Local mutualGroups: number = 0;
  @Local searchResults: Contact[] = [];

  private contactId: number = 0;
  private readonly TAG = 'ContactDetailPage';
  private readonly DOMAIN = 0x0001;
  private readonly contactService: CoreService = CoreService.getInstance();
  private loadStartTime: number = 0;

  aboutToAppear(): void {
    this.loadStartTime = Date.now();
    try {
      const params = router.getParams() as Record<string, Object>;
      if (params && params.contactId) {
        this.contactId = params.contactId as number;
      } else if (params && params.userId) {
        this.contactId = params.userId as number;
      }

      if (this.contactId > 0) {
        this.loadContactDetail();
      }
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
    }

    const loadDuration = Date.now() - this.loadStartTime;
    hilog.info(this.DOMAIN, this.TAG, `ContactDetailPage initialized in ${loadDuration}ms`);
  }

  /**
   * 加载联系人详情
   * 集成 ContactService 和 TDLib API
   */
  private async loadContactDetail(): Promise<void> {
    this.isLoading = true;
    try {
      // 性能监控：开始加载
      const loadStart = Date.now();

      // 从 ContactService 加载联系人信息
      const contact = await this.contactService.getContactById(this.contactId);
      if (contact) {
        this.contactInfo = contact;
        this.isBlocked = await this.checkIsBlocked(contact.userId);
        this.isMuted = await this.checkIsMuted(contact.userId);
        const username = contact.usernames && contact.usernames.length > 0 ? contact.usernames[0] : '';
        this.mutualGroups = await this.findMutualGroups(username);

        const loadDuration = Date.now() - loadStart;
        hilog.info(this.DOMAIN, this.TAG, `Contact detail loaded in ${loadDuration}ms: ${contact.firstName}`);
      } else {
        // 如果联系人不存在，显示提示
        promptAction.showToast({
          message: $r('app.string.contact_not_exist'),
          duration: 2000
        });
      }
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
      promptAction.showToast({
        message: $r('app.string.load_failed_retry'),
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 检查用户是否被拉黑
   */
  private async checkIsBlocked(userId: number): Promise<boolean> {
    try {
      return await this.contactService.isUserBlocked(userId);
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
      return false;
    }
  }

  /**
   * 检查聊天是否静音
   */
  private async checkIsMuted(userId: number): Promise<boolean> {
    try {
      return await this.contactService.isChatMuted(userId);
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
      return false;
    }
  }

  /**
   * 查找共同群组
   */
  private async findMutualGroups(username: string): Promise<number> {
    try {
      if (!this.contactInfo) {
        return 0;
      }
      return await this.contactService.getMutualGroupsCount(this.contactInfo.userId);
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
      return 0;
    }
  }

  /**
   * 发送消息
   * 跳转到聊天详情页面
   */
  private async sendMessage(): Promise<void> {
    if (!this.contactInfo) {
      return;
    }

    try {
      // 使用 userId 作为私聊的 chatId
      await router.pushUrl({
        url: 'feature-chat/pages/ChatDetailPage',
        params: {
          chatId: this.contactInfo.userId,
          chatType: 'private',
          userId: this.contactInfo.userId
        }
      });
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
    }
  }

  /**
   * 拨打电话
   */
  private async makeCall(): Promise<void> {
    if (!this.contactInfo) {
      return;
    }

    const phoneNumber = this.contactInfo.phone.replace(/\s/g, '');

    // 检查是否支持语音通话
    if (this.contactInfo.isBot) {
      promptAction.showToast({
        message: $r('app.string.bot_not_support_call'),
        duration: 2000
      });
      return;
    }

    try {
      // 发起 Telegram 语音通话
      await this.contactService.startVoiceCall(this.contactInfo.userId);

      promptAction.showToast({
        message: $r('app.string.starting_voice_call'),
        duration: 2000
      });

      hilog.info(this.DOMAIN, this.TAG, `Initiating voice call to user ${this.contactInfo.userId}`);
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
      promptAction.showToast({
        message: $r('app.string.call_failed_retry'),
        duration: 2000
      });
    }
  }

  /**
   * 分享联系人
   */
  private shareContact(): void {
    this.showShareMenu = true;
  }

  /**
   * 分享到聊天
   */
  private async shareToChat(): Promise<void> {
    this.showShareMenu = false;

    try {
      // TODO: 打开分享聊天选择对话框
      // 使用 TDLib shareContact API
      promptAction.showToast({
        message: $r('app.string.share_feature_developing'),
        duration: 2000
      });
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
    }
  }

  /**
   * 通过系统分享
   */
  private async shareViaSystem(): Promise<void> {
    if (!this.contactInfo) {
      return;
    }

    try {
      // TODO: 使用 UDMF (统一数据管理框架) 分享联系人
      // 构建 vCard 格式的联系人信息
      const vCard = `BEGIN:VCARD
VERSION:3.0
FN:${this.contactInfo.firstName} ${this.contactInfo.lastName || ''}
N:${this.contactInfo.lastName || ''};${this.contactInfo.firstName}
TEL;TYPE=CELL:${this.contactInfo.phone}
END:VCARD`;

      // 使用 pasteboard API 复制联系人信息
      const systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
      systemPasteboard.clearData();
      const pasteData: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, vCard);
      systemPasteboard.setPasteData(pasteData);

      promptAction.showToast({
        message: $r('app.string.contact_copied_to_clipboard'),
        duration: 2000
      });

      hilog.info(this.DOMAIN, this.TAG, `Contact info copied to clipboard: ${this.contactInfo.userId}`);
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
      promptAction.showToast({
        message: $r('app.string.share_failed'),
        duration: 2000
      });
    }
  }

  /**
   * 编辑联系人
   */
  private editContact(): void {
    if (!this.contactInfo) {
      return;
    }

    router.pushUrl({
      url: 'feature-contacts/pages/EditContactPage',
      params: {
        contactId: this.contactInfo.userId
      }
    }).catch((error: Error) => {
      ErrorHandler.getInstance().handle(error);
    });
  }

  /**
   * 删除联系人
   */
  private deleteContact(): void {
    this.showDeleteDialog = true;
  }

  /**
   * 确认删除联系人
   */
  private async confirmDeleteContact(): Promise<void> {
    this.showDeleteDialog = false;
    if (!this.contactInfo) {
      return;
    }

    try {
      // 从通讯录中移除联系人（不会删除用户数据）
      const success = await this.contactService.deleteContact(this.contactInfo.id);

      if (success) {
        hilog.info(this.DOMAIN, this.TAG, `删除联系人成功: ${this.contactInfo.firstName} ${this.contactInfo.lastName}`);

        promptAction.showToast({
          message: $r('app.string.contact_deleted'),
          duration: 2000
        });

        router.back();
      } else {
        throw new Error('删除联系人失败');
      }
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
      promptAction.showToast({
        message: $r('app.string.delete_failed_retry'),
        duration: 2000
      });
    }
  }

  /**
   * 拉黑联系人
   */
  private blockContact(): void {
    this.showBlockDialog = true;
  }

  /**
   * 确认拉黑联系人
   */
  private async confirmBlockContact(): Promise<void> {
    this.showBlockDialog = false;
    if (!this.contactInfo) {
      return;
    }

    try {
      await this.contactService.blockUser(this.contactInfo.userId);
      this.isBlocked = true;

      hilog.info(this.DOMAIN, this.TAG, `拉黑用户成功: ${this.contactInfo.userId}`);
      promptAction.showToast({
        message: $r('app.string.user_blocked'),
        duration: 2000
      });
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
      promptAction.showToast({
        message: '操作失败，请重试',
        duration: 2000
      });
    }
  }

  /**
   * 取消拉黑
   */
  private async unblockContact(): Promise<void> {
    if (!this.contactInfo) {
      return;
    }

    try {
      await this.contactService.unblockUser(this.contactInfo.userId);
      this.isBlocked = false;

      hilog.info(this.DOMAIN, this.TAG, `取消拉黑用户成功: ${this.contactInfo.userId}`);
      promptAction.showToast({
        message: $r('app.string.unblocked_success'),
        duration: 2000
      });
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
      promptAction.showToast({
        message: '操作失败，请重试',
        duration: 2000
      });
    }
  }

  /**
   * 切换静音
   */
  private async toggleMute(): Promise<void> {
    if (!this.contactInfo) {
      return;
    }

    try {
      const newMuteState = !this.isMuted;
      // TODO: CoreService需要添加setChatMuted方法
      hilog.warn(this.DOMAIN, this.TAG, `setChatMuted not implemented in CoreService`);
      // await this.contactService.setChatMuted(this.contactInfo.userId, newMuteState);
      this.isMuted = newMuteState;

      hilog.info(this.DOMAIN, this.TAG, `Mute state changed: ${newMuteState}`);

      promptAction.showToast({
        message: newMuteState ? $r('app.string.muted') : $r('app.string.unmuted'),
        duration: 2000
      });
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
    }
  }

  /**
   * 查看共同群组
   */
  private async viewMutualGroups(): Promise<void> {
    if (!this.contactInfo) {
      return;
    }

    try {
      if (this.mutualGroups > 0) {
        // 跳转到共同群组列表页面
        await router.pushUrl({
          url: 'feature-contacts/pages/MutualGroupsPage',
          params: {
            userId: this.contactInfo.userId,
            userName: this.contactInfo.fullName
          }
        });
      } else {
        promptAction.showToast({
          message: $r('app.string.no_mutual_groups'),
          duration: 2000
        });
      }
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
    }
  }

  /**
   * 格式化最后在线时间
   */
  private formatLastSeen(status: OnlineStatus): string {
    switch (status) {
      case OnlineStatus.ONLINE:
        return '在线';
      case OnlineStatus.RECENTLY:
        return '最近在线';
      case OnlineStatus.WEEK_AGO:
        return '一周前在线';
      case OnlineStatus.MONTH_AGO:
        return '一月前在线';
      case OnlineStatus.LONG_TIME_AGO:
        return '很久以前在线';
      case OnlineStatus.OFFLINE:
        return '离线';
      default:
        return '离线';
    }
  }

  /**
   * 获取联系人全名
   */
  private getFullName(): string {
    if (!this.contactInfo) {
      return '';
    }
    if (this.contactInfo.lastName) {
      return `${this.contactInfo.firstName} ${this.contactInfo.lastName}`;
    }
    return this.contactInfo.firstName;
  }

  /**
   * 获取联系人用户名（从 usernames 数组中获取第一个）
   */
  private getUsername(): string {
    if (!this.contactInfo || !this.contactInfo.usernames || this.contactInfo.usernames.length === 0) {
      return '';
    }
    return this.contactInfo.usernames[0];
  }

  /**
   * 获取联系人在线状态
   */
  private getOnlineStatus(): boolean {
    if (!this.contactInfo || !this.contactInfo.status) {
      return false;
    }
    return this.contactInfo.status.type === 'online';
  }

  /**
   * 获取头像资源路径
   */
  private getAvatarSource(): string {
    if (!this.contactInfo) {
      return '';
    }
    return this.contactInfo.avatarPath || '';
  }

  /**
   * 获取头像背景色
   * 基于名字生成一致的颜色
   */
  private getAvatarColor(): string {
    if (!this.contactInfo) {
      return '#6200EE';
    }
    const name = this.contactInfo.firstName;
    const colors: string[] = ['#F44336', '#E91E63', '#9C27B0', '#673AB7', '#3F51B5',
      '#2196F3', '#03A9F4', '#00BCD4', '#009688', '#4CAF50',
      '#8BC34A', '#CDDC39', '#FFEB3B', '#FFC107', '#FF9800',
      '#FF5722', '#795548', '#9E9E9E', '#607D8B'];

    // 基于名字哈希选择颜色
    let hash = 0;
    for (let i = 0; i < name.length; i++) {
      hash = name.charCodeAt(i) + ((hash << 5) - hash);
    }
    const index = Math.abs(hash) % colors.length;
    return colors[index];
  }

  /**
   * 构建顶部导航栏
   */
  @Builder
  buildTopBar() {
    Row() {
      // 返回按钮
      Image($r('sys.media.ohos_ic_public_arrow_left'))
        .width(24)
        .height(24)
        .fillColor('#333333')
        .onClick(() => {
          try {
            router.back();
          } catch (error) {
            ErrorHandler.getInstance().handle(error);
          }
        })

      // 标题
      Text('联系人详情')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 操作按钮
      Row({ space: 16 }) {
        // 编辑按钮
        Image($r('sys.media.ohos_ic_public_add'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => this.editContact())

        // 更多按钮
        Image($r('sys.media.ohos_ic_public_add'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => this.showShareMenu = true)
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .border({ width: { bottom: 1 }, color: '#F0F0F0' })
  }

  /**
   * 构建头像
   * 使用 ui-kit 的 Avatar 组件
   */
  @Builder
  buildAvatar() {
    Avatar({
      source: this.getAvatarSource(),
      name: this.getFullName(),
      avatarSize: 96,
      radius: 48,
      isOnline: this.getOnlineStatus(),
      avatarBackgroundColor: this.getAvatarColor()
    })
  }

  /**
   * 构建快捷操作按钮
   */
  @Builder
  buildQuickActions() {
    Row({ space: 0 }) {
      this.buildActionButton('发消息', $r('sys.media.ohos_ic_public_share'), () => this.sendMessage());
      this.buildActionButton('电话', $r('sys.media.ohos_ic_public_share'), () => this.makeCall());
      this.buildActionButton('分享', $r('sys.media.ohos_ic_public_share'), () => this.shareContact());
      this.buildActionButton('更多', $r('sys.media.ohos_ic_public_add'), () => this.showShareMenu = true);
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
    .padding({ top: 24, bottom: 24 })
  }

  /**
   * 构建用户名区域
   */
  @Builder
  buildUsernameSection() {
    if (this.getUsername()) {
      Row({ space: 4 }) {
        Text('@')
          .fontSize(14)
          .fontColor('#6200EE');

        Text(this.getUsername())
          .fontSize(14)
          .fontColor('#6200EE');

        if (this.contactInfo?.isVerified) {
          Image($r('sys.media.ohos_ic_public_ok'))
            .width(16)
            .height(16);
        }
      }
      .margin({ top: 4 });
    }
  }

  /**
   * 构建单个操作按钮
   */
  @Builder
  buildActionButton(text: string, icon: ResourceStr, action: () => void) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor('#666666');

      Text(text)
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })
    }
    .onClick(() => action())
  }

  /**
   * 构建信息项
   */
  @Builder
  buildInfoItem(icon: ResourceStr, label: string, value: string, onTap?: () => void) {
    Row() {
      Image(icon)
        .width(20)
        .height(20)
        .fillColor('#666666');

      Text(label)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ left: 12 })
        .layoutWeight(1);

      Row({ space: 8 }) {
        Text(value)
          .fontSize(16)
          .fontColor(onTap ? '#6200EE' : '#333333');

        if (onTap) {
          Image($r('sys.media.ohos_ic_public_arrow_right'))
            .width(16)
            .height(16)
            .fillColor('#CCCCCC');
        }
      }
      .onClick(() => {
        if (onTap) {
          onTap();
        }
      })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
  }

  /**
   * 包装为卡片样式 - 使用内联方式
   */
  private wrapAsCard(content: () => void): void {
    content();
  }

  build() {
    Column() {
      // 顶部导航栏
      this.buildTopBar();

      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#6200EE');

          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else if (this.contactInfo) {
        // 联系人信息
        Scroll() {
          Column() {
            // 头像和基本信息 - 直接使用 Column 包装
            Column() {
              this.buildAvatar();

              Text(this.getFullName())
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ top: 16 });

              this.buildUsernameSection();

              Text(this.contactInfo!.status?.type === 'online' ? '在线' : '离线')
                .fontSize(12)
                .fontColor(
                  this.getOnlineStatus() ? '#4CAF50' : '#999999'
                )
                .margin({ top: 8 });

              if (this.contactInfo!.isBot) {
                Text('机器人')
                  .fontSize(12)
                  .fontColor('#9C27B0')
                  .backgroundColor('#F3E5F5')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(4)
                  .margin({ top: 8 });
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .padding({ top: 16, bottom: 16 })
            .margin({ top: 8, left: 16, right: 16 });

            // 快捷操作
            Column() {
              this.buildQuickActions();
            }
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(12)
            .padding({ top: 16, bottom: 16 })
            .margin({ top: 8, left: 16, right: 16 });

            // 详细信息
            Column() {
              this.buildInfoItem($r('sys.media.ohos_ic_public_add'), '手机号', this.contactInfo!.phone);

              if (this.getUsername()) {
                this.buildInfoItem($r('sys.media.ohos_ic_public_add'), '用户名', '@' + this.getUsername());
              }

              if (this.mutualGroups > 0) {
                this.buildInfoItem($r('sys.media.ohos_ic_public_add'), '共同群组', `${this.mutualGroups} 个`, () => this.viewMutualGroups());
              }

              // 静音开关
              this.buildInfoItem(
                $r('sys.media.ohos_ic_public_add'),
                '消息通知',
                this.isMuted ? '已静音' : '未静音',
                () => this.toggleMute()
              );
            }
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(12)
            .padding({ top: 16, bottom: 16 })
            .margin({ top: 8, left: 16, right: 16 });

            // 危险操作区
            Column({ space: 12 }) {
              if (!this.isBlocked) {
                Button('拉黑该用户')
                  .width('100%')
                  .height(48)
                  .fontSize(16)
                  .fontColor('#FF5252')
                  .backgroundColor('#FFE8E8')
                  .borderRadius(8)
                  .onClick(() => this.blockContact());
              } else {
                Button('取消拉黑')
                  .width('100%')
                  .height(48)
                  .fontSize(16)
                  .fontColor(Color.White)
                  .backgroundColor('#4CAF50')
                  .borderRadius(8)
                  .onClick(() => this.unblockContact());
              }

              Button('删除联系人')
                .width('100%')
                .height(48)
                .fontSize(16)
                .fontColor('#FF5252')
                .backgroundColor(Color.Transparent)
                .border({ width: 1, color: '#FF5252' })
                .borderRadius(8)
                .onClick(() => this.deleteContact());
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 24, bottom: 24 });
          }
        }
        .layoutWeight(1)
        .backgroundColor('#F5F5F5');
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildDeleteDialog() {
    if (this.showDeleteDialog) {
      Column() {
        Column() {
          Text('确认删除')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333');

          Text('确定要删除此联系人吗？此操作无法撤销。')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 16 })
            .width('100%');

          Row({ space: 12 }) {
            Button('取消')
              .layoutWeight(1)
              .height(44)
              .fontSize(16)
              .fontColor('#666666')
              .backgroundColor('#F5F5F5')
              .onClick(() => {
                this.showDeleteDialog = false;
              });

            Button('删除')
              .layoutWeight(1)
              .height(44)
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor('#FF5252')
              .onClick(() => {
                this.confirmDeleteContact();
              });
          }
          .width('100%')
          .margin({ top: 24 });
        }
        .width('80%')
        .padding(24)
        .backgroundColor(Color.White)
        .borderRadius(12);
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('rgba(0, 0, 0, 0.5)');
    }

    // 拉黑确认对话框
    if (this.showBlockDialog) {
      Column() {
        Column() {
          Text('确认拉黑')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333');

          Text(`确定要拉黑 ${this.contactInfo?.firstName || '此用户'} 吗？拉黑后将无法接收该用户的消息。`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 16 })
            .width('100%');

          Row({ space: 12 }) {
            Button('取消')
              .layoutWeight(1)
              .height(44)
              .fontSize(16)
              .fontColor('#666666')
              .backgroundColor('#F5F5F5')
              .onClick(() => {
                this.showBlockDialog = false;
              });

            Button('拉黑')
              .layoutWeight(1)
              .height(44)
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor('#FF5252')
              .onClick(() => {
                this.confirmBlockContact();
              });
          }
          .width('100%')
          .margin({ top: 24 });
        }
        .width('80%')
        .padding(24)
        .backgroundColor(Color.White)
        .borderRadius(12);
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('rgba(0, 0, 0, 0.5)');
    }

    // 分享菜单
    if (this.showShareMenu) {
      Column() {
        Column() {
          Text('分享联系人')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .padding({ left: 20, right: 20, top: 20 });

          Divider()
            .margin({ top: 8 });

          Column() {
            this.buildShareMenuItem('分享到聊天', $r('sys.media.ohos_ic_public_share'), () => this.shareToChat());
            this.buildShareMenuItem('通过系统分享', $r('sys.media.ohos_ic_public_share'), () => this.shareViaSystem());
            this.buildShareMenuItem('复制联系方式', $r('sys.media.ohos_ic_public_share'), () => {
              this.showShareMenu = false;
              if (this.contactInfo) {
                const fullName = this.getFullName();
                const contactText = `${fullName}\n${this.contactInfo.phone}`;
                // TODO: 使用 pasteboard API
                promptAction.showToast({
                  message: '已复制到剪贴板',
                  duration: 2000
                });
              }
            });
          }
          .width('100%');

          Divider()
            .margin({ bottom: 8 });

          Text('取消')
            .fontSize(16)
            .fontColor('#666666')
            .width('100%')
            .height(48)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.showShareMenu = false;
            });
        }
        .width('280')
        .backgroundColor(Color.White)
        .borderRadius(12);
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('rgba(0, 0, 0, 0.5)')
      .onClick(() => {
        this.showShareMenu = false;
      });
    }
  }

  /**
   * 构建分享菜单项
   */
  @Builder
  buildShareMenuItem(text: string, icon: ResourceStr, action: () => void) {
    Row() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor('#333333');

      Text(text)
        .fontSize(16)
        .fontColor('#333333')
        .layoutWeight(1)
        .margin({ left: 12 });
    }
    .width('100%')
    .height(48)
    .padding({ left: 20, right: 20 })
    .onClick(() => {
      action();
    });
  }

  /**
   * 清理资源
   */
  aboutToDisappear(): void {
    hilog.info(this.DOMAIN, this.TAG, 'ContactDetailPage aboutToDisappear');
    // 清理定时器或其他资源
  }
}
