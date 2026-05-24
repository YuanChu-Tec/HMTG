/**
 * 消息内容缓存管理器
 * 缓存已渲染的消息内容，避免重复渲染提升性能
 */

export interface CachedMessageContent {
  messageId: number;
  content: string;
  timestamp: number;
}

export class MessageContentCache {
  private static instance: MessageContentCache;
  private cache: Map<string, CachedMessageContent>;
  private maxSize: number;
  private ttl: number; // 缓存过期时间（毫秒）

  private constructor(maxSize: number = 1000, ttl: number = 300000) {
    this.cache = new Map();
    this.maxSize = maxSize;
    this.ttl = ttl;
  }

  public static getInstance(): MessageContentCache {
    if (!MessageContentCache.instance) {
      MessageContentCache.instance = new MessageContentCache();
    }
    return MessageContentCache.instance;
  }

  /**
   * 生成缓存key
   */
  private generateKey(messageId: number, type: string): string {
    return `${messageId}_${type}`;
  }

  /**
   * 获取缓存内容
   */
  public get(messageId: number, type: string): CachedMessageContent | null {
    const key = this.generateKey(messageId, type);
    const cached = this.cache.get(key);

    if (!cached) {
      return null;
    }

    // 检查是否过期
    const now = Date.now();
    if (now - cached.timestamp > this.ttl) {
      this.cache.delete(key);
      return null;
    }

    return cached;
  }

  /**
   * 设置缓存内容
   */
  public set(messageId: number, type: string, content: string): void {
    const key = this.generateKey(messageId, type);

    // 如果缓存已满，删除最早的项
    if (this.cache.size >= this.maxSize) {
      const firstKey = this.cache.keys().next().value as string | undefined;
      if (firstKey) {
        this.cache.delete(firstKey);
      }
    }

    this.cache.set(key, {
      messageId,
      content,
      timestamp: Date.now()
    });
  }

  /**
   * 删除指定消息的缓存
   */
  public delete(messageId: number, type?: string): void {
    if (type) {
      const key = this.generateKey(messageId, type);
      this.cache.delete(key);
    } else {
      // 删除该消息的所有类型缓存
      for (const key of this.cache.keys()) {
        if (key.startsWith(`${messageId}_`)) {
          this.cache.delete(key);
        }
      }
    }
  }

  /**
   * 清空所有缓存
   */
  public clear(): void {
    this.cache.clear();
  }

  /**
   * 获取缓存大小
   */
  public size(): number {
    return this.cache.size;
  }

  /**
   * 清理过期缓存
   */
  public cleanExpired(): void {
    const now = Date.now();
    const expiredKeys: string[] = [];

    this.cache.forEach((cached: CachedMessageContent, key: string) => {
      if (now - cached.timestamp > this.ttl) {
        expiredKeys.push(key);
      }
    });

    for (const key of expiredKeys) {
      this.cache.delete(key);
    }
  }
}
