/**
 * TDLib 核心封装
 * 单例：封装 td_create_client_id / td_send / td_receive / td_execute / td_set_log_message_callback / td_set_update_callback
 */
#pragma once

#include <string>
#include <functional>

namespace tdlib {

class TDLibCore {
public:
    static TDLibCore& instance();

    /** 设置日志级别 (0-1024)，对应 td_set_log_message_callback 的 max_verbosity_level */
    void setLogVerbosityLevel(int level);

    /** 创建 TDLib 客户端，返回 client_id (对应 td_create_client_id) */
    int createClientId();

    /** 向指定 client 发送 JSON 请求 (对应 td_send) */
    void send(int clientId, const char* request);

    /** 全局接收：从任意 client 接收一条响应/更新 (对应 td_receive)，timeout 秒 */
    const char* receive(double timeoutSeconds);

    /** 同步执行一条 JSON 请求 (对应 td_execute) */
    const char* execute(const char* request);

    /** 关闭客户端：TDLib C API 无显式关闭，此处留空或发送 close 请求；当前为 no-op */
    void closeClient(int clientId);

    /** 设置 TDLib 更新回调函数（事件驱动模型核心） */
    using UpdateCallback = std::function<void(const char* updateJson)>;
    void setUpdateCallback(UpdateCallback callback);

    TDLibCore(const TDLibCore&) = delete;
    TDLibCore& operator=(const TDLibCore&) = delete;

private:
    TDLibCore() = default;
    ~TDLibCore() = default;
    
    UpdateCallback m_updateCallback;  ///< TDLib 更新回调
};

} // namespace tdlib
