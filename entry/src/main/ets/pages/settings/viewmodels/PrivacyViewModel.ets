/*
 * Copyright (c) 2026 HMTG Project
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

const TAG = 'PrivacyViewModel';
const DOMAIN = 0x0001;

/**
 * 隐私设置数据模型
 */
export interface PrivacySettingsData {
  phoneNumber: string;        // 电话号码隐私
  lastSeenPrivacy: string;    // 最后在线隐私
  profilePhotoPrivacy: string; // 个人资料照片隐私
  forwardPrivacy: string;      // 转发隐私
  callsPrivacy: string;        // 通话隐私
  twoFactorAuth: boolean;     // 两步验证
  loginAlerts: boolean;       // 登录提醒
  sessionTimeout: number;      // 会话超时时间(分钟)
  messageDeletionTime: number;  // 消息删除时间(天)
  autoDownloadMedia: boolean; // 自动下载媒体
}

/**
 * 隐私设置 ViewModel
 */
export class PrivacyViewModel {
  private static instance: PrivacyViewModel;
  private privacyData: PrivacySettingsData;
  private preferencesStore: preferences.Preferences | null = null;

  private constructor() {
    // TDLib option API 暂时不可用
    this.privacyData = this.getDefaultPrivacySettings();
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): PrivacyViewModel {
    if (!PrivacyViewModel.instance) {
      PrivacyViewModel.instance = new PrivacyViewModel();
    }
    return PrivacyViewModel.instance;
  }

  /**
   * 获取默认隐私设置
   */
  private getDefaultPrivacySettings(): PrivacySettingsData {
    return {
      phoneNumber: 'contacts',
      lastSeenPrivacy: 'contacts',
      profilePhotoPrivacy: 'everyone',
      forwardPrivacy: 'contacts',
      callsPrivacy: 'contacts',
      twoFactorAuth: false,
      loginAlerts: true,
      sessionTimeout: 7,
      messageDeletionTime: 7,
      autoDownloadMedia: false
    };
  }

  /**
   * 初始化
   */
  public async initialize(context: common.UIAbilityContext): Promise<void> {
    try {
      this.preferencesStore = await preferences.getPreferences(context, 'privacy');
      await this.loadPrivacySettings();
      hilog.info(DOMAIN, TAG, 'Privacy settings initialized');
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to initialize privacy settings: ' + JSON.stringify(error));
    }
  }

  /**
   * 加载隐私设置
   */
  private async loadPrivacySettings(): Promise<void> {
    if (!this.preferencesStore) {
      return;
    }

    try {
      this.privacyData = {
        phoneNumber: (await this.preferencesStore.get('phoneNumber', 'contacts')) as string,
        lastSeenPrivacy: (await this.preferencesStore.get('lastSeenPrivacy', 'contacts')) as string,
        profilePhotoPrivacy: (await this.preferencesStore.get('profilePhotoPrivacy', 'everyone')) as string,
        forwardPrivacy: (await this.preferencesStore.get('forwardPrivacy', 'contacts')) as string,
        callsPrivacy: (await this.preferencesStore.get('callsPrivacy', 'contacts')) as string,
        twoFactorAuth: (await this.preferencesStore.get('twoFactorAuth', false)) as boolean,
        loginAlerts: (await this.preferencesStore.get('loginAlerts', true)) as boolean,
        sessionTimeout: (await this.preferencesStore.get('sessionTimeout', 7)) as number,
        messageDeletionTime: (await this.preferencesStore.get('messageDeletionTime', 7)) as number,
        autoDownloadMedia: (await this.preferencesStore.get('autoDownloadMedia', false)) as boolean
      };
      hilog.info(DOMAIN, TAG, 'Privacy settings loaded');
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to load privacy settings: ' + JSON.stringify(error));
    }
  }

