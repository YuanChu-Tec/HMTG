/**
 * TDLib 请求 JSON 拼接辅助
 * 将 @type 与 paramsJson 合并为完整请求字符串并发送
 */
#pragma once

#include <string>
#include "../tdlib/core/TDLibCore.h"

namespace tdlib {

/** 将 @type 与 paramsJson 合并：{"@type":"MethodName",...paramsJson 内容}，并发送 */
inline void sendRequest(int clientId, const char* methodName, const std::string& paramsJson) {
    std::string full = "{\"@type\":\"";
    full += methodName;
    full += "\"";
    if (!paramsJson.empty() && paramsJson[0] == '{' && paramsJson.size() > 2) {
        full += ",";
        full += paramsJson.substr(1); // 去掉 paramsJson 开头的 {
    } else if (!paramsJson.empty() && paramsJson[0] != '{') {
        full += ",";
        full += paramsJson;
    }
    full += "}";
    TDLibCore::instance().send(clientId, full.c_str());
}

} // namespace tdlib
