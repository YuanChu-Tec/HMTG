/*
 * Copyright (c) 2026 HMTG Project
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use NavigationHelper file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * HMTG导航组件库
 * 提供统一的导航能力，基于HarmonyOS Navigation组件
 */

import { router } from '@kit.ArkUI';

const TAG = 'NavigationHelper';

/**
 * 导航参数接口
 */
export type NavParams = Record<string, Object>;

/**
 * 导航选项接口
 */
export interface NavOptions {
  /**
   * 是否清除历史栈
   */
  clearStack?: boolean;

  /**
   * 页面转换动画
   */
  animated?: boolean;

  /**
   * 参数
   */
  params?: NavParams;
}

/**
 * 导航助手类
 * 封装router API，提供统一的导航方法
 */
/**
 * Router状态接口
 */
interface RouterState {
  name: string;
  params: Map<string, Object>;
  current?: string;
}

/**
 * 路由选项接口
 */
interface RouterOptions {
  animated?: boolean;
}


export class NavigationHelper {
  /**
   * 导航到指定页面（默认push）
   */
  public static navigateTo(url: string, options?: NavOptions): Promise<void> {
    try {
      if (options?.clearStack) {
        return router.replaceUrl({
          url,
          params: options?.params
        });
      } else {
        return router.pushUrl({
          url,
          params: options?.params
        });
      }
    } catch (error) {
      console.error(`${TAG}: Navigation failed to ${url}`, error);
      throw new Error(String(error));
    }
  }

  /**
   * 替换当前页面
   */
  public static replacePage(url: string, params?: NavParams): Promise<void> {
    return NavigationHelper.navigateTo(url, {
      clearStack: true,
      params
    });
  }

  /**
   * 返回上一页
   */
  public static goBack(): void {
    try {
      router.back();
    } catch (error) {
      console.error(`${TAG}: Back navigation failed`, error);
    }
  }

  /**
   * 返回到指定层级
   */
  public static goBackTo(delta: number = 1): void {
    try {
      router.back(delta);
    } catch (error) {
      console.error(`${TAG}: Back navigation with delta ${delta} failed`, error);
    }
  }

  /**
   * 返回到根页面
   */
  public static goBackToRoot(): void {
    try {
      router.clear();
    } catch (error) {
      console.error(`${TAG}: Clear navigation failed`, error);
    }
  }

  /**
   * 关闭当前页面（适用于模态页面）
   */
  public static closePage(): void {
    goBack();
  }

  /**
   * 检查是否可以返回
   */
  public static canGoBack(): boolean {
    try {
      const state = router.getState();
      return state.index > 0;
    } catch {
      return false;
    }
  }

  /**
   * 获取当前路由信息
   */
  public static getCurrentRoute(): string | undefined {
    try {
      const state = router.getState();
      return state?.name;
    } catch {
      return undefined;
    }
  }

  /**
   * 获取路由历史深度
   */
  public static getRouteDepth(): number {
    try {
      const state = router.getState();
      return state?.index || 0;
    } catch {
      return 0;
    }
  }
}

/**
 * 导航路径常量
 * 集中管理所有路由路径，便于统一修改
 */
export class RoutePaths {
  // ============ Entry模块 ============
  /** 入口页 */
  public static readonly INDEX = 'pages/Index';

  /** 启动页 */
  public static readonly SPLASH = 'pages/SplashPage';

  /** 主页（使用自适应容器） */
  public static readonly MAIN = 'pages/MainTabContainer';

  // ============ Auth认证模块 ============
  /** 欢迎页 */
  public static readonly AUTH_WELCOME = 'pages/auth/WelcomePage';

  /** 手机号输入页 */
  public static readonly AUTH_PHONE_INPUT = 'pages/auth/AuthPhonePage';

  /** 验证码输入页 */
  public static readonly AUTH_CODE_VERIFICATION = 'pages/auth/AuthCodePage';

  /** 密码输入页（两步验证） */
  public static readonly AUTH_PASSWORD_INPUT = 'pages/auth/AuthPasswordPage';

  /** 二维码登录页 */
  public static readonly AUTH_QR_CODE = 'pages/auth/AuthQrCodePage';

  /** Bot Token登录页 */
  public static readonly AUTH_BOT_TOKEN = 'pages/auth/AuthBotTokenPage';

  /** 注册页 */
  public static readonly AUTH_SIGN_UP = 'pages/auth/AuthRegisterPage';

  /** 密码解锁页 */
  public static readonly AUTH_PASSCODE_UNLOCK = 'pages/auth/PasscodeUnlockPage';

