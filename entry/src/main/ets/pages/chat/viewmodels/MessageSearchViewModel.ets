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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { TdApiFactory, TDLibApi } from '../../../services/api';
import { router } from '@kit.ArkUI';

const TAG = 'MessageSearchViewModel';
const DOMAIN = 0x0001;

/**
 * 消息搜索结果
 */
export interface MessageSearchResult {
  id: number;
  chatId: number;
  chatTitle: string;
  chatAvatar?: string;
  content: string;
  timestamp: number;
  formattedTime: string;
  isMedia?: boolean;
  mediaType?: 'photo' | 'video' | 'audio' | 'document' | 'sticker';
  senderId?: number;
  senderName?: string;
  isPinned?: boolean;
}

/**
 * 搜索过滤器
 */
export interface SearchFilters {
  keyword: string;
  chatIds?: number[];
  startDate?: number;
  endDate?: number;
  mediaType?: 'all' | 'photo' | 'video' | 'audio' | 'document' | 'sticker';
  fromUser?: string;
}

/**
 * 路由参数接口
 */
interface RouterParams {
  chatId: number;
  messageId: number;
}

/**
 * TDLib 搜索消息参数
 */
interface SearchMessagesParams {
  '@type': string;
  query: string;
  offset_date?: number;
  limit_date?: number;
  from_user_id?: number;
  offset?: number;
  limit?: number;
  chat_ids?: number[];
  filter?: string;
  min_date?: number;
  max_date?: number;
}

/**
 * TDLib 搜索消息响应
 */
interface SearchMessagesResponse {
  '@type'?: string;
  total_count?: number;
  messages?: Object[];
  next_rate?: number;
}

/**
 * 搜索API包装器接口
 */
interface SearchApiWrapper {
  search: SearchApi;
}

/**
 * 消息搜索 ViewModel
 */
export class MessageSearchViewModel {
  private static instance: MessageSearchViewModel;
  private searchResults: MessageSearchResult[] = [];
  private searchHistory: string[] = [];
  private isLoading: boolean = false;
  private hasMore: boolean = true;
  private currentPage: number = 0;
  private pageSize: number = 20;

  private readonly searchApi: SearchApi;

  private constructor() {
    const tdApis = TdApiFactory.getInstance().createDefault();
    this.searchApi = tdApis.search;
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): MessageSearchViewModel {
    if (!MessageSearchViewModel.instance) {
      MessageSearchViewModel.instance = new MessageSearchViewModel();
    }
    return MessageSearchViewModel.instance;
  }

  /**
   * 搜索消息（使用keyword和filterType）
   */
  public async searchMessages(keyword: string, filterType: 'all' | 'media' | 'files' | 'links'): Promise<void> {
    const mediaTypeFilter: 'photo' | 'document' | undefined = 
      filterType === 'all' ? undefined :
      filterType === 'media' ? 'photo' :
      filterType === 'files' ? 'document' : undefined;
    
    const filters: SearchFilters = {
      keyword: keyword,
      mediaType: mediaTypeFilter
    };
    await this.searchMessagesWithFilters(filters);
  }

