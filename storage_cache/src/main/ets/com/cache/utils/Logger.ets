export enum LogLevel {
  DEBUG, INFO, WARN, ERROR
}

type ExternalLogger = (level: LogLevel, tag: string, message: string) => void;

export class CacheLogger {
  private static level: LogLevel = LogLevel.INFO;
  private static externalLogger?: ExternalLogger;

  static setLevel(level: LogLevel): void { CacheLogger.level = level; }
  static setExternalLogger(logger: ExternalLogger): void { CacheLogger.externalLogger = logger; }

  private static log(level: LogLevel, tag: string, message: string): void {
    if (level < CacheLogger.level) return;
    switch (level) {
      case LogLevel.DEBUG: console.debug(`[${tag}] ${message}`); break;
      case LogLevel.INFO:  console.info(`[${tag}] ${message}`); break;
      case LogLevel.WARN:  console.warn(`[${tag}] ${message}`); break;
      case LogLevel.ERROR: console.error(`[${tag}] ${message}`); break;
    }
    CacheLogger.externalLogger?.(level, tag, message);
  }

  static debug(tag: string, msg: string): void { CacheLogger.log(LogLevel.DEBUG, tag, msg); }
  static info(tag: string, msg: string): void { CacheLogger.log(LogLevel.INFO, tag, msg); }
  static warn(tag: string, msg: string): void { CacheLogger.log(LogLevel.WARN, tag, msg); }
  static error(tag: string, msg: string): void { CacheLogger.log(LogLevel.ERROR, tag, msg); }

  static async measureTime<T>(tag: string, operation: string, fn: () => Promise<T>): Promise<T> {
    const start = Date.now();
    try { return await fn(); } finally {
      const duration = Date.now() - start;
      if (duration > 100) CacheLogger.warn(tag, `${operation} took ${duration}ms`);
      else CacheLogger.debug(tag, `${operation} took ${duration}ms`);
    }
  }
}