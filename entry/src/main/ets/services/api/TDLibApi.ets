/**
 * TDLib API 完整封装（展开参数版本）
 * 使用时需确保 TDLibClient 实例已正确初始化。
 *
 * @module TDLibApi
 * @see https://core.telegram.org/tdlib/docs/
 */

import { TDLibClient } from '../core/tdlib/TDLibClient';
import type {
  // ==================== 基础类型 ====================
  Ok,
  Error,
  Updates,
  Update,

  // ==================== Bot 相关 ====================
  botCommand,

  // ==================== 认证相关 ====================
  AuthorizationState,
  PasswordState,
  RecoveryEmailAddress,
  TemporaryPasswordState,
  ResetPasswordResult,
  EmailAddressAuthenticationCodeInfo,
  phoneNumberAuthenticationSettings$Input,
  ResendCodeReason$Input,
  EmailAddressAuthentication$Input,
  StoreTransaction$Input,
  Session,
  termsOfService,
  passkey,
  passkeys,

  // ==================== 用户相关 ====================
  User,
  UserFullInfo,
  BasicGroup,
  BasicGroupFullInfo,
  Supergroup,
  SupergroupFullInfo,
  SecretChat,
  ChatPhotos,
  birthdate,
  emojiStatus,
  ProfileTab,
  usernames,

  // ==================== 消息相关 ====================
  Message,
  Messages,
  MessageProperties,
  MessageReadDate,
  MessageCalendar,
  MessageLink,
  MessageLinkInfo,
  MessageSenders,
  MessageAutoDeleteTime,
  MessageFileType,
  MessageEffect,
  MessageThreadInfo,
  MessagePositions,
  MessageViewers,
  MessageStatistics,
  MessageSchedulingState,
  messageStory,
  MessageTopic,
  MessageTopic$Input,
  FormattedText,
  TextEntities,
  draftMessage,

  // ==================== 聊天相关 ====================
  Chat,
  Chats,
  ChatList,
  ChatType,
  ChatTheme,
  chatPermissions,
  chatBoost,
  ChatStatistics,
  chatAdministratorRights,
  chatEventLogFilters$Input,
  chatInviteLinkMember,
  chatJoinRequest,
  chatLocation,
  locationAddress,
  location,
  chatNotificationSettings,
  chatListMain$Input,
  NewChatPrivacySettings,
  RecommendedChatFolders,
  ArchiveChatListSettings,
  forumTopicInfo,
  getCreatedPublicChats,
  setChatDescription,
  DirectMessagesChatTopic,
  ForumTopic,

  // ==================== 媒体和文件 ====================
  Animation,
  Animations,
  audio,
  Audios,
  document,
  File,
  photoSize,
  photo,
  Sticker,
  Stickers,
  video,
  voiceNote,
  videoNote,

  // ==================== 支付与星币 ====================
  StarCount,
  StarAmount,
  StarTransactions,
  StarRevenueStatistics,
  StarPaymentOptions,
  StarGiveawayPaymentOptions,
  StarSubscriptions,
  PaymentForm,
  PaymentReceipt,
  PaymentResult,
  OrderInfo,
  ValidatedOrderInfo,
  shippingOption,
  labeledPricePart,
  invoice,
  premiumGiftCodeInfo,
  premiumGiftPaymentOptions,
  premiumGiveawayPaymentOptions,
  GiveawayInfo,
  giveawayParameters,
  ReceivedGift,
  ReceivedGifts,
  UpgradeGiftResult,
  GiftResaleResult,
  GiftAuctionState,
  GiftAuctionAcquiredGifts,
  GiftsForResale,
  GiftsForCrafting,
  GiftCollection,
  GiftCollections,
  GiftChatThemes,
  GiftUpgradePreview,
  GiftUpgradeVariants,
  AvailableGifts,
  CanSendGiftResult,
  giftSettings,
  giftForResale,
  PaidReactionType,

  // ==================== 表情与背景 ====================
  AddedReactions,
  AvailableReactions,
  ReactionType,
  reactionNotificationSettings,
  Backgrounds,
  Background,
  BackgroundType,
  StickerSet,
  StickerSets,
  TrendingStickerSets,

  // ==================== Bot 与商业功能 ====================
  BotMenuButton,
  BotCommands,
  AttachmentMenuBot,
  BusinessConnectedBot,
  BusinessConnection,
  BusinessFeatures,
  BusinessChatLinks,
  BusinessChatLinkInfo,
  BusinessChatLink,
  businessStartPage,
  businessLocation,
  businessOpeningHours,
  businessGreetingMessageSettings,
  businessAwayMessageSettings,
  BusinessFeature,
  ChatMessageSenders,

  // ==================== 通话与直播 ====================
  GroupCall,
  GroupCallInfo,
  GroupCallParticipant,
  GroupCallParticipants,
  GroupCallStreams,
  GroupCallDataChannel$Input,
  GroupCallVideoQuality$Input,
  InviteGroupCallParticipantResult,
  RtmpUrl,
  callProtocol,
  StartLiveStoryResult,

  // ==================== 故事相关 ====================
  Story,
  Stories,
  StoryAlbum,
  StoryAlbums,
  StoryInteractions,
  StoryStatistics,
  FoundStories,
  LiveStoryDonors,
  CanPostStoryResult,
  StoryContent,
  ReportStoryResult,

  // ==================== 隐私与安全 ====================
  PassportElement,
  PassportElements,
  PassportElementsWithErrors,
  PassportAuthorizationForm,
  PassportElementType,
  passportElementError,
  BlockList,

  // ==================== 语言与本地化 ====================
  LanguagePackInfo,
  LanguagePackStrings,
  LanguagePackStringValue,
  LocalizationTargetInfo,
  TimeZones,

  // ==================== 通知与设置 ====================
  NotificationSound,
  NotificationSounds,
  ScopeNotificationSettings,
  AutosaveSettings,
  AutosaveSettingsScope,
  AutoDownloadSettingsPresets,
  ReadDatePrivacySettings,
  AccountTtl,
  CollectibleItemType$Input,

  // ==================== 网络与代理 ====================
  NetworkStatistics,
  NetworkStatisticsEntry,
  NetworkType,
  proxy,
  AddedProxy,
  AddedProxies,

  // ==================== 搜索与发现 ====================
  FoundPublicPosts,
  PublicPostSearchLimits,
  FoundWebApp,
  FoundFileDownloads,
  FoundUsers,
  InlineQueryResults,
  inlineQueryResultsButton,
  InlineQueryResult,
  PreparedInlineMessage,
  PreparedInlineMessageId,
  SentWebAppMessage,
  MainWebApp,
  WebAppInfo,
  TMeUrls,
  InternalLinkType,
  LoginUrlInfo,
  SearchMessagesFilter$Input,
  SearchMessagesChatTypeFilter$Input,
  MessageSender,
  messageSendOptions$Input,
  ReplyMarkup,
  InputMessageContent,

  // ==================== 统计与分析 ====================
  StatisticalGraph,
  TonRevenueStatistics,
  TonTransactions,
  BankCardInfo,

  // ==================== 游戏与抽奖 ====================
  GameHighScores,
  StakeDiceState,
  CallbackQueryAnswer,
  CallbackQueryPayload,

  // ==================== 快速回复与检查清单 ====================
  QuickReplyMessage,
  QuickReplyMessages,

  // ==================== 高级功能 ====================
  OptionValue,
  JsonValue,
  LinkPreview,
  WebPageInstantView,
  CanSendMessageToUserResult,
  ReportChatResult,
  SponsoredMessages,
  SponsoredChats,
  ReportSponsoredResult,
  VideoMessageAdvertisements,
  SavedMessagesTags,
  themeParameters$Input,

  // ==================== 联盟与推广 ====================
  affiliateProgramParameters,
  AffiliateProgramSortOrder$Input,

  // ==================== 输入类型 ====================
  joinGroupCall,
  UserLink,
  FoundChatMessages,
  FoundMessages,
  InputMessageReplyTo,
  inputTextQuote$Input,
  inputChecklist,
  BusinessMessage,
  StoryPrivacySettings,
  ForumTopics,
  EmojiReaction,
  SuggestedAction,
  ChatAction,
  CreatedBasicGroupChat,
  ChatLists,
  ChatFolder,
  ChatFolderInfo,
  ChatFolderIcon,
  ChatFolderInviteLink,
  ChatFolderInviteLinkInfo,
  ChatAvailableReactions,
  FailedToAddMembers,
  ChatMemberStatus,
  CanTransferOwnershipResult,
  CheckChatUsernameResult,
  ChatAdministrators,
  ChatMembers,
  InputFile,
  NotificationSettingsScope,
  TopChatCategory$Input,
  CurrentWeather,
  StoryList,
  ChatActiveStories,
  PublicForwards,
  ChatBoostLevelFeatures,
  ChatBoostFeatures,
  ChatBoostSlots,
  ChatBoostStatus,
  ChatBoostLink,
  ChatBoostLinkInfo,
  FoundChatBoosts,
  EmojiStatusCustomEmojis,
  EmojiStatuses,
  FileType,
  StickerFormat,
  ChatInviteLink,
  ChatInviteLinkCounts,
  ChatInviteLinks,
  ChatInviteLinkMembers,
  ChatInviteLinkInfo,
  ChatJoinRequests,
  ImportedContacts,
  importedContact$Input,
  StickerType,
  EmojiKeywords,
  EmojiCategories,
  AnimatedEmoji,
  CustomRequestResult,
  BotMediaPreviews,
  BotMediaPreviewInfo,
  BotMediaPreview,
  Sessions,
  ConnectedWebsites,
  ChatEvents,
  CraftGiftResult,
  GiftResalePrice,
  UpgradedGift,
  UpgradedGiftValueInfo,
  UserPrivacySettingRules,
  UserPrivacySetting,
  ChatRevenueStatistics,
  ChatRevenueTransactions,
  StorageStatistics,
  StorageStatisticsFast,
  DatabaseStatistics,
  PremiumLimit,
  PremiumLimitType,
  PremiumFeatures,
  PremiumFeature,
  PremiumState,
  PremiumGiftPaymentOptions,
  PremiumGiveawayPaymentOptions,
  PremiumGiftCodeInfo,
  FoundAffiliatePrograms,
  ConnectedAffiliateProgram,
  ConnectedAffiliatePrograms,
  Countries,
  PhoneNumberInfo,
  CollectibleItemInfo,
  DeepLinkInfo,
  LogStream,
  UserSupportInfo,
  TestInt,
  TestString,
  InputChatPhoto$Input,
  PublicChatType$Input,
  forumTopicIcon,
  TextParseMode$Input,
  inputChecklistTask,
  targetChatTypes$Input,
  Outline,
  webAppOpenParameters$Input,
  ChatFolderInviteLinks,
  Users,
  ChatMember,
  chatNotificationSettings$Input,
} from './factory/tdlib-types';

export class TDLibApi {
  private client: TDLibClient;

  constructor(client: TDLibClient) {
    this.client = client;
  }

  // ==================== 认证与授权 ====================

  /**
   * 返回当前授权状态（离线方法）
   */
  getAuthorizationState(): Promise<AuthorizationState> {
    const params: Record<string, Object> = {
      '@type': 'getAuthorizationState',
    };
    return this.client.execute<AuthorizationState>(params);
  }

  /**
   * 设置 TDLib 初始化参数，仅在 authorizationStateWaitTdlibParameters 时有效
   * @param use_test_dc 是否使用测试环境
   * @param database_directory 持久数据库目录
   * @param files_directory 文件存储目录
   * @param database_encryption_key 数据库加密密钥
   * @param use_file_database 是否在重启间保留文件信息
   * @param use_chat_info_database 是否缓存用户/群组信息
   * @param use_message_database 是否缓存聊天和消息
   * @param use_secret_chats 是否支持秘密聊天
   * @param api_id Telegram API ID
   * @param api_hash Telegram API Hash
   * @param system_language_code 系统语言标签
   * @param device_model 设备型号
   * @param system_version 操作系统版本
   * @param application_version 应用版本
   */
  setTdlibParameters(
    use_test_dc: boolean,
    database_directory: string,
    files_directory: string,
    database_encryption_key: Uint8Array,
    use_file_database: boolean,
    use_chat_info_database: boolean,
    use_message_database: boolean,
    use_secret_chats: boolean,
    api_id: number,
    api_hash: string,
    system_language_code: string,
    device_model: string,
    system_version: string,
    application_version: string
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setTdlibParameters',
      'use_test_dc': use_test_dc,
      'database_directory': database_directory,
      'files_directory': files_directory,
      'database_encryption_key': database_encryption_key,
      'use_file_database': use_file_database,
      'use_chat_info_database': use_chat_info_database,
      'use_message_database': use_message_database,
      'use_secret_chats': use_secret_chats,
      'api_id': api_id,
      'api_hash': api_hash,
      'system_language_code': system_language_code,
      'device_model': device_model,
      'system_version': system_version,
      'application_version': application_version,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置手机号并发送验证码
   * @param phone_number 国际格式手机号
   * @param settings 手机号认证设置
   */
  setAuthenticationPhoneNumber(phone_number: string, settings: phoneNumberAuthenticationSettings$Input): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setAuthenticationPhoneNumber',
      'phone_number': phone_number,
      'settings': settings,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 检查 Premium 购买（预授权）
   * @param currency ISO 4217 货币代码
   * @param amount 支付金额（最小单位）
   */
  checkAuthenticationPremiumPurchase(currency: string, amount: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'checkAuthenticationPremiumPurchase',
      'currency': currency,
      'amount': amount,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 提交 Premium 购买交易
   * @param transaction 交易信息
   * @param is_restore 是否为恢复购买
   * @param currency 货币代码
   * @param amount 支付金额
   */
  setAuthenticationPremiumPurchaseTransaction(
    transaction: StoreTransaction$Input,
    is_restore: boolean,
    currency: string,
    amount: number
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setAuthenticationPremiumPurchaseTransaction',
      'transaction': transaction,
      'is_restore': is_restore,
      'currency': currency,
      'amount': amount,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置邮箱地址并发送验证码
   * @param email_address 邮箱地址
   */
  setAuthenticationEmailAddress(email_address: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setAuthenticationEmailAddress',
      'email_address': email_address,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 重新发送验证码
   * ⭐ 注意：TDLib resendAuthenticationCode 不需要任何参数
   */
  resendAuthenticationCode(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'resendAuthenticationCode',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 验证邮箱验证码
   * @param code 邮箱验证数据
   */
  checkAuthenticationEmailCode(code: EmailAddressAuthentication$Input): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'checkAuthenticationEmailCode',
      'code': code,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 验证短信验证码
   * @param code 验证码字符串
   */
  checkAuthenticationCode(code: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'checkAuthenticationCode',
      'code': code,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 请求二维码认证
   * @param other_user_ids 其他正在使用应用的用户 ID 列表
   */
  requestQrCodeAuthentication(other_user_ids: number[]): Promise<Record<string, Object>> {
    const params: Record<string, Object> = {
      '@type': 'requestQrCodeAuthentication',
      'other_user_ids': other_user_ids,
    };
    return this.client.execute<Record<string, Object>>(params);
  }

  /**
   * 获取 Passkey 认证参数（返回 JSON 字符串）
   */
  getAuthenticationPasskeyParameters(): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getAuthenticationPasskeyParameters',
    };
    return this.client.execute<string>(params);
  }

  /**
   * 验证 Passkey 登录
   * @param credential_id Base64url 凭证 ID
   * @param client_data JSON 客户端数据
   * @param authenticator_data 认证器数据
   * @param signature 签名
   * @param user_handle 用户句柄
   */
  checkAuthenticationPasskey(
    credential_id: string,
    client_data: string,
    authenticator_data: Uint8Array,
    signature: Uint8Array,
    user_handle: Uint8Array
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'checkAuthenticationPasskey',
      'credential_id': credential_id,
      'client_data': client_data,
      'authenticator_data': authenticator_data,
      'signature': signature,
      'user_handle': user_handle,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 完成用户注册
   * @param first_name 名
   * @param last_name 姓
   * @param disable_notification 是否不通知联系人
   */
  registerUser(first_name: string, last_name: string, disable_notification: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'registerUser',
      'first_name': first_name,
      'last_name': last_name,
      'disable_notification': disable_notification,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 重置登录邮箱地址
   */
  resetAuthenticationEmailAddress(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'resetAuthenticationEmailAddress',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 验证两步验证密码
   * @param password 密码
   */
  checkAuthenticationPassword(password: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'checkAuthenticationPassword',
      'password': password,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 请求两步验证密码恢复码
   */
  requestAuthenticationPasswordRecovery(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'requestAuthenticationPasswordRecovery',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 验证两步验证恢复码
   * @param recovery_code 恢复码
   */
  checkAuthenticationPasswordRecoveryCode(recovery_code: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'checkAuthenticationPasswordRecoveryCode',
      'recovery_code': recovery_code,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 通过恢复码恢复两步验证密码
   * @param recovery_code 恢复码
   * @param new_password 新密码
   * @param new_hint 新密码提示
   */
  recoverAuthenticationPassword(recovery_code: string, new_password: string, new_hint: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'recoverAuthenticationPassword',
      'recovery_code': recovery_code,
      'new_password': new_password,
      'new_hint': new_hint,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 发送 Firebase 短信验证码
   * @param token Play Integrity 或 SafetyNet 令牌
   */
  sendAuthenticationFirebaseSms(token: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'sendAuthenticationFirebaseSms',
      'token': token,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 报告短信验证码未送达
   * @param mobile_network_code 当前移动网络代码
   */
  reportAuthenticationCodeMissing(mobile_network_code: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'reportAuthenticationCodeMissing',
      'mobile_network_code': mobile_network_code,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 使用 Bot Token 登录
   * @param token Bot Token
   */
  checkAuthenticationBotToken(token: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'checkAuthenticationBotToken',
      'token': token,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 注销账号并关闭实例
   */
  logOut(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'logOut',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 关闭 TDLib 实例（保留数据）
   */
  close(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'close',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 销毁 TDLib 实例并清除所有数据
   */
  destroy(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'destroy',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 确认二维码认证
   * @param link 二维码中的链接
   */
  confirmQrCodeAuthentication(link: string): Promise<Session> {
    const params: Record<string, Object> = {
      '@type': 'confirmQrCodeAuthentication',
      'link': link,
    };
    return this.client.execute<Session>(params);
  }

  /**
   * 获取当前状态（所有更新）
   */
  getCurrentState(): Promise<Record<string, Object>> {
    const params: Record<string, Object> = {
      '@type': 'getCurrentState',
    };
    return this.client.execute<Record<string, Object>>(params);
  }

  /**
   * 更改数据库加密密钥
   * @param new_encryption_key 新密钥
   */
  setDatabaseEncryptionKey(new_encryption_key: Uint8Array): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setDatabaseEncryptionKey',
      'new_encryption_key': new_encryption_key,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取两步验证状态
   */
  getPasswordState(): Promise<PasswordState> {
    const params: Record<string, Object> = {
      '@type': 'getPasswordState',
    };
    return this.client.execute<PasswordState>(params);
  }

  /**
   * 更改两步验证密码
   * @param old_password 旧密码
   * @param new_password 新密码
   * @param new_hint 新提示
   * @param set_recovery_email_address 是否同时设置恢复邮箱
   * @param new_recovery_email_address 新恢复邮箱
   */
  setPassword(
    old_password: string,
    new_password: string,
    new_hint: string,
    set_recovery_email_address: boolean,
    new_recovery_email_address: string
  ): Promise<PasswordState> {
    const params: Record<string, Object> = {
      '@type': 'setPassword',
      'old_password': old_password,
      'new_password': new_password,
      'new_hint': new_hint,
      'set_recovery_email_address': set_recovery_email_address,
      'new_recovery_email_address': new_recovery_email_address,
    };
    return this.client.execute<PasswordState>(params);
  }

  /**
   * 检查是否需要设置登录邮箱
   */
  isLoginEmailAddressRequired(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'isLoginEmailAddressRequired',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置登录邮箱地址
   * @param new_login_email_address 新登录邮箱
   */
  setLoginEmailAddress(new_login_email_address: string): Promise<EmailAddressAuthenticationCodeInfo> {
    const params: Record<string, Object> = {
      '@type': 'setLoginEmailAddress',
      'new_login_email_address': new_login_email_address,
    };
    return this.client.execute<EmailAddressAuthenticationCodeInfo>(params);
  }

  /**
   * 重新发送登录邮箱验证码
   */
  resendLoginEmailAddressCode(): Promise<EmailAddressAuthenticationCodeInfo> {
    const params: Record<string, Object> = {
      '@type': 'resendLoginEmailAddressCode',
    };
    return this.client.execute<EmailAddressAuthenticationCodeInfo>(params);
  }

  /**
   * 验证登录邮箱验证码
   * @param code 邮箱验证数据
   */
  checkLoginEmailAddressCode(code: EmailAddressAuthentication$Input): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'checkLoginEmailAddressCode',
      'code': code,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取恢复邮箱地址
   * @param password 两步验证密码
   */
  getRecoveryEmailAddress(password: string): Promise<RecoveryEmailAddress> {
    const params: Record<string, Object> = {
      '@type': 'getRecoveryEmailAddress',
      'password': password,
    };
    return this.client.execute<RecoveryEmailAddress>(params);
  }

  /**
   * 设置恢复邮箱地址
   * @param password 两步验证密码
   * @param new_recovery_email_address 新恢复邮箱
   */
  setRecoveryEmailAddress(password: string, new_recovery_email_address: string): Promise<PasswordState> {
    const params: Record<string, Object> = {
      '@type': 'setRecoveryEmailAddress',
      'password': password,
      'new_recovery_email_address': new_recovery_email_address,
    };
    return this.client.execute<PasswordState>(params);
  }

  /**
   * 验证恢复邮箱验证码
   * @param code 验证码
   */
  checkRecoveryEmailAddressCode(code: string): Promise<PasswordState> {
    const params: Record<string, Object> = {
      '@type': 'checkRecoveryEmailAddressCode',
      'code': code,
    };
    return this.client.execute<PasswordState>(params);
  }

  /**
   * 重新发送恢复邮箱验证码
   */
  resendRecoveryEmailAddressCode(): Promise<PasswordState> {
    const params: Record<string, Object> = {
      '@type': 'resendRecoveryEmailAddressCode',
    };
    return this.client.execute<PasswordState>(params);
  }

  /**
   * 取消恢复邮箱验证
   */
  cancelRecoveryEmailAddressVerification(): Promise<PasswordState> {
    const params: Record<string, Object> = {
      '@type': 'cancelRecoveryEmailAddressVerification',
    };
    return this.client.execute<PasswordState>(params);
  }

  /**
   * 请求密码恢复（发送邮件）
   */
  requestPasswordRecovery(): Promise<EmailAddressAuthenticationCodeInfo> {
    const params: Record<string, Object> = {
      '@type': 'requestPasswordRecovery',
    };
    return this.client.execute<EmailAddressAuthenticationCodeInfo>(params);
  }

  /**
   * 检查密码恢复码
   * @param recovery_code 恢复码
   */
  checkPasswordRecoveryCode(recovery_code: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'checkPasswordRecoveryCode',
      'recovery_code': recovery_code,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 通过恢复码恢复密码
   * @param recovery_code 恢复码
   * @param new_password 新密码
   * @param new_hint 新提示
   */
  recoverPassword(recovery_code: string, new_password: string, new_hint: string): Promise<PasswordState> {
    const params: Record<string, Object> = {
      '@type': 'recoverPassword',
      'recovery_code': recovery_code,
      'new_password': new_password,
      'new_hint': new_hint,
    };
    return this.client.execute<PasswordState>(params);
  }

  /**
   * 重置两步验证密码（需等待）
   */
  resetPassword(): Promise<ResetPasswordResult> {
    const params: Record<string, Object> = {
      '@type': 'resetPassword',
    };
    return this.client.execute<ResetPasswordResult>(params);
  }

  /**
   * 取消密码重置
   */
  cancelPasswordReset(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'cancelPasswordReset',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 创建临时支付密码
   * @param password 两步验证密码
   * @param valid_for 有效期（秒）
   */
  createTemporaryPassword(password: string, valid_for: number): Promise<TemporaryPasswordState> {
    const params: Record<string, Object> = {
      '@type': 'createTemporaryPassword',
      'password': password,
      'valid_for': valid_for,
    };
    return this.client.execute<TemporaryPasswordState>(params);
  }

  /**
   * 获取临时密码状态
   */
  getTemporaryPasswordState(): Promise<TemporaryPasswordState> {
    const params: Record<string, Object> = {
      '@type': 'getTemporaryPasswordState',
    };
    return this.client.execute<TemporaryPasswordState>(params);
  }

  // ==================== 用户与个人资料 ====================

  /**
   * 获取当前用户信息
   */
  getMe(): Promise<User> {
    const params: Record<string, Object> = {
      '@type': 'getMe',
    };
    return this.client.execute<User>(params);
  }

  /**
   * 根据 ID 获取用户信息
   * @param user_id 用户 ID
   */
  getUser(user_id: number): Promise<User> {
    const params: Record<string, Object> = {
      '@type': 'getUser',
      'user_id': user_id,
    };
    return this.client.execute<User>(params);
  }

  /**
   * 获取用户完整信息
   * @param user_id 用户 ID
   */
  getUserFullInfo(user_id: number): Promise<UserFullInfo> {
    const params: Record<string, Object> = {
      '@type': 'getUserFullInfo',
      'user_id': user_id,
    };
    return this.client.execute<UserFullInfo>(params);
  }

  /**
   * 获取基础群组信息
   * @param basic_group_id 基础群组 ID
   */
  getBasicGroup(basic_group_id: number): Promise<BasicGroup> {
    const params: Record<string, Object> = {
      '@type': 'getBasicGroup',
      'basic_group_id': basic_group_id,
    };
    return this.client.execute<BasicGroup>(params);
  }

  /**
   * 获取基础群组完整信息
   * @param basic_group_id 基础群组 ID
   */
  getBasicGroupFullInfo(basic_group_id: number): Promise<BasicGroupFullInfo> {
    const params: Record<string, Object> = {
      '@type': 'getBasicGroupFullInfo',
      'basic_group_id': basic_group_id,
    };
    return this.client.execute<BasicGroupFullInfo>(params);
  }

  /**
   * 获取超级群组/频道信息
   * @param supergroup_id 超级群组 ID
   */
  getSupergroup(supergroup_id: number): Promise<Supergroup> {
    const params: Record<string, Object> = {
      '@type': 'getSupergroup',
      'supergroup_id': supergroup_id,
    };
    return this.client.execute<Supergroup>(params);
  }

  /**
   * 获取超级群组/频道完整信息
   * @param supergroup_id 超级群组 ID
   */
  getSupergroupFullInfo(supergroup_id: number): Promise<SupergroupFullInfo> {
    const params: Record<string, Object> = {
      '@type': 'getSupergroupFullInfo',
      'supergroup_id': supergroup_id,
    };
    return this.client.execute<SupergroupFullInfo>(params);
  }

  /**
   * 获取秘密聊天信息
   * @param secret_chat_id 秘密聊天 ID
   */
  getSecretChat(secret_chat_id: number): Promise<SecretChat> {
    const params: Record<string, Object> = {
      '@type': 'getSecretChat',
      'secret_chat_id': secret_chat_id,
    };
    return this.client.execute<SecretChat>(params);
  }

  /**
   * 获取用户头像列表
   * @param user_id 用户 ID
   * @param offset 偏移量
   * @param limit 最大数量
   */
  getUserProfilePhotos(user_id: number, offset: number, limit: number): Promise<ChatPhotos> {
    const params: Record<string, Object> = {
      '@type': 'getUserProfilePhotos',
      'user_id': user_id,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<ChatPhotos>(params);
  }

  /**
   * 获取用户个人资料音频列表
   * @param user_id 用户 ID
   * @param offset 偏移量
   * @param limit 最大数量
   */
  getUserProfileAudios(user_id: number, offset: number, limit: number): Promise<Audios> {
    const params: Record<string, Object> = {
      '@type': 'getUserProfileAudios',
      'user_id': user_id,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<Audios>(params);
  }

  /**
   * 检查文件是否在个人资料音频中
   * @param file_id 文件 ID
   */
  isProfileAudio(file_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'isProfileAudio',
      'file_id': file_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 添加音频到个人资料音频列表开头
   * @param file_id 文件 ID
   */
  addProfileAudio(file_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'addProfileAudio',
      'file_id': file_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 调整个人资料音频顺序
   * @param file_id 要移动的文件 ID
   * @param after_file_id 插入后的文件 ID（0 表示开头）
   */
  setProfileAudioPosition(file_id: number, after_file_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setProfileAudioPosition',
      'file_id': file_id,
      'after_file_id': after_file_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 移除个人资料音频
   * @param file_id 文件 ID
   */
  removeProfileAudio(file_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeProfileAudio',
      'file_id': file_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置联系人的个人头像
   * @param user_id 用户 ID
   * @param photo 头像
   */
  setUserPersonalProfilePhoto(user_id: number, photo: InputChatPhoto$Input): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setUserPersonalProfilePhoto',
      'user_id': user_id,
      'photo': photo,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置联系人的备注
   * @param user_id 用户 ID
   * @param note 备注文本
   */
  setUserNote(user_id: number, note: FormattedText): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setUserNote',
      'user_id': user_id,
      'note': note,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 向用户建议头像
   * @param user_id 用户 ID
   * @param photo 建议的头像
   */
  suggestUserProfilePhoto(user_id: number, photo: InputChatPhoto$Input): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'suggestUserProfilePhoto',
      'user_id': user_id,
      'photo': photo,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 向用户建议生日
   * @param user_id 用户 ID
   * @param birthdate 建议的生日
   */
  suggestUserBirthdate(user_id: number, birthdate: birthdate): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'suggestUserBirthdate',
      'user_id': user_id,
      'birthdate': birthdate,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换 Bot 管理用户表情状态权限
   * @param bot_user_id Bot ID
   * @param can_manage_emoji_status 是否允许
   */
  toggleBotCanManageEmojiStatus(bot_user_id: number, can_manage_emoji_status: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleBotCanManageEmojiStatus',
      'bot_user_id': bot_user_id,
      'can_manage_emoji_status': can_manage_emoji_status,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置用户的表情状态（仅 Bot）
   * @param user_id 用户 ID
   * @param emoji_status 表情状态
   */
  setUserEmojiStatus(user_id: number, emoji_status: emojiStatus): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setUserEmojiStatus',
      'user_id': user_id,
      'emoji_status': emoji_status,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 根据手机号搜索用户
   * @param phone_number 手机号
   * @param only_local 是否仅本地
   */
  searchUserByPhoneNumber(phone_number: string, only_local: boolean): Promise<User> {
    const params: Record<string, Object> = {
      '@type': 'searchUserByPhoneNumber',
      'phone_number': phone_number,
      'only_local': only_local,
    };
    return this.client.execute<User>(params);
  }

  /**
   * 分享当前用户的手机号给互关联系人
   * @param user_id 用户 ID
   */
  sharePhoneNumber(user_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'sharePhoneNumber',
      'user_id': user_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置当前用户头像
   * @param photo 头像
   * @param is_public 是否设为公开头像
   */
  setProfilePhoto(photo: InputChatPhoto$Input, is_public: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setProfilePhoto',
      'photo': photo,
      'is_public': is_public,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 删除头像
   * @param profile_photo_id 头像 ID
   */
  deleteProfilePhoto(profile_photo_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteProfilePhoto',
      'profile_photo_id': profile_photo_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置强调色和背景自定义表情（Premium）
   * @param accent_color_id 强调色 ID
   * @param background_custom_emoji_id 背景自定义表情 ID
   */
  setAccentColor(accent_color_id: number, background_custom_emoji_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setAccentColor',
      'accent_color_id': accent_color_id,
      'background_custom_emoji_id': background_custom_emoji_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置基于升级礼物的配色方案（Premium）
   * @param upgraded_gift_colors_id 配色方案 ID
   */
  setUpgradedGiftColors(upgraded_gift_colors_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setUpgradedGiftColors',
      'upgraded_gift_colors_id': upgraded_gift_colors_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置个人资料强调色和背景自定义表情（Premium）
   * @param profile_accent_color_id 资料强调色 ID
   * @param profile_background_custom_emoji_id 资料背景自定义表情 ID
   */
  setProfileAccentColor(profile_accent_color_id: number, profile_background_custom_emoji_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setProfileAccentColor',
      'profile_accent_color_id': profile_accent_color_id,
      'profile_background_custom_emoji_id': profile_background_custom_emoji_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 修改当前用户姓名
   * @param first_name 名
   * @param last_name 姓
   */
  setName(first_name: string, last_name: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setName',
      'first_name': first_name,
      'last_name': last_name,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 修改个人简介
   * @param bio 简介文本
   */
  setBio(bio: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setBio',
      'bio': bio,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 修改可编辑的用户名
   * @param username 用户名
   */
  setUsername(username: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setUsername',
      'username': username,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 启用/禁用用户名
   * @param username 用户名
   * @param is_active 是否激活
   */
  toggleUsernameIsActive(username: string, is_active: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleUsernameIsActive',
      'username': username,
      'is_active': is_active,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 重新排序活跃用户名
   * @param usernames 新顺序的用户名列表
   */
  reorderActiveUsernames(usernames: string[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'reorderActiveUsernames',
      'usernames': usernames,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置生日
   * @param birthdate 生日信息
   */
  setBirthdate(birthdate: birthdate): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setBirthdate',
      'birthdate': birthdate,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置个人资料主选项卡
   * @param main_profile_tab 选项卡类型
   */
  setMainProfileTab(main_profile_tab: ProfileTab): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setMainProfileTab',
      'main_profile_tab': main_profile_tab,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置个人聊天（用于联系人）
   * @param chat_id 聊天 ID，0 表示移除
   */
  setPersonalChat(chat_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setPersonalChat',
      'chat_id': chat_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置表情状态（Premium）
   * @param emoji_status 表情状态
   */
  setEmojiStatus(emoji_status: emojiStatus): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setEmojiStatus',
      'emoji_status': emoji_status,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 启用/禁用赞助消息（Premium）
   * @param has_sponsored_messages_enabled 是否启用
   */
  toggleHasSponsoredMessagesEnabled(has_sponsored_messages_enabled: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleHasSponsoredMessagesEnabled',
      'has_sponsored_messages_enabled': has_sponsored_messages_enabled,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置商业账户位置（Business）
   * @param location 位置信息
   */
  setBusinessLocation(location: businessLocation): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setBusinessLocation',
      'location': location,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置商业账户营业时间
   * @param opening_hours 营业时间
   */
  setBusinessOpeningHours(opening_hours: businessOpeningHours): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setBusinessOpeningHours',
      'opening_hours': opening_hours,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置商业账户问候消息
   * @param greeting_message_settings 问候消息设置
   */
  setBusinessGreetingMessageSettings(greeting_message_settings: businessGreetingMessageSettings): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setBusinessGreetingMessageSettings',
      'greeting_message_settings': greeting_message_settings,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置商业账户离线消息
   * @param away_message_settings 离线消息设置
   */
  setBusinessAwayMessageSettings(away_message_settings: businessAwayMessageSettings): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setBusinessAwayMessageSettings',
      'away_message_settings': away_message_settings,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置商业账户启动页
   * @param start_page 启动页内容
   */
  setBusinessStartPage(start_page: businessStartPage): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setBusinessStartPage',
      'start_page': start_page,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取当前连接的商业 Bot
   */
  getBusinessConnectedBot(): Promise<BusinessConnectedBot> {
    const params: Record<string, Object> = {
      '@type': 'getBusinessConnectedBot',
    };
    return this.client.execute<BusinessConnectedBot>(params);
  }

  /**
   * 设置连接的商业 Bot
   * @param bot 商业 Bot 连接信息
   */
  setBusinessConnectedBot(bot: BusinessConnectedBot): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setBusinessConnectedBot',
      'bot': bot,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 断开商业 Bot 连接
   * @param bot_user_id Bot 用户 ID
   */
  deleteBusinessConnectedBot(bot_user_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteBusinessConnectedBot',
      'bot_user_id': bot_user_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 暂停/恢复商业 Bot 在特定聊天中的活动
   * @param chat_id 聊天 ID
   * @param is_paused 是否暂停
   */
  toggleBusinessConnectedBotChatIsPaused(chat_id: number, is_paused: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleBusinessConnectedBotChatIsPaused',
      'chat_id': chat_id,
      'is_paused': is_paused,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 将商业 Bot 从聊天中移除
   * @param chat_id 聊天 ID
   */
  removeBusinessConnectedBotFromChat(chat_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeBusinessConnectedBotFromChat',
      'chat_id': chat_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取商业聊天链接列表
   */
  getBusinessChatLinks(): Promise<BusinessChatLinks> {
    const params: Record<string, Object> = {
      '@type': 'getBusinessChatLinks',
    };
    return this.client.execute<BusinessChatLinks>(params);
  }

  /**
   * 创建商业聊天链接
   * @param link_info 链接信息
   */
  createBusinessChatLink(link_info: BusinessChatLink): Promise<BusinessChatLink> {
    const params: Record<string, Object> = {
      '@type': 'createBusinessChatLink',
      'link_info': link_info,
    };
    return this.client.execute<BusinessChatLink>(params);
  }

  /**
   * 编辑商业聊天链接
   * @param link 链接 URL
   * @param link_info 新信息
   */
  editBusinessChatLink(link: string, link_info: BusinessChatLink): Promise<BusinessChatLink> {
    const params: Record<string, Object> = {
      '@type': 'editBusinessChatLink',
      'link': link,
      'link_info': link_info,
    };
    return this.client.execute<BusinessChatLink>(params);
  }

  /**
   * 删除商业聊天链接
   * @param link 链接 URL
   */
  deleteBusinessChatLink(link: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteBusinessChatLink',
      'link': link,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取商业聊天链接信息
   * @param link_name 链接名称
   */
  getBusinessChatLinkInfo(link_name: string): Promise<BusinessChatLinkInfo> {
    const params: Record<string, Object> = {
      '@type': 'getBusinessChatLinkInfo',
      'link_name': link_name,
    };
    return this.client.execute<BusinessChatLinkInfo>(params);
  }

  /**
   * 获取当前用户的个人链接
   */
  getUserLink(): Promise<UserLink> {
    const params: Record<string, Object> = {
      '@type': 'getUserLink',
    };
    return this.client.execute<UserLink>(params);
  }

  /**
   * 通过令牌搜索用户
   * @param token 用户链接中的令牌
   */
  searchUserByToken(token: string): Promise<User> {
    const params: Record<string, Object> = {
      '@type': 'searchUserByToken',
      'token': token,
    };
    return this.client.execute<User>(params);
  }

  // ==================== 聊天管理 ====================

  /**
   * 获取聊天信息
   * @param chat_id 聊天 ID
   */
  getChat(chat_id: number): Promise<Chat> {
    const params: Record<string, Object> = {
      '@type': 'getChat',
      'chat_id': chat_id,
    };
    return this.client.execute<Chat>(params);
  }

  /**
   * 获取消息信息
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   */
  getMessage(chat_id: number, message_id: number): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'getMessage',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<Message>(params);
  }

  /**
   * 获取本地消息（不发送网络请求）
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   */
  getMessageLocally(chat_id: number, message_id: number): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'getMessageLocally',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<Message>(params);
  }

  /**
   * 获取被回复的消息
   * @param chat_id 聊天 ID
   * @param message_id 回复消息 ID
   */
  getRepliedMessage(chat_id: number, message_id: number): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'getRepliedMessage',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<Message>(params);
  }

  /**
   * 获取聊天置顶消息
   * @param chat_id 聊天 ID
   */
  getChatPinnedMessage(chat_id: number): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'getChatPinnedMessage',
      'chat_id': chat_id,
    };
    return this.client.execute<Message>(params);
  }

  /**
   * 获取回调查询对应的消息
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param callback_query_id 回调查询 ID
   */
  getCallbackQueryMessage(chat_id: number, message_id: number, callback_query_id: number): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'getCallbackQueryMessage',
      'chat_id': chat_id,
      'message_id': message_id,
      'callback_query_id': callback_query_id,
    };
    return this.client.execute<Message>(params);
  }

  /**
   * 批量获取消息
   * @param chat_id 聊天 ID
   * @param message_ids 消息 ID 列表
   */
  getMessages(chat_id: number, message_ids: number[]): Promise<Messages> {
    const params: Record<string, Object> = {
      '@type': 'getMessages',
      'chat_id': chat_id,
      'message_ids': message_ids,
    };
    return this.client.execute<Messages>(params);
  }

  /**
   * 获取消息属性（离线）
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   */
  getMessageProperties(chat_id: number, message_id: number): Promise<MessageProperties> {
    const params: Record<string, Object> = {
      '@type': 'getMessageProperties',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<MessageProperties>(params);
  }

  /**
   * 获取消息线程信息
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   */
  getMessageThread(chat_id: number, message_id: number): Promise<MessageThreadInfo> {
    const params: Record<string, Object> = {
      '@type': 'getMessageThread',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<MessageThreadInfo>(params);
  }

  /**
   * 获取消息已读时间
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   */
  getMessageReadDate(chat_id: number, message_id: number): Promise<MessageReadDate> {
    const params: Record<string, Object> = {
      '@type': 'getMessageReadDate',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<MessageReadDate>(params);
  }

  /**
   * 获取消息查看者列表
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   */
  getMessageViewers(chat_id: number, message_id: number): Promise<MessageViewers> {
    const params: Record<string, Object> = {
      '@type': 'getMessageViewers',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<MessageViewers>(params);
  }

  /**
   * 获取消息真实作者
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   */
  getMessageAuthor(chat_id: number, message_id: number): Promise<User> {
    const params: Record<string, Object> = {
      '@type': 'getMessageAuthor',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<User>(params);
  }

  /**
   * 加载更多聊天
   * @param chat_list 聊天列表
   * @param limit 最大数量
   */
  loadChats(chat_list: ChatList | null, limit: number): Promise<Ok> {
    // 【关键修复】使用具体接口类型和 _ 字段
    const defaultChatList: chatListMain$Input = { _: 'chatListMain' };
    const params: Record<string, Object> = {
      '@type': 'loadChats',
      'chat_list': chat_list ?? defaultChatList,
      'limit': limit,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取聊天列表
   * @param chat_list 聊天列表
   * @param limit 最大数量
   */
  getChats(chat_list: ChatList, limit: number): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'getChats',
      'chat_list': chat_list,
      'limit': limit,
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 通过用户名搜索公开聊天
   * @param username 用户名
   */
  searchPublicChat(username: string): Promise<Chat> {
    const params: Record<string, Object> = {
      '@type': 'searchPublicChat',
      'username': username,
    };
    return this.client.execute<Chat>(params);
  }

  /**
   * 搜索公开聊天列表
   * @param query 查询字符串
   */
  searchPublicChats(query: string): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'searchPublicChats',
      'query': query,
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 在已知聊天中搜索
   * @param query 查询字符串
   * @param limit 最大数量
   */
  searchChats(query: string, limit: number): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'searchChats',
      'query': query,
      'limit': limit,
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 在服务器上搜索聊天
   * @param query 查询字符串
   * @param limit 最大数量
   */
  searchChatsOnServer(query: string, limit: number): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'searchChatsOnServer',
      'query': query,
      'limit': limit,
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 获取推荐频道
   */
  getRecommendedChats(): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'getRecommendedChats',
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 获取相似聊天
   * @param chat_id 聊天 ID
   */
  getChatSimilarChats(chat_id: number): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'getChatSimilarChats',
      'chat_id': chat_id,
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 获取相似聊天数量
   * @param chat_id 聊天 ID
   * @param return_local 是否仅本地
   */
  getChatSimilarChatCount(chat_id: number, return_local: boolean): Promise<number> {
    const params: Record<string, Object> = {
      '@type': 'getChatSimilarChatCount',
      'chat_id': chat_id,
      'return_local': return_local,
    };
    return this.client.execute<number>(params);
  }

  /**
   * 打开相似聊天
   * @param chat_id 原聊天 ID
   * @param opened_chat_id 打开的聊天 ID
   */
  openChatSimilarChat(chat_id: number, opened_chat_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'openChatSimilarChat',
      'chat_id': chat_id,
      'opened_chat_id': opened_chat_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取相似 Bot
   * @param bot_user_id Bot ID
   */
  getBotSimilarBots(bot_user_id: number): Promise<Record<string, Object>> {
    const params: Record<string, Object> = {
      '@type': 'getBotSimilarBots',
      'bot_user_id': bot_user_id,
    };
    return this.client.execute<Record<string, Object>>(params);
  }

  /**
   * 获取相似 Bot 数量
   * @param bot_user_id Bot ID
   * @param return_local 是否仅本地
   */
  getBotSimilarBotCount(bot_user_id: number, return_local: boolean): Promise<number> {
    const params: Record<string, Object> = {
      '@type': 'getBotSimilarBotCount',
      'bot_user_id': bot_user_id,
      'return_local': return_local,
    };
    return this.client.execute<number>(params);
  }

  /**
   * 打开相似 Bot
   * @param bot_user_id 原 Bot ID
   * @param opened_bot_user_id 打开的 Bot ID
   */
  openBotSimilarBot(bot_user_id: number, opened_bot_user_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'openBotSimilarBot',
      'bot_user_id': bot_user_id,
      'opened_bot_user_id': opened_bot_user_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取常用聊天
   * @param category 类别
   * @param limit 最大数量
   */
  getTopChats(category: TopChatCategory$Input, limit: number): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'getTopChats',
      'category': category,
      'limit': limit,
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 移除常用聊天
   * @param category 类别
   * @param chat_id 聊天 ID
   */
  removeTopChat(category: TopChatCategory$Input, chat_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeTopChat',
      'category': category,
      'chat_id': chat_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 搜索最近找到的聊天
   * @param query 查询字符串
   * @param limit 最大数量
   */
  searchRecentlyFoundChats(query: string, limit: number): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'searchRecentlyFoundChats',
      'query': query,
      'limit': limit,
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 添加聊天到最近列表
   * @param chat_id 聊天 ID
   */
  addRecentlyFoundChat(chat_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'addRecentlyFoundChat',
      'chat_id': chat_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 从最近列表中移除聊天
   * @param chat_id 聊天 ID
   */
  removeRecentlyFoundChat(chat_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeRecentlyFoundChat',
      'chat_id': chat_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 清空最近聊天列表
   */
  clearRecentlyFoundChats(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'clearRecentlyFoundChats',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取最近打开的聊天
   * @param limit 最大数量
   */
  getRecentlyOpenedChats(limit: number): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'getRecentlyOpenedChats',
      'limit': limit,
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 检查用户名是否可用
   * @param chat_id 聊天 ID（0 表示新聊天）
   * @param username 用户名
   */
  checkChatUsername(chat_id: number, username: string): Promise<CheckChatUsernameResult> {
    const params: Record<string, Object> = {
      '@type': 'checkChatUsername',
      'chat_id': chat_id,
      'username': username,
    };
    return this.client.execute<CheckChatUsernameResult>(params);
  }

  /**
   * 获取用户创建的公开聊天
   * @param type 公开聊天类型
   */
  getCreatedPublicChats(type: PublicChatType$Input): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'getCreatedPublicChats',
      'type': type,
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 检查公开聊天数量限制
   * @param type 公开聊天类型
   */
  checkCreatedPublicChatsLimit(type: PublicChatType$Input): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'checkCreatedPublicChatsLimit',
      'type': type,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取合适的讨论群组
   */
  getSuitableDiscussionChats(): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'getSuitableDiscussionChats',
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 获取不活跃的超级群组/频道
   */
  getInactiveSupergroupChats(): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'getInactiveSupergroupChats',
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 获取合适的个人聊天
   */
  getSuitablePersonalChats(): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'getSuitablePersonalChats',
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 加载直接消息聊天主题（管理员）
   * @param chat_id 频道直聊 ID
   * @param limit 最大数量
   */
  loadDirectMessagesChatTopics(chat_id: number, limit: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'loadDirectMessagesChatTopics',
      'chat_id': chat_id,
      'limit': limit,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取直接消息主题
   * @param chat_id 频道直聊 ID
   * @param topic_id 主题 ID
   */
  getDirectMessagesChatTopic(chat_id: number, topic_id: number): Promise<DirectMessagesChatTopic> {
    const params: Record<string, Object> = {
      '@type': 'getDirectMessagesChatTopic',
      'chat_id': chat_id,
      'topic_id': topic_id,
    };
    return this.client.execute<DirectMessagesChatTopic>(params);
  }

  /**
   * 获取直接消息主题历史
   * @param chat_id 频道直聊 ID
   * @param topic_id 主题 ID
   * @param from_message_id 起始消息 ID
   * @param offset 偏移
   * @param limit 数量
   */
  getDirectMessagesChatTopicHistory(
    chat_id: number,
    topic_id: number,
    from_message_id: number,
    offset: number,
    limit: number
  ): Promise<Messages> {
    const params: Record<string, Object> = {
      '@type': 'getDirectMessagesChatTopicHistory',
      'chat_id': chat_id,
      'topic_id': topic_id,
      'from_message_id': from_message_id,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<Messages>(params);
  }

  /**
   * 按日期获取直接消息主题中的最后一条消息
   * @param chat_id 频道直聊 ID
   * @param topic_id 主题 ID
   * @param date 日期时间戳
   */
  getDirectMessagesChatTopicMessageByDate(chat_id: number, topic_id: number, date: number): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'getDirectMessagesChatTopicMessageByDate',
      'chat_id': chat_id,
      'topic_id': topic_id,
      'date': date,
    };
    return this.client.execute<Message>(params);
  }

  /**
   * 删除直接消息主题中的所有消息
   * @param chat_id 频道直聊 ID
   * @param topic_id 主题 ID
   */
  deleteDirectMessagesChatTopicHistory(chat_id: number, topic_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteDirectMessagesChatTopicHistory',
      'chat_id': chat_id,
      'topic_id': topic_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 按日期删除直接消息主题中的消息
   * @param chat_id 频道直聊 ID
   * @param topic_id 主题 ID
   * @param min_date 最小日期
   * @param max_date 最大日期
   */
  deleteDirectMessagesChatTopicMessagesByDate(
    chat_id: number,
    topic_id: number,
    min_date: number,
    max_date: number
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteDirectMessagesChatTopicMessagesByDate',
      'chat_id': chat_id,
      'topic_id': topic_id,
      'min_date': min_date,
      'max_date': max_date,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置直接消息主题的未读标记
   * @param chat_id 频道直聊 ID
   * @param topic_id 主题 ID
   * @param is_marked_as_unread 是否标记为未读
   */
  setDirectMessagesChatTopicIsMarkedAsUnread(chat_id: number, topic_id: number,
    is_marked_as_unread: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setDirectMessagesChatTopicIsMarkedAsUnread',
      'chat_id': chat_id,
      'topic_id': topic_id,
      'is_marked_as_unread': is_marked_as_unread,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 取消固定直接消息主题中的所有消息
   * @param chat_id 频道直聊 ID
   * @param topic_id 主题 ID
   */
  unpinAllDirectMessagesChatTopicMessages(chat_id: number, topic_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'unpinAllDirectMessagesChatTopicMessages',
      'chat_id': chat_id,
      'topic_id': topic_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 将直接消息主题中所有未读反应标记为已读
   * @param chat_id 频道直聊 ID
   * @param topic_id 主题 ID
   */
  readAllDirectMessagesChatTopicReactions(chat_id: number, topic_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'readAllDirectMessagesChatTopicReactions',
      'chat_id': chat_id,
      'topic_id': topic_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取直接消息主题的收入（星币）
   * @param chat_id 频道直聊 ID
   * @param topic_id 主题 ID
   */
  getDirectMessagesChatTopicRevenue(chat_id: number, topic_id: number): Promise<number> {
    const params: Record<string, Object> = {
      '@type': 'getDirectMessagesChatTopicRevenue',
      'chat_id': chat_id,
      'topic_id': topic_id,
    };
    return this.client.execute<number>(params);
  }

  /**
   * 切换是否允许向直接消息主题发送免费消息
   * @param chat_id 频道直聊 ID
   * @param topic_id 主题 ID
   * @param can_send_unpaid_messages 是否允许
   * @param refund_payments 是否退款
   */
  toggleDirectMessagesChatTopicCanSendUnpaidMessages(
    chat_id: number,
    topic_id: number,
    can_send_unpaid_messages: boolean,
    refund_payments: boolean
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleDirectMessagesChatTopicCanSendUnpaidMessages',
      'chat_id': chat_id,
      'topic_id': topic_id,
      'can_send_unpaid_messages': can_send_unpaid_messages,
      'refund_payments': refund_payments,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 加载更多“已保存消息”主题
   * @param limit 最大数量
   */
  loadSavedMessagesTopics(limit: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'loadSavedMessagesTopics',
      'limit': limit,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取“已保存消息”主题历史
   * @param saved_messages_topic_id 主题 ID
   * @param from_message_id 起始消息 ID
   * @param offset 偏移
   * @param limit 数量
   */
  getSavedMessagesTopicHistory(
    saved_messages_topic_id: number,
    from_message_id: number,
    offset: number,
    limit: number
  ): Promise<Messages> {
    const params: Record<string, Object> = {
      '@type': 'getSavedMessagesTopicHistory',
      'saved_messages_topic_id': saved_messages_topic_id,
      'from_message_id': from_message_id,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<Messages>(params);
  }

  /**
   * 按日期获取“已保存消息”主题中的最后一条消息
   * @param saved_messages_topic_id 主题 ID
   * @param date 日期时间戳
   */
  getSavedMessagesTopicMessageByDate(saved_messages_topic_id: number, date: number): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'getSavedMessagesTopicMessageByDate',
      'saved_messages_topic_id': saved_messages_topic_id,
      'date': date,
    };
    return this.client.execute<Message>(params);
  }

  /**
   * 删除“已保存消息”主题中的所有消息
   * @param saved_messages_topic_id 主题 ID
   */
  deleteSavedMessagesTopicHistory(saved_messages_topic_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteSavedMessagesTopicHistory',
      'saved_messages_topic_id': saved_messages_topic_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 按日期删除“已保存消息”主题中的消息
   * @param saved_messages_topic_id 主题 ID
   * @param min_date 最小日期
   * @param max_date 最大日期
   */
  deleteSavedMessagesTopicMessagesByDate(
    saved_messages_topic_id: number,
    min_date: number,
    max_date: number
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteSavedMessagesTopicMessagesByDate',
      'saved_messages_topic_id': saved_messages_topic_id,
      'min_date': min_date,
      'max_date': max_date,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 固定/取消固定“已保存消息”主题
   * @param saved_messages_topic_id 主题 ID
   * @param is_pinned 是否固定
   */
  toggleSavedMessagesTopicIsPinned(saved_messages_topic_id: number, is_pinned: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleSavedMessagesTopicIsPinned',
      'saved_messages_topic_id': saved_messages_topic_id,
      'is_pinned': is_pinned,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置固定主题的顺序
   * @param saved_messages_topic_ids 主题 ID 列表（按新顺序）
   */
  setPinnedSavedMessagesTopics(saved_messages_topic_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setPinnedSavedMessagesTopics',
      'saved_messages_topic_ids': saved_messages_topic_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取与用户的公共群组
   * @param user_id 用户 ID
   * @param offset_chat_id 偏移聊天 ID
   * @param limit 最大数量
   */
  getGroupsInCommon(user_id: number, offset_chat_id: number, limit: number): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'getGroupsInCommon',
      'user_id': user_id,
      'offset_chat_id': offset_chat_id,
      'limit': limit,
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 获取聊天历史
   * @param chat_id 聊天 ID
   * @param from_message_id 起始消息 ID
   * @param offset 偏移
   * @param limit 数量
   * @param only_local 是否仅本地
   */
  getChatHistory(
    chat_id: number,
    from_message_id: number,
    offset: number,
    limit: number,
    only_local: boolean
  ): Promise<Messages> {
    const params: Record<string, Object> = {
      '@type': 'getChatHistory',
      'chat_id': chat_id,
      'from_message_id': from_message_id,
      'offset': offset,
      'limit': limit,
      'only_local': only_local,
    };
    return this.client.execute<Messages>(params);
  }

  /**
   * 获取消息线程历史
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param from_message_id 起始消息 ID
   * @param offset 偏移
   * @param limit 数量
   */
  getMessageThreadHistory(
    chat_id: number,
    message_id: number,
    from_message_id: number,
    offset: number,
    limit: number
  ): Promise<Messages> {
    const params: Record<string, Object> = {
      '@type': 'getMessageThreadHistory',
      'chat_id': chat_id,
      'message_id': message_id,
      'from_message_id': from_message_id,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<Messages>(params);
  }

  /**
   * 删除聊天历史
   * @param chat_id 聊天 ID
   * @param remove_from_chat_list 是否从列表移除
   * @param revoke 是否也为所有人删除
   */
  deleteChatHistory(chat_id: number, remove_from_chat_list: boolean, revoke: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteChatHistory',
      'chat_id': chat_id,
      'remove_from_chat_list': remove_from_chat_list,
      'revoke': revoke,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 删除聊天
   * @param chat_id 聊天 ID
   */
  deleteChat(chat_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteChat',
      'chat_id': chat_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 在聊天中搜索消息
   * @param chat_id 聊天 ID
   * @param topic_id 主题 ID
   * @param query 查询字符串
   * @param sender_id 发送者 ID
   * @param from_message_id 起始消息 ID
   * @param offset 偏移
   * @param limit 数量
   * @param filter 过滤器
   */
  searchChatMessages(
    chat_id: number,
    topic_id: MessageTopic$Input | null,
    query: string,
    sender_id: MessageSender | null,
    from_message_id: number,
    offset: number,
    limit: number,
    filter: SearchMessagesFilter$Input | null
  ): Promise<FoundChatMessages> {
    const defaultTopicId: Record<string, Object> = { '@type': 'messageTopicThread', "message_thread_id": 0 };
    const defaultSenderId: Record<string, Object> = { '@type': 'messageSenderUser', "user_id": 0 };
    const defaultFilter: Record<string, Object> = { '@type': 'searchMessagesFilterEmpty' };
    const params: Record<string, Object> = {
      '@type': 'searchChatMessages',
      'chat_id': chat_id,
      // 【关键修复】嵌套对象也必须使用 @type，否则 TDLib 无法解析
      'topic_id': topic_id ?? defaultTopicId,
      'query': query,
      'sender_id': sender_id ?? defaultSenderId,
      'from_message_id': from_message_id,
      'offset': offset,
      'limit': limit,
      'filter': filter ?? defaultFilter,
    };
    return this.client.execute<FoundChatMessages>(params);
  }

  /**
   * 在所有聊天中搜索消息（不含秘密聊天）
   * @param chat_list 聊天列表
   * @param query 查询字符串
   * @param offset 偏移
   * @param limit 数量
   * @param filter 过滤器
   * @param chat_type_filter 聊天类型过滤
   * @param min_date 最小日期
   * @param max_date 最大日期
   */
  searchMessages(
    chat_list: ChatList | null,
    query: string,
    offset: string,
    limit: number,
    filter: SearchMessagesFilter$Input | null,
    chat_type_filter: SearchMessagesChatTypeFilter$Input | null,
    min_date: number,
    max_date: number
  ): Promise<FoundMessages> {
    // 【关键修复】使用具体接口类型和 _ 字段
    const defaultChatList: chatListMain$Input = { _: 'chatListMain' };
    const params: Record<string, Object> = {
      '@type': 'searchMessages',
      'chat_list': chat_list ?? defaultChatList,
      'query': query,
      'offset': offset,
      'limit': limit,
    };
    // 可选参数：仅在非空时添加
    if (filter) {
      params['filter'] = filter;
    }
    if (chat_type_filter) {
      params['chat_type_filter'] = chat_type_filter;
    }
    params['min_date'] = min_date;
    params['max_date'] = max_date;
    return this.client.execute<FoundMessages>(params);
  }

  /**
   * 在秘密聊天中搜索消息
   * @param chat_id 聊天 ID（0 表示所有秘密聊天）
   * @param query 查询字符串
   * @param offset 偏移
   * @param limit 数量
   * @param filter 过滤器
   */
  searchSecretMessages(
    chat_id: number,
    query: string,
    offset: string,
    limit: number,
    filter: SearchMessagesFilter$Input | null
  ): Promise<FoundMessages> {
    const params: Record<string, Object> = {
      '@type': 'searchSecretMessages',
      'chat_id': chat_id,
      'query': query,
      'offset': offset,
      'limit': limit,
    };
    // 可选参数：仅在非空时添加
    if (filter) {
      params['filter'] = filter;
    }
    return this.client.execute<FoundMessages>(params);
  }

  /**
   * 在“已保存消息”中搜索带标签的消息
   * @param saved_messages_topic_id 主题 ID（0 表示整个已保存消息）
   * @param tag 标签（反应类型）
   * @param query 查询字符串
   * @param from_message_id 起始消息 ID
   * @param offset 偏移
   * @param limit 数量
   */
  searchSavedMessages(
    saved_messages_topic_id: number,
    tag: ReactionType | null,
    query: string,
    from_message_id: number,
    offset: number,
    limit: number
  ): Promise<FoundChatMessages> {
    const params: Record<string, Object> = {
      '@type': 'searchSavedMessages',
      'saved_messages_topic_id': saved_messages_topic_id,
      'query': query,
      'from_message_id': from_message_id,
      'offset': offset,
      'limit': limit,
    };
    // 可选参数：仅在非空时添加
    if (tag) {
      params['tag'] = tag;
    }
    return this.client.execute<FoundChatMessages>(params);
  }

  /**
   * 搜索通话消息
   * @param offset 偏移
   * @param limit 数量
   * @param only_missed 是否仅未接
   */
  searchCallMessages(offset: string, limit: number, only_missed: boolean): Promise<FoundMessages> {
    const params: Record<string, Object> = {
      '@type': 'searchCallMessages',
      'offset': offset,
      'limit': limit,
      'only_missed': only_missed,
    };
    return this.client.execute<FoundMessages>(params);
  }

  /**
   * 搜索外发文档消息
   * @param query 查询字符串
   * @param limit 数量
   */
  searchOutgoingDocumentMessages(query: string, limit: number): Promise<FoundMessages> {
    const params: Record<string, Object> = {
      '@type': 'searchOutgoingDocumentMessages',
      'query': query,
      'limit': limit,
    };
    return this.client.execute<FoundMessages>(params);
  }

  /**
   * 获取公开帖子搜索限制
   * @param query 查询字符串
   */
  getPublicPostSearchLimits(query: string): Promise<PublicPostSearchLimits> {
    const params: Record<string, Object> = {
      '@type': 'getPublicPostSearchLimits',
      'query': query,
    };
    return this.client.execute<PublicPostSearchLimits>(params);
  }

  /**
   * 搜索公开帖子
   * @param query 查询字符串
   * @param offset 偏移
   * @param limit 数量
   * @param star_count 星币数量（付费搜索）
   */
  searchPublicPosts(query: string, offset: string, limit: number, star_count: number): Promise<FoundPublicPosts> {
    const params: Record<string, Object> = {
      '@type': 'searchPublicPosts',
      'query': query,
      'offset': offset,
      'limit': limit,
      'star_count': star_count,
    };
    return this.client.execute<FoundPublicPosts>(params);
  }

  /**
   * 按标签搜索公开消息
   * @param tag 标签（#话题或$货币）
   * @param offset 偏移
   * @param limit 数量
   */
  searchPublicMessagesByTag(tag: string, offset: string, limit: number): Promise<FoundMessages> {
    const params: Record<string, Object> = {
      '@type': 'searchPublicMessagesByTag',
      'tag': tag,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<FoundMessages>(params);
  }

  /**
   * 按标签搜索公开故事
   * @param story_poster_chat_id 故事发布者 ID（0 表示所有）
   * @param tag 标签
   * @param offset 偏移
   * @param limit 数量
   */
  searchPublicStoriesByTag(
    story_poster_chat_id: number,
    tag: string,
    offset: string,
    limit: number
  ): Promise<FoundStories> {
    const params: Record<string, Object> = {
      '@type': 'searchPublicStoriesByTag',
      'story_poster_chat_id': story_poster_chat_id,
      'tag': tag,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<FoundStories>(params);
  }

  /**
   * 按地址位置搜索公开故事
   * @param address 地址
   * @param offset 偏移
   * @param limit 数量
   */
  searchPublicStoriesByLocation(address: locationAddress, offset: string, limit: number): Promise<FoundStories> {
    const params: Record<string, Object> = {
      '@type': 'searchPublicStoriesByLocation',
      'address': address,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<FoundStories>(params);
  }

  /**
   * 按场所搜索公开故事
   * @param venue_provider 场所提供者
   * @param venue_id 场所 ID
   * @param offset 偏移
   * @param limit 数量
   */
  searchPublicStoriesByVenue(
    venue_provider: string,
    venue_id: string,
    offset: string,
    limit: number
  ): Promise<FoundStories> {
    const params: Record<string, Object> = {
      '@type': 'searchPublicStoriesByVenue',
      'venue_provider': venue_provider,
      'venue_id': venue_id,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<FoundStories>(params);
  }

  /**
   * 获取最近搜索过的标签
   * @param tag_prefix 标签前缀
   * @param limit 最大数量
   */
  getSearchedForTags(tag_prefix: string, limit: number): Promise<string[]> {
    const params: Record<string, Object> = {
      '@type': 'getSearchedForTags',
      'tag_prefix': tag_prefix,
      'limit': limit,
    };
    return this.client.execute<string[]>(params);
  }

  /**
   * 移除搜索过的标签
   * @param tag 标签
   */
  removeSearchedForTag(tag: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeSearchedForTag',
      'tag': tag,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 清除搜索过的标签
   * @param clear_cashtags 是否清除货币标签
   */
  clearSearchedForTags(clear_cashtags: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'clearSearchedForTags',
      'clear_cashtags': clear_cashtags,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 删除所有通话消息
   * @param revoke 是否为所有人删除
   */
  deleteAllCallMessages(revoke: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteAllCallMessages',
      'revoke': revoke,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 搜索聊天中的最近位置消息
   * @param chat_id 聊天 ID
   * @param limit 最大数量
   */
  searchChatRecentLocationMessages(chat_id: number, limit: number): Promise<Messages> {
    const params: Record<string, Object> = {
      '@type': 'searchChatRecentLocationMessages',
      'chat_id': chat_id,
      'limit': limit,
    };
    return this.client.execute<Messages>(params);
  }

  /**
   * 按日期获取聊天中的消息
   * @param chat_id 聊天 ID
   * @param date 日期时间戳
   */
  getChatMessageByDate(chat_id: number, date: number): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'getChatMessageByDate',
      'chat_id': chat_id,
      'date': date,
    };
    return this.client.execute<Message>(params);
  }

  /**
   * 获取聊天中稀疏消息位置
   * @param chat_id 聊天 ID
   * @param filter 过滤器
   * @param from_message_id 起始消息 ID
   * @param limit 数量
   * @param saved_messages_topic_id 已保存消息主题 ID
   */
  getChatSparseMessagePositions(
    chat_id: number,
    filter: SearchMessagesFilter$Input,
    from_message_id: number,
    limit: number,
    saved_messages_topic_id: number
  ): Promise<MessagePositions> {
    const params: Record<string, Object> = {
      '@type': 'getChatSparseMessagePositions',
      'chat_id': chat_id,
      'filter': filter,
      'from_message_id': from_message_id,
      'limit': limit,
      'saved_messages_topic_id': saved_messages_topic_id,
    };
    return this.client.execute<MessagePositions>(params);
  }

  /**
   * 获取聊天消息日历
   * @param chat_id 聊天 ID
   * @param topic_id 主题 ID
   * @param filter 过滤器
   * @param from_message_id 起始消息 ID
   */
  getChatMessageCalendar(
    chat_id: number,
    topic_id: MessageTopic | null,
    filter: SearchMessagesFilter$Input,
    from_message_id: number
  ): Promise<MessageCalendar> {
    const params: Record<string, Object> = {
      '@type': 'getChatMessageCalendar',
      'chat_id': chat_id,
      'topic_id': topic_id || ({} as MessageTopic),
      'filter': filter,
      'from_message_id': from_message_id,
    };
    return this.client.execute<MessageCalendar>(params);
  }

  /**
   * 获取聊天消息数量
   * @param chat_id 聊天 ID
   * @param topic_id 主题 ID
   * @param filter 过滤器
   * @param return_local 是否仅本地
   */
  getChatMessageCount(
    chat_id: number,
    topic_id: MessageTopic | null,
    filter: SearchMessagesFilter$Input,
    return_local: boolean
  ): Promise<number> {
    const params: Record<string, Object> = {
      '@type': 'getChatMessageCount',
      'chat_id': chat_id,
      'topic_id': topic_id || ({} as MessageTopic),
      'filter': filter,
      'return_local': return_local,
    };
    return this.client.execute<number>(params);
  }

  /**
   * 获取消息在聊天中的位置（按过滤器）
   * @param chat_id 聊天 ID
   * @param topic_id 主题 ID
   * @param filter 过滤器
   * @param message_id 消息 ID
   */
  getChatMessagePosition(
    chat_id: number,
    topic_id: MessageTopic | null,
    filter: SearchMessagesFilter$Input,
    message_id: number
  ): Promise<number> {
    const params: Record<string, Object> = {
      '@type': 'getChatMessagePosition',
      'chat_id': chat_id,
      'topic_id': topic_id || ({} as MessageTopic),
      'filter': filter,
      'message_id': message_id,
    };
    return this.client.execute<number>(params);
  }

  /**
   * 获取聊天中已计划的消息
   * @param chat_id 聊天 ID
   */
  getChatScheduledMessages(chat_id: number): Promise<Messages> {
    const params: Record<string, Object> = {
      '@type': 'getChatScheduledMessages',
      'chat_id': chat_id,
    };
    return this.client.execute<Messages>(params);
  }

  /**
   * 获取赞助消息
   * @param chat_id 聊天 ID
   */
  getChatSponsoredMessages(chat_id: number): Promise<SponsoredMessages> {
    const params: Record<string, Object> = {
      '@type': 'getChatSponsoredMessages',
      'chat_id': chat_id,
    };
    return this.client.execute<SponsoredMessages>(params);
  }

  /**
   * 点击赞助消息
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param is_media_click 是否点击媒体
   * @param from_fullscreen 是否全屏点击
   */
  clickChatSponsoredMessage(
    chat_id: number,
    message_id: number,
    is_media_click: boolean,
    from_fullscreen: boolean
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'clickChatSponsoredMessage',
      'chat_id': chat_id,
      'message_id': message_id,
      'is_media_click': is_media_click,
      'from_fullscreen': from_fullscreen,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 举报赞助消息
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param option_id 选项 ID
   */
  reportChatSponsoredMessage(chat_id: number, message_id: number,
    option_id: Uint8Array): Promise<ReportSponsoredResult> {
    const params: Record<string, Object> = {
      '@type': 'reportChatSponsoredMessage',
      'chat_id': chat_id,
      'message_id': message_id,
      'option_id': option_id,
    };
    return this.client.execute<ReportSponsoredResult>(params);
  }

  /**
   * 获取搜索赞助聊天
   * @param query 查询字符串
   */
  getSearchSponsoredChats(query: string): Promise<SponsoredChats> {
    const params: Record<string, Object> = {
      '@type': 'getSearchSponsoredChats',
      'query': query,
    };
    return this.client.execute<SponsoredChats>(params);
  }

  /**
   * 标记赞助聊天已查看
   * @param sponsored_chat_unique_id 唯一 ID
   */
  viewSponsoredChat(sponsored_chat_unique_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'viewSponsoredChat',
      'sponsored_chat_unique_id': sponsored_chat_unique_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 打开赞助聊天
   * @param sponsored_chat_unique_id 唯一 ID
   */
  openSponsoredChat(sponsored_chat_unique_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'openSponsoredChat',
      'sponsored_chat_unique_id': sponsored_chat_unique_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 举报赞助聊天
   * @param sponsored_chat_unique_id 唯一 ID
   * @param option_id 选项 ID
   */
  reportSponsoredChat(sponsored_chat_unique_id: number, option_id: Uint8Array): Promise<ReportSponsoredResult> {
    const params: Record<string, Object> = {
      '@type': 'reportSponsoredChat',
      'sponsored_chat_unique_id': sponsored_chat_unique_id,
      'option_id': option_id,
    };
    return this.client.execute<ReportSponsoredResult>(params);
  }

  /**
   * 获取视频消息广告
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   */
  getVideoMessageAdvertisements(chat_id: number, message_id: number): Promise<VideoMessageAdvertisements> {
    const params: Record<string, Object> = {
      '@type': 'getVideoMessageAdvertisements',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<VideoMessageAdvertisements>(params);
  }

  /**
   * 查看视频消息广告
   * @param advertisement_unique_id 唯一 ID
   */
  viewVideoMessageAdvertisement(advertisement_unique_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'viewVideoMessageAdvertisement',
      'advertisement_unique_id': advertisement_unique_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 点击视频消息广告
   * @param advertisement_unique_id 唯一 ID
   */
  clickVideoMessageAdvertisement(advertisement_unique_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'clickVideoMessageAdvertisement',
      'advertisement_unique_id': advertisement_unique_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 举报视频消息广告
   * @param advertisement_unique_id 唯一 ID
   * @param option_id 选项 ID
   */
  reportVideoMessageAdvertisement(advertisement_unique_id: number,
    option_id: Uint8Array): Promise<ReportSponsoredResult> {
    const params: Record<string, Object> = {
      '@type': 'reportVideoMessageAdvertisement',
      'advertisement_unique_id': advertisement_unique_id,
      'option_id': option_id,
    };
    return this.client.execute<ReportSponsoredResult>(params);
  }

  /**
   * 移除通知
   * @param notification_group_id 通知组 ID
   * @param notification_id 通知 ID
   */
  removeNotification(notification_group_id: number, notification_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeNotification',
      'notification_group_id': notification_group_id,
      'notification_id': notification_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 移除通知组
   * @param notification_group_id 通知组 ID
   * @param max_notification_id 最大通知 ID
   */
  removeNotificationGroup(notification_group_id: number, max_notification_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeNotificationGroup',
      'notification_group_id': notification_group_id,
      'max_notification_id': max_notification_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取消息链接
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param media_timestamp 媒体时间戳
   * @param for_album 是否用于整个相册
   * @param in_message_thread 是否在消息线程中
   */
  getMessageLink(
    chat_id: number,
    message_id: number,
    media_timestamp: number,
    for_album: boolean,
    in_message_thread: boolean
  ): Promise<MessageLink> {
    const params: Record<string, Object> = {
      '@type': 'getMessageLink',
      'chat_id': chat_id,
      'message_id': message_id,
      'media_timestamp': media_timestamp,
      'for_album': for_album,
      'in_message_thread': in_message_thread,
    };
    return this.client.execute<MessageLink>(params);
  }

  /**
   * 获取消息嵌入代码
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param for_album 是否用于整个相册
   */
  getMessageEmbeddingCode(chat_id: number, message_id: number, for_album: boolean): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getMessageEmbeddingCode',
      'chat_id': chat_id,
      'message_id': message_id,
      'for_album': for_album,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 获取消息链接信息
   * @param url 链接
   */
  getMessageLinkInfo(url: string): Promise<MessageLinkInfo> {
    const params: Record<string, Object> = {
      '@type': 'getMessageLinkInfo',
      'url': url,
    };
    return this.client.execute<MessageLinkInfo>(params);
  }

  /**
   * 翻译文本
   * @param text 文本
   * @param to_language_code 目标语言代码
   */
  translateText(text: FormattedText, to_language_code: string): Promise<FormattedText> {
    const params: Record<string, Object> = {
      '@type': 'translateText',
      'text': text,
      'to_language_code': to_language_code,
    };
    return this.client.execute<FormattedText>(params);
  }

  /**
   * 翻译消息内容
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param to_language_code 目标语言代码
   */
  translateMessageText(chat_id: number, message_id: number, to_language_code: string): Promise<FormattedText> {
    const params: Record<string, Object> = {
      '@type': 'translateMessageText',
      'chat_id': chat_id,
      'message_id': message_id,
      'to_language_code': to_language_code,
    };
    return this.client.execute<FormattedText>(params);
  }

  /**
   * 总结消息
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param translate_to_language_code 翻译语言代码
   */
  summarizeMessage(chat_id: number, message_id: number, translate_to_language_code: string): Promise<FormattedText> {
    const params: Record<string, Object> = {
      '@type': 'summarizeMessage',
      'chat_id': chat_id,
      'message_id': message_id,
      'translate_to_language_code': translate_to_language_code,
    };
    return this.client.execute<FormattedText>(params);
  }

  /**
   * 识别语音
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   */
  recognizeSpeech(chat_id: number, message_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'recognizeSpeech',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 评价语音识别结果
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param is_good 是否识别良好
   */
  rateSpeechRecognition(chat_id: number, message_id: number, is_good: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'rateSpeechRecognition',
      'chat_id': chat_id,
      'message_id': message_id,
      'is_good': is_good,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取聊天中可用的消息发送者
   * @param chat_id 聊天 ID
   */
  getChatAvailableMessageSenders(chat_id: number): Promise<ChatMessageSenders> {
    const params: Record<string, Object> = {
      '@type': 'getChatAvailableMessageSenders',
      'chat_id': chat_id,
    };
    return this.client.execute<ChatMessageSenders>(params);
  }

  /**
   * 设置聊天消息发送者
   * @param chat_id 聊天 ID
   * @param message_sender_id 发送者 ID
   */
  setChatMessageSender(chat_id: number, message_sender_id: MessageSender): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatMessageSender',
      'chat_id': chat_id,
      'message_sender_id': message_sender_id,
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 消息操作 ====================

  /**
   * 发送消息
   * @param chat_id 聊天 ID
   * @param topic_id 主题 ID
   * @param reply_to 回复信息
   * @param options 发送选项
   * @param reply_markup 回复标记
   * @param input_message_content 消息内容
   */
  sendMessage(
    chat_id: number,
    topic_id: MessageTopic | null,
    reply_to: InputMessageReplyTo | null,
    options: messageSendOptions$Input | null,
    reply_markup: ReplyMarkup | null,
    input_message_content: Object
  ): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'sendMessage',
      'chat_id': chat_id,
      'input_message_content': input_message_content,
    };
    if (topic_id !== null) {
      params['topic_id'] = topic_id;
    }
    if (reply_to !== null) {
      params['reply_to'] = reply_to;
    }
    if (options !== null) {
      params['options'] = options;
    }
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    return this.client.execute<Message>(params);
  }

  /**
   * 发送消息相册
   * @param chat_id 聊天 ID
   * @param topic_id 主题 ID
   * @param reply_to 回复信息
   * @param options 发送选项
   * @param input_message_contents 消息内容列表
   */
  sendMessageAlbum(
    chat_id: number,
    topic_id: MessageTopic | null,
    reply_to: InputMessageReplyTo | null,
    options: messageSendOptions$Input | null,
    input_message_contents: InputMessageContent[]
  ): Promise<Messages> {
    const params: Record<string, Object> = {
      '@type': 'sendMessageAlbum',
      'chat_id': chat_id,
      'input_message_contents': input_message_contents,
    };
    if (topic_id !== null) {
      params['topic_id'] = topic_id;
    }
    if (reply_to !== null) {
      params['reply_to'] = reply_to;
    }
    if (options !== null) {
      params['options'] = options;
    }
    return this.client.execute<Messages>(params);
  }

  /**
   * 发送 Bot 启动消息
   * @param bot_user_id Bot ID
   * @param chat_id 聊天 ID
   * @param parameter 启动参数
   */
  sendBotStartMessage(bot_user_id: number, chat_id: number, parameter: string): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'sendBotStartMessage',
      'bot_user_id': bot_user_id,
      'chat_id': chat_id,
      'parameter': parameter,
    };
    return this.client.execute<Message>(params);
  }

  /**
   * 发送内联查询结果消息
   * @param chat_id 聊天 ID
   * @param topic_id 主题 ID
   * @param reply_to 回复信息
   * @param options 发送选项
   * @param query_id 查询 ID
   * @param result_id 结果 ID
   * @param hide_via_bot 是否隐藏通过 Bot
   */
  sendInlineQueryResultMessage(
    chat_id: number,
    topic_id: MessageTopic | null,
    reply_to: InputMessageReplyTo | null,
    options: messageSendOptions$Input | null,
    query_id: number,
    result_id: string,
    hide_via_bot: boolean
  ): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'sendInlineQueryResultMessage',
      'chat_id': chat_id,
      'query_id': query_id,
      'result_id': result_id,
      'hide_via_bot': hide_via_bot,
    };
    if (topic_id !== null) {
      params['topic_id'] = topic_id;
    }
    if (reply_to !== null) {
      params['reply_to'] = reply_to;
    }
    if (options !== null) {
      params['options'] = options;
    }
    return this.client.execute<Message>(params);
  }

  /**
   * 转发消息
   * @param chat_id 目标聊天 ID
   * @param topic_id 主题 ID
   * @param from_chat_id 来源聊天 ID
   * @param message_ids 消息 ID 列表
   * @param options 发送选项
   * @param send_copy 是否发送副本
   * @param remove_caption 是否移除标题
   */
  forwardMessages(
    chat_id: number,
    topic_id: MessageTopic | null,
    from_chat_id: number,
    message_ids: number[],
    options: messageSendOptions$Input | null,
    send_copy: boolean,
    remove_caption: boolean
  ): Promise<Messages> {
    const params: Record<string, Object> = {
      '@type': 'forwardMessages',
      'chat_id': chat_id,
      'from_chat_id': from_chat_id,
      'message_ids': message_ids,
      'send_copy': send_copy,
      'remove_caption': remove_caption,
    };
    if (topic_id !== null) {
      params['topic_id'] = topic_id;
    }
    if (options !== null) {
      params['options'] = options;
    }
    return this.client.execute<Messages>(params);
  }

  /**
   * 发送快速回复快捷方式中的消息
   * @param chat_id 聊天 ID
   * @param shortcut_id 快捷方式 ID
   * @param sending_id 发送 ID
   */
  sendQuickReplyShortcutMessages(chat_id: number, shortcut_id: number, sending_id: number): Promise<Messages> {
    const params: Record<string, Object> = {
      '@type': 'sendQuickReplyShortcutMessages',
      'chat_id': chat_id,
      'shortcut_id': shortcut_id,
      'sending_id': sending_id,
    };
    return this.client.execute<Messages>(params);
  }

  /**
   * 重新发送失败的消息
   * @param chat_id 聊天 ID
   * @param message_ids 消息 ID 列表
   * @param quote 新引用
   * @param paid_message_star_count 付费星币数量
   */
  resendMessages(
    chat_id: number,
    message_ids: number[],
    quote: inputTextQuote$Input | null,
    paid_message_star_count: number
  ): Promise<Messages> {
    const params: Record<string, Object> = {
      '@type': 'resendMessages',
      'chat_id': chat_id,
      'message_ids': message_ids,
      'paid_message_star_count': paid_message_star_count,
    };
    if (quote !== null) {
      params['quote'] = quote;
    }
    return this.client.execute<Messages>(params);
  }

  /**
   * 添加本地消息
   * @param chat_id 聊天 ID
   * @param sender_id 发送者 ID
   * @param reply_to 回复信息
   * @param disable_notification 是否禁用通知
   * @param input_message_content 消息内容
   */
  addLocalMessage(
    chat_id: number,
    sender_id: MessageSender,
    reply_to: InputMessageReplyTo | null,
    disable_notification: boolean,
    input_message_content: InputMessageContent
  ): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'addLocalMessage',
      'chat_id': chat_id,
      'sender_id': sender_id,
      'disable_notification': disable_notification,
      'input_message_content': input_message_content,
    };
    if (reply_to !== null) {
      params['reply_to'] = reply_to;
    }
    return this.client.execute<Message>(params);
  }

  /**
   * 删除消息
   * @param chat_id 聊天 ID
   * @param message_ids 消息 ID 列表
   * @param revoke 是否为所有人删除
   */
  deleteMessages(chat_id: number, message_ids: number[], revoke: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteMessages',
      'chat_id': chat_id,
      'message_ids': message_ids,
      'revoke': revoke,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 按发送者删除聊天中的消息
   * @param chat_id 聊天 ID
   * @param sender_id 发送者 ID
   */
  deleteChatMessagesBySender(chat_id: number, sender_id: MessageSender): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteChatMessagesBySender',
      'chat_id': chat_id,
      'sender_id': sender_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 按日期删除聊天中的消息
   * @param chat_id 聊天 ID
   * @param min_date 最小日期
   * @param max_date 最大日期
   * @param revoke 是否为所有人删除
   */
  deleteChatMessagesByDate(chat_id: number, min_date: number, max_date: number, revoke: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteChatMessagesByDate',
      'chat_id': chat_id,
      'min_date': min_date,
      'max_date': max_date,
      'revoke': revoke,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 编辑消息文本
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param reply_markup 回复标记
   * @param input_message_content 新内容（必须是 inputMessageText）
   */
  editMessageText(
    chat_id: number,
    message_id: number,
    reply_markup: ReplyMarkup | null,
    input_message_content: InputMessageContent
  ): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'editMessageText',
      'chat_id': chat_id,
      'message_id': message_id,
      'input_message_content': input_message_content,
    };
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    return this.client.execute<Message>(params);
  }

  /**
   * 编辑实时位置消息
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param reply_markup 回复标记
   * @param location 新位置（null 表示停止共享）
   * @param live_period 新有效期（秒）
   * @param heading 方向
   * @param proximity_alert_radius 接近警报半径
   */
  editMessageLiveLocation(
    chat_id: number,
    message_id: number,
    reply_markup: ReplyMarkup | null,
    location: location | null,
    live_period: number,
    heading: number,
    proximity_alert_radius: number
  ): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'editMessageLiveLocation',
      'chat_id': chat_id,
      'message_id': message_id,
      'live_period': live_period,
      'heading': heading,
      'proximity_alert_radius': proximity_alert_radius,
    };
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    if (location !== null) {
      params['location'] = location;
    }
    return this.client.execute<Message>(params);
  }

  /**
   * 编辑清单消息
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param reply_markup 回复标记
   * @param checklist 新清单
   */
  editMessageChecklist(
    chat_id: number,
    message_id: number,
    reply_markup: ReplyMarkup | null,
    checklist: inputChecklist
  ): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'editMessageChecklist',
      'chat_id': chat_id,
      'message_id': message_id,
      'checklist': checklist,
    };
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    return this.client.execute<Message>(params);
  }

  /**
   * 编辑消息媒体
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param reply_markup 回复标记
   * @param input_message_content 新内容（动画/音频/文档/照片/视频）
   */
  editMessageMedia(
    chat_id: number,
    message_id: number,
    reply_markup: ReplyMarkup | null,
    input_message_content: InputMessageContent
  ): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'editMessageMedia',
      'chat_id': chat_id,
      'message_id': message_id,
      'input_message_content': input_message_content,
    };
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    return this.client.execute<Message>(params);
  }

  /**
   * 编辑消息标题
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param reply_markup 回复标记
   * @param caption 新标题
   * @param show_caption_above_media 是否显示在媒体上方
   */
  editMessageCaption(
    chat_id: number,
    message_id: number,
    reply_markup: ReplyMarkup | null,
    caption: FormattedText | null,
    show_caption_above_media: boolean
  ): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'editMessageCaption',
      'chat_id': chat_id,
      'message_id': message_id,
      'show_caption_above_media': show_caption_above_media,
    };
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    if (caption !== null) {
      params['caption'] = caption;
    }
    return this.client.execute<Message>(params);
  }

  /**
   * 编辑消息回复标记
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param reply_markup 新回复标记
   */
  editMessageReplyMarkup(chat_id: number, message_id: number, reply_markup: ReplyMarkup | null): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'editMessageReplyMarkup',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    return this.client.execute<Message>(params);
  }

  /**
   * 编辑内联消息文本（仅 Bot）
   * @param inline_message_id 内联消息 ID
   * @param reply_markup 回复标记
   * @param input_message_content 新内容（必须是 inputMessageText）
   */
  editInlineMessageText(
    inline_message_id: string,
    reply_markup: ReplyMarkup | null,
    input_message_content: InputMessageContent
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'editInlineMessageText',
      'inline_message_id': inline_message_id,
      'input_message_content': input_message_content,
    };
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 编辑内联实时位置消息（仅 Bot）
   * @param inline_message_id 内联消息 ID
   * @param reply_markup 回复标记
   * @param location 新位置
   * @param live_period 新有效期
   * @param heading 方向
   * @param proximity_alert_radius 接近警报半径
   */
  editInlineMessageLiveLocation(
    inline_message_id: string,
    reply_markup: ReplyMarkup | null,
    location: location | null,
    live_period: number,
    heading: number,
    proximity_alert_radius: number
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'editInlineMessageLiveLocation',
      'inline_message_id': inline_message_id,
      'live_period': live_period,
      'heading': heading,
      'proximity_alert_radius': proximity_alert_radius,
    };
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    if (location !== null) {
      params['location'] = location;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 编辑内联消息媒体（仅 Bot）
   * @param inline_message_id 内联消息 ID
   * @param reply_markup 回复标记
   * @param input_message_content 新内容（动画/音频/文档/照片/视频）
   */
  editInlineMessageMedia(
    inline_message_id: string,
    reply_markup: ReplyMarkup | null,
    input_message_content: InputMessageContent
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'editInlineMessageMedia',
      'inline_message_id': inline_message_id,
      'input_message_content': input_message_content,
    };
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 编辑内联消息标题（仅 Bot）
   * @param inline_message_id 内联消息 ID
   * @param reply_markup 回复标记
   * @param caption 新标题
   * @param show_caption_above_media 是否显示在媒体上方
   */
  editInlineMessageCaption(
    inline_message_id: string,
    reply_markup: ReplyMarkup | null,
    caption: FormattedText | null,
    show_caption_above_media: boolean
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'editInlineMessageCaption',
      'inline_message_id': inline_message_id,
      'show_caption_above_media': show_caption_above_media,
    };
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    if (caption !== null) {
      params['caption'] = caption;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 编辑内联消息回复标记（仅 Bot）
   * @param inline_message_id 内联消息 ID
   * @param reply_markup 新回复标记
   */
  editInlineMessageReplyMarkup(inline_message_id: string, reply_markup: ReplyMarkup | null): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'editInlineMessageReplyMarkup',
      'inline_message_id': inline_message_id,
    };
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 编辑已计划消息的发送时间
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param scheduling_state 新调度状态
   */
  editMessageSchedulingState(
    chat_id: number,
    message_id: number,
    scheduling_state: MessageSchedulingState | null
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'editMessageSchedulingState',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    if (scheduling_state !== null) {
      params['scheduling_state'] = scheduling_state;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置消息事实核查
   * @param chat_id 聊天 ID（必须是频道）
   * @param message_id 消息 ID
   * @param text 事实核查文本（null 表示移除）
   */
  setMessageFactCheck(chat_id: number, message_id: number, text: FormattedText | null): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setMessageFactCheck',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    if (text !== null) {
      params['text'] = text;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 代表商业账户发送消息（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param chat_id 聊天 ID
   * @param reply_to 回复信息
   * @param disable_notification 是否禁用通知
   * @param protect_content 是否保护内容
   * @param effect_id 效果 ID
   * @param reply_markup 回复标记
   * @param input_message_content 消息内容
   */
  sendBusinessMessage(
    business_connection_id: string,
    chat_id: number,
    reply_to: InputMessageReplyTo | null,
    disable_notification: boolean,
    protect_content: boolean,
    effect_id: number,
    reply_markup: ReplyMarkup | null,
    input_message_content: InputMessageContent
  ): Promise<BusinessMessage> {
    const params: Record<string, Object> = {
      '@type': 'sendBusinessMessage',
      'business_connection_id': business_connection_id,
      'chat_id': chat_id,
      'disable_notification': disable_notification,
      'protect_content': protect_content,
      'effect_id': effect_id,
      'input_message_content': input_message_content,
    };
    if (reply_to !== null) {
      params['reply_to'] = reply_to;
    }
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    return this.client.execute<BusinessMessage>(params);
  }

  /**
   * 代表商业账户发送相册消息（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param chat_id 聊天 ID
   * @param reply_to 回复信息
   * @param disable_notification 是否禁用通知
   * @param protect_content 是否保护内容
   * @param effect_id 效果 ID
   * @param input_message_contents 消息内容列表
   */
  sendBusinessMessageAlbum(
    business_connection_id: string,
    chat_id: number,
    reply_to: InputMessageReplyTo | null,
    disable_notification: boolean,
    protect_content: boolean,
    effect_id: number,
    input_message_contents: InputMessageContent[]
  ): Promise<BusinessMessage> {
    const params: Record<string, Object> = {
      '@type': 'sendBusinessMessageAlbum',
      'business_connection_id': business_connection_id,
      'chat_id': chat_id,
      'disable_notification': disable_notification,
      'protect_content': protect_content,
      'effect_id': effect_id,
      'input_message_contents': input_message_contents,
    };
    if (reply_to !== null) {
      params['reply_to'] = reply_to;
    }
    return this.client.execute<BusinessMessage>(params);
  }

  /**
   * 编辑商业账户消息文本（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param reply_markup 回复标记
   * @param input_message_content 新内容（必须是 inputMessageText）
   */
  editBusinessMessageText(
    business_connection_id: string,
    chat_id: number,
    message_id: number,
    reply_markup: ReplyMarkup | null,
    input_message_content: InputMessageContent
  ): Promise<BusinessMessage> {
    const params: Record<string, Object> = {
      '@type': 'editBusinessMessageText',
      'business_connection_id': business_connection_id,
      'chat_id': chat_id,
      'message_id': message_id,
      'input_message_content': input_message_content,
    };
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    return this.client.execute<BusinessMessage>(params);
  }

  /**
   * 编辑商业账户实时位置消息（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param reply_markup 回复标记
   * @param location 新位置
   * @param live_period 新有效期
   * @param heading 方向
   * @param proximity_alert_radius 接近警报半径
   */
  editBusinessMessageLiveLocation(
    business_connection_id: string,
    chat_id: number,
    message_id: number,
    reply_markup: ReplyMarkup | null,
    location: location | null,
    live_period: number,
    heading: number,
    proximity_alert_radius: number
  ): Promise<BusinessMessage> {
    const params: Record<string, Object> = {
      '@type': 'editBusinessMessageLiveLocation',
      'business_connection_id': business_connection_id,
      'chat_id': chat_id,
      'message_id': message_id,
      'live_period': live_period,
      'heading': heading,
      'proximity_alert_radius': proximity_alert_radius,
    };
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    if (location !== null) {
      params['location'] = location;
    }
    return this.client.execute<BusinessMessage>(params);
  }

  /**
   * 编辑商业账户清单消息（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param reply_markup 回复标记
   * @param checklist 新清单
   */
  editBusinessMessageChecklist(
    business_connection_id: string,
    chat_id: number,
    message_id: number,
    reply_markup: ReplyMarkup | null,
    checklist: inputChecklist
  ): Promise<BusinessMessage> {
    const params: Record<string, Object> = {
      '@type': 'editBusinessMessageChecklist',
      'business_connection_id': business_connection_id,
      'chat_id': chat_id,
      'message_id': message_id,
      'checklist': checklist,
    };
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    return this.client.execute<BusinessMessage>(params);
  }

  /**
   * 编辑商业账户消息媒体（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param reply_markup 回复标记
   * @param input_message_content 新内容
   */
  editBusinessMessageMedia(
    business_connection_id: string,
    chat_id: number,
    message_id: number,
    reply_markup: ReplyMarkup | null,
    input_message_content: InputMessageContent
  ): Promise<BusinessMessage> {
    const params: Record<string, Object> = {
      '@type': 'editBusinessMessageMedia',
      'business_connection_id': business_connection_id,
      'chat_id': chat_id,
      'message_id': message_id,
      'input_message_content': input_message_content,
    };
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    return this.client.execute<BusinessMessage>(params);
  }

  /**
   * 编辑商业账户消息标题（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param reply_markup 回复标记
   * @param caption 新标题
   * @param show_caption_above_media 是否显示在媒体上方
   */
  editBusinessMessageCaption(
    business_connection_id: string,
    chat_id: number,
    message_id: number,
    reply_markup: ReplyMarkup | null,
    caption: FormattedText | null,
    show_caption_above_media: boolean
  ): Promise<BusinessMessage> {
    const params: Record<string, Object> = {
      '@type': 'editBusinessMessageCaption',
      'business_connection_id': business_connection_id,
      'chat_id': chat_id,
      'message_id': message_id,
      'show_caption_above_media': show_caption_above_media,
    };
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    if (caption !== null) {
      params['caption'] = caption;
    }
    return this.client.execute<BusinessMessage>(params);
  }

  /**
   * 编辑商业账户消息回复标记（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param reply_markup 新回复标记
   */
  editBusinessMessageReplyMarkup(
    business_connection_id: string,
    chat_id: number,
    message_id: number,
    reply_markup: ReplyMarkup | null
  ): Promise<BusinessMessage> {
    const params: Record<string, Object> = {
      '@type': 'editBusinessMessageReplyMarkup',
      'business_connection_id': business_connection_id,
      'chat_id': chat_id,
      'message_id': message_id,
    };
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    return this.client.execute<BusinessMessage>(params);
  }

  /**
   * 停止商业账户中的投票（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param reply_markup 新回复标记
   */
  stopBusinessPoll(
    business_connection_id: string,
    chat_id: number,
    message_id: number,
    reply_markup: ReplyMarkup | null
  ): Promise<BusinessMessage> {
    const params: Record<string, Object> = {
      '@type': 'stopBusinessPoll',
      'business_connection_id': business_connection_id,
      'chat_id': chat_id,
      'message_id': message_id,
    };
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    return this.client.execute<BusinessMessage>(params);
  }

  /**
   * 固定/取消固定商业账户消息（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param is_pinned 是否固定
   */
  setBusinessMessageIsPinned(
    business_connection_id: string,
    chat_id: number,
    message_id: number,
    is_pinned: boolean
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setBusinessMessageIsPinned',
      'business_connection_id': business_connection_id,
      'chat_id': chat_id,
      'message_id': message_id,
      'is_pinned': is_pinned,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 阅读商业账户消息（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   */
  readBusinessMessage(business_connection_id: string, chat_id: number, message_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'readBusinessMessage',
      'business_connection_id': business_connection_id,
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 删除商业账户消息（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param message_ids 消息 ID 列表
   */
  deleteBusinessMessages(business_connection_id: string, message_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteBusinessMessages',
      'business_connection_id': business_connection_id,
      'message_ids': message_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 编辑商业账户故事（仅 Bot）
   * @param story_poster_chat_id 发布者聊天 ID
   * @param story_id 故事 ID
   * @param content 新内容
   * @param areas 新区域
   * @param caption 新标题
   * @param privacy_settings 隐私设置
   */
  editBusinessStory(
    story_poster_chat_id: number,
    story_id: number,
    content: StoryContent,
    areas: StoryContent,
    caption: FormattedText,
    privacy_settings: StoryPrivacySettings
  ): Promise<Story> {
    const params: Record<string, Object> = {
      '@type': 'editBusinessStory',
      'story_poster_chat_id': story_poster_chat_id,
      'story_id': story_id,
      'content': content,
      'areas': areas,
      'caption': caption,
      'privacy_settings': privacy_settings,
    };
    return this.client.execute<Story>(params);
  }

  /**
   * 删除商业账户故事（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param story_id 故事 ID
   */
  deleteBusinessStory(business_connection_id: string, story_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteBusinessStory',
      'business_connection_id': business_connection_id,
      'story_id': story_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置商业账户名称（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param first_name 名
   * @param last_name 姓
   */
  setBusinessAccountName(business_connection_id: string, first_name: string, last_name: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setBusinessAccountName',
      'business_connection_id': business_connection_id,
      'first_name': first_name,
      'last_name': last_name,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置商业账户简介（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param bio 简介
   */
  setBusinessAccountBio(business_connection_id: string, bio: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setBusinessAccountBio',
      'business_connection_id': business_connection_id,
      'bio': bio,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置商业账户头像（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param photo 头像
   * @param is_public 是否公开
   */
  setBusinessAccountProfilePhoto(business_connection_id: string, photo: InputChatPhoto$Input,
    is_public: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setBusinessAccountProfilePhoto',
      'business_connection_id': business_connection_id,
      'photo': photo,
      'is_public': is_public,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置商业账户用户名（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param username 用户名
   */
  setBusinessAccountUsername(business_connection_id: string, username: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setBusinessAccountUsername',
      'business_connection_id': business_connection_id,
      'username': username,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置商业账户礼物接收设置（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param settings 礼物设置
   */
  setBusinessAccountGiftSettings(business_connection_id: string, settings: giftSettings): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setBusinessAccountGiftSettings',
      'business_connection_id': business_connection_id,
      'settings': settings,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取商业账户星币数量（仅 Bot）
   * @param business_connection_id 商业连接 ID
   */
  getBusinessAccountStarAmount(business_connection_id: string): Promise<StarAmount> {
    const params: Record<string, Object> = {
      '@type': 'getBusinessAccountStarAmount',
      'business_connection_id': business_connection_id,
    };
    return this.client.execute<StarAmount>(params);
  }

  /**
   * 将星币从商业账户转移到 Bot（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param star_count 星币数量
   */
  transferBusinessAccountStars(business_connection_id: string, star_count: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'transferBusinessAccountStars',
      'business_connection_id': business_connection_id,
      'star_count': star_count,
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 快速回复快捷方式 ====================

  /**
   * 检查快捷方式名称的有效性
   * @param name 名称
   */
  checkQuickReplyShortcutName(name: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'checkQuickReplyShortcutName',
      'name': name,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 加载快速回复快捷方式
   */
  loadQuickReplyShortcuts(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'loadQuickReplyShortcuts',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置快捷方式名称
   * @param shortcut_id 快捷方式 ID
   * @param name 新名称
   */
  setQuickReplyShortcutName(shortcut_id: number, name: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setQuickReplyShortcutName',
      'shortcut_id': shortcut_id,
      'name': name,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 删除快捷方式
   * @param shortcut_id 快捷方式 ID
   */
  deleteQuickReplyShortcut(shortcut_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteQuickReplyShortcut',
      'shortcut_id': shortcut_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 重新排序快捷方式
   * @param shortcut_ids 新顺序的 ID 列表
   */
  reorderQuickReplyShortcuts(shortcut_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'reorderQuickReplyShortcuts',
      'shortcut_ids': shortcut_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 加载快捷方式消息
   * @param shortcut_id 快捷方式 ID
   */
  loadQuickReplyShortcutMessages(shortcut_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'loadQuickReplyShortcutMessages',
      'shortcut_id': shortcut_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 删除快捷方式中的消息
   * @param shortcut_id 快捷方式 ID
   * @param message_ids 消息 ID 列表
   */
  deleteQuickReplyShortcutMessages(shortcut_id: number, message_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteQuickReplyShortcutMessages',
      'shortcut_id': shortcut_id,
      'message_ids': message_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 向快捷方式添加消息
   * @param shortcut_name 快捷方式名称
   * @param reply_to_message_id 回复的消息 ID
   * @param input_message_content 消息内容
   */
  addQuickReplyShortcutMessage(
    shortcut_name: string,
    reply_to_message_id: number,
    input_message_content: InputMessageContent
  ): Promise<QuickReplyMessage> {
    const params: Record<string, Object> = {
      '@type': 'addQuickReplyShortcutMessage',
      'shortcut_name': shortcut_name,
      'reply_to_message_id': reply_to_message_id,
      'input_message_content': input_message_content,
    };
    return this.client.execute<QuickReplyMessage>(params);
  }

  /**
   * 通过内联查询结果添加快捷方式消息
   * @param shortcut_name 快捷方式名称
   * @param reply_to_message_id 回复的消息 ID
   * @param query_id 内联查询 ID
   * @param result_id 结果 ID
   * @param hide_via_bot 是否隐藏 via bot
   */
  addQuickReplyShortcutInlineQueryResultMessage(
    shortcut_name: string,
    reply_to_message_id: number,
    query_id: number,
    result_id: string,
    hide_via_bot: boolean
  ): Promise<QuickReplyMessage> {
    const params: Record<string, Object> = {
      '@type': 'addQuickReplyShortcutInlineQueryResultMessage',
      'shortcut_name': shortcut_name,
      'reply_to_message_id': reply_to_message_id,
      'query_id': query_id,
      'result_id': result_id,
      'hide_via_bot': hide_via_bot,
    };
    return this.client.execute<QuickReplyMessage>(params);
  }

  /**
   * 向快捷方式添加相册消息
   * @param shortcut_name 快捷方式名称
   * @param reply_to_message_id 回复的消息 ID
   * @param input_message_contents 消息内容列表
   */
  addQuickReplyShortcutMessageAlbum(
    shortcut_name: string,
    reply_to_message_id: number,
    input_message_contents: InputMessageContent[]
  ): Promise<QuickReplyMessages> {
    const params: Record<string, Object> = {
      '@type': 'addQuickReplyShortcutMessageAlbum',
      'shortcut_name': shortcut_name,
      'reply_to_message_id': reply_to_message_id,
      'input_message_contents': input_message_contents,
    };
    return this.client.execute<QuickReplyMessages>(params);
  }

  /**
   * 重新添加失败的消息到快捷方式
   * @param shortcut_name 快捷方式名称
   * @param message_ids 消息 ID 列表
   */
  readdQuickReplyShortcutMessages(shortcut_name: string, message_ids: number[]): Promise<QuickReplyMessages> {
    const params: Record<string, Object> = {
      '@type': 'readdQuickReplyShortcutMessages',
      'shortcut_name': shortcut_name,
      'message_ids': message_ids,
    };
    return this.client.execute<QuickReplyMessages>(params);
  }

  /**
   * 编辑快捷方式消息
   * @param shortcut_id 快捷方式 ID
   * @param message_id 消息 ID
   * @param input_message_content 新内容
   */
  editQuickReplyMessage(
    shortcut_id: number,
    message_id: number,
    input_message_content: InputMessageContent
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'editQuickReplyMessage',
      'shortcut_id': shortcut_id,
      'message_id': message_id,
      'input_message_content': input_message_content,
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 论坛主题 ====================

  /**
   * 获取论坛主题默认图标
   */
  getForumTopicDefaultIcons(): Promise<Stickers> {
    const params: Record<string, Object> = {
      '@type': 'getForumTopicDefaultIcons',
    };
    return this.client.execute<Stickers>(params);
  }

  /**
   * 创建论坛主题
   * @param chat_id 聊天 ID
   * @param name 主题名称
   * @param is_name_implicit 是否隐式名称
   * @param icon 图标
   */
  createForumTopic(chat_id: number, name: string, is_name_implicit: boolean,
    icon: forumTopicIcon): Promise<forumTopicInfo> {
    const params: Record<string, Object> = {
      '@type': 'createForumTopic',
      'chat_id': chat_id,
      'name': name,
      'is_name_implicit': is_name_implicit,
      'icon': icon,
    };
    return this.client.execute<forumTopicInfo>(params);
  }

  /**
   * 编辑论坛主题
   * @param chat_id 聊天 ID
   * @param forum_topic_id 主题 ID
   * @param name 新名称
   * @param edit_icon_custom_emoji 是否编辑图标
   * @param icon_custom_emoji_id 新图标自定义表情 ID
   */
  editForumTopic(
    chat_id: number,
    forum_topic_id: number,
    name: string,
    edit_icon_custom_emoji: boolean,
    icon_custom_emoji_id: number
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'editForumTopic',
      'chat_id': chat_id,
      'forum_topic_id': forum_topic_id,
      'name': name,
      'edit_icon_custom_emoji': edit_icon_custom_emoji,
      'icon_custom_emoji_id': icon_custom_emoji_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取论坛主题信息
   * @param chat_id 聊天 ID
   * @param forum_topic_id 主题 ID
   */
  getForumTopic(chat_id: number, forum_topic_id: number): Promise<ForumTopic> {
    const params: Record<string, Object> = {
      '@type': 'getForumTopic',
      'chat_id': chat_id,
      'forum_topic_id': forum_topic_id,
    };
    return this.client.execute<ForumTopic>(params);
  }

  /**
   * 获取论坛主题历史消息
   * @param chat_id 聊天 ID
   * @param forum_topic_id 主题 ID
   * @param from_message_id 起始消息 ID
   * @param offset 偏移
   * @param limit 数量
   */
  getForumTopicHistory(
    chat_id: number,
    forum_topic_id: number,
    from_message_id: number,
    offset: number,
    limit: number
  ): Promise<Messages> {
    const params: Record<string, Object> = {
      '@type': 'getForumTopicHistory',
      'chat_id': chat_id,
      'forum_topic_id': forum_topic_id,
      'from_message_id': from_message_id,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<Messages>(params);
  }

  /**
   * 获取论坛主题链接
   * @param chat_id 聊天 ID
   * @param forum_topic_id 主题 ID
   */
  getForumTopicLink(chat_id: number, forum_topic_id: number): Promise<MessageLink> {
    const params: Record<string, Object> = {
      '@type': 'getForumTopicLink',
      'chat_id': chat_id,
      'forum_topic_id': forum_topic_id,
    };
    return this.client.execute<MessageLink>(params);
  }

  /**
   * 获取论坛主题列表
   * @param chat_id 聊天 ID
   * @param query 查询字符串
   * @param offset_date 偏移日期
   * @param offset_message_id 偏移消息 ID
   * @param offset_forum_topic_id 偏移主题 ID
   * @param limit 数量
   */
  getForumTopics(
    chat_id: number,
    query: string,
    offset_date: number,
    offset_message_id: number,
    offset_forum_topic_id: number,
    limit: number
  ): Promise<ForumTopics> {
    const params: Record<string, Object> = {
      '@type': 'getForumTopics',
      'chat_id': chat_id,
      'query': query,
      'offset_date': offset_date,
      'offset_message_id': offset_message_id,
      'offset_forum_topic_id': offset_forum_topic_id,
      'limit': limit,
    };
    return this.client.execute<ForumTopics>(params);
  }

  /**
   * 设置论坛主题通知设置
   * @param chat_id 聊天 ID
   * @param forum_topic_id 主题 ID
   * @param notification_settings 通知设置
   */
  setForumTopicNotificationSettings(
    chat_id: number,
    forum_topic_id: number,
    notification_settings: chatNotificationSettings
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setForumTopicNotificationSettings',
      'chat_id': chat_id,
      'forum_topic_id': forum_topic_id,
      'notification_settings': notification_settings,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 关闭/重新打开论坛主题
   * @param chat_id 聊天 ID
   * @param forum_topic_id 主题 ID
   * @param is_closed 是否关闭
   */
  toggleForumTopicIsClosed(chat_id: number, forum_topic_id: number, is_closed: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleForumTopicIsClosed',
      'chat_id': chat_id,
      'forum_topic_id': forum_topic_id,
      'is_closed': is_closed,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 隐藏/显示 General 主题
   * @param chat_id 聊天 ID
   * @param is_hidden 是否隐藏
   */
  toggleGeneralForumTopicIsHidden(chat_id: number, is_hidden: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleGeneralForumTopicIsHidden',
      'chat_id': chat_id,
      'is_hidden': is_hidden,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 固定/取消固定论坛主题
   * @param chat_id 聊天 ID
   * @param forum_topic_id 主题 ID
   * @param is_pinned 是否固定
   */
  toggleForumTopicIsPinned(chat_id: number, forum_topic_id: number, is_pinned: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleForumTopicIsPinned',
      'chat_id': chat_id,
      'forum_topic_id': forum_topic_id,
      'is_pinned': is_pinned,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置固定主题的顺序
   * @param chat_id 聊天 ID
   * @param forum_topic_ids 主题 ID 列表（新顺序）
   */
  setPinnedForumTopics(chat_id: number, forum_topic_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setPinnedForumTopics',
      'chat_id': chat_id,
      'forum_topic_ids': forum_topic_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 删除论坛主题
   * @param chat_id 聊天 ID
   * @param forum_topic_id 主题 ID
   */
  deleteForumTopic(chat_id: number, forum_topic_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteForumTopic',
      'chat_id': chat_id,
      'forum_topic_id': forum_topic_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 将论坛主题中的提及标记为已读
   * @param chat_id 聊天 ID
   * @param forum_topic_id 主题 ID
   */
  readAllForumTopicMentions(chat_id: number, forum_topic_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'readAllForumTopicMentions',
      'chat_id': chat_id,
      'forum_topic_id': forum_topic_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 将论坛主题中的反应标记为已读
   * @param chat_id 聊天 ID
   * @param forum_topic_id 主题 ID
   */
  readAllForumTopicReactions(chat_id: number, forum_topic_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'readAllForumTopicReactions',
      'chat_id': chat_id,
      'forum_topic_id': forum_topic_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 取消固定论坛主题中的所有消息
   * @param chat_id 聊天 ID
   * @param forum_topic_id 主题 ID
   */
  unpinAllForumTopicMessages(chat_id: number, forum_topic_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'unpinAllForumTopicMessages',
      'chat_id': chat_id,
      'forum_topic_id': forum_topic_id,
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 反应与表情 ====================

  /**
   * 获取 Passkey 参数（JSON 字符串）
   */
  getPasskeyParameters(): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getPasskeyParameters',
    };
    return this.client.execute<string>(params);
  }

  /**
   * 添加登录 Passkey
   * @param client_data JSON 客户端数据
   * @param attestation_object 认证对象
   */
  addLoginPasskey(client_data: string, attestation_object: Uint8Array): Promise<passkey> {
    const params: Record<string, Object> = {
      '@type': 'addLoginPasskey',
      'client_data': client_data,
      'attestation_object': attestation_object,
    };
    return this.client.execute<passkey>(params);
  }

  /**
   * 获取登录 Passkey 列表
   */
  getLoginPasskeys(): Promise<passkeys> {
    const params: Record<string, Object> = {
      '@type': 'getLoginPasskeys',
    };
    return this.client.execute<passkeys>(params);
  }

  /**
   * 移除登录 Passkey
   * @param passkey_id Passkey ID
   */
  removeLoginPasskey(passkey_id: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeLoginPasskey',
      'passkey_id': passkey_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取表情反应
   * @param emoji 表情符号
   */
  getEmojiReaction(emoji: string): Promise<EmojiReaction> {
    const params: Record<string, Object> = {
      '@type': 'getEmojiReaction',
      'emoji': emoji,
    };
    return this.client.execute<EmojiReaction>(params);
  }

  /**
   * 获取自定义表情反应动画
   */
  getCustomEmojiReactionAnimations(): Promise<Stickers> {
    const params: Record<string, Object> = {
      '@type': 'getCustomEmojiReactionAnimations',
    };
    return this.client.execute<Stickers>(params);
  }

  /**
   * 获取消息可用的反应
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param row_size 每行数量
   */
  getMessageAvailableReactions(chat_id: number, message_id: number, row_size: number): Promise<AvailableReactions> {
    const params: Record<string, Object> = {
      '@type': 'getMessageAvailableReactions',
      'chat_id': chat_id,
      'message_id': message_id,
      'row_size': row_size,
    };
    return this.client.execute<AvailableReactions>(params);
  }

  /**
   * 清除最近使用的反应
   */
  clearRecentReactions(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'clearRecentReactions',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 添加消息反应
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param reaction_type 反应类型
   * @param is_big 是否大图
   * @param update_recent_reactions 是否更新最近反应
   */
  addMessageReaction(
    chat_id: number,
    message_id: number,
    reaction_type: ReactionType,
    is_big: boolean,
    update_recent_reactions: boolean
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'addMessageReaction',
      'chat_id': chat_id,
      'message_id': message_id,
      'reaction_type': reaction_type,
      'is_big': is_big,
      'update_recent_reactions': update_recent_reactions,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 移除消息反应
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param reaction_type 反应类型
   */
  removeMessageReaction(chat_id: number, message_id: number, reaction_type: ReactionType): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeMessageReaction',
      'chat_id': chat_id,
      'message_id': message_id,
      'reaction_type': reaction_type,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取可用于发送付费反应的发送者列表
   * @param chat_id 聊天 ID
   */
  getChatAvailablePaidMessageReactionSenders(chat_id: number): Promise<MessageSenders> {
    const params: Record<string, Object> = {
      '@type': 'getChatAvailablePaidMessageReactionSenders',
      'chat_id': chat_id,
    };
    return this.client.execute<MessageSenders>(params);
  }

  /**
   * 添加待处理的付费反应
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param star_count 星币数量
   * @param type 付费反应类型
   */
  addPendingPaidMessageReaction(
    chat_id: number,
    message_id: number,
    star_count: number,
    type: PaidReactionType | null
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'addPendingPaidMessageReaction',
      'chat_id': chat_id,
      'message_id': message_id,
      'star_count': star_count,
    };
    if (type !== null) {
      params['type'] = type;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 提交所有待处理的付费反应
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   */
  commitPendingPaidMessageReactions(chat_id: number, message_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'commitPendingPaidMessageReactions',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 移除所有待处理的付费反应
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   */
  removePendingPaidMessageReactions(chat_id: number, message_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removePendingPaidMessageReactions',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置付费反应类型
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param type 新类型
   */
  setPaidMessageReactionType(chat_id: number, message_id: number, type: PaidReactionType): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setPaidMessageReactionType',
      'chat_id': chat_id,
      'message_id': message_id,
      'type': type,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置消息反应（仅 Bot）
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param reaction_types 反应类型列表
   * @param is_big 是否大图
   */
  setMessageReactions(
    chat_id: number,
    message_id: number,
    reaction_types: ReactionType[],
    is_big: boolean
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setMessageReactions',
      'chat_id': chat_id,
      'message_id': message_id,
      'reaction_types': reaction_types,
      'is_big': is_big,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取消息已添加的反应及发送者
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param reaction_type 反应类型
   * @param offset 偏移
   * @param limit 数量
   */
  getMessageAddedReactions(
    chat_id: number,
    message_id: number,
    reaction_type: ReactionType | null,
    offset: string,
    limit: number
  ): Promise<AddedReactions> {
    const params: Record<string, Object> = {
      '@type': 'getMessageAddedReactions',
      'chat_id': chat_id,
      'message_id': message_id,
      'offset': offset,
      'limit': limit,
    };
    if (reaction_type !== null) {
      params['reaction_type'] = reaction_type;
    }
    return this.client.execute<AddedReactions>(params);
  }

  /**
   * 设置默认反应类型
   * @param reaction_type 反应类型
   */
  setDefaultReactionType(reaction_type: ReactionType): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setDefaultReactionType',
      'reaction_type': reaction_type,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取已保存消息的标签
   * @param saved_messages_topic_id 主题 ID（0 表示全部）
   */
  getSavedMessagesTags(saved_messages_topic_id: number): Promise<SavedMessagesTags> {
    const params: Record<string, Object> = {
      '@type': 'getSavedMessagesTags',
      'saved_messages_topic_id': saved_messages_topic_id,
    };
    return this.client.execute<SavedMessagesTags>(params);
  }

  /**
   * 设置已保存消息标签的标签文本
   * @param tag 标签（反应类型）
   * @param label 新标签文本
   */
  setSavedMessagesTagLabel(tag: ReactionType, label: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setSavedMessagesTagLabel',
      'tag': tag,
      'label': label,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取消息效果
   * @param effect_id 效果 ID
   */
  getMessageEffect(effect_id: number): Promise<MessageEffect> {
    const params: Record<string, Object> = {
      '@type': 'getMessageEffect',
      'effect_id': effect_id,
    };
    return this.client.execute<MessageEffect>(params);
  }

  /**
   * 在文本中搜索引用
   * @param text 文本
   * @param quote 引用文本
   * @param quote_position 引用位置
   */
  searchQuote(text: FormattedText, quote: FormattedText, quote_position: number): Promise<number> {
    const params: Record<string, Object> = {
      '@type': 'searchQuote',
      'text': text,
      'quote': quote,
      'quote_position': quote_position,
    };
    return this.client.execute<number>(params);
  }

  // ==================== 文本处理 ====================

  /**
   * 获取文本中的实体（离线）
   * @param text 文本
   */
  getTextEntities(text: string): Promise<TextEntities> {
    const params: Record<string, Object> = {
      '@type': 'getTextEntities',
      'text': text,
    };
    return this.client.execute<TextEntities>(params);
  }

  /**
   * 解析标记文本为带实体的文本
   * @param text 标记文本
   * @param parse_mode 解析模式
   */
  parseTextEntities(text: string, parse_mode: TextParseMode$Input): Promise<FormattedText> {
    const params: Record<string, Object> = {
      '@type': 'parseTextEntities',
      'text': text,
      'parse_mode': parse_mode,
    };
    return this.client.execute<FormattedText>(params);
  }

  /**
   * 将 Markdown 解析为带实体的文本
   * @param text 带实体的文本
   */
  parseMarkdown(text: FormattedText): Promise<FormattedText> {
    const params: Record<string, Object> = {
      '@type': 'parseMarkdown',
      'text': text,
    };
    return this.client.execute<FormattedText>(params);
  }

  /**
   * 将带实体的文本转换为 Markdown 格式
   * @param text 带实体的文本
   */
  getMarkdownText(text: FormattedText): Promise<FormattedText> {
    const params: Record<string, Object> = {
      '@type': 'getMarkdownText',
      'text': text,
    };
    return this.client.execute<FormattedText>(params);
  }

  /**
   * 获取国家表情符号
   * @param country_code 国家代码
   */
  getCountryFlagEmoji(country_code: string): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getCountryFlagEmoji',
      'country_code': country_code,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 根据扩展名获取 MIME 类型
   * @param file_name 文件名
   */
  getFileMimeType(file_name: string): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getFileMimeType',
      'file_name': file_name,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 根据 MIME 类型获取扩展名
   * @param mime_type MIME 类型
   */
  getFileExtension(mime_type: string): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getFileExtension',
      'mime_type': mime_type,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 清理文件名中的危险字符
   * @param file_name 文件名
   */
  cleanFileName(file_name: string): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'cleanFileName',
      'file_name': file_name,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 获取语言包字符串（离线）
   * @param language_pack_database_path 语言包数据库路径
   * @param localization_target 本地化目标
   * @param language_pack_id 语言包 ID
   * @param key 键
   */
  getLanguagePackString(
    language_pack_database_path: string,
    localization_target: string,
    language_pack_id: string,
    key: string
  ): Promise<LanguagePackStringValue> {
    const params: Record<string, Object> = {
      '@type': 'getLanguagePackString',
      'language_pack_database_path': language_pack_database_path,
      'localization_target': localization_target,
      'language_pack_id': language_pack_id,
      'key': key,
    };
    return this.client.execute<LanguagePackStringValue>(params);
  }

  /**
   * 将 JSON 字符串转换为 JsonValue 对象
   * @param json JSON 字符串
   */
  getJsonValue(json: string): Promise<JsonValue> {
    const params: Record<string, Object> = {
      '@type': 'getJsonValue',
      'json': json,
    };
    return this.client.execute<JsonValue>(params);
  }

  /**
   * 将 JsonValue 对象转换为 JSON 字符串
   * @param json_value JsonValue 对象
   */
  getJsonString(json_value: JsonValue): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getJsonString',
      'json_value': json_value,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 将 ThemeParameters 转换为 JSON 字符串
   * @param theme 主题参数
   */
  getThemeParametersJsonString(theme: themeParameters$Input): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getThemeParametersJsonString',
      'theme': theme,
    };
    return this.client.execute<string>(params);
  }

  // ==================== 投票与清单 ====================

  /**
   * 设置投票答案
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param option_ids 选项 ID 列表
   */
  setPollAnswer(chat_id: number, message_id: number, option_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setPollAnswer',
      'chat_id': chat_id,
      'message_id': message_id,
      'option_ids': option_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取投票者列表
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param option_id 选项 ID
   * @param offset 偏移
   * @param limit 数量
   */
  getPollVoters(chat_id: number, message_id: number, option_id: number, offset: number,
    limit: number): Promise<MessageSenders> {
    const params: Record<string, Object> = {
      '@type': 'getPollVoters',
      'chat_id': chat_id,
      'message_id': message_id,
      'option_id': option_id,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<MessageSenders>(params);
  }

  /**
   * 停止投票
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param reply_markup 回复标记
   */
  stopPoll(chat_id: number, message_id: number, reply_markup: ReplyMarkup | null): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'stopPoll',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    if (reply_markup !== null) {
      params['reply_markup'] = reply_markup;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 向清单添加任务
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param tasks 任务列表
   */
  addChecklistTasks(chat_id: number, message_id: number, tasks: inputChecklistTask[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'addChecklistTasks',
      'chat_id': chat_id,
      'message_id': message_id,
      'tasks': tasks,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 标记清单任务完成/未完成
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param marked_as_done_task_ids 已完成任务 ID 列表
   * @param marked_as_not_done_task_ids 未完成任务 ID 列表
   */
  markChecklistTasksAsDone(
    chat_id: number,
    message_id: number,
    marked_as_done_task_ids: number[],
    marked_as_not_done_task_ids: number[]
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'markChecklistTasksAsDone',
      'chat_id': chat_id,
      'message_id': message_id,
      'marked_as_done_task_ids': marked_as_done_task_ids,
      'marked_as_not_done_task_ids': marked_as_not_done_task_ids,
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 建议操作 ====================

  /**
   * 隐藏建议操作
   * @param action 建议操作
   */
  hideSuggestedAction(action: SuggestedAction): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'hideSuggestedAction',
      'action': action,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 隐藏生日接近的联系人（24 小时）
   */
  hideContactCloseBirthdays(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'hideContactCloseBirthdays',
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 商业连接 ====================

  /**
   * 获取商业连接信息（仅 Bot）
   * @param connection_id 连接 ID
   */
  getBusinessConnection(connection_id: string): Promise<BusinessConnection> {
    const params: Record<string, Object> = {
      '@type': 'getBusinessConnection',
      'connection_id': connection_id,
    };
    return this.client.execute<BusinessConnection>(params);
  }

  // ==================== 登录 URL ====================

  /**
   * 获取登录 URL 信息
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param button_id 按钮 ID
   */
  getLoginUrlInfo(chat_id: number, message_id: number, button_id: number): Promise<LoginUrlInfo> {
    const params: Record<string, Object> = {
      '@type': 'getLoginUrlInfo',
      'chat_id': chat_id,
      'message_id': message_id,
      'button_id': button_id,
    };
    return this.client.execute<LoginUrlInfo>(params);
  }

  /**
   * 获取登录 URL
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param button_id 按钮 ID
   * @param allow_write_access 是否允许发送消息
   */
  getLoginUrl(chat_id: number, message_id: number, button_id: number, allow_write_access: boolean): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getLoginUrl',
      'chat_id': chat_id,
      'message_id': message_id,
      'button_id': button_id,
      'allow_write_access': allow_write_access,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 与 Bot 分享用户
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param button_id 按钮 ID
   * @param shared_user_ids 分享的用户 ID 列表
   * @param only_check 是否仅检查
   */
  shareUsersWithBot(
    chat_id: number,
    message_id: number,
    button_id: number,
    shared_user_ids: number[],
    only_check: boolean
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'shareUsersWithBot',
      'chat_id': chat_id,
      'message_id': message_id,
      'button_id': button_id,
      'shared_user_ids': shared_user_ids,
      'only_check': only_check,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 与 Bot 分享聊天
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param button_id 按钮 ID
   * @param shared_chat_id 分享的聊天 ID
   * @param only_check 是否仅检查
   */
  shareChatWithBot(
    chat_id: number,
    message_id: number,
    button_id: number,
    shared_chat_id: number,
    only_check: boolean
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'shareChatWithBot',
      'chat_id': chat_id,
      'message_id': message_id,
      'button_id': button_id,
      'shared_chat_id': shared_chat_id,
      'only_check': only_check,
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 内联查询 ====================

  /**
   * 获取内联查询结果
   * @param bot_user_id Bot ID
   * @param chat_id 聊天 ID
   * @param user_location 用户位置
   * @param query 查询字符串
   * @param offset 偏移
   */
  getInlineQueryResults(
    bot_user_id: number,
    chat_id: number,
    user_location: location | null,
    query: string,
    offset: string
  ): Promise<InlineQueryResults> {
    const params: Record<string, Object> = {
      '@type': 'getInlineQueryResults',
      'bot_user_id': bot_user_id,
      'chat_id': chat_id,
      'query': query,
      'offset': offset,
    };
    if (user_location !== null) {
      params['user_location'] = user_location;
    }
    return this.client.execute<InlineQueryResults>(params);
  }

  /**
   * 回答内联查询（仅 Bot）
   * @param inline_query_id 查询 ID
   * @param is_personal 是否个人化
   * @param button 按钮
   * @param results 结果列表
   * @param cache_time 缓存时间
   * @param next_offset 下一偏移
   */
  answerInlineQuery(
    inline_query_id: number,
    is_personal: boolean,
    button: inlineQueryResultsButton | null,
    results: InlineQueryResult[],
    cache_time: number,
    next_offset: string
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'answerInlineQuery',
      'inline_query_id': inline_query_id,
      'is_personal': is_personal,
      'results': results,
      'cache_time': cache_time,
      'next_offset': next_offset,
    };
    if (button !== null) {
      params['button'] = button;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 保存准备的内联消息（仅 Bot）
   * @param user_id 用户 ID
   * @param result 内联查询结果
   * @param chat_types 允许的聊天类型
   */
  savePreparedInlineMessage(
    user_id: number,
    result: InlineQueryResult,
    chat_types: targetChatTypes$Input
  ): Promise<PreparedInlineMessageId> {
    const params: Record<string, Object> = {
      '@type': 'savePreparedInlineMessage',
      'user_id': user_id,
      'result': result,
      'chat_types': chat_types,
    };
    return this.client.execute<PreparedInlineMessageId>(params);
  }

  /**
   * 获取准备的内联消息
   * @param bot_user_id Bot ID
   * @param prepared_message_id 准备的消息 ID
   */
  getPreparedInlineMessage(bot_user_id: number, prepared_message_id: string): Promise<PreparedInlineMessage> {
    const params: Record<string, Object> = {
      '@type': 'getPreparedInlineMessage',
      'bot_user_id': bot_user_id,
      'prepared_message_id': prepared_message_id,
    };
    return this.client.execute<PreparedInlineMessage>(params);
  }

  // ==================== Web 应用 ====================

  /**
   * 获取最赚钱的 Web App Bot
   * @param offset 偏移
   * @param limit 数量
   */
  getGrossingWebAppBots(offset: string, limit: number): Promise<FoundUsers> {
    const params: Record<string, Object> = {
      '@type': 'getGrossingWebAppBots',
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<FoundUsers>(params);
  }

  /**
   * 搜索 Web App
   * @param bot_user_id Bot ID
   * @param web_app_short_name Web App 短名
   */
  searchWebApp(bot_user_id: number, web_app_short_name: string): Promise<FoundWebApp> {
    const params: Record<string, Object> = {
      '@type': 'searchWebApp',
      'bot_user_id': bot_user_id,
      'web_app_short_name': web_app_short_name,
    };
    return this.client.execute<FoundWebApp>(params);
  }

  /**
   * 获取 Web App 占位符（离线）
   * @param bot_user_id Bot ID
   */
  getWebAppPlaceholder(bot_user_id: number): Promise<Outline> {
    const params: Record<string, Object> = {
      '@type': 'getWebAppPlaceholder',
      'bot_user_id': bot_user_id,
    };
    return this.client.execute<Outline>(params);
  }

  /**
   * 获取 Web App 链接 URL
   * @param chat_id 聊天 ID
   * @param bot_user_id Bot ID
   * @param web_app_short_name Web App 短名
   * @param start_parameter 启动参数
   * @param allow_write_access 是否允许写消息
   * @param parameters 打开参数
   */
  getWebAppLinkUrl(
    chat_id: number,
    bot_user_id: number,
    web_app_short_name: string,
    start_parameter: string,
    allow_write_access: boolean,
    parameters: webAppOpenParameters$Input
  ): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getWebAppLinkUrl',
      'chat_id': chat_id,
      'bot_user_id': bot_user_id,
      'web_app_short_name': web_app_short_name,
      'start_parameter': start_parameter,
      'allow_write_access': allow_write_access,
      'parameters': parameters,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 获取主 Web App 信息
   * @param chat_id 聊天 ID
   * @param bot_user_id Bot ID
   * @param start_parameter 启动参数
   * @param parameters 打开参数
   */
  getMainWebApp(
    chat_id: number,
    bot_user_id: number,
    start_parameter: string,
    parameters: webAppOpenParameters$Input
  ): Promise<MainWebApp> {
    const params: Record<string, Object> = {
      '@type': 'getMainWebApp',
      'chat_id': chat_id,
      'bot_user_id': bot_user_id,
      'start_parameter': start_parameter,
      'parameters': parameters,
    };
    return this.client.execute<MainWebApp>(params);
  }

  /**
   * 获取 Web App URL（通用）
   * @param bot_user_id Bot ID
   * @param url URL（空表示从侧边菜单打开）
   * @param parameters 打开参数
   */
  getWebAppUrl(bot_user_id: number, url: string, parameters: webAppOpenParameters$Input): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getWebAppUrl',
      'bot_user_id': bot_user_id,
      'url': url,
      'parameters': parameters,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 发送 Web App 数据到 Bot
   * @param bot_user_id Bot ID
   * @param button_text 按钮文本
   * @param data 数据
   */
  sendWebAppData(bot_user_id: number, button_text: string, data: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'sendWebAppData',
      'bot_user_id': bot_user_id,
      'button_text': button_text,
      'data': data,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 打开 Web App
   * @param chat_id 聊天 ID
   * @param bot_user_id Bot ID
   * @param url URL
   * @param topic_id 主题 ID
   * @param reply_to 回复信息
   * @param parameters 打开参数
   */
  openWebApp(
    chat_id: number,
    bot_user_id: number,
    url: string,
    topic_id: MessageTopic | null,
    reply_to: InputMessageReplyTo | null,
    parameters: webAppOpenParameters$Input
  ): Promise<WebAppInfo> {
    const params: Record<string, Object> = {
      '@type': 'openWebApp',
      'chat_id': chat_id,
      'bot_user_id': bot_user_id,
      'url': url,
      'parameters': parameters,
    };
    if (topic_id !== null) {
      params['topic_id'] = topic_id;
    }
    if (reply_to !== null) {
      params['reply_to'] = reply_to;
    }
    return this.client.execute<WebAppInfo>(params);
  }

  /**
   * 关闭 Web App
   * @param web_app_launch_id 启动 ID
   */
  closeWebApp(web_app_launch_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'closeWebApp',
      'web_app_launch_id': web_app_launch_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 回答 Web App 查询（仅 Bot）
   * @param web_app_query_id 查询 ID
   * @param result 内联查询结果
   */
  answerWebAppQuery(web_app_query_id: string, result: InlineQueryResult): Promise<SentWebAppMessage> {
    const params: Record<string, Object> = {
      '@type': 'answerWebAppQuery',
      'web_app_query_id': web_app_query_id,
      'result': result,
    };
    return this.client.execute<SentWebAppMessage>(params);
  }

  /**
   * 检查 Web App 文件下载
   * @param bot_user_id Bot ID
   * @param file_name 文件名
   * @param url URL
   */
  checkWebAppFileDownload(bot_user_id: number, file_name: string, url: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'checkWebAppFileDownload',
      'bot_user_id': bot_user_id,
      'file_name': file_name,
      'url': url,
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 回调查询 ====================

  /**
   * 获取回调查询答案
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param payload 载荷
   */
  getCallbackQueryAnswer(chat_id: number, message_id: number,
    payload: CallbackQueryPayload): Promise<CallbackQueryAnswer> {
    const params: Record<string, Object> = {
      '@type': 'getCallbackQueryAnswer',
      'chat_id': chat_id,
      'message_id': message_id,
      'payload': payload,
    };
    return this.client.execute<CallbackQueryAnswer>(params);
  }

  /**
   * 回答回调查询（仅 Bot）
   * @param callback_query_id 查询 ID
   * @param text 文本
   * @param show_alert 是否显示警报
   * @param url URL
   * @param cache_time 缓存时间
   */
  answerCallbackQuery(
    callback_query_id: number,
    text: string,
    show_alert: boolean,
    url: string,
    cache_time: number
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'answerCallbackQuery',
      'callback_query_id': callback_query_id,
      'text': text,
      'show_alert': show_alert,
      'url': url,
      'cache_time': cache_time,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 回答配送查询（仅 Bot）
   * @param shipping_query_id 查询 ID
   * @param shipping_options 配送选项
   * @param error_message 错误消息
   */
  answerShippingQuery(
    shipping_query_id: number,
    shipping_options: shippingOption[],
    error_message: string
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'answerShippingQuery',
      'shipping_query_id': shipping_query_id,
      'shipping_options': shipping_options,
      'error_message': error_message,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 回答预结账查询（仅 Bot）
   * @param pre_checkout_query_id 查询 ID
   * @param error_message 错误消息
   */
  answerPreCheckoutQuery(pre_checkout_query_id: number, error_message: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'answerPreCheckoutQuery',
      'pre_checkout_query_id': pre_checkout_query_id,
      'error_message': error_message,
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 游戏 ====================

  /**
   * 设置游戏分数（仅 Bot）
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param edit_message 是否编辑消息
   * @param user_id 用户 ID
   * @param score 分数
   * @param force 是否强制（允许减少）
   */
  setGameScore(
    chat_id: number,
    message_id: number,
    edit_message: boolean,
    user_id: number,
    score: number,
    force: boolean
  ): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'setGameScore',
      'chat_id': chat_id,
      'message_id': message_id,
      'edit_message': edit_message,
      'user_id': user_id,
      'score': score,
      'force': force,
    };
    return this.client.execute<Message>(params);
  }

  /**
   * 设置内联游戏分数（仅 Bot）
   * @param inline_message_id 内联消息 ID
   * @param edit_message 是否编辑消息
   * @param user_id 用户 ID
   * @param score 分数
   * @param force 是否强制
   */
  setInlineGameScore(
    inline_message_id: string,
    edit_message: boolean,
    user_id: number,
    score: number,
    force: boolean
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setInlineGameScore',
      'inline_message_id': inline_message_id,
      'edit_message': edit_message,
      'user_id': user_id,
      'score': score,
      'force': force,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取游戏高分榜
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param user_id 用户 ID
   */
  getGameHighScores(chat_id: number, message_id: number, user_id: number): Promise<GameHighScores> {
    const params: Record<string, Object> = {
      '@type': 'getGameHighScores',
      'chat_id': chat_id,
      'message_id': message_id,
      'user_id': user_id,
    };
    return this.client.execute<GameHighScores>(params);
  }

  /**
   * 获取内联游戏高分榜
   * @param inline_message_id 内联消息 ID
   * @param user_id 用户 ID
   */
  getInlineGameHighScores(inline_message_id: string, user_id: number): Promise<GameHighScores> {
    const params: Record<string, Object> = {
      '@type': 'getInlineGameHighScores',
      'inline_message_id': inline_message_id,
      'user_id': user_id,
    };
    return this.client.execute<GameHighScores>(params);
  }

  // ==================== 聊天操作 ====================

  /**
   * 删除聊天回复标记
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   */
  deleteChatReplyMarkup(chat_id: number, message_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteChatReplyMarkup',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 发送聊天操作
   * @param chat_id 聊天 ID
   * @param topic_id 主题 ID
   * @param business_connection_id 商业连接 ID（仅 Bot）
   * @param action 操作
   */
  sendChatAction(
    chat_id: number,
    topic_id: MessageTopic | null,
    business_connection_id: string,
    action: ChatAction | null
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'sendChatAction',
      'chat_id': chat_id,
      'business_connection_id': business_connection_id,
    };
    if (topic_id !== null) {
      params['topic_id'] = topic_id;
    }
    if (action !== null) {
      params['action'] = action;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 发送文本消息草稿（仅 Bot）
   * @param chat_id 聊天 ID
   * @param forum_topic_id 论坛主题 ID
   * @param draft_id 草稿 ID
   * @param text 文本
   */
  sendTextMessageDraft(chat_id: number, forum_topic_id: number, draft_id: number, text: FormattedText): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'sendTextMessageDraft',
      'chat_id': chat_id,
      'forum_topic_id': forum_topic_id,
      'draft_id': draft_id,
      'text': text,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 打开聊天
   * @param chat_id 聊天 ID
   */
  openChat(chat_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'openChat',
      'chat_id': chat_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 关闭聊天
   * @param chat_id 聊天 ID
   */
  closeChat(chat_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'closeChat',
      'chat_id': chat_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 标记消息为已查看
   * @param chat_id 聊天 ID
   * @param message_ids 消息 ID 列表
   * @param source 消息来源
   * @param force_read 是否强制标记已读
   */
  viewMessages(
    chat_id: number,
    message_ids: number[],
    source: messageStory | null,
    force_read: boolean
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'viewMessages',
      'chat_id': chat_id,
      'message_ids': message_ids,
      'force_read': force_read,
    };
    if (source !== null) {
      params['source'] = source;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 打开消息内容
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   */
  openMessageContent(chat_id: number, message_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'openMessageContent',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 点击动态表情消息
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   */
  clickAnimatedEmojiMessage(chat_id: number, message_id: number): Promise<Sticker> {
    const params: Record<string, Object> = {
      '@type': 'clickAnimatedEmojiMessage',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<Sticker>(params);
  }

  /**
   * 获取内部链接
   * @param type 链接类型
   * @param is_http 是否生成 HTTP 链接
   */
  getInternalLink(type: InternalLinkType, is_http: boolean): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getInternalLink',
      'type': type,
      'is_http': is_http,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 获取内部链接类型
   * @param link 链接
   */
  getInternalLinkType(link: string): Promise<InternalLinkType> {
    const params: Record<string, Object> = {
      '@type': 'getInternalLinkType',
      'link': link,
    };
    return this.client.execute<InternalLinkType>(params);
  }

  /**
   * 获取外部链接信息
   * @param link 链接
   */
  getExternalLinkInfo(link: string): Promise<LoginUrlInfo> {
    const params: Record<string, Object> = {
      '@type': 'getExternalLinkInfo',
      'link': link,
    };
    return this.client.execute<LoginUrlInfo>(params);
  }

  /**
   * 获取外部链接
   * @param link 链接
   * @param allow_write_access 是否允许写消息
   * @param allow_phone_number_access 是否允许访问手机号
   */
  getExternalLink(link: string, allow_write_access: boolean, allow_phone_number_access: boolean): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getExternalLink',
      'link': link,
      'allow_write_access': allow_write_access,
      'allow_phone_number_access': allow_phone_number_access,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 将所有提及标记为已读
   * @param chat_id 聊天 ID
   */
  readAllChatMentions(chat_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'readAllChatMentions',
      'chat_id': chat_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 将所有反应标记为已读
   * @param chat_id 聊天 ID
   */
  readAllChatReactions(chat_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'readAllChatReactions',
      'chat_id': chat_id,
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 创建聊天 ====================

  /**
   * 创建私聊
   * @param user_id 用户 ID
   * @param force 是否强制（可能不准确）
   */
  createPrivateChat(user_id: number, force: boolean): Promise<Chat> {
    const params: Record<string, Object> = {
      '@type': 'createPrivateChat',
      'user_id': user_id,
      'force': force,
    };
    return this.client.execute<Chat>(params);
  }

  /**
   * 创建基础群组聊天
   * @param basic_group_id 基础群组 ID
   * @param force 是否强制
   */
  createBasicGroupChat(basic_group_id: number, force: boolean): Promise<Chat> {
    const params: Record<string, Object> = {
      '@type': 'createBasicGroupChat',
      'basic_group_id': basic_group_id,
      'force': force,
    };
    return this.client.execute<Chat>(params);
  }

  /**
   * 创建超级群组聊天
   * @param supergroup_id 超级群组 ID
   * @param force 是否强制
   */
  createSupergroupChat(supergroup_id: number, force: boolean): Promise<Chat> {
    const params: Record<string, Object> = {
      '@type': 'createSupergroupChat',
      'supergroup_id': supergroup_id,
      'force': force,
    };
    return this.client.execute<Chat>(params);
  }

  /**
   * 创建秘密聊天
   * @param secret_chat_id 秘密聊天 ID
   */
  createSecretChat(secret_chat_id: number): Promise<Chat> {
    const params: Record<string, Object> = {
      '@type': 'createSecretChat',
      'secret_chat_id': secret_chat_id,
    };
    return this.client.execute<Chat>(params);
  }

  /**
   * 创建新基础群组
   * @param user_ids 用户 ID 列表
   * @param title 标题
   * @param message_auto_delete_time 消息自动删除时间
   */
  createNewBasicGroupChat(user_ids: number[], title: string,
    message_auto_delete_time: number): Promise<CreatedBasicGroupChat> {
    const params: Record<string, Object> = {
      '@type': 'createNewBasicGroupChat',
      'user_ids': user_ids,
      'title': title,
      'message_auto_delete_time': message_auto_delete_time,
    };
    return this.client.execute<CreatedBasicGroupChat>(params);
  }

  /**
   * 创建新超级群组/频道
   * @param title 标题
   * @param is_forum 是否为论坛
   * @param is_channel 是否为频道
   * @param description 描述
   * @param location 位置
   * @param message_auto_delete_time 消息自动删除时间
   * @param for_import 是否为导入准备
   */
  createNewSupergroupChat(
    title: string,
    is_forum: boolean,
    is_channel: boolean,
    description: string,
    location: chatLocation | null,
    message_auto_delete_time: number,
    for_import: boolean
  ): Promise<Chat> {
    const params: Record<string, Object> = {
      '@type': 'createNewSupergroupChat',
      'title': title,
      'is_forum': is_forum,
      'is_channel': is_channel,
      'description': description,
      'message_auto_delete_time': message_auto_delete_time,
      'for_import': for_import,
    };
    if (location !== null) {
      params['location'] = location;
    }
    return this.client.execute<Chat>(params);
  }

  /**
   * 创建新秘密聊天
   * @param user_id 用户 ID
   */
  createNewSecretChat(user_id: number): Promise<Chat> {
    const params: Record<string, Object> = {
      '@type': 'createNewSecretChat',
      'user_id': user_id,
    };
    return this.client.execute<Chat>(params);
  }

  /**
   * 将基础群组升级为超级群组
   * @param chat_id 聊天 ID
   */
  upgradeBasicGroupChatToSupergroupChat(chat_id: number): Promise<Chat> {
    const params: Record<string, Object> = {
      '@type': 'upgradeBasicGroupChatToSupergroupChat',
      'chat_id': chat_id,
    };
    return this.client.execute<Chat>(params);
  }

  // ==================== 聊天列表与文件夹 ====================

  /**
   * 获取聊天可添加的列表
   * @param chat_id 聊天 ID
   */
  getChatListsToAddChat(chat_id: number): Promise<ChatLists> {
    const params: Record<string, Object> = {
      '@type': 'getChatListsToAddChat',
      'chat_id': chat_id,
    };
    return this.client.execute<ChatLists>(params);
  }

  /**
   * 将聊天添加到列表
   * @param chat_id 聊天 ID
   * @param chat_list 聊天列表
   */
  addChatToList(chat_id: number, chat_list: ChatList): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'addChatToList',
      'chat_id': chat_id,
      'chat_list': chat_list,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取聊天文件夹信息
   * @param chat_folder_id 文件夹 ID
   */
  getChatFolder(chat_folder_id: number): Promise<ChatFolder> {
    const params: Record<string, Object> = {
      '@type': 'getChatFolder',
      'chat_folder_id': chat_folder_id,
    };
    return this.client.execute<ChatFolder>(params);
  }

  /**
   * 创建聊天文件夹
   * @param folder 文件夹定义
   */
  createChatFolder(folder: ChatFolder): Promise<ChatFolderInfo> {
    const params: Record<string, Object> = {
      '@type': 'createChatFolder',
      'folder': folder,
    };
    return this.client.execute<ChatFolderInfo>(params);
  }

  /**
   * 编辑聊天文件夹
   * @param chat_folder_id 文件夹 ID
   * @param folder 新定义
   */
  editChatFolder(chat_folder_id: number, folder: ChatFolder): Promise<ChatFolderInfo> {
    const params: Record<string, Object> = {
      '@type': 'editChatFolder',
      'chat_folder_id': chat_folder_id,
      'folder': folder,
    };
    return this.client.execute<ChatFolderInfo>(params);
  }

  /**
   * 删除聊天文件夹
   * @param chat_folder_id 文件夹 ID
   * @param leave_chat_ids 离开的聊天 ID 列表
   */
  deleteChatFolder(chat_folder_id: number, leave_chat_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteChatFolder',
      'chat_folder_id': chat_folder_id,
      'leave_chat_ids': leave_chat_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取建议离开的聊天（当文件夹被删除时）
   * @param chat_folder_id 文件夹 ID
   */
  getChatFolderChatsToLeave(chat_folder_id: number): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'getChatFolderChatsToLeave',
      'chat_folder_id': chat_folder_id,
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 获取文件夹中的聊天数量（预览）
   * @param folder 文件夹定义
   */
  getChatFolderChatCount(folder: ChatFolder): Promise<number> {
    const params: Record<string, Object> = {
      '@type': 'getChatFolderChatCount',
      'folder': folder,
    };
    return this.client.execute<number>(params);
  }

  /**
   * 重新排序聊天文件夹
   * @param chat_folder_ids 文件夹 ID 列表（新顺序）
   * @param main_chat_list_position 主列表位置
   */
  reorderChatFolders(chat_folder_ids: number[], main_chat_list_position: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'reorderChatFolders',
      'chat_folder_ids': chat_folder_ids,
      'main_chat_list_position': main_chat_list_position,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 启用/禁用文件夹标签
   * @param are_tags_enabled 是否启用
   */
  toggleChatFolderTags(are_tags_enabled: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleChatFolderTags',
      'are_tags_enabled': are_tags_enabled,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取推荐文件夹
   */
  getRecommendedChatFolders(): Promise<RecommendedChatFolders> {
    const params: Record<string, Object> = {
      '@type': 'getRecommendedChatFolders',
    };
    return this.client.execute<RecommendedChatFolders>(params);
  }

  /**
   * 获取文件夹默认图标名称
   * @param folder 文件夹定义
   */
  getChatFolderDefaultIconName(folder: ChatFolder): Promise<ChatFolderIcon> {
    const params: Record<string, Object> = {
      '@type': 'getChatFolderDefaultIconName',
      'folder': folder,
    };
    return this.client.execute<ChatFolderIcon>(params);
  }

  /**
   * 获取文件夹邀请链接可包含的聊天
   * @param chat_folder_id 文件夹 ID
   */
  getChatsForChatFolderInviteLink(chat_folder_id: number): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'getChatsForChatFolderInviteLink',
      'chat_folder_id': chat_folder_id,
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 创建文件夹邀请链接
   * @param chat_folder_id 文件夹 ID
   * @param name 链接名称
   * @param chat_ids 聊天 ID 列表
   */
  createChatFolderInviteLink(chat_folder_id: number, name: string, chat_ids: number[]): Promise<ChatFolderInviteLink> {
    const params: Record<string, Object> = {
      '@type': 'createChatFolderInviteLink',
      'chat_folder_id': chat_folder_id,
      'name': name,
      'chat_ids': chat_ids,
    };
    return this.client.execute<ChatFolderInviteLink>(params);
  }

  /**
   * 获取文件夹邀请链接列表
   * @param chat_folder_id 文件夹 ID
   */
  getChatFolderInviteLinks(chat_folder_id: number): Promise<ChatFolderInviteLinks> {
    const params: Record<string, Object> = {
      '@type': 'getChatFolderInviteLinks',
      'chat_folder_id': chat_folder_id,
    };
    return this.client.execute<ChatFolderInviteLinks>(params);
  }

  /**
   * 编辑文件夹邀请链接
   * @param chat_folder_id 文件夹 ID
   * @param invite_link 链接
   * @param name 新名称
   * @param chat_ids 新聊天 ID 列表
   */
  editChatFolderInviteLink(
    chat_folder_id: number,
    invite_link: string,
    name: string,
    chat_ids: number[]
  ): Promise<ChatFolderInviteLink> {
    const params: Record<string, Object> = {
      '@type': 'editChatFolderInviteLink',
      'chat_folder_id': chat_folder_id,
      'invite_link': invite_link,
      'name': name,
      'chat_ids': chat_ids,
    };
    return this.client.execute<ChatFolderInviteLink>(params);
  }

  /**
   * 删除文件夹邀请链接
   * @param chat_folder_id 文件夹 ID
   * @param invite_link 链接
   */
  deleteChatFolderInviteLink(chat_folder_id: number, invite_link: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteChatFolderInviteLink',
      'chat_folder_id': chat_folder_id,
      'invite_link': invite_link,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 检查文件夹邀请链接
   * @param invite_link 链接
   */
  checkChatFolderInviteLink(invite_link: string): Promise<ChatFolderInviteLinkInfo> {
    const params: Record<string, Object> = {
      '@type': 'checkChatFolderInviteLink',
      'invite_link': invite_link,
    };
    return this.client.execute<ChatFolderInviteLinkInfo>(params);
  }

  /**
   * 通过邀请链接添加文件夹
   * @param invite_link 链接
   * @param chat_ids 聊天 ID 列表
   */
  addChatFolderByInviteLink(invite_link: string, chat_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'addChatFolderByInviteLink',
      'invite_link': invite_link,
      'chat_ids': chat_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取文件夹新聊天
   * @param chat_folder_id 文件夹 ID
   */
  getChatFolderNewChats(chat_folder_id: number): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'getChatFolderNewChats',
      'chat_folder_id': chat_folder_id,
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 处理文件夹新聊天
   * @param chat_folder_id 文件夹 ID
   * @param added_chat_ids 新增聊天 ID 列表
   */
  processChatFolderNewChats(chat_folder_id: number, added_chat_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'processChatFolderNewChats',
      'chat_folder_id': chat_folder_id,
      'added_chat_ids': added_chat_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取归档聊天列表设置
   */
  getArchiveChatListSettings(): Promise<ArchiveChatListSettings> {
    const params: Record<string, Object> = {
      '@type': 'getArchiveChatListSettings',
    };
    return this.client.execute<ArchiveChatListSettings>(params);
  }

  /**
   * 设置归档聊天列表设置
   * @param settings 新设置
   */
  setArchiveChatListSettings(settings: ArchiveChatListSettings): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setArchiveChatListSettings',
      'settings': settings,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置聊天标题
   * @param chat_id 聊天 ID
   * @param title 新标题
   */
  setChatTitle(chat_id: number, title: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatTitle',
      'chat_id': chat_id,
      'title': title,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置聊天头像
   * @param chat_id 聊天 ID
   * @param photo 新头像（null 表示删除）
   */
  setChatPhoto(chat_id: number, photo: InputChatPhoto$Input | null): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatPhoto',
      'chat_id': chat_id,
    };
    if (photo !== null) {
      params['photo'] = photo;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置聊天强调色和背景自定义表情
   * @param chat_id 聊天 ID
   * @param accent_color_id 强调色 ID
   * @param background_custom_emoji_id 背景自定义表情 ID
   */
  setChatAccentColor(chat_id: number, accent_color_id: number, background_custom_emoji_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatAccentColor',
      'chat_id': chat_id,
      'accent_color_id': accent_color_id,
      'background_custom_emoji_id': background_custom_emoji_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置聊天资料强调色和背景自定义表情
   * @param chat_id 聊天 ID
   * @param profile_accent_color_id 资料强调色 ID（-1 表示无）
   * @param profile_background_custom_emoji_id 背景自定义表情 ID
   */
  setChatProfileAccentColor(
    chat_id: number,
    profile_accent_color_id: number,
    profile_background_custom_emoji_id: number
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatProfileAccentColor',
      'chat_id': chat_id,
      'profile_accent_color_id': profile_accent_color_id,
      'profile_background_custom_emoji_id': profile_background_custom_emoji_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置聊天消息自动删除时间
   * @param chat_id 聊天 ID
   * @param message_auto_delete_time 时间（秒）
   */
  setChatMessageAutoDeleteTime(chat_id: number, message_auto_delete_time: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatMessageAutoDeleteTime',
      'chat_id': chat_id,
      'message_auto_delete_time': message_auto_delete_time,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置聊天表情状态
   * @param chat_id 聊天 ID
   * @param emoji_status 表情状态（null 表示移除）
   */
  setChatEmojiStatus(chat_id: number, emoji_status: emojiStatus | null): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatEmojiStatus',
      'chat_id': chat_id,
    };
    if (emoji_status !== null) {
      params['emoji_status'] = emoji_status;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置聊天权限
   * @param chat_id 聊天 ID
   * @param permissions 新权限
   */
  setChatPermissions(chat_id: number, permissions: chatPermissions): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatPermissions',
      'chat_id': chat_id,
      'permissions': permissions,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置聊天背景
   * @param chat_id 聊天 ID
   * @param background 背景输入（null 表示新建）
   * @param type 背景类型
   * @param dark_theme_dimming 暗色主题调暗百分比
   * @param only_for_self 是否仅为自己
   */
  setChatBackground(
    chat_id: number,
    background: Background | null,
    type: BackgroundType | null,
    dark_theme_dimming: number,
    only_for_self: boolean
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatBackground',
      'chat_id': chat_id,
      'dark_theme_dimming': dark_theme_dimming,
      'only_for_self': only_for_self,
    };
    if (background !== null) {
      params['background'] = background;
    }
    if (type !== null) {
      params['type'] = type;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 删除聊天背景
   * @param chat_id 聊天 ID
   * @param restore_previous 是否恢复之前的背景
   */
  deleteChatBackground(chat_id: number, restore_previous: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteChatBackground',
      'chat_id': chat_id,
      'restore_previous': restore_previous,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取礼物聊天主题
   * @param offset 偏移
   * @param limit 数量
   */
  getGiftChatThemes(offset: string, limit: number): Promise<GiftChatThemes> {
    const params: Record<string, Object> = {
      '@type': 'getGiftChatThemes',
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<GiftChatThemes>(params);
  }

  /**
   * 设置聊天主题
   * @param chat_id 聊天 ID
   * @param theme 新主题（null 表示默认）
   */
  setChatTheme(chat_id: number, theme: Object | null): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatTheme',
      'chat_id': chat_id,
    };
    if (theme !== null) {
      params['theme'] = theme;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置聊天草稿
   * @param chat_id 聊天 ID
   * @param topic_id 主题 ID
   * @param draft_message 草稿（null 表示删除）
   */
  setChatDraftMessage(chat_id: number, topic_id: MessageTopic | null, draft_message: draftMessage | null): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatDraftMessage',
      'chat_id': chat_id,
    };
    if (topic_id !== null) {
      params['topic_id'] = topic_id;
    }
    if (draft_message !== null) {
      params['draft_message'] = draft_message;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置聊天通知设置
   * @param chat_id 聊天 ID
   * @param notification_settings 新设置
   */
  setChatNotificationSettings(chat_id: number, notification_settings: chatNotificationSettings$Input): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatNotificationSettings',
      'chat_id': chat_id,
      'notification_settings': notification_settings,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换聊天内容保护
   * @param chat_id 聊天 ID
   * @param has_protected_content 是否保护
   */
  toggleChatHasProtectedContent(chat_id: number, has_protected_content: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleChatHasProtectedContent',
      'chat_id': chat_id,
      'has_protected_content': has_protected_content,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换聊天视图模式（论坛/列表）
   * @param chat_id 聊天 ID
   * @param view_as_topics 是否以主题视图显示
   */
  toggleChatViewAsTopics(chat_id: number, view_as_topics: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleChatViewAsTopics',
      'chat_id': chat_id,
      'view_as_topics': view_as_topics,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换聊天可翻译性
   * @param chat_id 聊天 ID
   * @param is_translatable 是否可翻译
   */
  toggleChatIsTranslatable(chat_id: number, is_translatable: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleChatIsTranslatable',
      'chat_id': chat_id,
      'is_translatable': is_translatable,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换聊天未读标记
   * @param chat_id 聊天 ID
   * @param is_marked_as_unread 是否标记为未读
   */
  toggleChatIsMarkedAsUnread(chat_id: number, is_marked_as_unread: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleChatIsMarkedAsUnread',
      'chat_id': chat_id,
      'is_marked_as_unread': is_marked_as_unread,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换聊天默认禁用通知
   * @param chat_id 聊天 ID
   * @param default_disable_notification 是否默认禁用通知
   */
  toggleChatDefaultDisableNotification(chat_id: number, default_disable_notification: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleChatDefaultDisableNotification',
      'chat_id': chat_id,
      'default_disable_notification': default_disable_notification,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置聊天可用反应
   * @param chat_id 聊天 ID
   * @param available_reactions 可用反应
   */
  setChatAvailableReactions(chat_id: number, available_reactions: ChatAvailableReactions): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatAvailableReactions',
      'chat_id': chat_id,
      'available_reactions': available_reactions,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置聊天客户端数据
   * @param chat_id 聊天 ID
   * @param client_data 数据
   */
  setChatClientData(chat_id: number, client_data: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatClientData',
      'chat_id': chat_id,
      'client_data': client_data,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置聊天描述
   * @param chat_id 聊天 ID
   * @param description 描述
   */
  setChatDescription(chat_id: number, description: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatDescription',
      'chat_id': chat_id,
      'description': description,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置聊天讨论组
   * @param chat_id 频道 ID
   * @param discussion_chat_id 讨论组 ID（0 表示移除）
   */
  setChatDiscussionGroup(chat_id: number, discussion_chat_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatDiscussionGroup',
      'chat_id': chat_id,
      'discussion_chat_id': discussion_chat_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置频道直聊群组
   * @param chat_id 频道 ID
   * @param is_enabled 是否启用
   * @param paid_message_star_count 付费消息星币数量
   */
  setChatDirectMessagesGroup(chat_id: number, is_enabled: boolean, paid_message_star_count: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatDirectMessagesGroup',
      'chat_id': chat_id,
      'is_enabled': is_enabled,
      'paid_message_star_count': paid_message_star_count,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置聊天位置（仅位置超级群组）
   * @param chat_id 聊天 ID
   * @param location 位置
   */
  setChatLocation(chat_id: number, location: chatLocation): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatLocation',
      'chat_id': chat_id,
      'location': location,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置聊天慢模式延迟
   * @param chat_id 聊天 ID
   * @param slow_mode_delay 延迟秒数
   */
  setChatSlowModeDelay(chat_id: number, slow_mode_delay: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatSlowModeDelay',
      'chat_id': chat_id,
      'slow_mode_delay': slow_mode_delay,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 固定消息
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param disable_notification 是否禁用通知
   * @param only_for_self 是否仅为自己（私聊）
   */
  pinChatMessage(
    chat_id: number,
    message_id: number,
    disable_notification: boolean,
    only_for_self: boolean
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'pinChatMessage',
      'chat_id': chat_id,
      'message_id': message_id,
      'disable_notification': disable_notification,
      'only_for_self': only_for_self,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 取消固定消息
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   */
  unpinChatMessage(chat_id: number, message_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'unpinChatMessage',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 取消固定所有消息
   * @param chat_id 聊天 ID
   */
  unpinAllChatMessages(chat_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'unpinAllChatMessages',
      'chat_id': chat_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 加入聊天
   * @param chat_id 聊天 ID
   */
  joinChat(chat_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'joinChat',
      'chat_id': chat_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 离开聊天
   * @param chat_id 聊天 ID
   */
  leaveChat(chat_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'leaveChat',
      'chat_id': chat_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 添加成员（单个）
   * @param chat_id 聊天 ID
   * @param user_id 用户 ID
   * @param forward_limit 转发消息数量限制
   */
  addChatMember(chat_id: number, user_id: number, forward_limit: number): Promise<FailedToAddMembers> {
    const params: Record<string, Object> = {
      '@type': 'addChatMember',
      'chat_id': chat_id,
      'user_id': user_id,
      'forward_limit': forward_limit,
    };
    return this.client.execute<FailedToAddMembers>(params);
  }

  /**
   * 添加成员（批量）
   * @param chat_id 聊天 ID
   * @param user_ids 用户 ID 列表
   */
  addChatMembers(chat_id: number, user_ids: number[]): Promise<FailedToAddMembers> {
    const params: Record<string, Object> = {
      '@type': 'addChatMembers',
      'chat_id': chat_id,
      'user_ids': user_ids,
    };
    return this.client.execute<FailedToAddMembers>(params);
  }

  /**
   * 设置成员状态
   * @param chat_id 聊天 ID
   * @param member_id 成员 ID
   * @param status 新状态
   */
  setChatMemberStatus(chat_id: number, member_id: MessageSender, status: ChatMemberStatus): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatMemberStatus',
      'chat_id': chat_id,
      'member_id': member_id,
      'status': status,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 封禁成员
   * @param chat_id 聊天 ID
   * @param member_id 成员 ID
   * @param banned_until_date 封禁截止时间戳
   * @param revoke_messages 是否删除消息
   */
  banChatMember(chat_id: number, member_id: MessageSender, banned_until_date: number,
    revoke_messages: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'banChatMember',
      'chat_id': chat_id,
      'member_id': member_id,
      'banned_until_date': banned_until_date,
      'revoke_messages': revoke_messages,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 检查能否转让所有权
   */
  canTransferOwnership(): Promise<CanTransferOwnershipResult> {
    const params: Record<string, Object> = {
      '@type': 'canTransferOwnership',
    };
    return this.client.execute<CanTransferOwnershipResult>(params);
  }

  /**
   * 转让聊天所有权
   * @param chat_id 聊天 ID
   * @param user_id 新所有者 ID
   * @param password 两步验证密码
   */
  transferChatOwnership(chat_id: number, user_id: number, password: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'transferChatOwnership',
      'chat_id': chat_id,
      'user_id': user_id,
      'password': password,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取离开后将成为所有者的用户
   * @param chat_id 聊天 ID
   */
  getChatOwnerAfterLeaving(chat_id: number): Promise<User> {
    const params: Record<string, Object> = {
      '@type': 'getChatOwnerAfterLeaving',
      'chat_id': chat_id,
    };
    return this.client.execute<User>(params);
  }

  /**
   * 获取成员信息
   * @param chat_id 聊天 ID
   * @param member_id 成员 ID
   */
  getChatMember(chat_id: number, member_id: MessageSender): Promise<ChatMember> {
    const params: Record<string, Object> = {
      '@type': 'getChatMember',
      'chat_id': chat_id,
      'member_id': member_id,
    };
    return this.client.execute<ChatMember>(params);
  }

  /**
   * 搜索成员
   * @param chat_id 聊天 ID
   * @param query 查询字符串
   * @param limit 数量
   * @param filter 过滤器
   */
  searchChatMembers(
    chat_id: number,
    query: string,
    limit: number,
    filter: Object | null
  ): Promise<ChatMembers> {
    const params: Record<string, Object> = {
      '@type': 'searchChatMembers',
      'chat_id': chat_id,
      'query': query,
      'limit': limit,
    };
    if (filter !== null) {
      params['filter'] = filter;
    }
    return this.client.execute<ChatMembers>(params);
  }

  /**
   * 获取管理员列表
   * @param chat_id 聊天 ID
   */
  getChatAdministrators(chat_id: number): Promise<ChatAdministrators> {
    const params: Record<string, Object> = {
      '@type': 'getChatAdministrators',
      'chat_id': chat_id,
    };
    return this.client.execute<ChatAdministrators>(params);
  }

  /**
   * 清除所有草稿
   * @param exclude_secret_chats 是否排除秘密聊天
   */
  clearAllDraftMessages(exclude_secret_chats: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'clearAllDraftMessages',
      'exclude_secret_chats': exclude_secret_chats,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取赌骰子状态
   */
  getStakeDiceState(): Promise<StakeDiceState> {
    const params: Record<string, Object> = {
      '@type': 'getStakeDiceState',
    };
    return this.client.execute<StakeDiceState>(params);
  }

  // ==================== 通知设置 ====================

  /**
   * 获取已保存的通知声音
   * @param notification_sound_id 声音 ID
   */
  getSavedNotificationSound(notification_sound_id: number): Promise<NotificationSounds> {
    const params: Record<string, Object> = {
      '@type': 'getSavedNotificationSound',
      'notification_sound_id': notification_sound_id,
    };
    return this.client.execute<NotificationSounds>(params);
  }

  /**
   * 获取所有已保存的通知声音
   */
  getSavedNotificationSounds(): Promise<NotificationSounds> {
    const params: Record<string, Object> = {
      '@type': 'getSavedNotificationSounds',
    };
    return this.client.execute<NotificationSounds>(params);
  }

  /**
   * 添加通知声音
   * @param sound 声音文件
   */
  addSavedNotificationSound(sound: InputFile): Promise<NotificationSound> {
    const params: Record<string, Object> = {
      '@type': 'addSavedNotificationSound',
      'sound': sound,
    };
    return this.client.execute<NotificationSound>(params);
  }

  /**
   * 移除通知声音
   * @param notification_sound_id 声音 ID
   */
  removeSavedNotificationSound(notification_sound_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeSavedNotificationSound',
      'notification_sound_id': notification_sound_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取非默认通知设置的聊天
   * @param scope 作用域
   * @param compare_sound 是否比较声音
   */
  getChatNotificationSettingsExceptions(scope: NotificationSettingsScope, compare_sound: boolean): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'getChatNotificationSettingsExceptions',
      'scope': scope,
      'compare_sound': compare_sound,
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 获取作用域通知设置
   * @param scope 作用域
   */
  getScopeNotificationSettings(scope: NotificationSettingsScope): Promise<ScopeNotificationSettings> {
    const params: Record<string, Object> = {
      '@type': 'getScopeNotificationSettings',
      'scope': scope,
    };
    return this.client.execute<ScopeNotificationSettings>(params);
  }

  /**
   * 设置作用域通知设置
   * @param scope 作用域
   * @param notification_settings 新设置
   */
  setScopeNotificationSettings(scope: NotificationSettingsScope,
    notification_settings: ScopeNotificationSettings): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setScopeNotificationSettings',
      'scope': scope,
      'notification_settings': notification_settings,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置反应通知设置
   * @param notification_settings 新设置
   */
  setReactionNotificationSettings(notification_settings: reactionNotificationSettings): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setReactionNotificationSettings',
      'notification_settings': notification_settings,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 重置所有通知设置
   */
  resetAllNotificationSettings(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'resetAllNotificationSettings',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换聊天固定状态
   * @param chat_list 聊天列表
   * @param chat_id 聊天 ID
   * @param is_pinned 是否固定
   */
  toggleChatIsPinned(chat_list: ChatList, chat_id: number, is_pinned: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleChatIsPinned',
      'chat_list': chat_list,
      'chat_id': chat_id,
      'is_pinned': is_pinned,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置固定聊天的顺序
   * @param chat_list 聊天列表
   * @param chat_ids 新顺序的聊天 ID 列表
   */
  setPinnedChats(chat_list: ChatList, chat_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setPinnedChats',
      'chat_list': chat_list,
      'chat_ids': chat_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 将聊天列表中的所有聊天标记为已读
   * @param chat_list 聊天列表
   */
  readChatList(chat_list: ChatList): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'readChatList',
      'chat_list': chat_list,
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 天气 ====================

  /**
   * 获取当前位置的天气
   * @param location 位置
   */
  getCurrentWeather(location: location): Promise<CurrentWeather> {
    const params: Record<string, Object> = {
      '@type': 'getCurrentWeather',
      'location': location,
    };
    return this.client.execute<CurrentWeather>(params);
  }

  // ==================== 故事 ====================

  /**
   * 获取故事
   * @param story_poster_chat_id 发布者聊天 ID
   * @param story_id 故事 ID
   * @param only_local 是否仅本地
   */
  getStory(story_poster_chat_id: number, story_id: number, only_local: boolean): Promise<Story> {
    const params: Record<string, Object> = {
      '@type': 'getStory',
      'story_poster_chat_id': story_poster_chat_id,
      'story_id': story_id,
      'only_local': only_local,
    };
    return this.client.execute<Story>(params);
  }

  /**
   * 获取可发布故事的聊天
   */
  getChatsToPostStories(): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'getChatsToPostStories',
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 检查能否发布故事
   * @param chat_id 聊天 ID
   */
  canPostStory(chat_id: number): Promise<CanPostStoryResult> {
    const params: Record<string, Object> = {
      '@type': 'canPostStory',
      'chat_id': chat_id,
    };
    return this.client.execute<CanPostStoryResult>(params);
  }

  /**
   * 发布故事
   * @param chat_id 聊天 ID
   * @param content 内容
   * @param areas 区域
   * @param caption 标题
   * @param privacy_settings 隐私设置
   * @param album_ids 相册 ID 列表
   * @param active_period 活动期（秒）
   * @param from_story_full_id 原故事 ID
   * @param is_posted_to_chat_page 是否发布到聊天页
   * @param protect_content 是否保护内容
   */
  postStory(
    chat_id: number,
    content: StoryContent,
    areas: StoryContent,
    caption: FormattedText,
    privacy_settings: StoryPrivacySettings,
    album_ids: number[],
    active_period: number,
    from_story_full_id: Object | null,
    is_posted_to_chat_page: boolean,
    protect_content: boolean
  ): Promise<Story> {
    const params: Record<string, Object> = {
      '@type': 'postStory',
      'chat_id': chat_id,
      'content': content,
      'areas': areas,
      'caption': caption,
      'privacy_settings': privacy_settings,
      'album_ids': album_ids,
      'active_period': active_period,
    };
    if (from_story_full_id !== null) {
      params['from_story_full_id'] = from_story_full_id;
    }
    params['is_posted_to_chat_page'] = is_posted_to_chat_page;
    params['protect_content'] = protect_content;
    return this.client.execute<Story>(params);
  }

  /**
   * 开始直播故事
   * @param chat_id 聊天 ID
   * @param privacy_settings 隐私设置
   * @param protect_content 是否保护内容
   * @param is_rtmp_stream 是否为 RTMP 流
   * @param enable_messages 是否允许消息
   * @param paid_message_star_count 付费消息星币数量
   */
  startLiveStory(
    chat_id: number,
    privacy_settings: StoryPrivacySettings,
    protect_content: boolean,
    is_rtmp_stream: boolean,
    enable_messages: boolean,
    paid_message_star_count: number
  ): Promise<StartLiveStoryResult> {
    const params: Record<string, Object> = {
      '@type': 'startLiveStory',
      'chat_id': chat_id,
      'privacy_settings': privacy_settings,
      'protect_content': protect_content,
      'is_rtmp_stream': is_rtmp_stream,
      'enable_messages': enable_messages,
      'paid_message_star_count': paid_message_star_count,
    };
    return this.client.execute<StartLiveStoryResult>(params);
  }

  /**
   * 编辑故事
   * @param story_poster_chat_id 发布者聊天 ID
   * @param story_id 故事 ID
   * @param content 新内容（null 保持不变）
   * @param areas 新区域（null 保持不变）
   * @param caption 新标题（null 保持不变）
   */
  editStory(
    story_poster_chat_id: number,
    story_id: number,
    content: StoryContent | null,
    areas: Object | null,
    caption: FormattedText | null
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'editStory',
      'story_poster_chat_id': story_poster_chat_id,
      'story_id': story_id,
    };
    if (content !== null) {
      params['content'] = content;
    }
    if (areas !== null) {
      params['areas'] = areas;
    }
    if (caption !== null) {
      params['caption'] = caption;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 编辑故事封面（视频故事）
   * @param story_poster_chat_id 发布者聊天 ID
   * @param story_id 故事 ID
   * @param cover_frame_timestamp 封面帧时间戳
   */
  editStoryCover(story_poster_chat_id: number, story_id: number, cover_frame_timestamp: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'editStoryCover',
      'story_poster_chat_id': story_poster_chat_id,
      'story_id': story_id,
      'cover_frame_timestamp': cover_frame_timestamp,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置故事隐私
   * @param story_id 故事 ID
   * @param privacy_settings 隐私设置
   */
  setStoryPrivacySettings(story_id: number, privacy_settings: StoryPrivacySettings): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setStoryPrivacySettings',
      'story_id': story_id,
      'privacy_settings': privacy_settings,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换故事是否发布到聊天页
   * @param story_poster_chat_id 发布者聊天 ID
   * @param story_id 故事 ID
   * @param is_posted_to_chat_page 是否发布
   */
  toggleStoryIsPostedToChatPage(story_poster_chat_id: number, story_id: number,
    is_posted_to_chat_page: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleStoryIsPostedToChatPage',
      'story_poster_chat_id': story_poster_chat_id,
      'story_id': story_id,
      'is_posted_to_chat_page': is_posted_to_chat_page,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 删除故事
   * @param story_poster_chat_id 发布者聊天 ID
   * @param story_id 故事 ID
   */
  deleteStory(story_poster_chat_id: number, story_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteStory',
      'story_poster_chat_id': story_poster_chat_id,
      'story_id': story_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取故事通知设置异常
   */
  getStoryNotificationSettingsExceptions(): Promise<Chats> {
    const params: Record<string, Object> = {
      '@type': 'getStoryNotificationSettingsExceptions',
    };
    return this.client.execute<Chats>(params);
  }

  /**
   * 加载更多活跃故事
   * @param story_list 故事列表
   */
  loadActiveStories(story_list: StoryList): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'loadActiveStories',
      'story_list': story_list,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置聊天的活跃故事列表
   * @param chat_id 聊天 ID
   * @param story_list 新列表
   */
  setChatActiveStoriesList(chat_id: number, story_list: StoryList): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatActiveStoriesList',
      'chat_id': chat_id,
      'story_list': story_list,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取聊天活跃故事
   * @param chat_id 聊天 ID
   */
  getChatActiveStories(chat_id: number): Promise<ChatActiveStories> {
    const params: Record<string, Object> = {
      '@type': 'getChatActiveStories',
      'chat_id': chat_id,
    };
    return this.client.execute<ChatActiveStories>(params);
  }

  /**
   * 获取聊天发布到聊天页的故事
   * @param chat_id 聊天 ID
   * @param from_story_id 起始故事 ID
   * @param limit 数量
   */
  getChatPostedToChatPageStories(chat_id: number, from_story_id: number, limit: number): Promise<Stories> {
    const params: Record<string, Object> = {
      '@type': 'getChatPostedToChatPageStories',
      'chat_id': chat_id,
      'from_story_id': from_story_id,
      'limit': limit,
    };
    return this.client.execute<Stories>(params);
  }

  /**
   * 获取聊天归档故事
   * @param chat_id 聊天 ID
   * @param from_story_id 起始故事 ID
   * @param limit 数量
   */
  getChatArchivedStories(chat_id: number, from_story_id: number, limit: number): Promise<Stories> {
    const params: Record<string, Object> = {
      '@type': 'getChatArchivedStories',
      'chat_id': chat_id,
      'from_story_id': from_story_id,
      'limit': limit,
    };
    return this.client.execute<Stories>(params);
  }

  /**
   * 设置聊天固定故事
   * @param chat_id 聊天 ID
   * @param story_ids 故事 ID 列表
   */
  setChatPinnedStories(chat_id: number, story_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatPinnedStories',
      'chat_id': chat_id,
      'story_ids': story_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 打开故事
   * @param story_poster_chat_id 发布者聊天 ID
   * @param story_id 故事 ID
   */
  openStory(story_poster_chat_id: number, story_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'openStory',
      'story_poster_chat_id': story_poster_chat_id,
      'story_id': story_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 关闭故事
   * @param story_poster_chat_id 发布者聊天 ID
   * @param story_id 故事 ID
   */
  closeStory(story_poster_chat_id: number, story_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'closeStory',
      'story_poster_chat_id': story_poster_chat_id,
      'story_id': story_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取故事可用反应
   * @param row_size 每行数量
   */
  getStoryAvailableReactions(row_size: number): Promise<AvailableReactions> {
    const params: Record<string, Object> = {
      '@type': 'getStoryAvailableReactions',
      'row_size': row_size,
    };
    return this.client.execute<AvailableReactions>(params);
  }

  /**
   * 设置故事反应
   * @param story_poster_chat_id 发布者聊天 ID
   * @param story_id 故事 ID
   * @param reaction_type 反应类型（null 表示移除）
   * @param update_recent_reactions 是否更新最近反应
   */
  setStoryReaction(
    story_poster_chat_id: number,
    story_id: number,
    reaction_type: ReactionType | null,
    update_recent_reactions: boolean
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setStoryReaction',
      'story_poster_chat_id': story_poster_chat_id,
      'story_id': story_id,
      'update_recent_reactions': update_recent_reactions,
    };
    if (reaction_type !== null) {
      params['reaction_type'] = reaction_type;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取故事互动
   * @param story_id 故事 ID
   * @param query 查询字符串
   * @param only_contacts 是否仅联系人
   * @param prefer_forwards 是否优先转发
   * @param prefer_with_reaction 是否优先有反应
   * @param offset 偏移
   * @param limit 数量
   */
  getStoryInteractions(
    story_id: number,
    query: string,
    only_contacts: boolean,
    prefer_forwards: boolean,
    prefer_with_reaction: boolean,
    offset: string,
    limit: number
  ): Promise<StoryInteractions> {
    const params: Record<string, Object> = {
      '@type': 'getStoryInteractions',
      'story_id': story_id,
      'query': query,
      'only_contacts': only_contacts,
      'prefer_forwards': prefer_forwards,
      'prefer_with_reaction': prefer_with_reaction,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<StoryInteractions>(params);
  }

  /**
   * 获取聊天故事互动（管理员）
   * @param story_poster_chat_id 发布者聊天 ID
   * @param story_id 故事 ID
   * @param reaction_type 反应类型（null 表示全部）
   * @param prefer_forwards 是否优先转发
   * @param offset 偏移
   * @param limit 数量
   */
  getChatStoryInteractions(
    story_poster_chat_id: number,
    story_id: number,
    reaction_type: ReactionType | null,
    prefer_forwards: boolean,
    offset: string,
    limit: number
  ): Promise<StoryInteractions> {
    const params: Record<string, Object> = {
      '@type': 'getChatStoryInteractions',
      'story_poster_chat_id': story_poster_chat_id,
      'story_id': story_id,
      'prefer_forwards': prefer_forwards,
      'offset': offset,
      'limit': limit,
    };
    if (reaction_type !== null) {
      params['reaction_type'] = reaction_type;
    }
    return this.client.execute<StoryInteractions>(params);
  }

  /**
   * 举报故事
   * @param story_poster_chat_id 发布者聊天 ID
   * @param story_id 故事 ID
   * @param option_id 选项 ID
   * @param text 附加文本
   */
  reportStory(story_poster_chat_id: number, story_id: number, option_id: Uint8Array,
    text: string): Promise<ReportStoryResult> {
    const params: Record<string, Object> = {
      '@type': 'reportStory',
      'story_poster_chat_id': story_poster_chat_id,
      'story_id': story_id,
      'option_id': option_id,
      'text': text,
    };
    return this.client.execute<ReportStoryResult>(params);
  }

  /**
   * 激活故事隐身模式
   */
  activateStoryStealthMode(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'activateStoryStealthMode',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取故事的公开转发
   * @param story_poster_chat_id 发布者聊天 ID
   * @param story_id 故事 ID
   * @param offset 偏移
   * @param limit 数量
   */
  getStoryPublicForwards(story_poster_chat_id: number, story_id: number, offset: string,
    limit: number): Promise<PublicForwards> {
    const params: Record<string, Object> = {
      '@type': 'getStoryPublicForwards',
      'story_poster_chat_id': story_poster_chat_id,
      'story_id': story_id,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<PublicForwards>(params);
  }

  /**
   * 获取聊天故事相册列表
   * @param chat_id 聊天 ID
   */
  getChatStoryAlbums(chat_id: number): Promise<StoryAlbums> {
    const params: Record<string, Object> = {
      '@type': 'getChatStoryAlbums',
      'chat_id': chat_id,
    };
    return this.client.execute<StoryAlbums>(params);
  }

  /**
   * 获取相册故事列表
   * @param chat_id 聊天 ID
   * @param story_album_id 相册 ID
   * @param offset 偏移
   * @param limit 数量
   */
  getStoryAlbumStories(chat_id: number, story_album_id: number, offset: number, limit: number): Promise<Stories> {
    const params: Record<string, Object> = {
      '@type': 'getStoryAlbumStories',
      'chat_id': chat_id,
      'story_album_id': story_album_id,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<Stories>(params);
  }

  /**
   * 创建故事相册
   * @param story_poster_chat_id 发布者聊天 ID
   * @param name 名称
   * @param story_ids 故事 ID 列表
   */
  createStoryAlbum(story_poster_chat_id: number, name: string, story_ids: number[]): Promise<StoryAlbum> {
    const params: Record<string, Object> = {
      '@type': 'createStoryAlbum',
      'story_poster_chat_id': story_poster_chat_id,
      'name': name,
      'story_ids': story_ids,
    };
    return this.client.execute<StoryAlbum>(params);
  }

  /**
   * 重新排序故事相册
   * @param chat_id 聊天 ID
   * @param story_album_ids 新顺序的相册 ID 列表
   */
  reorderStoryAlbums(chat_id: number, story_album_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'reorderStoryAlbums',
      'chat_id': chat_id,
      'story_album_ids': story_album_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 删除故事相册
   * @param chat_id 聊天 ID
   * @param story_album_id 相册 ID
   */
  deleteStoryAlbum(chat_id: number, story_album_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteStoryAlbum',
      'chat_id': chat_id,
      'story_album_id': story_album_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置故事相册名称
   * @param chat_id 聊天 ID
   * @param story_album_id 相册 ID
   * @param name 新名称
   */
  setStoryAlbumName(chat_id: number, story_album_id: number, name: string): Promise<StoryAlbum> {
    const params: Record<string, Object> = {
      '@type': 'setStoryAlbumName',
      'chat_id': chat_id,
      'story_album_id': story_album_id,
      'name': name,
    };
    return this.client.execute<StoryAlbum>(params);
  }

  /**
   * 向相册添加故事
   * @param chat_id 聊天 ID
   * @param story_album_id 相册 ID
   * @param story_ids 故事 ID 列表
   */
  addStoryAlbumStories(chat_id: number, story_album_id: number, story_ids: number[]): Promise<StoryAlbum> {
    const params: Record<string, Object> = {
      '@type': 'addStoryAlbumStories',
      'chat_id': chat_id,
      'story_album_id': story_album_id,
      'story_ids': story_ids,
    };
    return this.client.execute<StoryAlbum>(params);
  }

  /**
   * 从相册移除故事
   * @param chat_id 聊天 ID
   * @param story_album_id 相册 ID
   * @param story_ids 故事 ID 列表
   */
  removeStoryAlbumStories(chat_id: number, story_album_id: number, story_ids: number[]): Promise<StoryAlbum> {
    const params: Record<string, Object> = {
      '@type': 'removeStoryAlbumStories',
      'chat_id': chat_id,
      'story_album_id': story_album_id,
      'story_ids': story_ids,
    };
    return this.client.execute<StoryAlbum>(params);
  }

  /**
   * 重新排序相册中的故事
   * @param chat_id 聊天 ID
   * @param story_album_id 相册 ID
   * @param story_ids 移动到开头的故事 ID 列表
   */
  reorderStoryAlbumStories(chat_id: number, story_album_id: number, story_ids: number[]): Promise<StoryAlbum> {
    const params: Record<string, Object> = {
      '@type': 'reorderStoryAlbumStories',
      'chat_id': chat_id,
      'story_album_id': story_album_id,
      'story_ids': story_ids,
    };
    return this.client.execute<StoryAlbum>(params);
  }

  // ==================== 提升与增强 ====================

  /**
   * 获取特定提升等级的功能列表（离线）
   * @param is_channel 是否为频道
   * @param level 等级
   */
  getChatBoostLevelFeatures(is_channel: boolean, level: number): Promise<ChatBoostLevelFeatures> {
    const params: Record<string, Object> = {
      '@type': 'getChatBoostLevelFeatures',
      'is_channel': is_channel,
      'level': level,
    };
    return this.client.execute<ChatBoostLevelFeatures>(params);
  }

  /**
   * 获取各提升等级的功能列表（离线）
   * @param is_channel 是否为频道
   */
  getChatBoostFeatures(is_channel: boolean): Promise<ChatBoostFeatures> {
    const params: Record<string, Object> = {
      '@type': 'getChatBoostFeatures',
      'is_channel': is_channel,
    };
    return this.client.execute<ChatBoostFeatures>(params);
  }

  /**
   * 获取可用提升槽位
   */
  getAvailableChatBoostSlots(): Promise<ChatBoostSlots> {
    const params: Record<string, Object> = {
      '@type': 'getAvailableChatBoostSlots',
    };
    return this.client.execute<ChatBoostSlots>(params);
  }

  /**
   * 获取聊天提升状态
   * @param chat_id 聊天 ID
   */
  getChatBoostStatus(chat_id: number): Promise<ChatBoostStatus> {
    const params: Record<string, Object> = {
      '@type': 'getChatBoostStatus',
      'chat_id': chat_id,
    };
    return this.client.execute<ChatBoostStatus>(params);
  }

  /**
   * 提升聊天
   * @param chat_id 聊天 ID
   * @param slot_ids 使用的槽位 ID 列表
   */
  boostChat(chat_id: number, slot_ids: number[]): Promise<ChatBoostSlots> {
    const params: Record<string, Object> = {
      '@type': 'boostChat',
      'chat_id': chat_id,
      'slot_ids': slot_ids,
    };
    return this.client.execute<ChatBoostSlots>(params);
  }

  /**
   * 获取聊天提升链接
   * @param chat_id 聊天 ID
   */
  getChatBoostLink(chat_id: number): Promise<ChatBoostLink> {
    const params: Record<string, Object> = {
      '@type': 'getChatBoostLink',
      'chat_id': chat_id,
    };
    return this.client.execute<ChatBoostLink>(params);
  }

  /**
   * 获取聊天提升链接信息
   * @param url 链接 URL
   */
  getChatBoostLinkInfo(url: string): Promise<ChatBoostLinkInfo> {
    const params: Record<string, Object> = {
      '@type': 'getChatBoostLinkInfo',
      'url': url,
    };
    return this.client.execute<ChatBoostLinkInfo>(params);
  }

  /**
   * 获取聊天提升列表
   * @param chat_id 聊天 ID
   * @param only_gift_codes 是否仅礼包码
   * @param offset 偏移
   * @param limit 数量
   */
  getChatBoosts(chat_id: number, only_gift_codes: boolean, offset: string, limit: number): Promise<FoundChatBoosts> {
    const params: Record<string, Object> = {
      '@type': 'getChatBoosts',
      'chat_id': chat_id,
      'only_gift_codes': only_gift_codes,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<FoundChatBoosts>(params);
  }

  /**
   * 获取用户对聊天的提升（仅 Bot）
   * @param chat_id 聊天 ID
   * @param user_id 用户 ID
   */
  getUserChatBoosts(chat_id: number, user_id: number): Promise<FoundChatBoosts> {
    const params: Record<string, Object> = {
      '@type': 'getUserChatBoosts',
      'chat_id': chat_id,
      'user_id': user_id,
    };
    return this.client.execute<FoundChatBoosts>(params);
  }

  // ==================== 附件菜单机器人 ====================

  /**
   * 获取附件菜单机器人信息
   * @param bot_user_id Bot ID
   */
  getAttachmentMenuBot(bot_user_id: number): Promise<AttachmentMenuBot> {
    const params: Record<string, Object> = {
      '@type': 'getAttachmentMenuBot',
      'bot_user_id': bot_user_id,
    };
    return this.client.execute<AttachmentMenuBot>(params);
  }

  /**
   * 添加/移除附件菜单机器人
   * @param bot_user_id Bot ID
   * @param is_added 是否添加
   * @param allow_write_access 是否允许发送消息
   */
  toggleBotIsAddedToAttachmentMenu(bot_user_id: number, is_added: boolean, allow_write_access: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleBotIsAddedToAttachmentMenu',
      'bot_user_id': bot_user_id,
      'is_added': is_added,
      'allow_write_access': allow_write_access,
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 表情状态 ====================

  /**
   * 获取主题表情状态（最多 8 个）
   */
  getThemedEmojiStatuses(): Promise<EmojiStatusCustomEmojis> {
    const params: Record<string, Object> = {
      '@type': 'getThemedEmojiStatuses',
    };
    return this.client.execute<EmojiStatusCustomEmojis>(params);
  }

  /**
   * 获取最近表情状态
   */
  getRecentEmojiStatuses(): Promise<EmojiStatuses> {
    const params: Record<string, Object> = {
      '@type': 'getRecentEmojiStatuses',
    };
    return this.client.execute<EmojiStatuses>(params);
  }

  /**
   * 获取升级礼物表情状态
   */
  getUpgradedGiftEmojiStatuses(): Promise<EmojiStatuses> {
    const params: Record<string, Object> = {
      '@type': 'getUpgradedGiftEmojiStatuses',
    };
    return this.client.execute<EmojiStatuses>(params);
  }

  /**
   * 获取默认表情状态
   */
  getDefaultEmojiStatuses(): Promise<EmojiStatusCustomEmojis> {
    const params: Record<string, Object> = {
      '@type': 'getDefaultEmojiStatuses',
    };
    return this.client.execute<EmojiStatusCustomEmojis>(params);
  }

  /**
   * 清除最近表情状态
   */
  clearRecentEmojiStatuses(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'clearRecentEmojiStatuses',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取主题聊天表情状态
   */
  getThemedChatEmojiStatuses(): Promise<EmojiStatusCustomEmojis> {
    const params: Record<string, Object> = {
      '@type': 'getThemedChatEmojiStatuses',
    };
    return this.client.execute<EmojiStatusCustomEmojis>(params);
  }

  /**
   * 获取默认聊天表情状态
   */
  getDefaultChatEmojiStatuses(): Promise<EmojiStatusCustomEmojis> {
    const params: Record<string, Object> = {
      '@type': 'getDefaultChatEmojiStatuses',
    };
    return this.client.execute<EmojiStatusCustomEmojis>(params);
  }

  /**
   * 获取禁止作为聊天表情的状态
   */
  getDisallowedChatEmojiStatuses(): Promise<EmojiStatusCustomEmojis> {
    const params: Record<string, Object> = {
      '@type': 'getDisallowedChatEmojiStatuses',
    };
    return this.client.execute<EmojiStatusCustomEmojis>(params);
  }

  // ==================== 文件操作 ====================

  /**
   * 获取文件信息
   * @param file_id 文件 ID
   */
  getFile(file_id: number): Promise<File> {
    const params: Record<string, Object> = {
      '@type': 'getFile',
      'file_id': file_id,
    };
    return this.client.execute<File>(params);
  }

  /**
   * 通过远程 ID 获取文件
   * @param remote_file_id 远程 ID
   * @param file_type 文件类型
   */
  getRemoteFile(remote_file_id: string, file_type: FileType | null): Promise<File> {
    const params: Record<string, Object> = {
      '@type': 'getRemoteFile',
      'remote_file_id': remote_file_id,
    };
    if (file_type !== null) {
      params['file_type'] = file_type;
    }
    return this.client.execute<File>(params);
  }

  /**
   * 读取文件部分内容
   * @param file_id 文件 ID
   * @param offset 偏移
   * @param count 读取字节数（0 表示全部）
   */
  readFilePart(file_id: number, offset: number, count: number): Promise<Uint8Array> {
    const params: Record<string, Object> = {
      '@type': 'readFilePart',
      'file_id': file_id,
      'offset': offset,
      'count': count,
    };
    return this.client.execute<Uint8Array>(params);
  }

  /**
   * 获取已下载前缀大小
   * @param file_id 文件 ID
   * @param offset 偏移
   */
  getFileDownloadedPrefixSize(file_id: number, offset: number): Promise<number> {
    const params: Record<string, Object> = {
      '@type': 'getFileDownloadedPrefixSize',
      'file_id': file_id,
      'offset': offset,
    };
    return this.client.execute<number>(params);
  }

  /**
   * 下载文件
   * @param file_id 文件 ID
   * @param priority 优先级 (1-32)
   * @param offset 起始偏移
   * @param limit 限制字节数
   * @param synchronous 是否同步等待完成
   */
  downloadFile(file_id: number, priority: number, offset: number, limit: number, synchronous: boolean): Promise<File> {
    const params: Record<string, Object> = {
      '@type': 'downloadFile',
      'file_id': file_id,
      'priority': priority,
      'offset': offset,
      'limit': limit,
      'synchronous': synchronous,
    };
    return this.client.execute<File>(params);
  }

  /**
   * 取消下载
   * @param file_id 文件 ID
   * @param only_if_pending 仅取消未开始的下载
   */
  cancelDownloadFile(file_id: number, only_if_pending: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'cancelDownloadFile',
      'file_id': file_id,
      'only_if_pending': only_if_pending,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 预上传文件
   * @param file 文件输入
   * @param file_type 文件类型
   * @param priority 优先级
   */
  preliminaryUploadFile(file: InputFile, file_type: FileType | null, priority: number): Promise<File> {
    const params: Record<string, Object> = {
      '@type': 'preliminaryUploadFile',
      'file': file,
      'priority': priority,
    };
    if (file_type !== null) {
      params['file_type'] = file_type;
    }
    return this.client.execute<File>(params);
  }

  /**
   * 取消预上传
   * @param file_id 文件 ID
   */
  cancelPreliminaryUploadFile(file_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'cancelPreliminaryUploadFile',
      'file_id': file_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 写入生成的文件部分
   * @param generation_id 生成 ID
   * @param offset 偏移
   * @param data 数据
   */
  writeGeneratedFilePart(generation_id: number, offset: number, data: Uint8Array): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'writeGeneratedFilePart',
      'generation_id': generation_id,
      'offset': offset,
      'data': data,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置文件生成进度
   * @param generation_id 生成 ID
   * @param expected_size 预期大小
   * @param local_prefix_size 本地前缀大小
   */
  setFileGenerationProgress(generation_id: number, expected_size: number, local_prefix_size: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setFileGenerationProgress',
      'generation_id': generation_id,
      'expected_size': expected_size,
      'local_prefix_size': local_prefix_size,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 完成文件生成
   * @param generation_id 生成 ID
   * @param error 错误（成功时 null）
   */
  finishFileGeneration(generation_id: number, error: Error | null): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'finishFileGeneration',
      'generation_id': generation_id,
    };
    if (error !== null) {
      params['error'] = error;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取建议的文件名
   * @param file_id 文件 ID
   * @param directory 目录
   */
  getSuggestedFileName(file_id: number, directory: string): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getSuggestedFileName',
      'file_id': file_id,
      'directory': directory,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 删除文件
   * @param file_id 文件 ID
   */
  deleteFile(file_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteFile',
      'file_id': file_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 添加到下载列表
   * @param file_id 文件 ID
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param priority 优先级
   */
  addFileToDownloads(file_id: number, chat_id: number, message_id: number, priority: number): Promise<File> {
    const params: Record<string, Object> = {
      '@type': 'addFileToDownloads',
      'file_id': file_id,
      'chat_id': chat_id,
      'message_id': message_id,
      'priority': priority,
    };
    return this.client.execute<File>(params);
  }

  /**
   * 暂停/恢复下载
   * @param file_id 文件 ID
   * @param is_paused 是否暂停
   */
  toggleDownloadIsPaused(file_id: number, is_paused: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleDownloadIsPaused',
      'file_id': file_id,
      'is_paused': is_paused,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 暂停/恢复所有下载
   * @param are_paused 是否全部暂停
   */
  toggleAllDownloadsArePaused(are_paused: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleAllDownloadsArePaused',
      'are_paused': are_paused,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 从下载列表移除文件
   * @param file_id 文件 ID
   * @param delete_from_cache 是否从缓存删除
   */
  removeFileFromDownloads(file_id: number, delete_from_cache: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeFileFromDownloads',
      'file_id': file_id,
      'delete_from_cache': delete_from_cache,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 移除所有文件
   * @param only_active 仅活动下载
   * @param only_completed 仅已完成
   * @param delete_from_cache 是否从缓存删除
   */
  removeAllFilesFromDownloads(only_active: boolean, only_completed: boolean, delete_from_cache: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeAllFilesFromDownloads',
      'only_active': only_active,
      'only_completed': only_completed,
      'delete_from_cache': delete_from_cache,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 搜索下载的文件
   * @param query 查询字符串
   * @param only_active 仅活动
   * @param only_completed 仅已完成
   * @param offset 偏移
   * @param limit 数量
   */
  searchFileDownloads(
    query: string,
    only_active: boolean,
    only_completed: boolean,
    offset: string,
    limit: number
  ): Promise<FoundFileDownloads> {
    const params: Record<string, Object> = {
      '@type': 'searchFileDownloads',
      'query': query,
      'only_active': only_active,
      'only_completed': only_completed,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<FoundFileDownloads>(params);
  }

  /**
   * 获取自动下载设置预设
   */
  getAutoDownloadSettingsPresets(): Promise<AutoDownloadSettingsPresets> {
    const params: Record<string, Object> = {
      '@type': 'getAutoDownloadSettingsPresets',
    };
    return this.client.execute<AutoDownloadSettingsPresets>(params);
  }

  /**
   * 设置自动下载设置
   * @param settings 设置
   * @param type 网络类型
   */
  setAutoDownloadSettings(settings: Object, type: NetworkType): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setAutoDownloadSettings',
      'settings': settings,
      'type': type,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 上传贴纸文件
   * @param user_id 用户 ID
   * @param sticker_format 格式
   * @param sticker 文件
   */
  uploadStickerFile(user_id: number, sticker_format: StickerFormat, sticker: InputFile): Promise<File> {
    const params: Record<string, Object> = {
      '@type': 'uploadStickerFile',
      'user_id': user_id,
      'sticker_format': sticker_format,
      'sticker': sticker,
    };
    return this.client.execute<File>(params);
  }

  /**
   * 获取地图缩略图文件
   * @param location 位置
   * @param zoom 缩放级别
   * @param width 宽度
   * @param height 高度
   * @param scale 缩放比例
   * @param chat_id 聊天 ID
   */
  getMapThumbnailFile(
    location: location,
    zoom: number,
    width: number,
    height: number,
    scale: number,
    chat_id: number
  ): Promise<File> {
    const params: Record<string, Object> = {
      '@type': 'getMapThumbnailFile',
      'location': location,
      'zoom': zoom,
      'width': width,
      'height': height,
      'scale': scale,
      'chat_id': chat_id,
    };
    return this.client.execute<File>(params);
  }

  /**
   * 获取应用下载链接
   */
  getApplicationDownloadLink(): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getApplicationDownloadLink',
    };
    return this.client.execute<string>(params);
  }

  // ==================== 应用验证 ====================

  /**
   * 设置应用验证令牌
   * @param verification_id 验证 ID
   * @param token 令牌
   */
  setApplicationVerificationToken(verification_id: number, token: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setApplicationVerificationToken',
      'verification_id': verification_id,
      'token': token,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取消息文件类型
   * @param message_file_head 文件头部内容
   */
  getMessageFileType(message_file_head: string): Promise<MessageFileType> {
    const params: Record<string, Object> = {
      '@type': 'getMessageFileType',
      'message_file_head': message_file_head,
    };
    return this.client.execute<MessageFileType>(params);
  }

  /**
   * 获取消息导入确认文本
   * @param chat_id 聊天 ID
   */
  getMessageImportConfirmationText(chat_id: number): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getMessageImportConfirmationText',
      'chat_id': chat_id,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 导入消息
   * @param chat_id 聊天 ID
   * @param message_file 消息文件
   * @param attached_files 附件文件列表
   */
  importMessages(chat_id: number, message_file: InputFile, attached_files: InputFile[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'importMessages',
      'chat_id': chat_id,
      'message_file': message_file,
      'attached_files': attached_files,
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 邀请链接 ====================

  /**
   * 替换主邀请链接
   * @param chat_id 聊天 ID
   */
  replacePrimaryChatInviteLink(chat_id: number): Promise<ChatInviteLink> {
    const params: Record<string, Object> = {
      '@type': 'replacePrimaryChatInviteLink',
      'chat_id': chat_id,
    };
    return this.client.execute<ChatInviteLink>(params);
  }

  /**
   * 创建邀请链接
   * @param chat_id 聊天 ID
   * @param name 名称
   * @param expiration_date 过期时间戳
   * @param member_limit 成员限制
   * @param creates_join_request 是否仅创建加入请求
   */
  createChatInviteLink(
    chat_id: number,
    name: string,
    expiration_date: number,
    member_limit: number,
    creates_join_request: boolean
  ): Promise<ChatInviteLink> {
    const params: Record<string, Object> = {
      '@type': 'createChatInviteLink',
      'chat_id': chat_id,
      'name': name,
      'expiration_date': expiration_date,
      'member_limit': member_limit,
      'creates_join_request': creates_join_request,
    };
    return this.client.execute<ChatInviteLink>(params);
  }

  /**
   * 创建订阅邀请链接
   * @param chat_id 聊天 ID
   * @param name 名称
   * @param subscription_pricing 订阅定价
   */
  createChatSubscriptionInviteLink(
    chat_id: number,
    name: string,
    subscription_pricing: StarSubscriptions
  ): Promise<ChatInviteLink> {
    const params: Record<string, Object> = {
      '@type': 'createChatSubscriptionInviteLink',
      'chat_id': chat_id,
      'name': name,
      'subscription_pricing': subscription_pricing,
    };
    return this.client.execute<ChatInviteLink>(params);
  }

  /**
   * 编辑邀请链接
   * @param chat_id 聊天 ID
   * @param invite_link 链接
   * @param name 新名称
   * @param expiration_date 新过期时间
   * @param member_limit 新成员限制
   * @param creates_join_request 是否仅创建加入请求
   */
  editChatInviteLink(
    chat_id: number,
    invite_link: string,
    name: string,
    expiration_date: number,
    member_limit: number,
    creates_join_request: boolean
  ): Promise<ChatInviteLink> {
    const params: Record<string, Object> = {
      '@type': 'editChatInviteLink',
      'chat_id': chat_id,
      'invite_link': invite_link,
      'name': name,
      'expiration_date': expiration_date,
      'member_limit': member_limit,
      'creates_join_request': creates_join_request,
    };
    return this.client.execute<ChatInviteLink>(params);
  }

  /**
   * 编辑订阅邀请链接
   * @param chat_id 聊天 ID
   * @param invite_link 链接
   * @param name 新名称
   */
  editChatSubscriptionInviteLink(chat_id: number, invite_link: string, name: string): Promise<ChatInviteLink> {
    const params: Record<string, Object> = {
      '@type': 'editChatSubscriptionInviteLink',
      'chat_id': chat_id,
      'invite_link': invite_link,
      'name': name,
    };
    return this.client.execute<ChatInviteLink>(params);
  }

  /**
   * 获取邀请链接信息
   * @param chat_id 聊天 ID
   * @param invite_link 链接
   */
  getChatInviteLink(chat_id: number, invite_link: string): Promise<ChatInviteLink> {
    const params: Record<string, Object> = {
      '@type': 'getChatInviteLink',
      'chat_id': chat_id,
      'invite_link': invite_link,
    };
    return this.client.execute<ChatInviteLink>(params);
  }

  /**
   * 获取邀请链接统计
   * @param chat_id 聊天 ID
   */
  getChatInviteLinkCounts(chat_id: number): Promise<ChatInviteLinkCounts> {
    const params: Record<string, Object> = {
      '@type': 'getChatInviteLinkCounts',
      'chat_id': chat_id,
    };
    return this.client.execute<ChatInviteLinkCounts>(params);
  }

  /**
   * 获取邀请链接列表
   * @param chat_id 聊天 ID
   * @param creator_user_id 创建者 ID
   * @param is_revoked 是否已撤销
   * @param offset_date 偏移日期
   * @param offset_invite_link 偏移链接
   * @param limit 数量
   */
  getChatInviteLinks(
    chat_id: number,
    creator_user_id: number,
    is_revoked: boolean,
    offset_date: number,
    offset_invite_link: string,
    limit: number
  ): Promise<ChatInviteLinks> {
    const params: Record<string, Object> = {
      '@type': 'getChatInviteLinks',
      'chat_id': chat_id,
      'creator_user_id': creator_user_id,
      'is_revoked': is_revoked,
      'offset_date': offset_date,
      'offset_invite_link': offset_invite_link,
      'limit': limit,
    };
    return this.client.execute<ChatInviteLinks>(params);
  }

  /**
   * 获取通过邀请链接加入的成员
   * @param chat_id 聊天 ID
   * @param invite_link 链接
   * @param only_with_expired_subscription 仅已过期订阅
   * @param offset_member 偏移成员
   * @param limit 数量
   */
  getChatInviteLinkMembers(
    chat_id: number,
    invite_link: string,
    only_with_expired_subscription: boolean,
    offset_member: chatInviteLinkMember | null,
    limit: number
  ): Promise<ChatInviteLinkMembers> {
    const params: Record<string, Object> = {
      '@type': 'getChatInviteLinkMembers',
      'chat_id': chat_id,
      'invite_link': invite_link,
      'only_with_expired_subscription': only_with_expired_subscription,
      'limit': limit,
    };
    if (offset_member !== null) {
      params['offset_member'] = offset_member;
    }
    return this.client.execute<ChatInviteLinkMembers>(params);
  }

  /**
   * 撤销邀请链接
   * @param chat_id 聊天 ID
   * @param invite_link 链接
   */
  revokeChatInviteLink(chat_id: number, invite_link: string): Promise<ChatInviteLinks> {
    const params: Record<string, Object> = {
      '@type': 'revokeChatInviteLink',
      'chat_id': chat_id,
      'invite_link': invite_link,
    };
    return this.client.execute<ChatInviteLinks>(params);
  }

  /**
   * 删除已撤销的邀请链接
   * @param chat_id 聊天 ID
   * @param invite_link 链接
   */
  deleteRevokedChatInviteLink(chat_id: number, invite_link: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteRevokedChatInviteLink',
      'chat_id': chat_id,
      'invite_link': invite_link,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 删除所有已撤销的邀请链接
   * @param chat_id 聊天 ID
   * @param creator_user_id 创建者 ID
   */
  deleteAllRevokedChatInviteLinks(chat_id: number, creator_user_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteAllRevokedChatInviteLinks',
      'chat_id': chat_id,
      'creator_user_id': creator_user_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 检查邀请链接
   * @param invite_link 链接
   */
  checkChatInviteLink(invite_link: string): Promise<ChatInviteLinkInfo> {
    const params: Record<string, Object> = {
      '@type': 'checkChatInviteLink',
      'invite_link': invite_link,
    };
    return this.client.execute<ChatInviteLinkInfo>(params);
  }

  /**
   * 通过邀请链接加入聊天
   * @param invite_link 链接
   */
  joinChatByInviteLink(invite_link: string): Promise<Chat> {
    const params: Record<string, Object> = {
      '@type': 'joinChatByInviteLink',
      'invite_link': invite_link,
    };
    return this.client.execute<Chat>(params);
  }

  /**
   * 获取加入请求列表
   * @param chat_id 聊天 ID
   * @param invite_link 链接
   * @param query 查询字符串
   * @param offset_request 偏移请求
   * @param limit 数量
   */
  getChatJoinRequests(
    chat_id: number,
    invite_link: string,
    query: string,
    offset_request: chatJoinRequest | null,
    limit: number
  ): Promise<ChatJoinRequests> {
    const params: Record<string, Object> = {
      '@type': 'getChatJoinRequests',
      'chat_id': chat_id,
      'invite_link': invite_link,
      'query': query,
      'limit': limit,
    };
    if (offset_request !== null) {
      params['offset_request'] = offset_request;
    }
    return this.client.execute<ChatJoinRequests>(params);
  }

  /**
   * 处理加入请求
   * @param chat_id 聊天 ID
   * @param user_id 用户 ID
   * @param approve 是否批准
   */
  processChatJoinRequest(chat_id: number, user_id: number, approve: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'processChatJoinRequest',
      'chat_id': chat_id,
      'user_id': user_id,
      'approve': approve,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 批量处理加入请求
   * @param chat_id 聊天 ID
   * @param invite_link 链接
   * @param approve 是否批准
   */
  processChatJoinRequests(chat_id: number, invite_link: string, approve: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'processChatJoinRequests',
      'chat_id': chat_id,
      'invite_link': invite_link,
      'approve': approve,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 批准建议帖子
   * @param chat_id 频道直聊 ID
   * @param message_id 消息 ID
   * @param send_date 发布时间戳
   */
  approveSuggestedPost(chat_id: number, message_id: number, send_date: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'approveSuggestedPost',
      'chat_id': chat_id,
      'message_id': message_id,
      'send_date': send_date,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 拒绝建议帖子
   * @param chat_id 频道直聊 ID
   * @param message_id 消息 ID
   * @param comment 评论
   */
  declineSuggestedPost(chat_id: number, message_id: number, comment: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'declineSuggestedPost',
      'chat_id': chat_id,
      'message_id': message_id,
      'comment': comment,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 添加报价（建议帖子）
   * @param chat_id 频道直聊 ID
   * @param message_id 消息 ID
   * @param options 发送选项
   */
  addOffer(chat_id: number, message_id: number, options: messageSendOptions$Input): Promise<Message> {
    const params: Record<string, Object> = {
      '@type': 'addOffer',
      'chat_id': chat_id,
      'message_id': message_id,
      'options': options,
    };
    return this.client.execute<Message>(params);
  }

  // ==================== 通话与视频聊天 ====================

  /**
   * 创建通话
   * @param user_id 用户 ID
   * @param protocol 通话协议
   * @param is_video 是否视频通话
   */
  createCall(user_id: number, protocol: callProtocol, is_video: boolean): Promise<number> {
    const params: Record<string, Object> = {
      '@type': 'createCall',
      'user_id': user_id,
      'protocol': protocol,
      'is_video': is_video,
    };
    return this.client.execute<number>(params);
  }

  /**
   * 接听通话
   * @param call_id 通话 ID
   * @param protocol 通话协议
   */
  acceptCall(call_id: number, protocol: callProtocol): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'acceptCall',
      'call_id': call_id,
      'protocol': protocol,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 发送通话信令数据
   * @param call_id 通话 ID
   * @param data 数据
   */
  sendCallSignalingData(call_id: number, data: Uint8Array): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'sendCallSignalingData',
      'call_id': call_id,
      'data': data,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 挂断通话
   * @param call_id 通话 ID
   * @param is_disconnected 是否已断开
   * @param invite_link 邀请链接（升级为群组）
   * @param duration 通话时长
   * @param is_video 是否为视频通话
   * @param connection_id 连接 ID
   */
  discardCall(
    call_id: number,
    is_disconnected: boolean,
    invite_link: string,
    duration: number,
    is_video: boolean,
    connection_id: number
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'discardCall',
      'call_id': call_id,
      'is_disconnected': is_disconnected,
      'invite_link': invite_link,
      'duration': duration,
      'is_video': is_video,
      'connection_id': connection_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 发送通话评分
   * @param call_id 通话 ID
   * @param rating 评分 (1-5)
   * @param comment 评论
   * @param problems 问题列表
   */
  sendCallRating(call_id: number, rating: number, comment: string, problems: Object[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'sendCallRating',
      'call_id': call_id,
      'rating': rating,
      'comment': comment,
      'problems': problems,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 发送通话调试信息
   * @param call_id 通话 ID
   * @param debug_information 调试信息
   */
  sendCallDebugInformation(call_id: number, debug_information: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'sendCallDebugInformation',
      'call_id': call_id,
      'debug_information': debug_information,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 发送通话日志
   * @param call_id 通话 ID
   * @param log_file 日志文件
   */
  sendCallLog(call_id: number, log_file: InputFile): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'sendCallLog',
      'call_id': call_id,
      'log_file': log_file,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取视频聊天可用参与者
   * @param chat_id 聊天 ID
   */
  getVideoChatAvailableParticipants(chat_id: number): Promise<MessageSenders> {
    const params: Record<string, Object> = {
      '@type': 'getVideoChatAvailableParticipants',
      'chat_id': chat_id,
    };
    return this.client.execute<MessageSenders>(params);
  }

  /**
   * 设置视频聊天默认参与者
   * @param chat_id 聊天 ID
   * @param default_participant_id 默认参与者 ID
   */
  setVideoChatDefaultParticipant(chat_id: number, default_participant_id: MessageSender): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setVideoChatDefaultParticipant',
      'chat_id': chat_id,
      'default_participant_id': default_participant_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 创建视频聊天
   * @param chat_id 聊天 ID
   * @param title 标题
   * @param start_date 开始时间戳
   * @param is_rtmp_stream 是否为 RTMP 流
   */
  createVideoChat(chat_id: number, title: string, start_date: number, is_rtmp_stream: boolean): Promise<number> {
    const params: Record<string, Object> = {
      '@type': 'createVideoChat',
      'chat_id': chat_id,
      'title': title,
      'start_date': start_date,
      'is_rtmp_stream': is_rtmp_stream,
    };
    return this.client.execute<number>(params);
  }

  /**
   * 创建群组通话（不绑定聊天）
   * @param join_parameters 加入参数（null 表示仅创建链接）
   */
  createGroupCall(join_parameters: Object | null): Promise<GroupCallInfo> {
    const params: Record<string, Object> = {
      '@type': 'createGroupCall',
    };
    if (join_parameters !== null) {
      params['join_parameters'] = join_parameters;
    }
    return this.client.execute<GroupCallInfo>(params);
  }

  /**
   * 获取视频聊天 RTMP URL
   * @param chat_id 聊天 ID
   */
  getVideoChatRtmpUrl(chat_id: number): Promise<RtmpUrl> {
    const params: Record<string, Object> = {
      '@type': 'getVideoChatRtmpUrl',
      'chat_id': chat_id,
    };
    return this.client.execute<RtmpUrl>(params);
  }

  /**
   * 替换视频聊天 RTMP URL
   * @param chat_id 聊天 ID
   */
  replaceVideoChatRtmpUrl(chat_id: number): Promise<RtmpUrl> {
    const params: Record<string, Object> = {
      '@type': 'replaceVideoChatRtmpUrl',
      'chat_id': chat_id,
    };
    return this.client.execute<RtmpUrl>(params);
  }

  /**
   * 获取直播故事 RTMP URL
   * @param chat_id 聊天 ID
   */
  getLiveStoryRtmpUrl(chat_id: number): Promise<RtmpUrl> {
    const params: Record<string, Object> = {
      '@type': 'getLiveStoryRtmpUrl',
      'chat_id': chat_id,
    };
    return this.client.execute<RtmpUrl>(params);
  }

  /**
   * 替换直播故事 RTMP URL
   * @param chat_id 聊天 ID
   */
  replaceLiveStoryRtmpUrl(chat_id: number): Promise<RtmpUrl> {
    const params: Record<string, Object> = {
      '@type': 'replaceLiveStoryRtmpUrl',
      'chat_id': chat_id,
    };
    return this.client.execute<RtmpUrl>(params);
  }

  /**
   * 获取群组通话信息
   * @param group_call_id 群组通话 ID
   */
  getGroupCall(group_call_id: number): Promise<GroupCall> {
    const params: Record<string, Object> = {
      '@type': 'getGroupCall',
      'group_call_id': group_call_id,
    };
    return this.client.execute<GroupCall>(params);
  }

  /**
   * 开始已计划的视频聊天
   * @param group_call_id 群组通话 ID
   */
  startScheduledVideoChat(group_call_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'startScheduledVideoChat',
      'group_call_id': group_call_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换视频聊天开始通知
   * @param group_call_id 群组通话 ID
   * @param enabled_start_notification 是否启用通知
   */
  toggleVideoChatEnabledStartNotification(group_call_id: number, enabled_start_notification: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleVideoChatEnabledStartNotification',
      'group_call_id': group_call_id,
      'enabled_start_notification': enabled_start_notification,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 加入群组通话（不绑定聊天）
   * @param input_group_call 群组通话输入
   * @param join_parameters 加入参数
   */
  joinGroupCall(input_group_call: joinGroupCall, join_parameters: Object): Promise<GroupCallInfo> {
    const params: Record<string, Object> = {
      '@type': 'joinGroupCall',
      'input_group_call': input_group_call,
      'join_parameters': join_parameters,
    };
    return this.client.execute<GroupCallInfo>(params);
  }

  /**
   * 加入视频聊天
   * @param group_call_id 群组通话 ID
   * @param participant_id 参与者 ID
   * @param join_parameters 加入参数
   * @param invite_hash 邀请哈希
   */
  joinVideoChat(
    group_call_id: number,
    participant_id: MessageSender | null,
    join_parameters: Object,
    invite_hash: string
  ): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'joinVideoChat',
      'group_call_id': group_call_id,
      'join_parameters': join_parameters,
      'invite_hash': invite_hash,
    };
    if (participant_id !== null) {
      params['participant_id'] = participant_id;
    }
    return this.client.execute<string>(params);
  }

  /**
   * 加入直播故事
   * @param group_call_id 群组通话 ID
   * @param join_parameters 加入参数
   */
  joinLiveStory(group_call_id: number, join_parameters: Object): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'joinLiveStory',
      'group_call_id': group_call_id,
      'join_parameters': join_parameters,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 开始屏幕共享
   * @param group_call_id 群组通话 ID
   * @param audio_source_id 音频源 ID
   * @param payload 加入负载
   */
  startGroupCallScreenSharing(group_call_id: number, audio_source_id: number, payload: string): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'startGroupCallScreenSharing',
      'group_call_id': group_call_id,
      'audio_source_id': audio_source_id,
      'payload': payload,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 暂停/恢复屏幕共享
   * @param group_call_id 群组通话 ID
   * @param is_paused 是否暂停
   */
  toggleGroupCallScreenSharingIsPaused(group_call_id: number, is_paused: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleGroupCallScreenSharingIsPaused',
      'group_call_id': group_call_id,
      'is_paused': is_paused,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 结束屏幕共享
   * @param group_call_id 群组通话 ID
   */
  endGroupCallScreenSharing(group_call_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'endGroupCallScreenSharing',
      'group_call_id': group_call_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置视频聊天标题
   * @param group_call_id 群组通话 ID
   * @param title 新标题
   */
  setVideoChatTitle(group_call_id: number, title: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setVideoChatTitle',
      'group_call_id': group_call_id,
      'title': title,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换静音新参与者
   * @param group_call_id 群组通话 ID
   * @param mute_new_participants 是否静音新参与者
   */
  toggleVideoChatMuteNewParticipants(group_call_id: number, mute_new_participants: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleVideoChatMuteNewParticipants',
      'group_call_id': group_call_id,
      'mute_new_participants': mute_new_participants,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换是否允许消息
   * @param group_call_id 群组通话 ID
   * @param are_messages_allowed 是否允许消息
   */
  toggleGroupCallAreMessagesAllowed(group_call_id: number, are_messages_allowed: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleGroupCallAreMessagesAllowed',
      'group_call_id': group_call_id,
      'are_messages_allowed': are_messages_allowed,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取直播故事流媒体用户
   * @param group_call_id 群组通话 ID
   */
  getLiveStoryStreamer(group_call_id: number): Promise<GroupCallParticipant> {
    const params: Record<string, Object> = {
      '@type': 'getLiveStoryStreamer',
      'group_call_id': group_call_id,
    };
    return this.client.execute<GroupCallParticipant>(params);
  }

  /**
   * 获取直播故事可用消息发送者
   * @param group_call_id 群组通话 ID
   */
  getLiveStoryAvailableMessageSenders(group_call_id: number): Promise<ChatMessageSenders> {
    const params: Record<string, Object> = {
      '@type': 'getLiveStoryAvailableMessageSenders',
      'group_call_id': group_call_id,
    };
    return this.client.execute<ChatMessageSenders>(params);
  }

  /**
   * 设置直播故事消息发送者
   * @param group_call_id 群组通话 ID
   * @param message_sender_id 新发送者
   */
  setLiveStoryMessageSender(group_call_id: number, message_sender_id: MessageSender): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setLiveStoryMessageSender',
      'group_call_id': group_call_id,
      'message_sender_id': message_sender_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 发送群组通话消息
   * @param group_call_id 群组通话 ID
   * @param text 文本
   * @param paid_message_star_count 付费消息星币数量
   */
  sendGroupCallMessage(group_call_id: number, text: FormattedText, paid_message_star_count: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'sendGroupCallMessage',
      'group_call_id': group_call_id,
      'text': text,
      'paid_message_star_count': paid_message_star_count,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 添加待处理付费反应（直播故事）
   * @param group_call_id 群组通话 ID
   * @param star_count 星币数量
   */
  addPendingLiveStoryReaction(group_call_id: number, star_count: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'addPendingLiveStoryReaction',
      'group_call_id': group_call_id,
      'star_count': star_count,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 提交所有待处理付费反应
   * @param group_call_id 群组通话 ID
   */
  commitPendingLiveStoryReactions(group_call_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'commitPendingLiveStoryReactions',
      'group_call_id': group_call_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 移除所有待处理付费反应
   * @param group_call_id 群组通话 ID
   */
  removePendingLiveStoryReactions(group_call_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removePendingLiveStoryReactions',
      'group_call_id': group_call_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 删除群组通话消息
   * @param group_call_id 群组通话 ID
   * @param message_ids 消息 ID 列表
   * @param report_spam 是否举报为垃圾
   */
  deleteGroupCallMessages(group_call_id: number, message_ids: number[], report_spam: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteGroupCallMessages',
      'group_call_id': group_call_id,
      'message_ids': message_ids,
      'report_spam': report_spam,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 按发送者删除群组通话消息
   * @param group_call_id 群组通话 ID
   * @param sender_id 发送者 ID
   * @param report_spam 是否举报为垃圾
   */
  deleteGroupCallMessagesBySender(group_call_id: number, sender_id: MessageSender, report_spam: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteGroupCallMessagesBySender',
      'group_call_id': group_call_id,
      'sender_id': sender_id,
      'report_spam': report_spam,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取直播故事大额捐赠者
   * @param group_call_id 群组通话 ID
   */
  getLiveStoryTopDonors(group_call_id: number): Promise<LiveStoryDonors> {
    const params: Record<string, Object> = {
      '@type': 'getLiveStoryTopDonors',
      'group_call_id': group_call_id,
    };
    return this.client.execute<LiveStoryDonors>(params);
  }

  /**
   * 邀请群组通话参与者
   * @param group_call_id 群组通话 ID
   * @param user_id 用户 ID
   * @param is_video 是否为视频通话
   */
  inviteGroupCallParticipant(group_call_id: number, user_id: number,
    is_video: boolean): Promise<InviteGroupCallParticipantResult> {
    const params: Record<string, Object> = {
      '@type': 'inviteGroupCallParticipant',
      'group_call_id': group_call_id,
      'user_id': user_id,
      'is_video': is_video,
    };
    return this.client.execute<InviteGroupCallParticipantResult>(params);
  }

  /**
   * 拒绝群组通话邀请
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   */
  declineGroupCallInvitation(chat_id: number, message_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'declineGroupCallInvitation',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 封禁群组通话参与者
   * @param group_call_id 群组通话 ID
   * @param user_ids 用户 ID 列表
   */
  banGroupCallParticipants(group_call_id: number, user_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'banGroupCallParticipants',
      'group_call_id': group_call_id,
      'user_ids': user_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 邀请视频聊天参与者
   * @param group_call_id 群组通话 ID
   * @param user_ids 用户 ID 列表
   */
  inviteVideoChatParticipants(group_call_id: number, user_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'inviteVideoChatParticipants',
      'group_call_id': group_call_id,
      'user_ids': user_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取视频聊天邀请链接
   * @param group_call_id 群组通话 ID
   * @param can_self_unmute 是否允许自行取消静音
   */
  getVideoChatInviteLink(group_call_id: number, can_self_unmute: boolean): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getVideoChatInviteLink',
      'group_call_id': group_call_id,
      'can_self_unmute': can_self_unmute,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 撤销群组通话邀请链接
   * @param group_call_id 群组通话 ID
   */
  revokeGroupCallInviteLink(group_call_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'revokeGroupCallInviteLink',
      'group_call_id': group_call_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 开始录制群组通话
   * @param group_call_id 群组通话 ID
   * @param title 录制标题
   * @param record_video 是否录制视频
   * @param use_portrait_orientation 是否使用竖屏方向
   */
  startGroupCallRecording(group_call_id: number, title: string, record_video: boolean,
    use_portrait_orientation: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'startGroupCallRecording',
      'group_call_id': group_call_id,
      'title': title,
      'record_video': record_video,
      'use_portrait_orientation': use_portrait_orientation,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 结束录制群组通话
   * @param group_call_id 群组通话 ID
   */
  endGroupCallRecording(group_call_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'endGroupCallRecording',
      'group_call_id': group_call_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换当前用户视频是否暂停
   * @param group_call_id 群组通话 ID
   * @param is_my_video_paused 是否暂停
   */
  toggleGroupCallIsMyVideoPaused(group_call_id: number, is_my_video_paused: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleGroupCallIsMyVideoPaused',
      'group_call_id': group_call_id,
      'is_my_video_paused': is_my_video_paused,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换当前用户视频是否启用
   * @param group_call_id 群组通话 ID
   * @param is_my_video_enabled 是否启用
   */
  toggleGroupCallIsMyVideoEnabled(group_call_id: number, is_my_video_enabled: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleGroupCallIsMyVideoEnabled',
      'group_call_id': group_call_id,
      'is_my_video_enabled': is_my_video_enabled,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置直播故事付费消息星币数量
   * @param group_call_id 群组通话 ID
   * @param paid_message_star_count 星币数量
   */
  setGroupCallPaidMessageStarCount(group_call_id: number, paid_message_star_count: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setGroupCallPaidMessageStarCount',
      'group_call_id': group_call_id,
      'paid_message_star_count': paid_message_star_count,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置群组通话参与者说话状态
   * @param group_call_id 群组通话 ID
   * @param audio_source 音频源 ID
   * @param is_speaking 是否正在说话
   */
  setGroupCallParticipantIsSpeaking(group_call_id: number, audio_source: number,
    is_speaking: boolean): Promise<MessageSender> {
    const params: Record<string, Object> = {
      '@type': 'setGroupCallParticipantIsSpeaking',
      'group_call_id': group_call_id,
      'audio_source': audio_source,
      'is_speaking': is_speaking,
    };
    return this.client.execute<MessageSender>(params);
  }

  /**
   * 切换参与者静音状态
   * @param group_call_id 群组通话 ID
   * @param participant_id 参与者 ID
   * @param is_muted 是否静音
   */
  toggleGroupCallParticipantIsMuted(group_call_id: number, participant_id: MessageSender,
    is_muted: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleGroupCallParticipantIsMuted',
      'group_call_id': group_call_id,
      'participant_id': participant_id,
      'is_muted': is_muted,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置参与者音量
   * @param group_call_id 群组通话 ID
   * @param participant_id 参与者 ID
   * @param volume_level 音量级别 (1-20000 百倍百分比)
   */
  setGroupCallParticipantVolumeLevel(group_call_id: number, participant_id: MessageSender,
    volume_level: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setGroupCallParticipantVolumeLevel',
      'group_call_id': group_call_id,
      'participant_id': participant_id,
      'volume_level': volume_level,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换参与者举手状态
   * @param group_call_id 群组通话 ID
   * @param participant_id 参与者 ID
   * @param is_hand_raised 是否举手
   */
  toggleGroupCallParticipantIsHandRaised(group_call_id: number, participant_id: MessageSender,
    is_hand_raised: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleGroupCallParticipantIsHandRaised',
      'group_call_id': group_call_id,
      'participant_id': participant_id,
      'is_hand_raised': is_hand_raised,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取群组通话参与者（未加入）
   * @param input_group_call 群组通话输入
   * @param limit 数量
   */
  getGroupCallParticipants(input_group_call: joinGroupCall, limit: number): Promise<GroupCallParticipants> {
    const params: Record<string, Object> = {
      '@type': 'getGroupCallParticipants',
      'input_group_call': input_group_call,
      'limit': limit,
    };
    return this.client.execute<GroupCallParticipants>(params);
  }

  /**
   * 加载更多参与者（已加入）
   * @param group_call_id 群组通话 ID
   * @param limit 数量
   */
  loadGroupCallParticipants(group_call_id: number, limit: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'loadGroupCallParticipants',
      'group_call_id': group_call_id,
      'limit': limit,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 离开群组通话
   * @param group_call_id 群组通话 ID
   */
  leaveGroupCall(group_call_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'leaveGroupCall',
      'group_call_id': group_call_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 结束群组通话
   * @param group_call_id 群组通话 ID
   */
  endGroupCall(group_call_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'endGroupCall',
      'group_call_id': group_call_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取群组通话流
   * @param group_call_id 群组通话 ID
   */
  getGroupCallStreams(group_call_id: number): Promise<GroupCallStreams> {
    const params: Record<string, Object> = {
      '@type': 'getGroupCallStreams',
      'group_call_id': group_call_id,
    };
    return this.client.execute<GroupCallStreams>(params);
  }

  /**
   * 获取群组通话流片段
   * @param group_call_id 群组通话 ID
   * @param time_offset 时间偏移（毫秒）
   * @param scale 缩放比例
   * @param channel_id 通道 ID
   * @param video_quality 视频质量
   */
  getGroupCallStreamSegment(
    group_call_id: number,
    time_offset: number,
    scale: number,
    channel_id: number,
    video_quality: GroupCallVideoQuality$Input | null
  ): Promise<Uint8Array> {
    const params: Record<string, Object> = {
      '@type': 'getGroupCallStreamSegment',
      'group_call_id': group_call_id,
      'time_offset': time_offset,
      'scale': scale,
      'channel_id': channel_id,
    };
    if (video_quality !== null) {
      params['video_quality'] = video_quality;
    }
    return this.client.execute<Uint8Array>(params);
  }

  /**
   * 加密群组通话数据
   * @param group_call_id 群组通话 ID
   * @param data_channel 数据通道
   * @param data 数据
   * @param unencrypted_prefix_size 未加密前缀大小
   */
  encryptGroupCallData(
    group_call_id: number,
    data_channel: GroupCallDataChannel$Input,
    data: Uint8Array,
    unencrypted_prefix_size: number
  ): Promise<Uint8Array> {
    const params: Record<string, Object> = {
      '@type': 'encryptGroupCallData',
      'group_call_id': group_call_id,
      'data_channel': data_channel,
      'data': data,
      'unencrypted_prefix_size': unencrypted_prefix_size,
    };
    return this.client.execute<Uint8Array>(params);
  }

  /**
   * 解密群组通话数据
   * @param group_call_id 群组通话 ID
   * @param participant_id 参与者 ID
   * @param data_channel 数据通道（null 表示未知）
   * @param data 数据
   */
  decryptGroupCallData(
    group_call_id: number,
    participant_id: MessageSender,
    data_channel: GroupCallDataChannel$Input | null,
    data: Uint8Array
  ): Promise<Uint8Array> {
    const params: Record<string, Object> = {
      '@type': 'decryptGroupCallData',
      'group_call_id': group_call_id,
      'participant_id': participant_id,
      'data': data,
    };
    if (data_channel !== null) {
      params['data_channel'] = data_channel;
    }
    return this.client.execute<Uint8Array>(params);
  }

  // ==================== 封禁与联系人 ====================

  /**
   * 设置消息发送者封禁列表
   * @param sender_id 发送者 ID
   * @param block_list 封禁列表（null 表示解封）
   */
  setMessageSenderBlockList(sender_id: MessageSender, block_list: BlockList | null): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setMessageSenderBlockList',
      'sender_id': sender_id,
    };
    if (block_list !== null) {
      params['block_list'] = block_list;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 从回复中封禁原始发送者
   * @param message_id 消息 ID（回复聊天）
   * @param delete_message 是否删除消息
   * @param delete_all_messages 是否删除所有消息
   * @param report_spam 是否举报为垃圾
   */
  blockMessageSenderFromReplies(message_id: number, delete_message: boolean, delete_all_messages: boolean,
    report_spam: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'blockMessageSenderFromReplies',
      'message_id': message_id,
      'delete_message': delete_message,
      'delete_all_messages': delete_all_messages,
      'report_spam': report_spam,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取被屏蔽的发送者
   * @param block_list 封禁列表
   * @param offset 偏移
   * @param limit 数量
   */
  getBlockedMessageSenders(block_list: BlockList, offset: number, limit: number): Promise<MessageSenders> {
    const params: Record<string, Object> = {
      '@type': 'getBlockedMessageSenders',
      'block_list': block_list,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<MessageSenders>(params);
  }

  /**
   * 添加联系人
   * @param user_id 用户 ID
   * @param contact 联系人信息
   * @param share_phone_number 是否分享手机号
   */
  addContact(user_id: number, contact: importedContact$Input, share_phone_number: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'addContact',
      'user_id': user_id,
      'contact': contact,
      'share_phone_number': share_phone_number,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 导入联系人
   * @param contacts 联系人列表
   */
  importContacts(contacts: importedContact$Input[]): Promise<ImportedContacts> {
    const params: Record<string, Object> = {
      '@type': 'importContacts',
      'contacts': contacts,
    };
    return this.client.execute<ImportedContacts>(params);
  }

  /**
   * 获取所有联系人
   */
  getContacts(): Promise<Users> {
    const params: Record<string, Object> = {
      '@type': 'getContacts',
    };
    return this.client.execute<Users>(params);
  }

  /**
   * 搜索联系人
   * @param query 查询字符串
   * @param limit 数量
   */
  searchContacts(query: string, limit: number): Promise<Users> {
    const params: Record<string, Object> = {
      '@type': 'searchContacts',
      'query': query,
      'limit': limit,
    };
    return this.client.execute<Users>(params);
  }

  /**
   * 移除联系人
   * @param user_ids 用户 ID 列表
   */
  removeContacts(user_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeContacts',
      'user_ids': user_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取导入联系人数量
   */
  getImportedContactCount(): Promise<number> {
    const params: Record<string, Object> = {
      '@type': 'getImportedContactCount',
    };
    return this.client.execute<number>(params);
  }

  /**
   * 更改导入的联系人
   * @param contacts 新联系人列表
   */
  changeImportedContacts(contacts: ImportedContacts[]): Promise<ImportedContacts> {
    const params: Record<string, Object> = {
      '@type': 'changeImportedContacts',
      'contacts': contacts,
    };
    return this.client.execute<ImportedContacts>(params);
  }

  /**
   * 清除导入的联系人
   */
  clearImportedContacts(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'clearImportedContacts',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置密友列表
   * @param user_ids 用户 ID 列表
   */
  setCloseFriends(user_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setCloseFriends',
      'user_ids': user_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取密友列表
   */
  getCloseFriends(): Promise<Users> {
    const params: Record<string, Object> = {
      '@type': 'getCloseFriends',
    };
    return this.client.execute<Users>(params);
  }

  // ==================== 贴纸与表情 ====================

  /**
   * 获取贴纸轮廓（离线）
   * @param sticker_file_id 贴纸文件 ID
   * @param for_animated_emoji 是否用于动态表情
   * @param for_clicked_animated_emoji_message 是否用于点击动态表情消息
   */
  getStickerOutline(sticker_file_id: number, for_animated_emoji: boolean,
    for_clicked_animated_emoji_message: boolean): Promise<Outline> {
    const params: Record<string, Object> = {
      '@type': 'getStickerOutline',
      'sticker_file_id': sticker_file_id,
      'for_animated_emoji': for_animated_emoji,
      'for_clicked_animated_emoji_message': for_clicked_animated_emoji_message,
    };
    return this.client.execute<Outline>(params);
  }

  /**
   * 获取贴纸轮廓 SVG 路径（离线）
   * @param sticker_file_id 贴纸文件 ID
   * @param for_animated_emoji 是否用于动态表情
   * @param for_clicked_animated_emoji_message 是否用于点击动态表情消息
   */
  getStickerOutlineSvgPath(sticker_file_id: number, for_animated_emoji: boolean,
    for_clicked_animated_emoji_message: boolean): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getStickerOutlineSvgPath',
      'sticker_file_id': sticker_file_id,
      'for_animated_emoji': for_animated_emoji,
      'for_clicked_animated_emoji_message': for_clicked_animated_emoji_message,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 获取贴纸
   * @param sticker_type 贴纸类型
   * @param query 查询字符串
   * @param limit 数量
   * @param chat_id 聊天 ID
   */
  getStickers(sticker_type: StickerType, query: string, limit: number, chat_id: number): Promise<Stickers> {
    const params: Record<string, Object> = {
      '@type': 'getStickers',
      'sticker_type': sticker_type,
      'query': query,
      'limit': limit,
      'chat_id': chat_id,
    };
    return this.client.execute<Stickers>(params);
  }

  /**
   * 获取所有贴纸表情
   * @param sticker_type 贴纸类型
   * @param query 查询字符串
   * @param chat_id 聊天 ID
   * @param return_only_main_emoji 是否仅返回主表情
   */
  getAllStickerEmojis(sticker_type: StickerType, query: string, chat_id: number,
    return_only_main_emoji: boolean): Promise<string[]> {
    const params: Record<string, Object> = {
      '@type': 'getAllStickerEmojis',
      'sticker_type': sticker_type,
      'query': query,
      'chat_id': chat_id,
      'return_only_main_emoji': return_only_main_emoji,
    };
    return this.client.execute<string[]>(params);
  }

  /**
   * 搜索贴纸
   * @param sticker_type 贴纸类型
   * @param emojis 表情列表（空格分隔）
   * @param query 查询字符串
   * @param input_language_codes 输入语言列表
   * @param offset 偏移
   * @param limit 数量
   */
  searchStickers(
    sticker_type: StickerType,
    emojis: string,
    query: string,
    input_language_codes: string[],
    offset: number,
    limit: number
  ): Promise<Stickers> {
    const params: Record<string, Object> = {
      '@type': 'searchStickers',
      'sticker_type': sticker_type,
      'emojis': emojis,
      'query': query,
      'input_language_codes': input_language_codes,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<Stickers>(params);
  }

  /**
   * 获取问候贴纸
   */
  getGreetingStickers(): Promise<Stickers> {
    const params: Record<string, Object> = {
      '@type': 'getGreetingStickers',
    };
    return this.client.execute<Stickers>(params);
  }

  /**
   * 获取 Premium 贴纸
   * @param limit 数量
   */
  getPremiumStickers(limit: number): Promise<Stickers> {
    const params: Record<string, Object> = {
      '@type': 'getPremiumStickers',
      'limit': limit,
    };
    return this.client.execute<Stickers>(params);
  }

  /**
   * 获取已安装贴纸集
   * @param sticker_type 贴纸类型
   */
  getInstalledStickerSets(sticker_type: StickerType): Promise<StickerSets> {
    const params: Record<string, Object> = {
      '@type': 'getInstalledStickerSets',
      'sticker_type': sticker_type,
    };
    return this.client.execute<StickerSets>(params);
  }

  /**
   * 获取已归档贴纸集
   * @param sticker_type 贴纸类型
   * @param offset_sticker_set_id 偏移贴纸集 ID
   * @param limit 数量
   */
  getArchivedStickerSets(sticker_type: StickerType, offset_sticker_set_id: number,
    limit: number): Promise<StickerSets> {
    const params: Record<string, Object> = {
      '@type': 'getArchivedStickerSets',
      'sticker_type': sticker_type,
      'offset_sticker_set_id': offset_sticker_set_id,
      'limit': limit,
    };
    return this.client.execute<StickerSets>(params);
  }

  /**
   * 获取流行贴纸集
   * @param sticker_type 贴纸类型
   * @param offset 偏移
   * @param limit 数量
   */
  getTrendingStickerSets(sticker_type: StickerType, offset: number, limit: number): Promise<TrendingStickerSets> {
    const params: Record<string, Object> = {
      '@type': 'getTrendingStickerSets',
      'sticker_type': sticker_type,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<TrendingStickerSets>(params);
  }

  /**
   * 获取附加贴纸集（动画/照片/视频）
   * @param file_id 文件 ID
   */
  getAttachedStickerSets(file_id: number): Promise<StickerSets> {
    const params: Record<string, Object> = {
      '@type': 'getAttachedStickerSets',
      'file_id': file_id,
    };
    return this.client.execute<StickerSets>(params);
  }

  /**
   * 获取贴纸集信息
   * @param set_id 贴纸集 ID
   */
  getStickerSet(set_id: number): Promise<StickerSet> {
    const params: Record<string, Object> = {
      '@type': 'getStickerSet',
      'set_id': set_id,
    };
    return this.client.execute<StickerSet>(params);
  }

  /**
   * 获取贴纸集名称
   * @param set_id 贴纸集 ID
   */
  getStickerSetName(set_id: number): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getStickerSetName',
      'set_id': set_id,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 搜索贴纸集
   * @param name 名称
   * @param ignore_cache 是否忽略缓存
   */
  searchStickerSet(name: string, ignore_cache: boolean): Promise<StickerSet> {
    const params: Record<string, Object> = {
      '@type': 'searchStickerSet',
      'name': name,
      'ignore_cache': ignore_cache,
    };
    return this.client.execute<StickerSet>(params);
  }

  /**
   * 搜索已安装贴纸集
   * @param sticker_type 贴纸类型
   * @param query 查询字符串
   * @param limit 数量
   */
  searchInstalledStickerSets(sticker_type: StickerType, query: string, limit: number): Promise<StickerSets> {
    const params: Record<string, Object> = {
      '@type': 'searchInstalledStickerSets',
      'sticker_type': sticker_type,
      'query': query,
      'limit': limit,
    };
    return this.client.execute<StickerSets>(params);
  }

  /**
   * 搜索贴纸集（不包括已安装）
   * @param sticker_type 贴纸类型
   * @param query 查询字符串
   */
  searchStickerSets(sticker_type: StickerType, query: string): Promise<StickerSets> {
    const params: Record<string, Object> = {
      '@type': 'searchStickerSets',
      'sticker_type': sticker_type,
      'query': query,
    };
    return this.client.execute<StickerSets>(params);
  }

  /**
   * 更改贴纸集状态（安装/归档）
   * @param set_id 贴纸集 ID
   * @param is_installed 是否安装
   * @param is_archived 是否归档
   */
  changeStickerSet(set_id: number, is_installed: boolean, is_archived: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'changeStickerSet',
      'set_id': set_id,
      'is_installed': is_installed,
      'is_archived': is_archived,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 标记流行贴纸集已查看
   * @param sticker_set_ids 贴纸集 ID 列表
   */
  viewTrendingStickerSets(sticker_set_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'viewTrendingStickerSets',
      'sticker_set_ids': sticker_set_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 重新排序已安装贴纸集
   * @param sticker_type 贴纸类型
   * @param sticker_set_ids 新顺序的 ID 列表
   */
  reorderInstalledStickerSets(sticker_type: StickerType, sticker_set_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'reorderInstalledStickerSets',
      'sticker_type': sticker_type,
      'sticker_set_ids': sticker_set_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取最近使用的贴纸
   * @param is_attached 是否附加到照片/视频
   */
  getRecentStickers(is_attached: boolean): Promise<Stickers> {
    const params: Record<string, Object> = {
      '@type': 'getRecentStickers',
      'is_attached': is_attached,
    };
    return this.client.execute<Stickers>(params);
  }

  /**
   * 添加最近使用的贴纸
   * @param is_attached 是否附加
   * @param sticker 贴纸文件
   */
  addRecentSticker(is_attached: boolean, sticker: InputFile): Promise<Stickers> {
    const params: Record<string, Object> = {
      '@type': 'addRecentSticker',
      'is_attached': is_attached,
      'sticker': sticker,
    };
    return this.client.execute<Stickers>(params);
  }

  /**
   * 移除最近使用的贴纸
   * @param is_attached 是否附加
   * @param sticker 贴纸文件
   */
  removeRecentSticker(is_attached: boolean, sticker: InputFile): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeRecentSticker',
      'is_attached': is_attached,
      'sticker': sticker,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 清除最近使用的贴纸
   * @param is_attached 是否附加
   */
  clearRecentStickers(is_attached: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'clearRecentStickers',
      'is_attached': is_attached,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取收藏贴纸
   */
  getFavoriteStickers(): Promise<Stickers> {
    const params: Record<string, Object> = {
      '@type': 'getFavoriteStickers',
    };
    return this.client.execute<Stickers>(params);
  }

  /**
   * 添加收藏贴纸
   * @param sticker 贴纸文件
   */
  addFavoriteSticker(sticker: InputFile): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'addFavoriteSticker',
      'sticker': sticker,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 移除收藏贴纸
   * @param sticker 贴纸文件
   */
  removeFavoriteSticker(sticker: InputFile): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeFavoriteSticker',
      'sticker': sticker,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取贴纸对应的表情
   * @param sticker 贴纸文件
   */
  getStickerEmojis(sticker: InputFile): Promise<string[]> {
    const params: Record<string, Object> = {
      '@type': 'getStickerEmojis',
      'sticker': sticker,
    };
    return this.client.execute<string[]>(params);
  }

  /**
   * 按关键词搜索表情
   * @param text 文本
   * @param input_language_codes 输入语言列表
   */
  searchEmojis(text: string, input_language_codes: string[]): Promise<EmojiKeywords> {
    const params: Record<string, Object> = {
      '@type': 'searchEmojis',
      'text': text,
      'input_language_codes': input_language_codes,
    };
    return this.client.execute<EmojiKeywords>(params);
  }

  /**
   * 获取关键词表情
   * @param text 文本
   * @param input_language_codes 输入语言列表
   */
  getKeywordEmojis(text: string, input_language_codes: string[]): Promise<string[]> {
    const params: Record<string, Object> = {
      '@type': 'getKeywordEmojis',
      'text': text,
      'input_language_codes': input_language_codes,
    };
    return this.client.execute<string[]>(params);
  }

  /**
   * 获取表情类别
   * @param type 类别类型
   */
  getEmojiCategories(type: EmojiCategories | null): Promise<EmojiCategories> {
    const params: Record<string, Object> = {
      '@type': 'getEmojiCategories',
    };
    if (type !== null) {
      params['type'] = type;
    }
    return this.client.execute<EmojiCategories>(params);
  }

  /**
   * 获取动态表情
   * @param emoji 表情符号
   */
  getAnimatedEmoji(emoji: string): Promise<AnimatedEmoji> {
    const params: Record<string, Object> = {
      '@type': 'getAnimatedEmoji',
      'emoji': emoji,
    };
    return this.client.execute<AnimatedEmoji>(params);
  }

  /**
   * 获取表情建议链接
   * @param language_code 语言代码
   */
  getEmojiSuggestionsUrl(language_code: string): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getEmojiSuggestionsUrl',
      'language_code': language_code,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 获取自定义表情贴纸
   * @param custom_emoji_ids 自定义表情 ID 列表
   */
  getCustomEmojiStickers(custom_emoji_ids: number[]): Promise<Stickers> {
    const params: Record<string, Object> = {
      '@type': 'getCustomEmojiStickers',
      'custom_emoji_ids': custom_emoji_ids,
    };
    return this.client.execute<Stickers>(params);
  }

  /**
   * 获取默认聊天照片自定义表情
   */
  getDefaultChatPhotoCustomEmojiStickers(): Promise<Stickers> {
    const params: Record<string, Object> = {
      '@type': 'getDefaultChatPhotoCustomEmojiStickers',
    };
    return this.client.execute<Stickers>(params);
  }

  /**
   * 获取默认个人资料照片自定义表情
   */
  getDefaultProfilePhotoCustomEmojiStickers(): Promise<Stickers> {
    const params: Record<string, Object> = {
      '@type': 'getDefaultProfilePhotoCustomEmojiStickers',
    };
    return this.client.execute<Stickers>(params);
  }

  /**
   * 获取默认背景自定义表情
   */
  getDefaultBackgroundCustomEmojiStickers(): Promise<Stickers> {
    const params: Record<string, Object> = {
      '@type': 'getDefaultBackgroundCustomEmojiStickers',
    };
    return this.client.execute<Stickers>(params);
  }

  /**
   * 获取已保存动画
   */
  getSavedAnimations(): Promise<Animations> {
    const params: Record<string, Object> = {
      '@type': 'getSavedAnimations',
    };
    return this.client.execute<Animations>(params);
  }

  /**
   * 添加保存动画
   * @param animation 动画文件
   */
  addSavedAnimation(animation: InputFile): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'addSavedAnimation',
      'animation': animation,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 移除保存动画
   * @param animation 动画文件
   */
  removeSavedAnimation(animation: InputFile): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeSavedAnimation',
      'animation': animation,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取最近使用的内联 Bot
   */
  getRecentInlineBots(): Promise<Users> {
    const params: Record<string, Object> = {
      '@type': 'getRecentInlineBots',
    };
    return this.client.execute<Users>(params);
  }

  /**
   * 获取当前用户拥有的 Bot
   */
  getOwnedBots(): Promise<Users> {
    const params: Record<string, Object> = {
      '@type': 'getOwnedBots',
    };
    return this.client.execute<Users>(params);
  }

  /**
   * 搜索标签（话题/货币）
   * @param prefix 前缀
   * @param limit 数量
   */
  searchHashtags(prefix: string, limit: number): Promise<string[]> {
    const params: Record<string, Object> = {
      '@type': 'searchHashtags',
      'prefix': prefix,
      'limit': limit,
    };
    return this.client.execute<string[]>(params);
  }

  /**
   * 移除最近使用的标签
   * @param hashtag 标签
   */
  removeRecentHashtag(hashtag: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeRecentHashtag',
      'hashtag': hashtag,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取链接预览
   * @param text 文本
   * @param link_preview_options 预览选项
   */
  getLinkPreview(text: FormattedText, link_preview_options: Object | null): Promise<LinkPreview> {
    const params: Record<string, Object> = {
      '@type': 'getLinkPreview',
      'text': text,
    };
    if (link_preview_options !== null) {
      params['link_preview_options'] = link_preview_options;
    }
    return this.client.execute<LinkPreview>(params);
  }

  /**
   * 获取网页即时视图
   * @param url URL
   * @param only_local 是否仅本地
   */
  getWebPageInstantView(url: string, only_local: boolean): Promise<WebPageInstantView> {
    const params: Record<string, Object> = {
      '@type': 'getWebPageInstantView',
      'url': url,
      'only_local': only_local,
    };
    return this.client.execute<WebPageInstantView>(params);
  }

  // ==================== 机器人命令与菜单 ====================

  /**
   * 设置机器人命令（仅 Bot）
   * @param scope 作用域
   * @param language_code 语言代码
   * @param commands 命令列表
   */
  setCommands(scope: BotCommands | null, language_code: string, commands: botCommand[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setCommands',
      'language_code': language_code,
      'commands': commands,
    };
    if (scope !== null) {
      params['scope'] = scope;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 删除机器人命令（仅 Bot）
   * @param scope 作用域
   * @param language_code 语言代码
   */
  deleteCommands(scope: BotCommands | null, language_code: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteCommands',
      'language_code': language_code,
    };
    if (scope !== null) {
      params['scope'] = scope;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取机器人命令（仅 Bot）
   * @param scope 作用域
   * @param language_code 语言代码
   */
  getCommands(scope: BotCommands | null, language_code: string): Promise<BotCommands> {
    const params: Record<string, Object> = {
      '@type': 'getCommands',
      'language_code': language_code,
    };
    if (scope !== null) {
      params['scope'] = scope;
    }
    return this.client.execute<BotCommands>(params);
  }

  /**
   * 设置菜单按钮（仅 Bot）
   * @param user_id 用户 ID（0 表示全局）
   * @param menu_button 菜单按钮
   */
  setMenuButton(user_id: number, menu_button: BotMenuButton): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setMenuButton',
      'user_id': user_id,
      'menu_button': menu_button,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取菜单按钮（仅 Bot）
   * @param user_id 用户 ID（0 表示默认）
   */
  getMenuButton(user_id: number): Promise<BotMenuButton> {
    const params: Record<string, Object> = {
      '@type': 'getMenuButton',
      'user_id': user_id,
    };
    return this.client.execute<BotMenuButton>(params);
  }

  /**
   * 设置默认群组管理员权限（仅 Bot）
   * @param default_group_administrator_rights 权限（null 表示移除）
   */
  setDefaultGroupAdministratorRights(default_group_administrator_rights: chatAdministratorRights | null): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setDefaultGroupAdministratorRights',
    };
    if (default_group_administrator_rights !== null) {
      params['default_group_administrator_rights'] = default_group_administrator_rights;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置默认频道管理员权限（仅 Bot）
   * @param default_channel_administrator_rights 权限（null 表示移除）
   */
  setDefaultChannelAdministratorRights(default_channel_administrator_rights: chatAdministratorRights | null): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setDefaultChannelAdministratorRights',
    };
    if (default_channel_administrator_rights !== null) {
      params['default_channel_administrator_rights'] = default_channel_administrator_rights;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 检查 Bot 是否可以发送消息
   * @param bot_user_id Bot ID
   */
  canBotSendMessages(bot_user_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'canBotSendMessages',
      'bot_user_id': bot_user_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 允许 Bot 发送消息
   * @param bot_user_id Bot ID
   */
  allowBotToSendMessages(bot_user_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'allowBotToSendMessages',
      'bot_user_id': bot_user_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 发送 Web App 自定义请求（仅 Bot）
   * @param bot_user_id Bot ID
   * @param method 方法名
   * @param parameters JSON 参数
   */
  sendWebAppCustomRequest(bot_user_id: number, method: string, parameters: string): Promise<CustomRequestResult> {
    const params: Record<string, Object> = {
      '@type': 'sendWebAppCustomRequest',
      'bot_user_id': bot_user_id,
      'method': method,
      'parameters': parameters,
    };
    return this.client.execute<CustomRequestResult>(params);
  }

  /**
   * 获取 Bot 媒体预览（仅 Bot）
   * @param bot_user_id Bot ID
   */
  getBotMediaPreviews(bot_user_id: number): Promise<BotMediaPreviews> {
    const params: Record<string, Object> = {
      '@type': 'getBotMediaPreviews',
      'bot_user_id': bot_user_id,
    };
    return this.client.execute<BotMediaPreviews>(params);
  }

  /**
   * 获取 Bot 媒体预览信息（仅 Bot）
   * @param bot_user_id Bot ID
   * @param language_code 语言代码
   */
  getBotMediaPreviewInfo(bot_user_id: number, language_code: string): Promise<BotMediaPreviewInfo> {
    const params: Record<string, Object> = {
      '@type': 'getBotMediaPreviewInfo',
      'bot_user_id': bot_user_id,
      'language_code': language_code,
    };
    return this.client.execute<BotMediaPreviewInfo>(params);
  }

  /**
   * 添加 Bot 媒体预览（仅 Bot）
   * @param bot_user_id Bot ID
   * @param language_code 语言代码
   * @param content 预览内容
   */
  addBotMediaPreview(bot_user_id: number, language_code: string, content: StoryContent): Promise<BotMediaPreview> {
    const params: Record<string, Object> = {
      '@type': 'addBotMediaPreview',
      'bot_user_id': bot_user_id,
      'language_code': language_code,
      'content': content,
    };
    return this.client.execute<BotMediaPreview>(params);
  }

  /**
   * 编辑 Bot 媒体预览（仅 Bot）
   * @param bot_user_id Bot ID
   * @param language_code 语言代码
   * @param file_id 文件 ID
   * @param content 新内容
   */
  editBotMediaPreview(bot_user_id: number, language_code: string, file_id: number,
    content: StoryContent): Promise<BotMediaPreview> {
    const params: Record<string, Object> = {
      '@type': 'editBotMediaPreview',
      'bot_user_id': bot_user_id,
      'language_code': language_code,
      'file_id': file_id,
      'content': content,
    };
    return this.client.execute<BotMediaPreview>(params);
  }

  /**
   * 重新排序 Bot 媒体预览（仅 Bot）
   * @param bot_user_id Bot ID
   * @param language_code 语言代码
   * @param file_ids 文件 ID 列表（新顺序）
   */
  reorderBotMediaPreviews(bot_user_id: number, language_code: string, file_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'reorderBotMediaPreviews',
      'bot_user_id': bot_user_id,
      'language_code': language_code,
      'file_ids': file_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 删除 Bot 媒体预览（仅 Bot）
   * @param bot_user_id Bot ID
   * @param language_code 语言代码
   * @param file_ids 文件 ID 列表
   */
  deleteBotMediaPreviews(bot_user_id: number, language_code: string, file_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteBotMediaPreviews',
      'bot_user_id': bot_user_id,
      'language_code': language_code,
      'file_ids': file_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置 Bot 名称（仅 Bot）
   * @param bot_user_id Bot ID
   * @param language_code 语言代码
   * @param name 名称
   */
  setBotName(bot_user_id: number, language_code: string, name: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setBotName',
      'bot_user_id': bot_user_id,
      'language_code': language_code,
      'name': name,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取 Bot 名称（仅 Bot）
   * @param bot_user_id Bot ID
   * @param language_code 语言代码
   */
  getBotName(bot_user_id: number, language_code: string): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getBotName',
      'bot_user_id': bot_user_id,
      'language_code': language_code,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 设置 Bot 头像（仅 Bot）
   * @param bot_user_id Bot ID
   * @param photo 头像（null 表示删除）
   */
  setBotProfilePhoto(bot_user_id: number, photo: InputChatPhoto$Input | null): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setBotProfilePhoto',
      'bot_user_id': bot_user_id,
    };
    if (photo !== null) {
      params['photo'] = photo;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换 Bot 用户名活动状态（仅 Bot）
   * @param bot_user_id Bot ID
   * @param username 用户名
   * @param is_active 是否激活
   */
  toggleBotUsernameIsActive(bot_user_id: number, username: string, is_active: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleBotUsernameIsActive',
      'bot_user_id': bot_user_id,
      'username': username,
      'is_active': is_active,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 重新排序 Bot 活跃用户名（仅 Bot）
   * @param bot_user_id Bot ID
   * @param usernames 用户名列表（新顺序）
   */
  reorderBotActiveUsernames(bot_user_id: number, usernames: string[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'reorderBotActiveUsernames',
      'bot_user_id': bot_user_id,
      'usernames': usernames,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置 Bot 信息描述（仅 Bot）
   * @param bot_user_id Bot ID
   * @param language_code 语言代码
   * @param description 描述
   */
  setBotInfoDescription(bot_user_id: number, language_code: string, description: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setBotInfoDescription',
      'bot_user_id': bot_user_id,
      'language_code': language_code,
      'description': description,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取 Bot 信息描述（仅 Bot）
   * @param bot_user_id Bot ID
   * @param language_code 语言代码
   */
  getBotInfoDescription(bot_user_id: number, language_code: string): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getBotInfoDescription',
      'bot_user_id': bot_user_id,
      'language_code': language_code,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 设置 Bot 短描述（仅 Bot）
   * @param bot_user_id Bot ID
   * @param language_code 语言代码
   * @param short_description 短描述
   */
  setBotInfoShortDescription(bot_user_id: number, language_code: string, short_description: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setBotInfoShortDescription',
      'bot_user_id': bot_user_id,
      'language_code': language_code,
      'short_description': short_description,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取 Bot 短描述（仅 Bot）
   * @param bot_user_id Bot ID
   * @param language_code 语言代码
   */
  getBotInfoShortDescription(bot_user_id: number, language_code: string): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getBotInfoShortDescription',
      'bot_user_id': bot_user_id,
      'language_code': language_code,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 设置消息发送者 Bot 验证（仅 Bot）
   * @param bot_user_id Bot ID
   * @param verified_id 验证对象 ID
   * @param custom_description 自定义描述
   */
  setMessageSenderBotVerification(bot_user_id: number, verified_id: MessageSender,
    custom_description: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setMessageSenderBotVerification',
      'bot_user_id': bot_user_id,
      'verified_id': verified_id,
      'custom_description': custom_description,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 移除消息发送者 Bot 验证（仅 Bot）
   * @param bot_user_id Bot ID
   * @param verified_id 验证对象 ID
   */
  removeMessageSenderBotVerification(bot_user_id: number, verified_id: MessageSender): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeMessageSenderBotVerification',
      'bot_user_id': bot_user_id,
      'verified_id': verified_id,
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 会话与网站 ====================

  /**
   * 获取活动会话
   */
  getActiveSessions(): Promise<Sessions> {
    const params: Record<string, Object> = {
      '@type': 'getActiveSessions',
    };
    return this.client.execute<Sessions>(params);
  }

  /**
   * 终止会话
   * @param session_id 会话 ID
   */
  terminateSession(session_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'terminateSession',
      'session_id': session_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 终止所有其他会话
   */
  terminateAllOtherSessions(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'terminateAllOtherSessions',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 确认未确认会话
   * @param session_id 会话 ID
   */
  confirmSession(session_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'confirmSession',
      'session_id': session_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换会话是否可接听电话
   * @param session_id 会话 ID
   * @param can_accept_calls 是否允许接听电话
   */
  toggleSessionCanAcceptCalls(session_id: number, can_accept_calls: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleSessionCanAcceptCalls',
      'session_id': session_id,
      'can_accept_calls': can_accept_calls,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换会话是否可接受秘密聊天
   * @param session_id 会话 ID
   * @param can_accept_secret_chats 是否允许接受秘密聊天
   */
  toggleSessionCanAcceptSecretChats(session_id: number, can_accept_secret_chats: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleSessionCanAcceptSecretChats',
      'session_id': session_id,
      'can_accept_secret_chats': can_accept_secret_chats,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置非活动会话自动终止时间
   * @param inactive_session_ttl_days 天数
   */
  setInactiveSessionTtl(inactive_session_ttl_days: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setInactiveSessionTtl',
      'inactive_session_ttl_days': inactive_session_ttl_days,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取连接的网站
   */
  getConnectedWebsites(): Promise<ConnectedWebsites> {
    const params: Record<string, Object> = {
      '@type': 'getConnectedWebsites',
    };
    return this.client.execute<ConnectedWebsites>(params);
  }

  /**
   * 断开网站连接
   * @param website_id 网站 ID
   */
  disconnectWebsite(website_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'disconnectWebsite',
      'website_id': website_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 断开所有网站连接
   */
  disconnectAllWebsites(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'disconnectAllWebsites',
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 超级群组管理 ====================

  /**
   * 设置超级群组/频道用户名
   * @param supergroup_id 超级群组 ID
   * @param username 用户名
   */
  setSupergroupUsername(supergroup_id: number, username: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setSupergroupUsername',
      'supergroup_id': supergroup_id,
      'username': username,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换超级群组/频道用户名活动状态
   * @param supergroup_id 超级群组 ID
   * @param username 用户名
   * @param is_active 是否激活
   */
  toggleSupergroupUsernameIsActive(supergroup_id: number, username: string, is_active: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleSupergroupUsernameIsActive',
      'supergroup_id': supergroup_id,
      'username': username,
      'is_active': is_active,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 禁用所有非编辑用户名
   * @param supergroup_id 超级群组 ID
   */
  disableAllSupergroupUsernames(supergroup_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'disableAllSupergroupUsernames',
      'supergroup_id': supergroup_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 重新排序超级群组/频道活跃用户名
   * @param supergroup_id 超级群组 ID
   * @param usernames 用户名列表（新顺序）
   */
  reorderSupergroupActiveUsernames(supergroup_id: number, usernames: string[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'reorderSupergroupActiveUsernames',
      'supergroup_id': supergroup_id,
      'usernames': usernames,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置超级群组贴纸集
   * @param supergroup_id 超级群组 ID
   * @param sticker_set_id 贴纸集 ID（0 表示移除）
   */
  setSupergroupStickerSet(supergroup_id: number, sticker_set_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setSupergroupStickerSet',
      'supergroup_id': supergroup_id,
      'sticker_set_id': sticker_set_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置超级群组自定义表情贴纸集
   * @param supergroup_id 超级群组 ID
   * @param custom_emoji_sticker_set_id 自定义表情贴纸集 ID（0 表示移除）
   */
  setSupergroupCustomEmojiStickerSet(supergroup_id: number, custom_emoji_sticker_set_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setSupergroupCustomEmojiStickerSet',
      'supergroup_id': supergroup_id,
      'custom_emoji_sticker_set_id': custom_emoji_sticker_set_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置超级群组解除限制所需的提升次数
   * @param supergroup_id 超级群组 ID
   * @param unrestrict_boost_count 提升次数（0-8）
   */
  setSupergroupUnrestrictBoostCount(supergroup_id: number, unrestrict_boost_count: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setSupergroupUnrestrictBoostCount',
      'supergroup_id': supergroup_id,
      'unrestrict_boost_count': unrestrict_boost_count,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置频道的主资料选项卡
   * @param supergroup_id 频道 ID
   * @param main_profile_tab 选项卡类型
   */
  setSupergroupMainProfileTab(supergroup_id: number, main_profile_tab: ProfileTab): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setSupergroupMainProfileTab',
      'supergroup_id': supergroup_id,
      'main_profile_tab': main_profile_tab,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换频道签名/显示发送者
   * @param supergroup_id 频道 ID
   * @param sign_messages 是否签名
   * @param show_message_sender 是否显示发送者
   */
  toggleSupergroupSignMessages(supergroup_id: number, sign_messages: boolean,
    show_message_sender: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleSupergroupSignMessages',
      'supergroup_id': supergroup_id,
      'sign_messages': sign_messages,
      'show_message_sender': show_message_sender,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换加入后才能发送消息
   * @param supergroup_id 超级群组 ID
   * @param join_to_send_messages 是否加入才能发送
   */
  toggleSupergroupJoinToSendMessages(supergroup_id: number, join_to_send_messages: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleSupergroupJoinToSendMessages',
      'supergroup_id': supergroup_id,
      'join_to_send_messages': join_to_send_messages,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换加入需要审批
   * @param supergroup_id 超级群组 ID
   * @param join_by_request 是否需要审批
   */
  toggleSupergroupJoinByRequest(supergroup_id: number, join_by_request: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleSupergroupJoinByRequest',
      'supergroup_id': supergroup_id,
      'join_by_request': join_by_request,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换超级群组历史消息对新人可见
   * @param supergroup_id 超级群组 ID
   * @param is_all_history_available 是否所有历史可见
   */
  toggleSupergroupIsAllHistoryAvailable(supergroup_id: number, is_all_history_available: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleSupergroupIsAllHistoryAvailable',
      'supergroup_id': supergroup_id,
      'is_all_history_available': is_all_history_available,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换频道赞助消息显示
   * @param supergroup_id 频道 ID
   * @param can_have_sponsored_messages 是否显示赞助消息
   */
  toggleSupergroupCanHaveSponsoredMessages(supergroup_id: number, can_have_sponsored_messages: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleSupergroupCanHaveSponsoredMessages',
      'supergroup_id': supergroup_id,
      'can_have_sponsored_messages': can_have_sponsored_messages,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换频道自动翻译
   * @param supergroup_id 频道 ID
   * @param has_automatic_translation 是否自动翻译
   */
  toggleSupergroupHasAutomaticTranslation(supergroup_id: number, has_automatic_translation: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleSupergroupHasAutomaticTranslation',
      'supergroup_id': supergroup_id,
      'has_automatic_translation': has_automatic_translation,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换隐藏成员（非管理员）
   * @param supergroup_id 超级群组 ID
   * @param has_hidden_members 是否隐藏成员
   */
  toggleSupergroupHasHiddenMembers(supergroup_id: number, has_hidden_members: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleSupergroupHasHiddenMembers',
      'supergroup_id': supergroup_id,
      'has_hidden_members': has_hidden_members,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换激进反垃圾
   * @param supergroup_id 超级群组 ID
   * @param has_aggressive_anti_spam_enabled 是否启用
   */
  toggleSupergroupHasAggressiveAntiSpamEnabled(supergroup_id: number,
    has_aggressive_anti_spam_enabled: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleSupergroupHasAggressiveAntiSpamEnabled',
      'supergroup_id': supergroup_id,
      'has_aggressive_anti_spam_enabled': has_aggressive_anti_spam_enabled,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换超级群组为论坛模式
   * @param supergroup_id 超级群组 ID
   * @param is_forum 是否为论坛
   * @param has_forum_tabs 是否显示论坛标签
   */
  toggleSupergroupIsForum(supergroup_id: number, is_forum: boolean, has_forum_tabs: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleSupergroupIsForum',
      'supergroup_id': supergroup_id,
      'is_forum': is_forum,
      'has_forum_tabs': has_forum_tabs,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 将超级群组升级为广播群组
   * @param supergroup_id 超级群组 ID
   */
  toggleSupergroupIsBroadcastGroup(supergroup_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleSupergroupIsBroadcastGroup',
      'supergroup_id': supergroup_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 举报超级群组垃圾消息
   * @param supergroup_id 超级群组 ID
   * @param message_ids 消息 ID 列表
   */
  reportSupergroupSpam(supergroup_id: number, message_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'reportSupergroupSpam',
      'supergroup_id': supergroup_id,
      'message_ids': message_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 报告反垃圾误判
   * @param supergroup_id 超级群组 ID
   * @param message_id 消息 ID
   */
  reportSupergroupAntiSpamFalsePositive(supergroup_id: number, message_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'reportSupergroupAntiSpamFalsePositive',
      'supergroup_id': supergroup_id,
      'message_id': message_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取超级群组成员
   * @param supergroup_id 超级群组 ID
   * @param filter 过滤器
   * @param offset 偏移
   * @param limit 数量
   */
  getSupergroupMembers(
    supergroup_id: number,
    filter: Object | null,
    offset: number,
    limit: number
  ): Promise<ChatMembers> {
    const params: Record<string, Object> = {
      '@type': 'getSupergroupMembers',
      'supergroup_id': supergroup_id,
      'offset': offset,
      'limit': limit,
    };
    if (filter !== null) {
      params['filter'] = filter;
    }
    return this.client.execute<ChatMembers>(params);
  }

  /**
   * 关闭秘密聊天
   * @param secret_chat_id 秘密聊天 ID
   */
  closeSecretChat(secret_chat_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'closeSecretChat',
      'secret_chat_id': secret_chat_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取聊天事件日志
   * @param chat_id 聊天 ID
   * @param query 查询字符串
   * @param from_event_id 起始事件 ID
   * @param limit 数量
   * @param filters 过滤器
   * @param user_ids 用户 ID 列表
   */
  getChatEventLog(
    chat_id: number,
    query: string,
    from_event_id: number,
    limit: number,
    filters: chatEventLogFilters$Input | null,
    user_ids: number[]
  ): Promise<ChatEvents> {
    const params: Record<string, Object> = {
      '@type': 'getChatEventLog',
      'chat_id': chat_id,
      'query': query,
      'from_event_id': from_event_id,
      'limit': limit,
      'user_ids': user_ids,
    };
    if (filters !== null) {
      params['filters'] = filters;
    }
    return this.client.execute<ChatEvents>(params);
  }

  // ==================== 时区 ====================

  /**
   * 获取支持时区列表
   */
  getTimeZones(): Promise<TimeZones> {
    const params: Record<string, Object> = {
      '@type': 'getTimeZones',
    };
    return this.client.execute<TimeZones>(params);
  }

  // ==================== 支付与星币 ====================

  /**
   * 获取支付表单
   * @param input_invoice 输入发票
   * @param theme 主题参数
   */
  getPaymentForm(input_invoice: invoice, theme: themeParameters$Input | null): Promise<PaymentForm> {
    const params: Record<string, Object> = {
      '@type': 'getPaymentForm',
      'input_invoice': input_invoice,
    };
    if (theme !== null) {
      params['theme'] = theme;
    }
    return this.client.execute<PaymentForm>(params);
  }

  /**
   * 验证订单信息
   * @param input_invoice 输入发票
   * @param order_info 订单信息
   * @param allow_save 是否允许保存
   */
  validateOrderInfo(input_invoice: invoice, order_info: OrderInfo | null,
    allow_save: boolean): Promise<ValidatedOrderInfo> {
    const params: Record<string, Object> = {
      '@type': 'validateOrderInfo',
      'input_invoice': input_invoice,
      'allow_save': allow_save,
    };
    if (order_info !== null) {
      params['order_info'] = order_info;
    }
    return this.client.execute<ValidatedOrderInfo>(params);
  }

  /**
   * 发送支付表单
   * @param input_invoice 输入发票
   * @param payment_form_id 表单 ID
   * @param order_info_id 订单信息 ID
   * @param shipping_option_id 配送选项 ID
   * @param credentials 支付凭证（null 表示星币支付）
   * @param tip_amount 小费金额
   */
  sendPaymentForm(
    input_invoice: invoice,
    payment_form_id: number,
    order_info_id: string,
    shipping_option_id: string,
    credentials: Object | null,
    tip_amount: number
  ): Promise<PaymentResult> {
    const params: Record<string, Object> = {
      '@type': 'sendPaymentForm',
      'input_invoice': input_invoice,
      'payment_form_id': payment_form_id,
      'order_info_id': order_info_id,
      'shipping_option_id': shipping_option_id,
      'tip_amount': tip_amount,
    };
    if (credentials !== null) {
      params['credentials'] = credentials;
    }
    return this.client.execute<PaymentResult>(params);
  }

  /**
   * 获取支付收据
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   */
  getPaymentReceipt(chat_id: number, message_id: number): Promise<PaymentReceipt> {
    const params: Record<string, Object> = {
      '@type': 'getPaymentReceipt',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<PaymentReceipt>(params);
  }

  /**
   * 获取保存的订单信息
   */
  getSavedOrderInfo(): Promise<OrderInfo> {
    const params: Record<string, Object> = {
      '@type': 'getSavedOrderInfo',
    };
    return this.client.execute<OrderInfo>(params);
  }

  /**
   * 删除保存的订单信息
   */
  deleteSavedOrderInfo(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteSavedOrderInfo',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 删除保存的支付凭证
   */
  deleteSavedCredentials(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteSavedCredentials',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置礼物接收设置
   * @param settings 新设置
   */
  setGiftSettings(settings: giftSettings): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setGiftSettings',
      'settings': settings,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取可用礼物
   */
  getAvailableGifts(): Promise<AvailableGifts> {
    const params: Record<string, Object> = {
      '@type': 'getAvailableGifts',
    };
    return this.client.execute<AvailableGifts>(params);
  }

  /**
   * 检查能否发送礼物
   * @param gift_id 礼物 ID
   */
  canSendGift(gift_id: number): Promise<CanSendGiftResult> {
    const params: Record<string, Object> = {
      '@type': 'canSendGift',
      'gift_id': gift_id,
    };
    return this.client.execute<CanSendGiftResult>(params);
  }

  /**
   * 发送礼物
   * @param gift_id 礼物 ID
   * @param owner_id 接收者 ID
   * @param text 附言
   * @param is_private 是否私密
   * @param pay_for_upgrade 是否预付升级
   */
  sendGift(gift_id: number, owner_id: MessageSender, text: FormattedText, is_private: boolean,
    pay_for_upgrade: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'sendGift',
      'gift_id': gift_id,
      'owner_id': owner_id,
      'text': text,
      'is_private': is_private,
      'pay_for_upgrade': pay_for_upgrade,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取礼物拍卖状态
   * @param auction_id 拍卖 ID
   */
  getGiftAuctionState(auction_id: string): Promise<GiftAuctionState> {
    const params: Record<string, Object> = {
      '@type': 'getGiftAuctionState',
      'auction_id': auction_id,
    };
    return this.client.execute<GiftAuctionState>(params);
  }

  /**
   * 获取拍卖中获得的礼物
   * @param gift_id 礼物 ID
   */
  getGiftAuctionAcquiredGifts(gift_id: number): Promise<GiftAuctionAcquiredGifts> {
    const params: Record<string, Object> = {
      '@type': 'getGiftAuctionAcquiredGifts',
      'gift_id': gift_id,
    };
    return this.client.execute<GiftAuctionAcquiredGifts>(params);
  }

  /**
   * 打开礼物拍卖
   * @param gift_id 礼物 ID
   */
  openGiftAuction(gift_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'openGiftAuction',
      'gift_id': gift_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 关闭礼物拍卖
   * @param gift_id 礼物 ID
   */
  closeGiftAuction(gift_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'closeGiftAuction',
      'gift_id': gift_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 竞拍礼物
   * @param gift_id 礼物 ID
   * @param star_count 星币数量
   * @param user_id 接收者 ID
   * @param text 附言
   * @param is_private 是否私密
   */
  placeGiftAuctionBid(gift_id: number, star_count: number, user_id: number, text: FormattedText,
    is_private: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'placeGiftAuctionBid',
      'gift_id': gift_id,
      'star_count': star_count,
      'user_id': user_id,
      'text': text,
      'is_private': is_private,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 增加竞拍出价
   * @param gift_id 礼物 ID
   * @param star_count 新星币数量
   */
  increaseGiftAuctionBid(gift_id: number, star_count: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'increaseGiftAuctionBid',
      'gift_id': gift_id,
      'star_count': star_count,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 出售礼物
   * @param business_connection_id 商业连接 ID（仅 Bot）
   * @param received_gift_id 收到的礼物 ID
   */
  sellGift(business_connection_id: string, received_gift_id: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'sellGift',
      'business_connection_id': business_connection_id,
      'received_gift_id': received_gift_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换礼物是否显示在个人资料页
   * @param received_gift_id 收到的礼物 ID
   * @param is_saved 是否保存
   */
  toggleGiftIsSaved(received_gift_id: string, is_saved: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleGiftIsSaved',
      'received_gift_id': received_gift_id,
      'is_saved': is_saved,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置个人资料页固定礼物
   * @param owner_id 所有者 ID
   * @param received_gift_ids 固定礼物 ID 列表
   */
  setPinnedGifts(owner_id: MessageSender, received_gift_ids: string[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setPinnedGifts',
      'owner_id': owner_id,
      'received_gift_ids': received_gift_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 切换频道礼物通知
   * @param chat_id 频道 ID
   * @param are_enabled 是否启用
   */
  toggleChatGiftNotifications(chat_id: number, are_enabled: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'toggleChatGiftNotifications',
      'chat_id': chat_id,
      'are_enabled': are_enabled,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取礼物升级预览
   * @param regular_gift_id 普通礼物 ID
   */
  getGiftUpgradePreview(regular_gift_id: number): Promise<GiftUpgradePreview> {
    const params: Record<string, Object> = {
      '@type': 'getGiftUpgradePreview',
      'regular_gift_id': regular_gift_id,
    };
    return this.client.execute<GiftUpgradePreview>(params);
  }

  /**
   * 获取升级礼物变体
   * @param regular_gift_id 普通礼物 ID
   * @param return_upgrade_models 是否返回升级模型
   * @param return_craft_models 是否返回制作模型
   */
  getUpgradedGiftVariants(regular_gift_id: number, return_upgrade_models: boolean,
    return_craft_models: boolean): Promise<GiftUpgradeVariants> {
    const params: Record<string, Object> = {
      '@type': 'getUpgradedGiftVariants',
      'regular_gift_id': regular_gift_id,
      'return_upgrade_models': return_upgrade_models,
      'return_craft_models': return_craft_models,
    };
    return this.client.execute<GiftUpgradeVariants>(params);
  }

  /**
   * 升级礼物
   * @param business_connection_id 商业连接 ID（仅 Bot）
   * @param received_gift_id 收到的礼物 ID
   * @param keep_original_details 是否保留原始详情
   * @param star_count 星币数量（0 表示使用预付）
   */
  upgradeGift(
    business_connection_id: string,
    received_gift_id: string,
    keep_original_details: boolean,
    star_count: number
  ): Promise<UpgradeGiftResult> {
    const params: Record<string, Object> = {
      '@type': 'upgradeGift',
      'business_connection_id': business_connection_id,
      'received_gift_id': received_gift_id,
      'keep_original_details': keep_original_details,
      'star_count': star_count,
    };
    return this.client.execute<UpgradeGiftResult>(params);
  }

  /**
   * 为他人的礼物支付升级费用
   * @param owner_id 所有者 ID
   * @param prepaid_upgrade_hash 预付升级哈希
   * @param star_count 星币数量
   */
  buyGiftUpgrade(owner_id: MessageSender, prepaid_upgrade_hash: string, star_count: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'buyGiftUpgrade',
      'owner_id': owner_id,
      'prepaid_upgrade_hash': prepaid_upgrade_hash,
      'star_count': star_count,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 制作新礼物
   * @param received_gift_ids 使用的礼物 ID 列表
   */
  craftGift(received_gift_ids: string[]): Promise<CraftGiftResult> {
    const params: Record<string, Object> = {
      '@type': 'craftGift',
      'received_gift_ids': received_gift_ids,
    };
    return this.client.execute<CraftGiftResult>(params);
  }

  /**
   * 转让升级礼物
   * @param business_connection_id 商业连接 ID（仅 Bot）
   * @param received_gift_id 收到的礼物 ID
   * @param new_owner_id 新所有者 ID
   * @param star_count 星币数量
   */
  transferGift(business_connection_id: string, received_gift_id: string, new_owner_id: MessageSender,
    star_count: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'transferGift',
      'business_connection_id': business_connection_id,
      'received_gift_id': received_gift_id,
      'new_owner_id': new_owner_id,
      'star_count': star_count,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 丢弃升级礼物的原始详情
   * @param received_gift_id 收到的礼物 ID
   * @param star_count 星币数量
   */
  dropGiftOriginalDetails(received_gift_id: string, star_count: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'dropGiftOriginalDetails',
      'received_gift_id': received_gift_id,
      'star_count': star_count,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 发送转售礼物
   * @param gift_name 礼物名称
   * @param owner_id 接收者 ID
   * @param price 价格
   */
  sendResoldGift(gift_name: string, owner_id: MessageSender, price: GiftResalePrice): Promise<GiftResaleResult> {
    const params: Record<string, Object> = {
      '@type': 'sendResoldGift',
      'gift_name': gift_name,
      'owner_id': owner_id,
      'price': price,
    };
    return this.client.execute<GiftResaleResult>(params);
  }

  /**
   * 发送购买邀约
   * @param owner_id 当前所有者 ID
   * @param gift_name 礼物名称
   * @param price 价格
   * @param duration 有效期（秒）
   * @param paid_message_star_count 付费消息星币数量
   */
  sendGiftPurchaseOffer(
    owner_id: MessageSender,
    gift_name: string,
    price: GiftResalePrice,
    duration: number,
    paid_message_star_count: number
  ): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'sendGiftPurchaseOffer',
      'owner_id': owner_id,
      'gift_name': gift_name,
      'price': price,
      'duration': duration,
      'paid_message_star_count': paid_message_star_count,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 处理购买邀约
   * @param message_id 消息 ID
   * @param accept 是否接受
   */
  processGiftPurchaseOffer(message_id: number, accept: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'processGiftPurchaseOffer',
      'message_id': message_id,
      'accept': accept,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取收到的礼物
   * @param business_connection_id 商业连接 ID（仅 Bot）
   * @param owner_id 所有者 ID
   * @param collection_id 收藏集 ID
   * @param exclude_unsaved 排除未保存
   * @param exclude_saved 排除已保存
   * @param exclude_unlimited 排除无限礼物
   * @param exclude_upgradable 排除可升级
   * @param exclude_non_upgradable 排除不可升级
   * @param exclude_upgraded 排除已升级
   * @param exclude_without_colors 排除无颜色
   * @param exclude_hosted 排除托管
   * @param sort_by_price 按价格排序
   * @param offset 偏移
   * @param limit 数量
   */
  getReceivedGifts(
    business_connection_id: string,
    owner_id: MessageSender,
    collection_id: number,
    exclude_unsaved: boolean,
    exclude_saved: boolean,
    exclude_unlimited: boolean,
    exclude_upgradable: boolean,
    exclude_non_upgradable: boolean,
    exclude_upgraded: boolean,
    exclude_without_colors: boolean,
    exclude_hosted: boolean,
    sort_by_price: boolean,
    offset: string,
    limit: number
  ): Promise<ReceivedGifts> {
    const params: Record<string, Object> = {
      '@type': 'getReceivedGifts',
      'business_connection_id': business_connection_id,
      'owner_id': owner_id,
      'collection_id': collection_id,
      'exclude_unsaved': exclude_unsaved,
      'exclude_saved': exclude_saved,
      'exclude_unlimited': exclude_unlimited,
      'exclude_upgradable': exclude_upgradable,
      'exclude_non_upgradable': exclude_non_upgradable,
      'exclude_upgraded': exclude_upgraded,
      'exclude_without_colors': exclude_without_colors,
      'exclude_hosted': exclude_hosted,
      'sort_by_price': sort_by_price,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<ReceivedGifts>(params);
  }

  /**
   * 获取收到的礼物详情
   * @param received_gift_id 收到的礼物 ID
   */
  getReceivedGift(received_gift_id: string): Promise<ReceivedGift> {
    const params: Record<string, Object> = {
      '@type': 'getReceivedGift',
      'received_gift_id': received_gift_id,
    };
    return this.client.execute<ReceivedGift>(params);
  }

  /**
   * 获取可用于制作的礼物
   * @param regular_gift_id 普通礼物 ID
   * @param offset 偏移
   * @param limit 数量
   */
  getGiftsForCrafting(regular_gift_id: number, offset: string, limit: number): Promise<GiftsForCrafting> {
    const params: Record<string, Object> = {
      '@type': 'getGiftsForCrafting',
      'regular_gift_id': regular_gift_id,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<GiftsForCrafting>(params);
  }

  /**
   * 获取升级礼物信息
   * @param name 礼物名称
   */
  getUpgradedGift(name: string): Promise<UpgradedGift> {
    const params: Record<string, Object> = {
      '@type': 'getUpgradedGift',
      'name': name,
    };
    return this.client.execute<UpgradedGift>(params);
  }

  /**
   * 获取升级礼物价值信息
   * @param name 礼物名称
   */
  getUpgradedGiftValueInfo(name: string): Promise<UpgradedGiftValueInfo> {
    const params: Record<string, Object> = {
      '@type': 'getUpgradedGiftValueInfo',
      'name': name,
    };
    return this.client.execute<UpgradedGiftValueInfo>(params);
  }

  /**
   * 获取升级礼物提现 URL（NFT）
   * @param received_gift_id 收到的礼物 ID
   * @param password 两步验证密码
   */
  getUpgradedGiftWithdrawalUrl(received_gift_id: string, password: string): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getUpgradedGiftWithdrawalUrl',
      'received_gift_id': received_gift_id,
      'password': password,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 获取升级礼物宣传动画
   */
  getUpgradedGiftsPromotionalAnimation(): Promise<Animation> {
    const params: Record<string, Object> = {
      '@type': 'getUpgradedGiftsPromotionalAnimation',
    };
    return this.client.execute<Animation>(params);
  }

  /**
   * 设置礼物转售价格
   * @param received_gift_id 收到的礼物 ID
   * @param price 价格（null 表示禁止转售）
   */
  setGiftResalePrice(received_gift_id: string, price: GiftResalePrice | null): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setGiftResalePrice',
      'received_gift_id': received_gift_id,
    };
    if (price !== null) {
      params['price'] = price;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 搜索可转售的礼物
   * @param gift_id 礼物 ID
   * @param order 排序方式
   * @param for_crafting 是否用于制作
   * @param attributes 属性过滤
   * @param offset 偏移
   * @param limit 数量
   */
  searchGiftsForResale(
    gift_id: number,
    order: giftForResale,
    for_crafting: boolean,
    attributes: Object[],
    offset: string,
    limit: number
  ): Promise<GiftsForResale> {
    const params: Record<string, Object> = {
      '@type': 'searchGiftsForResale',
      'gift_id': gift_id,
      'order': order,
      'for_crafting': for_crafting,
      'attributes': attributes,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<GiftsForResale>(params);
  }

  /**
   * 获取礼物收藏集
   * @param owner_id 所有者 ID
   */
  getGiftCollections(owner_id: MessageSender): Promise<GiftCollections> {
    const params: Record<string, Object> = {
      '@type': 'getGiftCollections',
      'owner_id': owner_id,
    };
    return this.client.execute<GiftCollections>(params);
  }

  /**
   * 创建礼物收藏集
   * @param owner_id 所有者 ID
   * @param name 名称
   * @param received_gift_ids 礼物 ID 列表
   */
  createGiftCollection(owner_id: MessageSender, name: string, received_gift_ids: string[]): Promise<GiftCollection> {
    const params: Record<string, Object> = {
      '@type': 'createGiftCollection',
      'owner_id': owner_id,
      'name': name,
      'received_gift_ids': received_gift_ids,
    };
    return this.client.execute<GiftCollection>(params);
  }

  /**
   * 重新排序礼物收藏集
   * @param owner_id 所有者 ID
   * @param collection_ids 收藏集 ID 列表（新顺序）
   */
  reorderGiftCollections(owner_id: MessageSender, collection_ids: number[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'reorderGiftCollections',
      'owner_id': owner_id,
      'collection_ids': collection_ids,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 删除礼物收藏集
   * @param owner_id 所有者 ID
   * @param collection_id 收藏集 ID
   */
  deleteGiftCollection(owner_id: MessageSender, collection_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteGiftCollection',
      'owner_id': owner_id,
      'collection_id': collection_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置礼物收藏集名称
   * @param owner_id 所有者 ID
   * @param collection_id 收藏集 ID
   * @param name 新名称
   */
  setGiftCollectionName(owner_id: MessageSender, collection_id: number, name: string): Promise<GiftCollection> {
    const params: Record<string, Object> = {
      '@type': 'setGiftCollectionName',
      'owner_id': owner_id,
      'collection_id': collection_id,
      'name': name,
    };
    return this.client.execute<GiftCollection>(params);
  }

  /**
   * 向收藏集添加礼物
   * @param owner_id 所有者 ID
   * @param collection_id 收藏集 ID
   * @param received_gift_ids 礼物 ID 列表
   */
  addGiftCollectionGifts(owner_id: MessageSender, collection_id: number,
    received_gift_ids: string[]): Promise<GiftCollection> {
    const params: Record<string, Object> = {
      '@type': 'addGiftCollectionGifts',
      'owner_id': owner_id,
      'collection_id': collection_id,
      'received_gift_ids': received_gift_ids,
    };
    return this.client.execute<GiftCollection>(params);
  }

  /**
   * 从收藏集移除礼物
   * @param owner_id 所有者 ID
   * @param collection_id 收藏集 ID
   * @param received_gift_ids 礼物 ID 列表
   */
  removeGiftCollectionGifts(owner_id: MessageSender, collection_id: number,
    received_gift_ids: string[]): Promise<GiftCollection> {
    const params: Record<string, Object> = {
      '@type': 'removeGiftCollectionGifts',
      'owner_id': owner_id,
      'collection_id': collection_id,
      'received_gift_ids': received_gift_ids,
    };
    return this.client.execute<GiftCollection>(params);
  }

  /**
   * 重新排序收藏集中的礼物
   * @param owner_id 所有者 ID
   * @param collection_id 收藏集 ID
   * @param received_gift_ids 移动到开头的礼物 ID 列表
   */
  reorderGiftCollectionGifts(owner_id: MessageSender, collection_id: number,
    received_gift_ids: string[]): Promise<GiftCollection> {
    const params: Record<string, Object> = {
      '@type': 'reorderGiftCollectionGifts',
      'owner_id': owner_id,
      'collection_id': collection_id,
      'received_gift_ids': received_gift_ids,
    };
    return this.client.execute<GiftCollection>(params);
  }

  /**
   * 创建发票链接（仅 Bot）
   * @param business_connection_id 商业连接 ID
   * @param invoice 发票消息内容
   */
  createInvoiceLink(business_connection_id: string, invoice: InputMessageContent): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'createInvoiceLink',
      'business_connection_id': business_connection_id,
      'invoice': invoice,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 退款星币支付（仅 Bot）
   * @param user_id 用户 ID
   * @param telegram_payment_charge_id Telegram 支付 ID
   */
  refundStarPayment(user_id: number, telegram_payment_charge_id: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'refundStarPayment',
      'user_id': user_id,
      'telegram_payment_charge_id': telegram_payment_charge_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取支持用户
   */
  getSupportUser(): Promise<User> {
    const params: Record<string, Object> = {
      '@type': 'getSupportUser',
    };
    return this.client.execute<User>(params);
  }

  // ==================== 背景 ====================

  /**
   * 获取背景 URL
   * @param name 背景名称
   * @param type 背景类型
   */
  getBackgroundUrl(name: string, type: BackgroundType): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getBackgroundUrl',
      'name': name,
      'type': type,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 按名称搜索背景
   * @param name 背景名称
   */
  searchBackground(name: string): Promise<Background> {
    const params: Record<string, Object> = {
      '@type': 'searchBackground',
      'name': name,
    };
    return this.client.execute<Background>(params);
  }

  /**
   * 设置默认背景
   * @param background 背景输入（null 表示新建）
   * @param type 背景类型（null 表示自动）
   * @param for_dark_theme 是否用于暗色主题
   */
  setDefaultBackground(background: Background | null, type: BackgroundType | null,
    for_dark_theme: boolean): Promise<Background> {
    const params: Record<string, Object> = {
      '@type': 'setDefaultBackground',
      'for_dark_theme': for_dark_theme,
    };
    if (background !== null) {
      params['background'] = background;
    }
    if (type !== null) {
      params['type'] = type;
    }
    return this.client.execute<Background>(params);
  }

  /**
   * 删除默认背景
   * @param for_dark_theme 是否删除暗色主题默认背景
   */
  deleteDefaultBackground(for_dark_theme: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteDefaultBackground',
      'for_dark_theme': for_dark_theme,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取已安装背景
   * @param for_dark_theme 是否按暗色主题排序
   */
  getInstalledBackgrounds(for_dark_theme: boolean): Promise<Backgrounds> {
    const params: Record<string, Object> = {
      '@type': 'getInstalledBackgrounds',
      'for_dark_theme': for_dark_theme,
    };
    return this.client.execute<Backgrounds>(params);
  }

  /**
   * 移除已安装背景
   * @param background_id 背景 ID
   */
  removeInstalledBackground(background_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeInstalledBackground',
      'background_id': background_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 重置已安装背景为默认
   */
  resetInstalledBackgrounds(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'resetInstalledBackgrounds',
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 本地化 ====================

  /**
   * 获取本地化目标信息（离线）
   * @param only_local 是否仅本地
   */
  getLocalizationTargetInfo(only_local: boolean): Promise<LocalizationTargetInfo> {
    const params: Record<string, Object> = {
      '@type': 'getLocalizationTargetInfo',
      'only_local': only_local,
    };
    return this.client.execute<LocalizationTargetInfo>(params);
  }

  /**
   * 获取语言包信息
   * @param language_pack_id 语言包 ID
   */
  getLanguagePackInfo(language_pack_id: string): Promise<LanguagePackInfo> {
    const params: Record<string, Object> = {
      '@type': 'getLanguagePackInfo',
      'language_pack_id': language_pack_id,
    };
    return this.client.execute<LanguagePackInfo>(params);
  }

  /**
   * 获取语言包字符串
   * @param language_pack_id 语言包 ID
   * @param keys 键列表
   */
  getLanguagePackStrings(language_pack_id: string, keys: string[]): Promise<LanguagePackStrings> {
    const params: Record<string, Object> = {
      '@type': 'getLanguagePackStrings',
      'language_pack_id': language_pack_id,
      'keys': keys,
    };
    return this.client.execute<LanguagePackStrings>(params);
  }

  /**
   * 同步语言包
   * @param language_pack_id 语言包 ID
   */
  synchronizeLanguagePack(language_pack_id: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'synchronizeLanguagePack',
      'language_pack_id': language_pack_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 添加自定义服务器语言包
   * @param language_pack_id 语言包 ID
   */
  addCustomServerLanguagePack(language_pack_id: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'addCustomServerLanguagePack',
      'language_pack_id': language_pack_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置自定义本地语言包
   * @param info 语言包信息
   * @param strings 字符串列表
   */
  setCustomLanguagePack(info: LanguagePackInfo, strings: LanguagePackStrings[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setCustomLanguagePack',
      'info': info,
      'strings': strings,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 编辑自定义语言包信息
   * @param info 新信息
   */
  editCustomLanguagePackInfo(info: LanguagePackInfo): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'editCustomLanguagePackInfo',
      'info': info,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置自定义语言包字符串
   * @param language_pack_id 语言包 ID
   * @param new_string 新字符串
   */
  setCustomLanguagePackString(language_pack_id: string, new_string: LanguagePackStrings): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setCustomLanguagePackString',
      'language_pack_id': language_pack_id,
      'new_string': new_string,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 删除语言包
   * @param language_pack_id 语言包 ID
   */
  deleteLanguagePack(language_pack_id: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteLanguagePack',
      'language_pack_id': language_pack_id,
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 推送通知 ====================

  /**
   * 注册设备
   * @param device_token 设备令牌
   * @param other_user_ids 其他用户 ID 列表
   */
  registerDevice(device_token: Object, other_user_ids: number[]): Promise<number> {
    const params: Record<string, Object> = {
      '@type': 'registerDevice',
      'device_token': device_token,
      'other_user_ids': other_user_ids,
    };
    return this.client.execute<number>(params);
  }

  /**
   * 处理推送通知
   * @param payload JSON 负载
   */
  processPushNotification(payload: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'processPushNotification',
      'payload': payload,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取推送接收者 ID（同步）
   * @param payload JSON 负载
   */
  getPushReceiverId(payload: string): Promise<number> {
    const params: Record<string, Object> = {
      '@type': 'getPushReceiverId',
      'payload': payload,
    };
    return this.client.execute<number>(params);
  }

  /**
   * 获取最近访问的 t.me URL
   * @param referrer Google Play 引用
   */
  getRecentlyVisitedTMeUrls(referrer: string): Promise<TMeUrls> {
    const params: Record<string, Object> = {
      '@type': 'getRecentlyVisitedTMeUrls',
      'referrer': referrer,
    };
    return this.client.execute<TMeUrls>(params);
  }

  // ==================== 隐私设置 ====================

  /**
   * 设置用户隐私设置
   * @param setting 隐私设置类型
   * @param rules 新规则
   */
  setUserPrivacySettingRules(setting: UserPrivacySetting, rules: UserPrivacySettingRules): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setUserPrivacySettingRules',
      'setting': setting,
      'rules': rules,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取用户隐私设置
   * @param setting 隐私设置类型
   */
  getUserPrivacySettingRules(setting: UserPrivacySetting): Promise<UserPrivacySettingRules> {
    const params: Record<string, Object> = {
      '@type': 'getUserPrivacySettingRules',
      'setting': setting,
    };
    return this.client.execute<UserPrivacySettingRules>(params);
  }

  /**
   * 设置消息已读时间隐私设置
   * @param settings 新设置
   */
  setReadDatePrivacySettings(settings: ReadDatePrivacySettings): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setReadDatePrivacySettings',
      'settings': settings,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取消息已读时间隐私设置
   */
  getReadDatePrivacySettings(): Promise<ReadDatePrivacySettings> {
    const params: Record<string, Object> = {
      '@type': 'getReadDatePrivacySettings',
    };
    return this.client.execute<ReadDatePrivacySettings>(params);
  }

  /**
   * 设置新聊天隐私设置
   * @param settings 新设置
   */
  setNewChatPrivacySettings(settings: NewChatPrivacySettings): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setNewChatPrivacySettings',
      'settings': settings,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取新聊天隐私设置
   */
  getNewChatPrivacySettings(): Promise<NewChatPrivacySettings> {
    const params: Record<string, Object> = {
      '@type': 'getNewChatPrivacySettings',
    };
    return this.client.execute<NewChatPrivacySettings>(params);
  }

  // ==================== 付费消息与收入 ====================

  /**
   * 获取从用户处收到的付费消息总收入（星币）
   * @param user_id 用户 ID
   */
  getPaidMessageRevenue(user_id: number): Promise<number> {
    const params: Record<string, Object> = {
      '@type': 'getPaidMessageRevenue',
      'user_id': user_id,
    };
    return this.client.execute<number>(params);
  }

  /**
   * 允许用户发送免费消息
   * @param user_id 用户 ID
   * @param refund_payments 是否退款已付消息
   */
  allowUnpaidMessagesFromUser(user_id: number, refund_payments: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'allowUnpaidMessagesFromUser',
      'user_id': user_id,
      'refund_payments': refund_payments,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置超级群组付费消息星币数量
   * @param chat_id 聊天 ID
   * @param paid_message_star_count 星币数量
   */
  setChatPaidMessageStarCount(chat_id: number, paid_message_star_count: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setChatPaidMessageStarCount',
      'chat_id': chat_id,
      'paid_message_star_count': paid_message_star_count,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 检查能否向用户发送消息
   * @param user_id 用户 ID
   * @param only_local 是否仅本地
   */
  canSendMessageToUser(user_id: number, only_local: boolean): Promise<CanSendMessageToUserResult> {
    const params: Record<string, Object> = {
      '@type': 'canSendMessageToUser',
      'user_id': user_id,
      'only_local': only_local,
    };
    return this.client.execute<CanSendMessageToUserResult>(params);
  }

  /**
   * 获取选项值
   * @param name 选项名称
   */
  getOption(name: string): Promise<OptionValue> {
    const params: Record<string, Object> = {
      '@type': 'getOption',
      'name': name,
    };
    return this.client.execute<OptionValue>(params);
  }

  /**
   * 设置选项值
   * @param name 选项名称
   * @param value 新值（null 表示重置）
   */
  setOption(name: string, value: OptionValue | null): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setOption',
      'name': name,
    };
    if (value !== null) {
      params['value'] = value;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置账户自动删除期限
   * @param ttl 账户 TTL
   */
  setAccountTtl(ttl: AccountTtl): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setAccountTtl',
      'ttl': ttl,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取账户自动删除期限
   */
  getAccountTtl(): Promise<AccountTtl> {
    const params: Record<string, Object> = {
      '@type': 'getAccountTtl',
    };
    return this.client.execute<AccountTtl>(params);
  }

  /**
   * 删除账户
   * @param reason 删除原因
   * @param password 两步验证密码
   */
  deleteAccount(reason: string, password: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteAccount',
      'reason': reason,
      'password': password,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置默认消息自动删除时间
   * @param message_auto_delete_time 自动删除时间
   */
  setDefaultMessageAutoDeleteTime(message_auto_delete_time: MessageAutoDeleteTime): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setDefaultMessageAutoDeleteTime',
      'message_auto_delete_time': message_auto_delete_time,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取默认消息自动删除时间
   */
  getDefaultMessageAutoDeleteTime(): Promise<MessageAutoDeleteTime> {
    const params: Record<string, Object> = {
      '@type': 'getDefaultMessageAutoDeleteTime',
    };
    return this.client.execute<MessageAutoDeleteTime>(params);
  }

  /**
   * 移除聊天操作栏
   * @param chat_id 聊天 ID
   */
  removeChatActionBar(chat_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeChatActionBar',
      'chat_id': chat_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 举报聊天
   * @param chat_id 聊天 ID
   * @param option_id 选项 ID
   * @param message_ids 消息 ID 列表
   * @param text 附加文本
   */
  reportChat(chat_id: number, option_id: Uint8Array, message_ids: number[], text: string): Promise<ReportChatResult> {
    const params: Record<string, Object> = {
      '@type': 'reportChat',
      'chat_id': chat_id,
      'option_id': option_id,
      'message_ids': message_ids,
      'text': text,
    };
    return this.client.execute<ReportChatResult>(params);
  }

  /**
   * 举报聊天照片
   * @param chat_id 聊天 ID
   * @param file_id 文件 ID
   * @param reason 原因
   * @param text 附加文本
   */
  reportChatPhoto(chat_id: number, file_id: number, reason: Object, text: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'reportChatPhoto',
      'chat_id': chat_id,
      'file_id': file_id,
      'reason': reason,
      'text': text,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 举报消息反应
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param sender_id 发送者 ID
   */
  reportMessageReactions(chat_id: number, message_id: number, sender_id: MessageSender): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'reportMessageReactions',
      'chat_id': chat_id,
      'message_id': message_id,
      'sender_id': sender_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取聊天收入统计
   * @param chat_id 聊天 ID
   * @param is_dark 是否暗色主题
   */
  getChatRevenueStatistics(chat_id: number, is_dark: boolean): Promise<ChatRevenueStatistics> {
    const params: Record<string, Object> = {
      '@type': 'getChatRevenueStatistics',
      'chat_id': chat_id,
      'is_dark': is_dark,
    };
    return this.client.execute<ChatRevenueStatistics>(params);
  }

  /**
   * 获取聊天收入提现 URL
   * @param chat_id 聊天 ID
   * @param password 两步验证密码
   */
  getChatRevenueWithdrawalUrl(chat_id: number, password: string): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getChatRevenueWithdrawalUrl',
      'chat_id': chat_id,
      'password': password,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 获取聊天收入交易记录
   * @param chat_id 聊天 ID
   * @param offset 偏移
   * @param limit 数量
   */
  getChatRevenueTransactions(chat_id: number, offset: string, limit: number): Promise<ChatRevenueTransactions> {
    const params: Record<string, Object> = {
      '@type': 'getChatRevenueTransactions',
      'chat_id': chat_id,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<ChatRevenueTransactions>(params);
  }

  /**
   * 获取 Toncoin 交易记录
   * @param direction 方向
   * @param offset 偏移
   * @param limit 数量
   */
  getTonTransactions(direction: Object | null, offset: string, limit: number): Promise<TonTransactions> {
    const params: Record<string, Object> = {
      '@type': 'getTonTransactions',
      'offset': offset,
      'limit': limit,
    };
    if (direction !== null) {
      params['direction'] = direction;
    }
    return this.client.execute<TonTransactions>(params);
  }

  /**
   * 获取星币收入统计
   * @param owner_id 所有者 ID
   * @param is_dark 是否暗色主题
   */
  getStarRevenueStatistics(owner_id: MessageSender, is_dark: boolean): Promise<StarRevenueStatistics> {
    const params: Record<string, Object> = {
      '@type': 'getStarRevenueStatistics',
      'owner_id': owner_id,
      'is_dark': is_dark,
    };
    return this.client.execute<StarRevenueStatistics>(params);
  }

  /**
   * 获取星币提现 URL
   * @param owner_id 所有者 ID
   * @param star_count 星币数量
   * @param password 两步验证密码
   */
  getStarWithdrawalUrl(owner_id: MessageSender, star_count: number, password: string): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getStarWithdrawalUrl',
      'owner_id': owner_id,
      'star_count': star_count,
      'password': password,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 获取 Telegram 广告账户 URL
   * @param owner_id 所有者 ID
   */
  getStarAdAccountUrl(owner_id: MessageSender): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getStarAdAccountUrl',
      'owner_id': owner_id,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 获取 Toncoin 收入统计
   * @param is_dark 是否暗色主题
   */
  getTonRevenueStatistics(is_dark: boolean): Promise<TonRevenueStatistics> {
    const params: Record<string, Object> = {
      '@type': 'getTonRevenueStatistics',
      'is_dark': is_dark,
    };
    return this.client.execute<TonRevenueStatistics>(params);
  }

  /**
   * 获取 Toncoin 提现 URL
   * @param password 两步验证密码
   */
  getTonWithdrawalUrl(password: string): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getTonWithdrawalUrl',
      'password': password,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 获取聊天统计
   * @param chat_id 聊天 ID
   * @param is_dark 是否暗色主题
   */
  getChatStatistics(chat_id: number, is_dark: boolean): Promise<ChatStatistics> {
    const params: Record<string, Object> = {
      '@type': 'getChatStatistics',
      'chat_id': chat_id,
      'is_dark': is_dark,
    };
    return this.client.execute<ChatStatistics>(params);
  }

  /**
   * 获取消息统计
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param is_dark 是否暗色主题
   */
  getMessageStatistics(chat_id: number, message_id: number, is_dark: boolean): Promise<MessageStatistics> {
    const params: Record<string, Object> = {
      '@type': 'getMessageStatistics',
      'chat_id': chat_id,
      'message_id': message_id,
      'is_dark': is_dark,
    };
    return this.client.execute<MessageStatistics>(params);
  }

  /**
   * 获取消息的公开转发
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   * @param offset 偏移
   * @param limit 数量
   */
  getMessagePublicForwards(chat_id: number, message_id: number, offset: string,
    limit: number): Promise<PublicForwards> {
    const params: Record<string, Object> = {
      '@type': 'getMessagePublicForwards',
      'chat_id': chat_id,
      'message_id': message_id,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<PublicForwards>(params);
  }

  /**
   * 获取故事统计
   * @param chat_id 聊天 ID
   * @param story_id 故事 ID
   * @param is_dark 是否暗色主题
   */
  getStoryStatistics(chat_id: number, story_id: number, is_dark: boolean): Promise<StoryStatistics> {
    const params: Record<string, Object> = {
      '@type': 'getStoryStatistics',
      'chat_id': chat_id,
      'story_id': story_id,
      'is_dark': is_dark,
    };
    return this.client.execute<StoryStatistics>(params);
  }

  /**
   * 获取统计图
   * @param chat_id 聊天 ID
   * @param token 图 token
   * @param x X 值
   */
  getStatisticalGraph(chat_id: number, token: string, x: number): Promise<StatisticalGraph> {
    const params: Record<string, Object> = {
      '@type': 'getStatisticalGraph',
      'chat_id': chat_id,
      'token': token,
      'x': x,
    };
    return this.client.execute<StatisticalGraph>(params);
  }

  /**
   * 获取存储统计
   * @param chat_limit 聊天限制
   */
  getStorageStatistics(chat_limit: number): Promise<StorageStatistics> {
    const params: Record<string, Object> = {
      '@type': 'getStorageStatistics',
      'chat_limit': chat_limit,
    };
    return this.client.execute<StorageStatistics>(params);
  }

  /**
   * 快速获取存储统计
   */
  getStorageStatisticsFast(): Promise<StorageStatisticsFast> {
    const params: Record<string, Object> = {
      '@type': 'getStorageStatisticsFast',
    };
    return this.client.execute<StorageStatisticsFast>(params);
  }

  /**
   * 获取数据库统计
   */
  getDatabaseStatistics(): Promise<DatabaseStatistics> {
    const params: Record<string, Object> = {
      '@type': 'getDatabaseStatistics',
    };
    return this.client.execute<DatabaseStatistics>(params);
  }

  /**
   * 优化存储
   * @param size 大小限制
   * @param ttl 时间限制
   * @param count 数量限制
   * @param immunity_delay 免疫延迟
   * @param file_types 文件类型过滤
   * @param chat_ids 聊天过滤
   * @param exclude_chat_ids 排除聊天过滤
   * @param return_deleted_file_statistics 是否返回删除统计
   * @param chat_limit 聊天限制
   */
  optimizeStorage(
    size: number,
    ttl: number,
    count: number,
    immunity_delay: number,
    file_types: FileType[],
    chat_ids: number[],
    exclude_chat_ids: number[],
    return_deleted_file_statistics: boolean,
    chat_limit: number
  ): Promise<StorageStatistics> {
    const params: Record<string, Object> = {
      '@type': 'optimizeStorage',
      'size': size,
      'ttl': ttl,
      'count': count,
      'immunity_delay': immunity_delay,
      'file_types': file_types,
      'chat_ids': chat_ids,
      'exclude_chat_ids': exclude_chat_ids,
      'return_deleted_file_statistics': return_deleted_file_statistics,
      'chat_limit': chat_limit,
    };
    return this.client.execute<StorageStatistics>(params);
  }

  /**
   * 设置网络类型
   * @param type 网络类型
   */
  setNetworkType(type: NetworkType): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setNetworkType',
      'type': type,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取网络统计
   * @param only_current 是否仅本次启动
   */
  getNetworkStatistics(only_current: boolean): Promise<NetworkStatistics> {
    const params: Record<string, Object> = {
      '@type': 'getNetworkStatistics',
      'only_current': only_current,
    };
    return this.client.execute<NetworkStatistics>(params);
  }

  /**
   * 添加网络统计
   * @param entry 统计条目
   */
  addNetworkStatistics(entry: NetworkStatisticsEntry): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'addNetworkStatistics',
      'entry': entry,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 重置网络统计
   */
  resetNetworkStatistics(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'resetNetworkStatistics',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取自动保存设置
   */
  getAutosaveSettings(): Promise<AutosaveSettings> {
    const params: Record<string, Object> = {
      '@type': 'getAutosaveSettings',
    };
    return this.client.execute<AutosaveSettings>(params);
  }

  /**
   * 设置自动保存设置
   * @param scope 作用域
   * @param settings 新设置（null 表示默认）
   */
  setAutosaveSettings(scope: AutosaveSettingsScope, settings: AutosaveSettings | null): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setAutosaveSettings',
      'scope': scope,
    };
    if (settings !== null) {
      params['settings'] = settings;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 清除所有自动保存设置异常
   */
  clearAutosaveSettingsExceptions(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'clearAutosaveSettingsExceptions',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取银行卡信息
   * @param bank_card_number 银行卡号
   */
  getBankCardInfo(bank_card_number: string): Promise<BankCardInfo> {
    const params: Record<string, Object> = {
      '@type': 'getBankCardInfo',
      'bank_card_number': bank_card_number,
    };
    return this.client.execute<BankCardInfo>(params);
  }

  // ==================== 证件信息 ====================

  /**
   * 获取 Passport 元素
   * @param type 元素类型
   * @param password 两步验证密码
   */
  getPassportElement(type: PassportElementType, password: string): Promise<PassportElement> {
    const params: Record<string, Object> = {
      '@type': 'getPassportElement',
      'type': type,
      'password': password,
    };
    return this.client.execute<PassportElement>(params);
  }

  /**
   * 获取所有 Passport 元素
   * @param password 两步验证密码
   */
  getAllPassportElements(password: string): Promise<PassportElements> {
    const params: Record<string, Object> = {
      '@type': 'getAllPassportElements',
      'password': password,
    };
    return this.client.execute<PassportElements>(params);
  }

  /**
   * 设置 Passport 元素
   * @param element 输入元素
   * @param password 两步验证密码
   */
  setPassportElement(element: PassportElement, password: string): Promise<PassportElement> {
    const params: Record<string, Object> = {
      '@type': 'setPassportElement',
      'element': element,
      'password': password,
    };
    return this.client.execute<PassportElement>(params);
  }

  /**
   * 删除 Passport 元素
   * @param type 元素类型
   */
  deletePassportElement(type: PassportElementType): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deletePassportElement',
      'type': type,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置 Passport 元素错误（仅 Bot）
   * @param user_id 用户 ID
   * @param errors 错误列表
   */
  setPassportElementErrors(user_id: number, errors: passportElementError[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setPassportElementErrors',
      'user_id': user_id,
      'errors': errors,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取首选国家语言
   * @param country_code 国家代码
   */
  getPreferredCountryLanguage(country_code: string): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getPreferredCountryLanguage',
      'country_code': country_code,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 发送邮箱验证码
   * @param email_address 邮箱地址
   */
  sendEmailAddressVerificationCode(email_address: string): Promise<EmailAddressAuthenticationCodeInfo> {
    const params: Record<string, Object> = {
      '@type': 'sendEmailAddressVerificationCode',
      'email_address': email_address,
    };
    return this.client.execute<EmailAddressAuthenticationCodeInfo>(params);
  }

  /**
   * 重新发送邮箱验证码
   */
  resendEmailAddressVerificationCode(): Promise<EmailAddressAuthenticationCodeInfo> {
    const params: Record<string, Object> = {
      '@type': 'resendEmailAddressVerificationCode',
    };
    return this.client.execute<EmailAddressAuthenticationCodeInfo>(params);
  }

  /**
   * 检查邮箱验证码
   * @param code 验证码
   */
  checkEmailAddressVerificationCode(code: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'checkEmailAddressVerificationCode',
      'code': code,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取 Passport 授权表单
   * @param bot_user_id Bot ID
   * @param scope 作用域
   * @param public_key 公钥
   * @param nonce 随机数
   */
  getPassportAuthorizationForm(bot_user_id: number, scope: string, public_key: string,
    nonce: string): Promise<PassportAuthorizationForm> {
    const params: Record<string, Object> = {
      '@type': 'getPassportAuthorizationForm',
      'bot_user_id': bot_user_id,
      'scope': scope,
      'public_key': public_key,
      'nonce': nonce,
    };
    return this.client.execute<PassportAuthorizationForm>(params);
  }

  /**
   * 获取 Passport 授权表单可用元素
   * @param authorization_form_id 表单 ID
   * @param password 两步验证密码
   */
  getPassportAuthorizationFormAvailableElements(authorization_form_id: number,
    password: string): Promise<PassportElementsWithErrors> {
    const params: Record<string, Object> = {
      '@type': 'getPassportAuthorizationFormAvailableElements',
      'authorization_form_id': authorization_form_id,
      'password': password,
    };
    return this.client.execute<PassportElementsWithErrors>(params);
  }

  /**
   * 发送 Passport 授权表单
   * @param authorization_form_id 表单 ID
   * @param types 选择的元素类型列表
   */
  sendPassportAuthorizationForm(authorization_form_id: number, types: PassportElementType[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'sendPassportAuthorizationForm',
      'authorization_form_id': authorization_form_id,
      'types': types,
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 机器人更新 ====================

  /**
   * 设置 Bot 更新状态（仅 Bot）
   * @param pending_update_count 待处理更新数
   * @param error_message 错误消息
   */
  setBotUpdatesStatus(pending_update_count: number, error_message: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setBotUpdatesStatus',
      'pending_update_count': pending_update_count,
      'error_message': error_message,
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 贴纸集管理 ====================

  /**
   * 创建新贴纸集
   * @param user_id 用户 ID
   * @param title 标题
   * @param name 名称
   * @param sticker_type 贴纸类型
   * @param needs_repainting 是否需要重绘
   * @param stickers 贴纸列表
   * @param source 来源
   */
  createNewStickerSet(
    user_id: number,
    title: string,
    name: string,
    sticker_type: StickerType,
    needs_repainting: boolean,
    stickers: Object[],
    source: string
  ): Promise<StickerSet> {
    const params: Record<string, Object> = {
      '@type': 'createNewStickerSet',
      'user_id': user_id,
      'title': title,
      'name': name,
      'sticker_type': sticker_type,
      'needs_repainting': needs_repainting,
      'stickers': stickers,
      'source': source,
    };
    return this.client.execute<StickerSet>(params);
  }

  /**
   * 向贴纸集添加贴纸
   * @param user_id 用户 ID
   * @param name 贴纸集名称
   * @param sticker 贴纸
   */
  addStickerToSet(user_id: number, name: string, sticker: Object): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'addStickerToSet',
      'user_id': user_id,
      'name': name,
      'sticker': sticker,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 替换贴纸集中的贴纸
   * @param user_id 用户 ID
   * @param name 贴纸集名称
   * @param old_sticker 旧贴纸
   * @param new_sticker 新贴纸
   */
  replaceStickerInSet(user_id: number, name: string, old_sticker: InputFile, new_sticker: Object): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'replaceStickerInSet',
      'user_id': user_id,
      'name': name,
      'old_sticker': old_sticker,
      'new_sticker': new_sticker,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置贴纸集缩略图
   * @param user_id 用户 ID
   * @param name 贴纸集名称
   * @param thumbnail 缩略图（null 表示移除）
   * @param format 缩略图格式（null 表示移除）
   */
  setStickerSetThumbnail(user_id: number, name: string, thumbnail: InputFile | null,
    format: StickerFormat | null): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setStickerSetThumbnail',
      'user_id': user_id,
      'name': name,
    };
    if (thumbnail !== null) {
      params['thumbnail'] = thumbnail;
    }
    if (format !== null) {
      params['format'] = format;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置自定义表情贴纸集缩略图
   * @param name 贴纸集名称
   * @param custom_emoji_id 自定义表情 ID（0 表示移除）
   */
  setCustomEmojiStickerSetThumbnail(name: string, custom_emoji_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setCustomEmojiStickerSetThumbnail',
      'name': name,
      'custom_emoji_id': custom_emoji_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置贴纸集标题
   * @param name 贴纸集名称
   * @param title 新标题
   */
  setStickerSetTitle(name: string, title: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setStickerSetTitle',
      'name': name,
      'title': title,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 删除贴纸集
   * @param name 贴纸集名称
   */
  deleteStickerSet(name: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'deleteStickerSet',
      'name': name,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置贴纸在集中的位置
   * @param sticker 贴纸
   * @param position 新位置（0-based）
   */
  setStickerPositionInSet(sticker: InputFile, position: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setStickerPositionInSet',
      'sticker': sticker,
      'position': position,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 从集中移除贴纸
   * @param sticker 贴纸
   */
  removeStickerFromSet(sticker: InputFile): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeStickerFromSet',
      'sticker': sticker,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置贴纸的表情
   * @param sticker 贴纸
   * @param emojis 表情字符串（1-20 个）
   */
  setStickerEmojis(sticker: InputFile, emojis: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setStickerEmojis',
      'sticker': sticker,
      'emojis': emojis,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置贴纸的关键词
   * @param sticker 贴纸
   * @param keywords 关键词列表（最多 20 个，总长 ≤ 64）
   */
  setStickerKeywords(sticker: InputFile, keywords: string[]): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setStickerKeywords',
      'sticker': sticker,
      'keywords': keywords,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置遮罩贴纸的遮罩位置
   * @param sticker 贴纸
   * @param mask_position 遮罩位置（null 表示移除）
   */
  setStickerMaskPosition(sticker: InputFile, mask_position: Position | null): Promise<Ok> {
    const params = {} as Record<string, Object>;
    params['@type'] = 'setStickerMaskPosition';
    params['sticker'] = sticker;
    if (mask_position !== null) {
      params['mask_position'] = mask_position;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取用户拥有的贴纸集
   * @param offset_sticker_set_id 偏移贴纸集 ID
   * @param limit 数量
   */
  getOwnedStickerSets(offset_sticker_set_id: number, limit: number): Promise<StickerSets> {
    const params: Record<string, Object> = {
      '@type': 'getOwnedStickerSets',
      'offset_sticker_set_id': offset_sticker_set_id,
      'limit': limit,
    };
    return this.client.execute<StickerSets>(params);
  }

  /**
   * 获取 Premium 限制信息
   * @param limit_type 限制类型
   */
  getPremiumLimit(limit_type: PremiumLimitType): Promise<PremiumLimit> {
    const params: Record<string, Object> = {
      '@type': 'getPremiumLimit',
      'limit_type': limit_type,
    };
    return this.client.execute<PremiumLimit>(params);
  }

  /**
   * 获取 Premium 功能信息
   * @param source 来源
   */
  getPremiumFeatures(source: Object): Promise<PremiumFeatures> {
    const params = {} as Record<string, Object>;
    params['@type'] = 'getPremiumFeatures';
    params['source'] = source;
    return this.client.execute<PremiumFeatures>(params);
  }

  /**
   * 获取 Premium 贴纸示例
   */
  getPremiumStickerExamples(): Promise<Stickers> {
    const params: Record<string, Object> = {
      '@type': 'getPremiumStickerExamples',
    };
    return this.client.execute<Stickers>(params);
  }

  /**
   * 获取 Premium 信息贴纸
   * @param month_count 月数
   */
  getPremiumInfoSticker(month_count: number): Promise<Sticker> {
    const params: Record<string, Object> = {
      '@type': 'getPremiumInfoSticker',
      'month_count': month_count,
    };
    return this.client.execute<Sticker>(params);
  }

  /**
   * 标记 Premium 功能已查看
   * @param feature Premium 功能
   */
  viewPremiumFeature(feature: PremiumFeature): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'viewPremiumFeature',
      'feature': feature,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 点击 Premium 订阅按钮
   */
  clickPremiumSubscriptionButton(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'clickPremiumSubscriptionButton',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取 Premium 状态
   */
  getPremiumState(): Promise<PremiumState> {
    const params: Record<string, Object> = {
      '@type': 'getPremiumState',
    };
    return this.client.execute<PremiumState>(params);
  }

  /**
   * 获取 Premium 礼品支付选项
   */
  getPremiumGiftPaymentOptions(): Promise<PremiumGiftPaymentOptions> {
    const params: Record<string, Object> = {
      '@type': 'getPremiumGiftPaymentOptions',
    };
    return this.client.execute<PremiumGiftPaymentOptions>(params);
  }

  /**
   * 获取 Premium 赠品支付选项
   * @param boosted_chat_id 被提升的聊天 ID
   */
  getPremiumGiveawayPaymentOptions(boosted_chat_id: number): Promise<PremiumGiveawayPaymentOptions> {
    const params: Record<string, Object> = {
      '@type': 'getPremiumGiveawayPaymentOptions',
      'boosted_chat_id': boosted_chat_id,
    };
    return this.client.execute<PremiumGiveawayPaymentOptions>(params);
  }

  /**
   * 检查 Premium 礼品码
   * @param code 礼品码
   */
  checkPremiumGiftCode(code: string): Promise<PremiumGiftCodeInfo> {
    const params: Record<string, Object> = {
      '@type': 'checkPremiumGiftCode',
      'code': code,
    };
    return this.client.execute<PremiumGiftCodeInfo>(params);
  }

  /**
   * 应用 Premium 礼品码
   * @param code 礼品码
   */
  applyPremiumGiftCode(code: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'applyPremiumGiftCode',
      'code': code,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 使用星币赠送 Premium（仅 Bot）
   * @param user_id 用户 ID
   * @param star_count 星币数量
   * @param month_count 月数
   * @param text 附言
   */
  giftPremiumWithStars(user_id: number, star_count: number, month_count: number, text: FormattedText): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'giftPremiumWithStars',
      'user_id': user_id,
      'star_count': star_count,
      'month_count': month_count,
      'text': text,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 启动预付赠品
   * @param giveaway_id 赠品 ID
   * @param parameters 赠品参数
   * @param winner_count 获奖人数
   * @param star_count 星币数量
   */
  launchPrepaidGiveaway(giveaway_id: number, parameters: giveawayParameters, winner_count: number,
    star_count: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'launchPrepaidGiveaway',
      'giveaway_id': giveaway_id,
      'parameters': parameters,
      'winner_count': winner_count,
      'star_count': star_count,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取赠品信息
   * @param chat_id 聊天 ID
   * @param message_id 消息 ID
   */
  getGiveawayInfo(chat_id: number, message_id: number): Promise<GiveawayInfo> {
    const params: Record<string, Object> = {
      '@type': 'getGiveawayInfo',
      'chat_id': chat_id,
      'message_id': message_id,
    };
    return this.client.execute<GiveawayInfo>(params);
  }

  /**
   * 获取星币支付选项
   */
  getStarPaymentOptions(): Promise<StarPaymentOptions> {
    const params: Record<string, Object> = {
      '@type': 'getStarPaymentOptions',
    };
    return this.client.execute<StarPaymentOptions>(params);
  }

  /**
   * 获取星币礼品支付选项
   * @param user_id 用户 ID
   */
  getStarGiftPaymentOptions(user_id: number): Promise<StarPaymentOptions> {
    const params: Record<string, Object> = {
      '@type': 'getStarGiftPaymentOptions',
      'user_id': user_id,
    };
    return this.client.execute<StarPaymentOptions>(params);
  }

  /**
   * 获取星币赠品支付选项
   */
  getStarGiveawayPaymentOptions(): Promise<StarGiveawayPaymentOptions> {
    const params: Record<string, Object> = {
      '@type': 'getStarGiveawayPaymentOptions',
    };
    return this.client.execute<StarGiveawayPaymentOptions>(params);
  }

  /**
   * 获取星币交易记录
   * @param owner_id 所有者 ID
   * @param subscription_id 订阅 ID
   * @param direction 方向
   * @param offset 偏移
   * @param limit 数量
   */
  getStarTransactions(
    owner_id: MessageSender,
    subscription_id: string,
    direction: Object | null,
    offset: string,
    limit: number
  ): Promise<StarTransactions> {
    const params = {} as Record<string, Object>;
    params['@type'] = 'getStarTransactions';
    params['owner_id'] = owner_id;
    params['subscription_id'] = subscription_id;
    if (direction !== null) {
      params['direction'] = direction;
    }
    params['offset'] = offset;
    params['limit'] = limit;
    return this.client.execute<StarTransactions>(params);
  }

  /**
   * 获取星币订阅
   * @param only_expiring 是否仅即将过期
   * @param offset 偏移
   */
  getStarSubscriptions(only_expiring: boolean, offset: string): Promise<StarSubscriptions> {
    const params: Record<string, Object> = {
      '@type': 'getStarSubscriptions',
      'only_expiring': only_expiring,
      'offset': offset,
    };
    return this.client.execute<StarSubscriptions>(params);
  }

  /**
   * 检查是否可以购买（仅官方应用）
   * @param purpose 购买目的
   */
  canPurchaseFromStore(purpose: Object): Promise<Ok> {
    const params = {} as Record<string, Object>;
    params['@type'] = 'canPurchaseFromStore';
    params['purpose'] = purpose;
    return this.client.execute<Ok>(params);
  }

  /**
   * 分配商店交易（仅官方应用）
   * @param transaction 交易信息
   * @param purpose 购买目的
   */
  assignStoreTransaction(transaction: StoreTransaction$Input, purpose: Object): Promise<Ok> {
    const params = {} as Record<string, Object>;
    params['@type'] = 'assignStoreTransaction';
    params['transaction'] = transaction;
    params['purpose'] = purpose;
    return this.client.execute<Ok>(params);
  }

  /**
   * 编辑星币订阅（取消/重新启用）
   * @param subscription_id 订阅 ID
   * @param is_canceled 是否取消
   */
  editStarSubscription(subscription_id: string, is_canceled: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'editStarSubscription',
      'subscription_id': subscription_id,
      'is_canceled': is_canceled,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 编辑用户的星币订阅（仅 Bot）
   * @param user_id 用户 ID
   * @param telegram_payment_charge_id Telegram 支付 ID
   * @param is_canceled 是否取消
   */
  editUserStarSubscription(user_id: number, telegram_payment_charge_id: string, is_canceled: boolean): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'editUserStarSubscription',
      'user_id': user_id,
      'telegram_payment_charge_id': telegram_payment_charge_id,
      'is_canceled': is_canceled,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 重用星币订阅（重新加入频道）
   * @param subscription_id 订阅 ID
   */
  reuseStarSubscription(subscription_id: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'reuseStarSubscription',
      'subscription_id': subscription_id,
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 联盟计划 ====================

  /**
   * 设置聊天联盟计划（仅 Bot）
   * @param chat_id 聊天 ID
   * @param parameters 计划参数（null 表示关闭）
   */
  setChatAffiliateProgram(chat_id: number, parameters: affiliateProgramParameters | null): Promise<Ok> {
    const params = {} as Record<string, Object>;
    params['@type'] = 'setChatAffiliateProgram';
    params['chat_id'] = chat_id;
    if (parameters !== null) {
      params['parameters'] = parameters;
    }
    return this.client.execute<Ok>(params);
  }

  /**
   * 搜索有联盟计划的聊天
   * @param username 用户名
   * @param referrer 推荐人
   */
  searchChatAffiliateProgram(username: string, referrer: string): Promise<Chat> {
    const params: Record<string, Object> = {
      '@type': 'searchChatAffiliateProgram',
      'username': username,
      'referrer': referrer,
    };
    return this.client.execute<Chat>(params);
  }

  /**
   * 搜索联盟计划
   * @param affiliate 联盟方
   * @param sort_order 排序方式
   * @param offset 偏移
   * @param limit 数量
   */
  searchAffiliatePrograms(
    affiliate: Object,
    sort_order: AffiliateProgramSortOrder$Input,
    offset: string,
    limit: number
  ): Promise<FoundAffiliatePrograms> {
    const params: Record<string, Object> = {
      '@type': 'searchAffiliatePrograms',
      'affiliate': affiliate,
      'sort_order': sort_order,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<FoundAffiliatePrograms>(params);
  }

  /**
   * 连接联盟计划
   * @param affiliate 联盟方
   * @param bot_user_id Bot ID
   */
  connectAffiliateProgram(affiliate: Object, bot_user_id: number): Promise<ConnectedAffiliateProgram> {
    const params: Record<string, Object> = {
      '@type': 'connectAffiliateProgram',
      'affiliate': affiliate,
      'bot_user_id': bot_user_id,
    };
    return this.client.execute<ConnectedAffiliateProgram>(params);
  }

  /**
   * 断开联盟计划
   * @param affiliate 联盟方
   * @param url 链接
   */
  disconnectAffiliateProgram(affiliate: Object, url: string): Promise<ConnectedAffiliateProgram> {
    const params: Record<string, Object> = {
      '@type': 'disconnectAffiliateProgram',
      'affiliate': affiliate,
      'url': url,
    };
    return this.client.execute<ConnectedAffiliateProgram>(params);
  }

  /**
   * 获取连接的联盟计划
   * @param affiliate 联盟方
   * @param bot_user_id Bot ID
   */
  getConnectedAffiliateProgram(affiliate: Object, bot_user_id: number): Promise<ConnectedAffiliateProgram> {
    const params: Record<string, Object> = {
      '@type': 'getConnectedAffiliateProgram',
      'affiliate': affiliate,
      'bot_user_id': bot_user_id,
    };
    return this.client.execute<ConnectedAffiliateProgram>(params);
  }

  /**
   * 获取所有连接的联盟计划
   * @param affiliate 联盟方
   * @param offset 偏移
   * @param limit 数量
   */
  getConnectedAffiliatePrograms(affiliate: Object, offset: string, limit: number): Promise<ConnectedAffiliatePrograms> {
    const params: Record<string, Object> = {
      '@type': 'getConnectedAffiliatePrograms',
      'affiliate': affiliate,
      'offset': offset,
      'limit': limit,
    };
    return this.client.execute<ConnectedAffiliatePrograms>(params);
  }

  /**
   * 获取商业功能信息
   * @param source 来源
   */
  getBusinessFeatures(source: BusinessFeature): Promise<BusinessFeatures> {
    const params: Record<string, Object> = {
      '@type': 'getBusinessFeatures',
      'source': source,
    };
    return this.client.execute<BusinessFeatures>(params);
  }

  // ==================== 服务条款 ====================

  /**
   * 接受服务条款
   * @param terms_of_service_id 服务条款 ID
   */
  acceptTermsOfService(terms_of_service_id: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'acceptTermsOfService',
      'terms_of_service_id': terms_of_service_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 按前缀搜索字符串（同步）
   * @param strings 字符串列表
   * @param query 查询字符串
   * @param limit 最大数量
   * @param return_none_for_empty_query 空查询是否返回空
   */
  searchStringsByPrefix(strings: string[], query: string, limit: number,
    return_none_for_empty_query: boolean): Promise<number[]> {
    const params: Record<string, Object> = {
      '@type': 'searchStringsByPrefix',
      'strings': strings,
      'query': query,
      'limit': limit,
      'return_none_for_empty_query': return_none_for_empty_query,
    };
    return this.client.execute<number[]>(params);
  }

  /**
   * 发送自定义请求（仅 Bot）
   * @param method 方法名
   * @param parameters JSON 参数
   */
  sendCustomRequest(method: string, parameters: string): Promise<CustomRequestResult> {
    const params: Record<string, Object> = {
      '@type': 'sendCustomRequest',
      'method': method,
      'parameters': parameters,
    };
    return this.client.execute<CustomRequestResult>(params);
  }

  /**
   * 回答自定义查询（仅 Bot）
   * @param custom_query_id 查询 ID
   * @param data JSON 答案
   */
  answerCustomQuery(custom_query_id: number, data: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'answerCustomQuery',
      'custom_query_id': custom_query_id,
      'data': data,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 设置闹钟（测试用）
   * @param seconds 秒数
   */
  setAlarm(seconds: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setAlarm',
      'seconds': seconds,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取国家列表
   */
  getCountries(): Promise<Countries> {
    const params: Record<string, Object> = {
      '@type': 'getCountries',
    };
    return this.client.execute<Countries>(params);
  }

  /**
   * 获取国家代码
   */
  getCountryCode(): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getCountryCode',
    };
    return this.client.execute<string>(params);
  }

  /**
   * 获取电话号码信息
   * @param phone_number_prefix 号码前缀
   */
  getPhoneNumberInfo(phone_number_prefix: string): Promise<PhoneNumberInfo> {
    const params: Record<string, Object> = {
      '@type': 'getPhoneNumberInfo',
      'phone_number_prefix': phone_number_prefix,
    };
    return this.client.execute<PhoneNumberInfo>(params);
  }

  /**
   * 同步获取电话号码信息
   * @param language_code 语言代码
   * @param phone_number_prefix 号码前缀
   */
  getPhoneNumberInfoSync(language_code: string, phone_number_prefix: string): Promise<PhoneNumberInfo> {
    const params: Record<string, Object> = {
      '@type': 'getPhoneNumberInfoSync',
      'language_code': language_code,
      'phone_number_prefix': phone_number_prefix,
    };
    return this.client.execute<PhoneNumberInfo>(params);
  }

  /**
   * 获取收藏品信息
   * @param type 收藏品类型
   */
  getCollectibleItemInfo(type: CollectibleItemType$Input): Promise<CollectibleItemInfo> {
    const params: Record<string, Object> = {
      '@type': 'getCollectibleItemInfo',
      'type': type,
    };
    return this.client.execute<CollectibleItemInfo>(params);
  }

  /**
   * 获取深度链接信息
   * @param link 链接
   */
  getDeepLinkInfo(link: string): Promise<DeepLinkInfo> {
    const params: Record<string, Object> = {
      '@type': 'getDeepLinkInfo',
      'link': link,
    };
    return this.client.execute<DeepLinkInfo>(params);
  }

  /**
   * 获取应用配置
   */
  getApplicationConfig(): Promise<JsonValue> {
    const params: Record<string, Object> = {
      '@type': 'getApplicationConfig',
    };
    return this.client.execute<JsonValue>(params);
  }

  /**
   * 保存应用日志事件
   * @param type 类型
   * @param chat_id 聊天 ID
   * @param data 数据
   */
  saveApplicationLogEvent(type: string, chat_id: number, data: JsonValue): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'saveApplicationLogEvent',
      'type': type,
      'chat_id': chat_id,
      'data': data,
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 代理 ====================

  /**
   * 添加代理
   * @param proxy 代理
   * @param enable 是否立即启用
   */
  addProxy(proxy: proxy, enable: boolean): Promise<AddedProxy> {
    const params: Record<string, Object> = {
      '@type': 'addProxy',
      'proxy': proxy,
      'enable': enable,
    };
    return this.client.execute<AddedProxy>(params);
  }

  /**
   * 编辑代理
   * @param proxy_id 代理 ID
   * @param proxy 新代理信息
   * @param enable 是否立即启用
   */
  editProxy(proxy_id: number, proxy: proxy, enable: boolean): Promise<AddedProxy> {
    const params: Record<string, Object> = {
      '@type': 'editProxy',
      'proxy_id': proxy_id,
      'proxy': proxy,
      'enable': enable,
    };
    return this.client.execute<AddedProxy>(params);
  }

  /**
   * 启用代理
   * @param proxy_id 代理 ID
   */
  enableProxy(proxy_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'enableProxy',
      'proxy_id': proxy_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 禁用代理
   */
  disableProxy(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'disableProxy',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 移除代理
   * @param proxy_id 代理 ID
   */
  removeProxy(proxy_id: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'removeProxy',
      'proxy_id': proxy_id,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取代理列表
   */
  getProxies(): Promise<AddedProxies> {
    const params: Record<string, Object> = {
      '@type': 'getProxies',
    };
    return this.client.execute<AddedProxies>(params);
  }

  /**
   * Ping 代理
   * @param proxy 代理（null 表示直连）
   */
  pingProxy(proxy?: proxy): Promise<number> {
    const params: Record<string, Object> = {
      '@type': 'pingProxy',
    };
    if (proxy !== undefined) {
      params['proxy'] = proxy;
    }
    return this.client.execute<number>(params);
  }

  // ==================== 日志 ====================

  /**
   * 设置日志流（同步）
   * @param log_stream 日志流
   */
  setLogStream(log_stream: LogStream): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setLogStream',
      'log_stream': log_stream,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取日志流（同步）
   */
  getLogStream(): Promise<LogStream> {
    const params: Record<string, Object> = {
      '@type': 'getLogStream',
    };
    return this.client.execute<LogStream>(params);
  }

  /**
   * 设置日志详细程度（同步）
   * @param new_verbosity_level 新级别（0-1023）
   */
  setLogVerbosityLevel(new_verbosity_level: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setLogVerbosityLevel',
      'new_verbosity_level': new_verbosity_level,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取日志详细程度（同步）
   */
  getLogVerbosityLevel(): Promise<number> {
    const params: Record<string, Object> = {
      '@type': 'getLogVerbosityLevel',
    };
    return this.client.execute<number>(params);
  }

  /**
   * 获取日志标签（同步）
   */
  getLogTags(): Promise<string[]> {
    const params: Record<string, Object> = {
      '@type': 'getLogTags',
    };
    return this.client.execute<string[]>(params);
  }

  /**
   * 设置日志标签详细程度（同步）
   * @param tag 标签
   * @param new_verbosity_level 新级别（1-1024）
   */
  setLogTagVerbosityLevel(tag: string, new_verbosity_level: number): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'setLogTagVerbosityLevel',
      'tag': tag,
      'new_verbosity_level': new_verbosity_level,
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 获取日志标签详细程度（同步）
   * @param tag 标签
   */
  getLogTagVerbosityLevel(tag: string): Promise<number> {
    const params: Record<string, Object> = {
      '@type': 'getLogTagVerbosityLevel',
      'tag': tag,
    };
    return this.client.execute<number>(params);
  }

  /**
   * 添加日志消息（同步）
   * @param verbosity_level 最低级别
   * @param text 消息文本
   */
  addLogMessage(verbosity_level: number, text: string): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'addLogMessage',
      'verbosity_level': verbosity_level,
      'text': text,
    };
    return this.client.execute<Ok>(params);
  }

  // ==================== 支持 ====================

  /**
   * 获取用户支持信息（仅支持）
   * @param user_id 用户 ID
   */
  getUserSupportInfo(user_id: number): Promise<UserSupportInfo> {
    const params: Record<string, Object> = {
      '@type': 'getUserSupportInfo',
      'user_id': user_id,
    };
    return this.client.execute<UserSupportInfo>(params);
  }

  /**
   * 设置用户支持信息（仅支持）
   * @param user_id 用户 ID
   * @param message 信息
   */
  setUserSupportInfo(user_id: number, message: FormattedText): Promise<UserSupportInfo> {
    const params: Record<string, Object> = {
      '@type': 'setUserSupportInfo',
      'user_id': user_id,
      'message': message,
    };
    return this.client.execute<UserSupportInfo>(params);
  }

  /**
   * 获取支持名称（仅支持）
   */
  getSupportName(): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'getSupportName',
    };
    return this.client.execute<string>(params);
  }

  // ==================== 测试方法 ====================

  /**
   * 测试空调用（离线）
   */
  testCallEmpty(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'testCallEmpty',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 测试字符串（离线）
   * @param x 字符串
   */
  testCallString(x: string): Promise<string> {
    const params: Record<string, Object> = {
      '@type': 'testCallString',
      'x': x,
    };
    return this.client.execute<string>(params);
  }

  /**
   * 测试字节数组（离线）
   * @param x 字节数组
   */
  testCallBytes(x: Uint8Array): Promise<Uint8Array> {
    const params: Record<string, Object> = {
      '@type': 'testCallBytes',
      'x': x,
    };
    return this.client.execute<Uint8Array>(params);
  }

  /**
   * 测试整数向量（离线）
   * @param x 整数数组
   */
  testCallVectorInt(x: number[]): Promise<number[]> {
    const params: Record<string, Object> = {
      '@type': 'testCallVectorInt',
      'x': x,
    };
    return this.client.execute<number[]>(params);
  }

  /**
   * 测试整数对象向量（离线）
   * @param x 整数对象数组
   */
  testCallVectorIntObject(x: TestInt[]): Promise<TestInt[]> {
    const params: Record<string, Object> = {
      '@type': 'testCallVectorIntObject',
      'x': x,
    };
    return this.client.execute<TestInt[]>(params);
  }

  /**
   * 测试字符串向量（离线）
   * @param x 字符串数组
   */
  testCallVectorString(x: string[]): Promise<string[]> {
    const params: Record<string, Object> = {
      '@type': 'testCallVectorString',
      'x': x,
    };
    return this.client.execute<string[]>(params);
  }

  /**
   * 测试字符串对象向量（离线）
   * @param x 字符串对象数组
   */
  testCallVectorStringObject(x: TestString[]): Promise<TestString[]> {
    const params: Record<string, Object> = {
      '@type': 'testCallVectorStringObject',
      'x': x,
    };
    return this.client.execute<TestString[]>(params);
  }

  /**
   * 测试平方（离线）
   * @param x 整数
   */
  testSquareInt(x: number): Promise<number> {
    const params: Record<string, Object> = {
      '@type': 'testSquareInt',
      'x': x,
    };
    return this.client.execute<number>(params);
  }

  /**
   * 测试网络请求
   */
  testNetwork(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'testNetwork',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 测试代理网络请求
   * @param proxy 代理
   * @param dc_id 数据中心 ID
   * @param timeout 超时
   */
  testProxy(proxy: proxy, dc_id: number, timeout: number): Promise<number> {
    const params: Record<string, Object> = {
      '@type': 'testProxy',
      'proxy': proxy,
      'dc_id': dc_id,
      'timeout': timeout,
    };
    return this.client.execute<number>(params);
  }

  /**
   * 测试 GetDifference（仅测试）
   */
  testGetDifference(): Promise<Ok> {
    const params: Record<string, Object> = {
      '@type': 'testGetDifference',
    };
    return this.client.execute<Ok>(params);
  }

  /**
   * 测试 Update 使用（离线）
   */
  testUseUpdate(): Promise<Update> {
    const params: Record<string, Object> = {
      '@type': 'testUseUpdate',
    };
    return this.client.execute<Update>(params);
  }

  /**
   * 返回指定错误（测试用）
   * @param error 错误对象
   */
  testReturnError(error: Error): Promise<Error> {
    const params: Record<string, Object> = {
      '@type': 'testReturnError',
      'error': error,
    };
    return this.client.execute<Error>(params);
  }
}