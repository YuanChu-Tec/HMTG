/**
 * libhome.so 完整类型声明
 * 包含所有 TDLib API 方法（500+），每个方法接收 clientId 和 JSON 参数字符串。
 * 响应通过 tdlibReceiveGlobal 异步获取。
 *
 * 注意：所有 TDLib API 方法统一使用 (clientId: number, paramsJson: string) 签名
 */

/** 示例：两数相加 */
export const add: (a: number, b: number) => number;

/** 设置 TDLib 日志级别 (0-1024) */
export function setLogVerbosityLevel(clientId: number, paramsJson: string): void;

/** 创建 TDLib 客户端，返回 client_id */
export function tdlibCreateClientId(): number;

/** 向指定 client 发送 JSON 请求（完整 JSON 字符串） */
export function tdlibSendById(clientId: number, request: string): void;

/** 全局接收：从任意 client 接收一条响应/更新，timeout 秒 */
export function tdlibReceiveGlobal(timeout: number): string | null;

/** 同步执行一条 JSON 请求 */
export function tdlibExecuteGlobal(request: string): string | null;

/** 关闭 TDLib 客户端 */
export function tdlibCloseClient(clientId: number): void;

/**
 * 以下为所有 TDLib API 方法
 * 每个方法：(clientId: number, paramsJson: string) => void
 * paramsJson 为请求参数字符串（不含 @type），例如 "{\"phone_number\":\"+123\"}"
 */

// ==================== 认证与授权 ====================
export function getAuthorizationState(clientId: number, paramsJson: string): void;
export function setTdlibParameters(clientId: number, paramsJson: string): void;
export function setAuthenticationPhoneNumber(clientId: number, paramsJson: string): void;
export function checkAuthenticationPremiumPurchase(clientId: number, paramsJson: string): void;
export function setAuthenticationPremiumPurchaseTransaction(clientId: number, paramsJson: string): void;
export function setAuthenticationEmailAddress(clientId: number, paramsJson: string): void;
export function resendAuthenticationCode(clientId: number, paramsJson: string): void;
export function checkAuthenticationEmailCode(clientId: number, paramsJson: string): void;
export function checkAuthenticationCode(clientId: number, paramsJson: string): void;
export function requestQrCodeAuthentication(clientId: number, paramsJson: string): void;
export function getAuthenticationPasskeyParameters(clientId: number, paramsJson: string): void;
export function checkAuthenticationPasskey(clientId: number, paramsJson: string): void;
export function registerUser(clientId: number, paramsJson: string): void;
export function resetAuthenticationEmailAddress(clientId: number, paramsJson: string): void;
export function checkAuthenticationPassword(clientId: number, paramsJson: string): void;
export function requestAuthenticationPasswordRecovery(clientId: number, paramsJson: string): void;
export function checkAuthenticationPasswordRecoveryCode(clientId: number, paramsJson: string): void;
export function recoverAuthenticationPassword(clientId: number, paramsJson: string): void;
export function sendAuthenticationFirebaseSms(clientId: number, paramsJson: string): void;
export function reportAuthenticationCodeMissing(clientId: number, paramsJson: string): void;
export function checkAuthenticationBotToken(clientId: number, paramsJson: string): void;
export function logOut(clientId: number, paramsJson: string): void;
export function close(clientId: number, paramsJson: string): void;
export function destroy(clientId: number, paramsJson: string): void;
export function confirmQrCodeAuthentication(clientId: number, paramsJson: string): void;
export function getCurrentState(clientId: number, paramsJson: string): void;
export function setDatabaseEncryptionKey(clientId: number, paramsJson: string): void;
export function getPasswordState(clientId: number, paramsJson: string): void;
export function setPassword(clientId: number, paramsJson: string): void;
export function isLoginEmailAddressRequired(clientId: number, paramsJson: string): void;
export function setLoginEmailAddress(clientId: number, paramsJson: string): void;
export function resendLoginEmailAddressCode(clientId: number, paramsJson: string): void;
export function checkLoginEmailAddressCode(clientId: number, paramsJson: string): void;
export function getRecoveryEmailAddress(clientId: number, paramsJson: string): void;
export function setRecoveryEmailAddress(clientId: number, paramsJson: string): void;
export function checkRecoveryEmailAddressCode(clientId: number, paramsJson: string): void;
export function resendRecoveryEmailAddressCode(clientId: number, paramsJson: string): void;
export function cancelRecoveryEmailAddressVerification(clientId: number, paramsJson: string): void;
export function requestPasswordRecovery(clientId: number, paramsJson: string): void;
export function checkPasswordRecoveryCode(clientId: number, paramsJson: string): void;
export function recoverPassword(clientId: number, paramsJson: string): void;
export function resetPassword(clientId: number, paramsJson: string): void;
export function cancelPasswordReset(clientId: number, paramsJson: string): void;
export function createTemporaryPassword(clientId: number, paramsJson: string): void;
export function getTemporaryPasswordState(clientId: number, paramsJson: string): void;

// ==================== 用户与个人资料 ====================
export function getMe(clientId: number, paramsJson: string): void;
export function getUser(clientId: number, paramsJson: string): void;
export function getUserFullInfo(clientId: number, paramsJson: string): void;
export function getBasicGroup(clientId: number, paramsJson: string): void;
export function getBasicGroupFullInfo(clientId: number, paramsJson: string): void;
export function getSupergroup(clientId: number, paramsJson: string): void;
export function getSupergroupFullInfo(clientId: number, paramsJson: string): void;
export function getSecretChat(clientId: number, paramsJson: string): void;
export function getUserProfilePhotos(clientId: number, paramsJson: string): void;
export function getUserProfileAudios(clientId: number, paramsJson: string): void;
export function isProfileAudio(clientId: number, paramsJson: string): void;
export function addProfileAudio(clientId: number, paramsJson: string): void;
export function setProfileAudioPosition(clientId: number, paramsJson: string): void;
export function removeProfileAudio(clientId: number, paramsJson: string): void;
export function setUserPersonalProfilePhoto(clientId: number, paramsJson: string): void;
export function setUserNote(clientId: number, paramsJson: string): void;
export function suggestUserProfilePhoto(clientId: number, paramsJson: string): void;
export function suggestUserBirthdate(clientId: number, paramsJson: string): void;
export function toggleBotCanManageEmojiStatus(clientId: number, paramsJson: string): void;
export function setUserEmojiStatus(clientId: number, paramsJson: string): void;
export function searchUserByPhoneNumber(clientId: number, paramsJson: string): void;
export function sharePhoneNumber(clientId: number, paramsJson: string): void;
export function setProfilePhoto(clientId: number, paramsJson: string): void;
export function deleteProfilePhoto(clientId: number, paramsJson: string): void;
export function setAccentColor(clientId: number, paramsJson: string): void;
export function setUpgradedGiftColors(clientId: number, paramsJson: string): void;
export function setProfileAccentColor(clientId: number, paramsJson: string): void;
export function setName(clientId: number, paramsJson: string): void;
export function setBio(clientId: number, paramsJson: string): void;
export function setUsername(clientId: number, paramsJson: string): void;
export function toggleUsernameIsActive(clientId: number, paramsJson: string): void;
export function reorderActiveUsernames(clientId: number, paramsJson: string): void;
export function setBirthdate(clientId: number, paramsJson: string): void;
export function setMainProfileTab(clientId: number, paramsJson: string): void;
export function setPersonalChat(clientId: number, paramsJson: string): void;
export function setEmojiStatus(clientId: number, paramsJson: string): void;
export function toggleHasSponsoredMessagesEnabled(clientId: number, paramsJson: string): void;
export function setBusinessLocation(clientId: number, paramsJson: string): void;
export function setBusinessOpeningHours(clientId: number, paramsJson: string): void;
export function setBusinessGreetingMessageSettings(clientId: number, paramsJson: string): void;
export function setBusinessAwayMessageSettings(clientId: number, paramsJson: string): void;
export function setBusinessStartPage(clientId: number, paramsJson: string): void;
export function getBusinessConnectedBot(clientId: number, paramsJson: string): void;
export function setBusinessConnectedBot(clientId: number, paramsJson: string): void;
export function deleteBusinessConnectedBot(clientId: number, paramsJson: string): void;
export function toggleBusinessConnectedBotChatIsPaused(clientId: number, paramsJson: string): void;
export function removeBusinessConnectedBotFromChat(clientId: number, paramsJson: string): void;
export function getBusinessChatLinks(clientId: number, paramsJson: string): void;
export function createBusinessChatLink(clientId: number, paramsJson: string): void;
export function editBusinessChatLink(clientId: number, paramsJson: string): void;
export function deleteBusinessChatLink(clientId: number, paramsJson: string): void;
export function getBusinessChatLinkInfo(clientId: number, paramsJson: string): void;
export function getUserLink(clientId: number, paramsJson: string): void;
export function searchUserByToken(clientId: number, paramsJson: string): void;

