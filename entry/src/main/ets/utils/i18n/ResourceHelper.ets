/**
 * 国际化资源辅助工具
 * 
 * 用途：处理动态 key 的国际化场景
 * 注意：优先使用 $r('app.string.xxx')，仅在 key 为变量时使用此工具
 * 
 * 示例：
 * ```typescript
 * // ✅ 推荐：静态 key 直接使用 $r()
 * Text($r('app.string.welcome'))
 * 
 * // ⚠️ 动态 key 场景：使用 getString()
 * const key = getDynamicKey();
 * Text(getString(key))
 * ```
 */

import { common } from '@kit.AbilityKit';
import { i18n } from './I18n'; // ⭐ 导入 I18n 单例
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'ResourceHelper';
const DOMAIN = 0x0001;

/**
 * 根据动态 key 获取国际化字符串
 * 
 * @param key - 资源键名(不含 app.string. 前缀)
 * @returns 国际化字符串
 * 
 * @example
 * ```typescript
 * // 动态 key 场景
 * const hintKey = getCodeHintKey(codeType);
 * Text(getString(hintKey))
 * 
 * // 带参数的格式化(需要配合 formatString)
 * const message = formatString('welcome_user', userName);
 * ```
 */
export function getString(key: string): string {
  try {
    // ⭐ 方案1:优先使用 I18n 单例的 context(已在 EntryAbility 中初始化)
    const i18nContext = i18n.getContext();
    if (i18nContext && i18nContext.resourceManager) {
      try {
        // 使用 ResourceManager 的 getStringByNameSync 方法直接通过名称获取(同步版本)
        const result = i18nContext.resourceManager.getStringByNameSync(key);
        
        if (result && result.trim().length > 0) {
          hilog.info(DOMAIN, TAG, '[getString] Using I18n context, key=%{public}s, result="%{public}s"', key, result);
          return result;
        }
        
        hilog.warn(DOMAIN, TAG, '[getString] I18n context returned empty string for key: %{public}s', key);
      } catch (error) {
        hilog.warn(DOMAIN, TAG, '[getString] I18n context failed: %{public}s', JSON.stringify(error));
      }
    }
    
    // ⭐ 方案2:尝试使用 getContext() 作为降级
    try {
      const context = getContext() as common.UIAbilityContext;
      if (context && context.resourceManager) {
        // 使用 ResourceManager 的 getStringByNameSync 方法(同步版本)
        const result = context.resourceManager.getStringByNameSync(key);
        
        if (result && result.trim().length > 0) {
          hilog.info(DOMAIN, TAG, '[getString] Using getContext(), key=%{public}s, result="%{public}s"', key, result);
          return result;
        }
        
        hilog.warn(DOMAIN, TAG, '[getString] getContext() returned empty string for key: %{public}s', key);
      }
    } catch (error) {
      hilog.warn(DOMAIN, TAG, '[getString] getContext() failed: %{public}s', JSON.stringify(error));
    }
    
    // ⭐ 所有方法都失败,记录错误并返回key
    hilog.error(DOMAIN, TAG, '[getString] All methods failed for key: %{public}s', key);
    return key;
  } catch (error) {
    hilog.error(DOMAIN, TAG, '[getString] Unexpected error for key: %{public}s, error: %{public}s', key, JSON.stringify(error));
    return key;
  }
}

/**
 * 格式化国际化字符串（支持参数替换）
 * 
 * @param key - 资源键名
 * @param args - 替换参数
 * @returns 格式化后的字符串
 * 
 * @example
 * ```typescript
 * // 资源文件： "AuthCodePlaceholderN": "请输入{0}位验证码"
 * const msg = formatString('AuthCodePlaceholderN', 6);
 * // 结果： "请输入6位验证码"
 * ```
 */
export function formatString(key: string, ...args: Array<string | number>): string {
  let template = getString(key);
  
  // ⭐ 使用 {0}, {1}, ... 占位符格式（与 HMTG1.0.2 保持一致）
  args.forEach((arg, index) => {
    const placeholder = `{${index}}`;
    template = template.replace(placeholder, String(arg));
  });
  
  return template;
}