  // ============ Chat聊天模块 ============
  /** 聊天列表页 */
  public static readonly CHAT_LIST = 'pages/chat/ChatListPage';

  /** 通用聊天详情页（支持私聊/群组/频道/Bot） */
  public static readonly CHAT_DETAIL = 'pages/common/ChatPage';

  /** 聊天信息页 */
  public static readonly CHAT_INFO = 'pages/chat/ChatInfoPage';

  /** 消息搜索页 */
  public static readonly MESSAGE_SEARCH = 'pages/chat/MessageSearchPage';

  /** 共享媒体页 */
  public static readonly SHARED_MEDIA = 'pages/chat/SharedMediaPage';

  /** 置顶消息页 */
  public static readonly PINNED_MESSAGES = 'pages/chat/PinnedMessagesPage';

  /** 秘密聊天详情页 */
  public static readonly SECRET_CHAT_DETAIL = 'pages/chat/SecretChatDetailPage';

  // ============ Contacts联系人模块 ============
  /** 联系人列表页 */
  public static readonly CONTACTS_LIST = 'pages/contacts/ContactListPage';

  /** 联系人详情页 */
  public static readonly CONTACT_DETAIL = 'pages/contacts/ContactDetailPage';

  /** 新建联系人页 */
  public static readonly CONTACT_NEW = 'pages/contacts/NewContactPage';

  /** 编辑联系人页 */
  public static readonly CONTACT_EDIT = 'pages/contacts/EditContactPage';

  /** 联系人搜索页 */
  public static readonly CONTACT_SEARCH = 'pages/contacts/ContactSearchPage';

  /** 导入联系人页 */
  public static readonly CONTACT_IMPORT = 'pages/contacts/ImportContactsPage';

  /** 邀请好友页 */
  public static readonly CONTACT_INVITE = 'pages/contacts/InviteFriendsPage';

  /** 封禁用户页 */
  public static readonly BLOCKED_USERS = 'pages/contacts/BlockedUsersPage';

  /** 共同群组页 */
  public static readonly MUTUAL_GROUPS = 'pages/contacts/MutualGroupsPage';

  // ============ Groups群组模块 ============
  /** 群组信息页 */
  public static readonly GROUP_INFO = 'pages/groups/GroupInfoPage';

  /** 群组成员页 */
  public static readonly GROUP_MEMBERS = 'pages/groups/GroupMembersPage';

  /** 群组设置页 */
  public static readonly GROUP_SETTINGS = 'pages/groups/GroupSettingsPage';

  /** 创建群组页 */
  public static readonly CREATE_GROUP = 'pages/groups/CreateGroupPage';

  /** 管理员工具页 */
  public static readonly ADMIN_TOOLS = 'pages/groups/AdminToolsPage';

  /** 群组权限页 */
  public static readonly GROUP_PERMISSIONS = 'pages/groups/GroupPermissionsPage';

  /** 群组统计页 */
  public static readonly GROUP_STATS = 'pages/groups/GroupStatsPage';

  /** 邀请链接页 */
  public static readonly INVITE_LINKS = 'pages/groups/InviteLinksPage';

  /** 添加成员页 */
  public static readonly ADD_MEMBERS = 'pages/groups/AddMembersPage';

  // ============ Channels频道模块 ============
  /** 频道信息页 */
  public static readonly CHANNEL_INFO = 'pages/channels/ChannelInfoPage';

  /** 频道列表页 */
  public static readonly CHANNEL_LIST = 'pages/channels/ChannelListPage';

  /** 频道设置页 */
  public static readonly CHANNEL_SETTINGS = 'pages/channels/ChannelSettingsPage';

  /** 频道管理员页 */
  public static readonly CHANNEL_ADMINS = 'pages/channels/ChannelAdminsPage';

  /** 频道邀请页 */
  public static readonly CHANNEL_INVITES = 'pages/channels/ChannelInvitesPage';

  /** 频道搜索页 */
  public static readonly CHANNEL_SEARCH = 'pages/channels/ChannelSearchPage';

  /** 频道统计页 */
  public static readonly CHANNEL_STATS = 'pages/channels/ChannelStatsPage';

  /** 创建频道页 */
  public static readonly CREATE_CHANNEL = 'pages/channels/CreateChannelPage';

  /** 编辑帖子页 */
  public static readonly EDIT_POST = 'pages/channels/EditPostPage';

  /** 加入请求页 */
  public static readonly JOIN_REQUESTS = 'pages/channels/JoinRequestsPage';

