# TDLib 集成：使用已编译好的 TDLib (src/main/cpp/types/thirdparty/tdlib)
cmake_minimum_required(VERSION 3.5.0)
project(HMTG)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

# TDLib 预编译路径
set(TDLIB_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/types/thirdparty/tdlib)
if(DEFINED CMAKE_OHOS_ARCH_ABI)
    set(OHOS_ARCH_ABI ${CMAKE_OHOS_ARCH_ABI})
elseif(NOT DEFINED OHOS_ARCH_ABI)
    set(OHOS_ARCH_ABI "arm64-v8a")
endif()

include_directories(
    ${NATIVERENDER_ROOT_PATH}
    ${NATIVERENDER_ROOT_PATH}/include
    ${TDLIB_ROOT}/include
)

link_directories(${TDLIB_ROOT}/libs/${OHOS_ARCH_ABI})

# Native 库：home (产出 libhome.so，符合方案要求)
add_library(home SHARED
    napi_init.cpp
    # core 层
    tdlib/core/TDLibCore.cpp
    tdlib/core/TDLibClient.cpp
    tdlib/core/StateMonitor.cpp
    # api 层
    tdlib/api/TDLibApi.cpp
    # napi 层
    tdlib/napi/NAPIBinder.cpp
)

target_link_libraries(home PUBLIC libace_napi.z.so libhilog_ndk.z.so)

# 链接 TDLib（支持 libtdjson.so、libtdjson.so.1.8.0、libtdjson.so.1.8.60 等）
set(TDLIB_JSON_DIR "${TDLIB_ROOT}/libs/${OHOS_ARCH_ABI}")
if(EXISTS "${TDLIB_JSON_DIR}/libtdjson.so")
    target_link_libraries(home PRIVATE tdjson)
elseif(EXISTS "${TDLIB_JSON_DIR}/libtdjson.so.1.8.60")
    target_link_libraries(home PRIVATE ${TDLIB_JSON_DIR}/libtdjson.so.1.8.60)
elseif(EXISTS "${TDLIB_JSON_DIR}/libtdjson.so.1.8.0")
    target_link_libraries(home PRIVATE ${TDLIB_JSON_DIR}/libtdjson.so.1.8.0)
else()
    # 兜底：尝试 -ltdjson（需目录内有 libtdjson.so 或 libtdjson.a）
    target_link_libraries(home PRIVATE tdjson)
endif()
