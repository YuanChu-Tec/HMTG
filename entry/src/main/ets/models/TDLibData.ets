/**
 * TDLibData.ets
 * Telegram TDLib 完整类型定义（独立文件）
 * 符合 ArkTS 语法规范
 */


// ==================== 基础枚举 ====================

export enum ChatType {
  PRIVATE = 'private',
  SECRET = 'secret',
  GROUP = 'group',
  SUPERGROUP = 'supergroup',
  CHANNEL = 'channel',
  BOT = 'bot'
}

export enum MessageType {
  TEXT = 'text',
  PHOTO = 'photo',
  VIDEO = 'video',
  AUDIO = 'audio',
  VOICE_NOTE = 'voice_note',
  DOCUMENT = 'document',
  LOCATION = 'location',
  CONTACT = 'contact',
  STICKER = 'sticker',
  ANIMATION = 'animation',
  VIDEO_NOTE = 'video_note',
  POLL = 'poll',
  GAME = 'game',
  CALL = 'call',
  INVOICE = 'invoice',
  PAYMENT_SUCCESSFUL = 'payment_successful',
  LIVE_LOCATION = 'live_location',
  EXPIRED_PHOTO = 'expired_photo',
  EXPIRED_VIDEO = 'expired_video',
  EXPIRED_VOICE_NOTE = 'expired_voice_note',
  EXPIRED_VIDEO_NOTE = 'expired_video_note',
  DICE = 'dice',
  PAID_MEDIA = 'paid_media',
  GIFT_PREMIUM = 'gift_premium',
  GIFT_CODE = 'gift_code',
  GIVEAWAY = 'giveaway',
  GIVEAWAY_WINNERS = 'giveaway_winners',
  SYSTEM = 'system',
  GROUP_EVENT = 'group_event',
  UNSUPPORTED = 'unsupported'
}

export enum MessageStatus {
  SENDING = 'sending',
  PENDING = 'pending',
  SENT = 'sent',
  DELIVERED = 'delivered',
  READ = 'read',
  FAILED = 'failed'
}

export enum GroupEventType {
  MEMBER_JOINED = 'member_joined',
  MEMBER_LEFT = 'member_left',
  MEMBER_REMOVED = 'member_removed',
  ADMIN_PROMOTED = 'admin_promoted',
  GROUP_CREATED = 'group_created',
  GROUP_UPGRADED = 'group_upgraded',
  GROUP_RENAMED = 'group_renamed',
  GROUP_PHOTO_CHANGED = 'group_photo_changed',
  MESSAGE_PINNED = 'message_pinned',
  SLOW_MODE_ENABLED = 'slow_mode_enabled',
  RESTRICTED_MODE_ENABLED = 'restricted_mode_enabled',
  MEMBER_RESTRICTED = 'member_restricted'
}

/**
 * 系统消息类型枚举
 * 基于 TDlib 的 ChatEvent 和 MessageContent 服务消息类型
 */
export enum SystemMessageType {
  // 成员相关
  MEMBER_JOINED = 'member_joined',
  MEMBER_JOINED_BY_LINK = 'member_joined_by_link',
  MEMBER_INVITED = 'member_invited',
  MEMBER_LEFT = 'member_left',
  MEMBER_REMOVED = 'member_removed',
  MEMBER_PROMOTED = 'member_promoted',
  MEMBER_DEMOTED = 'member_demoted',
  MEMBER_RESTRICTED = 'member_restricted',
  MEMBER_UNRESTRICTED = 'member_unrestricted',
  MEMBER_BANNED = 'member_banned',

  // 聊天设置
  CHAT_CREATED = 'chat_created',
  TITLE_CHANGED = 'title_changed',
  PHOTO_CHANGED = 'photo_changed',
  DESCRIPTION_CHANGED = 'description_changed',
  SLOW_MODE_CHANGED = 'slow_mode_changed',
  SIGN_MESSAGES_CHANGED = 'sign_messages_changed',
  LINKED_CHAT_CHANGED = 'linked_chat_changed',

  // 消息操作
  MESSAGE_EDITED = 'message_edited',
  MESSAGE_DELETED = 'message_deleted',
  MESSAGE_PINNED = 'message_pinned',
  MESSAGE_UNPINNED = 'message_unpinned',

  // 其他
  POLL_CREATED = 'poll_created',
  GAME_STARTED = 'game_started',
  INVOICE_SENT = 'invoice_sent',
  PAYMENT_SUCCESSFUL = 'payment_successful',

  // 通用
  UNKNOWN = 'unknown'
}

/**
 * 系统消息参数接口
 */
export interface SystemMessageParams {
  userName?: string;
  inviterName?: string;
  actionerName?: string;
  newTitle?: string;
  duration?: number;
  enabled?: boolean;
  question?: string;
  gameTitle?: string;
  title?: string;
  pinnedMessageId?: number;
  message?: string;
}

export enum DownloadPriority {
  LOW = 1,
  NORMAL = 16,
  HIGH = 32,
  URGENT = 64 // ⭐ 最高优先级，用于头像等需要立即显示的内容
}

export enum DownloadStatus {
  PENDING = 'pending',
  QUEUED = 'queued',
  DOWNLOADING = 'downloading',
  PAUSED = 'paused',
  COMPLETED = 'completed',
  FAILED = 'failed',
  CANCELLED = 'cancelled'
}

export enum NetworkPolicy {
  WIFI_ONLY = 'wifi_only',
  WIFI_OR_CELLULAR = 'wifi_or_cellular',
  CELLULAR_ONLY = 'cellular_only',
  NEVER = 'never'
}

