/**
 * libhome.so 完整类型声明
 * 包含所有 TDLib API 方法（500+），每个方法接收 clientId 和 JSON 参数字符串。
 * 响应通过 tdlibReceiveGlobal 异步获取。
 *
 * 注意：所有 TDLib API 方法统一使用 (clientId: number, paramsJson: string) 签名
 * @note 这些函数由 C++ NAPI 模块提供，运行时从 libhome.so 加载
 */

/** 示例：两数相加 */
export declare function add(a: number, b: number): number;

/** 设置 TDLib 日志级别 (0-1024) */
export declare function setLogVerbosityLevel(clientId: number, paramsJson: string): void;

/** 创建 TDLib 客户端，返回 client_id */
export declare function tdlibCreateClientId(): number;

/** 向指定 client 发送 JSON 请求（完整 JSON 字符串） */
export declare function tdlibSendById(clientId: number, request: string): void;

/** 全局接收：从任意 client 接收一条响应/更新，timeout 秒 */
export declare function tdlibReceiveGlobal(timeout: number): string | null;

/** 同步执行一条 JSON 请求 */
export declare function tdlibExecuteGlobal(request: string): string | null;

/** 关闭 TDLib 客户端 */
export declare function tdlibCloseClient(clientId: number): void;

/**
 * 以下为所有 TDLib API 方法
 * 每个方法：(clientId: number, paramsJson: string) => void
 * paramsJson 为请求参数字符串（不含 @type），例如 "{\"phone_number\":\"+123\"}"
 */

// ==================== 认证与授权 ====================
export declare function getAuthorizationState(clientId: number, paramsJson: string): void;
export declare function setTdlibParameters(clientId: number, paramsJson: string): void;
export declare function setAuthenticationPhoneNumber(clientId: number, paramsJson: string): void;
export declare function checkAuthenticationPremiumPurchase(clientId: number, paramsJson: string): void;
export declare function setAuthenticationPremiumPurchaseTransaction(clientId: number, paramsJson: string): void;
export declare function setAuthenticationEmailAddress(clientId: number, paramsJson: string): void;
export declare function resendAuthenticationCode(clientId: number, paramsJson: string): void;
export declare function checkAuthenticationEmailCode(clientId: number, paramsJson: string): void;
export declare function checkAuthenticationCode(clientId: number, paramsJson: string): void;
export declare function requestQrCodeAuthentication(clientId: number, paramsJson: string): void;
export declare function getAuthenticationPasskeyParameters(clientId: number, paramsJson: string): void;
export declare function checkAuthenticationPasskey(clientId: number, paramsJson: string): void;
export declare function registerUser(clientId: number, paramsJson: string): void;
export declare function resetAuthenticationEmailAddress(clientId: number, paramsJson: string): void;
export declare function checkAuthenticationPassword(clientId: number, paramsJson: string): void;
export declare function requestAuthenticationPasswordRecovery(clientId: number, paramsJson: string): void;
export declare function checkAuthenticationPasswordRecoveryCode(clientId: number, paramsJson: string): void;
export declare function recoverAuthenticationPassword(clientId: number, paramsJson: string): void;
export declare function sendAuthenticationFirebaseSms(clientId: number, paramsJson: string): void;
export declare function reportAuthenticationCodeMissing(clientId: number, paramsJson: string): void;
export declare function checkAuthenticationBotToken(clientId: number, paramsJson: string): void;
export declare function logOut(clientId: number, paramsJson: string): void;
export declare function close(clientId: number, paramsJson: string): void;
export declare function destroy(clientId: number, paramsJson: string): void;
export declare function confirmQrCodeAuthentication(clientId: number, paramsJson: string): void;
export declare function getCurrentState(clientId: number, paramsJson: string): void;
export declare function setDatabaseEncryptionKey(clientId: number, paramsJson: string): void;
export declare function getPasswordState(clientId: number, paramsJson: string): void;
export declare function setPassword(clientId: number, paramsJson: string): void;
export declare function isLoginEmailAddressRequired(clientId: number, paramsJson: string): void;
export declare function setLoginEmailAddress(clientId: number, paramsJson: string): void;
export declare function resendLoginEmailAddressCode(clientId: number, paramsJson: string): void;
export declare function checkLoginEmailAddressCode(clientId: number, paramsJson: string): void;
export declare function getRecoveryEmailAddress(clientId: number, paramsJson: string): void;
export declare function setRecoveryEmailAddress(clientId: number, paramsJson: string): void;
export declare function checkRecoveryEmailAddressCode(clientId: number, paramsJson: string): void;
export declare function resendRecoveryEmailAddressCode(clientId: number, paramsJson: string): void;
export declare function cancelRecoveryEmailAddressVerification(clientId: number, paramsJson: string): void;
export declare function requestPasswordRecovery(clientId: number, paramsJson: string): void;
export declare function checkPasswordRecoveryCode(clientId: number, paramsJson: string): void;
export declare function recoverPassword(clientId: number, paramsJson: string): void;
export declare function resetPassword(clientId: number, paramsJson: string): void;
export declare function cancelPasswordReset(clientId: number, paramsJson: string): void;
export declare function createTemporaryPassword(clientId: number, paramsJson: string): void;
export declare function getTemporaryPasswordState(clientId: number, paramsJson: string): void;

// ==================== 用户与个人资料 ====================
export declare function getMe(clientId: number, paramsJson: string): void;
export declare function getUser(clientId: number, paramsJson: string): void;
export declare function getUserFullInfo(clientId: number, paramsJson: string): void;
export declare function getBasicGroup(clientId: number, paramsJson: string): void;
export declare function getBasicGroupFullInfo(clientId: number, paramsJson: string): void;
export declare function getSupergroup(clientId: number, paramsJson: string): void;
export declare function getSupergroupFullInfo(clientId: number, paramsJson: string): void;
export declare function getSecretChat(clientId: number, paramsJson: string): void;
export declare function getUserProfilePhotos(clientId: number, paramsJson: string): void;
export declare function getUserProfileAudios(clientId: number, paramsJson: string): void;
export declare function isProfileAudio(clientId: number, paramsJson: string): void;
export declare function addProfileAudio(clientId: number, paramsJson: string): void;
export declare function setProfileAudioPosition(clientId: number, paramsJson: string): void;
export declare function removeProfileAudio(clientId: number, paramsJson: string): void;
export declare function setUserPersonalProfilePhoto(clientId: number, paramsJson: string): void;
export declare function setUserNote(clientId: number, paramsJson: string): void;
export declare function suggestUserProfilePhoto(clientId: number, paramsJson: string): void;
export declare function suggestUserBirthdate(clientId: number, paramsJson: string): void;
export declare function toggleBotCanManageEmojiStatus(clientId: number, paramsJson: string): void;
export declare function setUserEmojiStatus(clientId: number, paramsJson: string): void;
export declare function searchUserByPhoneNumber(clientId: number, paramsJson: string): void;
export declare function sharePhoneNumber(clientId: number, paramsJson: string): void;
export declare function setProfilePhoto(clientId: number, paramsJson: string): void;
export declare function deleteProfilePhoto(clientId: number, paramsJson: string): void;
export declare function setAccentColor(clientId: number, paramsJson: string): void;
export declare function setUpgradedGiftColors(clientId: number, paramsJson: string): void;
export declare function setProfileAccentColor(clientId: number, paramsJson: string): void;
export declare function setName(clientId: number, paramsJson: string): void;
export declare function setBio(clientId: number, paramsJson: string): void;
export declare function setUsername(clientId: number, paramsJson: string): void;
export declare function toggleUsernameIsActive(clientId: number, paramsJson: string): void;
export declare function reorderActiveUsernames(clientId: number, paramsJson: string): void;
export declare function setBirthdate(clientId: number, paramsJson: string): void;
export declare function setMainProfileTab(clientId: number, paramsJson: string): void;
export declare function setPersonalChat(clientId: number, paramsJson: string): void;
export declare function setEmojiStatus(clientId: number, paramsJson: string): void;
export declare function toggleHasSponsoredMessagesEnabled(clientId: number, paramsJson: string): void;
export declare function setBusinessLocation(clientId: number, paramsJson: string): void;
export declare function setBusinessOpeningHours(clientId: number, paramsJson: string): void;
export declare function setBusinessGreetingMessageSettings(clientId: number, paramsJson: string): void;
export declare function setBusinessAwayMessageSettings(clientId: number, paramsJson: string): void;
export declare function setBusinessStartPage(clientId: number, paramsJson: string): void;
export declare function getBusinessConnectedBot(clientId: number, paramsJson: string): void;
export declare function setBusinessConnectedBot(clientId: number, paramsJson: string): void;
export declare function deleteBusinessConnectedBot(clientId: number, paramsJson: string): void;
export declare function toggleBusinessConnectedBotChatIsPaused(clientId: number, paramsJson: string): void;
export declare function removeBusinessConnectedBotFromChat(clientId: number, paramsJson: string): void;
export declare function getBusinessChatLinks(clientId: number, paramsJson: string): void;
export declare function createBusinessChatLink(clientId: number, paramsJson: string): void;
export declare function editBusinessChatLink(clientId: number, paramsJson: string): void;
export declare function deleteBusinessChatLink(clientId: number, paramsJson: string): void;
export declare function getBusinessChatLinkInfo(clientId: number, paramsJson: string): void;
export declare function getUserLink(clientId: number, paramsJson: string): void;
export declare function searchUserByToken(clientId: number, paramsJson: string): void;

