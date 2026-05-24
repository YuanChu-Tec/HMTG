/**
 * TDLib API 完整实现（所有方法）
 * 每个函数：接收 (clientId, paramsJson: string) → 调用 tdlib::sendRequest
 */
#include "TDLibApi.h"
#include "../../utils/JsonHelper.h"   // 假设 JsonHelper 提供必要的工具

namespace tdlib {
namespace api {

// ==================== 认证与授权 ====================
void getAuthorizationState(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getAuthorizationState", paramsJson);
}
void setTdlibParameters(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setTdlibParameters", paramsJson);
}
void setAuthenticationPhoneNumber(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setAuthenticationPhoneNumber", paramsJson);
}
void checkAuthenticationPremiumPurchase(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "checkAuthenticationPremiumPurchase", paramsJson);
}
void setAuthenticationPremiumPurchaseTransaction(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setAuthenticationPremiumPurchaseTransaction", paramsJson);
}
void setAuthenticationEmailAddress(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setAuthenticationEmailAddress", paramsJson);
}
void resendAuthenticationCode(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "resendAuthenticationCode", paramsJson);
}
void checkAuthenticationEmailCode(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "checkAuthenticationEmailCode", paramsJson);
}
void checkAuthenticationCode(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "checkAuthenticationCode", paramsJson);
}
void requestQrCodeAuthentication(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "requestQrCodeAuthentication", paramsJson);
}
void getAuthenticationPasskeyParameters(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getAuthenticationPasskeyParameters", paramsJson);
}
void checkAuthenticationPasskey(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "checkAuthenticationPasskey", paramsJson);
}
void registerUser(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "registerUser", paramsJson);
}
void resetAuthenticationEmailAddress(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "resetAuthenticationEmailAddress", paramsJson);
}
void checkAuthenticationPassword(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "checkAuthenticationPassword", paramsJson);
}
void requestAuthenticationPasswordRecovery(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "requestAuthenticationPasswordRecovery", paramsJson);
}
void checkAuthenticationPasswordRecoveryCode(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "checkAuthenticationPasswordRecoveryCode", paramsJson);
}
void recoverAuthenticationPassword(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "recoverAuthenticationPassword", paramsJson);
}
void sendAuthenticationFirebaseSms(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendAuthenticationFirebaseSms", paramsJson);
}
void reportAuthenticationCodeMissing(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reportAuthenticationCodeMissing", paramsJson);
}
void checkAuthenticationBotToken(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "checkAuthenticationBotToken", paramsJson);
}
void logOut(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "logOut", paramsJson);
}
void close(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "close", paramsJson);
}
void destroy(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "destroy", paramsJson);
}
void confirmQrCodeAuthentication(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "confirmQrCodeAuthentication", paramsJson);
}
void getCurrentState(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getCurrentState", paramsJson);
}
void setDatabaseEncryptionKey(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setDatabaseEncryptionKey", paramsJson);
}
void getPasswordState(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPasswordState", paramsJson);
}
void setPassword(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setPassword", paramsJson);
}
void isLoginEmailAddressRequired(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "isLoginEmailAddressRequired", paramsJson);
}
void setLoginEmailAddress(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setLoginEmailAddress", paramsJson);
}
void resendLoginEmailAddressCode(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "resendLoginEmailAddressCode", paramsJson);
}
void checkLoginEmailAddressCode(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "checkLoginEmailAddressCode", paramsJson);
}
void getRecoveryEmailAddress(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getRecoveryEmailAddress", paramsJson);
}
void setRecoveryEmailAddress(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setRecoveryEmailAddress", paramsJson);
}
void checkRecoveryEmailAddressCode(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "checkRecoveryEmailAddressCode", paramsJson);
}
void resendRecoveryEmailAddressCode(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "resendRecoveryEmailAddressCode", paramsJson);
}
void cancelRecoveryEmailAddressVerification(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "cancelRecoveryEmailAddressVerification", paramsJson);
}
void requestPasswordRecovery(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "requestPasswordRecovery", paramsJson);
}
void checkPasswordRecoveryCode(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "checkPasswordRecoveryCode", paramsJson);
}
void recoverPassword(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "recoverPassword", paramsJson);
}
void resetPassword(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "resetPassword", paramsJson);
}
void cancelPasswordReset(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "cancelPasswordReset", paramsJson);
}
void createTemporaryPassword(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createTemporaryPassword", paramsJson);
}
void getTemporaryPasswordState(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getTemporaryPasswordState", paramsJson);
}

// ==================== 用户与个人资料 ====================
void getMe(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMe", paramsJson);
}
void getUser(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getUser", paramsJson);
}
void getUserFullInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getUserFullInfo", paramsJson);
}
void getBasicGroup(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getBasicGroup", paramsJson);
}
void getBasicGroupFullInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getBasicGroupFullInfo", paramsJson);
}
void getSupergroup(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getSupergroup", paramsJson);
}
void getSupergroupFullInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getSupergroupFullInfo", paramsJson);
}
void getSecretChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getSecretChat", paramsJson);
}
void getUserProfilePhotos(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getUserProfilePhotos", paramsJson);
}
void getUserProfileAudios(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getUserProfileAudios", paramsJson);
}
void isProfileAudio(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "isProfileAudio", paramsJson);
}
void addProfileAudio(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addProfileAudio", paramsJson);
}
void setProfileAudioPosition(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setProfileAudioPosition", paramsJson);
}
void removeProfileAudio(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeProfileAudio", paramsJson);
}
void setUserPersonalProfilePhoto(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setUserPersonalProfilePhoto", paramsJson);
}
void setUserNote(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setUserNote", paramsJson);
}
void suggestUserProfilePhoto(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "suggestUserProfilePhoto", paramsJson);
}
void suggestUserBirthdate(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "suggestUserBirthdate", paramsJson);
}
void toggleBotCanManageEmojiStatus(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleBotCanManageEmojiStatus", paramsJson);
}
void setUserEmojiStatus(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setUserEmojiStatus", paramsJson);
}
void searchUserByPhoneNumber(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchUserByPhoneNumber", paramsJson);
}
void sharePhoneNumber(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sharePhoneNumber", paramsJson);
}
void setProfilePhoto(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setProfilePhoto", paramsJson);
}
void deleteProfilePhoto(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteProfilePhoto", paramsJson);
}
void setAccentColor(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setAccentColor", paramsJson);
}
void setUpgradedGiftColors(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setUpgradedGiftColors", paramsJson);
}
void setProfileAccentColor(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setProfileAccentColor", paramsJson);
}
void setName(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setName", paramsJson);
}
void setBio(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setBio", paramsJson);
}
void setUsername(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setUsername", paramsJson);
}
void toggleUsernameIsActive(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleUsernameIsActive", paramsJson);
}
void reorderActiveUsernames(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reorderActiveUsernames", paramsJson);
}
void setBirthdate(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setBirthdate", paramsJson);
}
void setMainProfileTab(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setMainProfileTab", paramsJson);
}
void setPersonalChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setPersonalChat", paramsJson);
}
void setEmojiStatus(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setEmojiStatus", paramsJson);
}
void toggleHasSponsoredMessagesEnabled(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleHasSponsoredMessagesEnabled", paramsJson);
}
void setBusinessLocation(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setBusinessLocation", paramsJson);
}
void setBusinessOpeningHours(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setBusinessOpeningHours", paramsJson);
}
void setBusinessGreetingMessageSettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setBusinessGreetingMessageSettings", paramsJson);
}
void setBusinessAwayMessageSettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setBusinessAwayMessageSettings", paramsJson);
}
void setBusinessStartPage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setBusinessStartPage", paramsJson);
}
void getBusinessConnectedBot(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getBusinessConnectedBot", paramsJson);
}
void setBusinessConnectedBot(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setBusinessConnectedBot", paramsJson);
}
void deleteBusinessConnectedBot(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteBusinessConnectedBot", paramsJson);
}
void toggleBusinessConnectedBotChatIsPaused(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleBusinessConnectedBotChatIsPaused", paramsJson);
}
void removeBusinessConnectedBotFromChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeBusinessConnectedBotFromChat", paramsJson);
}
void getBusinessChatLinks(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getBusinessChatLinks", paramsJson);
}
void createBusinessChatLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createBusinessChatLink", paramsJson);
}
void editBusinessChatLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editBusinessChatLink", paramsJson);
}
void deleteBusinessChatLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteBusinessChatLink", paramsJson);
}
void getBusinessChatLinkInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getBusinessChatLinkInfo", paramsJson);
}
void getUserLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getUserLink", paramsJson);
}
void searchUserByToken(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchUserByToken", paramsJson);
}

