import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'LogProfiler';
const DOMAIN = 0x0001;

/**
 * 日志级别
 */
export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3
}

/**
 * 日志记录
 */
export interface LogRecord {
  timestamp: number;
  level: LogLevel;
  tag: string;
  message: string;
  context?: Record<string, Object>;
}

/**
 * 日志分析器
 */
export class LogProfiler {
  private static instance: LogProfiler;
  private logs: LogRecord[] = [];
  private maxLogs: number = 1000;
  private enabled: boolean = true;
  private minLevel: LogLevel = LogLevel.DEBUG;

  private constructor() {}

  public static getInstance(): LogProfiler {
    if (!LogProfiler.instance) {
      LogProfiler.instance = new LogProfiler();
    }
    return LogProfiler.instance;
  }

  /**
   * 记录日志
   */
  public log(level: LogLevel, tag: string, message: string, context?: Record<string, Object>): void {
    if (!this.enabled || level < this.minLevel) {
      return;
    }

    const record: LogRecord = {
      timestamp: Date.now(),
      level,
      tag,
      message,
      context
    };

    this.logs.push(record);
    
    // 限制日志数量
    if (this.logs.length > this.maxLogs) {
      this.logs.shift();
    }

    // 输出到控制台
    this.outputToConsole(record);
  }

  /**
   * 输出到控制台
   */
  private outputToConsole(record: LogRecord): void {
    const levelNames = ['DEBUG', 'INFO', 'WARN', 'ERROR'];
    const levelName = levelNames[record.level];
    const contextStr = record.context ? ` ${JSON.stringify(record.context)}` : '';
    const logMessage = `[${levelName}][${record.tag}] ${record.message}${contextStr}`;

    switch (record.level) {
      case LogLevel.DEBUG:
        hilog.debug(DOMAIN, record.tag, logMessage);
        break;
      case LogLevel.INFO:
        hilog.info(DOMAIN, record.tag, logMessage);
        break;
      case LogLevel.WARN:
        hilog.warn(DOMAIN, record.tag, logMessage);
        break;
      case LogLevel.ERROR:
        hilog.error(DOMAIN, record.tag, logMessage);
        break;
    }
  }

  /**
   * 调试日志
   */
  public debug(tag: string, message: string, context?: Record<string, Object>): void {
    this.log(LogLevel.DEBUG, tag, message, context);
  }

  /**
   * 信息日志
   */
  public info(tag: string, message: string, context?: Record<string, Object>): void {
    this.log(LogLevel.INFO, tag, message, context);
  }

  /**
   * 警告日志
   */
  public warn(tag: string, message: string, context?: Record<string, Object>): void {
    this.log(LogLevel.WARN, tag, message, context);
  }

  /**
   * 错误日志
   */
  public error(tag: string, message: string, context?: Record<string, Object>): void {
    this.log(LogLevel.ERROR, tag, message, context);
  }

  /**
   * 获取所有日志
   */
  public getLogs(): LogRecord[] {
    return [...this.logs];
  }

  /**
   * 按标签过滤日志
   */
  public getLogsByTag(tag: string): LogRecord[] {
    return this.logs.filter(log => log.tag === tag);
  }

  /**
   * 按级别过滤日志
   */
  public getLogsByLevel(level: LogLevel): LogRecord[] {
    return this.logs.filter(log => log.level >= level);
  }

  /**
   * 按时间范围过滤日志
   */
  public getLogsByTimeRange(startTime: number, endTime: number): LogRecord[] {
    return this.logs.filter(log => log.timestamp >= startTime && log.timestamp <= endTime);
  }

  /**
   * 获取日志统计信息
   */
  public getStats(): LogStats {
    const stats: LogStats = {
      total: this.logs.length,
      debug: 0,
      info: 0,
      warn: 0,
      error: 0,
      tags: new Map<string, number>()
    };

    this.logs.forEach(log => {
      switch (log.level) {
        case LogLevel.DEBUG:
          stats.debug++;
          break;
        case LogLevel.INFO:
          stats.info++;
          break;
        case LogLevel.WARN:
          stats.warn++;
          break;
        case LogLevel.ERROR:
          stats.error++;
          break;
      }

      const count = stats.tags.get(log.tag) || 0;
      stats.tags.set(log.tag, count + 1);
    });

    return stats;
  }

  /**
   * 导出日志
   */
  public exportLogs(): string {
    return JSON.stringify(this.logs, null, 2);
  }

  /**
   * 清除所有日志
   */
  public clearLogs(): void {
    this.logs = [];
  }

  /**
   * 设置最大日志数量
   */
  public setMaxLogs(max: number): void {
    this.maxLogs = max;
  }

  /**
   * 设置最小日志级别
   */
  public setMinLevel(level: LogLevel): void {
    this.minLevel = level;
  }

  /**
   * 设置是否启用
   */
  public setEnabled(enabled: boolean): void {
    this.enabled = enabled;
  }
}

/**
 * 日志统计信息
 */
export interface LogStats {
  total: number;
  debug: number;
  info: number;
  warn: number;
  error: number;
  tags: Map<string, number>;
}
