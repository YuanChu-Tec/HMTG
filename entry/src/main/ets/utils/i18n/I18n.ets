// file: I18n.ets - 国际化工具类，提供多语言支持、时间格式化、复数处理等功能

import { i18n as I18nSys } from '@kit.LocalizationKit';
import { Context } from '@kit.AbilityKit';

// 定义时间格式化选项接口
interface TimeFormatOptions {
  hour?: string;
  minute?: string;
  second?: string;
  hour12?: boolean;
}

/**
 * 国际化工具类（单例模式）
 * 提供多语言字符串格式化、时间日期格式化、复数处理等功能
 */
export class I18n {
  private static instance: I18n;
  private context: Context | null = null;
  private currentLocale: string = 'zh_CN';

  private constructor() {
    // 私有构造函数，确保单例
  }

  /**
   * 获取 I18n 单例实例
   */
  static getInstance(): I18n {
    if (!I18n.instance) {
      I18n.instance = new I18n();
    }
    return I18n.instance;
  }

  /**
   * 初始化 I18n，需要提供 Context
   */
  init(context: Context): void {
    this.context = context;
    this.currentLocale = I18nSys.System.getSystemLanguage();
  }

  /**
   * 设置当前语言
   * @param locale 语言代码，如 'zh_CN', 'zh_Hant', 'en_US', 'ru_RU'
   */
  setLocale(locale: string): void {
    try {
      this.currentLocale = locale;
      I18nSys.System.setAppPreferredLanguage(locale);
    } catch (error) {
      console.error(`Failed to set locale to ${locale}:`, error);
    }
  }

  /**
   * 获取当前语言代码
   */
  getLocale(): string {
    return this.currentLocale;
  }

  /**
   * ⭐ 获取 Context（供 ResourceHelper 使用）
   */
  getContext(): Context | null {
    return this.context;
  }

  /**
   * 获取简化的语言代码（不带地区）
   * @return 如 'zh', 'en', 'ru'
   */
  getSimplifiedLanguage(): string {
    const simplified = I18nSys.System.getSimplifiedLanguage();
    return simplified || this.currentLocale.split('_')[0];
  }

  /**
   * 格式化复数字符串
   * 注意：此功能在 HarmonyOS 中建议直接使用 $r('app.plural.xxx', count)
   * @param resource 资源对象（通常来自 $r('app.plural.xxx')）
   * @param count 数量
   * @return 格式化后的字符串
   */
  formatPlural(resource: Resource, count: number): string {
    // HarmonyOS 中推荐直接在 UI 使用 $r()，这里保留接口供其他场景使用
    try {
      if (!this.context) {
        console.warn('I18n context not initialized, fallback to count display');
        return count.toString();
      }
      
      // 简化实现：返回格式化后的数量字符串
      // 实际使用中应该通过 UI 层的 $r('app.plural.xxx', count) 处理
      return count.toString();
    } catch (err) {
      console.error('Failed to format plural:', err);
      return count.toString();
    }
  }

  /**
   * 格式化时间
   * @param timestamp 时间戳（毫秒）
   * @param options 格式化选项
   * @return 格式化后的时间字符串
   * 
   * @example
   * // 格式化为时：分
   * formatTime(Date.now(), { hour: '2-digit', minute: '2-digit' })
   * 
   * @example
   * // 格式化为 时：分：秒
   * formatTime(Date.now(), { hour: '2-digit', minute: '2-digit', second: '2-digit' })
   */
  formatTime(timestamp: number, options?: TimeFormatOptions): string {
    try {
      const date = new Date(timestamp);
      const defaultOptions: Intl.DateTimeFormatOptions = {
        hour: 'numeric',
        minute: 'numeric',
        hour12: false
      };
      const mergedOptions: Intl.DateTimeFormatOptions = this.mergeDateTimeOptions(defaultOptions, options);
      return new Intl.DateTimeFormat(this.currentLocale, mergedOptions).format(date);
    } catch (err) {
      console.error('Failed to format time:', err);
      return new Date(timestamp).toLocaleTimeString(this.currentLocale);
    }
  }

