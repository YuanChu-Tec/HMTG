/**
 * 日志服务 - 基于EventBus实现
 * 
 * 功能描述:
 * - 统一的日志记录接口
 * - 支持日志级别过滤
 * - 支持日志导出功能
 * - 支持日志查询功能
 * - 集成EventBus进行日志事件发布
 * 
 * @module library/utils/src/main/ets/log/LogService
 * @since API 20
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { fileIo } from '@kit.CoreFileKit';
import { preferences } from '@kit.ArkData';
import { eventBus, AppEvents } from '../event/EventBus';

/**
 * 日志级别
 */
export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3,
  FATAL = 4
}

/**
 * 日志配置
 */
export interface LogConfig {
  /** 最小日志级别 */
  minLevel?: LogLevel;
  /** 是否启用控制台输出 */
  enableConsole?: boolean;
  /** 是否启用文件输出 */
  enableFile?: boolean;
  /** 日志文件路径 */
  logFilePath?: string;
  /** 最大日志文件大小（字节） */
  maxFileSize?: number;
  /** 日志保留天数 */
  retentionDays?: number;
}

/**
 * 日志记录接口
 */
export interface LogRecord {
  timestamp: number;
  level: LogLevel;
  domain: number;
  tag: string;
  message: string;
  data: Object | undefined;
}

/**
 * 日志查询选项
 */
export interface LogQueryOptions {
  /** 开始时间戳 */
  startTime?: number;
  /** 结束时间戳 */
  endTime?: number;
  /** 最小日志级别 */
  minLevel?: LogLevel;
  /** 域名过滤 */
  domain?: number;
  /** 标签过滤 */
  tag?: string;
  /** 最大返回数量 */
  limit?: number;
}

/**
 * 日志服务（单例模式）
 */
export class LogService {
  private static instance: LogService;
  private readonly TAG: string = 'LogService';
  private readonly DOMAIN: number = 0x0001;
  private static readonly DEFAULT_DOMAIN: number = 0x0001;

  private config: LogConfig;
  private logBuffer: LogRecord[] = [];
  private maxBufferSize: number = 1000;

  private constructor(config?: LogConfig) {
    const defaultConfig: LogConfig = new Object() as LogConfig;
    defaultConfig.minLevel = LogLevel.DEBUG;
    defaultConfig.enableConsole = true;
    defaultConfig.enableFile = false;
    defaultConfig.maxFileSize = 10 * 1024 * 1024; // 10MB
    defaultConfig.retentionDays = 7;
    this.config = defaultConfig;

    if (config) {
      if (config.minLevel !== undefined) {
        this.config.minLevel = config.minLevel;
      }
      if (config.enableConsole !== undefined) {
        this.config.enableConsole = config.enableConsole;
      }
      if (config.enableFile !== undefined) {
        this.config.enableFile = config.enableFile;
      }
      if (config.logFilePath !== undefined) {
        this.config.logFilePath = config.logFilePath;
      }
      if (config.maxFileSize !== undefined) {
        this.config.maxFileSize = config.maxFileSize;
      }
      if (config.retentionDays !== undefined) {
        this.config.retentionDays = config.retentionDays;
      }
    }

    this.initialize();

    hilog.info(this.DOMAIN, this.TAG, 'LogService initialized');
  }

  /**
   * 获取LogService单例
   */
  public static getInstance(config?: LogConfig): LogService {
    if (!LogService.instance) {
      LogService.instance = new LogService(config);
    }
    return LogService.instance;
  }

  /**
   * 初始化日志服务
   */
  private async initialize(): Promise<void> {
    // 清理过期日志文件
    await this.cleanOldLogs();
  }

  /**
   * 记录调试日志
   */
  public debug(domain: number, tag: string, message: string, data?: Object): void {
    this.log(LogLevel.DEBUG, domain, tag, message, data);
  }

  /**
   * 记录信息日志
   */
  public info(domain: number, tag: string, message: string, data?: Object): void {
    this.log(LogLevel.INFO, domain, tag, message, data);
  }

  /**
   * 记录警告日志
   */
  public warn(domain: number, tag: string, message: string, data?: Object): void {
    this.log(LogLevel.WARN, domain, tag, message, data);
  }

  /**
   * 记录错误日志
   */
  public error(domain: number, tag: string, message: string, data?: Object): void {
    this.log(LogLevel.ERROR, domain, tag, message, data);
  }

  /**
   * 记录致命错误日志
   */
  public fatal(domain: number, tag: string, message: string, data?: Object): void {
    this.log(LogLevel.FATAL, domain, tag, message, data);
  }

