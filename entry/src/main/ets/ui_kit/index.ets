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
 * 1. 全量导入：import { RoundButton, Avatar } from '../ui_kit'
 * 2. 按需导入：import { RoundButton } from '../ui_kit/components/common/RoundButton'
 */

// ==================== Common Components - 通用基础组件 ====================
export { IconButton } from './components/common/IconButton';
export { Avatar } from './components/common/Avatar';
export { RoundButton } from './components/common/RoundButton';
export { LoadingIndicator } from './components/common/LoadingIndicator';
export { BadgeEx as Badge } from './components/common/Badge';
export { SearchBar } from './components/common/SearchBar';
export { LazyImage } from './components/common/LazyImage';
export { SmartLazyImage, ImageLoader, LoadPriority, LoadState } from './components/common/SmartLazyImage';
export { SwipeActions } from './components/common/SwipeActions';

// ==================== Chat Components - 聊天相关组件 ====================
export { VirtualListView } from './components/chat/VirtualListView';
export { MessageBubble } from './components/chat/MessageBubble';
export { MessageMenu } from './components/chat/MessageMenu';
export { TypingIndicator } from './components/chat/TypingIndicator';
export { AvatarImage } from './components/chat/AvatarImage';

// ==================== Dialog Components - 对话框组件 ====================
export { CommonDialog } from './components/dialog/CommonDialog';
export { ProgressDialog } from './components/dialog/ProgressDialog';
export { BottomSheet } from './components/dialog/BottomSheet';

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


