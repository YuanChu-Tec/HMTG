import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { StorageManager } from './StorageManager';

const DOMAIN = 0x0001;
const TAG = 'BadgeManager';

/**
 * 徽章数据接口
 */
export interface BadgeData {
  chatBadge: number;        // 聊天徽章数
  contactsBadge: number;    // 联系人徽章数
  settingsBadge: number;    // 设置徽章数
  profileBadge: number;     // 个人资料徽章数
  totalBadge: number;       // 总徽章数
  lastUpdateTime: number;   // 最后更新时间
}

/**
 * 徽章键名常量
 */
export const BadgeKeys: Readonly<BadgeKeysType> = {
  CHAT_BADGE: 'badge.chat',
  CONTACTS_BADGE: 'badge.contacts',
  SETTINGS_BADGE: 'badge.settings',
  PROFILE_BADGE: 'badge.profile',
  TOTAL_BADGE: 'badge.total',
  LAST_UPDATE: 'badge.lastUpdate'
};

/**
 * BadgeKeys类型接口
 */
interface BadgeKeysType {
  CHAT_BADGE: string;
  CONTACTS_BADGE: string;
  SETTINGS_BADGE: string;
  PROFILE_BADGE: string;
  TOTAL_BADGE: string;
  LAST_UPDATE: string;
}

/**
 * 徽章管理器
 * 负责徽章数据的持久化存储和管理
 */
export class BadgeManager {
  private static instance: BadgeManager;
  private context: common.UIAbilityContext | null = null;
  private storageName: string = 'badge_data';

  private constructor() {}

  /**
   * 获取单例
   */
  public static getInstance(): BadgeManager {
    if (!BadgeManager.instance) {
      BadgeManager.instance = new BadgeManager();
    }
    return BadgeManager.instance;
  }

