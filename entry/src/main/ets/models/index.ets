/**
 * Models 数据模型统一导出入口
 * 
 * 所有业务层模型统一从 TDLibData.ets 导出
 * 
 * 使用方式:
 * 1. 全量导入：import { Chat, Message, AuthState, CallSession } from '../models'
 * 2. 按需导入：import { Message } from '../models'
 */

// ==================== TDLibData - 统一业务模型 ====================
export {
  // 基础枚举
  ChatType,
  MessageType,
  MessageStatus,
  GroupEventType,
  SystemMessageType,
  DownloadPriority,
  DownloadStatus,
  NetworkPolicy,
  SyncStatus,
  OnlineStatus,
  FileType,
  DownloadEvent,

  // 文件与资源
  LocalFile,
  RemoteFile,
  TdFile,

  // 消息相关
  MessageSendingStatePending,
  MessageSendingStateFailed,
  MessageSendingState,
  MessageSelfDestructTypeImmediately,
  MessageSelfDestructTypeTimer,
  MessageSelfDestructType,

  // 核心实体
  UserStatus,
  UserProfilePhoto,
  EmojiStatus,
  User,
  UserFullInfo,
  ChatListMain,
  ChatListArchive,
  ChatListFilter,
  ChatList,
  ChatPosition,
  ChatPermissions,
  ChatNotificationSettings,
  DraftMessage,
  AvailableReactions,
  VideoChat,
  ChatActionBarInviteLink,
  ChatActionBarReportSpam,
  ChatActionBarSharePhoneNumber,
  ChatActionBarAddContact,
  ChatActionBarJoinRequest,
  ChatActionBar,
  ChatReplyMarkupForceReply,
  ChatReplyMarkupReplyKeyboard,
  ChatReplyMarkupInlineKeyboard,
  ChatReplyMarkup,
  Chat,

  // 消息内容
  TextEntity,
  FormattedText,
  MessageReaction,
  ForwardInfo,
  LocationInfo,
  VenueInfo,
  ContactInfo,
  PollOption,
  PollInfo,
  MediaInfo,
  FileInfo,
  GroupEventData,
  MessageContent,
  Message,

  // 回调查询
  CallbackQueryPayload,

  // 消息链接预览
  MessageLinkInfo,

  // Web App
  WebAppInfo,

  // 游戏
  GameInfo,

  // 骰子消息
  DiceInfo,

  // 付费媒体
  PaidMediaInfo,

  // 礼物消息
  GiftInfo,

  // 赠品消息
  GiveawayInfo,

  // 发票
  InvoiceInfo,

  // 通话（消息中的通话数据）
  CallInfo,

  // 聊天统计
  ChatStatistics,

  // 加群请求
  ChatJoinRequest,

  // 用户隐私设置
  UserPrivacySetting,
  UserPrivacySettingRule,

  // 机器人命令
  BotCommand,

  // Passport 元素
  PassportElement,

  // 聊天提升
  ChatBoostFeatures,

  // 消息互动信息
  MessageInteractionInfo,

  // 故事
  StoryArea,

  // 聊天背景
  ChatBackground,

  // 键盘相关
  InlineKeyboardButton,
  InlineKeyboardRow,
  InlineKeyboardMarkup,
  KeyboardButton,
  ReplyKeyboardMarkup,

  // 群组/超级群组
  ChatAdministratorRights,
  ChatMemberStatusCreator,
  ChatMemberStatusAdministrator,
  ChatMemberStatusMember,
  ChatMemberStatusRestricted,
  ChatMemberStatusLeft,
  ChatMemberStatusBanned,
  ChatMemberStatus,
  BasicGroup,
  Supergroup,

  // 秘密聊天
  SecretChat,

  // 故事
  StoryInteractionInfo,
  StoryContent,
  Story,

  // 聊天筛选器
  ChatFilter,

  // 事实核查
  FactCheck,

  // 聊天提升
  ChatBoostSourcePremium,
  ChatBoostSourceGiftCode,
  ChatBoostSourceGiveaway,
  ChatBoostSource,
  ChatBoost,

  // 联系人相关
  PhoneNumber,
  EmailAddress,
  Contact,
  ContactGroup,
  ContactListItemData,
  ContactSearchResult,
  ContactStats,

  // 文件下载相关
  AutoDownloadConfig,
  DownloadTask,
  DownloadProgressData,
  DownloadCompleteData,
  DownloadFailedData,
  DownloadPausedData,
  DownloadQueuedData,
  DownloadStartData,
  DownloadCancelledData,
  QueueCheckResult,
  PersistedDownloadTask,

  // 通知相关
  NotificationSettings,
  ScopeNotificationSettings,
  AutosaveSettings,

  // 辅助类型
  ChatListItem,
  TypingStatus,
  UserInfo,
  MessageEntity,

  // 类型别名
  ChatId,
  UserId,
  MessageId,
  FileId,

  // ==================== 认证相关 ====================
  AuthState,
  AuthResult,
  SetPhoneNumberResult,
  CheckCodeResult,
  CheckPasswordResult,
  AuthErrorCode,

  // ==================== 通话相关 ====================
  CallType,
  CallState,
  CallDirection,
  CallSession,
  GroupCallInfo,
  GroupCallInfoParams,
  GroupCallInfoImpl,
  CallParticipant,
  CallSettings,
  CallRecord,
  CallSignalingMessage,
  STUNServerConfig
} from './TDLibData';


