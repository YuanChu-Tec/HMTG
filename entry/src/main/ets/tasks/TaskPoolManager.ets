/**
 * TaskPool 管理器 - 华为 HarmonyOS 最佳实践
 * 统一管理所有 TaskPool 任务，提供便捷的任务提交接口
 * 
 * 核心功能:
 * 1. 任务提交与执行
 * 2. 任务取消与清理
 * 3. 并发控制
 * 4. 性能统计
 */
import { taskpool } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'TaskPoolManager';
const DOMAIN = 0x0001;

/**
 * 任务执行结果封装
 */
export interface TaskResult<T = object> {
  success: boolean;
  data?: T;
  error?: string;
  executeTime?: number; // 执行耗时 (ms)
}

/**
 * 任务统计信息
 */
export interface TaskStats {
  totalTasks: number;      // 总任务数
  completedTasks: number;  // 已完成任务数
  failedTasks: number;     // 失败任务数
  averageExecuteTime: number; // 平均执行时间 (ms)
}

/**
 * TaskPool 管理器单例
 */
export class TaskPoolManager {
  private static instance: TaskPoolManager;
  
  /** 正在执行的任务映射 */
  private runningTasks: Map<string, taskpool.Task> = new Map();
  
  /** 任务统计信息 */
  private stats: TaskStats = {
    totalTasks: 0,
    completedTasks: 0,
    failedTasks: 0,
    averageExecuteTime: 0
  };
  
  /** 累计执行时间（用于计算平均值） */
  private totalExecuteTime: number = 0;
  
  /** 最大并发任务数 */
  private readonly MAX_CONCURRENT_TASKS: number = 4;
  
  private constructor() {
    hilog.info(DOMAIN, TAG, 'TaskPoolManager 初始化完成');
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): TaskPoolManager {
    if (!TaskPoolManager.instance) {
      TaskPoolManager.instance = new TaskPoolManager();
    }
    return TaskPoolManager.instance;
  }
  
  /**
   * 执行任务
   * @param task 任务对象
   * @param transfer 可转移的 ArrayBuffer 列表
   * @returns Promise<TaskResult>
   */
  public async execute<T>(
    task: taskpool.Task,
    transfer?: ArrayBuffer[]
  ): Promise<TaskResult<T>> {
    const taskId = `${task.taskId}_${Date.now()}`;
    
    this.stats.totalTasks++;
    this.runningTasks.set(taskId, task);
    
    hilog.debug(DOMAIN, TAG, `开始执行任务：${taskId}`);
    
    try {
      // 检查并发数
      if (this.runningTasks.size > this.MAX_CONCURRENT_TASKS) {
        hilog.warn(DOMAIN, TAG, `并发任务数超过上限：${this.runningTasks.size}`);
      }
      
      // 执行任务
      const result = await taskpool.execute(task) as T;
      
      this.updateStats(true, 0);
      
      hilog.debug(DOMAIN, TAG, `任务完成：${taskId}`);
      
      return {
        success: true,
        data: result,
        executeTime: 0
      };
    } catch (error) {
      this.updateStats(false, 0);
      
      hilog.error(DOMAIN, TAG, `任务失败：${taskId}, 错误：${JSON.stringify(error)}`);
      
      return {
        success: false,
        error: error instanceof Error ? error.message : JSON.stringify(error),
        executeTime: 0
      };
    } finally {
      this.runningTasks.delete(taskId);
    }
  }
  
  /**
   * 取消任务
   * @param taskId 任务 ID
   * @returns 是否成功取消
   */
  public cancel(taskId: string): boolean {
    const task = this.runningTasks.get(taskId);
    if (task) {
      try {
        taskpool.cancel(task);
        this.runningTasks.delete(taskId);
        hilog.info(DOMAIN, TAG, `任务已取消：${taskId}`);
        return true;
      } catch (error) {
        hilog.error(DOMAIN, TAG, `取消任务失败：${taskId}, 错误：${JSON.stringify(error)}`);
        return false;
      }
    }
    return false;
  }
  
  /**
   * 清空所有任务
   */
  public clear(): void {
    hilog.info(DOMAIN, TAG, '清空所有任务');
    
    this.runningTasks.forEach((task, taskId) => {
      try {
        taskpool.cancel(task);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `取消任务失败：${taskId}`);
      }
    });
    
    this.runningTasks.clear();
  }
  
  /**
   * 更新统计信息
   */
  private updateStats(success: boolean, executeTime: number): void {
    if (success) {
      this.stats.completedTasks++;
    } else {
      this.stats.failedTasks++;
    }
    
    this.totalExecuteTime += executeTime;
    this.stats.averageExecuteTime = this.totalExecuteTime / this.stats.totalTasks;
  }
  
  /**
   * 获取统计信息
   */
  public getStats(): TaskStats {
    return {
      totalTasks: this.stats.totalTasks,
      completedTasks: this.stats.completedTasks,
      failedTasks: this.stats.failedTasks,
      averageExecuteTime: this.stats.averageExecuteTime
    };
  }
  
  /**
   * 获取运行中的任务数
   */
  public getRunningTaskCount(): number {
    return this.runningTasks.size;
  }
  
  /**
   * 销毁管理器
   */
  public destroy(): void {
    hilog.info(DOMAIN, TAG, '销毁 TaskPoolManager');
    this.clear();
    this.stats = {
      totalTasks: 0,
      completedTasks: 0,
      failedTasks: 0,
      averageExecuteTime: 0
    };
    this.totalExecuteTime = 0;
  }
}
