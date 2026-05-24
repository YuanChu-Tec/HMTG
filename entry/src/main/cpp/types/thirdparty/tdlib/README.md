# TDLib for HarmonyOS

## 版本信息
- TDLib 版本: 1.8.60（libs 内含 libtdjson.so.1.8.60，用于缓解 406 UPDATE_APP_TO_LOGIN）
- HarmonyOS API 级别: 9
- 构建日期: 20260201
- 包含架构: arm64-v8a、armeabi-v7a、x86_64

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
# 在CMakeLists.txt中添加
set(CMAKE_PREFIX_PATH "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/tdlib-harmonyos")
find_package(tdlib REQUIRED)

# 链接到你的目标
tdlib_target_link_libraries(your_target)
```

### 手动使用
```bash
# 设置环境变量
export C_INCLUDE_PATH="${TDLIB_PATH}/include:${C_INCLUDE_PATH}"
export CPLUS_INCLUDE_PATH="${TDLIB_PATH}/include:${CPLUS_INCLUDE_PATH}"
export LIBRARY_PATH="${TDLIB_PATH}/libs/${OHOS_ARCH_ABI}:${LIBRARY_PATH}"

# 编译
clang++ -std=c++17 -I${TDLIB_PATH}/include -L${TDLIB_PATH}/libs/arm64-v8a \
    -ltdjson -ltdclient -lssl -lcrypto -lsqlite3 \
    your_app.cpp -o your_app
```

## 与 HMTG 项目集成

本仓库通过 **仅链接 libtdjson.so.1.8.60**（在 `entry/src/main/cpp/CMakeLists.txt` 中）与 HMTG 集成，不依赖 `libs/<abi>/cmake/` 下的 find_package(Td) 配置。若将来改用 find_package(Td)，需将 `libs/*/cmake/` 内硬编码的构建机绝对路径（如 `E:/important/tdlib-harmony-builder/install/...`）改为相对路径（如 `${CMAKE_CURRENT_LIST_DIR}/../..`），否则在其他机器或 CI 上会链接失败。

## 许可证
各库有其自己的许可证，请参考各库的 LICENSE 文件。
