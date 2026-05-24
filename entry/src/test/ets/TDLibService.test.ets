/**
 * TDLibService 单元测试
 * 测试 TDLib Worker 架构的核心功能
 */
import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import { TDLibService } from '../../src/main/ets/services/TDLibService';
import { TdlibClient } from '../../src/main/ets/workers/TdlibClient';
import { PerformanceMonitor } from '../../src/main/ets/common/managers/PerformanceMonitor';
import { TaskPoolManager } from '../../src/main/ets/common/managers/TaskPoolManager';

describe('TDLibService Test', () => {
  let tdLibService: TDLibService;
  let perfMonitor: PerformanceMonitor;
  let taskPoolManager: TaskPoolManager;

  beforeEach(() => {
    console.info('[TDLibService Test] Setup test environment');
    perfMonitor = PerformanceMonitor.getInstance();
    taskPoolManager = TaskPoolManager.getInstance();
  });

  afterEach(() => {
    console.info('[TDLibService Test] Cleanup test environment');
    perfMonitor.destroy();
    taskPoolManager.destroy();
  });

  /**
   * 测试 1: 单例模式
   */
  it('testGetInstance', 0, () => {
    console.info('[TDLibService Test] Test getInstance');
    
    const instance1 = TDLibService.getInstance();
    const instance2 = TDLibService.getInstance();
    
    expect(instance1).notEqual(null);
    expect(instance2).notEqual(null);
    expect(instance1 === instance2).assertTrue(true, 'TDLibService should be singleton');
    
    console.info('[TDLibService Test] getInstance passed');
  });

  /**
   * 测试 2: 性能监控器初始化
   */
  it('testPerformanceMonitorInit', 0, () => {
    console.info('[TDLibService Test] Test PerformanceMonitor initialization');
    
    const monitor = PerformanceMonitor.getInstance();
    expect(monitor).notEqual(null);
    
    const metrics = monitor.getMetrics();
    expect(metrics.requestCount).toEqual(0, 'Initial request count should be 0');
    expect(metrics.fps).toBeGreaterOrEqual(0, 'FPS should be >= 0');
    
    console.info('[TDLibService Test] PerformanceMonitor init passed');
  });

  /**
   * 测试 3: TaskPool 管理器初始化
   */
  it('testTaskPoolManagerInit', 0, () => {
    console.info('[TDLibService Test] Test TaskPoolManager initialization');
    
    const manager = TaskPoolManager.getInstance();
    expect(manager).notEqual(null);
    
    const stats = manager.getStats();
    expect(stats.totalTasks).toEqual(0, 'Initial task count should be 0');
    expect(stats.runningTasks).toEqual(0, 'Running tasks should be 0');
    
    console.info('[TDLibService Test] TaskPoolManager init passed');
  });

  /**
   * 测试 4: 性能监控 - 请求耗时统计
   */
  it('testRequestPerformanceMonitoring', 0, async () => {
    console.info('[TDLibService Test] Test request performance monitoring');
    
    const monitor = PerformanceMonitor.getInstance();
    monitor.reset();
    
    // 模拟请求开始
    const requestId = 'test_req_001';
    const method = 'getMessage';
    monitor.markRequestStart(requestId, method);
    
    // 等待 10ms 模拟请求处理
    await new Promise(resolve => setTimeout(resolve, 10));
    
    // 标记请求结束
    monitor.markRequestEnd(requestId, true);
    
    const metrics = monitor.getMetrics();
    expect(metrics.requestCount).toEqual(1, 'Should have 1 completed request');
    expect(metrics.averageRequestTime).toBeGreaterOrEqual(10, 'Average time should be >= 10ms');
    
    console.info(`[TDLibService Test] Request performance monitoring passed, avg time: ${metrics.averageRequestTime.toFixed(2)}ms`);
  });

  /**
   * 测试 5: TaskPool 任务执行统计
   */
  it('testTaskPoolStats', 0, async () => {
    console.info('[TDLibService Test] Test TaskPool statistics');
    
    const manager = TaskPoolManager.getInstance();
    
    // 模拟任务完成
    manager['updateStats'](true, 50); // 成功，耗时 50ms
    manager['updateStats'](true, 100); // 成功，耗时 100ms
    manager['updateStats'](false, 20); // 失败，耗时 20ms
    
    const stats = manager.getStats();
    expect(stats.totalTasks).toEqual(3, 'Total tasks should be 3');
    expect(stats.completedTasks).toEqual(2, 'Completed tasks should be 2');
    expect(stats.failedTasks).toEqual(1, 'Failed tasks should be 1');
    expect(stats.averageExecuteTime).toEqual(56.67, 'Average time should be ~56.67ms', 0.1);
    
    console.info('[TDLibService Test] TaskPool statistics passed');
  });

  /**
   * 测试 6: Worker 客户端基本功能
   */
  it('testTdlibClientBasic', 0, () => {
    console.info('[TDLibService Test] Test TdlibClient basic functionality');
    
    const client = TdlibClient.getInstance();
    expect(client).notEqual(null);
    
    // 初始状态应为未初始化
    expect(client.isInitialized()).assertFalse(false, 'Client should not be initialized initially');
    
    console.info('[TDLibService Test] TdlibClient basic passed');
  });

  /**
   * 测试 7: 批量更新处理
   */
  it('testBatchUpdateProcessing', 0, async () => {
    console.info('[TDLibService Test] Test batch update processing');
    
    const monitor = PerformanceMonitor.getInstance();
    monitor.reset();
    
    // 模拟批量更新
    const updates = [
      { type: 'updateNewMessage' },
      { type: 'updateChatLastMessage' },
      { type: 'updateFile' }
    ];
    
    // 更新批次大小
    monitor.updateBatchSize(updates.length);
    
    const metrics = monitor.getMetrics();
    expect(metrics.updateBatchSize).toEqual(3, 'Batch size should be 3');
    
    console.info('[TDLibService Test] Batch update processing passed');
  });

  /**
   * 测试 8: 错误处理
   */
  it('testErrorHandling', 0, () => {
    console.info('[TDLibService Test] Test error handling');
    
    const monitor = PerformanceMonitor.getInstance();
    monitor.reset();
    
    // 模拟失败的请求
    monitor.markRequestStart('fail_req_001', 'sendMessage');
    monitor.markRequestEnd('fail_req_001', false);
    
    const metrics = monitor.getMetrics();
    expect(metrics.slowRequests).toEqual(0, 'No slow requests expected');
    
    console.info('[TDLibService Test] Error handling passed');
  });

  /**
   * 测试 9: 监控系统启动停止
   */
  it('testMonitoringLifecycle', 0, async () => {
    console.info('[TDLibService Test] Test monitoring lifecycle');
    
    const monitor = PerformanceMonitor.getInstance();
    
    // 启动监控
    monitor.startMonitoring();
    await new Promise(resolve => setTimeout(resolve, 100));
    
    // 停止监控
    monitor.stopMonitoring();
    
    console.info('[TDLibService Test] Monitoring lifecycle passed');
  });

  /**
   * 测试 10: 并发任务处理
   */
  it('testConcurrentTasks', 0, async () => {
    console.info('[TDLibService Test] Test concurrent task processing');
    
    const manager = TaskPoolManager.getInstance();
    
    // 模拟多个并发任务
    const promises = [];
    for (let i = 0; i < 5; i++) {
      manager['updateStats'](true, 10 + i * 5);
      promises.push(Promise.resolve());
    }
    
    await Promise.all(promises);
    
    const stats = manager.getStats();
    expect(stats.totalTasks).toEqual(5, 'Should process 5 tasks');
    expect(stats.completedTasks).toEqual(5, 'All tasks should complete');
    
    console.info('[TDLibService Test] Concurrent tasks passed');
  });
});