  /**
   * 核心日志记录方法
   */
  private log(level: LogLevel, domain: number, tag: string, message: string, data?: Object): void {
    // 检查日志级别
    if (level < this.config.minLevel!) {
      return;
    }

    // 创建日志记录
    const record: LogRecord = new Object() as LogRecord;
    record.timestamp = Date.now();
    record.level = level;
    record.domain = domain;
    record.tag = tag;
    record.message = message;
    record.data = data;

    // 添加到缓冲区
    this.addToBuffer(record);

    // 控制台输出
    if (this.config.enableConsole) {
      this.outputToConsole(record);
    }

    // 文件输出
    if (this.config.enableFile) {
      this.outputToFile(record);
    }

    // 发布日志事件
    eventBus.emit(AppEvents.ERROR, record);
  }

  /**
   * 添加到缓冲区
   */
  private addToBuffer(record: LogRecord): void {
    this.logBuffer.push(record);

    // 限制缓冲区大小
    if (this.logBuffer.length > this.maxBufferSize) {
      this.logBuffer.shift();
    }
  }

  /**
   * 输出到控制台
   */
  private outputToConsole(record: LogRecord): void {
    const levelName = LogLevel[record.level];
    const formattedMessage = `[${levelName}] [${record.domain}:${record.tag}] ${record.message}`;

    switch (record.level) {
      case LogLevel.DEBUG:
        hilog.debug(record.domain, record.tag, formattedMessage);
        break;
      case LogLevel.INFO:
        hilog.info(record.domain, record.tag, formattedMessage);
        break;
      case LogLevel.WARN:
        hilog.warn(record.domain, record.tag, formattedMessage);
        break;
      case LogLevel.ERROR:
      case LogLevel.FATAL:
        hilog.error(record.domain, record.tag, formattedMessage);
        break;
    }
  }

