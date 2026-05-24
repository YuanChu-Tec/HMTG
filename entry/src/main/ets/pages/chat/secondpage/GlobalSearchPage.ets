/*
 * Copyright (c) 2026 HMTG Project
 * Licensed under the Apache License, Version 2.0
 *
 * GlobalSearchPage.ets - 全局搜索页面（Telegram 2026 风格）
 * 
 * 特性：
 * - Liquid Glass 半透明模糊背景
 * - 分类标签页：全部/联系人/聊天/消息/文件/链接
 * - 搜索历史记录（本地存储）
 * - 高级搜索语法支持
 * - AI 智能搜索入口
 */

import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { dataPreferences } from '@kit.BasicServicesKit';
import { ChatType } from '../../../models/TDLibData';
import { GlobalSearchViewModel, SearchResult, SearchCategory } from '../viewmodels/GlobalSearchViewModel';

const TAG = 'GlobalSearchPage';
const DOMAIN = 0x0001;
const HISTORY_PREF_KEY = 'global_search_history';
const MAX_HISTORY_ITEMS = 10;

/**
 * 全局搜索页面 - Telegram 2026 风格
 * 全屏独立页面，Liquid Glass 设计语言
 */
@Entry({ routeName: 'GlobalSearchPage' })
@ComponentV2
export struct GlobalSearchPage {
  // ==================== 状态变量 ====================
  @Local searchText: string = '';
  @Local selectedCategory: SearchCategory = 'all';
  @Local searchResults: SearchResult[] = [];
  @Local searchHistory: string[] = [];
  @Local isLoading: boolean = false;
  @Local hasMore: boolean = true;
  @Local showHistory: boolean = true;
  @Local isSearchFocused: boolean = false;
  
  // AI 助手相关
  @Local showAIEntry: boolean = true;
  @Local aiSuggestions: string[] = [
    '查找上周的照片',
    '总结工作群的消息',
    '找到小明的联系方式'
  ];

  // ==================== 私有属性 ====================
  private viewModel: GlobalSearchViewModel = GlobalSearchViewModel.getInstance();
  private searchTimeoutId: number = -1;
  private pref: dataPreferences.Preferences | null = null;

  // ==================== 生命周期 ====================
  aboutToAppear(): void {
    this.initializePreferences();
    this.loadSearchHistory();
    hilog.info(DOMAIN, TAG, 'GlobalSearchPage appeared');
  }

  aboutToDisappear(): void {
    if (this.searchTimeoutId !== -1) {
      clearTimeout(this.searchTimeoutId);
    }
    hilog.info(DOMAIN, TAG, 'GlobalSearchPage disappeared');
  }

