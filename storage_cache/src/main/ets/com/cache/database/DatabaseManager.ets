// storage_cache/src/main/ets/com/cache/database/DatabaseManager.ets
import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import {
  MessageEntity, ChatEntity, MediaEntity, ContactEntity, StoryEntity,
  UserEntity, ChatFilterEntity, ChatBoostEntity, BotCommandEntity,
  ReactionEntity, ChatPositionEntity, SecretChatEntity, PollOptionEntity,
  StickerSetEntity, StickerEntity, BotInfoEntity, GiftEntity, UpgradedGiftEntity,
  ReceivedGiftEntity, BusinessInfoEntity, BusinessChatLinkEntity, StarTransactionEntity,
  InvoiceEntity, ChatStatisticsEntity, NotificationSoundEntity, BackgroundEntity,
  GameHighScoreEntity, WebAppSessionEntity
} from '../model/TelegramEntity';
import { CacheLogger } from '../utils/Logger';
import { CacheResult, ErrorCodes } from '../utils/Result';

const TAG = 'DatabaseManager';

// 回收站项目类型定义
export interface RecycleBinItem {
  id: number;
  itemId: number;
  itemType: string;
  originalDataJson: string;
  deletedAt: number;
  expiresAt: number;
  chatId?: number;
  title?: string;
}

// 回收站统计类型定义
export interface RecycleBinStats {
  total: number;
  byType: Record<string, number>;
}

export class DatabaseManager {
  private static instance: DatabaseManager;
  private rdbStore: relationalStore.RdbStore | null = null;
  private context: common.UIAbilityContext | null = null;

  private readonly DB_NAME = 'storage_cache.db';
  private readonly DB_VERSION = 1;
  private readonly TABLE_MESSAGE = 'messages';
  private readonly TABLE_CHAT = 'chats';
  private readonly TABLE_MEDIA = 'media';
  private readonly TABLE_STORY = 'stories';
  private readonly TABLE_CONTACT = 'contacts';
  private readonly TABLE_USER = 'users';
  private readonly TABLE_CHAT_FILTER = 'chat_filters';
  private readonly TABLE_CHAT_BOOST = 'chat_boosts';
  private readonly TABLE_BOT_COMMAND = 'bot_commands';
  private readonly TABLE_REACTION = 'reactions';
  private readonly TABLE_CHAT_POSITION = 'chat_positions';
  private readonly TABLE_SECRET_CHAT = 'secret_chats';
  private readonly TABLE_POLL_OPTION = 'poll_options';
  private readonly TABLE_MESSAGE_FTS = 'messages_fts';
  private readonly TABLE_RECYCLE_BIN = 'recycle_bin';

  // 新增实体表名常量
  private readonly TABLE_STICKER_SET = 'sticker_sets';
  private readonly TABLE_STICKER = 'stickers';
  private readonly TABLE_BOT_INFO = 'bot_infos';
  private readonly TABLE_GIFT = 'gifts';
  private readonly TABLE_UPGRADED_GIFT = 'upgraded_gifts';
  private readonly TABLE_RECEIVED_GIFT = 'received_gifts';
  private readonly TABLE_BUSINESS_INFO = 'business_infos';
  private readonly TABLE_BUSINESS_CHAT_LINK = 'business_chat_links';
  private readonly TABLE_STAR_TRANSACTION = 'star_transactions';
  private readonly TABLE_INVOICE = 'invoices';
  private readonly TABLE_CHAT_STATISTICS = 'chat_statistics';
  private readonly TABLE_NOTIFICATION_SOUND = 'notification_sounds';
  private readonly TABLE_BACKGROUND = 'backgrounds';
  private readonly TABLE_GAME_HIGH_SCORE = 'game_high_scores';
  private readonly TABLE_WEBAPP_SESSION = 'webapp_sessions';

  private constructor(context: common.UIAbilityContext) {
    this.context = context;
    // 注意：initDatabase 是异步的，需要通过 getInstance 等待初始化完成
    this.initPromise = this.initDatabase();
  }

  private initPromise: Promise<void> | null = null;

  public static getInstance(context?: common.UIAbilityContext): DatabaseManager {
    if (!DatabaseManager.instance && context) {
      DatabaseManager.instance = new DatabaseManager(context);
    }
    return DatabaseManager.instance;
  }

  /**
   * 等待数据库初始化完成
   */
  public async waitForInit(): Promise<void> {
    if (this.initPromise) {
      await this.initPromise;
    }
  }

