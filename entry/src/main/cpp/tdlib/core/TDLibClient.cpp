/**
 * TDLibClient 实现：调用 td_send / td_receive / td_execute
 */
#include "TDLibClient.h"
#include "td/telegram/td_json_client.h"

namespace tdlib {

TDLibClient::TDLibClient(int clientId) : clientId_(clientId) {}

void TDLibClient::send(const char* request) {
    td_send(clientId_, request);
}

const char* TDLibClient::receive(double timeoutSeconds) {
    return td_receive(timeoutSeconds);
}

const char* TDLibClient::execute(const char* request) {
    return td_execute(request);
}

} // namespace tdlib