// ==================== 聊天管理 ====================
export declare function getChat(clientId: number, paramsJson: string): void;
export declare function getMessage(clientId: number, paramsJson: string): void;
export declare function getMessageLocally(clientId: number, paramsJson: string): void;
export declare function getRepliedMessage(clientId: number, paramsJson: string): void;
export declare function getChatPinnedMessage(clientId: number, paramsJson: string): void;
export declare function getCallbackQueryMessage(clientId: number, paramsJson: string): void;
export declare function getMessages(clientId: number, paramsJson: string): void;
export declare function getMessageProperties(clientId: number, paramsJson: string): void;
export declare function getMessageThread(clientId: number, paramsJson: string): void;
export declare function getMessageReadDate(clientId: number, paramsJson: string): void;
export declare function getMessageViewers(clientId: number, paramsJson: string): void;
export declare function getMessageAuthor(clientId: number, paramsJson: string): void;
export declare function loadChats(clientId: number, paramsJson: string): void;
export declare function getChats(clientId: number, paramsJson: string): void;
export declare function searchPublicChat(clientId: number, paramsJson: string): void;
export declare function searchPublicChats(clientId: number, paramsJson: string): void;
export declare function searchChats(clientId: number, paramsJson: string): void;
export declare function searchChatsOnServer(clientId: number, paramsJson: string): void;
export declare function getRecommendedChats(clientId: number, paramsJson: string): void;
export declare function getChatSimilarChats(clientId: number, paramsJson: string): void;
export declare function getChatSimilarChatCount(clientId: number, paramsJson: string): void;
export declare function openChatSimilarChat(clientId: number, paramsJson: string): void;
export declare function getBotSimilarBots(clientId: number, paramsJson: string): void;
export declare function getBotSimilarBotCount(clientId: number, paramsJson: string): void;
export declare function openBotSimilarBot(clientId: number, paramsJson: string): void;
export declare function getTopChats(clientId: number, paramsJson: string): void;
export declare function removeTopChat(clientId: number, paramsJson: string): void;
export declare function searchRecentlyFoundChats(clientId: number, paramsJson: string): void;
export declare function addRecentlyFoundChat(clientId: number, paramsJson: string): void;
export declare function removeRecentlyFoundChat(clientId: number, paramsJson: string): void;
export declare function clearRecentlyFoundChats(clientId: number, paramsJson: string): void;
export declare function getRecentlyOpenedChats(clientId: number, paramsJson: string): void;
export declare function checkChatUsername(clientId: number, paramsJson: string): void;
export declare function getCreatedPublicChats(clientId: number, paramsJson: string): void;
export declare function checkCreatedPublicChatsLimit(clientId: number, paramsJson: string): void;
export declare function getSuitableDiscussionChats(clientId: number, paramsJson: string): void;
export declare function getInactiveSupergroupChats(clientId: number, paramsJson: string): void;
export declare function getSuitablePersonalChats(clientId: number, paramsJson: string): void;
export declare function loadDirectMessagesChatTopics(clientId: number, paramsJson: string): void;
export declare function getDirectMessagesChatTopic(clientId: number, paramsJson: string): void;
export declare function getDirectMessagesChatTopicHistory(clientId: number, paramsJson: string): void;
export declare function getDirectMessagesChatTopicMessageByDate(clientId: number, paramsJson: string): void;
export declare function deleteDirectMessagesChatTopicHistory(clientId: number, paramsJson: string): void;
export declare function deleteDirectMessagesChatTopicMessagesByDate(clientId: number, paramsJson: string): void;
export declare function setDirectMessagesChatTopicIsMarkedAsUnread(clientId: number, paramsJson: string): void;
export declare function unpinAllDirectMessagesChatTopicMessages(clientId: number, paramsJson: string): void;
export declare function readAllDirectMessagesChatTopicReactions(clientId: number, paramsJson: string): void;
export declare function getDirectMessagesChatTopicRevenue(clientId: number, paramsJson: string): void;
export declare function toggleDirectMessagesChatTopicCanSendUnpaidMessages(clientId: number, paramsJson: string): void;
export declare function loadSavedMessagesTopics(clientId: number, paramsJson: string): void;
export declare function getSavedMessagesTopicHistory(clientId: number, paramsJson: string): void;
export declare function getSavedMessagesTopicMessageByDate(clientId: number, paramsJson: string): void;
export declare function deleteSavedMessagesTopicHistory(clientId: number, paramsJson: string): void;
export declare function deleteSavedMessagesTopicMessagesByDate(clientId: number, paramsJson: string): void;
export declare function toggleSavedMessagesTopicIsPinned(clientId: number, paramsJson: string): void;
export declare function setPinnedSavedMessagesTopics(clientId: number, paramsJson: string): void;
export declare function getGroupsInCommon(clientId: number, paramsJson: string): void;
export declare function getChatHistory(clientId: number, paramsJson: string): void;
export declare function getMessageThreadHistory(clientId: number, paramsJson: string): void;
export declare function deleteChatHistory(clientId: number, paramsJson: string): void;
export declare function deleteChat(clientId: number, paramsJson: string): void;
export declare function searchChatMessages(clientId: number, paramsJson: string): void;
export declare function searchMessages(clientId: number, paramsJson: string): void;
export declare function searchSecretMessages(clientId: number, paramsJson: string): void;
export declare function searchSavedMessages(clientId: number, paramsJson: string): void;
export declare function searchCallMessages(clientId: number, paramsJson: string): void;
export declare function searchOutgoingDocumentMessages(clientId: number, paramsJson: string): void;
export declare function getPublicPostSearchLimits(clientId: number, paramsJson: string): void;
export declare function searchPublicPosts(clientId: number, paramsJson: string): void;
export declare function searchPublicMessagesByTag(clientId: number, paramsJson: string): void;
export declare function searchPublicStoriesByTag(clientId: number, paramsJson: string): void;
export declare function searchPublicStoriesByLocation(clientId: number, paramsJson: string): void;
export declare function searchPublicStoriesByVenue(clientId: number, paramsJson: string): void;
export declare function getSearchedForTags(clientId: number, paramsJson: string): void;
export declare function removeSearchedForTag(clientId: number, paramsJson: string): void;
export declare function clearSearchedForTags(clientId: number, paramsJson: string): void;
export declare function deleteAllCallMessages(clientId: number, paramsJson: string): void;
export declare function searchChatRecentLocationMessages(clientId: number, paramsJson: string): void;
export declare function getChatMessageByDate(clientId: number, paramsJson: string): void;
export declare function getChatSparseMessagePositions(clientId: number, paramsJson: string): void;
export declare function getChatMessageCalendar(clientId: number, paramsJson: string): void;
export declare function getChatMessageCount(clientId: number, paramsJson: string): void;
export declare function getChatMessagePosition(clientId: number, paramsJson: string): void;
export declare function getChatScheduledMessages(clientId: number, paramsJson: string): void;
export declare function getChatSponsoredMessages(clientId: number, paramsJson: string): void;
export declare function clickChatSponsoredMessage(clientId: number, paramsJson: string): void;
export declare function reportChatSponsoredMessage(clientId: number, paramsJson: string): void;
export declare function getSearchSponsoredChats(clientId: number, paramsJson: string): void;
export declare function viewSponsoredChat(clientId: number, paramsJson: string): void;
export declare function openSponsoredChat(clientId: number, paramsJson: string): void;
export declare function reportSponsoredChat(clientId: number, paramsJson: string): void;
export declare function getVideoMessageAdvertisements(clientId: number, paramsJson: string): void;
export declare function viewVideoMessageAdvertisement(clientId: number, paramsJson: string): void;
export declare function clickVideoMessageAdvertisement(clientId: number, paramsJson: string): void;
export declare function reportVideoMessageAdvertisement(clientId: number, paramsJson: string): void;
export declare function removeNotification(clientId: number, paramsJson: string): void;
export declare function removeNotificationGroup(clientId: number, paramsJson: string): void;
export declare function getMessageLink(clientId: number, paramsJson: string): void;
export declare function getMessageEmbeddingCode(clientId: number, paramsJson: string): void;
export declare function getMessageLinkInfo(clientId: number, paramsJson: string): void;
export declare function translateText(clientId: number, paramsJson: string): void;
export declare function translateMessageText(clientId: number, paramsJson: string): void;
export declare function summarizeMessage(clientId: number, paramsJson: string): void;
export declare function recognizeSpeech(clientId: number, paramsJson: string): void;
export declare function rateSpeechRecognition(clientId: number, paramsJson: string): void;
export declare function getChatAvailableMessageSenders(clientId: number, paramsJson: string): void;
export declare function setChatMessageSender(clientId: number, paramsJson: string): void;

