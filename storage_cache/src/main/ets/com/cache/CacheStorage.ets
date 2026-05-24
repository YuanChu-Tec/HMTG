// storage_cache/src/main/ets/com/cache/CacheStorage.ets
import { common } from '@kit.AbilityKit';
import { DatabaseManager } from './database/DatabaseManager';
import { MMKVManager } from './mmkv/MMKVManager';
import { DiskLruCacheManager } from './disk/DiskLruCacheManager';
import { ImageKnifeManager } from './image/ImageKnifeManager';
import {
  MessageEntity, ChatEntity, MediaEntity, ContactEntity, StoryEntity,
  UserEntity, ChatFilterEntity, ChatBoostEntity, BotCommandEntity,
  ReactionEntity, ChatPositionEntity, SecretChatEntity, PollOptionEntity,
  StickerSetEntity, StickerEntity, BotInfoEntity, GiftEntity, UpgradedGiftEntity,
  ReceivedGiftEntity, BusinessInfoEntity, BusinessChatLinkEntity, StarTransactionEntity,
  InvoiceEntity, ChatStatisticsEntity, NotificationSoundEntity, BackgroundEntity,
  GameHighScoreEntity, WebAppSessionEntity
} from './model/TelegramEntity';
import { util } from '@kit.ArkTS';
import { CacheLogger } from './utils/Logger';

const TAG = 'CacheStorage';

// 缓存配置常量
class CacheConfigDefaults {
  static readonly messageCacheSize: number = 500;
  static readonly chatCacheSize: number = 50;
  static readonly userCacheSize: number = 200;
  static readonly preloadMessageCount: number = 20;
  static readonly batchInsertSize: number = 100;
}

// 缓存命中统计
interface CacheHitMissStats {
  hits: number;
  misses: number;
}

// 缓存命中率报告
interface CacheHitRateReport {
  hitRate: number;
  total: number;
}

// 缓存统计信息
export interface CacheStats {
  hits: number;
  misses: number;
  evictions: number;
  size: number;
  capacity: number;
}

// 缓存配置选项
export interface CacheConfig {
  messageCacheSize?: number;
  chatCacheSize?: number;
  userCacheSize?: number;
}

// 消息数据接口（用于便捷保存）
export interface MessageContent {
  _constructor: string;
}
export interface MessageData {
  id: number;
  senderId: number;
  date: number;
  content: MessageContent;
  entities?: object;
  replyToMessageId?: number;
}

// Story 内容接口
interface StoryPhoto {
  id?: string;
}
interface StoryPhotoSize {
  photo?: StoryPhoto;
}
interface StoryVideo {
  video?: StoryPhoto;
}
interface StoryPhotoContainer {
  sizes?: StoryPhotoSize[];
}
interface StoryContent {
  photo?: StoryPhotoContainer;
  video?: StoryVideo;
}

// 回收站恢复数据接口
interface RestoreChatData {
  chat: ChatEntity;
  messages: MessageEntity[];
}

// 回收站项目接口
interface RecycleBinItemView {
  id: number;
  itemId: number;
  itemType: string;
  deletedAt: number;
  expiresAt: number;
  chatId?: number;
  title?: string;
}

// 回收站统计接口
interface RecycleBinStats {
  total: number;
  byType: Record<string, number>;
}

export class CacheStorage {
  private static instance: CacheStorage;
  private context: common.UIAbilityContext | null = null;

  private _database: DatabaseManager | null = null;
  private _mmkv: MMKVManager | null = null;
  private _diskCache: DiskLruCacheManager | null = null;
  private _imageKnife: ImageKnifeManager | null = null;

  // 内存二级缓存（使用可配置容量）
  private messageMemCache: util.LRUCache<number, MessageEntity>;
  private chatMemCache: util.LRUCache<number, ChatEntity>;
  private userMemCache: util.LRUCache<number, UserEntity>;

  // 缓存统计
  private messageStats: CacheHitMissStats = { hits: 0, misses: 0 };
  private chatStats: CacheHitMissStats = { hits: 0, misses: 0 };
  private userStats: CacheHitMissStats = { hits: 0, misses: 0 };

  // 批量消息缓冲区
  private messageBatchBuffer: MessageEntity[] = [];
  private batchTimer: number | null = null;
  private readonly BATCH_DELAY: number = 100; // 100ms 延迟

