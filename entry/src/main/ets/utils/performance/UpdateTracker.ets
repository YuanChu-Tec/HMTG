/**
 * 更新跟踪器 - 用于追踪和监控更新操作的性能
 */

/**
 * 更新状态接口
 */
interface UpdateState {
  pending: number;
  inProgress: number;
  completed: number;
  failed: number;
}

/**
 * 跟踪数据接口
 */
interface TrackingData {
  timestamp: number;
  component: string;
  duration: number;
  success: boolean;
}

/**
 * 慢操作接口
 */
interface SlowOperation {
  operation: string;
  averageTime: number;
}

/**
 * UpdateTracker - 更新操作跟踪器
 * 
 * 功能特性：
 * 1. 跟踪更新操作耗时
 * 2. 计算平均耗时
 * 3. 识别慢操作
 * 4. 性能监控
 */
export class UpdateTracker {
  private static instance: UpdateTracker;
  private updateTimings: Map<string, number[]> = new Map();
  private readonly MAX_TIMINGS_PER_OPERATION = 100;

  private constructor() {}

  /**
   * 单例模式
   */
  static getInstance(): UpdateTracker {
    if (!UpdateTracker.instance) {
      UpdateTracker.instance = new UpdateTracker();
    }
    return UpdateTracker.instance;
  }

  /**
   * 测量同步操作耗时
   */
  static measureUpdate<T>(operation: () => T, operationName: string): T {
    const startTime = Date.now();
    const result = operation();
    const endTime = Date.now();

    const duration = endTime - startTime;
    UpdateTracker.getInstance().recordTiming(operationName, duration);

    if (duration > 300) { // 消息发送延迟阈值
      console.warn('UpdateTracker', `${operationName} 耗时过长: ${duration}ms`);
    }

    return result;
  }

  /**
   * 记录操作耗时
   */
  private recordTiming(operationName: string, duration: number): void {
    if (!this.updateTimings.has(operationName)) {
      this.updateTimings.set(operationName, []);
    }

    const timings = this.updateTimings.get(operationName)!;
    timings.push(duration);

    // 保持最近100次记录
    if (timings.length > 100) {
      timings.shift();
    }
  }

  /**
   * 跟踪更新操作
   */
  trackUpdate(operationName: string, duration: number): void {
    if (!this.updateTimings.has(operationName)) {
      this.updateTimings.set(operationName, []);
    }

    const timings = this.updateTimings.get(operationName)!;
    timings.push(duration);

    if (timings.length > this.MAX_TIMINGS_PER_OPERATION) {
      timings.shift();
    }
  }

  /**
   * 获取平均耗时
   */
  getAverageTiming(operationName: string): number {
    const timings = this.updateTimings.get(operationName);
    if (!timings || timings.length === 0) return 0;

    let sum = 0;
    for (let i = 0; i < timings.length; i++) {
      sum += timings[i];
    }
    return sum / timings.length;
  }

  /**
   * 获取慢操作列表
   * @param threshold 慢操作阈值（毫秒），默认300ms
   * @returns 慢操作数组，按平均耗时降序排列
   */
  getSlowOperations(threshold: number = 300): SlowOperation[] {
    const slowOps: SlowOperation[] = [];

    const entries = Array.from(this.updateTimings.entries());
    for (let i = 0; i < entries.length; i++) {
      const entry = entries[i];
      const operation = entry[0] as string;
      const timings = entry[1];
      const avgTime = this.getAverageTiming(operation);
      if (avgTime > threshold) {
        const slowOp: SlowOperation = { operation, averageTime: avgTime };
        slowOps.push(slowOp);
      }
    }

    return slowOps.sort((a, b) => b.averageTime - a.averageTime);
  }

  /**
   * 清理跟踪数据
   */
  clearTimings(): void {
    this.updateTimings.clear();
  }

  /**
   * 获取所有跟踪的操作名称
   */
  getAllOperationNames(): string[] {
    return Array.from(this.updateTimings.keys());
  }
}

export default UpdateTracker;