// ==================== 消息操作 ====================
export declare function sendMessage(clientId: number, paramsJson: string): void;
export declare function sendMessageAlbum(clientId: number, paramsJson: string): void;
export declare function sendBotStartMessage(clientId: number, paramsJson: string): void;
export declare function sendInlineQueryResultMessage(clientId: number, paramsJson: string): void;
export declare function forwardMessages(clientId: number, paramsJson: string): void;
export declare function sendQuickReplyShortcutMessages(clientId: number, paramsJson: string): void;
export declare function resendMessages(clientId: number, paramsJson: string): void;
export declare function addLocalMessage(clientId: number, paramsJson: string): void;
export declare function deleteMessages(clientId: number, paramsJson: string): void;
export declare function deleteChatMessagesBySender(clientId: number, paramsJson: string): void;
export declare function deleteChatMessagesByDate(clientId: number, paramsJson: string): void;
export declare function editMessageText(clientId: number, paramsJson: string): void;
export declare function editMessageLiveLocation(clientId: number, paramsJson: string): void;
export declare function editMessageChecklist(clientId: number, paramsJson: string): void;
export declare function editMessageMedia(clientId: number, paramsJson: string): void;
export declare function editMessageCaption(clientId: number, paramsJson: string): void;
export declare function editMessageReplyMarkup(clientId: number, paramsJson: string): void;
export declare function editInlineMessageText(clientId: number, paramsJson: string): void;
export declare function editInlineMessageLiveLocation(clientId: number, paramsJson: string): void;
export declare function editInlineMessageMedia(clientId: number, paramsJson: string): void;
export declare function editInlineMessageCaption(clientId: number, paramsJson: string): void;
export declare function editInlineMessageReplyMarkup(clientId: number, paramsJson: string): void;
export declare function editMessageSchedulingState(clientId: number, paramsJson: string): void;
export declare function setMessageFactCheck(clientId: number, paramsJson: string): void;
export declare function sendBusinessMessage(clientId: number, paramsJson: string): void;
export declare function sendBusinessMessageAlbum(clientId: number, paramsJson: string): void;
export declare function editBusinessMessageText(clientId: number, paramsJson: string): void;
export declare function editBusinessMessageLiveLocation(clientId: number, paramsJson: string): void;
export declare function editBusinessMessageChecklist(clientId: number, paramsJson: string): void;
export declare function editBusinessMessageMedia(clientId: number, paramsJson: string): void;
export declare function editBusinessMessageCaption(clientId: number, paramsJson: string): void;
export declare function editBusinessMessageReplyMarkup(clientId: number, paramsJson: string): void;
export declare function stopBusinessPoll(clientId: number, paramsJson: string): void;
export declare function setBusinessMessageIsPinned(clientId: number, paramsJson: string): void;
export declare function readBusinessMessage(clientId: number, paramsJson: string): void;
export declare function deleteBusinessMessages(clientId: number, paramsJson: string): void;
export declare function editBusinessStory(clientId: number, paramsJson: string): void;
export declare function deleteBusinessStory(clientId: number, paramsJson: string): void;
export declare function setBusinessAccountName(clientId: number, paramsJson: string): void;
export declare function setBusinessAccountBio(clientId: number, paramsJson: string): void;
export declare function setBusinessAccountProfilePhoto(clientId: number, paramsJson: string): void;
export declare function setBusinessAccountUsername(clientId: number, paramsJson: string): void;
export declare function setBusinessAccountGiftSettings(clientId: number, paramsJson: string): void;
export declare function getBusinessAccountStarAmount(clientId: number, paramsJson: string): void;
export declare function transferBusinessAccountStars(clientId: number, paramsJson: string): void;
export declare function checkQuickReplyShortcutName(clientId: number, paramsJson: string): void;
export declare function loadQuickReplyShortcuts(clientId: number, paramsJson: string): void;
export declare function setQuickReplyShortcutName(clientId: number, paramsJson: string): void;
export declare function deleteQuickReplyShortcut(clientId: number, paramsJson: string): void;
export declare function reorderQuickReplyShortcuts(clientId: number, paramsJson: string): void;
export declare function loadQuickReplyShortcutMessages(clientId: number, paramsJson: string): void;
export declare function deleteQuickReplyShortcutMessages(clientId: number, paramsJson: string): void;
export declare function addQuickReplyShortcutMessage(clientId: number, paramsJson: string): void;
export declare function addQuickReplyShortcutInlineQueryResultMessage(clientId: number, paramsJson: string): void;
export declare function addQuickReplyShortcutMessageAlbum(clientId: number, paramsJson: string): void;
export declare function readdQuickReplyShortcutMessages(clientId: number, paramsJson: string): void;
export declare function editQuickReplyMessage(clientId: number, paramsJson: string): void;
export declare function getForumTopicDefaultIcons(clientId: number, paramsJson: string): void;
export declare function createForumTopic(clientId: number, paramsJson: string): void;
export declare function editForumTopic(clientId: number, paramsJson: string): void;
export declare function getForumTopic(clientId: number, paramsJson: string): void;
export declare function getForumTopicHistory(clientId: number, paramsJson: string): void;
export declare function getForumTopicLink(clientId: number, paramsJson: string): void;
export declare function getForumTopics(clientId: number, paramsJson: string): void;
export declare function setForumTopicNotificationSettings(clientId: number, paramsJson: string): void;
export declare function toggleForumTopicIsClosed(clientId: number, paramsJson: string): void;
export declare function toggleGeneralForumTopicIsHidden(clientId: number, paramsJson: string): void;
export declare function toggleForumTopicIsPinned(clientId: number, paramsJson: string): void;
export declare function setPinnedForumTopics(clientId: number, paramsJson: string): void;
export declare function deleteForumTopic(clientId: number, paramsJson: string): void;
export declare function readAllForumTopicMentions(clientId: number, paramsJson: string): void;
export declare function readAllForumTopicReactions(clientId: number, paramsJson: string): void;
export declare function unpinAllForumTopicMessages(clientId: number, paramsJson: string): void;

// ==================== 反应与表情 ====================
export declare function getPasskeyParameters(clientId: number, paramsJson: string): void;
export declare function addLoginPasskey(clientId: number, paramsJson: string): void;
export declare function getLoginPasskeys(clientId: number, paramsJson: string): void;
export declare function removeLoginPasskey(clientId: number, paramsJson: string): void;
export declare function getEmojiReaction(clientId: number, paramsJson: string): void;
export declare function getCustomEmojiReactionAnimations(clientId: number, paramsJson: string): void;
export declare function getMessageAvailableReactions(clientId: number, paramsJson: string): void;
export declare function clearRecentReactions(clientId: number, paramsJson: string): void;
export declare function addMessageReaction(clientId: number, paramsJson: string): void;
export declare function removeMessageReaction(clientId: number, paramsJson: string): void;
export declare function getChatAvailablePaidMessageReactionSenders(clientId: number, paramsJson: string): void;
export declare function addPendingPaidMessageReaction(clientId: number, paramsJson: string): void;
export declare function commitPendingPaidMessageReactions(clientId: number, paramsJson: string): void;
export declare function removePendingPaidMessageReactions(clientId: number, paramsJson: string): void;
export declare function setPaidMessageReactionType(clientId: number, paramsJson: string): void;
export declare function setMessageReactions(clientId: number, paramsJson: string): void;
export declare function getMessageAddedReactions(clientId: number, paramsJson: string): void;
export declare function setDefaultReactionType(clientId: number, paramsJson: string): void;
export declare function getSavedMessagesTags(clientId: number, paramsJson: string): void;
export declare function setSavedMessagesTagLabel(clientId: number, paramsJson: string): void;
export declare function getMessageEffect(clientId: number, paramsJson: string): void;
export declare function searchQuote(clientId: number, paramsJson: string): void;

// ==================== 文本处理 ====================
export declare function getTextEntities(clientId: number, paramsJson: string): void;
export declare function parseTextEntities(clientId: number, paramsJson: string): void;
export declare function parseMarkdown(clientId: number, paramsJson: string): void;
export declare function getMarkdownText(clientId: number, paramsJson: string): void;
export declare function getCountryFlagEmoji(clientId: number, paramsJson: string): void;
export declare function getFileMimeType(clientId: number, paramsJson: string): void;
export declare function getFileExtension(clientId: number, paramsJson: string): void;
export declare function cleanFileName(clientId: number, paramsJson: string): void;
export declare function getLanguagePackString(clientId: number, paramsJson: string): void;
export declare function getJsonValue(clientId: number, paramsJson: string): void;
export declare function getJsonString(clientId: number, paramsJson: string): void;
export declare function getThemeParametersJsonString(clientId: number, paramsJson: string): void;

// ==================== 投票与清单 ====================
export declare function setPollAnswer(clientId: number, paramsJson: string): void;
export declare function getPollVoters(clientId: number, paramsJson: string): void;
export declare function stopPoll(clientId: number, paramsJson: string): void;
export declare function addChecklistTasks(clientId: number, paramsJson: string): void;
export declare function markChecklistTasksAsDone(clientId: number, paramsJson: string): void;

// ==================== 建议操作 ====================
export declare function hideSuggestedAction(clientId: number, paramsJson: string): void;
export declare function hideContactCloseBirthdays(clientId: number, paramsJson: string): void;

// ==================== 业务连接 ====================
export declare function getBusinessConnection(clientId: number, paramsJson: string): void;

// ==================== 登录 URL ====================
export declare function getLoginUrlInfo(clientId: number, paramsJson: string): void;
export declare function getLoginUrl(clientId: number, paramsJson: string): void;
export declare function shareUsersWithBot(clientId: number, paramsJson: string): void;
export declare function shareChatWithBot(clientId: number, paramsJson: string): void;

// ==================== 内联查询 ====================
export declare function getInlineQueryResults(clientId: number, paramsJson: string): void;
export declare function answerInlineQuery(clientId: number, paramsJson: string): void;
export declare function savePreparedInlineMessage(clientId: number, paramsJson: string): void;
export declare function getPreparedInlineMessage(clientId: number, paramsJson: string): void;

// ==================== Web 应用 ====================
export declare function getGrossingWebAppBots(clientId: number, paramsJson: string): void;
export declare function searchWebApp(clientId: number, paramsJson: string): void;
export declare function getWebAppPlaceholder(clientId: number, paramsJson: string): void;
export declare function getWebAppLinkUrl(clientId: number, paramsJson: string): void;
export declare function getMainWebApp(clientId: number, paramsJson: string): void;
export declare function getWebAppUrl(clientId: number, paramsJson: string): void;
export declare function sendWebAppData(clientId: number, paramsJson: string): void;
export declare function openWebApp(clientId: number, paramsJson: string): void;
export declare function closeWebApp(clientId: number, paramsJson: string): void;
export declare function answerWebAppQuery(clientId: number, paramsJson: string): void;
export declare function checkWebAppFileDownload(clientId: number, paramsJson: string): void;

// ==================== 回调查询 ====================
export declare function getCallbackQueryAnswer(clientId: number, paramsJson: string): void;
export declare function answerCallbackQuery(clientId: number, paramsJson: string): void;
export declare function answerShippingQuery(clientId: number, paramsJson: string): void;
export declare function answerPreCheckoutQuery(clientId: number, paramsJson: string): void;

