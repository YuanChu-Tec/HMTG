/**
 * 国家信息接口
 */
export interface CountryInfo {
  name: string;
  code: string;
  flag: string;
}

/**
 * 电话号码格式化工具类
 */
export class PhoneFormatter {
  /**
   * 格式化国际电话号码
   */
  static formatInternational(phone: string, countryCode: string = 'CN'): string {
    const cleaned = PhoneFormatter.cleanPhone(phone);

    if (countryCode === 'CN' && cleaned.length === 11) {
      return `+86 ${cleaned.slice(0, 3)} ${cleaned.slice(3, 7)} ${cleaned.slice(7)}`;
    } else if (countryCode === 'US' && cleaned.length === 10) {
      return `+1 (${cleaned.slice(0, 3)}) ${cleaned.slice(3, 6)}-${cleaned.slice(6)}`;
    } else {
      return phone;
    }
  }

  /**
   * 格式化国内电话号码
   */
  static formatNational(phone: string, countryCode: string = 'CN'): string {
    const cleaned = PhoneFormatter.cleanPhone(phone);

    if (countryCode === 'CN' && cleaned.length === 11) {
      return `${cleaned.slice(0, 3)} ${cleaned.slice(3, 7)} ${cleaned.slice(7)}`;
    } else if (countryCode === 'US' && cleaned.length === 10) {
      return `(${cleaned.slice(0, 3)}) ${cleaned.slice(3, 6)}-${cleaned.slice(6)}`;
    } else {
      return phone;
    }
  }

  /**
   * 清理电话号码（移除所有非数字字符）
   */
  static cleanPhone(phone: string): string {
    return phone.replace(/\D/g, '');
  }

  /**
   * 验证电话号码格式
   */
  static validate(phone: string, countryCode: string = 'CN'): boolean {
    const cleaned = PhoneFormatter.cleanPhone(phone);

    if (countryCode === 'CN') {
      // 中国手机号：1开头，共11位
      return /^1\d{10}$/.test(cleaned);
    } else if (countryCode === 'US') {
      // 美国手机号：10位
      return /^\d{10}$/.test(cleaned);
    } else {
      return cleaned.length >= 7;
    }
  }

  /**
   * 提取国家代码
   */
  static extractCountryCode(phone: string): CountryCodeResult {
    const cleaned = PhoneFormatter.cleanPhone(phone);

    if (cleaned.startsWith('86') && cleaned.length >= 13) {
      const result: CountryCodeResult = { code: '86', number: cleaned.slice(2) };
      return result;
    } else if (cleaned.startsWith('1') && cleaned.length >= 11) {
      const result: CountryCodeResult = { code: '1', number: cleaned.slice(1) };
      return result;
    } else {
      const result: CountryCodeResult = { code: '', number: cleaned };
      return result;
    }
  }

  /**
   * 隐藏部分号码（用于隐私保护）
   */
  static maskPhone(phone: string, countryCode: string = 'CN'): string {
    const cleaned = PhoneFormatter.cleanPhone(phone);

    if (countryCode === 'CN' && cleaned.length === 11) {
      return `${cleaned.slice(0, 3)}****${cleaned.slice(7)}`;
    } else if (countryCode === 'US' && cleaned.length === 10) {
      return `${cleaned.slice(0, 3)}***${cleaned.slice(6)}`;
    } else {
      return phone;
    }
  }

  /**
   * 获取国家信息
   */
  static getCountryInfo(countryCode: string): CountryInfo | null {
    const countryMap: Map<string, CountryInfo> = new Map();
    countryMap.set('CN', { name: 'China', code: '86', flag: '🇨🇳' });
    countryMap.set('US', { name: 'United States', code: '1', flag: '🇺🇸' });
    countryMap.set('UK', { name: 'United Kingdom', code: '44', flag: '🇬🇧' });
    countryMap.set('JP', { name: 'Japan', code: '81', flag: '🇯🇵' });
    countryMap.set('KR', { name: 'South Korea', code: '82', flag: '🇰🇷' });

    return countryMap.get(countryCode) || null;
  }
}

/**
 * 国家代码结果接口
 */
interface CountryCodeResult {
  code: string;
  number: string;
}