// ==================== 聊天管理 ====================
void getChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChat", paramsJson);
}
void getMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMessage", paramsJson);
}
void getMessageLocally(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMessageLocally", paramsJson);
}
void getRepliedMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getRepliedMessage", paramsJson);
}
void getChatPinnedMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatPinnedMessage", paramsJson);
}
void getCallbackQueryMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getCallbackQueryMessage", paramsJson);
}
void getMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMessages", paramsJson);
}
void getMessageProperties(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMessageProperties", paramsJson);
}
void getMessageThread(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMessageThread", paramsJson);
}
void getMessageReadDate(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMessageReadDate", paramsJson);
}
void getMessageViewers(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMessageViewers", paramsJson);
}
void getMessageAuthor(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMessageAuthor", paramsJson);
}
void loadChats(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "loadChats", paramsJson);
}
void getChats(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChats", paramsJson);
}
void searchPublicChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchPublicChat", paramsJson);
}
void searchPublicChats(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchPublicChats", paramsJson);
}
void searchChats(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchChats", paramsJson);
}
void searchChatsOnServer(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchChatsOnServer", paramsJson);
}
void getRecommendedChats(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getRecommendedChats", paramsJson);
}
void getChatSimilarChats(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatSimilarChats", paramsJson);
}
void getChatSimilarChatCount(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatSimilarChatCount", paramsJson);
}
void openChatSimilarChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "openChatSimilarChat", paramsJson);
}
void getBotSimilarBots(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getBotSimilarBots", paramsJson);
}
void getBotSimilarBotCount(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getBotSimilarBotCount", paramsJson);
}
void openBotSimilarBot(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "openBotSimilarBot", paramsJson);
}
void getTopChats(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getTopChats", paramsJson);
}
void removeTopChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeTopChat", paramsJson);
}
void searchRecentlyFoundChats(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchRecentlyFoundChats", paramsJson);
}
void addRecentlyFoundChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addRecentlyFoundChat", paramsJson);
}
void removeRecentlyFoundChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeRecentlyFoundChat", paramsJson);
}
void clearRecentlyFoundChats(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "clearRecentlyFoundChats", paramsJson);
}
void getRecentlyOpenedChats(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getRecentlyOpenedChats", paramsJson);
}
void checkChatUsername(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "checkChatUsername", paramsJson);
}
void getCreatedPublicChats(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getCreatedPublicChats", paramsJson);
}
void checkCreatedPublicChatsLimit(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "checkCreatedPublicChatsLimit", paramsJson);
}
void getSuitableDiscussionChats(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getSuitableDiscussionChats", paramsJson);
}
void getInactiveSupergroupChats(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getInactiveSupergroupChats", paramsJson);
}
void getSuitablePersonalChats(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getSuitablePersonalChats", paramsJson);
}
void loadDirectMessagesChatTopics(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "loadDirectMessagesChatTopics", paramsJson);
}
void getDirectMessagesChatTopic(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getDirectMessagesChatTopic", paramsJson);
}
void getDirectMessagesChatTopicHistory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getDirectMessagesChatTopicHistory", paramsJson);
}
void getDirectMessagesChatTopicMessageByDate(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getDirectMessagesChatTopicMessageByDate", paramsJson);
}
void deleteDirectMessagesChatTopicHistory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteDirectMessagesChatTopicHistory", paramsJson);
}
void deleteDirectMessagesChatTopicMessagesByDate(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteDirectMessagesChatTopicMessagesByDate", paramsJson);
}
void setDirectMessagesChatTopicIsMarkedAsUnread(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setDirectMessagesChatTopicIsMarkedAsUnread", paramsJson);
}
void unpinAllDirectMessagesChatTopicMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "unpinAllDirectMessagesChatTopicMessages", paramsJson);
}
void readAllDirectMessagesChatTopicReactions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "readAllDirectMessagesChatTopicReactions", paramsJson);
}
void getDirectMessagesChatTopicRevenue(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getDirectMessagesChatTopicRevenue", paramsJson);
}
void toggleDirectMessagesChatTopicCanSendUnpaidMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleDirectMessagesChatTopicCanSendUnpaidMessages", paramsJson);
}
void loadSavedMessagesTopics(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "loadSavedMessagesTopics", paramsJson);
}
void getSavedMessagesTopicHistory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getSavedMessagesTopicHistory", paramsJson);
}
void getSavedMessagesTopicMessageByDate(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getSavedMessagesTopicMessageByDate", paramsJson);
}
void deleteSavedMessagesTopicHistory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteSavedMessagesTopicHistory", paramsJson);
}
void deleteSavedMessagesTopicMessagesByDate(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteSavedMessagesTopicMessagesByDate", paramsJson);
}
void toggleSavedMessagesTopicIsPinned(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleSavedMessagesTopicIsPinned", paramsJson);
}
void setPinnedSavedMessagesTopics(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setPinnedSavedMessagesTopics", paramsJson);
}
void getGroupsInCommon(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getGroupsInCommon", paramsJson);
}
void getChatHistory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatHistory", paramsJson);
}
void getMessageThreadHistory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMessageThreadHistory", paramsJson);
}
void deleteChatHistory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteChatHistory", paramsJson);
}
void deleteChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteChat", paramsJson);
}
void searchChatMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchChatMessages", paramsJson);
}
void searchMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchMessages", paramsJson);
}
void searchSecretMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchSecretMessages", paramsJson);
}
void searchSavedMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchSavedMessages", paramsJson);
}
void searchCallMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchCallMessages", paramsJson);
}
void searchOutgoingDocumentMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchOutgoingDocumentMessages", paramsJson);
}
void getPublicPostSearchLimits(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPublicPostSearchLimits", paramsJson);
}
void searchPublicPosts(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchPublicPosts", paramsJson);
}
void searchPublicMessagesByTag(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchPublicMessagesByTag", paramsJson);
}
void searchPublicStoriesByTag(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchPublicStoriesByTag", paramsJson);
}
void searchPublicStoriesByLocation(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchPublicStoriesByLocation", paramsJson);
}
void searchPublicStoriesByVenue(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchPublicStoriesByVenue", paramsJson);
}
void getSearchedForTags(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getSearchedForTags", paramsJson);
}
void removeSearchedForTag(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeSearchedForTag", paramsJson);
}
void clearSearchedForTags(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "clearSearchedForTags", paramsJson);
}
void deleteAllCallMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteAllCallMessages", paramsJson);
}
void searchChatRecentLocationMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchChatRecentLocationMessages", paramsJson);
}
void getChatMessageByDate(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatMessageByDate", paramsJson);
}
void getChatSparseMessagePositions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatSparseMessagePositions", paramsJson);
}
void getChatMessageCalendar(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatMessageCalendar", paramsJson);
}
void getChatMessageCount(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatMessageCount", paramsJson);
}
void getChatMessagePosition(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatMessagePosition", paramsJson);
}
void getChatScheduledMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatScheduledMessages", paramsJson);
}
void getChatSponsoredMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatSponsoredMessages", paramsJson);
}
void clickChatSponsoredMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "clickChatSponsoredMessage", paramsJson);
}
void reportChatSponsoredMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reportChatSponsoredMessage", paramsJson);
}
void getSearchSponsoredChats(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getSearchSponsoredChats", paramsJson);
}
void viewSponsoredChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "viewSponsoredChat", paramsJson);
}
void openSponsoredChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "openSponsoredChat", paramsJson);
}
void reportSponsoredChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reportSponsoredChat", paramsJson);
}
void getVideoMessageAdvertisements(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getVideoMessageAdvertisements", paramsJson);
}
void viewVideoMessageAdvertisement(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "viewVideoMessageAdvertisement", paramsJson);
}
void clickVideoMessageAdvertisement(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "clickVideoMessageAdvertisement", paramsJson);
}
void reportVideoMessageAdvertisement(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reportVideoMessageAdvertisement", paramsJson);
}
void removeNotification(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeNotification", paramsJson);
}
void removeNotificationGroup(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeNotificationGroup", paramsJson);
}
void getMessageLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMessageLink", paramsJson);
}
void getMessageEmbeddingCode(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMessageEmbeddingCode", paramsJson);
}
void getMessageLinkInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMessageLinkInfo", paramsJson);
}
void translateText(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "translateText", paramsJson);
}
void translateMessageText(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "translateMessageText", paramsJson);
}
void summarizeMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "summarizeMessage", paramsJson);
}
void recognizeSpeech(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "recognizeSpeech", paramsJson);
}
void rateSpeechRecognition(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "rateSpeechRecognition", paramsJson);
}
void getChatAvailableMessageSenders(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatAvailableMessageSenders", paramsJson);
}
void setChatMessageSender(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatMessageSender", paramsJson);
}