// ==================== 聊天管理 ====================
export function getChat(clientId: number, paramsJson: string): void;
export function getMessage(clientId: number, paramsJson: string): void;
export function getMessageLocally(clientId: number, paramsJson: string): void;
export function getRepliedMessage(clientId: number, paramsJson: string): void;
export function getChatPinnedMessage(clientId: number, paramsJson: string): void;
export function getCallbackQueryMessage(clientId: number, paramsJson: string): void;
export function getMessages(clientId: number, paramsJson: string): void;
export function getMessageProperties(clientId: number, paramsJson: string): void;
export function getMessageThread(clientId: number, paramsJson: string): void;
export function getMessageReadDate(clientId: number, paramsJson: string): void;
export function getMessageViewers(clientId: number, paramsJson: string): void;
export function getMessageAuthor(clientId: number, paramsJson: string): void;
export function loadChats(clientId: number, paramsJson: string): void;
export function getChats(clientId: number, paramsJson: string): void;
export function searchPublicChat(clientId: number, paramsJson: string): void;
export function searchPublicChats(clientId: number, paramsJson: string): void;
export function searchChats(clientId: number, paramsJson: string): void;
export function searchChatsOnServer(clientId: number, paramsJson: string): void;
export function getRecommendedChats(clientId: number, paramsJson: string): void;
export function getChatSimilarChats(clientId: number, paramsJson: string): void;
export function getChatSimilarChatCount(clientId: number, paramsJson: string): void;
export function openChatSimilarChat(clientId: number, paramsJson: string): void;
export function getBotSimilarBots(clientId: number, paramsJson: string): void;
export function getBotSimilarBotCount(clientId: number, paramsJson: string): void;
export function openBotSimilarBot(clientId: number, paramsJson: string): void;
export function getTopChats(clientId: number, paramsJson: string): void;
export function removeTopChat(clientId: number, paramsJson: string): void;
export function searchRecentlyFoundChats(clientId: number, paramsJson: string): void;
export function addRecentlyFoundChat(clientId: number, paramsJson: string): void;
export function removeRecentlyFoundChat(clientId: number, paramsJson: string): void;
export function clearRecentlyFoundChats(clientId: number, paramsJson: string): void;
export function getRecentlyOpenedChats(clientId: number, paramsJson: string): void;
export function checkChatUsername(clientId: number, paramsJson: string): void;
export function getCreatedPublicChats(clientId: number, paramsJson: string): void;
export function checkCreatedPublicChatsLimit(clientId: number, paramsJson: string): void;
export function getSuitableDiscussionChats(clientId: number, paramsJson: string): void;
export function getInactiveSupergroupChats(clientId: number, paramsJson: string): void;
export function getSuitablePersonalChats(clientId: number, paramsJson: string): void;
export function loadDirectMessagesChatTopics(clientId: number, paramsJson: string): void;
export function getDirectMessagesChatTopic(clientId: number, paramsJson: string): void;
export function getDirectMessagesChatTopicHistory(clientId: number, paramsJson: string): void;
export function getDirectMessagesChatTopicMessageByDate(clientId: number, paramsJson: string): void;
export function deleteDirectMessagesChatTopicHistory(clientId: number, paramsJson: string): void;
export function deleteDirectMessagesChatTopicMessagesByDate(clientId: number, paramsJson: string): void;
export function setDirectMessagesChatTopicIsMarkedAsUnread(clientId: number, paramsJson: string): void;
export function unpinAllDirectMessagesChatTopicMessages(clientId: number, paramsJson: string): void;
export function readAllDirectMessagesChatTopicReactions(clientId: number, paramsJson: string): void;
export function getDirectMessagesChatTopicRevenue(clientId: number, paramsJson: string): void;
export function toggleDirectMessagesChatTopicCanSendUnpaidMessages(clientId: number, paramsJson: string): void;
export function loadSavedMessagesTopics(clientId: number, paramsJson: string): void;
export function getSavedMessagesTopicHistory(clientId: number, paramsJson: string): void;
export function getSavedMessagesTopicMessageByDate(clientId: number, paramsJson: string): void;
export function deleteSavedMessagesTopicHistory(clientId: number, paramsJson: string): void;
export function deleteSavedMessagesTopicMessagesByDate(clientId: number, paramsJson: string): void;
export function toggleSavedMessagesTopicIsPinned(clientId: number, paramsJson: string): void;
export function setPinnedSavedMessagesTopics(clientId: number, paramsJson: string): void;
export function getGroupsInCommon(clientId: number, paramsJson: string): void;
export function getChatHistory(clientId: number, paramsJson: string): void;
export function getMessageThreadHistory(clientId: number, paramsJson: string): void;
export function deleteChatHistory(clientId: number, paramsJson: string): void;
export function deleteChat(clientId: number, paramsJson: string): void;
export function searchChatMessages(clientId: number, paramsJson: string): void;
export function searchMessages(clientId: number, paramsJson: string): void;
export function searchSecretMessages(clientId: number, paramsJson: string): void;
export function searchSavedMessages(clientId: number, paramsJson: string): void;
export function searchCallMessages(clientId: number, paramsJson: string): void;
export function searchOutgoingDocumentMessages(clientId: number, paramsJson: string): void;
export function getPublicPostSearchLimits(clientId: number, paramsJson: string): void;
export function searchPublicPosts(clientId: number, paramsJson: string): void;
export function searchPublicMessagesByTag(clientId: number, paramsJson: string): void;
export function searchPublicStoriesByTag(clientId: number, paramsJson: string): void;
export function searchPublicStoriesByLocation(clientId: number, paramsJson: string): void;
export function searchPublicStoriesByVenue(clientId: number, paramsJson: string): void;
export function getSearchedForTags(clientId: number, paramsJson: string): void;
export function removeSearchedForTag(clientId: number, paramsJson: string): void;
export function clearSearchedForTags(clientId: number, paramsJson: string): void;
export function deleteAllCallMessages(clientId: number, paramsJson: string): void;
export function searchChatRecentLocationMessages(clientId: number, paramsJson: string): void;
export function getChatMessageByDate(clientId: number, paramsJson: string): void;
export function getChatSparseMessagePositions(clientId: number, paramsJson: string): void;
export function getChatMessageCalendar(clientId: number, paramsJson: string): void;
export function getChatMessageCount(clientId: number, paramsJson: string): void;
export function getChatMessagePosition(clientId: number, paramsJson: string): void;
export function getChatScheduledMessages(clientId: number, paramsJson: string): void;
export function getChatSponsoredMessages(clientId: number, paramsJson: string): void;
export function clickChatSponsoredMessage(clientId: number, paramsJson: string): void;
export function reportChatSponsoredMessage(clientId: number, paramsJson: string): void;
export function getSearchSponsoredChats(clientId: number, paramsJson: string): void;
export function viewSponsoredChat(clientId: number, paramsJson: string): void;
export function openSponsoredChat(clientId: number, paramsJson: string): void;
export function reportSponsoredChat(clientId: number, paramsJson: string): void;
export function getVideoMessageAdvertisements(clientId: number, paramsJson: string): void;
export function viewVideoMessageAdvertisement(clientId: number, paramsJson: string): void;
export function clickVideoMessageAdvertisement(clientId: number, paramsJson: string): void;
export function reportVideoMessageAdvertisement(clientId: number, paramsJson: string): void;
export function removeNotification(clientId: number, paramsJson: string): void;
export function removeNotificationGroup(clientId: number, paramsJson: string): void;
export function getMessageLink(clientId: number, paramsJson: string): void;
export function getMessageEmbeddingCode(clientId: number, paramsJson: string): void;
export function getMessageLinkInfo(clientId: number, paramsJson: string): void;
export function translateText(clientId: number, paramsJson: string): void;
export function translateMessageText(clientId: number, paramsJson: string): void;
export function summarizeMessage(clientId: number, paramsJson: string): void;
export function recognizeSpeech(clientId: number, paramsJson: string): void;
export function rateSpeechRecognition(clientId: number, paramsJson: string): void;
export function getChatAvailableMessageSenders(clientId: number, paramsJson: string): void;
export function setChatMessageSender(clientId: number, paramsJson: string): void;

