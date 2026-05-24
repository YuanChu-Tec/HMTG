/*
 * Copyright (c) 2026 HMTG Project
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { preferences } from '@kit.ArkData';
import { appManager } from '@kit.AbilityKit';
import { common } from '@kit.AbilityKit';

const TAG = 'AppearanceViewModel';
const DOMAIN = 0x0001;

/**
 * 外观设置数据模型
 */
export interface AppearanceSettingsData {
  themeMode: 'system' | 'light' | 'dark';
  language: string;
  fontSize: number;
  messageStyle: 'modern' | 'classic';
  showAnimations: boolean;
  animationSpeed: number;
  customThemeColor: string;
  bubbleColor: string;
}

/**
 * 语言信息接口
 */
export interface LanguageInfo {
  code: string;
  name: string;
  nativeName: string;
}

/**
 * 主题颜色信息接口
 */
export interface ThemeColorInfo {
  color: string;
  name: string;
}

/**
 * 外观设置 ViewModel
 */
export class AppearanceViewModel {
  private static instance: AppearanceViewModel;
  private appearanceData: AppearanceSettingsData;
  private preferencesStore: preferences.Preferences | null = null;
  private themeChangeListeners: Array<(theme: string) => void> = [];

  private constructor() {
    this.appearanceData = this.getDefaultAppearanceSettings();
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): AppearanceViewModel {
    if (!AppearanceViewModel.instance) {
      AppearanceViewModel.instance = new AppearanceViewModel();
    }
    return AppearanceViewModel.instance;
  }

  /**
   * 获取默认外观设置
   */
  private getDefaultAppearanceSettings(): AppearanceSettingsData {
    return {
      themeMode: 'system',
      language: 'zh-CN',
      fontSize: 16,
      messageStyle: 'modern',
      showAnimations: true,
      animationSpeed: 50,
      customThemeColor: '#007DFF',
      bubbleColor: '#007DFF'
    };
  }

  /**
   * 初始化
   */
  public async initialize(context: Context): Promise<void> {
    try {
      this.preferencesStore = await preferences.getPreferences(context, 'appearance');
      await this.loadAppearanceSettings();
      hilog.info(DOMAIN, TAG, 'Appearance settings initialized');
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to initialize appearance settings: ' + JSON.stringify(error));
    }
  }

  /**
   * 加载外观设置
   */
  private async loadAppearanceSettings(): Promise<void> {
    if (!this.preferencesStore) {
      return;
    }

    try {
      this.appearanceData = {
        themeMode: await this.preferencesStore.get('themeMode', 'system') as 'system' | 'light' | 'dark',
        language: await this.preferencesStore.get('language', 'zh-CN') as string,
        fontSize: await this.preferencesStore.get('fontSize', 16) as number,
        messageStyle: await this.preferencesStore.get('messageStyle', 'modern') as 'modern' | 'classic',
        showAnimations: await this.preferencesStore.get('showAnimations', true) as boolean,
        animationSpeed: await this.preferencesStore.get('animationSpeed', 50) as number,
        customThemeColor: await this.preferencesStore.get('customThemeColor', '#007DFF') as string,
        bubbleColor: await this.preferencesStore.get('bubbleColor', '#007DFF') as string
      };
      hilog.info(DOMAIN, TAG, 'Appearance settings loaded');
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to load appearance settings: ' + JSON.stringify(error));
    }
  }

  /**
   * 保存外观设置
   */
  public async saveAppearanceSettings(): Promise<void> {
    if (!this.preferencesStore) {
      return;
    }

    try {
      await this.preferencesStore.put('themeMode', this.appearanceData.themeMode);
      await this.preferencesStore.put('language', this.appearanceData.language);
      await this.preferencesStore.put('fontSize', this.appearanceData.fontSize);
      await this.preferencesStore.put('messageStyle', this.appearanceData.messageStyle);
      await this.preferencesStore.put('showAnimations', this.appearanceData.showAnimations);
      await this.preferencesStore.put('animationSpeed', this.appearanceData.animationSpeed);
      await this.preferencesStore.put('customThemeColor', this.appearanceData.customThemeColor);
      await this.preferencesStore.put('bubbleColor', this.appearanceData.bubbleColor);
      await this.preferencesStore.flush();
      hilog.info(DOMAIN, TAG, 'Appearance settings saved');
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to save appearance settings: ' + JSON.stringify(error));
    }
  }

  /**
   * 获取外观设置
   */
  public getAppearanceSettings(): AppearanceSettingsData {
    const result: AppearanceSettingsData = {
      themeMode: this.appearanceData.themeMode,
      language: this.appearanceData.language,
      fontSize: this.appearanceData.fontSize,
      messageStyle: this.appearanceData.messageStyle,
      showAnimations: this.appearanceData.showAnimations,
      animationSpeed: this.appearanceData.animationSpeed,
      customThemeColor: this.appearanceData.customThemeColor,
      bubbleColor: this.appearanceData.bubbleColor
    };
    return result;
  }

