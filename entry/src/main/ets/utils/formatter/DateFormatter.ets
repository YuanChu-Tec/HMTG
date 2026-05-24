/**
 * 日期格式化工具类
 */

interface DateFormat {
  FULL: string;
  LONG: string;
  MEDIUM: string;
  SHORT: string;
}

export class DateFormatter {
  private static readonly DATE_FORMATS: DateFormat = {

    FULL: 'full',
    LONG: 'long',
    MEDIUM: 'medium',
    SHORT: 'short'
  };

  /**
   * 格式化日期
   */
  static format(date: Date, format: string = 'medium'): string {
    if (format === DateFormatter.DATE_FORMATS.SHORT || format === 'short' || format === '1') {
      return `${date.getMonth() + 1}/${date.getDate()}/${date.getFullYear().toString().slice(-2)}`;
    } else if (format === DateFormatter.DATE_FORMATS.LONG) {
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return `${months[date.getMonth()]} ${date.getDate()}, ${date.getFullYear()}`;
    } else if (format === DateFormatter.DATE_FORMATS.FULL) {
      const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return `${days[date.getDay()]}, ${months[date.getMonth()]} ${date.getDate()}, ${date.getFullYear()}`;
    } else {
      return date.toLocaleDateString();
    }
  }

  /**
   * 格式化时间
   */
  static formatTime(date: Date, format: '12' | '24' = '24'): string {
    const hours = date.getHours();
    const minutes = date.getMinutes().toString().padStart(2, '0');
    
    if (format === '12') {
      const ampm = hours >= 12 ? 'PM' : 'AM';
      const displayHours = hours % 12 || 12;
      return `${displayHours}:${minutes} ${ampm}`;
    } else {
      return `${hours.toString().padStart(2, '0')}:${minutes}`;
    }
  }

  /**
   * 格式化日期和时间
   */
  static formatDateTime(date: Date): string {
    return `${DateFormatter.format(date)} ${DateFormatter.formatTime(date)}`;
  }

  /**
   * 格式化相对时间（如：5分钟前）
   */
  static formatRelative(timestamp: number | Date): string {
    const date = typeof timestamp === 'number' ? new Date(timestamp) : timestamp;
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const seconds = Math.floor(diff / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);
    const months = Math.floor(days / 30);
    const years = Math.floor(days / 365);

    if (years > 0) {
      return `${years} year${years > 1 ? 's' : ''} ago`;
    } else if (months > 0) {
      return `${months} month${months > 1 ? 's' : ''} ago`;
    } else if (days > 0) {
      return `${days} day${days > 1 ? 's' : ''} ago`;
    } else if (hours > 0) {
      return `${hours} hour${hours > 1 ? 's' : ''} ago`;
    } else if (minutes > 0) {
      return `${minutes} minute${minutes > 1 ? 's' : ''} ago`;
    } else if (seconds > 0) {
      return `${seconds} second${seconds > 1 ? 's' : ''} ago`;
    } else {
      return 'Just now';
    }
  }

  /**
   * 检查是否是今天
   */
  static isToday(date: Date): boolean {
    const today = new Date();
    return date.getDate() === today.getDate() &&
           date.getMonth() === today.getMonth() &&
           date.getFullYear() === today.getFullYear();
  }

  /**
   * 检查是否是昨天
   */
  static isYesterday(date: Date): boolean {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    return date.getDate() === yesterday.getDate() &&
           date.getMonth() === yesterday.getMonth() &&
           date.getFullYear() === yesterday.getFullYear();
  }

  /**
   * 智能格式化（今天显示时间，昨天显示"昨天"，更早显示日期）
   */
  static formatSmart(timestamp: number | Date): string {
    const date = typeof timestamp === 'number' ? new Date(timestamp) : timestamp;

    if (DateFormatter.isToday(date)) {
      return DateFormatter.formatTime(date);
    } else if (DateFormatter.isYesterday(date)) {
      return 'Yesterday';
    } else {
      return DateFormatter.format(date, '1');
    }
  }

  /**
   * 解析日期字符串
   */
  static parse(dateString: string): Date {
    return new Date(dateString);
  }

  /**
   * 获取时间戳
   */
  static getTimestamp(): number {
    return Date.now();
  }
}
