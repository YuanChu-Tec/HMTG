/**
 * Telegram 风格公共样式
 * 符合方案 UI/UX 设计 - 一比一风格
 */
import { ThemeTokenFactory } from '../ui_kit/themes/ThemeTokens';

// 获取浅色主题颜色（默认）
const colors = ThemeTokenFactory.createLightTokens().colors;
// 硬编码颜色值（简单页面不需要主题系统）
const TEXT_PRIMARY = '#333333';
const TEXT_SECONDARY = '#666666';
const BACKGROUND = '#ffffff';
const BACKGROUND_SECONDARY = '#f5f5f5';
const TELEGRAM_BLUE = '#2481cc';

@Styles
export function telegramCardStyle(): void {
  .backgroundColor(BACKGROUND)
  .borderRadius(AppRadius.MD)
  .padding(AppSpacing.LG)
  .shadow({ radius: 4, color: 'rgba(0,0,0,0.06)', offsetY: 2 })
}

@Styles
export function telegramButtonPrimary(): void {
  .fontSize(AppFont.BODY_L.fontSize)
  .fontColor(Color.White)
  .backgroundColor(TELEGRAM_BLUE)
  .borderRadius(AppRadius.MD)
  .height(48)
}

@Styles
export function telegramInputStyle(): void {
  .fontSize(AppFont.BODY_M.fontSize)
  .fontColor(TEXT_PRIMARY)
  .placeholderColor(colors.textSecondary)
  .backgroundColor(BACKGROUND_SECONDARY)
  .borderRadius(AppRadius.SM)
  .padding(AppSpacing.MD)
}