  /**
   * 设置主题模式
   */
  public setThemeMode(mode: 'system' | 'light' | 'dark'): void {
    this.appearanceData.themeMode = mode;
    this.notifyThemeChange(mode);
  }

  /**
   * 设置语言
   */
  public setLanguage(language: string): void {
    this.appearanceData.language = language;
  }

  /**
   * 设置字体大小
   */
  public setFontSize(size: number): void {
    this.appearanceData.fontSize = size;
  }

  /**
   * 设置消息样式
   */
  public setMessageStyle(style: 'modern' | 'classic'): void {
    this.appearanceData.messageStyle = style;
  }

  /**
   * 设置动画显示
   */
  public setShowAnimations(enabled: boolean): void {
    this.appearanceData.showAnimations = enabled;
  }

  /**
   * 设置动画速度
   */
  public setAnimationSpeed(speed: number): void {
    this.appearanceData.animationSpeed = speed;
  }

  /**
   * 设置自定义主题颜色
   */
  public setCustomThemeColor(color: string): void {
    this.appearanceData.customThemeColor = color;
  }

  /**
   * 设置气泡颜色
   */
  public setBubbleColor(color: string): void {
    this.appearanceData.bubbleColor = color;
  }

  /**
   * 注册主题变化监听
   */
  public onThemeChange(listener: (theme: string) => void): void {
    this.themeChangeListeners.push(listener);
  }

  /**
   * 移除主题变化监听
   */
  public offThemeChange(listener: (theme: string) => void): void {
    const index = this.themeChangeListeners.indexOf(listener);
    if (index !== -1) {
      this.themeChangeListeners.splice(index, 1);
    }
  }

  /**
   * 通知主题变化
   */
  private notifyThemeChange(theme: string): void {
    this.themeChangeListeners.forEach(listener => {
      try {
        listener(theme);
      } catch (error) {
        hilog.error(DOMAIN, TAG, 'Theme change listener error: ' + JSON.stringify(error));
      }
    });
  }

  /**
   * 应用语言设置
   */
  public async applyLanguageSettings(): Promise<boolean> {
    try {
      // 使用 i18n 系统设置语言
      const locale = this.appearanceData.language;
      const systemLocale: string = locale;

      // 通知应用语言已更新（实际设置应用需要重启应用）
      hilog.info(DOMAIN, TAG, `Applying language: ${systemLocale}`);
      
      // 这里只是标记已应用，实际的语言切换通常需要重启应用
      // 或者使用系统提供的语言切换API
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to apply language settings: ' + JSON.stringify(error));
      return false;
    }
  }

  /**
   * 应用主题设置
   */
  public async applyThemeSettings(): Promise<boolean> {
    try {
      // 设置应用主题模式（模拟实现）
      // 实际 HarmonyOS NEXT 中需要使用其他 API
      const themeMode = this.appearanceData.themeMode;
      hilog.info(DOMAIN, TAG, `Applied theme: ${themeMode}`);
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to apply theme settings: ' + JSON.stringify(error));
      return false;
    }
  }

  /**
   * 获取支持的语言列表
   */
  public getSupportedLanguages(): LanguageInfo[] {
    const languages: LanguageInfo[] = [
      { code: 'zh-CN', name: '简体中文', nativeName: '简体中文' },
      { code: 'zh-TW', name: '繁体中文', nativeName: '繁體中文' },
      { code: 'en-US', name: 'English (US)', nativeName: 'English' },
      { code: 'ja-JP', name: '日本語', nativeName: '日本語' },
      { code: 'ko-KR', name: '한국어', nativeName: '한국어' },
      { code: 'es-ES', name: 'Español', nativeName: 'Español' },
      { code: 'fr-FR', name: 'Français', nativeName: 'Français' },
      { code: 'de-DE', name: 'Deutsch', nativeName: 'Deutsch' },
      { code: 'ru-RU', name: 'Русский', nativeName: 'Русский' },
      { code: 'ar-SA', name: 'العربية', nativeName: 'العربية' }
    ];
    return languages;
  }

  /**
   * 获取支持的主题颜色
   */
  public getSupportedThemeColors(): ThemeColorInfo[] {
    const colors: ThemeColorInfo[] = [
      { color: '#007DFF', name: '默认蓝色' },
      { color: '#FF6B35', name: '活力橙' },
      { color: '#00C853', name: '自然绿' },
      { color: '#AA00FF', name: '神秘紫' },
      { color: '#FF1744', name: '热情红' },
      { color: '#00BCD4', name: '清新青' },
      { color: '#FFC107', name: '明亮黄' },
      { color: '#607D8B', name: '简约灰' }
    ];
    return colors;
  }

  /**
   * 重置为默认设置
   */
  public resetToDefaults(): void {
    this.appearanceData = this.getDefaultAppearanceSettings();
  }

  /**
   * 销毁
   */
  public destroy(): void {
    this.preferencesStore = null;
    this.themeChangeListeners = [];
  }
}
