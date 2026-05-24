/**
 * 沉浸式设计工具类（华为官方推荐实现）
 * 提供统一的沉浸式解决方案，支持组件级和窗口级沉浸式
 * 参考华为官方文档：https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-window
 * 
 * 核心原则：
 * 1. 优先使用组件级方案 `.expandSafeArea()` 
 * 2. 需要精确控制时使用窗口级方案
 * 3. 动态适配深色/浅色主题
 */

import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0001;
const TAG = 'ImmersiveUtils';

/**
 * 沉浸式模式
 */
export enum ImmersiveMode {
  NONE = 'none',                    // 不使用沉浸式
  COMPONENT_TOP = 'component_top',  // 组件级顶部沉浸
  COMPONENT_BOTTOM = 'component_bottom', // 组件级底部沉浸
  COMPONENT_ALL = 'component_all',  // 组件级全沉浸
  WINDOW_FULL = 'window_full',      // 窗口级全屏
}

/**
 * 主题模式
 */
export enum ThemeMode {
  AUTO = 'auto',     // 自动根据背景色判断
  LIGHT = 'light',   // 浅色主题（深色文字）
  DARK = 'dark',     // 深色主题（浅色文字）
}

/**
 * 沉浸式配置
 */
export interface ImmersiveConfig {
  mode: ImmersiveMode;            // 沉浸式模式
  theme: ThemeMode;               // 主题模式
  backgroundColor?: string;       // 背景颜色（用于主题自动判断）
  excludeTop?: boolean;           // 是否排除顶部
  excludeBottom?: boolean;        // 是否排除底部
}

/**
 * 安全区域配置
 */
export interface SafeAreaConfig {
  types: string[];
  edges: string[];
}

/**
 * 避让区域信息
 */
export interface AvoidAreaInfo {
  topHeight: number;
  bottomHeight: number;
}

/**
 * 沉浸式设计工具类（华为官方推荐实现）
 */
export class ImmersiveUtils {
  
  /**
   * 判断背景色是否为深色（用于自动主题适配）
   * @param color 颜色字符串（支持 #RRGGBB 或 #AARRGGBB）
   * @returns 是否为深色背景
   */
  static isDarkBackground(color: string): boolean {
    if (!color || color.length < 7) return false;
    
    // 提取RGB值
    let hex = color.startsWith('#') ? color.substring(1) : color;
    if (hex.length === 8) hex = hex.substring(2); // 去除透明度
    
    if (hex.length !== 6) return false;
    
    const r = parseInt(hex.substring(0, 2), 16);
    const g = parseInt(hex.substring(2, 4), 16);
    const b = parseInt(hex.substring(4, 6), 16);
    
    // 计算相对亮度（WCAG标准）
    const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
    
    return luminance < 0.5;
  }

  /**
   * 获取主题模式
   * @param config 沉浸式配置
   * @returns 实际主题模式
   */
  static getThemeMode(config: ImmersiveConfig): ThemeMode {
    if (config.theme !== ThemeMode.AUTO) {
      return config.theme;
    }
    
    // 自动判断
    if (config.backgroundColor && ImmersiveUtils.isDarkBackground(config.backgroundColor)) {
      return ThemeMode.DARK;
    }
    return ThemeMode.LIGHT;
  }

