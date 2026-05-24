/**
 * 连接状态枚举
 */
export enum ConnectionState {
  /** 未连接 */
  NONE = 'none',
  
  /** 正在连接 */
  CONNECTING = 'connecting',
  
  /** 已连接 */
  CONNECTED = 'connected',
  
  /** 连接失败 */
  FAILED = 'failed',
  
  /** 等待网络 */
  WAITING_FOR_NETWORK = 'waiting_for_network'
}