// ==================== 消息操作 ====================
void sendMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendMessage", paramsJson);
}
void sendMessageAlbum(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendMessageAlbum", paramsJson);
}
void sendBotStartMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendBotStartMessage", paramsJson);
}
void sendInlineQueryResultMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendInlineQueryResultMessage", paramsJson);
}
void forwardMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "forwardMessages", paramsJson);
}
void sendQuickReplyShortcutMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendQuickReplyShortcutMessages", paramsJson);
}
void resendMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "resendMessages", paramsJson);
}
void addLocalMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addLocalMessage", paramsJson);
}
void deleteMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteMessages", paramsJson);
}
void deleteChatMessagesBySender(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteChatMessagesBySender", paramsJson);
}
void deleteChatMessagesByDate(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteChatMessagesByDate", paramsJson);
}
void editMessageText(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editMessageText", paramsJson);
}
void editMessageLiveLocation(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editMessageLiveLocation", paramsJson);
}
void editMessageChecklist(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editMessageChecklist", paramsJson);
}
void editMessageMedia(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editMessageMedia", paramsJson);
}
void editMessageCaption(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editMessageCaption", paramsJson);
}
void editMessageReplyMarkup(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editMessageReplyMarkup", paramsJson);
}
void editInlineMessageText(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editInlineMessageText", paramsJson);
}
void editInlineMessageLiveLocation(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editInlineMessageLiveLocation", paramsJson);
}
void editInlineMessageMedia(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editInlineMessageMedia", paramsJson);
}
void editInlineMessageCaption(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editInlineMessageCaption", paramsJson);
}
void editInlineMessageReplyMarkup(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editInlineMessageReplyMarkup", paramsJson);
}
void editMessageSchedulingState(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editMessageSchedulingState", paramsJson);
}
void setMessageFactCheck(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setMessageFactCheck", paramsJson);
}
void sendBusinessMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendBusinessMessage", paramsJson);
}
void sendBusinessMessageAlbum(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendBusinessMessageAlbum", paramsJson);
}
void editBusinessMessageText(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editBusinessMessageText", paramsJson);
}
void editBusinessMessageLiveLocation(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editBusinessMessageLiveLocation", paramsJson);
}
void editBusinessMessageChecklist(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editBusinessMessageChecklist", paramsJson);
}
void editBusinessMessageMedia(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editBusinessMessageMedia", paramsJson);
}
void editBusinessMessageCaption(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editBusinessMessageCaption", paramsJson);
}
void editBusinessMessageReplyMarkup(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editBusinessMessageReplyMarkup", paramsJson);
}
void stopBusinessPoll(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "stopBusinessPoll", paramsJson);
}
void setBusinessMessageIsPinned(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setBusinessMessageIsPinned", paramsJson);
}
void readBusinessMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "readBusinessMessage", paramsJson);
}
void deleteBusinessMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteBusinessMessages", paramsJson);
}
void editBusinessStory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editBusinessStory", paramsJson);
}
void deleteBusinessStory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteBusinessStory", paramsJson);
}
void setBusinessAccountName(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setBusinessAccountName", paramsJson);
}
void setBusinessAccountBio(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setBusinessAccountBio", paramsJson);
}
void setBusinessAccountProfilePhoto(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setBusinessAccountProfilePhoto", paramsJson);
}
void setBusinessAccountUsername(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setBusinessAccountUsername", paramsJson);
}
void setBusinessAccountGiftSettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setBusinessAccountGiftSettings", paramsJson);
}
void getBusinessAccountStarAmount(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getBusinessAccountStarAmount", paramsJson);
}
void transferBusinessAccountStars(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "transferBusinessAccountStars", paramsJson);
}
void checkQuickReplyShortcutName(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "checkQuickReplyShortcutName", paramsJson);
}
void loadQuickReplyShortcuts(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "loadQuickReplyShortcuts", paramsJson);
}
void setQuickReplyShortcutName(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setQuickReplyShortcutName", paramsJson);
}
void deleteQuickReplyShortcut(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteQuickReplyShortcut", paramsJson);
}
void reorderQuickReplyShortcuts(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reorderQuickReplyShortcuts", paramsJson);
}
void loadQuickReplyShortcutMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "loadQuickReplyShortcutMessages", paramsJson);
}
void deleteQuickReplyShortcutMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteQuickReplyShortcutMessages", paramsJson);
}
void addQuickReplyShortcutMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addQuickReplyShortcutMessage", paramsJson);
}
void addQuickReplyShortcutInlineQueryResultMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addQuickReplyShortcutInlineQueryResultMessage", paramsJson);
}
void addQuickReplyShortcutMessageAlbum(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addQuickReplyShortcutMessageAlbum", paramsJson);
}
void readdQuickReplyShortcutMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "readdQuickReplyShortcutMessages", paramsJson);
}
void editQuickReplyMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editQuickReplyMessage", paramsJson);
}
void getForumTopicDefaultIcons(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getForumTopicDefaultIcons", paramsJson);
}
void createForumTopic(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createForumTopic", paramsJson);
}
void editForumTopic(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editForumTopic", paramsJson);
}
void getForumTopic(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getForumTopic", paramsJson);
}
void getForumTopicHistory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getForumTopicHistory", paramsJson);
}
void getForumTopicLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getForumTopicLink", paramsJson);
}
void getForumTopics(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getForumTopics", paramsJson);
}
void setForumTopicNotificationSettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setForumTopicNotificationSettings", paramsJson);
}
void toggleForumTopicIsClosed(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleForumTopicIsClosed", paramsJson);
}
void toggleGeneralForumTopicIsHidden(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleGeneralForumTopicIsHidden", paramsJson);
}
void toggleForumTopicIsPinned(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleForumTopicIsPinned", paramsJson);
}
void setPinnedForumTopics(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setPinnedForumTopics", paramsJson);
}
void deleteForumTopic(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteForumTopic", paramsJson);
}
void readAllForumTopicMentions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "readAllForumTopicMentions", paramsJson);
}
void readAllForumTopicReactions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "readAllForumTopicReactions", paramsJson);
}
void unpinAllForumTopicMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "unpinAllForumTopicMessages", paramsJson);
}

// ==================== 反应与表情 ====================
void getPasskeyParameters(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPasskeyParameters", paramsJson);
}
void addLoginPasskey(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addLoginPasskey", paramsJson);
}
void getLoginPasskeys(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getLoginPasskeys", paramsJson);
}
void removeLoginPasskey(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeLoginPasskey", paramsJson);
}
void getEmojiReaction(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getEmojiReaction", paramsJson);
}
void getCustomEmojiReactionAnimations(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getCustomEmojiReactionAnimations", paramsJson);
}
void getMessageAvailableReactions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMessageAvailableReactions", paramsJson);
}
void clearRecentReactions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "clearRecentReactions", paramsJson);
}
void addMessageReaction(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addMessageReaction", paramsJson);
}
void removeMessageReaction(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeMessageReaction", paramsJson);
}
void getChatAvailablePaidMessageReactionSenders(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatAvailablePaidMessageReactionSenders", paramsJson);
}
void addPendingPaidMessageReaction(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addPendingPaidMessageReaction", paramsJson);
}
void commitPendingPaidMessageReactions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "commitPendingPaidMessageReactions", paramsJson);
}
void removePendingPaidMessageReactions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removePendingPaidMessageReactions", paramsJson);
}
void setPaidMessageReactionType(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setPaidMessageReactionType", paramsJson);
}
void setMessageReactions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setMessageReactions", paramsJson);
}
void getMessageAddedReactions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMessageAddedReactions", paramsJson);
}
void setDefaultReactionType(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setDefaultReactionType", paramsJson);
}
void getSavedMessagesTags(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getSavedMessagesTags", paramsJson);
}
void setSavedMessagesTagLabel(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setSavedMessagesTagLabel", paramsJson);
}
void getMessageEffect(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMessageEffect", paramsJson);
}
void searchQuote(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchQuote", paramsJson);
}

// ==================== 文本处理 ====================
void getTextEntities(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getTextEntities", paramsJson);
}
void parseTextEntities(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "parseTextEntities", paramsJson);
}
void parseMarkdown(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "parseMarkdown", paramsJson);
}
void getMarkdownText(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMarkdownText", paramsJson);
}
void getCountryFlagEmoji(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getCountryFlagEmoji", paramsJson);
}
void getFileMimeType(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getFileMimeType", paramsJson);
}
void getFileExtension(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getFileExtension", paramsJson);
}
void cleanFileName(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "cleanFileName", paramsJson);
}
void getLanguagePackString(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getLanguagePackString", paramsJson);
}
void getJsonValue(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getJsonValue", paramsJson);
}
void getJsonString(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getJsonString", paramsJson);
}
void getThemeParametersJsonString(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getThemeParametersJsonString", paramsJson);
}

// ==================== 投票与清单 ====================
void setPollAnswer(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setPollAnswer", paramsJson);
}
void getPollVoters(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPollVoters", paramsJson);
}
void stopPoll(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "stopPoll", paramsJson);
}
void addChecklistTasks(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addChecklistTasks", paramsJson);
}
void markChecklistTasksAsDone(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "markChecklistTasksAsDone", paramsJson);
}

// ==================== 建议操作 ====================
void hideSuggestedAction(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "hideSuggestedAction", paramsJson);
}
void hideContactCloseBirthdays(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "hideContactCloseBirthdays", paramsJson);
}

// ==================== 业务连接 ====================
void getBusinessConnection(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getBusinessConnection", paramsJson);
}

// ==================== 登录 URL ====================
void getLoginUrlInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getLoginUrlInfo", paramsJson);
}
void getLoginUrl(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getLoginUrl", paramsJson);
}
void shareUsersWithBot(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "shareUsersWithBot", paramsJson);
}
void shareChatWithBot(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "shareChatWithBot", paramsJson);
}

// ==================== 内联查询 ====================
void getInlineQueryResults(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getInlineQueryResults", paramsJson);
}
void answerInlineQuery(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "answerInlineQuery", paramsJson);
}
void savePreparedInlineMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "savePreparedInlineMessage", paramsJson);
}
void getPreparedInlineMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPreparedInlineMessage", paramsJson);
}

// ==================== Web 应用 ====================
void getGrossingWebAppBots(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getGrossingWebAppBots", paramsJson);
}
void searchWebApp(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchWebApp", paramsJson);
}
void getWebAppPlaceholder(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getWebAppPlaceholder", paramsJson);
}
void getWebAppLinkUrl(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getWebAppLinkUrl", paramsJson);
}
void getMainWebApp(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMainWebApp", paramsJson);
}
void getWebAppUrl(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getWebAppUrl", paramsJson);
}
void sendWebAppData(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendWebAppData", paramsJson);
}
void openWebApp(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "openWebApp", paramsJson);
}
void closeWebApp(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "closeWebApp", paramsJson);
}
void answerWebAppQuery(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "answerWebAppQuery", paramsJson);
}
void checkWebAppFileDownload(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "checkWebAppFileDownload", paramsJson);
}

// ==================== 回调查询 ====================
void getCallbackQueryAnswer(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getCallbackQueryAnswer", paramsJson);
}
void answerCallbackQuery(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "answerCallbackQuery", paramsJson);
}
void answerShippingQuery(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "answerShippingQuery", paramsJson);
}
void answerPreCheckoutQuery(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "answerPreCheckoutQuery", paramsJson);
}

// ==================== 游戏 ====================
void setGameScore(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setGameScore", paramsJson);
}
void setInlineGameScore(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setInlineGameScore", paramsJson);
}
void getGameHighScores(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getGameHighScores", paramsJson);
}
void getInlineGameHighScores(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getInlineGameHighScores", paramsJson);
}

