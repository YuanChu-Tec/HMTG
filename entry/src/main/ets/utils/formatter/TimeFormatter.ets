/**
 * 时间格式化工具
 * 提供相对时间和完整时间格式化
 */

/**
 * 时间格式化工具类
 */
export class TimeFormatter {
  /**
   * 格式化为相对时间
   */
  public static formatRelative(timestamp: number): string {
    const now = Date.now();
    const diff = now - timestamp;
    const seconds = Math.floor(diff / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);
    const months = Math.floor(days / 30);
    const years = Math.floor(days / 365);
    
    if (seconds < 60) {
      return '刚刚';
    } else if (minutes < 60) {
      return `${minutes}分钟前`;
    } else if (hours < 24) {
      return `${hours}小时前`;
    } else if (days < 30) {
      return days === 1 ? '昨天' : `${days}天前`;
    } else if (days < 365) {
      return `${months}个月前`;
    } else {
      return `${years}年前`;
    }
  }
  
  /**
   * 格式化为完整时间
   */
  public static formatFull(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const isToday = date.toDateString() === now.toDateString();
    const isThisYear = date.getFullYear() === now.getFullYear();
    
    if (isToday) {
      // 今天显示时间
      return TimeFormatter.formatTime(date);
    } else if (isThisYear) {
      // 今年显示月-日 时间
      return TimeFormatter.formatMonthDayTime(date);
    } else {
      // 其他显示年-月-日 时间
      return TimeFormatter.formatYearMonthDayTime(date);
    }
  }
  
  /**
   * 格式化为时间（HH:mm）
   */
  public static formatTime(date: Date): string {
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }
  
  /**
   * 格式化为月-日时间
   */
  public static formatMonthDayTime(date: Date): string {
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const time = TimeFormatter.formatTime(date);
    return `${month}-${day} ${time}`;
  }
  
  /**
   * 格式化为年-月-日时间
   */
  public static formatYearMonthDayTime(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const time = TimeFormatter.formatTime(date);
    return `${year}-${month}-${day} ${time}`;
  }
  
  /**
   * 格式化为聊天时间格式
   */
  public static formatChatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const isToday = date.toDateString() === now.toDateString();
    
    if (isToday) {
      return TimeFormatter.formatTime(date);
    } else {
      return TimeFormatter.formatMonthDayTime(date);
    }
  }
  
  /**
   * 获取时间描述（如：今天、昨天、本周、本月）
   */
  public static getTimeDescription(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);
    const thisWeekStart = new Date(today.getTime() - today.getDay() * 24 * 60 * 60 * 1000);
    const thisMonthStart = new Date(now.getFullYear(), now.getMonth(), 1);
    
    if (date >= today) {
      return '今天';
    } else if (date >= yesterday) {
      return '昨天';
    } else if (date >= thisWeekStart) {
      return '本周';
    } else if (date >= thisMonthStart) {
      return '本月';
    } else {
      return '更早';
    }
  }
}
