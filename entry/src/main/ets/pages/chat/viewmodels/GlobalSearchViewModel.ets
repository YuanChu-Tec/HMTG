/*
 * Copyright (c) 2026 HMTG Project
 * Licensed under the Apache License, Version 2.0
 *
 * GlobalSearchViewModel.ets - 全局搜索 ViewModel
 * 
 * 支持：
 * - 多分类搜索（全部/联系人/聊天/消息/文件/链接）
 * - 高级搜索语法解析
 * - 搜索结果缓存
 * - 分页加载
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { TdApiFactory, TDLibApi } from '../../../services/api';

const TAG = 'GlobalSearchViewModel';
const DOMAIN = 0x0001;

/**
 * 搜索分类类型
 */
export type SearchCategory = 'all' | 'contacts' | 'chats' | 'messages' | 'files' | 'links';

/**
 * 搜索结果接口
 */
export interface SearchResult {
  id: number;
  type: 'contact' | 'chat' | 'message' | 'file' | 'link' | 'photo' | 'video';
  chatId: number;
  messageId?: number;
  title: string;
  subtitle?: string;
  content?: string;
  highlightedContent?: string;
  avatar?: string;
  source?: string;
  timestamp?: number;
  senderName?: string;
  fileSize?: number;
  fileType?: string;
}

/**
 * 高级搜索过滤器
 */
export interface AdvancedSearchFilter {
  exactPhrase?: string;
  excludeWords?: string[];
  fromUser?: string;
  inChat?: string;
  startDate?: Date;
  endDate?: Date;
  messageType?: 'text' | 'photo' | 'video' | 'audio' | 'document';
  fileExtension?: string;
}

/**
 * 搜索请求参数
 */
interface SearchParams {
  query: string;
  category: SearchCategory;
  offset: number;
  limit: number;
  filters?: AdvancedSearchFilter;
}

/**
 * 全局搜索 ViewModel
 * 单例模式管理全局搜索状态
 */
export class GlobalSearchViewModel {
  private static instance: GlobalSearchViewModel;
  
  // API 实例
  private tdLibApi: TDLibApi | null = null;
  
  // 搜索状态
  private currentQuery: string = '';
  private currentCategory: SearchCategory = 'all';
  private currentOffset: number = 0;
  private readonly pageSize: number = 20;
  
  // 缓存
  private searchCache: Map<string, SearchResult[]> = new Map();
  private cacheExpiry: Map<string, number> = new Map();
  private readonly CACHE_DURATION = 5 * 60 * 1000; // 5分钟缓存

  private constructor() {
    this.initializeApi();
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): GlobalSearchViewModel {
    if (!GlobalSearchViewModel.instance) {
      GlobalSearchViewModel.instance = new GlobalSearchViewModel();
    }
    return GlobalSearchViewModel.instance;
  }