// ==================== 聊天操作 ====================
void deleteChatReplyMarkup(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteChatReplyMarkup", paramsJson);
}
void sendChatAction(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendChatAction", paramsJson);
}
void sendTextMessageDraft(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendTextMessageDraft", paramsJson);
}
void openChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "openChat", paramsJson);
}
void closeChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "closeChat", paramsJson);
}
void viewMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "viewMessages", paramsJson);
}
void openMessageContent(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "openMessageContent", paramsJson);
}
void clickAnimatedEmojiMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "clickAnimatedEmojiMessage", paramsJson);
}
void getInternalLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getInternalLink", paramsJson);
}
void getInternalLinkType(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getInternalLinkType", paramsJson);
}
void getExternalLinkInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getExternalLinkInfo", paramsJson);
}
void getExternalLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getExternalLink", paramsJson);
}
void readAllChatMentions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "readAllChatMentions", paramsJson);
}
void readAllChatReactions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "readAllChatReactions", paramsJson);
}

// ==================== 创建聊天 ====================
void createPrivateChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createPrivateChat", paramsJson);
}
void createBasicGroupChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createBasicGroupChat", paramsJson);
}
void createSupergroupChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createSupergroupChat", paramsJson);
}
void createSecretChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createSecretChat", paramsJson);
}
void createNewBasicGroupChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createNewBasicGroupChat", paramsJson);
}
void createNewSupergroupChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createNewSupergroupChat", paramsJson);
}
void createNewSecretChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createNewSecretChat", paramsJson);
}
void upgradeBasicGroupChatToSupergroupChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "upgradeBasicGroupChatToSupergroupChat", paramsJson);
}

// ==================== 聊天列表与文件夹 ====================
void getChatListsToAddChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatListsToAddChat", paramsJson);
}
void addChatToList(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addChatToList", paramsJson);
}
void getChatFolder(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatFolder", paramsJson);
}
void createChatFolder(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createChatFolder", paramsJson);
}
void editChatFolder(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editChatFolder", paramsJson);
}
void deleteChatFolder(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteChatFolder", paramsJson);
}
void getChatFolderChatsToLeave(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatFolderChatsToLeave", paramsJson);
}
void getChatFolderChatCount(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatFolderChatCount", paramsJson);
}
void reorderChatFolders(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reorderChatFolders", paramsJson);
}
void toggleChatFolderTags(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleChatFolderTags", paramsJson);
}
void getRecommendedChatFolders(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getRecommendedChatFolders", paramsJson);
}
void getChatFolderDefaultIconName(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatFolderDefaultIconName", paramsJson);
}
void getChatsForChatFolderInviteLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatsForChatFolderInviteLink", paramsJson);
}
void createChatFolderInviteLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createChatFolderInviteLink", paramsJson);
}
void getChatFolderInviteLinks(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatFolderInviteLinks", paramsJson);
}
void editChatFolderInviteLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editChatFolderInviteLink", paramsJson);
}
void deleteChatFolderInviteLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteChatFolderInviteLink", paramsJson);
}
void checkChatFolderInviteLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "checkChatFolderInviteLink", paramsJson);
}
void addChatFolderByInviteLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addChatFolderByInviteLink", paramsJson);
}
void getChatFolderNewChats(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatFolderNewChats", paramsJson);
}
void processChatFolderNewChats(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "processChatFolderNewChats", paramsJson);
}
void getArchiveChatListSettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getArchiveChatListSettings", paramsJson);
}
void setArchiveChatListSettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setArchiveChatListSettings", paramsJson);
}
void setChatTitle(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatTitle", paramsJson);
}
void setChatPhoto(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatPhoto", paramsJson);
}
void setChatAccentColor(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatAccentColor", paramsJson);
}
void setChatProfileAccentColor(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatProfileAccentColor", paramsJson);
}
void setChatMessageAutoDeleteTime(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatMessageAutoDeleteTime", paramsJson);
}
void setChatEmojiStatus(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatEmojiStatus", paramsJson);
}
void setChatPermissions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatPermissions", paramsJson);
}
void setChatBackground(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatBackground", paramsJson);
}
void deleteChatBackground(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteChatBackground", paramsJson);
}
void getGiftChatThemes(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getGiftChatThemes", paramsJson);
}
void setChatTheme(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatTheme", paramsJson);
}
void setChatDraftMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatDraftMessage", paramsJson);
}
void setChatNotificationSettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatNotificationSettings", paramsJson);
}
void toggleChatHasProtectedContent(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleChatHasProtectedContent", paramsJson);
}
void toggleChatViewAsTopics(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleChatViewAsTopics", paramsJson);
}
void toggleChatIsTranslatable(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleChatIsTranslatable", paramsJson);
}
void toggleChatIsMarkedAsUnread(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleChatIsMarkedAsUnread", paramsJson);
}
void toggleChatDefaultDisableNotification(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleChatDefaultDisableNotification", paramsJson);
}
void setChatAvailableReactions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatAvailableReactions", paramsJson);
}
void setChatClientData(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatClientData", paramsJson);
}
void setChatDescription(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatDescription", paramsJson);
}
void setChatDiscussionGroup(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatDiscussionGroup", paramsJson);
}
void setChatDirectMessagesGroup(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatDirectMessagesGroup", paramsJson);
}
void setChatLocation(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatLocation", paramsJson);
}
void setChatSlowModeDelay(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatSlowModeDelay", paramsJson);
}
void pinChatMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "pinChatMessage", paramsJson);
}
void unpinChatMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "unpinChatMessage", paramsJson);
}
void unpinAllChatMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "unpinAllChatMessages", paramsJson);
}
void joinChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "joinChat", paramsJson);
}
void leaveChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "leaveChat", paramsJson);
}
void addChatMember(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addChatMember", paramsJson);
}
void addChatMembers(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addChatMembers", paramsJson);
}
void setChatMemberStatus(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatMemberStatus", paramsJson);
}
void banChatMember(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "banChatMember", paramsJson);
}
void canTransferOwnership(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "canTransferOwnership", paramsJson);
}
void transferChatOwnership(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "transferChatOwnership", paramsJson);
}
void getChatOwnerAfterLeaving(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatOwnerAfterLeaving", paramsJson);
}
void getChatMember(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatMember", paramsJson);
}
void searchChatMembers(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchChatMembers", paramsJson);
}
void getChatAdministrators(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatAdministrators", paramsJson);
}
void clearAllDraftMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "clearAllDraftMessages", paramsJson);
}
void getStakeDiceState(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStakeDiceState", paramsJson);
}

// ==================== 通知设置 ====================
void getSavedNotificationSound(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getSavedNotificationSound", paramsJson);
}
void getSavedNotificationSounds(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getSavedNotificationSounds", paramsJson);
}
void addSavedNotificationSound(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addSavedNotificationSound", paramsJson);
}
void removeSavedNotificationSound(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeSavedNotificationSound", paramsJson);
}
void getChatNotificationSettingsExceptions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatNotificationSettingsExceptions", paramsJson);
}
void getScopeNotificationSettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getScopeNotificationSettings", paramsJson);
}
void setScopeNotificationSettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setScopeNotificationSettings", paramsJson);
}
void setReactionNotificationSettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setReactionNotificationSettings", paramsJson);
}
void resetAllNotificationSettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "resetAllNotificationSettings", paramsJson);
}
void toggleChatIsPinned(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleChatIsPinned", paramsJson);
}
void setPinnedChats(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setPinnedChats", paramsJson);
}
void readChatList(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "readChatList", paramsJson);
}

// ==================== 天气 ====================
void getCurrentWeather(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getCurrentWeather", paramsJson);
}

// ==================== 故事 ====================
void getStory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStory", paramsJson);
}
void getChatsToPostStories(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatsToPostStories", paramsJson);
}
void canPostStory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "canPostStory", paramsJson);
}
void postStory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "postStory", paramsJson);
}
void startLiveStory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "startLiveStory", paramsJson);
}
void editStory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editStory", paramsJson);
}
void editStoryCover(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editStoryCover", paramsJson);
}
void setStoryPrivacySettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setStoryPrivacySettings", paramsJson);
}
void toggleStoryIsPostedToChatPage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleStoryIsPostedToChatPage", paramsJson);
}
void deleteStory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteStory", paramsJson);
}
void getStoryNotificationSettingsExceptions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStoryNotificationSettingsExceptions", paramsJson);
}
void loadActiveStories(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "loadActiveStories", paramsJson);
}
void setChatActiveStoriesList(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatActiveStoriesList", paramsJson);
}
void getChatActiveStories(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatActiveStories", paramsJson);
}
void getChatPostedToChatPageStories(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatPostedToChatPageStories", paramsJson);
}
void getChatArchivedStories(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatArchivedStories", paramsJson);
}
void setChatPinnedStories(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatPinnedStories", paramsJson);
}
void openStory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "openStory", paramsJson);
}
void closeStory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "closeStory", paramsJson);
}
void getStoryAvailableReactions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStoryAvailableReactions", paramsJson);
}
void setStoryReaction(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setStoryReaction", paramsJson);
}
void getStoryInteractions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStoryInteractions", paramsJson);
}
void getChatStoryInteractions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatStoryInteractions", paramsJson);
}
void reportStory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reportStory", paramsJson);
}
void activateStoryStealthMode(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "activateStoryStealthMode", paramsJson);
}
void getStoryPublicForwards(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStoryPublicForwards", paramsJson);
}
void getChatStoryAlbums(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatStoryAlbums", paramsJson);
}
void getStoryAlbumStories(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStoryAlbumStories", paramsJson);
}
void createStoryAlbum(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createStoryAlbum", paramsJson);
}
void reorderStoryAlbums(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reorderStoryAlbums", paramsJson);
}
void deleteStoryAlbum(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteStoryAlbum", paramsJson);
}
void setStoryAlbumName(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setStoryAlbumName", paramsJson);
}
void addStoryAlbumStories(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addStoryAlbumStories", paramsJson);
}
void removeStoryAlbumStories(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeStoryAlbumStories", paramsJson);
}
void reorderStoryAlbumStories(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reorderStoryAlbumStories", paramsJson);
}

