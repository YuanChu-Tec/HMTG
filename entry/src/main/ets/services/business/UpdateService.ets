/**
 * UpdateService.ets
 * 职责：接收所有 TDLib 原始更新，解析后调用 CoreService 的业务方法。
 * 不维护任何业务状态，只做"原始更新 → 方法调用"的转换。
 */
import { EventBus } from '../../utils/event/EventBus';
import { CoreService } from './CoreService';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class UpdateService {
  private eventBus = EventBus.getInstance();
  private coreService = CoreService.getInstance();

  constructor() {
    this.subscribeToAllUpdates();
  }

  private subscribeToAllUpdates(): void {
    // ==================== 消息相关 ====================
    this.eventBus.on('updateNewMessage', this.onUpdateNewMessage.bind(this));
    this.eventBus.on('updateMessageSendSucceeded', this.onUpdateMessageSendSucceeded.bind(this));
    this.eventBus.on('updateMessageSendFailed', this.onUpdateMessageSendFailed.bind(this));
    this.eventBus.on('updateMessageContent', this.onUpdateMessageContent.bind(this));
    this.eventBus.on('updateMessageEdited', this.onUpdateMessageEdited.bind(this));
    this.eventBus.on('updateDeleteMessages', this.onUpdateDeleteMessages.bind(this));
    this.eventBus.on('updateMessageViews', this.onUpdateMessageViews.bind(this));
    this.eventBus.on('updateMessageInteractionInfo', this.onUpdateMessageInteractionInfo.bind(this));
    this.eventBus.on('updateMessageContentOpened', this.onUpdateMessageContentOpened.bind(this));
    this.eventBus.on('updateMessageMentionRead', this.onUpdateMessageMentionRead.bind(this));
    this.eventBus.on('updateMessageLiveLocationViewed', this.onUpdateMessageLiveLocationViewed.bind(this));
    this.eventBus.on('updateMessageFactCheck', this.onUpdateMessageFactCheck.bind(this));

    // ==================== 聊天相关 ====================
    this.eventBus.on('updateNewChat', this.onUpdateNewChat.bind(this));
    this.eventBus.on('updateChatLastMessage', this.onUpdateChatLastMessage.bind(this));
    this.eventBus.on('updateChatPosition', this.onUpdateChatPosition.bind(this));
    this.eventBus.on('updateChatReadInbox', this.onUpdateChatReadInbox.bind(this));
    this.eventBus.on('updateChatReadOutbox', this.onUpdateChatReadOutbox.bind(this));
    this.eventBus.on('updateChatTitle', this.onUpdateChatTitle.bind(this));
    this.eventBus.on('updateChatPhoto', this.onUpdateChatPhoto.bind(this));
    this.eventBus.on('updateChatPermissions', this.onUpdateChatPermissions.bind(this));
    this.eventBus.on('updateChatThemes', this.onUpdateChatThemes.bind(this));
    this.eventBus.on('updateChatDraftMessage', this.onUpdateChatDraftMessage.bind(this));
    this.eventBus.on('updateChatIsPinned', this.onUpdateChatIsPinned.bind(this));
    this.eventBus.on('updateChatIsBlocked', this.onUpdateChatIsBlocked.bind(this));
    this.eventBus.on('updateChatHasScheduledMessages', this.onUpdateChatHasScheduledMessages.bind(this));
    this.eventBus.on('updateChatMessageSender', this.onUpdateChatMessageSender.bind(this));
    this.eventBus.on('updateChatMessageTtl', this.onUpdateChatMessageTtl.bind(this));
    this.eventBus.on('updateChatNotificationSettings', this.onUpdateChatNotificationSettings.bind(this));
    this.eventBus.on('updateChatActionBar', this.onUpdateChatActionBar.bind(this));
    this.eventBus.on('updateChatPendingJoinRequests', this.onUpdateChatPendingJoinRequests.bind(this));
    this.eventBus.on('updateChatReplyMarkup', this.onUpdateChatReplyMarkup.bind(this));
    this.eventBus.on('updateChatAvailableReactions', this.onUpdateChatAvailableReactions.bind(this));
    this.eventBus.on('updateChatVideoChat', this.onUpdateChatVideoChat.bind(this));
    this.eventBus.on('updateChatDefaultDisableNotification', this.onUpdateChatDefaultDisableNotification.bind(this));
    this.eventBus.on('updateChatHasProtectedContent', this.onUpdateChatHasProtectedContent.bind(this));
    this.eventBus.on('updateChatIsMarkedAsUnread', this.onUpdateChatIsMarkedAsUnread.bind(this));
    this.eventBus.on('updateChatOnlineMemberCount', this.onUpdateChatOnlineMemberCount.bind(this));
    this.eventBus.on('updateChatBackground', this.onUpdateChatBackground.bind(this));
    this.eventBus.on('updateChatSuggestion', this.onUpdateChatSuggestion.bind(this));
    this.eventBus.on('updateChatBoost', this.onUpdateChatBoost.bind(this));
    this.eventBus.on('updateChatBoostStatus', this.onUpdateChatBoostStatus.bind(this));
    this.eventBus.on('updateChatIsSponsored', this.onUpdateChatIsSponsored.bind(this));
    this.eventBus.on('updateChatStatistics', this.onUpdateChatStatistics.bind(this));
    this.eventBus.on('updateChatAction', this.onUpdateChatAction.bind(this));

    // ==================== 用户相关 ====================
    this.eventBus.on('updateUser', this.onUpdateUser.bind(this));
    this.eventBus.on('updateUserFullInfo', this.onUpdateUserFullInfo.bind(this));
    this.eventBus.on('updateUserStatus', this.onUpdateUserStatus.bind(this));
    this.eventBus.on('updateUserPrivacySettingRules', this.onUpdateUserPrivacySettingRules.bind(this));
    this.eventBus.on('updateUserUsername', this.onUpdateUserUsername.bind(this));

    // ==================== 群组/超级群组相关 ====================
    this.eventBus.on('updateBasicGroup', this.onUpdateBasicGroup.bind(this));
    this.eventBus.on('updateBasicGroupFullInfo', this.onUpdateBasicGroupFullInfo.bind(this));
    this.eventBus.on('updateSupergroup', this.onUpdateSupergroup.bind(this));
    this.eventBus.on('updateSupergroupFullInfo', this.onUpdateSupergroupFullInfo.bind(this));
    this.eventBus.on('updateSupergroupReactionSetting', this.onUpdateSupergroupReactionSetting.bind(this));

    // ==================== 秘密聊天 ====================
    this.eventBus.on('updateSecretChat', this.onUpdateSecretChat.bind(this));
    this.eventBus.on('updateSecretChatRead', this.onUpdateSecretChatRead.bind(this));

    // ==================== 授权与连接 ====================
    this.eventBus.on('updateAuthorizationState', this.onUpdateAuthorizationState.bind(this));
    this.eventBus.on('updateConnectionState', this.onUpdateConnectionState.bind(this));
    this.eventBus.on('updateOption', this.onUpdateOption.bind(this));
    this.eventBus.on('updateServiceNotification', this.onUpdateServiceNotification.bind(this));
    this.eventBus.on('updateTermsOfService', this.onUpdateTermsOfService.bind(this));

    // ==================== 通知 ====================
    this.eventBus.on('updateActiveNotifications', this.onUpdateActiveNotifications.bind(this));
    this.eventBus.on('updateNotification', this.onUpdateNotification.bind(this));
    this.eventBus.on('updateNotificationGroup', this.onUpdateNotificationGroup.bind(this));

    // ==================== 未读计数 ====================
    this.eventBus.on('updateUnreadMessageCount', this.onUpdateUnreadMessageCount.bind(this));
    this.eventBus.on('updateUnreadChatCount', this.onUpdateUnreadChatCount.bind(this));

    // ==================== 文件 ====================
    this.eventBus.on('updateFile', this.onUpdateFile.bind(this));
    this.eventBus.on('updateFileGenerationStart', this.onUpdateFileGenerationStart.bind(this));
    this.eventBus.on('updateFileGenerationStop', this.onUpdateFileGenerationStop.bind(this));

    // ==================== 通话 ====================
    this.eventBus.on('updateNewCall', this.onUpdateNewCall.bind(this));
    this.eventBus.on('updateCall', this.onUpdateCall.bind(this));
    this.eventBus.on('updateGroupCall', this.onUpdateGroupCall.bind(this));
    this.eventBus.on('updateGroupCallParticipant', this.onUpdateGroupCallParticipant.bind(this));

    // ==================== 机器人相关 ====================
    this.eventBus.on('updateNewCustomQuery', this.onUpdateNewCustomQuery.bind(this));
    this.eventBus.on('updateNewCallbackQuery', this.onUpdateNewCallbackQuery.bind(this));
    this.eventBus.on('updateNewInlineQuery', this.onUpdateNewInlineQuery.bind(this));
    this.eventBus.on('updateNewPreCheckoutQuery', this.onUpdateNewPreCheckoutQuery.bind(this));
    this.eventBus.on('updateNewChosenInlineResult', this.onUpdateNewChosenInlineResult.bind(this));
    this.eventBus.on('updateNewShippingQuery', this.onUpdateNewShippingQuery.bind(this));

    // ==================== 投票 ====================
    this.eventBus.on('updatePoll', this.onUpdatePoll.bind(this));
    this.eventBus.on('updatePollAnswer', this.onUpdatePollAnswer.bind(this));

    // ==================== 故事 ====================
    this.eventBus.on('updateNewStory', this.onUpdateNewStory.bind(this));
    this.eventBus.on('updateStory', this.onUpdateStory.bind(this));
    this.eventBus.on('updateStoryDeleted', this.onUpdateStoryDeleted.bind(this));
    this.eventBus.on('updateChatActiveStories', this.onUpdateChatActiveStories.bind(this));
    this.eventBus.on('updateChatSentStory', this.onUpdateChatSentStory.bind(this));
    this.eventBus.on('updateChatStory', this.onUpdateChatStory.bind(this));
    this.eventBus.on('updateStoryInteractionInfo', this.onUpdateStoryInteractionInfo.bind(this));
    this.eventBus.on('updateStoryList', this.onUpdateStoryList.bind(this));
    this.eventBus.on('updateChatReceiveStory', this.onUpdateChatReceiveStory.bind(this));
    this.eventBus.on('updateChatStoryInteractiveArea', this.onUpdateChatStoryInteractiveArea.bind(this));

    // ==================== 贴纸/表情 ====================
    this.eventBus.on('updateInstalledStickerSets', this.onUpdateInstalledStickerSets.bind(this));
    this.eventBus.on('updateTrendingStickerSets', this.onUpdateTrendingStickerSets.bind(this));
    this.eventBus.on('updateRecentStickers', this.onUpdateRecentStickers.bind(this));
    this.eventBus.on('updateFavoriteStickers', this.onUpdateFavoriteStickers.bind(this));
    this.eventBus.on('updateRecentEmojiStatuses', this.onUpdateRecentEmojiStatuses.bind(this));
    this.eventBus.on('updateEmojiReaction', this.onUpdateEmojiReaction.bind(this));
    this.eventBus.on('updateEmojiStatus', this.onUpdateEmojiStatus.bind(this));
    this.eventBus.on('updateDiceEmojis', this.onUpdateDiceEmojis.bind(this));
    this.eventBus.on('updateAnimatedEmojiMessageClicked', this.onUpdateAnimatedEmojiMessageClicked.bind(this));
    this.eventBus.on('updateAnimationSearchParameters', this.onUpdateAnimationSearchParameters.bind(this));

    // ==================== 聊天筛选器（文件夹） ====================
    this.eventBus.on('updateChatFilters', this.onUpdateChatFilters.bind(this));
    this.eventBus.on('updateChatFilter', this.onUpdateChatFilter.bind(this));
    this.eventBus.on('updateChatFilterChats', this.onUpdateChatFilterChats.bind(this));
    this.eventBus.on('updateChatFilterDefault', this.onUpdateChatFilterDefault.bind(this));
    this.eventBus.on('updateChatFilterOrder', this.onUpdateChatFilterOrder.bind(this));
    this.eventBus.on('updateChatFilterIsPinned', this.onUpdateChatFilterIsPinned.bind(this));
    this.eventBus.on('updateChatFilterHasMyInvites', this.onUpdateChatFilterHasMyInvites.bind(this));

    // ==================== 其他 ====================
    this.eventBus.on('updateAutosaveSettings', this.onUpdateAutosaveSettings.bind(this));
    this.eventBus.on('updateScopeNotificationSettings', this.onUpdateScopeNotificationSettings.bind(this));
    this.eventBus.on('updateCountriesList', this.onUpdateCountriesList.bind(this));
    this.eventBus.on('updatePhoneNumberCode', this.onUpdatePhoneNumberCode.bind(this));
    this.eventBus.on('updateUsersNearby', this.onUpdateUsersNearby.bind(this));
    this.eventBus.on('updateLanguagePackStrings', this.onUpdateLanguagePackStrings.bind(this));
    this.eventBus.on('updateSavedMessagesTopic', this.onUpdateSavedMessagesTopic.bind(this));
    this.eventBus.on('updateSavedMessagesTopicMessages', this.onUpdateSavedMessagesTopicMessages.bind(this));
    this.eventBus.on('updateSavedMessagesTopics', this.onUpdateSavedMessagesTopics.bind(this));
    this.eventBus.on('updateAttachmentMenuBots', this.onUpdateAttachmentMenuBots.bind(this));
    this.eventBus.on('updateWebApp', this.onUpdateWebApp.bind(this));
    this.eventBus.on('updatePremiumPromo', this.onUpdatePremiumPromo.bind(this));
    this.eventBus.on('updatePremiumState', this.onUpdatePremiumState.bind(this));
    this.eventBus.on('updatePremiumGiftCode', this.onUpdatePremiumGiftCode.bind(this));
    this.eventBus.on('updatePremiumPaymentVerification', this.onUpdatePremiumPaymentVerification.bind(this));
    this.eventBus.on('updateFactCheck', this.onUpdateFactCheck.bind(this));
    this.eventBus.on('updateStickerSet', this.onUpdateStickerSet.bind(this));
    this.eventBus.on('updateTrendingStickerSet', this.onUpdateTrendingStickerSet.bind(this));
    this.eventBus.on('updateApplicationVerification', this.onUpdateApplicationVerification.bind(this));
    this.eventBus.on('updateVerificationStatus', this.onUpdateVerificationStatus.bind(this));
    this.eventBus.on('updateVerificationStatusProvider', this.onUpdateVerificationStatusProvider.bind(this));
    this.eventBus.on('updateQuickReplyShortcuts', this.onUpdateQuickReplyShortcuts.bind(this));
    this.eventBus.on('updateQuickReplyShortcut', this.onUpdateQuickReplyShortcut.bind(this));
    this.eventBus.on('updateQuickReplyShortcutMessages', this.onUpdateQuickReplyShortcutMessages.bind(this));
    this.eventBus.on('updateMessageStatistics', this.onUpdateMessageStatistics.bind(this));
    this.eventBus.on('updateNetworkStatistics', this.onUpdateNetworkStatistics.bind(this));
    this.eventBus.on('updateSyncState', this.onUpdateSyncState.bind(this));
    this.eventBus.on('updatePasswordState', this.onUpdatePasswordState.bind(this));
    this.eventBus.on('updateRecoveryEmailAddress', this.onUpdateRecoveryEmailAddress.bind(this));
    this.eventBus.on('updateLoginCode', this.onUpdateLoginCode.bind(this));
    this.eventBus.on('updateClose', this.onUpdateClose.bind(this));
    this.eventBus.on('updateOk', this.onUpdateOk.bind(this));
    this.eventBus.on('updateError', this.onUpdateError.bind(this));
  }

  // ==================== 消息更新处理器 ====================
  private onUpdateNewMessage(update: Record<string, Object>): void {
    this.coreService.onUpdateNewMessage(update);
  }
  private onUpdateMessageSendSucceeded(update: Record<string, Object>): void {
    this.coreService.onUpdateMessageSendSucceeded(update);
  }
  private onUpdateMessageSendFailed(update: Record<string, Object>): void {
    this.coreService.onUpdateMessageSendFailed(update);
  }
  private onUpdateMessageContent(update: Record<string, Object>): void {
    this.coreService.onUpdateMessageContent(update);
  }
  private onUpdateMessageEdited(update: Record<string, Object>): void {
    this.coreService.onUpdateMessageEdited(update);
  }
  private async onUpdateDeleteMessages(update: Record<string, Object>): Promise<void> {
    const chatId = update['chat_id'] as number;
    const messageIds = update['message_ids'] as number[];
    const isPermanent = update['is_permanent'] as boolean;
    hilog.info(0x0001, 'UpdateService', `onUpdateDeleteMessages: chatId=${chatId}, messageIds=${JSON.stringify(messageIds)}, isPermanent=${isPermanent}`);
    await this.coreService.onUpdateDeleteMessages(update);
  }
  private onUpdateMessageViews(update: Record<string, Object>): void {
    this.coreService.onUpdateMessageViews(update);
  }
  private onUpdateMessageInteractionInfo(update: Record<string, Object>): void {
    this.coreService.onUpdateMessageInteractionInfo(update);
  }
  private onUpdateMessageContentOpened(update: Record<string, Object>): void {
    this.coreService.onUpdateMessageContentOpened(update);
  }
  private onUpdateMessageMentionRead(update: Record<string, Object>): void {
    this.coreService.onUpdateMessageMentionRead(update);
  }
  private onUpdateMessageLiveLocationViewed(update: Record<string, Object>): void {
    this.coreService.onUpdateMessageLiveLocationViewed(update);
  }
  private onUpdateMessageFactCheck(update: Record<string, Object>): void {
    this.coreService.onUpdateMessageFactCheck(update);
  }

  // ==================== 聊天更新处理器 ====================
  private onUpdateNewChat(update: Record<string, Object>): void {
    this.coreService.onUpdateNewChat(update);
  }
  private onUpdateChatLastMessage(update: Record<string, Object>): void {
    this.coreService.onUpdateChatLastMessage(update);
  }
  private onUpdateChatPosition(update: Record<string, Object>): void {
    this.coreService.onUpdateChatPosition(update);
  }
  private onUpdateChatReadInbox(update: Record<string, Object>): void {
    this.coreService.onUpdateChatReadInbox(update);
  }
  private onUpdateChatReadOutbox(update: Record<string, Object>): void {
    this.coreService.onUpdateChatReadOutbox(update);
  }
  private onUpdateChatTitle(update: Record<string, Object>): void {
    this.coreService.onUpdateChatTitle(update);
  }
  private onUpdateChatPhoto(update: Record<string, Object>): void {
    this.coreService.onUpdateChatPhoto(update);
  }
  private onUpdateChatPermissions(update: Record<string, Object>): void {
    this.coreService.onUpdateChatPermissions(update);
  }
  private onUpdateChatThemes(update: Record<string, Object>): void {
    this.coreService.onUpdateChatThemes(update);
  }
  private onUpdateChatDraftMessage(update: Record<string, Object>): void {
    this.coreService.onUpdateChatDraftMessage(update);
  }
  private onUpdateChatIsPinned(update: Record<string, Object>): void {
    this.coreService.onUpdateChatIsPinned(update);
  }
  private onUpdateChatIsBlocked(update: Record<string, Object>): void {
    this.coreService.onUpdateChatIsBlocked(update);
  }
  private onUpdateChatHasScheduledMessages(update: Record<string, Object>): void {
    this.coreService.onUpdateChatHasScheduledMessages(update);
  }
  private onUpdateChatMessageSender(update: Record<string, Object>): void {
    this.coreService.onUpdateChatMessageSender(update);
  }
  private onUpdateChatMessageTtl(update: Record<string, Object>): void {
    this.coreService.onUpdateChatMessageTtl(update);
  }
  private onUpdateChatNotificationSettings(update: Record<string, Object>): void {
    this.coreService.onUpdateChatNotificationSettings(update);
  }
  private onUpdateChatActionBar(update: Record<string, Object>): void {
    this.coreService.onUpdateChatActionBar(update);
  }
  private onUpdateChatPendingJoinRequests(update: Record<string, Object>): void {
    this.coreService.onUpdateChatPendingJoinRequests(update);
  }
  private onUpdateChatReplyMarkup(update: Record<string, Object>): void {
    this.coreService.onUpdateChatReplyMarkup(update);
  }
  private onUpdateChatAvailableReactions(update: Record<string, Object>): void {
    this.coreService.onUpdateChatAvailableReactions(update);
  }
  private onUpdateChatVideoChat(update: Record<string, Object>): void {
    this.coreService.onUpdateChatVideoChat(update);
  }
  private onUpdateChatDefaultDisableNotification(update: Record<string, Object>): void {
    this.coreService.onUpdateChatDefaultDisableNotification(update);
  }
  private onUpdateChatHasProtectedContent(update: Record<string, Object>): void {
    this.coreService.onUpdateChatHasProtectedContent(update);
  }
  private onUpdateChatIsMarkedAsUnread(update: Record<string, Object>): void {
    this.coreService.onUpdateChatIsMarkedAsUnread(update);
  }
  private onUpdateChatOnlineMemberCount(update: Record<string, Object>): void {
    this.coreService.onUpdateChatOnlineMemberCount(update);
  }
  private onUpdateChatBackground(update: Record<string, Object>): void {
    this.coreService.onUpdateChatBackground(update);
  }
  private onUpdateChatSuggestion(update: Record<string, Object>): void {
    this.coreService.onUpdateChatSuggestion(update);
  }
  private onUpdateChatBoost(update: Record<string, Object>): void {
    this.coreService.onUpdateChatBoost(update);
  }
  private onUpdateChatBoostStatus(update: Record<string, Object>): void {
    this.coreService.onUpdateChatBoostStatus(update);
  }
  private onUpdateChatIsSponsored(update: Record<string, Object>): void {
    this.coreService.onUpdateChatIsSponsored(update);
  }
  private onUpdateChatStatistics(update: Record<string, Object>): void {
    this.coreService.onUpdateChatStatistics(update);
  }
  private onUpdateChatAction(update: Record<string, Object>): void {
    this.coreService.onUpdateChatAction(update);
  }

  // ==================== 用户更新处理器 ====================
  private onUpdateUser(update: Record<string, Object>): void {
    this.coreService.onUpdateUser(update);
  }
  private onUpdateUserFullInfo(update: Record<string, Object>): void {
    this.coreService.onUpdateUserFullInfo(update);
  }
  private onUpdateUserStatus(update: Record<string, Object>): void {
    this.coreService.onUpdateUserStatus(update);
  }
  private onUpdateUserPrivacySettingRules(update: Record<string, Object>): void {
    this.coreService.onUpdateUserPrivacySettingRules(update);
  }
  private onUpdateUserUsername(update: Record<string, Object>): void {
    this.coreService.onUpdateUserUsername(update);
  }

  // ==================== 群组/超级群组更新处理器 ====================
  private onUpdateBasicGroup(update: Record<string, Object>): void {
    this.coreService.onUpdateBasicGroup(update);
  }
  private onUpdateBasicGroupFullInfo(update: Record<string, Object>): void {
    this.coreService.onUpdateBasicGroupFullInfo(update);
  }
  private onUpdateSupergroup(update: Record<string, Object>): void {
    this.coreService.onUpdateSupergroup(update);
  }
  private onUpdateSupergroupFullInfo(update: Record<string, Object>): void {
    this.coreService.onUpdateSupergroupFullInfo(update);
  }
  private onUpdateSupergroupReactionSetting(update: Record<string, Object>): void {
    this.coreService.onUpdateSupergroupReactionSetting(update);
  }

  // ==================== 秘密聊天更新处理器 ====================
  private onUpdateSecretChat(update: Record<string, Object>): void {
    this.coreService.onUpdateSecretChat(update);
  }
  private onUpdateSecretChatRead(update: Record<string, Object>): void {
    this.coreService.onUpdateSecretChatRead(update);
  }

  // ==================== 授权与连接更新处理器 ====================
  private onUpdateAuthorizationState(update: Record<string, Object>): void {
    this.coreService.onUpdateAuthorizationState(update);
  }
  private onUpdateConnectionState(update: Record<string, Object>): void {
    this.coreService.onUpdateConnectionState(update);
  }
  private onUpdateOption(update: Record<string, Object>): void {
    this.coreService.onUpdateOption(update);
  }
  private onUpdateServiceNotification(update: Record<string, Object>): void {
    this.coreService.onUpdateServiceNotification(update);
  }
  private onUpdateTermsOfService(update: Record<string, Object>): void {
    this.coreService.onUpdateTermsOfService(update);
  }

  // ==================== 通知更新处理器 ====================
  private onUpdateActiveNotifications(update: Record<string, Object>): void {
    this.coreService.onUpdateActiveNotifications(update);
  }
  private onUpdateNotification(update: Record<string, Object>): void {
    this.coreService.onUpdateNotification(update);
  }
  private onUpdateNotificationGroup(update: Record<string, Object>): void {
    this.coreService.onUpdateNotificationGroup(update);
  }

  // ==================== 未读计数更新处理器 ====================
  private onUpdateUnreadMessageCount(update: Record<string, Object>): void {
    this.coreService.onUpdateUnreadMessageCount(update);
  }
  private onUpdateUnreadChatCount(update: Record<string, Object>): void {
    this.coreService.onUpdateUnreadChatCount(update);
  }

  // ==================== 文件更新处理器 ====================
  private onUpdateFile(update: Record<string, Object>): void {
    this.coreService.onUpdateFile(update);
  }
  private onUpdateFileGenerationStart(update: Record<string, Object>): void {
    this.coreService.onUpdateFileGenerationStart(update);
  }
  private onUpdateFileGenerationStop(update: Record<string, Object>): void {
    this.coreService.onUpdateFileGenerationStop(update);
  }

  // ==================== 通话更新处理器 ====================
  private onUpdateNewCall(update: Record<string, Object>): void {
    this.coreService.onUpdateNewCall(update);
  }
  private onUpdateCall(update: Record<string, Object>): void {
    this.coreService.onUpdateCall(update);
  }
  private onUpdateGroupCall(update: Record<string, Object>): void {
    this.coreService.onUpdateGroupCall(update);
  }
  private onUpdateGroupCallParticipant(update: Record<string, Object>): void {
    this.coreService.onUpdateGroupCallParticipant(update);
  }

  // ==================== 机器人相关更新处理器 ====================
  private onUpdateNewCustomQuery(update: Record<string, Object>): void {
    this.coreService.onUpdateNewCustomQuery(update);
  }
  private onUpdateNewCallbackQuery(update: Record<string, Object>): void {
    this.coreService.onUpdateNewCallbackQuery(update);
  }
  private onUpdateNewInlineQuery(update: Record<string, Object>): void {
    this.coreService.onUpdateNewInlineQuery(update);
  }
  private onUpdateNewPreCheckoutQuery(update: Record<string, Object>): void {
    this.coreService.onUpdateNewPreCheckoutQuery(update);
  }
  private onUpdateNewChosenInlineResult(update: Record<string, Object>): void {
    this.coreService.onUpdateNewChosenInlineResult(update);
  }
  private onUpdateNewShippingQuery(update: Record<string, Object>): void {
    this.coreService.onUpdateNewShippingQuery(update);
  }

  // ==================== 投票更新处理器 ====================
  private onUpdatePoll(update: Record<string, Object>): void {
    this.coreService.onUpdatePoll(update);
  }
  private onUpdatePollAnswer(update: Record<string, Object>): void {
    this.coreService.onUpdatePollAnswer(update);
  }

  // ==================== 故事更新处理器 ====================
  private onUpdateNewStory(update: Record<string, Object>): void {
    this.coreService.onUpdateNewStory(update);
  }
  private onUpdateStory(update: Record<string, Object>): void {
    this.coreService.onUpdateStory(update);
  }
  private onUpdateStoryDeleted(update: Record<string, Object>): void {
    this.coreService.onUpdateStoryDeleted(update);
  }
  private onUpdateChatActiveStories(update: Record<string, Object>): void {
    this.coreService.onUpdateChatActiveStories(update);
  }
  private onUpdateChatSentStory(update: Record<string, Object>): void {
    this.coreService.onUpdateChatSentStory(update);
  }
  private onUpdateChatStory(update: Record<string, Object>): void {
    this.coreService.onUpdateChatStory(update);
  }
  private onUpdateStoryInteractionInfo(update: Record<string, Object>): void {
    this.coreService.onUpdateStoryInteractionInfo(update);
  }
  private onUpdateStoryList(update: Record<string, Object>): void {
    this.coreService.onUpdateStoryList(update);
  }
  private onUpdateChatReceiveStory(update: Record<string, Object>): void {
    this.coreService.onUpdateChatReceiveStory(update);
  }
  private onUpdateChatStoryInteractiveArea(update: Record<string, Object>): void {
    this.coreService.onUpdateChatStoryInteractiveArea(update);
  }

  // ==================== 贴纸/表情更新处理器 ====================
  private onUpdateInstalledStickerSets(update: Record<string, Object>): void {
    this.coreService.onUpdateInstalledStickerSets(update);
  }
  private onUpdateTrendingStickerSets(update: Record<string, Object>): void {
    this.coreService.onUpdateTrendingStickerSets(update);
  }
  private onUpdateRecentStickers(update: Record<string, Object>): void {
    this.coreService.onUpdateRecentStickers(update);
  }
  private onUpdateFavoriteStickers(update: Record<string, Object>): void {
    this.coreService.onUpdateFavoriteStickers(update);
  }
  private onUpdateRecentEmojiStatuses(update: Record<string, Object>): void {
    this.coreService.onUpdateRecentEmojiStatuses(update);
  }
  private onUpdateEmojiReaction(update: Record<string, Object>): void {
    this.coreService.onUpdateEmojiReaction(update);
  }
  private onUpdateEmojiStatus(update: Record<string, Object>): void {
    this.coreService.onUpdateEmojiStatus(update);
  }
  private onUpdateDiceEmojis(update: Record<string, Object>): void {
    this.coreService.onUpdateDiceEmojis(update);
  }
  private onUpdateAnimatedEmojiMessageClicked(update: Record<string, Object>): void {
    this.coreService.onUpdateAnimatedEmojiMessageClicked(update);
  }
  private onUpdateAnimationSearchParameters(update: Record<string, Object>): void {
    this.coreService.onUpdateAnimationSearchParameters(update);
  }

  // ==================== 聊天筛选器更新处理器 ====================
  private onUpdateChatFilters(update: Record<string, Object>): void {
    this.coreService.onUpdateChatFilters(update);
  }
  private onUpdateChatFilter(update: Record<string, Object>): void {
    this.coreService.onUpdateChatFilter(update);
  }
  private onUpdateChatFilterChats(update: Record<string, Object>): void {
    this.coreService.onUpdateChatFilterChats(update);
  }
  private onUpdateChatFilterDefault(update: Record<string, Object>): void {
    this.coreService.onUpdateChatFilterDefault(update);
  }
  private onUpdateChatFilterOrder(update: Record<string, Object>): void {
    this.coreService.onUpdateChatFilterOrder(update);
  }
  private onUpdateChatFilterIsPinned(update: Record<string, Object>): void {
    this.coreService.onUpdateChatFilterIsPinned(update);
  }
  private onUpdateChatFilterHasMyInvites(update: Record<string, Object>): void {
    this.coreService.onUpdateChatFilterHasMyInvites(update);
  }

  // ==================== 其他更新处理器 ====================
  private onUpdateAutosaveSettings(update: Record<string, Object>): void {
    this.coreService.onUpdateAutosaveSettings(update);
  }
  private onUpdateScopeNotificationSettings(update: Record<string, Object>): void {
    this.coreService.onUpdateScopeNotificationSettings(update);
  }
  private onUpdateCountriesList(update: Record<string, Object>): void {
    this.coreService.onUpdateCountriesList(update);
  }
  private onUpdatePhoneNumberCode(update: Record<string, Object>): void {
    this.coreService.onUpdatePhoneNumberCode(update);
  }
  private onUpdateUsersNearby(update: Record<string, Object>): void {
    this.coreService.onUpdateUsersNearby(update);
  }
  private onUpdateLanguagePackStrings(update: Record<string, Object>): void {
    this.coreService.onUpdateLanguagePackStrings(update);
  }
  private onUpdateSavedMessagesTopic(update: Record<string, Object>): void {
    this.coreService.onUpdateSavedMessagesTopic(update);
  }
  private onUpdateSavedMessagesTopicMessages(update: Record<string, Object>): void {
    this.coreService.onUpdateSavedMessagesTopicMessages(update);
  }
  private onUpdateSavedMessagesTopics(update: Record<string, Object>): void {
    this.coreService.onUpdateSavedMessagesTopics(update);
  }
  private onUpdateAttachmentMenuBots(update: Record<string, Object>): void {
    this.coreService.onUpdateAttachmentMenuBots(update);
  }
  private onUpdateWebApp(update: Record<string, Object>): void {
    this.coreService.onUpdateWebApp(update);
  }
  private onUpdatePremiumPromo(update: Record<string, Object>): void {
    this.coreService.onUpdatePremiumPromo(update);
  }
  private onUpdatePremiumState(update: Record<string, Object>): void {
    this.coreService.onUpdatePremiumState(update);
  }
  private onUpdatePremiumGiftCode(update: Record<string, Object>): void {
    this.coreService.onUpdatePremiumGiftCode(update);
  }
  private onUpdatePremiumPaymentVerification(update: Record<string, Object>): void {
    this.coreService.onUpdatePremiumPaymentVerification(update);
  }
  private onUpdateFactCheck(update: Record<string, Object>): void {
    this.coreService.onUpdateFactCheck(update);
  }
  private onUpdateStickerSet(update: Record<string, Object>): void {
    this.coreService.onUpdateStickerSet(update);
  }
  private onUpdateTrendingStickerSet(update: Record<string, Object>): void {
    this.coreService.onUpdateTrendingStickerSet(update);
  }
  private onUpdateApplicationVerification(update: Record<string, Object>): void {
    this.coreService.onUpdateApplicationVerification(update);
  }
  private onUpdateVerificationStatus(update: Record<string, Object>): void {
    this.coreService.onUpdateVerificationStatus(update);
  }
  private onUpdateVerificationStatusProvider(update: Record<string, Object>): void {
    this.coreService.onUpdateVerificationStatusProvider(update);
  }
  private onUpdateQuickReplyShortcuts(update: Record<string, Object>): void {
    this.coreService.onUpdateQuickReplyShortcuts(update);
  }
  private onUpdateQuickReplyShortcut(update: Record<string, Object>): void {
    this.coreService.onUpdateQuickReplyShortcut(update);
  }
  private onUpdateQuickReplyShortcutMessages(update: Record<string, Object>): void {
    this.coreService.onUpdateQuickReplyShortcutMessages(update);
  }
  private onUpdateMessageStatistics(update: Record<string, Object>): void {
    this.coreService.onUpdateMessageStatistics(update);
  }
  private onUpdateNetworkStatistics(update: Record<string, Object>): void {
    this.coreService.onUpdateNetworkStatistics(update);
  }
  private onUpdateSyncState(update: Record<string, Object>): void {
    this.coreService.onUpdateSyncState(update);
  }
  private onUpdatePasswordState(update: Record<string, Object>): void {
    this.coreService.onUpdatePasswordState(update);
  }
  private onUpdateRecoveryEmailAddress(update: Record<string, Object>): void {
    this.coreService.onUpdateRecoveryEmailAddress(update);
  }
  private onUpdateLoginCode(update: Record<string, Object>): void {
    this.coreService.onUpdateLoginCode(update);
  }
  private onUpdateClose(update: Record<string, Object>): void {
    this.coreService.onUpdateClose(update);
  }
  private onUpdateOk(update: Record<string, Object>): void {
    this.coreService.onUpdateOk(update);
  }
  private onUpdateError(update: Record<string, Object>): void {
    this.coreService.onUpdateError(update);
  }
}