// ==================== 游戏 ====================
export declare function setGameScore(clientId: number, paramsJson: string): void;
export declare function setInlineGameScore(clientId: number, paramsJson: string): void;
export declare function getGameHighScores(clientId: number, paramsJson: string): void;
export declare function getInlineGameHighScores(clientId: number, paramsJson: string): void;

// ==================== 聊天操作 ====================
export declare function deleteChatReplyMarkup(clientId: number, paramsJson: string): void;
export declare function sendChatAction(clientId: number, paramsJson: string): void;
export declare function sendTextMessageDraft(clientId: number, paramsJson: string): void;
export declare function openChat(clientId: number, paramsJson: string): void;
export declare function closeChat(clientId: number, paramsJson: string): void;
export declare function viewMessages(clientId: number, paramsJson: string): void;
export declare function openMessageContent(clientId: number, paramsJson: string): void;
export declare function clickAnimatedEmojiMessage(clientId: number, paramsJson: string): void;
export declare function getInternalLink(clientId: number, paramsJson: string): void;
export declare function getInternalLinkType(clientId: number, paramsJson: string): void;
export declare function getExternalLinkInfo(clientId: number, paramsJson: string): void;
export declare function getExternalLink(clientId: number, paramsJson: string): void;
export declare function readAllChatMentions(clientId: number, paramsJson: string): void;
export declare function readAllChatReactions(clientId: number, paramsJson: string): void;

// ==================== 创建聊天 ====================
export declare function createPrivateChat(clientId: number, paramsJson: string): void;
export declare function createBasicGroupChat(clientId: number, paramsJson: string): void;
export declare function createSupergroupChat(clientId: number, paramsJson: string): void;
export declare function createSecretChat(clientId: number, paramsJson: string): void;
export declare function createNewBasicGroupChat(clientId: number, paramsJson: string): void;
export declare function createNewSupergroupChat(clientId: number, paramsJson: string): void;
export declare function createNewSecretChat(clientId: number, paramsJson: string): void;
export declare function upgradeBasicGroupChatToSupergroupChat(clientId: number, paramsJson: string): void;

// ==================== 聊天列表与文件夹 ====================
export declare function getChatListsToAddChat(clientId: number, paramsJson: string): void;
export declare function addChatToList(clientId: number, paramsJson: string): void;
export declare function getChatFolder(clientId: number, paramsJson: string): void;
export declare function createChatFolder(clientId: number, paramsJson: string): void;
export declare function editChatFolder(clientId: number, paramsJson: string): void;
export declare function deleteChatFolder(clientId: number, paramsJson: string): void;
export declare function getChatFolderChatsToLeave(clientId: number, paramsJson: string): void;
export declare function getChatFolderChatCount(clientId: number, paramsJson: string): void;
export declare function reorderChatFolders(clientId: number, paramsJson: string): void;
export declare function toggleChatFolderTags(clientId: number, paramsJson: string): void;
export declare function getRecommendedChatFolders(clientId: number, paramsJson: string): void;
export declare function getChatFolderDefaultIconName(clientId: number, paramsJson: string): void;
export declare function getChatsForChatFolderInviteLink(clientId: number, paramsJson: string): void;
export declare function createChatFolderInviteLink(clientId: number, paramsJson: string): void;
export declare function getChatFolderInviteLinks(clientId: number, paramsJson: string): void;
export declare function editChatFolderInviteLink(clientId: number, paramsJson: string): void;
export declare function deleteChatFolderInviteLink(clientId: number, paramsJson: string): void;
export declare function checkChatFolderInviteLink(clientId: number, paramsJson: string): void;
export declare function addChatFolderByInviteLink(clientId: number, paramsJson: string): void;
export declare function getChatFolderNewChats(clientId: number, paramsJson: string): void;
export declare function processChatFolderNewChats(clientId: number, paramsJson: string): void;
export declare function getArchiveChatListSettings(clientId: number, paramsJson: string): void;
export declare function setArchiveChatListSettings(clientId: number, paramsJson: string): void;
export declare function setChatTitle(clientId: number, paramsJson: string): void;
export declare function setChatPhoto(clientId: number, paramsJson: string): void;
export declare function setChatAccentColor(clientId: number, paramsJson: string): void;
export declare function setChatProfileAccentColor(clientId: number, paramsJson: string): void;
export declare function setChatMessageAutoDeleteTime(clientId: number, paramsJson: string): void;
export declare function setChatEmojiStatus(clientId: number, paramsJson: string): void;
export declare function setChatPermissions(clientId: number, paramsJson: string): void;
export declare function setChatBackground(clientId: number, paramsJson: string): void;
export declare function deleteChatBackground(clientId: number, paramsJson: string): void;
export declare function getGiftChatThemes(clientId: number, paramsJson: string): void;
export declare function setChatTheme(clientId: number, paramsJson: string): void;
export declare function setChatDraftMessage(clientId: number, paramsJson: string): void;
export declare function setChatNotificationSettings(clientId: number, paramsJson: string): void;
export declare function toggleChatHasProtectedContent(clientId: number, paramsJson: string): void;
export declare function toggleChatViewAsTopics(clientId: number, paramsJson: string): void;
export declare function toggleChatIsTranslatable(clientId: number, paramsJson: string): void;
export declare function toggleChatIsMarkedAsUnread(clientId: number, paramsJson: string): void;
export declare function toggleChatDefaultDisableNotification(clientId: number, paramsJson: string): void;
export declare function setChatAvailableReactions(clientId: number, paramsJson: string): void;
export declare function setChatClientData(clientId: number, paramsJson: string): void;
export declare function setChatDescription(clientId: number, paramsJson: string): void;
export declare function setChatDiscussionGroup(clientId: number, paramsJson: string): void;
export declare function setChatDirectMessagesGroup(clientId: number, paramsJson: string): void;
export declare function setChatLocation(clientId: number, paramsJson: string): void;
export declare function setChatSlowModeDelay(clientId: number, paramsJson: string): void;
export declare function pinChatMessage(clientId: number, paramsJson: string): void;
export declare function unpinChatMessage(clientId: number, paramsJson: string): void;
export declare function unpinAllChatMessages(clientId: number, paramsJson: string): void;
export declare function joinChat(clientId: number, paramsJson: string): void;
export declare function leaveChat(clientId: number, paramsJson: string): void;
export declare function addChatMember(clientId: number, paramsJson: string): void;
export declare function addChatMembers(clientId: number, paramsJson: string): void;
export declare function setChatMemberStatus(clientId: number, paramsJson: string): void;
export declare function banChatMember(clientId: number, paramsJson: string): void;
export declare function canTransferOwnership(clientId: number, paramsJson: string): void;
export declare function transferChatOwnership(clientId: number, paramsJson: string): void;
export declare function getChatOwnerAfterLeaving(clientId: number, paramsJson: string): void;
export declare function getChatMember(clientId: number, paramsJson: string): void;
export declare function searchChatMembers(clientId: number, paramsJson: string): void;
export declare function getChatAdministrators(clientId: number, paramsJson: string): void;
export declare function clearAllDraftMessages(clientId: number, paramsJson: string): void;
export declare function getStakeDiceState(clientId: number, paramsJson: string): void;

// ==================== 通知设置 ====================
export declare function getSavedNotificationSound(clientId: number, paramsJson: string): void;
export declare function getSavedNotificationSounds(clientId: number, paramsJson: string): void;
export declare function addSavedNotificationSound(clientId: number, paramsJson: string): void;
export declare function removeSavedNotificationSound(clientId: number, paramsJson: string): void;
export declare function getChatNotificationSettingsExceptions(clientId: number, paramsJson: string): void;
export declare function getScopeNotificationSettings(clientId: number, paramsJson: string): void;
export declare function setScopeNotificationSettings(clientId: number, paramsJson: string): void;
export declare function setReactionNotificationSettings(clientId: number, paramsJson: string): void;
export declare function resetAllNotificationSettings(clientId: number, paramsJson: string): void;
export declare function toggleChatIsPinned(clientId: number, paramsJson: string): void;
export declare function setPinnedChats(clientId: number, paramsJson: string): void;
export declare function readChatList(clientId: number, paramsJson: string): void;

// ==================== 天气 ====================
export declare function getCurrentWeather(clientId: number, paramsJson: string): void;

// ==================== 故事 ====================
export declare function getStory(clientId: number, paramsJson: string): void;
export declare function getChatsToPostStories(clientId: number, paramsJson: string): void;
export declare function canPostStory(clientId: number, paramsJson: string): void;
export declare function postStory(clientId: number, paramsJson: string): void;
export declare function startLiveStory(clientId: number, paramsJson: string): void;
export declare function editStory(clientId: number, paramsJson: string): void;
export declare function editStoryCover(clientId: number, paramsJson: string): void;
export declare function setStoryPrivacySettings(clientId: number, paramsJson: string): void;
export declare function toggleStoryIsPostedToChatPage(clientId: number, paramsJson: string): void;
export declare function deleteStory(clientId: number, paramsJson: string): void;
export declare function getStoryNotificationSettingsExceptions(clientId: number, paramsJson: string): void;
export declare function loadActiveStories(clientId: number, paramsJson: string): void;
export declare function setChatActiveStoriesList(clientId: number, paramsJson: string): void;
export declare function getChatActiveStories(clientId: number, paramsJson: string): void;
export declare function getChatPostedToChatPageStories(clientId: number, paramsJson: string): void;
export declare function getChatArchivedStories(clientId: number, paramsJson: string): void;
export declare function setChatPinnedStories(clientId: number, paramsJson: string): void;
export declare function openStory(clientId: number, paramsJson: string): void;
export declare function closeStory(clientId: number, paramsJson: string): void;
export declare function getStoryAvailableReactions(clientId: number, paramsJson: string): void;
export declare function setStoryReaction(clientId: number, paramsJson: string): void;
export declare function getStoryInteractions(clientId: number, paramsJson: string): void;
export declare function getChatStoryInteractions(clientId: number, paramsJson: string): void;
export declare function reportStory(clientId: number, paramsJson: string): void;
export declare function activateStoryStealthMode(clientId: number, paramsJson: string): void;
export declare function getStoryPublicForwards(clientId: number, paramsJson: string): void;
export declare function getChatStoryAlbums(clientId: number, paramsJson: string): void;
export declare function getStoryAlbumStories(clientId: number, paramsJson: string): void;
export declare function createStoryAlbum(clientId: number, paramsJson: string): void;
export declare function reorderStoryAlbums(clientId: number, paramsJson: string): void;
export declare function deleteStoryAlbum(clientId: number, paramsJson: string): void;
export declare function setStoryAlbumName(clientId: number, paramsJson: string): void;
export declare function addStoryAlbumStories(clientId: number, paramsJson: string): void;
export declare function removeStoryAlbumStories(clientId: number, paramsJson: string): void;
export declare function reorderStoryAlbumStories(clientId: number, paramsJson: string): void;