  private constructor(context: common.UIAbilityContext, config?: CacheConfig) {
    this.context = context;
    this._database = DatabaseManager.getInstance(context);
    this._mmkv = MMKVManager.getInstance(context);
    this._diskCache = DiskLruCacheManager.getInstance(context);
    this._imageKnife = ImageKnifeManager.getInstance(context);

    // 初始化缓存（使用配置或默认值）
    const msgSize = config?.messageCacheSize ?? CacheConfigDefaults.messageCacheSize;
    const chatSize = config?.chatCacheSize ?? CacheConfigDefaults.chatCacheSize;
    const userSize = config?.userCacheSize ?? CacheConfigDefaults.userCacheSize;

    this.messageMemCache = new util.LRUCache(msgSize);
    this.chatMemCache = new util.LRUCache(chatSize);
    this.userMemCache = new util.LRUCache(userSize);
  }

  /**
   * 获取实例（支持配置）
   */
  public static getInstance(context?: common.UIAbilityContext, config?: CacheConfig): CacheStorage {
    if (!CacheStorage.instance && context) {
      CacheStorage.instance = new CacheStorage(context, config);
    }
    return CacheStorage.instance;
  }

  /**
   * 重新配置缓存（会清空现有缓存）
   */
  public reconfigure(config: CacheConfig): void {
    if (config.messageCacheSize) {
      this.messageMemCache.clear();
      this.messageMemCache = new util.LRUCache(config.messageCacheSize);
    }
    if (config.chatCacheSize) {
      this.chatMemCache.clear();
      this.chatMemCache = new util.LRUCache(config.chatCacheSize);
    }
    if (config.userCacheSize) {
      this.userMemCache.clear();
      this.userMemCache = new util.LRUCache(config.userCacheSize);
    }
    this.resetStats();
  }

  /**
   * 重置统计
   */
  resetStats(): void {
    this.messageStats = { hits: 0, misses: 0 };
    this.chatStats = { hits: 0, misses: 0 };
    this.userStats = { hits: 0, misses: 0 };
  }

  /**
   * 等待数据库初始化完成
   * 在访问数据库前调用此方法确保表已创建
   */
  public async waitForReady(): Promise<void> {
    if (this._database) {
      await this._database.waitForInit();
    }
  }

  get database(): DatabaseManager { return this._database!; }
  get mmkv(): MMKVManager { return this._mmkv!; }
  get diskCache(): DiskLruCacheManager { return this._diskCache!; }
  get imageKnife(): ImageKnifeManager { return this._imageKnife!; }

  // ========== 缓存统计方法 ==========

  /**
   * 获取缓存统计信息
   */
  getCacheStats(): Map<string, CacheStats> {
    const result = new Map<string, CacheStats>();
    result.set('message', {
      hits: this.messageStats.hits,
      misses: this.messageStats.misses,
      evictions: 0,
      size: this.messageMemCache.length,
      capacity: CacheConfigDefaults.messageCacheSize
    });
    result.set('chat', {
      hits: this.chatStats.hits,
      misses: this.chatStats.misses,
      evictions: 0,
      size: this.chatMemCache.length,
      capacity: CacheConfigDefaults.chatCacheSize
    });
    result.set('user', {
      hits: this.userStats.hits,
      misses: this.userStats.misses,
      evictions: 0,
      size: this.userMemCache.length,
      capacity: CacheConfigDefaults.userCacheSize
    });
    return result;
  }

  /**
   * 获取缓存命中率报告
   */
  getHitRateReport(): Map<string, CacheHitRateReport> {
    const report = new Map<string, CacheHitRateReport>();

    const msgTotal = this.messageStats.hits + this.messageStats.misses;
    report.set('message', {
      hitRate: msgTotal > 0 ? (this.messageStats.hits / msgTotal) : 0,
      total: msgTotal
    });

    const chatTotal = this.chatStats.hits + this.chatStats.misses;
    report.set('chat', {
      hitRate: chatTotal > 0 ? (this.chatStats.hits / chatTotal) : 0,
      total: chatTotal
    });

    const userTotal = this.userStats.hits + this.userStats.misses;
    report.set('user', {
      hitRate: userTotal > 0 ? (this.userStats.hits / userTotal) : 0,
      total: userTotal
    });

    return report;
  }



  // ========== 消息 ==========
  async saveMessage(chatId: number, message: MessageData): Promise<void> {
    const entity = new MessageEntity();
    entity.messageId = message.id;
    entity.chatId = chatId;
    entity.senderId = message.senderId;
    entity.date = message.date;
    entity.contentType = message.content._constructor;
    entity.contentJson = JSON.stringify(message.content);
    if (message.entities) entity.entitiesJson = JSON.stringify(message.entities);
    if (message.replyToMessageId) entity.replyToMsgId = message.replyToMessageId;
    await this.database.insertMessage(entity);
    this.messageMemCache.put(message.id, entity);
  }