  /**
   * 初始化 TDLib API
   */
  private async initializeApi(): Promise<void> {
    try {
      const apis = TdApiFactory.getInstance().createDefault();
      this.tdLibApi = apis;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to initialize TDLib API: ${error}`);
    }
  }

  /**
   * 执行搜索
   * @param query 搜索关键词
   * @param category 搜索分类
   * @returns 搜索结果列表
   */
  public async search(query: string, category: SearchCategory): Promise<SearchResult[]> {
    this.currentQuery = query;
    this.currentCategory = category;
    this.currentOffset = 0;

    // 检查缓存
    const cacheKey = this.getCacheKey(query, category);
    const cached = this.getFromCache(cacheKey);
    if (cached) {
      hilog.info(DOMAIN, TAG, `Cache hit for "${query}" in ${category}`);
      return cached;
    }

    // 解析高级搜索语法
    const filters = this.parseAdvancedSyntax(query);
    const cleanQuery = this.extractCleanQuery(query);

    try {
      const results = await this.executeSearch({
        query: cleanQuery,
        category,
        offset: 0,
        limit: this.pageSize,
        filters
      });

      // 存入缓存
      this.setCache(cacheKey, results);

      return results;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Search failed: ${error}`);
      return [];
    }
  }

  /**
   * 加载更多结果
   */
  public async loadMore(): Promise<SearchResult[]> {
    this.currentOffset += this.pageSize;

    try {
      const filters = this.parseAdvancedSyntax(this.currentQuery);
      const cleanQuery = this.extractCleanQuery(this.currentQuery);

      return await this.executeSearch({
        query: cleanQuery,
        category: this.currentCategory,
        offset: this.currentOffset,
        limit: this.pageSize,
        filters
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Load more failed: ${error}`);
      return [];
    }
  }

  /**
   * 执行实际搜索请求
   */
  private async executeSearch(params: SearchParams): Promise<SearchResult[]> {
    if (!this.tdLibApi) {
      await this.initializeApi();
    }

    switch (params.category) {
      case 'contacts':
        return this.searchContacts(params);
      case 'chats':
        return this.searchChats(params);
      case 'messages':
        return this.searchMessages(params);
      case 'files':
        return this.searchFiles(params);
      case 'links':
        return this.searchLinks(params);
      case 'all':
      default:
        return this.searchAll(params);
    }
  }

  /**
   * 搜索联系人
   */
  private async searchContacts(params: SearchParams): Promise<SearchResult[]> {
    // TODO: 调用 TDLib searchContacts 或本地缓存
    hilog.info(DOMAIN, TAG, `Searching contacts: ${params.query}`);
    
    // 模拟结果
    return [
      {
        id: 1,
        type: 'contact',
        chatId: 1001,
        title: '张三',
        subtitle: '@zhangsan',
        avatar: '',
        source: '3个共同群组'
      }
    ];
  }

  /**
   * 搜索聊天
   */
  private async searchChats(params: SearchParams): Promise<SearchResult[]> {
    try {
      // 调用 TDLib searchChats
      const result = await this.tdLibApi?.searchChats(params.query, 20);
      // 转换结果格式
      return this.convertChatResults(result);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Search chats failed: ${error}`);
      return [];
    }
  }

  /**
   * 搜索消息
   */
  private async searchMessages(params: SearchParams): Promise<SearchResult[]> {
    try {
      const result = await this.tdLibApi?.searchMessages(
        null, // chatList
        params.query,
        params.filters?.fromUser ? parseInt(params.filters.fromUser) : 0,
        params.offset,
        params.limit,
        undefined // messageThreadId
      );
      return this.convertMessageResults(result);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Search messages failed: ${error}`);
      return [];
    }
  }

  /**
   * 搜索文件
   */
  private async searchFiles(params: SearchParams): Promise<SearchResult[]> {
    // 使用消息搜索 + 文档过滤器
    try {
      const result = await this.tdLibApi?.searchMessages(
        null,
        params.query,
        0,
        params.offset,
        params.limit,
        undefined
      );
      return this.convertFileResults(result);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Search files failed: ${error}`);
      return [];
    }
  }

  /**
   * 搜索链接
   */
  private async searchLinks(params: SearchParams): Promise<SearchResult[]> {
    // 搜索包含 URL 的消息
    try {
      const result = await this.tdLibApi?.searchMessages(
        null,
        params.query,
        0,
        params.offset,
        params.limit,
        undefined
      );
      return this.convertLinkResults(result);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Search links failed: ${error}`);
      return [];
    }
  }

  /**
   * 全部分类搜索
   */
  private async searchAll(params: SearchParams): Promise<SearchResult[]> {
    // 并行搜索多个分类
    const [contacts, chats, messages] = await Promise.all([
      this.searchContacts({ ...params, category: 'contacts' }),
      this.searchChats({ ...params, category: 'chats' }),
      this.searchMessages({ ...params, category: 'messages' })
    ]);

    // 合并结果并按相关性排序
    return [
      ...contacts.slice(0, 3),
      ...chats.slice(0, 5),
      ...messages.slice(0, 12)
    ];
  }

  /**
   * 解析高级搜索语法
   * 支持：
   * - "精确短语" - 双引号包裹
   * - -排除词 - 减号前缀
   * - from:用户名 - 发送者限定
   * - chat:聊天名 - 聊天限定
   * - date:2026-01-01..2026-01-31 - 日期范围
   * - type:photo/video - 类型限定
   */
  private parseAdvancedSyntax(query: string): AdvancedSearchFilter {
    const filters: AdvancedSearchFilter = {};

    // 提取精确短语
    const exactPhraseMatch = query.match(/"([^"]+)"/g);
    if (exactPhraseMatch && exactPhraseMatch.length > 0) {
      filters.exactPhrase = exactPhraseMatch[0].replace(/"/g, '');
    }

    // 提取排除词
    const excludeMatches = query.match(/-(\w+)/g);
    if (excludeMatches) {
      filters.excludeWords = excludeMatches.map(m => m.substring(1));
    }

    // 提取发送者限定
    const fromMatch = query.match(/from:(\w+)/);
    if (fromMatch) {
      filters.fromUser = fromMatch[1];
    }

    // 提取聊天限定
    const chatMatch = query.match(/chat:(\w+)/);
    if (chatMatch) {
      filters.inChat = chatMatch[1];
    }

    // 提取日期范围
    const dateMatch = query.match(/date:(\d{4}-\d{2}-\d{2})\.\.(\d{4}-\d{2}-\d{2})/);
    if (dateMatch) {
      filters.startDate = new Date(dateMatch[1]);
      filters.endDate = new Date(dateMatch[2]);
    }

    // 提取类型限定
    const typeMatch = query.match(/type:(\w+)/);
    if (typeMatch) {
      const type = typeMatch[1];
      if (['text', 'photo', 'video', 'audio', 'document'].includes(type)) {
        filters.messageType = type as any;
      }
    }

    // 提取文件扩展名
    const fileMatch = query.match(/file:(\w+)/);
    if (fileMatch) {
      filters.fileExtension = fileMatch[1];
    }

    return filters;
  }

  /**
   * 提取干净的搜索词（移除高级语法）
   */
  private extractCleanQuery(query: string): string {
    return query
      .replace(/"[^"]*"/g, '') // 移除精确短语标记
      .replace(/-\w+/g, '') // 移除排除词
      .replace(/\w+:\S+/g, '') // 移除限定符
      .trim();
  }

  /**
   * 转换聊天搜索结果
   */
  private convertChatResults(result: any): SearchResult[] {
    if (!result || !result.chat_ids) return [];
    
    return result.chat_ids.map((chatId: number, index: number) => ({
      id: chatId,
      type: 'chat',
      chatId: chatId,
      title: `聊天 ${chatId}`, // TODO: 获取实际标题
      subtitle: '',
      timestamp: Date.now()
    }));
  }

  /**
   * 转换消息搜索结果
   */
  private convertMessageResults(result: any): SearchResult[] {
    if (!result || !result.messages) return [];

    return result.messages.map((msg: any) => ({
      id: msg.id,
      type: 'message',
      chatId: msg.chat_id,
      messageId: msg.id,
      title: msg.sender_name || '未知发送者',
      content: msg.content?.text || '',
      highlightedContent: this.highlightKeywords(msg.content?.text || '', this.currentQuery),
      timestamp: msg.date * 1000,
      senderName: msg.sender_name
    }));
  }

  /**
   * 转换文件搜索结果
   */
  private convertFileResults(result: any): SearchResult[] {
    const messages = this.convertMessageResults(result);
    return messages.filter(m => 
      m.content?.includes('.pdf') || 
      m.content?.includes('.doc') ||
      m.content?.includes('.xls')
    ).map(m => ({
      ...m,
      type: 'file' as const,
      fileType: this.extractFileType(m.content || ''),
      fileSize: 0 // TODO: 获取实际文件大小
    }));
  }

  /**
   * 转换链接搜索结果
   */
  private convertLinkResults(result: any): SearchResult[] {
    const messages = this.convertMessageResults(result);
    const urlRegex = /https?:\/\/\S+/;
    return messages.filter(m => urlRegex.test(m.content || '')).map(m => {
      const urlMatch = m.content?.match(urlRegex);
      return {
        ...m,
        type: 'link' as const,
        subtitle: urlMatch ? urlMatch[0] : ''
      };
    });
  }

  /**
   * 高亮关键词
   */
  private highlightKeywords(text: string, query: string): string {
    if (!query || !text) return text;
    
    const keywords = query.split(/\s+/).filter(k => k.length > 0);
    let highlighted = text;
    
    keywords.forEach(keyword => {
      const regex = new RegExp(`(${keyword})`, 'gi');
      highlighted = highlighted.replace(regex, '**$1**');
    });
    
    return highlighted;
  }

  /**
   * 提取文件类型
   */
  private extractFileType(filename: string): string {
    const ext = filename.split('.').pop()?.toLowerCase();
    const typeMap: Record<string, string> = {
      'pdf': 'PDF',
      'doc': 'Word',
      'docx': 'Word',
      'xls': 'Excel',
      'xlsx': 'Excel',
      'ppt': 'PPT',
      'pptx': 'PPT',
      'txt': '文本',
      'zip': '压缩包',
      'rar': '压缩包'
    };
    return typeMap[ext || ''] || '文件';
  }

  /**
   * 缓存相关方法
   */
  private getCacheKey(query: string, category: string): string {
    return `${category}:${query.toLowerCase()}`;
  }

  private getFromCache(key: string): SearchResult[] | null {
    const expiry = this.cacheExpiry.get(key);
    if (expiry && Date.now() > expiry) {
      this.searchCache.delete(key);
      this.cacheExpiry.delete(key);
      return null;
    }
    return this.searchCache.get(key) || null;
  }

  private setCache(key: string, results: SearchResult[]): void {
    this.searchCache.set(key, results);
    this.cacheExpiry.set(key, Date.now() + this.CACHE_DURATION);
  }

  /**
   * 清除缓存
   */
  public clearCache(): void {
    this.searchCache.clear();
    this.cacheExpiry.clear();
  }
}
