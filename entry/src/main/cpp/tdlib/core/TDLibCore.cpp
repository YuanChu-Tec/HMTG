/**
 * TDLib 核心实现：调用 td_json_client.h (td_create_client_id / td_send / td_receive / td_execute / td_set_log_message_callback / td_set_update_callback)
 * TDLib 内部日志通过 td_set_log_message_callback 回调输出到 hilog，与 ArkTS 层共用同一套日志（见文档 TDLib 验证码与最佳实践.md 第七节）。
 * TDLib 更新通过 td_set_update_callback 回调主动推送到应用层，实现事件驱动模型。
 */
#include "TDLibCore.h"
#include "td/telegram/td_json_client.h"
#include <mutex>
#include <cstdio>
#include <algorithm>

#if defined(__OHOS__) || defined(OHOS_UNIT_TEST)
#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x0001
#define LOG_TAG "TDLibNative"
#include "hilog/log.h"
#endif

namespace tdlib {

namespace {
    std::mutex g_receive_mutex; // td_receive 不可多线程同时调用

    /** TDLib 日志回调：输出到 hilog（与 ArkTS hilog 共用），便于 DevEco/hilog 统一查看。回调内禁止调用任何 TDLib 方法。 */
    void onTdLogMessage(int verbosity_level, const char *message) {
        if (!message) {
            return;
        }
#if defined(__OHOS__) || defined(OHOS_UNIT_TEST)
        OH_LOG_INFO(LOG_APP, "[%d] %{public}s", verbosity_level, message);
#else
        std::fprintf(stderr, "[TDLib][%d] %s\n", verbosity_level, message);
#endif
    }
}

TDLibCore& TDLibCore::instance() {
    static TDLibCore s_instance;
    return s_instance;
}

void TDLibCore::setLogVerbosityLevel(int level) {
    int clamped = std::max(0, std::min(1024, level));
    td_set_log_message_callback(clamped, onTdLogMessage);
}

int TDLibCore::createClientId() {
    return td_create_client_id();
}

void TDLibCore::send(int clientId, const char* request) {
    td_send(clientId, request);
}

const char* TDLibCore::receive(double timeoutSeconds) {
    std::lock_guard<std::mutex> lock(g_receive_mutex);
    return td_receive(timeoutSeconds);
}

const char* TDLibCore::execute(const char* request) {
    return td_execute(request);
}

void TDLibCore::closeClient(int clientId) {
    (void)clientId;
    // TDLib C API 无 td_close_client；客户端在进程退出前需保证不再使用
}

void TDLibCore::setUpdateCallback(UpdateCallback callback) {
    m_updateCallback = std::move(callback);
    
    // 注意：TDLib JSON C API 没有直接的 td_set_update_callback
    // 所有更新都会通过 td_receive 返回
    // Worker 层需要定期调用 receive() 来获取更新
}

} // namespace tdlib