  /**
   * 应用组件级沉浸式（华为官方推荐）
   * @param context UIAbility上下文
   * @param config 沉浸式配置
   */
  static async applyComponentImmersive(
    context: common.UIAbilityContext,
    config: ImmersiveConfig
  ): Promise<void> {
    try {
      const themeMode = ImmersiveUtils.getThemeMode(config);
      
      // 设置系统栏属性（状态栏文字颜色）
      const windowClass = await window.getLastWindow(context);
      if (windowClass) {
        const properties: window.SystemBarProperties = {
          statusBarColor: '#00000000', // 透明
          statusBarContentColor: themeMode === ThemeMode.DARK ? '#E5FFFFFF' : '#E5000000',
          isStatusBarLightIcon: themeMode === ThemeMode.DARK,
          navigationBarColor: '#00000000',
          navigationBarContentColor: themeMode === ThemeMode.DARK ? '#E5FFFFFF' : '#E5000000',
          isNavigationBarLightIcon: themeMode !== ThemeMode.DARK
        };
        
        windowClass.setWindowSystemBarProperties(properties);
        hilog.info(DOMAIN, TAG, `Component immersive applied: ${config.mode}, theme: ${themeMode}`);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to apply component immersive: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 获取扩展安全区域的配置
   * @param config 沉浸式配置
   * @returns SafeAreaType 和 SafeAreaEdge 配置
   */
  static getExpandSafeAreaConfig(config: ImmersiveConfig): SafeAreaConfig {
    const types: string[] = ['SYSTEM']; // 使用字符串常量
    const edges: string[] = [];
    
    switch (config.mode) {
      case ImmersiveMode.COMPONENT_TOP:
        if (!config.excludeTop) edges.push('TOP');
        break;
      case ImmersiveMode.COMPONENT_BOTTOM:
        if (!config.excludeBottom) edges.push('BOTTOM');
        break;
      case ImmersiveMode.COMPONENT_ALL:
        if (!config.excludeTop) edges.push('TOP');
        if (!config.excludeBottom) edges.push('BOTTOM');
        break;
    }
    
    return { types, edges };
  }

  /**
   * 应用窗口级沉浸式（全屏模式）
   * @param context UIAbility上下文
   * @param hideSystemBars 是否隐藏系统栏
   */
  static async applyWindowImmersive(
    context: common.UIAbilityContext,
    hideSystemBars: boolean = false
  ): Promise<void> {
    try {
      const windowClass = await window.getLastWindow(context);
      if (windowClass) {
        // 设置全屏布局
        windowClass.setWindowLayoutFullScreen(true);
        
        // 隐藏或显示系统栏
        if (hideSystemBars) {
          windowClass.setWindowSystemBarEnable([]);
        } else {
          windowClass.setWindowSystemBarEnable(['status', 'navigation']);
          
          // 设置透明系统栏
          const properties: window.SystemBarProperties = {
            statusBarColor: '#00000000',
            statusBarContentColor: '#E5FFFFFF',
            isStatusBarLightIcon: true,
            navigationBarColor: '#00000000',
            navigationBarContentColor: '#E5FFFFFF',
            isNavigationBarLightIcon: false
          };
          
          windowClass.setWindowSystemBarProperties(properties);
        }
        
        hilog.info(DOMAIN, TAG, `Window immersive applied, hideSystemBars: ${hideSystemBars}`);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to apply window immersive: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 恢复窗口级沉浸式（退出全屏）
   * @param context UIAbility上下文
   */
  static async restoreWindowImmersive(context: common.UIAbilityContext): Promise<void> {
    try {
      const windowClass = await window.getLastWindow(context);
      if (windowClass) {
        windowClass.setWindowLayoutFullScreen(false);
        windowClass.setWindowSystemBarEnable(['status', 'navigation']);
        hilog.info(DOMAIN, TAG, 'Window immersive restored');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to restore window immersive: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 获取避让区域信息
   * @param context UIAbility上下文
   * @returns 避让区域信息
   */
  static async getAvoidAreaInfo(context: common.UIAbilityContext): Promise<AvoidAreaInfo> {
    try {
      const windowClass = await window.getLastWindow(context);
      if (!windowClass) {
        return { topHeight: 0, bottomHeight: 0 };
      }
      
      const avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      return {
        topHeight: avoidArea.topRect.height,
        bottomHeight: avoidArea.bottomRect.height
      };
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to get avoid area info: ${JSON.stringify(error)}`);
      return { topHeight: 0, bottomHeight: 0 };
    }
  }
}