  async saveMessagesBatch(chatId: number, messages: MessageData[]): Promise<number> {
    const entities: MessageEntity[] = [];
    for (const msg of messages) {
      const e = new MessageEntity();
      e.messageId = msg.id;
      e.chatId = chatId;
      e.senderId = msg.senderId;
      e.date = msg.date;
      e.contentType = msg.content._constructor;
      e.contentJson = JSON.stringify(msg.content);
      if (msg.entities) e.entitiesJson = JSON.stringify(msg.entities);
      if (msg.replyToMessageId) e.replyToMsgId = msg.replyToMessageId;
      entities.push(e);
      this.messageMemCache.put(msg.id, e);
    }
    // 使用优化的批量插入方法
    const result = await this.database.insertMessagesBatchOptimized(entities);
    return result.success ? result.data! : 0;
  }

  /**
   * 延迟批量保存（用于高频写入场景）
   */
  async saveMessageDeferred(chatId: number, message: MessageData): Promise<void> {
    const entity = new MessageEntity();
    entity.messageId = message.id;
    entity.chatId = chatId;
    entity.senderId = message.senderId;
    entity.date = message.date;
    entity.contentType = message.content._constructor;
    entity.contentJson = JSON.stringify(message.content);
    if (message.entities) entity.entitiesJson = JSON.stringify(message.entities);
    if (message.replyToMessageId) entity.replyToMsgId = message.replyToMessageId;

    // 加入缓冲区
    this.messageBatchBuffer.push(entity);
    this.messageMemCache.put(message.id, entity);

    // 触发批量写入
    this.flushMessageBatchDeferred();
  }

  /**
   * 立即刷新消息批量缓冲区
   */
  async flushMessageBatch(): Promise<number> {
    if (this.messageBatchBuffer.length === 0) return 0;

    const count = this.messageBatchBuffer.length;
    const batch: MessageEntity[] = [];
    for (let i = 0; i < count; i++) {
      const msg: MessageEntity | undefined = this.messageBatchBuffer.shift();
      if (msg !== undefined) {
        batch.push(msg);
      }
    }
    const result = await this.database.insertMessagesBatchOptimized(batch);
    const dataValue: number = result.data ? result.data : 0;
    return result.success ? dataValue : 0;
  }

  private flushMessageBatchDeferred(): void {
    // 清除现有定时器
    if (this.batchTimer !== null) {
      clearTimeout(this.batchTimer);
    }

    // 设置新定时器
    this.batchTimer = setTimeout(() => {
      this.flushMessageBatch();
      this.batchTimer = null;
    }, this.BATCH_DELAY) as number;
  }

  async getMessages(chatId: number, limit: number = 50, offset: number = 0): Promise<MessageEntity[]> {
    return await this.database.queryMessagesByChat(chatId, limit, offset);
  }

  /**
   * 获取最近的消息
   */
  async getRecentMessages(chatId: number, limit: number = 50): Promise<MessageEntity[]> {
    return await this.database.queryMessagesByChat(chatId, limit, 0);
  }

  async getMessageWithCache(messageId: number): Promise<MessageEntity | undefined> {
    const cached = this.messageMemCache.get(messageId);
    if (cached) {
      this.messageStats.hits++;
      return cached;
    }
    this.messageStats.misses++;
    const msg = await this.database.getMessageByMessageId(messageId);
    if (msg) this.messageMemCache.put(messageId, msg);
    return msg;
  }

  /**
   * 批量获取消息（带缓存）
   */
  async getMessagesWithCache(messageIds: number[]): Promise<Map<number, MessageEntity>> {
    const result = new Map<number, MessageEntity>();
    const missingIds: number[] = [];

    // 先查缓存
    for (const id of messageIds) {
      const cached = this.messageMemCache.get(id);
      if (cached) {
        result.set(id, cached);
        this.messageStats.hits++;
      } else {
        missingIds.push(id);
        this.messageStats.misses++;
      }
    }

    // 批量查询缺失的消息
    if (missingIds.length > 0) {
      // 使用数据库批量查询（如果支持）
      for (const id of missingIds) {
        const msg = await this.database.getMessageByMessageId(id);
        if (msg) {
          result.set(id, msg);
          this.messageMemCache.put(id, msg);
        }
      }
    }

    return result;
  }

  async searchMessages(query: string, chatId?: number, limit: number = 50): Promise<MessageEntity[]> {
    return await this.database.searchMessages(query, chatId, limit);
  }

  // ========== 会话 ==========
  async getChatWithCache(chatId: number): Promise<ChatEntity | undefined> {
    const cached = this.chatMemCache.get(chatId);
    if (cached) {
      this.chatStats.hits++;
      return cached;
    }
    this.chatStats.misses++;
    const chat = await this.database.getChat(chatId);
    if (chat) this.chatMemCache.put(chatId, chat);
    return chat;
  }

