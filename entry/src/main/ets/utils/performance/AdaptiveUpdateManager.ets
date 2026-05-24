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
 * See the License for specific language governing permissions and
 * limitations under the License.
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { EventBus, eventBus } from '../event/EventBus';
import { PerformanceMonitor, PerformanceMetrics } from './PerformanceMonitor';

/**
 * 基础间隔配置
 */
interface BaseIntervals {
  chatAction: number;
  typingIndicator: number;
  onlineStatus: number;
  lastMessage: number;
  messageEdit: number;
}

/**
 * 模式倍数配置
 */
interface ModeMultipliers {
  HIGH: number;
  NORMAL: number;
  SAVE_POWER: number;
}

/**
 * 缓存策略
 */
interface CacheStrategy {
  enabled: boolean;
  maxSize: number;
  ttl: number;
}

/**
 * 图片加载策略
 */
interface ImageLoadStrategy {
  preloadEnabled: boolean;
  thumbnailOnly: boolean;
  maxConcurrent: number;
}

/**
 * 性能模式
 */
export enum PerformanceMode {
  HIGH = 'HIGH',           // 高性能模式
  NORMAL = 'NORMAL',       // 普通模式
  SAVE_POWER = 'SAVE_POWER' // 省电模式
}

/**
 * AdaptiveUpdateManager - 自适应更新管理器
 * 
 * 功能特性:
 * 1. 根据性能指标自动调整更新策略
 * 2. 多级性能降级
 * 3. 智能调度
 * 4. 性能模式切换
 * 5. 更新间隔动态调整
 */
export class AdaptiveUpdateManager {
  private static instance: AdaptiveUpdateManager;
  private mode: PerformanceMode = PerformanceMode.NORMAL;

  // 性能阈值
  private readonly FPS_HIGH_THRESHOLD = 55;  // 高性能FPS阈值
  private readonly FPS_LOW_THRESHOLD = 45;   // 低性能FPS阈值
  private readonly CPU_HIGH_THRESHOLD = 80;  // CPU使用率高阈值

  // 基础更新间隔（毫秒）
  private readonly BASE_INTERVALS: BaseIntervals = {
    chatAction: 500,        // 聊天动作聚合间隔
    typingIndicator: 300,   // 输入指示器更新间隔
    onlineStatus: 60000,    // 在线状态更新间隔
    lastMessage: 100,       // 最后消息更新间隔
    messageEdit: 300        // 消息编辑防抖间隔
  };

  // 模式倍数
  private readonly MODE_MULTIPLIERS: Record<PerformanceMode, number> = {
    [PerformanceMode.SAVE_POWER]: 3,
    [PerformanceMode.NORMAL]: 1,
    [PerformanceMode.HIGH]: 0.7
  };

  private constructor() {
    // 定期检查性能并调整模式
    setInterval(() => {
      this.autoAdjustMode();
    }, 5000); // 每5秒检查一次
  }

  /**
   * 单例模式
   */
  public static getInstance(): AdaptiveUpdateManager {
    if (!AdaptiveUpdateManager.instance) {
      AdaptiveUpdateManager.instance = new AdaptiveUpdateManager();
    }
    return AdaptiveUpdateManager.instance;
  }

  /**
   * 根据性能指标调整模式
   * @param fps 当前帧率
   * @param cpuUsage CPU使用率（0-100）
   */
  public adjustBasedOnMetrics(fps: number, cpuUsage: number): void {
    const oldMode = this.mode;

    if (fps < this.FPS_LOW_THRESHOLD || cpuUsage > this.CPU_HIGH_THRESHOLD) {
      // 严重负载：切换到省电模式
      this.mode = PerformanceMode.SAVE_POWER;
      hilog.info(0x0001, 'AdaptiveUpdateManager',
        `Mode changed to SAVE_POWER (fps: ${fps.toFixed(1)}, cpu: ${cpuUsage.toFixed(1)}%)`);
    } else if (fps < this.FPS_HIGH_THRESHOLD) {
      this.mode = PerformanceMode.NORMAL;
    } else {
      this.mode = PerformanceMode.HIGH;
    }

    // 如果模式发生变化，通知相关组件
    if (oldMode !== this.mode) {
      this.notifyModeChanged(oldMode, this.mode);
    }
  }