// ==================== 提升与增强 ====================
void getChatBoostLevelFeatures(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatBoostLevelFeatures", paramsJson);
}
void getChatBoostFeatures(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatBoostFeatures", paramsJson);
}
void getAvailableChatBoostSlots(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getAvailableChatBoostSlots", paramsJson);
}
void getChatBoostStatus(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatBoostStatus", paramsJson);
}
void boostChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "boostChat", paramsJson);
}
void getChatBoostLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatBoostLink", paramsJson);
}
void getChatBoostLinkInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatBoostLinkInfo", paramsJson);
}
void getChatBoosts(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatBoosts", paramsJson);
}
void getUserChatBoosts(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getUserChatBoosts", paramsJson);
}

// ==================== 附件菜单机器人 ====================
void getAttachmentMenuBot(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getAttachmentMenuBot", paramsJson);
}
void toggleBotIsAddedToAttachmentMenu(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleBotIsAddedToAttachmentMenu", paramsJson);
}

// ==================== 表情状态 ====================
void getThemedEmojiStatuses(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getThemedEmojiStatuses", paramsJson);
}
void getRecentEmojiStatuses(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getRecentEmojiStatuses", paramsJson);
}
void getUpgradedGiftEmojiStatuses(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getUpgradedGiftEmojiStatuses", paramsJson);
}
void getDefaultEmojiStatuses(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getDefaultEmojiStatuses", paramsJson);
}
void clearRecentEmojiStatuses(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "clearRecentEmojiStatuses", paramsJson);
}
void getThemedChatEmojiStatuses(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getThemedChatEmojiStatuses", paramsJson);
}
void getDefaultChatEmojiStatuses(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getDefaultChatEmojiStatuses", paramsJson);
}
void getDisallowedChatEmojiStatuses(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getDisallowedChatEmojiStatuses", paramsJson);
}

// ==================== 文件操作 ====================
void getFile(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getFile", paramsJson);
}
void getRemoteFile(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getRemoteFile", paramsJson);
}
void readFilePart(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "readFilePart", paramsJson);
}
void getFileDownloadedPrefixSize(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getFileDownloadedPrefixSize", paramsJson);
}
void downloadFile(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "downloadFile", paramsJson);
}
void cancelDownloadFile(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "cancelDownloadFile", paramsJson);
}
void preliminaryUploadFile(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "preliminaryUploadFile", paramsJson);
}
void cancelPreliminaryUploadFile(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "cancelPreliminaryUploadFile", paramsJson);
}
void writeGeneratedFilePart(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "writeGeneratedFilePart", paramsJson);
}
void setFileGenerationProgress(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setFileGenerationProgress", paramsJson);
}
void finishFileGeneration(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "finishFileGeneration", paramsJson);
}
void getSuggestedFileName(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getSuggestedFileName", paramsJson);
}
void deleteFile(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteFile", paramsJson);
}
void addFileToDownloads(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addFileToDownloads", paramsJson);
}
void toggleDownloadIsPaused(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleDownloadIsPaused", paramsJson);
}
void toggleAllDownloadsArePaused(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleAllDownloadsArePaused", paramsJson);
}
void removeFileFromDownloads(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeFileFromDownloads", paramsJson);
}
void removeAllFilesFromDownloads(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeAllFilesFromDownloads", paramsJson);
}
void searchFileDownloads(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchFileDownloads", paramsJson);
}
void getAutoDownloadSettingsPresets(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getAutoDownloadSettingsPresets", paramsJson);
}
void setAutoDownloadSettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setAutoDownloadSettings", paramsJson);
}
void uploadStickerFile(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "uploadStickerFile", paramsJson);
}
void getMapThumbnailFile(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMapThumbnailFile", paramsJson);
}
void getApplicationDownloadLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getApplicationDownloadLink", paramsJson);
}

// ==================== 应用验证 ====================
void setApplicationVerificationToken(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setApplicationVerificationToken", paramsJson);
}
void getMessageFileType(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMessageFileType", paramsJson);
}
void getMessageImportConfirmationText(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMessageImportConfirmationText", paramsJson);
}
void importMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "importMessages", paramsJson);
}

// ==================== 邀请链接 ====================
void replacePrimaryChatInviteLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "replacePrimaryChatInviteLink", paramsJson);
}
void createChatInviteLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createChatInviteLink", paramsJson);
}
void createChatSubscriptionInviteLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createChatSubscriptionInviteLink", paramsJson);
}
void editChatInviteLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editChatInviteLink", paramsJson);
}
void editChatSubscriptionInviteLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editChatSubscriptionInviteLink", paramsJson);
}
void getChatInviteLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatInviteLink", paramsJson);
}
void getChatInviteLinkCounts(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatInviteLinkCounts", paramsJson);
}
void getChatInviteLinks(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatInviteLinks", paramsJson);
}
void getChatInviteLinkMembers(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatInviteLinkMembers", paramsJson);
}
void revokeChatInviteLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "revokeChatInviteLink", paramsJson);
}
void deleteRevokedChatInviteLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteRevokedChatInviteLink", paramsJson);
}
void deleteAllRevokedChatInviteLinks(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteAllRevokedChatInviteLinks", paramsJson);
}
void checkChatInviteLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "checkChatInviteLink", paramsJson);
}
void joinChatByInviteLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "joinChatByInviteLink", paramsJson);
}
void getChatJoinRequests(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatJoinRequests", paramsJson);
}
void processChatJoinRequest(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "processChatJoinRequest", paramsJson);
}
void processChatJoinRequests(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "processChatJoinRequests", paramsJson);
}
void approveSuggestedPost(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "approveSuggestedPost", paramsJson);
}
void declineSuggestedPost(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "declineSuggestedPost", paramsJson);
}
void addOffer(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addOffer", paramsJson);
}

// ==================== 通话与视频聊天 ====================
void createCall(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createCall", paramsJson);
}
void acceptCall(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "acceptCall", paramsJson);
}
void sendCallSignalingData(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendCallSignalingData", paramsJson);
}
void discardCall(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "discardCall", paramsJson);
}
void sendCallRating(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendCallRating", paramsJson);
}
void sendCallDebugInformation(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendCallDebugInformation", paramsJson);
}
void sendCallLog(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendCallLog", paramsJson);
}
void getVideoChatAvailableParticipants(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getVideoChatAvailableParticipants", paramsJson);
}
void setVideoChatDefaultParticipant(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setVideoChatDefaultParticipant", paramsJson);
}
void createVideoChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createVideoChat", paramsJson);
}
void createGroupCall(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createGroupCall", paramsJson);
}
void getVideoChatRtmpUrl(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getVideoChatRtmpUrl", paramsJson);
}
void replaceVideoChatRtmpUrl(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "replaceVideoChatRtmpUrl", paramsJson);
}
void getLiveStoryRtmpUrl(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getLiveStoryRtmpUrl", paramsJson);
}
void replaceLiveStoryRtmpUrl(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "replaceLiveStoryRtmpUrl", paramsJson);
}
void getGroupCall(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getGroupCall", paramsJson);
}
void startScheduledVideoChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "startScheduledVideoChat", paramsJson);
}
void toggleVideoChatEnabledStartNotification(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleVideoChatEnabledStartNotification", paramsJson);
}
void joinGroupCall(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "joinGroupCall", paramsJson);
}
void joinVideoChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "joinVideoChat", paramsJson);
}
void joinLiveStory(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "joinLiveStory", paramsJson);
}
void startGroupCallScreenSharing(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "startGroupCallScreenSharing", paramsJson);
}
void toggleGroupCallScreenSharingIsPaused(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleGroupCallScreenSharingIsPaused", paramsJson);
}
void endGroupCallScreenSharing(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "endGroupCallScreenSharing", paramsJson);
}
void setVideoChatTitle(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setVideoChatTitle", paramsJson);
}
void toggleVideoChatMuteNewParticipants(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleVideoChatMuteNewParticipants", paramsJson);
}
void toggleGroupCallAreMessagesAllowed(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleGroupCallAreMessagesAllowed", paramsJson);
}
void getLiveStoryStreamer(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getLiveStoryStreamer", paramsJson);
}
void getLiveStoryAvailableMessageSenders(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getLiveStoryAvailableMessageSenders", paramsJson);
}
void setLiveStoryMessageSender(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setLiveStoryMessageSender", paramsJson);
}
void sendGroupCallMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendGroupCallMessage", paramsJson);
}
void addPendingLiveStoryReaction(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addPendingLiveStoryReaction", paramsJson);
}
void commitPendingLiveStoryReactions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "commitPendingLiveStoryReactions", paramsJson);
}
void removePendingLiveStoryReactions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removePendingLiveStoryReactions", paramsJson);
}
void deleteGroupCallMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteGroupCallMessages", paramsJson);
}
void deleteGroupCallMessagesBySender(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteGroupCallMessagesBySender", paramsJson);
}
void getLiveStoryTopDonors(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getLiveStoryTopDonors", paramsJson);
}
void inviteGroupCallParticipant(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "inviteGroupCallParticipant", paramsJson);
}
void declineGroupCallInvitation(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "declineGroupCallInvitation", paramsJson);
}
void banGroupCallParticipants(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "banGroupCallParticipants", paramsJson);
}
void inviteVideoChatParticipants(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "inviteVideoChatParticipants", paramsJson);
}
void getVideoChatInviteLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getVideoChatInviteLink", paramsJson);
}
void revokeGroupCallInviteLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "revokeGroupCallInviteLink", paramsJson);
}
void startGroupCallRecording(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "startGroupCallRecording", paramsJson);
}
void endGroupCallRecording(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "endGroupCallRecording", paramsJson);
}
void toggleGroupCallIsMyVideoPaused(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleGroupCallIsMyVideoPaused", paramsJson);
}
void toggleGroupCallIsMyVideoEnabled(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleGroupCallIsMyVideoEnabled", paramsJson);
}
void setGroupCallPaidMessageStarCount(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setGroupCallPaidMessageStarCount", paramsJson);
}
void setGroupCallParticipantIsSpeaking(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setGroupCallParticipantIsSpeaking", paramsJson);
}
void toggleGroupCallParticipantIsMuted(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleGroupCallParticipantIsMuted", paramsJson);
}
void setGroupCallParticipantVolumeLevel(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setGroupCallParticipantVolumeLevel", paramsJson);
}
void toggleGroupCallParticipantIsHandRaised(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleGroupCallParticipantIsHandRaised", paramsJson);
}
void getGroupCallParticipants(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getGroupCallParticipants", paramsJson);
}
void loadGroupCallParticipants(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "loadGroupCallParticipants", paramsJson);
}
void leaveGroupCall(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "leaveGroupCall", paramsJson);
}
void endGroupCall(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "endGroupCall", paramsJson);
}
void getGroupCallStreams(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getGroupCallStreams", paramsJson);
}
void getGroupCallStreamSegment(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getGroupCallStreamSegment", paramsJson);
}
void encryptGroupCallData(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "encryptGroupCallData", paramsJson);
}
void decryptGroupCallData(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "decryptGroupCallData", paramsJson);
}

