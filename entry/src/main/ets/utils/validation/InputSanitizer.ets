/**
 * 输入清理器 - 防止XSS和注入攻击
 */

export class InputSanitizer {
  /**
   * 清理HTML输入（防止XSS）
   */
  static sanitizeHTML(input: string): string {
    const htmlEscapes: Record<string, string> = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#39;',
      '/': '&#x2F;'
    };

    return input.replace(/[&<>"'/]/g, (match) => htmlEscapes[match] || match);
  }

  /**
   * 清理SQL输入（防止SQL注入）
   */
  static sanitizeSQL(input: string): string {
    // 移除SQL特殊字符
    return input
      .replace(/['";\\]/g, '')
      .replace(/--/g, '')
      .replace(/\/\*/g, '')
      .replace(/\*\//g, '');
  }

  /**
   * 清理脚本标签
   */
  static sanitizeScript(input: string): string {
    // 移除<script>标签
    return input
      .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
      .replace(/javascript:/gi, '')
      .replace(/on\w+\s*=/gi, '');
  }

  /**
   * 清理CSS输入
   */
  static sanitizeCSS(input: string): string {
    // 移除CSS中的expression和url
    return input
      .replace(/expression\([^)]*\)/gi, '')
      .replace(/url\([^)]*\)/gi, '')
      .replace(/@import[^;]+;/gi, '');
  }

  /**
   * 清理文件名（防止路径遍历）
   */
  static sanitizeFileName(fileName: string): string {
    return fileName
      .replace(/[<>:"/\\|?*\x00-\x1F]/g, '')
      .replace(/^\.+/, '')
      .trim();
  }

  /**
   * 清理路径（防止路径遍历）
   */
  static sanitizePath(path: string): string {
    return path
      .replace(/\.\./g, '')
      .replace(/[<>:"|?*\x00-\x1F]/g, '')
      .replace(/^\/+|\/+$/g, '/');
  }

  /**
   * 清理URL参数
   */
  static sanitizeURLParam(param: string): string {
    return encodeURIComponent(param)
      .replace(/[!'()*]/g, (match) => `%${match.charCodeAt(0).toString(16).toUpperCase()}`);
  }

  /**
   * 清理JSON输入
   */
  static sanitizeJSON(input: string): string {
    try {
      const parsed: ESObject = JSON.parse(input);
      // 递归清理所有字符串值
      return JSON.stringify(InputSanitizer.sanitizeJSONObject(parsed));
    } catch (error) {
      return input;
    }
  }

  /**
   * 递归清理JSON对象
   */
  private static sanitizeJSONObject(obj: ESObject): ESObject {
    if (typeof obj === 'string') {
      return InputSanitizer.sanitizeHTML(obj);
    } else if (Array.isArray(obj)) {
      const arrResult: ESObject[] = [];
      for (let i = 0; i < obj.length; i++) {
        const item: ESObject = obj[i];
        if (item !== undefined && item !== null) {
          arrResult.push(InputSanitizer.sanitizeJSONObject(item));
        }
      }
      return arrResult as ESObject;
    } else if (typeof obj === 'object' && obj !== null) {
      const result: Record<string, ESObject> = {};
      const keys = Object.keys(obj);
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        const value: ESObject = (obj as Record<string, ESObject>)[key];
        if (value !== undefined && value !== null) {
          result[InputSanitizer.sanitizeHTML(key)] = InputSanitizer.sanitizeJSONObject(value);
        }
      }
      return result;
    }
    return obj;
  }

  /**
   * 清理用户输入（通用方法）
   */
  static sanitizeInput(input: string, type: 'html' | 'sql' | 'script' | 'css' | 'filename' | 'path' | 'url' = 'html'): string {
    if (!input) {
      return '';
    }
    switch (type) {
      case 'html':
        return InputSanitizer.sanitizeHTML(input);
      case 'sql':
        return InputSanitizer.sanitizeSQL(input);
      case 'script':
        return InputSanitizer.sanitizeScript(input);
      case 'css':
        return InputSanitizer.sanitizeCSS(input);
      case 'filename':
        return InputSanitizer.sanitizeFileName(input);
      case 'path':
        return InputSanitizer.sanitizePath(input);
      case 'url':
        return InputSanitizer.sanitizeURLParam(input);
      default:
        return input;
    }
  }

  /**
   * 清理多个输入
   */
  static sanitizeInputs(inputs: Record<string, string>, type?: 'html' | 'sql' | 'script' | 'css' | 'filename' | 'path' | 'url'): Record<string, string> {
    const result: Record<string, string> = {};
    const keys = Object.keys(inputs);
    for (let i = 0; i < keys.length; i++) {
      const key = keys[i];
      const value = inputs[key] || '';
      result[key] = InputSanitizer.sanitizeInput(value, type);
    }
    return result;
  }
}
