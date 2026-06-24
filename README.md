<!-- PROJECT LOGO -->
<br />

<p align="center">
  <a href="https://github.com/Zitann/HarmonyOS-Haps">
    <img src="https://www.harmonyos.com/resource/image/release2/home/harmonyOS_logo.png" alt="Logo" height="80">
  </a>

  <h3 align="center">HMTG</h3>
  <p align="center">
    基于 TDLib 的 Telegram for HarmonyOS — 为鸿蒙系统提供原生、高效的 Telegram 体验。
  </p>

## 目录

- [声明](#声明)
- [作者的话](#作者的话)
- [项目简介](#项目简介)
- [项目架构总览](#项目架构总览)
- [技术栈](#技术栈)
- [模块目录说明](#模块目录说明)
- [数据流](#数据流)
- [主题与UI组件](#主题与ui组件)
- [权限说明](#权限说明)
- [构建配置](#构建配置)
- [安装调试](#安装调试)
- [开发指引](#开发指引)
- [反馈](#反馈)
- [鸣谢](#鸣谢)

---

## 声明

本仓库的所有内容仅供学习交流使用。如果您认为该内容侵犯了您的权益，请在 issue 中与我们联系，我们将立即删除相关内容。

## 作者的话

本人只是一个业余玩家，空闲时做些自己喜欢做的事，该项目是边学习边制作的（大量借助 AI IDE），所以质量欠佳，希望能有大佬协助创作，遂开源。

- Telegram 交流群：https://t.me/HMTGchannel 、 https://t.me/HMTGchat
- QQ 群：1075753335

---

## 项目简介

HMTG 是基于 **TDLib** 构建的 **HarmonyOS Telegram 客户端**，包名 `com.YuanChu.HMTG`，目标设备覆盖手机、平板、2in1。

| 属性 | 值 |
|------|-----|
| 包名 | com.YuanChu.HMTG |
| 版本 | 1.0.4 (versionCode: 1000004) |
| 最低兼容 SDK | 6.1.0(23) |
| 目标 SDK | 6.1.1(24) |
| 应用类型 | Stage 模型 + ArkTS |

核心技术选型：

- **IM 引擎** — TDLib（Telegram Database Library），通过 C++ NAPI 桥接到 ArkTS
- **UI 框架** — ArkUI 声明式 UI，MVVM 架构
- **状态管理** — 自定义 EventBus + ViewModel 数据源
- **持久化** — MMKV 高性能 KV 存储 + 自定义 HAR 缓存模块
- **通信** — 华为 Push Kit + WebRTC 音视频

---

## 项目架构总览

```
HMTG/
├── entry/                              # 主入口模块
│   ├── src/main/ets/
│   │   ├── entryability/               # Ability 生命周期入口
│   │   ├── pages/                      # 页面层（10 个主页面）
│   │   ├── viewmodels/                 # ViewModel 层
│   │   ├── models/                     # 数据模型定义
│   │   ├── ui_kit/                     # UI 组件库 + 主题系统
│   │   │   ├── components/             # 通用组件
│   │   │   ├── themes/                 # Light / Dark / System 三套主题
│   │   │   └── utils/                  # UI 工具（动画、点击效果）
│   │   ├── services/                   # 服务层
│   │   │   ├── api/                    # TDLib API 封装 & 类型声明
│   │   │   ├── business/               # 核心业务（CoreService 等）
│   │   │   ├── core/                   # TDLib Worker 通信
│   │   │   ├── network/                # 网络基础设施
│   │   │   ├── infrastructure/         # 连接管理
│   │   │   ├── optimization/           # 性能优化
│   │   │   └── system/                 # 系统集成（Push、备份等）
│   │   ├── utils/                      # 工具库
│   │   ├── tasks/                      # 后台任务
│   │   └── workers/                    # TDLib Worker 线程
│   ├── src/main/cpp/                   # C++ 原生代码
│   │   ├── tdlib/                      # TDLib C++ 封装
│   │   └── napi_init.cpp              # NAPI 导出入口
│   └── libs/                           # 预置原生 so 库
├── storage_cache/                      # HAR 缓存共享模块 — 多级缓存体系
│   └── src/main/ets/com/cache/
│       ├── CacheStorage.ets            # 统一缓存入口（LRU + DB + MMKV + Disk四层）
│       ├── database/
│       │   └── DatabaseManager.ets     # RDB 关系型数据库（23张表 + FTS全文搜索）
│       ├── mmkv/
│       │   └── MMKVManager.ets         # MMKV 高性能 KV 存储封装
│       ├── disk/
│       │   └── DiskLruCacheManager.ets # 文件级 LRU 磁盘缓存
│       ├── image/
│       │   └── ImageKnifeManager.ets   # ImageKnife 图片加载封装
│       ├── model/
│       │   └── TelegramEntity.ets      # 25+ 数据实体定义
│       └── utils/
│           ├── CryptoHelper.ets        # AES-256-GCM 加密工具
│           ├── Logger.ets              # 日志工具
│           └── Result.ets              # 统一返回类型
└── AppScope/                           # 全局资源（图标、启动页）

```

### 分层架构

```text
┌─────────────────────────────────────────────┐
│              UI Layer (Pages)                │
│   Index, ChatListPage, ChatPage, Login...   │
├─────────────────────────────────────────────┤
│          ViewModel Layer                     │
│   ChatListViewModel, ChatPageViewModel...    │
├─────────────────────────────────────────────┤
│           Service Layer                      │
│   CoreService / AuthService / FileDownload   │
├─────────────────────────────────────────────┤
│        Infrastructure Layer                  │
│   TDLibClient / RequestQueue / Connection    │
├─────────────────────────────────────────────┤
│           Worker Thread                      │
│   TdlibWorker (独立消息循环)                  │
├─────────────────────────────────────────────┤
│     NAPI Binding (libhome.so)                │
├─────────────────────────────────────────────┤
│     Native Library (libtdjson, libz)         │
└─────────────────────────────────────────────┘
```

---

## 技术栈

### 鸿蒙 Kit 套件

| Kit | 用途 |
|-----|------|
| `@kit.AbilityKit` | UIAbility 生命周期、Want 路由、Deep Link |
| `@kit.ArkUI` | 声明式 UI 框架（@Component, @State, LazyForEach） |
| `@kit.ArkTS` | 语言运行时 & Worker 线程 |
| `@kit.PerformanceAnalysisKit` | 性能日志（hilog） |
| `@kit.CoreFileKit` | 文件 I/O（fileIo） |
| `@kit.BasicServicesKit` | 基础错误类型（BusinessError） |
| **Push Kit** | 华为推送通知服务 |

### 第三方依赖

| 库 | 版本 | 用途 | 来源 | 所属模块 |
|----|------|------|------|----------|
| libtdjson.so | — | TDLib 原生核心 | 自定义 CMake 编译 | entry |
| libhome.so | 1.0.0 | TDLib NAPI 绑定 | `cpp/types/libhome` | entry |
| @tencent/mmkv | 2.4.0 | 高性能键值存储 | ohpm | storage_cache |
| @ohos/imageknife | 2.2.0 | 图片加载与缓存 | ohpm | storage_cache |
| @ohos/lottie-turbo | 1.0.10 | Lottie 动画渲染 | ohpm | entry |
| @yuanchu/webrtc | 1.0.2 | WebRTC 音视频通话 | ohpm | entry |
| @ohos/zxing | 2.1.2 | 二维码扫描解码 | ohpm | entry + 根项目 |
| pako | 2.1.0 | 数据压缩/解压 | ohpm | storage_cache(imageknife依赖) |
| @ohos/pinyin4js | 2.0.2 | 汉字拼音转换 | ohpm | 根项目 |

### TDLib NAPI 绑定架构

C++ 层将 TDLib 核心 API 导出为四个关键函数，通过 Worker 线程异步通信：

```typescript
// libhome.d.ts — NAPI 绑定类型声明
declare function tdlibCreateClientId(): number;
declare function tdlibSendById(clientId: number, request: string): void;
declare function tdlibReceiveGlobal(timeout: number): string | null;
declare function tdlibExecuteGlobal(request: string): string | null;
```

---

## storage_cache 模块：多级缓存体系深度解析

`storage_cache` 是一个类型为 `har` 的共享模块（HAR，Harmony Archive），作为整个应用的持久化基础设施，为 `entry` 模块提供**四级缓存 + 关系型数据库 + KV存储 + 文件缓存**的统一能力。

### 6.1 模块基本信息

| 属性 | 值 |
|------|-----|
| 模块名 | `@storage/cache` (package: @storage/cache) |
| 类型 | HAR（静态共享库） |
| 版本 | 1.0.0 |
| 描述 | 通用缓存持久化模块，支持消息类型及多应用场景 |
| 目标设备 | default / tablet / 2in1 / car / wearable / tv |

### 6.2 四层缓存架构

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: 内存 LRU 缓存（最快）                             │
│  util.LRUCache<number, Entity>                             │
│   messageMemCache(500条) | chatMemCache(50条) | user(200条)│
├─────────────────────────────────────────────────────────────┤
│  Layer 2: MMKV（高性能 KV 持久化）                          │
│  @tencent/mmkv  — 进程级 mmap 存储                        │
│  用途：设置项、Token、小对象快速读写                        │
├─────────────────────────────────────────────────────────────┤
│  Layer 3: 关系型数据库（RDB）                               │
│  @kit.ArkData relationalStore — SQLite 瓦特级               │
│  23 张业务表 + 全文搜索(FTS) + 回收站机制                   │
├─────────────────────────────────────────────────────────────┤
│  Layer 4: 磁盘 LRU 文件缓存                                 │
│  fileIo + LRUCache  — 大文件缓存(图片/视频缩略图等)       │
│  支持 TTL 过期 + 内存索引                                   │
└─────────────────────────────────────────────────────────────┘
```

### 6.3 各层详细说明

#### Layer 1 — 内存 LRU 缓存 (`CacheStorage.ets`)

```typescript
// 缓存项容量配置（可动态调整）
messageMemCache = new util.LRUCache(500);   // 最多500条消息
chatMemCache   = new util.LRUCache(50);     // 最多50个聊天
userMemCache   = new util.LRUCache(200);    // 最多200个用户
```

- 使用 `@kit.ArkTS` 内置的 `util.LRUCache` 实现
- **缓存穿透防护**：`getMessageWithCache` 先查内存 → 未命中则查 DB → 回填缓存
- **批量读取优化**：`getMessagesWithCache` 支持批量 ID 查缓存 → 一次性查询缺失项
- **缓存统计**：内置命中/未命中计数，提供 `getHitRateReport()` 监控缓存效率

#### Layer 2 — MMKV 键值存储 (`MMKVManager.ets`)

```typescript
// MMKV 封装了标准的 5 种类型 + JSON 对象 + 加密存储
setString / getString
setBoolean / getBoolean
setNumber / getNumber
setInt64 / getInt64
setObject<T> / getObject<T>    // JSON 序列化
setEncryptedString / getEncryptedString  // AES-256-GCM
```

- 基于 `@tencent/mmkv` v2.4.0（微信开源的高性能 KV 组件）
- 使用 mmap 内存映射，读写性能远超 SQLite
- **键索引机制**：维护 `__mmkv_key_index__` 跟踪所有键，支持按前缀批量查询/删除
- **加密存储**：敏感数据通过 `CryptoHelper` 的 AES-256-GCM 加密后存储

#### Layer 3 — 关系型数据库 (`DatabaseManager.ets`)

使用 `@kit.ArkData` 的 `relationalStore`（SQLite 封装），共 **23 张业务表**：

| 表名 | 用途 | 核心字段 |
|------|------|----------|
| `messages` | 消息持久化 | messageId, chatId, senderId, contentJson, flags |
| `chats` | 聊天会话 | chatId, title, type, lastMessageId, unreadCount |
| `media` | 媒体文件 | fileId, messageId, localPath, size, downloadProgress |
| `stories` | 故事(TL) | storyId, senderId, contentJson, expireDate |
| `contacts` | 联系人 | userId, phoneNumber, firstName, username |
| `users` | 用户信息 | userId, username, statusJson, profilePhoto |
| `chat_filters` | 聊天文件夹 | filterId, title, pinnedChatIdsJson |
| `chat_boosts` | 聊天提升 | boostId, chatId, userId, expires |
| `bot_commands` | 机器人命令 | botUserId, command, description |
| `reactions` | 表情反应 | messageId, chatId, emoji, userId |
| `chat_positions` | 聊天排序位置 | chatId, listId, order |
| `secret_chats` | 秘密聊天 | chatId, key, state |
| `poll_options` | 投票选项 | pollId, text, voterCount |
| `messages_fts` | 全文搜索（FTS） | content（虚拟表） |
| `recycle_bin` | 回收站 | itemId, itemType, originalDataJson |
| + 10 张扩展表 | 贴纸/礼物/商业/统计等 | 见源码 |

**性能优化 PRAGMA 配置**：

```sql
PRAGMA journal_mode=WAL;         -- WAL 模式（读写不互斥）
PRAGMA synchronous=NORMAL;       -- 平衡性能与安全
PRAGMA cache_size=-10240;        -- 10MB 缓存
PRAGMA mmap_size=268435456;      -- 256MB 内存映射
PRAGMA busy_timeout=3000;        -- 3秒等待超时
```

**索引优化**：为消息表、聊天表、媒体表等关键表建立了复合索引（如 `idx_message_chatId_date` 加速按聊天+时间查询）。

#### Layer 4 — 磁盘 LRU 文件缓存 (`DiskLruCacheManager.ets`)

```
缓存目录: {context.cacheDir}/storage_cache/
内存 + 磁盘双 LRU: 内存索引(100项) + 文件存储
```

- 支持 **TTL 过期**：`setBinaryWithTTL(key, data, ttlMs)` 自动清理过期数据
- 同步 API：`setBinarySync` / `getBinarySync`，适合小文件快速读写
- 文件名使用 `encodeURIComponent(key)` 编码，避免路径冲突

#### 图片缓存层 (`ImageKnifeManager.ets`)

- 基于 `@ohos/imageknife` v2.2.0 封装
- 提供 `loadImage(url)` 返回 `PixelMap`，支持内存+磁盘两级缓存
- `preloadImage(url)` 预加载，`clearMemoryCache()` 清理

### 6.4 数据实体定义 (`TelegramEntity.ets`)

定义了 25 个数据实体类，以 `MessageEntity` 为例：

```typescript
export class MessageEntity {
  id: number = 0;               // 自增主键
  messageId: number = 0;        // TDLib 消息ID
  chatId: number = 0;           // 所属聊天ID
  contentType: string = '';     // 消息类型（messageText, messagePhoto...）
  contentJson: string = '';     // 消息内容JSON
  flags: number = 0;            // 位掩码（isOutgoing, isRead, isEdited, isPinned）
  
  // 位运算属性
  get isOutgoing(): boolean { return (this.flags & 1) !== 0; }
  get isRead(): boolean     { return (this.flags & 2) !== 0; }
  get isEdited(): boolean   { return (this.flags & 4) !== 0; }
}
```

### 6.5 批量写入优化

```typescript
// 延迟批量保存机制（100ms 窗口）
private messageBatchBuffer: MessageEntity[] = [];
private readonly BATCH_DELAY: number = 100; // 100ms 延迟

saveMessageDeferred(chatId, message) → push buffer → setTimeout flush
```

- 高频写入场景（如接收大量消息）时，消息先入缓冲区
- 100ms 窗口内累积批量写入，减少 I/O 次数
- `flushMessageBatch()` 支持手动立即刷新

### 6.6 加密能力 (`CryptoHelper.ets`)

| 算法 | 模式 | 用途 |
|------|------|------|
| AES-256 | GCM + PKCS7 | 敏感数据加密存储（Token、密码等） |
| 随机 IV | 12 字节随机数 | 每次加密使用不同 IV |
| 认证标签 | 16 字节 GCM Tag | 完整性校验，防篡改 |
| Base64 | 输出编码 | 加密数据以 Base64 字符串传递 |

### 6.7 统一返回类型 (`Result.ets`)

```typescript
CacheResult<T>   // 泛型结果包装：success + data + errorCode + errorMessage
CacheError        // 自定义错误类型
ErrorCodes        // 错误码常量（DB: 1001-1004, FILE: 2001-2002, CRYPTO: 3001-3002）
```

### 6.8 数据流示例：消息持久化全链路

```
TDLib 收到消息更新
    ↓ EventBus
CoreService.onMessage()
    ↓
CacheStorage.saveMessageDeferred(chatId, messageData)
    ├── 构造 MessageEntity
    ├── 推入 messageBatchBuffer（100ms 批量窗口）
    ├── 写入 messageMemCache（内存 LRU）
    └── 定时器触发 → flushMessageBatch()
        └── DatabaseManager.insertMessagesBatchOptimized()
            └── SQLite WAL 模式写入
```

---

## entry 模块深度解析

`entry` 是应用的唯一动态能力模块（HAP），承载所有 UI 页面、业务逻辑、TDLib 集成、原生 NAPI 绑定层。以下从 7 个维度展开分析。

### 7.1 C++ 原生层 — TDLib 集成与 NAPI 绑定

#### 构建架构 (CMakeLists.txt)

```
libhome.so (最终产物)
├── napi_init.cpp           # NAPI 入口 + 4个核心导出函数
├── tdlib/api/TDLibApi.cpp  # 500+ TDLib API 方法封装
├── tdlib/core/
│   ├── TDLibCore.cpp       # 单例核心（管理 TDLib::Client 生命周期）
│   ├── TDLibClient.cpp     # TDLib::Client 封装
│   └── StateMonitor.cpp    # 状态监控
└── tdlib/napi/NAPIBinder.cpp # 500+ NAPI 绑定函数
    ↓ 链接
libtdjson.so（TDLib 预编译原生核心库）
libace_napi.z.so（HarmonyOS NAPI 运行时）
libhilog_ndk.z.so（HarmonyOS NDK 日志）
```

**ABI 兼容性搜索**：CMakeLists 智能检测 `libtdjson.so` / `libtdjson.so.1.8.0` / `libtdjson.so.1.8.65` 等多种命名。

#### NAPI 导出接口（4 个核心函数）

```cpp
// napi_init.cpp
napi_value TDLibCreateClientId(env, info);   // 创建 TDLib 客户端，返回 clientId
napi_value TDLibSendById(env, info);          // 异步发送 JSON 请求到指定客户端
napi_value TDLibReceiveGlobal(env, info);     // 阻塞接收任意客户端的响应/更新
napi_value TDLibExecuteGlobal(env, info);     // 同步执行一条请求（无需等待接收）
```

#### 500+ API 绑定

`NAPIBinder.cpp` 为每个 TDLib API 方法生成 NAPI 绑定函数，统一签名：

```cpp
// 所有函数统一签名：(clientId: number, paramsJson: string) => void
napi_value NAPI_getAuthorizationState(env, info);
napi_value NAPI_setTdlibParameters(env, info);
napi_value NAPI_getMe(env, info);
napi_value NAPI_sendMessage(env, info);
// ... 500+ 函数
```

绑定函数在 `registerAllBindings()` 中注册到 `napi_env` 的 `exports` 对象。

#### C++ API 封装层 (`TDLibApi.cpp`)

对 TDLib 的 C++ 原生 API 进行封装，提供与 libtdjson 接口对应的函数：

```cpp
namespace tdlib::api {
void getAuthorizationState(clientId, paramsJson);  // 调用 TDLib::Client::send
void setTdlibParameters(clientId, paramsJson);
void getMe(clientId, paramsJson);
// ... 500+ 方法
}
```

### 7.2 Worker 线程架构

```
┌────────────────────────────────────────────┐
│           UI Main Thread                    │
│  TDLibClient (proxy)                       │
│    ├── send(request) → Worker              │
│    ├── call(method, params) → Promise<T>   │
│    └── execute(method, params) → sync      │
│         ↑ Promise <-------- RESPONSE ----- │
│         ↑ EventBus  <----- UPDATE ---------│
├────────────────────────────────────────────┤
│           Worker Thread                    │
│  TdlibWorker.ets                           │
│    ├── tdlibReceiveGlobal(10s)  ← 阻塞轮询 │
│    ├── 批量更新队列 (50ms 窗口)            │
│    └── 类型转换: _ → @type                 │
│         ↓ postMessage                      │
│  TDLib NAPI (libhome.so)                   │
│    ├── tdlibSendById()                     │
│    ├── tdlibReceiveGlobal()                │
│    └── tdlibExecuteGlobal()                │
│         ↓                                  │
│  TDLib C++ Core (libtdjson.so)            │
└────────────────────────────────────────────┘
```

#### 通信协议 (`TdlibWorkerProtocol.ets`)

```typescript
// 6 种消息类型
MessageType.REQUEST       // UI → Worker: 异步请求
MessageType.RESPONSE      // Worker → UI: 请求响应
MessageType.UPDATE        // Worker → UI: TDLib 更新
MessageType.CONTROL       // 双向: 控制命令
MessageType.BATCH_UPDATE  // Worker → UI: 批量更新
MessageType.EXECUTE_RESULT // Worker → UI: 同步执行结果

// 5 种控制命令
ControlCommand.INIT       // 初始化 TDLib 参数
ControlCommand.DESTROY    // 销毁客户端
ControlCommand.HEARTBEAT  // 心跳检测
ControlCommand.READY      // 就绪通知
ControlCommand.CONFIG     // 配置更新
```

#### 批量更新优化 (`TdlibWorker.ets`)

```typescript
const BATCH_DELAY_MS = 50;       // 50ms 延迟窗口
const MAX_BATCH_SIZE = 200;      // 内存保护上限
const BATCHED_UPDATE_TYPES = [   // 高频事件类型
  'updateChatAction',
  'updateUserStatus',
  'updateChatLastMessage',
  'updateChatReadInbox',
  'updateChatReadOutbox',
];
```

高频更新事件在 Worker 线程中先进入批处理队列（50ms 窗口），批量发送到 UI 线程，减少线程间通信次数。

### 7.3 业务服务层

业务服务层以 `CoreService` 为核心，分层协作：

```
AppStateManager (启动状态机)
  ├── ThemeService      → 初始化主题（最先执行）
  ├── CoreService       → 核心业务引擎 (单例)
  │     └── UpdateService    → 订阅 TDLib 更新并分发
  ├── AuthService       → 认证流程
  ├── FileDownloadService → 文件下载
  ├── CacheService      → 缓存协调（委托 storage_cache）
  ├── NotificationService → 本地通知
  └── PushService       → 华为推送
```

#### CoreService — 核心业务引擎

作为**唯一可信数据源**（Single Source of Truth），维护：

| 数据 | 类型 | 容量 |
|------|------|------|
| `chatList` | `Chat[]` | 全部聊天 |
| `messagesMap` | `Map<number, Message[]>` | 按 chatId 索引的消息 |
| `userCache` | `Map<number, UserInfo>` | 用户信息 |

**消息处理队列**（Nagram 风格）：

```typescript
class MessageQueueTask {
  type: 'load' | 'append' | 'delete' | 'replace';
  chatId: number;
  execute: () => Promise<void>;
}

// 批量刷新机制（50ms 延迟窗口，累积更新掩码）
private pendingUpdateMask: number = 0;
private batchFlushTimer: number = -1;
```

**UpdateService** 订阅 60+ 种 TDLib 原始更新事件，包括：
- 消息事件（newMessage, sendSucceeded, sendFailed, edited, deleted, views, etc.）
- 聊天事件（newChat, lastMessage, position, readInbox, title, photo, permissions, etc.）
- 用户事件（user, userFullInfo, userStatus, etc.）
- 群组事件（basicGroup, supergroup, etc.）
- 文件事件（file, fileAdded, etc.）
- 连接事件（connectionState, etc.）

#### AppStateManager — 启动状态机

```
INIT → THEME_READY → AUTH_CHECKED → TD_LIB_READY → DATA_SYNCED
  ↓                                                      |
  └──────────────── ERROR ←──────────────────────────────┘
```

#### AuthService — 认证流程

集成多种认证方式：
- 手机号验证码登录
- Bot Token 登录
- QR Code 扫描登录
- 生物识别（指纹/面部）
- Email 验证码
- 密码恢复

### 7.4 UI 层

#### 页面路由

10 个页面通过 `main_pages.json` 注册，使用 HarmonyOS 页面路由机制：

```json
{
  "src": [
    "pages/Index",          // 启动页（状态分发）
    "pages/MainTabContainer", // 主 Tab 容器
    "pages/LoginPage",      // 登录页
    "pages/BotTokenPage",   // Bot Token 登录
    "pages/WelcomePage",    // 欢迎页
    "pages/ChatListPage",   // 聊天列表
    "pages/ChatPage",       // 会话页
    "pages/ContactListPage", // 联系人页
    "pages/ProfilePage",    // 个人资料
    "pages/SettingsPage"    // 设置页
  ]
}
```

#### ViewModel 层

5 个 ViewModel，采用 MVVM 模式，职责清晰：

| ViewModel | 核心功能 |
|-----------|----------|
| `ChatListViewModel` | 聊天列表数据源（`IDataSource` 供 `LazyForEach`）、去重、分组分隔线 |
| `ChatPageViewModel` | 会话消息管理、加载历史 |
| `ContactListViewModel` | 联系人搜索、排序、国际化 |
| `ProfilePageViewModel` | 个人资料展示与编辑 |
| `SettingsViewModel` | 设置项管理与持久化 |

#### 数据源关键设计

```typescript
// ChatListDataSource 实现 IDataSource 接口
export class ChatListDataSource implements IDataSource {
  updateData(newData: ChatItemDisplay[]): void {
    // 1. 使用 Map<id, Item> 去重
    // 2. 检查是否有置顶/非置顶聊天 → 插入分割线
    // 3. 通知 LazyForEach 增量更新
  }
}
```

### 7.5 Worker 通信链路时序

```
EntryAbility.onCreate()
  ↓
AppStateManager.initialize()
  ├── ThemeService.init()          → THEME_READY
  ├── TDLibClient.initialize()     → 创建 Worker 线程
  │     └── worker.postMessage({ type: 'init', parameters })
  │           └── Worker 内: tdlibCreateClientId()
  │                          tdlibSendById(setTdlibParameters)
  │                          tdlibReceiveGlobal(10s) → 轮询开始
  ├── TDLibClient.onmessage → READY → TD_LIB_READY
  ├── CoreService.init()           → 注册更新监听
  └── AuthService.restoreSession() → AUTH_CHECKED
       ↓
Index.aboutToAppear()
  ├── 权限申请 → handleStateTransition()
  └── NavigationHelper.navigateTo(LoginPage | ChatListPage)
```

### 7.6 网络层

| 模块 | 功能 |
|------|------|
| `ConnectionManager.ets` | 连接状态管理（已连接/重连中/断开） |
| `ConnectionState.ets` | 连接状态枚举与状态机 |
| `RequestQueueManager.ets` | 请求队列（优先级、重试、去重） |
| `NetworkMonitorService.ets` | 网络状态监听（WiFi/蜂窝/断开） |
| `MTProtoProxyService.ets` | MTProto 代理 |
| `Socks5ProxyService.ets` | SOCKS5 代理 |

#### 网络请求队列

```typescript
// RequestQueueManager — 高/中/低 三级优先级队列
// 支持自动重试（最多3次）、指数退避、请求去重
```

### 7.7 关键调用栈示例

**发送消息完整链路**：

```
用户点击发送 → ChatPage
  → ChatPageViewModel.sendMessage(text)
    → CoreService.sendTextMessage(chatId, text)
      → TDLibApi.sendMessage(params)
        → TDLibClient.call('sendMessage', params)
          → Worker: tdlibSendById(clientId, jsonRequest)
            → C++: NAPI_TDLibSendById()
              → TDLibCore.send(clientId, request)
                → TdClient::send(request)
                   ↓
TDLib 服务器处理 → 返回 updateNewMessage
  → Worker: tdlibReceiveGlobal() 收到
    → Worker: 构造 UPDATE 消息 postMessage()
      → TDLibClient.handleWorkerMessage()
        → EventBus.emit('updateNewMessage', data)
          → UpdateService.onUpdateNewMessage()
            → CoreService.onMessageReceived()
              → 更新 messageMap + 发布业务事件
                → ChatPageViewModel.onMessageUpdate()
                  → UI 自动刷新 (@State / LazyForEach)
```

---

## 模块目录说明

### pages/ — 页面层（10 个路由页面）

| 文件 | 功能 |
|------|------|
| `Index.ets` | 应用首页，启动逻辑分发 |
| `MainTabContainer.ets` | 主 Tab 容器（聊天、联系人、设置） |
| `LoginPage.ets` | 手机号登录 |
| `BotTokenPage.ets` | Bot Token 登录 |
| `WelcomePage.ets` | 欢迎引导页 |
| `ChatListPage.ets` | 聊天列表（LazyForEach） |
| `ChatPage.ets` | 单聊/群聊会话 |
| `ContactListPage.ets` | 联系人列表 |
| `ProfilePage.ets` | 用户个人资料 |
| `SettingsPage.ets` | 应用设置 |

### viewmodels/ — ViewModel 层

| 文件 | 职责 |
|------|------|
| `ChatListViewModel.ets` | 聊天列表数据源（去重、分组、排序） |
| `ChatPageViewModel.ets` | 会话页面消息管理 |
| `ContactListViewModel.ets` | 联系人搜索与管理 |
| `ProfilePageViewModel.ets` | 个人资料展示与编辑 |
| `SettingsViewModel.ets` | 设置项管理与持久化 |

### services/ — 服务层

| 类型 | 文件 | 功能 |
|------|------|------|
| API | `TDLibApi.ets` | TDLib 500+ API 的展开参数封装 |
| API | `TdApiFactory.ets` | TDLib 请求对象工厂 |
| Business | `CoreService.ets` | 核心业务：聊天列表、消息、用户（单例数据源） |
| Business | `AuthService.ets` | 认证流程管理 |
| Business | `CacheService.ets` | 缓存服务协调 |
| Business | `FileDownloadService.ets` | 文件下载队列 |
| Business | `NotificationService.ets` | 本地通知 |
| Core | `TDLibClient.ets` | Worker 通信封装、心跳、自动重连 |
| Core | `TDLibAuthManager.ets` | 授权状态机 |
| Network | `RequestQueueManager.ets` | 请求队列管理 |
| Network | `NetworkMonitorService.ets` | 网络状态监听 |
| System | `PushService.ets` | 华为 Push Kit 集成 |

### utils/ — 工具库分类

| 分类 | 文件 | 用途 |
|------|------|------|
| 网络 | `HttpClient.ets`、`WebSocketManager.ets` | HTTP 与 WebSocket |
| 存储 | `Preference.ets`、`CacheManager.ets`、`SecureStorage.ets` | 偏好设置、缓存、安全存储 |
| 安全 | `CryptoHelper.ets`、`KeyStoreManager.ets` | 加密、密钥管理 |
| 性能 | `PerformanceMonitor.ets`、`MemoryMonitor.ets` | 性能 & 内存监控 |
| 国际化 | `I18n.ets`、`ResourceHelper.ets` | 多语言支持 |
| 格式化 | `DateFormatter.ets`、`FileSizeFormatter.ets`、`TimeFormatter.ets` | 数据格式化 |
| 日志 | `LogService.ets` | 统一日志系统 |
| 事件 | `EventBus.ets` | 全局事件总线 |

---

## 数据流

```text
用户操作 → UI (Page)
           ↓ 交互
          ViewModel
           ↓ 业务调用
          CoreService
           ↓ TDLibApi
          TDLibClient (Worker 线程)
           ↓ tdlibSendById
libhome.so (NAPI)
           ↓ TDLib C++
          TDLib 服务器
           ↓ tdlibReceiveGlobal
libhome.so ←─ 响应/更新
           ↓
TDLibClient
           ↓ postMessage
TdlibWorker
           ↓ EventBus.emit
CoreService (消息队列 + 50ms 批量刷新)
           ↓
ViewModel
           ↓
UI 渲染 (LazyForEach 增量更新)
```

### 关键设计

- **批量刷新 (Batch Flush)**：借鉴 Nagram 的 `processUpdateArray` 机制，采用 50ms 延迟窗口累积更新掩码，避免逐条通知导致 UI 多次重绘
- **消息队列**：CoreService 中维护 `MessageQueueTask` 队列，串行处理加载、追加、删除、替换操作
- **去重机制**：`ChatListDataSource.updateData` 使用 `Map` 进行 ID 去重，确保列表唯一性

---

## 主题与 UI 组件

### 主题系统

三套主题，支持运行时切换：

```text
ThemeManager (单例)
├── LightTheme     — 浅色主题
├── DarkTheme      — 深色主题
└── SystemTheme    — 跟随系统
```

主题定义在 `AppTheme.ts`（颜色 Token 体系），通过 `addThemeListener` 订阅变更。

### 核心 UI 组件

| 组件 | 用途 |
|------|------|
| `Avatar.ets` | 用户头像（彩色圆形兜底） |
| `ChatListItem.ets` | 聊天列表项 |
| `Badge.ets` | 未读角标 |
| `ImmersiveContainer.ets` | 沉浸式容器 |
| `MainTopBar.ets` | 顶部导航栏 |
| `MenuItem.ets` | 菜单项 |
| `PhoneInputComponent.ets` | 手机号输入 |

---

## 权限说明

```json
ohos.permission.INTERNET                        网络访问
ohos.permission.CAMERA                          相机（扫码/拍照）
ohos.permission.MICROPHONE                      麦克风（语音/通话）
ohos.permission.READ_IMAGEVIDEO                 读取图片视频
ohos.permission.SHORT_TERM_WRITE_IMAGEVIDEO     写入图片视频
```

---

## 构建配置

```
SDK 版本:  target 6.1.1(24) | compatible 6.1.0(23)
编译工具:  Hvigor + BiSheng 编译器
ABI:       arm64-v8a, x86_64
混淆:      release 模式启用 (obfuscation-rules.txt)
Worker:    TdlibWorker.ets (独立消息循环线程)
原生编译:  CMakeLists.txt → libtdjson.so + libhome.so (NAPI)
```

---

## 安装调试

**小白调试助手（推荐）**

下载链接：[Auto-Installer](https://github.com/likuai2010/auto-installer/releases/latest)

- [下载教程文档](https://github.com/Zitann/HarmonyOS-Haps/raw/refs/heads/main/assets/guide.pdf)
- [视频教程](https://www.bilibili.com/video/BV1hkZ7YnEMd/)

**手动构建**

```bash
# DevEco Studio 中打开项目根目录
# 配置 signingConfigs（debug / release）
# 选择设备类型（phone / tablet / 2in1）
# Build → Build HAP(s)
```

---

## 开发指引

### ArkTS 语法约束

本项目遵循 ArkTS 严格语法限制，关键注意点：

- 使用 `@ComponentV2` 代替 `@Component`，`@Param` 代替 `@Prop`（大括号初始化）
- 不支持 `any`、`unknown` 类型，需显式声明
- 不支持解构赋值、`for..in` 遍历对象
- 不支持 `Function.apply/call/bind`
- 不支持 `Symbol`（除 `Symbol.iterator`）
- 不支持 `as const` 断言

详见 [ArkTS 语法规则](./code-linter.json5) 及项目配置中的 `user_rules`。

### 新增页面步骤

1. 在 `pages/` 下创建 `.ets` 文件，添加 `@Entry` 装饰器
2. 在 `main_pages.json` 中注册路由
3. 在 `viewmodels/` 添加对应的 ViewModel
4. 通过 `EventBus` 订阅 CoreService 的业务事件

### 新增第三方库

1. 在对应模块的 `oh-package.json5` 中添加依赖
2. 在 `oh-package-lock.json5` 中确认版本解析
3. 如需原生库，在 `entry/oh-package.json5` 中声明 `"libxxx.so": "file:./src/main/cpp/types/libxxx"`

---

## 反馈

如果您在使用过程中遇到问题，或有改进建议，欢迎提交 Issue。

- GitHub Issues：https://github.com/Zitann/HarmonyOS-Haps/issues
- Telegram：https://t.me/HMTGchannel 、 https://t.me/HMTGchat
- QQ 群：1075753335

---

## 鸣谢

按 ASCII 排序：

- [Gramony-dev](https://github.com/Gramony-dev) — 参考项目
- [Nagram](https://github.com/Nagram) — 参考项目（消息队列 & 批量刷新实现灵感）

### Star History

[暂无]
