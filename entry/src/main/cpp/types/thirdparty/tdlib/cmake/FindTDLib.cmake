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

# 查找库文件
find_library(TDLIB_JSON_LIBRARY
    NAMES tdjson tdjson_static
    PATHS
        ${CMAKE_CURRENT_LIST_DIR}/../libs/${OHOS_ARCH_ABI}
        ${CMAKE_PREFIX_PATH}/libs/${OHOS_ARCH_ABI}
        ${CMAKE_PREFIX_PATH}/lib
        /usr/local/lib
        /usr/lib
)

find_library(TDLIB_CLIENT_LIBRARY
    NAMES tdclient
    PATHS
        ${CMAKE_CURRENT_LIST_DIR}/../libs/${OHOS_ARCH_ABI}
        ${CMAKE_PREFIX_PATH}/libs/${OHOS_ARCH_ABI}
        ${CMAKE_PREFIX_PATH}/lib
        /usr/local/lib
        /usr/lib
)

find_library(TDLIB_CORE_LIBRARY
    NAMES tdcore
    PATHS
        ${CMAKE_CURRENT_LIST_DIR}/../libs/${OHOS_ARCH_ABI}
        ${CMAKE_PREFIX_PATH}/libs/${OHOS_ARCH_ABI}
        ${CMAKE_PREFIX_PATH}/lib
        /usr/local/lib
        /usr/lib
)

# 设置变量
if(TDLIB_INCLUDE_DIR AND TDLIB_JSON_LIBRARY)
    set(TDLIB_FOUND TRUE)
    set(TDLIB_LIBRARIES
        ${TDLIB_JSON_LIBRARY}
        ${TDLIB_CLIENT_LIBRARY}
        ${TDLIB_CORE_LIBRARY}
    )
    set(TDLIB_INCLUDE_DIRS ${TDLIB_INCLUDE_DIR})
    
    # 查找依赖库
    find_library(TDLIB_SSL_LIBRARY ssl
        PATHS ${CMAKE_PREFIX_PATH}/libs/${OHOS_ARCH_ABI}
    )
    find_library(TDLIB_CRYPTO_LIBRARY crypto
        PATHS ${CMAKE_PREFIX_PATH}/libs/${OHOS_ARCH_ABI}
    )
    find_library(TDLIB_Z_LIBRARY z
        PATHS ${CMAKE_PREFIX_PATH}/libs/${OHOS_ARCH_ABI}
    )
    find_library(TDLIB_SQLITE_LIBRARY sqlite3
        PATHS ${CMAKE_PREFIX_PATH}/libs/${OHOS_ARCH_ABI}
    )
    
    if(TDLIB_SSL_LIBRARY)
        list(APPEND TDLIB_LIBRARIES ${TDLIB_SSL_LIBRARY})
    endif()
    if(TDLIB_CRYPTO_LIBRARY)
        list(APPEND TDLIB_LIBRARIES ${TDLIB_CRYPTO_LIBRARY})
    endif()
    if(TDLIB_Z_LIBRARY)
        list(APPEND TDLIB_LIBRARIES ${TDLIB_Z_LIBRARY})
    endif()
    if(TDLIB_SQLITE_LIBRARY)
        list(APPEND TDLIB_LIBRARIES ${TDLIB_SQLITE_LIBRARY})
    endif()
endif()

# 显示结果
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(TDLib
    FOUND_VAR TDLIB_FOUND
    REQUIRED_VARS TDLIB_INCLUDE_DIR TDLIB_JSON_LIBRARY
)

if(TDLIB_FOUND)
    message(STATUS "Found TDLib:")
    message(STATUS "  Include dirs: ${TDLIB_INCLUDE_DIRS}")
    message(STATUS "  Libraries: ${TDLIB_LIBRARIES}")
endif()

# 创建导入目标
if(TDLIB_FOUND AND NOT TARGET TDLib::TDLib)
    add_library(TDLib::TDLib INTERFACE IMPORTED)
    set_target_properties(TDLib::TDLib PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${TDLIB_INCLUDE_DIRS}"
        INTERFACE_LINK_LIBRARIES "${TDLIB_LIBRARIES}"
    )
endif()
