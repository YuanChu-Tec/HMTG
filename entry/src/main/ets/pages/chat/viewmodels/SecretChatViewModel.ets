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
import { TdApiFactory, TDLibApi } from '../../../services/api';

const TAG = 'SecretChatViewModel';
const DOMAIN = 0x0001;

/**
 * 秘密聊天状态
 */
export type SecretChatState = 'pending' | 'active' | 'closed' | 'error';

/**
 * 秘密聊天信息
 */
export interface SecretChatInfo {
  id: number;
  userId: number;
  userName: string;
  userAvatar?: string;
  state: SecretChatState;
  isOutgoing: boolean;
  ttl: number; // 消息自毁时间(秒)
  keyFingerprint?: string;
  layer?: number;
  createdDate: number;
  formattedCreatedDate: string;
}

/**
 * 秘密聊天API包装器接口
 */
interface SecretChatApiWrapper {
  chat: ChatApi;
  user: UserApi;
  secretChat: SecretChatApi;
}

/**
 * 消息自动删除时间类型
 */
interface MessageAutoDeleteTimeTimer {
  '@type': string;
}

/**
 * 设置消息自动删除参数
 */
interface SetMessageAutoDeleteParams {
  chat_id: number;
  auto_delete_time: number;
  type: MessageAutoDeleteTimeTimer;
}

/**
 * TDLib getChats 参数
 */
interface GetChatsParams {
  chat_list: Record<string, string>;
}

/**
 * TDLib getChat 参数
 */
interface GetChatParams {
  chat_id: number;
}

/**
 * TDLib getSecretChat 参数
 */
interface GetSecretChatParams {
  chat_id: number;
}

/**
 * TDLib getUser 参数
 */
interface GetUserParams {
  user_id: number;
}

/**
 * TDLib createNewSecretChat 参数
 */
interface CreateSecretChatParams {
  user_id: number;
  ttl?: number;
}

/**
 * TDLib closeSecretChat 参数
 */
interface CloseSecretChatParams {
  chat_id: number;
}

/**
 * TDLib setChatMessageAutoDeleteTime 参数
 */
interface SetMessageAutoDeleteTimeParams {
  chat_id: number;
  auto_delete_time: number;
}

/**
 * TDLib 聊天响应
 */
interface ChatResponse {
  id?: number;
  type?: Record<string, Object>;
}

/**
 * TDLib 秘密聊天响应
 */
interface SecretChatResponse {
  id?: number;
  state?: string;
  ttl?: number;
  key_fingerprint?: string;
  layer?: number;
}

/**
 * TDLib 用户响应
 */
interface UserResponse {
  first_name?: string;
  last_name?: string;
}

/**
 * 秘密聊天 ViewModel
 */
export class SecretChatViewModel {
  private static instance: SecretChatViewModel;
  private secretChats: SecretChatInfo[] = [];
  private isLoading: boolean = false;

  private readonly chatApi: ChatApi;
  private readonly userApi: UserApi;
  private readonly secretChatApi: SecretChatApi;

  private constructor() {
    const tdApi = TdApiFactory.getInstance();
    const apiInstances = tdApi.createDefault();
    this.chatApi = apiInstances.chat;
    this.userApi = apiInstances.user;
    this.secretChatApi = apiInstances.secretChat;
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): SecretChatViewModel {
    if (!SecretChatViewModel.instance) {
      SecretChatViewModel.instance = new SecretChatViewModel();
    }
    return SecretChatViewModel.instance;
  }