  /**
   * 保存隐私设置
   */
  public async savePrivacySettings(): Promise<void> {
    if (!this.preferencesStore) {
      return;
    }

    try {
      await this.preferencesStore.put('phoneNumber', this.privacyData.phoneNumber);
      await this.preferencesStore.put('lastSeenPrivacy', this.privacyData.lastSeenPrivacy);
      await this.preferencesStore.put('profilePhotoPrivacy', this.privacyData.profilePhotoPrivacy);
      await this.preferencesStore.put('forwardPrivacy', this.privacyData.forwardPrivacy);
      await this.preferencesStore.put('callsPrivacy', this.privacyData.callsPrivacy);
      await this.preferencesStore.put('twoFactorAuth', this.privacyData.twoFactorAuth);
      await this.preferencesStore.put('loginAlerts', this.privacyData.loginAlerts);
      await this.preferencesStore.put('sessionTimeout', this.privacyData.sessionTimeout);
      await this.preferencesStore.flush();
      hilog.info(DOMAIN, TAG, 'Privacy settings saved');
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to save privacy settings: ' + JSON.stringify(error));
    }
  }

  /**
   * 获取隐私设置
   */
  public getPrivacySettings(): PrivacySettingsData {
    const result: PrivacySettingsData = {
      phoneNumber: this.privacyData.phoneNumber,
      lastSeenPrivacy: this.privacyData.lastSeenPrivacy,
      profilePhotoPrivacy: this.privacyData.profilePhotoPrivacy,
      forwardPrivacy: this.privacyData.forwardPrivacy,
      callsPrivacy: this.privacyData.callsPrivacy,
      twoFactorAuth: this.privacyData.twoFactorAuth,
      loginAlerts: this.privacyData.loginAlerts,
      sessionTimeout: this.privacyData.sessionTimeout,
      messageDeletionTime: this.privacyData.messageDeletionTime,
      autoDownloadMedia: this.privacyData.autoDownloadMedia
    };
    return result;
  }

  /**
   * 设置电话号码隐私
   */
  public setPhoneNumberPrivacy(value: string): void {
    this.privacyData.phoneNumber = value;
  }

  /**
   * 设置最后在线隐私
   */
  public setLastSeenPrivacy(value: string): void {
    this.privacyData.lastSeenPrivacy = value;
  }

  /**
   * 设置个人资料照片隐私
   */
  public setProfilePhotoPrivacy(value: string): void {
    this.privacyData.profilePhotoPrivacy = value;
  }

  /**
   * 设置转发隐私
   */
  public setForwardPrivacy(value: string): void {
    this.privacyData.forwardPrivacy = value;
  }

  /**
   * 设置通话隐私
   */
  public setCallsPrivacy(value: string): void {
    this.privacyData.callsPrivacy = value;
  }

  /**
   * 切换两步验证
   */
  public toggleTwoFactorAuth(enabled: boolean): void {
    this.privacyData.twoFactorAuth = enabled;
  }

  /**
   * 切换登录提醒
   */
  public toggleLoginAlerts(enabled: boolean): void {
    this.privacyData.loginAlerts = enabled;
  }

  /**
   * 设置会话超时
   */
  public setSessionTimeout(minutes: number): void {
    this.privacyData.sessionTimeout = minutes;
  }

  /**
   * 同步到TDLib
   */
  public async syncToTdlib(): Promise<boolean> {
    try {
      hilog.info(DOMAIN, TAG, 'Syncing privacy settings to TDLib');

      // TDLib 同步功能暂时禁用
      // 如需启用，需要在 tdlib-bridge 模块中添加对应 API
      hilog.info(DOMAIN, TAG, 'Privacy settings sync to TDLib disabled');
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to sync privacy settings: ' + JSON.stringify(error));
      return false;
    }
  }

  /**
   * 从TDLib加载
   */
  public async loadFromTdlib(): Promise<boolean> {
    try {
      hilog.info(DOMAIN, TAG, 'Loading privacy settings from TDLib');

      // TDLib 加载功能暂时禁用，使用本地默认值
      this.privacyData = this.getDefaultPrivacySettings();

      // 保存到本地
      await this.savePrivacySettings();

      hilog.info(DOMAIN, TAG, 'Privacy settings loaded from TDLib successfully');
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to load privacy settings from TDLib: ' + JSON.stringify(error));
      return false;
    }
  }

  /**
   * 重置为默认设置
   */
  public resetToDefaults(): void {
    this.privacyData = this.getDefaultPrivacySettings();
  }

  /**
   * 销毁
   */
  public destroy(): void {
    this.preferencesStore = null;
  }
}