  /**
   * 批量获取会话（带缓存）
   */
  async getChatsWithCache(chatIds: number[]): Promise<Map<number, ChatEntity>> {
    const result = new Map<number, ChatEntity>();
    const missingIds: number[] = [];

    for (const id of chatIds) {
      const cached = this.chatMemCache.get(id);
      if (cached) {
        result.set(id, cached);
        this.chatStats.hits++;
      } else {
        missingIds.push(id);
        this.chatStats.misses++;
      }
    }

    // 批量查询缺失的会话
    for (const id of missingIds) {
      const chat = await this.database.getChat(id);
      if (chat) {
        result.set(id, chat);
        this.chatMemCache.put(id, chat);
      }
    }

    return result;
  }

  async saveChat(chat: ChatEntity): Promise<void> {
    await this.database.insertChat(chat);
    this.chatMemCache.put(chat.chatId, chat);
  }

  async updateChat(chat: ChatEntity): Promise<void> {
    await this.database.updateChat(chat);
    this.chatMemCache.put(chat.chatId, chat);
  }

  async getAllChats(): Promise<ChatEntity[]> {
    return await this.database.getAllChats();
  }

  /**
   * 获取所有会话并预热缓存
   */
  async getAllChatsWithWarmup(): Promise<ChatEntity[]> {
    const chats = await this.database.getAllChats();
    // 预热缓存
    for (const chat of chats) {
      this.chatMemCache.put(chat.chatId, chat);
    }
    return chats;
  }

  // ========== 媒体 ==========
  async cacheMediaFile(fileId: string, data: ArrayBuffer): Promise<void> {
    this.diskCache.setBinarySync(fileId, data);
    const media = await this.database.getMediaByFileId(fileId);
    if (media) {
      media.isDownloaded = true;
      await this.database.updateMedia(media);
    }
  }

  async getMediaFile(fileId: string): Promise<ArrayBuffer | null> {
    return this.diskCache.getBinarySync(fileId);
  }

  async getMediaInfo(fileId: string): Promise<MediaEntity | undefined> {
    return await this.database.getMediaByFileId(fileId);
  }

  async saveMedia(media: MediaEntity): Promise<void> {
    const existing = await this.database.getMediaByFileId(media.fileId);
    if (existing) {
      await this.database.updateMedia(media);
    } else {
      await this.database.insertMedia(media);
    }
  }

  // ========== 故事 ==========
  async saveStory(story: StoryEntity): Promise<void> {
    await this.database.insertStory(story);
  }

  async getStoriesByChat(chatId: number, limit: number = 10): Promise<StoryEntity[]> {
    return await this.database.queryStoriesByChat(chatId, limit);
  }

  async deleteExpiredStories(now: number): Promise<number> {
    return await this.database.deleteExpiredStories(now);
  }

  // ========== 联系人 ==========
  async saveContact(contact: ContactEntity): Promise<void> {
    const existing = await this.database.getContactByPhoneNumber(contact.phoneNumber);
    if (existing) {
      await this.database.updateContact(contact);
    } else {
      await this.database.insertContact(contact);
    }
  }

  async getContactByPhoneNumber(phoneNumber: string): Promise<ContactEntity | undefined> {
    return await this.database.getContactByPhoneNumber(phoneNumber);
  }

  async getAllContacts(): Promise<ContactEntity[]> {
    return await this.database.getAllContacts();
  }

  // ========== 用户 ==========
  async saveUser(user: UserEntity): Promise<void> {
    const existing = await this.database.getUserByUserId(user.userId);
    if (existing) {
      await this.database.updateUser(user);
    } else {
      await this.database.insertUser(user);
    }
    this.userMemCache.put(user.userId, user);
  }

  async getUserWithCache(userId: number): Promise<UserEntity | undefined> {
    const cached = this.userMemCache.get(userId);
    if (cached) {
      this.userStats.hits++;
      return cached;
    }
    this.userStats.misses++;
    const user = await this.database.getUserByUserId(userId);
    if (user) this.userMemCache.put(userId, user);
    return user;
  }

  /**
   * 批量获取用户（带缓存）
   */
  async getUsersWithCache(userIds: number[]): Promise<Map<number, UserEntity>> {
    const result = new Map<number, UserEntity>();
    const missingIds: number[] = [];

    for (const id of userIds) {
      const cached = this.userMemCache.get(id);
      if (cached) {
        result.set(id, cached);
        this.userStats.hits++;
      } else {
        missingIds.push(id);
        this.userStats.misses++;
      }
    }

    // 批量查询缺失的用户
    for (const id of missingIds) {
      const user = await this.database.getUserByUserId(id);
      if (user) {
        result.set(id, user);
        this.userMemCache.put(id, user);
      }
    }

    return result;
  }

  async searchUsers(keyword: string): Promise<UserEntity[]> {
    return await this.database.searchUsersByKeyword(keyword);
  }