// ==================== 消息操作 ====================
export function sendMessage(clientId: number, paramsJson: string): void;
export function sendMessageAlbum(clientId: number, paramsJson: string): void;
export function sendBotStartMessage(clientId: number, paramsJson: string): void;
export function sendInlineQueryResultMessage(clientId: number, paramsJson: string): void;
export function forwardMessages(clientId: number, paramsJson: string): void;
export function sendQuickReplyShortcutMessages(clientId: number, paramsJson: string): void;
export function resendMessages(clientId: number, paramsJson: string): void;
export function addLocalMessage(clientId: number, paramsJson: string): void;
export function deleteMessages(clientId: number, paramsJson: string): void;
export function deleteChatMessagesBySender(clientId: number, paramsJson: string): void;
export function deleteChatMessagesByDate(clientId: number, paramsJson: string): void;
export function editMessageText(clientId: number, paramsJson: string): void;
export function editMessageLiveLocation(clientId: number, paramsJson: string): void;
export function editMessageChecklist(clientId: number, paramsJson: string): void;
export function editMessageMedia(clientId: number, paramsJson: string): void;
export function editMessageCaption(clientId: number, paramsJson: string): void;
export function editMessageReplyMarkup(clientId: number, paramsJson: string): void;
export function editInlineMessageText(clientId: number, paramsJson: string): void;
export function editInlineMessageLiveLocation(clientId: number, paramsJson: string): void;
export function editInlineMessageMedia(clientId: number, paramsJson: string): void;
export function editInlineMessageCaption(clientId: number, paramsJson: string): void;
export function editInlineMessageReplyMarkup(clientId: number, paramsJson: string): void;
export function editMessageSchedulingState(clientId: number, paramsJson: string): void;
export function setMessageFactCheck(clientId: number, paramsJson: string): void;
export function sendBusinessMessage(clientId: number, paramsJson: string): void;
export function sendBusinessMessageAlbum(clientId: number, paramsJson: string): void;
export function editBusinessMessageText(clientId: number, paramsJson: string): void;
export function editBusinessMessageLiveLocation(clientId: number, paramsJson: string): void;
export function editBusinessMessageChecklist(clientId: number, paramsJson: string): void;
export function editBusinessMessageMedia(clientId: number, paramsJson: string): void;
export function editBusinessMessageCaption(clientId: number, paramsJson: string): void;
export function editBusinessMessageReplyMarkup(clientId: number, paramsJson: string): void;
export function stopBusinessPoll(clientId: number, paramsJson: string): void;
export function setBusinessMessageIsPinned(clientId: number, paramsJson: string): void;
export function readBusinessMessage(clientId: number, paramsJson: string): void;
export function deleteBusinessMessages(clientId: number, paramsJson: string): void;
export function editBusinessStory(clientId: number, paramsJson: string): void;
export function deleteBusinessStory(clientId: number, paramsJson: string): void;
export function setBusinessAccountName(clientId: number, paramsJson: string): void;
export function setBusinessAccountBio(clientId: number, paramsJson: string): void;
export function setBusinessAccountProfilePhoto(clientId: number, paramsJson: string): void;
export function setBusinessAccountUsername(clientId: number, paramsJson: string): void;
export function setBusinessAccountGiftSettings(clientId: number, paramsJson: string): void;
export function getBusinessAccountStarAmount(clientId: number, paramsJson: string): void;
export function transferBusinessAccountStars(clientId: number, paramsJson: string): void;
export function checkQuickReplyShortcutName(clientId: number, paramsJson: string): void;
export function loadQuickReplyShortcuts(clientId: number, paramsJson: string): void;
export function setQuickReplyShortcutName(clientId: number, paramsJson: string): void;
export function deleteQuickReplyShortcut(clientId: number, paramsJson: string): void;
export function reorderQuickReplyShortcuts(clientId: number, paramsJson: string): void;
export function loadQuickReplyShortcutMessages(clientId: number, paramsJson: string): void;
export function deleteQuickReplyShortcutMessages(clientId: number, paramsJson: string): void;
export function addQuickReplyShortcutMessage(clientId: number, paramsJson: string): void;
export function addQuickReplyShortcutInlineQueryResultMessage(clientId: number, paramsJson: string): void;
export function addQuickReplyShortcutMessageAlbum(clientId: number, paramsJson: string): void;
export function readdQuickReplyShortcutMessages(clientId: number, paramsJson: string): void;
export function editQuickReplyMessage(clientId: number, paramsJson: string): void;
export function getForumTopicDefaultIcons(clientId: number, paramsJson: string): void;
export function createForumTopic(clientId: number, paramsJson: string): void;
export function editForumTopic(clientId: number, paramsJson: string): void;
export function getForumTopic(clientId: number, paramsJson: string): void;
export function getForumTopicHistory(clientId: number, paramsJson: string): void;
export function getForumTopicLink(clientId: number, paramsJson: string): void;
export function getForumTopics(clientId: number, paramsJson: string): void;
export function setForumTopicNotificationSettings(clientId: number, paramsJson: string): void;
export function toggleForumTopicIsClosed(clientId: number, paramsJson: string): void;
export function toggleGeneralForumTopicIsHidden(clientId: number, paramsJson: string): void;
export function toggleForumTopicIsPinned(clientId: number, paramsJson: string): void;
export function setPinnedForumTopics(clientId: number, paramsJson: string): void;
export function deleteForumTopic(clientId: number, paramsJson: string): void;
export function readAllForumTopicMentions(clientId: number, paramsJson: string): void;
export function readAllForumTopicReactions(clientId: number, paramsJson: string): void;
export function unpinAllForumTopicMessages(clientId: number, paramsJson: string): void;

// ==================== 反应与表情 ====================
export function getPasskeyParameters(clientId: number, paramsJson: string): void;
export function addLoginPasskey(clientId: number, paramsJson: string): void;
export function getLoginPasskeys(clientId: number, paramsJson: string): void;
export function removeLoginPasskey(clientId: number, paramsJson: string): void;
export function getEmojiReaction(clientId: number, paramsJson: string): void;
export function getCustomEmojiReactionAnimations(clientId: number, paramsJson: string): void;
export function getMessageAvailableReactions(clientId: number, paramsJson: string): void;
export function clearRecentReactions(clientId: number, paramsJson: string): void;
export function addMessageReaction(clientId: number, paramsJson: string): void;
export function removeMessageReaction(clientId: number, paramsJson: string): void;
export function getChatAvailablePaidMessageReactionSenders(clientId: number, paramsJson: string): void;
export function addPendingPaidMessageReaction(clientId: number, paramsJson: string): void;
export function commitPendingPaidMessageReactions(clientId: number, paramsJson: string): void;
export function removePendingPaidMessageReactions(clientId: number, paramsJson: string): void;
export function setPaidMessageReactionType(clientId: number, paramsJson: string): void;
export function setMessageReactions(clientId: number, paramsJson: string): void;
export function getMessageAddedReactions(clientId: number, paramsJson: string): void;
export function setDefaultReactionType(clientId: number, paramsJson: string): void;
export function getSavedMessagesTags(clientId: number, paramsJson: string): void;
export function setSavedMessagesTagLabel(clientId: number, paramsJson: string): void;
export function getMessageEffect(clientId: number, paramsJson: string): void;
export function searchQuote(clientId: number, paramsJson: string): void;

// ==================== 文本处理 ====================
export function getTextEntities(clientId: number, paramsJson: string): void;
export function parseTextEntities(clientId: number, paramsJson: string): void;
export function parseMarkdown(clientId: number, paramsJson: string): void;
export function getMarkdownText(clientId: number, paramsJson: string): void;
export function getCountryFlagEmoji(clientId: number, paramsJson: string): void;
export function getFileMimeType(clientId: number, paramsJson: string): void;
export function getFileExtension(clientId: number, paramsJson: string): void;
export function cleanFileName(clientId: number, paramsJson: string): void;
export function getLanguagePackString(clientId: number, paramsJson: string): void;
export function getJsonValue(clientId: number, paramsJson: string): void;
export function getJsonString(clientId: number, paramsJson: string): void;
export function getThemeParametersJsonString(clientId: number, paramsJson: string): void;

// ==================== 投票与清单 ====================
export function setPollAnswer(clientId: number, paramsJson: string): void;
export function getPollVoters(clientId: number, paramsJson: string): void;
export function stopPoll(clientId: number, paramsJson: string): void;
export function addChecklistTasks(clientId: number, paramsJson: string): void;
export function markChecklistTasksAsDone(clientId: number, paramsJson: string): void;

// ==================== 建议操作 ====================
export function hideSuggestedAction(clientId: number, paramsJson: string): void;
export function hideContactCloseBirthdays(clientId: number, paramsJson: string): void;

// ==================== 业务连接 ====================
export function getBusinessConnection(clientId: number, paramsJson: string): void;

// ==================== 登录 URL ====================
export function getLoginUrlInfo(clientId: number, paramsJson: string): void;
export function getLoginUrl(clientId: number, paramsJson: string): void;
export function shareUsersWithBot(clientId: number, paramsJson: string): void;
export function shareChatWithBot(clientId: number, paramsJson: string): void;

// ==================== 内联查询 ====================
export function getInlineQueryResults(clientId: number, paramsJson: string): void;
export function answerInlineQuery(clientId: number, paramsJson: string): void;
export function savePreparedInlineMessage(clientId: number, paramsJson: string): void;
export function getPreparedInlineMessage(clientId: number, paramsJson: string): void;

// ==================== Web 应用 ====================
export function getGrossingWebAppBots(clientId: number, paramsJson: string): void;
export function searchWebApp(clientId: number, paramsJson: string): void;
export function getWebAppPlaceholder(clientId: number, paramsJson: string): void;
export function getWebAppLinkUrl(clientId: number, paramsJson: string): void;
export function getMainWebApp(clientId: number, paramsJson: string): void;
export function getWebAppUrl(clientId: number, paramsJson: string): void;
export function sendWebAppData(clientId: number, paramsJson: string): void;
export function openWebApp(clientId: number, paramsJson: string): void;
export function closeWebApp(clientId: number, paramsJson: string): void;
export function answerWebAppQuery(clientId: number, paramsJson: string): void;
export function checkWebAppFileDownload(clientId: number, paramsJson: string): void;

// ==================== 回调查询 ====================
export function getCallbackQueryAnswer(clientId: number, paramsJson: string): void;
export function answerCallbackQuery(clientId: number, paramsJson: string): void;
export function answerShippingQuery(clientId: number, paramsJson: string): void;
export function answerPreCheckoutQuery(clientId: number, paramsJson: string): void;

