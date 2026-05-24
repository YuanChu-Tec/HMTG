/**
 * 远程通知扩展能力
 * 用于接收和处理华为 Push Kit 推送的远程通知消息
 *
 * 当应用被杀死或后台运行时，Push Kit 通过此 Extension 接收推送消息
 * 接收到消息后通过事件总线发送 'push_message_received' 事件
 */

import { notificationManager } from '@kit.NotificationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { emitter } from '@kit.BasicServicesKit';

// NotificationRequest 类型定义
interface GeneratedTypeLiteralInterface_1 {
  title: string;
  text: string;
}

interface NotificationContent {
  contentType: number;
  normal: GeneratedTypeLiteralInterface_1;
}

// NotificationRequest 工厂函数
function createNotificationRequest(
  id: number,
  content: NotificationContent,
  notificationSlotType: number
): notificationManager.NotificationRequest {
  const request: notificationManager.NotificationRequest = {
    id: id,
    content: content,
    notificationSlotType: notificationSlotType
  } as notificationManager.NotificationRequest;
  return request;
}

// import { RemoteExtensionAbility } from '@kit.AbilityKit'; // 暂时注释，等待 API 支持

const TAG = 'RemoteNotificationExtAbility';
const DOMAIN = 0x0001;

/**
 * 推送消息接口
 */
interface PushMessage {
  notificationId: number;
  notificationChannelId: string;
  publishedTime: number;
}

/**
 * 远程通知扩展能力
 * 继承自 RemoteExtensionAbility
 */
// export class RemoteNotificationExtAbility extends RemoteExtensionAbility {
interface EmitOptionsInterface {
  priority: number;
}

export class RemoteNotificationExtAbility {
  /**
   * 当接收到远程通知消息时调用
   * @param data 消息数据
   */
  async onRemoteNotificationReceived(data: Record<string, Object>): Promise<void> {
    try {
      hilog.info(DOMAIN, TAG, 'Remote notification received');
      hilog.info(DOMAIN, TAG, `Message data: ${JSON.stringify(data)}`);

      // 构建消息对象
      const messageObj: Record<string, Object> = {
        "notificationId": (data['notificationId'] as number) || Date.now(),
        "notificationChannelId": (data['notificationChannelId'] as string) || '',
        "publishedTime": Date.now()
      };
      // 手动复制 data 的所有属性
      const keys: Array<string> = Object.keys(data);
      for (const key of keys) {
        const value = data[key];
        if (value !== undefined) {
          messageObj[key] = value;
        }
      }

      // 通过事件总线发送消息
      // PushService 会监听此事件并处理消息
      const emitOptions: EmitOptionsInterface = { priority: emitter.EventPriority.HIGH };
      const eventData: Record<string, Object> = { "data": messageObj };
      await emitter.emit('push_message_received', emitOptions, eventData);

      hilog.info(DOMAIN, TAG, 'Push message event emitted successfully');

      // 显示本地通知（可选）
      // 如果需要显示通知栏通知，可以在这里创建 NotificationRequest
      await this.showLocalNotification(data);

    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to process remote notification: ${JSON.stringify(error)}`);
      throw new Error(String(error));
    }
  }

  /**
   * 显示本地通知
   * @param data 消息数据
   */
  private async showLocalNotification(data: Record<string, Object>): Promise<void> {
    try {
      // 解析推送消息内容
      const payload = data['payload'] as string;
      let title = '新消息';
      let content = '您收到了一条新消息';

      if (payload) {
        try {
          const messageObj = JSON.parse(payload) as Record<string, Object>;
          const messageType = messageObj['type'] as string;

          // 根据消息类型设置不同的通知标题和内容
          switch (messageType) {
            case 'new_message':
              title = messageObj['title'] as string || '新消息';
              content = messageObj['content'] as string || '您收到了一条新消息';
              break;
            case 'message_edited':
              title = '消息已编辑';
              content = '一条消息被编辑了';
              break;
            case 'chat_update':
              title = '聊天更新';
              content = '聊天信息已更新';
              break;
            default:
              title = '新消息';
              content = '您收到了一条新消息';
          }
        } catch (parseError) {
          hilog.warn(DOMAIN, TAG, `Failed to parse payload: ${JSON.stringify(parseError)}`);
        }
      }

      // 创建通知请求
      const notificationContent: NotificationContent = {
        contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: title,
          text: content
        }
      };

      const notificationIdValue: number = (data['notificationId'] as number) || Date.now();
      const localNotificationRequest: notificationManager.NotificationRequest = createNotificationRequest(
        notificationIdValue,
        notificationContent,
        notificationManager.SlotType.SOCIAL_COMMUNICATION
      );

      // 发布通知
      await notificationManager.publish(localNotificationRequest);
      hilog.info(DOMAIN, TAG, 'Local notification published successfully');

    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to show local notification: ${JSON.stringify(error)}`);
      // 不抛出错误，允许通知处理继续
    }
  }

  /**
   * 当用户点击通知栏中的通知时调用
   * @param data 消息数据
   */
  async onNotificationClicked(data: Record<string, Object>): Promise<void> {
    try {
      hilog.info(DOMAIN, TAG, 'Notification clicked by user');

      // 点击通知默认会启动应用，不需要额外处理
      // 应用启动后会在 EntryAbility 中处理跳转逻辑

    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to handle notification click: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 当通知被删除时调用
   */
  async onNotificationDeleted(): Promise<void> {
    try {
      hilog.info(DOMAIN, TAG, 'Notification deleted by user');

      // 可以在这里处理通知删除后的逻辑
      // 例如：标记消息为已读等

    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to handle notification delete: ${JSON.stringify(error)}`);
    }
  }
}