export enum SyncStatus {
  SYNCED = 'synced',
  PENDING = 'pending',
  CONFLICT = 'conflict',
  DELETED = 'deleted'
}

export enum OnlineStatus {
  ONLINE = 'online',
  OFFLINE = 'offline',
  RECENTLY = 'recently',
  WEEK_AGO = 'week_ago',
  MONTH_AGO = 'month_ago',
  LONG_TIME_AGO = 'long_time_ago',
  EXACT_TIME = 'exact_time'
}

export enum FileType {
  IMAGE = 'image',
  VIDEO = 'video',
  AUDIO = 'audio',
  VOICE_NOTE = 'voice_note',
  DOCUMENT = 'document',
  STICKER = 'sticker',
  ANIMATION = 'animation',
  VIDEO_NOTE = 'video_note',
  PROFILE_PHOTO = 'profile_photo',
  WALLPAPER = 'wallpaper',
  THUMBNAIL = 'thumbnail',
  SECRET = 'secret',
  SECRET_THUMBNAIL = 'secret_thumbnail',
  SECURE = 'secure',
  UNKNOWN = 'unknown'
}

export enum DownloadEvent {
  PROGRESS = 'download:progress',
  COMPLETE = 'download:complete',
  FAILED = 'download:failed',
  PAUSED = 'download:paused',
  QUEUED = 'download:queued',
  START = 'download:start',
  CANCELLED = 'download:cancelled'
}

// ==================== 文件与资源 ====================

export interface LocalFile {
  path: string;
  isDownloadingActive: boolean;
  isDownloadingCompleted: boolean;
  downloadedSize: number;
  canBeDeleted: boolean;
  isDeleted: boolean;
}

export interface RemoteFile {
  id: string;
  uniqueId: string;
  isUploadingActive: boolean;
  isUploadingCompleted: boolean;
  uploadedSize: number;
}

export interface TdFile {
  id: number;
  size: number;
  expectedSize: number;
  local: LocalFile;
  remote: RemoteFile;
}

// ==================== 消息发送状态与自毁类型 ====================

export interface MessageSendingStatePending {
  type: 'pending';
  messageId: number;
}

export interface MessageSendingStateFailed {
  type: 'failed';
  errorCode: number;
  errorMessage: string;
  canRetry: boolean;
  retryAfter: number;
}

export type MessageSendingState = MessageSendingStatePending | MessageSendingStateFailed;

export interface MessageSelfDestructTypeImmediately {
  type: 'immediately';
}

export interface MessageSelfDestructTypeTimer {
  type: 'timer';
  ttl: number;
}

export type MessageSelfDestructType = MessageSelfDestructTypeImmediately | MessageSelfDestructTypeTimer;

// ==================== 核心实体 ====================

// ⭐ TDLib 用户状态类型定义（与 TDLib 实际返回结构一致）
export interface UserStatusEmpty {
  _: 'userStatusEmpty';
}

export interface UserStatusOnline {
  _: 'userStatusOnline';
  expires: number;
}

export interface UserStatusOffline {
  _: 'userStatusOffline';
  was_online: number;
}

export interface UserStatusRecently {
  _: 'userStatusRecently';
  by_my_privacy_settings: boolean;
}

export interface UserStatusLastWeek {
  _: 'userStatusLastWeek';
  by_my_privacy_settings: boolean;
}

export interface UserStatusLastMonth {
  _: 'userStatusLastMonth';
  by_my_privacy_settings: boolean;
}

export type UserStatus =
  | UserStatusEmpty
  | UserStatusOnline
  | UserStatusOffline
  | UserStatusRecently
  | UserStatusLastWeek
  | UserStatusLastMonth;

// ⭐ TDLib 用户头像类型定义（与 TDLib 实际返回结构一致）
export interface UserProfilePhoto {
  _: 'profilePhoto';
  id: string;
  small: TdFile;
  big: TdFile;
  localPath?: string;
}

export interface EmojiStatus {
  emoji: string;
  untilDate?: number;
}

// ⭐ TDLib usernames 类型定义（与 TDLib 实际返回结构一致）
export interface Usernames {
  _: 'usernames';
  active_usernames: string[];
  disabled_usernames: string[];
  editable_username: string;
  collectible_usernames: string[];
}

export interface User {
  id: number;
  firstName: string;
  lastName?: string;
  username?: string;
  phoneNumber?: string;
  isVerified: boolean;
  isPremium: boolean;
  isBot: boolean;
  status: UserStatus;
  profilePhoto?: UserProfilePhoto;
  emojiStatus?: EmojiStatus;
  usernames?: Usernames;
  botCommands?: BotCommand[];           // 机器人命令列表
}

export interface UserFullInfo {
  description: string;
  birthday?: number;
  personalPhoto?: UserProfilePhoto;
  personalChatId?: number;
  privacySettings: Record<string, object>;
  groupInCommonCount: number;
  isBlocked: boolean;
  canBeCalled: boolean;
  supportsVideoCalls: boolean;
  hasPrivateCalls: boolean;
  hasPrivateForwards: boolean;
  needPhoneNumberPrivacyException: boolean;
  bio?: string;
  shareText?: string;
}

// ArkTS 兼容：使用接口替代对象字面量类型
export interface ChatListMain {
  type: 'main';
}

export interface ChatListArchive {
  type: 'archive';
}

export interface ChatListFilter {
  type: 'filter';
  filterId: number;
}

export type ChatList = ChatListMain | ChatListArchive | ChatListFilter;

export interface ChatPosition {
  list: ChatList;
  order: number;
  isPinned: boolean;
  source?: string;
}

