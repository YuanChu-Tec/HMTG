// SortedHashMap.ets
// 排序哈希表实现，用于 DataSource 层的高效数据管理
// 优化版本：使用二分查找插入，复杂度从 O(n log n) 降至 O(log n)

export class SortedHashMap<K, V> {
  private map: Map<K, V> = new Map();
  private sortedKeys: K[] = [];
  private compareFn: (a: K, b: K) => number;

  constructor(compareFn?: (a: K, b: K) => number) {
    this.compareFn = compareFn || ((a: K, b: K) => (a as number) - (b as number));
  }

  /**
   * 设置键值对，返回插入/更新后的索引
   * 优化：新键使用二分查找插入，避免全排序
   */
  set(key: K, value: V): number {
    const existingIndex = this.map.has(key) ? this.binarySearchKey(key) : -1;
    this.map.set(key, value);

    if (existingIndex >= 0) {
      // 已存在，更新值但保持位置（如果比较函数基于 value）
      // 如果比较函数基于 key，则位置不变
      return existingIndex;
    } else {
      // 新键，二分查找插入位置
      const insertIndex = this.binarySearchForInsert(key);
      this.sortedKeys.splice(insertIndex, 0, key);
      return insertIndex;
    }
  }

  /**
   * 二分查找键的索引
   */
  private binarySearchKey(key: K): number {
    let left = 0;
    let right = this.sortedKeys.length - 1;

    while (left <= right) {
      const mid = (left + right) >>> 1;
      const cmp = this.compareFn(key, this.sortedKeys[mid]);

      if (cmp === 0) {
        return mid;
      } else if (cmp < 0) {
        right = mid - 1;
      } else {
        left = mid + 1;
      }
    }
    return -1;
  }

  /**
   * 二分查找插入位置
   */
  private binarySearchForInsert(key: K): number {
    let left = 0;
    let right = this.sortedKeys.length;

    while (left < right) {
      const mid = (left + right) >>> 1;
      const cmp = this.compareFn(key, this.sortedKeys[mid]);

      if (cmp < 0) {
        right = mid;
      } else {
        left = mid + 1;
      }
    }
    return left;
  }

  /**
   * 根据键获取值
   */
  get(key: K): V | undefined {
    return this.map.get(key);
  }

  /**
   * 根据索引获取值
   */
  getValueAt(index: number): V | undefined {
    if (index < 0 || index >= this.sortedKeys.length) {
      return undefined;
    }
    const key = this.sortedKeys[index];
    return key !== undefined ? this.map.get(key) : undefined;
  }

  /**
   * 删除指定键，返回删除前的索引（未找到返回 -1）
   */
  delete(key: K): number {
    const index = this.sortedKeys.indexOf(key);
    if (index >= 0) {
      this.map.delete(key);
      this.sortedKeys.splice(index, 1);
    }
    return index;
  }

  /**
   * 获取键的索引
   */
  indexOf(key: K): number {
    return this.sortedKeys.indexOf(key);
  }

  /**
   * 是否包含指定键
   */
  has(key: K): boolean {
    return this.map.has(key);
  }

  /**
   * 获取元素数量
   */
  length(): number {
    return this.map.size;
  }

  /**
   * 清空所有数据
   */
  clear(): void {
    this.map.clear();
    this.sortedKeys = [];
  }

  /**
   * 获取所有值的迭代器
   */
  values(): IterableIterator<V> {
    return this.map.values();
  }

  /**
   * 获取排序后的值数组
   */
  getSortedValues(): V[] {
    const result: V[] = [];
    for (const k of this.sortedKeys) {
      const v = this.map.get(k);
      if (v !== undefined) {
        result.push(v);
      }
    }
    return result;
  }

  /**
   * 获取所有键的数组
   */
  getKeys(): K[] {
    return [...this.sortedKeys];
  }

  /**
   * 获取第一个元素
   */
  first(): V | undefined {
    if (this.sortedKeys.length === 0) {
      return undefined;
    }
    return this.map.get(this.sortedKeys[0]);
  }

  /**
   * 获取最后一个元素
   */
  last(): V | undefined {
    if (this.sortedKeys.length === 0) {
      return undefined;
    }
    return this.map.get(this.sortedKeys[this.sortedKeys.length - 1]);
  }

  /**
   * 遍历所有键值对
   */
  forEach(callback: (value: V, key: K, index: number) => void): void {
    for (let i = 0; i < this.sortedKeys.length; i++) {
      const key = this.sortedKeys[i];
      const value = this.map.get(key);
      if (value !== undefined) {
        callback(value, key, i);
      }
    }
  }

  /**
   * 批量设置键值对（用于初始化）
   * 比逐个插入更高效
   */
  setAll(entries: [K, V][]): void {
    // 先全部放入 Map
    for (const entry of entries) {
      const key = entry[0];
      const value = entry[1];
      this.map.set(key, value);
    }
    // 提取所有 key 并排序
    this.sortedKeys = [];
    for (const entry of entries) {
      this.sortedKeys.push(entry[0]);
    }
    this.sortedKeys.sort(this.compareFn);
  }

  /**
   * 内部排序方法（保留用于批量操作后排序）
   */
  private sortKeys(): void {
    this.sortedKeys.sort(this.compareFn);
  }
}

export default SortedHashMap;
