/**
 * 错误处理辅助
 */
#pragma once

#include <string>

namespace tdlib {

inline bool isTdlibError(const std::string& json) {
    return json.find("\"@type\":\"error\"") != std::string::npos;
}

} // namespace tdlib
