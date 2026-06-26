/**
 * TDLibReceiver - TDLib 更新接收器（Worker 架构版本）
 *
 * 职责：
 * 1. 从 Worker 线程接收更新消息
 * 2. 分发给回调监听器和事件总线
 * 3. 处理特殊更新类型（认证状态、连接状态）
 *
 * ⚠️ 注意：不再在 UI 线程执行轮询，所有 tdlibReceiveGlobal 调用均在 Worker 线程
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { emitter } from '@kit.BasicServicesKit';
import { TDLibClient, ConnectionEventListener } from './TDLibClient';
import { tdLibCallbackDispatcher } from '../callback/TDLibCallbackDispatcher';
import { AuthService, CodeInfoCache } from '../../business/auth/AuthService';
import { eventBus } from '../../../utils/event/EventBus';

const TAG = 'TDLibReceiver';
const DOMAIN = 0x0001;

/** TDLib 认证状态事件数据 */
interface AuthStateEventData {
  state: string;
  /** 完整的认证状态对象（包含 link 等字段） */
  authState?: Record<string, Object>;
}

/** TDLib 需要验证码事件数据 */
interface NeedCodeEventData {
  code_info_type: string;
  code_length: number;
  timeout_seconds?: number; // ⭐ TDLib 返回的实际超时时间（秒）
}

export class TDLibReceiver {
  private static instance: TDLibReceiver;
  private tdClient: TDLibClient;

  private constructor() {
    this.tdClient = TDLibClient.getInstance();
    hilog.info(DOMAIN, TAG, 'TDLibReceiver created (Worker architecture)');
  }

  public static getInstance(): TDLibReceiver {
    if (!TDLibReceiver.instance) {
      TDLibReceiver.instance = new TDLibReceiver();
    }
    return TDLibReceiver.instance;
  }

  /**
   * ⚠️ 废弃方法：Worker 架构下无需在 UI 线程启动轮询
   * @deprecated Worker 线程内部已自动启动 receiveLoop
   */
  public startReceiving(): void {
    hilog.warn(DOMAIN, TAG, 'startReceiving() is deprecated. Worker handles receiving automatically.');
    // 不再启动 UI 线程轮询
  }

  /**
   * ⚠️ 废弃方法：Worker 架构下无需停止 UI 线程轮询
   * @deprecated Worker 生命周期由 TDLibClient 管理
   */
  public stopReceiving(): void {
    hilog.warn(DOMAIN, TAG, 'stopReceiving() is deprecated. Worker lifecycle managed by TDLibClient.');
  }

