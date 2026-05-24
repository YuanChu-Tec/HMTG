/**
 * 主题助手 - 提供便捷的主题访问方式
 * 
 * 使用说明:
 * 1. 在组件中使用 ThemeAssistant 提供的静态方法获取主题 tokens
 * 2. 推荐使用 AppTheme 实例来访问主题属性
 * 
 * 示例:
 * ```typescript
 * @Component
 * export struct MyComponent {
 *   private theme = ThemeAssistant.getCurrentTheme();
 *   
 *   build() {
 *     Column() {
 *       Text('Hello')
 *         .fontColor(this.theme.telegramBlue)
 *         .backgroundColor(this.theme.backgroundSecondary);
 *     }
 *   }
 * }
 * ```
 */
import { AppTheme, ThemeType } from '../ui_kit/themes/AppTheme';
import type { ThemeTokens } from '../ui_kit/themes/AppTheme';
import { ThemeTokenFactory } from '../ui_kit/themes/ThemeTokens';

export class ThemeAssistant {
  /**
   * 获取当前主题实例
   * @param type 主题类型，默认为浅色主题
   */
  static getCurrentTheme(type: ThemeType = ThemeType.LIGHT): AppTheme {
    let tokens: ThemeTokens;
    switch (type) {
      case ThemeType.DARK:
        tokens = ThemeTokenFactory.createDarkTokens();
        break;
      case ThemeType.SYSTEM:
        // 系统主题暂时使用浅色主题，实际应用中可根据系统设置动态切换
        tokens = ThemeTokenFactory.createLightTokens();
        break;
      default:
        tokens = ThemeTokenFactory.createLightTokens();
    }
    return new AppTheme(type, tokens);
  }
  
  /**
   * 获取浅色主题
   */
  static getLightTheme(): AppTheme {
    return new AppTheme(ThemeType.LIGHT, ThemeTokenFactory.createLightTokens());
  }
  
  /**
   * 获取深色主题
   */
  static getDarkTheme(): AppTheme {
    return new AppTheme(ThemeType.DARK, ThemeTokenFactory.createDarkTokens());
  }
}
