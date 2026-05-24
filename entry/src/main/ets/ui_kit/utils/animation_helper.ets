/**
 * 动画辅助工具类
 */
export class AnimationHelper {
  /**
   * 淡入动画配置
   */
  static fadeIn(duration: number = 300): Object {
    return {
      duration,
      curve: Curve.FastOutSlowIn,
      playMode: PlayMode.Normal
    };
  }

  /**
   * 淡出动画配置
   */
  static fadeOut(duration: number = 300): Object {
    return {
      duration,
      curve: Curve.FastOutSlowIn,
      playMode: PlayMode.Normal
    };
  }

  /**
   * 缩放动画配置
   */
  static scale(
    fromScale: number = 0.8,
    toScale: number = 1,
    duration: number = 300
  ): Object {
    return {
      duration,
      curve: Curve.FastOutSlowIn,
      playMode: PlayMode.Normal
    };
  }

  /**
   * 滑入动画配置
   */
  static slideIn(
    direction: 'left' | 'right' | 'top' | 'bottom' = 'bottom',
    distance: number = 100,
    duration: number = 300
  ): Object {
    const offsets: Record<string, number> = {
      left: distance,
      right: -distance,
      top: distance,
      bottom: -distance
    };

    return {
      duration,
      curve: Curve.FastOutSlowIn,
      playMode: PlayMode.Normal
    };
  }

  /**
   * 滑出动画配置
   */
  static slideOut(
    direction: 'left' | 'right' | 'top' | 'bottom' = 'bottom',
    distance: number = 100,
    duration: number = 300
  ): Object {
    const offsets: Record<string, number> = {
      left: -distance,
      right: distance,
      top: -distance,
      bottom: distance
    };

    return {
      duration,
      curve: Curve.FastOutSlowIn,
      playMode: PlayMode.Normal
    };
  }

  /**
   * 旋转动画配置
   */
  static rotate(
    fromAngle: number = 0,
    toAngle: number = 360,
    duration: number = 1000,
    iterations: number = 1
  ): Object {
    return {
      duration,
      curve: Curve.Linear,
      iterations,
      playMode: PlayMode.Normal
    };
  }

  /**
   * 弹跳动画配置
   */
  static bounce(
    duration: number = 500
  ): Object {
    return {
      duration,
      curve: Curve.EaseInOut,
      playMode: PlayMode.Normal
    };
  }

  /**
   * 闪烁动画配置
   */
  static blink(
    duration: number = 1000,
    iterations: number = -1
  ): Object {
    return {
      duration: duration / 2,
      curve: Curve.Linear,
      iterations,
      playMode: PlayMode.Alternate
    };
  }

  /**
   * 弹性动画配置
   */
  static spring(
    duration: number = 600
  ): Object {
    return {
      duration,
      curve: Curve.EaseInOutElastic,
      playMode: PlayMode.Normal
    };
  }

  /**
   * 创建动画组合
   */
  static createSequence(...animations: Object[]): Object {
    let totalDuration = 0;
    for (let i = 0; i < animations.length; i++) {
      const anim = animations[i] as Record<string, Object>;
      if (anim.duration !== undefined) {
        totalDuration = totalDuration + (anim.duration as number);
      }
    }
    return {
      duration: totalDuration,
      curve: Curve.FastOutSlowIn
    };
  }

  /**
   * 创建并行动画
   */
  static createParallel(...animations: Object[]): Object {
    let maxDuration = 0;
    for (let i = 0; i < animations.length; i++) {
      const anim = animations[i] as Record<string, Object>;
      if (anim.duration !== undefined) {
        const duration = anim.duration as number;
        if (duration > maxDuration) {
          maxDuration = duration;
        }
      }
    }
    return {
      duration: maxDuration,
      curve: Curve.FastOutSlowIn
    };
  }

  /**
   * 延迟动画
   */
  static delay(duration: number): Promise<void> {
    return new Promise(resolve => {
      setTimeout(() => {
        resolve();
      }, duration);
    });
  }
}

/**
 * 动画类型
 */
export type AnimationType =
  | 'fadeIn'
  | 'fadeOut'
  | 'scale'
  | 'slideIn'
  | 'slideOut'
  | 'rotate'
  | 'bounce'
  | 'blink'
  | 'spring';

/**
 * 动画方向
 */
export type AnimationDirection = 'left' | 'right' | 'top' | 'bottom';