  /**
   * 处理来自 Worker 的更新（Worker 架构核心方法）
   * @param update Worker 发送的更新对象
   */
  public handleWorkerUpdate(update: Record<string, Object>): void {
    try {
      // TDLib JSON API 使用 @type 作为类型标识
      const updateType = (update as Record<string, Object>)['@type'] as string;

      hilog.debug(DOMAIN, TAG, `Received update: ${updateType}`);

      // 使用回调分发器处理更新
      tdLibCallbackDispatcher.onWorkerUpdate(update);

      // 【新增】通过 EventBus 广播所有 TDLib 更新事件，实现增量刷新
      this.emitToEventBus(updateType, update);

      // 特殊更新类型处理
      if (updateType === 'updateConnectionState') {
        this.handleConnectionStateUpdate(update);
      } else if (updateType === 'updateAuthorizationState') {
        this.handleAuthorizationStateUpdate(update);
      } else if (updateType === 'updateUserStatus') {
        this.handleUserStatusUpdate(update);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Handle update error: ${error}`);
    }
  }

  /**
   * 【新增】将 TDLib 更新发送到 EventBus
   * 这样 ChatListPage 可以订阅并实现增量更新
   */
  private emitToEventBus(updateType: string, update: Record<string, Object>): void {
    // 转发所有聊天相关的更新事件
    switch (updateType) {
      case 'updateNewMessage':
        eventBus.emit('updateNewMessage',
          { "message": (update as Record<string, Object>)['message'] } as Record<string, Object>);
        break;

      case 'updateChat':
        eventBus.emit('updateChat', { "chat": (update as Record<string, Object>)['chat'] } as Record<string, Object>);
        break;

      case 'updateChatLastMessage':
        eventBus.emit('updateChatLastMessage', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "last_message": (update as Record<string, Object>)['last_message']
        } as Record<string, Object>);
        break;

      case 'updateChatOrder':
        eventBus.emit('updateChatOrder', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "order": (update as Record<string, Object>)['order']
        } as Record<string, Object>);
        break;

      case 'updateChatReadInbox':
        eventBus.emit('updateChatReadInbox', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "last_read_inbox_message_id": (update as Record<string, Object>)['last_read_inbox_message_id'],
          "unread_count": (update as Record<string, Object>)['unread_count']
        } as Record<string, Object>);
        break;

      case 'updateChatReadOutbox':
        eventBus.emit('updateChatReadOutbox', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "last_read_outbox_message_id": (update as Record<string, Object>)['last_read_outbox_message_id']
        } as Record<string, Object>);
        break;

      case 'updateChatDraftMessage':
        eventBus.emit('updateChatDraftMessage', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "draft_message": (update as Record<string, Object>)['draft_message']
        } as Record<string, Object>);
        break;

      case 'updateChatIsMarkedAsUnread':
        eventBus.emit('updateChatIsMarkedAsUnread', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "is_marked_as_unread": (update as Record<string, Object>)['is_marked_as_unread']
        } as Record<string, Object>);
        break;

      case 'updateChatNotificationSettings':
        eventBus.emit('updateChatNotificationSettings', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "notification_settings": (update as Record<string, Object>)['notification_settings']
        } as Record<string, Object>);
        break;

      case 'updateChatPermissions':
        eventBus.emit('updateChatPermissions', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "permissions": (update as Record<string, Object>)['permissions']
        } as Record<string, Object>);
        break;

      case 'updateChatAvailableReactions':
        eventBus.emit('updateChatAvailableReactions', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "available_reactions": (update as Record<string, Object>)['available_reactions']
        } as Record<string, Object>);
        break;

      case 'updateChatMessageAutoDeleteTime':
        eventBus.emit('updateChatMessageAutoDeleteTime', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "message_auto_delete_time": (update as Record<string, Object>)['message_auto_delete_time']
        } as Record<string, Object>);
        break;

      case 'updateUser':
        const userObj = (update as Record<string, Object>)['user'] as Record<string, Object>;
        eventBus.emit('updateUser', {
          "user_id": userObj ? userObj['id'] : undefined,
          "user": userObj
        } as Record<string, Object>);
        break;

      case 'updateUserChatAction':
        eventBus.emit('updateUserChatAction', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "user_id": (update as Record<string, Object>)['user_id'],
          "action": (update as Record<string, Object>)['action']
        } as Record<string, Object>);
        break;

      case 'updateChatMentionCount':
        eventBus.emit('updateChatMentionCount', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "unread_mention_count": (update as Record<string, Object>)['unread_mention_count']
        } as Record<string, Object>);
        break;

      case 'updateChatPosition':
        eventBus.emit('updateChatPosition', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "position": (update as Record<string, Object>)['position']
        } as Record<string, Object>);
        break;

      // 【新增核心事件】消息删除和发送状态
      case 'updateDeleteMessages':
        eventBus.emit('updateDeleteMessages', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "message_ids": (update as Record<string, Object>)['message_ids'],
          "is_permanent": (update as Record<string, Object>)['is_permanent']
        } as Record<string, Object>);
        break;

      case 'updateMessageSendSucceeded':
        eventBus.emit('updateMessageSendSucceeded', {
          "message": (update as Record<string, Object>)['message'],
          "old_message_id": (update as Record<string, Object>)['old_message_id']
        } as Record<string, Object>);
        break;

      case 'updateMessageSendFailed':
        eventBus.emit('updateMessageSendFailed', {
          "message": (update as Record<string, Object>)['message'],
          "old_message_id": (update as Record<string, Object>)['old_message_id'],
          "error": (update as Record<string, Object>)['error']
        } as Record<string, Object>);
        break;

      case 'updateMessageContent':
        eventBus.emit('updateMessageContent', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "message_id": (update as Record<string, Object>)['message_id'],
          "new_content": (update as Record<string, Object>)['new_content']
        } as Record<string, Object>);
        break;

      // 【新增核心事件】文件下载进度
      case 'updateFile':
        eventBus.emit('updateFile', {
          "file": (update as Record<string, Object>)['file']
        } as Record<string, Object>);
        break;

      // 【新增核心事件】认证状态 - 关键：UpdateService 依赖此事件
      case 'updateAuthorizationState':
        const authState = (update as Record<string, Object>)['authorization_state'] as Record<string, Object>;
        if (authState) {
          eventBus.emit('updateAuthorizationState', {
            "authorization_state": authState
          } as Record<string, Object>);
        }
        break;

      // 【新增核心事件】连接状态
      case 'updateConnectionState':
        const state = (update as Record<string, Object>)['state'] as Record<string, Object>;
        if (state) {
          eventBus.emit('updateConnectionState', {
            "state_type": state['@type']
          } as Record<string, Object>);
        }
        break;

      // 【新增核心事件】全局选项变化
      case 'updateOption':
        eventBus.emit('updateOption', {
          "name": (update as Record<string, Object>)['name'],
          "value": (update as Record<string, Object>)['value']
        } as Record<string, Object>);
        break;

      // 【新增事件】其他重要事件
      case 'updateUserStatus':
        eventBus.emit('updateUserStatus', {
          "user_id": (update as Record<string, Object>)['user_id'],
          "status": (update as Record<string, Object>)['status']
        } as Record<string, Object>);
        break;

      case 'updateBasicGroup':
        eventBus.emit('updateBasicGroup', {
          "basic_group": (update as Record<string, Object>)['basic_group']
        } as Record<string, Object>);
        break;

      case 'updateSupergroup':
        eventBus.emit('updateSupergroup', {
          "supergroup": (update as Record<string, Object>)['supergroup']
        } as Record<string, Object>);
        break;

      case 'updateUnreadMessageCount':
        eventBus.emit('updateUnreadMessageCount', {
          "unread_count": (update as Record<string, Object>)['unread_count'],
          "unread_unmuted_count": (update as Record<string, Object>)['unread_unmuted_count']
        } as Record<string, Object>);
        break;

      case 'updateUnreadChatCount':
        eventBus.emit('updateUnreadChatCount', {
          "unread_count": (update as Record<string, Object>)['unread_count'],
          "unread_unmuted_count": (update as Record<string, Object>)['unread_unmuted_count']
        } as Record<string, Object>);
        break;

      // 【新增】聊天相关扩展事件
      case 'updateChatTitle':
        eventBus.emit('updateChatTitle', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "title": (update as Record<string, Object>)['title']
        } as Record<string, Object>);
        break;

      case 'updateChatPhoto':
        eventBus.emit('updateChatPhoto', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "photo": (update as Record<string, Object>)['photo']
        } as Record<string, Object>);
        break;

      case 'updateChatDefaultDisableNotification':
        eventBus.emit('updateChatDefaultDisableNotification', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "default_disable_notification": (update as Record<string, Object>)['default_disable_notification']
        } as Record<string, Object>);
        break;

      case 'updateChatIsPinned':
        eventBus.emit('updateChatIsPinned', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "is_pinned": (update as Record<string, Object>)['is_pinned'],
          "order": (update as Record<string, Object>)['order']
        } as Record<string, Object>);
        break;

      case 'updateChatHasScheduledMessages':
        eventBus.emit('updateChatHasScheduledMessages', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "has_scheduled_messages": (update as Record<string, Object>)['has_scheduled_messages']
        } as Record<string, Object>);
        break;

      case 'updateChatVideoChat':
        eventBus.emit('updateChatVideoChat', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "video_chat": (update as Record<string, Object>)['video_chat']
        } as Record<string, Object>);
        break;

      case 'updateChatReplyMarkup':
        eventBus.emit('updateChatReplyMarkup', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "reply_markup_message_id": (update as Record<string, Object>)['reply_markup_message_id']
        } as Record<string, Object>);
        break;

      case 'updateChatTheme':
        eventBus.emit('updateChatTheme', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "theme_name": (update as Record<string, Object>)['theme_name']
        } as Record<string, Object>);
        break;

      case 'updateChatActionBar':
        eventBus.emit('updateChatActionBar', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "action_bar": (update as Record<string, Object>)['action_bar']
        } as Record<string, Object>);
        break;

      case 'updateChatPendingJoinRequests':
        eventBus.emit('updateChatPendingJoinRequests', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "pending_join_requests_count": (update as Record<string, Object>)['pending_join_requests_count']
        } as Record<string, Object>);
        break;

      case 'updateChatMessageSender':
        eventBus.emit('updateChatMessageSender', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "message_sender_id": (update as Record<string, Object>)['message_sender_id']
        } as Record<string, Object>);
        break;

      case 'updateChatMember':
        eventBus.emit('updateChatMember', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "member": (update as Record<string, Object>)['member']
        } as Record<string, Object>);
        break;

      case 'updateChatJoinRequest':
        eventBus.emit('updateChatJoinRequest', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "join_request": (update as Record<string, Object>)['join_request']
        } as Record<string, Object>);
        break;

      // 【新增】消息相关扩展事件
      case 'updateMessageEdited':
        eventBus.emit('updateMessageEdited', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "message_id": (update as Record<string, Object>)['message_id'],
          "edit_date": (update as Record<string, Object>)['edit_date'],
          "reply_markup": (update as Record<string, Object>)['reply_markup']
        } as Record<string, Object>);
        break;

      case 'updateMessageViews':
        eventBus.emit('updateMessageViews', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "message_id": (update as Record<string, Object>)['message_id'],
          "views": (update as Record<string, Object>)['views']
        } as Record<string, Object>);
        break;

      case 'updateMessageInteractionInfo':
        eventBus.emit('updateMessageInteractionInfo', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "message_id": (update as Record<string, Object>)['message_id'],
          "interaction_info": (update as Record<string, Object>)['interaction_info']
        } as Record<string, Object>);
        break;

      case 'updateMessagePoll':
        eventBus.emit('updateMessagePoll', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "message_id": (update as Record<string, Object>)['message_id'],
          "poll": (update as Record<string, Object>)['poll']
        } as Record<string, Object>);
        break;

      case 'updateMessagePollVote':
        eventBus.emit('updateMessagePollVote', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "message_id": (update as Record<string, Object>)['message_id'],
          "user_id": (update as Record<string, Object>)['user_id'],
          "options": (update as Record<string, Object>)['options'],
          "total_voters": (update as Record<string, Object>)['total_voters']
        } as Record<string, Object>);
        break;

      case 'updateMessageLink':
        eventBus.emit('updateMessageLink', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "message_id": (update as Record<string, Object>)['message_id'],
          "link": (update as Record<string, Object>)['link']
        } as Record<string, Object>);
        break;

      case 'updateMessageLinkInfo':
        eventBus.emit('updateMessageLinkInfo', {
          "chat_id": (update as Record<string, Object>)['chat_id'],
          "message_id": (update as Record<string, Object>)['message_id'],
          "link_info": (update as Record<string, Object>)['link_info']
        } as Record<string, Object>);
        break;

      // 【新增】用户详细信息
      case 'updateUserFullInfo':
        eventBus.emit('updateUserFullInfo', {
          "user_id": (update as Record<string, Object>)['user_id'],
          "user_full_info": (update as Record<string, Object>)['user_full_info']
        } as Record<string, Object>);
        break;

      // 【新增】群组详细信息
      case 'updateBasicGroupFullInfo':
        eventBus.emit('updateBasicGroupFullInfo', {
          "basic_group_id": (update as Record<string, Object>)['basic_group_id'],
          "basic_group_full_info": (update as Record<string, Object>)['basic_group_full_info']
        } as Record<string, Object>);
        break;

      case 'updateSupergroupFullInfo':
        eventBus.emit('updateSupergroupFullInfo', {
          "supergroup_id": (update as Record<string, Object>)['supergroup_id'],
          "supergroup_full_info": (update as Record<string, Object>)['supergroup_full_info']
        } as Record<string, Object>);
        break;

      // 【新增】文件下载扩展事件
      case 'updateFileGenerationStart':
        eventBus.emit('updateFileGenerationStart', {
          "generation_id": (update as Record<string, Object>)['generation_id'],
          "original_path": (update as Record<string, Object>)['original_path'],
          "destination_path": (update as Record<string, Object>)['destination_path'],
          "conversion": (update as Record<string, Object>)['conversion']
        } as Record<string, Object>);
        break;

      case 'updateFileGenerationStop':
        eventBus.emit('updateFileGenerationStop', {
          "generation_id": (update as Record<string, Object>)['generation_id']
        } as Record<string, Object>);
        break;

      case 'updateFileDownloads':
        eventBus.emit('updateFileDownloads', {
          "total_size": (update as Record<string, Object>)['total_size'],
          "downloaded_size": (update as Record<string, Object>)['downloaded_size'],
          "files": (update as Record<string, Object>)['files']
        } as Record<string, Object>);
        break;

      case 'updateFileAddedToDownloads':
        eventBus.emit('updateFileAddedToDownloads', {
          "file_download": (update as Record<string, Object>)['file_download'],
          "count": (update as Record<string, Object>)['count']
        } as Record<string, Object>);
        break;

      case 'updateFileDownload':
        eventBus.emit('updateFileDownload', {
          "file_download": (update as Record<string, Object>)['file_download']
        } as Record<string, Object>);
        break;

      case 'updateFileRemovedFromDownloads':
        eventBus.emit('updateFileRemovedFromDownloads', {
          "file_id": (update as Record<string, Object>)['file_id'],
          "is_deleted": (update as Record<string, Object>)['is_deleted']
        } as Record<string, Object>);
        break;

      // 【新增】通知相关事件
      case 'updateNotificationGroup':
        eventBus.emit('updateNotificationGroup', {
          "notification_group_id": (update as Record<string, Object>)['notification_group_id'],
          "notification_group": (update as Record<string, Object>)['notification_group']
        } as Record<string, Object>);
        break;

      case 'updateNotification':
        eventBus.emit('updateNotification', {
          "notification_group_id": (update as Record<string, Object>)['notification_group_id'],
          "notification": (update as Record<string, Object>)['notification']
        } as Record<string, Object>);
        break;

      case 'updateActiveNotifications':
        eventBus.emit('updateActiveNotifications', {
          "groups": (update as Record<string, Object>)['groups']
        } as Record<string, Object>);
        break;

      case 'updateHavePendingNotifications':
        eventBus.emit('updateHavePendingNotifications', {
          "have_delayed_notifications": (update as Record<string, Object>)['have_delayed_notifications'],
          "have_unreceived_notifications": (update as Record<string, Object>)['have_unreceived_notifications']
        } as Record<string, Object>);
        break;

      case 'updateServiceNotification':
        eventBus.emit('updateServiceNotification', {
          "type": (update as Record<string, Object>)['type'],
          "content": (update as Record<string, Object>)['content']
        } as Record<string, Object>);
        break;

      case 'updateUnreadStoryCount':
        eventBus.emit('updateUnreadStoryCount', {
          "unread_count": (update as Record<string, Object>)['unread_count'],
          "unread_unmuted_count": (update as Record<string, Object>)['unread_unmuted_count']
        } as Record<string, Object>);
        break;

      // 【新增】账户配置事件
      case 'updateLanguagePackStrings':
        eventBus.emit('updateLanguagePackStrings', {
          "language_pack_id": (update as Record<string, Object>)['language_pack_id'],
          "strings": (update as Record<string, Object>)['strings']
        } as Record<string, Object>);
        break;

      case 'updateScopeNotificationSettings':
        eventBus.emit('updateScopeNotificationSettings', {
          "scope": (update as Record<string, Object>)['scope'],
          "notification_settings": (update as Record<string, Object>)['notification_settings']
        } as Record<string, Object>);
        break;

      case 'updateReactionNotificationSettings':
        eventBus.emit('updateReactionNotificationSettings', {
          "notification_settings": (update as Record<string, Object>)['notification_settings']
        } as Record<string, Object>);
        break;

      case 'updateDefaultReactionType':
        eventBus.emit('updateDefaultReactionType', {
          "reaction_type": (update as Record<string, Object>)['reaction_type']
        } as Record<string, Object>);
        break;

      case 'updateDiceEmojis':
        eventBus.emit('updateDiceEmojis', {
          "emojis": (update as Record<string, Object>)['emojis']
        } as Record<string, Object>);
        break;

      case 'updateAnimationSearchParameters':
        eventBus.emit('updateAnimationSearchParameters', {
          "provider": (update as Record<string, Object>)['provider'],
          "emojis": (update as Record<string, Object>)['emojis']
        } as Record<string, Object>);
        break;

      case 'updateSuggestedActions':
        eventBus.emit('updateSuggestedActions', {
          "suggested_actions": (update as Record<string, Object>)['suggested_actions']
        } as Record<string, Object>);
        break;

      case 'updateSpeedLimitNotification':
        eventBus.emit('updateSpeedLimitNotification', {
          "speed_limit": (update as Record<string, Object>)['speed_limit']
        } as Record<string, Object>);
        break;

      case 'updateAccentColors':
        eventBus.emit('updateAccentColors', {
          "colors": (update as Record<string, Object>)['colors']
        } as Record<string, Object>);
        break;

      case 'updateProfileAccentColors':
        eventBus.emit('updateProfileAccentColors', {
          "colors": (update as Record<string, Object>)['colors']
        } as Record<string, Object>);
        break;

      // 【新增】贴纸和动画事件
      case 'updateInstalledStickerSets':
        eventBus.emit('updateInstalledStickerSets', {
          "sticker_set_ids": (update as Record<string, Object>)['sticker_set_ids']
        } as Record<string, Object>);
        break;

      case 'updateTrendingStickerSets':
        eventBus.emit('updateTrendingStickerSets', {
          "sticker_sets": (update as Record<string, Object>)['sticker_sets']
        } as Record<string, Object>);
        break;

      case 'updateRecentStickers':
        eventBus.emit('updateRecentStickers', {
          "sticker_ids": (update as Record<string, Object>)['sticker_ids']
        } as Record<string, Object>);
        break;

      case 'updateFavoriteStickers':
        eventBus.emit('updateFavoriteStickers', {
          "sticker_ids": (update as Record<string, Object>)['sticker_ids']
        } as Record<string, Object>);
        break;

      case 'updateSavedAnimations':
        eventBus.emit('updateSavedAnimations', {
          "animation_ids": (update as Record<string, Object>)['animation_ids']
        } as Record<string, Object>);
        break;

      case 'updateSavedNotificationSounds':
        eventBus.emit('updateSavedNotificationSounds', {
          "notification_sound_ids": (update as Record<string, Object>)['notification_sound_ids']
        } as Record<string, Object>);
        break;

      case 'updateSelectedBackground':
        eventBus.emit('updateSelectedBackground', {
          "background": (update as Record<string, Object>)['background']
        } as Record<string, Object>);
        break;

      case 'updateChatThemes':
        eventBus.emit('updateChatThemes', {
          "chat_themes": (update as Record<string, Object>)['chat_themes']
        } as Record<string, Object>);
        break;

      case 'updateStickerSet':
        eventBus.emit('updateStickerSet', {
          "sticker_set": (update as Record<string, Object>)['sticker_set']
        } as Record<string, Object>);
        break;

      case 'updateDefaultBackground':
        eventBus.emit('updateDefaultBackground', {
          "background": (update as Record<string, Object>)['background']
        } as Record<string, Object>);
        break;

      // 【新增】故事(Story)相关事件
      case 'updateStory':
        eventBus.emit('updateStory', {
          "story": (update as Record<string, Object>)['story']
        } as Record<string, Object>);
        break;

      case 'updateStorySendSucceeded':
        eventBus.emit('updateStorySendSucceeded', {
          "story": (update as Record<string, Object>)['story'],
          "old_story_id": (update as Record<string, Object>)['old_story_id']
        } as Record<string, Object>);
        break;

      case 'updateStorySendFailed':
        eventBus.emit('updateStorySendFailed', {
          "story": (update as Record<string, Object>)['story'],
          "error": (update as Record<string, Object>)['error']
        } as Record<string, Object>);
        break;

      case 'updateStoryDeleted':
        eventBus.emit('updateStoryDeleted', {
          "story_id": (update as Record<string, Object>)['story_id']
        } as Record<string, Object>);
        break;

      case 'updateStoryStealthMode':
        eventBus.emit('updateStoryStealthMode', {
          "active_until_date": (update as Record<string, Object>)['active_until_date']
        } as Record<string, Object>);
        break;

      case 'updateStoryAvailableReactions':
        eventBus.emit('updateStoryAvailableReactions', {
          "reactions": (update as Record<string, Object>)['reactions']
        } as Record<string, Object>);
        break;

      case 'updateUserStories':
        eventBus.emit('updateUserStories', {
          "user_id": (update as Record<string, Object>)['user_id'],
          "stories": (update as Record<string, Object>)['stories']
        } as Record<string, Object>);
        break;

      case 'updateStoryInteractionInfo':
        eventBus.emit('updateStoryInteractionInfo', {
          "story_id": (update as Record<string, Object>)['story_id'],
          "interaction_info": (update as Record<string, Object>)['interaction_info']
        } as Record<string, Object>);
        break;

      case 'updateStoryList':
        eventBus.emit('updateStoryList', {
          "list": (update as Record<string, Object>)['list'],
          "story_ids": (update as Record<string, Object>)['story_ids']
        } as Record<string, Object>);
        break;

      case 'updateArchiveChatListSettings':
        eventBus.emit('updateArchiveChatListSettings', {
          "settings": (update as Record<string, Object>)['settings']
        } as Record<string, Object>);
        break;

      // 【新增】语音/视频通话(Call)相关事件
      case 'updateGroupCall':
        eventBus.emit('updateGroupCall', {
          "group_call": (update as Record<string, Object>)['group_call']
        } as Record<string, Object>);
        break;

      case 'updateGroupCallParticipant':
        eventBus.emit('updateGroupCallParticipant', {
          "group_call_id": (update as Record<string, Object>)['group_call_id'],
          "participant": (update as Record<string, Object>)['participant']
        } as Record<string, Object>);
        break;

      case 'updateNewCall':
        eventBus.emit('updateNewCall', {
          "call": (update as Record<string, Object>)['call']
        } as Record<string, Object>);
        break;

      case 'updateCall':
        eventBus.emit('updateCall', {
          "call": (update as Record<string, Object>)['call']
        } as Record<string, Object>);
        break;

      case 'updateCallAccepted':
        eventBus.emit('updateCallAccepted', {
          "call_id": (update as Record<string, Object>)['call_id']
        } as Record<string, Object>);
        break;

      case 'updateCallDiscarded':
        eventBus.emit('updateCallDiscarded', {
          "call_id": (update as Record<string, Object>)['call_id']
        } as Record<string, Object>);
        break;

      case 'updateCallState':
        eventBus.emit('updateCallState', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "state": (update as Record<string, Object>)['state']
        } as Record<string, Object>);
        break;

      case 'updateCallPrivate':
        eventBus.emit('updateCallPrivate', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "is_private": (update as Record<string, Object>)['is_private']
        } as Record<string, Object>);
        break;

      case 'updateCallRingtone':
        eventBus.emit('updateCallRingtone', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "ringtone": (update as Record<string, Object>)['ringtone']
        } as Record<string, Object>);
        break;

      case 'updateCallGroupCallId':
        eventBus.emit('updateCallGroupCallId', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "group_call_id": (update as Record<string, Object>)['group_call_id']
        } as Record<string, Object>);
        break;

      case 'updateCallConnectionState':
        eventBus.emit('updateCallConnectionState', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "state": (update as Record<string, Object>)['state']
        } as Record<string, Object>);
        break;

      case 'updateCallMediaState':
        eventBus.emit('updateCallMediaState', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "media_state": (update as Record<string, Object>)['media_state']
        } as Record<string, Object>);
        break;

      case 'updateCallVideo':
        eventBus.emit('updateCallVideo', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "video": (update as Record<string, Object>)['video']
        } as Record<string, Object>);
        break;

      case 'updateCallAudioLevel':
        eventBus.emit('updateCallAudioLevel', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "audio_level": (update as Record<string, Object>)['audio_level']
        } as Record<string, Object>);
        break;

      case 'updateCallVideoQuality':
        eventBus.emit('updateCallVideoQuality', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "video_quality": (update as Record<string, Object>)['video_quality']
        } as Record<string, Object>);
        break;

      case 'updateCallParticipant':
        eventBus.emit('updateCallParticipant', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "participant": (update as Record<string, Object>)['participant']
        } as Record<string, Object>);
        break;

      case 'updateCallScreenSharing':
        eventBus.emit('updateCallScreenSharing', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "screen_sharing": (update as Record<string, Object>)['screen_sharing']
        } as Record<string, Object>);
        break;

      case 'updateCallRecording':
        eventBus.emit('updateCallRecording', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "recording": (update as Record<string, Object>)['recording']
        } as Record<string, Object>);
        break;

      case 'updateCallTranscription':
        eventBus.emit('updateCallTranscription', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "transcription": (update as Record<string, Object>)['transcription']
        } as Record<string, Object>);
        break;

      case 'updateCallSpeechRecognition':
        eventBus.emit('updateCallSpeechRecognition', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "speech_recognition": (update as Record<string, Object>)['speech_recognition']
        } as Record<string, Object>);
        break;

      case 'updateCallLocalVideo':
        eventBus.emit('updateCallLocalVideo', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "local_video": (update as Record<string, Object>)['local_video']
        } as Record<string, Object>);
        break;

      case 'updateCallRemoteVideo':
        eventBus.emit('updateCallRemoteVideo', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "remote_video": (update as Record<string, Object>)['remote_video']
        } as Record<string, Object>);
        break;

      case 'updateCallLocalAudio':
        eventBus.emit('updateCallLocalAudio', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "local_audio": (update as Record<string, Object>)['local_audio']
        } as Record<string, Object>);
        break;

      case 'updateCallRemoteAudio':
        eventBus.emit('updateCallRemoteAudio', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "remote_audio": (update as Record<string, Object>)['remote_audio']
        } as Record<string, Object>);
        break;

      case 'updateCallLocalScreenSharing':
        eventBus.emit('updateCallLocalScreenSharing', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "local_screen_sharing": (update as Record<string, Object>)['local_screen_sharing']
        } as Record<string, Object>);
        break;

      case 'updateCallRemoteScreenSharing':
        eventBus.emit('updateCallRemoteScreenSharing', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "remote_screen_sharing": (update as Record<string, Object>)['remote_screen_sharing']
        } as Record<string, Object>);
        break;

      case 'updateCallLocalRecording':
        eventBus.emit('updateCallLocalRecording', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "local_recording": (update as Record<string, Object>)['local_recording']
        } as Record<string, Object>);
        break;

      case 'updateCallRemoteRecording':
        eventBus.emit('updateCallRemoteRecording', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "remote_recording": (update as Record<string, Object>)['remote_recording']
        } as Record<string, Object>);
        break;

      case 'updateCallLocalTranscription':
        eventBus.emit('updateCallLocalTranscription', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "local_transcription": (update as Record<string, Object>)['local_transcription']
        } as Record<string, Object>);
        break;

      case 'updateCallRemoteTranscription':
        eventBus.emit('updateCallRemoteTranscription', {
          "call_id": (update as Record<string, Object>)['call_id'],
          "remote_transcription": (update as Record<string, Object>)['remote_transcription']
        } as Record<string, Object>);
        break;

      // 【新增】其他高级功能事件
      case 'updateNewCallbackQuery':
        eventBus.emit('updateNewCallbackQuery', {
          "callback_query": (update as Record<string, Object>)['callback_query']
        } as Record<string, Object>);
        break;

      case 'updateNewInlineQuery':
        eventBus.emit('updateNewInlineQuery', {
          "inline_query": (update as Record<string, Object>)['inline_query']
        } as Record<string, Object>);
        break;

      case 'updateNewChosenInlineResult':
        eventBus.emit('updateNewChosenInlineResult', {
          "chosen_inline_result": (update as Record<string, Object>)['chosen_inline_result']
        } as Record<string, Object>);
        break;

      case 'updateNewCustomEvent':
        eventBus.emit('updateNewCustomEvent', {
          "event": (update as Record<string, Object>)['event']
        } as Record<string, Object>);
        break;

      case 'updateNewCustomQuery':
        eventBus.emit('updateNewCustomQuery', {
          "query": (update as Record<string, Object>)['query']
        } as Record<string, Object>);
        break;

      case 'updatePoll':
        eventBus.emit('updatePoll', {
          "poll": (update as Record<string, Object>)['poll']
        } as Record<string, Object>);
        break;

      case 'updatePollAnswer':
        eventBus.emit('updatePollAnswer', {
          "poll_id": (update as Record<string, Object>)['poll_id'],
          "user_id": (update as Record<string, Object>)['user_id'],
          "option_ids": (update as Record<string, Object>)['option_ids']
        } as Record<string, Object>);
        break;

      case 'updateTrendingChats':
        eventBus.emit('updateTrendingChats', {
          "chats": (update as Record<string, Object>)['chats']
        } as Record<string, Object>);
        break;

      default:
      // 其他事件不处理，让 tdLibCallbackDispatcher 处理
        break;
    }
  }

  /**
   * 处理连接状态更新
   */
  private handleConnectionStateUpdate(update: Record<string, Object>): void {
    try {
      const state = (update as Record<string, Object>)['state'] as Record<string, Object>;
      const stateType = state['_'] as string;

      hilog.info(DOMAIN, TAG, `Connection state changed to: ${stateType}`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Handle connection state update error: ${error}`);
    }
  }

