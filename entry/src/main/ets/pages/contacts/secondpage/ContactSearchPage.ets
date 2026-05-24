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
import { promptAction } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { preferences } from '@kit.ArkData';
import { CoreService } from '../../../services/business/CoreService';
import { Contact, ContactSearchResult } from '../../../models/TDLibData';
import { ImmersiveContainer } from '../../../components/common/ImmersiveContainer';
import { ImmersiveMode, ThemeMode } from '../../../utils/utils/ImmersiveUtils';

const TAG = 'ContactSearchPage';
const DOMAIN = 0x0001;

/**
 * 联系人搜索页面
 */
@Entry
@ComponentV2
export struct ContactSearchPage {
  @Local searchQuery: string = '';
  @Local searchResults: Contact[] = [];
  @Local searchHistory: string[] = [];
  @Local isSearching: boolean = false;
  @Local showHistory: boolean = true;

  private readonly SEARCH_HISTORY_KEY = 'contact_search_history';
  private readonly MAX_HISTORY_COUNT = 10;

  private contactService: CoreService = CoreService.getInstance();

  async aboutToAppear(): Promise<void> {
    await this.loadSearchHistory();
  }

  /**
   * 加载搜索历史
   */
  private async loadSearchHistory(): Promise<void> {
    try {
      const pref = await preferences.getPreferences(getContext(this), 'contact_search_prefs');
      const historyStr = await pref.get(this.SEARCH_HISTORY_KEY, '[]') as string;
      this.searchHistory = JSON.parse(historyStr) as string[];
      hilog.info(DOMAIN, TAG, `加载搜索历史成功: ${this.searchHistory.length} 条`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `加载搜索历史失败: ${JSON.stringify(error)}`);
      this.searchHistory = [];
    }
  }

