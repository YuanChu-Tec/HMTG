/**
 * StateMonitor：TDLib 连接/认证状态回调监听
 * 可选：用于监听 updateAuthorizationState、updateConnectionState 等
 */
#pragma once

#include <functional>
#include <string>

namespace tdlib {

enum class AuthState {
    WaitTdlibParameters,
    WaitPhoneNumber,
    WaitCode,
    WaitPassword,
    WaitRegistration,
    Ready,
    Closed
};

enum class ConnectionState {
    WaitingForNetwork,
    ConnectingToProxy,
    Connecting,
    Updating,
    Ready
};

class StateMonitor {
public:
    using AuthStateCallback = std::function<void(AuthState)>;
    using ConnectionStateCallback = std::function<void(ConnectionState)>;

    static StateMonitor& instance();

    /** 设置认证状态回调 */
    void setAuthStateCallback(AuthStateCallback callback);

    /** 设置连接状态回调 */
    void setConnectionStateCallback(ConnectionStateCallback callback);

    /** 处理 TDLib 更新（从 receive 循环调用） */
    void handleUpdate(const std::string& updateJson);

    StateMonitor(const StateMonitor&) = delete;
    StateMonitor& operator=(const StateMonitor&) = delete;

private:
    StateMonitor() = default;
    ~StateMonitor() = default;

    AuthStateCallback authCallback_;
    ConnectionStateCallback connCallback_;
};

} // namespace tdlib