  /**
   * 处理用户状态更新
   */
  private handleUserStatusUpdate(update: Record<string, Object>): void {
    try {
      const userId = (update as Record<string, Object>)['user_id'] as number;
      const status = (update as Record<string, Object>)['status'] as Object | undefined;

      if (userId && status) {
        hilog.debug(DOMAIN, TAG, `👤 User ${userId} status updated`);

        // 发送全局事件，通知 ContactService 更新缓存
        hilog.info(DOMAIN, TAG, `📢 Emitting tdlib_user_status_update for user ${userId}`);
        emitter.emit('tdlib_user_status_update', {
          data: { userId, status }
        });
        hilog.info(DOMAIN, TAG, `✅ Event emitted successfully`);
      } else {
        hilog.warn(DOMAIN, TAG, `⚠️ Invalid status update: userId=${userId}, hasStatus=${!!status}`);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Handle user status update error: ${error}`);
    }
  }

  /**
   * 处理认证状态更新
   */
  private handleAuthorizationStateUpdate(update: Record<string, Object>): void {
    try {
      const authState = (update as Record<string, Object>)['authorization_state'] as Record<string, Object>;
      // 同样修正为 @type
      const authStateType = authState['@type'] as string;

      hilog.info(DOMAIN, TAG, `🔐 Authorization state changed to: ${authStateType}`);

      // 触发认证状态机处理 - 发送全局事件
      const authData: AuthStateEventData = { state: authStateType, authState: authState };
      emitter.emit('tdlib_auth_state', { data: authData });

      // 【修复】当授权完成时，发布 tdlib.auth.completed 事件通知 CoreService 重试同步
      if (authStateType === 'authorizationStateReady') {
        hilog.info(DOMAIN, TAG, '✅ TDLib authorization completed, notifying CoreService...');
        emitter.emit('tdlib.auth.completed', { data: {} });
        hilog.info(DOMAIN, TAG, '✅ Event emitted successfully');
      }

      // 如果进入等待验证码状态，专门发送一个信号方便页面跳转
      if (authStateType === 'authorizationStateWaitCode') {
        const codeInfo = authState['code_info'] as Record<string, Object>;
        let codeInfoType = '';
        let codeLength = 0;
        let timeoutSeconds = 60; // 默认60秒

        if (codeInfo) {
          // ⭐ 关键修复：code_length 在 code_info.type.length 中，而非 code_info.length
          const typeObj = codeInfo['type'] as Record<string, Object>;
          if (typeObj) {
            codeInfoType = typeObj['@type'] as string || '';
            const lenVal = typeObj['length'] as number;
            if (typeof lenVal === 'number' && lenVal >= 4 && lenVal <= 8) {
              codeLength = lenVal;
            }
          }

          // ⭐ 提取 TDLib 返回的实际超时时间
          const timeoutVal = codeInfo['timeout'] as number;
          if (typeof timeoutVal === 'number' && timeoutVal > 0) {
            timeoutSeconds = timeoutVal;
          }
        }

        hilog.info(DOMAIN, TAG,
          `🔐 Emit tdlib_need_code: type=${codeInfoType}, length=${codeLength}, timeout=${timeoutSeconds}s`);

        // ⭐ 关键修复：在发射事件前先更新 AuthService 缓存，确保页面启动时能读取到最新数据
        const codeInfoCache: CodeInfoCache = {
          type: codeInfoType,
          length: codeLength,
          timeout: timeoutSeconds // ⭐ 保存timeout到缓存
        };
        AuthService.lastCodeInfo = codeInfoCache;

        // ⭐ 新增：记录时间戳，用于跨页面恢复倒计时
        AuthService.lastCodeTimestamp = Date.now();

        hilog.info(DOMAIN, TAG,
          `💾 Updated AuthService cache: type=${codeInfoType}, length=${codeLength}, timeout=${timeoutSeconds}s, timestamp=${AuthService.lastCodeTimestamp}`);

        const codeData: NeedCodeEventData = {
          code_info_type: codeInfoType,
          code_length: codeLength,
          timeout_seconds: timeoutSeconds
        };
        emitter.emit('tdlib_need_code', { data: codeData });
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Handle authorization state update error: ${error}`);
    }
  }
}
