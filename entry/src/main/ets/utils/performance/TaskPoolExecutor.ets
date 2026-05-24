/**
 * TaskPoolExecutor - 任务池执行器
 * 用于提交耗时操作到任务池，避免阻塞UI线程
 */

import taskpool from '@ohos.taskpool';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 任务优先级
 */
export enum TaskPriority {
  LOW = 0,
  MEDIUM = 1,
  HIGH = 2,
  CRITICAL = 3
}

/**
 * 任务状态
 */
export enum TaskStatus {
  PENDING = 'pending',
  RUNNING = 'running',
  COMPLETED = 'completed',
  FAILED = 'failed',
  CANCELLED = 'cancelled'
}

/**
 * 任务结果
 */
interface TaskResult<T> {
  taskId: number;
  status: TaskStatus;
  result?: T;
  error?: Error;
  startTime: number;
  endTime?: number;
  duration?: number;
}

/**
 * 任务配置
 */
interface TaskConfig {
  priority: TaskPriority;
  timeout?: number;      // 超时时间（毫秒）
  retryTimes?: number;    // 重试次数
  retryDelay?: number;    // 重试延迟（毫秒）
}

/**
 * 任务函数
 */
type TaskFunc<T> = () => Promise<T>;

/**
 * 任务包装器
 */
class TaskWrapper<T> {
  taskId: number;
  taskFunc: TaskFunc<T>;
  config: Required<TaskConfig>;
  status: TaskStatus = TaskStatus.PENDING;
  startTime: number = 0;
  endTime: number = 0;
  retryCount: number = 0;
  timeoutTimer: number = -1;

  constructor(taskId: number, taskFunc: TaskFunc<T>, config: TaskConfig) {
    this.taskId = taskId;
    this.taskFunc = taskFunc;
    this.config = {
      priority: config.priority,
      timeout: config.timeout || 60000,      // 默认60秒
      retryTimes: config.retryTimes || 0,    // 默认不重试
      retryDelay: config.retryDelay || 1000   // 默认1秒
    };
  }

  /**
   * 执行任务
   */
  async execute(): Promise<TaskResult<T>> {
    this.status = TaskStatus.RUNNING;
    this.startTime = Date.now();

    // 设置超时
    let timeoutResolve: (value: TaskResult<T>) => void;
    const timeoutPromise = new Promise<TaskResult<T>>(resolve => {
      timeoutResolve = resolve;
      this.timeoutTimer = setTimeout(() => {
        this.status = TaskStatus.FAILED;
        resolve({
          taskId: this.taskId,
          status: TaskStatus.FAILED,
          error: new Error(`Task timeout after ${this.config.timeout}ms`),
          startTime: this.startTime,
          endTime: Date.now(),
          duration: Date.now() - this.startTime
        });
      }, this.config.timeout);
    });

    // 执行任务
    let lastError: Error | undefined;
    while (this.retryCount <= this.config.retryTimes) {
      try {
        const result = await this.taskFunc();
        
        // 清除超时
        clearTimeout(this.timeoutTimer);
        
        this.status = TaskStatus.COMPLETED;
        this.endTime = Date.now();

        const taskResult: TaskResult<T> = {
          taskId: this.taskId,
          status: TaskStatus.COMPLETED,
          result,
          startTime: this.startTime,
          endTime: this.endTime,
          duration: this.endTime - this.startTime
        };

        return taskResult;
      } catch (error) {
        lastError = error as Error;
        this.retryCount++;
        
        // 不是最后一次重试，延迟后继续
        if (this.retryCount <= this.config.retryTimes) {
          const delayPromise = new Promise<void>(resolve => {
            setTimeout(resolve, this.config.retryDelay);
          });
          await delayPromise;
        }
      }
    }

    // 重试次数用尽，返回失败
    clearTimeout(this.timeoutTimer);
    this.status = TaskStatus.FAILED;
    this.endTime = Date.now();

    return {
      taskId: this.taskId,
      status: TaskStatus.FAILED,
      error: lastError,
      startTime: this.startTime,
      endTime: this.endTime,
      duration: this.endTime - this.startTime
    };
  }

  /**
   * 取消任务
   */
  cancel(): void {
    if (this.status === TaskStatus.PENDING || this.status === TaskStatus.RUNNING) {
      this.status = TaskStatus.CANCELLED;
      clearTimeout(this.timeoutTimer);
    }
  }
}

/**
 * 任务池配置
 */
