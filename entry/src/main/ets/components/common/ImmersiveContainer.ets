/**
 * 沉浸式容器组件（华为官方推荐实现）
 * 替代 TopImmersiveContainer，提供统一的沉浸式解决方案
 *
 * 使用场景：
 * 1. 普通页面：使用组件级沉浸式，背景延伸到状态栏
 * 2. 深色背景页面：自动适配浅色状态栏文字
 * 3. 特殊页面：支持全屏模式
 *
 * 华为官方推荐优先级：
 * 1. 组件级沉浸式（.expandSafeArea()） - 大多数场景
 * 2. 窗口级沉浸式（setWindowLayoutFullScreen） - 特殊场景（视频、游戏）
 */

import { common } from '@kit.AbilityKit';
import { KeyboardAvoidMode } from '@kit.ArkUI';
import { ImmersiveUtils, ImmersiveMode, ThemeMode, ImmersiveConfig } from '../../utils/utils/ImmersiveUtils';

/**
 * 沉浸式容器组件
 *
 * @param mode 沉浸式模式（默认：顶部沉浸）
 * @param theme 主题模式（默认：自动）
 * @param excludeTop 是否排除顶部沉浸（默认：false）
 * @param excludeBottom 是否排除底部沉浸（默认：true）
 * @param fullScreen 是否使用全屏模式（默认：false）
 * @param hideSystemBars 是否隐藏系统栏（全屏模式下有效，默认：false）
 */
@Component
export struct ImmersiveContainer {
  /** 沉浸式模式 */
  mode: ImmersiveMode = ImmersiveMode.COMPONENT_TOP;
  /** 主题模式 */
  theme: ThemeMode = ThemeMode.AUTO;
  /** 是否排除顶部 */
  excludeTop: boolean = false;
  /** 是否排除底部 */
  excludeBottom: boolean = true;
  /** 是否使用全屏模式 */
  fullScreen: boolean = false;
  /** 是否隐藏系统栏（全屏模式下有效） */
  hideSystemBars: boolean = false;
  /** 背景颜色 */
  bgColor?: string;
  /** 内容插槽 */
  @BuilderParam content: () => void = this.defaultContent;

  /**
   * 默认内容构建器
   */
  @Builder
  defaultContent() {}

  /**
   * 初始化时设置软键盘避让模式为 RESIZE（压缩模式）
   * 这是华为官方推荐的表单页最佳实践，可以避免页面整体上抬导致的布局错位。
   */
  aboutToAppear(): void {
    try {
      this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
    } catch (e) {
      console.warn('Failed to set keyboard avoid mode:', e);
    }
  }

  /**
   * 上下文
   */
  private getContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext;
  }

  /**
   * 构建沉浸式容器
   * 华为最佳实践：组件级沉浸式 = expandSafeArea() + 手动padding避让
   * 注意：expandSafeArea() 只影响绘制区域，不影响子组件布局
   */
  build() {
    // 构建容器
    Column() {
      // 内容插槽 - 添加动态padding避让系统栏
      Column() {
        this.content();
      }
      .width('100%')
      .height('100%')
      // 华为官方推荐：手动设置padding避让状态栏和导航栏
      .padding({
        top: this.excludeTop ? 0 : '48vp',  // 默认48vp状态栏高度
        bottom: this.excludeBottom ? 0 : '0vp'
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor || '#FFFFFF')
    // 华为官方推荐：组件级沉浸式核心方法
    // 扩展到系统安全区域（状态栏/导航栏）
    .expandSafeArea()
    .onAppear(() => {
      this.onContainerAppear();
    })
    .onDisAppear(() => {
      this.onContainerDisappear();
    })
  }

  /**
   * 容器显示时处理
   */
  private async onContainerAppear(): Promise<void> {
    const context = this.getContext();
    const config: ImmersiveConfig = {
      mode: this.mode,
      theme: this.theme,
      excludeTop: this.excludeTop,
      excludeBottom: this.excludeBottom
    };

    if (this.fullScreen) {
      // 全屏模式
      await ImmersiveUtils.applyWindowImmersive(context, this.hideSystemBars);
    } else {
      // 组件级沉浸式
      await ImmersiveUtils.applyComponentImmersive(context, config);
    }
  }

  /**
   * 容器隐藏时处理
   */
  private async onContainerDisappear(): Promise<void> {
    if (this.fullScreen) {
      // 恢复窗口级沉浸式
      await ImmersiveUtils.restoreWindowImmersive(this.getContext());
    }
  }
}

/**
 * 顶部沉浸式容器（最常用）
 * 适用于大多数页面，背景延伸到状态栏
 */
@Component
export struct TopImmersiveContainer {
  theme: ThemeMode = ThemeMode.AUTO;
  @BuilderParam content: () => void = this.defaultContent;

  @Builder
  defaultContent() {}

  build() {
    Column() {
      ImmersiveContainer({
        mode: ImmersiveMode.COMPONENT_TOP,
        theme: this.theme,
        excludeBottom: true
      }) {
        this.content();
      }
    }
    .width('100%')
    .height('100%')
  }
}

/**
 * 全沉浸式容器
 * 背景同时延伸到状态栏和导航栏
 * 适用于背景图片或特殊设计页面
 */
@Component
export struct FullImmersiveContainer {
  theme: ThemeMode = ThemeMode.AUTO;
  @BuilderParam content: () => void = this.defaultContent;

  @Builder
  defaultContent() {}

  build() {
    Column() {
      ImmersiveContainer({
        mode: ImmersiveMode.COMPONENT_ALL,
        theme: this.theme,
        excludeBottom: false
      }) {
        this.content();
      }
    }
    .width('100%')
    .height('100%')
  }
}

/**
 * 全屏沉浸式容器
 * 适用于视频播放器、游戏、图片查看器等
 */
@Component
export struct FullScreenContainer {
  hideSystemBars: boolean = false;
  @BuilderParam content: () => void = this.defaultContent;

  @Builder
  defaultContent() {}

  build() {
    Column() {
      ImmersiveContainer({
        fullScreen: true,
        hideSystemBars: this.hideSystemBars
      }) {
        this.content();
      }
    }
    .width('100%')
    .height('100%')
  }
}

/**
 * 深色主题沉浸式容器
 * 适用于深色背景页面
 */
@Component
export struct DarkImmersiveContainer {
  @BuilderParam content: () => void = this.defaultContent;

  @Builder
  defaultContent() {}

  build() {
    Column() {
      ImmersiveContainer({
        mode: ImmersiveMode.COMPONENT_TOP,
        theme: ThemeMode.DARK,
        excludeBottom: true,
        bgColor: '#1C1C1E'
      }) {
        this.content();
      }
    }
    .width('100%')
    .height('100%')
  }
}

/**
 * 浅色主题沉浸式容器
 * 适用于浅色背景页面
 */
@Component
export struct LightImmersiveContainer {
  @BuilderParam content: () => void = this.defaultContent;

  @Builder
  defaultContent() {}

  build() {
    Column() {
      ImmersiveContainer({
        mode: ImmersiveMode.COMPONENT_TOP,
        theme: ThemeMode.LIGHT,
        excludeBottom: true
      }) {
        this.content();
      }
    }
    .width('100%')
    .height('100%')
  }
}
