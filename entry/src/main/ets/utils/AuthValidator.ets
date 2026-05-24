/**
 * 认证输入验证工具类
 * 提供认证相关数据的验证功能
 */

/**
 * 验证结果接口
 */
export interface ValidationResult {
  isValid: boolean;
  errorMessage?: string;
  errorType?: ValidationErrorType;
}

/**
 * 验证错误类型
 */
export enum ValidationErrorType {
  EMPTY = 'empty',
  FORMAT = 'format',
  LENGTH = 'length',
  INVALID = 'invalid',
  TOO_SHORT = 'too_short',
  TOO_LONG = 'too_long',
  CONTAINS_SPECIAL = 'contains_special'
}

/**
 * 注册数据接口
 */
interface RegistrationData {
  firstName: string;
  lastName: string;
  username: string;
}

/**
 * 验证项接口
 */
interface ValidationItem {
  value: Object;
  validator: (value: Object) => ValidationResult;
}

/**
 * 批量验证结果接口
 */
interface ValidateAllResult {
  isValid: boolean;
  results: ValidationResult[];
  firstError?: ValidationResult;
}

/**
 * 认证验证器
 */
export class AuthValidator {
  // 手机号正则表达式（支持中国大陆）
  private static readonly PHONE_REGEX = /^1[3-9]\d{9}$/;

  // 国际手机号正则（较宽松）
  private static readonly INTERNATIONAL_PHONE_REGEX = /^\+[1-9]\d{1,14}$/;

  // 验证码正则（5-6位数字）
  private static readonly CODE_REGEX = /^\d{5,6}$/;

  // 用户名正则（5-32位字母、数字、下划线）
  private static readonly USERNAME_REGEX = /^[a-zA-Z0-9_]{5,32}$/;

  // 姓名正则（支持中文、字母、空格）
  private static readonly NAME_REGEX = /^[\u4e00-\u9fa5a-zA-Z\s]{1,50}$/;

  /**
   * 验证手机号
   * @param phone 手机号
   * @param countryCode 国家代码
   * @returns 验证结果
   */
  public static validatePhone(phone: string, countryCode: string = '+86'): ValidationResult {
    // 检查是否为空
    if (!phone || phone.trim().length === 0) {
      return {
        isValid: false,
        errorMessage: '请输入手机号',
        errorType: ValidationErrorType.EMPTY
      };
    }

    // 去除空格
    const cleanPhone = phone.replace(/\s/g, '');

    // 根据国家代码选择验证规则
    const regex = countryCode === '+86' ? AuthValidator.PHONE_REGEX : AuthValidator.INTERNATIONAL_PHONE_REGEX;

    if (!regex.test(cleanPhone)) {
      return {
        isValid: false,
        errorMessage: '手机号格式不正确',
        errorType: ValidationErrorType.FORMAT
      };
    }

    return { isValid: true };
  }

  /**
   * 验证验证码
   * @param code 验证码
   * @returns 验证结果
   */
  public static validateCode(code: string): ValidationResult {
    if (!code || code.trim().length === 0) {
      return {
        isValid: false,
        errorMessage: '请输入验证码',
        errorType: ValidationErrorType.EMPTY
      };
    }

    const cleanCode = code.trim();

    if (!AuthValidator.CODE_REGEX.test(cleanCode)) {
      return {
        isValid: false,
        errorMessage: '验证码格式不正确',
        errorType: ValidationErrorType.FORMAT
      };
    }

    return { isValid: true };
  }

  /**
   * 验证密码
   * @param password 密码
   * @returns 验证结果
   */
  public static validatePassword(password: string): ValidationResult {
    if (!password || password.trim().length === 0) {
      return {
        isValid: false,
        errorMessage: '请输入密码',
        errorType: ValidationErrorType.EMPTY
      };
    }

    if (password.length < 8) {
      return {
        isValid: false,
        errorMessage: '密码长度不能少于8位',
        errorType: ValidationErrorType.TOO_SHORT
      };
    }

    if (password.length > 64) {
      return {
        isValid: false,
        errorMessage: '密码长度不能超过64位',
        errorType: ValidationErrorType.TOO_LONG
      };
    }

    return { isValid: true };
  }