  /**
   * 搜索消息（使用SearchFilters对象）
   */
  public async searchMessagesWithFilters(filters: SearchFilters): Promise<void> {
    this.isLoading = true;
    this.currentPage = 0;
    this.searchResults = [];

    try {
      // 调用TDLib搜索API
      const query = filters.keyword || '';
      const offset = this.currentPage * this.pageSize;
      const limit = this.pageSize;

      const fromUserId = filters.fromUser ? parseInt(filters.fromUser) : 0;

      const result = await this.searchApi.searchMessages(
        query,
        offset.toString(),
        limit,
        undefined,
        filters.startDate,
        filters.endDate
      );

      // 处理搜索结果
      if (result) {
        const resultRecord = result as SearchMessagesResponse;
        if (resultRecord.messages) {
          const searchResults: MessageSearchResult[] = [];
          const messages = resultRecord.messages;
          for (let i = 0; i < messages.length; i++) {
            const msg = messages[i] as Record<string, Object>;
            const msgId = msg['id'] as number;
            const msgChatId = msg['chat_id'] as number;
            const msgDate = msg['date'] as number;
            const resultItem: MessageSearchResult = {
              id: msgId,
              chatId: msgChatId,
              chatTitle: '',
              content: this.getMessageContent(msg),
              timestamp: msgDate * 1000,
              formattedTime: this.formatTime(msgDate * 1000),
              isMedia: this.isMediaMessage(msg),
              mediaType: this.getMediaType(msg),
              senderId: 0,
              isPinned: false
            };
            searchResults.push(resultItem);
          }

          this.searchResults = searchResults;
          this.hasMore = searchResults.length >= this.pageSize;
        }
      }

      // 添加到搜索历史
      if (filters.keyword) {
        const historyIndex = this.searchHistory.indexOf(filters.keyword);
        if (historyIndex === -1) {
          this.addToSearchHistory(filters.keyword);
        }
      }

      hilog.info(DOMAIN, TAG, `Found ${this.searchResults.length} messages`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Search failed: ${JSON.stringify(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 加载更多结果
   */
  public async loadMore(filters: SearchFilters): Promise<void> {
    if (this.isLoading || !this.hasMore) {
      return;
    }

    this.isLoading = true;
    this.currentPage++;

    try {
      const query = filters.keyword || '';
      const offset = this.currentPage * this.pageSize;
      const limit = this.pageSize;

      const result = await this.searchApi.searchMessages(
        query,
        offset.toString(),
        limit,
        undefined,
        filters.startDate,
        filters.endDate
      );

      if (result) {
        const resultRecord = result as SearchMessagesResponse;
        if (resultRecord.messages) {
          const moreResults: MessageSearchResult[] = [];
          const messages = resultRecord.messages;
          for (let i = 0; i < messages.length; i++) {
            const msg = messages[i] as Record<string, Object>;
            const msgId = msg['id'] as number;
            const msgChatId = msg['chat_id'] as number;
            const msgDate = msg['date'] as number;
            const resultItem: MessageSearchResult = {
              id: msgId,
              chatId: msgChatId,
              chatTitle: '',
              content: this.getMessageContent(msg),
              timestamp: msgDate * 1000,
              formattedTime: this.formatTime(msgDate * 1000),
              isMedia: this.isMediaMessage(msg),
              mediaType: this.getMediaType(msg),
              senderId: 0
            };
            moreResults.push(resultItem);
          }

          for (let j = 0; j < moreResults.length; j++) {
            this.searchResults.push(moreResults[j]);
          }
          this.hasMore = moreResults.length >= this.pageSize;
        }
      }

      hilog.info(DOMAIN, TAG, `Loaded more messages`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Load more failed: ${JSON.stringify(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 清除搜索结果
   */
  public clearResults(): void {
    this.searchResults = [];
    this.currentPage = 0;
    this.hasMore = true;
  }

  /**
   * 获取搜索结果
   */
  public getResults(): MessageSearchResult[] {
    return [...this.searchResults];
  }

  /**
   * 获取搜索历史
   */
  public getSearchHistory(): string[] {
    return [...this.searchHistory];
  }

  /**
   * 添加到搜索历史
   */
  private addToSearchHistory(keyword: string): void {
    this.searchHistory.unshift(keyword);

    // 限制历史记录数量
    if (this.searchHistory.length > 20) {
      this.searchHistory = this.searchHistory.slice(0, 20);
    }
  }

  /**
   * 清除搜索历史
   */
  public clearSearchHistory(): void {
    this.searchHistory = [];
    hilog.info(DOMAIN, TAG, 'Search history cleared');
  }

  /**
   * 删除指定历史记录
   */
  public deleteFromHistory(keyword: string): void {
    const index = this.searchHistory.indexOf(keyword);
    if (index !== -1) {
      this.searchHistory.splice(index, 1);
    }
  }

  /**
   * 模拟搜索结果获取（保留为辅助方法）
   */
  private async fetchSearchResults(filters: SearchFilters, page: number): Promise<MessageSearchResult[]> {
    await new Promise<void>(resolve => setTimeout(resolve, 300));

    const results: MessageSearchResult[] = [];
    const startIndex = page * this.pageSize;

    for (let i = 0; i < this.pageSize; i++) {
      const id = startIndex + i;
      const resultItem: MessageSearchResult = {
        id: id,
        chatId: id % 5,
        chatTitle: `聊天 ${id % 5}`,
        content: `搜索结果消息 ${id} - ${filters.keyword}`,
        timestamp: Date.now() - id * 3600000,
        formattedTime: this.formatTime(Date.now() - id * 3600000),
        isMedia: id % 3 === 0,
        mediaType: id % 3 === 0 ? 'photo' : undefined,
        senderName: `用户 ${id}`,
        isPinned: id % 10 === 0
      };
      results.push(resultItem);
    }

    return results;
  }

  /**
   * 从TDLib消息对象获取内容
   */
  private getMessageContent(msg: Record<string, Object>): string {
    const msgContent = msg['content'] as Record<string, Object> | undefined;
    if (!msgContent) {
      return '';
    }
    const type = msgContent['@type'] as string;
    if (type === 'messageText') {
      const textObj = msgContent['text'] as Record<string, string> | undefined;
      return textObj ? textObj['text'] || '' : '';
    } else if (type === 'messagePhoto' || type === 'messageVideo' || type === 'messageDocument') {
      const captionObj = msgContent['caption'] as Record<string, string> | undefined;
      return captionObj ? captionObj['text'] || '' : '';
    } else if (type === 'messageSticker') {
      return '[贴纸]';
    } else if (type === 'messageVoiceNote') {
      return '[语音消息]';
    } else if (type === 'messageAudio') {
      return '[音频]';
    }
    return '';
  }

  /**
   * 判断是否为媒体消息
   */
  private isMediaMessage(msg: Record<string, Object>): boolean {
    const msgContent = msg['content'] as Record<string, Object> | undefined;
    if (!msgContent) {
      return false;
    }
    const type = msgContent['@type'] as string;
    const mediaTypes = ['messagePhoto', 'messageVideo', 'messageDocument', 'messageSticker', 'messageAudio', 'messageVoiceNote'];
    return mediaTypes.includes(type);
  }

  /**
   * 获取媒体类型
   */
  private getMediaType(msg: Record<string, Object>): 'photo' | 'video' | 'audio' | 'document' | 'sticker' | undefined {
    const msgContent = msg['content'] as Record<string, Object> | undefined;
    if (!msgContent) {
      return undefined;
    }
    const type = msgContent['@type'] as string;
    if (type === 'messagePhoto') {
      return 'photo';
    } else if (type === 'messageVideo') {
      return 'video';
    } else if (type === 'messageDocument') {
      return 'document';
    } else if (type === 'messageSticker') {
      return 'sticker';
    } else if (type === 'messageAudio' || type === 'messageVoiceNote') {
      return 'audio';
    }
    return undefined;
  }

  /**
   * 格式化时间
   */
  private formatTime(timestamp: number): string {
    const now = Date.now();
    const diff = now - timestamp;
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (days > 365) {
      const date = new Date(timestamp);
      return `${date.getMonth() + 1}/${date.getFullYear()}`;
    } else if (days > 0) {
      return `${days}天前`;
    } else if (hours > 0) {
      return `${hours}小时前`;
    } else if (minutes > 0) {
      return `${minutes}分钟前`;
    } else {
      return '刚刚';
    }
  }

  /**
   * 跳转到消息
   */
  public async jumpToMessage(chatId: number, messageId: number): Promise<boolean> {
    try {
      // 使用router跳转到聊天详情页面并定位消息
      const params: RouterParams = {
        chatId: chatId,
        chatType: ChatType.PRIVATE,
        title: '聊天',
        messageId: messageId
      };

      await router.pushUrl({
        url: 'pages/common/ChatPage',
        params: params
      });

      hilog.info(DOMAIN, TAG, `Jump to message ${messageId} in chat ${chatId}`);
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Jump to message failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * 获取是否正在加载
   */
  public getIsLoading(): boolean {
    return this.isLoading;
  }

  /**
   * 获取搜索结果
   */
  public get results(): MessageSearchResult[] {
    return [...this.searchResults];
  }

  /**
   * 清理资源
   */
  public cleanup(): void {
    this.clearResults();
    this.searchHistory = [];
  }

  /**
   * 获取是否有更多
   */
  public getHasMore(): boolean {
    return this.hasMore;
  }
}
