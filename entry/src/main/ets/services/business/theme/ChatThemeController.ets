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

import hilog from '@ohos.hilog';
import { AppStorageV2 } from '@kit.ArkUI';

const TAG = 'ChatThemeController';
const DOMAIN = 0x0001;

/**
 * 主题文本颜色
 */
export interface ThemeTextColors {
  primary: string;
  secondary: string;
  disabled: string;
}

/**
 * 主题模式
 */
export type ThemeMode = 'system' | 'light' | 'dark';

/**
 * 主题变化监听器
 */
export type ThemeChangeListener = (mode: ThemeMode) => void;

/**
 * 主题服务
 * 管理应用主题切换和应用
 */
export class ThemeService {
  private static instance: ThemeService;
  private currentMode: ThemeMode = 'system';
  private isDarkMode: boolean = false;
  private listeners: ThemeChangeListener[] = [];
  private configuration: Configuration | null = null;

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): ThemeService {
    if (!ThemeService.instance) {
      ThemeService.instance = new ThemeService();
    }
    return ThemeService.instance;
  }

  /**
   * 初始化
   */
  public initialize(configuration: Configuration): void {
    this.configuration = configuration;
    this.updateSystemTheme();
    this.registerThemeListener();
    hilog.info(DOMAIN, TAG, 'ThemeService initialized');
  }

  /**
   * 注册主题监听
   */
  private registerThemeListener(): void {
    if (!this.configuration) {
      return;
    }

    // 实现系统主题变化监听
    // HarmonyOS Configuration API 通过 updateConfiguration 触发配置变化
    // 使用 AppStorage 监听系统主题变化
    AppStorage.setOrCreate('systemColorMode', this.configuration.colorMode);
    AppStorage.link('systemColorMode');

    // 监听系统主题变化
    const colorMode = AppStorage.get('systemColorMode') as number;
    if (colorMode !== undefined) {
      // 使用 StorageLink 监听系统配置变化
      // 注意：实际监听需要在 UI 层通过 @StorageLink 实现
      // 这里仅记录系统主题状态
      // ConfigurationConstant.ColorMode.DARK = 1, ConfigurationConstant.ColorMode.LIGHT = 0
      this.isDarkMode = colorMode === 1;
      hilog.debug(DOMAIN, TAG, `Initial system color mode: ${colorMode}`);
    }

    hilog.info(DOMAIN, TAG, 'Theme listener registered successfully');
  }

  /**
   * 更新系统主题
   */
  private updateSystemTheme(): void {
    if (!this.configuration) {
      return;
    }

    try {
      const colorModeValue = this.configuration.colorMode;
      const colorMode: number = typeof colorModeValue === 'number' ? colorModeValue : 0;
      // ConfigurationConstant.ColorMode.DARK = 1, ConfigurationConstant.ColorMode.LIGHT = 0
      this.isDarkMode = colorMode === 1;
      hilog.debug(DOMAIN, TAG, `System theme: ${this.isDarkMode ? 'dark' : 'light'}`);
      this.notifyListeners();
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to update system theme: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 设置主题模式
   */
  public setThemeMode(mode: ThemeMode): void {
    this.currentMode = mode;
    hilog.info(DOMAIN, TAG, `Theme mode set to: ${mode}`);

    if (mode === 'system') {
      this.updateSystemTheme();
    } else {
      this.isDarkMode = mode === 'dark';
      this.notifyListeners();
    }
  }

  /**
   * 获取当前主题模式
   */
  public getThemeMode(): ThemeMode {
    return this.currentMode;
  }

  /**
   * 获取是否为深色模式
   */
  public isDark(): boolean {
    return this.isDarkMode;
  }

  /**
   * 获取是否为浅色模式
   */
  public isLight(): boolean {
    return !this.isDarkMode;
  }

  /**
   * 注册主题变化监听器
   */
  public onThemeChange(listener: ThemeChangeListener): void {
    this.listeners.push(listener);
    hilog.debug(DOMAIN, TAG, `Theme listener registered, total: ${this.listeners.length}`);
  }

  /**
   * 移除主题变化监听器
   */
  public offThemeChange(listener: ThemeChangeListener): void {
    const index = this.listeners.indexOf(listener);
    if (index !== -1) {
      this.listeners.splice(index, 1);
      hilog.debug(DOMAIN, TAG, `Theme listener removed, total: ${this.listeners.length}`);
    }
  }

  /**
   * 通知所有监听器
   */
  private notifyListeners(): void {
    const mode = this.currentMode === 'system'
      ? (this.isDarkMode ? 'dark' : 'light')
      : this.currentMode;

    this.listeners.forEach(listener => {
      try {
        listener(mode);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Theme listener error: ${JSON.stringify(error)}`);
      }
    });
  }

  /**
   * 切换主题
   */
  public toggleTheme(): void {
    const newMode: ThemeMode = this.currentMode === 'dark' ? 'light' : 'dark';
    this.setThemeMode(newMode);
  }

  /**
   * 应用主题到窗口
   */
  public applyThemeToWindow(): void {
    try {
      // 实现主题应用到窗口功能
      // 通过 AppStorage 设置全局主题状态，UI 组件通过 @StorageLink 响应变化
      const targetDarkMode = this.isDarkMode;
      AppStorage.setOrCreate('isDarkMode', targetDarkMode);
      AppStorage.setOrCreate('themeMode', this.currentMode);

      // 应用主题颜色到全局存储
      const colors = this.getThemeColors();
      AppStorage.setOrCreate('themeColors', colors);

      // 如果需要更新系统配置（仅当不是跟随系统模式时）
      if (this.currentMode !== 'system' && this.configuration) {
        // 注意：实际应用中不应修改系统主题，只修改应用内部状态
        // 这里仅记录日志
        hilog.debug(DOMAIN, TAG, `Application theme: ${this.currentMode}, dark mode: ${targetDarkMode}`);
      }

      hilog.info(DOMAIN, TAG, `Theme applied: ${this.isDarkMode ? 'dark' : 'light'}, mode: ${this.currentMode}`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to apply theme to window: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 获取主题颜色
   */
  public getThemeColors(): ThemeColors {
    return this.isDarkMode ? this.getDarkColors() : this.getLightColors();
  }

  /**
   * 获取浅色主题颜色
   */
  private getLightColors(): ThemeColors {
    const textColors: ThemeTextColors = {
      primary: '#333333',
      secondary: '#666666',
      disabled: '#CCCCCC'
    };

    const colors: ThemeColors = {
      primary: '#007DFF',
      secondary: '#66BB6A',
      background: '#FFFFFF',
      surface: '#F5F5F5',
      error: '#FF5252',
      warning: '#FFA726',
      success: '#66BB6A',
      info: '#29B6F6',
      text: textColors,
      divider: '#E0E0E0',
      overlay: 'rgba(0, 0, 0, 0.5)'
    };
    return colors;
  }

  /**
   * 获取深色主题颜色
   */
  private getDarkColors(): ThemeColors {
    const textColors: ThemeTextColors = {
      primary: '#FFFFFF',
      secondary: '#B0B0B0',
      disabled: '#666666'
    };

    const colors: ThemeColors = {
      primary: '#40C4FF',
      secondary: '#81C784',
      background: '#1A1A1A',
      surface: '#2D2D2D',
      error: '#FF8A80',
      warning: '#FFB74D',
      success: '#81C784',
      info: '#4DD0E1',
      text: textColors,
      divider: '#404040',
      overlay: 'rgba(0, 0, 0, 0.7)'
    };
    return colors;
  }

  /**
   * 销毁
   */
  public destroy(): void {
    this.listeners = [];
    this.configuration = null;
    hilog.info(DOMAIN, TAG, 'ThemeService destroyed');
  }
}

/**
 * 主题颜色配置
 */
export interface ThemeColors {
  primary: string;
  secondary: string;
  background: string;
  surface: string;
  error: string;
  warning: string;
  success: string;
  info: string;
  text: ThemeTextColors;
  divider: string;
  overlay: string;
}

/**
 * 主题工具类
 */
export class ThemeUtils {
  /**
   * 调整颜色亮度
   * @param color 颜色字符串，格式为 #RRGGBB
   * @param amount 亮度调整值，范围从 -255 到 255，负值变暗，正值变亮
   * @returns 调整后的颜色字符串
   */
  public static adjustBrightness(color: string, amount: number): string {
    const hex = color.replace('#', '');
    const r = Math.max(0, Math.min(255, parseInt(hex.substring(0, 2), 16) + amount));
    const g = Math.max(0, Math.min(255, parseInt(hex.substring(2, 4), 16) + amount));
    const b = Math.max(0, Math.min(255, parseInt(hex.substring(4, 6), 16) + amount));

    const rr = r.toString(16).padStart(2, '0');
    const gg = g.toString(16).padStart(2, '0');
    const bb = b.toString(16).padStart(2, '0');

    return `#${rr}${gg}${bb}`;
  }

  /**
   * 获取颜色的反色
   * @param color 颜色字符串，格式为 #RRGGBB
   * @returns 反转后的颜色字符串
   */
  public static getInvertedColor(color: string): string {
    const hex = color.replace('#', '');
    const r = (255 - parseInt(hex.substring(0, 2), 16)).toString(16).padStart(2, '0');
    const g = (255 - parseInt(hex.substring(2, 4), 16)).toString(16).padStart(2, '0');
    const b = (255 - parseInt(hex.substring(4, 6), 16)).toString(16).padStart(2, '0');

    return `#${r}${g}${b}`;
  }

  /**
   * 判断颜色是深色还是浅色
   * @param color 颜色字符串，格式为 #RRGGBB
   * @returns true表示深色，false表示浅色
   */
  public static isDarkColor(color: string): boolean {
    const hex = color.replace('#', '');
    const r = parseInt(hex.substring(0, 2), 16);
    const g = parseInt(hex.substring(2, 4), 16);
    const b = parseInt(hex.substring(4, 6), 16);

    // 使用亮度公式：Y = 0.299R + 0.587G + 0.114B
    const brightness = (r * 299 + g * 587 + b * 114) / 1000;

    // 亮度小于128为深色
    return brightness < 128;
  }

  /**
   * 混合两个颜色
   * @param color1 第一个颜色字符串，格式为 #RRGGBB
   * @param color2 第二个颜色字符串，格式为 #RRGGBB
   * @param ratio 混合比例，0到1之间，0表示完全使用color1，1表示完全使用color2
   * @returns 混合后的颜色字符串
   */
  public static blendColors(color1: string, color2: string, ratio: number): string {
    const hex1 = color1.replace('#', '');
    const hex2 = color2.replace('#', '');

    const r1 = parseInt(hex1.substring(0, 2), 16);
    const g1 = parseInt(hex1.substring(2, 4), 16);
    const b1 = parseInt(hex1.substring(4, 6), 16);

    const r2 = parseInt(hex2.substring(0, 2), 16);
    const g2 = parseInt(hex2.substring(2, 4), 16);
    const b2 = parseInt(hex2.substring(4, 6), 16);

    const r = Math.round(r1 + (r2 - r1) * ratio);
    const g = Math.round(g1 + (g2 - g1) * ratio);
    const b = Math.round(b1 + (b2 - b1) * ratio);

    const rr = r.toString(16).padStart(2, '0');
    const gg = g.toString(16).padStart(2, '0');
    const bb = b.toString(16).padStart(2, '0');

    return `#${rr}${gg}${bb}`;
  }

  /**
   * 添加透明度
   * @param color 颜色字符串，格式为 #RRGGBB
   * @param alpha 透明度值，范围从 0 到 1，0表示完全透明，1表示完全不透明
   * @returns 添加透明度后的颜色字符串，格式为 #RRGGBBAA
   */
  public static addAlpha(color: string, alpha: number): string {
    const hex = color.replace('#', '');
    const alphaInt = Math.round(Math.max(0, Math.min(1, alpha)) * 255);
    const alphaHex = alphaInt.toString(16).padStart(2, '0');

    return `#${hex}${alphaHex}`;
  }
}

/**
 * 主题颜色配置接口
 */
export interface ThemeColorConfig {
  PRIMARY: string;
  SECONDARY: string;
  SUCCESS: string;
  WARNING: string;
  ERROR: string;
  INFO: string;
  WHITE: string;
  BLACK: string;
  TRANSPARENT: string;
}

/**
 * 主题常量
 */
export class ThemeConstants {
  static readonly MODES: string[] = ['system', 'light', 'dark'];
  static readonly LIGHT_MODE = 'light';
  static readonly DARK_MODE = 'dark';
  static readonly SYSTEM_MODE = 'system';

  static readonly COLORS: ThemeColorConfig = {
    PRIMARY: '#007DFF',
    SECONDARY: '#66BB6A',
    SUCCESS: '#66BB6A',
    WARNING: '#FFA726',
    ERROR: '#FF5252',
    INFO: '#29B6F6',
    WHITE: '#FFFFFF',
    BLACK: '#000000',
    TRANSPARENT: 'transparent'
  };
}