  // ============ Media媒体模块 ============
  /** 媒体库页 */
  public static readonly MEDIA_GALLERY = 'pages/media/MediaGalleryPage';

  /** 媒体查看页 */
  public static readonly MEDIA_VIEWER = 'pages/media/MediaViewerPage';

  /** 媒体选择页 */
  public static readonly MEDIA_PICKER = 'pages/media/MediaPickerPage';

  /** 图片编辑页 */
  public static readonly IMAGE_EDITOR = 'pages/media/ImageEditorPage';

  /** 视频播放页 */
  public static readonly VIDEO_PLAYER = 'pages/media/VideoPlayerPage';

  // ============ Call通话模块 ============
  /** 通话历史页 */
  public static readonly CALL_HISTORY = 'pages/call/CallHistoryPage';

  /** 活跃通话页 */
  public static readonly ACTIVE_CALL = 'pages/call/ActiveCallPage';

  /** 通话参与者页 */
  public static readonly CALL_PARTICIPANTS = 'pages/call/CallParticipantsPage';

  /** 通话设置页 */
  public static readonly CALL_SETTINGS = 'pages/call/CallSettingsPage';

  /** 群组通话页 */
  public static readonly GROUP_CALL = 'pages/call/GroupCallPage';

  /** 来电页 */
  public static readonly INCOMING_CALL = 'pages/call/IncomingCallPage';

  /** 去电页 */
  public static readonly OUTGOING_CALL = 'pages/call/OutgoingCallPage';

  // ============ Bots机器人模块 ============
  /** 机器人聊天页（使用通用 ChatPage） */
  public static readonly BOT_CHAT = 'pages/common/ChatPage';

  /** 机器人命令页 */
  public static readonly BOT_COMMANDS = 'pages/bots/BotCommandsPage';

  /** 机器人游戏页 */
  public static readonly BOT_GAMES = 'pages/bots/BotGamesPage';

  // ============ Monetization变现模块 ============
  /** 变现阶段 */
  public static readonly MONETIZATION = 'pages/monetization/MonetizationPage';

  /** Premium会员页 */
  public static readonly PREMIUM = 'pages/monetization/PremiumPage';

  /** 收益页 */
  public static readonly REVENUE = 'pages/monetization/RevenuePage';

  /** Stars商店页 */
  public static readonly STARS_SHOP = 'pages/monetization/StarsShopPage';

  /** Stars交易页 */
  public static readonly STARS_TRANSACTION = 'pages/monetization/StarsTransactionPage';

  /** 提现页 */
  public static readonly WITHDRAWAL = 'pages/monetization/WithdrawalPage';

  /** 广告设置页 */
  public static readonly ADS_SETTINGS = 'pages/monetization/AdsSettingsPage';

  // ============ Privacy隐私模块 ============
  /** 隐私设置页 */
  public static readonly PRIVACY_SETTINGS = 'pages/privacy/PrivacySettingsPage';

  /** 安全设置页 */
  public static readonly SECURITY_SETTINGS = 'pages/privacy/SecuritySettingsPage';

  /** 同意管理页 */
  public static readonly CONSENT_MANAGEMENT = 'pages/privacy/ConsentManagementPage';

  /** 数据管理页 */
  public static readonly DATA_MANAGEMENT = 'pages/privacy/DataManagementPage';

  /** 数据导出页 */
  public static readonly DATA_EXPORT = 'pages/privacy/DataExportPage';

  /** 数据详情页 */
  public static readonly DATA_DETAIL = 'pages/privacy/DataDetailPage';

  /** 数据保护页 */
  public static readonly DATA_PROTECTION = 'pages/privacy/DataProtectionPage';

  /** 隐私政策页 */
  public static readonly PRIVACY_POLICY = 'pages/privacy/PrivacyPolicyPage';

  // ============ Settings设置模块 ============
  /** 设置主页 */
  public static readonly SETTINGS_MAIN = 'pages/settings/SettingsPage';

  /** 通知设置页 */
  public static readonly SETTINGS_NOTIFICATION = 'pages/settings/NotificationSettingsPage';

  /** 隐私设置页(旧) */
  public static readonly SETTINGS_PRIVACY = 'pages/settings/PrivacySettingsPage';

  /** 安全设置页(旧) */
  public static readonly SETTINGS_SECURITY = 'pages/settings/SecuritySettingsPage';

  /** 聊天设置页 */
  public static readonly SETTINGS_CHAT = 'pages/settings/ChatSettingsPage';

  /** 外观设置页 */
  public static readonly SETTINGS_APPEARANCE = 'pages/settings/AppearanceSettingsPage';