// ==================== 提升与增强 ====================
export declare function getChatBoostLevelFeatures(clientId: number, paramsJson: string): void;
export declare function getChatBoostFeatures(clientId: number, paramsJson: string): void;
export declare function getAvailableChatBoostSlots(clientId: number, paramsJson: string): void;
export declare function getChatBoostStatus(clientId: number, paramsJson: string): void;
export declare function boostChat(clientId: number, paramsJson: string): void;
export declare function getChatBoostLink(clientId: number, paramsJson: string): void;
export declare function getChatBoostLinkInfo(clientId: number, paramsJson: string): void;
export declare function getChatBoosts(clientId: number, paramsJson: string): void;
export declare function getUserChatBoosts(clientId: number, paramsJson: string): void;

// ==================== 附件菜单机器人 ====================
export declare function getAttachmentMenuBot(clientId: number, paramsJson: string): void;
export declare function toggleBotIsAddedToAttachmentMenu(clientId: number, paramsJson: string): void;

// ==================== 表情状态 ====================
export declare function getThemedEmojiStatuses(clientId: number, paramsJson: string): void;
export declare function getRecentEmojiStatuses(clientId: number, paramsJson: string): void;
export declare function getUpgradedGiftEmojiStatuses(clientId: number, paramsJson: string): void;
export declare function getDefaultEmojiStatuses(clientId: number, paramsJson: string): void;
export declare function clearRecentEmojiStatuses(clientId: number, paramsJson: string): void;
export declare function getThemedChatEmojiStatuses(clientId: number, paramsJson: string): void;
export declare function getDefaultChatEmojiStatuses(clientId: number, paramsJson: string): void;
export declare function getDisallowedChatEmojiStatuses(clientId: number, paramsJson: string): void;

// ==================== 文件操作 ====================
export declare function getFile(clientId: number, paramsJson: string): void;
export declare function getRemoteFile(clientId: number, paramsJson: string): void;
export declare function readFilePart(clientId: number, paramsJson: string): void;
export declare function getFileDownloadedPrefixSize(clientId: number, paramsJson: string): void;
export declare function downloadFile(clientId: number, paramsJson: string): void;
export declare function cancelDownloadFile(clientId: number, paramsJson: string): void;
export declare function preliminaryUploadFile(clientId: number, paramsJson: string): void;
export declare function cancelPreliminaryUploadFile(clientId: number, paramsJson: string): void;
export declare function writeGeneratedFilePart(clientId: number, paramsJson: string): void;
export declare function setFileGenerationProgress(clientId: number, paramsJson: string): void;
export declare function finishFileGeneration(clientId: number, paramsJson: string): void;
export declare function getSuggestedFileName(clientId: number, paramsJson: string): void;
export declare function deleteFile(clientId: number, paramsJson: string): void;
export declare function addFileToDownloads(clientId: number, paramsJson: string): void;
export declare function toggleDownloadIsPaused(clientId: number, paramsJson: string): void;
export declare function toggleAllDownloadsArePaused(clientId: number, paramsJson: string): void;
export declare function removeFileFromDownloads(clientId: number, paramsJson: string): void;
export declare function removeAllFilesFromDownloads(clientId: number, paramsJson: string): void;
export declare function searchFileDownloads(clientId: number, paramsJson: string): void;
export declare function getAutoDownloadSettingsPresets(clientId: number, paramsJson: string): void;
export declare function setAutoDownloadSettings(clientId: number, paramsJson: string): void;
export declare function uploadStickerFile(clientId: number, paramsJson: string): void;
export declare function getMapThumbnailFile(clientId: number, paramsJson: string): void;
export declare function getApplicationDownloadLink(clientId: number, paramsJson: string): void;

// ==================== 应用验证 ====================
export declare function setApplicationVerificationToken(clientId: number, paramsJson: string): void;
export declare function getMessageFileType(clientId: number, paramsJson: string): void;
export declare function getMessageImportConfirmationText(clientId: number, paramsJson: string): void;
export declare function importMessages(clientId: number, paramsJson: string): void;

// ==================== 邀请链接 ====================
export declare function replacePrimaryChatInviteLink(clientId: number, paramsJson: string): void;
export declare function createChatInviteLink(clientId: number, paramsJson: string): void;
export declare function createChatSubscriptionInviteLink(clientId: number, paramsJson: string): void;
export declare function editChatInviteLink(clientId: number, paramsJson: string): void;
export declare function editChatSubscriptionInviteLink(clientId: number, paramsJson: string): void;
export declare function getChatInviteLink(clientId: number, paramsJson: string): void;
export declare function getChatInviteLinkCounts(clientId: number, paramsJson: string): void;
export declare function getChatInviteLinks(clientId: number, paramsJson: string): void;
export declare function getChatInviteLinkMembers(clientId: number, paramsJson: string): void;
export declare function revokeChatInviteLink(clientId: number, paramsJson: string): void;
export declare function deleteRevokedChatInviteLink(clientId: number, paramsJson: string): void;
export declare function deleteAllRevokedChatInviteLinks(clientId: number, paramsJson: string): void;
export declare function checkChatInviteLink(clientId: number, paramsJson: string): void;
export declare function joinChatByInviteLink(clientId: number, paramsJson: string): void;
export declare function getChatJoinRequests(clientId: number, paramsJson: string): void;
export declare function processChatJoinRequest(clientId: number, paramsJson: string): void;
export declare function processChatJoinRequests(clientId: number, paramsJson: string): void;
export declare function approveSuggestedPost(clientId: number, paramsJson: string): void;
export declare function declineSuggestedPost(clientId: number, paramsJson: string): void;
export declare function addOffer(clientId: number, paramsJson: string): void;

// ==================== 通话与视频聊天 ====================
export declare function createCall(clientId: number, paramsJson: string): void;
export declare function acceptCall(clientId: number, paramsJson: string): void;
export declare function sendCallSignalingData(clientId: number, paramsJson: string): void;
export declare function discardCall(clientId: number, paramsJson: string): void;
export declare function sendCallRating(clientId: number, paramsJson: string): void;
export declare function sendCallDebugInformation(clientId: number, paramsJson: string): void;
export declare function sendCallLog(clientId: number, paramsJson: string): void;
export declare function getVideoChatAvailableParticipants(clientId: number, paramsJson: string): void;
export declare function setVideoChatDefaultParticipant(clientId: number, paramsJson: string): void;
export declare function createVideoChat(clientId: number, paramsJson: string): void;
export declare function createGroupCall(clientId: number, paramsJson: string): void;
export declare function getVideoChatRtmpUrl(clientId: number, paramsJson: string): void;
export declare function replaceVideoChatRtmpUrl(clientId: number, paramsJson: string): void;
export declare function getLiveStoryRtmpUrl(clientId: number, paramsJson: string): void;
export declare function replaceLiveStoryRtmpUrl(clientId: number, paramsJson: string): void;
export declare function getGroupCall(clientId: number, paramsJson: string): void;
export declare function startScheduledVideoChat(clientId: number, paramsJson: string): void;
export declare function toggleVideoChatEnabledStartNotification(clientId: number, paramsJson: string): void;
export declare function joinGroupCall(clientId: number, paramsJson: string): void;
export declare function joinVideoChat(clientId: number, paramsJson: string): void;
export declare function joinLiveStory(clientId: number, paramsJson: string): void;
export declare function startGroupCallScreenSharing(clientId: number, paramsJson: string): void;
export declare function toggleGroupCallScreenSharingIsPaused(clientId: number, paramsJson: string): void;
export declare function endGroupCallScreenSharing(clientId: number, paramsJson: string): void;
export declare function setVideoChatTitle(clientId: number, paramsJson: string): void;
export declare function toggleVideoChatMuteNewParticipants(clientId: number, paramsJson: string): void;
export declare function toggleGroupCallAreMessagesAllowed(clientId: number, paramsJson: string): void;
export declare function getLiveStoryStreamer(clientId: number, paramsJson: string): void;
export declare function getLiveStoryAvailableMessageSenders(clientId: number, paramsJson: string): void;
export declare function setLiveStoryMessageSender(clientId: number, paramsJson: string): void;
export declare function sendGroupCallMessage(clientId: number, paramsJson: string): void;
export declare function addPendingLiveStoryReaction(clientId: number, paramsJson: string): void;
export declare function commitPendingLiveStoryReactions(clientId: number, paramsJson: string): void;
export declare function removePendingLiveStoryReactions(clientId: number, paramsJson: string): void;
export declare function deleteGroupCallMessages(clientId: number, paramsJson: string): void;
export declare function deleteGroupCallMessagesBySender(clientId: number, paramsJson: string): void;
export declare function getLiveStoryTopDonors(clientId: number, paramsJson: string): void;
export declare function inviteGroupCallParticipant(clientId: number, paramsJson: string): void;
export declare function declineGroupCallInvitation(clientId: number, paramsJson: string): void;
export declare function banGroupCallParticipants(clientId: number, paramsJson: string): void;
export declare function inviteVideoChatParticipants(clientId: number, paramsJson: string): void;
export declare function getVideoChatInviteLink(clientId: number, paramsJson: string): void;
export declare function revokeGroupCallInviteLink(clientId: number, paramsJson: string): void;
export declare function startGroupCallRecording(clientId: number, paramsJson: string): void;
export declare function endGroupCallRecording(clientId: number, paramsJson: string): void;
export declare function toggleGroupCallIsMyVideoPaused(clientId: number, paramsJson: string): void;
export declare function toggleGroupCallIsMyVideoEnabled(clientId: number, paramsJson: string): void;
export declare function setGroupCallPaidMessageStarCount(clientId: number, paramsJson: string): void;
export declare function setGroupCallParticipantIsSpeaking(clientId: number, paramsJson: string): void;
export declare function toggleGroupCallParticipantIsMuted(clientId: number, paramsJson: string): void;
export declare function setGroupCallParticipantVolumeLevel(clientId: number, paramsJson: string): void;
export declare function toggleGroupCallParticipantIsHandRaised(clientId: number, paramsJson: string): void;
export declare function getGroupCallParticipants(clientId: number, paramsJson: string): void;
export declare function loadGroupCallParticipants(clientId: number, paramsJson: string): void;
export declare function leaveGroupCall(clientId: number, paramsJson: string): void;
export declare function endGroupCall(clientId: number, paramsJson: string): void;
export declare function getGroupCallStreams(clientId: number, paramsJson: string): void;
export declare function getGroupCallStreamSegment(clientId: number, paramsJson: string): void;
export declare function encryptGroupCallData(clientId: number, paramsJson: string): void;
export declare function decryptGroupCallData(clientId: number, paramsJson: string): void;

