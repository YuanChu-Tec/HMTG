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
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { hilog } from '@kit.PerformanceAnalysisKit';

// StartupCacheLoader 将在功能实现时导入
// import { StartupCacheLoader } from '../../../utils/chat/StartupCacheLoader';

const TAG = 'CacheAwareViewModel';
const DOMAIN = 0x0001;

/**
 * 缓存策略
 */
export type CacheStrategy = 'LRU' | 'LFU' | 'FIFO' | 'LIFO' | 'TTL';

/**
 * 缓存层级
 */
export type CacheLevel = 'L1' | 'L2' | 'L3' | 'L4' | 'L5';

/**
 * 缓存项
 */
export interface CacheItem<T = Object> {
  key: string;
  value: T;
  level: CacheLevel;
  timestamp: number;
  ttl?: number;
  size: number;
  hitCount: number;
}

/**
 * 缓存配置
 */
export interface CacheConfig {
  maxMemorySize: number;     // 最大内存大小(bytes)
  maxDiskSize: number;       // 最大磁盘大小(bytes)
  strategy: CacheStrategy;   // 缓存策略
  compressionEnabled: boolean; // 启用压缩
  encryptionEnabled: boolean; // 启用加密
  ttl: number;             // 默认TTL(秒)
}

/**
 * 层级统计
 */
interface LevelStats {
  size: number;
  count: number;
}

/**
 * 缓存统计
 */
export interface CacheStats {
  totalSize: number;
  itemCount: number;
  hitCount: number;
  missCount: number;
  hitRate: number;
  levelStats: Map<CacheLevel, LevelStats>;
}

/**
 * 缓存感知 ViewModel
 * 提供智能缓存功能的基类
 */