  /**
   * 初始化
   */
  public async initialize(context: common.UIAbilityContext): Promise<void> {
    try {
      this.context = context;
      hilog.info(DOMAIN, TAG, 'BadgeManager initialized');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to initialize BadgeManager: ${JSON.stringify(error)}`);
      throw new Error(String(error));
    }
  }

  /**
   * 加载徽章数据
   */
  public async loadBadges(): Promise<BadgeData> {
    try {
      const storage = StorageManager.getInstance(this.storageName);
      await storage.initialize(this.context!);

      const chatBadgeValue: number = await storage.get<number>(BadgeKeys.CHAT_BADGE, 0) || 0;
      const contactsBadgeValue: number = await storage.get<number>(BadgeKeys.CONTACTS_BADGE, 0) || 0;
      const settingsBadgeValue: number = await storage.get<number>(BadgeKeys.SETTINGS_BADGE, 0) || 0;
      const profileBadgeValue: number = await storage.get<number>(BadgeKeys.PROFILE_BADGE, 0) || 0;
      const totalBadgeValue: number = await storage.get<number>(BadgeKeys.TOTAL_BADGE, 0) || 0;
      const lastUpdateTimeValue: number = await storage.get<number>(BadgeKeys.LAST_UPDATE, 0) || 0;

      const badgeData: BadgeData = {
        chatBadge: chatBadgeValue,
        contactsBadge: contactsBadgeValue,
        settingsBadge: settingsBadgeValue,
        profileBadge: profileBadgeValue,
        totalBadge: totalBadgeValue,
        lastUpdateTime: lastUpdateTimeValue
      };

      hilog.debug(DOMAIN, TAG, `Badges loaded: ${JSON.stringify(badgeData)}`);
      return badgeData;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to load badges: ${JSON.stringify(error)}`);
      // 返回默认徽章数据
      return this.getDefaultBadgeData();
    }
  }

  /**
   * 保存徽章数据
   */
  public async saveBadges(badgeData: Partial<BadgeData>): Promise<boolean> {
    try {
      const storage = StorageManager.getInstance(this.storageName);
      await storage.initialize(this.context!);

      // 只保存非undefined的值
      const saveData: Record<string, preferences.ValueType> = {};

      if (badgeData.chatBadge !== undefined) {
        saveData[BadgeKeys.CHAT_BADGE] = badgeData.chatBadge;
      }
      if (badgeData.contactsBadge !== undefined) {
        saveData[BadgeKeys.CONTACTS_BADGE] = badgeData.contactsBadge;
      }
      if (badgeData.settingsBadge !== undefined) {
        saveData[BadgeKeys.SETTINGS_BADGE] = badgeData.settingsBadge;
      }
      if (badgeData.profileBadge !== undefined) {
        saveData[BadgeKeys.PROFILE_BADGE] = badgeData.profileBadge;
      }

      const totalBadge =
        (badgeData.chatBadge ?? 0) +
        (badgeData.contactsBadge ?? 0) +
        (badgeData.settingsBadge ?? 0) +
        (badgeData.profileBadge ?? 0);
      saveData[BadgeKeys.TOTAL_BADGE] = totalBadge;
      saveData[BadgeKeys.LAST_UPDATE] = Date.now();

      // 逐个保存键值对
      const keys = Object.keys(saveData);
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        const value = saveData[key];
        if (value !== undefined) {
          await storage.put(key, value);
        }
      }

      hilog.debug(DOMAIN, TAG, `Badges saved: ${JSON.stringify(saveData)}`);
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to save badges: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * 增加聊天徽章
   */
  public async incrementChatBadge(delta: number = 1): Promise<number> {
    try {
      const currentBadges = await this.loadBadges();
      const newChatBadge = Math.max(0, currentBadges.chatBadge + delta);

      await this.saveBadges({ chatBadge: newChatBadge });

      hilog.debug(DOMAIN, TAG, `Chat badge incremented: ${currentBadges.chatBadge} -> ${newChatBadge}`);
      return newChatBadge;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to increment chat badge: ${JSON.stringify(error)}`);
      return 0;
    }
  }

  /**
   * 减少聊天徽章
   */
  public async decrementChatBadge(delta: number = 1): Promise<number> {
    try {
      const currentBadges = await this.loadBadges();
      const newChatBadge = Math.max(0, currentBadges.chatBadge - delta);

      await this.saveBadges({ chatBadge: newChatBadge });

      hilog.debug(DOMAIN, TAG, `Chat badge decremented: ${currentBadges.chatBadge} -> ${newChatBadge}`);
      return newChatBadge;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to decrement chat badge: ${JSON.stringify(error)}`);
      return 0;
    }
  }

  /**
   * 增加联系人徽章
   */
  public async incrementContactsBadge(delta: number = 1): Promise<number> {
    try {
      const currentBadges = await this.loadBadges();
      const newContactsBadge = Math.max(0, currentBadges.contactsBadge + delta);

      await this.saveBadges({ contactsBadge: newContactsBadge });

      hilog.debug(DOMAIN, TAG, `Contacts badge incremented: ${currentBadges.contactsBadge} -> ${newContactsBadge}`);
      return newContactsBadge;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to increment contacts badge: ${JSON.stringify(error)}`);
      return 0;
    }
  }

  /**
   * 增加设置徽章
   */
  public async incrementSettingsBadge(delta: number = 1): Promise<number> {
    try {
      const currentBadges = await this.loadBadges();
      const newSettingsBadge = Math.max(0, currentBadges.settingsBadge + delta);

      await this.saveBadges({ settingsBadge: newSettingsBadge });

      hilog.debug(DOMAIN, TAG, `Settings badge incremented: ${currentBadges.settingsBadge} -> ${newSettingsBadge}`);
      return newSettingsBadge;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to increment settings badge: ${JSON.stringify(error)}`);
      return 0;
    }
  }

  /**
   * 增加个人资料徽章
   */
  public async incrementProfileBadge(delta: number = 1): Promise<number> {
    try {
      const currentBadges = await this.loadBadges();
      const newProfileBadge = Math.max(0, currentBadges.profileBadge + delta);

      await this.saveBadges({ profileBadge: newProfileBadge });

      hilog.debug(DOMAIN, TAG, `Profile badge incremented: ${currentBadges.profileBadge} -> ${newProfileBadge}`);
      return newProfileBadge;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to increment profile badge: ${JSON.stringify(error)}`);
      return 0;
    }
  }

  /**
   * 清除聊天徽章
   */
  public async clearChatBadge(): Promise<void> {
    await this.saveBadges({ chatBadge: 0 });
    hilog.debug(DOMAIN, TAG, 'Chat badge cleared');
  }

  /**
   * 清除联系人徽章
   */
  public async clearContactsBadge(): Promise<void> {
    await this.saveBadges({ contactsBadge: 0 });
    hilog.debug(DOMAIN, TAG, 'Contacts badge cleared');
  }

  /**
   * 清除设置徽章
   */
  public async clearSettingsBadge(): Promise<void> {
    await this.saveBadges({ settingsBadge: 0 });
    hilog.debug(DOMAIN, TAG, 'Settings badge cleared');
  }

  /**
   * 清除个人资料徽章
   */
  public async clearProfileBadge(): Promise<void> {
    await this.saveBadges({ profileBadge: 0 });
    hilog.debug(DOMAIN, TAG, 'Profile badge cleared');
  }

  /**
   * 清除所有徽章
   */
  public async clearAllBadges(): Promise<void> {
    await this.saveBadges({
      chatBadge: 0,
      contactsBadge: 0,
      settingsBadge: 0,
      profileBadge: 0
    });
    hilog.debug(DOMAIN, TAG, 'All badges cleared');
  }

  /**
   * 重置徽章数据
   */
  public async resetBadges(): Promise<void> {
    const storage = StorageManager.getInstance(this.storageName);
    await storage.initialize(this.context!);
    await storage.clear();
    hilog.debug(DOMAIN, TAG, 'Badges reset to default');
  }

  /**
   * 获取默认徽章数据
   */
  private getDefaultBadgeData(): BadgeData {
    return {
      chatBadge: 0,
      contactsBadge: 0,
      settingsBadge: 0,
      profileBadge: 0,
      totalBadge: 0,
      lastUpdateTime: 0
    };
  }

  /**
   * 格式化徽章显示
   * 如果徽章数大于99，显示"99+"
   */
  public static formatBadge(badge: number): string {
    if (badge <= 0) {
      return '';
    } else if (badge > 99) {
      return '99+';
    }
    return badge.toString();
  }
}

// 导出单例实例
export const badgeManager = BadgeManager.getInstance();
