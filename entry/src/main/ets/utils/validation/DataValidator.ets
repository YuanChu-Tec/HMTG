import { BusinessError } from '../error/BusinessError';
// import { URL } from '@kit.ArkTS'; // URL not available in API 20


/**
 * 验证结果
 */
export interface ValidationResult {
  isValid: boolean;
  errors: string[];
}

/**
 * 数据验证器
 */

export class DataValidator {
  /**
   * 验证邮箱
   */
  static validateEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  /**
   * 验证手机号
   */
  static validatePhone(phone: string, countryCode: string = 'CN'): boolean {
    const cleaned = phone.replace(/\D/g, '');
    
    if (countryCode === 'CN') {
      return /^1\d{10}$/.test(cleaned);
    } else if (countryCode === 'US') {
      return /^\d{10}$/.test(cleaned);
    }
    
    return cleaned.length >= 7;
  }

  /**
   * 验证密码强度
   */
  static validatePassword(password: string): ValidationResult {
    const errors: string[] = [];

    if (password.length < 8) {
      errors.push('密码长度至少8位');
    }

    if (!/[a-z]/.test(password)) {
      errors.push('密码需要包含小写字母');
    }

    if (!/[A-Z]/.test(password)) {
      errors.push('密码需要包含大写字母');
    }

    if (!/\d/.test(password)) {
      errors.push('密码需要包含数字');
    }

    if (!/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
      errors.push('密码需要包含特殊字符');
    }

    return {
      isValid: errors.length === 0,
      errors
    };
  }

  /**
   * 验证URL
   */
  static validateURL(url: string): boolean {
    try {
      // 简化的URL验证
      if (!url || url.length < 7) {
        return false;
      }
      return url.startsWith('http://') || url.startsWith('https://');
    } catch {
      return false;
    }
  }

  /**
   * 验证用户名
   */
  static validateUsername(username: string): ValidationResult {
    const errors: string[] = [];

    if (username.length < 3) {
      errors.push('用户名长度至少3位');
    }

    if (username.length > 30) {
      errors.push('用户名长度不能超过30位');
    }

    if (!/^[a-zA-Z0-9_-]+$/.test(username)) {
      errors.push('用户名只能包含字母、数字、下划线和连字符');
    }

    return {
      isValid: errors.length === 0,
      errors
    };
  }

  /**
   * 验证用户输入
   */
  static validateUserInput(data: Record<string, Object>): ValidationResult {
    const errors: string[] = [];

    if (data['email'] !== undefined) {
      const email = data['email'] as string;
      if (!DataValidator.validateEmail(email)) {
        errors.push('邮箱格式不正确');
      }
    }

    if (data['phone'] !== undefined) {
      const phone = data['phone'] as string;
      if (!DataValidator.validatePhone(phone)) {
        errors.push('手机号格式不正确');
      }
    }

    if (data['username'] !== undefined) {
      const username = data['username'] as string;
      const usernameResult = DataValidator.validateUsername(username);
      for (let i = 0; i < usernameResult.errors.length; i++) {
        errors.push(usernameResult.errors[i]);
      }
    }

    if (data['password'] !== undefined) {
      const password = data['password'] as string;
      const passwordResult = DataValidator.validatePassword(password);
      for (let i = 0; i < passwordResult.errors.length; i++) {
        errors.push(passwordResult.errors[i]);
      }
    }

    return {
      isValid: errors.length === 0,
      errors
    };
  }

  /**
   * 验证数字范围
   */
  static validateRange(value: number, min: number, max: number): boolean {
    return value >= min && value <= max;
  }

  /**
   * 验证文件类型
   */
  static validateFileType(fileName: string, allowedTypes: string[]): boolean {
    const ext = fileName.split('.').pop()?.toLowerCase() || '';
    return allowedTypes.includes(ext);
  }

  /**
   * 验证文件大小
   */
  static validateFileSize(size: number, maxSize: number): boolean {
    return size <= maxSize;
  }

  /**
   * 验证必填字段
   */
  static validateRequired(data: Map<string, Object>, requiredFields: string[]): ValidationResult {
    const errors: string[] = [];

    requiredFields.forEach(field => {
      const value = data.get(field);
      if (!data.has(field) || value === null || value === undefined || value === '') {
        errors.push(`${field} 为必填字段`);
      }
    });

    return {
      isValid: errors.length === 0,
      errors
    };
  }

  /**
   * 验证JSON格式
   */
  static validateJSON(jsonString: string): boolean {
    try {
      JSON.parse(jsonString);
      return true;
    } catch {
      return false;
    }
  }

  /**
   * 验证IP地址
   */
  static validateIP(ip: string): boolean {
    const ipv4Regex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
    const ipv6Regex = /^(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$/;
    
    return ipv4Regex.test(ip) || ipv6Regex.test(ip);
  }

  /**
   * 验证端口号
   */
  static validatePort(port: number): boolean {
    return port >= 1 && port <= 65535;
  }

  /**
   * 验证日期格式
   */
  static validateDate(dateString: string): boolean {
    return !isNaN(Date.parse(dateString));
  }

  /**
   * 验证年龄
   */
  static validateAge(age: number, minAge: number = 0, maxAge: number = 150): boolean {
    return DataValidator.validateRange(age, minAge, maxAge);
  }

  /**
   * 验证验证码长度
   * ⭐ 注意：TDLib 验证码长度为 4-8 位，由服务端指定
   * @param code 验证码字符串
   * @param expectedLength 期望的验证码位数（4-8），如果不传则检查是否为 4-8 位之间的任意长度
   */
  static validateCodeByLength(code: string, expectedLength?: number): boolean {
    const cleaned = code.replace(/\D/g, '');
    
    if (expectedLength !== undefined && expectedLength >= 4 && expectedLength <= 8) {
      // ⭐ 如果 TDLib 指定了确切位数，必须精确匹配
      return cleaned.length === expectedLength;
    } else {
      // 未指定位数时，接受 4-8 位之间的任意长度
      return cleaned.length >= 4 && cleaned.length <= 8;
    }
  }
}
