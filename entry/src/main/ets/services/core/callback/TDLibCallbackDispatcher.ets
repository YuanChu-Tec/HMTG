/**
 * TDLib 回调分发器 - 华为 HarmonyOS 最佳实践 (Worker 架构版本)
 * 解决 TDLib 原生回调阻塞 UI 线程的问题
 * 通过批量处理、优先级排序、Worker 线程等方式提升性能
 * 
 * 核心优化:
 * 1. 回调分组: 按 chatId 分组,批量处理相同聊天的回调
 * 2. 优先级排序: 重要回调(updateNewMessage)优先处理
 * 3. Worker 处理: 耗时操作移至 Worker 线程
 * 4. 防抖合并: 快速连续的回调合并为一个批次
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { EventBus } from '../../../utils';

const TAG = 'TDLibCallbackDispatcher';
const DOMAIN = 0x0001;

/**
 * TDLib 回调接口
 */
export interface TDLibCallback {
  type: string; // '@type' 的替代
  chat_id?: number;
  message?: Record<string, Object>;
  data?: Record<string, Object>;
}

/**
 * 聊天回调分组接口
 */
interface ChatCallbackGroup {
  callbacks: TDLibCallback[];
  timer?: number;
}

/**
 * 处理后的回调批次
 */
interface ProcessedBatch {
  type: string;
  callbacks: TDLibCallback[];
  priority: number;
}

export class TDLibCallbackDispatcher {
  private static instance: TDLibCallbackDispatcher;

  // 回调队列
  private callbackQueue: TDLibCallback[] = [];
  
  // 按 chatId 分组的回调
  private groupedCallbacks: Map<number, ChatCallbackGroup> = new Map();
  
  // 分组计时器
  private groupedTimers: Set<number> = new Set();
  
  // 是否正在处理
  private isProcessing = false;

  // 华为建议：回调优先级分类 (使用 Map 替代 Record)
  private readonly PRIORITY_MAP: Map<string, number> = new Map([
    ['updateNewMessage', 0],           // 最高优先级：新消息
    ['updateMessageEdited', 1],         // 高优先级：消息编辑
    ['updateDeleteMessages', 1],         // 高优先级：消息删除
    ['updateUserChatAction', 2],        // 中高优先级：用户操作
    ['updateChatLastMessage', 2],       // 中高优先级：最后消息
    ['updateChatPosition', 3],          // 中优先级：聊天位置
    ['updateChatReadOutbox', 3],       // 中优先级：已读状态
    ['updateChatReadInbox', 3],        // 中优先级：已读状态
    ['updateUser', 4],                 // 低优先级：用户信息
    ['updateChatPhoto', 4],             // 低优先级：聊天头像
    ['updateBasicGroup', 5],            // 最低优先级：群组信息
    ['updateSupergroup', 5],            // 最低优先级：超级群组
    ['updateUnreadMessageCount', 6],    // 最低优先级：未读数
    ['updateFile', 6]                  // 最低优先级：文件信息
  ]);

  // 华为策略：批量处理配置 (使用常量替代对象字面量)
  private readonly BATCH_CONFIG_GROUP_MAX_SIZE = 10;      // 相同聊天最多 10 个回调触发一次处理
  private readonly BATCH_CONFIG_GROUP_TIMEOUT = 200;       // 相同聊天 200ms 内触发一次处理
  private readonly BATCH_CONFIG_MAX_QUEUE_SIZE = 100;     // 队列最大 100 个回调
  private readonly BATCH_CONFIG_PROCESS_BATCH_SIZE = 20;    // 每次最多处理 20 个回调

  private constructor() {
    hilog.info(DOMAIN, TAG, 'TDLib 回调分发器初始化');
  }

  public static getInstance(): TDLibCallbackDispatcher {
    if (!TDLibCallbackDispatcher.instance) {
      TDLibCallbackDispatcher.instance = new TDLibCallbackDispatcher();
    }
    return TDLibCallbackDispatcher.instance;
  }

