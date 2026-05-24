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

import { router, promptAction } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { CoreService } from '../../../services/business/CoreService';
import { Contact, SyncStatus, UserStatus } from '../../../models/TDLibData';

const TAG = 'NewContactPage';
const DOMAIN = 0x0001;

/**
 * 新建联系人页面
 */
@Entry
@ComponentV2
export struct NewContactPage {
  @Local firstName: string = '';
  @Local lastName: string = '';
  @Local phone: string = '';
  @Local username: string = '';
  @Local notes: string = '';
  @Local isSaving: boolean = false;
  @Local showAvatarPicker: boolean = false;
  @Local selectedAvatar: string = '';

  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private contactService: CoreService = CoreService.getInstance();

  /**
   * 验证输入
   */
  private validateInput(): boolean {
    // 手机号或用户名至少填一个
    const hasPhone = this.phone.trim().length > 0;
    const hasUsername = this.username.trim().length > 0;

    if (!hasPhone && !hasUsername) {
      promptAction.showToast({
        message: '请输入手机号或用户名',
        duration: 2000
      });
      return false;
    }

    // 验证手机号格式
    if (hasPhone && !this.validatePhone(this.phone)) {
      promptAction.showToast({
        message: '手机号格式不正确',
        duration: 2000
      });
      return false;
    }

    // 验证用户名格式
    if (hasUsername && !this.validateUsername(this.username)) {
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
    const phoneRegex = /^[1-9]\d{1,14}$/;
    return phoneRegex.test(phone.replace(/\D/g, ''));
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
    if (!this.validateInput()) {
      return;
    }

    this.isSaving = true;

    try {
      // 创建 Contact 对象 - 使用显式变量声明避免结构类型错误
      const userStatus: UserStatus = { type: 'offline', wasOnline: 0 };
      const firstName = this.firstName.trim();
      const lastName = this.lastName.trim();
      const phone = this.phone.trim().replace(/\s+/g, '');
      const fullName = `${firstName} ${lastName}`.trim();
      const sectionKey = firstName.charAt(0).toUpperCase();
      const now = Date.now();

      // ArkTS: 先创建基础对象，再转换为 Contact 类型
      const contactData: Contact = {
        id: 0,
        userId: 0,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        usernames: [],
        isVerified: false,
        isPremium: false,
        isBot: false,
        status: userStatus,
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

      // 使用 ContactService 添加联系人
      await this.contactService.addContact(contactData);

      promptAction.showToast({
        message: '联系人已保存',
        duration: 2000
      });

      // 返回列表
      router.back();
    } catch (error) {
      hilog.error(DOMAIN, TAG, `保存联系人失败: ${error}`);

      promptAction.showToast({
        message: '保存失败，请重试',
        duration: 2000
      });
    } finally {
      this.isSaving = false;
    }
  }

  /**
   * 取消
   */
  private handleCancel(): void {
    router.back();
  }

  /**
   * 从通讯录导入
   */
  private async importFromPhoneBook(): Promise<void> {
    try {
      // 读取系统通讯录权限
      // 注意：HarmonyOS 使用 @kit.BasicServicesKit.contact 访问通讯录
      // 当前 TDLib 提供 importContacts API 可以批量导入手机号
      promptAction.showToast({
        message: '请手动输入手机号或用户名',
        duration: 3000
      });

      // 未来实现方式：
      // 1. 使用 @kit.BasicServicesKit.contact 读取系统通讯录
      // 2. 获取电话号码列表
      // 3. 调用 this.tdClient.execute('importContacts', { ... })
    } catch (error) {
      hilog.error(DOMAIN, TAG, `导入联系人失败: ${error}`);
    }
  }

  /**
   * 选择头像
   */
  private async selectAvatar(): Promise<void> {
    try {
      // 暂时禁用头像上传功能，等待 TDLib 集成完成
      promptAction.showToast({
        message: '头像上传功能开发中',
        duration: 2000
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, `选择头像失败: ${error}`);
      promptAction.showToast({
        message: '选择头像失败',
        duration: 2000
      });
    }
  }

  /**
   * 上传头像到TDLib
   */
  private async uploadAvatarToTdLib(fileUri: string): Promise<string> {
    try {
      // 暂时禁用头像上传功能，等待 TDLib 集成完成
      return '';
    } catch (error) {
      hilog.error(DOMAIN, TAG, `头像上传失败: ${error}`);
      promptAction.showToast({
        message: '头像上传失败，请重试',
        duration: 2000
      });
      return '';
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.buildNavigationBar()

      // 表单内容
      Scroll() {
        Column({ space: 20 }) {
          this.buildPhotoSection()
          this.buildNameSection()
          this.buildPhoneSection()
          this.buildUsernameSection()
          this.buildNotesSection()
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 底部操作栏
      this.buildActionBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  /**
   * 构建导航栏
   */
  @Builder
  private buildNavigationBar() {
    Row() {
      // 取消按钮
      Text('取消')
        .fontSize(16)
        .fontColor('#007DFF')
        .onClick(() => {
          this.handleCancel();
        })

      // 标题
      Text('新建联系人')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)

      // 保存按钮
      if (this.isSaving) {
        LoadingProgress()
          .width(20)
          .height(20)
          .color('#007DFF')
      } else {
        Text('保存')
          .fontSize(16)
          .fontColor('#007DFF')
          .onClick(() => {
            this.saveContact();
          })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .border({ width: { bottom: 0.5 }, color: '#E0E0E0' })
  }

  /**
   * 构建头像区域
   */
  @Builder
  private buildPhotoSection() {
    Column() {
      Stack() {
        Circle()
          .width(80)
          .height(80)
          .fill('#E0E0E0')

        Image($r('sys.media.ohos_ic_public_add'))
          .width(40)
          .height(40)
          .fillColor('#999999')
      }
      .width('100%')
      .height(80)
      .alignContent(Alignment.Center)

      Text('添加照片')
        .fontSize(14)
        .fontColor('#007DFF')
        .margin({ top: 8 })
        .onClick(() => {
          this.selectAvatar();
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 8, bottom: 8 })
  }

  /**
   * 构建姓名区域
   */
  @Builder
  private buildNameSection() {
    Column({ space: 12 }) {
      // 姓
      TextInput({ placeholder: '姓', text: this.firstName })
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .onChange((value: string) => {
          this.firstName = value;
        })

      // 名
      TextInput({ placeholder: '名', text: this.lastName })
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .onChange((value: string) => {
          this.lastName = value;
        })
    }
    .width('100%')
  }

  /**
   * 构建手机号区域
   */
  @Builder
  private buildPhoneSection() {
    Column({ space: 8 }) {
      Text('手机号')
        .fontSize(14)
        .fontColor('#666666')
        .width('100%')

      Row() {
        TextInput({ 
          placeholder: '输入手机号',
          text: this.phone
        })
          .layoutWeight(1)
          .height(48)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .onChange((value: string) => {
            this.phone = value;
          })

        Image($r('sys.media.ohos_ic_public_add'))
          .width(24)
          .height(24)
          .fillColor('#999999')
          .margin({ left: 8 })
          .onClick(() => {
            this.importFromPhoneBook();
          })
      }
      .width('100%')
    }
    .width('100%')
  }

  /**
   * 构建用户名区域
   */
  @Builder
  private buildUsernameSection() {
    Column({ space: 8 }) {
      Text('Telegram用户名')
        .fontSize(14)
        .fontColor('#666666')
        .width('100%')

      TextInput({ 
        placeholder: '@username',
        text: this.username
      })
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .onChange((value: string) => {
          this.username = value;
        })
    }
    .width('100%')
  }

  /**
   * 构建备注区域
   */
  @Builder
  private buildNotesSection() {
    Column({ space: 8 }) {
      Text('备注')
        .fontSize(14)
        .fontColor('#666666')
        .width('100%')

      TextArea({ 
        placeholder: '添加备注',
        text: this.notes
      })
        .width('100%')
        .height(100)
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .onChange((value: string) => {
          this.notes = value;
        })
    }
    .width('100%')
  }

  /**
   * 构建操作栏
   */
  @Builder
  private buildActionBar() {
    Row() {
      Button('导入通讯录')
        .layoutWeight(1)
        .height(48)
        .fontSize(16)
        .backgroundColor('#F5F5F5')
        .fontColor('#007DFF')
        .borderRadius(0)
        .onClick(() => {
          this.importFromPhoneBook();
        })
    }
    .width('100%')
    .height(48)
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 0.5 }, color: '#E0E0E0' })
  }
}