  /**
   * 获取更新间隔
   * @param updateType 更新类型
   * @returns 更新间隔（毫秒）
   */
  public getUpdateInterval(updateType: string): number {
    let baseInterval = 1000;
    if (updateType === 'chatAction') {
      baseInterval = this.BASE_INTERVALS.chatAction;
    } else if (updateType === 'typingIndicator') {
      baseInterval = this.BASE_INTERVALS.typingIndicator;
    } else if (updateType === 'onlineStatus') {
      baseInterval = this.BASE_INTERVALS.onlineStatus;
    } else if (updateType === 'lastMessage') {
      baseInterval = this.BASE_INTERVALS.lastMessage;
    } else if (updateType === 'messageEdit') {
      baseInterval = this.BASE_INTERVALS.messageEdit;
    }
    const multiplier = this.MODE_MULTIPLIERS[this.mode];

    return baseInterval * multiplier;
  }

  /**
   * 获取当前性能模式
   */
  public getCurrentMode(): PerformanceMode {
    return this.mode;
  }

  /**
   * 手动设置性能模式
   * @param mode 性能模式
   */
  public setMode(mode: PerformanceMode): void {
    const oldMode = this.mode;
    this.mode = mode;

    hilog.info(0x0001, 'AdaptiveUpdateManager', `Mode manually changed from ${oldMode} to ${mode}`);

    this.notifyModeChanged(oldMode, this.mode);
  }

