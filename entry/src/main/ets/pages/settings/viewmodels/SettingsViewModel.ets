import { hilog } from '@kit.PerformanceAnalysisKit';
import { bundleManager } from '@kit.AbilityKit';
import { CoreService } from '../../../services/business/CoreService';
import { LogService } from '../../../utils/log/LogService';
import { ErrorHandler } from '../../../utils/error/ErrorHandler';
import { FileDownloadService } from '../../../services/business/FileDownloadService';
import { FileType, DownloadPriority } from '../../../models/TDLibData';
import { EventBus } from '../../../utils/event/EventBus';

const TAG = 'SettingsViewModel';
const DOMAIN = 0x0001;

export interface UserInfo {
  fullName: string;
  phoneNumber: string;
  username: string;
  avatarInitials: string;
  avatarPath?: string; // ⭐ 用户头像路径
  avatarFileId?: number; // ⭐ 头像文件ID
}

@ObservedV2
export class SettingsViewModel {
  @Trace userInfo: UserInfo | null = null;
  @Trace appVersion: string = '';
  @Trace isLoading: boolean = true;

  private CoreService: CoreService = CoreService.getInstance();
  private fileDownloadService: FileDownloadService = FileDownloadService.getInstance();
  private eventBus: EventBus = EventBus.getInstance();
  
  // 当前用户ID和头像fileId
  private currentUserId: number = 0;
  private currentAvatarFileId: number = 0;
  private isAvatarDownloading: boolean = false;

  public async initialize(): Promise<void> {
    this.isLoading = true;
    hilog.info(DOMAIN, TAG, '⭐ SettingsViewModel initialize() started');
    
    // 注册事件监听
    this.registerEventListeners();
    
    await Promise.all([
      this.loadAppVersion(),
      this.loadUserInfo()
    ]);
    this.isLoading = false;
    hilog.info(DOMAIN, TAG, '⭐ SettingsViewModel initialize() completed');
  }
  
  private registerEventListeners(): void {
    // ⭐ 使用 CoreService 领域事件替代 TDLib 原始事件
    this.eventBus.on('core:avatarDownloaded', this.handleCoreAvatarDownloaded.bind(this));
    this.eventBus.on('core:userUpdated', this.handleCoreUserUpdated.bind(this));
    this.eventBus.on('core:userFullInfoUpdated', this.handleCoreUserFullInfoUpdated.bind(this));
  }
  
  private unregisterEventListeners(): void {
    this.eventBus.off('core:avatarDownloaded', this.handleCoreAvatarDownloaded.bind(this));
    this.eventBus.off('core:userUpdated', this.handleCoreUserUpdated.bind(this));
    this.eventBus.off('core:userFullInfoUpdated', this.handleCoreUserFullInfoUpdated.bind(this));
  }
  
  private handleCoreUserUpdated(data?: Object): void {
    const userId = (data as Record<string, Object>)['userId'] as number;
    if (!userId || !this.userInfo) return;
    if (userId !== this.currentUserId) return;
    
    hilog.info(DOMAIN, TAG, `User updated, reloading user info for userId: ${userId}`);
    // 重新加载用户信息
    this.loadUserInfo().catch((err: Error) => {
      hilog.error(DOMAIN, TAG, `Failed to reload user info: ${err.message}`);
    });
  }
  
  private handleCoreUserFullInfoUpdated(data?: Object): void {
    const userId = (data as Record<string, Object>)['userId'] as number;
    if (!userId || !this.userInfo) return;
    if (userId !== this.currentUserId) return;
    
    hilog.info(DOMAIN, TAG, `User full info updated, reloading for userId: ${userId}`);
    // 重新加载用户信息
    this.loadUserInfo().catch((err: Error) => {
      hilog.error(DOMAIN, TAG, `Failed to reload user full info: ${err.message}`);
    });
  }
  
  private handleCoreAvatarDownloaded(data?: Object): void {
    if (!data || !this.userInfo) return;
    
    const fileId = (data as Record<string, Object>)['fileId'] as number;
    const path = (data as Record<string, Object>)['path'] as string;
    
    // 检查是否是当前用户的头像
    if (fileId === this.currentAvatarFileId && path) {
      hilog.info(DOMAIN, TAG, `Avatar downloaded via core:avatarDownloaded: ${path}`);
      // 更新头像路径
      this.userInfo = {
        fullName: this.userInfo.fullName,
        phoneNumber: this.userInfo.phoneNumber,
        username: this.userInfo.username,
        avatarInitials: this.userInfo.avatarInitials,
        avatarPath: 'file://' + path
      };
      this.isAvatarDownloading = false;
    }
  }

  private async loadAppVersion(): Promise<void> {
    try {
      const bundleInfo = bundleManager.getBundleInfoForSelfSync(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT
      );
      const versionName = bundleInfo.versionName || '未知';
      this.appVersion = `Telegram HarmonyOS 客户端 v${versionName}\nstore bundled arm64-v8a`;
    } catch (error) {
      LogService.getInstance().error(DOMAIN, TAG, `Failed to load version: ${error}`);
      this.appVersion = 'Telegram HarmonyOS 客户端\n版本信息获取失败';
    }
  }

