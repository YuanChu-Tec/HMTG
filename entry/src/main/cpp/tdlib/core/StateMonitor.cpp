/**
 * StateMonitor 实现：解析 updateAuthorizationState / updateConnectionState 并触发回调
 */
#include "StateMonitor.h"
#include <cstring>

namespace tdlib {

StateMonitor& StateMonitor::instance() {
    static StateMonitor s_instance;
    return s_instance;
}

void StateMonitor::setAuthStateCallback(AuthStateCallback callback) {
    authCallback_ = callback;
}

void StateMonitor::setConnectionStateCallback(ConnectionStateCallback callback) {
    connCallback_ = callback;
}

void StateMonitor::handleUpdate(const std::string& updateJson) {
    // 简化：检查 @type 是否为 updateAuthorizationState 或 updateConnectionState
    if (updateJson.find("\"@type\":\"updateAuthorizationState\"") != std::string::npos) {
        // 解析 authorization_state.@type 并触发回调（此处简化为字符串匹配）
        if (updateJson.find("authorizationStateWaitTdlibParameters") != std::string::npos) {
            if (authCallback_) authCallback_(AuthState::WaitTdlibParameters);
        } else if (updateJson.find("authorizationStateWaitPhoneNumber") != std::string::npos) {
            if (authCallback_) authCallback_(AuthState::WaitPhoneNumber);
        } else if (updateJson.find("authorizationStateWaitCode") != std::string::npos) {
            if (authCallback_) authCallback_(AuthState::WaitCode);
        } else if (updateJson.find("authorizationStateWaitPassword") != std::string::npos) {
            if (authCallback_) authCallback_(AuthState::WaitPassword);
        } else if (updateJson.find("authorizationStateWaitRegistration") != std::string::npos) {
            if (authCallback_) authCallback_(AuthState::WaitRegistration);
        } else if (updateJson.find("authorizationStateReady") != std::string::npos) {
            if (authCallback_) authCallback_(AuthState::Ready);
        } else if (updateJson.find("authorizationStateClosed") != std::string::npos) {
            if (authCallback_) authCallback_(AuthState::Closed);
        }
    } else if (updateJson.find("\"@type\":\"updateConnectionState\"") != std::string::npos) {
        if (updateJson.find("connectionStateWaitingForNetwork") != std::string::npos) {
            if (connCallback_) connCallback_(ConnectionState::WaitingForNetwork);
        } else if (updateJson.find("connectionStateConnectingToProxy") != std::string::npos) {
            if (connCallback_) connCallback_(ConnectionState::ConnectingToProxy);
        } else if (updateJson.find("connectionStateConnecting") != std::string::npos) {
            if (connCallback_) connCallback_(ConnectionState::Connecting);
        } else if (updateJson.find("connectionStateUpdating") != std::string::npos) {
            if (connCallback_) connCallback_(ConnectionState::Updating);
        } else if (updateJson.find("connectionStateReady") != std::string::npos) {
            if (connCallback_) connCallback_(ConnectionState::Ready);
        }
    }
}

} // namespace tdlib