export interface ChatPermissions {
  canSendMessages: boolean;
  canSendMedia: boolean;
  canSendPolls: boolean;
  canSendOtherMessages: boolean;
  canAddWebPagePreviews: boolean;
  canChangeInfo: boolean;
  canInviteUsers: boolean;
  canPinMessages: boolean;
}

export interface ChatNotificationSettings {
  useDefaultMuteFor: boolean;
  muteFor: number;
  useDefaultSound: boolean;
  soundId?: number;
  useDefaultShowPreview: boolean;
  showPreview: boolean;
  useDefaultDisablePinnedMessageNotifications: boolean;
  disablePinnedMessageNotifications: boolean;
  useDefaultDisableMentionNotifications: boolean;
  disableMentionNotifications: boolean;
}

export interface DraftMessage {
  text: string;
  entities: TextEntity[];
  replyToMessageId?: number;
  date: number;
}

export interface AvailableReactions {
  type: 'all' | 'some';
  reactions?: string[];
}

export interface VideoChat {
  groupCallId: number;
  hasParticipants: boolean;
  defaultParticipantId?: number;
}

export interface ChatActionBarInviteLink {
  type: 'inviteLink';
  inviteLink: string;
  canReport: boolean;
}

export interface ChatActionBarReportSpam {
  type: 'reportSpam';
  canReport: boolean;
}

export interface ChatActionBarSharePhoneNumber {
  type: 'sharePhoneNumber';
}

export interface ChatActionBarAddContact {
  type: 'addContact';
}

export interface ChatActionBarJoinRequest {
  type: 'joinRequest';
  pendingCount: number;
}

export type ChatActionBar =
  | ChatActionBarInviteLink
    | ChatActionBarReportSpam
    | ChatActionBarSharePhoneNumber
    | ChatActionBarAddContact
    | ChatActionBarJoinRequest;

export interface ChatReplyMarkupForceReply {
  type: 'forceReply';
  isPersonal: boolean;
}

export interface ChatReplyMarkupReplyKeyboard {
  type: 'replyKeyboard';
  keyboard: ReplyKeyboardMarkup;
}

export interface ChatReplyMarkupInlineKeyboard {
  type: 'inlineKeyboard';
  keyboard: InlineKeyboardMarkup;
}

export type ChatReplyMarkup =
  | ChatReplyMarkupForceReply
    | ChatReplyMarkupReplyKeyboard
    | ChatReplyMarkupInlineKeyboard;

export interface Chat {
  id: number;
  type: ChatType;
  title: string;
  avatar?: string;
  avatarFileId?: number;
  lastMessage?: Message;
  unreadCount: number;
  unreadMentionCount: number;
  isPinned: boolean;
  isMuted: boolean;
  isArchived: boolean;
  isMarkedAsUnread: boolean;
  hasProtectedContent: boolean;
  hasScheduledMessages: boolean;
  order: number;
  positions: ChatPosition[];
  draftMessage?: DraftMessage;
  permissions?: ChatPermissions;
  notificationSettings?: ChatNotificationSettings;
  messageTtl?: number;
  messageTtlSetting?: number;
  userId?: number;
  basicGroupId?: number;
  supergroupId?: number;
  secretChatId?: number;
  isVerified: boolean;
  isScam: boolean;
  isFake: boolean;
  description?: string;
  membersCount?: number;
  onlineMemberCount?: number;
  timestamp: number;
  userStatus?: UserStatus;
  canBeDeletedOnlyForSelf: boolean;
  canBeDeletedForAllUsers: boolean;
  canBeReported: boolean;
  defaultDisableNotification: boolean;
  themeName?: string;
  availableReactions?: AvailableReactions;
  hasActiveStories: boolean;
  storyIds: number[];
  videoChat?: VideoChat;
  pendingJoinRequests?: number;
  actionBar?: ChatActionBar;
  replyMarkup?: ChatReplyMarkup;
  hasLinkedChat: boolean;               // 是否有关联聊天
  linkedChatId?: number;                // 关联的聊天 ID（如讨论群组）
  pinnedMessageId?: number;             // 置顶消息 ID
  chatBoostFeatures?: ChatBoostFeatures; // 提升功能
  lastReadMessageId?: number;            // 最后已读消息 ID
  // ⭐ 成员状态（用于区分"我的"和"其他人的"频道/群组）
  memberStatus?: ChatMemberStatus;       // 当前用户在该聊天中的成员状态
  isOwner?: boolean;                     // 是否为创建者/所有者
  isAdmin?: boolean;                     // 是否为管理员
}

// ==================== 消息相关 ====================

export interface TextEntity {
  offset: number;
  length: number;
  type: string;
  url?: string;
  userId?: number;
  language?: string;
  customEmojiId?: number;
}

export interface FormattedText {
  text: string;
  entities: TextEntity[];
}

export interface MessageReaction {
  emoji: string;
  count: number;
  isSelected: boolean;
}

export interface ForwardInfo {
  senderName: string;
  senderId: number;
  date: number;
  originalChatId?: number;
  originalMessageId?: number;
  // ⭐ 频道帖子转发专用字段
  isChannelPost?: boolean;      // 是否为频道帖子转发
  viewCount?: number;           // 浏览量
  replyCount?: number;          // 回复数（评论数）
}

export interface LocationInfo {
  latitude: number;
  longitude: number;
  address?: string;
  title?: string;
  venue?: VenueInfo;
}

export interface VenueInfo {
  title: string;
  address: string;
  latitude: number;
  longitude: number;
  provider?: string;
  venueId?: string;
}

export interface ContactInfo {
  phoneNumber: string;
  firstName: string;
  lastName?: string;
  vcard?: string;
  userId?: number;
}

export interface PollOption {
  text: string;
  voterCount: number;
  isSelected?: boolean;
  isChosen?: boolean;
}