  private async loadUserInfo(): Promise<void> {
    try {
      // ⭐ 通过 CoreService 获取当前用户的完整信息
      const fullUserInfo = await this.CoreService.getCurrentUserFullInfo();

      if (!fullUserInfo) {
        hilog.warn(DOMAIN, TAG, 'Failed to get current user full info');
        // 使用缓存作为后备
        const cachedInfo = this.CoreService.getCachedUserInfo(0);
        if (cachedInfo) {
          const nameParts = cachedInfo.name.split(' ');
          const firstName = nameParts[0] || '';
          const lastName = nameParts.slice(1).join(' ') || '';
          const firstInitial = firstName ? firstName.charAt(0) : '';
          const lastLastInitial = lastName ? lastName.charAt(0) : '';

          this.userInfo = {
            fullName: cachedInfo.name || '用户',
            phoneNumber: '',
            username: '',
            avatarInitials: (firstInitial + lastLastInitial).toUpperCase() || '用户',
            avatarPath: cachedInfo.avatar || ''
          };
        }
        return;
      }

      // 解析用户信息
      const firstName = (fullUserInfo['first_name'] as string) || '';
      const lastName = (fullUserInfo['last_name'] as string) || '';
      const phoneNumber = (fullUserInfo['phone_number'] as string) || '';

      // 获取用户名
      let username = '';
      const usernamesObj = (fullUserInfo['usernames'] || fullUserInfo['usernames_']) as Record<string, Object>;
      if (usernamesObj) {
        const activeUsernames = usernamesObj['active_usernames'] as Array<string>;
        if (activeUsernames && activeUsernames.length > 0) {
          username = activeUsernames[0];
        }
      }

      // 获取用户ID
      this.currentUserId = (fullUserInfo['id'] as number) || 0;
      
      // 获取头像路径和fileId
      let avatarPath = '';
      let avatarFileId = 0;
      const profilePhoto = fullUserInfo['profile_photo'] as Record<string, Object>;
      if (profilePhoto?.['small']) {
        const small = profilePhoto['small'] as Record<string, Object>;
        const local = small['local'] as Record<string, Object>;
        avatarPath = (local?.['path'] as string) || '';
        // 获取头像fileId用于下载
        avatarFileId = (small['id'] as number) || 0;
        this.currentAvatarFileId = avatarFileId;
      }

      // 如果头像为空，尝试从缓存获取
      if (!avatarPath) {
        const cachedInfo = this.CoreService.getCachedUserInfo(this.currentUserId);
        if (cachedInfo?.avatar) {
          avatarPath = cachedInfo.avatar;
        }
      }
      
      // ⭐ 如果头像为空且有fileId，触发异步下载
      if (!avatarPath && avatarFileId > 0 && !this.isAvatarDownloading) {
        this.triggerAvatarDownload(avatarFileId);
      }

      // ⭐ 处理头像路径，确保格式正确
      const originalAvatarPath = avatarPath;
      if (avatarPath && !avatarPath.startsWith('file://') && avatarPath.startsWith('/')) {
        avatarPath = 'file://' + avatarPath;
      }
      hilog.info(DOMAIN, TAG, `⭐ Avatar path: "${originalAvatarPath}" -> "${avatarPath}"`);

      const firstInitial = firstName ? firstName.charAt(0) : '';
      const lastLastInitial = lastName ? lastName.charAt(0) : '';

      this.userInfo = {
        fullName: `${firstName} ${lastName}`.trim() || '用户',
        phoneNumber: this.formatPhoneNumber(phoneNumber),
        username: username ? `@${username}` : '',
        avatarInitials: (firstInitial + lastLastInitial).toUpperCase() || '用户',
        avatarPath: avatarPath,
        avatarFileId: avatarFileId
      };

      hilog.info(DOMAIN, TAG, `⭐ Loaded user info: ${firstName} ${lastName}, avatar: ${avatarPath ? 'yes' : 'no'}`);
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
      LogService.getInstance().error(DOMAIN, TAG, `Failed to load user info: ${error}`);
    }
  }

  private formatPhoneNumber(phone: string): string {
    if (!phone) return '';
    if (phone.startsWith('+')) return phone;
    if (phone.startsWith('86') && phone.length === 13) {
      const countryCode = phone.substring(0, 2);
      const part1 = phone.substring(2, 5);
      const part2 = phone.substring(5, 9);
      const part3 = phone.substring(9);
      return `+${countryCode} ${part1}-${part2}-${part3}`;
    }
    return `+${phone}`;
  }
  
  /**
   * ⭐ 触发头像异步下载
   */
  private triggerAvatarDownload(fileId: number): void {
    if (this.isAvatarDownloading) return;
    
    this.isAvatarDownloading = true;
    hilog.info(DOMAIN, TAG, `Triggering avatar download for current user, fileId: ${fileId}`);
    
    this.fileDownloadService.downloadFile(
      fileId,
      FileType.PROFILE_PHOTO,
      DownloadPriority.HIGH
    ).then((path: string) => {
      hilog.info(DOMAIN, TAG, `✅ Avatar downloaded: ${path}`);
      if (this.userInfo) {
        this.userInfo = {
          fullName: this.userInfo.fullName,
          phoneNumber: this.userInfo.phoneNumber,
          username: this.userInfo.username,
          avatarInitials: this.userInfo.avatarInitials,
          avatarPath: 'file://' + path
        };
      }
      this.isAvatarDownloading = false;
    }).catch((err: Error) => {
      hilog.warn(DOMAIN, TAG, `⚠️ Avatar download failed: ${err.message}`);
      this.isAvatarDownloading = false;
    });
  }
  
  public cleanup(): void {
    this.unregisterEventListeners();
  }
}