  private async initDatabase(): Promise<void> {
    if (!this.context) return;
    const config: relationalStore.StoreConfig = {
      name: this.DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    try {
      this.rdbStore = await relationalStore.getRdbStore(this.context, config);

      // 性能优化 PRAGMA 设置
      await this.rdbStore.executeSql('PRAGMA journal_mode=WAL');
      await this.rdbStore.executeSql('PRAGMA synchronous=NORMAL');
      await this.rdbStore.executeSql('PRAGMA cache_size=-10240');      // 10MB
      await this.rdbStore.executeSql('PRAGMA mmap_size=268435456');    // 256MB
      await this.rdbStore.executeSql('PRAGMA busy_timeout=3000');      // 3秒超时

      const currentVersion = this.rdbStore.version;
      CacheLogger.info(TAG, `Database current version: ${currentVersion}, target: ${this.DB_VERSION}`);
      if (currentVersion < this.DB_VERSION) {
        await this.onUpgrade(this.rdbStore, currentVersion, this.DB_VERSION);
        CacheLogger.info(TAG, `Database upgraded to v${this.DB_VERSION}`);
      } else {
        await this.createTables();
      }
    } catch (err) {
      CacheLogger.error(TAG, `Init failed: ${JSON.stringify(err)}`);
    }
  }

  private async createTables(): Promise<void> {
    if (!this.rdbStore) return;

    // 消息表
    const sqlMessage = `CREATE TABLE IF NOT EXISTS ${this.TABLE_MESSAGE} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      messageId INTEGER NOT NULL,
      chatId INTEGER NOT NULL,
      senderId INTEGER,
      date INTEGER,
      editDate INTEGER,
      contentType TEXT,
      contentJson TEXT,
      caption TEXT,
      entitiesJson TEXT,
      replyToMsgId INTEGER,
      mediaGroupId TEXT,
      forwardInfoJson TEXT,
      replyMarkupJson TEXT,
      inlineKeyboardJson TEXT,
      flags INTEGER DEFAULT 0,
      pollId TEXT,
      gameId INTEGER,
      invoiceId TEXT,
      callbackQueryData TEXT,
      extraJson TEXT
    )`;
    await this.rdbStore.executeSql(sqlMessage);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_message_chatId ON ${this.TABLE_MESSAGE} (chatId)`);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_message_messageId ON ${this.TABLE_MESSAGE} (messageId)`);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_message_pollId ON ${this.TABLE_MESSAGE} (pollId)`);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_message_gameId ON ${this.TABLE_MESSAGE} (gameId)`);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_message_invoiceId ON ${this.TABLE_MESSAGE} (invoiceId)`);
    // 优化：添加复合索引，加速按 chatId + date 的查询（最常用的查询模式）
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_message_chatId_date ON ${this.TABLE_MESSAGE} (chatId, date DESC)`);
    // 优化：添加 senderId 索引，加速按发送者查询
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_message_senderId ON ${this.TABLE_MESSAGE} (senderId)`);
    // 优化：添加 mediaGroupId 索引，加速媒体组查询
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_message_mediaGroupId ON ${this.TABLE_MESSAGE} (mediaGroupId)`);

    // 会话表
    const sqlChat = `CREATE TABLE IF NOT EXISTS ${this.TABLE_CHAT} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      chatId INTEGER NOT NULL UNIQUE,
      title TEXT,
      type TEXT,
      photoJson TEXT,
      lastMessageId INTEGER,
      lastMessageDate INTEGER,
      unreadCount INTEGER DEFAULT 0,
      draftMessage TEXT,
      lastReadMsgId INTEGER,
      isMuted INTEGER DEFAULT 0,
      isPinned INTEGER DEFAULT 0,
      syncCursor INTEGER DEFAULT 0,
      extraJson TEXT,
      canSendMessages INTEGER DEFAULT 1,
      canSendMedia INTEGER DEFAULT 1,
      canSendPolls INTEGER DEFAULT 1,
      canAddWebPagePreviews INTEGER DEFAULT 1,
      muteUntil INTEGER DEFAULT 0,
      showPreview INTEGER DEFAULT 1,
      memberStatusJson TEXT
    )`;
    await this.rdbStore.executeSql(sqlChat);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_chat_chatId ON ${this.TABLE_CHAT} (chatId)`);
    // 优化：添加复合索引，加速按 lastMessageDate 排序的查询
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_chat_lastMessageDate ON ${this.TABLE_CHAT} (lastMessageDate DESC)`);
    // 优化：添加 isPinned 索引，加速置顶聊天筛选
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_chat_isPinned ON ${this.TABLE_CHAT} (isPinned)`);
    // 优化：添加 type 索引，加速按类型筛选
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_chat_type ON ${this.TABLE_CHAT} (type)`);

    // 媒体表
    const sqlMedia = `CREATE TABLE IF NOT EXISTS ${this.TABLE_MEDIA} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fileId TEXT NOT NULL UNIQUE,
      messageId INTEGER,
      chatId INTEGER,
      fileType TEXT,
      localPath TEXT,
      remoteUrl TEXT,
      size INTEGER,
      width INTEGER,
      height INTEGER,
      duration INTEGER,
      mimeType TEXT,
      thumbnailPath TEXT,
      extraJson TEXT,
      isDownloaded INTEGER DEFAULT 0,
      isDownloading INTEGER DEFAULT 0,
      downloadProgress INTEGER DEFAULT 0
    )`;
    await this.rdbStore.executeSql(sqlMedia);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_media_fileId ON ${this.TABLE_MEDIA} (fileId)`);
    // 优化：添加复合索引，加速按 chatId + messageId 的媒体查询
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_media_chatId_messageId ON ${this.TABLE_MEDIA} (chatId, messageId)`);
    // 优化：添加 isDownloaded 索引，加速未下载文件筛选
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_media_isDownloaded ON ${this.TABLE_MEDIA} (isDownloaded)`);

    // 故事表
    const sqlStory = `CREATE TABLE IF NOT EXISTS ${this.TABLE_STORY} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      storyId INTEGER NOT NULL,
      senderId INTEGER,
      chatId INTEGER,
      date INTEGER,
      isEdited INTEGER DEFAULT 0,
      isPinned INTEGER DEFAULT 0,
      contentJson TEXT,
      interactionInfoJson TEXT,
      fileId TEXT,
      isViewed INTEGER DEFAULT 0,
      expireDate INTEGER
    )`;
    await this.rdbStore.executeSql(sqlStory);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_story_chatId ON ${this.TABLE_STORY} (chatId)`);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_story_storyId ON ${this.TABLE_STORY} (storyId)`);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_story_expireDate ON ${this.TABLE_STORY} (expireDate)`);

    // 联系人表
    const sqlContact = `CREATE TABLE IF NOT EXISTS ${this.TABLE_CONTACT} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER,
      phoneNumber TEXT NOT NULL,
      firstName TEXT,
      lastName TEXT,
      fullName TEXT,
      username TEXT,
      avatarFileId TEXT,
      isVerified INTEGER DEFAULT 0,
      isPremium INTEGER DEFAULT 0,
      isBot INTEGER DEFAULT 0,
      isFavorite INTEGER DEFAULT 0,
      syncStatus TEXT DEFAULT 'synced',
      lastUpdated INTEGER,
      extraJson TEXT
    )`;
    await this.rdbStore.executeSql(sqlContact);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_contact_phoneNumber ON ${this.TABLE_CONTACT} (phoneNumber)`);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_contact_userId ON ${this.TABLE_CONTACT} (userId)`);

    // 用户表
    const sqlUser = `CREATE TABLE IF NOT EXISTS ${this.TABLE_USER} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL UNIQUE,
      firstName TEXT,
      lastName TEXT,
      username TEXT,
      phoneNumber TEXT,
      isVerified INTEGER DEFAULT 0,
      isPremium INTEGER DEFAULT 0,
      isBot INTEGER DEFAULT 0,
      statusJson TEXT,
      profilePhotoFileId TEXT,
      emojiStatus TEXT,
      bio TEXT,
      extraJson TEXT,
      lastUpdated INTEGER,
      onlineStatus TEXT,
      lastSeen INTEGER
    )`;
    await this.rdbStore.executeSql(sqlUser);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_user_userId ON ${this.TABLE_USER} (userId)`);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_user_username ON ${this.TABLE_USER} (username)`);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_user_lastSeen ON ${this.TABLE_USER} (lastSeen)`);

    // 聊天文件夹表
    const sqlFilter = `CREATE TABLE IF NOT EXISTS ${this.TABLE_CHAT_FILTER} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      filterId INTEGER NOT NULL UNIQUE,
      title TEXT,
      iconName TEXT,
      orderNum INTEGER,
      pinnedChatIdsJson TEXT,
      includedChatIdsJson TEXT,
      excludedChatIdsJson TEXT,
      isPinned INTEGER DEFAULT 0,
      hasMyInvites INTEGER DEFAULT 0
    )`;
    await this.rdbStore.executeSql(sqlFilter);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_filter_order ON ${this.TABLE_CHAT_FILTER} (orderNum)`);

    // 聊天提升表
    const sqlBoost = `CREATE TABLE IF NOT EXISTS ${this.TABLE_CHAT_BOOST} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      boostId INTEGER NOT NULL UNIQUE,
      chatId INTEGER NOT NULL,
      userId INTEGER,
      date INTEGER,
      expires INTEGER,
      sourceType TEXT,
      sourceUserId INTEGER
    )`;
    await this.rdbStore.executeSql(sqlBoost);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_boost_chatId ON ${this.TABLE_CHAT_BOOST} (chatId)`);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_boost_expires ON ${this.TABLE_CHAT_BOOST} (expires)`);

    // 机器人命令表
    const sqlBotCmd = `CREATE TABLE IF NOT EXISTS ${this.TABLE_BOT_COMMAND} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      botUserId INTEGER NOT NULL,
      command TEXT,
      description TEXT
    )`;
    await this.rdbStore.executeSql(sqlBotCmd);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_botcmd_botUserId ON ${this.TABLE_BOT_COMMAND} (botUserId)`);

    // 表情反应表
    const sqlReaction = `CREATE TABLE IF NOT EXISTS ${this.TABLE_REACTION} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      messageId INTEGER NOT NULL,
      chatId INTEGER NOT NULL,
      emoji TEXT NOT NULL,
      userId INTEGER NOT NULL,
      date INTEGER,
      isSelected INTEGER DEFAULT 1
    )`;
    await this.rdbStore.executeSql(sqlReaction);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_reaction_messageId ON ${this.TABLE_REACTION} (messageId)`);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_reaction_chatId ON ${this.TABLE_REACTION} (chatId)`);
    await this.rdbStore.executeSql(`CREATE UNIQUE INDEX IF NOT EXISTS idx_reaction_unique ON ${this.TABLE_REACTION} (messageId, emoji, userId)`);

    // 聊天位置表
    const sqlChatPosition = `CREATE TABLE IF NOT EXISTS ${this.TABLE_CHAT_POSITION} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      chatId INTEGER NOT NULL,
      listType TEXT NOT NULL,
      filterId INTEGER,
      orderNum INTEGER,
      isPinned INTEGER DEFAULT 0,
      source TEXT
    )`;
    await this.rdbStore.executeSql(sqlChatPosition);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_position_chatId ON ${this.TABLE_CHAT_POSITION} (chatId)`);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_position_list ON ${this.TABLE_CHAT_POSITION} (listType, filterId, orderNum DESC)`);

    // 秘密聊天表
    const sqlSecretChat = `CREATE TABLE IF NOT EXISTS ${this.TABLE_SECRET_CHAT} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      secretChatId INTEGER NOT NULL UNIQUE,
      userId INTEGER NOT NULL,
      state TEXT,
      ttl INTEGER,
      keyHash TEXT,
      layer INTEGER,
      isOutgoing INTEGER DEFAULT 0
    )`;
    await this.rdbStore.executeSql(sqlSecretChat);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_secret_userId ON ${this.TABLE_SECRET_CHAT} (userId)`);

    // 投票选项表
    const sqlPollOption = `CREATE TABLE IF NOT EXISTS ${this.TABLE_POLL_OPTION} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pollId TEXT NOT NULL,
      optionIndex INTEGER NOT NULL,
      text TEXT,
      voterCount INTEGER,
      isSelected INTEGER DEFAULT 0,
      isChosen INTEGER DEFAULT 0
    )`;
    await this.rdbStore.executeSql(sqlPollOption);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_poll_pollId ON ${this.TABLE_POLL_OPTION} (pollId)`);

    // FTS5 虚拟表（全文搜索）
    const sqlFts = `CREATE VIRTUAL TABLE IF NOT EXISTS ${this.TABLE_MESSAGE_FTS} USING fts5(
      messageId UNINDEXED,
      chatId,
      content,
      contentJson
    )`;
    await this.rdbStore.executeSql(sqlFts);

    // 触发器保持 FTS 表与消息表同步
    const sqlTriggerInsert = `CREATE TRIGGER IF NOT EXISTS messages_ai AFTER INSERT ON ${this.TABLE_MESSAGE} BEGIN
      INSERT INTO ${this.TABLE_MESSAGE_FTS}(messageId, chatId, content, contentJson)
      VALUES (NEW.messageId, NEW.chatId, NEW.contentJson, NEW.contentJson);
    END`;
    const sqlTriggerUpdate = `CREATE TRIGGER IF NOT EXISTS messages_au AFTER UPDATE ON ${this.TABLE_MESSAGE} BEGIN
      UPDATE ${this.TABLE_MESSAGE_FTS}
      SET content = NEW.contentJson, contentJson = NEW.contentJson
      WHERE messageId = OLD.messageId;
    END`;
    const sqlTriggerDelete = `CREATE TRIGGER IF NOT EXISTS messages_ad AFTER DELETE ON ${this.TABLE_MESSAGE} BEGIN
      DELETE FROM ${this.TABLE_MESSAGE_FTS} WHERE messageId = OLD.messageId;
    END`;
    await this.rdbStore.executeSql(sqlTriggerInsert);
    await this.rdbStore.executeSql(sqlTriggerUpdate);
    await this.rdbStore.executeSql(sqlTriggerDelete);

    // ========== 新增实体表 ==========

    // 贴纸集表
    const sqlStickerSet = `CREATE TABLE IF NOT EXISTS ${this.TABLE_STICKER_SET} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      setId TEXT NOT NULL UNIQUE,
      title TEXT,
      name TEXT,
      stickerType TEXT,
      thumbnailFileId TEXT,
      isInstalled INTEGER DEFAULT 0,
      isArchived INTEGER DEFAULT 0,
      isOfficial INTEGER DEFAULT 0,
      isViewed INTEGER DEFAULT 0,
      size INTEGER,
      extraJson TEXT,
      lastUpdated INTEGER
    )`;
    await this.rdbStore.executeSql(sqlStickerSet);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_stickerset_setId ON ${this.TABLE_STICKER_SET} (setId)`);

    // 贴纸表
    const sqlSticker = `CREATE TABLE IF NOT EXISTS ${this.TABLE_STICKER} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      stickerId TEXT NOT NULL UNIQUE,
      setId TEXT,
      format TEXT,
      type TEXT,
      emoji TEXT,
      width INTEGER,
      height INTEGER,
      fileId TEXT,
      thumbnailFileId TEXT,
      maskPositionJson TEXT,
      isPremium INTEGER DEFAULT 0,
      extraJson TEXT
    )`;
    await this.rdbStore.executeSql(sqlSticker);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_sticker_setId ON ${this.TABLE_STICKER} (setId)`);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_sticker_fileId ON ${this.TABLE_STICKER} (fileId)`);

    // 机器人详情表
    const sqlBotInfo = `CREATE TABLE IF NOT EXISTS ${this.TABLE_BOT_INFO} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      botUserId INTEGER NOT NULL UNIQUE,
      shortDescription TEXT,
      description TEXT,
      photoFileId TEXT,
      animationFileId TEXT,
      menuButtonJson TEXT,
      commandsJson TEXT,
      privacyPolicyUrl TEXT,
      defaultGroupAdminRightsJson TEXT,
      defaultChannelAdminRightsJson TEXT,
      canGetRevenueStatistics INTEGER DEFAULT 0,
      extraJson TEXT
    )`;
    await this.rdbStore.executeSql(sqlBotInfo);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_botinfo_botUserId ON ${this.TABLE_BOT_INFO} (botUserId)`);

    // 普通礼物表
    const sqlGift = `CREATE TABLE IF NOT EXISTS ${this.TABLE_GIFT} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      giftId TEXT NOT NULL UNIQUE,
      stickerFileId TEXT,
      starCount INTEGER,
      upgradeStarCount INTEGER,
      backgroundJson TEXT,
      isPremium INTEGER DEFAULT 0,
      isForBirthday INTEGER DEFAULT 0,
      extraJson TEXT
    )`;
    await this.rdbStore.executeSql(sqlGift);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_gift_giftId ON ${this.TABLE_GIFT} (giftId)`);

    // 升级礼物表
    const sqlUpgradedGift = `CREATE TABLE IF NOT EXISTS ${this.TABLE_UPGRADED_GIFT} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      upgradedGiftId TEXT NOT NULL UNIQUE,
      regularGiftId TEXT,
      title TEXT,
      name TEXT,
      number INTEGER,
      totalUpgradedCount INTEGER,
      maxUpgradedCount INTEGER,
      isPremium INTEGER DEFAULT 0,
      isBurned INTEGER DEFAULT 0,
      modelCustomEmojiId TEXT,
      symbolCustomEmojiId TEXT,
      backdropColorsJson TEXT,
      ownerId INTEGER,
      ownerName TEXT,
      resaleStarCount INTEGER,
      craftProbabilityPerMille INTEGER,
      extraJson TEXT
    )`;
    await this.rdbStore.executeSql(sqlUpgradedGift);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_upgradedgift_id ON ${this.TABLE_UPGRADED_GIFT} (upgradedGiftId)`);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_upgradedgift_ownerId ON ${this.TABLE_UPGRADED_GIFT} (ownerId)`);

    // 已接收礼物表
    const sqlReceivedGift = `CREATE TABLE IF NOT EXISTS ${this.TABLE_RECEIVED_GIFT} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      receivedGiftId TEXT NOT NULL UNIQUE,
      senderId INTEGER,
      text TEXT,
      isPrivate INTEGER DEFAULT 0,
      isSaved INTEGER DEFAULT 0,
      isPinned INTEGER DEFAULT 0,
      canBeUpgraded INTEGER DEFAULT 0,
      canBeTransferred INTEGER DEFAULT 0,
      date INTEGER,
      giftJson TEXT,
      collectionIdsJson TEXT,
      sellStarCount INTEGER,
      transferStarCount INTEGER,
      nextTransferDate INTEGER,
      nextResaleDate INTEGER,
      exportDate INTEGER,
      craftDate INTEGER,
      extraJson TEXT
    )`;
    await this.rdbStore.executeSql(sqlReceivedGift);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_receivedgift_id ON ${this.TABLE_RECEIVED_GIFT} (receivedGiftId)`);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_receivedgift_senderId ON ${this.TABLE_RECEIVED_GIFT} (senderId)`);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_receivedgift_date ON ${this.TABLE_RECEIVED_GIFT} (date)`);

    // 商业账户信息表
    const sqlBusinessInfo = `CREATE TABLE IF NOT EXISTS ${this.TABLE_BUSINESS_INFO} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL UNIQUE,
      locationJson TEXT,
      openingHoursJson TEXT,
      greetingMessageSettingsJson TEXT,
      awayMessageSettingsJson TEXT,
      startPageJson TEXT,
      extraJson TEXT
    )`;
    await this.rdbStore.executeSql(sqlBusinessInfo);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_business_userId ON ${this.TABLE_BUSINESS_INFO} (userId)`);

    // 商业聊天链接表
    const sqlBusinessChatLink = `CREATE TABLE IF NOT EXISTS ${this.TABLE_BUSINESS_CHAT_LINK} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      link TEXT NOT NULL UNIQUE,
      text TEXT,
      title TEXT,
      viewCount INTEGER
    )`;
    await this.rdbStore.executeSql(sqlBusinessChatLink);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_businesslink_link ON ${this.TABLE_BUSINESS_CHAT_LINK} (link)`);

    // Stars 交易表
    const sqlStarTransaction = `CREATE TABLE IF NOT EXISTS ${this.TABLE_STAR_TRANSACTION} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      transactionId TEXT NOT NULL UNIQUE,
      ownerId INTEGER NOT NULL,
      starAmount INTEGER,
      nanostarAmount INTEGER,
      isRefund INTEGER DEFAULT 0,
      date INTEGER,
      type TEXT,
      extraJson TEXT
    )`;
    await this.rdbStore.executeSql(sqlStarTransaction);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_startrans_ownerId ON ${this.TABLE_STAR_TRANSACTION} (ownerId)`);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_startrans_date ON ${this.TABLE_STAR_TRANSACTION} (date)`);

    // 发票表
    const sqlInvoice = `CREATE TABLE IF NOT EXISTS ${this.TABLE_INVOICE} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoiceId TEXT NOT NULL UNIQUE,
      chatId INTEGER,
      messageId INTEGER,
      title TEXT,
      description TEXT,
      currency TEXT,
      totalAmount INTEGER,
      isTest INTEGER DEFAULT 0,
      needShippingAddress INTEGER DEFAULT 0,
      receiptMessageId INTEGER,
      extraJson TEXT
    )`;
    await this.rdbStore.executeSql(sqlInvoice);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_invoice_invoiceId ON ${this.TABLE_INVOICE} (invoiceId)`);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_invoice_chatId ON ${this.TABLE_INVOICE} (chatId)`);

    // 聊天统计表（简略缓存）
    const sqlChatStatistics = `CREATE TABLE IF NOT EXISTS ${this.TABLE_CHAT_STATISTICS} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      chatId INTEGER NOT NULL,
      periodStart INTEGER,
      periodEnd INTEGER,
      memberCount INTEGER,
      messageCount INTEGER,
      viewerCount INTEGER,
      senderCount INTEGER,
      extraJson TEXT,
      cachedAt INTEGER
    )`;
    await this.rdbStore.executeSql(sqlChatStatistics);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_chatstats_chatId ON ${this.TABLE_CHAT_STATISTICS} (chatId)`);
    await this.rdbStore.executeSql(`CREATE UNIQUE INDEX IF NOT EXISTS idx_chatstats_unique ON ${this.TABLE_CHAT_STATISTICS} (chatId, periodStart, periodEnd)`);

    // 通知声音表
    const sqlNotificationSound = `CREATE TABLE IF NOT EXISTS ${this.TABLE_NOTIFICATION_SOUND} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      soundId TEXT NOT NULL UNIQUE,
      title TEXT,
      duration INTEGER,
      fileId TEXT,
      extraJson TEXT
    )`;
    await this.rdbStore.executeSql(sqlNotificationSound);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_notifysound_soundId ON ${this.TABLE_NOTIFICATION_SOUND} (soundId)`);

    // 聊天背景表
    const sqlBackground = `CREATE TABLE IF NOT EXISTS ${this.TABLE_BACKGROUND} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      backgroundId TEXT NOT NULL UNIQUE,
      name TEXT,
      isDefault INTEGER DEFAULT 0,
      isDark INTEGER DEFAULT 0,
      type TEXT,
      fillJson TEXT,
      documentFileId TEXT,
      extraJson TEXT
    )`;
    await this.rdbStore.executeSql(sqlBackground);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_background_backgroundId ON ${this.TABLE_BACKGROUND} (backgroundId)`);

    // 游戏高分表
    const sqlGameHighScore = `CREATE TABLE IF NOT EXISTS ${this.TABLE_GAME_HIGH_SCORE} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      gameId TEXT NOT NULL,
      userId INTEGER NOT NULL,
      score INTEGER,
      position INTEGER,
      date INTEGER
    )`;
    await this.rdbStore.executeSql(sqlGameHighScore);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_gamehighscore_gameId ON ${this.TABLE_GAME_HIGH_SCORE} (gameId)`);
    await this.rdbStore.executeSql(`CREATE UNIQUE INDEX IF NOT EXISTS idx_gamehighscore_unique ON ${this.TABLE_GAME_HIGH_SCORE} (gameId, userId)`);

    // WebApp 会话表
    const sqlWebAppSession = `CREATE TABLE IF NOT EXISTS ${this.TABLE_WEBAPP_SESSION} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      botUserId INTEGER NOT NULL,
      launchId TEXT NOT NULL,
      url TEXT,
      mode TEXT,
      openedAt INTEGER,
      extraJson TEXT
    )`;
    await this.rdbStore.executeSql(sqlWebAppSession);
    await this.rdbStore.executeSql(`CREATE INDEX IF NOT EXISTS idx_webapp_botUserId ON ${this.TABLE_WEBAPP_SESSION} (botUserId)`);
    await this.rdbStore.executeSql(`CREATE UNIQUE INDEX IF NOT EXISTS idx_webapp_launchId ON ${this.TABLE_WEBAPP_SESSION} (launchId)`);
  }

  private async onUpgrade(store: relationalStore.RdbStore, oldVersion: number, newVersion: number): Promise<void> {
    CacheLogger.info(TAG, `Migrating from v${oldVersion} to v${newVersion}`);
    try {
      await store.beginTransaction();
      for (let v = oldVersion + 1; v <= newVersion; v++) {
        await this.migrateToVersion(store, v);
      }
      await store.commit();
    } catch (err) {
      await store.rollBack();
      const errorMessage = err instanceof Error ? err.message : String(err);
      CacheLogger.error(TAG, `Migration failed: ${errorMessage}`);
      throw new Error(`Migration failed: ${errorMessage}`);
    }
  }

  private async migrateToVersion(store: relationalStore.RdbStore, version: number): Promise<void> {
    switch (version) {
      case 1:
        // v1 是所有表的基础版本，表结构在 createTables() 中创建
        CacheLogger.info(TAG, 'v1: Creating all base tables');
        await this.createTables();
        break;
      default:
        CacheLogger.warn(TAG, `No migration for version ${version}`);
    }
  }

  getStore(): relationalStore.RdbStore | null {
    return this.rdbStore;
  }

  // ========== Message CRUD ==========
  private messageToValuesBucket(msg: MessageEntity): relationalStore.ValuesBucket {
    // 确保 senderId 是有效的数字类型，避免数据库参数错误
    const safeSenderId = typeof msg.senderId === 'number' && !isNaN(msg.senderId) ? msg.senderId : 0;
    return {
      'messageId': msg.messageId, 'chatId': msg.chatId, 'senderId': safeSenderId,
      'date': msg.date, 'editDate': msg.editDate, 'contentType': msg.contentType,
      'contentJson': msg.contentJson, 'caption': msg.caption, 'entitiesJson': msg.entitiesJson,
      'replyToMsgId': msg.replyToMsgId, 'mediaGroupId': msg.mediaGroupId,
      'forwardInfoJson': msg.forwardInfoJson, 'replyMarkupJson': msg.replyMarkupJson,
      'inlineKeyboardJson': msg.inlineKeyboardJson, 'flags': msg.flags,
      'pollId': msg.pollId ?? '', 'gameId': msg.gameId ?? 0,
      'invoiceId': msg.invoiceId ?? '', 'callbackQueryData': msg.callbackQueryData ?? '',
      'extraJson': msg.extraJson ?? ''
    };
  }

  async insertMessage(message: MessageEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    try {
      const rowId = await this.rdbStore.insert(this.TABLE_MESSAGE, this.messageToValuesBucket(message));
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, JSON.stringify(err));
    }
  }

  async insertMessagesBatch(messages: MessageEntity[]): Promise<CacheResult<number>> {
    if (!this.rdbStore || messages.length === 0) return CacheResult.ok(0);

    // 优化：使用 INSERT OR REPLACE 批量语句，比逐条插入快 10-50 倍
    try {
      await this.rdbStore.beginTransaction();

      // 构建批量插入 SQL
      const columns = [
        'messageId', 'chatId', 'senderId', 'date', 'editDate', 'contentType',
        'contentJson', 'caption', 'entitiesJson', 'replyToMsgId', 'mediaGroupId',
        'forwardInfoJson', 'replyMarkupJson', 'inlineKeyboardJson', 'flags',
        'pollId', 'gameId', 'invoiceId', 'callbackQueryData', 'extraJson'
      ];

      const placeholders = messages.map(() => `(${columns.map(() => '?').join(',')})`).join(',');
      const sql = `INSERT OR REPLACE INTO ${this.TABLE_MESSAGE} (${columns.join(',')}) VALUES ${placeholders}`;

      // 扁平化所有参数
      const params: relationalStore.ValueType[] = [];
      for (const msg of messages) {
        // 确保 senderId 是有效的数字类型，避免数据库参数错误
        const safeSenderId = typeof msg.senderId === 'number' && !isNaN(msg.senderId) ? msg.senderId : 0;
        params.push(
          msg.messageId, msg.chatId, safeSenderId, msg.date, msg.editDate, msg.contentType,
          msg.contentJson, msg.caption, msg.entitiesJson, msg.replyToMsgId, msg.mediaGroupId,
          msg.forwardInfoJson, msg.replyMarkupJson, msg.inlineKeyboardJson, msg.flags,
          msg.pollId ?? '', msg.gameId ?? 0, msg.invoiceId ?? '', msg.callbackQueryData ?? '', msg.extraJson ?? ''
        );
      }

      await this.rdbStore.executeSql(sql, params);
      await this.rdbStore.commit();
      return CacheResult.ok(messages.length);
    } catch (err) {
      await this.rdbStore.rollBack();
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, JSON.stringify(err));
    }
  }

  /**
   * 使用预编译语句批量插入（更高效的方案，适用于重复批量插入）
   */
  async insertMessagesBatchOptimized(messages: MessageEntity[]): Promise<CacheResult<number>> {
    if (!this.rdbStore || messages.length === 0) return CacheResult.ok(0);

    // 分批处理，每批 500 条，避免 SQL 过长
    const BATCH_SIZE = 500;
    let totalSuccess = 0;

    try {
      await this.rdbStore.beginTransaction();

      for (let i = 0; i < messages.length; i += BATCH_SIZE) {
        const batch = messages.slice(i, i + BATCH_SIZE);
        const result = await this.insertBatchInternal(batch);
        if (result.success) {
          totalSuccess += result.data || 0;
        }
      }

      await this.rdbStore.commit();
      return CacheResult.ok(totalSuccess);
    } catch (err) {
      await this.rdbStore.rollBack();
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, JSON.stringify(err));
    }
  }

  private async insertBatchInternal(messages: MessageEntity[]): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');

    const columns = [
      'messageId', 'chatId', 'senderId', 'date', 'editDate', 'contentType',
      'contentJson', 'caption', 'entitiesJson', 'replyToMsgId', 'mediaGroupId',
      'forwardInfoJson', 'replyMarkupJson', 'inlineKeyboardJson', 'flags',
      'pollId', 'gameId', 'invoiceId', 'callbackQueryData', 'extraJson'
    ];

    const placeholders = messages.map(() => `(${columns.map(() => '?').join(',')})`).join(',');
    const sql = `INSERT OR REPLACE INTO ${this.TABLE_MESSAGE} (${columns.join(',')}) VALUES ${placeholders}`;

    const params: relationalStore.ValueType[] = [];
    for (const msg of messages) {
      // 确保 senderId 是有效的数字类型，避免数据库参数错误
      const safeSenderId = typeof msg.senderId === 'number' && !isNaN(msg.senderId) ? msg.senderId : 0;
      params.push(
        msg.messageId, msg.chatId, safeSenderId, msg.date, msg.editDate, msg.contentType,
        msg.contentJson, msg.caption, msg.entitiesJson, msg.replyToMsgId, msg.mediaGroupId,
        msg.forwardInfoJson, msg.replyMarkupJson, msg.inlineKeyboardJson, msg.flags,
        msg.pollId ?? '', msg.gameId ?? 0, msg.invoiceId ?? '', msg.callbackQueryData ?? '', msg.extraJson ?? ''
      );
    }

    await this.rdbStore.executeSql(sql, params);
    return CacheResult.ok(messages.length);
  }

  async queryMessagesByChat(chatId: number, limit: number, offset: number): Promise<MessageEntity[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(this.TABLE_MESSAGE);
    predicates.equalTo('chatId', chatId).orderByDesc('date').limitAs(limit).offsetAs(offset);
    const result = await this.rdbStore.query(predicates);
    const list: MessageEntity[] = [];
    while (result.goToNextRow()) {
      const msg = new MessageEntity();
      msg.id = result.getLong(result.getColumnIndex('id'));
      msg.messageId = result.getLong(result.getColumnIndex('messageId'));
      msg.chatId = result.getLong(result.getColumnIndex('chatId'));
      msg.senderId = result.getLong(result.getColumnIndex('senderId'));
      msg.date = result.getLong(result.getColumnIndex('date'));
      msg.editDate = result.getLong(result.getColumnIndex('editDate'));
      msg.contentType = result.getString(result.getColumnIndex('contentType'));
      msg.contentJson = result.getString(result.getColumnIndex('contentJson'));
      msg.caption = result.getString(result.getColumnIndex('caption'));
      msg.entitiesJson = result.getString(result.getColumnIndex('entitiesJson'));
      msg.replyToMsgId = result.getLong(result.getColumnIndex('replyToMsgId'));
      msg.mediaGroupId = result.getString(result.getColumnIndex('mediaGroupId'));
      msg.forwardInfoJson = result.getString(result.getColumnIndex('forwardInfoJson'));
      msg.replyMarkupJson = result.getString(result.getColumnIndex('replyMarkupJson'));
      msg.inlineKeyboardJson = result.getString(result.getColumnIndex('inlineKeyboardJson'));
      msg.flags = result.getLong(result.getColumnIndex('flags'));
      msg.pollId = result.getString(result.getColumnIndex('pollId'));
      msg.gameId = result.getLong(result.getColumnIndex('gameId'));
      msg.invoiceId = result.getString(result.getColumnIndex('invoiceId'));
      msg.callbackQueryData = result.getString(result.getColumnIndex('callbackQueryData'));
      msg.extraJson = result.getString(result.getColumnIndex('extraJson'));
      list.push(msg);
    }
    result.close();
    return list;
  }

  async getMessageByMessageId(messageId: number): Promise<MessageEntity | undefined> {
    if (!this.rdbStore) return undefined;
    const predicates = new relationalStore.RdbPredicates(this.TABLE_MESSAGE);
    predicates.equalTo('messageId', messageId);
    const result = await this.rdbStore.query(predicates);
    if (result.goToFirstRow()) {
      const msg = new MessageEntity();
      msg.id = result.getLong(result.getColumnIndex('id'));
      msg.messageId = result.getLong(result.getColumnIndex('messageId'));
      msg.chatId = result.getLong(result.getColumnIndex('chatId'));
      msg.senderId = result.getLong(result.getColumnIndex('senderId'));
      msg.date = result.getLong(result.getColumnIndex('date'));
      msg.editDate = result.getLong(result.getColumnIndex('editDate'));
      msg.contentType = result.getString(result.getColumnIndex('contentType'));
      msg.contentJson = result.getString(result.getColumnIndex('contentJson'));
      msg.caption = result.getString(result.getColumnIndex('caption'));
      msg.entitiesJson = result.getString(result.getColumnIndex('entitiesJson'));
      msg.replyToMsgId = result.getLong(result.getColumnIndex('replyToMsgId'));
      msg.mediaGroupId = result.getString(result.getColumnIndex('mediaGroupId'));
      msg.forwardInfoJson = result.getString(result.getColumnIndex('forwardInfoJson'));
      msg.replyMarkupJson = result.getString(result.getColumnIndex('replyMarkupJson'));
      msg.inlineKeyboardJson = result.getString(result.getColumnIndex('inlineKeyboardJson'));
      msg.flags = result.getLong(result.getColumnIndex('flags'));
      msg.pollId = result.getString(result.getColumnIndex('pollId'));
      msg.gameId = result.getLong(result.getColumnIndex('gameId'));
      msg.invoiceId = result.getString(result.getColumnIndex('invoiceId'));
      msg.callbackQueryData = result.getString(result.getColumnIndex('callbackQueryData'));
      msg.extraJson = result.getString(result.getColumnIndex('extraJson'));
      result.close();
      return msg;
    }
    result.close();
    return undefined;
  }

  async updateMessage(message: MessageEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, 'DB not init');
    const values: relationalStore.ValuesBucket = {
      'editDate': message.editDate, 'contentJson': message.contentJson,
      'caption': message.caption, 'entitiesJson': message.entitiesJson, 'flags': message.flags,
      'pollId': message.pollId ?? '', 'gameId': message.gameId ?? 0,
      'invoiceId': message.invoiceId ?? '', 'callbackQueryData': message.callbackQueryData ?? '',
      'extraJson': message.extraJson ?? ''
    };
    const predicates = new relationalStore.RdbPredicates(this.TABLE_MESSAGE);
    predicates.equalTo('messageId', message.messageId);
    try {
      const rows = await this.rdbStore.update(values, predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, JSON.stringify(err));
    }
  }

  // ========== Chat CRUD ==========
  private chatToValuesBucket(chat: ChatEntity): relationalStore.ValuesBucket {
    return {
      'chatId': chat.chatId, 'title': chat.title, 'type': chat.type, 'photoJson': chat.photoJson,
      'lastMessageId': chat.lastMessageId, 'lastMessageDate': chat.lastMessageDate,
      'unreadCount': chat.unreadCount, 'draftMessage': chat.draftMessage,
      'lastReadMsgId': chat.lastReadMsgId, 'isMuted': chat.isMuted ? 1 : 0,
      'isPinned': chat.isPinned ? 1 : 0, 'syncCursor': chat.syncCursor,
      'extraJson': chat.extraJson,
      'canSendMessages': chat.canSendMessages ? 1 : 0,
      'canSendMedia': chat.canSendMedia ? 1 : 0,
      'canSendPolls': chat.canSendPolls ? 1 : 0,
      'canAddWebPagePreviews': chat.canAddWebPagePreviews ? 1 : 0,
      'muteUntil': chat.muteUntil,
      'showPreview': chat.showPreview ? 1 : 0,
      'memberStatusJson': chat.memberStatusJson
    };
  }

  async insertChat(chat: ChatEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    try {
      // 先检查是否存在
      const existingChat = await this.getChat(chat.chatId);
      if (existingChat) {
        // 已存在则更新
        const updateResult = await this.updateChat(chat);
        if (updateResult.success) {
          return CacheResult.ok(existingChat.id);
        } else {
          return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'Update existing chat failed');
        }
      }
      const rowId = await this.rdbStore.insert(this.TABLE_CHAT, this.chatToValuesBucket(chat));
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, JSON.stringify(err));
    }
  }

  async updateChat(chat: ChatEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, 'DB not init');
    const values: relationalStore.ValuesBucket = {
      'title': chat.title, 'type': chat.type, 'photoJson': chat.photoJson,
      'lastMessageId': chat.lastMessageId, 'lastMessageDate': chat.lastMessageDate,
      'unreadCount': chat.unreadCount, 'draftMessage': chat.draftMessage,
      'lastReadMsgId': chat.lastReadMsgId, 'isMuted': chat.isMuted ? 1 : 0,
      'isPinned': chat.isPinned ? 1 : 0, 'syncCursor': chat.syncCursor,
      'extraJson': chat.extraJson,
      'canSendMessages': chat.canSendMessages ? 1 : 0,
      'canSendMedia': chat.canSendMedia ? 1 : 0,
      'canSendPolls': chat.canSendPolls ? 1 : 0,
      'canAddWebPagePreviews': chat.canAddWebPagePreviews ? 1 : 0,
      'muteUntil': chat.muteUntil,
      'showPreview': chat.showPreview ? 1 : 0,
      'memberStatusJson': chat.memberStatusJson
    };
    const predicates = new relationalStore.RdbPredicates(this.TABLE_CHAT);
    predicates.equalTo('chatId', chat.chatId);
    try {
      const rows = await this.rdbStore.update(values, predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, JSON.stringify(err));
    }
  }

  async getChat(chatId: number): Promise<ChatEntity | undefined> {
    if (!this.rdbStore) return undefined;
    const predicates = new relationalStore.RdbPredicates(this.TABLE_CHAT);
    predicates.equalTo('chatId', chatId);
    const result = await this.rdbStore.query(predicates);
    if (result.goToFirstRow()) {
      const chat = new ChatEntity();
      chat.id = result.getLong(result.getColumnIndex('id'));
      chat.chatId = result.getLong(result.getColumnIndex('chatId'));
      chat.title = result.getString(result.getColumnIndex('title'));
      chat.type = result.getString(result.getColumnIndex('type'));
      chat.photoJson = result.getString(result.getColumnIndex('photoJson'));
      chat.lastMessageId = result.getLong(result.getColumnIndex('lastMessageId'));
      chat.lastMessageDate = result.getLong(result.getColumnIndex('lastMessageDate'));
      chat.unreadCount = result.getLong(result.getColumnIndex('unreadCount'));
      chat.draftMessage = result.getString(result.getColumnIndex('draftMessage'));
      chat.lastReadMsgId = result.getLong(result.getColumnIndex('lastReadMsgId'));
      chat.isMuted = result.getLong(result.getColumnIndex('isMuted')) === 1;
      chat.isPinned = result.getLong(result.getColumnIndex('isPinned')) === 1;
      chat.syncCursor = result.getLong(result.getColumnIndex('syncCursor'));
      chat.extraJson = result.getString(result.getColumnIndex('extraJson'));
      chat.canSendMessages = result.getLong(result.getColumnIndex('canSendMessages')) === 1;
      chat.canSendMedia = result.getLong(result.getColumnIndex('canSendMedia')) === 1;
      chat.canSendPolls = result.getLong(result.getColumnIndex('canSendPolls')) === 1;
      chat.canAddWebPagePreviews = result.getLong(result.getColumnIndex('canAddWebPagePreviews')) === 1;
      chat.muteUntil = result.getLong(result.getColumnIndex('muteUntil'));
      chat.showPreview = result.getLong(result.getColumnIndex('showPreview')) === 1;
      chat.memberStatusJson = result.getString(result.getColumnIndex('memberStatusJson'));
      result.close();
      return chat;
    }
    result.close();
    return undefined;
  }

  async getAllChats(): Promise<ChatEntity[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(this.TABLE_CHAT);
    predicates.orderByDesc('lastMessageDate');
    const result = await this.rdbStore.query(predicates);
    const list: ChatEntity[] = [];
    while (result.goToNextRow()) {
      const chat = new ChatEntity();
      chat.id = result.getLong(result.getColumnIndex('id'));
      chat.chatId = result.getLong(result.getColumnIndex('chatId'));
      chat.title = result.getString(result.getColumnIndex('title'));
      chat.type = result.getString(result.getColumnIndex('type'));
      chat.photoJson = result.getString(result.getColumnIndex('photoJson'));
      chat.lastMessageId = result.getLong(result.getColumnIndex('lastMessageId'));
      chat.lastMessageDate = result.getLong(result.getColumnIndex('lastMessageDate'));
      chat.unreadCount = result.getLong(result.getColumnIndex('unreadCount'));
      chat.draftMessage = result.getString(result.getColumnIndex('draftMessage'));
      chat.lastReadMsgId = result.getLong(result.getColumnIndex('lastReadMsgId'));
      chat.isMuted = result.getLong(result.getColumnIndex('isMuted')) === 1;
      chat.isPinned = result.getLong(result.getColumnIndex('isPinned')) === 1;
      chat.syncCursor = result.getLong(result.getColumnIndex('syncCursor'));
      chat.extraJson = result.getString(result.getColumnIndex('extraJson'));
      chat.canSendMessages = result.getLong(result.getColumnIndex('canSendMessages')) === 1;
      chat.canSendMedia = result.getLong(result.getColumnIndex('canSendMedia')) === 1;
      chat.canSendPolls = result.getLong(result.getColumnIndex('canSendPolls')) === 1;
      chat.canAddWebPagePreviews = result.getLong(result.getColumnIndex('canAddWebPagePreviews')) === 1;
      chat.muteUntil = result.getLong(result.getColumnIndex('muteUntil'));
      chat.showPreview = result.getLong(result.getColumnIndex('showPreview')) === 1;
      chat.memberStatusJson = result.getString(result.getColumnIndex('memberStatusJson'));
      list.push(chat);
    }
    result.close();
    return list;
  }

  // ========== Media CRUD ==========
  private mediaToValuesBucket(media: MediaEntity): relationalStore.ValuesBucket {
    return {
      'fileId': media.fileId, 'messageId': media.messageId, 'chatId': media.chatId,
      'fileType': media.fileType, 'localPath': media.localPath, 'remoteUrl': media.remoteUrl,
      'size': media.size, 'width': media.width, 'height': media.height, 'duration': media.duration,
      'mimeType': media.mimeType, 'thumbnailPath': media.thumbnailPath, 'extraJson': media.extraJson,
      'isDownloaded': media.isDownloaded ? 1 : 0, 'isDownloading': media.isDownloading ? 1 : 0,
      'downloadProgress': media.downloadProgress
    };
  }

  async insertMedia(media: MediaEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    try {
      const rowId = await this.rdbStore.insert(this.TABLE_MEDIA, this.mediaToValuesBucket(media));
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, JSON.stringify(err));
    }
  }

  async updateMedia(media: MediaEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, 'DB not init');
    const values = this.mediaToValuesBucket(media);
    const predicates = new relationalStore.RdbPredicates(this.TABLE_MEDIA);
    predicates.equalTo('fileId', media.fileId);
    try {
      const rows = await this.rdbStore.update(values, predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, JSON.stringify(err));
    }
  }

  async getMediaByFileId(fileId: string): Promise<MediaEntity | undefined> {
    if (!this.rdbStore) return undefined;
    const predicates = new relationalStore.RdbPredicates(this.TABLE_MEDIA);
    predicates.equalTo('fileId', fileId);
    const result = await this.rdbStore.query(predicates);
    if (result.goToFirstRow()) {
      const media = new MediaEntity();
      media.id = result.getLong(result.getColumnIndex('id'));
      media.fileId = result.getString(result.getColumnIndex('fileId'));
      media.messageId = result.getLong(result.getColumnIndex('messageId'));
      media.chatId = result.getLong(result.getColumnIndex('chatId'));
      media.fileType = result.getString(result.getColumnIndex('fileType'));
      media.localPath = result.getString(result.getColumnIndex('localPath'));
      media.remoteUrl = result.getString(result.getColumnIndex('remoteUrl'));
      media.size = result.getLong(result.getColumnIndex('size'));
      media.width = result.getLong(result.getColumnIndex('width'));
      media.height = result.getLong(result.getColumnIndex('height'));
      media.duration = result.getLong(result.getColumnIndex('duration'));
      media.mimeType = result.getString(result.getColumnIndex('mimeType'));
      media.thumbnailPath = result.getString(result.getColumnIndex('thumbnailPath'));
      media.extraJson = result.getString(result.getColumnIndex('extraJson'));
      media.isDownloaded = result.getLong(result.getColumnIndex('isDownloaded')) === 1;
      media.isDownloading = result.getLong(result.getColumnIndex('isDownloading')) === 1;
      media.downloadProgress = result.getLong(result.getColumnIndex('downloadProgress'));
      result.close();
      return media;
    }
    result.close();
    return undefined;
  }

  // ========== Story CRUD ==========
  async insertStory(story: StoryEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    const values: relationalStore.ValuesBucket = {
      'storyId': story.storyId,
      'senderId': story.senderId,
      'chatId': story.chatId,
      'date': story.date,
      'isEdited': story.isEdited ? 1 : 0,
      'isPinned': story.isPinned ? 1 : 0,
      'contentJson': story.contentJson,
      'interactionInfoJson': story.interactionInfoJson,
      'fileId': story.fileId ?? '',
      'isViewed': story.isViewed ? 1 : 0,
      'expireDate': story.expireDate
    };
    try {
      const rowId = await this.rdbStore.insert(this.TABLE_STORY, values);
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, JSON.stringify(err));
    }
  }

  async queryStoriesByChat(chatId: number, limit: number = 10): Promise<StoryEntity[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(this.TABLE_STORY);
    predicates.equalTo('chatId', chatId).orderByDesc('date').limitAs(limit);
    const result = await this.rdbStore.query(predicates);
    const stories: StoryEntity[] = [];
    while (result.goToNextRow()) {
      const story = new StoryEntity();
      story.id = result.getLong(result.getColumnIndex('id'));
      story.storyId = result.getLong(result.getColumnIndex('storyId'));
      story.senderId = result.getLong(result.getColumnIndex('senderId'));
      story.chatId = result.getLong(result.getColumnIndex('chatId'));
      story.date = result.getLong(result.getColumnIndex('date'));
      story.isEdited = result.getLong(result.getColumnIndex('isEdited')) === 1;
      story.isPinned = result.getLong(result.getColumnIndex('isPinned')) === 1;
      story.contentJson = result.getString(result.getColumnIndex('contentJson'));
      story.interactionInfoJson = result.getString(result.getColumnIndex('interactionInfoJson'));
      story.fileId = result.getString(result.getColumnIndex('fileId'));
      story.isViewed = result.getLong(result.getColumnIndex('isViewed')) === 1;
      story.expireDate = result.getLong(result.getColumnIndex('expireDate'));
      stories.push(story);
    }
    result.close();
    return stories;
  }

  async deleteExpiredStories(now: number): Promise<number> {
    if (!this.rdbStore) return 0;
    const predicates = new relationalStore.RdbPredicates(this.TABLE_STORY);
    predicates.lessThan('expireDate', now);
    try {
      return await this.rdbStore.delete(predicates);
    } catch (err) {
      CacheLogger.error(TAG, `deleteExpiredStories failed: ${err}`);
      return 0;
    }
  }

  // ========== Contact CRUD ==========
  private contactToValuesBucket(contact: ContactEntity): relationalStore.ValuesBucket {
    return {
      'userId': contact.userId,
      'phoneNumber': contact.phoneNumber,
      'firstName': contact.firstName,
      'lastName': contact.lastName,
      'fullName': contact.fullName,
      'username': contact.username,
      'avatarFileId': contact.avatarFileId ?? '',
      'isVerified': contact.isVerified ? 1 : 0,
      'isPremium': contact.isPremium ? 1 : 0,
      'isBot': contact.isBot ? 1 : 0,
      'isFavorite': contact.isFavorite ? 1 : 0,
      'syncStatus': contact.syncStatus,
      'lastUpdated': contact.lastUpdated,
      'extraJson': contact.extraJson ?? ''
    };
  }

  async insertContact(contact: ContactEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    try {
      const rowId = await this.rdbStore.insert(this.TABLE_CONTACT, this.contactToValuesBucket(contact));
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, JSON.stringify(err));
    }
  }

  async updateContact(contact: ContactEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, 'DB not init');
    const values = this.contactToValuesBucket(contact);
    const predicates = new relationalStore.RdbPredicates(this.TABLE_CONTACT);
    predicates.equalTo('phoneNumber', contact.phoneNumber);
    try {
      const rows = await this.rdbStore.update(values, predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, JSON.stringify(err));
    }
  }

  async getContactByPhoneNumber(phoneNumber: string): Promise<ContactEntity | undefined> {
    if (!this.rdbStore) return undefined;
    const predicates = new relationalStore.RdbPredicates(this.TABLE_CONTACT);
    predicates.equalTo('phoneNumber', phoneNumber);
    const result = await this.rdbStore.query(predicates);
    if (result.goToFirstRow()) {
      const contact = new ContactEntity();
      contact.id = result.getLong(result.getColumnIndex('id'));
      contact.userId = result.getLong(result.getColumnIndex('userId'));
      contact.phoneNumber = result.getString(result.getColumnIndex('phoneNumber'));
      contact.firstName = result.getString(result.getColumnIndex('firstName'));
      contact.lastName = result.getString(result.getColumnIndex('lastName'));
      contact.fullName = result.getString(result.getColumnIndex('fullName'));
      contact.username = result.getString(result.getColumnIndex('username'));
      contact.avatarFileId = result.getString(result.getColumnIndex('avatarFileId'));
      contact.isVerified = result.getLong(result.getColumnIndex('isVerified')) === 1;
      contact.isPremium = result.getLong(result.getColumnIndex('isPremium')) === 1;
      contact.isBot = result.getLong(result.getColumnIndex('isBot')) === 1;
      contact.isFavorite = result.getLong(result.getColumnIndex('isFavorite')) === 1;
      contact.syncStatus = result.getString(result.getColumnIndex('syncStatus'));
      contact.lastUpdated = result.getLong(result.getColumnIndex('lastUpdated'));
      contact.extraJson = result.getString(result.getColumnIndex('extraJson'));
      result.close();
      return contact;
    }
    result.close();
    return undefined;
  }

  async getAllContacts(): Promise<ContactEntity[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(this.TABLE_CONTACT);
    predicates.orderByAsc('firstName');
    const result = await this.rdbStore.query(predicates);
    const contacts: ContactEntity[] = [];
    while (result.goToNextRow()) {
      const contact = new ContactEntity();
      contact.id = result.getLong(result.getColumnIndex('id'));
      contact.userId = result.getLong(result.getColumnIndex('userId'));
      contact.phoneNumber = result.getString(result.getColumnIndex('phoneNumber'));
      contact.firstName = result.getString(result.getColumnIndex('firstName'));
      contact.lastName = result.getString(result.getColumnIndex('lastName'));
      contact.fullName = result.getString(result.getColumnIndex('fullName'));
      contact.username = result.getString(result.getColumnIndex('username'));
      contact.avatarFileId = result.getString(result.getColumnIndex('avatarFileId'));
      contact.isVerified = result.getLong(result.getColumnIndex('isVerified')) === 1;
      contact.isPremium = result.getLong(result.getColumnIndex('isPremium')) === 1;
      contact.isBot = result.getLong(result.getColumnIndex('isBot')) === 1;
      contact.isFavorite = result.getLong(result.getColumnIndex('isFavorite')) === 1;
      contact.syncStatus = result.getString(result.getColumnIndex('syncStatus'));
      contact.lastUpdated = result.getLong(result.getColumnIndex('lastUpdated'));
      contact.extraJson = result.getString(result.getColumnIndex('extraJson'));
      contacts.push(contact);
    }
    result.close();
    return contacts;
  }

  // ========== User CRUD ==========
  private userToValuesBucket(user: UserEntity): relationalStore.ValuesBucket {
    return {
      'userId': user.userId,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'username': user.username,
      'phoneNumber': user.phoneNumber,
      'isVerified': user.isVerified ? 1 : 0,
      'isPremium': user.isPremium ? 1 : 0,
      'isBot': user.isBot ? 1 : 0,
      'statusJson': user.statusJson,
      'profilePhotoFileId': user.profilePhotoFileId ?? '',
      'emojiStatus': user.emojiStatus ?? '',
      'bio': user.bio,
      'extraJson': user.extraJson,
      'lastUpdated': user.lastUpdated,
      'onlineStatus': user.onlineStatus,
      'lastSeen': user.lastSeen
    };
  }

  async insertUser(user: UserEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    try {
      const rowId = await this.rdbStore.insert(this.TABLE_USER, this.userToValuesBucket(user));
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, JSON.stringify(err));
    }
  }

  async updateUser(user: UserEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, 'DB not init');
    const values = this.userToValuesBucket(user);
    const predicates = new relationalStore.RdbPredicates(this.TABLE_USER);
    predicates.equalTo('userId', user.userId);
    try {
      const rows = await this.rdbStore.update(values, predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, JSON.stringify(err));
    }
  }

  async getUserByUserId(userId: number): Promise<UserEntity | undefined> {
    if (!this.rdbStore) return undefined;
    const predicates = new relationalStore.RdbPredicates(this.TABLE_USER);
    predicates.equalTo('userId', userId);
    const result = await this.rdbStore.query(predicates);
    if (result.goToFirstRow()) {
      const user = new UserEntity();
      user.id = result.getLong(result.getColumnIndex('id'));
      user.userId = result.getLong(result.getColumnIndex('userId'));
      user.firstName = result.getString(result.getColumnIndex('firstName'));
      user.lastName = result.getString(result.getColumnIndex('lastName'));
      user.username = result.getString(result.getColumnIndex('username'));
      user.phoneNumber = result.getString(result.getColumnIndex('phoneNumber'));
      user.isVerified = result.getLong(result.getColumnIndex('isVerified')) === 1;
      user.isPremium = result.getLong(result.getColumnIndex('isPremium')) === 1;
      user.isBot = result.getLong(result.getColumnIndex('isBot')) === 1;
      user.statusJson = result.getString(result.getColumnIndex('statusJson'));
      user.profilePhotoFileId = result.getString(result.getColumnIndex('profilePhotoFileId'));
      user.emojiStatus = result.getString(result.getColumnIndex('emojiStatus'));
      user.bio = result.getString(result.getColumnIndex('bio'));
      user.extraJson = result.getString(result.getColumnIndex('extraJson'));
      user.lastUpdated = result.getLong(result.getColumnIndex('lastUpdated'));
      user.onlineStatus = result.getString(result.getColumnIndex('onlineStatus'));
      user.lastSeen = result.getLong(result.getColumnIndex('lastSeen'));
      result.close();
      return user;
    }
    result.close();
    return undefined;
  }

  async searchUsersByKeyword(keyword: string): Promise<UserEntity[]> {
    if (!this.rdbStore) return [];
    const sql = `SELECT * FROM ${this.TABLE_USER} WHERE
                 firstName LIKE ? OR lastName LIKE ? OR username LIKE ? OR phoneNumber LIKE ?`;
    const params = [`%${keyword}%`, `%${keyword}%`, `%${keyword}%`, `%${keyword}%`];
    const result = await this.rdbStore.querySql(sql, params);
    const users: UserEntity[] = [];
    while (result.goToNextRow()) {
      const user = new UserEntity();
      user.id = result.getLong(result.getColumnIndex('id'));
      user.userId = result.getLong(result.getColumnIndex('userId'));
      user.firstName = result.getString(result.getColumnIndex('firstName'));
      user.lastName = result.getString(result.getColumnIndex('lastName'));
      user.username = result.getString(result.getColumnIndex('username'));
      user.phoneNumber = result.getString(result.getColumnIndex('phoneNumber'));
      user.isVerified = result.getLong(result.getColumnIndex('isVerified')) === 1;
      user.isPremium = result.getLong(result.getColumnIndex('isPremium')) === 1;
      user.isBot = result.getLong(result.getColumnIndex('isBot')) === 1;
      user.statusJson = result.getString(result.getColumnIndex('statusJson'));
      user.profilePhotoFileId = result.getString(result.getColumnIndex('profilePhotoFileId'));
      user.emojiStatus = result.getString(result.getColumnIndex('emojiStatus'));
      user.bio = result.getString(result.getColumnIndex('bio'));
      user.extraJson = result.getString(result.getColumnIndex('extraJson'));
      user.lastUpdated = result.getLong(result.getColumnIndex('lastUpdated'));
      user.onlineStatus = result.getString(result.getColumnIndex('onlineStatus'));
      user.lastSeen = result.getLong(result.getColumnIndex('lastSeen'));
      users.push(user);
    }
    result.close();
    return users;
  }

  // ========== ChatFilter CRUD ==========
  private filterToValuesBucket(filter: ChatFilterEntity): relationalStore.ValuesBucket {
    return {
      'filterId': filter.filterId,
      'title': filter.title,
      'iconName': filter.iconName,
      'orderNum': filter.order,
      'pinnedChatIdsJson': filter.pinnedChatIdsJson,
      'includedChatIdsJson': filter.includedChatIdsJson,
      'excludedChatIdsJson': filter.excludedChatIdsJson,
      'isPinned': filter.isPinned ? 1 : 0,
      'hasMyInvites': filter.hasMyInvites ? 1 : 0
    };
  }

  async insertChatFilter(filter: ChatFilterEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    try {
      const rowId = await this.rdbStore.insert(this.TABLE_CHAT_FILTER, this.filterToValuesBucket(filter));
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, JSON.stringify(err));
    }
  }

  async updateChatFilter(filter: ChatFilterEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, 'DB not init');
    const values = this.filterToValuesBucket(filter);
    const predicates = new relationalStore.RdbPredicates(this.TABLE_CHAT_FILTER);
    predicates.equalTo('filterId', filter.filterId);
    try {
      const rows = await this.rdbStore.update(values, predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, JSON.stringify(err));
    }
  }

  async getAllChatFilters(): Promise<ChatFilterEntity[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(this.TABLE_CHAT_FILTER);
    predicates.orderByAsc('orderNum');
    const result = await this.rdbStore.query(predicates);
    const filters: ChatFilterEntity[] = [];
    while (result.goToNextRow()) {
      const filter = new ChatFilterEntity();
      filter.id = result.getLong(result.getColumnIndex('id'));
      filter.filterId = result.getLong(result.getColumnIndex('filterId'));
      filter.title = result.getString(result.getColumnIndex('title'));
      filter.iconName = result.getString(result.getColumnIndex('iconName'));
      filter.order = result.getLong(result.getColumnIndex('orderNum'));
      filter.pinnedChatIdsJson = result.getString(result.getColumnIndex('pinnedChatIdsJson'));
      filter.includedChatIdsJson = result.getString(result.getColumnIndex('includedChatIdsJson'));
      filter.excludedChatIdsJson = result.getString(result.getColumnIndex('excludedChatIdsJson'));
      filter.isPinned = result.getLong(result.getColumnIndex('isPinned')) === 1;
      filter.hasMyInvites = result.getLong(result.getColumnIndex('hasMyInvites')) === 1;
      filters.push(filter);
    }
    result.close();
    return filters;
  }

  // ========== ChatBoost CRUD ==========
  async insertChatBoost(boost: ChatBoostEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    const values: relationalStore.ValuesBucket = {
      'boostId': boost.boostId,
      'chatId': boost.chatId,
      'userId': boost.userId,
      'date': boost.date,
      'expires': boost.expires,
      'sourceType': boost.sourceType,
      'sourceUserId': boost.sourceUserId ?? 0
    };
    try {
      const rowId = await this.rdbStore.insert(this.TABLE_CHAT_BOOST, values);
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, JSON.stringify(err));
    }
  }

  async getActiveBoostsByChat(chatId: number, now: number): Promise<ChatBoostEntity[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(this.TABLE_CHAT_BOOST);
    predicates.equalTo('chatId', chatId).greaterThan('expires', now);
    const result = await this.rdbStore.query(predicates);
    const boosts: ChatBoostEntity[] = [];
    while (result.goToNextRow()) {
      const boost = new ChatBoostEntity();
      boost.id = result.getLong(result.getColumnIndex('id'));
      boost.boostId = result.getLong(result.getColumnIndex('boostId'));
      boost.chatId = result.getLong(result.getColumnIndex('chatId'));
      boost.userId = result.getLong(result.getColumnIndex('userId'));
      boost.date = result.getLong(result.getColumnIndex('date'));
      boost.expires = result.getLong(result.getColumnIndex('expires'));
      boost.sourceType = result.getString(result.getColumnIndex('sourceType'));
      boost.sourceUserId = result.getLong(result.getColumnIndex('sourceUserId'));
      boosts.push(boost);
    }
    result.close();
    return boosts;
  }

  // ========== BotCommand CRUD ==========
  async insertBotCommand(cmd: BotCommandEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    const values: relationalStore.ValuesBucket = {
      'botUserId': cmd.botUserId,
      'command': cmd.command,
      'description': cmd.description
    };
    try {
      const rowId = await this.rdbStore.insert(this.TABLE_BOT_COMMAND, values);
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, JSON.stringify(err));
    }
  }

  async getBotCommands(botUserId: number): Promise<BotCommandEntity[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(this.TABLE_BOT_COMMAND);
    predicates.equalTo('botUserId', botUserId);
    const result = await this.rdbStore.query(predicates);
    const commands: BotCommandEntity[] = [];
    while (result.goToNextRow()) {
      const cmd = new BotCommandEntity();
      cmd.id = result.getLong(result.getColumnIndex('id'));
      cmd.botUserId = result.getLong(result.getColumnIndex('botUserId'));
      cmd.command = result.getString(result.getColumnIndex('command'));
      cmd.description = result.getString(result.getColumnIndex('description'));
      commands.push(cmd);
    }
    result.close();
    return commands;
  }

  async deleteBotCommands(botUserId: number): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, 'DB not init');
    const predicates = new relationalStore.RdbPredicates(this.TABLE_BOT_COMMAND);
    predicates.equalTo('botUserId', botUserId);
    try {
      const rows = await this.rdbStore.delete(predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, JSON.stringify(err));
    }
  }

  // ========== Reaction CRUD ==========
  async addReaction(reaction: ReactionEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    const values: relationalStore.ValuesBucket = {
      'messageId': reaction.messageId,
      'chatId': reaction.chatId,
      'emoji': reaction.emoji,
      'userId': reaction.userId,
      'date': reaction.date,
      'isSelected': reaction.isSelected ? 1 : 0
    };
    try {
      const rowId = await this.rdbStore.insert(this.TABLE_REACTION, values);
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, JSON.stringify(err));
    }
  }

  async removeReaction(messageId: number, emoji: string, userId: number): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, 'DB not init');
    const predicates = new relationalStore.RdbPredicates(this.TABLE_REACTION);
    predicates.equalTo('messageId', messageId).equalTo('emoji', emoji).equalTo('userId', userId);
    try {
      const rows = await this.rdbStore.delete(predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, JSON.stringify(err));
    }
  }

  async getReactionsForMessage(messageId: number): Promise<ReactionEntity[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(this.TABLE_REACTION);
    predicates.equalTo('messageId', messageId);
    const result = await this.rdbStore.query(predicates);
    const reactions: ReactionEntity[] = [];
    while (result.goToNextRow()) {
      const r = new ReactionEntity();
      r.id = result.getLong(result.getColumnIndex('id'));
      r.messageId = result.getLong(result.getColumnIndex('messageId'));
      r.chatId = result.getLong(result.getColumnIndex('chatId'));
      r.emoji = result.getString(result.getColumnIndex('emoji'));
      r.userId = result.getLong(result.getColumnIndex('userId'));
      r.date = result.getLong(result.getColumnIndex('date'));
      r.isSelected = result.getLong(result.getColumnIndex('isSelected')) === 1;
      reactions.push(r);
    }
    result.close();
    return reactions;
  }

  async getReactionCount(messageId: number): Promise<Map<string, number>> {
    const reactions = await this.getReactionsForMessage(messageId);
    const map = new Map<string, number>();
    for (const r of reactions) {
      if (r.isSelected) {
        map.set(r.emoji, (map.get(r.emoji) || 0) + 1);
      }
    }
    return map;
  }

  // ========== ChatPosition CRUD ==========
  async insertChatPosition(position: ChatPositionEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    const values: relationalStore.ValuesBucket = {
      'chatId': position.chatId,
      'listType': position.listType,
      'filterId': position.filterId ?? 0,
      'orderNum': position.order,
      'isPinned': position.isPinned ? 1 : 0,
      'source': position.source ?? ''
    };
    try {
      const rowId = await this.rdbStore.insert(this.TABLE_CHAT_POSITION, values);
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, JSON.stringify(err));
    }
  }

  async updateChatPosition(position: ChatPositionEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, 'DB not init');
    const values: relationalStore.ValuesBucket = {
      'orderNum': position.order,
      'isPinned': position.isPinned ? 1 : 0,
      'source': position.source ?? ''
    };
    const predicates = new relationalStore.RdbPredicates(this.TABLE_CHAT_POSITION);
    predicates.equalTo('chatId', position.chatId).equalTo('listType', position.listType);
    if (position.filterId) {
      predicates.equalTo('filterId', position.filterId);
    } else {
      predicates.isNull('filterId');
    }
    try {
      const rows = await this.rdbStore.update(values, predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, JSON.stringify(err));
    }
  }

  async getChatPositions(chatId: number): Promise<ChatPositionEntity[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(this.TABLE_CHAT_POSITION);
    predicates.equalTo('chatId', chatId);
    const result = await this.rdbStore.query(predicates);
    const positions: ChatPositionEntity[] = [];
    while (result.goToNextRow()) {
      const pos = new ChatPositionEntity();
      pos.id = result.getLong(result.getColumnIndex('id'));
      pos.chatId = result.getLong(result.getColumnIndex('chatId'));
      pos.listType = result.getString(result.getColumnIndex('listType'));
      const filterId = result.getLong(result.getColumnIndex('filterId'));
      pos.filterId = filterId === 0 ? undefined : filterId;
      pos.order = result.getLong(result.getColumnIndex('orderNum'));
      pos.isPinned = result.getLong(result.getColumnIndex('isPinned')) === 1;
      pos.source = result.getString(result.getColumnIndex('source'));
      positions.push(pos);
    }
    result.close();
    return positions;
  }

  async getChatsByList(listType: string, filterId?: number, limit?: number): Promise<number[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(this.TABLE_CHAT_POSITION);
    predicates.equalTo('listType', listType);
    if (filterId) {
      predicates.equalTo('filterId', filterId);
    } else if (listType !== 'filter') {
      predicates.isNull('filterId');
    }
    predicates.orderByDesc('orderNum');
    if (limit) predicates.limitAs(limit);
    const result = await this.rdbStore.query(predicates);
    const chatIds: number[] = [];
    while (result.goToNextRow()) {
      chatIds.push(result.getLong(result.getColumnIndex('chatId')));
    }
    result.close();
    return chatIds;
  }

  // ========== SecretChat CRUD ==========
  async insertSecretChat(secret: SecretChatEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    const values: relationalStore.ValuesBucket = {
      'secretChatId': secret.secretChatId,
      'userId': secret.userId,
      'state': secret.state,
      'ttl': secret.ttl,
      'keyHash': secret.keyHash,
      'layer': secret.layer,
      'isOutgoing': secret.isOutgoing ? 1 : 0
    };
    try {
      const rowId = await this.rdbStore.insert(this.TABLE_SECRET_CHAT, values);
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, JSON.stringify(err));
    }
  }

  async updateSecretChat(secret: SecretChatEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, 'DB not init');
    const values: relationalStore.ValuesBucket = {
      'state': secret.state,
      'ttl': secret.ttl,
      'keyHash': secret.keyHash,
      'layer': secret.layer,
      'isOutgoing': secret.isOutgoing ? 1 : 0
    };
    const predicates = new relationalStore.RdbPredicates(this.TABLE_SECRET_CHAT);
    predicates.equalTo('secretChatId', secret.secretChatId);
    try {
      const rows = await this.rdbStore.update(values, predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, JSON.stringify(err));
    }
  }

  async getSecretChatByUserId(userId: number): Promise<SecretChatEntity | undefined> {
    if (!this.rdbStore) return undefined;
    const predicates = new relationalStore.RdbPredicates(this.TABLE_SECRET_CHAT);
    predicates.equalTo('userId', userId);
    const result = await this.rdbStore.query(predicates);
    if (result.goToFirstRow()) {
      const secret = new SecretChatEntity();
      secret.id = result.getLong(result.getColumnIndex('id'));
      secret.secretChatId = result.getLong(result.getColumnIndex('secretChatId'));
      secret.userId = result.getLong(result.getColumnIndex('userId'));
      secret.state = result.getString(result.getColumnIndex('state'));
      secret.ttl = result.getLong(result.getColumnIndex('ttl'));
      secret.keyHash = result.getString(result.getColumnIndex('keyHash'));
      secret.layer = result.getLong(result.getColumnIndex('layer'));
      secret.isOutgoing = result.getLong(result.getColumnIndex('isOutgoing')) === 1;
      result.close();
      return secret;
    }
    result.close();
    return undefined;
  }

  // ========== PollOption CRUD ==========
  async upsertPollOption(option: PollOptionEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    const deletePredicates = new relationalStore.RdbPredicates(this.TABLE_POLL_OPTION);
    deletePredicates.equalTo('pollId', option.pollId).equalTo('optionIndex', option.optionIndex);
    await this.rdbStore.delete(deletePredicates);
    const values: relationalStore.ValuesBucket = {
      'pollId': option.pollId,
      'optionIndex': option.optionIndex,
      'text': option.text,
      'voterCount': option.voterCount,
      'isSelected': option.isSelected ? 1 : 0,
      'isChosen': option.isChosen ? 1 : 0
    };
    try {
      const rowId = await this.rdbStore.insert(this.TABLE_POLL_OPTION, values);
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, JSON.stringify(err));
    }
  }

  async getPollOptions(pollId: string): Promise<PollOptionEntity[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(this.TABLE_POLL_OPTION);
    predicates.equalTo('pollId', pollId);
    const result = await this.rdbStore.query(predicates);
    const options: PollOptionEntity[] = [];
    while (result.goToNextRow()) {
      const opt = new PollOptionEntity();
      opt.id = result.getLong(result.getColumnIndex('id'));
      opt.pollId = result.getString(result.getColumnIndex('pollId'));
      opt.optionIndex = result.getLong(result.getColumnIndex('optionIndex'));
      opt.text = result.getString(result.getColumnIndex('text'));
      opt.voterCount = result.getLong(result.getColumnIndex('voterCount'));
      opt.isSelected = result.getLong(result.getColumnIndex('isSelected')) === 1;
      opt.isChosen = result.getLong(result.getColumnIndex('isChosen')) === 1;
      options.push(opt);
    }
    result.close();
    return options;
  }

  async clearPollOptions(pollId: string): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, 'DB not init');
    const predicates = new relationalStore.RdbPredicates(this.TABLE_POLL_OPTION);
    predicates.equalTo('pollId', pollId);
    try {
      const rows = await this.rdbStore.delete(predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, JSON.stringify(err));
    }
  }

  // ========== Full-Text Search ==========
  async searchMessages(query: string, chatId?: number, limit: number = 50): Promise<MessageEntity[]> {
    if (!this.rdbStore) return [];
    let sql = `SELECT m.* FROM ${this.TABLE_MESSAGE} m
               JOIN ${this.TABLE_MESSAGE_FTS} f ON m.messageId = f.messageId
               WHERE f.content MATCH ?`;
    const params: relationalStore.ValueType[] = [query];
    if (chatId) {
      sql += ` AND m.chatId = ?`;
      params.push(chatId);
    }
    sql += ` ORDER BY bm25(f) LIMIT ${limit}`;
    const result = await this.rdbStore.querySql(sql, params);
    const messages: MessageEntity[] = [];
    while (result.goToNextRow()) {
      const msg = new MessageEntity();
      msg.id = result.getLong(result.getColumnIndex('id'));
      msg.messageId = result.getLong(result.getColumnIndex('messageId'));
      msg.chatId = result.getLong(result.getColumnIndex('chatId'));
      msg.senderId = result.getLong(result.getColumnIndex('senderId'));
      msg.date = result.getLong(result.getColumnIndex('date'));
      msg.editDate = result.getLong(result.getColumnIndex('editDate'));
      msg.contentType = result.getString(result.getColumnIndex('contentType'));
      msg.contentJson = result.getString(result.getColumnIndex('contentJson'));
      msg.caption = result.getString(result.getColumnIndex('caption'));
      msg.entitiesJson = result.getString(result.getColumnIndex('entitiesJson'));
      msg.replyToMsgId = result.getLong(result.getColumnIndex('replyToMsgId'));
      msg.mediaGroupId = result.getString(result.getColumnIndex('mediaGroupId'));
      msg.forwardInfoJson = result.getString(result.getColumnIndex('forwardInfoJson'));
      msg.replyMarkupJson = result.getString(result.getColumnIndex('replyMarkupJson'));
      msg.inlineKeyboardJson = result.getString(result.getColumnIndex('inlineKeyboardJson'));
      msg.flags = result.getLong(result.getColumnIndex('flags'));
      msg.pollId = result.getString(result.getColumnIndex('pollId'));
      msg.gameId = result.getLong(result.getColumnIndex('gameId'));
      msg.invoiceId = result.getString(result.getColumnIndex('invoiceId'));
      msg.callbackQueryData = result.getString(result.getColumnIndex('callbackQueryData'));
      msg.extraJson = result.getString(result.getColumnIndex('extraJson'));
      messages.push(msg);
    }
    result.close();
    return messages;
  }

  // ========== Delete Operations ==========

  async deleteMessage(messageId: number): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, 'DB not init');
    try {
      await this.rdbStore.beginTransaction();

      // 1. 删除消息的所有反应
      const reactionPredicates = new relationalStore.RdbPredicates(this.TABLE_REACTION);
      reactionPredicates.equalTo('messageId', messageId);
      await this.rdbStore.delete(reactionPredicates);

      // 2. 删除消息的媒体索引
      const mediaPredicates = new relationalStore.RdbPredicates(this.TABLE_MEDIA);
      mediaPredicates.equalTo('messageId', messageId);
      await this.rdbStore.delete(mediaPredicates);

      // 3. 删除消息（FTS 触发器会自动删除索引）
      const msgPredicates = new relationalStore.RdbPredicates(this.TABLE_MESSAGE);
      msgPredicates.equalTo('messageId', messageId);
      const rows = await this.rdbStore.delete(msgPredicates);

      await this.rdbStore.commit();
      return CacheResult.ok(rows);
    } catch (err) {
      await this.rdbStore.rollBack();
      return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, String(err));
    }
  }

  /**
   * ⭐ 批量删除消息（用于消息删除功能）
   * @param chatId 聊天ID
   * @param messageIds 消息ID数组
   */
  async deleteMessages(chatId: number, messageIds: number[]): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, 'DB not init');
    if (messageIds.length === 0) return CacheResult.ok(0);
    
    try {
      await this.rdbStore.beginTransaction();

      // 1. 删除所有消息的反应
      const placeholders = messageIds.map(() => '?').join(',');
      const reactionSql = `DELETE FROM ${this.TABLE_REACTION} WHERE messageId IN (${placeholders})`;
      await this.rdbStore.executeSql(reactionSql, messageIds);

      // 2. 删除所有消息的媒体索引
      const mediaSql = `DELETE FROM ${this.TABLE_MEDIA} WHERE messageId IN (${placeholders})`;
      await this.rdbStore.executeSql(mediaSql, messageIds);

      // 3. 删除所有消息（FTS 触发器会自动删除索引）
      const msgSql = `DELETE FROM ${this.TABLE_MESSAGE} WHERE chatId = ? AND messageId IN (${placeholders})`;
      const params = [chatId, ...messageIds];
      await this.rdbStore.executeSql(msgSql, params);

      await this.rdbStore.commit();
      // ⭐ executeSql 返回 void，直接返回成功
      return CacheResult.ok(messageIds.length);
    } catch (err) {
      await this.rdbStore.rollBack();
      CacheLogger.error(TAG, `❌ deleteMessages failed: ${JSON.stringify(err)}`);
      return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, String(err));
    }
  }

  async deleteChat(chatId: number): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, 'DB not init');
    try {
      await this.rdbStore.beginTransaction();

      // 1. 获取该会话下所有消息 ID
      const msgIds = await this.getMessageIdsByChatId(chatId);

      // 2. 删除所有消息的反应
      if (msgIds.length > 0) {
        const placeholders = msgIds.map(() => '?').join(',');
        const sql = `DELETE FROM ${this.TABLE_REACTION} WHERE messageId IN (${placeholders})`;
        await this.rdbStore.executeSql(sql, msgIds);
      }

      // 3. 删除所有消息的媒体索引
      if (msgIds.length > 0) {
        const placeholders = msgIds.map(() => '?').join(',');
        const sql = `DELETE FROM ${this.TABLE_MEDIA} WHERE messageId IN (${placeholders})`;
        await this.rdbStore.executeSql(sql, msgIds);
      }

      // 4. 删除所有消息（FTS 触发器自动清理）
      const msgPredicates = new relationalStore.RdbPredicates(this.TABLE_MESSAGE);
      msgPredicates.equalTo('chatId', chatId);
      await this.rdbStore.delete(msgPredicates);

      // 5. 删除该会话下的所有故事
      const storyPredicates = new relationalStore.RdbPredicates(this.TABLE_STORY);
      storyPredicates.equalTo('chatId', chatId);
      await this.rdbStore.delete(storyPredicates);

      // 6. 删除该会话下的所有聊天位置
      const posPredicates = new relationalStore.RdbPredicates(this.TABLE_CHAT_POSITION);
      posPredicates.equalTo('chatId', chatId);
      await this.rdbStore.delete(posPredicates);

      // 7. 删除会话本身
      const chatPredicates = new relationalStore.RdbPredicates(this.TABLE_CHAT);
      chatPredicates.equalTo('chatId', chatId);
      const rows = await this.rdbStore.delete(chatPredicates);

      await this.rdbStore.commit();
      return CacheResult.ok(rows);
    } catch (err) {
      await this.rdbStore.rollBack();
      return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, String(err));
    }
  }

  private async getMessageIdsByChatId(chatId: number): Promise<number[]> {
    if (!this.rdbStore) return [];
    const sql = `SELECT messageId FROM ${this.TABLE_MESSAGE} WHERE chatId = ?`;
    const result = await this.rdbStore.querySql(sql, [chatId]);
    const ids: number[] = [];
    while (result.goToNextRow()) {
      ids.push(result.getLong(result.getColumnIndex('messageId')));
    }
    result.close();
    return ids;
  }

  async deleteMediaByFileId(fileId: string): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, 'DB not init');
    const predicates = new relationalStore.RdbPredicates(this.TABLE_MEDIA);
    predicates.equalTo('fileId', fileId);
    try {
      const rows = await this.rdbStore.delete(predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, String(err));
    }
  }

  async deleteUser(userId: number): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, 'DB not init');
    try {
      await this.rdbStore.beginTransaction();

      // 1. 删除该用户创建的所有会话（私人聊天）
      const chatPredicates = new relationalStore.RdbPredicates(this.TABLE_CHAT);
      chatPredicates.equalTo('type', 'private').equalTo('chatId', userId);
      const chats = await this.rdbStore.query(chatPredicates);
      while (chats.goToNextRow()) {
        const chatId = chats.getLong(chats.getColumnIndex('chatId'));
        await this.deleteChat(chatId);
      }
      chats.close();

      // 2. 删除联系人记录
      const contactPredicates = new relationalStore.RdbPredicates(this.TABLE_CONTACT);
      contactPredicates.equalTo('userId', userId);
      await this.rdbStore.delete(contactPredicates);

      // 3. 删除机器人命令（如果该用户是机器人）
      const botPredicates = new relationalStore.RdbPredicates(this.TABLE_BOT_COMMAND);
      botPredicates.equalTo('botUserId', userId);
      await this.rdbStore.delete(botPredicates);

      // 4. 删除用户本身
      const userPredicates = new relationalStore.RdbPredicates(this.TABLE_USER);
      userPredicates.equalTo('userId', userId);
      const rows = await this.rdbStore.delete(userPredicates);

      await this.rdbStore.commit();
      return CacheResult.ok(rows);
    } catch (err) {
      await this.rdbStore.rollBack();
      return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, String(err));
    }
  }

  async getMediaByMessageId(messageId: number): Promise<MediaEntity[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(this.TABLE_MEDIA);
    predicates.equalTo('messageId', messageId);
    const result = await this.rdbStore.query(predicates);
    const list: MediaEntity[] = [];
    while (result.goToNextRow()) {
      const media = new MediaEntity();
      media.id = result.getLong(result.getColumnIndex('id'));
      media.fileId = result.getString(result.getColumnIndex('fileId'));
      media.messageId = result.getLong(result.getColumnIndex('messageId'));
      media.chatId = result.getLong(result.getColumnIndex('chatId'));
      media.fileType = result.getString(result.getColumnIndex('fileType'));
      media.localPath = result.getString(result.getColumnIndex('localPath'));
      list.push(media);
    }
    result.close();
    return list;
  }

  async getMediaByChatId(chatId: number): Promise<MediaEntity[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(this.TABLE_MEDIA);
    predicates.equalTo('chatId', chatId);
    const result = await this.rdbStore.query(predicates);
    const list: MediaEntity[] = [];
    while (result.goToNextRow()) {
      const media = new MediaEntity();
      media.id = result.getLong(result.getColumnIndex('id'));
      media.fileId = result.getString(result.getColumnIndex('fileId'));
      media.messageId = result.getLong(result.getColumnIndex('messageId'));
      media.chatId = result.getLong(result.getColumnIndex('chatId'));
      media.fileType = result.getString(result.getColumnIndex('fileType'));
      media.localPath = result.getString(result.getColumnIndex('localPath'));
      list.push(media);
    }
    result.close();
    return list;
  }

  async getPrivateChatsByUserId(userId: number): Promise<number[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(this.TABLE_CHAT);
    predicates.equalTo('type', 'private').equalTo('chatId', userId);
    const result = await this.rdbStore.query(predicates);
    const chatIds: number[] = [];
    while (result.goToNextRow()) {
      chatIds.push(result.getLong(result.getColumnIndex('chatId')));
    }
    result.close();
    return chatIds;
  }

  // ========== 补充删除方法 ==========

  async deleteStory(storyId: number): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, 'DB not init');
    const predicates = new relationalStore.RdbPredicates(this.TABLE_STORY);
    predicates.equalTo('storyId', storyId);
    try {
      const rows = await this.rdbStore.delete(predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, String(err));
    }
  }

  async deleteChatFilter(filterId: number): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, 'DB not init');
    const predicates = new relationalStore.RdbPredicates(this.TABLE_CHAT_FILTER);
    predicates.equalTo('filterId', filterId);
    try {
      const rows = await this.rdbStore.delete(predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, String(err));
    }
  }

  async deleteChatBoost(boostId: number): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, 'DB not init');
    const predicates = new relationalStore.RdbPredicates(this.TABLE_CHAT_BOOST);
    predicates.equalTo('boostId', boostId);
    try {
      const rows = await this.rdbStore.delete(predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, String(err));
    }
  }

  async deleteSecretChat(secretChatId: number): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, 'DB not init');
    const predicates = new relationalStore.RdbPredicates(this.TABLE_SECRET_CHAT);
    predicates.equalTo('secretChatId', secretChatId);
    try {
      const rows = await this.rdbStore.delete(predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, String(err));
    }
  }

  async clearDraft(chatId: number): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, 'DB not init');
    const values: relationalStore.ValuesBucket = { 'draftMessage': '' };
    const predicates = new relationalStore.RdbPredicates(this.TABLE_CHAT);
    predicates.equalTo('chatId', chatId);
    try {
      const rows = await this.rdbStore.update(values, predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, String(err));
    }
  }

  async deleteMessagesByChat(chatId: number): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, 'DB not init');
    try {
      await this.rdbStore.beginTransaction();

      // 1. 获取该会话下所有消息 ID
      const msgIds = await this.getMessageIdsByChatId(chatId);

      // 2. 删除所有消息的反应
      if (msgIds.length > 0) {
        const placeholders = msgIds.map(() => '?').join(',');
        const sql = `DELETE FROM ${this.TABLE_REACTION} WHERE messageId IN (${placeholders})`;
        await this.rdbStore.executeSql(sql, msgIds);
      }

      // 3. 删除所有消息的媒体索引
      if (msgIds.length > 0) {
        const placeholders = msgIds.map(() => '?').join(',');
        const sql = `DELETE FROM ${this.TABLE_MEDIA} WHERE messageId IN (${placeholders})`;
        await this.rdbStore.executeSql(sql, msgIds);
      }

      // 4. 删除所有消息（FTS 触发器自动清理）
      const msgPredicates = new relationalStore.RdbPredicates(this.TABLE_MESSAGE);
      msgPredicates.equalTo('chatId', chatId);
      const rows = await this.rdbStore.delete(msgPredicates);

      await this.rdbStore.commit();
      return CacheResult.ok(rows);
    } catch (err) {
      await this.rdbStore.rollBack();
      return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, String(err));
    }
  }

  async getStoryById(storyId: number): Promise<StoryEntity | undefined> {
    if (!this.rdbStore) return undefined;
    const predicates = new relationalStore.RdbPredicates(this.TABLE_STORY);
    predicates.equalTo('storyId', storyId);
    const result = await this.rdbStore.query(predicates);
    if (result.goToFirstRow()) {
      const story = new StoryEntity();
      story.id = result.getLong(result.getColumnIndex('id'));
      story.storyId = result.getLong(result.getColumnIndex('storyId'));
      story.senderId = result.getLong(result.getColumnIndex('senderId'));
      story.chatId = result.getLong(result.getColumnIndex('chatId'));
      story.date = result.getLong(result.getColumnIndex('date'));
      story.expireDate = result.getLong(result.getColumnIndex('expireDate'));
      story.isEdited = result.getLong(result.getColumnIndex('isEdited')) === 1;
      story.isPinned = result.getLong(result.getColumnIndex('isPinned')) === 1;
      story.contentJson = result.getString(result.getColumnIndex('contentJson'));
      result.close();
      return story;
    }
    result.close();
    return undefined;
  }

  async queryExpiredStories(now: number): Promise<StoryEntity[]> {
    if (!this.rdbStore) return [];
    const sql = `SELECT * FROM ${this.TABLE_STORY} WHERE expireDate < ?`;
    const result = await this.rdbStore.querySql(sql, [now]);
    const list: StoryEntity[] = [];
    while (result.goToNextRow()) {
      const story = new StoryEntity();
      story.id = result.getLong(result.getColumnIndex('id'));
      story.storyId = result.getLong(result.getColumnIndex('storyId'));
      story.senderId = result.getLong(result.getColumnIndex('senderId'));
      story.chatId = result.getLong(result.getColumnIndex('chatId'));
      story.date = result.getLong(result.getColumnIndex('date'));
      story.expireDate = result.getLong(result.getColumnIndex('expireDate'));
      story.isEdited = result.getLong(result.getColumnIndex('isEdited')) === 1;
      story.isPinned = result.getLong(result.getColumnIndex('isPinned')) === 1;
      story.contentJson = result.getString(result.getColumnIndex('contentJson'));
      list.push(story);
    }
    result.close();
    return list;
  }

  async deleteReaction(messageId: number, emoji: string, userId: number): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, 'DB not init');
    const predicates = new relationalStore.RdbPredicates(this.TABLE_REACTION);
    predicates.equalTo('messageId', messageId).equalTo('emoji', emoji).equalTo('userId', userId);
    try {
      const rows = await this.rdbStore.delete(predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, String(err));
    }
  }

  async deletePollOption(pollId: string, optionIndex: number): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, 'DB not init');
    const predicates = new relationalStore.RdbPredicates(this.TABLE_POLL_OPTION);
    predicates.equalTo('pollId', pollId).equalTo('optionIndex', optionIndex);
    try {
      const rows = await this.rdbStore.delete(predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, String(err));
    }
  }

  // ========== Transaction ==========
  async runInTransaction<T>(callback: () => Promise<T>): Promise<T> {
    if (!this.rdbStore) throw new Error('DB not init');
    try {
      await this.rdbStore.beginTransaction();
      const result = await callback();
      await this.rdbStore.commit();
      return result;
    } catch (err) {
      await this.rdbStore.rollBack();
      const errorMessage = err instanceof Error ? err.message : String(err);
      throw new Error(`Transaction failed: ${errorMessage}`);
    }
  }

  // ========== 回收站方法 ==========

  async addToRecycleBin(
    itemId: number,
    itemType: string,
    originalDataJson: string,
    retentionDays: number = 30,
    chatId?: number,
    title?: string,
    extraJson?: string
  ): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    const now = Date.now();
    const expiresAt = now + retentionDays * 24 * 60 * 60 * 1000;
    const values: relationalStore.ValuesBucket = {
      'itemId': itemId,
      'itemType': itemType,
      'originalDataJson': originalDataJson,
      'deletedAt': now,
      'expiresAt': expiresAt,
      'chatId': chatId ?? null,
      'title': title ?? '',
      'extraJson': extraJson ?? ''
    };
    try {
      const rowId = await this.rdbStore.insert(this.TABLE_RECYCLE_BIN, values);
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, String(err));
    }
  }

  async getRecycleBinItems(itemType?: string, limit: number = 100): Promise<RecycleBinItem[]> {
    if (!this.rdbStore) return [];
    let sql = `SELECT * FROM ${this.TABLE_RECYCLE_BIN}`;
    const args: (string | number)[] = [];
    if (itemType) {
      sql += ` WHERE itemType = ?`;
      args.push(itemType);
    }
    sql += ` ORDER BY deletedAt DESC LIMIT ?`;
    args.push(limit);
    const result = await this.rdbStore.querySql(sql, args);
    const items: RecycleBinItem[] = [];
    while (result.goToNextRow()) {
      items.push({
        id: result.getLong(result.getColumnIndex('id')),
        itemId: result.getLong(result.getColumnIndex('itemId')),
        itemType: result.getString(result.getColumnIndex('itemType')),
        originalDataJson: result.getString(result.getColumnIndex('originalDataJson')),
        deletedAt: result.getLong(result.getColumnIndex('deletedAt')),
        expiresAt: result.getLong(result.getColumnIndex('expiresAt')),
        chatId: result.getLong(result.getColumnIndex('chatId')) || undefined,
        title: result.getString(result.getColumnIndex('title')) || undefined
      });
    }
    result.close();
    return items;
  }

  async restoreFromRecycleBin(itemId: number, itemType: string): Promise<CacheResult<string | null>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_QUERY_FAILED, 'DB not init');
    const predicates = new relationalStore.RdbPredicates(this.TABLE_RECYCLE_BIN);
    predicates.equalTo('itemId', itemId).equalTo('itemType', itemType);
    const result = await this.rdbStore.query(predicates);
    if (result.goToFirstRow()) {
      const originalData = result.getString(result.getColumnIndex('originalDataJson'));
      result.close();
      // 从回收站删除
      await this.rdbStore.delete(predicates);
      return CacheResult.ok(originalData);
    }
    result.close();
    return CacheResult.fail(ErrorCodes.DB_QUERY_FAILED, 'Item not found in recycle bin');
  }

  async permanentlyDeleteFromRecycleBin(itemId: number, itemType: string): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, 'DB not init');
    const predicates = new relationalStore.RdbPredicates(this.TABLE_RECYCLE_BIN);
    predicates.equalTo('itemId', itemId).equalTo('itemType', itemType);
    try {
      const rows = await this.rdbStore.delete(predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, String(err));
    }
  }

  async clearExpiredRecycleBinItems(now: number = Date.now()): Promise<number> {
    if (!this.rdbStore) return 0;
    const predicates = new relationalStore.RdbPredicates(this.TABLE_RECYCLE_BIN);
    predicates.lessThan('expiresAt', now);
    try {
      const rows = await this.rdbStore.delete(predicates);
      return rows;
    } catch (err) {
      CacheLogger.error(TAG, `Failed to clear expired recycle bin items: ${err}`);
      return 0;
    }
  }

  async getRecycleBinStats(): Promise<RecycleBinStats> {
    if (!this.rdbStore) return { total: 0, byType: {} };
    const sql = `SELECT itemType, COUNT(*) as count FROM ${this.TABLE_RECYCLE_BIN} GROUP BY itemType`;
    const result = await this.rdbStore.querySql(sql, []);
    const byType: Record<string, number> = {};
    let total = 0;
    while (result.goToNextRow()) {
      const type = result.getString(result.getColumnIndex('itemType'));
      const count = result.getLong(result.getColumnIndex('count'));
      byType[type] = count;
      total += count;
    }
    result.close();
    return { total, byType };
  }

  // ========== StickerSet CRUD ==========
  async insertStickerSet(set: StickerSetEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    const values: relationalStore.ValuesBucket = {
      'setId': set.setId, 'title': set.title, 'name': set.name,
      'stickerType': set.stickerType, 'thumbnailFileId': set.thumbnailFileId ?? '',
      'isInstalled': set.isInstalled ? 1 : 0, 'isArchived': set.isArchived ? 1 : 0,
      'isOfficial': set.isOfficial ? 1 : 0, 'isViewed': set.isViewed ? 1 : 0,
      'size': set.size, 'extraJson': set.extraJson, 'lastUpdated': set.lastUpdated
    };
    try {
      const rowId = await this.rdbStore.insert(this.TABLE_STICKER_SET, values);
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, String(err));
    }
  }

  async updateStickerSet(set: StickerSetEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, 'DB not init');
    const values: relationalStore.ValuesBucket = {
      'title': set.title, 'name': set.name,
      'stickerType': set.stickerType, 'thumbnailFileId': set.thumbnailFileId ?? '',
      'isInstalled': set.isInstalled ? 1 : 0, 'isArchived': set.isArchived ? 1 : 0,
      'isOfficial': set.isOfficial ? 1 : 0, 'isViewed': set.isViewed ? 1 : 0,
      'size': set.size, 'extraJson': set.extraJson, 'lastUpdated': set.lastUpdated
    };
    const predicates = new relationalStore.RdbPredicates(this.TABLE_STICKER_SET);
    predicates.equalTo('setId', set.setId);
    try {
      const rows = await this.rdbStore.update(values, predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, String(err));
    }
  }

  async deleteStickerSet(setId: string): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, 'DB not init');
    const predicates = new relationalStore.RdbPredicates(this.TABLE_STICKER_SET);
    predicates.equalTo('setId', setId);
    try {
      const rows = await this.rdbStore.delete(predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_DELETE_FAILED, String(err));
    }
  }

  async getStickerSet(setId: string): Promise<StickerSetEntity | undefined> {
    if (!this.rdbStore) return undefined;
    const predicates = new relationalStore.RdbPredicates(this.TABLE_STICKER_SET);
    predicates.equalTo('setId', setId);
    const result = await this.rdbStore.query(predicates);
    if (result.goToFirstRow()) {
      const set = new StickerSetEntity();
      set.id = result.getLong(result.getColumnIndex('id'));
      set.setId = result.getString(result.getColumnIndex('setId'));
      set.title = result.getString(result.getColumnIndex('title'));
      set.name = result.getString(result.getColumnIndex('name'));
      set.stickerType = result.getString(result.getColumnIndex('stickerType'));
      set.thumbnailFileId = result.getString(result.getColumnIndex('thumbnailFileId'));
      set.isInstalled = result.getLong(result.getColumnIndex('isInstalled')) === 1;
      set.isArchived = result.getLong(result.getColumnIndex('isArchived')) === 1;
      set.isOfficial = result.getLong(result.getColumnIndex('isOfficial')) === 1;
      set.isViewed = result.getLong(result.getColumnIndex('isViewed')) === 1;
      set.size = result.getLong(result.getColumnIndex('size'));
      set.extraJson = result.getString(result.getColumnIndex('extraJson'));
      set.lastUpdated = result.getLong(result.getColumnIndex('lastUpdated'));
      result.close();
      return set;
    }
    result.close();
    return undefined;
  }

  async getAllStickerSets(): Promise<StickerSetEntity[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(this.TABLE_STICKER_SET);
    predicates.orderByDesc('lastUpdated');
    const result = await this.rdbStore.query(predicates);
    const sets: StickerSetEntity[] = [];
    while (result.goToNextRow()) {
      const set = new StickerSetEntity();
      set.id = result.getLong(result.getColumnIndex('id'));
      set.setId = result.getString(result.getColumnIndex('setId'));
      set.title = result.getString(result.getColumnIndex('title'));
      set.name = result.getString(result.getColumnIndex('name'));
      set.stickerType = result.getString(result.getColumnIndex('stickerType'));
      set.thumbnailFileId = result.getString(result.getColumnIndex('thumbnailFileId'));
      set.isInstalled = result.getLong(result.getColumnIndex('isInstalled')) === 1;
      set.isArchived = result.getLong(result.getColumnIndex('isArchived')) === 1;
      set.isOfficial = result.getLong(result.getColumnIndex('isOfficial')) === 1;
      set.isViewed = result.getLong(result.getColumnIndex('isViewed')) === 1;
      set.size = result.getLong(result.getColumnIndex('size'));
      set.extraJson = result.getString(result.getColumnIndex('extraJson'));
      set.lastUpdated = result.getLong(result.getColumnIndex('lastUpdated'));
      sets.push(set);
    }
    result.close();
    return sets;
  }

  // ========== Sticker CRUD ==========
  async insertSticker(sticker: StickerEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    const values: relationalStore.ValuesBucket = {
      'stickerId': sticker.stickerId, 'setId': sticker.setId,
      'format': sticker.format, 'type': sticker.type, 'emoji': sticker.emoji,
      'width': sticker.width, 'height': sticker.height, 'fileId': sticker.fileId,
      'thumbnailFileId': sticker.thumbnailFileId ?? '',
      'maskPositionJson': sticker.maskPositionJson ?? '',
      'isPremium': sticker.isPremium ? 1 : 0, 'extraJson': sticker.extraJson
    };
    try {
      const rowId = await this.rdbStore.insert(this.TABLE_STICKER, values);
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, String(err));
    }
  }

  async getStickersBySetId(setId: string): Promise<StickerEntity[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(this.TABLE_STICKER);
    predicates.equalTo('setId', setId);
    const result = await this.rdbStore.query(predicates);
    const stickers: StickerEntity[] = [];
    while (result.goToNextRow()) {
      const s = new StickerEntity();
      s.id = result.getLong(result.getColumnIndex('id'));
      s.stickerId = result.getString(result.getColumnIndex('stickerId'));
      s.setId = result.getString(result.getColumnIndex('setId'));
      s.format = result.getString(result.getColumnIndex('format'));
      s.type = result.getString(result.getColumnIndex('type'));
      s.emoji = result.getString(result.getColumnIndex('emoji'));
      s.width = result.getLong(result.getColumnIndex('width'));
      s.height = result.getLong(result.getColumnIndex('height'));
      s.fileId = result.getString(result.getColumnIndex('fileId'));
      s.thumbnailFileId = result.getString(result.getColumnIndex('thumbnailFileId'));
      s.maskPositionJson = result.getString(result.getColumnIndex('maskPositionJson'));
      s.isPremium = result.getLong(result.getColumnIndex('isPremium')) === 1;
      s.extraJson = result.getString(result.getColumnIndex('extraJson'));
      stickers.push(s);
    }
    result.close();
    return stickers;
  }

  // ========== BotInfo CRUD ==========
  async insertBotInfo(botInfo: BotInfoEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    const values: relationalStore.ValuesBucket = {
      'botUserId': botInfo.botUserId, 'shortDescription': botInfo.shortDescription,
      'description': botInfo.description, 'photoFileId': botInfo.photoFileId ?? '',
      'animationFileId': botInfo.animationFileId ?? '',
      'menuButtonJson': botInfo.menuButtonJson ?? '',
      'commandsJson': botInfo.commandsJson,
      'privacyPolicyUrl': botInfo.privacyPolicyUrl,
      'defaultGroupAdminRightsJson': botInfo.defaultGroupAdminRightsJson ?? '',
      'defaultChannelAdminRightsJson': botInfo.defaultChannelAdminRightsJson ?? '',
      'canGetRevenueStatistics': botInfo.canGetRevenueStatistics ? 1 : 0,
      'extraJson': botInfo.extraJson
    };
    try {
      const rowId = await this.rdbStore.insert(this.TABLE_BOT_INFO, values);
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, String(err));
    }
  }

  async updateBotInfo(botInfo: BotInfoEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, 'DB not init');
    const values: relationalStore.ValuesBucket = {
      'shortDescription': botInfo.shortDescription,
      'description': botInfo.description, 'photoFileId': botInfo.photoFileId ?? '',
      'animationFileId': botInfo.animationFileId ?? '',
      'menuButtonJson': botInfo.menuButtonJson ?? '',
      'commandsJson': botInfo.commandsJson,
      'privacyPolicyUrl': botInfo.privacyPolicyUrl,
      'defaultGroupAdminRightsJson': botInfo.defaultGroupAdminRightsJson ?? '',
      'defaultChannelAdminRightsJson': botInfo.defaultChannelAdminRightsJson ?? '',
      'canGetRevenueStatistics': botInfo.canGetRevenueStatistics ? 1 : 0,
      'extraJson': botInfo.extraJson
    };
    const predicates = new relationalStore.RdbPredicates(this.TABLE_BOT_INFO);
    predicates.equalTo('botUserId', botInfo.botUserId);
    try {
      const rows = await this.rdbStore.update(values, predicates);
      return CacheResult.ok(rows);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_UPDATE_FAILED, String(err));
    }
  }

  async getBotInfo(botUserId: number): Promise<BotInfoEntity | undefined> {
    if (!this.rdbStore) return undefined;
    const predicates = new relationalStore.RdbPredicates(this.TABLE_BOT_INFO);
    predicates.equalTo('botUserId', botUserId);
    const result = await this.rdbStore.query(predicates);
    if (result.goToFirstRow()) {
      const bot = new BotInfoEntity();
      bot.id = result.getLong(result.getColumnIndex('id'));
      bot.botUserId = result.getLong(result.getColumnIndex('botUserId'));
      bot.shortDescription = result.getString(result.getColumnIndex('shortDescription'));
      bot.description = result.getString(result.getColumnIndex('description'));
      bot.photoFileId = result.getString(result.getColumnIndex('photoFileId'));
      bot.animationFileId = result.getString(result.getColumnIndex('animationFileId'));
      bot.menuButtonJson = result.getString(result.getColumnIndex('menuButtonJson'));
      bot.commandsJson = result.getString(result.getColumnIndex('commandsJson'));
      bot.privacyPolicyUrl = result.getString(result.getColumnIndex('privacyPolicyUrl'));
      bot.defaultGroupAdminRightsJson = result.getString(result.getColumnIndex('defaultGroupAdminRightsJson'));
      bot.defaultChannelAdminRightsJson = result.getString(result.getColumnIndex('defaultChannelAdminRightsJson'));
      bot.canGetRevenueStatistics = result.getLong(result.getColumnIndex('canGetRevenueStatistics')) === 1;
      bot.extraJson = result.getString(result.getColumnIndex('extraJson'));
      result.close();
      return bot;
    }
    result.close();
    return undefined;
  }

  // ========== Gift CRUD ==========
  async insertGift(gift: GiftEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    const values: relationalStore.ValuesBucket = {
      'giftId': gift.giftId, 'stickerFileId': gift.stickerFileId,
      'starCount': gift.starCount, 'upgradeStarCount': gift.upgradeStarCount,
      'backgroundJson': gift.backgroundJson,
      'isPremium': gift.isPremium ? 1 : 0,
      'isForBirthday': gift.isForBirthday ? 1 : 0,
      'extraJson': gift.extraJson
    };
    try {
      const rowId = await this.rdbStore.insert(this.TABLE_GIFT, values);
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, String(err));
    }
  }

  async getGift(giftId: string): Promise<GiftEntity | undefined> {
    if (!this.rdbStore) return undefined;
    const predicates = new relationalStore.RdbPredicates(this.TABLE_GIFT);
    predicates.equalTo('giftId', giftId);
    const result = await this.rdbStore.query(predicates);
    if (result.goToFirstRow()) {
      const gift = new GiftEntity();
      gift.id = result.getLong(result.getColumnIndex('id'));
      gift.giftId = result.getString(result.getColumnIndex('giftId'));
      gift.stickerFileId = result.getString(result.getColumnIndex('stickerFileId'));
      gift.starCount = result.getLong(result.getColumnIndex('starCount'));
      gift.upgradeStarCount = result.getLong(result.getColumnIndex('upgradeStarCount'));
      gift.backgroundJson = result.getString(result.getColumnIndex('backgroundJson'));
      gift.isPremium = result.getLong(result.getColumnIndex('isPremium')) === 1;
      gift.isForBirthday = result.getLong(result.getColumnIndex('isForBirthday')) === 1;
      gift.extraJson = result.getString(result.getColumnIndex('extraJson'));
      result.close();
      return gift;
    }
    result.close();
    return undefined;
  }

  async getAllGifts(): Promise<GiftEntity[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(this.TABLE_GIFT);
    const result = await this.rdbStore.query(predicates);
    const gifts: GiftEntity[] = [];
    while (result.goToNextRow()) {
      const gift = new GiftEntity();
      gift.id = result.getLong(result.getColumnIndex('id'));
      gift.giftId = result.getString(result.getColumnIndex('giftId'));
      gift.stickerFileId = result.getString(result.getColumnIndex('stickerFileId'));
      gift.starCount = result.getLong(result.getColumnIndex('starCount'));
      gift.upgradeStarCount = result.getLong(result.getColumnIndex('upgradeStarCount'));
      gift.backgroundJson = result.getString(result.getColumnIndex('backgroundJson'));
      gift.isPremium = result.getLong(result.getColumnIndex('isPremium')) === 1;
      gift.isForBirthday = result.getLong(result.getColumnIndex('isForBirthday')) === 1;
      gift.extraJson = result.getString(result.getColumnIndex('extraJson'));
      gifts.push(gift);
    }
    result.close();
    return gifts;
  }

  // ========== StarTransaction CRUD ==========
  async insertStarTransaction(transaction: StarTransactionEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    const values: relationalStore.ValuesBucket = {
      'transactionId': transaction.transactionId, 'ownerId': transaction.ownerId,
      'starAmount': transaction.starAmount, 'nanostarAmount': transaction.nanostarAmount,
      'isRefund': transaction.isRefund ? 1 : 0,
      'date': transaction.date, 'type': transaction.type, 'extraJson': transaction.extraJson
    };
    try {
      const rowId = await this.rdbStore.insert(this.TABLE_STAR_TRANSACTION, values);
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, String(err));
    }
  }

  async getStarTransactionsByOwner(ownerId: number, limit: number = 50): Promise<StarTransactionEntity[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(this.TABLE_STAR_TRANSACTION);
    predicates.equalTo('ownerId', ownerId).orderByDesc('date').limitAs(limit);
    const result = await this.rdbStore.query(predicates);
    const transactions: StarTransactionEntity[] = [];
    while (result.goToNextRow()) {
      const t = new StarTransactionEntity();
      t.id = result.getLong(result.getColumnIndex('id'));
      t.transactionId = result.getString(result.getColumnIndex('transactionId'));
      t.ownerId = result.getLong(result.getColumnIndex('ownerId'));
      t.starAmount = result.getLong(result.getColumnIndex('starAmount'));
      t.nanostarAmount = result.getLong(result.getColumnIndex('nanostarAmount'));
      t.isRefund = result.getLong(result.getColumnIndex('isRefund')) === 1;
      t.date = result.getLong(result.getColumnIndex('date'));
      t.type = result.getString(result.getColumnIndex('type'));
      t.extraJson = result.getString(result.getColumnIndex('extraJson'));
      transactions.push(t);
    }
    result.close();
    return transactions;
  }

  // ========== Background CRUD ==========
  async insertBackground(background: BackgroundEntity): Promise<CacheResult<number>> {
    if (!this.rdbStore) return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, 'DB not init');
    const values: relationalStore.ValuesBucket = {
      'backgroundId': background.backgroundId, 'name': background.name,
      'isDefault': background.isDefault ? 1 : 0, 'isDark': background.isDark ? 1 : 0,
      'type': background.type, 'fillJson': background.fillJson ?? '',
      'documentFileId': background.documentFileId ?? '', 'extraJson': background.extraJson
    };
    try {
      const rowId = await this.rdbStore.insert(this.TABLE_BACKGROUND, values);
      return CacheResult.ok(rowId);
    } catch (err) {
      return CacheResult.fail(ErrorCodes.DB_INSERT_FAILED, String(err));
    }
  }

  async getBackground(backgroundId: string): Promise<BackgroundEntity | undefined> {
    if (!this.rdbStore) return undefined;
    const predicates = new relationalStore.RdbPredicates(this.TABLE_BACKGROUND);
    predicates.equalTo('backgroundId', backgroundId);
    const result = await this.rdbStore.query(predicates);
    if (result.goToFirstRow()) {
      const bg = new BackgroundEntity();
      bg.id = result.getLong(result.getColumnIndex('id'));
      bg.backgroundId = result.getString(result.getColumnIndex('backgroundId'));
      bg.name = result.getString(result.getColumnIndex('name'));
      bg.isDefault = result.getLong(result.getColumnIndex('isDefault')) === 1;
      bg.isDark = result.getLong(result.getColumnIndex('isDark')) === 1;
      bg.type = result.getString(result.getColumnIndex('type'));
      bg.fillJson = result.getString(result.getColumnIndex('fillJson'));
      bg.documentFileId = result.getString(result.getColumnIndex('documentFileId'));
      bg.extraJson = result.getString(result.getColumnIndex('extraJson'));
      result.close();
      return bg;
    }
    result.close();
    return undefined;
  }

  async getAllBackgrounds(): Promise<BackgroundEntity[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(this.TABLE_BACKGROUND);
    const result = await this.rdbStore.query(predicates);
    const backgrounds: BackgroundEntity[] = [];
    while (result.goToNextRow()) {
      const bg = new BackgroundEntity();
      bg.id = result.getLong(result.getColumnIndex('id'));
      bg.backgroundId = result.getString(result.getColumnIndex('backgroundId'));
      bg.name = result.getString(result.getColumnIndex('name'));
      bg.isDefault = result.getLong(result.getColumnIndex('isDefault')) === 1;
      bg.isDark = result.getLong(result.getColumnIndex('isDark')) === 1;
      bg.type = result.getString(result.getColumnIndex('type'));
      bg.fillJson = result.getString(result.getColumnIndex('fillJson'));
      bg.documentFileId = result.getString(result.getColumnIndex('documentFileId'));
      bg.extraJson = result.getString(result.getColumnIndex('extraJson'));
      backgrounds.push(bg);
    }
    result.close();
    return backgrounds;
  }

  async close(): Promise<void> {
    if (this.rdbStore) {
      await this.rdbStore.close();
      this.rdbStore = null;
    }
  }
}