  /**
   * 输出到文件
   */
  private async outputToFile(record: LogRecord): Promise<void> {
    if (!this.config.logFilePath) {
      return;
    }

    try {
      const line = this.formatLogLine(record);
      const file = await fileIo.open(
        this.config.logFilePath,
        fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.APPEND
      );
      await fileIo.write(file.fd, line + '\n');
      await fileIo.close(file.fd);
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to write log to file: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 格式化日志行
   */
  private formatLogLine(record: LogRecord): string {
    const timestamp = new Date(record.timestamp).toISOString();
    const levelName = LogLevel[record.level];
    const dataStr = record.data ? ` | ${JSON.stringify(record.data)}` : '';

    return `${timestamp} | ${levelName} | ${record.domain} | ${record.tag} | ${record.message}${dataStr}`;
  }

  /**
   * 查询日志
   */
  public async queryLogs(options: LogQueryOptions): Promise<LogRecord[]> {
    let results: LogRecord[] = [];
    for (let i = 0; i < this.logBuffer.length; i++) {
      results.push(this.logBuffer[i]);
    }

    // 按时间范围过滤
    if (options.startTime) {
      const filteredResults: LogRecord[] = [];
      for (let i = 0; i < results.length; i++) {
        if (results[i].timestamp >= options.startTime!) {
          filteredResults.push(results[i]);
        }
      }
      results = filteredResults;
    }
    if (options.endTime) {
      const filteredResults: LogRecord[] = [];
      for (let i = 0; i < results.length; i++) {
        if (results[i].timestamp <= options.endTime!) {
          filteredResults.push(results[i]);
        }
      }
      results = filteredResults;
    }

    // 按日志级别过滤
    if (options.minLevel !== undefined) {
      const filteredResults: LogRecord[] = [];
      for (let i = 0; i < results.length; i++) {
        if (results[i].level >= options.minLevel!) {
          filteredResults.push(results[i]);
        }
      }
      results = filteredResults;
    }

    // 按域过滤
    if (options.domain !== undefined) {
      const filteredResults: LogRecord[] = [];
      for (let i = 0; i < results.length; i++) {
        if (results[i].domain === options.domain) {
          filteredResults.push(results[i]);
        }
      }
      results = filteredResults;
    }

    // 按标签过滤
    if (options.tag) {
      const filteredResults: LogRecord[] = [];
      for (let i = 0; i < results.length; i++) {
        if (results[i].tag.includes(options.tag)) {
          filteredResults.push(results[i]);
        }
      }
      results = filteredResults;
    }

    // 排序（最新在前）
    results.sort((a, b) => b.timestamp - a.timestamp);

    // 限制返回数量
    if (options.limit) {
      results = results.slice(0, options.limit);
    }

    return results;
  }

  /**
   * 导出日志
   */
  public async exportLogs(options: LogQueryOptions): Promise<string> {
    const logs = await this.queryLogs(options);

    // 格式化为JSON
    const json = JSON.stringify(logs, null, 2);

    return json;
  }

  /**
   * 导出日志到文件
   */
  public async exportLogsToFile(filePath: string, options?: LogQueryOptions): Promise<void> {
    try {
      const exportOptions: LogQueryOptions = new Object() as LogQueryOptions;
      const json = await this.exportLogs(options || exportOptions);

      const file = await fileIo.open(
        filePath,
        fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY
      );
      await fileIo.write(file.fd, json);
      await fileIo.close(file.fd);

      hilog.info(this.DOMAIN, this.TAG, `Logs exported to ${filePath}`);
    } catch (error) {
      const errorMsg: string = JSON.stringify(error);
      hilog.error(this.DOMAIN, this.TAG, `Failed to export logs: ${errorMsg}`);
      throw new Error(errorMsg);
    }
  }

  /**
   * 清空日志缓冲区
   */
  public clearLogs(): void {
    this.logBuffer = [];
    hilog.info(this.DOMAIN, this.TAG, 'Log buffer cleared');
  }

  /**
   * 清理过期日志文件
   */
  private async cleanOldLogs(): Promise<void> {
    try {
      const context = getContext(this);
      const logDir = context.filesDir + '/logs/';

      try {
        await fileIo.stat(logDir);
      } catch (error) {
        // 目录不存在，跳过
        return;
      }

      const list = await fileIo.listFile(logDir);
      const now = Date.now();
      const retentionMs = (this.config.retentionDays || 7) * 24 * 60 * 60 * 1000;

      for (let i = 0; i < list.length; i++) {
        const fileName = list[i];
        if (!fileName.endsWith('.log')) {
          continue;
        }

        const filePath = logDir + fileName;
        const stat = await fileIo.stat(filePath);
        const fileAge = now - stat.mtime;

        // 删除过期的日志文件
        if (fileAge > retentionMs) {
          await fileIo.unlink(filePath);
          hilog.info(this.DOMAIN, this.TAG, `Deleted old log file: ${fileName}`);
        }
      }
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to clean old logs: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 获取日志统计信息
   */
  public getLogStats(): LogStats {
    const stats: LogStats = new Object() as LogStats;
    stats.total = this.logBuffer.length;
    stats.debug = 0;
    stats.info = 0;
    stats.warn = 0;
    stats.error = 0;
    stats.fatal = 0;
    stats.earliest = null;
    stats.latest = null;

    if (this.logBuffer.length === 0) {
      return stats;
    }

    this.logBuffer.forEach(record => {
      switch (record.level) {
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
        case LogLevel.FATAL:
          stats.fatal++;
          break;
      }
    });

    stats.earliest = this.logBuffer[this.logBuffer.length - 1].timestamp;
    stats.latest = this.logBuffer[0].timestamp;

    return stats;
  }

  /**
   * 设置配置
   */
  public setConfig(config: Partial<LogConfig>): void {
    if (config.minLevel !== undefined) {
      this.config.minLevel = config.minLevel;
    }
    if (config.enableConsole !== undefined) {
      this.config.enableConsole = config.enableConsole;
    }
    if (config.enableFile !== undefined) {
      this.config.enableFile = config.enableFile;
    }
    if (config.logFilePath !== undefined) {
      this.config.logFilePath = config.logFilePath;
    }
    if (config.maxFileSize !== undefined) {
      this.config.maxFileSize = config.maxFileSize;
    }
    if (config.retentionDays !== undefined) {
      this.config.retentionDays = config.retentionDays;
    }
    hilog.info(this.DOMAIN, this.TAG, 'LogService config updated');
  }

  /**
   * 获取配置
   */
  public getConfig(): LogConfig {
    const configCopy: LogConfig = new Object() as LogConfig;
    configCopy.minLevel = this.config.minLevel;
    configCopy.enableConsole = this.config.enableConsole;
    configCopy.enableFile = this.config.enableFile;
    configCopy.logFilePath = this.config.logFilePath;
    configCopy.maxFileSize = this.config.maxFileSize;
    configCopy.retentionDays = this.config.retentionDays;
    return configCopy;
  }

  /**
   * 启用文件日志
   */
  public async enableFileLogging(filePath: string): Promise<void> {
    try {
      // 确保目录存在
      const dir = filePath.substring(0, filePath.lastIndexOf('/'));
      try {
        await fileIo.stat(dir);
      } catch (error) {
        await fileIo.mkdir(dir);
      }

      this.config.logFilePath = filePath;
      this.config.enableFile = true;

      hilog.info(this.DOMAIN, this.TAG, `File logging enabled: ${filePath}`);
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `Failed to enable file logging: ${JSON.stringify(error)}`);
      throw new Error(String(error));
    }
  }

  /**
   * 禁用文件日志
   */
  public disableFileLogging(): void {
    this.config.enableFile = false;
    this.config.logFilePath = undefined;

    hilog.info(this.DOMAIN, this.TAG, 'File logging disabled');
  }

  /**
   * 设置最小日志级别
   */
  public setMinLevel(level: LogLevel): void {
    this.config.minLevel = level;
    hilog.info(this.DOMAIN, this.TAG, `Min log level set to ${LogLevel[level]}`);
  }
}

/**
 * 日志统计接口
 */
export interface LogStats {
  total: number;
  debug: number;
  info: number;
  warn: number;
  error: number;
  fatal: number;
  earliest: number | null;
  latest: number | null;
}

/**
 * 导出单例实例（便捷访问）
 */
export const logService = LogService.getInstance();

/**
 * 应用统一日志域
 */
const APP_LOG_DOMAIN = 0x0001;

/**
 * 页面/组件测试用日志（info）
 */
export function logPageInfo(tag: string, message: string): void {
  logService.info(APP_LOG_DOMAIN, tag, message);
}

/**
 * 页面/组件错误日志（error）
 */
export function logPageError(tag: string, message: string): void {
  logService.error(APP_LOG_DOMAIN, tag, message);
}

/**
 * 页面/组件警告日志（warn）
 */
export function logPageWarn(tag: string, message: string): void {
  logService.warn(APP_LOG_DOMAIN, tag, message);
}

/**
 * 调试用（debug），发布可关闭
 */
export function logPageDebug(tag: string, message: string): void {
  logService.debug(APP_LOG_DOMAIN, tag, message);
}

/**
 * 便捷的静态方法类（替代 AuthLogger）
 */
export class AppLogger {
  private static readonly DOMAIN = APP_LOG_DOMAIN;

  /**
   * 调试日志
   */
  public static debug(tag: string, message: string, data?: Object): void {
    hilog.debug(AppLogger.DOMAIN, tag, message, data ? JSON.stringify(data) : '');
  }

  /**
   * 信息日志
   */
  public static info(tag: string, message: string, data?: Object): void {
    hilog.info(AppLogger.DOMAIN, tag, message, data ? JSON.stringify(data) : '');
  }

  /**
   * 警告日志
   */
  public static warn(tag: string, message: string, data?: Object): void {
    hilog.warn(AppLogger.DOMAIN, tag, message, data ? JSON.stringify(data) : '');
  }

  /**
   * 错误日志
   */
  public static error(tag: string, message: string, error?: Error | Object): void {
    if (error instanceof Error) {
      hilog.error(AppLogger.DOMAIN, tag, `${message} - ${error.message}`);
    } else if (error) {
      hilog.error(AppLogger.DOMAIN, tag, message, JSON.stringify(error));
    } else {
      hilog.error(AppLogger.DOMAIN, tag, message);
    }
  }

  /**
   * 记录认证事件
   */
  public static logAuthEvent(tag: string, event: string): void {
    AppLogger.info(tag, `Auth Event: ${event}`);
  }

  /**
   * 记录错误（简化版）
   */
  public static logError(tag: string, message: string, error: Error | Object): void {
    AppLogger.error(tag, message, error);
  }
}

/**
 * 便捷的快捷方法
 */
class LoggerHelper {
  debug(domain: number, tag: string, message: string, data?: Object): void {
    logService.debug(domain, tag, message, data);
  }

  info(domain: number, tag: string, message: string, data?: Object): void {
    logService.info(domain, tag, message, data);
  }

  warn(domain: number, tag: string, message: string, data?: Object): void {
    logService.warn(domain, tag, message, data);
  }

  error(domain: number, tag: string, message: string, data?: Object): void {
    logService.error(domain, tag, message, data);
  }

  fatal(domain: number, tag: string, message: string, data?: Object): void {
    logService.fatal(domain, tag, message, data);
  }
}

export const logger = new LoggerHelper();