  /**
   * 接收原生回调 (从 C++ 层) Worker 架构版本
   * 这是 TDLib 原生代码调用的入口点
   * 
   * Worker 架构说明:
   * - 在 Worker 模式下，TDLib 运行在独立 Worker 线程
   * - Worker 会将更新发送到 UI 线程
   * - 此方法仍然可用，用于降级兼容
   */
  public onNativeCallback(callbackJson: string): void {
    try {
      const callback = JSON.parse(callbackJson) as TDLibCallback;
      const callbackType = this.getCallbackTypeSafe(callback);
      
      hilog.debug(DOMAIN, TAG, `收到 TDLib 回调：${callbackType}`);

      const chatId = this.extractChatId(callback);

      if (chatId) {
        // 按聊天分组，便于批量处理
        this.groupByChatId(chatId, callback);
      } else {
        // 非聊天相关回调，加入主队列
        this.addToQueue(callback);
      }

      // 触发处理
      this.scheduleProcessing();
    } catch (error) {
      hilog.error(DOMAIN, TAG, `处理 TDLib 回调失败：${JSON.stringify(error)}`);
    }
  }

  /**
   * 处理 Worker 推送的更新 (Worker 架构)
   * @param update Worker 发送的更新数据
   */
  public onWorkerUpdate(update: Record<string, Object>): void {
    try {
      // Worker 更新已经是解析后的对象
      const dataValue = this.getSafeProperty<Object>(update, 'data');
      const callback: TDLibCallback = (dataValue as TDLibCallback) || this.convertToTDLibCallback(update);
      const callbackType = this.getCallbackTypeSafe(callback);
      
      hilog.debug(DOMAIN, TAG, `收到 Worker 更新：${callbackType}`);

      // 直接使用 Worker 传来的数据，无需再次解析
      const chatId = this.extractChatId(callback);

      if (chatId) {
        this.groupByChatId(chatId, callback);
      } else {
        this.addToQueue(callback);
      }

      this.scheduleProcessing();
    } catch (error) {
      hilog.error(DOMAIN, TAG, `处理 Worker 更新失败：${JSON.stringify(error)}`);
    }
  }

  /**
   * 从回调中提取 chatId
   */
  private extractChatId(callback: TDLibCallback): number | null {
    // 使用类型守卫检查属性是否存在
    if (callback.chat_id !== undefined && callback.chat_id !== null) {
      return Number(callback.chat_id);
    }
    return null;
  }

  /**
   * 安全获取对象属性 (避免索引访问)
   */
  private getSafeProperty<T>(obj: Record<string, Object>, key: string): T | undefined {
    const keys = Object.keys(obj);
    for (let i = 0; i < keys.length; i++) {
      if (keys[i] === key) {
        return obj[keys[i]] as T;
      }
    }
    return undefined;
  }

  /**
   * 按 chatId 分组回调
   * 华为策略：相同聊天的回调批量处理，减少 UI 更新次数
   */
  private groupByChatId(chatId: number, callback: TDLibCallback): void {
    let group = this.groupedCallbacks.get(chatId);
      
    if (!group) {
      group = { callbacks: [] };
      this.groupedCallbacks.set(chatId, group);
    }
  
    group.callbacks.push(callback);
  
    // 华为策略：相同聊天回调满 10 个或 200ms 触发处理
    if (group.callbacks.length >= this.BATCH_CONFIG_GROUP_MAX_SIZE) {
      this.processChatGroup(chatId);
    } else if (!this.groupedTimers.has(chatId)) {
      const timer = setTimeout(() => {
        this.processChatGroup(chatId);
      }, this.BATCH_CONFIG_GROUP_TIMEOUT);
      this.groupedTimers.add(chatId);
    }
  }

  /**
   * 将 Record 转换为 TDLibCallback（安全转换）
   */
  private convertToTDLibCallback(data: Record<string, Object>): TDLibCallback {
    const result: TDLibCallback = {
      type: this.getSafeProperty<string>(data, 'type') || ''
    };
    
    // 使用类型断言避免索引访问
    const chatIdValue = this.getSafeProperty<number>(data, 'chat_id');
    if (chatIdValue !== undefined) {
      result.chat_id = chatIdValue;
    }
    const messageValue = this.getSafeProperty<Record<string, Object>>(data, 'message');
    if (messageValue !== undefined) {
      result.message = messageValue;
    }
    const dataValue = this.getSafeProperty<Record<string, Object>>(data, 'data');
    if (dataValue !== undefined) {
      result.data = dataValue;
    }
    
    return result;
  }
  
  /**
   * 获取回调类型（安全访问）
   */
  private getCallbackType(callback: TDLibCallback): string {
    return this.getCallbackTypeSafe(callback);
  }
  
  /**
   * 安全获取回调类型
   */
  private getCallbackTypeSafe(callback: TDLibCallback): string {
    // 直接访问 type 属性（点语法）
    const typeProp: string | undefined = callback.type;
    if (typeProp !== undefined) {
      return typeProp;
    }
    return '';
  }

