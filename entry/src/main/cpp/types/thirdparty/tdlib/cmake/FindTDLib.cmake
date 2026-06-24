# FindTDLib.cmake
# TDLib for HarmonyOS CMake 查找模块

# 设置默认架构
if(NOT DEFINED OHOS_ARCH_ABI)
    set(OHOS_ARCH_ABI "arm64-v8a")
endif()

# 查找头文件
find_path(TDLIB_INCLUDE_DIR
    NAMES td/telegram/Client.h
    PATHS
        ${CMAKE_CURRENT_LIST_DIR}/../include
        ${CMAKE_PREFIX_PATH}/include
        /usr/local/include
        /usr/include
    PATH_SUFFIXES td
)

# 查找库文件目录
find_path(TDLIB_LIBRARY_DIR
    NAMES libtdjson.a libtdjson.so
    PATHS
        ${CMAKE_CURRENT_LIST_DIR}/../libs/${OHOS_ARCH_ABI}
        ${CMAKE_PREFIX_PATH}/libs/${OHOS_ARCH_ABI}
        ${CMAKE_PREFIX_PATH}/lib
        /usr/local/lib
        /usr/lib
)

# 设置变量
if(TDLIB_INCLUDE_DIR AND TDLIB_LIBRARY_DIR)
    set(TDLIB_FOUND TRUE)
    set(TDLIB_INCLUDE_DIRS ${TDLIB_INCLUDE_DIR})
else()
    set(TDLIB_FOUND FALSE)
endif()

# 显示结果
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(TDLib
    FOUND_VAR TDLIB_FOUND
    REQUIRED_VARS TDLIB_INCLUDE_DIR TDLIB_LIBRARY_DIR
)

# 创建导入目标和链接宏
if(TDLIB_FOUND AND NOT TARGET TDLib::TDLib)
    add_library(TDLib::TDLib INTERFACE IMPORTED)
    set_target_properties(TDLib::TDLib PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${TDLIB_INCLUDE_DIRS}"
        INTERFACE_LINK_DIRECTORIES "${TDLIB_LIBRARY_DIR}"
    )

    # TDLib 内部库（按依赖顺序）
    set(_TDLIB_INTERNAL_LIBS
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
    )

    # 外部依赖库（TDLib 的依赖）
    set(_TDLIB_EXTERNAL_LIBS
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

    # 将 TDLib 内部库链接为接口依赖
    set(_TDLIB_ALL_LIBS "")
    foreach(_lib IN LISTS _TDLIB_INTERNAL_LIBS _TDLIB_EXTERNAL_LIBS)
        list(APPEND _TDLIB_ALL_LIBS "${_lib}")
    endforeach()

    set_target_properties(TDLib::TDLib PROPERTIES
        INTERFACE_LINK_OPTIONS "$<$<CONFIG:Release>:-s>"
        INTERFACE_LINK_LIBRARIES "${_TDLIB_ALL_LIBS}"
    )

    if(TDLIB_FOUND)
        message(STATUS "Found TDLib (HarmonyOS):")
        message(STATUS "  Version: ${PROJECT_VERSION}")
        message(STATUS "  Include dirs: ${TDLIB_INCLUDE_DIRS}")
        message(STATUS "  Library dir: ${TDLIB_LIBRARY_DIR}")
        message(STATUS "  Target: TDLib::TDLib")
        message(STATUS "")
        message(STATUS "  Usage in CMakeLists.txt:")
        message(STATUS "    find_package(TDLib REQUIRED)")
        message(STATUS "    target_link_libraries(your_target TDLib::TDLib)")
    endif()
endif()
