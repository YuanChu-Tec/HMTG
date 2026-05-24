/**
 * TDLib Worker 通信协议定义 (V2.1 - Final)
 * 严格遵循 Telegram for HarmonyOS 多线程通信设计方案
 */

export const PROTOCOL_VERSION = 1;

/**
 * 消息类型枚举
 */
export enum MessageType {
  REQUEST = 'request',
  RESPONSE = 'response',
  UPDATE = 'update',
  CONTROL = 'control',
  TASK_REQUEST = 'task_request',
  TASK_RESULT = 'task_result',
  EXECUTE_RESULT = 'execute_result',  // ⭐ execute 请求的响应
  BATCH_UPDATE = 'batch_update',      // ⭐ 批量更新
  ERROR = 'error'                     // ⭐ 错误消息
}

/**
 * 控制命令枚举
 */
export enum ControlCommand {
  INIT = 'init',
  DESTROY = 'destroy',
  CONFIG = 'config',
  HEARTBEAT = 'heartbeat',
  HEARTBEAT_ACK = 'heartbeat_ack',
  READY = 'ready',
  FORWARD_TASK = 'forward_task' // 新增：任务转发指令
}

/**
 * 基础消息接口
 */
export interface BaseMessage {
  id: string;
  timestamp: number;
  type: MessageType;
  version?: number; // 当前协议版本: 1
}

/**
 * TDLib 通用对象结构
 * 修复：移除交叉类型，使用接口定义核心字段，业务层通过 Record<string, Object> 处理动态属性
 */
export interface TDLibObject {
  '@type': string;
}

/**
 * Request: UI → Worker
 */
export interface Request<T extends Record<string, Object> = Record<string, Object>> extends BaseMessage {
  type: MessageType.REQUEST;
  method: string;
  params: T;
  expectResponse: boolean;
}

/**
 * Response: Worker → UI
 */
export interface Response<R extends Object = Object> extends BaseMessage {
  type: MessageType.RESPONSE;
  requestId: string;
  success: boolean;
  result?: R;
  error?: ErrorInfo;
}

/**
 * Update: Worker → UI
 */
export interface Update<D extends Object = Object> extends BaseMessage {
  type: MessageType.UPDATE;
  updateType: string;
  data?: D; // 设为可选，兼容 BatchUpdate
}

/**
 * Control: UI ↔ Worker
 */
export interface Control extends BaseMessage {
  type: MessageType.CONTROL;
  command: ControlCommand;
  payload?: Record<string, Object>;
}

/**
 * ExecuteResult: Worker → UI (execute 请求的响应)
 */
export interface ExecuteResult extends BaseMessage {
  type: MessageType.EXECUTE_RESULT;
  id: string;              // 请求 ID
  result?: Record<string, Object> | null;
  error?: string;
}

/**
 * BatchUpdate: Worker → UI (批量更新)
 */
export interface BatchUpdateMessage extends BaseMessage {
  type: MessageType.BATCH_UPDATE;
  updates: Array<Record<string, Object>>;
}

/**
 * ErrorMessage: Worker → UI (错误通知)
 */
export interface ErrorMessage extends BaseMessage {
  type: MessageType.ERROR;
  message: string;
}

/**
 * TaskRequest: Worker → TaskPool
 * 使用 funcName 避免 ArkTS 保留字冲突
 */
export interface TaskRequest extends BaseMessage {
  type: MessageType.TASK_REQUEST;
  taskId: string;
  funcName: string;
  args: Object[];
  transferList?: ArrayBuffer[];
}

/**
 * TaskResult: TaskPool → Worker
 */
export interface TaskResult extends BaseMessage {
  type: MessageType.TASK_RESULT;
  taskId: string;
  success: boolean;
  result?: Object;
  error?: string;
}

/**
 * 错误信息接口
 */
export interface ErrorInfo {
  code: number;
  message: string;
}

/**
 * 批量更新接口 (用于高频事件合并)
 */
export interface BatchUpdate extends Update {
  batch: true;
  updates: Update[];
  data?: never; // 明确禁止在批量消息中使用 data 字段
}

/**
 * 联合类型：所有可能的 Worker 消息
 * 用于在 onmessage 中进行类型收窄
 */
export type WorkerMessage = 
  | Request 
  | Response 
  | Update 
  | Control 
  | TaskRequest 
  | TaskResult
  | ExecuteResult
  | BatchUpdateMessage
  | ErrorMessage;