  /**
   * 安全获取字符串属性
   */
  private getStringProperty(obj: TDLibCallback, key: string): string | undefined {
    // 根据 key 返回对应属性值（使用点语法）
    if (key === 'type') {
      return obj.type;
    }
    // 其他属性无法处理，返回 undefined
    return undefined;
  }

  /**
   * 处理单个聊天的回调组
   */
  private async processChatGroup(chatId: number): Promise<void> {
    const group = this.groupedCallbacks.get(chatId);
    if (!group || group.callbacks.length === 0) return;
  
    hilog.debug(DOMAIN, TAG, `处理聊天 ${chatId} 的 ${group.callbacks.length} 个回调`);
  
    // 合并相似回调 (华为优化技巧)
    const merged = this.mergeSimilarCallbacks(group.callbacks);

    // 使用 Worker 处理，避免阻塞 UI
    try {
      // await WorkerThreadManager.getInstance().processTDLibCallbacks(merged);
      // 暂时降级到主线程直接分发
      merged.forEach(callback => this.dispatchCallback(callback));
      hilog.debug(DOMAIN, TAG, `聊天 ${chatId} 回调处理完成`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `处理失败：${JSON.stringify(error)}`);
      // 降级：直接分发回调
      merged.forEach(callback => this.dispatchCallback(callback));
    }

    // 清理
    this.groupedCallbacks.delete(chatId);
    if (this.groupedTimers.has(chatId)) {
      this.groupedTimers.delete(chatId);
    }
  }

  /**
   * 合并相似回调
   * 华为策略：相同类型的连续更新合并为一个批次
   */
  private mergeSimilarCallbacks(callbacks: TDLibCallback[]): TDLibCallback[] {
    const merged: TDLibCallback[] = [];
    let currentBatch: TDLibCallback[] = [];
  
    for (const callback of callbacks) {
      if (currentBatch.length === 0) {
        currentBatch.push(callback);
      } else {
        const currentType = this.getCallbackType(currentBatch[0]);
        const callbackType = this.getCallbackType(callback);
        if (currentType === callbackType) {
          currentBatch.push(callback);
        } else {
          // 不同类型，处理当前批次，开始新批次
          merged.push(this.mergeBatch(currentBatch));
          currentBatch = [callback];
        }
      }
    }
  
    // 处理最后一个批次
    if (currentBatch.length > 0) {
      merged.push(this.mergeBatch(currentBatch));
    }
  
    return merged;
  }

  /**
   * 合并一批回调
   */
  private mergeBatch(callbacks: TDLibCallback[]): TDLibCallback {
    if (callbacks.length === 1) {
      return callbacks[0];
    }
  
    const firstCallback = callbacks[0];
    const type = this.getCallbackType(firstCallback);
      
    // 特殊处理：updateChatLastMessage，只保留最后一个
    if (type === 'updateChatLastMessage') {
      return callbacks[callbacks.length - 1];
    }
  
    // 默认：返回第一个
    return callbacks[0];
  }
  
  /**
   * 获取回调类型优先级
   */
  private getCallbackPriority(callback: TDLibCallback): number {
    const type = this.getCallbackType(callback);
    return this.PRIORITY_MAP.get(type) ?? 99;
  }

  /**
   * 添加到主队列
   */
  private addToQueue(callback: TDLibCallback): void {
    // 队列大小限制
    if (this.callbackQueue.length >= this.BATCH_CONFIG_MAX_QUEUE_SIZE) {
      hilog.warn(DOMAIN, TAG, '回调队列已满,丢弃最旧的回调');
      this.callbackQueue.shift();
    }

    this.callbackQueue.push(callback);
  }

  /**
   * 安排处理
   */
  private scheduleProcessing(): void {
    if (this.isProcessing) return;
  
    // 延迟调用处理
    setTimeout(() => {
      this.processQueue();
    }, 0);
  
    this.isProcessing = true;
  }