// ==================== 游戏 ====================
export function setGameScore(clientId: number, paramsJson: string): void;
export function setInlineGameScore(clientId: number, paramsJson: string): void;
export function getGameHighScores(clientId: number, paramsJson: string): void;
export function getInlineGameHighScores(clientId: number, paramsJson: string): void;

// ==================== 聊天操作 ====================
export function deleteChatReplyMarkup(clientId: number, paramsJson: string): void;
export function sendChatAction(clientId: number, paramsJson: string): void;
export function sendTextMessageDraft(clientId: number, paramsJson: string): void;
export function openChat(clientId: number, paramsJson: string): void;
export function closeChat(clientId: number, paramsJson: string): void;
export function viewMessages(clientId: number, paramsJson: string): void;
export function openMessageContent(clientId: number, paramsJson: string): void;
export function clickAnimatedEmojiMessage(clientId: number, paramsJson: string): void;
export function getInternalLink(clientId: number, paramsJson: string): void;
export function getInternalLinkType(clientId: number, paramsJson: string): void;
export function getExternalLinkInfo(clientId: number, paramsJson: string): void;
export function getExternalLink(clientId: number, paramsJson: string): void;
export function readAllChatMentions(clientId: number, paramsJson: string): void;
export function readAllChatReactions(clientId: number, paramsJson: string): void;

// ==================== 创建聊天 ====================
export function createPrivateChat(clientId: number, paramsJson: string): void;
export function createBasicGroupChat(clientId: number, paramsJson: string): void;
export function createSupergroupChat(clientId: number, paramsJson: string): void;
export function createSecretChat(clientId: number, paramsJson: string): void;
export function createNewBasicGroupChat(clientId: number, paramsJson: string): void;
export function createNewSupergroupChat(clientId: number, paramsJson: string): void;
export function createNewSecretChat(clientId: number, paramsJson: string): void;
export function upgradeBasicGroupChatToSupergroupChat(clientId: number, paramsJson: string): void;

// ==================== 聊天列表与文件夹 ====================
export function getChatListsToAddChat(clientId: number, paramsJson: string): void;
export function addChatToList(clientId: number, paramsJson: string): void;
export function getChatFolder(clientId: number, paramsJson: string): void;
export function createChatFolder(clientId: number, paramsJson: string): void;
export function editChatFolder(clientId: number, paramsJson: string): void;
export function deleteChatFolder(clientId: number, paramsJson: string): void;
export function getChatFolderChatsToLeave(clientId: number, paramsJson: string): void;
export function getChatFolderChatCount(clientId: number, paramsJson: string): void;
export function reorderChatFolders(clientId: number, paramsJson: string): void;
export function toggleChatFolderTags(clientId: number, paramsJson: string): void;
export function getRecommendedChatFolders(clientId: number, paramsJson: string): void;
export function getChatFolderDefaultIconName(clientId: number, paramsJson: string): void;
export function getChatsForChatFolderInviteLink(clientId: number, paramsJson: string): void;
export function createChatFolderInviteLink(clientId: number, paramsJson: string): void;
export function getChatFolderInviteLinks(clientId: number, paramsJson: string): void;
export function editChatFolderInviteLink(clientId: number, paramsJson: string): void;
export function deleteChatFolderInviteLink(clientId: number, paramsJson: string): void;
export function checkChatFolderInviteLink(clientId: number, paramsJson: string): void;
export function addChatFolderByInviteLink(clientId: number, paramsJson: string): void;
export function getChatFolderNewChats(clientId: number, paramsJson: string): void;
export function processChatFolderNewChats(clientId: number, paramsJson: string): void;
export function getArchiveChatListSettings(clientId: number, paramsJson: string): void;
export function setArchiveChatListSettings(clientId: number, paramsJson: string): void;
export function setChatTitle(clientId: number, paramsJson: string): void;
export function setChatPhoto(clientId: number, paramsJson: string): void;
export function setChatAccentColor(clientId: number, paramsJson: string): void;
export function setChatProfileAccentColor(clientId: number, paramsJson: string): void;
export function setChatMessageAutoDeleteTime(clientId: number, paramsJson: string): void;
export function setChatEmojiStatus(clientId: number, paramsJson: string): void;
export function setChatPermissions(clientId: number, paramsJson: string): void;
export function setChatBackground(clientId: number, paramsJson: string): void;
export function deleteChatBackground(clientId: number, paramsJson: string): void;
export function getGiftChatThemes(clientId: number, paramsJson: string): void;
export function setChatTheme(clientId: number, paramsJson: string): void;
export function setChatDraftMessage(clientId: number, paramsJson: string): void;
export function setChatNotificationSettings(clientId: number, paramsJson: string): void;
export function toggleChatHasProtectedContent(clientId: number, paramsJson: string): void;
export function toggleChatViewAsTopics(clientId: number, paramsJson: string): void;
export function toggleChatIsTranslatable(clientId: number, paramsJson: string): void;
export function toggleChatIsMarkedAsUnread(clientId: number, paramsJson: string): void;
export function toggleChatDefaultDisableNotification(clientId: number, paramsJson: string): void;
export function setChatAvailableReactions(clientId: number, paramsJson: string): void;
export function setChatClientData(clientId: number, paramsJson: string): void;
export function setChatDescription(clientId: number, paramsJson: string): void;
export function setChatDiscussionGroup(clientId: number, paramsJson: string): void;
export function setChatDirectMessagesGroup(clientId: number, paramsJson: string): void;
export function setChatLocation(clientId: number, paramsJson: string): void;
export function setChatSlowModeDelay(clientId: number, paramsJson: string): void;
export function pinChatMessage(clientId: number, paramsJson: string): void;
export function unpinChatMessage(clientId: number, paramsJson: string): void;
export function unpinAllChatMessages(clientId: number, paramsJson: string): void;
export function joinChat(clientId: number, paramsJson: string): void;
export function leaveChat(clientId: number, paramsJson: string): void;
export function addChatMember(clientId: number, paramsJson: string): void;
export function addChatMembers(clientId: number, paramsJson: string): void;
export function setChatMemberStatus(clientId: number, paramsJson: string): void;
export function banChatMember(clientId: number, paramsJson: string): void;
export function canTransferOwnership(clientId: number, paramsJson: string): void;
export function transferChatOwnership(clientId: number, paramsJson: string): void;
export function getChatOwnerAfterLeaving(clientId: number, paramsJson: string): void;
export function getChatMember(clientId: number, paramsJson: string): void;
export function searchChatMembers(clientId: number, paramsJson: string): void;
export function getChatAdministrators(clientId: number, paramsJson: string): void;
export function clearAllDraftMessages(clientId: number, paramsJson: string): void;
export function getStakeDiceState(clientId: number, paramsJson: string): void;

// ==================== 通知设置 ====================
export function getSavedNotificationSound(clientId: number, paramsJson: string): void;
export function getSavedNotificationSounds(clientId: number, paramsJson: string): void;
export function addSavedNotificationSound(clientId: number, paramsJson: string): void;
export function removeSavedNotificationSound(clientId: number, paramsJson: string): void;
export function getChatNotificationSettingsExceptions(clientId: number, paramsJson: string): void;
export function getScopeNotificationSettings(clientId: number, paramsJson: string): void;
export function setScopeNotificationSettings(clientId: number, paramsJson: string): void;
export function setReactionNotificationSettings(clientId: number, paramsJson: string): void;
export function resetAllNotificationSettings(clientId: number, paramsJson: string): void;
export function toggleChatIsPinned(clientId: number, paramsJson: string): void;
export function setPinnedChats(clientId: number, paramsJson: string): void;
export function readChatList(clientId: number, paramsJson: string): void;

// ==================== 天气 ====================
export function getCurrentWeather(clientId: number, paramsJson: string): void;

// ==================== 故事 ====================
export function getStory(clientId: number, paramsJson: string): void;
export function getChatsToPostStories(clientId: number, paramsJson: string): void;
export function canPostStory(clientId: number, paramsJson: string): void;
export function postStory(clientId: number, paramsJson: string): void;
export function startLiveStory(clientId: number, paramsJson: string): void;
export function editStory(clientId: number, paramsJson: string): void;
export function editStoryCover(clientId: number, paramsJson: string): void;
export function setStoryPrivacySettings(clientId: number, paramsJson: string): void;
export function toggleStoryIsPostedToChatPage(clientId: number, paramsJson: string): void;
export function deleteStory(clientId: number, paramsJson: string): void;
export function getStoryNotificationSettingsExceptions(clientId: number, paramsJson: string): void;
export function loadActiveStories(clientId: number, paramsJson: string): void;
export function setChatActiveStoriesList(clientId: number, paramsJson: string): void;
export function getChatActiveStories(clientId: number, paramsJson: string): void;
export function getChatPostedToChatPageStories(clientId: number, paramsJson: string): void;
export function getChatArchivedStories(clientId: number, paramsJson: string): void;
export function setChatPinnedStories(clientId: number, paramsJson: string): void;
export function openStory(clientId: number, paramsJson: string): void;
export function closeStory(clientId: number, paramsJson: string): void;
export function getStoryAvailableReactions(clientId: number, paramsJson: string): void;
export function setStoryReaction(clientId: number, paramsJson: string): void;
export function getStoryInteractions(clientId: number, paramsJson: string): void;
export function getChatStoryInteractions(clientId: number, paramsJson: string): void;
export function reportStory(clientId: number, paramsJson: string): void;
export function activateStoryStealthMode(clientId: number, paramsJson: string): void;
export function getStoryPublicForwards(clientId: number, paramsJson: string): void;
export function getChatStoryAlbums(clientId: number, paramsJson: string): void;
export function getStoryAlbumStories(clientId: number, paramsJson: string): void;
export function createStoryAlbum(clientId: number, paramsJson: string): void;
export function reorderStoryAlbums(clientId: number, paramsJson: string): void;
export function deleteStoryAlbum(clientId: number, paramsJson: string): void;
export function setStoryAlbumName(clientId: number, paramsJson: string): void;
export function addStoryAlbumStories(clientId: number, paramsJson: string): void;
export function removeStoryAlbumStories(clientId: number, paramsJson: string): void;
export function reorderStoryAlbumStories(clientId: number, paramsJson: string): void;