  // ========== 聊天文件夹 ==========
  async saveChatFilter(filter: ChatFilterEntity): Promise<void> {
    const existing = (await this.database.getAllChatFilters()).find(f => f.filterId === filter.filterId);
    if (existing) {
      await this.database.updateChatFilter(filter);
    } else {
      await this.database.insertChatFilter(filter);
    }
  }

  async getAllChatFilters(): Promise<ChatFilterEntity[]> {
    return await this.database.getAllChatFilters();
  }

  // ========== 聊天提升 ==========
  async addChatBoost(boost: ChatBoostEntity): Promise<void> {
    await this.database.insertChatBoost(boost);
  }

  async getActiveChatBoosts(chatId: number, now: number): Promise<ChatBoostEntity[]> {
    return await this.database.getActiveBoostsByChat(chatId, now);
  }

  // ========== 机器人命令 ==========
  async setBotCommands(botUserId: number, commands: BotCommandEntity[]): Promise<void> {
    await this.database.deleteBotCommands(botUserId);
    for (const cmd of commands) {
      await this.database.insertBotCommand(cmd);
    }
  }

  async getBotCommands(botUserId: number): Promise<BotCommandEntity[]> {
    return await this.database.getBotCommands(botUserId);
  }

  // ========== 表情反应 ==========
  async addReaction(messageId: number, chatId: number, emoji: string, userId: number, date?: number): Promise<void> {
    const reaction = new ReactionEntity();
    reaction.messageId = messageId;
    reaction.chatId = chatId;
    reaction.emoji = emoji;
    reaction.userId = userId;
    reaction.date = date || Date.now();
    reaction.isSelected = true;
    await this.database.addReaction(reaction);
  }

  async removeReaction(messageId: number, emoji: string, userId: number): Promise<void> {
    await this.database.removeReaction(messageId, emoji, userId);
  }

  async getReactions(messageId: number): Promise<ReactionEntity[]> {
    return await this.database.getReactionsForMessage(messageId);
  }

  async getReactionCount(messageId: number): Promise<Map<string, number>> {
    return await this.database.getReactionCount(messageId);
  }

  // ========== 聊天位置 ==========
  async updateChatPosition(position: ChatPositionEntity): Promise<void> {
    const existing = await this.database.getChatPositions(position.chatId);
    const found = existing.find(p => p.listType === position.listType && p.filterId === position.filterId);
    if (found) {
      position.id = found.id;
      await this.database.updateChatPosition(position);
    } else {
      await this.database.insertChatPosition(position);
    }
  }

  async getChatsInList(listType: string, filterId?: number, limit?: number): Promise<number[]> {
    return await this.database.getChatsByList(listType, filterId, limit);
  }

  // ========== 秘密聊天 ==========
  async saveSecretChat(secret: SecretChatEntity): Promise<void> {
    const existing = await this.database.getSecretChatByUserId(secret.userId);
    if (existing) {
      secret.id = existing.id;
      await this.database.updateSecretChat(secret);
    } else {
      await this.database.insertSecretChat(secret);
    }
  }

  async getSecretChat(userId: number): Promise<SecretChatEntity | undefined> {
    return await this.database.getSecretChatByUserId(userId);
  }

  // ========== 投票选项 ==========
  async updatePollOption(pollId: string, optionIndex: number, voterCount: number, isSelected?: boolean, isChosen?: boolean): Promise<void> {
    const opt = new PollOptionEntity();
    opt.pollId = pollId;
    opt.optionIndex = optionIndex;
    opt.voterCount = voterCount;
    if (isSelected !== undefined) opt.isSelected = isSelected;
    if (isChosen !== undefined) opt.isChosen = isChosen;
    await this.database.upsertPollOption(opt);
  }

  async getPollOptions(pollId: string): Promise<PollOptionEntity[]> {
    return await this.database.getPollOptions(pollId);
  }

  async clearPollOptions(pollId: string): Promise<void> {
    await this.database.clearPollOptions(pollId);
  }

  // ========== 删除操作 ==========

  async deleteMessage(messageId: number): Promise<boolean> {
    // 1. 获取该消息关联的所有媒体文件 ID
    const mediaList = await this.database.getMediaByMessageId(messageId);
    // 2. 删除磁盘文件
    for (const media of mediaList) {
      if (media.fileId) {
        this.diskCache.removeSync(media.fileId);
      }
    }
    // 3. 删除数据库中的消息（会级联删除反应和媒体索引）
    const result = await this.database.deleteMessage(messageId);
    // 4. 清理内存缓存
    this.messageMemCache.remove(messageId);
    return result.success && (result.data ?? 0) > 0;
  }

