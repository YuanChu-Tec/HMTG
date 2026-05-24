/**
 * 点击波纹效果工具函数
 */

/**
 * 创建点击波纹效果
 */
export function createRippleEffect(): Record<string, Object> {
  const result: Record<string, Object> = {};
  result.rippleColor = 'rgba(0,0,0,0.1)';
  result.rippleDuration = 300;
  result.rippleDelay = 0;
  return result;
}

/**
 * 应用波纹效果到组件
 */
export function applyRippleEffect(): Record<string, Object> {
  const result: Record<string, Object> = {};
  result.stateEffect = true;
  const stateStyles: Record<string, Object> = {};
  const normalStyle: Record<string, Object> = {};
  normalStyle.backgroundColor = 'transparent';
  stateStyles.normal = normalStyle;

  const pressedStyle: Record<string, Object> = {};
  pressedStyle.backgroundColor = 'rgba(0,0,0,0.05)';
  stateStyles.pressed = pressedStyle;
  result.stateStyles = stateStyles;
  return result;
}

/**
 * 创建按压反馈效果
 */
export function createPressFeedback(): Record<string, Object> {
  const result: Record<string, Object> = {};
  const scale: Record<string, number> = {};
  scale.x = 0.98;
  scale.y = 0.98;
  result.scale = scale;
  result.duration = 100;
  return result;
}

/**
 * 组合点击效果（波纹 + 缩放）
 */
export function createClickEffect(): Record<string, Object> {
  const rippleEffect = applyRippleEffect();
  const gestureEffect: Record<string, Object> = {};

  // 注意：LongPressGesture需要从@kit.ArkUI导入
  // 这里仅作为示例，实际使用时需要正确导入
  const gestureObj: Record<string, Object> = {};
  gestureObj.repeat = false;
  gestureObj.onAction = () => {
    // 长按事件
  };

  const gesture: Record<string, Object> = {};
  gesture.gesture = gestureObj;
  Object.keys(rippleEffect).forEach(key => {
    gesture[key] = rippleEffect[key];
  });
  Object.keys(gestureEffect).forEach(key => {
    gesture[key] = gestureEffect[key];
  });

  return gesture;
}

/**
 * 防抖函数
 */
export function debounce<T extends (...args: Object[]) => Object>(
  func: T,
  delay: number
): (...args: Object[]) => void {
  let timeoutId: number | null = null;

  return (...args: Object[]) => {
    if (timeoutId) {
      clearTimeout(timeoutId);
    }
    timeoutId = setTimeout(() => {
      func(...args);
    }, delay);
  };
}

/**
 * 节流函数
 */
export function throttle<T extends (...args: Object[]) => Object>(
  func: T,
  limit: number
): (...args: Object[]) => void {
  let inThrottle: boolean = false;

  return (...args: Object[]) => {
    if (!inThrottle) {
      func(...args);
      inThrottle = true;
      setTimeout(() => {
        inThrottle = false;
      }, limit);
    }
  };
}
