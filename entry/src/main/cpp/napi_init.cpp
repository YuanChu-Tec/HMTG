#include "napi/native_api.h"
#include "tdlib/core/TDLibCore.h"
#include <cstring>
#include <string>

// 1 个域的注册函数声明（定义于 tdlib::napi_binder 命名空间）
namespace tdlib { namespace napi_binder {
extern void registerAllBindings(napi_env env, napi_value exports);
}}

static napi_value Add(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    double value0 = 0, value1 = 0;
    napi_get_value_double(env, args[0], &value0);
    napi_get_value_double(env, args[1], &value1);
    napi_value sum;
    napi_create_double(env, value0 + value1, &sum);
    return sum;
}

// ========== TDLib 通用 NAPI ==========
// 注意：setLogVerbosityLevel 已移至 NAPIBinder.cpp，使用标准 2 参数签名

static napi_value TDLibCreateClientId(napi_env env, napi_callback_info info)
{
    int clientId = tdlib::TDLibCore::instance().createClientId();
    napi_value result;
    napi_create_int32(env, clientId, &result);
    return result;
}

static napi_value TDLibSendById(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = 0;
    napi_get_value_int32(env, args[0], &clientId);
    size_t strLen = 0;
    napi_get_value_string_utf8(env, args[1], nullptr, 0, &strLen);
    std::string request(strLen + 1, '\0');
    napi_get_value_string_utf8(env, args[1], &request[0], strLen + 1, &strLen);
    request.resize(strLen);
    tdlib::TDLibCore::instance().send(clientId, request.c_str());
    return nullptr;
}

static napi_value TDLibReceiveGlobal(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    double timeout = 10.0;
    if (argc > 0) {
        napi_get_value_double(env, args[0], &timeout);
    }
    const char* response = tdlib::TDLibCore::instance().receive(timeout);
    if (response == nullptr || response[0] == '\0') {
        return nullptr;
    }
    napi_value result;
    napi_create_string_utf8(env, response, NAPI_AUTO_LENGTH, &result);
    return result;
}

static napi_value TDLibExecuteGlobal(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    size_t strLen = 0;
    napi_get_value_string_utf8(env, args[0], nullptr, 0, &strLen);
    std::string request(strLen + 1, '\0');
    napi_get_value_string_utf8(env, args[0], &request[0], strLen + 1, &strLen);
    request.resize(strLen);
    const char* response = tdlib::TDLibCore::instance().execute(request.c_str());
    if (response == nullptr || response[0] == '\0') {
        return nullptr;
    }
    napi_value result;
    napi_create_string_utf8(env, response, NAPI_AUTO_LENGTH, &result);
    return result;
}

static napi_value TDLibCloseClient(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = 0;
    napi_get_value_int32(env, args[0], &clientId);
    tdlib::TDLibCore::instance().closeClient(clientId);
    return nullptr;
}

static napi_value TDLibDestroyClient(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t clientId = 0;
    napi_get_value_int32(env, args[0], &clientId);
    // 注意：TDLibCore 内部需确保 destroyClient 线程安全
    // 如果 TDLibCore 尚未实现 destroyClient，此处可暂时调用 closeClient 或留空
    tdlib::TDLibCore::instance().closeClient(clientId); 
    return nullptr;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    // 通用接口
    napi_property_descriptor desc[] = {
        { "add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "tdlibCreateClientId", nullptr, TDLibCreateClientId, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "tdlibSendById", nullptr, TDLibSendById, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "tdlibReceiveGlobal", nullptr, TDLibReceiveGlobal, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "tdlibExecuteGlobal", nullptr, TDLibExecuteGlobal, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "tdlibCloseClient", nullptr, TDLibCloseClient, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "tdlibDestroyClient", nullptr, TDLibDestroyClient, nullptr, nullptr, nullptr, napi_default, nullptr },
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);

    // 注册 1 个域的 500+ 个 TDLib API
    tdlib::napi_binder::registerAllBindings(env, exports);

    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "home",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterHomeModule(void)
{
    napi_module_register(&demoModule);
}