interface ExecutorConfig {
  maxConcurrentTasks: number;     // 最大并发任务数
  taskTimeout: number;            // 默认任务超时
  enableMetrics: boolean;         // 启用指标收集
  logLevel: 'none' | 'error' | 'info' | 'debug';
}

/**
 * 任务池状态接口
 */
interface ExecutorStatus {
  queueSize: number;
  runningCount: number;
  maxConcurrent: number;
}

/**
 * 任务池执行器
 */
export class TaskPoolExecutor {
  private static instance: TaskPoolExecutor;
  private config: ExecutorConfig;
  private taskQueue: TaskWrapper<Object>[] = [];
  private runningTasks: Map<number, TaskWrapper<Object>> = new Map();
  private taskIdCounter: number = 0;
  private isProcessing: boolean = false;
  private metrics: Map<string, number> = new Map();
  private taskResultCallbacks: Map<number, (result: TaskResult<Object>) => void> = new Map();

  private constructor() {
    this.config = {
      maxConcurrentTasks: 5,
      taskTimeout: 60000,
      enableMetrics: true,
      logLevel: 'error'
    };
  }

  /**
   * 获取单例实例
   */
  static getInstance(): TaskPoolExecutor {
    if (!TaskPoolExecutor.instance) {
      TaskPoolExecutor.instance = new TaskPoolExecutor();
    }
    return TaskPoolExecutor.instance;
  }

  /**
   * 配置执行器
   */
  configure(config: Partial<ExecutorConfig>): void {
    // 手动合并配置以避免使用 spread 操作符
    if (config.maxConcurrentTasks !== undefined) {
      this.config.maxConcurrentTasks = config.maxConcurrentTasks;
    }
    if (config.taskTimeout !== undefined) {
      this.config.taskTimeout = config.taskTimeout;
    }
    if (config.enableMetrics !== undefined) {
      this.config.enableMetrics = config.enableMetrics;
    }
    if (config.logLevel !== undefined) {
      this.config.logLevel = config.logLevel;
    }
  }

  /**
   * 执行任务
   */
  async execute<T>(taskFunc: TaskFunc<T>, config?: Partial<TaskConfig>): Promise<T> {
    const taskId = this.taskIdCounter++;
    
    const taskConfig: TaskConfig = {
      priority: config?.priority ?? TaskPriority.MEDIUM,
      timeout: config?.timeout ?? this.config.taskTimeout,
      retryTimes: config?.retryTimes ?? 0,
      retryDelay: config?.retryDelay ?? 1000
    };

    const wrapper = new TaskWrapper<T>(taskId, taskFunc, taskConfig);

    // 插入队列（按优先级排序）
    this.insertByPriority(wrapper as TaskWrapper<Object>);

    // 返回Promise
    return new Promise<T>((resolve, reject) => {
      this.taskResultCallbacks.set(taskId, (result: TaskResult<Object>) => {
        this.taskResultCallbacks.delete(taskId);
        
        if (result.status === TaskStatus.COMPLETED && result.result !== undefined) {
          resolve(result.result as T);
        } else {
          reject(result.error || new Error('Task failed'));
        }
      });

      // 开始处理队列
      this.processQueue();
    });
  }

  /**
   * 使用任务池执行函数
   */
  private async executeInPool<T>(taskFunc: TaskFunc<T>): Promise<T> {
    try {
      return await taskFunc();
    } catch (error) {
      const err = error as Error;
      hilog.error(0x0001, 'TaskPoolExecutor', `Execute in pool failed: ${err.message}`);
      throw new Error(err.message);
    }
  }

  /**
   * 批量执行任务
   */
  async executeBatch<T>(tasks: Array<TaskFunc<T>>, config?: Partial<TaskConfig>): Promise<T[]> {
    const promises = tasks.map(task => this.execute(task, config));
    return Promise.all(promises);
  }

  /**
   * 并发执行任务（限制并发数）
   */
  async executeConcurrent<T>(tasks: Array<TaskFunc<T>>, concurrency: number = 3, 
                            config?: Partial<TaskConfig>): Promise<T[]> {
    const results: T[] = [];
    
    for (let i = 0; i < tasks.length; i += concurrency) {
      const batch = tasks.slice(i, i + concurrency);
      const batchResults = await Promise.all(batch.map(task => this.execute(task, config)));
      results.push(...batchResults);
    }

    return results;
  }

  /**
   * 按优先级插入任务
   */
  private insertByPriority(wrapper: TaskWrapper<Object>): void {
    let insertIndex = this.taskQueue.length;
    
    for (let i = 0; i < this.taskQueue.length; i++) {
      if (wrapper.config.priority > this.taskQueue[i].config.priority) {
        insertIndex = i;
        break;
      }
    }

    this.taskQueue.splice(insertIndex, 0, wrapper);
  }

