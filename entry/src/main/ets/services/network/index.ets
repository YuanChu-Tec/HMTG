/**
 * Network Layer - 网络通信层
 * 
 * 包含:
 * - NetworkMonitorService: 网络状态监控
 * - MTProtoProxyService: MTProto 代理服务
 * - Socks5ProxyService: SOCKS5 代理服务
 * - RequestQueueManager: 请求队列管理
 */

export { NetworkMonitorService } from './NetworkMonitorService';
export { MTProtoProxyService } from './MTProtoProxyService';
export { Socks5ProxyService } from './Socks5ProxyService';
export { RequestQueueManager } from './RequestQueueManager';

// 导出类型定义
export type {
  RequestType,
  RequestPriority,
  RequestStatus,
  RequestItem,
  BatchRequestConfig
} from './RequestQueueManager';
