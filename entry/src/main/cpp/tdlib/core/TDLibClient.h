/**
 * TDLibClient：单个 TDLib 客户端封装
 * 负责单个 client 的 send/receive 操作
 */
#pragma once

#include <string>

namespace tdlib {

class TDLibClient {
public:
    explicit TDLibClient(int clientId);
    ~TDLibClient() = default;

    /** 获取客户端 ID */
    int getClientId() const { return clientId_; }

    /** 发送 JSON 请求 */
    void send(const char* request);

    /** 接收响应（阻塞，timeout 秒） */
    const char* receive(double timeoutSeconds);

    /** 同步执行请求 */
    const char* execute(const char* request);

private:
    int clientId_;
};

} // namespace tdlib
