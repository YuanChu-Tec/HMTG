/**
 * 简单日志封装
 */
#pragma once

#include <cstdio>
#include <cstring>

namespace tdlib {

inline void logInfo(const char* tag, const char* msg) {
    printf("[%s] %s\n", tag, msg);
}

inline void logError(const char* tag, const char* msg) {
    printf("[ERROR %s] %s\n", tag, msg);
}

} // namespace tdlib