  /** 存储设置页 */
  public static readonly SETTINGS_STORAGE = 'pages/settings/StorageSettingsPage';

  /** 高级设置页 */
  public static readonly SETTINGS_ADVANCED = 'pages/settings/AdvancedSettingsPage';

  /** 关于页 */
  public static readonly SETTINGS_ABOUT = 'pages/settings/AboutPage';

  /** 语言选择页 */
  public static readonly LANGUAGE_SELECT = 'pages/settings/LanguageSelectPage';

  /** 捐赠页 */
  public static readonly DONATE = 'pages/settings/DonatePage';

  // ============ Stickers贴纸模块 ============
  /** 我的贴纸页 */
  public static readonly MY_STICKERS = 'pages/stickers/MyStickersPage';

  /** 贴纸包页 */
  public static readonly STICKER_PACK = 'pages/stickers/StickerPackPage';

  /** 贴纸选择页 */
  public static readonly STICKER_PICKER = 'pages/stickers/StickerPickerPage';

  /** 贴纸商店页 */
  public static readonly STICKER_STORE = 'pages/stickers/StickerStorePage';

  // ============ Stories故事模块 ============
  /** 故事相机页 */
  public static readonly STORY_CAMERA = 'pages/stories/StoryCameraPage';

  /** 故事编辑器页 */
  public static readonly STORY_EDITOR = 'pages/stories/StoryEditorPage';

  /** 故事反应页 */
  public static readonly STORY_REACTIONS = 'pages/stories/StoryReactionsPage';

  /** 故事回复页 */
  public static readonly STORY_REPLIES = 'pages/stories/StoryRepliesPage';

  /** 故事设置页 */
  public static readonly STORY_SETTINGS = 'pages/stories/StorySettingsPage';

  /** 故事查看页 */
  public static readonly STORY_VIEWER = 'pages/stories/StoryViewerPage';
}

/**
 * 导航参数类型定义
 * 用于类型安全的参数传递
 */
export class RouteParams {
  /** 聊天ID参数 */
  public static readonly CHAT_ID = 'chatId';

  /** 用户ID参数 */
  public static readonly USER_ID = 'userId';

  /** 联系人ID参数 */
  public static readonly CONTACT_ID = 'contactId';

  /** 消息ID参数 */
  public static readonly MESSAGE_ID = 'messageId';

  /** 编辑模式参数 */
  public static readonly EDIT_MODE = 'editMode';

  /** 搜索关键词参数 */
  public static readonly SEARCH_KEYWORD = 'keyword';

  /** 媒体类型参数 */
  public static readonly MEDIA_TYPE = 'mediaType';
}

/**
 * 导航参数构建器
 * 提供便捷的参数构建方法
 */
export class RouteParamBuilder {
  /**
   * 构建参数对象
   */
  public static build(params: Record<string, Object>): NavParams {
    const result: NavParams = {};
    const keys = Object.keys(params);
    for (let i = 0; i < keys.length; i++) {
      result[keys[i]] = params[keys[i]];
    }
    return result;
  }

  /**
   * 构建单个参数对象
   */
  public static single(key: string, value: Object): NavParams {
    const result: NavParams = {};
    result[key] = value;
    return result;
  }

  /**
   * 构建聊天参数
   */
  public static chatParams(chatId: number, messageId?: number): NavParams {
    const result: NavParams = {};
    result['chatId'] = chatId;
    if (messageId !== undefined) {
      result['messageId'] = messageId;
    }
    return result;
  }

  /**
   * 构建用户参数
   */
  public static userParams(userId: number): NavParams {
    const result: NavParams = {};
    result['userId'] = userId;
    return result;
  }

  /**
   * 构建联系人参数
   */
  public static contactParams(contactId: number, editMode?: boolean): NavParams {
    const result: NavParams = {};
    result['contactId'] = contactId;
    if (editMode !== undefined) {
      result['editMode'] = editMode;
    }
    return result;
  }
}

/**
 * 导航工具函数
 * 提供函数式导航方法
 */
export const navigateTo = (url: string, options?: NavOptions): Promise<void> => {
  return NavigationHelper.navigateTo(url, options);
};

export const replacePage = (url: string, params?: Record<string, Object>): Promise<void> => {
  return NavigationHelper.replacePage(url, params as NavParams);
};

export const goBack = (): void => {
  NavigationHelper.goBack();
};

export const goBackToRoot = (): void => {
  NavigationHelper.goBackToRoot();
};

export const canGoBack = (): boolean => {
  return NavigationHelper.canGoBack();
};