export interface PollInfo {
  id: string;
  question: string;
  options: PollOption[];
  totalVoterCount: number;
  isClosed: boolean;
  isAnonymous: boolean;
  type: 'regular' | 'quiz';
  allowsMultipleAnswers: boolean;
  correctOptionId?: number;
  explanation?: string;
  explanationEntities?: TextEntity[];   // 解释的富文本实体
}

export interface MediaInfo {
  fileId: string;
  fileUniqueId: string;
  mimeType: string;
  width?: number;
  height?: number;
  size: number;
  thumbnail?: string;
  fileName?: string;
  duration?: number;
  localPath?: string;
  downloadProgress?: number;
  isDownloading?: boolean;
  tdlibFileId?: number;
  hasSpoiler: boolean;                  // 是否包含剧透
  blurhash?: string;                    // 模糊哈希值
}

export interface FileInfo {
  id: number;
  remoteId: string;
  size: number;
  path: string;
  mimeType?: string;
  fileName?: string;
}

export interface GroupEventData {
  userId?: number;
  userName?: string;
  adminId?: number;
  adminName?: string;
  oldTitle?: string;
  newTitle?: string;
  restrictedUntil?: number;
  isRestricted?: boolean;
}

export interface MessageContent {
  text?: string;
  caption?: string;
  entities?: TextEntity[];
  address?: string;
  latitude?: number;
  longitude?: number;
  livePeriod?: number;
  title?: string;
  phoneNumber?: string;
  firstName?: string;
  lastName?: string;
  userId?: number;
  question?: string;
  options?: PollOption[];
  totalVoterCount?: number;
  isAnonymous?: boolean;
  allowsMultipleAnswers?: boolean;
  closeDate?: number;
  description?: string;
  gameId?: number;
  shortName?: string;
  isVideo?: boolean;
  duration?: number;
  isOutgoing?: boolean;
  isMissed?: boolean;
  // ⭐ 支付相关字段
  currency?: string;
  totalAmount?: number;
  invoiceMessageId?: number;
}

export interface Message {
  id: number;
  chatId: number;
  senderId: number;
  senderName: string;
  senderAvatar?: string;
  type: MessageType;
  content: string | MessageContent;
  timestamp: number;
  status: MessageStatus;
  isOutgoing: boolean;
  isEdited?: boolean;
  editDate?: number;
  replyToMessageId?: number;
  replyToMessage?: Message;
  media?: MediaInfo;
  file?: FileInfo;
  duration?: number;
  isRead?: boolean;
  localPath?: string;
  downloadProgress?: number;
  isDownloading?: boolean;
  views?: number;
  forwards?: number;
  reactions: MessageReaction[];
  formattedText?: FormattedText;
  location?: LocationInfo;
  contact?: ContactInfo;
  poll?: PollInfo;
  forwardInfo?: ForwardInfo;
  inlineKeyboard?: InlineKeyboardMarkup;
  replyMarkup?: ReplyKeyboardMarkup;
  authorSignature?: string;
  isChannelPost?: boolean;
  groupEventType?: GroupEventType;
  groupEventData?: GroupEventData;
  sendingState?: MessageSendingState;
  selfDestructType?: MessageSelfDestructType;
  selfDestructTime?: number;
  isPinned: boolean;                    // 是否置顶
  canBeEdited: boolean;                 // 是否可编辑
  canBeDeleted: boolean;                // 是否可删除
  interactionInfo?: MessageInteractionInfo; // 互动信息
  linkPreview?: MessageLinkInfo;        // 链接预览
  hasProtectedContent: boolean;         // 是否禁止转发
  webApp?: WebAppInfo;                  // Web App 数据
  game?: GameInfo;                      // 游戏数据
  invoice?: InvoiceInfo;                // 发票数据
  call?: CallInfo;                      // 通话数据
  // ⭐ 系统消息专用字段
  systemType?: SystemMessageType;
  systemParams?: SystemMessageParams;

  // ⭐ 扩展消息类型专用字段
  dice?: DiceInfo;
  paidMedia?: PaidMediaInfo;
  gift?: GiftInfo;
  giveaway?: GiveawayInfo;
}

// ==================== 回调查询 ====================

export interface CallbackQueryPayload {
  type: 'data' | 'game' | 'invoice';
  data?: string;
  gameShortName?: string;
  invoice?: InvoiceInfo;
}

// ==================== 消息链接预览 ====================

export interface MessageLinkInfo {
  url: string;
  title?: string;
  description?: string;
  photo?: MediaInfo;
  isMedia: boolean;
  mediaTimestamp?: number;
}

// ==================== Web App ====================

export interface WebAppInfo {
  url: string;
  title: string;
  shortName: string;
  botUsername: string;
  photo?: MediaInfo;
  backgroundColor: string;
}

// ==================== 游戏 ====================

export interface GameInfo {
  id: number;
  title: string;
  shortName: string;
  description: string;
  photo: MediaInfo;
  animation?: MediaInfo;
  text?: FormattedText;
}

// ==================== 骰子消息 ====================

export interface DiceInfo {
  emoji: string;
  value: number;
}

// ==================== 付费媒体消息 ====================

export interface PaidMediaInfo {
  starCount: number;
  media: MediaInfo[];
  caption?: string;
}

// ==================== 礼物消息 ====================

export interface GiftInfo {
  type: 'premium' | 'code';
  months?: number;
  currency?: string;
  amount?: number;
  caption?: string;
}

// ==================== 赠品消息 ====================

export interface GiveawayInfo {
  type: 'giveaway' | 'winners';
  winnerCount: number;
  prizeDescription?: string;
  countries?: string[];
  untilDate?: number;
  onlyNewMembers?: boolean;
  winners?: number[];
}

