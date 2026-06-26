/**
 * 消息通知服务
 * 负责处理聊天消息的推送通知
 */

import { notificationManager } from '@kit.NotificationKit';
import { Message, Chat } from '../../../models';

/**
 * 通知服务（单例）
 */
export class NotificationService {
  private static instance: NotificationService;
  private notificationId: number = 0;
  private enabled: boolean = true;
  private soundEnabled: boolean = true;
  private vibrateEnabled: boolean = true;

  private constructor() {
    // 私有构造函数
  }

  public static getInstance(): NotificationService {
    if (!NotificationService.instance) {
      NotificationService.instance = new NotificationService();
    }
    return NotificationService.instance;
  }

  /**
   * 显示消息通知
   */
  public async showNotification(message: Message, chat: Chat): Promise<void> {
    if (!this.enabled) {
      return;
    }

    try {
      const notificationRequest: notificationManager.NotificationRequest = {
        id: this.notificationId++,
        content: {
          contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: chat.title,
            text: this.getMessagePreview(message)
          }
        },
        notificationSlotType: notificationManager.SlotType.SOCIAL_COMMUNICATION
      } as notificationManager.NotificationRequest;

      await notificationManager.publish(notificationRequest);
    } catch (error) {
      console.error('Failed to show notification:', error);
    }
  }

  /**
   * 显示多条未读消息通知
   */
  public async showUnreadSummary(unreadCount: number): Promise<void> {
    if (!this.enabled || unreadCount === 0) {
      return;
    }

    try {
      const notificationRequest: notificationManager.NotificationRequest = {
        id: this.notificationId++,
        content: {
          contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: 'Telegram',
            text: `您有 ${unreadCount} 条未读消息`
          }
        },
        notificationSlotType: notificationManager.SlotType.SOCIAL_COMMUNICATION
      } as notificationManager.NotificationRequest;

      await notificationManager.publish(notificationRequest);
    } catch (error) {
      console.error('Failed to show summary notification:', error);
    }
  }

  /**
   * 取消指定通知
   */
  public async cancelNotification(notificationId: number): Promise<void> {
    try {
      await notificationManager.cancel(notificationId);
    } catch (error) {
      console.error('Failed to cancel notification:', error);
    }
  }

  /**
   * 取消所有通知
   */
  public async cancelAllNotifications(): Promise<void> {
    try {
      await notificationManager.cancelAll();
    } catch (error) {
      console.error('Failed to cancel all notifications:', error);
    }
  }

  /**
   * 设置通知启用状态
   */
  public setEnabled(enabled: boolean): void {
    this.enabled = enabled;
  }

  /**
   * 设置声音启用状态
   */
  public setSoundEnabled(enabled: boolean): void {
    this.soundEnabled = enabled;
  }

  /**
   * 设置震动启用状态
   */
  public setVibrateEnabled(enabled: boolean): void {
    this.vibrateEnabled = enabled;
  }

  /**
   * 获取消息预览文本
   */
  private getMessagePreview(message: Message): string {
    const content = message.content as string;
    if (typeof content === 'string') {
      return content;
    }
    return '新消息';
  }

  /**
   * 批量显示通知
   */
  public async showNotifications(messages: Message[], chat: Chat): Promise<void> {
    if (!this.enabled || messages.length === 0) {
      return;
    }

    // 取最新的一条消息进行通知
    const latestMessage = messages[messages.length - 1];
    await this.showNotification(latestMessage, chat);
  }
}