// ==================== 封禁与联系人 ====================
export declare function setMessageSenderBlockList(clientId: number, paramsJson: string): void;
export declare function blockMessageSenderFromReplies(clientId: number, paramsJson: string): void;
export declare function getBlockedMessageSenders(clientId: number, paramsJson: string): void;
export declare function addContact(clientId: number, paramsJson: string): void;
export declare function importContacts(clientId: number, paramsJson: string): void;
export declare function getContacts(clientId: number, paramsJson: string): void;
export declare function searchContacts(clientId: number, paramsJson: string): void;
export declare function removeContacts(clientId: number, paramsJson: string): void;
export declare function getImportedContactCount(clientId: number, paramsJson: string): void;
export declare function changeImportedContacts(clientId: number, paramsJson: string): void;
export declare function clearImportedContacts(clientId: number, paramsJson: string): void;
export declare function setCloseFriends(clientId: number, paramsJson: string): void;
export declare function getCloseFriends(clientId: number, paramsJson: string): void;

// ==================== 贴纸与表情 ====================
export declare function getStickerOutline(clientId: number, paramsJson: string): void;
export declare function getStickerOutlineSvgPath(clientId: number, paramsJson: string): void;
export declare function getStickers(clientId: number, paramsJson: string): void;
export declare function getAllStickerEmojis(clientId: number, paramsJson: string): void;
export declare function searchStickers(clientId: number, paramsJson: string): void;
export declare function getGreetingStickers(clientId: number, paramsJson: string): void;
export declare function getPremiumStickers(clientId: number, paramsJson: string): void;
export declare function getInstalledStickerSets(clientId: number, paramsJson: string): void;
export declare function getArchivedStickerSets(clientId: number, paramsJson: string): void;
export declare function getTrendingStickerSets(clientId: number, paramsJson: string): void;
export declare function getAttachedStickerSets(clientId: number, paramsJson: string): void;
export declare function getStickerSet(clientId: number, paramsJson: string): void;
export declare function getStickerSetName(clientId: number, paramsJson: string): void;
export declare function searchStickerSet(clientId: number, paramsJson: string): void;
export declare function searchInstalledStickerSets(clientId: number, paramsJson: string): void;
export declare function searchStickerSets(clientId: number, paramsJson: string): void;
export declare function changeStickerSet(clientId: number, paramsJson: string): void;
export declare function viewTrendingStickerSets(clientId: number, paramsJson: string): void;
export declare function reorderInstalledStickerSets(clientId: number, paramsJson: string): void;
export declare function getRecentStickers(clientId: number, paramsJson: string): void;
export declare function addRecentSticker(clientId: number, paramsJson: string): void;
export declare function removeRecentSticker(clientId: number, paramsJson: string): void;
export declare function clearRecentStickers(clientId: number, paramsJson: string): void;
export declare function getFavoriteStickers(clientId: number, paramsJson: string): void;
export declare function addFavoriteSticker(clientId: number, paramsJson: string): void;
export declare function removeFavoriteSticker(clientId: number, paramsJson: string): void;
export declare function getStickerEmojis(clientId: number, paramsJson: string): void;
export declare function searchEmojis(clientId: number, paramsJson: string): void;
export declare function getKeywordEmojis(clientId: number, paramsJson: string): void;
export declare function getEmojiCategories(clientId: number, paramsJson: string): void;
export declare function getAnimatedEmoji(clientId: number, paramsJson: string): void;
export declare function getEmojiSuggestionsUrl(clientId: number, paramsJson: string): void;
export declare function getCustomEmojiStickers(clientId: number, paramsJson: string): void;
export declare function getDefaultChatPhotoCustomEmojiStickers(clientId: number, paramsJson: string): void;
export declare function getDefaultProfilePhotoCustomEmojiStickers(clientId: number, paramsJson: string): void;
export declare function getDefaultBackgroundCustomEmojiStickers(clientId: number, paramsJson: string): void;
export declare function getSavedAnimations(clientId: number, paramsJson: string): void;
export declare function addSavedAnimation(clientId: number, paramsJson: string): void;
export declare function removeSavedAnimation(clientId: number, paramsJson: string): void;
export declare function getRecentInlineBots(clientId: number, paramsJson: string): void;
export declare function getOwnedBots(clientId: number, paramsJson: string): void;
export declare function searchHashtags(clientId: number, paramsJson: string): void;
export declare function removeRecentHashtag(clientId: number, paramsJson: string): void;
export declare function getLinkPreview(clientId: number, paramsJson: string): void;
export declare function getWebPageInstantView(clientId: number, paramsJson: string): void;

// ==================== 机器人命令与菜单 ====================
export declare function setCommands(clientId: number, paramsJson: string): void;
export declare function deleteCommands(clientId: number, paramsJson: string): void;
export declare function getCommands(clientId: number, paramsJson: string): void;
export declare function setMenuButton(clientId: number, paramsJson: string): void;
export declare function getMenuButton(clientId: number, paramsJson: string): void;
export declare function setDefaultGroupAdministratorRights(clientId: number, paramsJson: string): void;
export declare function setDefaultChannelAdministratorRights(clientId: number, paramsJson: string): void;
export declare function canBotSendMessages(clientId: number, paramsJson: string): void;
export declare function allowBotToSendMessages(clientId: number, paramsJson: string): void;
export declare function sendWebAppCustomRequest(clientId: number, paramsJson: string): void;
export declare function getBotMediaPreviews(clientId: number, paramsJson: string): void;
export declare function getBotMediaPreviewInfo(clientId: number, paramsJson: string): void;
export declare function addBotMediaPreview(clientId: number, paramsJson: string): void;
export declare function editBotMediaPreview(clientId: number, paramsJson: string): void;
export declare function reorderBotMediaPreviews(clientId: number, paramsJson: string): void;
export declare function deleteBotMediaPreviews(clientId: number, paramsJson: string): void;
export declare function setBotName(clientId: number, paramsJson: string): void;
export declare function getBotName(clientId: number, paramsJson: string): void;
export declare function setBotProfilePhoto(clientId: number, paramsJson: string): void;
export declare function toggleBotUsernameIsActive(clientId: number, paramsJson: string): void;
export declare function reorderBotActiveUsernames(clientId: number, paramsJson: string): void;
export declare function setBotInfoDescription(clientId: number, paramsJson: string): void;
export declare function getBotInfoDescription(clientId: number, paramsJson: string): void;
export declare function setBotInfoShortDescription(clientId: number, paramsJson: string): void;
export declare function getBotInfoShortDescription(clientId: number, paramsJson: string): void;
export declare function setMessageSenderBotVerification(clientId: number, paramsJson: string): void;
export declare function removeMessageSenderBotVerification(clientId: number, paramsJson: string): void;

// ==================== 会话与网站 ====================
export declare function getActiveSessions(clientId: number, paramsJson: string): void;
export declare function terminateSession(clientId: number, paramsJson: string): void;
export declare function terminateAllOtherSessions(clientId: number, paramsJson: string): void;
export declare function confirmSession(clientId: number, paramsJson: string): void;
export declare function toggleSessionCanAcceptCalls(clientId: number, paramsJson: string): void;
export declare function toggleSessionCanAcceptSecretChats(clientId: number, paramsJson: string): void;
export declare function setInactiveSessionTtl(clientId: number, paramsJson: string): void;
export declare function getConnectedWebsites(clientId: number, paramsJson: string): void;
export declare function disconnectWebsite(clientId: number, paramsJson: string): void;
export declare function disconnectAllWebsites(clientId: number, paramsJson: string): void;

