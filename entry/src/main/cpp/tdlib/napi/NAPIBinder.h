/**
 * NAPI 通用辅助：参数读取、类型转换
 */
#pragma once

#include "napi/native_api.h"
#include <string>

namespace tdlib {
namespace napi_helper {

/** 从 args[index] 读取 int32 */
inline int32_t getInt32(napi_env env, napi_value* args, size_t index) {
    int32_t val = 0;
    napi_get_value_int32(env, args[index], &val);
    return val;
}

/** 从 args[index] 读取 int64 */
inline int64_t getInt64(napi_env env, napi_value* args, size_t index) {
    int64_t val = 0;
    napi_get_value_int64(env, args[index], &val);
    return val;
}

/** 从 args[index] 读取 string */
inline std::string getString(napi_env env, napi_value* args, size_t index) {
    size_t len = 0;
    napi_get_value_string_utf8(env, args[index], nullptr, 0, &len);
    std::string s(len + 1, '\0');
    napi_get_value_string_utf8(env, args[index], &s[0], len + 1, &len);
    s.resize(len);
    return s;
}

/** 从 args[index] 读取 bool */
inline bool getBool(napi_env env, napi_value* args, size_t index) {
    bool val = false;
    napi_get_value_bool(env, args[index], &val);
    return val;
}

/** 从 args[index] 读取 double */
inline double getDouble(napi_env env, napi_value* args, size_t index) {
    double val = 0.0;
    napi_get_value_double(env, args[index], &val);
    return val;
}

} // namespace napi_helper

// NAPI 绑定宏定义
#define DEFINE_NAPI_METHOD(func_name) \
    napi_value NAPI_##func_name(napi_env env, napi_callback_info info) { \
        size_t argc = 2; \
        napi_value args[2] = {nullptr}; \
        napi_get_cb_info(env, info, &argc, args, nullptr, nullptr); \
        int32_t clientId = napi_helper::getInt32(env, args, 0); \
        std::string paramsJson = napi_helper::getString(env, args, 1); \
        tdlib::api::func_name(clientId, paramsJson); \
        return nullptr; \
    }

#define REGISTER_NAPI_METHOD(name) \
    {#name, nullptr, NAPI_##name, nullptr, nullptr, nullptr, napi_default, nullptr}

} // namespace tdlib
