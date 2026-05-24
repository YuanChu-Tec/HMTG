import { AppTheme, ThemeType } from './AppTheme';
import { LightTheme } from './LightTheme';
import { DarkTheme } from './DarkTheme';
import { SystemTheme } from './SystemTheme';
import { BusinessError } from '@ohos.base';
import { Preference } from '../../utils/storage/Preference';

/**
 * 主题管理器 - 单例模式
 */
export class ThemeManager {
  private static instance: ThemeManager;
  private currentTheme: AppTheme;
  private themeListeners: Set<(theme: AppTheme) => void> = new Set();
  private readonly STORAGE_KEY = 'app_theme_preference';

  private constructor() {
    this.currentTheme = new LightTheme();
  }

  public static getInstance(): ThemeManager {
    if (!ThemeManager.instance) {
      ThemeManager.instance = new ThemeManager();
    }
    return ThemeManager.instance;
  }

  /**
   * 获取当前主题
   */
  public getCurrentTheme(): AppTheme {
    return this.currentTheme;
  }

  /**
   * 设置主题
   */
  public setTheme(type: ThemeType): void {
    switch (type) {
      case ThemeType.LIGHT:
        this.currentTheme = new LightTheme();
        break;
      case ThemeType.DARK:
        this.currentTheme = new DarkTheme();
        break;
      case ThemeType.SYSTEM:
        this.currentTheme = new SystemTheme();
        break;
      default:
        throw new Error(`Unknown theme type: ${type}`);
    }

    this.notifyListeners();
  }

  /**
   * 切换主题（浅色/深色）
   */
  public toggleTheme(): void {
    const isDark = this.currentTheme.type === ThemeType.DARK;
    this.setTheme(isDark ? ThemeType.LIGHT : ThemeType.DARK);
  }

  /**
   * 添加主题变更监听器
   */
  public addThemeListener(listener: (theme: AppTheme) => void): void {
    this.themeListeners.add(listener);
  }

  /**
   * 移除主题变更监听器
   */
  public removeThemeListener(listener: (theme: AppTheme) => void): void {
    this.themeListeners.delete(listener);
  }

  /**
   * 通知所有监听器
   */
  private notifyListeners(): void {
    this.themeListeners.forEach(listener => {
      try {
        listener(this.currentTheme);
      } catch (error) {
        console.error('Theme listener error:', error);
      }
    });
  }

  /**
   * 保存主题偏好（持久化）
   */
  public async saveThemePreference(type: ThemeType): Promise<void> {
    try {
      const preference = Preference.getInstance('theme_preference');
      await preference.set(this.STORAGE_KEY, type);
    } catch (error) {
      console.error('Failed to save theme preference:', error);
    }
  }

  /**
   * 加载主题偏好
   */
  public async loadThemePreference(): Promise<ThemeType> {
    try {
      const preference = Preference.getInstance('theme_preference');
      const savedTheme = await preference.get(this.STORAGE_KEY);
      if (savedTheme) {
        return savedTheme as ThemeType;
      }
    } catch (error) {
      console.error('Failed to load theme preference:', error);
    }
    return ThemeType.LIGHT;
  }

  /**
   * 初始化主题
   */
  public async initialize(): Promise<void> {
    const savedTheme = await this.loadThemePreference();
    this.setTheme(savedTheme);
  }

  /**
   * 应用主题到组件
   */
  public get tokens() {
    return this.currentTheme.tokens;
  }

  /**
   * 获取当前主题类型
   */
  public get themeType(): ThemeType {
    return this.currentTheme.type;
  }

  /**
   * 检查是否为深色主题
   */
  public isDarkTheme(): boolean {
    return this.currentTheme.type === ThemeType.DARK;
  }
}