// ==================== 超级群组管理 ====================
export declare function setSupergroupUsername(clientId: number, paramsJson: string): void;
export declare function toggleSupergroupUsernameIsActive(clientId: number, paramsJson: string): void;
export declare function disableAllSupergroupUsernames(clientId: number, paramsJson: string): void;
export declare function reorderSupergroupActiveUsernames(clientId: number, paramsJson: string): void;
export declare function setSupergroupStickerSet(clientId: number, paramsJson: string): void;
export declare function setSupergroupCustomEmojiStickerSet(clientId: number, paramsJson: string): void;
export declare function setSupergroupUnrestrictBoostCount(clientId: number, paramsJson: string): void;
export declare function setSupergroupMainProfileTab(clientId: number, paramsJson: string): void;
export declare function toggleSupergroupSignMessages(clientId: number, paramsJson: string): void;
export declare function toggleSupergroupJoinToSendMessages(clientId: number, paramsJson: string): void;
export declare function toggleSupergroupJoinByRequest(clientId: number, paramsJson: string): void;
export declare function toggleSupergroupIsAllHistoryAvailable(clientId: number, paramsJson: string): void;
export declare function toggleSupergroupCanHaveSponsoredMessages(clientId: number, paramsJson: string): void;
export declare function toggleSupergroupHasAutomaticTranslation(clientId: number, paramsJson: string): void;
export declare function toggleSupergroupHasHiddenMembers(clientId: number, paramsJson: string): void;
export declare function toggleSupergroupHasAggressiveAntiSpamEnabled(clientId: number, paramsJson: string): void;
export declare function toggleSupergroupIsForum(clientId: number, paramsJson: string): void;
export declare function toggleSupergroupIsBroadcastGroup(clientId: number, paramsJson: string): void;
export declare function reportSupergroupSpam(clientId: number, paramsJson: string): void;
export declare function reportSupergroupAntiSpamFalsePositive(clientId: number, paramsJson: string): void;
export declare function getSupergroupMembers(clientId: number, paramsJson: string): void;
export declare function closeSecretChat(clientId: number, paramsJson: string): void;
export declare function getChatEventLog(clientId: number, paramsJson: string): void;

// ==================== 时区 ====================
export declare function getTimeZones(clientId: number, paramsJson: string): void;

// ==================== 支付与星币 ====================
export declare function getPaymentForm(clientId: number, paramsJson: string): void;
export declare function validateOrderInfo(clientId: number, paramsJson: string): void;
export declare function sendPaymentForm(clientId: number, paramsJson: string): void;
export declare function getPaymentReceipt(clientId: number, paramsJson: string): void;
export declare function getSavedOrderInfo(clientId: number, paramsJson: string): void;
export declare function deleteSavedOrderInfo(clientId: number, paramsJson: string): void;
export declare function deleteSavedCredentials(clientId: number, paramsJson: string): void;
export declare function setGiftSettings(clientId: number, paramsJson: string): void;
export declare function getAvailableGifts(clientId: number, paramsJson: string): void;
export declare function canSendGift(clientId: number, paramsJson: string): void;
export declare function sendGift(clientId: number, paramsJson: string): void;
export declare function getGiftAuctionState(clientId: number, paramsJson: string): void;
export declare function getGiftAuctionAcquiredGifts(clientId: number, paramsJson: string): void;
export declare function openGiftAuction(clientId: number, paramsJson: string): void;
export declare function closeGiftAuction(clientId: number, paramsJson: string): void;
export declare function placeGiftAuctionBid(clientId: number, paramsJson: string): void;
export declare function increaseGiftAuctionBid(clientId: number, paramsJson: string): void;
export declare function sellGift(clientId: number, paramsJson: string): void;
export declare function toggleGiftIsSaved(clientId: number, paramsJson: string): void;
export declare function setPinnedGifts(clientId: number, paramsJson: string): void;
export declare function toggleChatGiftNotifications(clientId: number, paramsJson: string): void;
export declare function getGiftUpgradePreview(clientId: number, paramsJson: string): void;
export declare function getUpgradedGiftVariants(clientId: number, paramsJson: string): void;
export declare function upgradeGift(clientId: number, paramsJson: string): void;
export declare function buyGiftUpgrade(clientId: number, paramsJson: string): void;
export declare function craftGift(clientId: number, paramsJson: string): void;
export declare function transferGift(clientId: number, paramsJson: string): void;
export declare function dropGiftOriginalDetails(clientId: number, paramsJson: string): void;
export declare function sendResoldGift(clientId: number, paramsJson: string): void;
export declare function sendGiftPurchaseOffer(clientId: number, paramsJson: string): void;
export declare function processGiftPurchaseOffer(clientId: number, paramsJson: string): void;
export declare function getReceivedGifts(clientId: number, paramsJson: string): void;
export declare function getReceivedGift(clientId: number, paramsJson: string): void;
export declare function getGiftsForCrafting(clientId: number, paramsJson: string): void;
export declare function getUpgradedGift(clientId: number, paramsJson: string): void;
export declare function getUpgradedGiftValueInfo(clientId: number, paramsJson: string): void;
export declare function getUpgradedGiftWithdrawalUrl(clientId: number, paramsJson: string): void;
export declare function getUpgradedGiftsPromotionalAnimation(clientId: number, paramsJson: string): void;
export declare function setGiftResalePrice(clientId: number, paramsJson: string): void;
export declare function searchGiftsForResale(clientId: number, paramsJson: string): void;
export declare function getGiftCollections(clientId: number, paramsJson: string): void;
export declare function createGiftCollection(clientId: number, paramsJson: string): void;
export declare function reorderGiftCollections(clientId: number, paramsJson: string): void;
export declare function deleteGiftCollection(clientId: number, paramsJson: string): void;
export declare function setGiftCollectionName(clientId: number, paramsJson: string): void;
export declare function addGiftCollectionGifts(clientId: number, paramsJson: string): void;
export declare function removeGiftCollectionGifts(clientId: number, paramsJson: string): void;
export declare function reorderGiftCollectionGifts(clientId: number, paramsJson: string): void;
export declare function createInvoiceLink(clientId: number, paramsJson: string): void;
export declare function refundStarPayment(clientId: number, paramsJson: string): void;
export declare function getSupportUser(clientId: number, paramsJson: string): void;

// ==================== 背景 ====================
export declare function getBackgroundUrl(clientId: number, paramsJson: string): void;
export declare function searchBackground(clientId: number, paramsJson: string): void;
export declare function setDefaultBackground(clientId: number, paramsJson: string): void;
export declare function deleteDefaultBackground(clientId: number, paramsJson: string): void;
export declare function getInstalledBackgrounds(clientId: number, paramsJson: string): void;
export declare function removeInstalledBackground(clientId: number, paramsJson: string): void;
export declare function resetInstalledBackgrounds(clientId: number, paramsJson: string): void;

// ==================== 本地化 ====================
export declare function getLocalizationTargetInfo(clientId: number, paramsJson: string): void;
export declare function getLanguagePackInfo(clientId: number, paramsJson: string): void;
export declare function getLanguagePackStrings(clientId: number, paramsJson: string): void;
export declare function synchronizeLanguagePack(clientId: number, paramsJson: string): void;
export declare function addCustomServerLanguagePack(clientId: number, paramsJson: string): void;
export declare function setCustomLanguagePack(clientId: number, paramsJson: string): void;
export declare function editCustomLanguagePackInfo(clientId: number, paramsJson: string): void;
export declare function setCustomLanguagePackString(clientId: number, paramsJson: string): void;
export declare function deleteLanguagePack(clientId: number, paramsJson: string): void;

// ==================== 推送通知 ====================
export declare function registerDevice(clientId: number, paramsJson: string): void;
export declare function processPushNotification(clientId: number, paramsJson: string): void;
export declare function getPushReceiverId(clientId: number, paramsJson: string): void;
export declare function getRecentlyVisitedTMeUrls(clientId: number, paramsJson: string): void;

// ==================== 隐私设置 ====================
export declare function setUserPrivacySettingRules(clientId: number, paramsJson: string): void;
export declare function getUserPrivacySettingRules(clientId: number, paramsJson: string): void;
export declare function setReadDatePrivacySettings(clientId: number, paramsJson: string): void;
export declare function getReadDatePrivacySettings(clientId: number, paramsJson: string): void;
export declare function setNewChatPrivacySettings(clientId: number, paramsJson: string): void;
export declare function getNewChatPrivacySettings(clientId: number, paramsJson: string): void;

// ==================== 付费消息与收入 ====================
export declare function getPaidMessageRevenue(clientId: number, paramsJson: string): void;
export declare function allowUnpaidMessagesFromUser(clientId: number, paramsJson: string): void;
export declare function setChatPaidMessageStarCount(clientId: number, paramsJson: string): void;
export declare function canSendMessageToUser(clientId: number, paramsJson: string): void;
export declare function getOption(clientId: number, paramsJson: string): void;
export declare function setOption(clientId: number, paramsJson: string): void;
export declare function setAccountTtl(clientId: number, paramsJson: string): void;
export declare function getAccountTtl(clientId: number, paramsJson: string): void;
export declare function deleteAccount(clientId: number, paramsJson: string): void;
export declare function setDefaultMessageAutoDeleteTime(clientId: number, paramsJson: string): void;
export declare function getDefaultMessageAutoDeleteTime(clientId: number, paramsJson: string): void;
export declare function removeChatActionBar(clientId: number, paramsJson: string): void;
export declare function reportChat(clientId: number, paramsJson: string): void;
export declare function reportChatPhoto(clientId: number, paramsJson: string): void;
export declare function reportMessageReactions(clientId: number, paramsJson: string): void;
export declare function getChatRevenueStatistics(clientId: number, paramsJson: string): void;
export declare function getChatRevenueWithdrawalUrl(clientId: number, paramsJson: string): void;
export declare function getChatRevenueTransactions(clientId: number, paramsJson: string): void;
export declare function getTonTransactions(clientId: number, paramsJson: string): void;
export declare function getStarRevenueStatistics(clientId: number, paramsJson: string): void;
export declare function getStarWithdrawalUrl(clientId: number, paramsJson: string): void;
export declare function getStarAdAccountUrl(clientId: number, paramsJson: string): void;
export declare function getTonRevenueStatistics(clientId: number, paramsJson: string): void;
export declare function getTonWithdrawalUrl(clientId: number, paramsJson: string): void;
export declare function getChatStatistics(clientId: number, paramsJson: string): void;
export declare function getMessageStatistics(clientId: number, paramsJson: string): void;
export declare function getMessagePublicForwards(clientId: number, paramsJson: string): void;
export declare function getStoryStatistics(clientId: number, paramsJson: string): void;
export declare function getStatisticalGraph(clientId: number, paramsJson: string): void;
export declare function getStorageStatistics(clientId: number, paramsJson: string): void;
export declare function getStorageStatisticsFast(clientId: number, paramsJson: string): void;
export declare function getDatabaseStatistics(clientId: number, paramsJson: string): void;
export declare function optimizeStorage(clientId: number, paramsJson: string): void;
export declare function setNetworkType(clientId: number, paramsJson: string): void;
export declare function getNetworkStatistics(clientId: number, paramsJson: string): void;
export declare function addNetworkStatistics(clientId: number, paramsJson: string): void;
export declare function resetNetworkStatistics(clientId: number, paramsJson: string): void;
export declare function getAutosaveSettings(clientId: number, paramsJson: string): void;
export declare function setAutosaveSettings(clientId: number, paramsJson: string): void;
export declare function clearAutosaveSettingsExceptions(clientId: number, paramsJson: string): void;
export declare function getBankCardInfo(clientId: number, paramsJson: string): void;