// ==================== 封禁与联系人 ====================
void setMessageSenderBlockList(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setMessageSenderBlockList", paramsJson);
}
void blockMessageSenderFromReplies(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "blockMessageSenderFromReplies", paramsJson);
}
void getBlockedMessageSenders(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getBlockedMessageSenders", paramsJson);
}
void addContact(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addContact", paramsJson);
}
void importContacts(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "importContacts", paramsJson);
}
void getContacts(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getContacts", paramsJson);
}
void searchContacts(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchContacts", paramsJson);
}
void removeContacts(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeContacts", paramsJson);
}
void getImportedContactCount(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getImportedContactCount", paramsJson);
}
void changeImportedContacts(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "changeImportedContacts", paramsJson);
}
void clearImportedContacts(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "clearImportedContacts", paramsJson);
}
void setCloseFriends(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setCloseFriends", paramsJson);
}
void getCloseFriends(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getCloseFriends", paramsJson);
}

// ==================== 贴纸与表情 ====================
void getStickerOutline(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStickerOutline", paramsJson);
}
void getStickerOutlineSvgPath(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStickerOutlineSvgPath", paramsJson);
}
void getStickers(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStickers", paramsJson);
}
void getAllStickerEmojis(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getAllStickerEmojis", paramsJson);
}
void searchStickers(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchStickers", paramsJson);
}
void getGreetingStickers(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getGreetingStickers", paramsJson);
}
void getPremiumStickers(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPremiumStickers", paramsJson);
}
void getInstalledStickerSets(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getInstalledStickerSets", paramsJson);
}
void getArchivedStickerSets(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getArchivedStickerSets", paramsJson);
}
void getTrendingStickerSets(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getTrendingStickerSets", paramsJson);
}
void getAttachedStickerSets(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getAttachedStickerSets", paramsJson);
}
void getStickerSet(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStickerSet", paramsJson);
}
void getStickerSetName(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStickerSetName", paramsJson);
}
void searchStickerSet(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchStickerSet", paramsJson);
}
void searchInstalledStickerSets(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchInstalledStickerSets", paramsJson);
}
void searchStickerSets(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchStickerSets", paramsJson);
}
void changeStickerSet(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "changeStickerSet", paramsJson);
}
void viewTrendingStickerSets(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "viewTrendingStickerSets", paramsJson);
}
void reorderInstalledStickerSets(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reorderInstalledStickerSets", paramsJson);
}
void getRecentStickers(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getRecentStickers", paramsJson);
}
void addRecentSticker(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addRecentSticker", paramsJson);
}
void removeRecentSticker(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeRecentSticker", paramsJson);
}
void clearRecentStickers(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "clearRecentStickers", paramsJson);
}
void getFavoriteStickers(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getFavoriteStickers", paramsJson);
}
void addFavoriteSticker(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addFavoriteSticker", paramsJson);
}
void removeFavoriteSticker(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeFavoriteSticker", paramsJson);
}
void getStickerEmojis(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStickerEmojis", paramsJson);
}
void searchEmojis(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchEmojis", paramsJson);
}
void getKeywordEmojis(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getKeywordEmojis", paramsJson);
}
void getEmojiCategories(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getEmojiCategories", paramsJson);
}
void getAnimatedEmoji(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getAnimatedEmoji", paramsJson);
}
void getEmojiSuggestionsUrl(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getEmojiSuggestionsUrl", paramsJson);
}
void getCustomEmojiStickers(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getCustomEmojiStickers", paramsJson);
}
void getDefaultChatPhotoCustomEmojiStickers(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getDefaultChatPhotoCustomEmojiStickers", paramsJson);
}
void getDefaultProfilePhotoCustomEmojiStickers(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getDefaultProfilePhotoCustomEmojiStickers", paramsJson);
}
void getDefaultBackgroundCustomEmojiStickers(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getDefaultBackgroundCustomEmojiStickers", paramsJson);
}
void getSavedAnimations(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getSavedAnimations", paramsJson);
}
void addSavedAnimation(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addSavedAnimation", paramsJson);
}
void removeSavedAnimation(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeSavedAnimation", paramsJson);
}
void getRecentInlineBots(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getRecentInlineBots", paramsJson);
}
void getOwnedBots(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getOwnedBots", paramsJson);
}
void searchHashtags(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchHashtags", paramsJson);
}
void removeRecentHashtag(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeRecentHashtag", paramsJson);
}
void getLinkPreview(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getLinkPreview", paramsJson);
}
void getWebPageInstantView(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getWebPageInstantView", paramsJson);
}

// ==================== 机器人命令与菜单 ====================
void setCommands(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setCommands", paramsJson);
}
void deleteCommands(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteCommands", paramsJson);
}
void getCommands(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getCommands", paramsJson);
}
void setMenuButton(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setMenuButton", paramsJson);
}
void getMenuButton(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMenuButton", paramsJson);
}
void setDefaultGroupAdministratorRights(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setDefaultGroupAdministratorRights", paramsJson);
}
void setDefaultChannelAdministratorRights(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setDefaultChannelAdministratorRights", paramsJson);
}
void canBotSendMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "canBotSendMessages", paramsJson);
}
void allowBotToSendMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "allowBotToSendMessages", paramsJson);
}
void sendWebAppCustomRequest(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendWebAppCustomRequest", paramsJson);
}
void getBotMediaPreviews(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getBotMediaPreviews", paramsJson);
}
void getBotMediaPreviewInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getBotMediaPreviewInfo", paramsJson);
}
void addBotMediaPreview(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addBotMediaPreview", paramsJson);
}
void editBotMediaPreview(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editBotMediaPreview", paramsJson);
}
void reorderBotMediaPreviews(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reorderBotMediaPreviews", paramsJson);
}
void deleteBotMediaPreviews(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteBotMediaPreviews", paramsJson);
}
void setBotName(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setBotName", paramsJson);
}
void getBotName(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getBotName", paramsJson);
}
void setBotProfilePhoto(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setBotProfilePhoto", paramsJson);
}
void toggleBotUsernameIsActive(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleBotUsernameIsActive", paramsJson);
}
void reorderBotActiveUsernames(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reorderBotActiveUsernames", paramsJson);
}
void setBotInfoDescription(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setBotInfoDescription", paramsJson);
}
void getBotInfoDescription(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getBotInfoDescription", paramsJson);
}
void setBotInfoShortDescription(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setBotInfoShortDescription", paramsJson);
}
void getBotInfoShortDescription(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getBotInfoShortDescription", paramsJson);
}
void setMessageSenderBotVerification(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setMessageSenderBotVerification", paramsJson);
}
void removeMessageSenderBotVerification(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeMessageSenderBotVerification", paramsJson);
}

// ==================== 会话与网站 ====================
void getActiveSessions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getActiveSessions", paramsJson);
}
void terminateSession(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "terminateSession", paramsJson);
}
void terminateAllOtherSessions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "terminateAllOtherSessions", paramsJson);
}
void confirmSession(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "confirmSession", paramsJson);
}
void toggleSessionCanAcceptCalls(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleSessionCanAcceptCalls", paramsJson);
}
void toggleSessionCanAcceptSecretChats(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleSessionCanAcceptSecretChats", paramsJson);
}
void setInactiveSessionTtl(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setInactiveSessionTtl", paramsJson);
}
void getConnectedWebsites(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getConnectedWebsites", paramsJson);
}
void disconnectWebsite(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "disconnectWebsite", paramsJson);
}
void disconnectAllWebsites(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "disconnectAllWebsites", paramsJson);
}

