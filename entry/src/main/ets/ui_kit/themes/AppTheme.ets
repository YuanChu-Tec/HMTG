/**
 * 主题类型
 */
export enum ThemeType {
  LIGHT = 'light',
  DARK = 'dark',
  SYSTEM = 'system'
}

/**
 * 应用主题基类
 */
@Observed
export class AppTheme {
  public readonly type: ThemeType;
  public readonly tokens: ThemeTokens;

  constructor(type: ThemeType, tokens: ThemeTokens) {
    this.type = type;
    this.tokens = tokens;
  }

  /**
   * 获取主色调
   */
  get primaryColor(): string {
    return this.tokens.colors.primary;
  }

  /**
   * 获取背景色
   */
  get backgroundColor(): string {
    return this.tokens.colors.background;
  }

  /**
   * 获取文字颜色
   */
  get textColor(): string {
    return this.tokens.colors.text;
  }

  /**
   * 获取次要文字颜色
   */
  get secondaryTextColor(): string {
    return this.tokens.colors.textSecondary;
  }

  /**
   * 获取边框颜色
   */
  get borderColor(): string {
    return this.tokens.colors.border;
  }

  /**
   * 获取错误色
   */
  get errorColor(): string {
    return this.tokens.colors.error;
  }

  /**
   * 获取成功色
   */
  get successColor(): string {
    return this.tokens.colors.success;
  }

  /**
   * 获取警告色
   */
  get warningColor(): string {
    return this.tokens.colors.warning;
  }

  /**
   * 获取圆角
   */
  get borderRadius(): number {
    return this.tokens.borders.radius;
  }

  /**
   * 获取小圆角
   */
  get borderRadiusSmall(): number {
    return this.tokens.borders.radiusSmall;
  }

  /**
   * 获取大圆角
   */
  get borderRadiusLarge(): number {
    return this.tokens.borders.radiusLarge;
  }
  
  // ==================== Telegram 特定颜色访问器 ====================
  
  /**
   * 获取 Telegram 蓝色
   */
  get telegramBlue(): string {
    return this.tokens.colors.telegramBlue;
  }
  
  /**
   * 获取 Telegram 深蓝色
   */
  get telegramDarkBlue(): string {
    return this.tokens.colors.telegramDarkBlue;
  }
  
  /**
   * 获取 Telegram 浅蓝色
   */
  get telegramLightBlue(): string {
    return this.tokens.colors.telegramLightBlue;
  }
  
  /**
   * 获取消息气泡颜色（发出）
   */
  get messageOutColor(): string {
    return this.tokens.colors.messageOut;
  }
  
  /**
   * 获取消息气泡颜色（接收）
   */
  get messageInColor(): string {
    return this.tokens.colors.messageIn;
  }
  
  /**
   * 获取次要背景色
   */
  get backgroundSecondary(): string {
    return this.tokens.colors.backgroundSecondary;
  }
  
  /**
   * 获取深色背景
   */
  get backgroundDark(): string {
    return this.tokens.colors.backgroundDark;
  }
  
  /**
   * 获取深色背景上的文字颜色
   */
  get textOnDark(): string {
    return this.tokens.colors.textOnDark;
  }
  
  /**
   * 获取深灰色
   */
  get darkGray(): string {
    return this.tokens.colors.darkGray;
  }
  
  /**
   * 获取中灰色
   */
  get mediumGray(): string {
    return this.tokens.colors.mediumGray;
  }
  
  /**
   * 获取浅灰色
   */
  get lightGray(): string {
    return this.tokens.colors.lightGray;
  }
  
  /**
   * 获取第三级文字颜色
   */
  get textTertiary(): string {
    return this.tokens.colors.textTertiary;
  }
}

/**
 * 主题Token
 */
export interface ThemeTokens {
  colors: ColorTokens;
  typography: TypographyTokens;
  borders: BorderTokens;
  spacing: SpacingTokens;
  shadows: ShadowTokens;
}

/**
 * 颜色 Token
 */
export interface ColorTokens {
  // 主色调
  primary: string;
  primaryLight: string;
  primaryDark: string;
  secondary: string;
  
  // 背景色
  background: string;
  surface: string;
  backgroundSecondary: string;
  backgroundDark: string;
  
  // 文字色
  text: string;
  textSecondary: string;
  textTertiary: string;
  textOnDark: string;
  darkGray: string;
  mediumGray: string;
  lightGray: string;
  
  // 功能色
  border: string;
  divider: string;
  error: string;
  success: string;
  warning: string;
  info: string;
  
  // Telegram 特定颜色
  telegramBlue: string;
  telegramDarkBlue: string;
  telegramLightBlue: string;
  
  // 消息气泡
  messageOut: string;
  messageIn: string;
}

/**
 * 排版Token
 */
export interface TypographyToken {
  fontSize: number;
  fontWeight: number;
  lineHeight: number;
}

export interface TypographyTokens {
  h1: TypographyToken;
  h2: TypographyToken;
  h3: TypographyToken;
  body1: TypographyToken;
  body2: TypographyToken;
  caption: TypographyToken;
  button: TypographyToken;
}

/**
 * 边框Token
 */
export interface BorderTokens {
  radius: number;
  radiusSmall: number;
  radiusLarge: number;
  width: number;
  widthSmall: number;
  widthLarge: number;
}

/**
 * 间距Token
 */
export interface SpacingTokens {
  xs: number;
  sm: number;
  md: number;
  lg: number;
  xl: number;
  xxl: number;
}

/**
 * 阴影Token
 */
export interface ShadowToken {
  radius: number;
  color: string;
  offsetY: number;
}

export interface ShadowTokens {
  small: ShadowToken;
  medium: ShadowToken;
  large: ShadowToken;
}
