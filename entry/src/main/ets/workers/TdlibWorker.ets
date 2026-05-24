/**
 * TDLib Worker - 独立线程处理 TDLib 通信
 * 
 * 职责：
 * 1. 维护 TDLib 客户端生命周期
 * 2. 执行 td_receive 非阻塞轮询
 * 3. 批量合并高频更新事件
 * 4. 转发请求响应给 UI 线程
 */
import { worker, MessageEvents } from '@kit.ArkTS';
import nativeBinding from 'libhome.so';
import { MessageType, ControlCommand, Update, ExecuteResult, BatchUpdateMessage, ErrorMessage, Request, Response, Control } from './TdlibWorkerProtocol';

const workerPort = worker.workerPort;
let clientId: number = -1;
let receiveLoopActive: boolean = true;

// ⭐ 待匹配的异步请求映射表（@extra → requestId）
let pendingRequestExtras: Map<string, string> = new Map();

// ⭐ 标记 setTdlibParameters 是否已发送但还未收到响应
let isWaitingForInitResponse: boolean = false;

// 批量更新队列配置
const BATCH_DELAY_MS = 50;
const MAX_BATCH_SIZE = 200; // 内存保护：防止极端情况下队列无限增长
let batchQueue: Array<Record<string, Object>> = [];
let batchTimer: number | null = null;

// 需要批量合并的高频事件类型
const BATCHED_UPDATE_TYPES = new Set([
  'updateChatAction',
  'updateUserStatus',
  'updateChatLastMessage',
  'updateChatReadInbox',
  'updateChatReadOutbox'
]);

/**
 * 递归转换对象：将 _ 字段转换为 @type
 * 
 * TDLib JSON API 要求所有对象（包括嵌套对象）都使用 "@type" 作为类型标识符，
 * 但 ArkTS 类型定义使用 "_" 字段。此函数在序列化前进行转换。
 * 
 * @param obj 要转换的对象
 * @returns 转换后的对象（新对象）
 */
function convertUnderscoreToAtType(obj: Object): Object {
  if (!obj || typeof obj !== 'object') {
    return obj;
  }
  
  // 处理数组
  if (Array.isArray(obj)) {
    const result: Object[] = [];
    for (let i = 0; i < obj.length; i++) {
      result.push(convertUnderscoreToAtType(obj[i]));
    }
    return result;
  }
  
  // 处理普通对象
  const result: Record<string, Object> = {};
  const keys = Object.keys(obj);
  
  for (let i = 0; i < keys.length; i++) {
    const key = keys[i];
    const value = (obj as Record<string, Object>)[key];
    
    // 关键转换：将 _ 字段转换为 @type
    if (key === '_') {
      result['@type'] = value;
    } else {
      // 递归处理嵌套对象
      result[key] = convertUnderscoreToAtType(value);
    }
  }
  
  return result;
}

/**
 * 刷新批量队列并发送给 UI
 */
function flushBatch(): void {
  if (batchQueue.length === 0) return;
  
  const batch = [...batchQueue];
  batchQueue = [];
  batchTimer = null;
  
  try {
    // ⭐ 使用协议类型
    const message: BatchUpdateMessage = {
      id: `batch_${Date.now()}`,
      timestamp: Date.now(),
      type: MessageType.BATCH_UPDATE,
      updates: batch
    };
    workerPort.postMessage(message);
  } catch (e) {
    console.error('[Worker] Failed to post batch update:', e);
  }
}

/**
 * 将更新加入批量队列
 */
function queueUpdate(update: Record<string, Object>): void {
  if (batchQueue.length >= MAX_BATCH_SIZE) {
    // 如果队列已满，立即刷新以防止内存溢出
    flushBatch();
  }
  
  batchQueue.push(update);
  if (batchTimer === null) {
    batchTimer = setTimeout(flushBatch, BATCH_DELAY_MS);
  }
}

/**
 * 处理 TDLib 返回的 JSON 对象
 */
