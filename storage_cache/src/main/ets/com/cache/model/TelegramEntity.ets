// storage_cache/src/main/ets/com/cache/model/TelegramEntity.ets

// ==================== 消息实体 ====================
export class MessageEntity {
  id: number = 0;
  messageId: number = 0;
  chatId: number = 0;
  senderId: number = 0;
  date: number = 0;
  editDate: number = 0;
  contentType: string = '';
  contentJson: string = '';
  caption: string = '';
  entitiesJson: string = '';
  replyToMsgId: number = 0;
  mediaGroupId: string = '';
  forwardInfoJson: string = '';
  replyMarkupJson: string = '';
  inlineKeyboardJson: string = '';
  flags: number = 0;
  pollId?: string;
  gameId?: number;
  invoiceId?: string;
  callbackQueryData?: string;
  extraJson?: string;

  get isOutgoing(): boolean { return (this.flags & 1) !== 0; }
  set isOutgoing(value: boolean) { this.flags = value ? (this.flags | 1) : (this.flags & ~1); }
  get isRead(): boolean { return (this.flags & 2) !== 0; }
  set isRead(value: boolean) { this.flags = value ? (this.flags | 2) : (this.flags & ~2); }
  get isEdited(): boolean { return (this.flags & 4) !== 0; }
  set isEdited(value: boolean) { this.flags = value ? (this.flags | 4) : (this.flags & ~4); }
  get isPinned(): boolean { return (this.flags & 8) !== 0; }
  set isPinned(value: boolean) { this.flags = value ? (this.flags | 8) : (this.flags & ~8); }

  /**
   * 创建深拷贝
   */
  clone(): MessageEntity {
    const clone = new MessageEntity();
    clone.id = this.id;
    clone.messageId = this.messageId;
    clone.chatId = this.chatId;
    clone.senderId = this.senderId;
    clone.date = this.date;
    clone.editDate = this.editDate;
    clone.contentType = this.contentType;
    clone.contentJson = this.contentJson;
    clone.caption = this.caption;
    clone.entitiesJson = this.entitiesJson;
    clone.replyToMsgId = this.replyToMsgId;
    clone.mediaGroupId = this.mediaGroupId;
    clone.forwardInfoJson = this.forwardInfoJson;
    clone.replyMarkupJson = this.replyMarkupJson;
    clone.inlineKeyboardJson = this.inlineKeyboardJson;
    clone.flags = this.flags;
    clone.pollId = this.pollId;
    clone.gameId = this.gameId;
    clone.invoiceId = this.invoiceId;
    clone.callbackQueryData = this.callbackQueryData;
    clone.extraJson = this.extraJson;
    return clone;
  }

  /**
   * 比较两个消息是否相等（基于关键字段）
   */
  equals(other: MessageEntity): boolean {
    return this.messageId === other.messageId &&
           this.chatId === other.chatId &&
           this.date === other.date &&
           this.contentJson === other.contentJson &&
           this.flags === other.flags;
  }

  /**
   * 获取内容对象（自动解析 JSON）
   */
  getContent<T = object>(): T | null {
    try {
      return this.contentJson ? JSON.parse(this.contentJson) as T : null;
    } catch {
      return null;
    }
  }

  /**
   * 设置内容对象（自动序列化为 JSON）
   */
  setContent(content: object): void {
    this.contentJson = JSON.stringify(content);
    this.contentType = (content as Record<string, string>)['_constructor'] || '';
  }

  /**
   * 获取转发信息对象
   */
  getForwardInfo(): object | null {
    try {
      return this.forwardInfoJson ? JSON.parse(this.forwardInfoJson) : null;
    } catch {
      return null;
    }
  }

  /**
   * 获取回复标记对象
   */
  getReplyMarkup(): object | null {
    try {
      return this.replyMarkupJson ? JSON.parse(this.replyMarkupJson) : null;
    } catch {
      return null;
    }
  }

  /**
   * 获取实体数组
   */
  getEntities(): object[] | null {
    try {
      return this.entitiesJson ? JSON.parse(this.entitiesJson) as object[] : null;
    } catch {
      return null;
    }
  }

