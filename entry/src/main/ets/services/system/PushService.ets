/**
 * 华为 Push Kit 推送服务
 * 封装推送初始化、Token 获取、消息接收等功能
 * 与 TDLib 消息服务集成，实现 Telegram 消息推送
 * 
 * 注意：当前 PushKit API 可能因 SDK 版本不同而有所差异
 * 需要根据实际的 @kit.PushKit API 文档进行调整
 */

import { common, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { emitter } from '@kit.BasicServicesKit';
import { BusinessError } from '@kit.BasicServicesKit';
// 根据 HarmonyOS PushKit 官方文档导入
// pushService 提供 Push Kit 的基本能力，包括获取和删除推送令牌、绑定和解绑账号、接收场景化消息
import { pushService } from '@kit.PushKit';

const TAG = 'PushService';
const DOMAIN = 0x0001;

/** 推送 Token 回调接口 */
export interface PushTokenCallback {
  onTokenReceived(token: string): void;
  onTokenError(error: string): void;
}

/** 推送消息回调接口 */
export interface PushMessageCallback {
  onMessageReceived(message: Record<string, Object>): void;
  onMessageError(error: string): void;
}

/** 推送 Token 事件数据 */
export interface PushTokenEventData {
  token: string;
}

/** 推送新消息事件数据 */
export interface PushNewMessageEventData {
  chatId: number;
  messageId: number;
}

/** 推送消息编辑事件数据 */
export interface PushMessageEditedEventData {
  chatId: number;
  messageId: number;
}

/** 推送聊天更新事件数据 */
export interface PushChatUpdateEventData {
  chatId: number;
}

/** 推送通知点击事件数据 */
export interface PushNotificationClickEventData {
  chatId: number;
  messageId: number;
}

/** 推送消息信息接口 */
export interface PushMessageInfo {
  payload: string;
  messageId: number;
  chatId: number;
}

/**
 * Push Service 单例类
 * 负责推送服务的初始化和消息处理
 */
export class PushService {
  private static instance: PushService | null = null;
  private context: common.UIAbilityContext | null = null;
  private isInitialized: boolean = false;
  private pushToken: string = '';
  
  // 回调函数
  private tokenCallback: PushTokenCallback | null = null;
  private messageCallback: PushMessageCallback | null = null;

  private constructor() {
    // 私有构造函数，单例模式
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): PushService {
    if (!PushService.instance) {
      PushService.instance = new PushService();
    }
    return PushService.instance;
  }

  /**
   * 检查 PushService 是否已初始化
   */
  public getInitialized(): boolean {
    return this.isInitialized;
  }

  /**
   * 初始化推送服务
   * @param context UIAbility 上下文
   */
  public async initialize(context: common.UIAbilityContext): Promise<boolean> {
    if (this.isInitialized) {
      hilog.warn(DOMAIN, TAG, 'PushService already initialized');
      return true;
    }

    try {
      this.context = context;
      
      // 请求通知权限（运行时请求，不需要在 module.json5 中声明）
      await this.requestNotificationPermission(context);
      
      // 根据 HarmonyOS PushKit 官方文档实现
      // 注册消息接收回调（应用在前台时接收消息）
      this.registerMessageListener();
      
      // 获取 Token（应用启动时获取）
      await this.getToken();
      
      this.isInitialized = true;
      hilog.info(DOMAIN, TAG, 'PushService initialized successfully');
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to initialize PushService: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * 请求通知权限
   * PushKit 需要通知权限才能显示推送通知
   * 注意：HarmonyOS 通知权限通常通过系统设置管理
   * PushKit 本身不需要特殊的运行时权限请求，通知权限由系统管理
   */
  private async requestNotificationPermission(context: common.UIAbilityContext): Promise<void> {
    try {
      // HarmonyOS 通知权限通过系统设置管理，不需要运行时请求
      // PushKit 会自动使用系统通知权限
      hilog.info(DOMAIN, TAG, 'Notification permission managed by system - no runtime request needed');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to check notification permission: ${JSON.stringify(error)}`);
      // 不抛出错误，允许继续初始化（用户可能稍后手动开启）
    }
  }

  /**
   * 注册 Token 监听器
   * 注意：HarmonyOS PushKit 可能不提供 Token 监听器
   * Token 变化时需要通过 getToken() 重新获取
   * 此方法保留用于未来可能的 API 更新
   */
  private registerTokenListener(): void {
    // HarmonyOS PushKit 可能不提供 Token 监听器
    // Token 变化场景：卸载重装、恢复出厂设置、显式调用 deleteToken()、设备跨区域使用
    // 建议在应用启动时调用 getToken() 检查 Token 是否变化
    hilog.info(DOMAIN, TAG, 'Token listener registration skipped - use getToken() to check token changes');
  }

  /**
   * 注册消息监听器
   * 注意：HarmonyOS PushKit 消息接收需要通过 RemoteNotificationExtAbility 实现
   * RemoteNotificationExtAbility 接收到消息后会通过事件总线发送 'push_message_received' 事件
   * PushService 监听此事件并处理消息
   */
  private registerMessageListener(): void {
    try {
      // 监听来自 RemoteNotificationExtAbility 的消息事件
      emitter.on('push_message_received', (eventData: emitter.EventData) => {
        try {
          const messageObj = eventData.data as Record<string, Object>;
          hilog.info(DOMAIN, TAG, `Push message received via event bus: ${JSON.stringify(messageObj)}`);
          
          // 通知消息回调
          if (this.messageCallback) {
            this.messageCallback.onMessageReceived(messageObj);
          }
          
          // 处理推送消息
          this.handlePushMessage(messageObj);
        } catch (error) {
          hilog.error(DOMAIN, TAG, `Failed to process push message from event bus: ${JSON.stringify(error)}`);
        }
      });
      
      hilog.info(DOMAIN, TAG, 'Message listener registered - listening to RemoteNotificationExtAbility events');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to register message listener: ${JSON.stringify(error)}`);
      // 不抛出错误，允许继续初始化
    }
  }

  /**
   * 获取推送 Token
   * 根据 HarmonyOS PushKit 官方文档：使用 pushService.getToken()
   * Token 用于标识设备和应用实例，需要上传到服务器
   * 
   * API 说明：
   * - pushService.getToken() 返回 Promise<string>
   * - 需要在 module.json5 中配置 client_id 元数据
   */
  public async getToken(): Promise<string | null> {
    if (!this.context) {
      hilog.error(DOMAIN, TAG, 'PushService context not available');
      return null;
    }

    try {
      // 根据官方文档：pushService.getToken() 返回 Promise<string>
      const token: string = await pushService.getToken();
      
      if (token && token.length > 0) {
        this.pushToken = token;
        hilog.info(DOMAIN, TAG, `Push token obtained: ${this.pushToken.substring(0, 20)}...`);
        
        // 通知回调
        if (this.tokenCallback) {
          this.tokenCallback.onTokenReceived(this.pushToken);
        }
        
        // 上传 Token 到服务器
        await this.uploadTokenToServer(this.pushToken);
        
        return this.pushToken;
      } else {
        hilog.warn(DOMAIN, TAG, 'Push token is empty');
        return null;
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to get token: ${JSON.stringify(error)}`);
      
      // 通知错误回调
      if (this.tokenCallback) {
        const errorMsg = error instanceof Error ? error.message : String(error);
        this.tokenCallback.onTokenError(errorMsg);
      }
      
      return null;
    }
  }

  /**
   * 上传 Token 到服务器
   * 需要与后端 API 集成，将 Token 发送到 Telegram 服务器
   */
  private async uploadTokenToServer(token: string): Promise<void> {
    try {
      // TODO: 实现 Token 上传逻辑
      // 需要调用 TDLibService 或直接通过 HTTP 请求将 Token 发送到服务器
      // 示例：
      // const response = await http.post('/api/push/token', { token });
      hilog.info(DOMAIN, TAG, `Token ready to upload: ${token}`);
      
      // 通过事件总线通知其他组件 Token 已获取
      const tokenEventData: PushTokenEventData = { token };
      emitter.emit('push_token_received', { priority: emitter.EventPriority.HIGH }, { data: tokenEventData });
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to upload token: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 处理推送消息
   * 解析消息内容并触发相应的 UI 更新
   */
  private handlePushMessage(messageInfo: Record<string, Object>): void {
    try {
      // 解析推送消息内容
      const payload = messageInfo['payload'] as string;
      if (!payload) {
        hilog.warn(DOMAIN, TAG, 'Push message has no payload');
        return;
      }

      const messageObj = JSON.parse(payload) as Record<string, Object>;
      const messageType = messageObj['type'] as string;
      
      hilog.info(DOMAIN, TAG, `Processing push message type: ${messageType}`);
      
      switch (messageType) {
        case 'new_message':
          // 处理新消息推送
          this.handleNewMessageNotification(messageObj);
          break;
        case 'message_edited':
          // 处理消息编辑推送
          this.handleMessageEditedNotification(messageObj);
          break;
        case 'chat_update':
          // 处理聊天更新推送
          this.handleChatUpdateNotification(messageObj);
          break;
        default:
          hilog.warn(DOMAIN, TAG, `Unknown message type: ${messageType}`);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to parse push message: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 处理新消息通知
   * 与 TDLibService 集成，触发消息更新事件
   */
  private handleNewMessageNotification(messageObj: Record<string, Object>): void {
    try {
      const chatId = messageObj['chatId'] as number;
      const messageId = messageObj['messageId'] as number;
      
      hilog.info(DOMAIN, TAG, `New message notification: chatId=${chatId}, messageId=${messageId}`);
      
      // 通过事件总线通知 UI 层有新消息
      // 直接使用 messageObj，它已经包含了所有需要的信息
      emitter.emit('push_new_message', { priority: emitter.EventPriority.HIGH }, {
        data: messageObj
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to handle new message notification: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 处理消息编辑通知
   */
  private handleMessageEditedNotification(messageObj: Record<string, Object>): void {
    try {
      const chatId = messageObj['chatId'] as number;
      const messageId = messageObj['messageId'] as number;
      
      hilog.info(DOMAIN, TAG, `Message edited notification: chatId=${chatId}, messageId=${messageId}`);
      
      // 通过事件总线通知 UI 层消息已编辑
      // 直接使用 messageObj，它已经包含了所有需要的信息
      emitter.emit('push_message_edited', { priority: emitter.EventPriority.HIGH }, {
        data: messageObj
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to handle message edited notification: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 处理聊天更新通知
   */
  private handleChatUpdateNotification(messageObj: Record<string, Object>): void {
    try {
      const chatId = messageObj['chatId'] as number;
      
      hilog.info(DOMAIN, TAG, `Chat update notification: chatId=${chatId}`);
      
      // 通过事件总线通知 UI 层聊天已更新
      // 直接使用 messageObj，它已经包含了所有需要的信息
      emitter.emit('push_chat_update', { priority: emitter.EventPriority.HIGH }, {
        data: messageObj
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to handle chat update notification: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 处理点击推送通知
   * 在 EntryAbility.onNewWant 中调用，或通过消息监听器自动触发
   */
  public handleNotificationClick(messageInfo: Record<string, Object>): void {
    try {
      const payload = messageInfo['payload'] as string;
      if (!payload) {
        hilog.warn(DOMAIN, TAG, 'Notification click has no payload');
        return;
      }

      const messageObj = JSON.parse(payload) as Record<string, Object>;
      const chatId = messageObj['chatId'] as number;
      const messageId = messageObj['messageId'] as number;
      
      hilog.info(DOMAIN, TAG, `Notification clicked: chatId=${chatId}, messageId=${messageId}`);
      
      // 通过事件总线通知需要跳转到聊天页面
      // 直接使用 messageObj，它已经包含了所有需要的信息
      emitter.emit('push_notification_click', { priority: emitter.EventPriority.HIGH }, {
        data: messageObj
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to handle notification click: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 处理从 Want 中解析的推送通知点击
   * 用于处理应用从后台被推送通知唤醒的场景
   */
  public handleNotificationClickFromWant(want: Want): void {
    try {
      // 从 Want 参数中解析推送信息
      const payload = want.parameters?.['push_payload'] as string;
      if (payload) {
        const messageObj = JSON.parse(payload) as Record<string, Object>;
        // 使用 JSON 序列化/反序列化创建类型化的 Record 对象
        const messageInfo: Record<string, Object> = JSON.parse(JSON.stringify({
          payload: payload,
          messageId: messageObj['messageId'] as number,
          chatId: messageObj['chatId'] as number
        })) as Record<string, Object>;
        this.handleNotificationClick(messageInfo);
      } else {
        // 如果没有 payload，尝试从其他参数获取
        const chatId = want.parameters?.['chatId'] as number;
        const messageId = want.parameters?.['messageId'] as number;
        
        if (chatId) {
          // 使用 JSON 序列化/反序列化创建类型化的 Record 对象
          const clickEventData: Record<string, Object> = JSON.parse(JSON.stringify({
            chatId: chatId,
            messageId: messageId || 0
          })) as Record<string, Object>;
          emitter.emit('push_notification_click', { priority: emitter.EventPriority.HIGH }, {
            data: clickEventData
          });
        }
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to handle notification click from want: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 设置 Token 回调
   */
  public setTokenCallback(callback: PushTokenCallback): void {
    this.tokenCallback = callback;
  }

  /**
   * 设置消息回调
   */
  public setMessageCallback(callback: PushMessageCallback): void {
    this.messageCallback = callback;
  }

  /**
   * 删除 Token（取消订阅推送）
   * 根据 HarmonyOS PushKit 官方文档：使用 pushService.deleteToken()
   * 
   * API 说明：
   * - pushService.deleteToken() 返回 Promise<void>
   * - 删除后需要重新调用 getToken() 才能再次接收推送
   */
  public async deleteToken(): Promise<boolean> {
    if (!this.context) {
      hilog.error(DOMAIN, TAG, 'PushService context not available');
      return false;
    }

    try {
      // 根据官方文档：pushService.deleteToken() 返回 Promise<void>
      await pushService.deleteToken();
      this.pushToken = '';
      hilog.info(DOMAIN, TAG, 'Push token deleted successfully');
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to delete token: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * 获取当前 Token
   */
  public getCurrentToken(): string {
    return this.pushToken;
  }

  /**
   * 检查是否已初始化
   */
  public isServiceInitialized(): boolean {
    return this.isInitialized;
  }

  /**
   * 清理资源
   * 注意：HarmonyOS PushKit 的 pushService 是全局单例，不需要手动清理
   * 只需要清理本地状态和回调
   */
  public dispose(): void {
    try {
      // 取消事件监听
      emitter.off('push_message_received');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to remove event listener: ${JSON.stringify(error)}`);
    }
    
    // HarmonyOS PushKit 的 pushService 是全局单例，不需要手动清理
    // 只需要清理本地状态和回调
    this.context = null;
    this.isInitialized = false;
    this.pushToken = '';
    this.tokenCallback = null;
    this.messageCallback = null;
    hilog.info(DOMAIN, TAG, 'PushService disposed');
  }
}