  /**
   * 验证用户名
   * @param username 用户名
   * @returns 验证结果
   */
  public static validateUsername(username: string): ValidationResult {
    // 用户名是可选的
    if (!username || username.trim().length === 0) {
      return { isValid: true };
    }

    const cleanUsername = username.trim();

    if (cleanUsername.length < 5) {
      return {
        isValid: false,
        errorMessage: '用户名至少5个字符',
        errorType: ValidationErrorType.TOO_SHORT
      };
    }

    if (cleanUsername.length > 32) {
      return {
        isValid: false,
        errorMessage: '用户名最多32个字符',
        errorType: ValidationErrorType.TOO_LONG
      };
    }

    if (!AuthValidator.USERNAME_REGEX.test(cleanUsername)) {
      return {
        isValid: false,
        errorMessage: '用户名只能包含字母、数字和下划线',
        errorType: ValidationErrorType.FORMAT
      };
    }

    return { isValid: true };
  }

  /**
   * 验证名
   * @param firstName 名
   * @returns 验证结果
   */
  public static validateFirstName(firstName: string): ValidationResult {
    if (!firstName || firstName.trim().length === 0) {
      return {
        isValid: false,
        errorMessage: '请输入您的名字',
        errorType: ValidationErrorType.EMPTY
      };
    }

    const cleanName = firstName.trim();

    if (cleanName.length > 50) {
      return {
        isValid: false,
        errorMessage: '名字不能超过50个字符',
        errorType: ValidationErrorType.TOO_LONG
      };
    }

    if (!AuthValidator.NAME_REGEX.test(cleanName)) {
      return {
        isValid: false,
        errorMessage: '名字格式不正确',
        errorType: ValidationErrorType.FORMAT
      };
    }

    return { isValid: true };
  }

  /**
   * 验证姓
   * @param lastName 姓
   * @returns 验证结果
   */
  public static validateLastName(lastName: string): ValidationResult {
    // 姓是可选的
    if (!lastName || lastName.trim().length === 0) {
      return { isValid: true };
    }

    const cleanName = lastName.trim();

    if (cleanName.length > 50) {
      return {
        isValid: false,
        errorMessage: '姓氏不能超过50个字符',
        errorType: ValidationErrorType.TOO_LONG
      };
    }

    if (!AuthValidator.NAME_REGEX.test(cleanName)) {
      return {
        isValid: false,
        errorMessage: '姓氏格式不正确',
        errorType: ValidationErrorType.FORMAT
      };
    }

    return { isValid: true };
  }

  /**
   * 验证协议同意
   * @param agreed 是否同意
   * @returns 验证结果
   */
  public static validateAgreement(agreed: boolean): ValidationResult {
    if (!agreed) {
      return {
        isValid: false,
        errorMessage: '请同意用户协议和隐私政策',
        errorType: ValidationErrorType.INVALID
      };
    }

    return { isValid: true };
  }

  /**
   * 批量验证
   * @param validations 验证对象数组 { value, validator }
   * @returns 是否全部验证通过
   */
  public static validateAll(
    validations: ValidationItem[]
  ): ValidateAllResult {
    const results: ValidationResult[] = [];

    for (const validation of validations) {
      const result = validation.validator(validation.value);
      results.push(result);

      if (!result.isValid) {
        const errorResult: ValidateAllResult = {
          isValid: false,
          results: results,
          firstError: result
        };
        return errorResult;
      }
    }

    const successResult: ValidateAllResult = {
      isValid: true,
      results: results
    };
    return successResult;
  }

  /**
   * 获取错误提示信息
   * @param errorType 错误类型
   * @param fieldName 字段名
   * @returns 错误提示
   */
  public static getErrorMessage(errorType: ValidationErrorType, fieldName: string): string {
    const messages: Record<ValidationErrorType, string> = {
      [ValidationErrorType.EMPTY]: `请输入${fieldName}`,
      [ValidationErrorType.FORMAT]: `${fieldName}格式不正确`,
      [ValidationErrorType.LENGTH]: `${fieldName}长度不正确`,
      [ValidationErrorType.INVALID]: `${fieldName}无效`,
      [ValidationErrorType.TOO_SHORT]: `${fieldName}太短`,
      [ValidationErrorType.TOO_LONG]: `${fieldName}太长`,
      [ValidationErrorType.CONTAINS_SPECIAL]: `${fieldName}包含特殊字符`
    };

    return messages[errorType] || `${fieldName}验证失败`;
  }

  /**
   * 验证注册信息
   * @param data 注册数据
   * @returns 验证结果
   */
  public static validateRegistration(data: RegistrationData): ValidationResult {
    const firstNameResult = AuthValidator.validateFirstName(data.firstName);
    if (!firstNameResult.isValid) {
      return firstNameResult;
    }

    const lastNameResult = AuthValidator.validateLastName(data.lastName);
    if (!lastNameResult.isValid) {
      return lastNameResult;
    }

    const usernameResult = AuthValidator.validateUsername(data.username);
    if (!usernameResult.isValid) {
      return usernameResult;
    }

    return { isValid: true };
  }
}