  /**
   * 是否包含媒体
   */
  hasMedia(): boolean {
    return ['messagePhoto', 'messageVideo', 'messageAudio', 'messageDocument', 
            'messageVoiceNote', 'messageVideoNote', 'messageAnimation'].includes(this.contentType);
  }

  /**
   * 是否是文本消息
   */
  isText(): boolean {
    return this.contentType === 'messageText';
  }

  /**
   * 获取文本内容（如果是文本消息）
   */
  getText(): string {
    if (!this.isText()) return '';
    try {
      const content = this.getContent() as Record<string, object> | null;
      if (content === null) return '';
      const textObj = content['text'] as Record<string, string> | undefined;
      return textObj?.['text'] || '';
    } catch {
      return '';
    }
  }

  /**
   * 创建用于排序的复合键
   * 格式: "timestamp#messageId"
   */
  getSortKey(): string {
    const ts = this.date.toString().padStart(10, '0');
    const id = this.messageId.toString().padStart(10, '0');
    return `${ts}#${id}`;
  }

  /**
   * 快速创建 MessageEntity（工厂方法）
   */
  static create(messageId: number, chatId: number, senderId: number, date: number, contentType: string, content: object): MessageEntity {
    const entity = new MessageEntity();
    entity.messageId = messageId;
    entity.chatId = chatId;
    entity.senderId = senderId;
    entity.date = date;
    entity.setContent(content);
    return entity;
  }

  // ========== 运行时字段（不持久化）==========
  content?: Record<string, string>;        // 运行时内容对象
  entities?: Record<string, string>[];     // 运行时实体数组
  forwardInfo?: Record<string, string>;    // 运行时转发信息
  replyMarkup?: Record<string, string>;    // 运行时回复标记
  senderName?: string;                     // 运行时发送者名称
  senderAvatar?: string;                   // 运行时发送者头像
  
  // 文件下载相关运行时字段
  downloadProgress?: number;               // 下载进度 (0-100)
  isDownloading?: boolean;                 // 是否正在下载
  filePath?: string;                       // 本地文件路径

  /**
   * 反序列化所有 JSON 字段到运行时对象
   * 参考 Gramony-dev 的 deserializeFmtEntities 设计
   */
  deserialize(): void {
    if (this.contentJson && this.contentJson.length > 0) {
      try {
        this.content = JSON.parse(this.contentJson) as Record<string, string>;
      } catch (e) {
        this.content = undefined;
      }
    }
    if (this.entitiesJson && this.entitiesJson.length > 0) {
      try {
        this.entities = JSON.parse(this.entitiesJson) as Record<string, string>[];
      } catch (e) {
        this.entities = undefined;
      }
    }
    if (this.forwardInfoJson && this.forwardInfoJson.length > 0) {
      try {
        this.forwardInfo = JSON.parse(this.forwardInfoJson) as Record<string, string>;
      } catch (e) {
        this.forwardInfo = undefined;
      }
    }
    if (this.replyMarkupJson && this.replyMarkupJson.length > 0) {
      try {
        this.replyMarkup = JSON.parse(this.replyMarkupJson) as Record<string, string>;
      } catch (e) {
        this.replyMarkup = undefined;
      }
    }
  }

  /**
   * 序列化运行时对象到 JSON 字段
   */
  serialize(): void {
    if (this.content !== undefined) {
      this.contentJson = JSON.stringify(this.content);
    }
    if (this.entities !== undefined) {
      this.entitiesJson = JSON.stringify(this.entities);
    }
    if (this.forwardInfo !== undefined) {
      this.forwardInfoJson = JSON.stringify(this.forwardInfo);
    }
    if (this.replyMarkup !== undefined) {
      this.replyMarkupJson = JSON.stringify(this.replyMarkup);
    }
  }
}