  /**
   * 加载秘密聊天列表
   */
  public async loadSecretChats(): Promise<void> {
    this.isLoading = true;

    try {
      // 调用TDLib获取秘密聊天列表
      const getChatsParams: GetChatsParams = {
        chat_list: { '@type': 'chatListMain' }
      };
      const result = await this.chatApi.getChats(getChatsParams);

      if (result) {
        const resultRecord = result as Record<string, Object>;
        const chatIdsArray = resultRecord['chat_ids'];
        const chatIds: number[] = Array.isArray(chatIdsArray) ? chatIdsArray as number[] : [];
        
        const secretChats: SecretChatInfo[] = [];
        for (let i = 0; i < chatIds.length; i++) {
          const chatId = chatIds[i];
          // 直接传 chatId 作为参数
          const chatResult = await this.chatApi.getChat(chatId);

          if (chatResult) {
            const chatResultRecord = chatResult as Record<string, Object>;
            const chatType = chatResultRecord['type'] as Record<string, Object> | undefined;
            if (chatType) {
              const typeStr = chatType['@type'] as string;
              if (typeStr === 'chatTypeSecret') {
                const userIdValue = chatType['user_id'];
                const userId = typeof userIdValue === 'number' ? userIdValue : 0;

                // 直接传 chatId 作为参数
                const chatInfo = await this.secretChatApi.getSecretChat(chatId);

                // 直接传 userId 作为参数
                const userResult = await this.userApi.getUser(userId);

                let firstName = '';
                let lastName = '';
                let userName = 'Unknown';
                
                if (userResult) {
                  const userRecord = userResult as UserResponse;
                  firstName = userRecord.first_name || '';
                  lastName = userRecord.last_name || '';
                  userName = firstName + (lastName ? ` ${lastName}` : '');
                }

                const chatInfoRecord = chatInfo as SecretChatResponse;
                const stateStr = chatInfoRecord.state || '';
                const state: SecretChatState = stateStr === 'secretChatStateReady' ? 'active' : 'pending';
                const ttl = chatInfoRecord.ttl || 0;
                const keyFingerprint = String(chatInfoRecord.key_fingerprint || '');
                const layer = chatInfoRecord.layer || 0;

                const chatInfoItem: SecretChatInfo = {
                  id: chatId,
                  userId: userId,
                  userName: userName,
                  userAvatar: '',
                  state: state,
                  isOutgoing: false,
                  ttl: ttl,
                  keyFingerprint: keyFingerprint,
                  layer: layer,
                  createdDate: Date.now() / 1000,
                  formattedCreatedDate: this.formatDate(Date.now() / 1000)
                };
                secretChats.push(chatInfoItem);
              }
            }
          }
        }

        this.secretChats = secretChats;
        hilog.info(DOMAIN, TAG, `Loaded ${this.secretChats.length} secret chats`);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Load secret chats failed: ${JSON.stringify(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 创建新的秘密聊天
   */
  public async createSecretChat(userId: number, ttl: number = 30): Promise<number | null> {
    try {
      // 调用TDLib创建秘密聊天
      const createParams: CreateSecretChatParams = {
        user_id: userId
      };
      const result: Object | null = await this.secretChatApi.createSecretChat(userId);

      let chatId: number | null = null;
      if (result) {
        const resultRecord = result as Record<string, number>;
        const idValue = resultRecord['id'];
        if (typeof idValue === 'number') {
          chatId = idValue;
        }
      }
      
      hilog.info(DOMAIN, TAG, `Created secret chat ${chatId}`);
      return chatId;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Create secret chat failed: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 关闭秘密聊天
   */
  public async closeSecretChat(chatId: number): Promise<boolean> {
    try {
      // 调用TDLib关闭秘密聊天 - 直接传 chatId
      const result = await this.secretChatApi.closeSecretChat(chatId);

      if (result) {
        const chatIndex = this.secretChats.findIndex(c => c.id === chatId);
        if (chatIndex !== -1) {
          this.secretChats[chatIndex].state = 'closed';
        }
      }

      hilog.info(DOMAIN, TAG, `Closed secret chat ${chatId}`);
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Close secret chat failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * 设置消息自毁时间
   */
  public async setSelfDestructTimer(chatId: number, ttl: number): Promise<boolean> {
    try {
      // 调用TDLib设置自毁时间
      const autoDeleteParams: SetMessageAutoDeleteParams = {
        chat_id: chatId,
        auto_delete_time: ttl,
        type: { '@type': 'messageAutoDeleteTimeTimer' }
      };
      // API接受两个number参数: chat_id和message_auto_delete_time
      const result = await this.chatApi.setChatMessageAutoDeleteTime(chatId, ttl);

      if (result) {
        const chatIndex = this.secretChats.findIndex(c => c.id === chatId);
        if (chatIndex !== -1) {
          this.secretChats[chatIndex].ttl = ttl;
        }
      }

      hilog.info(DOMAIN, TAG, `Set self-destruct timer for chat ${chatId}: ${ttl}s`);
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Set self-destruct timer failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * 获取密钥指纹
   */
  public async getKeyFingerprint(chatId: number): Promise<string | null> {
    const chat = this.secretChats.find(c => c.id === chatId);
    return chat?.keyFingerprint || null;
  }

  /**
   * 验证密钥
   */
  public async verifyKey(chatId: number): Promise<boolean> {
    try {
      const chat = this.getSecretChat(chatId);
      if (!chat || !chat.keyFingerprint) {
        return false;
      }

      // 调用TDLib验证密钥（通过获取聊天信息间接实现）
      const result = await this.secretChatApi.getSecretChat(chatId);

      let isValid = false;
      if (result) {
        const resultRecord = result as Record<string, Object>;
        const stateValue = resultRecord['state'];
        isValid = stateValue === 'secretChatStateReady';
      }
      
      hilog.info(DOMAIN, TAG, `Verified key for chat ${chatId}: ${isValid}`);
      return isValid;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Verify key failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * 获取秘密聊天信息
   */
  public getSecretChat(chatId: number): SecretChatInfo | null {
    const found = this.secretChats.find(c => c.id === chatId);
    return found || null;
  }

  /**
   * 获取秘密聊天列表
   */
  public getSecretChats(): SecretChatInfo[] {
    return [...this.secretChats];
  }

  /**
   * 获取是否正在加载
   */
  public getIsLoading(): boolean {
    return this.isLoading;
  }

  /**
   * 格式化TTL
   */
  public formatTTL(ttl: number): string {
    if (ttl < 60) {
      return `${ttl}秒`;
    } else if (ttl < 3600) {
      return `${Math.floor(ttl / 60)}分钟`;
    } else if (ttl < 86400) {
      return `${Math.floor(ttl / 3600)}小时`;
    } else {
      return `${Math.floor(ttl / 86400)}天`;
    }
  }

  /**
   * 格式化状态
   */
  public formatState(state: SecretChatState): string {
    const stateMap: Record<string, string> = {
      'pending': '等待确认',
      'active': '活跃',
      'closed': '已关闭',
      'error': '错误'
    };
    return stateMap[state] || '未知';
  }

  /**
   * 模拟获取秘密聊天列表
   */
  private async fetchSecretChats(): Promise<SecretChatInfo[]> {
    await new Promise<void>(resolve => setTimeout(resolve, 300));

    const chats: SecretChatInfo[] = [];
    const users = ['Alice', 'Bob', 'Charlie', 'David', 'Eve'];

    for (let i = 0; i < users.length; i++) {
      const userId = i + 1;
      const now = Date.now();
      const createdDate = now - i * 7 * 86400000;

      const chatInfo: SecretChatInfo = {
        id: i,
        userId: userId,
        userName: users[i],
        userAvatar: `avatar${(i % 10) + 1}`,
        state: i === 0 ? 'pending' : (i === 1 ? 'closed' : 'active'),
        isOutgoing: i % 2 === 0,
        ttl: [30, 60, 300, 1800][i % 4],
        keyFingerprint: this.generateFingerprint(userId),
        layer: 2,
        createdDate: createdDate,
        formattedCreatedDate: this.formatDate(createdDate)
      };
      chats.push(chatInfo);
    }

    return chats;
  }

  /**
   * 模拟创建新的秘密聊天
   */
  private async createNewSecretChat(userId: number, ttl: number): Promise<number> {
    await new Promise<void>(resolve => setTimeout(resolve, 500));

    const newId = this.secretChats.length;
    const now = Date.now();

    const newChat: SecretChatInfo = {
      id: newId,
      userId: userId,
      userName: `User ${userId}`,
      state: 'pending',
      isOutgoing: true,
      ttl: ttl,
      keyFingerprint: this.generateFingerprint(userId),
      layer: 2,
      createdDate: now,
      formattedCreatedDate: this.formatDate(now)
    };
    this.secretChats.push(newChat);

    return newId;
  }

  /**
   * 生成密钥指纹
   */
  private generateFingerprint(userId: number): string {
    // 模拟生成密钥指纹
    const chars = 'ABCDEF0123456789';
    let fingerprint = '';
    for (let i = 0; i < 8; i++) {
      fingerprint += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return fingerprint;
  }

  /**
   * 格式化日期
   */
  private formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getMonth() + 1}/${date.getDate()}`;
  }

  /**
   * 销毁
   */
  public destroy(): void {
    this.secretChats = [];
  }
}