// ==================== 超级群组管理 ====================
void setSupergroupUsername(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setSupergroupUsername", paramsJson);
}
void toggleSupergroupUsernameIsActive(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleSupergroupUsernameIsActive", paramsJson);
}
void disableAllSupergroupUsernames(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "disableAllSupergroupUsernames", paramsJson);
}
void reorderSupergroupActiveUsernames(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reorderSupergroupActiveUsernames", paramsJson);
}
void setSupergroupStickerSet(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setSupergroupStickerSet", paramsJson);
}
void setSupergroupCustomEmojiStickerSet(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setSupergroupCustomEmojiStickerSet", paramsJson);
}
void setSupergroupUnrestrictBoostCount(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setSupergroupUnrestrictBoostCount", paramsJson);
}
void setSupergroupMainProfileTab(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setSupergroupMainProfileTab", paramsJson);
}
void toggleSupergroupSignMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleSupergroupSignMessages", paramsJson);
}
void toggleSupergroupJoinToSendMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleSupergroupJoinToSendMessages", paramsJson);
}
void toggleSupergroupJoinByRequest(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleSupergroupJoinByRequest", paramsJson);
}
void toggleSupergroupIsAllHistoryAvailable(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleSupergroupIsAllHistoryAvailable", paramsJson);
}
void toggleSupergroupCanHaveSponsoredMessages(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleSupergroupCanHaveSponsoredMessages", paramsJson);
}
void toggleSupergroupHasAutomaticTranslation(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleSupergroupHasAutomaticTranslation", paramsJson);
}
void toggleSupergroupHasHiddenMembers(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleSupergroupHasHiddenMembers", paramsJson);
}
void toggleSupergroupHasAggressiveAntiSpamEnabled(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleSupergroupHasAggressiveAntiSpamEnabled", paramsJson);
}
void toggleSupergroupIsForum(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleSupergroupIsForum", paramsJson);
}
void toggleSupergroupIsBroadcastGroup(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleSupergroupIsBroadcastGroup", paramsJson);
}
void reportSupergroupSpam(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reportSupergroupSpam", paramsJson);
}
void reportSupergroupAntiSpamFalsePositive(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reportSupergroupAntiSpamFalsePositive", paramsJson);
}
void getSupergroupMembers(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getSupergroupMembers", paramsJson);
}
void closeSecretChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "closeSecretChat", paramsJson);
}
void getChatEventLog(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatEventLog", paramsJson);
}

// ==================== 时区 ====================
void getTimeZones(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getTimeZones", paramsJson);
}

// ==================== 支付与星币 ====================
void getPaymentForm(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPaymentForm", paramsJson);
}
void validateOrderInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "validateOrderInfo", paramsJson);
}
void sendPaymentForm(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendPaymentForm", paramsJson);
}
void getPaymentReceipt(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPaymentReceipt", paramsJson);
}
void getSavedOrderInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getSavedOrderInfo", paramsJson);
}
void deleteSavedOrderInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteSavedOrderInfo", paramsJson);
}
void deleteSavedCredentials(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteSavedCredentials", paramsJson);
}
void setGiftSettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setGiftSettings", paramsJson);
}
void getAvailableGifts(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getAvailableGifts", paramsJson);
}
void canSendGift(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "canSendGift", paramsJson);
}
void sendGift(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendGift", paramsJson);
}
void getGiftAuctionState(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getGiftAuctionState", paramsJson);
}
void getGiftAuctionAcquiredGifts(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getGiftAuctionAcquiredGifts", paramsJson);
}
void openGiftAuction(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "openGiftAuction", paramsJson);
}
void closeGiftAuction(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "closeGiftAuction", paramsJson);
}
void placeGiftAuctionBid(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "placeGiftAuctionBid", paramsJson);
}
void increaseGiftAuctionBid(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "increaseGiftAuctionBid", paramsJson);
}
void sellGift(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sellGift", paramsJson);
}
void toggleGiftIsSaved(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleGiftIsSaved", paramsJson);
}
void setPinnedGifts(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setPinnedGifts", paramsJson);
}
void toggleChatGiftNotifications(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "toggleChatGiftNotifications", paramsJson);
}
void getGiftUpgradePreview(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getGiftUpgradePreview", paramsJson);
}
void getUpgradedGiftVariants(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getUpgradedGiftVariants", paramsJson);
}
void upgradeGift(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "upgradeGift", paramsJson);
}
void buyGiftUpgrade(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "buyGiftUpgrade", paramsJson);
}
void craftGift(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "craftGift", paramsJson);
}
void transferGift(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "transferGift", paramsJson);
}
void dropGiftOriginalDetails(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "dropGiftOriginalDetails", paramsJson);
}
void sendResoldGift(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendResoldGift", paramsJson);
}
void sendGiftPurchaseOffer(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendGiftPurchaseOffer", paramsJson);
}
void processGiftPurchaseOffer(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "processGiftPurchaseOffer", paramsJson);
}
void getReceivedGifts(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getReceivedGifts", paramsJson);
}
void getReceivedGift(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getReceivedGift", paramsJson);
}
void getGiftsForCrafting(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getGiftsForCrafting", paramsJson);
}
void getUpgradedGift(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getUpgradedGift", paramsJson);
}
void getUpgradedGiftValueInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getUpgradedGiftValueInfo", paramsJson);
}
void getUpgradedGiftWithdrawalUrl(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getUpgradedGiftWithdrawalUrl", paramsJson);
}
void getUpgradedGiftsPromotionalAnimation(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getUpgradedGiftsPromotionalAnimation", paramsJson);
}
void setGiftResalePrice(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setGiftResalePrice", paramsJson);
}
void searchGiftsForResale(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchGiftsForResale", paramsJson);
}
void getGiftCollections(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getGiftCollections", paramsJson);
}
void createGiftCollection(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createGiftCollection", paramsJson);
}
void reorderGiftCollections(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reorderGiftCollections", paramsJson);
}
void deleteGiftCollection(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteGiftCollection", paramsJson);
}
void setGiftCollectionName(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setGiftCollectionName", paramsJson);
}
void addGiftCollectionGifts(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addGiftCollectionGifts", paramsJson);
}
void removeGiftCollectionGifts(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeGiftCollectionGifts", paramsJson);
}
void reorderGiftCollectionGifts(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reorderGiftCollectionGifts", paramsJson);
}
void createInvoiceLink(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createInvoiceLink", paramsJson);
}
void refundStarPayment(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "refundStarPayment", paramsJson);
}
void getSupportUser(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getSupportUser", paramsJson);
}

// ==================== 背景 ====================
void getBackgroundUrl(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getBackgroundUrl", paramsJson);
}
void searchBackground(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchBackground", paramsJson);
}
void setDefaultBackground(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setDefaultBackground", paramsJson);
}
void deleteDefaultBackground(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteDefaultBackground", paramsJson);
}
void getInstalledBackgrounds(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getInstalledBackgrounds", paramsJson);
}
void removeInstalledBackground(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeInstalledBackground", paramsJson);
}
void resetInstalledBackgrounds(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "resetInstalledBackgrounds", paramsJson);
}

// ==================== 本地化 ====================
void getLocalizationTargetInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getLocalizationTargetInfo", paramsJson);
}
void getLanguagePackInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getLanguagePackInfo", paramsJson);
}
void getLanguagePackStrings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getLanguagePackStrings", paramsJson);
}
void synchronizeLanguagePack(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "synchronizeLanguagePack", paramsJson);
}
void addCustomServerLanguagePack(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addCustomServerLanguagePack", paramsJson);
}
void setCustomLanguagePack(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setCustomLanguagePack", paramsJson);
}
void editCustomLanguagePackInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editCustomLanguagePackInfo", paramsJson);
}
void setCustomLanguagePackString(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setCustomLanguagePackString", paramsJson);
}
void deleteLanguagePack(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteLanguagePack", paramsJson);
}

// ==================== 推送通知 ====================
void registerDevice(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "registerDevice", paramsJson);
}
void processPushNotification(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "processPushNotification", paramsJson);
}
void getPushReceiverId(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPushReceiverId", paramsJson);
}
void getRecentlyVisitedTMeUrls(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getRecentlyVisitedTMeUrls", paramsJson);
}

// ==================== 隐私设置 ====================
void setUserPrivacySettingRules(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setUserPrivacySettingRules", paramsJson);
}
void getUserPrivacySettingRules(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getUserPrivacySettingRules", paramsJson);
}
void setReadDatePrivacySettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setReadDatePrivacySettings", paramsJson);
}
void getReadDatePrivacySettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getReadDatePrivacySettings", paramsJson);
}
void setNewChatPrivacySettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setNewChatPrivacySettings", paramsJson);
}
void getNewChatPrivacySettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getNewChatPrivacySettings", paramsJson);
}

// ==================== 付费消息与收入 ====================
void getPaidMessageRevenue(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPaidMessageRevenue", paramsJson);
}
void allowUnpaidMessagesFromUser(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "allowUnpaidMessagesFromUser", paramsJson);
}
void setChatPaidMessageStarCount(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatPaidMessageStarCount", paramsJson);
}
void canSendMessageToUser(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "canSendMessageToUser", paramsJson);
}
void getOption(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getOption", paramsJson);
}
void setOption(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setOption", paramsJson);
}
void setAccountTtl(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setAccountTtl", paramsJson);
}
void getAccountTtl(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getAccountTtl", paramsJson);
}
void deleteAccount(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteAccount", paramsJson);
}
void setDefaultMessageAutoDeleteTime(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setDefaultMessageAutoDeleteTime", paramsJson);
}
void getDefaultMessageAutoDeleteTime(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getDefaultMessageAutoDeleteTime", paramsJson);
}
void removeChatActionBar(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeChatActionBar", paramsJson);
}
void reportChat(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reportChat", paramsJson);
}
void reportChatPhoto(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reportChatPhoto", paramsJson);
}
void reportMessageReactions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reportMessageReactions", paramsJson);
}
void getChatRevenueStatistics(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatRevenueStatistics", paramsJson);
}
void getChatRevenueWithdrawalUrl(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatRevenueWithdrawalUrl", paramsJson);
}
void getChatRevenueTransactions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatRevenueTransactions", paramsJson);
}
void getTonTransactions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getTonTransactions", paramsJson);
}
void getStarRevenueStatistics(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStarRevenueStatistics", paramsJson);
}
void getStarWithdrawalUrl(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStarWithdrawalUrl", paramsJson);
}
void getStarAdAccountUrl(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStarAdAccountUrl", paramsJson);
}
void getTonRevenueStatistics(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getTonRevenueStatistics", paramsJson);
}
void getTonWithdrawalUrl(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getTonWithdrawalUrl", paramsJson);
}
void getChatStatistics(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getChatStatistics", paramsJson);
}
void getMessageStatistics(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMessageStatistics", paramsJson);
}
void getMessagePublicForwards(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getMessagePublicForwards", paramsJson);
}
void getStoryStatistics(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStoryStatistics", paramsJson);
}
void getStatisticalGraph(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStatisticalGraph", paramsJson);
}
void getStorageStatistics(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStorageStatistics", paramsJson);
}
void getStorageStatisticsFast(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStorageStatisticsFast", paramsJson);
}
void getDatabaseStatistics(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getDatabaseStatistics", paramsJson);
}
void optimizeStorage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "optimizeStorage", paramsJson);
}
void setNetworkType(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setNetworkType", paramsJson);
}
void getNetworkStatistics(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getNetworkStatistics", paramsJson);
}
void addNetworkStatistics(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addNetworkStatistics", paramsJson);
}
void resetNetworkStatistics(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "resetNetworkStatistics", paramsJson);
}
void getAutosaveSettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getAutosaveSettings", paramsJson);
}
void setAutosaveSettings(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setAutosaveSettings", paramsJson);
}
void clearAutosaveSettingsExceptions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "clearAutosaveSettingsExceptions", paramsJson);
}
void getBankCardInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getBankCardInfo", paramsJson);
}