// ==================== 会话实体 ====================
export class ChatEntity {
  id: number = 0;
  chatId: number = 0;
  title: string = '';
  type: string = '';
  photoJson: string = '';
  lastMessageId: number = 0;
  lastMessageDate: number = 0;
  unreadCount: number = 0;
  draftMessage: string = '';
  draftMessageDate: number = 0;
  lastReadMsgId: number = 0;
  isMuted: boolean = false;
  isPinned: boolean = false;
  syncCursor: number = 0;
  extraJson: string = '';
  canSendMessages: boolean = true;
  canSendMedia: boolean = true;
  canSendPolls: boolean = true;
  canAddWebPagePreviews: boolean = true;
  muteUntil: number = 0;
  showPreview: boolean = true;
  memberStatusJson: string = ''; // ⭐ 成员状态 JSON，用于过滤非成员聊天

  /**
   * 创建深拷贝
   */
  clone(): ChatEntity {
    const clone = new ChatEntity();
    clone.id = this.id;
    clone.chatId = this.chatId;
    clone.title = this.title;
    clone.type = this.type;
    clone.photoJson = this.photoJson;
    clone.lastMessageId = this.lastMessageId;
    clone.lastMessageDate = this.lastMessageDate;
    clone.unreadCount = this.unreadCount;
    clone.draftMessage = this.draftMessage;
    clone.draftMessageDate = this.draftMessageDate;
    clone.lastReadMsgId = this.lastReadMsgId;
    clone.isMuted = this.isMuted;
    clone.isPinned = this.isPinned;
    clone.syncCursor = this.syncCursor;
    clone.extraJson = this.extraJson;
    clone.canSendMessages = this.canSendMessages;
    clone.canSendMedia = this.canSendMedia;
    clone.canSendPolls = this.canSendPolls;
    clone.canAddWebPagePreviews = this.canAddWebPagePreviews;
    clone.muteUntil = this.muteUntil;
    clone.showPreview = this.showPreview;
    clone.memberStatusJson = this.memberStatusJson;
    return clone;
  }

  /**
   * 比较两个会话是否相等（基于关键字段）
   */
  equals(other: ChatEntity): boolean {
    return this.chatId === other.chatId &&
           this.lastMessageId === other.lastMessageId &&
           this.lastMessageDate === other.lastMessageDate &&
           this.unreadCount === other.unreadCount &&
           this.isPinned === other.isPinned;
  }

  /**
   * 获取显示名称（如果有标题则返回标题，否则返回默认值）
   */
  getDisplayName(): string {
    return this.title || 'Unknown Chat';
  }

  /**
   * 获取头像信息对象
   */
  getPhoto(): object | null {
    try {
      return this.photoJson ? JSON.parse(this.photoJson) : null;
    } catch {
      return null;
    }
  }

  /**
   * 获取草稿消息对象
   */
  getDraftMessage(): object | null {
    try {
      return this.draftMessage ? JSON.parse(this.draftMessage) : null;
    } catch {
      return null;
    }
  }

  /**
   * 获取扩展信息对象
   */
  getExtra(): object | null {
    try {
      return this.extraJson ? JSON.parse(this.extraJson) : null;
    } catch {
      return null;
    }
  }

  /**
   * ⭐ 获取成员状态对象
   */
  getMemberStatus(): Record<string, string> | null {
    try {
      return this.memberStatusJson ? JSON.parse(this.memberStatusJson) as Record<string, string> : null;
    } catch {
      return null;
    }
  }

  /**
   * ⭐ 检查用户是否是该聊天的成员
   */
  isMember(): boolean {
    const status = this.getMemberStatus();
    if (!status) return false;
    const validStatuses = ['creator', 'administrator', 'member', 'restricted'];
    return validStatuses.includes(status.type);
  }

  /**
   * 是否是私聊
   */
  isPrivate(): boolean {
    return this.type === 'chatTypePrivate';
  }

  /**
   * 是否是群组
   */
  isGroup(): boolean {
    return this.type === 'chatTypeBasicGroup' || this.type === 'chatTypeSupergroup';
  }

  /**
   * 是否是频道
   */
  isChannel(): boolean {
    return this.type === 'chatTypeSupergroup' || this.type === 'chatTypeChannel';
  }

  /**
   * 是否有未读消息
   */
  hasUnread(): boolean {
    return this.unreadCount > 0;
  }