  /**
   * 合并日期时间选项
   */
  private mergeDateTimeOptions(
    defaults: Intl.DateTimeFormatOptions,
    custom?: TimeFormatOptions
  ): Intl.DateTimeFormatOptions {
    const result: Intl.DateTimeFormatOptions = {};
    // 手动复制默认值
    if (defaults.hour !== undefined) result.hour = defaults.hour;
    if (defaults.minute !== undefined) result.minute = defaults.minute;
    if (defaults.second !== undefined) result.second = defaults.second;
    if (defaults.hour12 !== undefined) result.hour12 = defaults.hour12;
    
    // 覆盖自定义值
    if (custom) {
      if (custom.hour !== undefined) result.hour = custom.hour as 'numeric' | '2-digit';
      if (custom.minute !== undefined) result.minute = custom.minute as 'numeric' | '2-digit';
      if (custom.second !== undefined) result.second = custom.second as 'numeric' | '2-digit';
      if (custom.hour12 !== undefined) result.hour12 = custom.hour12;
    }
    return result;
  }

  /**
   * 格式化日期
   * @param timestamp 时间戳（毫秒）
   * @param options 格式化选项
   * @return 格式化后的日期字符串
   * 
   * @example
   * // 格式化为星期
   * formatDate(Date.now(), { weekday: 'long' })
   * 
   * @example
   * // 格式化为完整日期
   * formatDate(Date.now(), { year: 'numeric', month: 'short', day: 'numeric' })
   */
  formatDate(timestamp: number, options?: Intl.DateTimeFormatOptions): string {
    try {
      const date = new Date(timestamp);
      const defaultOptions: Intl.DateTimeFormatOptions = {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      };
      const mergedOptions: Intl.DateTimeFormatOptions = this.mergeDateTimeFormatOptions(defaultOptions, options);
      return new Intl.DateTimeFormat(this.currentLocale, mergedOptions).format(date);
    } catch (err) {
      console.error('Failed to format date:', err);
      return new Date(timestamp).toLocaleDateString(this.currentLocale);
    }
  }

  /**
   * 合并日期时间格式选项
   */
  private mergeDateTimeFormatOptions(
    defaults: Intl.DateTimeFormatOptions,
    custom?: Intl.DateTimeFormatOptions
  ): Intl.DateTimeFormatOptions {
    const result: Intl.DateTimeFormatOptions = {};
    // 手动复制默认值
    if (defaults.year !== undefined) result.year = defaults.year;
    if (defaults.month !== undefined) result.month = defaults.month;
    if (defaults.day !== undefined) result.day = defaults.day;
    if (defaults.weekday !== undefined) result.weekday = defaults.weekday;
    if (defaults.hour !== undefined) result.hour = defaults.hour;
    if (defaults.minute !== undefined) result.minute = defaults.minute;
    if (defaults.second !== undefined) result.second = defaults.second;
    if (defaults.hour12 !== undefined) result.hour12 = defaults.hour12;
    
    // 覆盖自定义值
    if (custom) {
      if (custom.year !== undefined) result.year = custom.year as 'numeric' | '2-digit';
      if (custom.month !== undefined) result.month = custom.month as 'numeric' | '2-digit' | 'short' | 'long' | 'narrow';
      if (custom.day !== undefined) result.day = custom.day as 'numeric' | '2-digit';
      if (custom.weekday !== undefined) result.weekday = custom.weekday as 'short' | 'long' | 'narrow';
      if (custom.hour !== undefined) result.hour = custom.hour as 'numeric' | '2-digit';
      if (custom.minute !== undefined) result.minute = custom.minute as 'numeric' | '2-digit';
      if (custom.second !== undefined) result.second = custom.second as 'numeric' | '2-digit';
      if (custom.hour12 !== undefined) result.hour12 = custom.hour12;
    }
    return result;
  }

