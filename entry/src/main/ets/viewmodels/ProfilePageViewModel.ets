// ProfilePageViewModel.ets
import { CoreService } from '../services/business/CoreService';
import type { FormattedText, birthdate } from '../services/api/factory/tdlib-types';
import { EventBus } from '../utils/event/EventBus';
import { LogService } from '../utils/log/LogService';
import { ErrorHandler } from '../utils/error/ErrorHandler';
import { picker, fileIo as fs } from '@kit.CoreFileKit';
import { pasteboard } from '@kit.BasicServicesKit';
import { QRCodeGenerator } from '../utils/QRCodeGenerator';
import { image } from '@kit.ImageKit';
import { promptAction } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { FileDownloadService } from '../services/business/FileDownloadService';
import { FileType, DownloadPriority } from '../models/TDLibData';

export interface UserInfo {
  id: number;
  firstName: string;
  lastName: string;
  username: string;
  phoneNumber: string;
  profilePhoto: string;
  bio: string;
  birthday?: string;
  statusText: string;
  isOnline: boolean;
}

@ObservedV2
export class ProfilePageViewModel {
  @Trace userInfo: UserInfo | null = null;
  @Trace isLoading: boolean = true;
  @Trace isEditing: boolean = false;
  @Trace showQRCode: boolean = false;
  @Trace qrCodePixelMap: image.PixelMap | null = null;
  @Trace qrContent: string = '';
  @Trace editFirstName: string = '';
  @Trace editLastName: string = '';
  @Trace editBio: string = '';
  @Trace currentTabIndex: number = 0;

  private CoreService: CoreService = CoreService.getInstance();
  private currentUserId: number = 0;
  private currentAvatarFileId: number = 0;
  private eventBus: EventBus = EventBus.getInstance();
  private fileDownloadService: FileDownloadService = FileDownloadService.getInstance();
  
  // 头像下载状态
  private isAvatarDownloading: boolean = false;

  constructor() {
    this.registerEventListeners();
  }