  /**
   * 是否被静音
   */
  isMutedUntil(date: number = Date.now() / 1000): boolean {
    return this.muteUntil > date;
  }

  /**
   * 创建用于排序的复合键
   * 格式: "lastMessageDate#chatId"
   */
  getSortKey(): string {
    const ts = this.lastMessageDate.toString().padStart(10, '0');
    const id = this.chatId.toString().padStart(10, '0');
    return `${ts}#${id}`;
  }

  /**
   * 快速创建 ChatEntity（工厂方法）
   */
  static create(chatId: number, title: string, type: string): ChatEntity {
    const entity = new ChatEntity();
    entity.chatId = chatId;
    entity.title = title;
    entity.type = type;
    return entity;
  }

  // ========== 运行时字段（不持久化）==========
  photo?: Record<string, string>;          // 运行时头像信息
  draft?: Record<string, string>;          // 运行时草稿消息
  extra?: Record<string, string>;          // 运行时扩展信息

  /**
   * 反序列化所有 JSON 字段到运行时对象
   */
  deserialize(): void {
    if (this.photoJson && this.photoJson.length > 0) {
      try {
        this.photo = JSON.parse(this.photoJson) as Record<string, string>;
      } catch (e) {
        this.photo = undefined;
      }
    }
    if (this.draftMessage && this.draftMessage.length > 0) {
      try {
        this.draft = JSON.parse(this.draftMessage) as Record<string, string>;
      } catch (e) {
        this.draft = undefined;
      }
    }
    if (this.extraJson && this.extraJson.length > 0) {
      try {
        this.extra = JSON.parse(this.extraJson) as Record<string, string>;
      } catch (e) {
        this.extra = undefined;
      }
    }
  }

  /**
   * 序列化运行时对象到 JSON 字段
   */
  serialize(): void {
    if (this.photo !== undefined) {
      this.photoJson = JSON.stringify(this.photo);
    }
    if (this.draft !== undefined) {
      this.draftMessage = JSON.stringify(this.draft);
    }
    if (this.extra !== undefined) {
      this.extraJson = JSON.stringify(this.extra);
    }
  }
}

// ==================== 媒体文件实体 ====================
export class MediaEntity {
  id: number = 0;
  fileId: string = '';
  messageId: number = 0;
  chatId: number = 0;
  fileType: string = '';
  localPath: string = '';
  remoteUrl: string = '';
  size: number = 0;
  width: number = 0;
  height: number = 0;
  duration: number = 0;
  mimeType: string = '';
  thumbnailPath: string = '';
  extraJson: string = '';
  isDownloaded: boolean = false;
  isDownloading: boolean = false;
  downloadProgress: number = 0;

  /**
   * 创建深拷贝
   */
  clone(): MediaEntity {
    const clone = new MediaEntity();
    clone.id = this.id;
    clone.fileId = this.fileId;
    clone.messageId = this.messageId;
    clone.chatId = this.chatId;
    clone.fileType = this.fileType;
    clone.localPath = this.localPath;
    clone.remoteUrl = this.remoteUrl;
    clone.size = this.size;
    clone.width = this.width;
    clone.height = this.height;
    clone.duration = this.duration;
    clone.mimeType = this.mimeType;
    clone.thumbnailPath = this.thumbnailPath;
    clone.extraJson = this.extraJson;
    clone.isDownloaded = this.isDownloaded;
    clone.isDownloading = this.isDownloading;
    clone.downloadProgress = this.downloadProgress;
    return clone;
  }

  /**
   * 获取扩展信息对象
   */
  getExtra(): object | null {
    try {
      return this.extraJson ? JSON.parse(this.extraJson) : null;
    } catch {
      return null;
    }
  }

  /**
   * 是否是图片
   */
  isImage(): boolean {
    return this.fileType === 'photo' || this.mimeType.startsWith('image/');
  }

  /**
   * 是否是视频
   */
  isVideo(): boolean {
    return this.fileType === 'video' || this.mimeType.startsWith('video/');
  }

  /**
   * 是否是音频
   */
  isAudio(): boolean {
    return this.fileType === 'audio' || this.fileType === 'voice' || this.mimeType.startsWith('audio/');
  }