// ==================== 发票 ====================

export interface InvoiceInfo {
  currency: string;
  totalAmount: number;
  needName: boolean;
  needPhoneNumber: boolean;
  needEmail: boolean;
  needShippingAddress: boolean;
  isTest: boolean;
  title: string;
  description: string;
  photo?: MediaInfo;
  startParameter: string;
}

// ==================== 通话 ====================

export interface CallInfo {
  isVideo: boolean;
  duration: number;
  isOutgoing: boolean;
  isMissed: boolean;
  canBeRejoined: boolean;
}

// ==================== 聊天统计 ====================

export interface ChatStatistics {
  period: number;
  memberCount: number;
  messageCount: number;
  viewerCount: number;
  senderCount: number;
}

// ==================== 加群请求 ====================

export interface ChatJoinRequest {
  userId: number;
  date: number;
  bio?: string;
}

// ==================== 用户隐私设置 ====================

export interface UserPrivacySetting {
  type: 'showStatus' | 'showPhoto' | 'showPhoneNumber' | 'allowCalls' | 'allowPeerToPeerCalls' | 'allowFindingByPhoneNumber';
  rules: UserPrivacySettingRule[];
}

export interface UserPrivacySettingRule {
  type: 'allowAll' | 'allowContacts' | 'allowUsers' | 'restrictAll' | 'restrictContacts' | 'restrictUsers';
  userIds?: number[];
}

// ==================== 机器人命令 ====================

export interface BotCommand {
  command: string;
  description: string;
}

// ==================== Passport 元素 ====================

export interface PassportElement {
  type: 'personalDetails' | 'passport' | 'driverLicense' | 'identityCard' | 'internalPassport' | 'address' | 'utilityBill' | 'bankStatement' | 'rentalAgreement' | 'passportRegistration' | 'temporaryRegistration' | 'phoneNumber' | 'emailAddress';
  data: string;
}

// ==================== 聊天提升（补充） ====================

export interface ChatBoostFeatures {
  canChangeInfo: boolean;
  canSetUsername: boolean;
  canPinMessages: boolean;
  canInviteUsers: boolean;
  canPostMessages: boolean;
  canEditMessages: boolean;
  canDeleteMessages: boolean;
  canRestrictMembers: boolean;
  canPromoteMembers: boolean;
  canManageVideoChats: boolean;
}

// ==================== 消息互动信息（补充） ====================

export interface MessageInteractionInfo {
  viewCount: number;
  forwardCount: number;
  replyCount: number;
  reactionCount: number;
  recentReactionUserIds: number[];
}

// ==================== 故事（补充） ====================

export interface StoryArea {
  type: 'location' | 'reaction' | 'link';
  x: number;
  y: number;
  width: number;
  height: number;
  location?: LocationInfo;
  reaction?: string;
  link?: string;
}

// ==================== 聊天背景 ====================

export interface ChatBackground {
  type: 'wallpaper' | 'pattern' | 'solid';
  wallpaper?: TdFile;
  pattern?: TdFile;
  color?: number;
  intensity?: number;
  isMoving: boolean;
}

// ==================== 键盘相关 ====================

export interface InlineKeyboardButton {
  text: string;
  callbackData?: string;
  url?: string;
  switchInlineQuery?: string;
  switchInlineQueryCurrentChat?: string;
}

export interface InlineKeyboardRow {
  buttons: InlineKeyboardButton[];
}

export interface InlineKeyboardMarkup {
  rows: InlineKeyboardRow[];
}

export interface KeyboardButton {
  text: string;
  requestContact?: boolean;
  requestLocation?: boolean;
}

export interface ReplyKeyboardMarkup {
  rows: KeyboardButton[][];
  resizeKeyboard?: boolean;
  oneTimeKeyboard?: boolean;
  selective?: boolean;
}

// ==================== 群组/超级群组 ====================

export interface ChatAdministratorRights {
  canBeEdited: boolean;
  canChangeInfo: boolean;
  canPostMessages: boolean;
  canEditMessages: boolean;
  canDeleteMessages: boolean;
  canInviteUsers: boolean;
  canRestrictMembers: boolean;
  canPinMessages: boolean;
  canPromoteMembers: boolean;
  canManageVideoChats: boolean;
}

export interface ChatMemberStatusCreator {
  type: 'creator';
  customTitle?: string;
}

export interface ChatMemberStatusAdministrator {
  type: 'administrator';
  rights: ChatAdministratorRights;
}

export interface ChatMemberStatusMember {
  type: 'member';
}

export interface ChatMemberStatusRestricted {
  type: 'restricted';
  rights: ChatPermissions;
  untilDate: number;
}

export interface ChatMemberStatusLeft {
  type: 'left';
}

export interface ChatMemberStatusBanned {
  type: 'banned';
  untilDate: number;
}

export type ChatMemberStatus =
  | ChatMemberStatusCreator
    | ChatMemberStatusAdministrator
    | ChatMemberStatusMember
    | ChatMemberStatusRestricted
    | ChatMemberStatusLeft
    | ChatMemberStatusBanned;

export interface BasicGroup {
  id: number;
  memberCount: number;
  status: ChatMemberStatus;
  isActive: boolean;
  upgradedToSupergroupId?: number;
}

export interface Supergroup {
  id: number;
  username?: string;
  date: number;
  status: ChatMemberStatus;
  memberCount: number;
  isChannel: boolean;
  isVerified: boolean;
  isSlowModeEnabled: boolean;
  slowModeDelay: number;
  restrictionReason?: string;
  isScam: boolean;
  isFake: boolean;
}