// ==================== 提升与增强 ====================
export function getChatBoostLevelFeatures(clientId: number, paramsJson: string): void;
export function getChatBoostFeatures(clientId: number, paramsJson: string): void;
export function getAvailableChatBoostSlots(clientId: number, paramsJson: string): void;
export function getChatBoostStatus(clientId: number, paramsJson: string): void;
export function boostChat(clientId: number, paramsJson: string): void;
export function getChatBoostLink(clientId: number, paramsJson: string): void;
export function getChatBoostLinkInfo(clientId: number, paramsJson: string): void;
export function getChatBoosts(clientId: number, paramsJson: string): void;
export function getUserChatBoosts(clientId: number, paramsJson: string): void;

// ==================== 附件菜单机器人 ====================
export function getAttachmentMenuBot(clientId: number, paramsJson: string): void;
export function toggleBotIsAddedToAttachmentMenu(clientId: number, paramsJson: string): void;

// ==================== 表情状态 ====================
export function getThemedEmojiStatuses(clientId: number, paramsJson: string): void;
export function getRecentEmojiStatuses(clientId: number, paramsJson: string): void;
export function getUpgradedGiftEmojiStatuses(clientId: number, paramsJson: string): void;
export function getDefaultEmojiStatuses(clientId: number, paramsJson: string): void;
export function clearRecentEmojiStatuses(clientId: number, paramsJson: string): void;
export function getThemedChatEmojiStatuses(clientId: number, paramsJson: string): void;
export function getDefaultChatEmojiStatuses(clientId: number, paramsJson: string): void;
export function getDisallowedChatEmojiStatuses(clientId: number, paramsJson: string): void;

// ==================== 文件操作 ====================
export function getFile(clientId: number, paramsJson: string): void;
export function getRemoteFile(clientId: number, paramsJson: string): void;
export function readFilePart(clientId: number, paramsJson: string): void;
export function getFileDownloadedPrefixSize(clientId: number, paramsJson: string): void;
export function downloadFile(clientId: number, paramsJson: string): void;
export function cancelDownloadFile(clientId: number, paramsJson: string): void;
export function preliminaryUploadFile(clientId: number, paramsJson: string): void;
export function cancelPreliminaryUploadFile(clientId: number, paramsJson: string): void;
export function writeGeneratedFilePart(clientId: number, paramsJson: string): void;
export function setFileGenerationProgress(clientId: number, paramsJson: string): void;
export function finishFileGeneration(clientId: number, paramsJson: string): void;
export function getSuggestedFileName(clientId: number, paramsJson: string): void;
export function deleteFile(clientId: number, paramsJson: string): void;
export function addFileToDownloads(clientId: number, paramsJson: string): void;
export function toggleDownloadIsPaused(clientId: number, paramsJson: string): void;
export function toggleAllDownloadsArePaused(clientId: number, paramsJson: string): void;
export function removeFileFromDownloads(clientId: number, paramsJson: string): void;
export function removeAllFilesFromDownloads(clientId: number, paramsJson: string): void;
export function searchFileDownloads(clientId: number, paramsJson: string): void;
export function getAutoDownloadSettingsPresets(clientId: number, paramsJson: string): void;
export function setAutoDownloadSettings(clientId: number, paramsJson: string): void;
export function uploadStickerFile(clientId: number, paramsJson: string): void;
export function getMapThumbnailFile(clientId: number, paramsJson: string): void;
export function getApplicationDownloadLink(clientId: number, paramsJson: string): void;

// ==================== 应用验证 ====================
export function setApplicationVerificationToken(clientId: number, paramsJson: string): void;
export function getMessageFileType(clientId: number, paramsJson: string): void;
export function getMessageImportConfirmationText(clientId: number, paramsJson: string): void;
export function importMessages(clientId: number, paramsJson: string): void;

// ==================== 邀请链接 ====================
export function replacePrimaryChatInviteLink(clientId: number, paramsJson: string): void;
export function createChatInviteLink(clientId: number, paramsJson: string): void;
export function createChatSubscriptionInviteLink(clientId: number, paramsJson: string): void;
export function editChatInviteLink(clientId: number, paramsJson: string): void;
export function editChatSubscriptionInviteLink(clientId: number, paramsJson: string): void;
export function getChatInviteLink(clientId: number, paramsJson: string): void;
export function getChatInviteLinkCounts(clientId: number, paramsJson: string): void;
export function getChatInviteLinks(clientId: number, paramsJson: string): void;
export function getChatInviteLinkMembers(clientId: number, paramsJson: string): void;
export function revokeChatInviteLink(clientId: number, paramsJson: string): void;
export function deleteRevokedChatInviteLink(clientId: number, paramsJson: string): void;
export function deleteAllRevokedChatInviteLinks(clientId: number, paramsJson: string): void;
export function checkChatInviteLink(clientId: number, paramsJson: string): void;
export function joinChatByInviteLink(clientId: number, paramsJson: string): void;
export function getChatJoinRequests(clientId: number, paramsJson: string): void;
export function processChatJoinRequest(clientId: number, paramsJson: string): void;
export function processChatJoinRequests(clientId: number, paramsJson: string): void;
export function approveSuggestedPost(clientId: number, paramsJson: string): void;
export function declineSuggestedPost(clientId: number, paramsJson: string): void;
export function addOffer(clientId: number, paramsJson: string): void;

// ==================== 通话与视频聊天 ====================
export function createCall(clientId: number, paramsJson: string): void;
export function acceptCall(clientId: number, paramsJson: string): void;
export function sendCallSignalingData(clientId: number, paramsJson: string): void;
export function discardCall(clientId: number, paramsJson: string): void;
export function sendCallRating(clientId: number, paramsJson: string): void;
export function sendCallDebugInformation(clientId: number, paramsJson: string): void;
export function sendCallLog(clientId: number, paramsJson: string): void;
export function getVideoChatAvailableParticipants(clientId: number, paramsJson: string): void;
export function setVideoChatDefaultParticipant(clientId: number, paramsJson: string): void;
export function createVideoChat(clientId: number, paramsJson: string): void;
export function createGroupCall(clientId: number, paramsJson: string): void;
export function getVideoChatRtmpUrl(clientId: number, paramsJson: string): void;
export function replaceVideoChatRtmpUrl(clientId: number, paramsJson: string): void;
export function getLiveStoryRtmpUrl(clientId: number, paramsJson: string): void;
export function replaceLiveStoryRtmpUrl(clientId: number, paramsJson: string): void;
export function getGroupCall(clientId: number, paramsJson: string): void;
export function startScheduledVideoChat(clientId: number, paramsJson: string): void;
export function toggleVideoChatEnabledStartNotification(clientId: number, paramsJson: string): void;
export function joinGroupCall(clientId: number, paramsJson: string): void;
export function joinVideoChat(clientId: number, paramsJson: string): void;
export function joinLiveStory(clientId: number, paramsJson: string): void;
export function startGroupCallScreenSharing(clientId: number, paramsJson: string): void;
export function toggleGroupCallScreenSharingIsPaused(clientId: number, paramsJson: string): void;
export function endGroupCallScreenSharing(clientId: number, paramsJson: string): void;
export function setVideoChatTitle(clientId: number, paramsJson: string): void;
export function toggleVideoChatMuteNewParticipants(clientId: number, paramsJson: string): void;
export function toggleGroupCallAreMessagesAllowed(clientId: number, paramsJson: string): void;
export function getLiveStoryStreamer(clientId: number, paramsJson: string): void;
export function getLiveStoryAvailableMessageSenders(clientId: number, paramsJson: string): void;
export function setLiveStoryMessageSender(clientId: number, paramsJson: string): void;
export function sendGroupCallMessage(clientId: number, paramsJson: string): void;
export function addPendingLiveStoryReaction(clientId: number, paramsJson: string): void;
export function commitPendingLiveStoryReactions(clientId: number, paramsJson: string): void;
export function removePendingLiveStoryReactions(clientId: number, paramsJson: string): void;
export function deleteGroupCallMessages(clientId: number, paramsJson: string): void;
export function deleteGroupCallMessagesBySender(clientId: number, paramsJson: string): void;
export function getLiveStoryTopDonors(clientId: number, paramsJson: string): void;
export function inviteGroupCallParticipant(clientId: number, paramsJson: string): void;
export function declineGroupCallInvitation(clientId: number, paramsJson: string): void;
export function banGroupCallParticipants(clientId: number, paramsJson: string): void;
export function inviteVideoChatParticipants(clientId: number, paramsJson: string): void;
export function getVideoChatInviteLink(clientId: number, paramsJson: string): void;
export function revokeGroupCallInviteLink(clientId: number, paramsJson: string): void;
export function startGroupCallRecording(clientId: number, paramsJson: string): void;
export function endGroupCallRecording(clientId: number, paramsJson: string): void;
export function toggleGroupCallIsMyVideoPaused(clientId: number, paramsJson: string): void;
export function toggleGroupCallIsMyVideoEnabled(clientId: number, paramsJson: string): void;
export function setGroupCallPaidMessageStarCount(clientId: number, paramsJson: string): void;
export function setGroupCallParticipantIsSpeaking(clientId: number, paramsJson: string): void;
export function toggleGroupCallParticipantIsMuted(clientId: number, paramsJson: string): void;
export function setGroupCallParticipantVolumeLevel(clientId: number, paramsJson: string): void;
export function toggleGroupCallParticipantIsHandRaised(clientId: number, paramsJson: string): void;
export function getGroupCallParticipants(clientId: number, paramsJson: string): void;
export function loadGroupCallParticipants(clientId: number, paramsJson: string): void;
export function leaveGroupCall(clientId: number, paramsJson: string): void;
export function endGroupCall(clientId: number, paramsJson: string): void;
export function getGroupCallStreams(clientId: number, paramsJson: string): void;
export function getGroupCallStreamSegment(clientId: number, paramsJson: string): void;
export function encryptGroupCallData(clientId: number, paramsJson: string): void;
export function decryptGroupCallData(clientId: number, paramsJson: string): void;