// ==================== 证件信息 ====================
void getPassportElement(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPassportElement", paramsJson);
}
void getAllPassportElements(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getAllPassportElements", paramsJson);
}
void setPassportElement(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setPassportElement", paramsJson);
}
void deletePassportElement(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deletePassportElement", paramsJson);
}
void setPassportElementErrors(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setPassportElementErrors", paramsJson);
}
void getPreferredCountryLanguage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPreferredCountryLanguage", paramsJson);
}
void sendEmailAddressVerificationCode(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendEmailAddressVerificationCode", paramsJson);
}
void resendEmailAddressVerificationCode(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "resendEmailAddressVerificationCode", paramsJson);
}
void checkEmailAddressVerificationCode(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "checkEmailAddressVerificationCode", paramsJson);
}
void getPassportAuthorizationForm(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPassportAuthorizationForm", paramsJson);
}
void getPassportAuthorizationFormAvailableElements(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPassportAuthorizationFormAvailableElements", paramsJson);
}
void sendPassportAuthorizationForm(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendPassportAuthorizationForm", paramsJson);
}

// ==================== 机器人更新 ====================
void setBotUpdatesStatus(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setBotUpdatesStatus", paramsJson);
}

// ==================== 贴纸集管理 ====================
void createNewStickerSet(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "createNewStickerSet", paramsJson);
}
void addStickerToSet(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addStickerToSet", paramsJson);
}
void replaceStickerInSet(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "replaceStickerInSet", paramsJson);
}
void setStickerSetThumbnail(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setStickerSetThumbnail", paramsJson);
}
void setCustomEmojiStickerSetThumbnail(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setCustomEmojiStickerSetThumbnail", paramsJson);
}
void setStickerSetTitle(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setStickerSetTitle", paramsJson);
}
void deleteStickerSet(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "deleteStickerSet", paramsJson);
}
void setStickerPositionInSet(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setStickerPositionInSet", paramsJson);
}
void removeStickerFromSet(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeStickerFromSet", paramsJson);
}
void setStickerEmojis(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setStickerEmojis", paramsJson);
}
void setStickerKeywords(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setStickerKeywords", paramsJson);
}
void setStickerMaskPosition(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setStickerMaskPosition", paramsJson);
}
void getOwnedStickerSets(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getOwnedStickerSets", paramsJson);
}
void getPremiumLimit(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPremiumLimit", paramsJson);
}
void getPremiumFeatures(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPremiumFeatures", paramsJson);
}
void getPremiumStickerExamples(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPremiumStickerExamples", paramsJson);
}
void getPremiumInfoSticker(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPremiumInfoSticker", paramsJson);
}
void viewPremiumFeature(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "viewPremiumFeature", paramsJson);
}
void clickPremiumSubscriptionButton(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "clickPremiumSubscriptionButton", paramsJson);
}
void getPremiumState(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPremiumState", paramsJson);
}
void getPremiumGiftPaymentOptions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPremiumGiftPaymentOptions", paramsJson);
}
void getPremiumGiveawayPaymentOptions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPremiumGiveawayPaymentOptions", paramsJson);
}
void checkPremiumGiftCode(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "checkPremiumGiftCode", paramsJson);
}
void applyPremiumGiftCode(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "applyPremiumGiftCode", paramsJson);
}
void giftPremiumWithStars(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "giftPremiumWithStars", paramsJson);
}
void launchPrepaidGiveaway(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "launchPrepaidGiveaway", paramsJson);
}
void getGiveawayInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getGiveawayInfo", paramsJson);
}
void getStarPaymentOptions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStarPaymentOptions", paramsJson);
}
void getStarGiftPaymentOptions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStarGiftPaymentOptions", paramsJson);
}
void getStarGiveawayPaymentOptions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStarGiveawayPaymentOptions", paramsJson);
}
void getStarTransactions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStarTransactions", paramsJson);
}
void getStarSubscriptions(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getStarSubscriptions", paramsJson);
}
void canPurchaseFromStore(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "canPurchaseFromStore", paramsJson);
}
void assignStoreTransaction(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "assignStoreTransaction", paramsJson);
}
void editStarSubscription(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editStarSubscription", paramsJson);
}
void editUserStarSubscription(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editUserStarSubscription", paramsJson);
}
void reuseStarSubscription(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "reuseStarSubscription", paramsJson);
}

// ==================== 联盟计划 ====================
void setChatAffiliateProgram(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setChatAffiliateProgram", paramsJson);
}
void searchChatAffiliateProgram(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchChatAffiliateProgram", paramsJson);
}
void searchAffiliatePrograms(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchAffiliatePrograms", paramsJson);
}
void connectAffiliateProgram(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "connectAffiliateProgram", paramsJson);
}
void disconnectAffiliateProgram(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "disconnectAffiliateProgram", paramsJson);
}
void getConnectedAffiliateProgram(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getConnectedAffiliateProgram", paramsJson);
}
void getConnectedAffiliatePrograms(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getConnectedAffiliatePrograms", paramsJson);
}
void getBusinessFeatures(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getBusinessFeatures", paramsJson);
}

// ==================== 服务条款 ====================
void acceptTermsOfService(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "acceptTermsOfService", paramsJson);
}
void searchStringsByPrefix(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "searchStringsByPrefix", paramsJson);
}
void sendCustomRequest(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "sendCustomRequest", paramsJson);
}
void answerCustomQuery(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "answerCustomQuery", paramsJson);
}
void setAlarm(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setAlarm", paramsJson);
}
void getCountries(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getCountries", paramsJson);
}
void getCountryCode(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getCountryCode", paramsJson);
}
void getPhoneNumberInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPhoneNumberInfo", paramsJson);
}
void getPhoneNumberInfoSync(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getPhoneNumberInfoSync", paramsJson);
}
void getCollectibleItemInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getCollectibleItemInfo", paramsJson);
}
void getDeepLinkInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getDeepLinkInfo", paramsJson);
}
void getApplicationConfig(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getApplicationConfig", paramsJson);
}
void saveApplicationLogEvent(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "saveApplicationLogEvent", paramsJson);
}

// ==================== 代理 ====================
void addProxy(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addProxy", paramsJson);
}
void editProxy(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "editProxy", paramsJson);
}
void enableProxy(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "enableProxy", paramsJson);
}
void disableProxy(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "disableProxy", paramsJson);
}
void removeProxy(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "removeProxy", paramsJson);
}
void getProxies(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getProxies", paramsJson);
}
void pingProxy(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "pingProxy", paramsJson);
}

// ==================== 日志 ====================
void setLogStream(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setLogStream", paramsJson);
}
void getLogStream(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getLogStream", paramsJson);
}
void setLogVerbosityLevel(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setLogVerbosityLevel", paramsJson);
}
void getLogVerbosityLevel(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getLogVerbosityLevel", paramsJson);
}
void getLogTags(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getLogTags", paramsJson);
}
void setLogTagVerbosityLevel(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setLogTagVerbosityLevel", paramsJson);
}
void getLogTagVerbosityLevel(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getLogTagVerbosityLevel", paramsJson);
}
void addLogMessage(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "addLogMessage", paramsJson);
}

// ==================== 支持 ====================
void getUserSupportInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getUserSupportInfo", paramsJson);
}
void setUserSupportInfo(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "setUserSupportInfo", paramsJson);
}
void getSupportName(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "getSupportName", paramsJson);
}

// ==================== 测试方法 ====================
void testCallEmpty(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "testCallEmpty", paramsJson);
}
void testCallString(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "testCallString", paramsJson);
}
void testCallBytes(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "testCallBytes", paramsJson);
}
void testCallVectorInt(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "testCallVectorInt", paramsJson);
}
void testCallVectorIntObject(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "testCallVectorIntObject", paramsJson);
}
void testCallVectorString(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "testCallVectorString", paramsJson);
}
void testCallVectorStringObject(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "testCallVectorStringObject", paramsJson);
}
void testSquareInt(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "testSquareInt", paramsJson);
}
void testNetwork(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "testNetwork", paramsJson);
}
void testProxy(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "testProxy", paramsJson);
}
void testGetDifference(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "testGetDifference", paramsJson);
}
void testUseUpdate(int clientId, const std::string& paramsJson) {
    tdlib::sendRequest(clientId, "testUseUpdate", paramsJson);
}

} // namespace api
} // namespace tdlib