// ==================== 秘密聊天 ====================

export interface SecretChat {
  id: number;
  userId: number;
  state: 'pending' | 'ready' | 'closed';
  ttl: number;
  keyHash: string;
}

// ==================== 故事 ====================

export interface StoryInteractionInfo {
  viewCount: number;
  reactionCount: number;
  recentViewerIds: number[];
}

export interface StoryContent {
  type: 'photo' | 'video';
  photo?: MediaInfo;
  video?: MediaInfo;
  caption?: FormattedText;
}

export interface Story {
  id: number;
  senderId: number;
  date: number;
  isEdited: boolean;
  isPinned: boolean;
  content: StoryContent;
  interactionInfo?: StoryInteractionInfo;
}

// ==================== 聊天筛选器（文件夹） ====================

export interface ChatFilter {
  id: number;
  title: string;
  iconName: string;
  order: number;
  pinnedChatIds: number[];
  includedChatIds: number[];
  excludedChatIds: number[];
  isPinned: boolean;
  hasMyInvites: boolean;
}

// ==================== 事实核查 ====================

export interface FactCheck {
  text: string;
  hash: string;
}

// ==================== 聊天提升 ====================

export interface ChatBoostSourcePremium {
  type: 'premium';
}

export interface ChatBoostSourceGiftCode {
  type: 'giftCode';
  userId: number;
}

export interface ChatBoostSourceGiveaway {
  type: 'giveaway';
  userId: number;
}

export type ChatBoostSource =
  | ChatBoostSourcePremium
    | ChatBoostSourceGiftCode
    | ChatBoostSourceGiveaway;

export interface ChatBoost {
  id: number;
  userId: number;
  date: number;
  expires: number;
  source: ChatBoostSource;
}

// ==================== 联系人相关（独立定义） ====================

export interface PhoneNumber {
  number: string;
  label: string;
  normalizedNumber: string;
}

export interface EmailAddress {
  address: string;
  label: string;
}

export interface Contact {
  id: number;
  userId: number;
  usernames?: Usernames;
  isVerified: boolean;
  isPremium: boolean;
  isBot: boolean;
  status: UserStatus;
  firstName: string;
  lastName: string;
  fullName: string;
  avatarPath?: string;
  avatarFileId?: number;
  phones: PhoneNumber[];
  emails: EmailAddress[];
  phone: string;
  syncSource: 'tdlib' | 'system' | 'merged';
  lastUpdated: number;
  syncStatus: SyncStatus;
  isFavorite: boolean;
  displayOrder: number;
  sectionKey: string;
  mutualChats?: number;
}

export interface ContactGroup {
  id: number;
  name: string;
  contacts: Contact[];
  count: number;
}

export interface ContactListItemData {
  contact: Contact;
  sectionTitle?: string;
  isSectionHeader: boolean;
}

export interface ContactSearchResult {
  contacts: Contact[];
  globalContacts: Contact[];
  exactMatch?: Contact;
}

export interface ContactStats {
  totalContacts: number;
  onlineContacts: number;
  verifiedContacts: number;
  botContacts: number;
}

// ==================== 文件下载相关 ====================

export interface AutoDownloadConfig {
  images: NetworkPolicy;
  videos: NetworkPolicy;
  audios: NetworkPolicy;
  documents: NetworkPolicy;
  stickers: NetworkPolicy;
  animations: NetworkPolicy;
  voiceNotes: NetworkPolicy;
  videoNotes: NetworkPolicy;
  profilePhotos: NetworkPolicy;
  wallpapers: NetworkPolicy;
  thumbnails: NetworkPolicy;
  maxImageSize: number;
  maxVideoSize: number;
  maxAudioSize: number;
  maxDocumentSize: number;
  maxStickerSize: number;
  maxAnimationSize: number;
  maxVoiceNoteSize: number;
  maxVideoNoteSize: number;
  maxProfilePhotoSize: number;
  maxThumbnailSize: number;
  roamingAllowed: boolean;
}

export interface DownloadTask {
  id: string;
  fileId: number;
  type: FileType;
  priority: DownloadPriority;
  status: DownloadStatus;
  progress: number;
  downloadedBytes: number;
  totalBytes: number;
  localPath?: string;
  error?: string;
  createTime: number;
  startTime?: number;
  endTime?: number;
  messageId?: number;
  chatId?: number;
  fileName?: string;
  mimeType?: string;
  formattedSize?: string;
  formattedDownloaded?: string;
  formattedTotal?: string;
  formattedSpeed?: string;
  formattedTimeLeft?: string;
}

export interface DownloadProgressData {
  taskId: string;
  fileId: number;
  progress: number;
  downloadedBytes: number;
  totalBytes: number;
  formattedDownloaded: string;
  formattedTotal: string;
  speedBytesPerSec: number;
  formattedSpeed: string;
  estimatedTimeLeftMs: number;
  formattedTimeLeft: string;
}

export interface DownloadCompleteData {
  taskId: string;
  fileId: number;
  localPath: string;
  durationMs: number;
  formattedDuration: string;
}

export interface DownloadFailedData {
  taskId: string;
  fileId: number;
  error: string;
}

export interface DownloadPausedData {
  taskId: string;
  fileId: number;
  reason?: string;
}

export interface DownloadQueuedData {
  taskId: string;
  fileId: number;
}

export interface DownloadStartData {
  taskId: string;
  fileId: number;
}

export interface DownloadCancelledData {
  taskId: string;
  fileId: number;
}

export interface PersistedDownloadTask {
  id: string;
  fileId: number;
  type: FileType;
  priority: DownloadPriority;
  status: DownloadStatus;
  downloadedBytes: number;
  totalBytes: number;
  localPath?: string;
  createTime: number;
  messageId?: number;
  chatId?: number;
  fileName?: string;
  mimeType?: string;
}