  /**
   * 处理任务队列
   */
  private async processQueue(): Promise<void> {
    if (this.isProcessing) {
      return;
    }

    this.isProcessing = true;

    while (this.taskQueue.length > 0 && 
           this.runningTasks.size < this.config.maxConcurrentTasks) {
      
      const wrapper = this.taskQueue.shift()!;
      this.runningTasks.set(wrapper.taskId, wrapper);

      // 执行任务
      wrapper.execute().then((result: TaskResult<Object>) => {
        this.handleTaskResult(wrapper, result);
      });
    }

    this.isProcessing = false;
  }

  /**
   * 处理任务结果
   */
  private handleTaskResult(wrapper: TaskWrapper<Object>, result: TaskResult<Object>): void {
    // 从运行列表移除
    this.runningTasks.delete(wrapper.taskId);

    // 记录指标
    if (this.config.enableMetrics) {
      this.recordMetrics(result);
    }

    // 记录日志
    this.logResult(result);

    // 触发回调
    const callback = this.taskResultCallbacks.get(wrapper.taskId);
    if (callback) {
      callback(result);
    }

    // 继续处理队列
    this.processQueue();
  }

  /**
   * 记录指标
   */
  private recordMetrics(result: TaskResult<Object>): void {
    const statusKey = `task_${result.status}`;
    this.metrics.set(statusKey, (this.metrics.get(statusKey) || 0) + 1);

    if (result.duration !== undefined) {
      const avgDuration = this.metrics.get('avg_duration') || 0;
      const count = this.metrics.get('task_count') || 0;
      const newAvg = (avgDuration * count + result.duration) / (count + 1);
      this.metrics.set('avg_duration', newAvg);
      this.metrics.set('task_count', count + 1);
    }
  }

  /**
   * 记录日志
   */
  private logResult(result: TaskResult<Object>): void {
    if (this.config.logLevel === 'none') {
      return;
    }

    const message = `[TaskPoolExecutor] Task ${result.taskId}: ${result.status}`;
    
    if (result.status === TaskStatus.FAILED) {
      if (this.config.logLevel === 'error' || this.config.logLevel === 'info' || 
          this.config.logLevel === 'debug') {
        hilog.error(0x0001, 'TaskPoolExecutor', message);
      }
    } else if (this.config.logLevel === 'debug') {
      hilog.debug(0x0001, 'TaskPoolExecutor', `${message} duration: ${result.duration}ms`);
    }
  }

  /**
   * 获取指标
   */
  getMetrics(): Record<string, number> {
    const result: Record<string, number> = {};
    this.metrics.forEach((value: number, key: string) => {
      result[key] = value;
    });
    return result;
  }

  /**
   * 清空指标
   */
  clearMetrics(): void {
    this.metrics.clear();
  }

  /**
   * 取消所有任务
   */
  async cancelAll(): Promise<void> {
    // 取消运行中的任务
    for (const wrapper of this.runningTasks.values()) {
      wrapper.cancel();
    }

    // 清空队列
    this.taskQueue = [];
    this.runningTasks.clear();
    this.taskResultCallbacks.clear();
  }

  /**
   * 获取当前状态
   */
  getStatus(): ExecutorStatus {
    return {
      queueSize: this.taskQueue.length,
      runningCount: this.runningTasks.size,
      maxConcurrent: this.config.maxConcurrentTasks
    };
  }
}

/**
 * 便捷函数 - 执行单个任务
 */
export async function executeTask<T>(taskFunc: TaskFunc<T>, 
                                   config?: Partial<TaskConfig>): Promise<T> {
  const executor = TaskPoolExecutor.getInstance();
  return executor.execute(taskFunc, config);
}

/**
 * 便捷函数 - 批量执行任务
 */
export async function executeBatch<T>(tasks: Array<TaskFunc<T>>, 
                                    config?: Partial<TaskConfig>): Promise<T[]> {
  const executor = TaskPoolExecutor.getInstance();
  return executor.executeBatch(tasks, config);
}

/**
 * 便捷函数 - 并发执行任务
 */
export async function executeConcurrent<T>(tasks: Array<TaskFunc<T>>, 
                                         concurrency: number = 3,
                                         config?: Partial<TaskConfig>): Promise<T[]> {
  const executor = TaskPoolExecutor.getInstance();
  return executor.executeConcurrent(tasks, concurrency, config);
}
