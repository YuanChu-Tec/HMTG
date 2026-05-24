// file: MessageSearchPage.ets - 消息搜索页面
/**
 * 消息搜索页面
 * 支持跨聊天消息搜索、历史记录、筛选
 */

import { router } from '@kit.ArkUI';
import { SearchBar, Avatar, ThemeManager } from '../../../ui_kit';
import { logger } from '../../../utils/log/LogService';
import { BusinessError, BusinessErrorCode } from '../../../utils/error/BusinessError';
import { TDLibApi, createTdLibAPIs } from '../../../services/api';
import type { ChatList, SearchMessagesFilter$Input, SearchMessagesChatTypeFilter$Input } from '../../../services/api/factory/tdlib-types';
import { ChatType } from '../../../models/TDLibData';

/**
 * 消息搜索结果
 */
interface SearchResult {
  id: number;
  chatId: number;
  chatTitle: string;
  title?: string;
  chatAvatar?: string;
  content: string;
  timestamp: number;
  type: 'text' | 'photo' | 'video' | 'file' | 'link';
}

/**
 * 搜索过滤器类型
 */
type SearchFilter = 'all' | 'media' | 'files' | 'links';

/**
 * 搜索主题颜色接口
 */
interface SearchThemeColors {
  background: string;
  surface: string;
  text: string;
  textSecondary: string;
  textHint: string;
  primary: string;
  divider: string;
}

@Entry({ routeName: 'MessageSearchPage' })
@ComponentV2
export struct MessageSearchPage {
  @Local searchText: string = '';
  @Local selectedFilter: SearchFilter = 'all';
  @Local searchResults: SearchResult[] = [];
  @Local searchHistory: string[] = [];
  @Local isLoading: boolean = false;
  @Local hasMore: boolean = true;
  @Local showHistory: boolean = false;

  private readonly TAG = 'MessageSearchPage';
  private readonly HISTORY_KEY = 'search_history';
  private readonly MAX_HISTORY = 10;

  private tdLibApi: TDLibApi | null = null;
  private currentPage: number = 0;
  private searchTimeoutId: number = -1;

  private theme: SearchThemeColors = {
    background: '#FFFFFF',
    surface: '#F5F5F5',
    text: '#000000',
    textSecondary: '#666666',
    textHint: '#999999',
    primary: '#0088CC',
    divider: '#E0E0E0'
  };

  aboutToAppear(): void {
    this.initializeTheme();
    this.initializeTdLibAPIs();
    this.loadSearchHistory();
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

    const newTheme: SearchThemeColors = {
      background: colors.surface,
      surface: colors.primary,
      text: colors.text,
      textSecondary: colors.textSecondary,
      textHint: colors.border,
      primary: colors.primary,
      divider: colors.divider
    };
    this.theme = newTheme;
  }

  /**
   * 初始化 TDLib APIs
   */
  private async initializeTdLibAPIs(): Promise<void> {
    try {
      this.tdLibApi = await createTdLibAPIs();
    } catch (error) {
      logger.error(0x0001, 'MessageSearch', 'Failed to initialize TDLib APIs');
    }
  }

  /**
   * 加载搜索历史
   */
  private async loadSearchHistory(): Promise<void> {
    try {
      // TODO: 从 Preferences 加载历史记录
      this.searchHistory = [];
    } catch (error) {
      logger.error(0x0001, 'MessageSearch', 'Failed to load search history');
    }
  }

  /**
   * 处理搜索变化
   */
  private handleSearchChange(value: string): void {
    this.searchText = value;

    if (this.searchTimeoutId !== -1) {
      clearTimeout(this.searchTimeoutId);
    }

    if (!value) {
      this.showHistory = this.searchHistory.length > 0;
      this.searchResults = [];
    } else {
      this.searchTimeoutId = setTimeout(() => {
        this.performSearch(value);
      }, 300) as number;
    }
  }

  /**
   * 保存搜索历史
   */
  private async saveSearchHistory(query: string): Promise<void> {
    if (!query.trim()) {
      return;
    }

    try {
      // 移除重复项
      this.searchHistory = this.searchHistory.filter(item => item !== query);
      // 添加到开头
      this.searchHistory.unshift(query);
      // 限制数量
      if (this.searchHistory.length > this.MAX_HISTORY) {
        this.searchHistory = this.searchHistory.slice(0, this.MAX_HISTORY);
      }

      // TODO: 保存到 Preferences
    } catch (error) {
      logger.error(0x0001, 'MessageSearch', 'Failed to save search history');
    }
  }

  /**
   * 清除搜索历史
   */
  private clearSearchHistory(): void {
    this.searchHistory = [];
    // TODO: 清除 Preferences 中的历史记录
  }