  async deleteMessagesByChat(chatId: number): Promise<boolean> {
    // 获取该会话下所有消息并逐个删除（包含媒体文件清理）
    const messages = await this.database.queryMessagesByChat(chatId, 10000, 0);
    let success = true;
    for (const msg of messages) {
      const deleted = await this.deleteMessage(msg.messageId);
      if (!deleted) success = false;
    }
    return success;
  }

  async deleteChat(chatId: number): Promise<boolean> {
    // 1. 获取该会话下所有媒体文件 ID
    const mediaList = await this.database.getMediaByChatId(chatId);
    // 2. 删除所有磁盘文件
    for (const media of mediaList) {
      if (media.fileId) {
        this.diskCache.removeSync(media.fileId);
      }
    }
    // 3. 删除数据库中的会话（级联删除所有关联数据）
    const result = await this.database.deleteChat(chatId);
    // 4. 清理内存缓存
    this.chatMemCache.remove(chatId);
    return result.success && (result.data ?? 0) > 0;
  }

  async deleteMediaFile(fileId: string): Promise<boolean> {
    // 1. 删除磁盘文件
    const diskDeleted = this.diskCache.removeSync(fileId);
    // 2. 删除数据库索引
    const dbResult = await this.database.deleteMediaByFileId(fileId);
    return diskDeleted && dbResult.success && (dbResult.data ?? 0) > 0;
  }

  async deleteUser(userId: number): Promise<boolean> {
    // 先获取该用户的所有私人聊天 ID
    const privateChats = await this.database.getPrivateChatsByUserId(userId);
    // 依次删除每个会话（会删除其下所有媒体文件）
    for (const chatId of privateChats) {
      await this.deleteChat(chatId);
    }
    // 删除用户记录（也会删除联系人、机器人命令等）
    const result = await this.database.deleteUser(userId);
    // 清理用户内存缓存
    this.userMemCache.remove(userId);
    return result.success && (result.data ?? 0) > 0;
  }

  async clearAllData(): Promise<void> {
    // 1. 清空所有磁盘缓存
    this.diskCache.clearSync();
    // 2. 清空图片缓存
    this.imageKnife.clearDiskCache();
    this.imageKnife.clearMemoryCache();
    // 3. 清空 MMKV
    this.mmkv.clear();
    // 4. 删除所有数据库表数据（保留表结构）
    const tables = [
      'messages', 'chats', 'media', 'stories', 'contacts', 'users',
      'chat_filters', 'chat_boosts', 'bot_commands', 'reactions',
      'chat_positions', 'secret_chats', 'poll_options',
      'sticker_sets', 'stickers', 'bot_infos', 'gifts', 'upgraded_gifts',
      'received_gifts', 'business_infos', 'business_chat_links',
      'star_transactions', 'invoices', 'chat_statistics',
      'notification_sounds', 'backgrounds', 'game_high_scores', 'webapp_sessions'
    ];
    for (const table of tables) {
      try {
        await this.database.getStore()?.executeSql(`DELETE FROM ${table}`);
      } catch (e) {
        CacheLogger.warn(TAG, `Failed to clear table ${table}: ${e}`);
      }
    }
    // 5. 清空 FTS 表
    try {
      await this.database.getStore()?.executeSql('DELETE FROM messages_fts');
    } catch (e) {
      CacheLogger.warn(TAG, `Failed to clear FTS: ${e}`);
    }
    // 6. 清空内存缓存
    this.messageMemCache.clear();
    this.chatMemCache.clear();
    this.userMemCache.clear();
  }

  // ========== 补充删除方法 ==========

  async deleteStory(storyId: number): Promise<boolean> {
    // 先查出故事的 fileId（从 contentJson 解析）
    const story = await this.database.getStoryById(storyId);
    if (story) {
      // 尝试从 contentJson 解析 fileId 并删除
      try {
        const content: StoryContent = JSON.parse(story.contentJson) as StoryContent;
        if (content.photo?.sizes?.[0]?.photo?.id) {
          this.diskCache.removeSync(String(content.photo.sizes[0].photo.id));
        }
        if (content.video?.video?.id) {
          this.diskCache.removeSync(String(content.video.video.id));
        }
      } catch (e) {
        CacheLogger.warn(TAG, `Failed to parse story content: ${e}`);
      }
    }
    const result = await this.database.deleteStory(storyId);
    return result.success && (result.data ?? 0) > 0;
  }

  async deleteChatFilter(filterId: number): Promise<boolean> {
    const result = await this.database.deleteChatFilter(filterId);
    return result.success && (result.data ?? 0) > 0;
  }

  async deleteChatBoost(boostId: number): Promise<boolean> {
    const result = await this.database.deleteChatBoost(boostId);
    return result.success && (result.data ?? 0) > 0;
  }

  async deleteSecretChat(secretChatId: number): Promise<boolean> {
    const result = await this.database.deleteSecretChat(secretChatId);
    return result.success && (result.data ?? 0) > 0;
  }

