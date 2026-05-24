/**
 * NAPI 绑定：所有 TDLib API 方法
 * 每个函数：接收 (clientId, paramsJson) → 调用 tdlib::api::对应方法
 */
#include "napi/native_api.h"
#include "NAPIBinder.h"
#include "../api/TDLibApi.h"

namespace tdlib {
namespace napi_binder {

// ==================== 认证与授权 ====================
napi_value NAPI_getAuthorizationState(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getAuthorizationState(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setTdlibParameters(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setTdlibParameters(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setAuthenticationPhoneNumber(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setAuthenticationPhoneNumber(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_checkAuthenticationPremiumPurchase(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::checkAuthenticationPremiumPurchase(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setAuthenticationPremiumPurchaseTransaction(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setAuthenticationPremiumPurchaseTransaction(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setAuthenticationEmailAddress(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setAuthenticationEmailAddress(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_resendAuthenticationCode(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::resendAuthenticationCode(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_checkAuthenticationEmailCode(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::checkAuthenticationEmailCode(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_checkAuthenticationCode(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::checkAuthenticationCode(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_requestQrCodeAuthentication(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::requestQrCodeAuthentication(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getAuthenticationPasskeyParameters(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getAuthenticationPasskeyParameters(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_checkAuthenticationPasskey(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::checkAuthenticationPasskey(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_registerUser(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::registerUser(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_resetAuthenticationEmailAddress(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::resetAuthenticationEmailAddress(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_checkAuthenticationPassword(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::checkAuthenticationPassword(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_requestAuthenticationPasswordRecovery(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::requestAuthenticationPasswordRecovery(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_checkAuthenticationPasswordRecoveryCode(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::checkAuthenticationPasswordRecoveryCode(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_recoverAuthenticationPassword(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::recoverAuthenticationPassword(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendAuthenticationFirebaseSms(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendAuthenticationFirebaseSms(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reportAuthenticationCodeMissing(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reportAuthenticationCodeMissing(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_checkAuthenticationBotToken(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::checkAuthenticationBotToken(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_logOut(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::logOut(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_close(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::close(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_destroy(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::destroy(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_confirmQrCodeAuthentication(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::confirmQrCodeAuthentication(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getCurrentState(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getCurrentState(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setDatabaseEncryptionKey(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setDatabaseEncryptionKey(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getPasswordState(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPasswordState(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setPassword(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setPassword(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_isLoginEmailAddressRequired(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::isLoginEmailAddressRequired(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setLoginEmailAddress(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setLoginEmailAddress(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_resendLoginEmailAddressCode(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::resendLoginEmailAddressCode(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_checkLoginEmailAddressCode(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::checkLoginEmailAddressCode(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getRecoveryEmailAddress(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getRecoveryEmailAddress(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setRecoveryEmailAddress(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setRecoveryEmailAddress(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_checkRecoveryEmailAddressCode(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::checkRecoveryEmailAddressCode(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_resendRecoveryEmailAddressCode(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::resendRecoveryEmailAddressCode(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_cancelRecoveryEmailAddressVerification(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::cancelRecoveryEmailAddressVerification(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_requestPasswordRecovery(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::requestPasswordRecovery(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_checkPasswordRecoveryCode(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::checkPasswordRecoveryCode(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_recoverPassword(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::recoverPassword(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_resetPassword(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::resetPassword(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_cancelPasswordReset(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::cancelPasswordReset(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_createTemporaryPassword(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createTemporaryPassword(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getTemporaryPasswordState(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getTemporaryPasswordState(clientId, paramsJson);
    return nullptr;
}

// ==================== 用户与个人资料 ====================
napi_value NAPI_getMe(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMe(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getUser(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getUser(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getUserFullInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getUserFullInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getBasicGroup(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getBasicGroup(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getBasicGroupFullInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getBasicGroupFullInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getSupergroup(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getSupergroup(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getSupergroupFullInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getSupergroupFullInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getSecretChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getSecretChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getUserProfilePhotos(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getUserProfilePhotos(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getUserProfileAudios(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getUserProfileAudios(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_isProfileAudio(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::isProfileAudio(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addProfileAudio(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addProfileAudio(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setProfileAudioPosition(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setProfileAudioPosition(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeProfileAudio(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeProfileAudio(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setUserPersonalProfilePhoto(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setUserPersonalProfilePhoto(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setUserNote(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setUserNote(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_suggestUserProfilePhoto(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::suggestUserProfilePhoto(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_suggestUserBirthdate(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::suggestUserBirthdate(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleBotCanManageEmojiStatus(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleBotCanManageEmojiStatus(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setUserEmojiStatus(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setUserEmojiStatus(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchUserByPhoneNumber(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchUserByPhoneNumber(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sharePhoneNumber(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sharePhoneNumber(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setProfilePhoto(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setProfilePhoto(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteProfilePhoto(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteProfilePhoto(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setAccentColor(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setAccentColor(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setUpgradedGiftColors(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setUpgradedGiftColors(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setProfileAccentColor(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setProfileAccentColor(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setName(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setName(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setBio(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setBio(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setUsername(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setUsername(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleUsernameIsActive(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleUsernameIsActive(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reorderActiveUsernames(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reorderActiveUsernames(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setBirthdate(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setBirthdate(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setMainProfileTab(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setMainProfileTab(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setPersonalChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setPersonalChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setEmojiStatus(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setEmojiStatus(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleHasSponsoredMessagesEnabled(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleHasSponsoredMessagesEnabled(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setBusinessLocation(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setBusinessLocation(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setBusinessOpeningHours(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setBusinessOpeningHours(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setBusinessGreetingMessageSettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setBusinessGreetingMessageSettings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setBusinessAwayMessageSettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setBusinessAwayMessageSettings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setBusinessStartPage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setBusinessStartPage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getBusinessConnectedBot(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getBusinessConnectedBot(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setBusinessConnectedBot(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setBusinessConnectedBot(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteBusinessConnectedBot(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteBusinessConnectedBot(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleBusinessConnectedBotChatIsPaused(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleBusinessConnectedBotChatIsPaused(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeBusinessConnectedBotFromChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeBusinessConnectedBotFromChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getBusinessChatLinks(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getBusinessChatLinks(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_createBusinessChatLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createBusinessChatLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editBusinessChatLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editBusinessChatLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteBusinessChatLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteBusinessChatLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getBusinessChatLinkInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getBusinessChatLinkInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getUserLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getUserLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchUserByToken(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchUserByToken(clientId, paramsJson);
    return nullptr;
}

// ==================== 聊天管理 ====================
napi_value NAPI_getChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMessageLocally(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMessageLocally(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getRepliedMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getRepliedMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatPinnedMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatPinnedMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getCallbackQueryMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getCallbackQueryMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMessageProperties(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMessageProperties(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMessageThread(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMessageThread(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMessageReadDate(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMessageReadDate(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMessageViewers(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMessageViewers(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMessageAuthor(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMessageAuthor(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_loadChats(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::loadChats(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChats(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChats(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchPublicChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchPublicChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchPublicChats(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchPublicChats(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchChats(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchChats(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchChatsOnServer(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchChatsOnServer(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getRecommendedChats(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getRecommendedChats(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatSimilarChats(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatSimilarChats(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatSimilarChatCount(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatSimilarChatCount(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_openChatSimilarChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::openChatSimilarChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getBotSimilarBots(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getBotSimilarBots(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getBotSimilarBotCount(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getBotSimilarBotCount(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_openBotSimilarBot(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::openBotSimilarBot(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getTopChats(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getTopChats(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeTopChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeTopChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchRecentlyFoundChats(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchRecentlyFoundChats(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addRecentlyFoundChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addRecentlyFoundChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeRecentlyFoundChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeRecentlyFoundChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_clearRecentlyFoundChats(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::clearRecentlyFoundChats(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getRecentlyOpenedChats(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getRecentlyOpenedChats(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_checkChatUsername(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::checkChatUsername(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getCreatedPublicChats(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getCreatedPublicChats(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_checkCreatedPublicChatsLimit(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::checkCreatedPublicChatsLimit(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getSuitableDiscussionChats(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getSuitableDiscussionChats(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getInactiveSupergroupChats(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getInactiveSupergroupChats(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getSuitablePersonalChats(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getSuitablePersonalChats(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_loadDirectMessagesChatTopics(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::loadDirectMessagesChatTopics(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getDirectMessagesChatTopic(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getDirectMessagesChatTopic(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getDirectMessagesChatTopicHistory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getDirectMessagesChatTopicHistory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getDirectMessagesChatTopicMessageByDate(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getDirectMessagesChatTopicMessageByDate(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteDirectMessagesChatTopicHistory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteDirectMessagesChatTopicHistory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteDirectMessagesChatTopicMessagesByDate(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteDirectMessagesChatTopicMessagesByDate(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setDirectMessagesChatTopicIsMarkedAsUnread(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setDirectMessagesChatTopicIsMarkedAsUnread(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_unpinAllDirectMessagesChatTopicMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::unpinAllDirectMessagesChatTopicMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_readAllDirectMessagesChatTopicReactions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::readAllDirectMessagesChatTopicReactions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getDirectMessagesChatTopicRevenue(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getDirectMessagesChatTopicRevenue(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleDirectMessagesChatTopicCanSendUnpaidMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleDirectMessagesChatTopicCanSendUnpaidMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_loadSavedMessagesTopics(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::loadSavedMessagesTopics(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getSavedMessagesTopicHistory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getSavedMessagesTopicHistory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getSavedMessagesTopicMessageByDate(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getSavedMessagesTopicMessageByDate(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteSavedMessagesTopicHistory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteSavedMessagesTopicHistory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteSavedMessagesTopicMessagesByDate(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteSavedMessagesTopicMessagesByDate(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleSavedMessagesTopicIsPinned(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleSavedMessagesTopicIsPinned(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setPinnedSavedMessagesTopics(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setPinnedSavedMessagesTopics(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getGroupsInCommon(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getGroupsInCommon(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatHistory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatHistory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMessageThreadHistory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMessageThreadHistory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteChatHistory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteChatHistory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchChatMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchChatMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchSecretMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchSecretMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchSavedMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchSavedMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchCallMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchCallMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchOutgoingDocumentMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchOutgoingDocumentMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getPublicPostSearchLimits(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPublicPostSearchLimits(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchPublicPosts(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchPublicPosts(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchPublicMessagesByTag(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchPublicMessagesByTag(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchPublicStoriesByTag(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchPublicStoriesByTag(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchPublicStoriesByLocation(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchPublicStoriesByLocation(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchPublicStoriesByVenue(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchPublicStoriesByVenue(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getSearchedForTags(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getSearchedForTags(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeSearchedForTag(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeSearchedForTag(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_clearSearchedForTags(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::clearSearchedForTags(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteAllCallMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteAllCallMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchChatRecentLocationMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchChatRecentLocationMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatMessageByDate(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatMessageByDate(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatSparseMessagePositions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatSparseMessagePositions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatMessageCalendar(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatMessageCalendar(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatMessageCount(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatMessageCount(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatMessagePosition(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatMessagePosition(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatScheduledMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatScheduledMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatSponsoredMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatSponsoredMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_clickChatSponsoredMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::clickChatSponsoredMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reportChatSponsoredMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reportChatSponsoredMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getSearchSponsoredChats(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getSearchSponsoredChats(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_viewSponsoredChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::viewSponsoredChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_openSponsoredChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::openSponsoredChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reportSponsoredChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reportSponsoredChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getVideoMessageAdvertisements(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getVideoMessageAdvertisements(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_viewVideoMessageAdvertisement(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::viewVideoMessageAdvertisement(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_clickVideoMessageAdvertisement(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::clickVideoMessageAdvertisement(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reportVideoMessageAdvertisement(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reportVideoMessageAdvertisement(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeNotification(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeNotification(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeNotificationGroup(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeNotificationGroup(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMessageLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMessageLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMessageEmbeddingCode(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMessageEmbeddingCode(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMessageLinkInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMessageLinkInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_translateText(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::translateText(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_translateMessageText(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::translateMessageText(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_summarizeMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::summarizeMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_recognizeSpeech(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::recognizeSpeech(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_rateSpeechRecognition(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::rateSpeechRecognition(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatAvailableMessageSenders(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatAvailableMessageSenders(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatMessageSender(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatMessageSender(clientId, paramsJson);
    return nullptr;
}

// ==================== 消息操作 ====================
napi_value NAPI_sendMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendMessageAlbum(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendMessageAlbum(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendBotStartMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendBotStartMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendInlineQueryResultMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendInlineQueryResultMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_forwardMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::forwardMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendQuickReplyShortcutMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendQuickReplyShortcutMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_resendMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::resendMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addLocalMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addLocalMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteChatMessagesBySender(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteChatMessagesBySender(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteChatMessagesByDate(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteChatMessagesByDate(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editMessageText(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editMessageText(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editMessageLiveLocation(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editMessageLiveLocation(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editMessageChecklist(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editMessageChecklist(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editMessageMedia(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editMessageMedia(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editMessageCaption(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editMessageCaption(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editMessageReplyMarkup(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editMessageReplyMarkup(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editInlineMessageText(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editInlineMessageText(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editInlineMessageLiveLocation(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editInlineMessageLiveLocation(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editInlineMessageMedia(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editInlineMessageMedia(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editInlineMessageCaption(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editInlineMessageCaption(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editInlineMessageReplyMarkup(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editInlineMessageReplyMarkup(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editMessageSchedulingState(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editMessageSchedulingState(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setMessageFactCheck(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setMessageFactCheck(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendBusinessMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendBusinessMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendBusinessMessageAlbum(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendBusinessMessageAlbum(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editBusinessMessageText(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editBusinessMessageText(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editBusinessMessageLiveLocation(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editBusinessMessageLiveLocation(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editBusinessMessageChecklist(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editBusinessMessageChecklist(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editBusinessMessageMedia(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editBusinessMessageMedia(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editBusinessMessageCaption(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editBusinessMessageCaption(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editBusinessMessageReplyMarkup(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editBusinessMessageReplyMarkup(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_stopBusinessPoll(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::stopBusinessPoll(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setBusinessMessageIsPinned(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setBusinessMessageIsPinned(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_readBusinessMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::readBusinessMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteBusinessMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteBusinessMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editBusinessStory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editBusinessStory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteBusinessStory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteBusinessStory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setBusinessAccountName(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setBusinessAccountName(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setBusinessAccountBio(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setBusinessAccountBio(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setBusinessAccountProfilePhoto(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setBusinessAccountProfilePhoto(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setBusinessAccountUsername(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setBusinessAccountUsername(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setBusinessAccountGiftSettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setBusinessAccountGiftSettings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getBusinessAccountStarAmount(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getBusinessAccountStarAmount(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_transferBusinessAccountStars(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::transferBusinessAccountStars(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_checkQuickReplyShortcutName(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::checkQuickReplyShortcutName(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_loadQuickReplyShortcuts(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::loadQuickReplyShortcuts(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setQuickReplyShortcutName(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setQuickReplyShortcutName(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteQuickReplyShortcut(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteQuickReplyShortcut(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reorderQuickReplyShortcuts(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reorderQuickReplyShortcuts(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_loadQuickReplyShortcutMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::loadQuickReplyShortcutMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteQuickReplyShortcutMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteQuickReplyShortcutMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addQuickReplyShortcutMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addQuickReplyShortcutMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addQuickReplyShortcutInlineQueryResultMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addQuickReplyShortcutInlineQueryResultMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addQuickReplyShortcutMessageAlbum(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addQuickReplyShortcutMessageAlbum(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_readdQuickReplyShortcutMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::readdQuickReplyShortcutMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editQuickReplyMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editQuickReplyMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getForumTopicDefaultIcons(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getForumTopicDefaultIcons(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_createForumTopic(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createForumTopic(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editForumTopic(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editForumTopic(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getForumTopic(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getForumTopic(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getForumTopicHistory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getForumTopicHistory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getForumTopicLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getForumTopicLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getForumTopics(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getForumTopics(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setForumTopicNotificationSettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setForumTopicNotificationSettings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleForumTopicIsClosed(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleForumTopicIsClosed(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleGeneralForumTopicIsHidden(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleGeneralForumTopicIsHidden(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleForumTopicIsPinned(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleForumTopicIsPinned(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setPinnedForumTopics(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setPinnedForumTopics(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteForumTopic(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteForumTopic(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_readAllForumTopicMentions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::readAllForumTopicMentions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_readAllForumTopicReactions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::readAllForumTopicReactions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_unpinAllForumTopicMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::unpinAllForumTopicMessages(clientId, paramsJson);
    return nullptr;
}

// ==================== 反应与表情 ====================
napi_value NAPI_getPasskeyParameters(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPasskeyParameters(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addLoginPasskey(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addLoginPasskey(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getLoginPasskeys(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getLoginPasskeys(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeLoginPasskey(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeLoginPasskey(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getEmojiReaction(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getEmojiReaction(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getCustomEmojiReactionAnimations(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getCustomEmojiReactionAnimations(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMessageAvailableReactions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMessageAvailableReactions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_clearRecentReactions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::clearRecentReactions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addMessageReaction(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addMessageReaction(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeMessageReaction(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeMessageReaction(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatAvailablePaidMessageReactionSenders(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatAvailablePaidMessageReactionSenders(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addPendingPaidMessageReaction(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addPendingPaidMessageReaction(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_commitPendingPaidMessageReactions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::commitPendingPaidMessageReactions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removePendingPaidMessageReactions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removePendingPaidMessageReactions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setPaidMessageReactionType(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setPaidMessageReactionType(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setMessageReactions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setMessageReactions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMessageAddedReactions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMessageAddedReactions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setDefaultReactionType(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setDefaultReactionType(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getSavedMessagesTags(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getSavedMessagesTags(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setSavedMessagesTagLabel(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setSavedMessagesTagLabel(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMessageEffect(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMessageEffect(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchQuote(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchQuote(clientId, paramsJson);
    return nullptr;
}

// ==================== 文本处理 ====================
napi_value NAPI_getTextEntities(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getTextEntities(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_parseTextEntities(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::parseTextEntities(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_parseMarkdown(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::parseMarkdown(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMarkdownText(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMarkdownText(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getCountryFlagEmoji(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getCountryFlagEmoji(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getFileMimeType(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getFileMimeType(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getFileExtension(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getFileExtension(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_cleanFileName(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::cleanFileName(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getLanguagePackString(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getLanguagePackString(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getJsonValue(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getJsonValue(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getJsonString(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getJsonString(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getThemeParametersJsonString(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getThemeParametersJsonString(clientId, paramsJson);
    return nullptr;
}

// ==================== 投票与清单 ====================
napi_value NAPI_setPollAnswer(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setPollAnswer(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getPollVoters(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPollVoters(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_stopPoll(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::stopPoll(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addChecklistTasks(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addChecklistTasks(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_markChecklistTasksAsDone(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::markChecklistTasksAsDone(clientId, paramsJson);
    return nullptr;
}

// ==================== 建议操作 ====================
napi_value NAPI_hideSuggestedAction(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::hideSuggestedAction(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_hideContactCloseBirthdays(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::hideContactCloseBirthdays(clientId, paramsJson);
    return nullptr;
}

// ==================== 业务连接 ====================
napi_value NAPI_getBusinessConnection(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getBusinessConnection(clientId, paramsJson);
    return nullptr;
}

// ==================== 登录 URL ====================
napi_value NAPI_getLoginUrlInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getLoginUrlInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getLoginUrl(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getLoginUrl(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_shareUsersWithBot(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::shareUsersWithBot(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_shareChatWithBot(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::shareChatWithBot(clientId, paramsJson);
    return nullptr;
}

// ==================== 内联查询 ====================
napi_value NAPI_getInlineQueryResults(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getInlineQueryResults(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_answerInlineQuery(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::answerInlineQuery(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_savePreparedInlineMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::savePreparedInlineMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getPreparedInlineMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPreparedInlineMessage(clientId, paramsJson);
    return nullptr;
}

// ==================== Web 应用 ====================
napi_value NAPI_getGrossingWebAppBots(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getGrossingWebAppBots(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchWebApp(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchWebApp(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getWebAppPlaceholder(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getWebAppPlaceholder(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getWebAppLinkUrl(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getWebAppLinkUrl(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMainWebApp(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMainWebApp(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getWebAppUrl(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getWebAppUrl(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendWebAppData(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendWebAppData(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_openWebApp(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::openWebApp(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_closeWebApp(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::closeWebApp(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_answerWebAppQuery(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::answerWebAppQuery(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_checkWebAppFileDownload(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::checkWebAppFileDownload(clientId, paramsJson);
    return nullptr;
}

// ==================== 回调查询 ====================
napi_value NAPI_getCallbackQueryAnswer(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getCallbackQueryAnswer(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_answerCallbackQuery(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::answerCallbackQuery(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_answerShippingQuery(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::answerShippingQuery(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_answerPreCheckoutQuery(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::answerPreCheckoutQuery(clientId, paramsJson);
    return nullptr;
}

// ==================== 游戏 ====================
napi_value NAPI_setGameScore(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setGameScore(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setInlineGameScore(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setInlineGameScore(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getGameHighScores(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getGameHighScores(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getInlineGameHighScores(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getInlineGameHighScores(clientId, paramsJson);
    return nullptr;
}

// ==================== 聊天操作 ====================
napi_value NAPI_deleteChatReplyMarkup(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteChatReplyMarkup(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendChatAction(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendChatAction(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendTextMessageDraft(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendTextMessageDraft(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_openChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::openChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_closeChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::closeChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_viewMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::viewMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_openMessageContent(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::openMessageContent(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_clickAnimatedEmojiMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::clickAnimatedEmojiMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getInternalLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getInternalLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getInternalLinkType(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getInternalLinkType(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getExternalLinkInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getExternalLinkInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getExternalLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getExternalLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_readAllChatMentions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::readAllChatMentions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_readAllChatReactions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::readAllChatReactions(clientId, paramsJson);
    return nullptr;
}

// ==================== 创建聊天 ====================
napi_value NAPI_createPrivateChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createPrivateChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_createBasicGroupChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createBasicGroupChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_createSupergroupChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createSupergroupChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_createSecretChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createSecretChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_createNewBasicGroupChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createNewBasicGroupChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_createNewSupergroupChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createNewSupergroupChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_createNewSecretChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createNewSecretChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_upgradeBasicGroupChatToSupergroupChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::upgradeBasicGroupChatToSupergroupChat(clientId, paramsJson);
    return nullptr;
}

// ==================== 聊天列表与文件夹 ====================
napi_value NAPI_getChatListsToAddChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatListsToAddChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addChatToList(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addChatToList(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatFolder(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatFolder(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_createChatFolder(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createChatFolder(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editChatFolder(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editChatFolder(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteChatFolder(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteChatFolder(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatFolderChatsToLeave(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatFolderChatsToLeave(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatFolderChatCount(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatFolderChatCount(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reorderChatFolders(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reorderChatFolders(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleChatFolderTags(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleChatFolderTags(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getRecommendedChatFolders(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getRecommendedChatFolders(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatFolderDefaultIconName(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatFolderDefaultIconName(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatsForChatFolderInviteLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatsForChatFolderInviteLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_createChatFolderInviteLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createChatFolderInviteLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatFolderInviteLinks(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatFolderInviteLinks(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editChatFolderInviteLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editChatFolderInviteLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteChatFolderInviteLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteChatFolderInviteLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_checkChatFolderInviteLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::checkChatFolderInviteLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addChatFolderByInviteLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addChatFolderByInviteLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatFolderNewChats(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatFolderNewChats(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_processChatFolderNewChats(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::processChatFolderNewChats(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getArchiveChatListSettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getArchiveChatListSettings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setArchiveChatListSettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setArchiveChatListSettings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatTitle(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatTitle(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatPhoto(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatPhoto(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatAccentColor(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatAccentColor(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatProfileAccentColor(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatProfileAccentColor(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatMessageAutoDeleteTime(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatMessageAutoDeleteTime(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatEmojiStatus(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatEmojiStatus(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatPermissions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatPermissions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatBackground(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatBackground(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteChatBackground(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteChatBackground(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getGiftChatThemes(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getGiftChatThemes(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatTheme(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatTheme(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatDraftMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatDraftMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatNotificationSettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatNotificationSettings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleChatHasProtectedContent(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleChatHasProtectedContent(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleChatViewAsTopics(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleChatViewAsTopics(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleChatIsTranslatable(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleChatIsTranslatable(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleChatIsMarkedAsUnread(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleChatIsMarkedAsUnread(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleChatDefaultDisableNotification(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleChatDefaultDisableNotification(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatAvailableReactions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatAvailableReactions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatClientData(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatClientData(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatDescription(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatDescription(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatDiscussionGroup(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatDiscussionGroup(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatDirectMessagesGroup(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatDirectMessagesGroup(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatLocation(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatLocation(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatSlowModeDelay(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatSlowModeDelay(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_pinChatMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::pinChatMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_unpinChatMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::unpinChatMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_unpinAllChatMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::unpinAllChatMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_joinChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::joinChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_leaveChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::leaveChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addChatMember(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addChatMember(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addChatMembers(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addChatMembers(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatMemberStatus(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatMemberStatus(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_banChatMember(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::banChatMember(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_canTransferOwnership(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::canTransferOwnership(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_transferChatOwnership(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::transferChatOwnership(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatOwnerAfterLeaving(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatOwnerAfterLeaving(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatMember(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatMember(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchChatMembers(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchChatMembers(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatAdministrators(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatAdministrators(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_clearAllDraftMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::clearAllDraftMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStakeDiceState(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStakeDiceState(clientId, paramsJson);
    return nullptr;
}

// ==================== 通知设置 ====================
napi_value NAPI_getSavedNotificationSound(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getSavedNotificationSound(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getSavedNotificationSounds(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getSavedNotificationSounds(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addSavedNotificationSound(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addSavedNotificationSound(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeSavedNotificationSound(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeSavedNotificationSound(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatNotificationSettingsExceptions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatNotificationSettingsExceptions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getScopeNotificationSettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getScopeNotificationSettings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setScopeNotificationSettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setScopeNotificationSettings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setReactionNotificationSettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setReactionNotificationSettings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_resetAllNotificationSettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::resetAllNotificationSettings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleChatIsPinned(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleChatIsPinned(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setPinnedChats(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setPinnedChats(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_readChatList(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::readChatList(clientId, paramsJson);
    return nullptr;
}

// ==================== 天气 ====================
napi_value NAPI_getCurrentWeather(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getCurrentWeather(clientId, paramsJson);
    return nullptr;
}

// ==================== 故事 ====================
napi_value NAPI_getStory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatsToPostStories(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatsToPostStories(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_canPostStory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::canPostStory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_postStory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::postStory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_startLiveStory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::startLiveStory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editStory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editStory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editStoryCover(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editStoryCover(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setStoryPrivacySettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setStoryPrivacySettings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleStoryIsPostedToChatPage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleStoryIsPostedToChatPage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteStory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteStory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStoryNotificationSettingsExceptions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStoryNotificationSettingsExceptions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_loadActiveStories(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::loadActiveStories(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatActiveStoriesList(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatActiveStoriesList(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatActiveStories(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatActiveStories(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatPostedToChatPageStories(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatPostedToChatPageStories(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatArchivedStories(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatArchivedStories(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatPinnedStories(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatPinnedStories(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_openStory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::openStory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_closeStory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::closeStory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStoryAvailableReactions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStoryAvailableReactions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setStoryReaction(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setStoryReaction(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStoryInteractions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStoryInteractions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatStoryInteractions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatStoryInteractions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reportStory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reportStory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_activateStoryStealthMode(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::activateStoryStealthMode(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStoryPublicForwards(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStoryPublicForwards(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatStoryAlbums(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatStoryAlbums(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStoryAlbumStories(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStoryAlbumStories(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_createStoryAlbum(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createStoryAlbum(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reorderStoryAlbums(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reorderStoryAlbums(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteStoryAlbum(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteStoryAlbum(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setStoryAlbumName(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setStoryAlbumName(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addStoryAlbumStories(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addStoryAlbumStories(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeStoryAlbumStories(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeStoryAlbumStories(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reorderStoryAlbumStories(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reorderStoryAlbumStories(clientId, paramsJson);
    return nullptr;
}

// ==================== 提升与增强 ====================
napi_value NAPI_getChatBoostLevelFeatures(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatBoostLevelFeatures(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatBoostFeatures(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatBoostFeatures(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getAvailableChatBoostSlots(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getAvailableChatBoostSlots(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatBoostStatus(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatBoostStatus(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_boostChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::boostChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatBoostLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatBoostLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatBoostLinkInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatBoostLinkInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatBoosts(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatBoosts(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getUserChatBoosts(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getUserChatBoosts(clientId, paramsJson);
    return nullptr;
}

// ==================== 附件菜单机器人 ====================
napi_value NAPI_getAttachmentMenuBot(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getAttachmentMenuBot(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleBotIsAddedToAttachmentMenu(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleBotIsAddedToAttachmentMenu(clientId, paramsJson);
    return nullptr;
}

// ==================== 表情状态 ====================
napi_value NAPI_getThemedEmojiStatuses(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getThemedEmojiStatuses(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getRecentEmojiStatuses(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getRecentEmojiStatuses(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getUpgradedGiftEmojiStatuses(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getUpgradedGiftEmojiStatuses(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getDefaultEmojiStatuses(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getDefaultEmojiStatuses(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_clearRecentEmojiStatuses(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::clearRecentEmojiStatuses(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getThemedChatEmojiStatuses(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getThemedChatEmojiStatuses(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getDefaultChatEmojiStatuses(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getDefaultChatEmojiStatuses(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getDisallowedChatEmojiStatuses(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getDisallowedChatEmojiStatuses(clientId, paramsJson);
    return nullptr;
}

// ==================== 文件操作 ====================
napi_value NAPI_getFile(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getFile(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getRemoteFile(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getRemoteFile(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_readFilePart(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::readFilePart(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getFileDownloadedPrefixSize(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getFileDownloadedPrefixSize(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_downloadFile(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::downloadFile(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_cancelDownloadFile(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::cancelDownloadFile(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_preliminaryUploadFile(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::preliminaryUploadFile(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_cancelPreliminaryUploadFile(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::cancelPreliminaryUploadFile(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_writeGeneratedFilePart(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::writeGeneratedFilePart(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setFileGenerationProgress(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setFileGenerationProgress(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_finishFileGeneration(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::finishFileGeneration(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getSuggestedFileName(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getSuggestedFileName(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteFile(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteFile(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addFileToDownloads(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addFileToDownloads(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleDownloadIsPaused(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleDownloadIsPaused(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleAllDownloadsArePaused(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleAllDownloadsArePaused(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeFileFromDownloads(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeFileFromDownloads(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeAllFilesFromDownloads(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeAllFilesFromDownloads(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchFileDownloads(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchFileDownloads(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getAutoDownloadSettingsPresets(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getAutoDownloadSettingsPresets(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setAutoDownloadSettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setAutoDownloadSettings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_uploadStickerFile(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::uploadStickerFile(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMapThumbnailFile(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMapThumbnailFile(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getApplicationDownloadLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getApplicationDownloadLink(clientId, paramsJson);
    return nullptr;
}

// ==================== 应用验证 ====================
napi_value NAPI_setApplicationVerificationToken(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setApplicationVerificationToken(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMessageFileType(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMessageFileType(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMessageImportConfirmationText(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMessageImportConfirmationText(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_importMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::importMessages(clientId, paramsJson);
    return nullptr;
}

// ==================== 邀请链接 ====================
napi_value NAPI_replacePrimaryChatInviteLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::replacePrimaryChatInviteLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_createChatInviteLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createChatInviteLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_createChatSubscriptionInviteLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createChatSubscriptionInviteLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editChatInviteLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editChatInviteLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editChatSubscriptionInviteLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editChatSubscriptionInviteLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatInviteLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatInviteLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatInviteLinkCounts(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatInviteLinkCounts(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatInviteLinks(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatInviteLinks(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatInviteLinkMembers(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatInviteLinkMembers(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_revokeChatInviteLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::revokeChatInviteLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteRevokedChatInviteLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteRevokedChatInviteLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteAllRevokedChatInviteLinks(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteAllRevokedChatInviteLinks(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_checkChatInviteLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::checkChatInviteLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_joinChatByInviteLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::joinChatByInviteLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatJoinRequests(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatJoinRequests(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_processChatJoinRequest(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::processChatJoinRequest(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_processChatJoinRequests(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::processChatJoinRequests(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_approveSuggestedPost(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::approveSuggestedPost(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_declineSuggestedPost(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::declineSuggestedPost(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addOffer(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addOffer(clientId, paramsJson);
    return nullptr;
}

// ==================== 通话与视频聊天 ====================
napi_value NAPI_createCall(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createCall(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_acceptCall(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::acceptCall(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendCallSignalingData(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendCallSignalingData(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_discardCall(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::discardCall(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendCallRating(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendCallRating(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendCallDebugInformation(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendCallDebugInformation(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendCallLog(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendCallLog(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getVideoChatAvailableParticipants(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getVideoChatAvailableParticipants(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setVideoChatDefaultParticipant(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setVideoChatDefaultParticipant(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_createVideoChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createVideoChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_createGroupCall(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createGroupCall(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getVideoChatRtmpUrl(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getVideoChatRtmpUrl(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_replaceVideoChatRtmpUrl(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::replaceVideoChatRtmpUrl(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getLiveStoryRtmpUrl(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getLiveStoryRtmpUrl(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_replaceLiveStoryRtmpUrl(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::replaceLiveStoryRtmpUrl(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getGroupCall(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getGroupCall(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_startScheduledVideoChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::startScheduledVideoChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleVideoChatEnabledStartNotification(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleVideoChatEnabledStartNotification(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_joinGroupCall(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::joinGroupCall(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_joinVideoChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::joinVideoChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_joinLiveStory(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::joinLiveStory(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_startGroupCallScreenSharing(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::startGroupCallScreenSharing(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleGroupCallScreenSharingIsPaused(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleGroupCallScreenSharingIsPaused(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_endGroupCallScreenSharing(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::endGroupCallScreenSharing(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setVideoChatTitle(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setVideoChatTitle(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleVideoChatMuteNewParticipants(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleVideoChatMuteNewParticipants(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleGroupCallAreMessagesAllowed(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleGroupCallAreMessagesAllowed(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getLiveStoryStreamer(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getLiveStoryStreamer(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getLiveStoryAvailableMessageSenders(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getLiveStoryAvailableMessageSenders(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setLiveStoryMessageSender(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setLiveStoryMessageSender(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendGroupCallMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendGroupCallMessage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addPendingLiveStoryReaction(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addPendingLiveStoryReaction(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_commitPendingLiveStoryReactions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::commitPendingLiveStoryReactions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removePendingLiveStoryReactions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removePendingLiveStoryReactions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteGroupCallMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteGroupCallMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteGroupCallMessagesBySender(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteGroupCallMessagesBySender(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getLiveStoryTopDonors(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getLiveStoryTopDonors(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_inviteGroupCallParticipant(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::inviteGroupCallParticipant(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_declineGroupCallInvitation(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::declineGroupCallInvitation(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_banGroupCallParticipants(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::banGroupCallParticipants(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_inviteVideoChatParticipants(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::inviteVideoChatParticipants(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getVideoChatInviteLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getVideoChatInviteLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_revokeGroupCallInviteLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::revokeGroupCallInviteLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_startGroupCallRecording(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::startGroupCallRecording(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_endGroupCallRecording(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::endGroupCallRecording(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleGroupCallIsMyVideoPaused(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleGroupCallIsMyVideoPaused(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleGroupCallIsMyVideoEnabled(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleGroupCallIsMyVideoEnabled(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setGroupCallPaidMessageStarCount(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setGroupCallPaidMessageStarCount(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setGroupCallParticipantIsSpeaking(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setGroupCallParticipantIsSpeaking(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleGroupCallParticipantIsMuted(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleGroupCallParticipantIsMuted(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setGroupCallParticipantVolumeLevel(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setGroupCallParticipantVolumeLevel(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleGroupCallParticipantIsHandRaised(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleGroupCallParticipantIsHandRaised(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getGroupCallParticipants(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getGroupCallParticipants(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_loadGroupCallParticipants(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::loadGroupCallParticipants(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_leaveGroupCall(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::leaveGroupCall(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_endGroupCall(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::endGroupCall(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getGroupCallStreams(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getGroupCallStreams(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getGroupCallStreamSegment(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getGroupCallStreamSegment(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_encryptGroupCallData(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::encryptGroupCallData(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_decryptGroupCallData(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::decryptGroupCallData(clientId, paramsJson);
    return nullptr;
}

// ==================== 封禁与联系人 ====================
napi_value NAPI_setMessageSenderBlockList(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setMessageSenderBlockList(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_blockMessageSenderFromReplies(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::blockMessageSenderFromReplies(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getBlockedMessageSenders(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getBlockedMessageSenders(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addContact(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addContact(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_importContacts(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::importContacts(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getContacts(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getContacts(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchContacts(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchContacts(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeContacts(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeContacts(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getImportedContactCount(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getImportedContactCount(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_changeImportedContacts(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::changeImportedContacts(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_clearImportedContacts(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::clearImportedContacts(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setCloseFriends(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setCloseFriends(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getCloseFriends(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getCloseFriends(clientId, paramsJson);
    return nullptr;
}

// ==================== 贴纸与表情 ====================
napi_value NAPI_getStickerOutline(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStickerOutline(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStickerOutlineSvgPath(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStickerOutlineSvgPath(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStickers(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStickers(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getAllStickerEmojis(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getAllStickerEmojis(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchStickers(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchStickers(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getGreetingStickers(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getGreetingStickers(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getPremiumStickers(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPremiumStickers(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getInstalledStickerSets(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getInstalledStickerSets(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getArchivedStickerSets(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getArchivedStickerSets(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getTrendingStickerSets(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getTrendingStickerSets(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getAttachedStickerSets(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getAttachedStickerSets(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStickerSet(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStickerSet(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStickerSetName(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStickerSetName(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchStickerSet(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchStickerSet(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchInstalledStickerSets(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchInstalledStickerSets(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchStickerSets(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchStickerSets(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_changeStickerSet(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::changeStickerSet(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_viewTrendingStickerSets(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::viewTrendingStickerSets(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reorderInstalledStickerSets(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reorderInstalledStickerSets(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getRecentStickers(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getRecentStickers(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addRecentSticker(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addRecentSticker(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeRecentSticker(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeRecentSticker(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_clearRecentStickers(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::clearRecentStickers(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getFavoriteStickers(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getFavoriteStickers(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addFavoriteSticker(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addFavoriteSticker(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeFavoriteSticker(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeFavoriteSticker(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStickerEmojis(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStickerEmojis(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchEmojis(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchEmojis(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getKeywordEmojis(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getKeywordEmojis(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getEmojiCategories(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getEmojiCategories(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getAnimatedEmoji(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getAnimatedEmoji(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getEmojiSuggestionsUrl(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getEmojiSuggestionsUrl(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getCustomEmojiStickers(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getCustomEmojiStickers(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getDefaultChatPhotoCustomEmojiStickers(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getDefaultChatPhotoCustomEmojiStickers(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getDefaultProfilePhotoCustomEmojiStickers(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getDefaultProfilePhotoCustomEmojiStickers(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getDefaultBackgroundCustomEmojiStickers(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getDefaultBackgroundCustomEmojiStickers(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getSavedAnimations(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getSavedAnimations(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addSavedAnimation(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addSavedAnimation(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeSavedAnimation(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeSavedAnimation(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getRecentInlineBots(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getRecentInlineBots(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getOwnedBots(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getOwnedBots(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchHashtags(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchHashtags(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeRecentHashtag(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeRecentHashtag(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getLinkPreview(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getLinkPreview(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getWebPageInstantView(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getWebPageInstantView(clientId, paramsJson);
    return nullptr;
}

// ==================== 机器人命令与菜单 ====================
napi_value NAPI_setCommands(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setCommands(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteCommands(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteCommands(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getCommands(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getCommands(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setMenuButton(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setMenuButton(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMenuButton(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMenuButton(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setDefaultGroupAdministratorRights(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setDefaultGroupAdministratorRights(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setDefaultChannelAdministratorRights(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setDefaultChannelAdministratorRights(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_canBotSendMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::canBotSendMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_allowBotToSendMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::allowBotToSendMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendWebAppCustomRequest(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendWebAppCustomRequest(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getBotMediaPreviews(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getBotMediaPreviews(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getBotMediaPreviewInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getBotMediaPreviewInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addBotMediaPreview(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addBotMediaPreview(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editBotMediaPreview(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editBotMediaPreview(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reorderBotMediaPreviews(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reorderBotMediaPreviews(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteBotMediaPreviews(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteBotMediaPreviews(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setBotName(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setBotName(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getBotName(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getBotName(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setBotProfilePhoto(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setBotProfilePhoto(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleBotUsernameIsActive(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleBotUsernameIsActive(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reorderBotActiveUsernames(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reorderBotActiveUsernames(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setBotInfoDescription(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setBotInfoDescription(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getBotInfoDescription(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getBotInfoDescription(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setBotInfoShortDescription(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setBotInfoShortDescription(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getBotInfoShortDescription(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getBotInfoShortDescription(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setMessageSenderBotVerification(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setMessageSenderBotVerification(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeMessageSenderBotVerification(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeMessageSenderBotVerification(clientId, paramsJson);
    return nullptr;
}

// ==================== 会话与网站 ====================
napi_value NAPI_getActiveSessions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getActiveSessions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_terminateSession(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::terminateSession(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_terminateAllOtherSessions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::terminateAllOtherSessions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_confirmSession(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::confirmSession(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleSessionCanAcceptCalls(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleSessionCanAcceptCalls(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleSessionCanAcceptSecretChats(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleSessionCanAcceptSecretChats(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setInactiveSessionTtl(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setInactiveSessionTtl(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getConnectedWebsites(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getConnectedWebsites(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_disconnectWebsite(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::disconnectWebsite(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_disconnectAllWebsites(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::disconnectAllWebsites(clientId, paramsJson);
    return nullptr;
}

// ==================== 超级群组管理 ====================
napi_value NAPI_setSupergroupUsername(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setSupergroupUsername(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleSupergroupUsernameIsActive(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleSupergroupUsernameIsActive(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_disableAllSupergroupUsernames(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::disableAllSupergroupUsernames(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reorderSupergroupActiveUsernames(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reorderSupergroupActiveUsernames(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setSupergroupStickerSet(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setSupergroupStickerSet(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setSupergroupCustomEmojiStickerSet(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setSupergroupCustomEmojiStickerSet(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setSupergroupUnrestrictBoostCount(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setSupergroupUnrestrictBoostCount(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setSupergroupMainProfileTab(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setSupergroupMainProfileTab(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleSupergroupSignMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleSupergroupSignMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleSupergroupJoinToSendMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleSupergroupJoinToSendMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleSupergroupJoinByRequest(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleSupergroupJoinByRequest(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleSupergroupIsAllHistoryAvailable(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleSupergroupIsAllHistoryAvailable(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleSupergroupCanHaveSponsoredMessages(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleSupergroupCanHaveSponsoredMessages(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleSupergroupHasAutomaticTranslation(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleSupergroupHasAutomaticTranslation(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleSupergroupHasHiddenMembers(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleSupergroupHasHiddenMembers(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleSupergroupHasAggressiveAntiSpamEnabled(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleSupergroupHasAggressiveAntiSpamEnabled(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleSupergroupIsForum(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleSupergroupIsForum(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleSupergroupIsBroadcastGroup(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleSupergroupIsBroadcastGroup(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reportSupergroupSpam(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reportSupergroupSpam(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reportSupergroupAntiSpamFalsePositive(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reportSupergroupAntiSpamFalsePositive(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getSupergroupMembers(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getSupergroupMembers(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_closeSecretChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::closeSecretChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatEventLog(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatEventLog(clientId, paramsJson);
    return nullptr;
}

// ==================== 时区 ====================
napi_value NAPI_getTimeZones(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getTimeZones(clientId, paramsJson);
    return nullptr;
}

// ==================== 支付与星币 ====================
napi_value NAPI_getPaymentForm(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPaymentForm(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_validateOrderInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::validateOrderInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendPaymentForm(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendPaymentForm(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getPaymentReceipt(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPaymentReceipt(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getSavedOrderInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getSavedOrderInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteSavedOrderInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteSavedOrderInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteSavedCredentials(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteSavedCredentials(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setGiftSettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setGiftSettings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getAvailableGifts(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getAvailableGifts(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_canSendGift(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::canSendGift(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendGift(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendGift(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getGiftAuctionState(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getGiftAuctionState(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getGiftAuctionAcquiredGifts(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getGiftAuctionAcquiredGifts(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_openGiftAuction(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::openGiftAuction(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_closeGiftAuction(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::closeGiftAuction(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_placeGiftAuctionBid(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::placeGiftAuctionBid(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_increaseGiftAuctionBid(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::increaseGiftAuctionBid(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sellGift(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sellGift(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleGiftIsSaved(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleGiftIsSaved(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setPinnedGifts(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setPinnedGifts(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_toggleChatGiftNotifications(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::toggleChatGiftNotifications(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getGiftUpgradePreview(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getGiftUpgradePreview(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getUpgradedGiftVariants(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getUpgradedGiftVariants(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_upgradeGift(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::upgradeGift(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_buyGiftUpgrade(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::buyGiftUpgrade(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_craftGift(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::craftGift(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_transferGift(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::transferGift(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_dropGiftOriginalDetails(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::dropGiftOriginalDetails(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendResoldGift(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendResoldGift(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendGiftPurchaseOffer(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendGiftPurchaseOffer(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_processGiftPurchaseOffer(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::processGiftPurchaseOffer(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getReceivedGifts(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getReceivedGifts(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getReceivedGift(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getReceivedGift(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getGiftsForCrafting(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getGiftsForCrafting(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getUpgradedGift(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getUpgradedGift(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getUpgradedGiftValueInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getUpgradedGiftValueInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getUpgradedGiftWithdrawalUrl(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getUpgradedGiftWithdrawalUrl(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getUpgradedGiftsPromotionalAnimation(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getUpgradedGiftsPromotionalAnimation(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setGiftResalePrice(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setGiftResalePrice(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchGiftsForResale(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchGiftsForResale(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getGiftCollections(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getGiftCollections(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_createGiftCollection(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createGiftCollection(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reorderGiftCollections(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reorderGiftCollections(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteGiftCollection(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteGiftCollection(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setGiftCollectionName(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setGiftCollectionName(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addGiftCollectionGifts(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addGiftCollectionGifts(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeGiftCollectionGifts(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeGiftCollectionGifts(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reorderGiftCollectionGifts(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reorderGiftCollectionGifts(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_createInvoiceLink(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createInvoiceLink(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_refundStarPayment(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::refundStarPayment(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getSupportUser(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getSupportUser(clientId, paramsJson);
    return nullptr;
}

// ==================== 背景 ====================
napi_value NAPI_getBackgroundUrl(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getBackgroundUrl(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchBackground(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchBackground(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setDefaultBackground(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setDefaultBackground(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteDefaultBackground(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteDefaultBackground(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getInstalledBackgrounds(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getInstalledBackgrounds(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeInstalledBackground(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeInstalledBackground(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_resetInstalledBackgrounds(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::resetInstalledBackgrounds(clientId, paramsJson);
    return nullptr;
}

// ==================== 本地化 ====================
napi_value NAPI_getLocalizationTargetInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getLocalizationTargetInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getLanguagePackInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getLanguagePackInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getLanguagePackStrings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getLanguagePackStrings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_synchronizeLanguagePack(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::synchronizeLanguagePack(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addCustomServerLanguagePack(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addCustomServerLanguagePack(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setCustomLanguagePack(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setCustomLanguagePack(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editCustomLanguagePackInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editCustomLanguagePackInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setCustomLanguagePackString(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setCustomLanguagePackString(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteLanguagePack(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteLanguagePack(clientId, paramsJson);
    return nullptr;
}

// ==================== 推送通知 ====================
napi_value NAPI_registerDevice(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::registerDevice(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_processPushNotification(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::processPushNotification(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getPushReceiverId(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPushReceiverId(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getRecentlyVisitedTMeUrls(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getRecentlyVisitedTMeUrls(clientId, paramsJson);
    return nullptr;
}

// ==================== 隐私设置 ====================
napi_value NAPI_setUserPrivacySettingRules(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setUserPrivacySettingRules(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getUserPrivacySettingRules(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getUserPrivacySettingRules(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setReadDatePrivacySettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setReadDatePrivacySettings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getReadDatePrivacySettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getReadDatePrivacySettings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setNewChatPrivacySettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setNewChatPrivacySettings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getNewChatPrivacySettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getNewChatPrivacySettings(clientId, paramsJson);
    return nullptr;
}

// ==================== 付费消息与收入 ====================
napi_value NAPI_getPaidMessageRevenue(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPaidMessageRevenue(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_allowUnpaidMessagesFromUser(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::allowUnpaidMessagesFromUser(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setChatPaidMessageStarCount(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatPaidMessageStarCount(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_canSendMessageToUser(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::canSendMessageToUser(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getOption(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getOption(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setOption(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setOption(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setAccountTtl(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setAccountTtl(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getAccountTtl(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getAccountTtl(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteAccount(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteAccount(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setDefaultMessageAutoDeleteTime(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setDefaultMessageAutoDeleteTime(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getDefaultMessageAutoDeleteTime(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getDefaultMessageAutoDeleteTime(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeChatActionBar(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeChatActionBar(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reportChat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reportChat(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reportChatPhoto(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reportChatPhoto(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reportMessageReactions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reportMessageReactions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatRevenueStatistics(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatRevenueStatistics(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatRevenueWithdrawalUrl(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatRevenueWithdrawalUrl(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatRevenueTransactions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatRevenueTransactions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getTonTransactions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getTonTransactions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStarRevenueStatistics(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStarRevenueStatistics(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStarWithdrawalUrl(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStarWithdrawalUrl(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStarAdAccountUrl(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStarAdAccountUrl(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getTonRevenueStatistics(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getTonRevenueStatistics(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getTonWithdrawalUrl(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getTonWithdrawalUrl(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getChatStatistics(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getChatStatistics(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMessageStatistics(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMessageStatistics(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getMessagePublicForwards(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getMessagePublicForwards(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStoryStatistics(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStoryStatistics(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStatisticalGraph(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStatisticalGraph(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStorageStatistics(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStorageStatistics(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStorageStatisticsFast(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStorageStatisticsFast(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getDatabaseStatistics(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getDatabaseStatistics(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_optimizeStorage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::optimizeStorage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setNetworkType(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setNetworkType(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getNetworkStatistics(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getNetworkStatistics(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addNetworkStatistics(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addNetworkStatistics(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_resetNetworkStatistics(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::resetNetworkStatistics(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getAutosaveSettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getAutosaveSettings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setAutosaveSettings(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setAutosaveSettings(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_clearAutosaveSettingsExceptions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::clearAutosaveSettingsExceptions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getBankCardInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getBankCardInfo(clientId, paramsJson);
    return nullptr;
}

// ==================== 证件信息 ====================
napi_value NAPI_getPassportElement(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPassportElement(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getAllPassportElements(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getAllPassportElements(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setPassportElement(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setPassportElement(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deletePassportElement(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deletePassportElement(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setPassportElementErrors(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setPassportElementErrors(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getPreferredCountryLanguage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPreferredCountryLanguage(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendEmailAddressVerificationCode(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendEmailAddressVerificationCode(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_resendEmailAddressVerificationCode(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::resendEmailAddressVerificationCode(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_checkEmailAddressVerificationCode(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::checkEmailAddressVerificationCode(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getPassportAuthorizationForm(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPassportAuthorizationForm(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getPassportAuthorizationFormAvailableElements(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPassportAuthorizationFormAvailableElements(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendPassportAuthorizationForm(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendPassportAuthorizationForm(clientId, paramsJson);
    return nullptr;
}

// ==================== 机器人更新 ====================
napi_value NAPI_setBotUpdatesStatus(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setBotUpdatesStatus(clientId, paramsJson);
    return nullptr;
}

// ==================== 贴纸集管理 ====================
napi_value NAPI_createNewStickerSet(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::createNewStickerSet(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addStickerToSet(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addStickerToSet(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_replaceStickerInSet(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::replaceStickerInSet(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setStickerSetThumbnail(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setStickerSetThumbnail(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setCustomEmojiStickerSetThumbnail(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setCustomEmojiStickerSetThumbnail(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setStickerSetTitle(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setStickerSetTitle(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_deleteStickerSet(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::deleteStickerSet(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setStickerPositionInSet(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setStickerPositionInSet(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeStickerFromSet(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeStickerFromSet(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setStickerEmojis(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setStickerEmojis(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setStickerKeywords(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setStickerKeywords(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setStickerMaskPosition(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setStickerMaskPosition(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getOwnedStickerSets(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getOwnedStickerSets(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getPremiumLimit(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPremiumLimit(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getPremiumFeatures(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPremiumFeatures(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getPremiumStickerExamples(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPremiumStickerExamples(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getPremiumInfoSticker(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPremiumInfoSticker(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_viewPremiumFeature(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::viewPremiumFeature(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_clickPremiumSubscriptionButton(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::clickPremiumSubscriptionButton(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getPremiumState(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPremiumState(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getPremiumGiftPaymentOptions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPremiumGiftPaymentOptions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getPremiumGiveawayPaymentOptions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPremiumGiveawayPaymentOptions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_checkPremiumGiftCode(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::checkPremiumGiftCode(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_applyPremiumGiftCode(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::applyPremiumGiftCode(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_giftPremiumWithStars(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::giftPremiumWithStars(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_launchPrepaidGiveaway(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::launchPrepaidGiveaway(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getGiveawayInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getGiveawayInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStarPaymentOptions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStarPaymentOptions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStarGiftPaymentOptions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStarGiftPaymentOptions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStarGiveawayPaymentOptions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStarGiveawayPaymentOptions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStarTransactions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStarTransactions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getStarSubscriptions(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getStarSubscriptions(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_canPurchaseFromStore(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::canPurchaseFromStore(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_assignStoreTransaction(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::assignStoreTransaction(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editStarSubscription(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editStarSubscription(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editUserStarSubscription(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editUserStarSubscription(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_reuseStarSubscription(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::reuseStarSubscription(clientId, paramsJson);
    return nullptr;
}

// ==================== 联盟计划 ====================
napi_value NAPI_setChatAffiliateProgram(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setChatAffiliateProgram(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchChatAffiliateProgram(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchChatAffiliateProgram(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchAffiliatePrograms(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchAffiliatePrograms(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_connectAffiliateProgram(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::connectAffiliateProgram(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_disconnectAffiliateProgram(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::disconnectAffiliateProgram(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getConnectedAffiliateProgram(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getConnectedAffiliateProgram(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getConnectedAffiliatePrograms(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getConnectedAffiliatePrograms(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getBusinessFeatures(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getBusinessFeatures(clientId, paramsJson);
    return nullptr;
}

// ==================== 服务条款 ====================
napi_value NAPI_acceptTermsOfService(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::acceptTermsOfService(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_searchStringsByPrefix(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::searchStringsByPrefix(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_sendCustomRequest(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::sendCustomRequest(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_answerCustomQuery(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::answerCustomQuery(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setAlarm(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setAlarm(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getCountries(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getCountries(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getCountryCode(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getCountryCode(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getPhoneNumberInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPhoneNumberInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getPhoneNumberInfoSync(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getPhoneNumberInfoSync(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getCollectibleItemInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getCollectibleItemInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getDeepLinkInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getDeepLinkInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getApplicationConfig(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getApplicationConfig(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_saveApplicationLogEvent(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::saveApplicationLogEvent(clientId, paramsJson);
    return nullptr;
}

// ==================== 代理 ====================
napi_value NAPI_addProxy(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addProxy(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_editProxy(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::editProxy(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_enableProxy(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::enableProxy(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_disableProxy(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::disableProxy(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_removeProxy(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::removeProxy(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getProxies(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getProxies(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_pingProxy(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::pingProxy(clientId, paramsJson);
    return nullptr;
}

// ==================== 日志 ====================
napi_value NAPI_setLogStream(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setLogStream(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getLogStream(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getLogStream(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setLogVerbosityLevel(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setLogVerbosityLevel(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getLogVerbosityLevel(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getLogVerbosityLevel(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getLogTags(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getLogTags(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setLogTagVerbosityLevel(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setLogTagVerbosityLevel(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getLogTagVerbosityLevel(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getLogTagVerbosityLevel(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_addLogMessage(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::addLogMessage(clientId, paramsJson);
    return nullptr;
}

// ==================== 支持 ====================
napi_value NAPI_getUserSupportInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getUserSupportInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_setUserSupportInfo(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::setUserSupportInfo(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_getSupportName(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::getSupportName(clientId, paramsJson);
    return nullptr;
}

// ==================== 测试方法 ====================
napi_value NAPI_testCallEmpty(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::testCallEmpty(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_testCallString(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::testCallString(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_testCallBytes(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::testCallBytes(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_testCallVectorInt(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::testCallVectorInt(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_testCallVectorIntObject(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::testCallVectorIntObject(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_testCallVectorString(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::testCallVectorString(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_testCallVectorStringObject(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::testCallVectorStringObject(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_testSquareInt(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::testSquareInt(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_testNetwork(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::testNetwork(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_testProxy(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::testProxy(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_testGetDifference(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::testGetDifference(clientId, paramsJson);
    return nullptr;
}
napi_value NAPI_testUseUpdate(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = napi_helper::getInt32(env, args, 0);
    std::string paramsJson = napi_helper::getString(env, args, 1);
    tdlib::api::testUseUpdate(clientId, paramsJson);
    return nullptr;
}

// 注册所有 API 绑定
void registerAllBindings(napi_env env, napi_value exports) {
    napi_property_descriptor properties[] = {
        // 认证与授权 (已在前面的模块中定义，这里需要完整列出所有)
        {"getAuthorizationState", nullptr, NAPI_getAuthorizationState, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setTdlibParameters", nullptr, NAPI_setTdlibParameters, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setAuthenticationPhoneNumber", nullptr, NAPI_setAuthenticationPhoneNumber, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"checkAuthenticationPremiumPurchase", nullptr, NAPI_checkAuthenticationPremiumPurchase, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setAuthenticationPremiumPurchaseTransaction", nullptr, NAPI_setAuthenticationPremiumPurchaseTransaction, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setAuthenticationEmailAddress", nullptr, NAPI_setAuthenticationEmailAddress, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"resendAuthenticationCode", nullptr, NAPI_resendAuthenticationCode, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"checkAuthenticationEmailCode", nullptr, NAPI_checkAuthenticationEmailCode, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"checkAuthenticationCode", nullptr, NAPI_checkAuthenticationCode, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"requestQrCodeAuthentication", nullptr, NAPI_requestQrCodeAuthentication, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getAuthenticationPasskeyParameters", nullptr, NAPI_getAuthenticationPasskeyParameters, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"checkAuthenticationPasskey", nullptr, NAPI_checkAuthenticationPasskey, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"registerUser", nullptr, NAPI_registerUser, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"resetAuthenticationEmailAddress", nullptr, NAPI_resetAuthenticationEmailAddress, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"checkAuthenticationPassword", nullptr, NAPI_checkAuthenticationPassword, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"requestAuthenticationPasswordRecovery", nullptr, NAPI_requestAuthenticationPasswordRecovery, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"checkAuthenticationPasswordRecoveryCode", nullptr, NAPI_checkAuthenticationPasswordRecoveryCode, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"recoverAuthenticationPassword", nullptr, NAPI_recoverAuthenticationPassword, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendAuthenticationFirebaseSms", nullptr, NAPI_sendAuthenticationFirebaseSms, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reportAuthenticationCodeMissing", nullptr, NAPI_reportAuthenticationCodeMissing, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"checkAuthenticationBotToken", nullptr, NAPI_checkAuthenticationBotToken, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"logOut", nullptr, NAPI_logOut, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"close", nullptr, NAPI_close, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"destroy", nullptr, NAPI_destroy, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"confirmQrCodeAuthentication", nullptr, NAPI_confirmQrCodeAuthentication, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getCurrentState", nullptr, NAPI_getCurrentState, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setDatabaseEncryptionKey", nullptr, NAPI_setDatabaseEncryptionKey, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPasswordState", nullptr, NAPI_getPasswordState, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setPassword", nullptr, NAPI_setPassword, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"isLoginEmailAddressRequired", nullptr, NAPI_isLoginEmailAddressRequired, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setLoginEmailAddress", nullptr, NAPI_setLoginEmailAddress, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"resendLoginEmailAddressCode", nullptr, NAPI_resendLoginEmailAddressCode, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"checkLoginEmailAddressCode", nullptr, NAPI_checkLoginEmailAddressCode, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getRecoveryEmailAddress", nullptr, NAPI_getRecoveryEmailAddress, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setRecoveryEmailAddress", nullptr, NAPI_setRecoveryEmailAddress, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"checkRecoveryEmailAddressCode", nullptr, NAPI_checkRecoveryEmailAddressCode, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"resendRecoveryEmailAddressCode", nullptr, NAPI_resendRecoveryEmailAddressCode, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"cancelRecoveryEmailAddressVerification", nullptr, NAPI_cancelRecoveryEmailAddressVerification, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"requestPasswordRecovery", nullptr, NAPI_requestPasswordRecovery, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"checkPasswordRecoveryCode", nullptr, NAPI_checkPasswordRecoveryCode, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"recoverPassword", nullptr, NAPI_recoverPassword, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"resetPassword", nullptr, NAPI_resetPassword, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"cancelPasswordReset", nullptr, NAPI_cancelPasswordReset, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createTemporaryPassword", nullptr, NAPI_createTemporaryPassword, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getTemporaryPasswordState", nullptr, NAPI_getTemporaryPasswordState, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 用户与个人资料
        {"getMe", nullptr, NAPI_getMe, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getUser", nullptr, NAPI_getUser, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getUserFullInfo", nullptr, NAPI_getUserFullInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getBasicGroup", nullptr, NAPI_getBasicGroup, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getBasicGroupFullInfo", nullptr, NAPI_getBasicGroupFullInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSupergroup", nullptr, NAPI_getSupergroup, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSupergroupFullInfo", nullptr, NAPI_getSupergroupFullInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSecretChat", nullptr, NAPI_getSecretChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getUserProfilePhotos", nullptr, NAPI_getUserProfilePhotos, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getUserProfileAudios", nullptr, NAPI_getUserProfileAudios, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"isProfileAudio", nullptr, NAPI_isProfileAudio, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addProfileAudio", nullptr, NAPI_addProfileAudio, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setProfileAudioPosition", nullptr, NAPI_setProfileAudioPosition, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeProfileAudio", nullptr, NAPI_removeProfileAudio, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setUserPersonalProfilePhoto", nullptr, NAPI_setUserPersonalProfilePhoto, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setUserNote", nullptr, NAPI_setUserNote, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"suggestUserProfilePhoto", nullptr, NAPI_suggestUserProfilePhoto, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"suggestUserBirthdate", nullptr, NAPI_suggestUserBirthdate, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleBotCanManageEmojiStatus", nullptr, NAPI_toggleBotCanManageEmojiStatus, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setUserEmojiStatus", nullptr, NAPI_setUserEmojiStatus, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchUserByPhoneNumber", nullptr, NAPI_searchUserByPhoneNumber, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sharePhoneNumber", nullptr, NAPI_sharePhoneNumber, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setProfilePhoto", nullptr, NAPI_setProfilePhoto, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteProfilePhoto", nullptr, NAPI_deleteProfilePhoto, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setAccentColor", nullptr, NAPI_setAccentColor, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setUpgradedGiftColors", nullptr, NAPI_setUpgradedGiftColors, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setProfileAccentColor", nullptr, NAPI_setProfileAccentColor, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setName", nullptr, NAPI_setName, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setBio", nullptr, NAPI_setBio, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setUsername", nullptr, NAPI_setUsername, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleUsernameIsActive", nullptr, NAPI_toggleUsernameIsActive, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reorderActiveUsernames", nullptr, NAPI_reorderActiveUsernames, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setBirthdate", nullptr, NAPI_setBirthdate, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setMainProfileTab", nullptr, NAPI_setMainProfileTab, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setPersonalChat", nullptr, NAPI_setPersonalChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setEmojiStatus", nullptr, NAPI_setEmojiStatus, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleHasSponsoredMessagesEnabled", nullptr, NAPI_toggleHasSponsoredMessagesEnabled, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setBusinessLocation", nullptr, NAPI_setBusinessLocation, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setBusinessOpeningHours", nullptr, NAPI_setBusinessOpeningHours, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setBusinessGreetingMessageSettings", nullptr, NAPI_setBusinessGreetingMessageSettings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setBusinessAwayMessageSettings", nullptr, NAPI_setBusinessAwayMessageSettings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setBusinessStartPage", nullptr, NAPI_setBusinessStartPage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getBusinessConnectedBot", nullptr, NAPI_getBusinessConnectedBot, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setBusinessConnectedBot", nullptr, NAPI_setBusinessConnectedBot, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteBusinessConnectedBot", nullptr, NAPI_deleteBusinessConnectedBot, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleBusinessConnectedBotChatIsPaused", nullptr, NAPI_toggleBusinessConnectedBotChatIsPaused, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeBusinessConnectedBotFromChat", nullptr, NAPI_removeBusinessConnectedBotFromChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getBusinessChatLinks", nullptr, NAPI_getBusinessChatLinks, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createBusinessChatLink", nullptr, NAPI_createBusinessChatLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editBusinessChatLink", nullptr, NAPI_editBusinessChatLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteBusinessChatLink", nullptr, NAPI_deleteBusinessChatLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getBusinessChatLinkInfo", nullptr, NAPI_getBusinessChatLinkInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getUserLink", nullptr, NAPI_getUserLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchUserByToken", nullptr, NAPI_searchUserByToken, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 聊天管理 (此处仅列出部分，完整列表参考上面实现)
        {"getChat", nullptr, NAPI_getChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMessage", nullptr, NAPI_getMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMessageLocally", nullptr, NAPI_getMessageLocally, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getRepliedMessage", nullptr, NAPI_getRepliedMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatPinnedMessage", nullptr, NAPI_getChatPinnedMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getCallbackQueryMessage", nullptr, NAPI_getCallbackQueryMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMessages", nullptr, NAPI_getMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMessageProperties", nullptr, NAPI_getMessageProperties, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMessageThread", nullptr, NAPI_getMessageThread, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMessageReadDate", nullptr, NAPI_getMessageReadDate, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMessageViewers", nullptr, NAPI_getMessageViewers, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMessageAuthor", nullptr, NAPI_getMessageAuthor, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"loadChats", nullptr, NAPI_loadChats, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChats", nullptr, NAPI_getChats, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchPublicChat", nullptr, NAPI_searchPublicChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchPublicChats", nullptr, NAPI_searchPublicChats, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchChats", nullptr, NAPI_searchChats, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchChatsOnServer", nullptr, NAPI_searchChatsOnServer, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getRecommendedChats", nullptr, NAPI_getRecommendedChats, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatSimilarChats", nullptr, NAPI_getChatSimilarChats, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatSimilarChatCount", nullptr, NAPI_getChatSimilarChatCount, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"openChatSimilarChat", nullptr, NAPI_openChatSimilarChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getBotSimilarBots", nullptr, NAPI_getBotSimilarBots, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getBotSimilarBotCount", nullptr, NAPI_getBotSimilarBotCount, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"openBotSimilarBot", nullptr, NAPI_openBotSimilarBot, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getTopChats", nullptr, NAPI_getTopChats, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeTopChat", nullptr, NAPI_removeTopChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchRecentlyFoundChats", nullptr, NAPI_searchRecentlyFoundChats, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addRecentlyFoundChat", nullptr, NAPI_addRecentlyFoundChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeRecentlyFoundChat", nullptr, NAPI_removeRecentlyFoundChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"clearRecentlyFoundChats", nullptr, NAPI_clearRecentlyFoundChats, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getRecentlyOpenedChats", nullptr, NAPI_getRecentlyOpenedChats, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"checkChatUsername", nullptr, NAPI_checkChatUsername, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getCreatedPublicChats", nullptr, NAPI_getCreatedPublicChats, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"checkCreatedPublicChatsLimit", nullptr, NAPI_checkCreatedPublicChatsLimit, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSuitableDiscussionChats", nullptr, NAPI_getSuitableDiscussionChats, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getInactiveSupergroupChats", nullptr, NAPI_getInactiveSupergroupChats, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSuitablePersonalChats", nullptr, NAPI_getSuitablePersonalChats, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"loadDirectMessagesChatTopics", nullptr, NAPI_loadDirectMessagesChatTopics, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getDirectMessagesChatTopic", nullptr, NAPI_getDirectMessagesChatTopic, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getDirectMessagesChatTopicHistory", nullptr, NAPI_getDirectMessagesChatTopicHistory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getDirectMessagesChatTopicMessageByDate", nullptr, NAPI_getDirectMessagesChatTopicMessageByDate, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteDirectMessagesChatTopicHistory", nullptr, NAPI_deleteDirectMessagesChatTopicHistory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteDirectMessagesChatTopicMessagesByDate", nullptr, NAPI_deleteDirectMessagesChatTopicMessagesByDate, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setDirectMessagesChatTopicIsMarkedAsUnread", nullptr, NAPI_setDirectMessagesChatTopicIsMarkedAsUnread, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"unpinAllDirectMessagesChatTopicMessages", nullptr, NAPI_unpinAllDirectMessagesChatTopicMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"readAllDirectMessagesChatTopicReactions", nullptr, NAPI_readAllDirectMessagesChatTopicReactions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getDirectMessagesChatTopicRevenue", nullptr, NAPI_getDirectMessagesChatTopicRevenue, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleDirectMessagesChatTopicCanSendUnpaidMessages", nullptr, NAPI_toggleDirectMessagesChatTopicCanSendUnpaidMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"loadSavedMessagesTopics", nullptr, NAPI_loadSavedMessagesTopics, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSavedMessagesTopicHistory", nullptr, NAPI_getSavedMessagesTopicHistory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSavedMessagesTopicMessageByDate", nullptr, NAPI_getSavedMessagesTopicMessageByDate, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteSavedMessagesTopicHistory", nullptr, NAPI_deleteSavedMessagesTopicHistory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteSavedMessagesTopicMessagesByDate", nullptr, NAPI_deleteSavedMessagesTopicMessagesByDate, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleSavedMessagesTopicIsPinned", nullptr, NAPI_toggleSavedMessagesTopicIsPinned, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setPinnedSavedMessagesTopics", nullptr, NAPI_setPinnedSavedMessagesTopics, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getGroupsInCommon", nullptr, NAPI_getGroupsInCommon, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatHistory", nullptr, NAPI_getChatHistory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMessageThreadHistory", nullptr, NAPI_getMessageThreadHistory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteChatHistory", nullptr, NAPI_deleteChatHistory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteChat", nullptr, NAPI_deleteChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchChatMessages", nullptr, NAPI_searchChatMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchMessages", nullptr, NAPI_searchMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchSecretMessages", nullptr, NAPI_searchSecretMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchSavedMessages", nullptr, NAPI_searchSavedMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchCallMessages", nullptr, NAPI_searchCallMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchOutgoingDocumentMessages", nullptr, NAPI_searchOutgoingDocumentMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPublicPostSearchLimits", nullptr, NAPI_getPublicPostSearchLimits, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchPublicPosts", nullptr, NAPI_searchPublicPosts, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchPublicMessagesByTag", nullptr, NAPI_searchPublicMessagesByTag, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchPublicStoriesByTag", nullptr, NAPI_searchPublicStoriesByTag, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchPublicStoriesByLocation", nullptr, NAPI_searchPublicStoriesByLocation, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchPublicStoriesByVenue", nullptr, NAPI_searchPublicStoriesByVenue, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSearchedForTags", nullptr, NAPI_getSearchedForTags, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeSearchedForTag", nullptr, NAPI_removeSearchedForTag, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"clearSearchedForTags", nullptr, NAPI_clearSearchedForTags, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteAllCallMessages", nullptr, NAPI_deleteAllCallMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchChatRecentLocationMessages", nullptr, NAPI_searchChatRecentLocationMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatMessageByDate", nullptr, NAPI_getChatMessageByDate, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatSparseMessagePositions", nullptr, NAPI_getChatSparseMessagePositions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatMessageCalendar", nullptr, NAPI_getChatMessageCalendar, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatMessageCount", nullptr, NAPI_getChatMessageCount, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatMessagePosition", nullptr, NAPI_getChatMessagePosition, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatScheduledMessages", nullptr, NAPI_getChatScheduledMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatSponsoredMessages", nullptr, NAPI_getChatSponsoredMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"clickChatSponsoredMessage", nullptr, NAPI_clickChatSponsoredMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reportChatSponsoredMessage", nullptr, NAPI_reportChatSponsoredMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSearchSponsoredChats", nullptr, NAPI_getSearchSponsoredChats, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"viewSponsoredChat", nullptr, NAPI_viewSponsoredChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"openSponsoredChat", nullptr, NAPI_openSponsoredChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reportSponsoredChat", nullptr, NAPI_reportSponsoredChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getVideoMessageAdvertisements", nullptr, NAPI_getVideoMessageAdvertisements, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"viewVideoMessageAdvertisement", nullptr, NAPI_viewVideoMessageAdvertisement, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"clickVideoMessageAdvertisement", nullptr, NAPI_clickVideoMessageAdvertisement, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reportVideoMessageAdvertisement", nullptr, NAPI_reportVideoMessageAdvertisement, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeNotification", nullptr, NAPI_removeNotification, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeNotificationGroup", nullptr, NAPI_removeNotificationGroup, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMessageLink", nullptr, NAPI_getMessageLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMessageEmbeddingCode", nullptr, NAPI_getMessageEmbeddingCode, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMessageLinkInfo", nullptr, NAPI_getMessageLinkInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"translateText", nullptr, NAPI_translateText, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"translateMessageText", nullptr, NAPI_translateMessageText, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"summarizeMessage", nullptr, NAPI_summarizeMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"recognizeSpeech", nullptr, NAPI_recognizeSpeech, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"rateSpeechRecognition", nullptr, NAPI_rateSpeechRecognition, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatAvailableMessageSenders", nullptr, NAPI_getChatAvailableMessageSenders, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatMessageSender", nullptr, NAPI_setChatMessageSender, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 消息操作
        {"sendMessage", nullptr, NAPI_sendMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendMessageAlbum", nullptr, NAPI_sendMessageAlbum, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendBotStartMessage", nullptr, NAPI_sendBotStartMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendInlineQueryResultMessage", nullptr, NAPI_sendInlineQueryResultMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"forwardMessages", nullptr, NAPI_forwardMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendQuickReplyShortcutMessages", nullptr, NAPI_sendQuickReplyShortcutMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"resendMessages", nullptr, NAPI_resendMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addLocalMessage", nullptr, NAPI_addLocalMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteMessages", nullptr, NAPI_deleteMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteChatMessagesBySender", nullptr, NAPI_deleteChatMessagesBySender, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteChatMessagesByDate", nullptr, NAPI_deleteChatMessagesByDate, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editMessageText", nullptr, NAPI_editMessageText, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editMessageLiveLocation", nullptr, NAPI_editMessageLiveLocation, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editMessageChecklist", nullptr, NAPI_editMessageChecklist, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editMessageMedia", nullptr, NAPI_editMessageMedia, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editMessageCaption", nullptr, NAPI_editMessageCaption, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editMessageReplyMarkup", nullptr, NAPI_editMessageReplyMarkup, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editInlineMessageText", nullptr, NAPI_editInlineMessageText, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editInlineMessageLiveLocation", nullptr, NAPI_editInlineMessageLiveLocation, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editInlineMessageMedia", nullptr, NAPI_editInlineMessageMedia, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editInlineMessageCaption", nullptr, NAPI_editInlineMessageCaption, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editInlineMessageReplyMarkup", nullptr, NAPI_editInlineMessageReplyMarkup, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editMessageSchedulingState", nullptr, NAPI_editMessageSchedulingState, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setMessageFactCheck", nullptr, NAPI_setMessageFactCheck, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendBusinessMessage", nullptr, NAPI_sendBusinessMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendBusinessMessageAlbum", nullptr, NAPI_sendBusinessMessageAlbum, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editBusinessMessageText", nullptr, NAPI_editBusinessMessageText, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editBusinessMessageLiveLocation", nullptr, NAPI_editBusinessMessageLiveLocation, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editBusinessMessageChecklist", nullptr, NAPI_editBusinessMessageChecklist, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editBusinessMessageMedia", nullptr, NAPI_editBusinessMessageMedia, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editBusinessMessageCaption", nullptr, NAPI_editBusinessMessageCaption, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editBusinessMessageReplyMarkup", nullptr, NAPI_editBusinessMessageReplyMarkup, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"stopBusinessPoll", nullptr, NAPI_stopBusinessPoll, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setBusinessMessageIsPinned", nullptr, NAPI_setBusinessMessageIsPinned, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"readBusinessMessage", nullptr, NAPI_readBusinessMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteBusinessMessages", nullptr, NAPI_deleteBusinessMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editBusinessStory", nullptr, NAPI_editBusinessStory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteBusinessStory", nullptr, NAPI_deleteBusinessStory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setBusinessAccountName", nullptr, NAPI_setBusinessAccountName, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setBusinessAccountBio", nullptr, NAPI_setBusinessAccountBio, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setBusinessAccountProfilePhoto", nullptr, NAPI_setBusinessAccountProfilePhoto, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setBusinessAccountUsername", nullptr, NAPI_setBusinessAccountUsername, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setBusinessAccountGiftSettings", nullptr, NAPI_setBusinessAccountGiftSettings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getBusinessAccountStarAmount", nullptr, NAPI_getBusinessAccountStarAmount, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"transferBusinessAccountStars", nullptr, NAPI_transferBusinessAccountStars, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"checkQuickReplyShortcutName", nullptr, NAPI_checkQuickReplyShortcutName, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"loadQuickReplyShortcuts", nullptr, NAPI_loadQuickReplyShortcuts, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setQuickReplyShortcutName", nullptr, NAPI_setQuickReplyShortcutName, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteQuickReplyShortcut", nullptr, NAPI_deleteQuickReplyShortcut, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reorderQuickReplyShortcuts", nullptr, NAPI_reorderQuickReplyShortcuts, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"loadQuickReplyShortcutMessages", nullptr, NAPI_loadQuickReplyShortcutMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteQuickReplyShortcutMessages", nullptr, NAPI_deleteQuickReplyShortcutMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addQuickReplyShortcutMessage", nullptr, NAPI_addQuickReplyShortcutMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addQuickReplyShortcutInlineQueryResultMessage", nullptr, NAPI_addQuickReplyShortcutInlineQueryResultMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addQuickReplyShortcutMessageAlbum", nullptr, NAPI_addQuickReplyShortcutMessageAlbum, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"readdQuickReplyShortcutMessages", nullptr, NAPI_readdQuickReplyShortcutMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editQuickReplyMessage", nullptr, NAPI_editQuickReplyMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getForumTopicDefaultIcons", nullptr, NAPI_getForumTopicDefaultIcons, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createForumTopic", nullptr, NAPI_createForumTopic, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editForumTopic", nullptr, NAPI_editForumTopic, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getForumTopic", nullptr, NAPI_getForumTopic, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getForumTopicHistory", nullptr, NAPI_getForumTopicHistory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getForumTopicLink", nullptr, NAPI_getForumTopicLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getForumTopics", nullptr, NAPI_getForumTopics, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setForumTopicNotificationSettings", nullptr, NAPI_setForumTopicNotificationSettings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleForumTopicIsClosed", nullptr, NAPI_toggleForumTopicIsClosed, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleGeneralForumTopicIsHidden", nullptr, NAPI_toggleGeneralForumTopicIsHidden, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleForumTopicIsPinned", nullptr, NAPI_toggleForumTopicIsPinned, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setPinnedForumTopics", nullptr, NAPI_setPinnedForumTopics, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteForumTopic", nullptr, NAPI_deleteForumTopic, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"readAllForumTopicMentions", nullptr, NAPI_readAllForumTopicMentions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"readAllForumTopicReactions", nullptr, NAPI_readAllForumTopicReactions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"unpinAllForumTopicMessages", nullptr, NAPI_unpinAllForumTopicMessages, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 反应与表情
        {"getPasskeyParameters", nullptr, NAPI_getPasskeyParameters, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addLoginPasskey", nullptr, NAPI_addLoginPasskey, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getLoginPasskeys", nullptr, NAPI_getLoginPasskeys, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeLoginPasskey", nullptr, NAPI_removeLoginPasskey, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getEmojiReaction", nullptr, NAPI_getEmojiReaction, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getCustomEmojiReactionAnimations", nullptr, NAPI_getCustomEmojiReactionAnimations, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMessageAvailableReactions", nullptr, NAPI_getMessageAvailableReactions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"clearRecentReactions", nullptr, NAPI_clearRecentReactions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addMessageReaction", nullptr, NAPI_addMessageReaction, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeMessageReaction", nullptr, NAPI_removeMessageReaction, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatAvailablePaidMessageReactionSenders", nullptr, NAPI_getChatAvailablePaidMessageReactionSenders, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addPendingPaidMessageReaction", nullptr, NAPI_addPendingPaidMessageReaction, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"commitPendingPaidMessageReactions", nullptr, NAPI_commitPendingPaidMessageReactions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removePendingPaidMessageReactions", nullptr, NAPI_removePendingPaidMessageReactions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setPaidMessageReactionType", nullptr, NAPI_setPaidMessageReactionType, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setMessageReactions", nullptr, NAPI_setMessageReactions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMessageAddedReactions", nullptr, NAPI_getMessageAddedReactions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setDefaultReactionType", nullptr, NAPI_setDefaultReactionType, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSavedMessagesTags", nullptr, NAPI_getSavedMessagesTags, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setSavedMessagesTagLabel", nullptr, NAPI_setSavedMessagesTagLabel, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMessageEffect", nullptr, NAPI_getMessageEffect, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchQuote", nullptr, NAPI_searchQuote, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 文本处理
        {"getTextEntities", nullptr, NAPI_getTextEntities, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"parseTextEntities", nullptr, NAPI_parseTextEntities, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"parseMarkdown", nullptr, NAPI_parseMarkdown, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMarkdownText", nullptr, NAPI_getMarkdownText, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getCountryFlagEmoji", nullptr, NAPI_getCountryFlagEmoji, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getFileMimeType", nullptr, NAPI_getFileMimeType, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getFileExtension", nullptr, NAPI_getFileExtension, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"cleanFileName", nullptr, NAPI_cleanFileName, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getLanguagePackString", nullptr, NAPI_getLanguagePackString, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getJsonValue", nullptr, NAPI_getJsonValue, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getJsonString", nullptr, NAPI_getJsonString, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getThemeParametersJsonString", nullptr, NAPI_getThemeParametersJsonString, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 投票与清单
        {"setPollAnswer", nullptr, NAPI_setPollAnswer, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPollVoters", nullptr, NAPI_getPollVoters, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"stopPoll", nullptr, NAPI_stopPoll, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addChecklistTasks", nullptr, NAPI_addChecklistTasks, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"markChecklistTasksAsDone", nullptr, NAPI_markChecklistTasksAsDone, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 建议操作
        {"hideSuggestedAction", nullptr, NAPI_hideSuggestedAction, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"hideContactCloseBirthdays", nullptr, NAPI_hideContactCloseBirthdays, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 业务连接
        {"getBusinessConnection", nullptr, NAPI_getBusinessConnection, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 登录 URL
        {"getLoginUrlInfo", nullptr, NAPI_getLoginUrlInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getLoginUrl", nullptr, NAPI_getLoginUrl, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"shareUsersWithBot", nullptr, NAPI_shareUsersWithBot, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"shareChatWithBot", nullptr, NAPI_shareChatWithBot, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 内联查询
        {"getInlineQueryResults", nullptr, NAPI_getInlineQueryResults, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"answerInlineQuery", nullptr, NAPI_answerInlineQuery, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"savePreparedInlineMessage", nullptr, NAPI_savePreparedInlineMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPreparedInlineMessage", nullptr, NAPI_getPreparedInlineMessage, nullptr, nullptr, nullptr, napi_default, nullptr},

        // Web 应用
        {"getGrossingWebAppBots", nullptr, NAPI_getGrossingWebAppBots, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchWebApp", nullptr, NAPI_searchWebApp, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getWebAppPlaceholder", nullptr, NAPI_getWebAppPlaceholder, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getWebAppLinkUrl", nullptr, NAPI_getWebAppLinkUrl, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMainWebApp", nullptr, NAPI_getMainWebApp, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getWebAppUrl", nullptr, NAPI_getWebAppUrl, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendWebAppData", nullptr, NAPI_sendWebAppData, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"openWebApp", nullptr, NAPI_openWebApp, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"closeWebApp", nullptr, NAPI_closeWebApp, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"answerWebAppQuery", nullptr, NAPI_answerWebAppQuery, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"checkWebAppFileDownload", nullptr, NAPI_checkWebAppFileDownload, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 回调查询
        {"getCallbackQueryAnswer", nullptr, NAPI_getCallbackQueryAnswer, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"answerCallbackQuery", nullptr, NAPI_answerCallbackQuery, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"answerShippingQuery", nullptr, NAPI_answerShippingQuery, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"answerPreCheckoutQuery", nullptr, NAPI_answerPreCheckoutQuery, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 游戏
        {"setGameScore", nullptr, NAPI_setGameScore, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setInlineGameScore", nullptr, NAPI_setInlineGameScore, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getGameHighScores", nullptr, NAPI_getGameHighScores, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getInlineGameHighScores", nullptr, NAPI_getInlineGameHighScores, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 聊天操作
        {"deleteChatReplyMarkup", nullptr, NAPI_deleteChatReplyMarkup, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendChatAction", nullptr, NAPI_sendChatAction, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendTextMessageDraft", nullptr, NAPI_sendTextMessageDraft, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"openChat", nullptr, NAPI_openChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"closeChat", nullptr, NAPI_closeChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"viewMessages", nullptr, NAPI_viewMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"openMessageContent", nullptr, NAPI_openMessageContent, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"clickAnimatedEmojiMessage", nullptr, NAPI_clickAnimatedEmojiMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getInternalLink", nullptr, NAPI_getInternalLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getInternalLinkType", nullptr, NAPI_getInternalLinkType, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getExternalLinkInfo", nullptr, NAPI_getExternalLinkInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getExternalLink", nullptr, NAPI_getExternalLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"readAllChatMentions", nullptr, NAPI_readAllChatMentions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"readAllChatReactions", nullptr, NAPI_readAllChatReactions, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 创建聊天
        {"createPrivateChat", nullptr, NAPI_createPrivateChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createBasicGroupChat", nullptr, NAPI_createBasicGroupChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createSupergroupChat", nullptr, NAPI_createSupergroupChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createSecretChat", nullptr, NAPI_createSecretChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createNewBasicGroupChat", nullptr, NAPI_createNewBasicGroupChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createNewSupergroupChat", nullptr, NAPI_createNewSupergroupChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createNewSecretChat", nullptr, NAPI_createNewSecretChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"upgradeBasicGroupChatToSupergroupChat", nullptr, NAPI_upgradeBasicGroupChatToSupergroupChat, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 聊天列表与文件夹 (部分)
        {"getChatListsToAddChat", nullptr, NAPI_getChatListsToAddChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addChatToList", nullptr, NAPI_addChatToList, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatFolder", nullptr, NAPI_getChatFolder, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createChatFolder", nullptr, NAPI_createChatFolder, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editChatFolder", nullptr, NAPI_editChatFolder, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteChatFolder", nullptr, NAPI_deleteChatFolder, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatFolderChatsToLeave", nullptr, NAPI_getChatFolderChatsToLeave, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatFolderChatCount", nullptr, NAPI_getChatFolderChatCount, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reorderChatFolders", nullptr, NAPI_reorderChatFolders, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleChatFolderTags", nullptr, NAPI_toggleChatFolderTags, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getRecommendedChatFolders", nullptr, NAPI_getRecommendedChatFolders, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatFolderDefaultIconName", nullptr, NAPI_getChatFolderDefaultIconName, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatsForChatFolderInviteLink", nullptr, NAPI_getChatsForChatFolderInviteLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createChatFolderInviteLink", nullptr, NAPI_createChatFolderInviteLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatFolderInviteLinks", nullptr, NAPI_getChatFolderInviteLinks, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editChatFolderInviteLink", nullptr, NAPI_editChatFolderInviteLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteChatFolderInviteLink", nullptr, NAPI_deleteChatFolderInviteLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"checkChatFolderInviteLink", nullptr, NAPI_checkChatFolderInviteLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addChatFolderByInviteLink", nullptr, NAPI_addChatFolderByInviteLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatFolderNewChats", nullptr, NAPI_getChatFolderNewChats, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"processChatFolderNewChats", nullptr, NAPI_processChatFolderNewChats, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getArchiveChatListSettings", nullptr, NAPI_getArchiveChatListSettings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setArchiveChatListSettings", nullptr, NAPI_setArchiveChatListSettings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatTitle", nullptr, NAPI_setChatTitle, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatPhoto", nullptr, NAPI_setChatPhoto, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatAccentColor", nullptr, NAPI_setChatAccentColor, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatProfileAccentColor", nullptr, NAPI_setChatProfileAccentColor, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatMessageAutoDeleteTime", nullptr, NAPI_setChatMessageAutoDeleteTime, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatEmojiStatus", nullptr, NAPI_setChatEmojiStatus, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatPermissions", nullptr, NAPI_setChatPermissions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatBackground", nullptr, NAPI_setChatBackground, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteChatBackground", nullptr, NAPI_deleteChatBackground, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getGiftChatThemes", nullptr, NAPI_getGiftChatThemes, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatTheme", nullptr, NAPI_setChatTheme, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatDraftMessage", nullptr, NAPI_setChatDraftMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatNotificationSettings", nullptr, NAPI_setChatNotificationSettings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleChatHasProtectedContent", nullptr, NAPI_toggleChatHasProtectedContent, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleChatViewAsTopics", nullptr, NAPI_toggleChatViewAsTopics, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleChatIsTranslatable", nullptr, NAPI_toggleChatIsTranslatable, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleChatIsMarkedAsUnread", nullptr, NAPI_toggleChatIsMarkedAsUnread, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleChatDefaultDisableNotification", nullptr, NAPI_toggleChatDefaultDisableNotification, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatAvailableReactions", nullptr, NAPI_setChatAvailableReactions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatClientData", nullptr, NAPI_setChatClientData, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatDescription", nullptr, NAPI_setChatDescription, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatDiscussionGroup", nullptr, NAPI_setChatDiscussionGroup, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatDirectMessagesGroup", nullptr, NAPI_setChatDirectMessagesGroup, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatLocation", nullptr, NAPI_setChatLocation, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatSlowModeDelay", nullptr, NAPI_setChatSlowModeDelay, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"pinChatMessage", nullptr, NAPI_pinChatMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"unpinChatMessage", nullptr, NAPI_unpinChatMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"unpinAllChatMessages", nullptr, NAPI_unpinAllChatMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"joinChat", nullptr, NAPI_joinChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"leaveChat", nullptr, NAPI_leaveChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addChatMember", nullptr, NAPI_addChatMember, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addChatMembers", nullptr, NAPI_addChatMembers, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatMemberStatus", nullptr, NAPI_setChatMemberStatus, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"banChatMember", nullptr, NAPI_banChatMember, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"canTransferOwnership", nullptr, NAPI_canTransferOwnership, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"transferChatOwnership", nullptr, NAPI_transferChatOwnership, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatOwnerAfterLeaving", nullptr, NAPI_getChatOwnerAfterLeaving, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatMember", nullptr, NAPI_getChatMember, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchChatMembers", nullptr, NAPI_searchChatMembers, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatAdministrators", nullptr, NAPI_getChatAdministrators, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"clearAllDraftMessages", nullptr, NAPI_clearAllDraftMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStakeDiceState", nullptr, NAPI_getStakeDiceState, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 通知设置
        {"getSavedNotificationSound", nullptr, NAPI_getSavedNotificationSound, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSavedNotificationSounds", nullptr, NAPI_getSavedNotificationSounds, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addSavedNotificationSound", nullptr, NAPI_addSavedNotificationSound, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeSavedNotificationSound", nullptr, NAPI_removeSavedNotificationSound, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatNotificationSettingsExceptions", nullptr, NAPI_getChatNotificationSettingsExceptions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getScopeNotificationSettings", nullptr, NAPI_getScopeNotificationSettings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setScopeNotificationSettings", nullptr, NAPI_setScopeNotificationSettings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setReactionNotificationSettings", nullptr, NAPI_setReactionNotificationSettings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"resetAllNotificationSettings", nullptr, NAPI_resetAllNotificationSettings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleChatIsPinned", nullptr, NAPI_toggleChatIsPinned, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setPinnedChats", nullptr, NAPI_setPinnedChats, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"readChatList", nullptr, NAPI_readChatList, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 天气
        {"getCurrentWeather", nullptr, NAPI_getCurrentWeather, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 故事 (部分)
        {"getStory", nullptr, NAPI_getStory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatsToPostStories", nullptr, NAPI_getChatsToPostStories, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"canPostStory", nullptr, NAPI_canPostStory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"postStory", nullptr, NAPI_postStory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"startLiveStory", nullptr, NAPI_startLiveStory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editStory", nullptr, NAPI_editStory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editStoryCover", nullptr, NAPI_editStoryCover, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setStoryPrivacySettings", nullptr, NAPI_setStoryPrivacySettings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleStoryIsPostedToChatPage", nullptr, NAPI_toggleStoryIsPostedToChatPage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteStory", nullptr, NAPI_deleteStory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStoryNotificationSettingsExceptions", nullptr, NAPI_getStoryNotificationSettingsExceptions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"loadActiveStories", nullptr, NAPI_loadActiveStories, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatActiveStoriesList", nullptr, NAPI_setChatActiveStoriesList, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatActiveStories", nullptr, NAPI_getChatActiveStories, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatPostedToChatPageStories", nullptr, NAPI_getChatPostedToChatPageStories, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatArchivedStories", nullptr, NAPI_getChatArchivedStories, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatPinnedStories", nullptr, NAPI_setChatPinnedStories, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"openStory", nullptr, NAPI_openStory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"closeStory", nullptr, NAPI_closeStory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStoryAvailableReactions", nullptr, NAPI_getStoryAvailableReactions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setStoryReaction", nullptr, NAPI_setStoryReaction, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStoryInteractions", nullptr, NAPI_getStoryInteractions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatStoryInteractions", nullptr, NAPI_getChatStoryInteractions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reportStory", nullptr, NAPI_reportStory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"activateStoryStealthMode", nullptr, NAPI_activateStoryStealthMode, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStoryPublicForwards", nullptr, NAPI_getStoryPublicForwards, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatStoryAlbums", nullptr, NAPI_getChatStoryAlbums, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStoryAlbumStories", nullptr, NAPI_getStoryAlbumStories, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createStoryAlbum", nullptr, NAPI_createStoryAlbum, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reorderStoryAlbums", nullptr, NAPI_reorderStoryAlbums, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteStoryAlbum", nullptr, NAPI_deleteStoryAlbum, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setStoryAlbumName", nullptr, NAPI_setStoryAlbumName, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addStoryAlbumStories", nullptr, NAPI_addStoryAlbumStories, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeStoryAlbumStories", nullptr, NAPI_removeStoryAlbumStories, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reorderStoryAlbumStories", nullptr, NAPI_reorderStoryAlbumStories, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 提升与增强
        {"getChatBoostLevelFeatures", nullptr, NAPI_getChatBoostLevelFeatures, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatBoostFeatures", nullptr, NAPI_getChatBoostFeatures, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getAvailableChatBoostSlots", nullptr, NAPI_getAvailableChatBoostSlots, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatBoostStatus", nullptr, NAPI_getChatBoostStatus, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"boostChat", nullptr, NAPI_boostChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatBoostLink", nullptr, NAPI_getChatBoostLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatBoostLinkInfo", nullptr, NAPI_getChatBoostLinkInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatBoosts", nullptr, NAPI_getChatBoosts, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getUserChatBoosts", nullptr, NAPI_getUserChatBoosts, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 附件菜单机器人
        {"getAttachmentMenuBot", nullptr, NAPI_getAttachmentMenuBot, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleBotIsAddedToAttachmentMenu", nullptr, NAPI_toggleBotIsAddedToAttachmentMenu, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 表情状态
        {"getThemedEmojiStatuses", nullptr, NAPI_getThemedEmojiStatuses, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getRecentEmojiStatuses", nullptr, NAPI_getRecentEmojiStatuses, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getUpgradedGiftEmojiStatuses", nullptr, NAPI_getUpgradedGiftEmojiStatuses, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getDefaultEmojiStatuses", nullptr, NAPI_getDefaultEmojiStatuses, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"clearRecentEmojiStatuses", nullptr, NAPI_clearRecentEmojiStatuses, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getThemedChatEmojiStatuses", nullptr, NAPI_getThemedChatEmojiStatuses, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getDefaultChatEmojiStatuses", nullptr, NAPI_getDefaultChatEmojiStatuses, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getDisallowedChatEmojiStatuses", nullptr, NAPI_getDisallowedChatEmojiStatuses, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 文件操作
        {"getFile", nullptr, NAPI_getFile, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getRemoteFile", nullptr, NAPI_getRemoteFile, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"readFilePart", nullptr, NAPI_readFilePart, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getFileDownloadedPrefixSize", nullptr, NAPI_getFileDownloadedPrefixSize, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"downloadFile", nullptr, NAPI_downloadFile, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"cancelDownloadFile", nullptr, NAPI_cancelDownloadFile, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"preliminaryUploadFile", nullptr, NAPI_preliminaryUploadFile, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"cancelPreliminaryUploadFile", nullptr, NAPI_cancelPreliminaryUploadFile, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"writeGeneratedFilePart", nullptr, NAPI_writeGeneratedFilePart, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setFileGenerationProgress", nullptr, NAPI_setFileGenerationProgress, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"finishFileGeneration", nullptr, NAPI_finishFileGeneration, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSuggestedFileName", nullptr, NAPI_getSuggestedFileName, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteFile", nullptr, NAPI_deleteFile, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addFileToDownloads", nullptr, NAPI_addFileToDownloads, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleDownloadIsPaused", nullptr, NAPI_toggleDownloadIsPaused, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleAllDownloadsArePaused", nullptr, NAPI_toggleAllDownloadsArePaused, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeFileFromDownloads", nullptr, NAPI_removeFileFromDownloads, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeAllFilesFromDownloads", nullptr, NAPI_removeAllFilesFromDownloads, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchFileDownloads", nullptr, NAPI_searchFileDownloads, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getAutoDownloadSettingsPresets", nullptr, NAPI_getAutoDownloadSettingsPresets, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setAutoDownloadSettings", nullptr, NAPI_setAutoDownloadSettings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"uploadStickerFile", nullptr, NAPI_uploadStickerFile, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMapThumbnailFile", nullptr, NAPI_getMapThumbnailFile, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getApplicationDownloadLink", nullptr, NAPI_getApplicationDownloadLink, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 应用验证
        {"setApplicationVerificationToken", nullptr, NAPI_setApplicationVerificationToken, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMessageFileType", nullptr, NAPI_getMessageFileType, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMessageImportConfirmationText", nullptr, NAPI_getMessageImportConfirmationText, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"importMessages", nullptr, NAPI_importMessages, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 邀请链接
        {"replacePrimaryChatInviteLink", nullptr, NAPI_replacePrimaryChatInviteLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createChatInviteLink", nullptr, NAPI_createChatInviteLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createChatSubscriptionInviteLink", nullptr, NAPI_createChatSubscriptionInviteLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editChatInviteLink", nullptr, NAPI_editChatInviteLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editChatSubscriptionInviteLink", nullptr, NAPI_editChatSubscriptionInviteLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatInviteLink", nullptr, NAPI_getChatInviteLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatInviteLinkCounts", nullptr, NAPI_getChatInviteLinkCounts, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatInviteLinks", nullptr, NAPI_getChatInviteLinks, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatInviteLinkMembers", nullptr, NAPI_getChatInviteLinkMembers, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"revokeChatInviteLink", nullptr, NAPI_revokeChatInviteLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteRevokedChatInviteLink", nullptr, NAPI_deleteRevokedChatInviteLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteAllRevokedChatInviteLinks", nullptr, NAPI_deleteAllRevokedChatInviteLinks, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"checkChatInviteLink", nullptr, NAPI_checkChatInviteLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"joinChatByInviteLink", nullptr, NAPI_joinChatByInviteLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatJoinRequests", nullptr, NAPI_getChatJoinRequests, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"processChatJoinRequest", nullptr, NAPI_processChatJoinRequest, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"processChatJoinRequests", nullptr, NAPI_processChatJoinRequests, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"approveSuggestedPost", nullptr, NAPI_approveSuggestedPost, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"declineSuggestedPost", nullptr, NAPI_declineSuggestedPost, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addOffer", nullptr, NAPI_addOffer, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 通话与视频聊天 (部分)
        {"createCall", nullptr, NAPI_createCall, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"acceptCall", nullptr, NAPI_acceptCall, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendCallSignalingData", nullptr, NAPI_sendCallSignalingData, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"discardCall", nullptr, NAPI_discardCall, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendCallRating", nullptr, NAPI_sendCallRating, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendCallDebugInformation", nullptr, NAPI_sendCallDebugInformation, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendCallLog", nullptr, NAPI_sendCallLog, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getVideoChatAvailableParticipants", nullptr, NAPI_getVideoChatAvailableParticipants, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setVideoChatDefaultParticipant", nullptr, NAPI_setVideoChatDefaultParticipant, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createVideoChat", nullptr, NAPI_createVideoChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createGroupCall", nullptr, NAPI_createGroupCall, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getVideoChatRtmpUrl", nullptr, NAPI_getVideoChatRtmpUrl, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"replaceVideoChatRtmpUrl", nullptr, NAPI_replaceVideoChatRtmpUrl, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getLiveStoryRtmpUrl", nullptr, NAPI_getLiveStoryRtmpUrl, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"replaceLiveStoryRtmpUrl", nullptr, NAPI_replaceLiveStoryRtmpUrl, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getGroupCall", nullptr, NAPI_getGroupCall, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"startScheduledVideoChat", nullptr, NAPI_startScheduledVideoChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleVideoChatEnabledStartNotification", nullptr, NAPI_toggleVideoChatEnabledStartNotification, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"joinGroupCall", nullptr, NAPI_joinGroupCall, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"joinVideoChat", nullptr, NAPI_joinVideoChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"joinLiveStory", nullptr, NAPI_joinLiveStory, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"startGroupCallScreenSharing", nullptr, NAPI_startGroupCallScreenSharing, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleGroupCallScreenSharingIsPaused", nullptr, NAPI_toggleGroupCallScreenSharingIsPaused, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"endGroupCallScreenSharing", nullptr, NAPI_endGroupCallScreenSharing, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setVideoChatTitle", nullptr, NAPI_setVideoChatTitle, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleVideoChatMuteNewParticipants", nullptr, NAPI_toggleVideoChatMuteNewParticipants, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleGroupCallAreMessagesAllowed", nullptr, NAPI_toggleGroupCallAreMessagesAllowed, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getLiveStoryStreamer", nullptr, NAPI_getLiveStoryStreamer, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getLiveStoryAvailableMessageSenders", nullptr, NAPI_getLiveStoryAvailableMessageSenders, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setLiveStoryMessageSender", nullptr, NAPI_setLiveStoryMessageSender, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendGroupCallMessage", nullptr, NAPI_sendGroupCallMessage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addPendingLiveStoryReaction", nullptr, NAPI_addPendingLiveStoryReaction, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"commitPendingLiveStoryReactions", nullptr, NAPI_commitPendingLiveStoryReactions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removePendingLiveStoryReactions", nullptr, NAPI_removePendingLiveStoryReactions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteGroupCallMessages", nullptr, NAPI_deleteGroupCallMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteGroupCallMessagesBySender", nullptr, NAPI_deleteGroupCallMessagesBySender, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getLiveStoryTopDonors", nullptr, NAPI_getLiveStoryTopDonors, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"inviteGroupCallParticipant", nullptr, NAPI_inviteGroupCallParticipant, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"declineGroupCallInvitation", nullptr, NAPI_declineGroupCallInvitation, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"banGroupCallParticipants", nullptr, NAPI_banGroupCallParticipants, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"inviteVideoChatParticipants", nullptr, NAPI_inviteVideoChatParticipants, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getVideoChatInviteLink", nullptr, NAPI_getVideoChatInviteLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"revokeGroupCallInviteLink", nullptr, NAPI_revokeGroupCallInviteLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"startGroupCallRecording", nullptr, NAPI_startGroupCallRecording, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"endGroupCallRecording", nullptr, NAPI_endGroupCallRecording, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleGroupCallIsMyVideoPaused", nullptr, NAPI_toggleGroupCallIsMyVideoPaused, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleGroupCallIsMyVideoEnabled", nullptr, NAPI_toggleGroupCallIsMyVideoEnabled, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setGroupCallPaidMessageStarCount", nullptr, NAPI_setGroupCallPaidMessageStarCount, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setGroupCallParticipantIsSpeaking", nullptr, NAPI_setGroupCallParticipantIsSpeaking, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleGroupCallParticipantIsMuted", nullptr, NAPI_toggleGroupCallParticipantIsMuted, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setGroupCallParticipantVolumeLevel", nullptr, NAPI_setGroupCallParticipantVolumeLevel, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleGroupCallParticipantIsHandRaised", nullptr, NAPI_toggleGroupCallParticipantIsHandRaised, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getGroupCallParticipants", nullptr, NAPI_getGroupCallParticipants, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"loadGroupCallParticipants", nullptr, NAPI_loadGroupCallParticipants, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"leaveGroupCall", nullptr, NAPI_leaveGroupCall, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"endGroupCall", nullptr, NAPI_endGroupCall, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getGroupCallStreams", nullptr, NAPI_getGroupCallStreams, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getGroupCallStreamSegment", nullptr, NAPI_getGroupCallStreamSegment, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"encryptGroupCallData", nullptr, NAPI_encryptGroupCallData, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"decryptGroupCallData", nullptr, NAPI_decryptGroupCallData, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 封禁与联系人
        {"setMessageSenderBlockList", nullptr, NAPI_setMessageSenderBlockList, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"blockMessageSenderFromReplies", nullptr, NAPI_blockMessageSenderFromReplies, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getBlockedMessageSenders", nullptr, NAPI_getBlockedMessageSenders, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addContact", nullptr, NAPI_addContact, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"importContacts", nullptr, NAPI_importContacts, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getContacts", nullptr, NAPI_getContacts, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchContacts", nullptr, NAPI_searchContacts, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeContacts", nullptr, NAPI_removeContacts, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getImportedContactCount", nullptr, NAPI_getImportedContactCount, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"changeImportedContacts", nullptr, NAPI_changeImportedContacts, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"clearImportedContacts", nullptr, NAPI_clearImportedContacts, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setCloseFriends", nullptr, NAPI_setCloseFriends, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getCloseFriends", nullptr, NAPI_getCloseFriends, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 贴纸与表情 (部分)
        {"getStickerOutline", nullptr, NAPI_getStickerOutline, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStickerOutlineSvgPath", nullptr, NAPI_getStickerOutlineSvgPath, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStickers", nullptr, NAPI_getStickers, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getAllStickerEmojis", nullptr, NAPI_getAllStickerEmojis, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchStickers", nullptr, NAPI_searchStickers, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getGreetingStickers", nullptr, NAPI_getGreetingStickers, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPremiumStickers", nullptr, NAPI_getPremiumStickers, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getInstalledStickerSets", nullptr, NAPI_getInstalledStickerSets, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getArchivedStickerSets", nullptr, NAPI_getArchivedStickerSets, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getTrendingStickerSets", nullptr, NAPI_getTrendingStickerSets, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getAttachedStickerSets", nullptr, NAPI_getAttachedStickerSets, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStickerSet", nullptr, NAPI_getStickerSet, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStickerSetName", nullptr, NAPI_getStickerSetName, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchStickerSet", nullptr, NAPI_searchStickerSet, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchInstalledStickerSets", nullptr, NAPI_searchInstalledStickerSets, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchStickerSets", nullptr, NAPI_searchStickerSets, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"changeStickerSet", nullptr, NAPI_changeStickerSet, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"viewTrendingStickerSets", nullptr, NAPI_viewTrendingStickerSets, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reorderInstalledStickerSets", nullptr, NAPI_reorderInstalledStickerSets, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getRecentStickers", nullptr, NAPI_getRecentStickers, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addRecentSticker", nullptr, NAPI_addRecentSticker, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeRecentSticker", nullptr, NAPI_removeRecentSticker, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"clearRecentStickers", nullptr, NAPI_clearRecentStickers, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getFavoriteStickers", nullptr, NAPI_getFavoriteStickers, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addFavoriteSticker", nullptr, NAPI_addFavoriteSticker, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeFavoriteSticker", nullptr, NAPI_removeFavoriteSticker, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStickerEmojis", nullptr, NAPI_getStickerEmojis, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchEmojis", nullptr, NAPI_searchEmojis, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getKeywordEmojis", nullptr, NAPI_getKeywordEmojis, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getEmojiCategories", nullptr, NAPI_getEmojiCategories, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getAnimatedEmoji", nullptr, NAPI_getAnimatedEmoji, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getEmojiSuggestionsUrl", nullptr, NAPI_getEmojiSuggestionsUrl, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getCustomEmojiStickers", nullptr, NAPI_getCustomEmojiStickers, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getDefaultChatPhotoCustomEmojiStickers", nullptr, NAPI_getDefaultChatPhotoCustomEmojiStickers, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getDefaultProfilePhotoCustomEmojiStickers", nullptr, NAPI_getDefaultProfilePhotoCustomEmojiStickers, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getDefaultBackgroundCustomEmojiStickers", nullptr, NAPI_getDefaultBackgroundCustomEmojiStickers, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSavedAnimations", nullptr, NAPI_getSavedAnimations, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addSavedAnimation", nullptr, NAPI_addSavedAnimation, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeSavedAnimation", nullptr, NAPI_removeSavedAnimation, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getRecentInlineBots", nullptr, NAPI_getRecentInlineBots, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getOwnedBots", nullptr, NAPI_getOwnedBots, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchHashtags", nullptr, NAPI_searchHashtags, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeRecentHashtag", nullptr, NAPI_removeRecentHashtag, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getLinkPreview", nullptr, NAPI_getLinkPreview, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getWebPageInstantView", nullptr, NAPI_getWebPageInstantView, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 机器人命令与菜单 (部分)
        {"setCommands", nullptr, NAPI_setCommands, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteCommands", nullptr, NAPI_deleteCommands, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getCommands", nullptr, NAPI_getCommands, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setMenuButton", nullptr, NAPI_setMenuButton, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMenuButton", nullptr, NAPI_getMenuButton, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setDefaultGroupAdministratorRights", nullptr, NAPI_setDefaultGroupAdministratorRights, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setDefaultChannelAdministratorRights", nullptr, NAPI_setDefaultChannelAdministratorRights, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"canBotSendMessages", nullptr, NAPI_canBotSendMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"allowBotToSendMessages", nullptr, NAPI_allowBotToSendMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendWebAppCustomRequest", nullptr, NAPI_sendWebAppCustomRequest, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getBotMediaPreviews", nullptr, NAPI_getBotMediaPreviews, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getBotMediaPreviewInfo", nullptr, NAPI_getBotMediaPreviewInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addBotMediaPreview", nullptr, NAPI_addBotMediaPreview, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editBotMediaPreview", nullptr, NAPI_editBotMediaPreview, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reorderBotMediaPreviews", nullptr, NAPI_reorderBotMediaPreviews, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteBotMediaPreviews", nullptr, NAPI_deleteBotMediaPreviews, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setBotName", nullptr, NAPI_setBotName, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getBotName", nullptr, NAPI_getBotName, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setBotProfilePhoto", nullptr, NAPI_setBotProfilePhoto, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleBotUsernameIsActive", nullptr, NAPI_toggleBotUsernameIsActive, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reorderBotActiveUsernames", nullptr, NAPI_reorderBotActiveUsernames, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setBotInfoDescription", nullptr, NAPI_setBotInfoDescription, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getBotInfoDescription", nullptr, NAPI_getBotInfoDescription, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setBotInfoShortDescription", nullptr, NAPI_setBotInfoShortDescription, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getBotInfoShortDescription", nullptr, NAPI_getBotInfoShortDescription, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setMessageSenderBotVerification", nullptr, NAPI_setMessageSenderBotVerification, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeMessageSenderBotVerification", nullptr, NAPI_removeMessageSenderBotVerification, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 会话与网站
        {"getActiveSessions", nullptr, NAPI_getActiveSessions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"terminateSession", nullptr, NAPI_terminateSession, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"terminateAllOtherSessions", nullptr, NAPI_terminateAllOtherSessions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"confirmSession", nullptr, NAPI_confirmSession, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleSessionCanAcceptCalls", nullptr, NAPI_toggleSessionCanAcceptCalls, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleSessionCanAcceptSecretChats", nullptr, NAPI_toggleSessionCanAcceptSecretChats, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setInactiveSessionTtl", nullptr, NAPI_setInactiveSessionTtl, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getConnectedWebsites", nullptr, NAPI_getConnectedWebsites, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"disconnectWebsite", nullptr, NAPI_disconnectWebsite, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"disconnectAllWebsites", nullptr, NAPI_disconnectAllWebsites, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 超级群组管理 (部分)
        {"setSupergroupUsername", nullptr, NAPI_setSupergroupUsername, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleSupergroupUsernameIsActive", nullptr, NAPI_toggleSupergroupUsernameIsActive, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"disableAllSupergroupUsernames", nullptr, NAPI_disableAllSupergroupUsernames, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reorderSupergroupActiveUsernames", nullptr, NAPI_reorderSupergroupActiveUsernames, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setSupergroupStickerSet", nullptr, NAPI_setSupergroupStickerSet, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setSupergroupCustomEmojiStickerSet", nullptr, NAPI_setSupergroupCustomEmojiStickerSet, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setSupergroupUnrestrictBoostCount", nullptr, NAPI_setSupergroupUnrestrictBoostCount, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setSupergroupMainProfileTab", nullptr, NAPI_setSupergroupMainProfileTab, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleSupergroupSignMessages", nullptr, NAPI_toggleSupergroupSignMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleSupergroupJoinToSendMessages", nullptr, NAPI_toggleSupergroupJoinToSendMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleSupergroupJoinByRequest", nullptr, NAPI_toggleSupergroupJoinByRequest, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleSupergroupIsAllHistoryAvailable", nullptr, NAPI_toggleSupergroupIsAllHistoryAvailable, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleSupergroupCanHaveSponsoredMessages", nullptr, NAPI_toggleSupergroupCanHaveSponsoredMessages, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleSupergroupHasAutomaticTranslation", nullptr, NAPI_toggleSupergroupHasAutomaticTranslation, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleSupergroupHasHiddenMembers", nullptr, NAPI_toggleSupergroupHasHiddenMembers, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleSupergroupHasAggressiveAntiSpamEnabled", nullptr, NAPI_toggleSupergroupHasAggressiveAntiSpamEnabled, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleSupergroupIsForum", nullptr, NAPI_toggleSupergroupIsForum, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleSupergroupIsBroadcastGroup", nullptr, NAPI_toggleSupergroupIsBroadcastGroup, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reportSupergroupSpam", nullptr, NAPI_reportSupergroupSpam, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reportSupergroupAntiSpamFalsePositive", nullptr, NAPI_reportSupergroupAntiSpamFalsePositive, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSupergroupMembers", nullptr, NAPI_getSupergroupMembers, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"closeSecretChat", nullptr, NAPI_closeSecretChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatEventLog", nullptr, NAPI_getChatEventLog, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 时区
        {"getTimeZones", nullptr, NAPI_getTimeZones, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 支付与星币 (部分)
        {"getPaymentForm", nullptr, NAPI_getPaymentForm, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"validateOrderInfo", nullptr, NAPI_validateOrderInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendPaymentForm", nullptr, NAPI_sendPaymentForm, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPaymentReceipt", nullptr, NAPI_getPaymentReceipt, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSavedOrderInfo", nullptr, NAPI_getSavedOrderInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteSavedOrderInfo", nullptr, NAPI_deleteSavedOrderInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteSavedCredentials", nullptr, NAPI_deleteSavedCredentials, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setGiftSettings", nullptr, NAPI_setGiftSettings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getAvailableGifts", nullptr, NAPI_getAvailableGifts, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"canSendGift", nullptr, NAPI_canSendGift, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendGift", nullptr, NAPI_sendGift, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getGiftAuctionState", nullptr, NAPI_getGiftAuctionState, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getGiftAuctionAcquiredGifts", nullptr, NAPI_getGiftAuctionAcquiredGifts, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"openGiftAuction", nullptr, NAPI_openGiftAuction, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"closeGiftAuction", nullptr, NAPI_closeGiftAuction, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"placeGiftAuctionBid", nullptr, NAPI_placeGiftAuctionBid, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"increaseGiftAuctionBid", nullptr, NAPI_increaseGiftAuctionBid, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sellGift", nullptr, NAPI_sellGift, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleGiftIsSaved", nullptr, NAPI_toggleGiftIsSaved, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setPinnedGifts", nullptr, NAPI_setPinnedGifts, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"toggleChatGiftNotifications", nullptr, NAPI_toggleChatGiftNotifications, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getGiftUpgradePreview", nullptr, NAPI_getGiftUpgradePreview, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getUpgradedGiftVariants", nullptr, NAPI_getUpgradedGiftVariants, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"upgradeGift", nullptr, NAPI_upgradeGift, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"buyGiftUpgrade", nullptr, NAPI_buyGiftUpgrade, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"craftGift", nullptr, NAPI_craftGift, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"transferGift", nullptr, NAPI_transferGift, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"dropGiftOriginalDetails", nullptr, NAPI_dropGiftOriginalDetails, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendResoldGift", nullptr, NAPI_sendResoldGift, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendGiftPurchaseOffer", nullptr, NAPI_sendGiftPurchaseOffer, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"processGiftPurchaseOffer", nullptr, NAPI_processGiftPurchaseOffer, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getReceivedGifts", nullptr, NAPI_getReceivedGifts, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getReceivedGift", nullptr, NAPI_getReceivedGift, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getGiftsForCrafting", nullptr, NAPI_getGiftsForCrafting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getUpgradedGift", nullptr, NAPI_getUpgradedGift, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getUpgradedGiftValueInfo", nullptr, NAPI_getUpgradedGiftValueInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getUpgradedGiftWithdrawalUrl", nullptr, NAPI_getUpgradedGiftWithdrawalUrl, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getUpgradedGiftsPromotionalAnimation", nullptr, NAPI_getUpgradedGiftsPromotionalAnimation, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setGiftResalePrice", nullptr, NAPI_setGiftResalePrice, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchGiftsForResale", nullptr, NAPI_searchGiftsForResale, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getGiftCollections", nullptr, NAPI_getGiftCollections, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createGiftCollection", nullptr, NAPI_createGiftCollection, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reorderGiftCollections", nullptr, NAPI_reorderGiftCollections, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteGiftCollection", nullptr, NAPI_deleteGiftCollection, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setGiftCollectionName", nullptr, NAPI_setGiftCollectionName, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addGiftCollectionGifts", nullptr, NAPI_addGiftCollectionGifts, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeGiftCollectionGifts", nullptr, NAPI_removeGiftCollectionGifts, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reorderGiftCollectionGifts", nullptr, NAPI_reorderGiftCollectionGifts, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createInvoiceLink", nullptr, NAPI_createInvoiceLink, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"refundStarPayment", nullptr, NAPI_refundStarPayment, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSupportUser", nullptr, NAPI_getSupportUser, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 背景
        {"getBackgroundUrl", nullptr, NAPI_getBackgroundUrl, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchBackground", nullptr, NAPI_searchBackground, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setDefaultBackground", nullptr, NAPI_setDefaultBackground, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteDefaultBackground", nullptr, NAPI_deleteDefaultBackground, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getInstalledBackgrounds", nullptr, NAPI_getInstalledBackgrounds, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeInstalledBackground", nullptr, NAPI_removeInstalledBackground, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"resetInstalledBackgrounds", nullptr, NAPI_resetInstalledBackgrounds, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 本地化
        {"getLocalizationTargetInfo", nullptr, NAPI_getLocalizationTargetInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getLanguagePackInfo", nullptr, NAPI_getLanguagePackInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getLanguagePackStrings", nullptr, NAPI_getLanguagePackStrings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"synchronizeLanguagePack", nullptr, NAPI_synchronizeLanguagePack, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addCustomServerLanguagePack", nullptr, NAPI_addCustomServerLanguagePack, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setCustomLanguagePack", nullptr, NAPI_setCustomLanguagePack, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editCustomLanguagePackInfo", nullptr, NAPI_editCustomLanguagePackInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setCustomLanguagePackString", nullptr, NAPI_setCustomLanguagePackString, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteLanguagePack", nullptr, NAPI_deleteLanguagePack, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 推送通知
        {"registerDevice", nullptr, NAPI_registerDevice, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"processPushNotification", nullptr, NAPI_processPushNotification, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPushReceiverId", nullptr, NAPI_getPushReceiverId, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getRecentlyVisitedTMeUrls", nullptr, NAPI_getRecentlyVisitedTMeUrls, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 隐私设置
        {"setUserPrivacySettingRules", nullptr, NAPI_setUserPrivacySettingRules, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getUserPrivacySettingRules", nullptr, NAPI_getUserPrivacySettingRules, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setReadDatePrivacySettings", nullptr, NAPI_setReadDatePrivacySettings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getReadDatePrivacySettings", nullptr, NAPI_getReadDatePrivacySettings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setNewChatPrivacySettings", nullptr, NAPI_setNewChatPrivacySettings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getNewChatPrivacySettings", nullptr, NAPI_getNewChatPrivacySettings, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 付费消息与收入 (部分)
        {"getPaidMessageRevenue", nullptr, NAPI_getPaidMessageRevenue, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"allowUnpaidMessagesFromUser", nullptr, NAPI_allowUnpaidMessagesFromUser, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setChatPaidMessageStarCount", nullptr, NAPI_setChatPaidMessageStarCount, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"canSendMessageToUser", nullptr, NAPI_canSendMessageToUser, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getOption", nullptr, NAPI_getOption, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setOption", nullptr, NAPI_setOption, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setAccountTtl", nullptr, NAPI_setAccountTtl, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getAccountTtl", nullptr, NAPI_getAccountTtl, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteAccount", nullptr, NAPI_deleteAccount, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setDefaultMessageAutoDeleteTime", nullptr, NAPI_setDefaultMessageAutoDeleteTime, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getDefaultMessageAutoDeleteTime", nullptr, NAPI_getDefaultMessageAutoDeleteTime, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeChatActionBar", nullptr, NAPI_removeChatActionBar, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reportChat", nullptr, NAPI_reportChat, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reportChatPhoto", nullptr, NAPI_reportChatPhoto, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reportMessageReactions", nullptr, NAPI_reportMessageReactions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatRevenueStatistics", nullptr, NAPI_getChatRevenueStatistics, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatRevenueWithdrawalUrl", nullptr, NAPI_getChatRevenueWithdrawalUrl, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatRevenueTransactions", nullptr, NAPI_getChatRevenueTransactions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getTonTransactions", nullptr, NAPI_getTonTransactions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStarRevenueStatistics", nullptr, NAPI_getStarRevenueStatistics, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStarWithdrawalUrl", nullptr, NAPI_getStarWithdrawalUrl, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStarAdAccountUrl", nullptr, NAPI_getStarAdAccountUrl, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getTonRevenueStatistics", nullptr, NAPI_getTonRevenueStatistics, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getTonWithdrawalUrl", nullptr, NAPI_getTonWithdrawalUrl, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChatStatistics", nullptr, NAPI_getChatStatistics, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMessageStatistics", nullptr, NAPI_getMessageStatistics, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getMessagePublicForwards", nullptr, NAPI_getMessagePublicForwards, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStoryStatistics", nullptr, NAPI_getStoryStatistics, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStatisticalGraph", nullptr, NAPI_getStatisticalGraph, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStorageStatistics", nullptr, NAPI_getStorageStatistics, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStorageStatisticsFast", nullptr, NAPI_getStorageStatisticsFast, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getDatabaseStatistics", nullptr, NAPI_getDatabaseStatistics, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"optimizeStorage", nullptr, NAPI_optimizeStorage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setNetworkType", nullptr, NAPI_setNetworkType, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getNetworkStatistics", nullptr, NAPI_getNetworkStatistics, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addNetworkStatistics", nullptr, NAPI_addNetworkStatistics, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"resetNetworkStatistics", nullptr, NAPI_resetNetworkStatistics, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getAutosaveSettings", nullptr, NAPI_getAutosaveSettings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setAutosaveSettings", nullptr, NAPI_setAutosaveSettings, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"clearAutosaveSettingsExceptions", nullptr, NAPI_clearAutosaveSettingsExceptions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getBankCardInfo", nullptr, NAPI_getBankCardInfo, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 证件信息
        {"getPassportElement", nullptr, NAPI_getPassportElement, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getAllPassportElements", nullptr, NAPI_getAllPassportElements, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setPassportElement", nullptr, NAPI_setPassportElement, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deletePassportElement", nullptr, NAPI_deletePassportElement, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setPassportElementErrors", nullptr, NAPI_setPassportElementErrors, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPreferredCountryLanguage", nullptr, NAPI_getPreferredCountryLanguage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendEmailAddressVerificationCode", nullptr, NAPI_sendEmailAddressVerificationCode, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"resendEmailAddressVerificationCode", nullptr, NAPI_resendEmailAddressVerificationCode, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"checkEmailAddressVerificationCode", nullptr, NAPI_checkEmailAddressVerificationCode, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPassportAuthorizationForm", nullptr, NAPI_getPassportAuthorizationForm, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPassportAuthorizationFormAvailableElements", nullptr, NAPI_getPassportAuthorizationFormAvailableElements, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendPassportAuthorizationForm", nullptr, NAPI_sendPassportAuthorizationForm, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 机器人更新
        {"setBotUpdatesStatus", nullptr, NAPI_setBotUpdatesStatus, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 贴纸集管理 (部分)
        {"createNewStickerSet", nullptr, NAPI_createNewStickerSet, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addStickerToSet", nullptr, NAPI_addStickerToSet, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"replaceStickerInSet", nullptr, NAPI_replaceStickerInSet, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setStickerSetThumbnail", nullptr, NAPI_setStickerSetThumbnail, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setCustomEmojiStickerSetThumbnail", nullptr, NAPI_setCustomEmojiStickerSetThumbnail, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setStickerSetTitle", nullptr, NAPI_setStickerSetTitle, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deleteStickerSet", nullptr, NAPI_deleteStickerSet, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setStickerPositionInSet", nullptr, NAPI_setStickerPositionInSet, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeStickerFromSet", nullptr, NAPI_removeStickerFromSet, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setStickerEmojis", nullptr, NAPI_setStickerEmojis, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setStickerKeywords", nullptr, NAPI_setStickerKeywords, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setStickerMaskPosition", nullptr, NAPI_setStickerMaskPosition, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getOwnedStickerSets", nullptr, NAPI_getOwnedStickerSets, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPremiumLimit", nullptr, NAPI_getPremiumLimit, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPremiumFeatures", nullptr, NAPI_getPremiumFeatures, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPremiumStickerExamples", nullptr, NAPI_getPremiumStickerExamples, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPremiumInfoSticker", nullptr, NAPI_getPremiumInfoSticker, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"viewPremiumFeature", nullptr, NAPI_viewPremiumFeature, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"clickPremiumSubscriptionButton", nullptr, NAPI_clickPremiumSubscriptionButton, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPremiumState", nullptr, NAPI_getPremiumState, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPremiumGiftPaymentOptions", nullptr, NAPI_getPremiumGiftPaymentOptions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPremiumGiveawayPaymentOptions", nullptr, NAPI_getPremiumGiveawayPaymentOptions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"checkPremiumGiftCode", nullptr, NAPI_checkPremiumGiftCode, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"applyPremiumGiftCode", nullptr, NAPI_applyPremiumGiftCode, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"giftPremiumWithStars", nullptr, NAPI_giftPremiumWithStars, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"launchPrepaidGiveaway", nullptr, NAPI_launchPrepaidGiveaway, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getGiveawayInfo", nullptr, NAPI_getGiveawayInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStarPaymentOptions", nullptr, NAPI_getStarPaymentOptions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStarGiftPaymentOptions", nullptr, NAPI_getStarGiftPaymentOptions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStarGiveawayPaymentOptions", nullptr, NAPI_getStarGiveawayPaymentOptions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStarTransactions", nullptr, NAPI_getStarTransactions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStarSubscriptions", nullptr, NAPI_getStarSubscriptions, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"canPurchaseFromStore", nullptr, NAPI_canPurchaseFromStore, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"assignStoreTransaction", nullptr, NAPI_assignStoreTransaction, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editStarSubscription", nullptr, NAPI_editStarSubscription, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editUserStarSubscription", nullptr, NAPI_editUserStarSubscription, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"reuseStarSubscription", nullptr, NAPI_reuseStarSubscription, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 联盟计划
        {"setChatAffiliateProgram", nullptr, NAPI_setChatAffiliateProgram, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchChatAffiliateProgram", nullptr, NAPI_searchChatAffiliateProgram, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchAffiliatePrograms", nullptr, NAPI_searchAffiliatePrograms, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"connectAffiliateProgram", nullptr, NAPI_connectAffiliateProgram, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"disconnectAffiliateProgram", nullptr, NAPI_disconnectAffiliateProgram, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getConnectedAffiliateProgram", nullptr, NAPI_getConnectedAffiliateProgram, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getConnectedAffiliatePrograms", nullptr, NAPI_getConnectedAffiliatePrograms, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getBusinessFeatures", nullptr, NAPI_getBusinessFeatures, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 服务条款
        {"acceptTermsOfService", nullptr, NAPI_acceptTermsOfService, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"searchStringsByPrefix", nullptr, NAPI_searchStringsByPrefix, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendCustomRequest", nullptr, NAPI_sendCustomRequest, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"answerCustomQuery", nullptr, NAPI_answerCustomQuery, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setAlarm", nullptr, NAPI_setAlarm, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getCountries", nullptr, NAPI_getCountries, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getCountryCode", nullptr, NAPI_getCountryCode, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPhoneNumberInfo", nullptr, NAPI_getPhoneNumberInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPhoneNumberInfoSync", nullptr, NAPI_getPhoneNumberInfoSync, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getCollectibleItemInfo", nullptr, NAPI_getCollectibleItemInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getDeepLinkInfo", nullptr, NAPI_getDeepLinkInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getApplicationConfig", nullptr, NAPI_getApplicationConfig, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"saveApplicationLogEvent", nullptr, NAPI_saveApplicationLogEvent, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 代理
        {"addProxy", nullptr, NAPI_addProxy, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"editProxy", nullptr, NAPI_editProxy, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"enableProxy", nullptr, NAPI_enableProxy, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"disableProxy", nullptr, NAPI_disableProxy, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"removeProxy", nullptr, NAPI_removeProxy, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getProxies", nullptr, NAPI_getProxies, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"pingProxy", nullptr, NAPI_pingProxy, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 日志
        {"setLogStream", nullptr, NAPI_setLogStream, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getLogStream", nullptr, NAPI_getLogStream, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setLogVerbosityLevel", nullptr, NAPI_setLogVerbosityLevel, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getLogVerbosityLevel", nullptr, NAPI_getLogVerbosityLevel, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getLogTags", nullptr, NAPI_getLogTags, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setLogTagVerbosityLevel", nullptr, NAPI_setLogTagVerbosityLevel, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getLogTagVerbosityLevel", nullptr, NAPI_getLogTagVerbosityLevel, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addLogMessage", nullptr, NAPI_addLogMessage, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 支持
        {"getUserSupportInfo", nullptr, NAPI_getUserSupportInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setUserSupportInfo", nullptr, NAPI_setUserSupportInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSupportName", nullptr, NAPI_getSupportName, nullptr, nullptr, nullptr, napi_default, nullptr},

        // 测试方法
        {"testCallEmpty", nullptr, NAPI_testCallEmpty, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"testCallString", nullptr, NAPI_testCallString, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"testCallBytes", nullptr, NAPI_testCallBytes, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"testCallVectorInt", nullptr, NAPI_testCallVectorInt, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"testCallVectorIntObject", nullptr, NAPI_testCallVectorIntObject, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"testCallVectorString", nullptr, NAPI_testCallVectorString, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"testCallVectorStringObject", nullptr, NAPI_testCallVectorStringObject, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"testSquareInt", nullptr, NAPI_testSquareInt, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"testNetwork", nullptr, NAPI_testNetwork, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"testProxy", nullptr, NAPI_testProxy, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"testGetDifference", nullptr, NAPI_testGetDifference, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"testUseUpdate", nullptr, NAPI_testUseUpdate, nullptr, nullptr, nullptr, napi_default, nullptr},
    };

    napi_define_properties(env, exports, sizeof(properties) / sizeof(properties[0]), properties);
}

} // namespace napi_binder
} // namespace tdlib