  // ==================== 初始化方法 ====================
  private async initializePreferences(): Promise<void> {
    try {
      this.pref = await dataPreferences.getPreferences(getContext(), 'search_prefs');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to initialize preferences: ${error}`);
    }
  }

  private async loadSearchHistory(): Promise<void> {
    try {
      if (!this.pref) {
        await this.initializePreferences();
      }
      const historyJson = await this.pref?.get(HISTORY_PREF_KEY, '[]') as string;
      this.searchHistory = JSON.parse(historyJson);
      this.showHistory = this.searchHistory.length > 0 && this.searchText === '';
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to load search history: ${error}`);
      this.searchHistory = [];
    }
  }

  private async saveSearchHistory(): Promise<void> {
    try {
      if (!this.pref) return;
      await this.pref.put(HISTORY_PREF_KEY, JSON.stringify(this.searchHistory));
      await this.pref.flush();
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to save search history: ${error}`);
    }
  }

  // ==================== 搜索逻辑 ====================
  private onSearchTextChange(value: string): void {
    this.searchText = value;
    
    // 清除之前的搜索定时器
    if (this.searchTimeoutId !== -1) {
      clearTimeout(this.searchTimeoutId);
    }

    if (!value.trim()) {
      // 空输入时显示历史记录
      this.showHistory = this.searchHistory.length > 0;
      this.searchResults = [];
      this.showAIEntry = true;
      return;
    }

    // 隐藏历史记录和 AI 入口
    this.showHistory = false;
    this.showAIEntry = false;

    // 防抖搜索（300ms）
    this.searchTimeoutId = setTimeout(() => {
      this.performSearch(value);
    }, 300) as number;
  }

  private async performSearch(query: string): Promise<void> {
    if (!query.trim()) return;

    this.isLoading = true;
    this.hasMore = true;

    try {
      // 添加到搜索历史
      this.addToHistory(query);

      // 执行搜索
      const results = await this.viewModel.search(query, this.selectedCategory);
      this.searchResults = results;
      this.hasMore = results.length >= 20; // 假设每页20条

      hilog.info(DOMAIN, TAG, `Search completed: ${results.length} results for "${query}"`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Search failed: ${error}`);
      this.searchResults = [];
    } finally {
      this.isLoading = false;
    }
  }

  private addToHistory(query: string): void {
    // 移除重复项
    this.searchHistory = this.searchHistory.filter(item => item !== query);
    // 添加到开头
    this.searchHistory.unshift(query);
    // 限制数量
    if (this.searchHistory.length > MAX_HISTORY_ITEMS) {
      this.searchHistory = this.searchHistory.slice(0, MAX_HISTORY_ITEMS);
    }
    // 异步保存
    this.saveSearchHistory();
  }

  private async deleteHistoryItem(index: number): Promise<void> {
    this.searchHistory.splice(index, 1);
    await this.saveSearchHistory();
    this.showHistory = this.searchHistory.length > 0;
  }

  private async clearAllHistory(): Promise<void> {
    this.searchHistory = [];
    await this.saveSearchHistory();
    this.showHistory = false;
  }

  private onCategoryChange(category: SearchCategory): void {
    this.selectedCategory = category;
    if (this.searchText.trim()) {
      this.performSearch(this.searchText);
    }
  }

  // ==================== 导航方法 ====================
  private goBack(): void {
    router.back();
  }

  private navigateToResult(result: SearchResult): void {
    switch (result.type) {
      case 'contact':
        // 跳转到联系人详情或私聊
        router.pushUrl({
          url: 'pages/common/ChatPage',
          params: { chatId: result.chatId }
        });
        break;
      case 'chat':
      case 'message':
        // 跳转到聊天页面
        router.pushUrl({
          url: 'pages/common/ChatPage',
          params: { 
            chatId: result.chatId,
            highlightMessageId: result.messageId 
          }
        });
        break;
      case 'file':
        // 打开文件预览
        break;
      case 'link':
        // 打开链接
        break;
    }
  }

  // ==================== Builder 方法 ====================
  @Builder
  private buildTopBar() {
    Row() {
      // 返回按钮
      Text('←')
        .fontSize(24)
        .fontColor('#007AFF')
        .padding(12)
        .onClick(() => this.goBack())

      // 搜索输入框
      Row() {
        Text('🔍')
          .fontSize(16)
          .margin({ left: 12, right: 8 })
        
        TextInput({ placeholder: '搜索', text: this.searchText })
          .placeholderColor('#8E8E93')
          .fontSize(17)
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .onChange((value) => this.onSearchTextChange(value))
          .onFocus(() => this.isSearchFocused = true)
          .onBlur(() => this.isSearchFocused = false)

        // 清除按钮
        if (this.searchText !== '') {
          Text('✕')
            .fontSize(14)
            .fontColor('#8E8E93')
            .padding(8)
            .onClick(() => {
              this.searchText = '';
              this.onSearchTextChange('');
            })
        }
      }
      .height(40)
      .layoutWeight(1)
      .backgroundColor('#F2F2F7')
      .borderRadius(20)
      .margin({ left: 8, right: 12 })

      // 取消按钮
      Text('取消')
        .fontSize(17)
        .fontColor('#007AFF')
        .padding(12)
        .onClick(() => this.goBack())
    }
    .width('100%')
    .height(60)
    .padding({ left: 4, right: 4 })
    .backgroundColor('rgba(255,255,255,0.92)')
    // Liquid Glass 效果
    .backdropBlur(20)
  }

  @Builder
  private buildCategoryTabs() {
    Row() {
      // 分类标签
      this.buildCategoryTab('全部', 'all')
      this.buildCategoryTab('联系人', 'contacts')
      this.buildCategoryTab('聊天', 'chats')
      this.buildCategoryTab('消息', 'messages')
      this.buildCategoryTab('文件', 'files')
      this.buildCategoryTab('链接', 'links')
    }
    .width('100%')
    .height(44)
    .padding({ left: 12, right: 12 })
    .backgroundColor('rgba(255,255,255,0.92)')
    .backdropBlur(20)
  }

  @Builder
  private buildCategoryTab(label: string, category: SearchCategory) {
    const isSelected = this.selectedCategory === category;
    
    Column() {
      Text(label)
        .fontSize(15)
        .fontWeight(isSelected ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(isSelected ? '#007AFF' : '#8E8E93')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      
      // 选中指示条
      if (isSelected) {
        Column()
          .width(20)
          .height(3)
          .backgroundColor('#007AFF')
          .borderRadius(1.5)
      }
    }
    .onClick(() => this.onCategoryChange(category))
  }

  @Builder
  private buildSearchHistory() {
    Column() {
      // 标题栏
      Row() {
        Text('最近搜索')
          .fontSize(13)
          .fontColor('#8E8E93')
          .fontWeight(FontWeight.Medium)
        
        Blank().layoutWeight(1)
        
        Text('清除')
          .fontSize(13)
          .fontColor('#007AFF')
          .onClick(() => this.clearAllHistory())
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      // 历史记录列表
      List() {
        ForEach(this.searchHistory, (item: string, index: number) => {
          ListItem() {
            Row() {
              Text('🕐')
                .fontSize(16)
                .margin({ right: 12 })
              
              Text(item)
                .fontSize(16)
                .fontColor('#000000')
                .layoutWeight(1)
              
              Text('✕')
                .fontSize(14)
                .fontColor('#C7C7CC')
                .padding(8)
                .onClick(() => this.deleteHistoryItem(index))
            }
            .width('100%')
            .padding({ left: 16, right: 8, top: 12, bottom: 12 })
            .onClick(() => {
              this.searchText = item;
              this.onSearchTextChange(item);
            })
          }
          .swipeAction({ end: this.buildDeleteAction(index) })
        }, (item: string, index: number) => index.toString())
      }
      .width('100%')
      .layoutWeight(1)
      .divider({ strokeWidth: 0.5, color: '#E5E5EA' })
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  private buildDeleteAction(index: number) {
    Column() {
      Text('删除')
        .fontSize(16)
        .fontColor(Color.White)
        .padding({ left: 20, right: 20 })
    }
    .width(80)
    .height('100%')
    .backgroundColor('#FA2A2D')
    .justifyContent(FlexAlign.Center)
    .onClick(() => this.deleteHistoryItem(index))
  }

  @Builder
  private buildAIEntry() {
    Column() {
      // AI 助手入口
      Row() {
        Text('✨')
          .fontSize(24)
          .margin({ right: 12 })
        
        Column() {
          Text('AI 智能搜索')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#000000')
          
          Text('用自然语言查找内容')
            .fontSize(13)
            .fontColor('#8E8E93')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        Text('›')
          .fontSize(24)
          .fontColor('#C7C7CC')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('rgba(0,122,255,0.08)')
      .borderRadius(12)
      .margin({ left: 16, right: 16, top: 12, bottom: 12 })
      .onClick(() => {
        // TODO: 打开 AI 搜索界面
        hilog.info(DOMAIN, TAG, 'AI search entry clicked');
      })

      // AI 建议问题
      if (this.aiSuggestions.length > 0) {
        Text('试试这样问')
          .fontSize(13)
          .fontColor('#8E8E93')
          .margin({ left: 16, top: 8, bottom: 8 })
        
        Row() {
          ForEach(this.aiSuggestions, (suggestion: string, index: number) => {
            Text(suggestion)
              .fontSize(14)
              .fontColor('#007AFF')
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor('rgba(0,122,255,0.1)')
              .borderRadius(16)
              .margin({ right: 8 })
              .onClick(() => {
                this.searchText = suggestion;
                this.onSearchTextChange(suggestion);
              })
          }, (item: string, index: number) => index.toString())
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
    }
    .width('100%')
  }

  @Builder
  private buildSearchResults() {
    List() {
      // 加载中指示器
      if (this.isLoading && this.searchResults.length === 0) {
        ListItem() {
          Column() {
            LoadingProgress()
              .width(40)
              .height(40)
              .color('#007AFF')
            Text('搜索中...')
              .fontSize(14)
              .fontColor('#8E8E93')
              .margin({ top: 12 })
          }
          .width('100%')
          .padding(40)
        }
      }

      // 搜索结果列表
      ForEach(this.searchResults, (result: SearchResult, index: number) => {
        ListItem() {
          this.buildResultItem(result)
        }
        .onClick(() => this.navigateToResult(result))
      }, (result: SearchResult) => result.id.toString())

      // 加载更多
      if (this.hasMore && !this.isLoading && this.searchResults.length > 0) {
        ListItem() {
          Column() {
            LoadingProgress()
              .width(24)
              .height(24)
              .color('#007AFF')
          }
          .width('100%')
          .padding(16)
          .onClick(() => this.loadMore())
        }
      }

      // 空状态
      if (!this.isLoading && this.searchResults.length === 0 && this.searchText !== '') {
        ListItem() {
          Column() {
            Text('🔍')
              .fontSize(48)
              .margin({ bottom: 16 })
            Text('未找到结果')
              .fontSize(17)
              .fontColor('#8E8E93')
            Text('尝试其他关键词或检查拼写')
              .fontSize(14)
              .fontColor('#C7C7CC')
              .margin({ top: 8 })
          }
          .width('100%')
          .padding(60)
        }
      }
    }
    .width('100%')
    .layoutWeight(1)
    .divider({ strokeWidth: 0.5, color: '#E5E5EA' })
  }

  @Builder
  private buildResultItem(result: SearchResult) {
    Row() {
      // 头像或图标
      if (result.avatar) {
        Image(result.avatar)
          .width(48)
          .height(48)
          .borderRadius(24)
          .objectFit(ImageFit.Cover)
      } else {
        Column() {
          Text(this.getResultIcon(result.type))
            .fontSize(24)
        }
        .width(48)
        .height(48)
        .backgroundColor('#F2F2F7')
        .borderRadius(24)
        .justifyContent(FlexAlign.Center)
      }

      // 内容区域
      Column() {
        // 标题行
        Row() {
          Text(result.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#000000')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          
          if (result.timestamp) {
            Text(this.formatTime(result.timestamp))
              .fontSize(12)
              .fontColor('#8E8E93')
              .margin({ left: 8 })
          }
        }
        .width('100%')

        // 副标题/内容
        if (result.subtitle) {
          Text(result.subtitle)
            .fontSize(14)
            .fontColor('#8E8E93')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })
        }

        // 匹配内容高亮
        if (result.highlightedContent) {
          Text(result.highlightedContent)
            .fontSize(14)
            .fontColor('#000000')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })
            // 高亮样式通过 Span 实现
        }

        // 来源信息
        if (result.source) {
          Text(result.source)
            .fontSize(12)
            .fontColor('#C7C7CC')
            .margin({ top: 4 })
        }
      }
      .margin({ left: 12 })
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
  }

  // ==================== 辅助方法 ====================
  private getResultIcon(type: string): string {
    switch (type) {
      case 'contact': return '👤';
      case 'chat': return '💬';
      case 'message': return '📝';
      case 'file': return '📎';
      case 'link': return '🔗';
      case 'photo': return '📷';
      case 'video': return '🎬';
      default: return '📄';
    }
  }

  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const diffDays = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60 * 24));
    
    if (diffDays === 0) {
      return date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });
    } else if (diffDays === 1) {
      return '昨天';
    } else if (diffDays < 7) {
      const days = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      return days[date.getDay()];
    } else {
      return date.toLocaleDateString('zh-CN', { month: 'short', day: 'numeric' });
    }
  }

  private async loadMore(): Promise<void> {
    if (this.isLoading || !this.hasMore) return;
    
    this.isLoading = true;
    try {
      const moreResults = await this.viewModel.loadMore();
      this.searchResults.push(...moreResults);
      this.hasMore = moreResults.length >= 20;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to load more: ${error}`);
    } finally {
      this.isLoading = false;
    }
  }

  // ==================== 主构建方法 ====================
  build() {
    Column() {
      // 顶部栏
      this.buildTopBar()

      // 分类标签
      this.buildCategoryTabs()

      // 内容区域
      if (this.showHistory) {
        // 显示历史记录
        this.buildSearchHistory()
        
        // AI 入口
        if (this.showAIEntry) {
          this.buildAIEntry()
        }
      } else {
        // 显示搜索结果
        this.buildSearchResults()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(255,255,255,0.96)')
    // Liquid Glass 整体背景效果
    .backdropBlur(10)
  }
}