  /**
   * 自动调整模式
   */
  private autoAdjustMode(): void {
    try {
      // 从PerformanceMonitor获取真实的fps和cpuUsage
      const perfMonitor = PerformanceMonitor.getInstance();
      const metrics = perfMonitor.getMetrics();

      // 获取FPS（从性能指标中计算）
      const fps = this.calculateFpsFromMetrics(metrics);

      // 获取CPU使用率（从性能指标中获取或估算）
      const cpuUsage = this.calculateCpuUsageFromMetrics(metrics);

      this.adjustBasedOnMetrics(fps, cpuUsage);
    } catch (error) {
      hilog.error(0x0001, 'AdaptiveUpdateManager', `Failed to adjust mode: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 从性能指标计算FPS
   */
  private calculateFpsFromMetrics(metrics: PerformanceMetrics): number {
    try {
      // 直接使用metrics中的FPS值
      if (metrics.fps > 0 && metrics.fps <= 120) {
        return metrics.fps;
      }

      // 如果FPS无效，从avgFrameTime计算
      if (metrics.avgFrameTime > 0) {
        const calculatedFps = 1000 / metrics.avgFrameTime;
        return Math.min(calculatedFps, 60); // 最大60fps
      }

      // 默认值
      return 60;
    } catch (error) {
      return 60; // 默认值
    }
  }

  /**
   * 从性能指标计算CPU使用率
   */
  private calculateCpuUsageFromMetrics(metrics: PerformanceMetrics): number {
    try {
      // 从内存使用率估算CPU使用率（高内存使用通常伴随着高CPU使用）
      const memoryUsageValue: number = metrics.memoryUsage ?? 0;

      // 从活跃追踪数估算CPU负载
      const activeTracesValue: number = metrics.activeTraces ?? 0;
      const traceLoadValue = activeTracesValue * 5;
      const traceLoad = Math.min(traceLoadValue, 50); // 最多50%影响

      // 从平均帧时间估算CPU使用（帧时间越长，CPU越忙）
      let frameTimeImpact = 0;
      const avgFrameTimeValue: number = metrics.avgFrameTime ?? 0;
      if (avgFrameTimeValue > 0) {
        // 如果帧时间超过16ms（60fps），每增加1ms增加2%的CPU使用估算
        const excessFrameTime = Math.max(0, avgFrameTimeValue - 16);
        const frameTimeImpactValue = excessFrameTime * 2;
        frameTimeImpact = Math.min(frameTimeImpactValue, 30); // 最多30%影响
      }

      // 综合计算
      const baseCpuUsage = 20; // 基础CPU使用率
      const memoryImpact = memoryUsageValue * 40; // 内存影响最多40%
      const totalCpuUsage = baseCpuUsage + memoryImpact + traceLoad + frameTimeImpact;

      return Math.min(totalCpuUsage, 100); // 最大100%
    } catch (error) {
      return 50; // 默认值
    }
  }

  /**
   * 通知模式变化
   */
  private notifyModeChanged(oldMode: PerformanceMode, newMode: PerformanceMode): void {
    // 通过EventBus通知相关组件
    try {
      interface ModeChangedEvent {
        oldMode: PerformanceMode;
        newMode: PerformanceMode;
        timestamp: number;
      }
      const event: ModeChangedEvent = {
        oldMode,
        newMode,
        timestamp: Date.now()
      } as ModeChangedEvent;
      eventBus.emit('performanceModeChanged', event);
    } catch (error) {
      hilog.warn(0x0001, 'AdaptiveUpdateManager',
        `Failed to emit performanceModeChanged event: ${JSON.stringify(error)}`);
    }

    // 记录日志
    hilog.info(0x0001, 'AdaptiveUpdateManager',
      `Performance mode changed: ${oldMode} -> ${newMode}`);
  }

  /**
   * 检查是否应该跳过更新
   * @param updateType 更新类型
   * @returns 是否跳过
   */
  public shouldSkipUpdate(updateType: string): boolean {
    // 在省电模式下，跳过某些非关键更新
    if (this.mode === PerformanceMode.SAVE_POWER) {
      const skipInLowPower = [
        'chatAction',      // 聊天动作（正在输入等）
        'onlineStatus',    // 在线状态
        'messageEdit'      // 消息编辑
      ];

      return skipInLowPower.includes(updateType);
    }

    return false;
  }

  /**
   * 获取缓存策略
   * @returns 缓存策略配置
   */
  public getCacheStrategy(): CacheStrategy {
    const highStrategy: CacheStrategy = {
      enabled: true,
      maxSize: 100,
      ttl: 60000
    };
    const normalStrategy: CacheStrategy = {
      enabled: true,
      maxSize: 50,
      ttl: 120000
    };
    const savePowerStrategy: CacheStrategy = {
      enabled: true,
      maxSize: 30,
      ttl: 300000
    };

    const strategies: Record<PerformanceMode, CacheStrategy> = {
      [PerformanceMode.HIGH]: highStrategy,
      [PerformanceMode.NORMAL]: normalStrategy,
      [PerformanceMode.SAVE_POWER]: savePowerStrategy
    };

    return strategies[this.mode];
  }

  /**
   * 获取图片加载策略
   * @returns 图片加载策略
   */
  public getImageLoadStrategy(): ImageLoadStrategy {
    const highStrategy: ImageLoadStrategy = {
      preloadEnabled: true,
      thumbnailOnly: false,
      maxConcurrent: 5
    };
    const normalStrategy: ImageLoadStrategy = {
      preloadEnabled: true,
      thumbnailOnly: false,
      maxConcurrent: 3
    };
    const savePowerStrategy: ImageLoadStrategy = {
      preloadEnabled: false,
      thumbnailOnly: true,
      maxConcurrent: 1
    };

    const strategies: Record<PerformanceMode, ImageLoadStrategy> = {
      [PerformanceMode.HIGH]: highStrategy,
      [PerformanceMode.NORMAL]: normalStrategy,
      [PerformanceMode.SAVE_POWER]: savePowerStrategy
    };

    return strategies[this.mode];
  }

  /**
   * 清理资源
   */
  public cleanup(): void {
    this.mode = PerformanceMode.NORMAL;
    hilog.info(0x0001, 'AdaptiveUpdateManager', 'AdaptiveUpdateManager cleanup');
  }
}

export default AdaptiveUpdateManager;