// ==================== 通知相关 ====================

export interface NotificationSettings {
  useDefaultMuteFor: boolean;
  muteFor: number;
  useDefaultSound: boolean;
  soundId?: number;
  useDefaultShowPreview: boolean;
  showPreview: boolean;
  useDefaultDisablePinnedMessageNotifications: boolean;
  disablePinnedMessageNotifications: boolean;
  useDefaultDisableMentionNotifications: boolean;
  disableMentionNotifications: boolean;
}

export interface ScopeNotificationSettings {
  muteFor: number;
  soundId?: number;
  showPreview: boolean;
  disablePinnedMessageNotifications: boolean;
  disableMentionNotifications: boolean;
}

export interface AutosaveSettings {
  autosave: boolean;
  maxPhotoSize: number;
  maxVideoSize: number;
  maxDocumentSize: number;
  includeChatIds: number[];
  excludeChatIds: number[];
}

// ==================== 辅助类型 ====================

export interface ChatListItem {
  chat: Chat;
  displayTime: string;
  displayMessage: string;
  isOnline?: boolean;
}

export interface TypingStatus {
  chatId: number;
  userId: number;
  userName: string;
  timestamp: number;
}

export interface UserInfo {
  id: number;
  firstName: string;
  lastName?: string;
  username?: string;
  avatar?: string;
  isOnline?: boolean;
}

export interface MessageEntity {
  type: string;
  offset: number;
  length: number;
  url?: string;
  user?: UserInfo;
}

// ==================== 认证相关 ====================

/**
 * 认证状态枚举
 */
export enum AuthState {
  /** 初始状态 */
  INITIAL = 'INITIAL',
  /** 手机号输入状态 */
  PHONE_INPUT = 'PHONE_INPUT',
  /** 验证码验证状态 */
  CODE_VERIFICATION = 'CODE_VERIFICATION',
  /** 需要两步验证密码 */
  PASSWORD_REQUIRED = 'PASSWORD_REQUIRED',
  /** 需要新用户注册信息 */
  SIGNUP_REQUIRED = 'SIGNUP_REQUIRED',
  /** 认证完成 */
  COMPLETED = 'COMPLETED',
  /** 认证错误 */
  ERROR = 'ERROR',
  /** 等待验证码（兼容旧代码） */
  WAITING_CODE = 'WAITING_CODE',
  /** 等待密码（兼容旧代码） */
  WAITING_PASSWORD = 'WAITING_PASSWORD',
  /** 准备就绪（兼容旧代码） */
  READY = 'READY'
}

/**
 * 认证结果接口
 */
export interface AuthResult {
  /** 是否成功 */
  success: boolean;
  /** 错误信息 */
  errorMessage?: string;
  /** 错误代码 */
  errorCode?: number;
  /** 下一步骤 */
  nextStep?: AuthState;
}

/**
 * 设置手机号结果
 */
export interface SetPhoneNumberResult extends AuthResult {
  /** 需要的验证码类型 */
  codeType?: 'sms' | 'call' | 'flash_call' | 'missed_call';
}

/**
 * 验证码检查结果
 */
export interface CheckCodeResult extends AuthResult {
  /** 需要的2FA提示 */
  passwordHint?: string;
  /** 是否需要注册 */
  needSignUp?: boolean;
}

/**
 * 密码检查结果
 */
export interface CheckPasswordResult extends AuthResult {
  /** 用户信息 */
  userInfo?: UserInfo;
}

/**
 * 认证错误代码
 */
export enum AuthErrorCode {
  /** 手机号无效 */
  INVALID_PHONE = 400,
  /** 验证码错误 */
  INVALID_CODE = 401,
  /** 验证码已过期 */
  CODE_EXPIRED = 402,
  /** 密码错误 */
  INVALID_PASSWORD = 403,
  /** 手机号已注册 */
  PHONE_REGISTERED = 404,
  /** 网络错误 */
  NETWORK_ERROR = 500,
  /** 服务器错误 */
  SERVER_ERROR = 501,
  /** 权限被拒绝 */
  PERMISSION_DENIED = 403
}

// ==================== 通话相关 ====================

/**
 * 通话类型枚举
 */
export enum CallType {
  VOICE = 'voice',
  VIDEO = 'video',
  GROUP_VOICE = 'group_voice',
  GROUP_VIDEO = 'group_video'
}

/**
 * 通话状态枚举
 */
export enum CallState {
  IDLE = 'idle',
  RINGING = 'ringing',
  CONNECTING = 'connecting',
  CONNECTED = 'connected',
  ENDED = 'ended',
  FAILED = 'failed',
  REJECTED = 'rejected'
}

/**
 * 通话方向枚举
 */
export enum CallDirection {
  INCOMING = 'incoming',
  OUTGOING = 'outgoing'
}

/**
 * 通话会话信息接口（用于通话功能）
 * 注意：与 Message.call 中的 CallInfo 区分
 */
export interface CallSession {
  id: string;
  type: CallType;
  state: CallState;
  direction: CallDirection;
  peerId: number;
  peerName: string;
  peerAvatar?: string;
  startTime: number;
  endTime?: number;
  duration: number;
  isMuted: boolean;
  isVideoEnabled: boolean;
  isSpeakerEnabled: boolean;
}

/**
 * 群组通话信息接口
 */
export interface GroupCallInfo extends CallSession {
  type: CallType.GROUP_VOICE | CallType.GROUP_VIDEO;
  participantCount: number;
  participants: CallParticipant[];
}