  async clearDraft(chatId: number): Promise<boolean> {
    const result = await this.database.clearDraft(chatId);
    return result.success && (result.data ?? 0) > 0;
  }

  // ========== 批量删除方法 ==========

  async clearChatMessages(chatId: number): Promise<number> {
    // 获取该会话所有媒体文件并删除
    const mediaList = await this.database.getMediaByChatId(chatId);
    for (const media of mediaList) {
      if (media.fileId) {
        this.diskCache.removeSync(media.fileId);
      }
    }
    // 删除数据库中的消息
    const result = await this.database.deleteMessagesByChat(chatId);
    // 清理消息内存缓存（遍历所有消息ID）
    const messages = await this.database.queryMessagesByChat(chatId, 10000, 0);
    for (const msg of messages) {
      this.messageMemCache.remove(msg.messageId);
    }
    return result.data || 0;
  }

  async deleteExpiredStoriesWithFiles(now: number): Promise<number> {
    const expired = await this.database.queryExpiredStories(now);
    for (const story of expired) {
      // 尝试删除故事关联的文件
      try {
        const content: StoryContent = JSON.parse(story.contentJson) as StoryContent;
        if (content.photo?.sizes?.[0]?.photo?.id) {
          this.diskCache.removeSync(String(content.photo.sizes[0].photo.id));
        }
        if (content.video?.video?.id) {
          this.diskCache.removeSync(String(content.video.video.id));
        }
      } catch (e) {
        CacheLogger.warn(TAG, `Failed to parse expired story content: ${e}`);
      }
    }
    return await this.database.deleteExpiredStories(now);
  }

  async deleteReaction(messageId: number, emoji: string, userId: number): Promise<boolean> {
    const result = await this.database.deleteReaction(messageId, emoji, userId);
    return result.success && (result.data ?? 0) > 0;
  }

  async deletePollOption(pollId: string, optionIndex: number): Promise<boolean> {
    const result = await this.database.deletePollOption(pollId, optionIndex);
    return result.success && (result.data ?? 0) > 0;
  }

  // ========== 内存告警 ==========
  onMemoryLevel(level: number): void {
    if (level >= 20) { // MODERATE
      this.messageMemCache.clear();
      this.chatMemCache.clear();
      this.userMemCache.clear();
      this.imageKnife.clearMemoryCache();
    }
    if (level >= 80) { // CRITICAL
      this.diskCache.clearSync();
    }
  }

  // ========== 清理所有缓存 ==========
  async clearAllCache(): Promise<void> {
    this.mmkv.clear();
    this.diskCache.clearSync();
    this.imageKnife.clearDiskCache();
    this.imageKnife.clearMemoryCache();
    this.messageMemCache.clear();
    this.chatMemCache.clear();
    this.userMemCache.clear();
  }

  // ========== 回收站功能 ==========

  async moveMessageToRecycleBin(messageId: number, retentionDays: number = 30): Promise<boolean> {
    // 获取消息数据
    const message = await this.database.getMessageByMessageId(messageId);
    if (!message) return false;

    // 保存到回收站
    const result = await this.database.addToRecycleBin(
      messageId,
      'message',
      JSON.stringify(message),
      retentionDays,
      message.chatId,
      `Message #${messageId}`,
      JSON.stringify({ contentType: message.contentType })
    );

    if (!result.success) return false;

    // 软删除：标记为已删除但不实际删除数据
    // 或者调用现有的 deleteMessage 进行硬删除
    // 这里选择硬删除，因为数据已备份到回收站
    return await this.deleteMessage(messageId);
  }

  async moveChatToRecycleBin(chatId: number, retentionDays: number = 30): Promise<boolean> {
    // 获取会话数据
    const chat = await this.database.getChat(chatId);
    if (!chat) return false;

    // 获取会话下的所有消息
    const messages = await this.database.queryMessagesByChat(chatId, 10000, 0);

    // 保存会话到回收站
    const chatResult = await this.database.addToRecycleBin(
      chatId,
      'chat',
      JSON.stringify({ chat, messages }),
      retentionDays,
      chatId,
      chat.title,
      JSON.stringify({ messageCount: messages.length })
    );

    if (!chatResult.success) return false;

    // 删除会话（数据已备份）
    return await this.deleteChat(chatId);
  }

  async restoreMessageFromRecycleBin(messageId: number): Promise<boolean> {
    const result = await this.database.restoreFromRecycleBin(messageId, 'message');
    if (!result.success || !result.data) return false;

    try {
      const messageData = JSON.parse(result.data) as MessageEntity;
      // 重新插入消息
      await this.database.insertMessage(messageData);
      // 更新内存缓存
      this.messageMemCache.put(messageId, messageData);
      return true;
    } catch (e) {
      CacheLogger.error(TAG, `Failed to restore message: ${e}`);
      return false;
    }
  }