function handleResponse(obj: Record<string, Object>): void {
  if (!obj || !obj['@type']) return;
  
  const type = obj['@type'] as string;
  
  // ⭐ 关键修复：检查 setTdlibParameters 是否真正生效
  // 只有当授权状态从 WaitTdlibParameters 变为其他状态时,才说明参数设置成功
  if (isWaitingForInitResponse && type === 'updateAuthorizationState') {
    const authState = obj['authorization_state'] as Record<string, Object> | undefined;
    if (authState && authState['@type']) {
      const authType = authState['@type'] as string;
      console.info(`[Worker] Received authorization state after init: ${authType}`);
      
      // 如果仍然是 WaitTdlibParameters,说明参数设置失败,TDLib拒绝了这些参数
      if (authType === 'authorizationStateWaitTdlibParameters') {
        console.warn('[Worker] ⚠️ TDLib not ready yet for setTdlibParameters (timing issue).');
        console.warn('[Worker] This is normal during initialization, will retry automatically.');
        // 不标记为完成,继续等待正确的响应
        return;
      }
      
      // 状态已变化(如 WaitPhoneNumber/WaitEncryptionKey 等),说明参数设置成功
      console.info(`[Worker] ✅ setTdlibParameters succeeded! Auth state changed to: ${authType}`);
      isWaitingForInitResponse = false;
      sendReadyMessage();
    }
  }
  
  // ⭐ 检查是否是某个异步请求的响应（通过 @extra 匹配）
  const extraValue = obj['@extra'];
  if (extraValue !== undefined && extraValue !== null) {
    const extraStr = String(extraValue);
    const requestId = pendingRequestExtras.get(extraStr);
    if (requestId !== undefined) {
      // 匹配到待处理请求，作为 Response 发回 UI
      pendingRequestExtras.delete(extraStr);
      
      // 检查 TDLib 是否返回了错误
      if (type === 'error') {
        const errorCode = obj['code'] as number | undefined;
        const errorMsg = obj['message'] as string | undefined;
        console.error(`[Worker] Async request error: code=${errorCode}, message=${errorMsg}, requestId=${requestId}`);
        
        const response: Response = {
          id: `resp_${Date.now()}`,
          timestamp: Date.now(),
          type: MessageType.RESPONSE,
          requestId: requestId,
          success: false,
          error: {
            code: errorCode ?? -1,
            message: errorMsg ?? 'Unknown TDLib error'
          }
        };
        workerPort.postMessage(response);
      } else {
        const response: Response = {
          id: `resp_${Date.now()}`,
          timestamp: Date.now(),
          type: MessageType.RESPONSE,
          requestId: requestId,
          success: true,
          result: obj
        };
        console.info(`[Worker] Async request response matched: ${type}, requestId=${requestId}`);
        workerPort.postMessage(response);
      }
      return;
    }
  }
  
  // 非 @extra 匹配的响应 → 作为 Update 处理
  
  // 1. 高优先级事件：立即发送（如授权状态、连接状态、新消息）
  if (type === 'updateAuthorizationState' || 
      type === 'updateConnectionState' || 
      type === 'updateNewMessage' ||
      type === 'updateDeleteMessages') {
    // ⭐ 使用协议类型
    const message: Update = {
      id: `upd_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      timestamp: Date.now(),
      type: MessageType.UPDATE,
      updateType: type,
      data: obj
    };
    workerPort.postMessage(message);
    return;
  }
  
  // 2. 低优先级/高频事件：批量合并
  if (BATCHED_UPDATE_TYPES.has(type)) {
    queueUpdate(obj);
    return;
  }
  
  // 3. 其他更新：默认立即发送
  const message: Update = {
    id: `upd_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
    timestamp: Date.now(),
    type: MessageType.UPDATE,
    updateType: type,
    data: obj
  };
  workerPort.postMessage(message);
}

/**
 * TDLib 接收循环 (批量处理模式)
 * 
 * 关键设计：
 * 1. 使用非阻塞接收(timeout=0),快速检查是否有更新
 * 2. 批量处理所有可用更新,最多处理 BATCH_SIZE 条
 * 3. 每批处理后使用 setTimeout(1) 让出控制权(比 setTimeout(0) 更可靠)
 * 4. 平衡实时更新和请求响应
 */
const RECEIVE_BATCH_SIZE = 50;  // 每批最大处理的更新数量
const RECEIVE_LOOP_DELAY = 1;   // 每批之间的延迟(ms),使用 1ms 而非 0

let receiveLoopRunning = false;

function startReceiveLoop(): void {
  if (receiveLoopRunning) {
    return;
  }
  
  receiveLoopRunning = true;
  receiveLoop();
}

function stopReceiveLoop(): void {
  receiveLoopRunning = false;
}

function receiveLoop(): void {
  if (!receiveLoopRunning || clientId === -1) {
    console.warn('[Worker] Receive loop stopped: running=' + receiveLoopRunning + ', clientId=' + clientId);
    return;
  }
  
  try {
    let processed = 0;
    
    // 批量处理:最多处理 RECEIVE_BATCH_SIZE 条更新
    while (processed < RECEIVE_BATCH_SIZE) {
      const responseJson: string | null = nativeBinding.tdlibReceiveGlobal(0); // 非阻塞
      
      if (responseJson && typeof responseJson === 'string') {
        // 收到响应/更新,立即处理
        try {
          const obj: Record<string, Object> = JSON.parse(responseJson) as Record<string, Object>;
          const type = obj['@type'] as string | undefined;
          if (type && type.startsWith('update')) {
            // 只记录重要的更新事件,避免日志过多
            if (type === 'updateNewMessage' || 
                type === 'updateChatLastMessage' ||
                type === 'updateDeleteMessages') {
              console.info(`[Worker] 📥 ${type}`);
            }
          }
          handleResponse(obj);
          processed++;
        } catch (parseError) {
          console.error('[Worker] JSON parse error:', parseError);
        }
      } else {
        // 没有更多更新,跳出循环
        break;
      }
    }
    
    // 使用 setTimeout(1) 让出控制权,确保 onmessage 能被处理
    // setTimeout(1) 在 HarmonyOS Worker 中比 setTimeout(0) 更可靠
    setTimeout(() => receiveLoop(), RECEIVE_LOOP_DELAY);
  } catch (error) {
    console.error('[Worker] Receive loop error:', error);
    // 出错后等待 100ms 再试,避免频繁报错
    setTimeout(() => receiveLoop(), 100);
  }
}

/**
 * 发送 READY 消息给 UI 线程
 */
function sendReadyMessage(): void {
  console.info('[Worker] Sending READY signal to UI thread');
  const readyMessage: Control = {
    id: 'init',
    timestamp: Date.now(),
    type: MessageType.CONTROL,
    command: ControlCommand.READY
  };
  workerPort.postMessage(readyMessage);
}

/**
 * 初始化 TDLib 客户端
 */
function initTdlib(parameters: Record<string, Object>): void {
  if (clientId !== -1) {
    console.warn('[Worker] Client already initialized');
    return;
  }
  
  try {
    // ⭐ 设置日志级别（注意：当前 NAPI 绑定需要 clientId，暂时跳过）
    // const logLevel = parameters['logVerbosityLevel'] as number ?? 1024;
    // nativeBinding.setLogVerbosityLevel(clientId, JSON.stringify({ level: logLevel }));
    // console.info(`[Worker] Log verbosity level set to ${logLevel}`);
    
    clientId = nativeBinding.tdlibCreateClientId();
    console.info(`[Worker] Client created with ID: ${clientId}`);
    
    // ⭐ 构造 setTdlibParameters 请求对象（与 TDLibApi.setTdlibParameters 保持严格一致）
    const initRequestObj: Record<string, Object> = {};
    initRequestObj['@type'] = 'setTdlibParameters';
    initRequestObj['use_test_dc'] = parameters['use_test_dc'] as boolean;
    initRequestObj['database_directory'] = parameters['database_directory'] as string;
    initRequestObj['files_directory'] = parameters['files_directory'] as string;
    // ⭐ 关键修复：database_encryption_key 应该是空字符串，而非 Uint8Array
    // TDLib JSON API 要求 bytes 类型字段为空时使用空字符串 ""
    initRequestObj['database_encryption_key'] = (parameters['database_encryption_key'] as string) ?? '';
    initRequestObj['use_file_database'] = parameters['use_file_database'] as boolean;
    initRequestObj['use_chat_info_database'] = parameters['use_chat_info_database'] as boolean;
    initRequestObj['use_message_database'] = parameters['use_message_database'] as boolean;
    initRequestObj['use_secret_chats'] = parameters['use_secret_chats'] as boolean;
    initRequestObj['api_id'] = parameters['api_id'] as number;
    initRequestObj['api_hash'] = parameters['api_hash'] as string;
    initRequestObj['system_language_code'] = parameters['system_language_code'] as string;
    initRequestObj['device_model'] = parameters['device_model'] as string;
    initRequestObj['system_version'] = parameters['system_version'] as string;
    initRequestObj['application_version'] = parameters['application_version'] as string;
    
    console.info(`[Worker] Sending setTdlibParameters to client ${clientId}`);
    console.info(`[Worker] Parameters:`);
    console.info(`  - api_id: ${initRequestObj['api_id']}`);
    console.info(`  - api_hash: ${(initRequestObj['api_hash'] as string).length} chars`);
    console.info(`  - database_directory: ${initRequestObj['database_directory']}`);
    console.info(`  - files_directory: ${initRequestObj['files_directory']}`);
    console.info(`  - database_encryption_key: "${initRequestObj['database_encryption_key']}" (${(initRequestObj['database_encryption_key'] as string).length} chars)`);
    console.info(`  - device_model: ${initRequestObj['device_model']}`);
    console.info(`  - system_version: ${initRequestObj['system_version']}`);
    console.info(`  - application_version: ${initRequestObj['application_version']}`);
    console.info(`  - system_language_code: ${initRequestObj['system_language_code']}`);
    console.info(`  - use_test_dc: ${initRequestObj['use_test_dc']}`);
    
    // ⭐ 标记正在等待初始化响应
    isWaitingForInitResponse = true;
    
    // ⭐ 关键修复：在序列化前将所有嵌套对象中的 _ 转换为 @type
    const convertedInitRequestObj = convertUnderscoreToAtType(initRequestObj) as Record<string, Object>;
    
    // ⭐ 通过 NAPI 发送请求（这是初始化阶段的特殊处理）
    nativeBinding.tdlibSendById(clientId, JSON.stringify(convertedInitRequestObj));
    console.info(`[Worker] setTdlibParameters sent successfully, waiting for authorization state...`);
    
    // ⭐ 启动接收循环（READY 消息将在收到授权状态后发送）
    startReceiveLoop();
    
  } catch (error) {
    console.error('[Worker] Init failed:', error);
    // ⭐ 使用协议类型发送错误消息
    const errorMessage: ErrorMessage = {
      id: `err_${Date.now()}`,
      timestamp: Date.now(),
      type: MessageType.ERROR,
      message: String(error)
    };
    workerPort.postMessage(errorMessage);
  }
}

// 监听来自 UI 的消息
workerPort.onmessage = (e: MessageEvents): void => {
  const msg = e.data as Record<string, Object>;
  if (!msg || !msg['type']) return;
  
  const msgType = msg['type'] as string;
  
  switch (msgType) {
    case ControlCommand.INIT:
      initTdlib(msg['parameters'] as Record<string, Object>);
      break;
    
    // ⭐ 新增：处理 CONTROL 消息（心跳等）
    case MessageType.CONTROL: {
      const command = msg['command'] as string | undefined;
      if (command === ControlCommand.HEARTBEAT) {
        // 回复心跳确认
        const heartbeatAck: Control = {
          id: msg['id'] as string,
          timestamp: Date.now(),
          type: MessageType.CONTROL,
          command: ControlCommand.HEARTBEAT_ACK
        };
        workerPort.postMessage(heartbeatAck);
      }
      // 其他控制命令可以在这里扩展
      break;
    }
    
    // ⭐ 新增：处理 REQUEST 消息（支持异步请求响应）
    case MessageType.REQUEST: {
      const reqId = msg['id'] as string;
      const method = msg['method'] as string;
      const params = msg['params'] as Record<string, Object> | undefined;
      const expectResponse = msg['expectResponse'] as boolean;
      
      if (clientId === -1) {
        // 返回错误响应
        const errorResp: Response = {
          id: `resp_${Date.now()}`,
          timestamp: Date.now(),
          type: MessageType.RESPONSE,
          requestId: reqId,
          success: false,
          error: { code: -1, message: 'TDLib not initialized' }
        };
        workerPort.postMessage(errorResp);
        return;
      }
      
      try {
        const requestObj: Record<string, Object> = {};
        requestObj['@type'] = method;
        
        // ⭐ 调试：验证 @type 是否正确设置
        console.info(`[Worker] REQUEST processing: method=${method}, expectResponse=${expectResponse}`);
        console.info(`[Worker] After setting @type: requestObj['@type']=${requestObj['@type']}`);
        
        // 复制参数（跳过 @type，避免覆盖）
        if (params) {
          const paramKeys = Object.keys(params);
          console.info(`[Worker] Params has ${paramKeys.length} keys`);
          
          for (let i = 0; i < paramKeys.length; i++) {
            const key = paramKeys[i];
            const value = params[key];
            
            // ⭐ 关键修复：跳过 @type 和 @extra，避免覆盖
            if (key === '@type') {
              console.warn(`[Worker] Found @type in params: '${value}', but keeping method: '${method}'`);
              continue;
            }
            if (key === '@extra') {
              console.warn(`[Worker] Skipping @extra from params to avoid override`);
              continue;
            }
            
            requestObj[key] = value;
            console.debug(`[Worker] Copied param[${i}]: ${key} = ${typeof value === 'object' ? '[Object]' : String(value).substring(0, 50)}`);
          }
          
          console.info(`[Worker] After copying: requestObj has ${Object.keys(requestObj).length} keys`);
          // ⭐ 关键调试：检查复制参数后 @type 是否还存在
          const typeValue = requestObj['@type'];
          console.info(`[Worker] Final @type check: value='${typeValue}'`);
        }
        
        if (expectResponse) {
          // 需要响应的请求：使用 @extra 机制
          const extraValue = `extra_${reqId}`;
          requestObj['@extra'] = extraValue;
          pendingRequestExtras.set(extraValue, reqId);
          console.info(`[Worker] td_send request: ${method}, @extra=${extraValue}`);
          
          // ⭐ 关键调试：序列化前检查最终对象
          const finalKeys = Object.keys(requestObj);
          console.info(`[Worker] Final requestObj keys (${finalKeys.length}): ${finalKeys.join(', ')}`);
          console.info(`[Worker] Final @type check: '${requestObj['@type']}'`);
          
          // ⭐ 关键修复：在序列化前将所有嵌套对象中的 _ 转换为 @type
          const convertedRequestObj = convertUnderscoreToAtType(requestObj) as Record<string, Object>;
          const jsonString = JSON.stringify(convertedRequestObj);
          console.info(`[Worker] Serialized JSON (first 300 chars): ${jsonString.substring(0, 300)}`);
          
          nativeBinding.tdlibSendById(clientId, jsonString);
        } else {
          // fire-and-forget 请求
          console.debug(`[Worker] td_send (fire-and-forget): ${method}`);
          
          // ⭐ 关键修复：在序列化前将所有嵌套对象中的 _ 转换为 @type
          const convertedRequestObj = convertUnderscoreToAtType(requestObj) as Record<string, Object>;
          nativeBinding.tdlibSendById(clientId, JSON.stringify(convertedRequestObj));
        }
      } catch (error) {
        console.error(`[Worker] Failed to handle request: ${error}`);
        const errorResp: Response = {
          id: `resp_${Date.now()}`,
          timestamp: Date.now(),
          type: MessageType.RESPONSE,
          requestId: reqId,
          success: false,
          error: { code: -1, message: String(error) }
        };
        workerPort.postMessage(errorResp);
      }
      break;
    }
      
    case ControlCommand.DESTROY:
      // ⭐ 停止轮询循环
      stopReceiveLoop();
      receiveLoopActive = false;
      if (clientId !== -1) {
        nativeBinding.tdlibDestroyClient(clientId);
        clientId = -1;
      }
      // 清理定时器
      if (batchTimer !== null) {
        clearTimeout(batchTimer);
        batchTimer = null;
      }
      workerPort.close();
      break;
    
    // ⭐ 已合并到 MessageType.CONTROL 处理逻辑中
    
    default:
      console.warn('[Worker] Unknown message type:', msg.type);
  }
};

workerPort.onerror = (): void => {
  console.error('[Worker] System error occurred');
};