/**
 * 群组通话信息构建参数接口
 */
export interface GroupCallInfoParams {
  id: string;
  type: CallType;
  state: CallState;
  direction: CallDirection;
  peerId: number;
  peerName: string;
  peerAvatar?: string;
  startTime: number;
  duration: number;
  isMuted: boolean;
  isVideoEnabled: boolean;
  isSpeakerEnabled: boolean;
  participantCount: number;
  participants: CallParticipant[];
}

/**
 * 群组通话信息实现类
 */
export class GroupCallInfoImpl implements GroupCallInfo {
  id: string;
  type: CallType.GROUP_VOICE | CallType.GROUP_VIDEO;
  state: CallState;
  direction: CallDirection;
  peerId: number;
  peerName: string;
  peerAvatar?: string;
  startTime: number;
  endTime?: number;
  duration: number;
  isMuted: boolean;
  isVideoEnabled: boolean;
  isSpeakerEnabled: boolean;
  participantCount: number;
  participants: CallParticipant[];

  constructor(params: GroupCallInfoParams) {
    this.id = params.id;
    this.type = params.type as CallType.GROUP_VOICE | CallType.GROUP_VIDEO;
    this.state = params.state;
    this.direction = params.direction;
    this.peerId = params.peerId;
    this.peerName = params.peerName;
    this.peerAvatar = params.peerAvatar;
    this.startTime = params.startTime;
    this.duration = params.duration;
    this.isMuted = params.isMuted;
    this.isVideoEnabled = params.isVideoEnabled;
    this.isSpeakerEnabled = params.isSpeakerEnabled;
    this.participantCount = params.participantCount;
    this.participants = params.participants;
  }
}

/**
 * 通话参与者接口
 */
export interface CallParticipant {
  userId: number;
  userName: string;
  userAvatar?: string;
  isSpeaking: boolean;
  isMuted: boolean;
  isVideoEnabled: boolean;
  isHandRaised: boolean;
  audioLevel: number;
}

/**
 * 通话设置接口
 */
export interface CallSettings {
  enableVideo: boolean;
  enableSpeaker: boolean;
  enableNoiseCancellation: boolean;
  enableEchoCancellation: boolean;
  videoQuality: 'low' | 'medium' | 'high' | 'auto';
  audioBitrate: number;
  videoBitrate: number;
}

/**
 * 通话记录接口
 */
export interface CallRecord {
  id: string;
  peerId: number;
  peerName: string;
  peerAvatar?: string;
  callType: CallType;
  direction: CallDirection;
  startTime: number;
  endTime: number;
  duration: number;
  isMissed: boolean;
}

/**
 * WebRTC 信令消息接口
 */
export interface CallSignalingMessage {
  type: 'offer' | 'answer' | 'ice' | 'hangup' | 'mute' | 'video';
  callId: string;
  sdp?: string;
  iceCandidate?: string;
  isMuted?: boolean;
  isVideoEnabled?: boolean;
}

/**
 * STUN/TURN 服务器配置接口
 */
export interface STUNServerConfig {
  urls: string[];
  username?: string;
  password?: string;
}

// ==================== 类型别名 ====================

export type ChatId = number;
export type UserId = number;
export type MessageId = number;
export type FileId = number;

// ==================== ⭐ Nagram 参考：更新位掩码 ====================
// 用于批量通知 ViewModel 进行细粒度增量刷新，避免全量重绘
// 使用方式: combinedMask = MASK_A | MASK_B, ViewModel 按位检查

export const UPDATE_MASK_NEW_MESSAGE = 1;           // 新消息到达
export const UPDATE_MASK_MESSAGE_SENT = 2;           // 消息发送成功
export const UPDATE_MASK_MESSAGE_FAILED = 4;         // 消息发送失败
export const UPDATE_MASK_MESSAGE_EDITED = 8;         // 消息被编辑
export const UPDATE_MASK_MESSAGE_DELETED = 16;       // 消息被删除
export const UPDATE_MASK_MESSAGE_STATUS = 32;        // 消息状态变更（已读/发送中）
export const UPDATE_MASK_CHAT_ACTION = 64;           // 聊天动作（正在输入等）
export const UPDATE_MASK_FILE_PROGRESS = 128;        // 文件下载进度
export const UPDATE_MASK_CONNECTION = 256;           // 连接状态
export const UPDATE_MASK_USER_AVATAR = 512;          // 用户头像变更
export const UPDATE_MASK_NAME = 1024;                // 用户名变更
export const UPDATE_MASK_AVATAR = 2048;              // 头像变更
export const UPDATE_MASK_STATUS = 4096;              // 在线状态变更
export const UPDATE_MASK_CHAT_NAME = 8192;           // 聊天名称变更
export const UPDATE_MASK_CHAT_AVATAR = 16384;        // 聊天头像变更
export const UPDATE_MASK_CHAT_MEMBERS = 32768;       // 群成员变更
export const UPDATE_MASK_READ_DIALOG = 65536;        // 对话已读状态
export const UPDATE_MASK_CHAT_LIST = 131072;         // 聊天列表变更

// 组合掩码（快捷引用）
export const UPDATE_MASK_ALL = UPDATE_MASK_NEW_MESSAGE | UPDATE_MASK_MESSAGE_SENT |
  UPDATE_MASK_MESSAGE_FAILED | UPDATE_MASK_MESSAGE_EDITED | UPDATE_MASK_MESSAGE_DELETED |
  UPDATE_MASK_MESSAGE_STATUS | UPDATE_MASK_CHAT_ACTION | UPDATE_MASK_FILE_PROGRESS |
  UPDATE_MASK_CONNECTION | UPDATE_MASK_USER_AVATAR;