  /**
   * 获取文件大小（格式化）
   */
  getFormattedSize(): string {
    if (this.size < 1024) return `${this.size} B`;
    if (this.size < 1024 * 1024) return `${(this.size / 1024).toFixed(1)} KB`;
    if (this.size < 1024 * 1024 * 1024) return `${(this.size / (1024 * 1024)).toFixed(1)} MB`;
    return `${(this.size / (1024 * 1024 * 1024)).toFixed(1)} GB`;
  }

  /**
   * 获取宽高比
   */
  getAspectRatio(): number {
    if (this.width === 0 || this.height === 0) return 1;
    return this.width / this.height;
  }

  /**
   * 快速创建 MediaEntity（工厂方法）
   */
  static create(fileId: string, fileType: string, size: number): MediaEntity {
    const entity = new MediaEntity();
    entity.fileId = fileId;
    entity.fileType = fileType;
    entity.size = size;
    return entity;
  }
}

// ==================== 故事实体 ====================
export class StoryEntity {
  id: number = 0;
  storyId: number = 0;
  senderId: number = 0;
  chatId: number = 0;
  date: number = 0;
  isEdited: boolean = false;
  isPinned: boolean = false;
  contentJson: string = '';
  interactionInfoJson: string = '';
  fileId?: string;
  isViewed: boolean = false;
  expireDate: number = 0;
}

// ==================== 联系人实体 ====================
export class ContactEntity {
  id: number = 0;
  userId: number = 0;
  phoneNumber: string = '';
  firstName: string = '';
  lastName: string = '';
  fullName: string = '';
  username: string = '';
  avatarFileId?: string;
  isVerified: boolean = false;
  isPremium: boolean = false;
  isBot: boolean = false;
  isFavorite: boolean = false;
  syncStatus: string = 'synced';
  lastUpdated: number = 0;
  extraJson: string = '';

  /**
   * 创建深拷贝
   */
  clone(): ContactEntity {
    const clone = new ContactEntity();
    clone.id = this.id;
    clone.userId = this.userId;
    clone.phoneNumber = this.phoneNumber;
    clone.firstName = this.firstName;
    clone.lastName = this.lastName;
    clone.fullName = this.fullName;
    clone.username = this.username;
    clone.avatarFileId = this.avatarFileId;
    clone.isVerified = this.isVerified;
    clone.isPremium = this.isPremium;
    clone.isBot = this.isBot;
    clone.isFavorite = this.isFavorite;
    clone.syncStatus = this.syncStatus;
    clone.lastUpdated = this.lastUpdated;
    clone.extraJson = this.extraJson;
    return clone;
  }

  /**
   * 获取完整姓名（动态计算）
   */
  getFullName(): string {
    if (this.fullName) return this.fullName;
    const parts: string[] = [];
    if (this.firstName) parts.push(this.firstName);
    if (this.lastName) parts.push(this.lastName);
    return parts.join(' ').trim() || this.username || `User ${this.userId}`;
  }

  /**
   * 获取显示名称
   */
  getDisplayName(): string {
    if (this.username) return `@${this.username}`;
    return this.getFullName();
  }

  /**
   * 获取扩展信息对象
   */
  getExtra(): object | null {
    try {
      return this.extraJson ? JSON.parse(this.extraJson) : null;
    } catch {
      return null;
    }
  }

  /**
   * 快速创建 ContactEntity（工厂方法）
   */
  static create(userId: number, firstName: string, lastName: string): ContactEntity {
    const entity = new ContactEntity();
    entity.userId = userId;
    entity.firstName = firstName;
    entity.lastName = lastName;
    entity.lastUpdated = Date.now();
    return entity;
  }
}

// ==================== 用户实体 ====================
export class UserEntity {
  id: number = 0;
  userId: number = 0;
  firstName: string = '';
  lastName: string = '';
  username: string = '';
  phoneNumber: string = '';
  isVerified: boolean = false;
  isPremium: boolean = false;
  isBot: boolean = false;
  statusJson: string = '';
  profilePhotoFileId?: string;
  emojiStatus?: string;
  bio: string = '';
  extraJson: string = '';
  lastUpdated: number = 0;
  onlineStatus: string = '';
  lastSeen: number = 0;

