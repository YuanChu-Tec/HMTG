import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'MemoryMonitor';
const DOMAIN = 0x0001;

/**
 * 内存信息
 */
export interface MemoryInfo {
  used: number;
  total: number;
  percentage: number;
  timestamp: number;
}

/**
 * 内存监控器
 */
export class MemoryMonitor {
  private static instance: MemoryMonitor;
  private history: MemoryInfo[] = [];
  private maxHistory: number = 100;
  private warningThreshold: number = 0.8;
  private criticalThreshold: number = 0.9;
  private listeners: Set<(info: MemoryInfo) => void> = new Set();

  private constructor() {}

  public static getInstance(): MemoryMonitor {
    if (!MemoryMonitor.instance) {
      MemoryMonitor.instance = new MemoryMonitor();
    }
    return MemoryMonitor.instance;
  }

  /**
   * 获取当前内存信息
   */
  public getMemoryInfo(): MemoryInfo {
    // 简化实现，实际应调用系统API
    const total = 8 * 1024 * 1024 * 1024; // 8GB
    const used = Math.floor(Math.random() * (total * 0.7));
    const percentage = used / total;

    const info: MemoryInfo = {
      used,
      total,
      percentage,
      timestamp: Date.now()
    };

    return info;
  }

  /**
   * 开始监控
   */
  public startMonitoring(interval: number = 5000): void {
    setInterval(() => {
      const info = this.getMemoryInfo();
      this.recordMemory(info);
    }, interval);
  }

  /**
   * 记录内存信息
   */
  public recordMemory(info: MemoryInfo): void {
    this.history.push(info);
    
    // 限制历史记录数量
    if (this.history.length > this.maxHistory) {
      this.history.shift();
    }

    // 检查阈值
    if (info.percentage >= this.criticalThreshold) {
      hilog.error(DOMAIN, TAG, `Critical memory usage: ${(info.percentage * 100).toFixed(2)}%`);
    } else if (info.percentage >= this.warningThreshold) {
      hilog.warn(DOMAIN, TAG, `High memory usage: ${(info.percentage * 100).toFixed(2)}%`);
    }

    // 通知监听器
    this.notifyListeners(info);
  }

  /**
   * 获取内存历史
   */
  public getHistory(): MemoryInfo[] {
    return [...this.history];
  }

  /**
   * 获取内存统计信息
   */
  public getStats(): MemoryStats {
    if (this.history.length === 0) {
      return {
        min: 0,
        max: 0,
        avg: 0,
        current: 0,
        unit: 'bytes'
      };
    }

    const values = this.history.map(m => m.used);
    const sum = values.reduce((a, b) => a + b, 0);
    const min = Math.min(...values);
    const max = Math.max(...values);
    const avg = sum / values.length;
    const current = this.history[this.history.length - 1].used;

    return {
      min,
      max,
      avg,
      current,
      unit: 'bytes'
    };
  }

  /**
   * 添加监听器
   */
  public addListener(listener: (info: MemoryInfo) => void): void {
    this.listeners.add(listener);
  }

  /**
   * 移除监听器
   */
  public removeListener(listener: (info: MemoryInfo) => void): void {
    this.listeners.delete(listener);
  }

  /**
   * 通知监听器
   */
  private notifyListeners(info: MemoryInfo): void {
    this.listeners.forEach(listener => {
      try {
        listener(info);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Listener error: ${error}`);
      }
    });
  }

  /**
   * 设置警告阈值
   */
  public setWarningThreshold(threshold: number): void {
    this.warningThreshold = Math.max(0, Math.min(1, threshold));
  }

  /**
   * 设置严重阈值
   */
  public setCriticalThreshold(threshold: number): void {
    this.criticalThreshold = Math.max(0, Math.min(1, threshold));
  }

  /**
   * 清除历史记录
   */
  public clearHistory(): void {
    this.history = [];
  }

  /**
   * 格式化内存大小
   */
  public static formatSize(bytes: number): string {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    let index = 0;
    let size = bytes;

    while (size >= 1024 && index < units.length - 1) {
      size /= 1024;
      index++;
    }

    return `${size.toFixed(2)} ${units[index]}`;
  }
}

/**
 * 内存统计信息
 */
export interface MemoryStats {
  min: number;
  max: number;
  avg: number;
  current: number;
  unit: string;
}
