/**
 * Schema类型定义
 */
export type SchemaType = 'string' | 'number' | 'boolean' | 'array' | 'object' | 'any';

/**
 * Schema规则
 */
export interface SchemaRule {
  type?: SchemaType;
  required?: boolean;
  min?: number;
  max?: number;
  pattern?: RegExp;
  enum?: Object[];
  custom?: (value: Object) => boolean | string;
  properties?: Record<string, SchemaRule>;
  items?: SchemaRule;
}

/**
 * Schema定义
 */
export type Schema = Record<string, SchemaRule>;

/**
 * Schema验证器
 */
export class SchemaValidator {
  /**
   * 验证数据是否符合Schema
   */
  static validate(data: Object, schema: Schema): ValidationResult {
    const errors: string[] = [];

    const keys = Object.keys(schema);
    for (let i = 0; i < keys.length; i++) {
      const key = keys[i];
      const rule = schema[key];
      // 检查必填
      if (rule.required && (data as Record<string, Object>)[key] === undefined) {
        errors.push(`${key} 为必填字段`);
        continue;
      }

      const value = (data as Record<string, Object>)[key];

      // 如果字段不存在且不是必填，跳过验证
      if ((data as Record<string, Object>)[key] === undefined) {
        continue;
      }

      // 验证类型
      if (rule.type && rule.type !== 'any') {
        if (!SchemaValidator.validateType(value, rule.type)) {
          errors.push(`${key} 类型应为 ${rule.type}`);
          continue;
        }
      }

      // 验证最小值/最小长度
      if (rule.min !== undefined) {
        if (typeof value === 'number') {
          if (value < rule.min) {
            errors.push(`${key} 不能小于 ${rule.min}`);
          }
        } else if (typeof value === 'string') {
          if (value.length < rule.min) {
            errors.push(`${key} 长度不能小于 ${rule.min}`);
          }
        } else if (Array.isArray(value)) {
          if (value.length < rule.min) {
            errors.push(`${key} 数量不能少于 ${rule.min}`);
          }
        }
      }

      // 验证最大值/最大长度
      if (rule.max !== undefined) {
        if (typeof value === 'number') {
          if (value > rule.max) {
            errors.push(`${key} 不能大于 ${rule.max}`);
          }
        } else if (typeof value === 'string') {
          if (value.length > rule.max) {
            errors.push(`${key} 长度不能大于 ${rule.max}`);
          }
        } else if (Array.isArray(value)) {
          if (value.length > rule.max) {
            errors.push(`${key} 数量不能多于 ${rule.max}`);
          }
        }
      }

      // 验证正则表达式
      if (rule.pattern && typeof value === 'string') {
        if (!rule.pattern.test(value)) {
          errors.push(`${key} 格式不正确`);
        }
      }

      // 验证枚举值
      if (rule.enum) {
        let found = false;
        for (let j = 0; j < rule.enum.length; j++) {
          const enumValue: ESObject = rule.enum[j];
          if (enumValue === value) {
            found = true;
            break;
          }
        }
        if (!found) {
          let enumValues = '';
          for (let j = 0; j < rule.enum.length; j++) {
            enumValues += String(rule.enum[j]);
            if (j < rule.enum.length - 1) {
              enumValues += ', ';
            }
          }
          errors.push(`${key} 必须是以下值之一: ${enumValues}`);
        }
      }

      // 自定义验证
      if (rule.custom) {
        const result = rule.custom(value);
        if (result !== true) {
          errors.push(typeof result === 'string' ? result : `${key} 验证失败`);
        }
      }

      // 验证对象属性
      if (rule.properties && typeof value === 'object' && !Array.isArray(value)) {
        const nestedResult = SchemaValidator.validate(value as Object, rule.properties);
        for (let k = 0; k < nestedResult.errors.length; k++) {
          errors.push(`${key}.${nestedResult.errors[k]}`);
        }
      }

      // 验证数组元素
      if (rule.items && Array.isArray(value)) {
        for (let index = 0; index < value.length; index++) {
          const item: ESObject = value[index];
          const itemSchema: Schema = new Object() as Schema;
          itemSchema.value = rule.items;
          const itemResult = SchemaValidator.validate(item as Object, itemSchema);
          for (let k = 0; k < itemResult.errors.length; k++) {
            errors.push(`${key}[${index}].${itemResult.errors[k]}`);
          }
        }
      }
    }

    return {
      isValid: errors.length === 0,
      errors
    };
  }

  /**
   * 验证数据类型
   */
  private static validateType(value: Object, type: SchemaType): boolean {
    switch (type) {
      case 'string':
        return typeof value === 'string';
      case 'number':
        return typeof value === 'number';
      case 'boolean':
        return typeof value === 'boolean';
      case 'array':
        return Array.isArray(value);
      case 'object':
        return typeof value === 'object' && !Array.isArray(value) && value !== null;
      case 'any':
        return true;
      default:
        return false;
    }
  }

  /**
   * 快速验证器工厂
   */
  static createValidator(schema: Schema): (data: Object) => ValidationResult {
    return (data: Object) => SchemaValidator.validate(data, schema);
  }
}

/**
 * 验证结果
 */
export interface ValidationResult {
  isValid: boolean;
  errors: string[];
}
