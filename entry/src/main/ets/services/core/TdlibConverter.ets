/*
 * Copyright (c) 2026 HMTG Project
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { ChatEntity, MessageEntity, UserEntity, ContactEntity } from '@storage/cache';
import { ChatType } from '../../models/TDLibData';

const TAG = 'TdlibConverter';
const DOMAIN = 0x0001;

/**
 * TDLib 数据转换器
 * 负责将 TDLib JSON 对象转换为本地数据库实体
 */
export class TdlibConverter {

  /**
   * 将 TDLib Chat 对象转换为会话实体
   */
  public static convertToSession(chat: Record<string, Object>): ChatEntity {
    const id = chat['id'] as number;
    const typeObj = chat['type'] as Record<string, Object>;
    let type: string = 'private';
    
    if (typeObj) {
      const t = typeObj['@type'] as string;
      if (t === 'chatTypePrivate') type = 'private';
      else if (t === 'chatTypeBasicGroup') type = 'group';
      else if (t === 'chatTypeSupergroup') type = 'supergroup';
      else if (t === 'chatTypeSecret') type = 'secret';
    }

    // 提取最后一条消息预览
    const lastMsg = chat['last_message'] as Record<string, Object>;
    let lastContent = '';
    let lastMsgId = 0;
    let lastMsgDate = 0;

    if (lastMsg) {
      lastMsgId = lastMsg['id'] as number || 0;
      lastMsgDate = (lastMsg['date'] as number || 0) * 1000; // 转为毫秒
      
      const content = lastMsg['content'] as Record<string, Object>;
      if (content) {
        const cType = content['@type'] as string;
        if (cType === 'messageText') {
          const textObj = content['text'] as Record<string, Object>;
          lastContent = (textObj['text'] as string) || '';
        } else {
          lastContent = `[${cType.replace('message', '')}]`;
        }
      }
    }

    const entity = new ChatEntity();
    entity.chatId = id;
    entity.type = type;
    entity.title = chat['title'] as string || '';
    entity.photoJson = ''; // 头像通常需要通过 getUserProfilePhotos 或 getChatPhoto 单独获取
    entity.unreadCount = chat['unread_count'] as number || 0;
    entity.lastMessageId = lastMsgId;
    entity.lastMessageDate = Math.floor(lastMsgDate / 1000); // 转为秒
    entity.isPinned = chat['is_pinned'] as boolean || false;
    entity.isMuted = (chat['notification_settings'] as Record<string, Object>)?.['mute_for'] !== 0;
    entity.draftMessage = lastContent;
    entity.draftMessageDate = Math.floor(Date.now() / 1000);
    return entity;
  }

  /**
   * 将 TDLib Message 对象转换为消息实体
   */
  public static convertToMessage(msg: Record<string, Object>, chatId: number): MessageEntity {
    const id = msg['id'] as number;
    const senderId = (msg['sender_id'] as Record<string, Object>)?.['user_id'] as number || 0;
    const content = msg['content'] as Record<string, Object>;

    let text = '';
    let mediaFileId = '';
    let messageType = 'text';

    if (content) {
      const cType = content['@type'] as string;
      messageType = cType.replace('message', '').toLowerCase();

      if (cType === 'messageText') {
        text = ((content['text'] as Record<string, Object>)?.['text'] as string) || '';
      } else if (cType === 'messagePhoto') {
        text = (content['caption'] as Record<string, Object>)?.['text'] as string || '[图片]';
        // 这里可以进一步提取 photo.sizes[0].photo.remote.id 作为 mediaFileId
      }
    }

    const entity = new MessageEntity();
    entity.messageId = id;
    entity.chatId = chatId;
    entity.senderId = senderId;
    entity.contentJson = JSON.stringify({ text: text, type: messageType });
    entity.caption = text;
    entity.date = msg['date'] as number || 0;
    entity.editDate = (msg['edit_date'] as number) || 0;
    entity.contentType = messageType;
    entity.isOutgoing = msg['is_outgoing'] as boolean || false;
    entity.isEdited = msg['edit_date'] !== undefined && (msg['edit_date'] as number) > 0;
    return entity;
  }

  /**
   * 将 TDLib User 对象转换为用户实体
   */
  public static convertToUser(user: Record<string, Object>): UserEntity {
    const id = user['id'] as number || 0;
    const firstName = user['first_name'] as string || '';
    const lastName = user['last_name'] as string || '';
    const username = user['username'] as string || '';
    const phoneNumber = user['phone_number'] as string || '';

    // 提取用户类型
    const typeObj = user['type'] as Record<string, Object>;
    const isBot = typeObj?.['@type'] === 'userTypeBot';

    // 提取在线状态
    const statusObj = user['status'] as Record<string, Object>;
    let onlineStatus = 'offline';
    let lastSeen = 0;
    if (statusObj) {
      const statusType = statusObj['@type'] as string;
      if (statusType === 'userStatusOnline') {
        onlineStatus = 'online';
        lastSeen = statusObj['expires'] as number || 0;
      } else if (statusType === 'userStatusOffline') {
        onlineStatus = 'offline';
        lastSeen = statusObj['was_online'] as number || 0;
      } else if (statusType === 'userStatusRecently') {
        onlineStatus = 'recently';
      }
    }

    // 提取头像文件ID
    let profilePhotoFileId = '';
    const profilePhoto = user['profile_photo'] as Record<string, Object>;
    if (profilePhoto) {
      const small = profilePhoto['small'] as Record<string, Object>;
      if (small) {
        profilePhotoFileId = String(small['id'] || '');
      }
    }

    const entity = new UserEntity();
    entity.userId = id;
    entity.firstName = firstName;
    entity.lastName = lastName;
    entity.username = username;
    entity.phoneNumber = phoneNumber;
    entity.isBot = isBot;
    entity.isPremium = user['is_premium'] as boolean || false;
    entity.isVerified = user['is_verified'] as boolean || false;
    entity.statusJson = JSON.stringify(statusObj || {});
    entity.profilePhotoFileId = profilePhotoFileId;
    entity.onlineStatus = onlineStatus;
    entity.lastSeen = lastSeen;
    entity.lastUpdated = Date.now();

    return entity;
  }

  /**
   * 将 TDLib User 对象转换为联系人实体
   */
  public static convertToContact(user: Record<string, Object>): ContactEntity {
    const id = user['id'] as number || 0;
    const firstName = user['first_name'] as string || '';
    const lastName = user['last_name'] as string || '';
    const username = user['username'] as string || '';
    const phoneNumber = user['phone_number'] as string || '';

    // 提取头像文件ID
    let avatarFileId = '';
    const profilePhoto = user['profile_photo'] as Record<string, Object>;
    if (profilePhoto) {
      const small = profilePhoto['small'] as Record<string, Object>;
      if (small) {
        avatarFileId = String(small['id'] || '');
      }
    }

    // 提取用户类型
    const typeObj = user['type'] as Record<string, Object>;
    const isBot = typeObj?.['@type'] === 'userTypeBot';

    const entity = new ContactEntity();
    entity.userId = id;
    entity.firstName = firstName;
    entity.lastName = lastName;
    entity.fullName = `${firstName} ${lastName}`.trim();
    entity.username = username;
    entity.phoneNumber = phoneNumber;
    entity.avatarFileId = avatarFileId;
    entity.isBot = isBot;
    entity.isPremium = user['is_premium'] as boolean || false;
    entity.isVerified = user['is_verified'] as boolean || false;
    entity.syncStatus = 'synced';
    entity.lastUpdated = Date.now();

    return entity;
  }
}

