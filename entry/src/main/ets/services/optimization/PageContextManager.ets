/**
 * 页面上下文管理器（参考微信/QQ的页面优先级策略）
 * 功能：
 * 1. 跟踪当前活跃页面
 * 2. 为当前页面数据请求提供更高优先级
 * 3. 优化资源分配，确保当前页面数据优先加载
 */
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'PageContextManager';
const DOMAIN = 0x0001;

/** 页面类型 */
export enum PageType {
  CHAT_LIST = 'chatList',
  CHAT_DETAIL = 'chatDetail',
  CONTACT = 'contact',
  SETTINGS = 'settings',
  OTHER = 'other'
}

export class PageContextManager {
  private static instance: PageContextManager;
  private currentPageType: PageType = PageType.OTHER;
  private currentChatId: number = 0;
  
  private constructor() {}
  
  public static getInstance(): PageContextManager {
    if (!PageContextManager.instance) {
      PageContextManager.instance = new PageContextManager();
    }
    return PageContextManager.instance;
  }
  
  /**
   * 设置当前页面（页面进入时调用）
   */
  public setCurrentPage(pageType: PageType, chatId: number = 0): void {
    this.currentPageType = pageType;
    this.currentChatId = chatId;
    hilog.info(DOMAIN, TAG, `Current page: ${pageType}, chatId: ${chatId}`);
  }
  
  /**
   * 清除当前页面（页面退出时调用）
   */
  public clearCurrentPage(): void {
    this.currentPageType = PageType.OTHER;
    this.currentChatId = 0;
  }
  
  /**
   * 检查是否为当前页面的数据请求
   */
  public isCurrentPageRequest(pageType: PageType, chatId: number = 0): boolean {
    if (this.currentPageType !== pageType) {
      return false;
    }
    if (pageType === PageType.CHAT_DETAIL && chatId > 0) {
      return this.currentChatId === chatId;
    }
    return true;
  }
  
  /**
   * 获取当前页面类型
   */
  public getCurrentPageType(): PageType {
    return this.currentPageType;
  }
  
  /**
   * 获取当前聊天ID
   */
  public getCurrentChatId(): number {
    return this.currentChatId;
  }
  
  /**
   * 检查是否为当前聊天页面的消息请求
   */
  public isCurrentChatMessages(chatId: number): boolean {
    return this.currentPageType === PageType.CHAT_DETAIL && this.currentChatId === chatId;
  }
}