// ==================== 封禁与联系人 ====================
export function setMessageSenderBlockList(clientId: number, paramsJson: string): void;
export function blockMessageSenderFromReplies(clientId: number, paramsJson: string): void;
export function getBlockedMessageSenders(clientId: number, paramsJson: string): void;
export function addContact(clientId: number, paramsJson: string): void;
export function importContacts(clientId: number, paramsJson: string): void;
export function getContacts(clientId: number, paramsJson: string): void;
export function searchContacts(clientId: number, paramsJson: string): void;
export function removeContacts(clientId: number, paramsJson: string): void;
export function getImportedContactCount(clientId: number, paramsJson: string): void;
export function changeImportedContacts(clientId: number, paramsJson: string): void;
export function clearImportedContacts(clientId: number, paramsJson: string): void;
export function setCloseFriends(clientId: number, paramsJson: string): void;
export function getCloseFriends(clientId: number, paramsJson: string): void;

// ==================== 贴纸与表情 ====================
export function getStickerOutline(clientId: number, paramsJson: string): void;
export function getStickerOutlineSvgPath(clientId: number, paramsJson: string): void;
export function getStickers(clientId: number, paramsJson: string): void;
export function getAllStickerEmojis(clientId: number, paramsJson: string): void;
export function searchStickers(clientId: number, paramsJson: string): void;
export function getGreetingStickers(clientId: number, paramsJson: string): void;
export function getPremiumStickers(clientId: number, paramsJson: string): void;
export function getInstalledStickerSets(clientId: number, paramsJson: string): void;
export function getArchivedStickerSets(clientId: number, paramsJson: string): void;
export function getTrendingStickerSets(clientId: number, paramsJson: string): void;
export function getAttachedStickerSets(clientId: number, paramsJson: string): void;
export function getStickerSet(clientId: number, paramsJson: string): void;
export function getStickerSetName(clientId: number, paramsJson: string): void;
export function searchStickerSet(clientId: number, paramsJson: string): void;
export function searchInstalledStickerSets(clientId: number, paramsJson: string): void;
export function searchStickerSets(clientId: number, paramsJson: string): void;
export function changeStickerSet(clientId: number, paramsJson: string): void;
export function viewTrendingStickerSets(clientId: number, paramsJson: string): void;
export function reorderInstalledStickerSets(clientId: number, paramsJson: string): void;
export function getRecentStickers(clientId: number, paramsJson: string): void;
export function addRecentSticker(clientId: number, paramsJson: string): void;
export function removeRecentSticker(clientId: number, paramsJson: string): void;
export function clearRecentStickers(clientId: number, paramsJson: string): void;
export function getFavoriteStickers(clientId: number, paramsJson: string): void;
export function addFavoriteSticker(clientId: number, paramsJson: string): void;
export function removeFavoriteSticker(clientId: number, paramsJson: string): void;
export function getStickerEmojis(clientId: number, paramsJson: string): void;
export function searchEmojis(clientId: number, paramsJson: string): void;
export function getKeywordEmojis(clientId: number, paramsJson: string): void;
export function getEmojiCategories(clientId: number, paramsJson: string): void;
export function getAnimatedEmoji(clientId: number, paramsJson: string): void;
export function getEmojiSuggestionsUrl(clientId: number, paramsJson: string): void;
export function getCustomEmojiStickers(clientId: number, paramsJson: string): void;
export function getDefaultChatPhotoCustomEmojiStickers(clientId: number, paramsJson: string): void;
export function getDefaultProfilePhotoCustomEmojiStickers(clientId: number, paramsJson: string): void;
export function getDefaultBackgroundCustomEmojiStickers(clientId: number, paramsJson: string): void;
export function getSavedAnimations(clientId: number, paramsJson: string): void;
export function addSavedAnimation(clientId: number, paramsJson: string): void;
export function removeSavedAnimation(clientId: number, paramsJson: string): void;
export function getRecentInlineBots(clientId: number, paramsJson: string): void;
export function getOwnedBots(clientId: number, paramsJson: string): void;
export function searchHashtags(clientId: number, paramsJson: string): void;
export function removeRecentHashtag(clientId: number, paramsJson: string): void;
export function getLinkPreview(clientId: number, paramsJson: string): void;
export function getWebPageInstantView(clientId: number, paramsJson: string): void;

// ==================== 机器人命令与菜单 ====================
export function setCommands(clientId: number, paramsJson: string): void;
export function deleteCommands(clientId: number, paramsJson: string): void;
export function getCommands(clientId: number, paramsJson: string): void;
export function setMenuButton(clientId: number, paramsJson: string): void;
export function getMenuButton(clientId: number, paramsJson: string): void;
export function setDefaultGroupAdministratorRights(clientId: number, paramsJson: string): void;
export function setDefaultChannelAdministratorRights(clientId: number, paramsJson: string): void;
export function canBotSendMessages(clientId: number, paramsJson: string): void;
export function allowBotToSendMessages(clientId: number, paramsJson: string): void;
export function sendWebAppCustomRequest(clientId: number, paramsJson: string): void;
export function getBotMediaPreviews(clientId: number, paramsJson: string): void;
export function getBotMediaPreviewInfo(clientId: number, paramsJson: string): void;
export function addBotMediaPreview(clientId: number, paramsJson: string): void;
export function editBotMediaPreview(clientId: number, paramsJson: string): void;
export function reorderBotMediaPreviews(clientId: number, paramsJson: string): void;
export function deleteBotMediaPreviews(clientId: number, paramsJson: string): void;
export function setBotName(clientId: number, paramsJson: string): void;
export function getBotName(clientId: number, paramsJson: string): void;
export function setBotProfilePhoto(clientId: number, paramsJson: string): void;
export function toggleBotUsernameIsActive(clientId: number, paramsJson: string): void;
export function reorderBotActiveUsernames(clientId: number, paramsJson: string): void;
export function setBotInfoDescription(clientId: number, paramsJson: string): void;
export function getBotInfoDescription(clientId: number, paramsJson: string): void;
export function setBotInfoShortDescription(clientId: number, paramsJson: string): void;
export function getBotInfoShortDescription(clientId: number, paramsJson: string): void;
export function setMessageSenderBotVerification(clientId: number, paramsJson: string): void;
export function removeMessageSenderBotVerification(clientId: number, paramsJson: string): void;

// ==================== 会话与网站 ====================
export function getActiveSessions(clientId: number, paramsJson: string): void;
export function terminateSession(clientId: number, paramsJson: string): void;
export function terminateAllOtherSessions(clientId: number, paramsJson: string): void;
export function confirmSession(clientId: number, paramsJson: string): void;
export function toggleSessionCanAcceptCalls(clientId: number, paramsJson: string): void;
export function toggleSessionCanAcceptSecretChats(clientId: number, paramsJson: string): void;
export function setInactiveSessionTtl(clientId: number, paramsJson: string): void;
export function getConnectedWebsites(clientId: number, paramsJson: string): void;
export function disconnectWebsite(clientId: number, paramsJson: string): void;
export function disconnectAllWebsites(clientId: number, paramsJson: string): void;

