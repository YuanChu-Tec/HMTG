/**
 * UI 组件库统一导出入口
 * 
 * 架构说明:
 * - components/common/: 通用基础组件
 * - components/chat/: 聊天相关组件
 * - components/dialog/: 对话框组件
 * - themes/: 主题系统
 * - utils/: 工具函数
 * 
 * 使用方式:
 * 1. 全量导入：import { Avatar } from '../ui_kit'
 * 2. 按需导入：import { Avatar } from '../ui_kit/components/Avatar'
 */

// ==================== Common Components - 通用基础组件 ====================
export { Avatar } from './components/Avatar';
export { LoadingIndicator } from './components/LoadingIndicator';
export { BadgeEx as Badge } from './components/Badge';

// ==================== Theme System - 主题系统 ====================
export { ThemeManager } from './themes/ThemeManager';
export { AppTheme, ThemeType } from './themes/AppTheme';
export { LightTheme } from './themes/LightTheme';
export { DarkTheme } from './themes/DarkTheme';
export { SystemTheme } from './themes/SystemTheme';
export { ThemeTokenFactory } from './themes/ThemeTokens';
export { ThemeAssistant } from '../utils/ThemeAssistant';

// ==================== Utils - 工具函数 ====================
export { createClickEffect } from './utils/click_effect';
export { MessageContentCache } from './utils/MessageContentCache';


