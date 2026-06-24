# TDLib for HarmonyOS 配置文件
# 自动生成于: Fri Jun 19 22:17:03 CST 2026

# TDLib 源版本（实际 TDLib 源码版本）
set(TDLIB_SOURCE_VERSION "1.8.65")
# TDLib HarmonyOS 打包版本（包含 HarmonyOS 适配标记）
set(TDLIB_PACKAGE_VERSION "1.8.65-harmonyos")
# 向后兼容
set(TDLIB_VERSION "1.8.65-harmonyos")
set(TDLIB_HARMONYOS_API_LEVEL "23")

# 根据架构设置路径
if(NOT DEFINED OHOS_ARCH_ABI)
    set(OHOS_ARCH_ABI "arm64-v8a")
endif()

set(TDLIB_INCLUDE_DIRS "${CMAKE_CURRENT_LIST_DIR}/include")
set(TDLIB_LIBRARY_DIRS "${CMAKE_CURRENT_LIST_DIR}/libs/${OHOS_ARCH_ABI}")

# 导出变量
set(TDLIB_FOUND TRUE)
message(STATUS "Found TDLib for HarmonyOS: v${TDLIB_PACKAGE_VERSION} (TDLib source v${TDLIB_SOURCE_VERSION})")

# TDLib 内部库（按依赖顺序）
set(_TDLIB_LIBS
    tdjson
    tdjson_static
    tdjson_private
    tdclient
    tdcore
    tdapi
    tdactor
    tdnet
    tdutils
    tdmtproto
    tddb
    tdsqlite
    tde2e
    ssl
    crypto
    z
    sqlite3
    icuuc
    icudata
    icui18n
    protobuf
    protobuf-lite
    re2
    crc32c
    xxhash
    event
    event_core
    event_extra
    event_pthreads
    lz4
    snappy
    double-conversion
    phonenumber
)

# 创建导入目标（与 FindTDLib.cmake 一致）
if(NOT TARGET TDLib::TDLib)
    add_library(TDLib::TDLib INTERFACE IMPORTED)
    set_target_properties(TDLib::TDLib PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${TDLIB_INCLUDE_DIRS}"
        INTERFACE_LINK_DIRECTORIES "${TDLIB_LIBRARY_DIRS}"
        INTERFACE_LINK_LIBRARIES "${_TDLIB_LIBS}"
    )
endif()

# 兼容旧的函数调用方式
function(tdlib_target_link_libraries TARGET)
    target_link_libraries(${TARGET} TDLib::TDLib)
endfunction()