// ==================== 超级群组管理 ====================
export function setSupergroupUsername(clientId: number, paramsJson: string): void;
export function toggleSupergroupUsernameIsActive(clientId: number, paramsJson: string): void;
export function disableAllSupergroupUsernames(clientId: number, paramsJson: string): void;
export function reorderSupergroupActiveUsernames(clientId: number, paramsJson: string): void;
export function setSupergroupStickerSet(clientId: number, paramsJson: string): void;
export function setSupergroupCustomEmojiStickerSet(clientId: number, paramsJson: string): void;
export function setSupergroupUnrestrictBoostCount(clientId: number, paramsJson: string): void;
export function setSupergroupMainProfileTab(clientId: number, paramsJson: string): void;
export function toggleSupergroupSignMessages(clientId: number, paramsJson: string): void;
export function toggleSupergroupJoinToSendMessages(clientId: number, paramsJson: string): void;
export function toggleSupergroupJoinByRequest(clientId: number, paramsJson: string): void;
export function toggleSupergroupIsAllHistoryAvailable(clientId: number, paramsJson: string): void;
export function toggleSupergroupCanHaveSponsoredMessages(clientId: number, paramsJson: string): void;
export function toggleSupergroupHasAutomaticTranslation(clientId: number, paramsJson: string): void;
export function toggleSupergroupHasHiddenMembers(clientId: number, paramsJson: string): void;
export function toggleSupergroupHasAggressiveAntiSpamEnabled(clientId: number, paramsJson: string): void;
export function toggleSupergroupIsForum(clientId: number, paramsJson: string): void;
export function toggleSupergroupIsBroadcastGroup(clientId: number, paramsJson: string): void;
export function reportSupergroupSpam(clientId: number, paramsJson: string): void;
export function reportSupergroupAntiSpamFalsePositive(clientId: number, paramsJson: string): void;
export function getSupergroupMembers(clientId: number, paramsJson: string): void;
export function closeSecretChat(clientId: number, paramsJson: string): void;
export function getChatEventLog(clientId: number, paramsJson: string): void;

// ==================== 时区 ====================
export function getTimeZones(clientId: number, paramsJson: string): void;

// ==================== 支付与星币 ====================
export function getPaymentForm(clientId: number, paramsJson: string): void;
export function validateOrderInfo(clientId: number, paramsJson: string): void;
export function sendPaymentForm(clientId: number, paramsJson: string): void;
export function getPaymentReceipt(clientId: number, paramsJson: string): void;
export function getSavedOrderInfo(clientId: number, paramsJson: string): void;
export function deleteSavedOrderInfo(clientId: number, paramsJson: string): void;
export function deleteSavedCredentials(clientId: number, paramsJson: string): void;
export function setGiftSettings(clientId: number, paramsJson: string): void;
export function getAvailableGifts(clientId: number, paramsJson: string): void;
export function canSendGift(clientId: number, paramsJson: string): void;
export function sendGift(clientId: number, paramsJson: string): void;
export function getGiftAuctionState(clientId: number, paramsJson: string): void;
export function getGiftAuctionAcquiredGifts(clientId: number, paramsJson: string): void;
export function openGiftAuction(clientId: number, paramsJson: string): void;
export function closeGiftAuction(clientId: number, paramsJson: string): void;
export function placeGiftAuctionBid(clientId: number, paramsJson: string): void;
export function increaseGiftAuctionBid(clientId: number, paramsJson: string): void;
export function sellGift(clientId: number, paramsJson: string): void;
export function toggleGiftIsSaved(clientId: number, paramsJson: string): void;
export function setPinnedGifts(clientId: number, paramsJson: string): void;
export function toggleChatGiftNotifications(clientId: number, paramsJson: string): void;
export function getGiftUpgradePreview(clientId: number, paramsJson: string): void;
export function getUpgradedGiftVariants(clientId: number, paramsJson: string): void;
export function upgradeGift(clientId: number, paramsJson: string): void;
export function buyGiftUpgrade(clientId: number, paramsJson: string): void;
export function craftGift(clientId: number, paramsJson: string): void;
export function transferGift(clientId: number, paramsJson: string): void;
export function dropGiftOriginalDetails(clientId: number, paramsJson: string): void;
export function sendResoldGift(clientId: number, paramsJson: string): void;
export function sendGiftPurchaseOffer(clientId: number, paramsJson: string): void;
export function processGiftPurchaseOffer(clientId: number, paramsJson: string): void;
export function getReceivedGifts(clientId: number, paramsJson: string): void;
export function getReceivedGift(clientId: number, paramsJson: string): void;
export function getGiftsForCrafting(clientId: number, paramsJson: string): void;
export function getUpgradedGift(clientId: number, paramsJson: string): void;
export function getUpgradedGiftValueInfo(clientId: number, paramsJson: string): void;
export function getUpgradedGiftWithdrawalUrl(clientId: number, paramsJson: string): void;
export function getUpgradedGiftsPromotionalAnimation(clientId: number, paramsJson: string): void;
export function setGiftResalePrice(clientId: number, paramsJson: string): void;
export function searchGiftsForResale(clientId: number, paramsJson: string): void;
export function getGiftCollections(clientId: number, paramsJson: string): void;
export function createGiftCollection(clientId: number, paramsJson: string): void;
export function reorderGiftCollections(clientId: number, paramsJson: string): void;
export function deleteGiftCollection(clientId: number, paramsJson: string): void;
export function setGiftCollectionName(clientId: number, paramsJson: string): void;
export function addGiftCollectionGifts(clientId: number, paramsJson: string): void;
export function removeGiftCollectionGifts(clientId: number, paramsJson: string): void;
export function reorderGiftCollectionGifts(clientId: number, paramsJson: string): void;
export function createInvoiceLink(clientId: number, paramsJson: string): void;
export function refundStarPayment(clientId: number, paramsJson: string): void;
export function getSupportUser(clientId: number, paramsJson: string): void;

// ==================== 背景 ====================
export function getBackgroundUrl(clientId: number, paramsJson: string): void;
export function searchBackground(clientId: number, paramsJson: string): void;
export function setDefaultBackground(clientId: number, paramsJson: string): void;
export function deleteDefaultBackground(clientId: number, paramsJson: string): void;
export function getInstalledBackgrounds(clientId: number, paramsJson: string): void;
export function removeInstalledBackground(clientId: number, paramsJson: string): void;
export function resetInstalledBackgrounds(clientId: number, paramsJson: string): void;

// ==================== 本地化 ====================
export function getLocalizationTargetInfo(clientId: number, paramsJson: string): void;
export function getLanguagePackInfo(clientId: number, paramsJson: string): void;
export function getLanguagePackStrings(clientId: number, paramsJson: string): void;
export function synchronizeLanguagePack(clientId: number, paramsJson: string): void;
export function addCustomServerLanguagePack(clientId: number, paramsJson: string): void;
export function setCustomLanguagePack(clientId: number, paramsJson: string): void;
export function editCustomLanguagePackInfo(clientId: number, paramsJson: string): void;
export function setCustomLanguagePackString(clientId: number, paramsJson: string): void;
export function deleteLanguagePack(clientId: number, paramsJson: string): void;

// ==================== 推送通知 ====================
export function registerDevice(clientId: number, paramsJson: string): void;
export function processPushNotification(clientId: number, paramsJson: string): void;
export function getPushReceiverId(clientId: number, paramsJson: string): void;
export function getRecentlyVisitedTMeUrls(clientId: number, paramsJson: string): void;

// ==================== 隐私设置 ====================
export function setUserPrivacySettingRules(clientId: number, paramsJson: string): void;
export function getUserPrivacySettingRules(clientId: number, paramsJson: string): void;
export function setReadDatePrivacySettings(clientId: number, paramsJson: string): void;
export function getReadDatePrivacySettings(clientId: number, paramsJson: string): void;
export function setNewChatPrivacySettings(clientId: number, paramsJson: string): void;
export function getNewChatPrivacySettings(clientId: number, paramsJson: string): void;

// ==================== 付费消息与收入 ====================
export function getPaidMessageRevenue(clientId: number, paramsJson: string): void;
export function allowUnpaidMessagesFromUser(clientId: number, paramsJson: string): void;
export function setChatPaidMessageStarCount(clientId: number, paramsJson: string): void;
export function canSendMessageToUser(clientId: number, paramsJson: string): void;
export function getOption(clientId: number, paramsJson: string): void;
export function setOption(clientId: number, paramsJson: string): void;
export function setAccountTtl(clientId: number, paramsJson: string): void;
export function getAccountTtl(clientId: number, paramsJson: string): void;
export function deleteAccount(clientId: number, paramsJson: string): void;
export function setDefaultMessageAutoDeleteTime(clientId: number, paramsJson: string): void;
export function getDefaultMessageAutoDeleteTime(clientId: number, paramsJson: string): void;
export function removeChatActionBar(clientId: number, paramsJson: string): void;
export function reportChat(clientId: number, paramsJson: string): void;
export function reportChatPhoto(clientId: number, paramsJson: string): void;
export function reportMessageReactions(clientId: number, paramsJson: string): void;
export function getChatRevenueStatistics(clientId: number, paramsJson: string): void;
export function getChatRevenueWithdrawalUrl(clientId: number, paramsJson: string): void;
export function getChatRevenueTransactions(clientId: number, paramsJson: string): void;
export function getTonTransactions(clientId: number, paramsJson: string): void;
export function getStarRevenueStatistics(clientId: number, paramsJson: string): void;
export function getStarWithdrawalUrl(clientId: number, paramsJson: string): void;
export function getStarAdAccountUrl(clientId: number, paramsJson: string): void;
export function getTonRevenueStatistics(clientId: number, paramsJson: string): void;
export function getTonWithdrawalUrl(clientId: number, paramsJson: string): void;
export function getChatStatistics(clientId: number, paramsJson: string): void;
export function getMessageStatistics(clientId: number, paramsJson: string): void;
export function getMessagePublicForwards(clientId: number, paramsJson: string): void;
export function getStoryStatistics(clientId: number, paramsJson: string): void;
export function getStatisticalGraph(clientId: number, paramsJson: string): void;
export function getStorageStatistics(clientId: number, paramsJson: string): void;
export function getStorageStatisticsFast(clientId: number, paramsJson: string): void;
export function getDatabaseStatistics(clientId: number, paramsJson: string): void;
export function optimizeStorage(clientId: number, paramsJson: string): void;
export function setNetworkType(clientId: number, paramsJson: string): void;
export function getNetworkStatistics(clientId: number, paramsJson: string): void;
export function addNetworkStatistics(clientId: number, paramsJson: string): void;
export function resetNetworkStatistics(clientId: number, paramsJson: string): void;
export function getAutosaveSettings(clientId: number, paramsJson: string): void;
export function setAutosaveSettings(clientId: number, paramsJson: string): void;
export function clearAutosaveSettingsExceptions(clientId: number, paramsJson: string): void;
export function getBankCardInfo(clientId: number, paramsJson: string): void;