  /**
   * 保存搜索历史
   */
  private async saveSearchHistory(query: string): Promise<void> {
    try {
      // 移除重复项
      const index = this.searchHistory.indexOf(query);
      if (index > -1) {
        this.searchHistory.splice(index, 1);
      }

      // 添加到开头
      this.searchHistory.unshift(query);

      // 限制历史记录数量
      if (this.searchHistory.length > this.MAX_HISTORY_COUNT) {
        this.searchHistory = this.searchHistory.slice(0, this.MAX_HISTORY_COUNT);
      }

      // 保存到 preferences
      const pref = await preferences.getPreferences(getContext(this), 'contact_search_prefs');
      await pref.put(this.SEARCH_HISTORY_KEY, JSON.stringify(this.searchHistory));
      await pref.flush();

      hilog.debug(DOMAIN, TAG, `保存搜索历史: ${query}`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `保存搜索历史失败: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 执行搜索
   */
  private async performSearch(query: string): Promise<void> {
    if (!query.trim()) {
      this.searchResults = [];
      this.showHistory = true;
      return;
    }

    this.isSearching = true;
    this.showHistory = false;

    try {
      const searchResult: ContactSearchResult = await this.contactService.searchContacts(query);
      this.searchResults = searchResult.contacts;
      
      // 保存搜索历史
      await this.saveSearchHistory(query);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `搜索失败: ${error}`);
      promptAction.showToast({
        message: $r('app.string.search_failed_retry'),
        duration: 2000
      });
    } finally {
      this.isSearching = false;
    }
  }

  /**
   * 处理搜索输入
   */
  private handleSearchInput(value: string): void {
    this.searchQuery = value;
    
    // 防抖处理
    if (this.searchQuery.trim()) {
      this.performSearch(this.searchQuery);
    } else {
      this.searchResults = [];
      this.showHistory = true;
    }
  }

  /**
   * 清除搜索
   */
  private handleClearSearch(): void {
    this.searchQuery = '';
    this.searchResults = [];
    this.showHistory = true;
  }

  /**
   * 使用历史搜索词
   */
  private useHistory(query: string): void {
    this.searchQuery = query;
    this.performSearch(query);
  }

  /**
   * 清除历史记录
   */
  private async handleClearHistory(): Promise<void> {
    try {
      this.searchHistory = [];
      const pref = await preferences.getPreferences(getContext(this), 'contact_search_prefs');
      await pref.delete(this.SEARCH_HISTORY_KEY);
      await pref.flush();

      hilog.info(DOMAIN, TAG, '清除搜索历史成功');
      // 提示用户
      promptAction.showToast({
        message: $r('app.string.search_history_cleared'),
        duration: 2000
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, `清除搜索历史失败: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 查看联系人详情
   */
  private viewContact(contact: Contact): void {
    router.pushUrl({
      url: 'pages/ContactDetailPage',
      params: {
        contactId: contact.id
      }
    });
  }

  /**
   * 添加新联系人
   */
  private handleAddContact(): void {
    router.pushUrl({
      url: 'pages/NewContactPage'
    });
  }

  build() {
    Column() {
      ImmersiveContainer({
        mode: ImmersiveMode.COMPONENT_TOP,
        theme: ThemeMode.AUTO,
        excludeBottom: true
      }) {
        Column() {
          // 搜索栏
          this.buildSearchBar()

          // 内容区域
          if (this.showHistory && this.searchHistory.length > 0) {
            this.buildSearchHistory()
          } else if (this.searchResults.length > 0) {
            this.buildSearchResults()
          } else if (!this.isSearching && this.searchQuery.trim()) {
            this.buildEmptyState()
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F5F5F5')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  /**
   * 构建搜索栏
   */
  @Builder
  private buildSearchBar() {
    Row() {
      // 返回按钮
      Text('<')
        .fontSize(24)
        .fontColor('#333333')
        .onClick(() => {
          router.back();
        })

      // 搜索输入框
      Row({ space: 8 }) {
        Text('🔍')
          .fontSize(20)
          .fontColor('#999999')

        TextInput({
          placeholder: $r('app.string.search_contacts_placeholder'),
          text: this.searchQuery
        })
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .onChange((value: string) => {
            this.handleSearchInput(value);
          })

        // 清除按钮
        if (this.searchQuery) {
          Image($r('sys.media.ohos_ic_public_cancel'))
            .width(20)
            .height(20)
            .fillColor('#999999')
            .onClick(() => {
              this.handleClearSearch();
            })
        }
      }
      .layoutWeight(1)
      .margin({ left: 12, right: 16 })
      .padding({ left: 12, right: 12 })
      .backgroundColor('#F5F5F5')
      .borderRadius(20)

      // 添加按钮
      Text('+')
        .fontSize(24)
        .fontColor('#007DFF')
        .onClick(() => {
          this.handleAddContact();
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .border({ width: { bottom: 0.5 }, color: '#E0E0E0' })
  }

  /**
   * 构建搜索历史
   */
  @Builder
  private buildSearchHistory() {
    Column({ space: 0 }) {
      Row({ space: 8 }) {
        Text($r('app.string.search_history_label'))
          .fontSize(14)
          .fontColor('#999999')
          .layoutWeight(1);

        Text($r('app.string.clear_button'))
          .fontSize(14)
          .fontColor('#007DFF')
          .onClick(() => {
            this.handleClearHistory();
          });
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 12 });

      List() {
        ForEach(this.searchHistory, (query: string, index: number) => {
          ListItem() {
            Text(query)
              .fontSize(14)
              .fontColor('#333333')
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
              .onClick(() => {
                this.useHistory(query);
              });
          }
        }, (query: string, index: number) => `history_${index}`);
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 });
    }
  }

  /**
   * 构建搜索结果
   */
  @Builder
  private buildSearchResults() {
    List() {
      ForEach(this.searchResults, (contact: Contact, index: number) => {
        ListItem() {
          this.buildContactItem(contact);
        }
      }, (contact: Contact) => `${contact.id}`);
    }
    .width('100%')
    .layoutWeight(1)
    .divider({
      strokeWidth: 0.5,
      color: '#E0E0E0',
      startMargin: 80,
      endMargin: 0
    });
  }

  /**
   * 构建联系人项
   */
  @Builder
  private buildContactItem(contact: Contact) {
    Row({ space: 12 }) {
      // 头像
      Circle()
        .width(48)
        .height(48)
        .fill('#E0E0E0');

      // 联系人信息
      Column({ space: 4 }) {
        Text(`${contact.firstName || ''} ${contact.lastName || ''}`.trim() || (contact.usernames && contact.usernames.length > 0 ? contact.usernames[0] : 'Unknown'))
          .fontSize(16)
          .fontColor('#333333');

        if (contact.phone) {
          Text(contact.phone)
            .fontSize(14)
            .fontColor('#666666');
        }

        if (contact.usernames && contact.usernames.length > 0) {
          Text(`@${contact.usernames[0]}`)
            .fontSize(14)
            .fontColor('#007DFF');
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .height(72)
    .padding({ left: 16, right: 16 })
    .onClick(() => {
      this.viewContact(contact);
    });
  }

  /**
   * 构建空状态
   */
  @Builder
  private buildEmptyState() {
    Column({ space: 16 }) {
      Image($r('app.media.ic_search'))
        .width(64)
        .height(64)
        .fillColor('#CCCCCC');

      Text($r('app.string.no_matching_contacts'))
        .fontSize(16)
        .fontColor('#999999');

      Text($r('app.string.try_other_keywords_or_add'))
        .fontSize(14)
        .fontColor('#CCCCCC');
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding({ top: 100 });
  }
}