  /**
   * 执行搜索
   */
  private async performSearch(query: string): Promise<void> {
    if (!query.trim() || !this.tdLibApi) {
      return;
    }

    this.isLoading = true;
    this.currentPage = 0;
    this.searchResults = [];
    this.showHistory = false;

    try {
      const chatList: ChatList | null = null;
      const filter: SearchMessagesFilter$Input | null = null;
      const chatTypeFilter: SearchMessagesChatTypeFilter$Input | null = null;
      
      const resultsObj = await this.tdLibApi.searchMessages(
        chatList,
        query,
        '0',
        50,
        filter,
        chatTypeFilter,
        0,
        0
      );
      
      if (resultsObj && resultsObj.messages) {
        const messagesArray = resultsObj.messages as Object[];
        for (let i = 0; i < messagesArray.length; i++) {
          const msg = messagesArray[i] as Record<string, Object>;
          const chatId = msg['chat_id'] as number || 0;
          const searchResult: SearchResult = {
            id: msg['id'] as number || 0,
            chatId: chatId,
            chatTitle: `Chat ${chatId}`,
            content: this.extractContent(msg),
            timestamp: (msg['date'] as number) || 0,
            type: this.getMessageType(msg)
          };
          this.searchResults.push(searchResult);
        }
        this.hasMore = messagesArray.length >= 50;
      } else {
        this.searchResults = [];
        this.hasMore = false;
      }
    } catch (error) {
      logger.error(0x0001, 'MessageSearch', 'Failed to search messages');
      throw new BusinessError(BusinessErrorCode.MESSAGE_NOT_FOUND, 'Search failed', '搜索失败');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 提取消息内容
   */
  private extractContent(msg: Record<string, Object>): string {
    const msgContent = msg['content'] as Record<string, Object> | undefined;
    if (msgContent) {
      const textObj = msgContent['text'] as Record<string, string> | undefined;
      if (textObj) {
        return textObj['text'] || '';
      }
      const captionObj = msgContent['caption'] as Record<string, string> | undefined;
      if (captionObj) {
        return captionObj['text'] || '';
      }
    }
    return '[媒体消息]';
  }

  /**
   * 获取消息类型
   */
  private getMessageType(msg: Record<string, Object>): 'text' | 'photo' | 'video' | 'file' | 'link' {
    const msgContent = msg['content'] as Record<string, Object> | undefined;
    if (msgContent) {
      if (msgContent['photo']) return 'photo';
      if (msgContent['video']) return 'video';
      if (msgContent['document']) return 'file';
    }
    return 'text';
  }

  /**
   * 筛选结果
   */
  private getFilteredResults(): SearchResult[] {
    if (this.selectedFilter === 'all') {
      return this.searchResults;
    }
    return this.searchResults.filter(result => {
      switch (this.selectedFilter) {
        case 'media':
          return result.type === 'photo' || result.type === 'video';
        case 'files':
          return result.type === 'file';
        case 'links':
          return result.content.includes('http');
        default:
          return true;
      }
    });
  }

  /**
   * 加载更多结果
   */
  private async loadMoreResults(): Promise<void> {
    if (!this.hasMore || !this.tdLibApi || !this.searchText) {
      return;
    }

    try {
      const offset = (this.currentPage * 50).toString();
      const chatList: ChatList | null = null;
      const filter: SearchMessagesFilter$Input | null = null;
      const chatTypeFilter: SearchMessagesChatTypeFilter$Input | null = null;
      
      const resultsObj = await this.tdLibApi.searchMessages(
        chatList,
        this.searchText,
        offset,
        50,
        filter,
        chatTypeFilter,
        0,
        0
      );
      
      if (resultsObj && resultsObj.messages) {
        const messagesArray = resultsObj.messages as Object[];
        const newResults: SearchResult[] = [];
        for (let i = 0; i < messagesArray.length; i++) {
          const msg = messagesArray[i] as Record<string, Object>;
          const chatId = msg['chat_id'] as number || 0;
          const searchResult: SearchResult = {
            id: msg['id'] as number || 0,
            chatId: chatId,
            chatTitle: `Chat ${chatId}`,
            content: this.extractContent(msg),
            timestamp: (msg['date'] as number) || 0,
            type: this.getMessageType(msg)
          };
          newResults.push(searchResult);
        }

        this.searchResults = this.searchResults.concat(newResults);
        this.hasMore = newResults.length >= 50;
      } else {
        this.hasMore = false;
      }
    } catch (error) {
      logger.error(0x0001, 'MessageSearch', `Failed to load more results: ${error}`);
    }
  }

  /**
   * 跳转到消息
   */
  private navigateToMessage(result: SearchResult): void {
    try {
      router.pushUrl({
        url: 'pages/common/ChatPage',
        params: {
          chatId: result.chatId,
          chatType: ChatType.PRIVATE,
          title: result.title || '聊天',
          messageId: result.id
        }
      });
    } catch (error) {
      logger.error(0x0001, 'MessageSearch', `Failed to navigate to message: ${error}`);
    }
  }

  /**
   * 格式化时间
   */
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp * 1000);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));

    if (days === 0) {
      return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    } else if (days === 1) {
      return '昨天';
    } else if (days < 7) {
      const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      return weekdays[date.getDay()];
    } else {
      return date.toLocaleDateString([], { month: '2-digit', day: '2-digit' });
    }
  }

  /**
   * 清理资源
   */
  private cleanup(): void {
    if (this.searchTimeoutId !== -1) {
      clearTimeout(this.searchTimeoutId);
    }
  }

  build() {
    Column() {
      // 标题栏
      this.buildHeader()

      // 搜索栏
      this.buildSearchBar()

      // 筛选栏
      this.buildFilterBar()

      // 内容区域
      if (this.showHistory && this.searchHistory.length > 0) {
        this.buildSearchHistory()
      } else if (this.isLoading) {
        this.buildLoadingView()
      } else if (this.getFilteredResults().length === 0 && this.searchText) {
        this.buildEmptyView()
      } else {
        this.buildResultsList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.background)
  }

  @Builder
  buildHeader() {
    Row() {
      Text('搜索消息')
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
  buildSearchBar() {
    Row() {
      Search({
        placeholder: '搜索消息',
        value: this.searchText
      })
        .placeholderColor(this.theme.textHint)
        .backgroundColor(this.theme.surface)
        .height(40)
        .layoutWeight(1)
        .onChange((value: string) => {
          this.handleSearchChange(value);
        })

      if (this.searchText) {
        Button('清除')
          .fontSize(14)
          .fontColor(this.theme.primary)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.searchText = '';
            this.searchResults = [];
            this.showHistory = this.searchHistory.length > 0;
          })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  buildFilterBar() {
    Row() {
      this.buildFilterItem('all', '全部')
      this.buildFilterItem('media', '媒体')
      this.buildFilterItem('files', '文件')
      this.buildFilterItem('links', '链接')
    }
    .width('100%')
    .height(40)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  buildFilterItem(filter: SearchFilter, label: string) {
    Text(label)
      .fontSize(14)
      .fontColor(this.selectedFilter === filter ? this.theme.primary : this.theme.textSecondary)
      .padding({ left: 12, right: 12 })
      .height(28)
      .borderRadius(14)
      .backgroundColor(this.selectedFilter === filter ? `${this.theme.primary}20` : 'transparent')
      .onClick(() => {
        this.selectedFilter = filter;
      })
  }

  @Builder
  buildSearchHistory() {
    Column() {
      Row() {
        Text('搜索历史')
          .fontSize(14)
          .fontColor(this.theme.textSecondary)

        Blank()

        if (this.searchHistory.length > 0) {
          Text('清除')
            .fontSize(14)
            .fontColor(this.theme.primary)
            .onClick(() => {
              this.clearSearchHistory();
            })
        }
      }
      .width('100%')
      .height(40)
      .alignItems(VerticalAlign.Center)

      List() {
        ForEach(this.searchHistory, (item: string, index: number) => {
          ListItem() {
            Row() {
              Text(item)
                .fontSize(16)
                .fontColor(this.theme.text)
                .layoutWeight(1)

              Text('×')
                .fontSize(20)
                .fontColor(this.theme.textSecondary)
                .onClick(() => {
                  this.searchHistory.splice(index, 1);
                  this.searchHistory = [...this.searchHistory];
                })
            }
            .width('100%')
            .height(48)
            .alignItems(VerticalAlign.Center)
          }
        }, (item: string, index: number) => `${index}_${item}`)
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
  }

  @Builder
  buildLoadingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color(this.theme.primary)

      Text('搜索中...')
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
      Text('未找到相关消息')
        .fontSize(16)
        .fontColor(this.theme.textSecondary)
        .margin({ top: 100 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildResultsList() {
    List({ space: 8 }) {
      ForEach(this.getFilteredResults(), (result: SearchResult) => {
        ListItem() {
          this.buildResultItem(result)
        }
      }, (result: SearchResult) => result.id.toString())
    }
    .layoutWeight(1)
    .width('100%')
    .padding({ left: 16, right: 16 })
    .onReachEnd(() => {
      if (this.hasMore) {
        this.loadMoreResults();
      }
    })
  }

  @Builder
  buildResultItem(result: SearchResult) {
    Row() {
      // 聊天头像
      if (result.chatAvatar) {
        Avatar({
          source: result.chatAvatar,
          name: result.chatTitle,
          avatarSize: 48
        })
      } else {
        Text(result.chatTitle.charAt(0))
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
        Row() {
          Text(result.chatTitle)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.theme.text)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          Text(this.formatTime(result.timestamp))
            .fontSize(12)
            .fontColor(this.theme.textSecondary)
        }
        .width('100%')
        .margin({ bottom: 4 })

        Text(result.content)
          .fontSize(14)
          .fontColor(this.theme.textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(72)
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .borderRadius(8)
    .backgroundColor(this.theme.surface)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.navigateToMessage(result);
    })
  }
}
