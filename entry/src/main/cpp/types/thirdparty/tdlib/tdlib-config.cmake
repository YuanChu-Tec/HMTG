# TDLib for HarmonyOS 配置文件
# 自动生成于: Sun Feb  1 02:28:06 CST 2026

set(TDLIB_VERSION "1.8.0-harmonyos")
set(TDLIB_HARMONYOS_API_LEVEL "9")

# 根据架构设置路径
if(NOT DEFINED OHOS_ARCH_ABI)
    set(OHOS_ARCH_ABI "arm64-v8a")
endif()

set(TDLIB_INCLUDE_DIRS "${CMAKE_CURRENT_LIST_DIR}/include")
set(TDLIB_LIBRARY_DIRS "${CMAKE_CURRENT_LIST_DIR}/libs/${OHOS_ARCH_ABI}")

# 导出变量
set(TDLIB_FOUND TRUE)
message(STATUS "Found TDLib for HarmonyOS: ${TDLIB_VERSION}")

# 添加链接库
function(tdlib_target_link_libraries TARGET)
    target_include_directories(${TARGET} PRIVATE ${TDLIB_INCLUDE_DIRS})
    target_link_directories(${TARGET} PRIVATE ${TDLIB_LIBRARY_DIRS})
    
    # TDLib 主库
    target_link_libraries(${TARGET}
        tdjson
        tdjson_static
        tdclient
        tdcore
    )
    
    # 依赖库
    target_link_libraries(${TARGET}
        ssl
        crypto
        z
        sqlite3
        icuuc
        icudata
        protobuf
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
endfunction()