  /**
   * 格式化相对时间（如"刚刚"、"5分钟前"）
   * @param timestamp 时间戳（毫秒）
   * @return 相对时间字符串
   */
  formatRelativeTime(timestamp: number): string {
    try {
      const now = Date.now();
      const diff = now - timestamp;
      const seconds = Math.floor(diff / 1000);
      const minutes = Math.floor(seconds / 60);
      const hours = Math.floor(minutes / 60);
      const days = Math.floor(hours / 24);

      if (seconds < 60) {
        return this.getString('time.just_now', '刚刚');
      } else if (minutes < 60) {
        return this.getString('time.minutes_ago', '%d 分钟前', [minutes]);
      } else if (hours < 24) {
        return this.getString('time.hours_ago', '%d 小时前', [hours]);
      } else if (days === 1) {
        return this.getString('time.yesterday', '昨天');
      } else if (days < 7) {
        return this.formatDate(timestamp, { weekday: 'long' });
      } else if (days < 30) {
        return this.getString('time.days_ago', '%d 天前', [days]);
      } else {
        return this.formatDate(timestamp);
      }
    } catch (err) {
      console.error('Failed to format relative time:', err);
      return this.formatDate(timestamp);
    }
  }

  /**
   * 获取字符串资源（用于非 UI 代码）
   * @param key 资源键名
   * @param defaultValue 默认值
   * @param args 格式化参数（可选）
   * @return 字符串
   * 
   * @example
   * // 不带参数
   * getString('welcome', 'Welcome')
   * 
   * @example
   * // 带参数
   * getString('greeting', 'Hello, %s', ['Alice'])
   */
  getString(key: string, defaultValue: string, args?: Array<string | number>): string {
    try {
      if (!this.context) {
        console.warn('[I18n] Context not initialized, returning default value');
        return defaultValue;
      }

      // ⭐ 通过 ResourceManager 真正从资源文件读取字符串
      const resource = $r(`app.string.${key}`);
      let result: string = this.context.resourceManager.getStringSync(resource.id);
      
      // 替换占位符 %s 或 %d
      if (args && args.length > 0) {
        for (let i = 0; i < args.length; i++) {
          result = result.replace(/%s|%d/g, args[i].toString());
        }
      }

      return result;
    } catch (err) {
      console.error(`[I18n] Failed to get string ${key}:`, err);
      return defaultValue;
    }
  }

  /**
   * 格式化文件大小
   * @param bytes 字节数
   * @return 格式化后的文件大小字符串
   * 
   * @example
   * // 1024 bytes -> "1 KB"
   * // 1048576 bytes -> "1 MB"
   */
  formatFileSize(bytes: number): string {
    const units: string[] = ['B', 'KB', 'MB', 'GB', 'TB'];
    let size: number = bytes;
    let unitIndex: number = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return `${size.toFixed(2)} ${units[unitIndex]}`;
  }

  /**
   * 格式化数字（千位分隔符）
   * @param number 数字
   * @return 格式化后的字符串
   * 
   * @example
   * // 1000000 -> "1,000,000" (en_US)
   * // 1000000 -> "1 000 000" (ru_RU)
   */
  formatNumber(number: number): string {
    try {
      return new Intl.NumberFormat(this.currentLocale).format(number);
    } catch (err) {
      console.error('Failed to format number:', err);
      return number.toString();
    }
  }

  /**
   * 格式化百分比
   * @param value 0-1 之间的数值
   * @param decimals 小数位数（默认 0）
   * @return 格式化后的百分比字符串
   * 
   * @example
   * // 0.5 -> "50%"
   */
  formatPercentage(value: number, decimals: number = 0): string {
    try {
      return new Intl.NumberFormat(this.currentLocale, {
        style: 'percent',
        minimumFractionDigits: decimals,
        maximumFractionDigits: decimals
      }).format(value);
    } catch (err) {
      console.error('Failed to format percentage:', err);
      return `${Math.round(value * 100)}%`;
    }
  }

  /**
   * 获取当前语言的文本方向
   * @return 'ltr' 或 'rtl'
   */
  getTextDirection(): 'ltr' | 'rtl' {
    // 阿拉伯语、希伯来语等是从右到左的语言
    const rtlLocales = ['ar', 'he', 'fa', 'ur'];
    const simplified: string = this.getSimplifiedLanguage();
    return rtlLocales.includes(simplified) ? 'rtl' : 'ltr';
  }

  /**
   * 是否为 RTL 语言
   */
  isRTL(): boolean {
    return this.getTextDirection() === 'rtl';
  }
}

/**
 * 导出单例实例的便捷方式
 */
export const i18n = I18n.getInstance();
