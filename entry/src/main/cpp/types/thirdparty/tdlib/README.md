# TDLib for HarmonyOS

## 版本信息
- TDLib源版本: 1.8.65
- HarmonyOS适配版本: 1.8.65-harmonyos
- HarmonyOS API级别: 23
- 构建日期: 20260619
- 包含架构: arm64-v8a armeabi-v7a x86_64

## 包含的库
- OpenSSL 1.1.1w
- zlib 1.2.13
- SQLite 3420000
- ICU 72.1
- Protocol Buffers 3.21.12
- libphonenumber 8.13.14
- RE2 2023-06-01
- libevent 2.1.12
- 以及其他必要的依赖库

## 使用方法

### CMake项目
```cmake
# 方法1: 使用 find_package(tdlib)（配置模式）
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/tdlib-harmonyos")

# 方法2: 使用 find_package(TDLib)（模块模式）
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/tdlib-harmonyos/cmake")

# 设置目标架构（必须）
set(OHOS_ARCH_ABI "arm64-v8a")  # 可选: arm64-v8a, armeabi-v7a, x86_64

find_package(tdlib REQUIRED)

# 链接到你的目标（两种方式任选）
target_link_libraries(your_target TDLib::TDLib)        # 推荐方式
# tdlib_target_link_libraries(your_target)              # 兼容方式
```

### 手动使用
```bash
# 设置环境变量
export OHOS_ARCH_ABI=arm64-v8a  # 可选: arm64-v8a, armeabi-v7a, x86_64
export C_INCLUDE_PATH="${TDLIB_PATH}/include:${C_INCLUDE_PATH}"
export CPLUS_INCLUDE_PATH="${TDLIB_PATH}/include:${CPLUS_INCLUDE_PATH}"
export LIBRARY_PATH="${TDLIB_PATH}/libs/${OHOS_ARCH_ABI}:${LIBRARY_PATH}"

# 编译
clang++ -std=c++17 -I${TDLIB_PATH}/include -L${TDLIB_PATH}/libs/${OHOS_ARCH_ABI} \
    your_app.cpp -o your_app \
    -ltdjson -ltdclient -ltdcore -ltdapi \
    -lssl -lcrypto -lsqlite3 -lprotobuf \
    -licuuc -licudata -licui18n \
    -levent -levent_pthreads \
    -lre2 -lcrc32c -lxxhash -llz4 -lsnappy \
    -ldouble-conversion -lphonenumber
```

## 许可证
各库有其自己的许可证，请参考各库的LICENSE文件。