export class CacheAwareViewModel {
  private static instance: CacheAwareViewModel;
  private cache: Map<string, CacheItem> = new Map();
  private config: CacheConfig = this.getDefaultConfig();
  private stats: CacheStats = this.getDefaultStats();
  private cacheLoader?: Object;

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): CacheAwareViewModel {
    if (!CacheAwareViewModel.instance) {
      CacheAwareViewModel.instance = new CacheAwareViewModel();
    }
    return CacheAwareViewModel.instance;
  }

  /**
   * 获取默认配置
   */
  private getDefaultConfig(): CacheConfig {
    return {
      maxMemorySize: 50 * 1024 * 1024,  // 50MB
      maxDiskSize: 500 * 1024 * 1024,  // 500MB
      strategy: 'LRU',
      compressionEnabled: true,
      encryptionEnabled: false,
      ttl: 3600  // 1小时
    };
  }

  /**
   * 获取默认统计
   */
  private getDefaultStats(): CacheStats {
    const l1Stats: LevelStats = { size: 0, count: 0 };
    const l2Stats: LevelStats = { size: 0, count: 0 };
    const l3Stats: LevelStats = { size: 0, count: 0 };
    const l4Stats: LevelStats = { size: 0, count: 0 };
    const l5Stats: LevelStats = { size: 0, count: 0 };

    return {
      totalSize: 0,
      itemCount: 0,
      hitCount: 0,
      missCount: 0,
      hitRate: 0,
      levelStats: new Map<CacheLevel, LevelStats>([
        ['L1', l1Stats],
        ['L2', l2Stats],
        ['L3', l3Stats],
        ['L4', l4Stats],
        ['L5', l5Stats]
      ])
    };
  }

  /**
   * 初始化
   */
  public initialize(cacheLoader?: Object): void {
    this.cacheLoader = cacheLoader;
    hilog.info(DOMAIN, TAG, 'CacheAwareViewModel initialized');
  }

  /**
   * 获取缓存
   */
  public get<T>(key: string, level?: CacheLevel): T | null {
    const item = this.cache.get(key);

    if (!item) {
      this.stats.missCount++;
      this.updateHitRate();
      return null;
    }

    // 检查是否过期
    if (item.ttl && (Date.now() - item.timestamp) > item.ttl * 1000) {
      this.delete(key);
      this.stats.missCount++;
      this.updateHitRate();
      return null;
    }

    // 检查层级
    if (level) {
      const levelKey: CacheLevel = level;
      if (item.level !== levelKey) {
        this.stats.missCount++;
        this.updateHitRate();
        return null;
      }
    }

    item.hitCount++;
    this.stats.hitCount++;

    // 应用缓存策略
    this.applyStrategy(item);

    this.updateHitRate();
    hilog.debug(DOMAIN, TAG, `Cache hit: ${key}, level: ${item.level}`);
    return item.value as T;
  }

  /**
   * 设置缓存
   */
  public set<T>(key: string, value: T, level: CacheLevel = 'L2', ttl?: number): boolean {
    const size = this.estimateSize(value as Object);

    // 检查大小限制
    if (!this.checkSizeLimit(size)) {
      this.evictIfNeeded(size);
    }

    const item: CacheItem = {
      key,
      value: value as Object,
      level,
      timestamp: Date.now(),
      ttl: ttl || this.config.ttl,
      size,
      hitCount: 0
    };

    this.cache.set(key, item);
    this.updateStats(item);
    hilog.debug(DOMAIN, TAG, `Cache set: ${key}, level: ${level}, size: ${size}`);

    // 通知缓存加载器
    if (this.cacheLoader && typeof this.cacheLoader === 'object') {
      const loader = this.cacheLoader as Record<string, Function>;
      if (loader.calculateCacheSize) {
        loader.calculateCacheSize();
      }
    }

    return true;
  }

  /**
   * 删除缓存
   */
  public delete(key: string): boolean {
    const item = this.cache.get(key);
    if (item) {
      this.updateStatsOnDelete(item);
      this.cache.delete(key);
      hilog.debug(DOMAIN, TAG, `Cache deleted: ${key}`);
      return true;
    }
    return false;
  }

  /**
   * 清空缓存
   */
  public clear(): void {
    const count = this.cache.size;
    this.cache.clear();
    this.resetStats();
    hilog.info(DOMAIN, TAG, `Cache cleared: ${count} items`);
  }

  /**
   * 检查缓存是否存在
   */
  public has(key: string): boolean {
    const item = this.cache.get(key);
    if (!item) {
      return false;
    }

    // 检查是否过期
    if (item.ttl && (Date.now() - item.timestamp) > item.ttl * 1000) {
      this.delete(key);
      return false;
    }

    return true;
  }

  /**
   * 预取缓存
   */
  public async prefetch<T>(keys: string[], fetcher: (key: string) => Promise<T>): Promise<void> {
    for (const key of keys) {
      if (!this.has(key)) {
        try {
          hilog.debug(DOMAIN, TAG, `Prefetching: ${key}`);
          const value = await fetcher(key);
          this.set(key, value, 'L1');
        } catch (error) {
          hilog.error(DOMAIN, TAG, `Prefetch failed: ${key}, ${JSON.stringify(error)}`);
        }
      }
    }
  }

  /**
   * 应用缓存策略
   */
  private applyStrategy(item: CacheItem): void {
    switch (this.config.strategy) {
      case 'LRU':
        // LRU: 最近最少使用的会在需要空间时被移除
        break;
      case 'LFU':
        // LFU: 最不常用的会在需要空间时被移除
        break;
      case 'FIFO':
        // FIFO: 先进先出
        break;
      case 'LIFO':
        // LIFO: 后进先出
        break;
      case 'TTL':
        // TTL: 按生存时间清理
        break;
    }
  }

  /**
   * 检查大小限制
   */
  private checkSizeLimit(size: number): boolean {
    return (this.stats.totalSize + size) <= this.config.maxMemorySize;
  }

  /**
   * 需要时驱逐缓存
   */
  private evictIfNeeded(requiredSize: number): void {
    let freedSize = 0;
    const items = Array.from(this.cache.values());

    // 按策略排序
    items.sort((a, b) => {
      switch (this.config.strategy) {
        case 'LRU':
          return a.timestamp - b.timestamp;
        case 'LFU':
          return a.hitCount - b.hitCount;
        case 'FIFO':
          return a.timestamp - b.timestamp;
        case 'LIFO':
          return b.timestamp - a.timestamp;
        case 'TTL':
          return (a.ttl || 0) - (b.ttl || 0);
        default:
          return a.timestamp - b.timestamp;
      }
    });

    // 驱逐直到有足够空间
    for (const item of items) {
      if (freedSize >= requiredSize) {
        break;
      }

      this.delete(item.key);
      freedSize += item.size;
    }

    hilog.info(DOMAIN, TAG, `Evicted ${freedSize} bytes from cache`);
  }

  /**
   * 更新统计
   */
  private updateStats(item: CacheItem): void {
    this.stats.totalSize += item.size;
    this.stats.itemCount = this.cache.size;

    const levelStat = this.stats.levelStats.get(item.level);
    if (levelStat) {
      levelStat.size += item.size;
      levelStat.count++;
    }
  }

  /**
   * 删除时更新统计
   */
  private updateStatsOnDelete(item: CacheItem): void {
    this.stats.totalSize -= item.size;
    this.stats.itemCount = this.cache.size;

    const levelStat = this.stats.levelStats.get(item.level);
    if (levelStat) {
      levelStat.size = Math.max(0, levelStat.size - item.size);
      levelStat.count = Math.max(0, levelStat.count - 1);
    }
  }

  /**
   * 更新命中率
   */
  private updateHitRate(): void {
    const total = this.stats.hitCount + this.stats.missCount;
    this.stats.hitRate = total > 0 ? (this.stats.hitCount / total) * 100 : 0;
  }

  /**
   * 重置统计
   */
  private resetStats(): void {
    this.stats = this.getDefaultStats();
  }

  /**
   * 估算大小
   */
  private estimateSize(value: Object): number {
    if (value === null || value === undefined) {
      return 0;
    }

    try {
      return JSON.stringify(value).length * 2; // 粗略估算
    } catch (error) {
      return 100; // 默认大小
    }
  }

  /**
   * 获取统计
   */
  public getStats(): CacheStats {
    const result: CacheStats = {
      totalSize: this.stats.totalSize,
      itemCount: this.stats.itemCount,
      hitCount: this.stats.hitCount,
      missCount: this.stats.missCount,
      hitRate: this.stats.hitRate,
      levelStats: new Map(this.stats.levelStats)
    };
    return result;
  }

  /**
   * 获取配置
   */
  public getConfig(): CacheConfig {
    const result: CacheConfig = {
      maxMemorySize: this.config.maxMemorySize,
      maxDiskSize: this.config.maxDiskSize,
      strategy: this.config.strategy,
      compressionEnabled: this.config.compressionEnabled,
      encryptionEnabled: this.config.encryptionEnabled,
      ttl: this.config.ttl
    };
    return result;
  }

  /**
   * 设置配置
   */
  public setConfig(config: Partial<CacheConfig>): void {
    if (config.maxMemorySize !== undefined) {
      this.config.maxMemorySize = config.maxMemorySize;
    }
    if (config.maxDiskSize !== undefined) {
      this.config.maxDiskSize = config.maxDiskSize;
    }
    if (config.strategy !== undefined) {
      this.config.strategy = config.strategy;
    }
    if (config.compressionEnabled !== undefined) {
      this.config.compressionEnabled = config.compressionEnabled;
    }
    if (config.encryptionEnabled !== undefined) {
      this.config.encryptionEnabled = config.encryptionEnabled;
    }
    if (config.ttl !== undefined) {
      this.config.ttl = config.ttl;
    }
    hilog.info(DOMAIN, TAG, `Cache config updated: ${JSON.stringify(this.config)}`);
  }

  /**
   * 获取缓存大小
   */
  public getCacheSize(): number {
    return this.stats.totalSize;
  }

  /**
   * 获取格式化大小
   */
  public getFormattedCacheSize(): string {
    const bytes = this.stats.totalSize;
    const mb = bytes / (1024 * 1024);
    const gb = mb / 1024;

    if (gb >= 1) {
      return `${gb.toFixed(2)} GB`;
    } else {
      return `${mb.toFixed(2)} MB`;
    }
  }

  /**
   * 销毁
   */
  public destroy(): void {
    this.clear();
    this.cacheLoader = undefined;
  }
}
