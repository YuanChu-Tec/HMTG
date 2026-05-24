import { ThemeTokens } from './AppTheme';
import { TypographyToken, ShadowToken, ColorTokens, TypographyTokens, BorderTokens, SpacingTokens, ShadowTokens } from './AppTheme';

/**
 * 主题 Tokens 定义
 * 
 * 使用说明:
 * 1. 通过 ThemeTokenFactory.createLightTokens() 或 createDarkTokens() 获取主题 tokens
 * 2. 使用 AppTheme 类提供的访问器方法访问颜色、间距等
 * 3. 所有 Telegram 特定颜色和样式都已集成到 tokens 系统中
 * 
 * 示例:
 * ```typescript
 * const theme = new AppTheme(ThemeType.LIGHT, ThemeTokenFactory.createLightTokens());
 * Text('Hello')
 *   .fontColor(theme.telegramBlue)
 *   .backgroundColor(theme.backgroundSecondary);
 * ```
 */
export class ThemeTokenFactory {
  /**
   * 创建浅色主题 Token
   */
  static createLightTokens(): ThemeTokens {
    // 创建颜色对象（Telegram 风格）
    const colors: ColorTokens = {
      // 主色调
      primary: '#2481cc',
      primaryLight: '#5aa6e8',
      primaryDark: '#005a9e',
      secondary: '#7b61ff',
        
      // 背景色
      background: '#ffffff',
      surface: '#f5f5f5',
      backgroundSecondary: '#f5f5f5',
      backgroundDark: '#1a1a1a',
        
      // 文字色
      text: '#000000',
      textSecondary: '#707579',
      textTertiary: '#9da3a8',
      textOnDark: '#ffffff',
      darkGray: '#333333',
      mediumGray: '#666666',
      lightGray: '#999999',
        
      // 功能色
      border: '#e0e0e0',
      divider: '#eeeeee',
      error: '#ff5252',
      success: '#00c853',
      warning: '#ff9800',
      info: '#2196f3',
        
      // Telegram 特定颜色
      telegramBlue: '#0088cc',
      telegramDarkBlue: '#2b5278',
      telegramLightBlue: '#e1f0ff',
        
      // 消息气泡
      messageOut: '#eeffde',
      messageIn: '#ffffff'
    };

    // 创建排版对象
    const h1: TypographyToken = {
      fontSize: 32,
      fontWeight: 700,
      lineHeight: 40
    };

    const h2: TypographyToken = {
      fontSize: 28,
      fontWeight: 700,
      lineHeight: 36
    };

    const h3: TypographyToken = {
      fontSize: 24,
      fontWeight: 600,
      lineHeight: 32
    };

    const body1: TypographyToken = {
      fontSize: 16,
      fontWeight: 400,
      lineHeight: 24
    };

    const body2: TypographyToken = {
      fontSize: 14,
      fontWeight: 400,
      lineHeight: 22
    };

    const caption: TypographyToken = {
      fontSize: 12,
      fontWeight: 400,
      lineHeight: 20
    };

    const button: TypographyToken = {
      fontSize: 14,
      fontWeight: 500,
      lineHeight: 20
    };

    const typography: TypographyTokens = {
      h1,
      h2,
      h3,
      body1,
      body2,
      caption,
      button
    };

    // 创建边框对象
    const borders: BorderTokens = {
      radius: 8,
      radiusSmall: 4,
      radiusLarge: 16,
      width: 1,
      widthSmall: 0.5,
      widthLarge: 2
    };

    // 创建间距对象
    const spacing: SpacingTokens = {
      xs: 4,
      sm: 8,
      md: 16,
      lg: 24,
      xl: 32,
      xxl: 48
    };

    // 创建阴影对象
    const small: ShadowToken = {
      radius: 2,
      color: 'rgba(0,0,0,0.1)',
      offsetY: 2
    };

    const medium: ShadowToken = {
      radius: 4,
      color: 'rgba(0,0,0,0.15)',
      offsetY: 4
    };

    const large: ShadowToken = {
      radius: 8,
      color: 'rgba(0,0,0,0.2)',
      offsetY: 8
    };

    const shadows: ShadowTokens = {
      small,
      medium,
      large
    };

    // 构建最终对象
    const tokens: ThemeTokens = {
      colors,
      typography,
      borders,
      spacing,
      shadows
    };

    return tokens;
  }

  /**
   * 创建深色主题 Token
   */
  static createDarkTokens(): ThemeTokens {
    // 创建颜色对象（Telegram 风格）
    const colors: ColorTokens = {
      // 主色调
      primary: '#4da6ff',
      primaryLight: '#80bdff',
      primaryDark: '#0069cc',
      secondary: '#9e8aff',
        
      // 背景色
      background: '#121212',
      surface: '#1e1e1e',
      backgroundSecondary: '#1a1a1a',
      backgroundDark: '#0d0d0d',
        
      // 文字色
      text: '#ffffff',
      textSecondary: '#b0b0b0',
      textTertiary: '#8b8b8b',
      textOnDark: '#ffffff',
      darkGray: '#333333',
      mediumGray: '#666666',
      lightGray: '#999999',
        
      // 功能色
      border: '#333333',
      divider: '#2a2a2a',
      error: '#ff5252',
      success: '#69f0ae',
      warning: '#ffab40',
      info: '#448aff',
        
      // Telegram 特定颜色
      telegramBlue: '#5aa6e8',
      telegramDarkBlue: '#2b5278',
      telegramLightBlue: '#1a3a52',
        
      // 消息气泡
      messageOut: '#eeffde',
      messageIn: '#1e1e1e'
    };

    // 创建排版对象
    const h1: TypographyToken = {
      fontSize: 32,
      fontWeight: 700,
      lineHeight: 40
    };

    const h2: TypographyToken = {
      fontSize: 28,
      fontWeight: 700,
      lineHeight: 36
    };

    const h3: TypographyToken = {
      fontSize: 24,
      fontWeight: 600,
      lineHeight: 32
    };

    const body1: TypographyToken = {
      fontSize: 16,
      fontWeight: 400,
      lineHeight: 24
    };

    const body2: TypographyToken = {
      fontSize: 14,
      fontWeight: 400,
      lineHeight: 22
    };

    const caption: TypographyToken = {
      fontSize: 12,
      fontWeight: 400,
      lineHeight: 20
    };

    const button: TypographyToken = {
      fontSize: 14,
      fontWeight: 500,
      lineHeight: 20
    };

    const typography: TypographyTokens = {
      h1,
      h2,
      h3,
      body1,
      body2,
      caption,
      button
    };

    // 创建边框对象
    const borders: BorderTokens = {
      radius: 8,
      radiusSmall: 4,
      radiusLarge: 16,
      width: 1,
      widthSmall: 0.5,
      widthLarge: 2
    };

    // 创建间距对象
    const spacing: SpacingTokens = {
      xs: 4,
      sm: 8,
      md: 16,
      lg: 24,
      xl: 32,
      xxl: 48
    };

    // 创建阴影对象
    const small: ShadowToken = {
      radius: 2,
      color: 'rgba(255,255,255,0.1)',
      offsetY: 2
    };

    const medium: ShadowToken = {
      radius: 4,
      color: 'rgba(255,255,255,0.15)',
      offsetY: 4
    };

    const large: ShadowToken = {
      radius: 8,
      color: 'rgba(255,255,255,0.2)',
      offsetY: 8
    };

    const shadows: ShadowTokens = {
      small,
      medium,
      large
    };

    // 构建最终对象
    const tokens: ThemeTokens = {
      colors,
      typography,
      borders,
      spacing,
      shadows
    };

    return tokens;
  }
}