  /**
   * 按优先级排序，批量处理
   */
  private processQueue(): void {
    if (this.callbackQueue.length === 0) {
      this.isProcessing = false;
      return;
    }
  
    // 按优先级排序
    this.callbackQueue.sort((a, b) => {
      return this.getCallbackPriority(a) - this.getCallbackPriority(b);
    });

    // 批量处理 (每批最多 20 个)
    const batchSize = Math.min(
      this.BATCH_CONFIG_PROCESS_BATCH_SIZE,
      this.callbackQueue.length
    );

    const batch = this.callbackQueue.splice(0, batchSize);
    
    hilog.debug(DOMAIN, TAG, `批量处理 ${batch.length} 个回调`);

    // 批量分发
    batch.forEach(callback => {
      this.dispatchCallback(callback);
    });

    // 如果还有回调，安排下一帧处理
    if (this.callbackQueue.length > 0) {
      setTimeout(() => {
        this.processQueue();
      }, 0);
    } else {
      this.isProcessing = false;
    }
  }

  /**
   * 分发单个回调到事件总线
   */
  private dispatchCallback(callback: TDLibCallback): void {
    const type = this.getCallbackTypeSafe(callback);
    
    // 发送到全局事件总线 - 使用类型转换
    EventBus.getInstance().emit('tdlib_callback', this.convertToRecord(callback));

    // 特殊处理：发送专门事件（根据类型）
    switch (type) {
      case 'updateNewMessage':
        EventBus.getInstance().emit('message_new', callback.message || {} as Record<string, Object>);
        break;
      case 'updateMessageEdited':
        EventBus.getInstance().emit('message_edited', callback.message || {} as Record<string, Object>);
        break;
      case 'updateDeleteMessages':
        EventBus.getInstance().emit('message_deleted', this.convertToRecord(callback));
        break;
      case 'updateChatLastMessage':
        EventBus.getInstance().emit('chat_last_message', this.convertToRecord(callback));
        break;
      case 'updateChat':
        EventBus.getInstance().emit('updateChat', this.convertToRecord(callback));
        break;
      case 'updateChatOrder':
        EventBus.getInstance().emit('updateChatOrder', this.convertToRecord(callback));
        break;
      case 'updateChatReadInbox':
        EventBus.getInstance().emit('updateChatReadInbox', this.convertToRecord(callback));
        break;
      case 'updateChatDraftMessage':
        EventBus.getInstance().emit('updateChatDraftMessage', this.convertToRecord(callback));
        break;
      case 'updateChatIsPinned':
        EventBus.getInstance().emit('updateChatIsPinned', this.convertToRecord(callback));
        break;
      case 'updateChatNotificationSettings':
        EventBus.getInstance().emit('updateChatNotificationSettings', this.convertToRecord(callback));
        break;
      case 'updateUser':
        EventBus.getInstance().emit('updateUser', this.convertToRecord(callback));
        break;
      case 'updateUserStatus':
        EventBus.getInstance().emit('updateUserStatus', this.convertToRecord(callback));
        break;
      case 'updateNewChat':
        EventBus.getInstance().emit('updateNewChat', this.convertToRecord(callback));
        break;
      default:
        // 其他事件通过 tdlib_callback 统一分发
        break;
    }
  }

  /**
   * 将 TDLibCallback 转换为 Record（用于事件发送）
   */
  private convertToRecord(callback: TDLibCallback): Record<string, Object> {
    const result: Record<string, Object> = {};
    
    // 直接复制已知属性（使用点语法）
    if (callback.type !== undefined) {
      result['type'] = callback.type;
    }
    if (callback.chat_id !== undefined) {
      result['chat_id'] = callback.chat_id;
    }
    if (callback.message !== undefined) {
      result['message'] = callback.message;
    }
    if (callback.data !== undefined) {
      result['data'] = callback.data;
    }
    
    return result;
  }

  /**
   * 清空队列
   * 用于页面销毁或需要重置时
   */
  public clear(): void {
    hilog.info(DOMAIN, TAG, '清空回调队列');
    
    this.callbackQueue = [];
    this.groupedCallbacks.clear();
    
    // 清除所有计时器
    this.groupedTimers.forEach(chatId => {
      clearTimeout(chatId);
    });
    this.groupedTimers.clear();
    
    this.isProcessing = false;
  }

  /**
   * 获取统计信息
   */
  public getStats(): StatsInfo {
    const result: StatsInfo = {
      queueSize: this.callbackQueue.length,
      groupedChats: this.groupedCallbacks.size,
      isProcessing: this.isProcessing
    };
    return result;
  }
}

/**
 * 统计信息接口
 */
interface StatsInfo {
  queueSize: number;
  groupedChats: number;
  isProcessing: boolean;
}

// 导出单例
export const tdLibCallbackDispatcher = TDLibCallbackDispatcher.getInstance();
