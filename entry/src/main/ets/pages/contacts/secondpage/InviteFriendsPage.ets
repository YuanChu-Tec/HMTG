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

import { router, promptAction } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CoreService } from '../../../services/business/CoreService';
import { Contact } from '../../../models/TDLibData';
import { TdApiFactory } from '../../../services/api/factory/TdApiFactory';
import { TDLibClient } from '../../../services/core';

const TAG = 'InviteFriendsPage';
const DOMAIN = 0x0001;

/**
 * 邀请好友页面
 */
@Entry
@ComponentV2
export struct InviteFriendsPage {
  @Local contacts: Contact[] = [];
  @Local selectedContacts: Set<number> = new Set<number>();
  @Local searchQuery: string = '';
  @Local isLoading: boolean = false;

  private contactService: CoreService = CoreService.getInstance();
  private tdClient: TDLibClient | null = null;

  aboutToAppear(): Promise<void> {
    // 初始化 TDLib 客户端
    const factory = TdApiFactory.getInstance();
    this.tdClient = factory.getTdClient();
    return this.loadContacts();
  }

  /**
   * 加载联系人
   */
  private async loadContacts(): Promise<void> {
    this.isLoading = true;
    try {
      this.contacts = await this.contactService.getContacts();
    } catch (error) {
      hilog.error(DOMAIN, TAG, `加载联系人失败: ${error}`);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 切换选择状态
   */
  private toggleSelection(contactId: number): void {
    if (this.selectedContacts.has(contactId)) {
      this.selectedContacts.delete(contactId);
    } else {
      this.selectedContacts.add(contactId);
    }
  }

  /**
   * 全选/取消全选
   */
  private toggleSelectAll(): void {
    if (this.selectedContacts.size === this.contacts.length) {
      // 取消全选
      this.selectedContacts.clear();
    } else {
      // 全选
      this.contacts.forEach(contact => {
        this.selectedContacts.add(contact.id);
      });
    }
  }

  /**
   * 是否全选
   */
  private isAllSelected(): boolean {
    return this.contacts.length > 0 && 
           this.selectedContacts.size === this.contacts.length;
  }

  /**
   * 邀请联系人
   */
  private async inviteContacts(): Promise<void> {
    if (this.selectedContacts.size === 0) {
      promptAction.showToast({
        message: '请选择要邀请的联系人',
        duration: 2000
      });
      return;
    }

    if (!this.tdClient) {
      hilog.error(DOMAIN, TAG, 'TDLib client not initialized');
      promptAction.showToast({
        message: '服务未初始化，请重试',
        duration: 2000
      });
      return;
    }

    try {
      // 为每个选中的联系人生成邀请链接
      for (const contactId of Array.from(this.selectedContacts)) {
        const contact = this.contacts.find(c => c.id === contactId);
        if (!contact) continue;

        // 使用 TDLib API 创建私聊并生成邀请链接
        try {
          // 先创建私聊
          const chatParams: Record<string, Object> = {
            '@type': 'createPrivateChat',
            'user_id': contact.id,
            'force': false
          };
          const chatResult = await this.tdClient.execute<Record<string, Object>>(chatParams);

          if (chatResult && (chatResult as Record<string, Object>)['id']) {
            // 生成邀请链接
            const chatId: number = (chatResult as Record<string, Object>)['id'] as number;
            const linkParams: Record<string, Object> = {
              '@type': 'createChatInviteLink',
              'chat_id': chatId
            };
            const inviteLinkResult = await this.tdClient.execute<Record<string, Object>>(linkParams);

            if (inviteLinkResult && (inviteLinkResult as Record<string, Object>)['invite_link']) {
              const inviteLink = (inviteLinkResult as Record<string, Object>)['invite_link'] as string;
              hilog.info(DOMAIN, TAG, `为联系人 ${contact.firstName} 生成邀请链接成功`);
              hilog.info(DOMAIN, TAG, `邀请链接: ${inviteLink}`);
            }
          }
        } catch (error) {
          hilog.error(DOMAIN, TAG, `生成邀请链接失败: ${JSON.stringify(error)}`);
        }
      }

      promptAction.showToast({
        message: `已发送 ${this.selectedContacts.size} 个邀请链接`,
        duration: 2000
      });

      router.back();
    } catch (error) {
      hilog.error(DOMAIN, TAG, `邀请失败: ${JSON.stringify(error)}`);
      promptAction.showToast({
        message: '邀请失败，请重试',
        duration: 2000
      });
    }
  }

  /**
   * 分享邀请链接
   */
  private async shareInviteLink(): Promise<void> {
    if (!this.tdClient) {
      hilog.error(DOMAIN, TAG, 'TDLib client not initialized');
      promptAction.showToast({
        message: '服务未初始化，请重试',
        duration: 2000
      });
      return;
    }

    try {
      // 生成通用邀请链接（使用当前用户的私聊）
      const meParams: Record<string, Object> = {
        '@type': 'getMe'
      };
      const meResult = await this.tdClient.execute<Record<string, Object>>(meParams);

      if (meResult && (meResult as Record<string, Object>)['id']) {
        const userId: number = (meResult as Record<string, Object>)['id'] as number;
        const chatParams: Record<string, Object> = {
          '@type': 'createPrivateChat',
          'user_id': userId,
          'force': false
        };
        const chatResult = await this.tdClient.execute<Record<string, Object>>(chatParams);

        if (chatResult && (chatResult as Record<string, Object>)['id']) {
          const chatId: number = (chatResult as Record<string, Object>)['id'] as number;
          const linkParams: Record<string, Object> = {
            '@type': 'createChatInviteLink',
            'chat_id': chatId
          };
          const result = await this.tdClient.execute<Record<string, Object>>(linkParams);

          const inviteLink = (result as Record<string, Object>)['invite_link'] as string;
          const inviteMessage = `加入我的Telegram: ${inviteLink}`;

          promptAction.showToast({
            message: inviteMessage,
            duration: 2000
          });

          hilog.info(DOMAIN, TAG, `分享邀请链接: ${inviteLink}`);
        }
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `分享邀请链接失败: ${JSON.stringify(error)}`);
      promptAction.showToast({
        message: '分享失败，请重试',
        duration: 2000
      });
    }
  }

  /**
   * 筛选联系人
   */
  private getFilteredContacts(): Contact[] {
    if (!this.searchQuery) {
      return this.contacts;
    }

    const query = this.searchQuery.toLowerCase();
    return this.contacts.filter(contact => {
      const username = contact.usernames && contact.usernames.length > 0 ? contact.usernames[0] : '';
      return contact.firstName?.toLowerCase().includes(query) ||
        contact.lastName?.toLowerCase().includes(query) ||
        username.toLowerCase().includes(query);
    });
  }

  /**
   * 获取选择数量文本
   */
  private getSelectionText(): string {
    const count = this.selectedContacts.size;
    return count > 0 ? `已选择 ${count} 人` : '选择联系人';
  }

  build() {
    Column() {
      // 顶部导航栏
      this.buildNavigationBar()

      // 搜索栏
      this.buildSearchBar()

      // 联系人列表
      if (this.isLoading) {
        this.buildLoadingState()
      } else {
        this.buildContactList()
      }

      // 底部操作栏
      this.buildActionBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  /**
   * 构建导航栏
   */
  @Builder
  private buildNavigationBar() {
    Row() {
      // 返回按钮
      Text('<')
        .fontSize(24)
        .fontColor('#333333')
        .onClick(() => {
          router.back();
        })

      // 标题
      Text('邀请好友')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .margin({ left: 12 })

      // 全选按钮
      Text(this.isAllSelected() ? '取消全选' : '全选')
        .fontSize(16)
        .fontColor('#007DFF')
        .margin({ right: 16 })
        .onClick(() => {
          this.toggleSelectAll();
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .border({ width: { bottom: 0.5 }, color: '#E0E0E0' })
  }

  /**
   * 构建搜索栏
   */
  @Builder
  private buildSearchBar() {
    Row() {
      Search({
        placeholder: '搜索联系人',
        value: this.searchQuery
      })
        .searchButton('')
        .layoutWeight(1)

      // 分享链接按钮
      Image($r('sys.media.ohos_ic_public_share'))
        .width(24)
        .height(24)
        .fillColor('#007DFF')
        .margin({ left: 12 })
        .onClick(() => {
          this.shareInviteLink();
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor('#FFFFFF')
  }

  /**
   * 构建联系人列表
   */
  @Builder
  private buildContactList() {
    List() {
      ForEach(this.getFilteredContacts(), (contact: Contact, index: number) => {
        ListItem() {
          this.buildContactItem(contact, index)
        }
      }, (contact: Contact) => `${contact.id}`)
    }
    .width('100%')
    .layoutWeight(1)
    .divider({
      strokeWidth: 0.5,
      color: '#E0E0E0',
      startMargin: 80,
      endMargin: 0
    })
  }

  /**
   * 构建联系人项
   */
  @Builder
  private buildContactItem(contact: Contact, index: number) {
    Row({ space: 12 }) {
      // 选择复选框
      Stack() {
        Circle()
          .width(20)
          .height(20)
          .stroke(this.selectedContacts.has(contact.id) ? '#007DFF' : '#CCCCCC')
          .strokeWidth(2)

        if (this.selectedContacts.has(contact.id)) {
          Image($r('sys.media.ohos_ic_public_ok'))
            .width(12)
            .height(12)
            .fillColor('#FFFFFF')
        }
      }
      .width(20)
      .height(20)
      .onClick(() => {
        this.toggleSelection(contact.id);
      })

      // 头像
      Circle()
        .width(48)
        .height(48)
        .backgroundColor('#E0E0E0')
        .margin({ left: 8 })

      // 联系人信息
      Column({ space: 4 }) {
        Text(`${contact.firstName || ''} ${contact.lastName || ''}`.trim() || (contact.usernames && contact.usernames.length > 0 ? contact.usernames[0] : 'Unknown') || 'Unknown')
          .fontSize(16)
          .fontColor('#333333')

        if (contact.phone) {
          Text(contact.phone)
            .fontSize(14)
            .fontColor('#666666')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(72)
    .padding({ left: 16, right: 16 })
    .onClick(() => {
      this.toggleSelection(contact.id);
    })
  }


  /**
   * 构建操作栏
   */
  @Builder
  private buildActionBar() {
    Column() {
      Text(this.getSelectionText())
        .fontSize(14)
        .fontColor('#666666')
        .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      Button(`邀请 (${this.selectedContacts.size})`)
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#007DFF')
        .fontColor('#FFFFFF')
        .borderRadius(0)
        .enabled(this.selectedContacts.size > 0)
        .opacity(this.selectedContacts.size > 0 ? 1 : 0.5)
        .margin({ left: 16, right: 16, bottom: 12 })
        .onClick(() => {
          this.inviteContacts();
        })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 0.5 }, color: '#E0E0E0' })
  }

  /**
   * 构建加载状态
   */
  @Builder
  private buildLoadingState() {
    Column() {
      Text('加载中...')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 100 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}