// ==================== 证件信息 ====================
export declare function getPassportElement(clientId: number, paramsJson: string): void;
export declare function getAllPassportElements(clientId: number, paramsJson: string): void;
export declare function setPassportElement(clientId: number, paramsJson: string): void;
export declare function deletePassportElement(clientId: number, paramsJson: string): void;
export declare function setPassportElementErrors(clientId: number, paramsJson: string): void;
export declare function getPreferredCountryLanguage(clientId: number, paramsJson: string): void;
export declare function sendEmailAddressVerificationCode(clientId: number, paramsJson: string): void;
export declare function resendEmailAddressVerificationCode(clientId: number, paramsJson: string): void;
export declare function checkEmailAddressVerificationCode(clientId: number, paramsJson: string): void;
export declare function getPassportAuthorizationForm(clientId: number, paramsJson: string): void;
export declare function getPassportAuthorizationFormAvailableElements(clientId: number, paramsJson: string): void;
export declare function sendPassportAuthorizationForm(clientId: number, paramsJson: string): void;

// ==================== 机器人更新 ====================
export declare function setBotUpdatesStatus(clientId: number, paramsJson: string): void;

// ==================== 贴纸集管理 ====================
export declare function createNewStickerSet(clientId: number, paramsJson: string): void;
export declare function addStickerToSet(clientId: number, paramsJson: string): void;
export declare function replaceStickerInSet(clientId: number, paramsJson: string): void;
export declare function setStickerSetThumbnail(clientId: number, paramsJson: string): void;
export declare function setCustomEmojiStickerSetThumbnail(clientId: number, paramsJson: string): void;
export declare function setStickerSetTitle(clientId: number, paramsJson: string): void;
export declare function deleteStickerSet(clientId: number, paramsJson: string): void;
export declare function setStickerPositionInSet(clientId: number, paramsJson: string): void;
export declare function removeStickerFromSet(clientId: number, paramsJson: string): void;
export declare function setStickerEmojis(clientId: number, paramsJson: string): void;
export declare function setStickerKeywords(clientId: number, paramsJson: string): void;
export declare function setStickerMaskPosition(clientId: number, paramsJson: string): void;
export declare function getOwnedStickerSets(clientId: number, paramsJson: string): void;
export declare function getPremiumLimit(clientId: number, paramsJson: string): void;
export declare function getPremiumFeatures(clientId: number, paramsJson: string): void;
export declare function getPremiumStickerExamples(clientId: number, paramsJson: string): void;
export declare function getPremiumInfoSticker(clientId: number, paramsJson: string): void;
export declare function viewPremiumFeature(clientId: number, paramsJson: string): void;
export declare function clickPremiumSubscriptionButton(clientId: number, paramsJson: string): void;
export declare function getPremiumState(clientId: number, paramsJson: string): void;
export declare function getPremiumGiftPaymentOptions(clientId: number, paramsJson: string): void;
export declare function getPremiumGiveawayPaymentOptions(clientId: number, paramsJson: string): void;
export declare function checkPremiumGiftCode(clientId: number, paramsJson: string): void;
export declare function applyPremiumGiftCode(clientId: number, paramsJson: string): void;
export declare function giftPremiumWithStars(clientId: number, paramsJson: string): void;
export declare function launchPrepaidGiveaway(clientId: number, paramsJson: string): void;
export declare function getGiveawayInfo(clientId: number, paramsJson: string): void;
export declare function getStarPaymentOptions(clientId: number, paramsJson: string): void;
export declare function getStarGiftPaymentOptions(clientId: number, paramsJson: string): void;
export declare function getStarGiveawayPaymentOptions(clientId: number, paramsJson: string): void;
export declare function getStarTransactions(clientId: number, paramsJson: string): void;
export declare function getStarSubscriptions(clientId: number, paramsJson: string): void;
export declare function canPurchaseFromStore(clientId: number, paramsJson: string): void;
export declare function assignStoreTransaction(clientId: number, paramsJson: string): void;
export declare function editStarSubscription(clientId: number, paramsJson: string): void;
export declare function editUserStarSubscription(clientId: number, paramsJson: string): void;
export declare function reuseStarSubscription(clientId: number, paramsJson: string): void;

// ==================== 联盟计划 ====================
export declare function setChatAffiliateProgram(clientId: number, paramsJson: string): void;
export declare function searchChatAffiliateProgram(clientId: number, paramsJson: string): void;
export declare function searchAffiliatePrograms(clientId: number, paramsJson: string): void;
export declare function connectAffiliateProgram(clientId: number, paramsJson: string): void;
export declare function disconnectAffiliateProgram(clientId: number, paramsJson: string): void;
export declare function getConnectedAffiliateProgram(clientId: number, paramsJson: string): void;
export declare function getConnectedAffiliatePrograms(clientId: number, paramsJson: string): void;
export declare function getBusinessFeatures(clientId: number, paramsJson: string): void;

// ==================== 服务条款 ====================
export declare function acceptTermsOfService(clientId: number, paramsJson: string): void;
export declare function searchStringsByPrefix(clientId: number, paramsJson: string): void;
export declare function sendCustomRequest(clientId: number, paramsJson: string): void;
export declare function answerCustomQuery(clientId: number, paramsJson: string): void;
export declare function setAlarm(clientId: number, paramsJson: string): void;
export declare function getCountries(clientId: number, paramsJson: string): void;
export declare function getCountryCode(clientId: number, paramsJson: string): void;
export declare function getPhoneNumberInfo(clientId: number, paramsJson: string): void;
export declare function getPhoneNumberInfoSync(clientId: number, paramsJson: string): void;
export declare function getCollectibleItemInfo(clientId: number, paramsJson: string): void;
export declare function getDeepLinkInfo(clientId: number, paramsJson: string): void;
export declare function getApplicationConfig(clientId: number, paramsJson: string): void;
export declare function saveApplicationLogEvent(clientId: number, paramsJson: string): void;

// ==================== 代理 ====================
export declare function addProxy(clientId: number, paramsJson: string): void;
export declare function editProxy(clientId: number, paramsJson: string): void;
export declare function enableProxy(clientId: number, paramsJson: string): void;
export declare function disableProxy(clientId: number, paramsJson: string): void;
export declare function removeProxy(clientId: number, paramsJson: string): void;
export declare function getProxies(clientId: number, paramsJson: string): void;
export declare function pingProxy(clientId: number, paramsJson: string): void;

// ==================== 日志 ====================
export declare function setLogStream(clientId: number, paramsJson: string): void;
export declare function getLogStream(clientId: number, paramsJson: string): void;
export declare function setLogVerbosityLevel(clientId: number, paramsJson: string): void;
export declare function getLogVerbosityLevel(clientId: number, paramsJson: string): void;
export declare function getLogTags(clientId: number, paramsJson: string): void;
export declare function setLogTagVerbosityLevel(clientId: number, paramsJson: string): void;
export declare function getLogTagVerbosityLevel(clientId: number, paramsJson: string): void;
export declare function addLogMessage(clientId: number, paramsJson: string): void;

// ==================== 支持 ====================
export declare function getUserSupportInfo(clientId: number, paramsJson: string): void;
export declare function setUserSupportInfo(clientId: number, paramsJson: string): void;
export declare function getSupportName(clientId: number, paramsJson: string): void;

// ==================== 测试方法 ====================
export declare function testCallEmpty(clientId: number, paramsJson: string): void;
export declare function testCallString(clientId: number, paramsJson: string): void;
export declare function testCallBytes(clientId: number, paramsJson: string): void;
export declare function testCallVectorInt(clientId: number, paramsJson: string): void;
export declare function testCallVectorIntObject(clientId: number, paramsJson: string): void;
export declare function testCallVectorString(clientId: number, paramsJson: string): void;
export declare function testCallVectorStringObject(clientId: number, paramsJson: string): void;
export declare function testSquareInt(clientId: number, paramsJson: string): void;
export declare function testNetwork(clientId: number, paramsJson: string): void;
export declare function testProxy(clientId: number, paramsJson: string): void;
export declare function testGetDifference(clientId: number, paramsJson: string): void;
export declare function testUseUpdate(clientId: number, paramsJson: string): void;
export declare function testReturnError(clientId: number, paramsJson: string): void;

/** 销毁指定客户端 */
export declare function tdlibDestroyClient(clientId: number): void;