// ==================== 证件信息 ====================
export function getPassportElement(clientId: number, paramsJson: string): void;
export function getAllPassportElements(clientId: number, paramsJson: string): void;
export function setPassportElement(clientId: number, paramsJson: string): void;
export function deletePassportElement(clientId: number, paramsJson: string): void;
export function setPassportElementErrors(clientId: number, paramsJson: string): void;
export function getPreferredCountryLanguage(clientId: number, paramsJson: string): void;
export function sendEmailAddressVerificationCode(clientId: number, paramsJson: string): void;
export function resendEmailAddressVerificationCode(clientId: number, paramsJson: string): void;
export function checkEmailAddressVerificationCode(clientId: number, paramsJson: string): void;
export function getPassportAuthorizationForm(clientId: number, paramsJson: string): void;
export function getPassportAuthorizationFormAvailableElements(clientId: number, paramsJson: string): void;
export function sendPassportAuthorizationForm(clientId: number, paramsJson: string): void;

// ==================== 机器人更新 ====================
export function setBotUpdatesStatus(clientId: number, paramsJson: string): void;

// ==================== 贴纸集管理 ====================
export function createNewStickerSet(clientId: number, paramsJson: string): void;
export function addStickerToSet(clientId: number, paramsJson: string): void;
export function replaceStickerInSet(clientId: number, paramsJson: string): void;
export function setStickerSetThumbnail(clientId: number, paramsJson: string): void;
export function setCustomEmojiStickerSetThumbnail(clientId: number, paramsJson: string): void;
export function setStickerSetTitle(clientId: number, paramsJson: string): void;
export function deleteStickerSet(clientId: number, paramsJson: string): void;
export function setStickerPositionInSet(clientId: number, paramsJson: string): void;
export function removeStickerFromSet(clientId: number, paramsJson: string): void;
export function setStickerEmojis(clientId: number, paramsJson: string): void;
export function setStickerKeywords(clientId: number, paramsJson: string): void;
export function setStickerMaskPosition(clientId: number, paramsJson: string): void;
export function getOwnedStickerSets(clientId: number, paramsJson: string): void;
export function getPremiumLimit(clientId: number, paramsJson: string): void;
export function getPremiumFeatures(clientId: number, paramsJson: string): void;
export function getPremiumStickerExamples(clientId: number, paramsJson: string): void;
export function getPremiumInfoSticker(clientId: number, paramsJson: string): void;
export function viewPremiumFeature(clientId: number, paramsJson: string): void;
export function clickPremiumSubscriptionButton(clientId: number, paramsJson: string): void;
export function getPremiumState(clientId: number, paramsJson: string): void;
export function getPremiumGiftPaymentOptions(clientId: number, paramsJson: string): void;
export function getPremiumGiveawayPaymentOptions(clientId: number, paramsJson: string): void;
export function checkPremiumGiftCode(clientId: number, paramsJson: string): void;
export function applyPremiumGiftCode(clientId: number, paramsJson: string): void;
export function giftPremiumWithStars(clientId: number, paramsJson: string): void;
export function launchPrepaidGiveaway(clientId: number, paramsJson: string): void;
export function getGiveawayInfo(clientId: number, paramsJson: string): void;
export function getStarPaymentOptions(clientId: number, paramsJson: string): void;
export function getStarGiftPaymentOptions(clientId: number, paramsJson: string): void;
export function getStarGiveawayPaymentOptions(clientId: number, paramsJson: string): void;
export function getStarTransactions(clientId: number, paramsJson: string): void;
export function getStarSubscriptions(clientId: number, paramsJson: string): void;
export function canPurchaseFromStore(clientId: number, paramsJson: string): void;
export function assignStoreTransaction(clientId: number, paramsJson: string): void;
export function editStarSubscription(clientId: number, paramsJson: string): void;
export function editUserStarSubscription(clientId: number, paramsJson: string): void;
export function reuseStarSubscription(clientId: number, paramsJson: string): void;

// ==================== 联盟计划 ====================
export function setChatAffiliateProgram(clientId: number, paramsJson: string): void;
export function searchChatAffiliateProgram(clientId: number, paramsJson: string): void;
export function searchAffiliatePrograms(clientId: number, paramsJson: string): void;
export function connectAffiliateProgram(clientId: number, paramsJson: string): void;
export function disconnectAffiliateProgram(clientId: number, paramsJson: string): void;
export function getConnectedAffiliateProgram(clientId: number, paramsJson: string): void;
export function getConnectedAffiliatePrograms(clientId: number, paramsJson: string): void;
export function getBusinessFeatures(clientId: number, paramsJson: string): void;

// ==================== 服务条款 ====================
export function acceptTermsOfService(clientId: number, paramsJson: string): void;
export function searchStringsByPrefix(clientId: number, paramsJson: string): void;
export function sendCustomRequest(clientId: number, paramsJson: string): void;
export function answerCustomQuery(clientId: number, paramsJson: string): void;
export function setAlarm(clientId: number, paramsJson: string): void;
export function getCountries(clientId: number, paramsJson: string): void;
export function getCountryCode(clientId: number, paramsJson: string): void;
export function getPhoneNumberInfo(clientId: number, paramsJson: string): void;
export function getPhoneNumberInfoSync(clientId: number, paramsJson: string): void;
export function getCollectibleItemInfo(clientId: number, paramsJson: string): void;
export function getDeepLinkInfo(clientId: number, paramsJson: string): void;
export function getApplicationConfig(clientId: number, paramsJson: string): void;
export function saveApplicationLogEvent(clientId: number, paramsJson: string): void;

// ==================== 代理 ====================
export function addProxy(clientId: number, paramsJson: string): void;
export function editProxy(clientId: number, paramsJson: string): void;
export function enableProxy(clientId: number, paramsJson: string): void;
export function disableProxy(clientId: number, paramsJson: string): void;
export function removeProxy(clientId: number, paramsJson: string): void;
export function getProxies(clientId: number, paramsJson: string): void;
export function pingProxy(clientId: number, paramsJson: string): void;

// ==================== 日志 ====================
export function setLogStream(clientId: number, paramsJson: string): void;
export function getLogStream(clientId: number, paramsJson: string): void;
export function setLogVerbosityLevel(clientId: number, paramsJson: string): void;
export function getLogVerbosityLevel(clientId: number, paramsJson: string): void;
export function getLogTags(clientId: number, paramsJson: string): void;
export function setLogTagVerbosityLevel(clientId: number, paramsJson: string): void;
export function getLogTagVerbosityLevel(clientId: number, paramsJson: string): void;
export function addLogMessage(clientId: number, paramsJson: string): void;

// ==================== 支持 ====================
export function getUserSupportInfo(clientId: number, paramsJson: string): void;
export function setUserSupportInfo(clientId: number, paramsJson: string): void;
export function getSupportName(clientId: number, paramsJson: string): void;

// ==================== 测试方法 ====================
export function testCallEmpty(clientId: number, paramsJson: string): void;
export function testCallString(clientId: number, paramsJson: string): void;
export function testCallBytes(clientId: number, paramsJson: string): void;
export function testCallVectorInt(clientId: number, paramsJson: string): void;
export function testCallVectorIntObject(clientId: number, paramsJson: string): void;
export function testCallVectorString(clientId: number, paramsJson: string): void;
export function testCallVectorStringObject(clientId: number, paramsJson: string): void;
export function testSquareInt(clientId: number, paramsJson: string): void;
export function testNetwork(clientId: number, paramsJson: string): void;
export function testProxy(clientId: number, paramsJson: string): void;
export function testGetDifference(clientId: number, paramsJson: string): void;
export function testUseUpdate(clientId: number, paramsJson: string): void;
export function testReturnError(clientId: number, paramsJson: string): void;