  // ==================== 数据加载 ====================
  public async loadUserInfo(): Promise<void> {
    this.isLoading = true;
    hilog.info(0x0001, 'ProfileVM', '⭐ ProfilePageViewModel loadUserInfo() started');
    try {
      // ⭐ 通过 CoreService 获取当前用户的完整信息
      const fullUserInfo = await this.CoreService.getCurrentUserFullInfo();
      hilog.info(0x0001, 'ProfileVM', `⭐ Got fullUserInfo: ${fullUserInfo ? 'yes' : 'no'}`);

      if (!fullUserInfo) {
        hilog.warn(0x0001, 'ProfileVM', 'Failed to get current user full info');
        this.userInfo = null;
        return;
      }

      // 解析用户信息
      this.currentUserId = (fullUserInfo['id'] as number) || 0;
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

      // 获取头像路径和fileId
      let profilePhoto = this.extractProfilePhotoJson(fullUserInfo) || '';
      const originalProfilePhoto = profilePhoto;

      // ⭐ 处理头像路径：HarmonyOS Image 组件直接接受绝对路径，不需要 file:// 前缀
      // 移除可能存在的 file:// 前缀
      if (profilePhoto && profilePhoto.startsWith('file://')) {
        profilePhoto = profilePhoto.substring(7);
      }
      hilog.info(0x0001, 'ProfileVM', `⭐ Avatar path: "${originalProfilePhoto}" -> "${profilePhoto}", fileId: ${this.currentAvatarFileId}`);

      // 获取详细信息（bio, birthday）
      let bio = '';
      let birthday = '';
      const fullInfo = fullUserInfo['full_info'] as Record<string, Object>;
      if (fullInfo) {
        const bioObj = fullInfo['bio'] as FormattedText;
        if (bioObj?.text) bio = bioObj.text;
        const birthdateObj = fullInfo['birthdate'] as birthdate;
        if (birthdateObj) {
          const day = birthdateObj.day;
          const month = birthdateObj.month;
          const year = birthdateObj.year;
          if (day && month && year) {
            birthday = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
          } else if (day && month) {
            birthday = `${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
          }
        }
      }

      // 如果头像为空，尝试从缓存获取
      if (!profilePhoto) {
        const cachedInfo = this.CoreService.getCachedUserInfo(this.currentUserId);
        if (cachedInfo?.avatar) {
          profilePhoto = cachedInfo.avatar;
        }
      }

      const formattedPhone = this.formatPhoneNumber(phoneNumber);

      this.userInfo = {
        id: this.currentUserId,
        firstName,
        lastName,
        username,
        phoneNumber: formattedPhone,
        profilePhoto,
        bio,
        birthday,
        statusText: '在线',
        isOnline: true
      };

      hilog.info(0x0001, 'ProfileVM', `Loaded user info: ${firstName} ${lastName}, id=${this.currentUserId}`);
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
      this.userInfo = null;
    } finally {
      this.isLoading = false;
    }
  }

  // ==================== 业务操作 ====================
  public toggleEditMode(): void {
    if (this.isEditing) {
      this.isEditing = false;
    } else if (this.userInfo) {
      this.editFirstName = this.userInfo.firstName;
      this.editLastName = this.userInfo.lastName;
      this.editBio = this.userInfo.bio;
      this.isEditing = true;
    }
  }

  public async saveProfile(): Promise<void> {
    if (!this.userInfo) return;
    try {
      // 乐观更新 UI
      this.userInfo = {
        id: this.userInfo.id,
        firstName: this.editFirstName,
        lastName: this.editLastName,
        username: this.userInfo.username,
        phoneNumber: this.userInfo.phoneNumber,
        profilePhoto: this.userInfo.profilePhoto,
        bio: this.editBio,
        birthday: this.userInfo.birthday,
        statusText: this.userInfo.statusText,
        isOnline: this.userInfo.isOnline
      };
      
      promptAction.showToast({ message: $r('app.string.profile_updated_toast'), duration: 2000 });
      this.isEditing = false;
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
      promptAction.showToast({ message: $r('app.string.save_failed'), duration: 2000 });
    }
  }

  public async changeAvatar(): Promise<void> {
    try {
      const photoSelectOption = new picker.PhotoSelectOptions();
      const photoPicker = new picker.PhotoViewPicker();
      const photoResult = await photoPicker.select(photoSelectOption);
      if (photoResult?.photoUris.length > 0) {
        const uri = photoResult.photoUris[0];
        if (this.userInfo) this.userInfo.profilePhoto = uri;
        promptAction.showToast({ message: $r('app.string.avatar_updated_toast'), duration: 2000 });
      }
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
      promptAction.showToast({ message: $r('app.string.avatar_update_failed'), duration: 3000 });
    }
  }

  public async generateQRCode(): Promise<void> {
    if (!this.userInfo) return;
    try {
      let content = '';
      if (this.userInfo.username) content = `https://t.me/${this.userInfo.username}`;
      else if (this.userInfo.phoneNumber) content = `tel:${this.userInfo.phoneNumber}`;
      else return;
      this.qrCodePixelMap = await QRCodeGenerator.generateQRCode(content, 300);
      if (this.qrCodePixelMap) {
        this.qrContent = content;
        this.showQRCode = true;
      } else {
        promptAction.showToast({ message: $r('app.string.qr_generate_failed'), duration: 2000 });
      }
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
    }
  }

  public closeQRCode(): void {
    this.showQRCode = false;
    this.qrCodePixelMap?.release();
    this.qrCodePixelMap = null;
  }

  public async copyText(text: string, successMsg: ResourceStr): Promise<void> {
    try {
      const systemPasteboard = pasteboard.getSystemPasteboard();
      const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
      await systemPasteboard.setData(pasteData);
      promptAction.showToast({ message: successMsg, duration: 1500 });
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
      promptAction.showToast({ message: $r('app.string.copy_failed'), duration: 1500 });
    }
  }

  // ==================== 辅助方法 ====================
  private formatPhoneNumber(phone: string): string {
    if (!phone) return '';
    let cleanPhone = phone.startsWith('+') ? phone.substring(1) : phone;
    if (cleanPhone.startsWith('86') && cleanPhone.length === 13) {
      const countryCode = cleanPhone.substring(0, 2);
      const prefix = cleanPhone.substring(2, 5);
      const middle = cleanPhone.substring(5, 9);
      const suffix = cleanPhone.substring(9);
      return `+${countryCode} ${prefix}-${middle}-${suffix}`;
    }
    return `+${cleanPhone}`;
  }

  private extractProfilePhotoJson(meResult: Object): string {
    try {
      const jsonStr = JSON.stringify(meResult);
      const jsonObj: Record<string, Object> = JSON.parse(jsonStr);
      const profilePhoto = jsonObj.profile_photo as Record<string, Object>;
      if (profilePhoto?.small) {
        const small = profilePhoto.small as Record<string, Object>;
        const local = small.local as Record<string, Object>;
        const fileId = small.id as number;

        // 保存 fileId 用于后续更新检查
        if (fileId && fileId > 0) {
          this.currentAvatarFileId = fileId;
          hilog.info(0x0001, 'ProfileVM', `Extracted avatar fileId: ${fileId}`);

          // ⭐ 如果有本地路径，先检查文件是否真实存在
          if (local?.path) {
            let path = local.path as string;
            let checkPath = path;
            if (checkPath.startsWith('file://')) {
              checkPath = checkPath.substring(7);
            }
            try {
              const stat = fs.statSync(checkPath);
              hilog.info(0x0001, 'ProfileVM', `Avatar file exists: ${checkPath}, size: ${stat.size}`);
            } catch {
              hilog.info(0x0001, 'ProfileVM', `Avatar file not found at ${checkPath}, triggering download`);
              this.triggerAvatarDownload(fileId);
              return '';
            }
          } else {
            // 如果没有本地路径，触发异步下载
            hilog.info(0x0001, 'ProfileVM', `Avatar not cached, triggering download for fileId: ${fileId}`);
            this.triggerAvatarDownload(fileId);
          }
        }

        if (local?.path) {
          let path = local.path as string;
          if (!path.startsWith('file://')) {
            path = 'file://' + path;
          }
          return path;
        }
      }
      return '';
    } catch {
      return '';
    }
  }

  /**
   * ⭐ 触发头像异步下载（通过 CoreService）
   */
  private triggerAvatarDownload(fileId: number): void {
    if (this.isAvatarDownloading) return;

    this.isAvatarDownloading = true;
    hilog.info(0x0001, 'ProfileVM', `Triggering avatar download directly via FileDownloadService, fileId: ${fileId}`);

    this.fileDownloadService.downloadFile(
      fileId,
      FileType.PROFILE_PHOTO,
      DownloadPriority.URGENT
    ).then(async (path: string) => {
      hilog.info(0x0001, 'ProfileVM', `✅ Avatar downloaded: ${path}`);
      
      // ⭐ 检查文件是否存在
      let finalPath = path;
      if (finalPath.startsWith('file://')) {
        finalPath = finalPath.substring(7);
      }
      
      try {
        const stat = await fs.stat(finalPath);
        hilog.info(0x0001, 'ProfileVM', `✅ File exists: ${finalPath}, size: ${stat.size} bytes`);
      } catch (statErr) {
        hilog.warn(0x0001, 'ProfileVM', `⚠️ File does not exist: ${finalPath}, error: ${JSON.stringify(statErr)}`);
        // 文件不存在，不更新头像路径
        this.isAvatarDownloading = false;
        return;
      }
      
      let displayPath = finalPath;
      if (!displayPath.startsWith('file://')) {
        displayPath = 'file://' + displayPath;
      }
      
      if (this.userInfo) {
        hilog.info(0x0001, 'ProfileVM', `✅ Updating userInfo.profilePhoto to: ${displayPath}`);
        this.userInfo = {
          id: this.userInfo.id,
          firstName: this.userInfo.firstName,
          lastName: this.userInfo.lastName,
          username: this.userInfo.username,
          phoneNumber: this.userInfo.phoneNumber,
          profilePhoto: displayPath,
          bio: this.userInfo.bio,
          birthday: this.userInfo.birthday || '',
          statusText: this.userInfo.statusText,
          isOnline: this.userInfo.isOnline
        };
      }
      this.isAvatarDownloading = false;
    }).catch((err: Error) => {
      hilog.warn(0x0001, 'ProfileVM', `⚠️ Avatar download failed: ${err.message}`);
      this.isAvatarDownloading = false;
    });
  }

  // ==================== CoreService 领域事件监听 ====================
  private registerEventListeners(): void {
    // ⭐ 使用 CoreService 领域事件替代 TDLib 原始事件
    this.eventBus.on('core:userUpdated', this.handleCoreUserUpdate.bind(this));
    this.eventBus.on('core:userFullInfoUpdated', this.handleCoreUserFullInfo.bind(this));
    this.eventBus.on('core:userAvatarDownloaded', this.handleCoreAvatarDownloaded.bind(this));
    // ⭐ 使用 CoreService 领域事件替代 TDLib 原始事件
    this.eventBus.on('core:optionUpdated', this.handleCoreOptionUpdated.bind(this));
    this.eventBus.on('core:passwordStateUpdated', this.handleCorePasswordStateUpdated.bind(this));
    this.eventBus.on('core:connectedWebsitesUpdated', this.handleCoreConnectedWebsitesUpdated.bind(this));
  }

  private unregisterEventListeners(): void {
    this.eventBus.off('core:userUpdated', this.handleCoreUserUpdate.bind(this));
    this.eventBus.off('core:userFullInfoUpdated', this.handleCoreUserFullInfo.bind(this));
    this.eventBus.off('core:userAvatarDownloaded', this.handleCoreAvatarDownloaded.bind(this));
    this.eventBus.off('core:optionUpdated', this.handleCoreOptionUpdated.bind(this));
    this.eventBus.off('core:passwordStateUpdated', this.handleCorePasswordStateUpdated.bind(this));
    this.eventBus.off('core:connectedWebsitesUpdated', this.handleCoreConnectedWebsitesUpdated.bind(this));
  }

  // ==================== CoreService 领域事件处理 ====================
  private handleCoreUserUpdate(data: Object): void {
    const userId = (data as Record<string, Object>)['userId'] as number;
    if (!userId || !this.userInfo) return;
    if (userId !== this.currentUserId) return;

    // 重新加载用户信息
    this.loadUserInfo().catch((err: Error) => {
      hilog.error(0x0001, 'ProfileVM', `Failed to reload user info: ${err.message}`);
    });
  }

  private handleCoreUserFullInfo(data: Object): void {
    const userId = (data as Record<string, Object>)['userId'] as number;
    if (!userId || !this.userInfo) return;
    if (userId !== this.currentUserId) return;

    // 重新加载用户详细信息（复用 loadUserInfo）
    this.loadUserInfo().catch((err: Error) => {
      hilog.error(0x0001, 'ProfileVM', `Failed to reload user full info: ${err.message}`);
    });
  }

  private handleCoreAvatarDownloaded(data: Object): void {
    const fileId = (data as Record<string, Object>)['fileId'] as number;
    const path = (data as Record<string, Object>)['path'] as string;
    
    if (!this.userInfo) return;
    
    // 检查是否是当前用户的头像（通过fileId匹配）
    if (fileId !== this.currentAvatarFileId) return;
    if (!path) return;
    
    hilog.info(0x0001, 'ProfileVM', `Avatar downloaded via core:avatarDownloaded: ${path}`);
    
    // ⭐ 移除 file:// 前缀（如果存在）
    let photoPath = path;
    if (photoPath.startsWith('file://')) {
      photoPath = photoPath.substring(7);
    }
    
    this.userInfo = {
      id: this.userInfo.id,
      firstName: this.userInfo.firstName,
      lastName: this.userInfo.lastName,
      username: this.userInfo.username,
      phoneNumber: this.userInfo.phoneNumber,
      profilePhoto: photoPath,
      bio: this.userInfo.bio,
      birthday: this.userInfo.birthday || '',
      statusText: this.userInfo.statusText,
      isOnline: this.userInfo.isOnline
    };
    
    this.isAvatarDownloading = false;
  }

  private handleCoreOptionUpdated(data: Object): void {
    const name = (data as Record<string, Object>)['name'] as string;
    // 仅记录日志
    LogService.getInstance().debug(0x0001, 'ProfileVM', `Option updated: ${name}`);
  }

  private handleCorePasswordStateUpdated(data: Object): void {
    LogService.getInstance().info(0x0001, 'ProfileVM', 'Password state updated');
  }

  private handleCoreConnectedWebsitesUpdated(data: Object): void {
    LogService.getInstance().info(0x0001, 'ProfileVM', 'Connected websites updated');
  }

  public cleanup(): void {
    this.unregisterEventListeners();
  }
}