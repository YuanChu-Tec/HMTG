/**
 * TDLib API 完整封装（所有方法）
 * 每个函数：接收 (clientId, paramsJson: string) → 调用 tdlib::sendRequest
 */
#pragma once

#include <string>

namespace tdlib {
namespace api {

// ==================== 认证与授权 ====================
void getAuthorizationState(int clientId, const std::string& paramsJson);
void setTdlibParameters(int clientId, const std::string& paramsJson);
void setAuthenticationPhoneNumber(int clientId, const std::string& paramsJson);
void checkAuthenticationPremiumPurchase(int clientId, const std::string& paramsJson);
void setAuthenticationPremiumPurchaseTransaction(int clientId, const std::string& paramsJson);
void setAuthenticationEmailAddress(int clientId, const std::string& paramsJson);
void resendAuthenticationCode(int clientId, const std::string& paramsJson);
void checkAuthenticationEmailCode(int clientId, const std::string& paramsJson);
void checkAuthenticationCode(int clientId, const std::string& paramsJson);
void requestQrCodeAuthentication(int clientId, const std::string& paramsJson);
void getAuthenticationPasskeyParameters(int clientId, const std::string& paramsJson);
void checkAuthenticationPasskey(int clientId, const std::string& paramsJson);
void registerUser(int clientId, const std::string& paramsJson);
void resetAuthenticationEmailAddress(int clientId, const std::string& paramsJson);
void checkAuthenticationPassword(int clientId, const std::string& paramsJson);
void requestAuthenticationPasswordRecovery(int clientId, const std::string& paramsJson);
void checkAuthenticationPasswordRecoveryCode(int clientId, const std::string& paramsJson);
void recoverAuthenticationPassword(int clientId, const std::string& paramsJson);
void sendAuthenticationFirebaseSms(int clientId, const std::string& paramsJson);
void reportAuthenticationCodeMissing(int clientId, const std::string& paramsJson);
void checkAuthenticationBotToken(int clientId, const std::string& paramsJson);
void logOut(int clientId, const std::string& paramsJson);
void close(int clientId, const std::string& paramsJson);
void destroy(int clientId, const std::string& paramsJson);
void confirmQrCodeAuthentication(int clientId, const std::string& paramsJson);
void getCurrentState(int clientId, const std::string& paramsJson);
void setDatabaseEncryptionKey(int clientId, const std::string& paramsJson);
void getPasswordState(int clientId, const std::string& paramsJson);
void setPassword(int clientId, const std::string& paramsJson);
void isLoginEmailAddressRequired(int clientId, const std::string& paramsJson);
void setLoginEmailAddress(int clientId, const std::string& paramsJson);
void resendLoginEmailAddressCode(int clientId, const std::string& paramsJson);
void checkLoginEmailAddressCode(int clientId, const std::string& paramsJson);
void getRecoveryEmailAddress(int clientId, const std::string& paramsJson);
void setRecoveryEmailAddress(int clientId, const std::string& paramsJson);
void checkRecoveryEmailAddressCode(int clientId, const std::string& paramsJson);
void resendRecoveryEmailAddressCode(int clientId, const std::string& paramsJson);
void cancelRecoveryEmailAddressVerification(int clientId, const std::string& paramsJson);
void requestPasswordRecovery(int clientId, const std::string& paramsJson);
void checkPasswordRecoveryCode(int clientId, const std::string& paramsJson);
void recoverPassword(int clientId, const std::string& paramsJson);
void resetPassword(int clientId, const std::string& paramsJson);
void cancelPasswordReset(int clientId, const std::string& paramsJson);
void createTemporaryPassword(int clientId, const std::string& paramsJson);
void getTemporaryPasswordState(int clientId, const std::string& paramsJson);

// ==================== 用户与个人资料 ====================
void getMe(int clientId, const std::string& paramsJson);
void getUser(int clientId, const std::string& paramsJson);
void getUserFullInfo(int clientId, const std::string& paramsJson);
void getBasicGroup(int clientId, const std::string& paramsJson);
void getBasicGroupFullInfo(int clientId, const std::string& paramsJson);
void getSupergroup(int clientId, const std::string& paramsJson);
void getSupergroupFullInfo(int clientId, const std::string& paramsJson);
void getSecretChat(int clientId, const std::string& paramsJson);
void getUserProfilePhotos(int clientId, const std::string& paramsJson);
void getUserProfileAudios(int clientId, const std::string& paramsJson);
void isProfileAudio(int clientId, const std::string& paramsJson);
void addProfileAudio(int clientId, const std::string& paramsJson);
void setProfileAudioPosition(int clientId, const std::string& paramsJson);
void removeProfileAudio(int clientId, const std::string& paramsJson);
void setUserPersonalProfilePhoto(int clientId, const std::string& paramsJson);
void setUserNote(int clientId, const std::string& paramsJson);
void suggestUserProfilePhoto(int clientId, const std::string& paramsJson);
void suggestUserBirthdate(int clientId, const std::string& paramsJson);
void toggleBotCanManageEmojiStatus(int clientId, const std::string& paramsJson);
void setUserEmojiStatus(int clientId, const std::string& paramsJson);
void searchUserByPhoneNumber(int clientId, const std::string& paramsJson);
void sharePhoneNumber(int clientId, const std::string& paramsJson);
void setProfilePhoto(int clientId, const std::string& paramsJson);
void deleteProfilePhoto(int clientId, const std::string& paramsJson);
void setAccentColor(int clientId, const std::string& paramsJson);
void setUpgradedGiftColors(int clientId, const std::string& paramsJson);
void setProfileAccentColor(int clientId, const std::string& paramsJson);
void setName(int clientId, const std::string& paramsJson);
void setBio(int clientId, const std::string& paramsJson);
void setUsername(int clientId, const std::string& paramsJson);
void toggleUsernameIsActive(int clientId, const std::string& paramsJson);
void reorderActiveUsernames(int clientId, const std::string& paramsJson);
void setBirthdate(int clientId, const std::string& paramsJson);
void setMainProfileTab(int clientId, const std::string& paramsJson);
void setPersonalChat(int clientId, const std::string& paramsJson);
void setEmojiStatus(int clientId, const std::string& paramsJson);
void toggleHasSponsoredMessagesEnabled(int clientId, const std::string& paramsJson);
void setBusinessLocation(int clientId, const std::string& paramsJson);
void setBusinessOpeningHours(int clientId, const std::string& paramsJson);
void setBusinessGreetingMessageSettings(int clientId, const std::string& paramsJson);
void setBusinessAwayMessageSettings(int clientId, const std::string& paramsJson);
void setBusinessStartPage(int clientId, const std::string& paramsJson);
void getBusinessConnectedBot(int clientId, const std::string& paramsJson);
void setBusinessConnectedBot(int clientId, const std::string& paramsJson);
void deleteBusinessConnectedBot(int clientId, const std::string& paramsJson);
void toggleBusinessConnectedBotChatIsPaused(int clientId, const std::string& paramsJson);
void removeBusinessConnectedBotFromChat(int clientId, const std::string& paramsJson);
void getBusinessChatLinks(int clientId, const std::string& paramsJson);
void createBusinessChatLink(int clientId, const std::string& paramsJson);
void editBusinessChatLink(int clientId, const std::string& paramsJson);
void deleteBusinessChatLink(int clientId, const std::string& paramsJson);
void getBusinessChatLinkInfo(int clientId, const std::string& paramsJson);
void getUserLink(int clientId, const std::string& paramsJson);
void searchUserByToken(int clientId, const std::string& paramsJson);

// ==================== 聊天管理 ====================
void getChat(int clientId, const std::string& paramsJson);
void getMessage(int clientId, const std::string& paramsJson);
void getMessageLocally(int clientId, const std::string& paramsJson);
void getRepliedMessage(int clientId, const std::string& paramsJson);
void getChatPinnedMessage(int clientId, const std::string& paramsJson);
void getCallbackQueryMessage(int clientId, const std::string& paramsJson);
void getMessages(int clientId, const std::string& paramsJson);
void getMessageProperties(int clientId, const std::string& paramsJson);
void getMessageThread(int clientId, const std::string& paramsJson);
void getMessageReadDate(int clientId, const std::string& paramsJson);
void getMessageViewers(int clientId, const std::string& paramsJson);
void getMessageAuthor(int clientId, const std::string& paramsJson);
void loadChats(int clientId, const std::string& paramsJson);
void getChats(int clientId, const std::string& paramsJson);
void searchPublicChat(int clientId, const std::string& paramsJson);
void searchPublicChats(int clientId, const std::string& paramsJson);
void searchChats(int clientId, const std::string& paramsJson);
void searchChatsOnServer(int clientId, const std::string& paramsJson);
void getRecommendedChats(int clientId, const std::string& paramsJson);
void getChatSimilarChats(int clientId, const std::string& paramsJson);
void getChatSimilarChatCount(int clientId, const std::string& paramsJson);
void openChatSimilarChat(int clientId, const std::string& paramsJson);
void getBotSimilarBots(int clientId, const std::string& paramsJson);
void getBotSimilarBotCount(int clientId, const std::string& paramsJson);
void openBotSimilarBot(int clientId, const std::string& paramsJson);
void getTopChats(int clientId, const std::string& paramsJson);
void removeTopChat(int clientId, const std::string& paramsJson);
void searchRecentlyFoundChats(int clientId, const std::string& paramsJson);
void addRecentlyFoundChat(int clientId, const std::string& paramsJson);
void removeRecentlyFoundChat(int clientId, const std::string& paramsJson);
void clearRecentlyFoundChats(int clientId, const std::string& paramsJson);
void getRecentlyOpenedChats(int clientId, const std::string& paramsJson);
void checkChatUsername(int clientId, const std::string& paramsJson);
void getCreatedPublicChats(int clientId, const std::string& paramsJson);
void checkCreatedPublicChatsLimit(int clientId, const std::string& paramsJson);
void getSuitableDiscussionChats(int clientId, const std::string& paramsJson);
void getInactiveSupergroupChats(int clientId, const std::string& paramsJson);
void getSuitablePersonalChats(int clientId, const std::string& paramsJson);
void loadDirectMessagesChatTopics(int clientId, const std::string& paramsJson);
void getDirectMessagesChatTopic(int clientId, const std::string& paramsJson);
void getDirectMessagesChatTopicHistory(int clientId, const std::string& paramsJson);
void getDirectMessagesChatTopicMessageByDate(int clientId, const std::string& paramsJson);
void deleteDirectMessagesChatTopicHistory(int clientId, const std::string& paramsJson);
void deleteDirectMessagesChatTopicMessagesByDate(int clientId, const std::string& paramsJson);
void setDirectMessagesChatTopicIsMarkedAsUnread(int clientId, const std::string& paramsJson);
void unpinAllDirectMessagesChatTopicMessages(int clientId, const std::string& paramsJson);
void readAllDirectMessagesChatTopicReactions(int clientId, const std::string& paramsJson);
void getDirectMessagesChatTopicRevenue(int clientId, const std::string& paramsJson);
void toggleDirectMessagesChatTopicCanSendUnpaidMessages(int clientId, const std::string& paramsJson);
void loadSavedMessagesTopics(int clientId, const std::string& paramsJson);
void getSavedMessagesTopicHistory(int clientId, const std::string& paramsJson);
void getSavedMessagesTopicMessageByDate(int clientId, const std::string& paramsJson);
void deleteSavedMessagesTopicHistory(int clientId, const std::string& paramsJson);
void deleteSavedMessagesTopicMessagesByDate(int clientId, const std::string& paramsJson);
void toggleSavedMessagesTopicIsPinned(int clientId, const std::string& paramsJson);
void setPinnedSavedMessagesTopics(int clientId, const std::string& paramsJson);
void getGroupsInCommon(int clientId, const std::string& paramsJson);
void getChatHistory(int clientId, const std::string& paramsJson);
void getMessageThreadHistory(int clientId, const std::string& paramsJson);
void deleteChatHistory(int clientId, const std::string& paramsJson);
void deleteChat(int clientId, const std::string& paramsJson);
void searchChatMessages(int clientId, const std::string& paramsJson);
void searchMessages(int clientId, const std::string& paramsJson);
void searchSecretMessages(int clientId, const std::string& paramsJson);
void searchSavedMessages(int clientId, const std::string& paramsJson);
void searchCallMessages(int clientId, const std::string& paramsJson);
void searchOutgoingDocumentMessages(int clientId, const std::string& paramsJson);
void getPublicPostSearchLimits(int clientId, const std::string& paramsJson);
void searchPublicPosts(int clientId, const std::string& paramsJson);
void searchPublicMessagesByTag(int clientId, const std::string& paramsJson);
void searchPublicStoriesByTag(int clientId, const std::string& paramsJson);
void searchPublicStoriesByLocation(int clientId, const std::string& paramsJson);
void searchPublicStoriesByVenue(int clientId, const std::string& paramsJson);
void getSearchedForTags(int clientId, const std::string& paramsJson);
void removeSearchedForTag(int clientId, const std::string& paramsJson);
void clearSearchedForTags(int clientId, const std::string& paramsJson);
void deleteAllCallMessages(int clientId, const std::string& paramsJson);
void searchChatRecentLocationMessages(int clientId, const std::string& paramsJson);
void getChatMessageByDate(int clientId, const std::string& paramsJson);
void getChatSparseMessagePositions(int clientId, const std::string& paramsJson);
void getChatMessageCalendar(int clientId, const std::string& paramsJson);
void getChatMessageCount(int clientId, const std::string& paramsJson);
void getChatMessagePosition(int clientId, const std::string& paramsJson);
void getChatScheduledMessages(int clientId, const std::string& paramsJson);
void getChatSponsoredMessages(int clientId, const std::string& paramsJson);
void clickChatSponsoredMessage(int clientId, const std::string& paramsJson);
void reportChatSponsoredMessage(int clientId, const std::string& paramsJson);
void getSearchSponsoredChats(int clientId, const std::string& paramsJson);
void viewSponsoredChat(int clientId, const std::string& paramsJson);
void openSponsoredChat(int clientId, const std::string& paramsJson);
void reportSponsoredChat(int clientId, const std::string& paramsJson);
void getVideoMessageAdvertisements(int clientId, const std::string& paramsJson);
void viewVideoMessageAdvertisement(int clientId, const std::string& paramsJson);
void clickVideoMessageAdvertisement(int clientId, const std::string& paramsJson);
void reportVideoMessageAdvertisement(int clientId, const std::string& paramsJson);
void removeNotification(int clientId, const std::string& paramsJson);
void removeNotificationGroup(int clientId, const std::string& paramsJson);
void getMessageLink(int clientId, const std::string& paramsJson);
void getMessageEmbeddingCode(int clientId, const std::string& paramsJson);
void getMessageLinkInfo(int clientId, const std::string& paramsJson);
void translateText(int clientId, const std::string& paramsJson);
void translateMessageText(int clientId, const std::string& paramsJson);
void summarizeMessage(int clientId, const std::string& paramsJson);
void recognizeSpeech(int clientId, const std::string& paramsJson);
void rateSpeechRecognition(int clientId, const std::string& paramsJson);
void getChatAvailableMessageSenders(int clientId, const std::string& paramsJson);
void setChatMessageSender(int clientId, const std::string& paramsJson);

// ==================== 消息操作 ====================
void sendMessage(int clientId, const std::string& paramsJson);
void sendMessageAlbum(int clientId, const std::string& paramsJson);
void sendBotStartMessage(int clientId, const std::string& paramsJson);
void sendInlineQueryResultMessage(int clientId, const std::string& paramsJson);
void forwardMessages(int clientId, const std::string& paramsJson);
void sendQuickReplyShortcutMessages(int clientId, const std::string& paramsJson);
void resendMessages(int clientId, const std::string& paramsJson);
void addLocalMessage(int clientId, const std::string& paramsJson);
void deleteMessages(int clientId, const std::string& paramsJson);
void deleteChatMessagesBySender(int clientId, const std::string& paramsJson);
void deleteChatMessagesByDate(int clientId, const std::string& paramsJson);
void editMessageText(int clientId, const std::string& paramsJson);
void editMessageLiveLocation(int clientId, const std::string& paramsJson);
void editMessageChecklist(int clientId, const std::string& paramsJson);
void editMessageMedia(int clientId, const std::string& paramsJson);
void editMessageCaption(int clientId, const std::string& paramsJson);
void editMessageReplyMarkup(int clientId, const std::string& paramsJson);
void editInlineMessageText(int clientId, const std::string& paramsJson);
void editInlineMessageLiveLocation(int clientId, const std::string& paramsJson);
void editInlineMessageMedia(int clientId, const std::string& paramsJson);
void editInlineMessageCaption(int clientId, const std::string& paramsJson);
void editInlineMessageReplyMarkup(int clientId, const std::string& paramsJson);
void editMessageSchedulingState(int clientId, const std::string& paramsJson);
void setMessageFactCheck(int clientId, const std::string& paramsJson);
void sendBusinessMessage(int clientId, const std::string& paramsJson);
void sendBusinessMessageAlbum(int clientId, const std::string& paramsJson);
void editBusinessMessageText(int clientId, const std::string& paramsJson);
void editBusinessMessageLiveLocation(int clientId, const std::string& paramsJson);
void editBusinessMessageChecklist(int clientId, const std::string& paramsJson);
void editBusinessMessageMedia(int clientId, const std::string& paramsJson);
void editBusinessMessageCaption(int clientId, const std::string& paramsJson);
void editBusinessMessageReplyMarkup(int clientId, const std::string& paramsJson);
void stopBusinessPoll(int clientId, const std::string& paramsJson);
void setBusinessMessageIsPinned(int clientId, const std::string& paramsJson);
void readBusinessMessage(int clientId, const std::string& paramsJson);
void deleteBusinessMessages(int clientId, const std::string& paramsJson);
void editBusinessStory(int clientId, const std::string& paramsJson);
void deleteBusinessStory(int clientId, const std::string& paramsJson);
void setBusinessAccountName(int clientId, const std::string& paramsJson);
void setBusinessAccountBio(int clientId, const std::string& paramsJson);
void setBusinessAccountProfilePhoto(int clientId, const std::string& paramsJson);
void setBusinessAccountUsername(int clientId, const std::string& paramsJson);
void setBusinessAccountGiftSettings(int clientId, const std::string& paramsJson);
void getBusinessAccountStarAmount(int clientId, const std::string& paramsJson);
void transferBusinessAccountStars(int clientId, const std::string& paramsJson);
void checkQuickReplyShortcutName(int clientId, const std::string& paramsJson);
void loadQuickReplyShortcuts(int clientId, const std::string& paramsJson);
void setQuickReplyShortcutName(int clientId, const std::string& paramsJson);
void deleteQuickReplyShortcut(int clientId, const std::string& paramsJson);
void reorderQuickReplyShortcuts(int clientId, const std::string& paramsJson);
void loadQuickReplyShortcutMessages(int clientId, const std::string& paramsJson);
void deleteQuickReplyShortcutMessages(int clientId, const std::string& paramsJson);
void addQuickReplyShortcutMessage(int clientId, const std::string& paramsJson);
void addQuickReplyShortcutInlineQueryResultMessage(int clientId, const std::string& paramsJson);
void addQuickReplyShortcutMessageAlbum(int clientId, const std::string& paramsJson);
void readdQuickReplyShortcutMessages(int clientId, const std::string& paramsJson);
void editQuickReplyMessage(int clientId, const std::string& paramsJson);
void getForumTopicDefaultIcons(int clientId, const std::string& paramsJson);
void createForumTopic(int clientId, const std::string& paramsJson);
void editForumTopic(int clientId, const std::string& paramsJson);
void getForumTopic(int clientId, const std::string& paramsJson);
void getForumTopicHistory(int clientId, const std::string& paramsJson);
void getForumTopicLink(int clientId, const std::string& paramsJson);
void getForumTopics(int clientId, const std::string& paramsJson);
void setForumTopicNotificationSettings(int clientId, const std::string& paramsJson);
void toggleForumTopicIsClosed(int clientId, const std::string& paramsJson);
void toggleGeneralForumTopicIsHidden(int clientId, const std::string& paramsJson);
void toggleForumTopicIsPinned(int clientId, const std::string& paramsJson);
void setPinnedForumTopics(int clientId, const std::string& paramsJson);
void deleteForumTopic(int clientId, const std::string& paramsJson);
void readAllForumTopicMentions(int clientId, const std::string& paramsJson);
void readAllForumTopicReactions(int clientId, const std::string& paramsJson);
void unpinAllForumTopicMessages(int clientId, const std::string& paramsJson);

// ==================== 反应与表情 ====================
void getPasskeyParameters(int clientId, const std::string& paramsJson);
void addLoginPasskey(int clientId, const std::string& paramsJson);
void getLoginPasskeys(int clientId, const std::string& paramsJson);
void removeLoginPasskey(int clientId, const std::string& paramsJson);
void getEmojiReaction(int clientId, const std::string& paramsJson);
void getCustomEmojiReactionAnimations(int clientId, const std::string& paramsJson);
void getMessageAvailableReactions(int clientId, const std::string& paramsJson);
void clearRecentReactions(int clientId, const std::string& paramsJson);
void addMessageReaction(int clientId, const std::string& paramsJson);
void removeMessageReaction(int clientId, const std::string& paramsJson);
void getChatAvailablePaidMessageReactionSenders(int clientId, const std::string& paramsJson);
void addPendingPaidMessageReaction(int clientId, const std::string& paramsJson);
void commitPendingPaidMessageReactions(int clientId, const std::string& paramsJson);
void removePendingPaidMessageReactions(int clientId, const std::string& paramsJson);
void setPaidMessageReactionType(int clientId, const std::string& paramsJson);
void setMessageReactions(int clientId, const std::string& paramsJson);
void getMessageAddedReactions(int clientId, const std::string& paramsJson);
void setDefaultReactionType(int clientId, const std::string& paramsJson);
void getSavedMessagesTags(int clientId, const std::string& paramsJson);
void setSavedMessagesTagLabel(int clientId, const std::string& paramsJson);
void getMessageEffect(int clientId, const std::string& paramsJson);
void searchQuote(int clientId, const std::string& paramsJson);

// ==================== 文本处理 ====================
void getTextEntities(int clientId, const std::string& paramsJson);
void parseTextEntities(int clientId, const std::string& paramsJson);
void parseMarkdown(int clientId, const std::string& paramsJson);
void getMarkdownText(int clientId, const std::string& paramsJson);
void getCountryFlagEmoji(int clientId, const std::string& paramsJson);
void getFileMimeType(int clientId, const std::string& paramsJson);
void getFileExtension(int clientId, const std::string& paramsJson);
void cleanFileName(int clientId, const std::string& paramsJson);
void getLanguagePackString(int clientId, const std::string& paramsJson);
void getJsonValue(int clientId, const std::string& paramsJson);
void getJsonString(int clientId, const std::string& paramsJson);
void getThemeParametersJsonString(int clientId, const std::string& paramsJson);

// ==================== 投票与清单 ====================
void setPollAnswer(int clientId, const std::string& paramsJson);
void getPollVoters(int clientId, const std::string& paramsJson);
void stopPoll(int clientId, const std::string& paramsJson);
void addChecklistTasks(int clientId, const std::string& paramsJson);
void markChecklistTasksAsDone(int clientId, const std::string& paramsJson);

// ==================== 建议操作 ====================
void hideSuggestedAction(int clientId, const std::string& paramsJson);
void hideContactCloseBirthdays(int clientId, const std::string& paramsJson);

// ==================== 业务连接 ====================
void getBusinessConnection(int clientId, const std::string& paramsJson);

// ==================== 登录 URL ====================
void getLoginUrlInfo(int clientId, const std::string& paramsJson);
void getLoginUrl(int clientId, const std::string& paramsJson);
void shareUsersWithBot(int clientId, const std::string& paramsJson);
void shareChatWithBot(int clientId, const std::string& paramsJson);

// ==================== 内联查询 ====================
void getInlineQueryResults(int clientId, const std::string& paramsJson);
void answerInlineQuery(int clientId, const std::string& paramsJson);
void savePreparedInlineMessage(int clientId, const std::string& paramsJson);
void getPreparedInlineMessage(int clientId, const std::string& paramsJson);

// ==================== Web 应用 ====================
void getGrossingWebAppBots(int clientId, const std::string& paramsJson);
void searchWebApp(int clientId, const std::string& paramsJson);
void getWebAppPlaceholder(int clientId, const std::string& paramsJson);
void getWebAppLinkUrl(int clientId, const std::string& paramsJson);
void getMainWebApp(int clientId, const std::string& paramsJson);
void getWebAppUrl(int clientId, const std::string& paramsJson);
void sendWebAppData(int clientId, const std::string& paramsJson);
void openWebApp(int clientId, const std::string& paramsJson);
void closeWebApp(int clientId, const std::string& paramsJson);
void answerWebAppQuery(int clientId, const std::string& paramsJson);
void checkWebAppFileDownload(int clientId, const std::string& paramsJson);

// ==================== 回调查询 ====================
void getCallbackQueryAnswer(int clientId, const std::string& paramsJson);
void answerCallbackQuery(int clientId, const std::string& paramsJson);
void answerShippingQuery(int clientId, const std::string& paramsJson);
void answerPreCheckoutQuery(int clientId, const std::string& paramsJson);

// ==================== 游戏 ====================
void setGameScore(int clientId, const std::string& paramsJson);
void setInlineGameScore(int clientId, const std::string& paramsJson);
void getGameHighScores(int clientId, const std::string& paramsJson);
void getInlineGameHighScores(int clientId, const std::string& paramsJson);

// ==================== 聊天操作 ====================
void deleteChatReplyMarkup(int clientId, const std::string& paramsJson);
void sendChatAction(int clientId, const std::string& paramsJson);
void sendTextMessageDraft(int clientId, const std::string& paramsJson);
void openChat(int clientId, const std::string& paramsJson);
void closeChat(int clientId, const std::string& paramsJson);
void viewMessages(int clientId, const std::string& paramsJson);
void openMessageContent(int clientId, const std::string& paramsJson);
void clickAnimatedEmojiMessage(int clientId, const std::string& paramsJson);
void getInternalLink(int clientId, const std::string& paramsJson);
void getInternalLinkType(int clientId, const std::string& paramsJson);
void getExternalLinkInfo(int clientId, const std::string& paramsJson);
void getExternalLink(int clientId, const std::string& paramsJson);
void readAllChatMentions(int clientId, const std::string& paramsJson);
void readAllChatReactions(int clientId, const std::string& paramsJson);

// ==================== 创建聊天 ====================
void createPrivateChat(int clientId, const std::string& paramsJson);
void createBasicGroupChat(int clientId, const std::string& paramsJson);
void createSupergroupChat(int clientId, const std::string& paramsJson);
void createSecretChat(int clientId, const std::string& paramsJson);
void createNewBasicGroupChat(int clientId, const std::string& paramsJson);
void createNewSupergroupChat(int clientId, const std::string& paramsJson);
void createNewSecretChat(int clientId, const std::string& paramsJson);
void upgradeBasicGroupChatToSupergroupChat(int clientId, const std::string& paramsJson);

// ==================== 聊天列表与文件夹 ====================
void getChatListsToAddChat(int clientId, const std::string& paramsJson);
void addChatToList(int clientId, const std::string& paramsJson);
void getChatFolder(int clientId, const std::string& paramsJson);
void createChatFolder(int clientId, const std::string& paramsJson);
void editChatFolder(int clientId, const std::string& paramsJson);
void deleteChatFolder(int clientId, const std::string& paramsJson);
void getChatFolderChatsToLeave(int clientId, const std::string& paramsJson);
void getChatFolderChatCount(int clientId, const std::string& paramsJson);
void reorderChatFolders(int clientId, const std::string& paramsJson);
void toggleChatFolderTags(int clientId, const std::string& paramsJson);
void getRecommendedChatFolders(int clientId, const std::string& paramsJson);
void getChatFolderDefaultIconName(int clientId, const std::string& paramsJson);
void getChatsForChatFolderInviteLink(int clientId, const std::string& paramsJson);
void createChatFolderInviteLink(int clientId, const std::string& paramsJson);
void getChatFolderInviteLinks(int clientId, const std::string& paramsJson);
void editChatFolderInviteLink(int clientId, const std::string& paramsJson);
void deleteChatFolderInviteLink(int clientId, const std::string& paramsJson);
void checkChatFolderInviteLink(int clientId, const std::string& paramsJson);
void addChatFolderByInviteLink(int clientId, const std::string& paramsJson);
void getChatFolderNewChats(int clientId, const std::string& paramsJson);
void processChatFolderNewChats(int clientId, const std::string& paramsJson);
void getArchiveChatListSettings(int clientId, const std::string& paramsJson);
void setArchiveChatListSettings(int clientId, const std::string& paramsJson);
void setChatTitle(int clientId, const std::string& paramsJson);
void setChatPhoto(int clientId, const std::string& paramsJson);
void setChatAccentColor(int clientId, const std::string& paramsJson);
void setChatProfileAccentColor(int clientId, const std::string& paramsJson);
void setChatMessageAutoDeleteTime(int clientId, const std::string& paramsJson);
void setChatEmojiStatus(int clientId, const std::string& paramsJson);
void setChatPermissions(int clientId, const std::string& paramsJson);
void setChatBackground(int clientId, const std::string& paramsJson);
void deleteChatBackground(int clientId, const std::string& paramsJson);
void getGiftChatThemes(int clientId, const std::string& paramsJson);
void setChatTheme(int clientId, const std::string& paramsJson);
void setChatDraftMessage(int clientId, const std::string& paramsJson);
void setChatNotificationSettings(int clientId, const std::string& paramsJson);
void toggleChatHasProtectedContent(int clientId, const std::string& paramsJson);
void toggleChatViewAsTopics(int clientId, const std::string& paramsJson);
void toggleChatIsTranslatable(int clientId, const std::string& paramsJson);
void toggleChatIsMarkedAsUnread(int clientId, const std::string& paramsJson);
void toggleChatDefaultDisableNotification(int clientId, const std::string& paramsJson);
void setChatAvailableReactions(int clientId, const std::string& paramsJson);
void setChatClientData(int clientId, const std::string& paramsJson);
void setChatDescription(int clientId, const std::string& paramsJson);
void setChatDiscussionGroup(int clientId, const std::string& paramsJson);
void setChatDirectMessagesGroup(int clientId, const std::string& paramsJson);
void setChatLocation(int clientId, const std::string& paramsJson);
void setChatSlowModeDelay(int clientId, const std::string& paramsJson);
void pinChatMessage(int clientId, const std::string& paramsJson);
void unpinChatMessage(int clientId, const std::string& paramsJson);
void unpinAllChatMessages(int clientId, const std::string& paramsJson);
void joinChat(int clientId, const std::string& paramsJson);
void leaveChat(int clientId, const std::string& paramsJson);
void addChatMember(int clientId, const std::string& paramsJson);
void addChatMembers(int clientId, const std::string& paramsJson);
void setChatMemberStatus(int clientId, const std::string& paramsJson);
void banChatMember(int clientId, const std::string& paramsJson);
void canTransferOwnership(int clientId, const std::string& paramsJson);
void transferChatOwnership(int clientId, const std::string& paramsJson);
void getChatOwnerAfterLeaving(int clientId, const std::string& paramsJson);
void getChatMember(int clientId, const std::string& paramsJson);
void searchChatMembers(int clientId, const std::string& paramsJson);
void getChatAdministrators(int clientId, const std::string& paramsJson);
void clearAllDraftMessages(int clientId, const std::string& paramsJson);
void getStakeDiceState(int clientId, const std::string& paramsJson);

// ==================== 通知设置 ====================
void getSavedNotificationSound(int clientId, const std::string& paramsJson);
void getSavedNotificationSounds(int clientId, const std::string& paramsJson);
void addSavedNotificationSound(int clientId, const std::string& paramsJson);
void removeSavedNotificationSound(int clientId, const std::string& paramsJson);
void getChatNotificationSettingsExceptions(int clientId, const std::string& paramsJson);
void getScopeNotificationSettings(int clientId, const std::string& paramsJson);
void setScopeNotificationSettings(int clientId, const std::string& paramsJson);
void setReactionNotificationSettings(int clientId, const std::string& paramsJson);
void resetAllNotificationSettings(int clientId, const std::string& paramsJson);
void toggleChatIsPinned(int clientId, const std::string& paramsJson);
void setPinnedChats(int clientId, const std::string& paramsJson);
void readChatList(int clientId, const std::string& paramsJson);

// ==================== 天气 ====================
void getCurrentWeather(int clientId, const std::string& paramsJson);

// ==================== 故事 ====================
void getStory(int clientId, const std::string& paramsJson);
void getChatsToPostStories(int clientId, const std::string& paramsJson);
void canPostStory(int clientId, const std::string& paramsJson);
void postStory(int clientId, const std::string& paramsJson);
void startLiveStory(int clientId, const std::string& paramsJson);
void editStory(int clientId, const std::string& paramsJson);
void editStoryCover(int clientId, const std::string& paramsJson);
void setStoryPrivacySettings(int clientId, const std::string& paramsJson);
void toggleStoryIsPostedToChatPage(int clientId, const std::string& paramsJson);
void deleteStory(int clientId, const std::string& paramsJson);
void getStoryNotificationSettingsExceptions(int clientId, const std::string& paramsJson);
void loadActiveStories(int clientId, const std::string& paramsJson);
void setChatActiveStoriesList(int clientId, const std::string& paramsJson);
void getChatActiveStories(int clientId, const std::string& paramsJson);
void getChatPostedToChatPageStories(int clientId, const std::string& paramsJson);
void getChatArchivedStories(int clientId, const std::string& paramsJson);
void setChatPinnedStories(int clientId, const std::string& paramsJson);
void openStory(int clientId, const std::string& paramsJson);
void closeStory(int clientId, const std::string& paramsJson);
void getStoryAvailableReactions(int clientId, const std::string& paramsJson);
void setStoryReaction(int clientId, const std::string& paramsJson);
void getStoryInteractions(int clientId, const std::string& paramsJson);
void getChatStoryInteractions(int clientId, const std::string& paramsJson);
void reportStory(int clientId, const std::string& paramsJson);
void activateStoryStealthMode(int clientId, const std::string& paramsJson);
void getStoryPublicForwards(int clientId, const std::string& paramsJson);
void getChatStoryAlbums(int clientId, const std::string& paramsJson);
void getStoryAlbumStories(int clientId, const std::string& paramsJson);
void createStoryAlbum(int clientId, const std::string& paramsJson);
void reorderStoryAlbums(int clientId, const std::string& paramsJson);
void deleteStoryAlbum(int clientId, const std::string& paramsJson);
void setStoryAlbumName(int clientId, const std::string& paramsJson);
void addStoryAlbumStories(int clientId, const std::string& paramsJson);
void removeStoryAlbumStories(int clientId, const std::string& paramsJson);
void reorderStoryAlbumStories(int clientId, const std::string& paramsJson);

// ==================== 提升与增强 ====================
void getChatBoostLevelFeatures(int clientId, const std::string& paramsJson);
void getChatBoostFeatures(int clientId, const std::string& paramsJson);
void getAvailableChatBoostSlots(int clientId, const std::string& paramsJson);
void getChatBoostStatus(int clientId, const std::string& paramsJson);
void boostChat(int clientId, const std::string& paramsJson);
void getChatBoostLink(int clientId, const std::string& paramsJson);
void getChatBoostLinkInfo(int clientId, const std::string& paramsJson);
void getChatBoosts(int clientId, const std::string& paramsJson);
void getUserChatBoosts(int clientId, const std::string& paramsJson);

// ==================== 附件菜单机器人 ====================
void getAttachmentMenuBot(int clientId, const std::string& paramsJson);
void toggleBotIsAddedToAttachmentMenu(int clientId, const std::string& paramsJson);

// ==================== 表情状态 ====================
void getThemedEmojiStatuses(int clientId, const std::string& paramsJson);
void getRecentEmojiStatuses(int clientId, const std::string& paramsJson);
void getUpgradedGiftEmojiStatuses(int clientId, const std::string& paramsJson);
void getDefaultEmojiStatuses(int clientId, const std::string& paramsJson);
void clearRecentEmojiStatuses(int clientId, const std::string& paramsJson);
void getThemedChatEmojiStatuses(int clientId, const std::string& paramsJson);
void getDefaultChatEmojiStatuses(int clientId, const std::string& paramsJson);
void getDisallowedChatEmojiStatuses(int clientId, const std::string& paramsJson);

// ==================== 文件操作 ====================
void getFile(int clientId, const std::string& paramsJson);
void getRemoteFile(int clientId, const std::string& paramsJson);
void readFilePart(int clientId, const std::string& paramsJson);
void getFileDownloadedPrefixSize(int clientId, const std::string& paramsJson);
void downloadFile(int clientId, const std::string& paramsJson);
void cancelDownloadFile(int clientId, const std::string& paramsJson);
void preliminaryUploadFile(int clientId, const std::string& paramsJson);
void cancelPreliminaryUploadFile(int clientId, const std::string& paramsJson);
void writeGeneratedFilePart(int clientId, const std::string& paramsJson);
void setFileGenerationProgress(int clientId, const std::string& paramsJson);
void finishFileGeneration(int clientId, const std::string& paramsJson);
void getSuggestedFileName(int clientId, const std::string& paramsJson);
void deleteFile(int clientId, const std::string& paramsJson);
void addFileToDownloads(int clientId, const std::string& paramsJson);
void toggleDownloadIsPaused(int clientId, const std::string& paramsJson);
void toggleAllDownloadsArePaused(int clientId, const std::string& paramsJson);
void removeFileFromDownloads(int clientId, const std::string& paramsJson);
void removeAllFilesFromDownloads(int clientId, const std::string& paramsJson);
void searchFileDownloads(int clientId, const std::string& paramsJson);
void getAutoDownloadSettingsPresets(int clientId, const std::string& paramsJson);
void setAutoDownloadSettings(int clientId, const std::string& paramsJson);
void uploadStickerFile(int clientId, const std::string& paramsJson);
void getMapThumbnailFile(int clientId, const std::string& paramsJson);
void getApplicationDownloadLink(int clientId, const std::string& paramsJson);

// ==================== 应用验证 ====================
void setApplicationVerificationToken(int clientId, const std::string& paramsJson);
void getMessageFileType(int clientId, const std::string& paramsJson);
void getMessageImportConfirmationText(int clientId, const std::string& paramsJson);
void importMessages(int clientId, const std::string& paramsJson);

// ==================== 邀请链接 ====================
void replacePrimaryChatInviteLink(int clientId, const std::string& paramsJson);
void createChatInviteLink(int clientId, const std::string& paramsJson);
void createChatSubscriptionInviteLink(int clientId, const std::string& paramsJson);
void editChatInviteLink(int clientId, const std::string& paramsJson);
void editChatSubscriptionInviteLink(int clientId, const std::string& paramsJson);
void getChatInviteLink(int clientId, const std::string& paramsJson);
void getChatInviteLinkCounts(int clientId, const std::string& paramsJson);
void getChatInviteLinks(int clientId, const std::string& paramsJson);
void getChatInviteLinkMembers(int clientId, const std::string& paramsJson);
void revokeChatInviteLink(int clientId, const std::string& paramsJson);
void deleteRevokedChatInviteLink(int clientId, const std::string& paramsJson);
void deleteAllRevokedChatInviteLinks(int clientId, const std::string& paramsJson);
void checkChatInviteLink(int clientId, const std::string& paramsJson);
void joinChatByInviteLink(int clientId, const std::string& paramsJson);
void getChatJoinRequests(int clientId, const std::string& paramsJson);
void processChatJoinRequest(int clientId, const std::string& paramsJson);
void processChatJoinRequests(int clientId, const std::string& paramsJson);
void approveSuggestedPost(int clientId, const std::string& paramsJson);
void declineSuggestedPost(int clientId, const std::string& paramsJson);
void addOffer(int clientId, const std::string& paramsJson);

// ==================== 通话与视频聊天 ====================
void createCall(int clientId, const std::string& paramsJson);
void acceptCall(int clientId, const std::string& paramsJson);
void sendCallSignalingData(int clientId, const std::string& paramsJson);
void discardCall(int clientId, const std::string& paramsJson);
void sendCallRating(int clientId, const std::string& paramsJson);
void sendCallDebugInformation(int clientId, const std::string& paramsJson);
void sendCallLog(int clientId, const std::string& paramsJson);
void getVideoChatAvailableParticipants(int clientId, const std::string& paramsJson);
void setVideoChatDefaultParticipant(int clientId, const std::string& paramsJson);
void createVideoChat(int clientId, const std::string& paramsJson);
void createGroupCall(int clientId, const std::string& paramsJson);
void getVideoChatRtmpUrl(int clientId, const std::string& paramsJson);
void replaceVideoChatRtmpUrl(int clientId, const std::string& paramsJson);
void getLiveStoryRtmpUrl(int clientId, const std::string& paramsJson);
void replaceLiveStoryRtmpUrl(int clientId, const std::string& paramsJson);
void getGroupCall(int clientId, const std::string& paramsJson);
void startScheduledVideoChat(int clientId, const std::string& paramsJson);
void toggleVideoChatEnabledStartNotification(int clientId, const std::string& paramsJson);
void joinGroupCall(int clientId, const std::string& paramsJson);
void joinVideoChat(int clientId, const std::string& paramsJson);
void joinLiveStory(int clientId, const std::string& paramsJson);
void startGroupCallScreenSharing(int clientId, const std::string& paramsJson);
void toggleGroupCallScreenSharingIsPaused(int clientId, const std::string& paramsJson);
void endGroupCallScreenSharing(int clientId, const std::string& paramsJson);
void setVideoChatTitle(int clientId, const std::string& paramsJson);
void toggleVideoChatMuteNewParticipants(int clientId, const std::string& paramsJson);
void toggleGroupCallAreMessagesAllowed(int clientId, const std::string& paramsJson);
void getLiveStoryStreamer(int clientId, const std::string& paramsJson);
void getLiveStoryAvailableMessageSenders(int clientId, const std::string& paramsJson);
void setLiveStoryMessageSender(int clientId, const std::string& paramsJson);
void sendGroupCallMessage(int clientId, const std::string& paramsJson);
void addPendingLiveStoryReaction(int clientId, const std::string& paramsJson);
void commitPendingLiveStoryReactions(int clientId, const std::string& paramsJson);
void removePendingLiveStoryReactions(int clientId, const std::string& paramsJson);
void deleteGroupCallMessages(int clientId, const std::string& paramsJson);
void deleteGroupCallMessagesBySender(int clientId, const std::string& paramsJson);
void getLiveStoryTopDonors(int clientId, const std::string& paramsJson);
void inviteGroupCallParticipant(int clientId, const std::string& paramsJson);
void declineGroupCallInvitation(int clientId, const std::string& paramsJson);
void banGroupCallParticipants(int clientId, const std::string& paramsJson);
void inviteVideoChatParticipants(int clientId, const std::string& paramsJson);
void getVideoChatInviteLink(int clientId, const std::string& paramsJson);
void revokeGroupCallInviteLink(int clientId, const std::string& paramsJson);
void startGroupCallRecording(int clientId, const std::string& paramsJson);
void endGroupCallRecording(int clientId, const std::string& paramsJson);
void toggleGroupCallIsMyVideoPaused(int clientId, const std::string& paramsJson);
void toggleGroupCallIsMyVideoEnabled(int clientId, const std::string& paramsJson);
void setGroupCallPaidMessageStarCount(int clientId, const std::string& paramsJson);
void setGroupCallParticipantIsSpeaking(int clientId, const std::string& paramsJson);
void toggleGroupCallParticipantIsMuted(int clientId, const std::string& paramsJson);
void setGroupCallParticipantVolumeLevel(int clientId, const std::string& paramsJson);
void toggleGroupCallParticipantIsHandRaised(int clientId, const std::string& paramsJson);
void getGroupCallParticipants(int clientId, const std::string& paramsJson);
void loadGroupCallParticipants(int clientId, const std::string& paramsJson);
void leaveGroupCall(int clientId, const std::string& paramsJson);
void endGroupCall(int clientId, const std::string& paramsJson);
void getGroupCallStreams(int clientId, const std::string& paramsJson);
void getGroupCallStreamSegment(int clientId, const std::string& paramsJson);
void encryptGroupCallData(int clientId, const std::string& paramsJson);
void decryptGroupCallData(int clientId, const std::string& paramsJson);

// ==================== 封禁与联系人 ====================
void setMessageSenderBlockList(int clientId, const std::string& paramsJson);
void blockMessageSenderFromReplies(int clientId, const std::string& paramsJson);
void getBlockedMessageSenders(int clientId, const std::string& paramsJson);
void addContact(int clientId, const std::string& paramsJson);
void importContacts(int clientId, const std::string& paramsJson);
void getContacts(int clientId, const std::string& paramsJson);
void searchContacts(int clientId, const std::string& paramsJson);
void removeContacts(int clientId, const std::string& paramsJson);
void getImportedContactCount(int clientId, const std::string& paramsJson);
void changeImportedContacts(int clientId, const std::string& paramsJson);
void clearImportedContacts(int clientId, const std::string& paramsJson);
void setCloseFriends(int clientId, const std::string& paramsJson);
void getCloseFriends(int clientId, const std::string& paramsJson);

// ==================== 贴纸与表情 ====================
void getStickerOutline(int clientId, const std::string& paramsJson);
void getStickerOutlineSvgPath(int clientId, const std::string& paramsJson);
void getStickers(int clientId, const std::string& paramsJson);
void getAllStickerEmojis(int clientId, const std::string& paramsJson);
void searchStickers(int clientId, const std::string& paramsJson);
void getGreetingStickers(int clientId, const std::string& paramsJson);
void getPremiumStickers(int clientId, const std::string& paramsJson);
void getInstalledStickerSets(int clientId, const std::string& paramsJson);
void getArchivedStickerSets(int clientId, const std::string& paramsJson);
void getTrendingStickerSets(int clientId, const std::string& paramsJson);
void getAttachedStickerSets(int clientId, const std::string& paramsJson);
void getStickerSet(int clientId, const std::string& paramsJson);
void getStickerSetName(int clientId, const std::string& paramsJson);
void searchStickerSet(int clientId, const std::string& paramsJson);
void searchInstalledStickerSets(int clientId, const std::string& paramsJson);
void searchStickerSets(int clientId, const std::string& paramsJson);
void changeStickerSet(int clientId, const std::string& paramsJson);
void viewTrendingStickerSets(int clientId, const std::string& paramsJson);
void reorderInstalledStickerSets(int clientId, const std::string& paramsJson);
void getRecentStickers(int clientId, const std::string& paramsJson);
void addRecentSticker(int clientId, const std::string& paramsJson);
void removeRecentSticker(int clientId, const std::string& paramsJson);
void clearRecentStickers(int clientId, const std::string& paramsJson);
void getFavoriteStickers(int clientId, const std::string& paramsJson);
void addFavoriteSticker(int clientId, const std::string& paramsJson);
void removeFavoriteSticker(int clientId, const std::string& paramsJson);
void getStickerEmojis(int clientId, const std::string& paramsJson);
void searchEmojis(int clientId, const std::string& paramsJson);
void getKeywordEmojis(int clientId, const std::string& paramsJson);
void getEmojiCategories(int clientId, const std::string& paramsJson);
void getAnimatedEmoji(int clientId, const std::string& paramsJson);
void getEmojiSuggestionsUrl(int clientId, const std::string& paramsJson);
void getCustomEmojiStickers(int clientId, const std::string& paramsJson);
void getDefaultChatPhotoCustomEmojiStickers(int clientId, const std::string& paramsJson);
void getDefaultProfilePhotoCustomEmojiStickers(int clientId, const std::string& paramsJson);
void getDefaultBackgroundCustomEmojiStickers(int clientId, const std::string& paramsJson);
void getSavedAnimations(int clientId, const std::string& paramsJson);
void addSavedAnimation(int clientId, const std::string& paramsJson);
void removeSavedAnimation(int clientId, const std::string& paramsJson);
void getRecentInlineBots(int clientId, const std::string& paramsJson);
void getOwnedBots(int clientId, const std::string& paramsJson);
void searchHashtags(int clientId, const std::string& paramsJson);
void removeRecentHashtag(int clientId, const std::string& paramsJson);
void getLinkPreview(int clientId, const std::string& paramsJson);
void getWebPageInstantView(int clientId, const std::string& paramsJson);

// ==================== 机器人命令与菜单 ====================
void setCommands(int clientId, const std::string& paramsJson);
void deleteCommands(int clientId, const std::string& paramsJson);
void getCommands(int clientId, const std::string& paramsJson);
void setMenuButton(int clientId, const std::string& paramsJson);
void getMenuButton(int clientId, const std::string& paramsJson);
void setDefaultGroupAdministratorRights(int clientId, const std::string& paramsJson);
void setDefaultChannelAdministratorRights(int clientId, const std::string& paramsJson);
void canBotSendMessages(int clientId, const std::string& paramsJson);
void allowBotToSendMessages(int clientId, const std::string& paramsJson);
void sendWebAppCustomRequest(int clientId, const std::string& paramsJson);
void getBotMediaPreviews(int clientId, const std::string& paramsJson);
void getBotMediaPreviewInfo(int clientId, const std::string& paramsJson);
void addBotMediaPreview(int clientId, const std::string& paramsJson);
void editBotMediaPreview(int clientId, const std::string& paramsJson);
void reorderBotMediaPreviews(int clientId, const std::string& paramsJson);
void deleteBotMediaPreviews(int clientId, const std::string& paramsJson);
void setBotName(int clientId, const std::string& paramsJson);
void getBotName(int clientId, const std::string& paramsJson);
void setBotProfilePhoto(int clientId, const std::string& paramsJson);
void toggleBotUsernameIsActive(int clientId, const std::string& paramsJson);
void reorderBotActiveUsernames(int clientId, const std::string& paramsJson);
void setBotInfoDescription(int clientId, const std::string& paramsJson);
void getBotInfoDescription(int clientId, const std::string& paramsJson);
void setBotInfoShortDescription(int clientId, const std::string& paramsJson);
void getBotInfoShortDescription(int clientId, const std::string& paramsJson);
void setMessageSenderBotVerification(int clientId, const std::string& paramsJson);
void removeMessageSenderBotVerification(int clientId, const std::string& paramsJson);

// ==================== 会话与网站 ====================
void getActiveSessions(int clientId, const std::string& paramsJson);
void terminateSession(int clientId, const std::string& paramsJson);
void terminateAllOtherSessions(int clientId, const std::string& paramsJson);
void confirmSession(int clientId, const std::string& paramsJson);
void toggleSessionCanAcceptCalls(int clientId, const std::string& paramsJson);
void toggleSessionCanAcceptSecretChats(int clientId, const std::string& paramsJson);
void setInactiveSessionTtl(int clientId, const std::string& paramsJson);
void getConnectedWebsites(int clientId, const std::string& paramsJson);
void disconnectWebsite(int clientId, const std::string& paramsJson);
void disconnectAllWebsites(int clientId, const std::string& paramsJson);

// ==================== 超级群组管理 ====================
void setSupergroupUsername(int clientId, const std::string& paramsJson);
void toggleSupergroupUsernameIsActive(int clientId, const std::string& paramsJson);
void disableAllSupergroupUsernames(int clientId, const std::string& paramsJson);
void reorderSupergroupActiveUsernames(int clientId, const std::string& paramsJson);
void setSupergroupStickerSet(int clientId, const std::string& paramsJson);
void setSupergroupCustomEmojiStickerSet(int clientId, const std::string& paramsJson);
void setSupergroupUnrestrictBoostCount(int clientId, const std::string& paramsJson);
void setSupergroupMainProfileTab(int clientId, const std::string& paramsJson);
void toggleSupergroupSignMessages(int clientId, const std::string& paramsJson);
void toggleSupergroupJoinToSendMessages(int clientId, const std::string& paramsJson);
void toggleSupergroupJoinByRequest(int clientId, const std::string& paramsJson);
void toggleSupergroupIsAllHistoryAvailable(int clientId, const std::string& paramsJson);
void toggleSupergroupCanHaveSponsoredMessages(int clientId, const std::string& paramsJson);
void toggleSupergroupHasAutomaticTranslation(int clientId, const std::string& paramsJson);
void toggleSupergroupHasHiddenMembers(int clientId, const std::string& paramsJson);
void toggleSupergroupHasAggressiveAntiSpamEnabled(int clientId, const std::string& paramsJson);
void toggleSupergroupIsForum(int clientId, const std::string& paramsJson);
void toggleSupergroupIsBroadcastGroup(int clientId, const std::string& paramsJson);
void reportSupergroupSpam(int clientId, const std::string& paramsJson);
void reportSupergroupAntiSpamFalsePositive(int clientId, const std::string& paramsJson);
void getSupergroupMembers(int clientId, const std::string& paramsJson);
void closeSecretChat(int clientId, const std::string& paramsJson);
void getChatEventLog(int clientId, const std::string& paramsJson);

// ==================== 时区 ====================
void getTimeZones(int clientId, const std::string& paramsJson);

// ==================== 支付与星币 ====================
void getPaymentForm(int clientId, const std::string& paramsJson);
void validateOrderInfo(int clientId, const std::string& paramsJson);
void sendPaymentForm(int clientId, const std::string& paramsJson);
void getPaymentReceipt(int clientId, const std::string& paramsJson);
void getSavedOrderInfo(int clientId, const std::string& paramsJson);
void deleteSavedOrderInfo(int clientId, const std::string& paramsJson);
void deleteSavedCredentials(int clientId, const std::string& paramsJson);
void setGiftSettings(int clientId, const std::string& paramsJson);
void getAvailableGifts(int clientId, const std::string& paramsJson);
void canSendGift(int clientId, const std::string& paramsJson);
void sendGift(int clientId, const std::string& paramsJson);
void getGiftAuctionState(int clientId, const std::string& paramsJson);
void getGiftAuctionAcquiredGifts(int clientId, const std::string& paramsJson);
void openGiftAuction(int clientId, const std::string& paramsJson);
void closeGiftAuction(int clientId, const std::string& paramsJson);
void placeGiftAuctionBid(int clientId, const std::string& paramsJson);
void increaseGiftAuctionBid(int clientId, const std::string& paramsJson);
void sellGift(int clientId, const std::string& paramsJson);
void toggleGiftIsSaved(int clientId, const std::string& paramsJson);
void setPinnedGifts(int clientId, const std::string& paramsJson);
void toggleChatGiftNotifications(int clientId, const std::string& paramsJson);
void getGiftUpgradePreview(int clientId, const std::string& paramsJson);
void getUpgradedGiftVariants(int clientId, const std::string& paramsJson);
void upgradeGift(int clientId, const std::string& paramsJson);
void buyGiftUpgrade(int clientId, const std::string& paramsJson);
void craftGift(int clientId, const std::string& paramsJson);
void transferGift(int clientId, const std::string& paramsJson);
void dropGiftOriginalDetails(int clientId, const std::string& paramsJson);
void sendResoldGift(int clientId, const std::string& paramsJson);
void sendGiftPurchaseOffer(int clientId, const std::string& paramsJson);
void processGiftPurchaseOffer(int clientId, const std::string& paramsJson);
void getReceivedGifts(int clientId, const std::string& paramsJson);
void getReceivedGift(int clientId, const std::string& paramsJson);
void getGiftsForCrafting(int clientId, const std::string& paramsJson);
void getUpgradedGift(int clientId, const std::string& paramsJson);
void getUpgradedGiftValueInfo(int clientId, const std::string& paramsJson);
void getUpgradedGiftWithdrawalUrl(int clientId, const std::string& paramsJson);
void getUpgradedGiftsPromotionalAnimation(int clientId, const std::string& paramsJson);
void setGiftResalePrice(int clientId, const std::string& paramsJson);
void searchGiftsForResale(int clientId, const std::string& paramsJson);
void getGiftCollections(int clientId, const std::string& paramsJson);
void createGiftCollection(int clientId, const std::string& paramsJson);
void reorderGiftCollections(int clientId, const std::string& paramsJson);
void deleteGiftCollection(int clientId, const std::string& paramsJson);
void setGiftCollectionName(int clientId, const std::string& paramsJson);
void addGiftCollectionGifts(int clientId, const std::string& paramsJson);
void removeGiftCollectionGifts(int clientId, const std::string& paramsJson);
void reorderGiftCollectionGifts(int clientId, const std::string& paramsJson);
void createInvoiceLink(int clientId, const std::string& paramsJson);
void refundStarPayment(int clientId, const std::string& paramsJson);
void getSupportUser(int clientId, const std::string& paramsJson);

// ==================== 背景 ====================
void getBackgroundUrl(int clientId, const std::string& paramsJson);
void searchBackground(int clientId, const std::string& paramsJson);
void setDefaultBackground(int clientId, const std::string& paramsJson);
void deleteDefaultBackground(int clientId, const std::string& paramsJson);
void getInstalledBackgrounds(int clientId, const std::string& paramsJson);
void removeInstalledBackground(int clientId, const std::string& paramsJson);
void resetInstalledBackgrounds(int clientId, const std::string& paramsJson);

// ==================== 本地化 ====================
void getLocalizationTargetInfo(int clientId, const std::string& paramsJson);
void getLanguagePackInfo(int clientId, const std::string& paramsJson);
void getLanguagePackStrings(int clientId, const std::string& paramsJson);
void synchronizeLanguagePack(int clientId, const std::string& paramsJson);
void addCustomServerLanguagePack(int clientId, const std::string& paramsJson);
void setCustomLanguagePack(int clientId, const std::string& paramsJson);
void editCustomLanguagePackInfo(int clientId, const std::string& paramsJson);
void setCustomLanguagePackString(int clientId, const std::string& paramsJson);
void deleteLanguagePack(int clientId, const std::string& paramsJson);

// ==================== 推送通知 ====================
void registerDevice(int clientId, const std::string& paramsJson);
void processPushNotification(int clientId, const std::string& paramsJson);
void getPushReceiverId(int clientId, const std::string& paramsJson);
void getRecentlyVisitedTMeUrls(int clientId, const std::string& paramsJson);

// ==================== 隐私设置 ====================
void setUserPrivacySettingRules(int clientId, const std::string& paramsJson);
void getUserPrivacySettingRules(int clientId, const std::string& paramsJson);
void setReadDatePrivacySettings(int clientId, const std::string& paramsJson);
void getReadDatePrivacySettings(int clientId, const std::string& paramsJson);
void setNewChatPrivacySettings(int clientId, const std::string& paramsJson);
void getNewChatPrivacySettings(int clientId, const std::string& paramsJson);

// ==================== 付费消息与收入 ====================
void getPaidMessageRevenue(int clientId, const std::string& paramsJson);
void allowUnpaidMessagesFromUser(int clientId, const std::string& paramsJson);
void setChatPaidMessageStarCount(int clientId, const std::string& paramsJson);
void canSendMessageToUser(int clientId, const std::string& paramsJson);
void getOption(int clientId, const std::string& paramsJson);
void setOption(int clientId, const std::string& paramsJson);
void setAccountTtl(int clientId, const std::string& paramsJson);
void getAccountTtl(int clientId, const std::string& paramsJson);
void deleteAccount(int clientId, const std::string& paramsJson);
void setDefaultMessageAutoDeleteTime(int clientId, const std::string& paramsJson);
void getDefaultMessageAutoDeleteTime(int clientId, const std::string& paramsJson);
void removeChatActionBar(int clientId, const std::string& paramsJson);
void reportChat(int clientId, const std::string& paramsJson);
void reportChatPhoto(int clientId, const std::string& paramsJson);
void reportMessageReactions(int clientId, const std::string& paramsJson);
void getChatRevenueStatistics(int clientId, const std::string& paramsJson);
void getChatRevenueWithdrawalUrl(int clientId, const std::string& paramsJson);
void getChatRevenueTransactions(int clientId, const std::string& paramsJson);
void getTonTransactions(int clientId, const std::string& paramsJson);
void getStarRevenueStatistics(int clientId, const std::string& paramsJson);
void getStarWithdrawalUrl(int clientId, const std::string& paramsJson);
void getStarAdAccountUrl(int clientId, const std::string& paramsJson);
void getTonRevenueStatistics(int clientId, const std::string& paramsJson);
void getTonWithdrawalUrl(int clientId, const std::string& paramsJson);
void getChatStatistics(int clientId, const std::string& paramsJson);
void getMessageStatistics(int clientId, const std::string& paramsJson);
void getMessagePublicForwards(int clientId, const std::string& paramsJson);
void getStoryStatistics(int clientId, const std::string& paramsJson);
void getStatisticalGraph(int clientId, const std::string& paramsJson);
void getStorageStatistics(int clientId, const std::string& paramsJson);
void getStorageStatisticsFast(int clientId, const std::string& paramsJson);
void getDatabaseStatistics(int clientId, const std::string& paramsJson);
void optimizeStorage(int clientId, const std::string& paramsJson);
void setNetworkType(int clientId, const std::string& paramsJson);
void getNetworkStatistics(int clientId, const std::string& paramsJson);
void addNetworkStatistics(int clientId, const std::string& paramsJson);
void resetNetworkStatistics(int clientId, const std::string& paramsJson);
void getAutosaveSettings(int clientId, const std::string& paramsJson);
void setAutosaveSettings(int clientId, const std::string& paramsJson);
void clearAutosaveSettingsExceptions(int clientId, const std::string& paramsJson);
void getBankCardInfo(int clientId, const std::string& paramsJson);

// ==================== 证件信息 ====================
void getPassportElement(int clientId, const std::string& paramsJson);
void getAllPassportElements(int clientId, const std::string& paramsJson);
void setPassportElement(int clientId, const std::string& paramsJson);
void deletePassportElement(int clientId, const std::string& paramsJson);
void setPassportElementErrors(int clientId, const std::string& paramsJson);
void getPreferredCountryLanguage(int clientId, const std::string& paramsJson);
void sendEmailAddressVerificationCode(int clientId, const std::string& paramsJson);
void resendEmailAddressVerificationCode(int clientId, const std::string& paramsJson);
void checkEmailAddressVerificationCode(int clientId, const std::string& paramsJson);
void getPassportAuthorizationForm(int clientId, const std::string& paramsJson);
void getPassportAuthorizationFormAvailableElements(int clientId, const std::string& paramsJson);
void sendPassportAuthorizationForm(int clientId, const std::string& paramsJson);

// ==================== 机器人更新 ====================
void setBotUpdatesStatus(int clientId, const std::string& paramsJson);

// ==================== 贴纸集管理 ====================
void createNewStickerSet(int clientId, const std::string& paramsJson);
void addStickerToSet(int clientId, const std::string& paramsJson);
void replaceStickerInSet(int clientId, const std::string& paramsJson);
void setStickerSetThumbnail(int clientId, const std::string& paramsJson);
void setCustomEmojiStickerSetThumbnail(int clientId, const std::string& paramsJson);
void setStickerSetTitle(int clientId, const std::string& paramsJson);
void deleteStickerSet(int clientId, const std::string& paramsJson);
void setStickerPositionInSet(int clientId, const std::string& paramsJson);
void removeStickerFromSet(int clientId, const std::string& paramsJson);
void setStickerEmojis(int clientId, const std::string& paramsJson);
void setStickerKeywords(int clientId, const std::string& paramsJson);
void setStickerMaskPosition(int clientId, const std::string& paramsJson);
void getOwnedStickerSets(int clientId, const std::string& paramsJson);
void getPremiumLimit(int clientId, const std::string& paramsJson);
void getPremiumFeatures(int clientId, const std::string& paramsJson);
void getPremiumStickerExamples(int clientId, const std::string& paramsJson);
void getPremiumInfoSticker(int clientId, const std::string& paramsJson);
void viewPremiumFeature(int clientId, const std::string& paramsJson);
void clickPremiumSubscriptionButton(int clientId, const std::string& paramsJson);
void getPremiumState(int clientId, const std::string& paramsJson);
void getPremiumGiftPaymentOptions(int clientId, const std::string& paramsJson);
void getPremiumGiveawayPaymentOptions(int clientId, const std::string& paramsJson);
void checkPremiumGiftCode(int clientId, const std::string& paramsJson);
void applyPremiumGiftCode(int clientId, const std::string& paramsJson);
void giftPremiumWithStars(int clientId, const std::string& paramsJson);
void launchPrepaidGiveaway(int clientId, const std::string& paramsJson);
void getGiveawayInfo(int clientId, const std::string& paramsJson);
void getStarPaymentOptions(int clientId, const std::string& paramsJson);
void getStarGiftPaymentOptions(int clientId, const std::string& paramsJson);
void getStarGiveawayPaymentOptions(int clientId, const std::string& paramsJson);
void getStarTransactions(int clientId, const std::string& paramsJson);
void getStarSubscriptions(int clientId, const std::string& paramsJson);
void canPurchaseFromStore(int clientId, const std::string& paramsJson);
void assignStoreTransaction(int clientId, const std::string& paramsJson);
void editStarSubscription(int clientId, const std::string& paramsJson);
void editUserStarSubscription(int clientId, const std::string& paramsJson);
void reuseStarSubscription(int clientId, const std::string& paramsJson);

// ==================== 联盟计划 ====================
void setChatAffiliateProgram(int clientId, const std::string& paramsJson);
void searchChatAffiliateProgram(int clientId, const std::string& paramsJson);
void searchAffiliatePrograms(int clientId, const std::string& paramsJson);
void connectAffiliateProgram(int clientId, const std::string& paramsJson);
void disconnectAffiliateProgram(int clientId, const std::string& paramsJson);
void getConnectedAffiliateProgram(int clientId, const std::string& paramsJson);
void getConnectedAffiliatePrograms(int clientId, const std::string& paramsJson);
void getBusinessFeatures(int clientId, const std::string& paramsJson);

// ==================== 服务条款 ====================
void acceptTermsOfService(int clientId, const std::string& paramsJson);
void searchStringsByPrefix(int clientId, const std::string& paramsJson);
void sendCustomRequest(int clientId, const std::string& paramsJson);
void answerCustomQuery(int clientId, const std::string& paramsJson);
void setAlarm(int clientId, const std::string& paramsJson);
void getCountries(int clientId, const std::string& paramsJson);
void getCountryCode(int clientId, const std::string& paramsJson);
void getPhoneNumberInfo(int clientId, const std::string& paramsJson);
void getPhoneNumberInfoSync(int clientId, const std::string& paramsJson);
void getCollectibleItemInfo(int clientId, const std::string& paramsJson);
void getDeepLinkInfo(int clientId, const std::string& paramsJson);
void getApplicationConfig(int clientId, const std::string& paramsJson);
void saveApplicationLogEvent(int clientId, const std::string& paramsJson);

// ==================== 代理 ====================
void addProxy(int clientId, const std::string& paramsJson);
void editProxy(int clientId, const std::string& paramsJson);
void enableProxy(int clientId, const std::string& paramsJson);
void disableProxy(int clientId, const std::string& paramsJson);
void removeProxy(int clientId, const std::string& paramsJson);
void getProxies(int clientId, const std::string& paramsJson);
void pingProxy(int clientId, const std::string& paramsJson);

// ==================== 日志 ====================
void setLogStream(int clientId, const std::string& paramsJson);
void getLogStream(int clientId, const std::string& paramsJson);
void setLogVerbosityLevel(int clientId, const std::string& paramsJson);
void getLogVerbosityLevel(int clientId, const std::string& paramsJson);
void getLogTags(int clientId, const std::string& paramsJson);
void setLogTagVerbosityLevel(int clientId, const std::string& paramsJson);
void getLogTagVerbosityLevel(int clientId, const std::string& paramsJson);
void addLogMessage(int clientId, const std::string& paramsJson);

// ==================== 支持 ====================
void getUserSupportInfo(int clientId, const std::string& paramsJson);
void setUserSupportInfo(int clientId, const std::string& paramsJson);
void getSupportName(int clientId, const std::string& paramsJson);

// ==================== 测试方法 ====================
void testCallEmpty(int clientId, const std::string& paramsJson);
void testCallString(int clientId, const std::string& paramsJson);
void testCallBytes(int clientId, const std::string& paramsJson);
void testCallVectorInt(int clientId, const std::string& paramsJson);
void testCallVectorIntObject(int clientId, const std::string& paramsJson);
void testCallVectorString(int clientId, const std::string& paramsJson);
void testCallVectorStringObject(int clientId, const std::string& paramsJson);
void testSquareInt(int clientId, const std::string& paramsJson);
void testNetwork(int clientId, const std::string& paramsJson);
void testProxy(int clientId, const std::string& paramsJson);
void testGetDifference(int clientId, const std::string& paramsJson);
void testUseUpdate(int clientId, const std::string& paramsJson);

} // namespace api
} // namespace tdlib