  /**
   * 创建深拷贝
   */
  clone(): UserEntity {
    const clone = new UserEntity();
    clone.id = this.id;
    clone.userId = this.userId;
    clone.firstName = this.firstName;
    clone.lastName = this.lastName;
    clone.username = this.username;
    clone.phoneNumber = this.phoneNumber;
    clone.isVerified = this.isVerified;
    clone.isPremium = this.isPremium;
    clone.isBot = this.isBot;
    clone.statusJson = this.statusJson;
    clone.profilePhotoFileId = this.profilePhotoFileId;
    clone.emojiStatus = this.emojiStatus;
    clone.bio = this.bio;
    clone.extraJson = this.extraJson;
    clone.lastUpdated = this.lastUpdated;
    clone.onlineStatus = this.onlineStatus;
    clone.lastSeen = this.lastSeen;
    return clone;
  }

  /**
   * 获取完整姓名
   */
  getFullName(): string {
    const name = `${this.firstName} ${this.lastName}`.trim();
    return name || this.username || `User ${this.userId}`;
  }

  /**
   * 获取显示名称（优先使用用户名）
   */
  getDisplayName(): string {
    if (this.username) return `@${this.username}`;
    return this.getFullName();
  }

  /**
   * 获取在线状态对象
   */
  getStatus(): object | null {
    try {
      return this.statusJson ? JSON.parse(this.statusJson) : null;
    } catch {
      return null;
    }
  }
}

// ==================== 聊天文件夹实体 ====================
export class ChatFilterEntity {
  id: number = 0;
  filterId: number = 0;
  title: string = '';
  iconName: string = '';
  order: number = 0;
  pinnedChatIdsJson: string = '[]';
  includedChatIdsJson: string = '[]';
  excludedChatIdsJson: string = '[]';
  isPinned: boolean = false;
  hasMyInvites: boolean = false;
}

// ==================== 聊天提升实体 ====================
export class ChatBoostEntity {
  id: number = 0;
  boostId: number = 0;
  chatId: number = 0;
  userId: number = 0;
  date: number = 0;
  expires: number = 0;
  sourceType: string = '';
  sourceUserId?: number;
}

// ==================== 机器人命令实体 ====================
export class BotCommandEntity {
  id: number = 0;
  botUserId: number = 0;
  command: string = '';
  description: string = '';
}

// ==================== 表情反应实体 ====================
export class ReactionEntity {
  id: number = 0;
  messageId: number = 0;
  chatId: number = 0;
  emoji: string = '';
  userId: number = 0;
  date: number = 0;
  isSelected: boolean = true;
}

// ==================== 聊天位置实体 ====================
export class ChatPositionEntity {
  id: number = 0;
  chatId: number = 0;
  listType: string = 'main';
  filterId?: number;
  order: number = 0;
  isPinned: boolean = false;
  source?: string;
}

// ==================== 秘密聊天实体 ====================
export class SecretChatEntity {
  id: number = 0;
  secretChatId: number = 0;
  userId: number = 0;
  state: string = 'pending';
  ttl: number = 0;
  keyHash: string = '';
  layer: number = 0;
  isOutgoing: boolean = false;
}

// ==================== 投票选项实体 ====================
export class PollOptionEntity {
  id: number = 0;
  pollId: string = '';
  optionIndex: number = 0;
  text: string = '';
  voterCount: number = 0;
  isSelected: boolean = false;
  isChosen: boolean = false;
}

// ==================== 话题（Forum Topic）实体 ====================
export class TopicEntity {
  id: number = 0;
  topicId: number = 0;
  chatId: number = 0;
  name: string = '';
  iconColor: number = 0;
  iconEmoji?: string;
  unreadCount: number = 0;
  lastMessageId: number = 0;
  lastMessageDate: number = 0;
  draftMessage: string = '';
  isClosed: boolean = false;
  isHidden: boolean = false;
}

