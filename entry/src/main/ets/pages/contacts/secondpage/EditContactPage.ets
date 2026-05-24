import { router, promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CoreService } from '../../../services/business/CoreService';
import { Contact, SyncStatus, UserStatus } from '../../../models/TDLibData';
import { TDLibApi } from '../../../services/api/TDLibApi';
import { TDLibClient } from '../../../services/core';
import type { User, UserFullInfo } from '../../../services/api/factory/tdlib-types';

/**
 * 编辑联系人数据接口
 */
export interface EditContactData {
  id?: number;
  userId?: number;
  firstName: string;
  lastName: string;
  phone: string;
  username?: string;
  avatar?: string;
  bio?: string;
}

/**
 * 编辑联系人页面
 * 支持新建和编辑联系人
 */
@Entry
@ComponentV2
struct EditContactPage {
  @Local isEditMode: boolean = false;
  @Local contactData: EditContactData = {
    firstName: '',
    lastName: '',
    phone: '',
    username: '',
    avatar: '',
    bio: ''
  };
  @Local selectedAvatar: string = '';
  @Local showAvatarPicker: boolean = false;
  @Local avatarOptions: string[] = [];
  @Local showDeleteDialog: boolean = false;

  private contactId: number = 0;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private readonly TAG = 'EditContactPage';
  private readonly DOMAIN = 0x0001;
  private contactService: CoreService = CoreService.getInstance();
  private tdLibApi: TDLibApi = new TDLibApi(TDLibClient.getInstance());

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params && params.contactId) {
      this.contactId = params.contactId as number;
      this.isEditMode = true;
      this.loadContactData();
    }

    // 初始化头像选项
    this.initAvatarOptions();
  }

  /**
   * 初始化头像选项
   */
  private initAvatarOptions(): void {
    this.avatarOptions = [
      '/common/media/avatar1.png',
      '/common/media/avatar2.png',
      '/common/media/avatar3.png',
      '/common/media/avatar4.png',
      '/common/media/avatar5.png',
      '/common/media/avatar6.png'
    ];
  }

  /**
   * 加载联系人数据
   */
  private async loadContactData(): Promise<void> {
    try {
      // 从 ContactService 加载联系人信息
      const contact = await this.contactService.getContactById(this.contactId);
      if (contact) {
        // 获取用户详细信息
        let userBio = '';
        try {
          const userFullInfo: UserFullInfo = await this.tdLibApi.getUserFullInfo(contact.userId);
          if (userFullInfo && userFullInfo.bio) {
            userBio = userFullInfo.bio.text || '';
          }
        } catch (error) {
          hilog.warn(this.DOMAIN, this.TAG, `获取用户详情失败: ${JSON.stringify(error)}`);
        }

        this.contactData = {
          id: contact.id,
          userId: contact.userId,
          firstName: contact.firstName,
          lastName: contact.lastName || '',
          phone: contact.phone,
          username: contact.usernames.length > 0 ? contact.usernames[0] : '',
          avatar: contact.avatarPath || '',
          bio: userBio
        };
        this.selectedAvatar = this.contactData.avatar || '';
      } else {
        promptAction.showToast({
          message: '联系人不存在',
          duration: 2000
        });
        router.back();
      }
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `加载联系人数据失败: ${JSON.stringify(error)}`);
      promptAction.showToast({
        message: '加载失败，请重试',
        duration: 2000
      });
    }
  }

  /**
   * 验证表单
   */
  private validateForm(): boolean {
    if (!this.contactData.firstName.trim()) {
      promptAction.showToast({
        message: '请输入名字',
        duration: 2000
      });
      return false;
    }

    if (!this.validatePhone(this.contactData.phone)) {
      promptAction.showToast({
        message: '请输入正确的手机号',
        duration: 2000
      });
      return false;
    }

    if (this.contactData.username && !this.validateUsername(this.contactData.username)) {
      promptAction.showToast({
        message: '用户名格式不正确',
        duration: 2000
      });
      return false;
    }

    return true;
  }

  /**
   * 验证手机号
   */
  private validatePhone(phone: string): boolean {
    const phoneRegex = /^\+?[1-9]\d{1,14}$/;
    return phoneRegex.test(phone.replace(/\s/g, ''));
  }

  /**
   * 验证用户名
   */
  private validateUsername(username: string): boolean {
    const usernameRegex = /^[a-zA-Z0-9_]{5,32}$/;
    return usernameRegex.test(username);
  }

  /**
   * 保存联系人
   */
  private async saveContact(): Promise<void> {
    if (!this.validateForm()) {
      return;
    }

    try {
      if (this.isEditMode && this.contactId > 0) {
        // 更新联系人 - ArkTS: 使用显式变量避免结构类型错误
        const updateStatus: UserStatus = { type: 'empty' };
        const firstName = this.contactData.firstName;
        const lastName = this.contactData.lastName;
        const fullName = `${firstName} ${lastName}`.trim();
        const sectionKey = firstName.charAt(0).toUpperCase();
        const now = Date.now();

        const contactToUpdate: Contact = {
          id: this.contactId,
          userId: this.contactId,
          firstName: firstName,
          lastName: lastName,
          phone: this.contactData.phone,
          usernames: [],
          isVerified: false,
          isPremium: false,
          isBot: false,
          status: updateStatus,
          avatarPath: '',
          fullName: fullName,
          phones: [],
          emails: [],
          syncSource: 'tdlib',
          lastUpdated: now,
          syncStatus: SyncStatus.SYNCED,
          isFavorite: false,
          displayOrder: 0,
          sectionKey: sectionKey
        } as Contact;
        await this.contactService.updateContact(contactToUpdate);
        promptAction.showToast({
          message: '联系人已更新',
          duration: 2000
        });
      } else {
        // 添加新联系人 - ArkTS: 使用显式变量避免结构类型错误
        const addStatus: UserStatus = { type: 'empty' };
        const addFirstName = this.contactData.firstName;
        const addLastName = this.contactData.lastName;
        const addFullName = `${addFirstName} ${addLastName}`.trim();
        const addSectionKey = addFirstName.charAt(0).toUpperCase();
        const addNow = Date.now();

        const contactToAdd: Contact = {
          id: 0,
          userId: 0,
          firstName: addFirstName,
          lastName: addLastName,
          phone: this.contactData.phone,
          usernames: [],
          isVerified: false,
          isPremium: false,
          isBot: false,
          status: addStatus,
          avatarPath: '',
          fullName: addFullName,
          phones: [],
          emails: [],
          syncSource: 'tdlib',
          lastUpdated: addNow,
          syncStatus: SyncStatus.SYNCED,
          isFavorite: false,
          displayOrder: 0,
          sectionKey: addSectionKey
        } as Contact;
        await this.contactService.addContact(contactToAdd);
        promptAction.showToast({
          message: '联系人已添加',
          duration: 2000
        });
      }
      router.back();
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `保存联系人失败: ${JSON.stringify(error)}`);
      promptAction.showToast({
        message: '保存失败，请重试',
        duration: 2000
      });
    }
  }

  /**
   * 删除联系人
   */
  private async deleteContact(): Promise<void> {
    try {
      await this.contactService.deleteContact(this.contactId);
      promptAction.showToast({
        message: '联系人已删除',
        duration: 2000
      });
      router.back();
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `删除联系人失败: ${JSON.stringify(error)}`);
      promptAction.showToast({
        message: '删除失败，请重试',
        duration: 2000
      });
    }
    this.showDeleteDialog = false;
  }

  build() {
    Column() {
      // 头部
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => {
            router.back();
          });

        Text(this.isEditMode ? '编辑联系人' : '新建联系人')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .margin({ left: 16 });

        Text('保存')
          .fontSize(16)
          .fontColor('#007DFF')
          .onClick(() => this.saveContact());
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 0.5 }, color: '#E0E0E0' });

      Scroll() {
        Column({ space: 16 }) {
          // 头像选择
          Column() {
            if (this.selectedAvatar) {
              Image(this.selectedAvatar)
                .width(80)
                .height(80)
                .borderRadius(40)
                .onClick(() => this.showAvatarPicker = true);
            } else {
              Column()
                .width(80)
                .height(80)
                .borderRadius(40)
                .backgroundColor('#E0E0E0')
                .onClick(() => this.showAvatarPicker = true);
            }

            Text('点击更换头像')
              .fontSize(12)
              .fontColor('#007DFF')
              .margin({ top: 8 });
          }
          .alignItems(HorizontalAlign.Center)
          .padding({ top: 24, bottom: 16 });

          // 名字
          Column({ space: 8 }) {
            Text('名字')
              .fontSize(14)
              .fontColor('#666666');

            TextInput({ text: this.contactData.firstName, placeholder: '请输入名字' })
              .width('100%')
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onChange((value: string) => {
                this.contactData.firstName = value;
              });
          }
          .width('100%')
          .padding({ left: 16, right: 16 });

          // 姓氏
          Column({ space: 8 }) {
            Text('姓氏')
              .fontSize(14)
              .fontColor('#666666');

            TextInput({ text: this.contactData.lastName, placeholder: '请输入姓氏' })
              .width('100%')
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onChange((value: string) => {
                this.contactData.lastName = value;
              });
          }
          .width('100%')
          .padding({ left: 16, right: 16 });

          // 手机号
          Column({ space: 8 }) {
            Text('手机号')
              .fontSize(14)
              .fontColor('#666666');

            TextInput({ text: this.contactData.phone, placeholder: '请输入手机号' })
              .width('100%')
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .type(InputType.PhoneNumber)
              .onChange((value: string) => {
                this.contactData.phone = value;
              });
          }
          .width('100%')
          .padding({ left: 16, right: 16 });

          // 用户名
          Column({ space: 8 }) {
            Text('用户名')
              .fontSize(14)
              .fontColor('#666666');

            TextInput({ text: this.contactData.username, placeholder: '请输入用户名（可选）' })
              .width('100%')
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onChange((value: string) => {
                this.contactData.username = value;
              });
          }
          .width('100%')
          .padding({ left: 16, right: 16 });

          // 删除按钮
          if (this.isEditMode) {
            Button('删除联系人')
              .width('90%')
              .height(48)
              .fontSize(16)
              .fontColor('#FF5252')
              .backgroundColor('#FFE8E8')
              .borderRadius(8)
              .margin({ top: 32 })
              .onClick(() => this.showDeleteDialog = true);
          }
        }
        .width('100%')
        .padding({ bottom: 32 });
      }
      .width('100%')
      .layoutWeight(1);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }
}