  async restoreChatFromRecycleBin(chatId: number): Promise<boolean> {
    const result = await this.database.restoreFromRecycleBin(chatId, 'chat');
    if (!result.success || !result.data) return false;

    try {
      const restoreData: RestoreChatData = JSON.parse(result.data) as RestoreChatData;
      // 恢复会话
      await this.database.insertChat(restoreData.chat);
      this.chatMemCache.put(chatId, restoreData.chat);
      // 恢复消息
      for (const msg of restoreData.messages) {
        await this.database.insertMessage(msg);
        this.messageMemCache.put(msg.messageId, msg);
      }
      return true;
    } catch (e) {
      CacheLogger.error(TAG, `Failed to restore chat: ${e}`);
      return false;
    }
  }

  async getRecycleBinItems(itemType?: string, limit: number = 100): Promise<RecycleBinItemView[]> {
    const items = await this.database.getRecycleBinItems(itemType, limit);
    return items.map((item): RecycleBinItemView => ({
      id: item.id,
      itemId: item.itemId,
      itemType: item.itemType,
      deletedAt: item.deletedAt,
      expiresAt: item.expiresAt,
      chatId: item.chatId,
      title: item.title
    }));
  }

  async permanentlyDeleteFromRecycleBin(itemId: number, itemType: string): Promise<boolean> {
    const result = await this.database.permanentlyDeleteFromRecycleBin(itemId, itemType);
    return result.success && (result.data ?? 0) > 0;
  }

  async clearExpiredRecycleBinItems(): Promise<number> {
    return await this.database.clearExpiredRecycleBinItems();
  }

  async getRecycleBinStats(): Promise<RecycleBinStats> {
    return await this.database.getRecycleBinStats();
  }

  async emptyRecycleBin(): Promise<boolean> {
    const items = await this.database.getRecycleBinItems(undefined, 10000);
    for (const item of items) {
      await this.database.permanentlyDeleteFromRecycleBin(item.itemId, item.itemType);
    }
    return true;
  }

  // ========== 贴纸集 ==========
  async saveStickerSet(set: StickerSetEntity): Promise<void> {
    const existing = await this.database.getStickerSet(set.setId);
    if (existing) await this.database.updateStickerSet(set);
    else await this.database.insertStickerSet(set);
  }

  async getStickerSet(setId: string): Promise<StickerSetEntity | undefined> {
    return await this.database.getStickerSet(setId);
  }

  async getAllStickerSets(): Promise<StickerSetEntity[]> {
    return await this.database.getAllStickerSets();
  }

  // ========== 贴纸 ==========
  async saveSticker(sticker: StickerEntity): Promise<void> {
    await this.database.insertSticker(sticker);
  }

  async getStickersBySetId(setId: string): Promise<StickerEntity[]> {
    return await this.database.getStickersBySetId(setId);
  }

  // ========== 机器人详情 ==========
  async saveBotInfo(botInfo: BotInfoEntity): Promise<void> {
    const existing = await this.database.getBotInfo(botInfo.botUserId);
    if (existing) await this.database.updateBotInfo(botInfo);
    else await this.database.insertBotInfo(botInfo);
  }

  async getBotInfo(botUserId: number): Promise<BotInfoEntity | undefined> {
    return await this.database.getBotInfo(botUserId);
  }

  // ========== 礼物 ==========
  async saveGift(gift: GiftEntity): Promise<void> {
    const existing = await this.database.getGift(gift.giftId);
    if (!existing) await this.database.insertGift(gift);
  }

  async getGift(giftId: string): Promise<GiftEntity | undefined> {
    return await this.database.getGift(giftId);
  }

  async getAllGifts(): Promise<GiftEntity[]> {
    return await this.database.getAllGifts();
  }

  // ========== Stars 交易 ==========
  async saveStarTransaction(transaction: StarTransactionEntity): Promise<void> {
    await this.database.insertStarTransaction(transaction);
  }

  async getStarTransactionsByOwner(ownerId: number, limit?: number): Promise<StarTransactionEntity[]> {
    return await this.database.getStarTransactionsByOwner(ownerId, limit);
  }

  // ========== 聊天背景 ==========
  async saveBackground(background: BackgroundEntity): Promise<void> {
    const existing = await this.database.getBackground(background.backgroundId);
    if (!existing) await this.database.insertBackground(background);
  }

  async getBackground(backgroundId: string): Promise<BackgroundEntity | undefined> {
    return await this.database.getBackground(backgroundId);
  }

  async getAllBackgrounds(): Promise<BackgroundEntity[]> {
    return await this.database.getAllBackgrounds();
  }

  async close(): Promise<void> {
    await this.database.close();
  }
}