// ==================== 投票用户选择记录 ====================
export class PollVoteEntity {
  id: number = 0;
  pollId: string = '';
  optionIndex: number = 0;
  userId: number = 0;
  date: number = 0;
}

// ==================== 消息发送失败详情 ====================
export class MessageSendingStateEntity {
  messageId: number = 0;
  errorCode: number = 0;
  errorMessage: string = '';
  retryCount: number = 0;
  canRetry: boolean = true;
}

// ==================== 已读回执/消息互动记录 ====================
export class MessageReadReceiptEntity {
  messageId: number = 0;
  userId: number = 0;
  readDate: number = 0;
}

// ==================== 聊天事件（群组操作历史） ====================
export class ChatEventEntity {
  id: number = 0;
  chatId: number = 0;
  eventType: string = '';
  initiatorUserId: number = 0;
  targetUserId?: number;
  date: number = 0;
  extraJson: string = '';
}

// ==================== 用户头像多种尺寸 ====================
export class UserPhotoEntity {
  id: number = 0;
  userId: number = 0;
  fileId: string = '';
  width: number = 0;
  height: number = 0;
  isAnimated: boolean = false;
  isMain: boolean = false;
}

// ==================== 扩展实体（新增） ====================

// ---------- 贴纸集 ----------
export class StickerSetEntity {
  id: number = 0;
  setId: string = '';           // sticker set identifier
  title: string = '';
  name: string = '';
  stickerType: string = '';     // regular, mask, customEmoji
  thumbnailFileId?: string;
  isInstalled: boolean = false;
  isArchived: boolean = false;
  isOfficial: boolean = false;
  isViewed: boolean = false;
  size: number = 0;
  extraJson: string = '';       // covers, emojis, etc.
  lastUpdated: number = 0;
}

// ---------- 贴纸 ----------
export class StickerEntity {
  id: number = 0;
  stickerId: string = '';
  setId: string = '';
  format: string = '';          // webp, tgs, webm
  type: string = '';
  emoji: string = '';
  width: number = 0;
  height: number = 0;
  fileId: string = '';
  thumbnailFileId?: string;
  maskPositionJson?: string;    // for mask stickers
  isPremium: boolean = false;
  extraJson: string = '';
}

// ---------- 机器人详情 ----------
export class BotInfoEntity {
  id: number = 0;
  botUserId: number = 0;
  shortDescription: string = '';
  description: string = '';
  photoFileId?: string;
  animationFileId?: string;
  menuButtonJson?: string;
  commandsJson: string = '[]';
  privacyPolicyUrl: string = '';
  defaultGroupAdminRightsJson?: string;
  defaultChannelAdminRightsJson?: string;
  canGetRevenueStatistics: boolean = false;
  extraJson: string = '';
}

// ---------- 礼物（普通） ----------
export class GiftEntity {
  id: number = 0;
  giftId: string = '';
  stickerFileId: string = '';
  starCount: number = 0;
  upgradeStarCount: number = 0;
  backgroundJson: string = '';
  isPremium: boolean = false;
  isForBirthday: boolean = false;
  extraJson: string = '';
}

// ---------- 升级礼物 ----------
export class UpgradedGiftEntity {
  id: number = 0;
  upgradedGiftId: string = '';
  regularGiftId?: string;
  title: string = '';
  name: string = '';
  number: number = 0;
  totalUpgradedCount: number = 0;
  maxUpgradedCount: number = 0;
  isPremium: boolean = false;
  isBurned: boolean = false;
  modelCustomEmojiId?: string;
  symbolCustomEmojiId?: string;
  backdropColorsJson?: string;
  ownerId?: number;
  ownerName: string = '';
  resaleStarCount?: number;
  craftProbabilityPerMille: number = 0;
  extraJson: string = '';
}

// ---------- 已接收礼物 ----------
export class ReceivedGiftEntity {
  id: number = 0;
  receivedGiftId: string = '';
  senderId?: number;
  text: string = '';
  isPrivate: boolean = false;
  isSaved: boolean = false;
  isPinned: boolean = false;
  canBeUpgraded: boolean = false;
  canBeTransferred: boolean = false;
  date: number = 0;
  giftJson: string = '';        // serialized GiftEntity or UpgradedGiftEntity
  collectionIdsJson: string = '[]';
  sellStarCount: number = 0;
  transferStarCount: number = 0;
  nextTransferDate: number = 0;
  nextResaleDate: number = 0;
  exportDate: number = 0;
  craftDate: number = 0;
  extraJson: string = '';
}

