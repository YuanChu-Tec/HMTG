/**
 * 数字格式化工具类
 */
export class NumberFormatter {
  /**
   * 格式化整数（添加千位分隔符）
   */
  static formatInteger(num: number, locale: string = 'en-US'): string {
    return num.toLocaleString(locale);
  }

  /**
   * 格式化小数
   */
  static formatDecimal(num: number, decimals: number = 2): string {
    return num.toFixed(decimals);
  }

  /**
   * 格式化货币
   */
  static formatCurrency(
    num: number,
    currency: string = 'USD',
    locale: string = 'en-US'
  ): string {
    return num.toLocaleString(locale, {
      style: 'currency',
      currency: currency
    });
  }

  /**
   * 格式化百分比
   */
  static formatPercent(num: number, decimals: number = 2): string {
    return `${(num * 100).toFixed(decimals)}%`;
  }

  /**
   * 简化大数字（如：1.2K, 1.5M）
   */
  static formatCompact(num: number): string {
    if (num >= 1000000000) {
      return `${(num / 1000000000).toFixed(1)}B`;
    } else if (num >= 1000000) {
      return `${(num / 1000000).toFixed(1)}M`;
    } else if (num >= 1000) {
      return `${(num / 1000).toFixed(1)}K`;
    } else {
      return num.toString();
    }
  }

  /**
   * 格式化电话号码
   */
  static formatPhone(phone: string, countryCode: string = 'US'): string {
    // 移除非数字字符
    const cleaned = phone.replace(/\D/g, '');
    
    if (countryCode === 'CN' && cleaned.length === 11) {
      return `${cleaned.slice(0, 3)} ${cleaned.slice(3, 7)} ${cleaned.slice(7)}`;
    } else if (countryCode === 'US' && cleaned.length === 10) {
      return `(${cleaned.slice(0, 3)}) ${cleaned.slice(3, 6)}-${cleaned.slice(6)}`;
    } else {
      return phone;
    }
  }

  /**
   * 格式化数字范围（如：1K-2K）
   */
  static formatRange(min: number, max: number): string {
    return `${NumberFormatter.formatCompact(min)}-${NumberFormatter.formatCompact(max)}`;
  }

  /**
   * 解析数字字符串
   */
  static parse(str: string): number {
    const cleaned = str.replace(/,/g, '');
    return parseFloat(cleaned);
  }
}