// ---------- 商业账户信息 ----------
export class BusinessInfoEntity {
  id: number = 0;
  userId: number = 0;
  locationJson?: string;
  openingHoursJson?: string;
  greetingMessageSettingsJson?: string;
  awayMessageSettingsJson?: string;
  startPageJson?: string;
  extraJson: string = '';
}

// ---------- 商业聊天链接 ----------
export class BusinessChatLinkEntity {
  id: number = 0;
  link: string = '';
  text: string = '';
  title: string = '';
  viewCount: number = 0;
}

// ---------- Telegram Stars 交易 ----------
export class StarTransactionEntity {
  id: number = 0;
  transactionId: string = '';
  ownerId: number = 0;           // user or chat id
  starAmount: number = 0;
  nanostarAmount: number = 0;
  isRefund: boolean = false;
  date: number = 0;
  type: string = '';
  extraJson: string = '';
}

// ---------- 发票/支付 ----------
export class InvoiceEntity {
  id: number = 0;
  invoiceId: string = '';
  chatId: number = 0;
  messageId: number = 0;
  title: string = '';
  description: string = '';
  currency: string = '';
  totalAmount: number = 0;
  isTest: boolean = false;
  needShippingAddress: boolean = false;
  receiptMessageId: number = 0;
  extraJson: string = '';
}

// ---------- 聊天统计（简略缓存） ----------
export class ChatStatisticsEntity {
  id: number = 0;
  chatId: number = 0;
  periodStart: number = 0;
  periodEnd: number = 0;
  memberCount: number = 0;
  messageCount: number = 0;
  viewerCount: number = 0;
  senderCount: number = 0;
  extraJson: string = '';
  cachedAt: number = 0;
}

// ---------- 通知声音 ----------
export class NotificationSoundEntity {
  id: number = 0;
  soundId: string = '';
  title: string = '';
  duration: number = 0;
  fileId: string = '';
  extraJson: string = '';
}

// ---------- 聊天背景 ----------
export class BackgroundEntity {
  id: number = 0;
  backgroundId: string = '';
  name: string = '';
  isDefault: boolean = false;
  isDark: boolean = false;
  type: string = '';
  fillJson?: string;
  documentFileId?: string;
  extraJson: string = '';
}

// ---------- 游戏高分 ----------
export class GameHighScoreEntity {
  id: number = 0;
  gameId: string = '';
  userId: number = 0;
  score: number = 0;
  position: number = 0;
  date: number = 0;
}

// ---------- WebApp 会话 ----------
export class WebAppSessionEntity {
  id: number = 0;
  botUserId: number = 0;
  launchId: string = '';
  url: string = '';
  mode: string = '';
  openedAt: number = 0;
  extraJson: string = '';
}

// ==================== 索引辅助（按需） ====================
// 可添加复合索引定义、外键约束等，具体取决于所使用的数据库实现。

// ==================== 类型守卫函数 ====================
// 注意：ArkTS 不支持 'in' 运算符和 'is' 类型守卫，使用 instanceof 替代

/**
 * 检查对象是否为 MessageEntity
 */
export function isMessageEntity(obj: object): boolean {
  return obj instanceof MessageEntity;
}

/**
 * 检查对象是否为 ChatEntity
 */
export function isChatEntity(obj: object): boolean {
  return obj instanceof ChatEntity;
}

/**
 * 检查对象是否为 UserEntity
 */
export function isUserEntity(obj: object): boolean {
  return obj instanceof UserEntity;
}

/**
 * 检查对象是否为 MediaEntity
 */
export function isMediaEntity(obj: object): boolean {
  return obj instanceof MediaEntity;
}

/**
 * 检查对象是否为 ContactEntity
 */
export function isContactEntity(obj: object): boolean {
  return obj instanceof ContactEntity;
}