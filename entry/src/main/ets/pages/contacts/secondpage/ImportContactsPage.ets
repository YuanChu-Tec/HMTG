import { hilog } from '@kit.PerformanceAnalysisKit';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import { common } from '@kit.AbilityKit';
import { promptAction, router } from '@kit.ArkUI';
import { contact } from '@kit.ContactsKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CoreService } from '../../../services/business/CoreService';
import { Contact, SyncStatus, UserStatus } from '../../../models/TDLibData';

/**
 * 联系人导入项接口
 */
export interface ImportContactItem {
  id: string;
  name: string;
  phone: string;
  avatar?: string;
  isImported: boolean;
  userId?: number;
}

/**
 * 通讯录导入页面
 * 从系统通讯录导入联系人到Telegram
 */
@Entry
@ComponentV2
struct ImportContactsPage {
  @Local systemContacts: ImportContactItem[] = [];
  @Local isLoading: boolean = true;
  @Local hasPermission: boolean = false;
  @Local selectAll: boolean = false;
  @Local selectedContacts: Set<string> = new Set();
  @Local isImporting: boolean = false;
  
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private readonly TAG = 'ImportContactsPage';
  private readonly DOMAIN = 0x0001;
  private readonly CONTACT_PERMISSION: Permissions = 'ohos.permission.READ_CONTACTS';
  private contactService: CoreService = CoreService.getInstance();

  aboutToAppear(): void {
    this.checkPermission();
  }

  /**
   * 检查通讯录权限
   */
  private async checkPermission(): Promise<void> {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const grantStatus = await atManager.checkAccessToken(
        this.context.applicationInfo.accessTokenId,
        this.CONTACT_PERMISSION
      );
      
      this.hasPermission = grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
      
      if (this.hasPermission) {
        this.loadSystemContacts();
      } else {
        this.requestPermission();
      }
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `检查权限失败: ${JSON.stringify(error)}`);
      this.isLoading = false;
    }
  }

  /**
   * 请求通讯录权限
   */
  private async requestPermission(): Promise<void> {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const result = await atManager.requestPermissionsFromUser(this.context, [this.CONTACT_PERMISSION]);
      
      if (result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        this.hasPermission = true;
        this.loadSystemContacts();
      } else {
        this.isLoading = false;
        promptAction.showToast({
          message: '需要通讯录权限才能导入联系人',
          duration: 2000
        });
      }
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `请求权限失败: ${JSON.stringify(error)}`);
      this.isLoading = false;
    }
  }

  /**
   * 加载系统通讯录
   * 使用 ContactsKit API 读取系统通讯录
   * 注意：API 20 中 queryContacts 接口需要 bundleName 属性
   */
  private async loadSystemContacts(): Promise<void> {
    this.isLoading = true;
    try {
      // API 20 中 Holder 需要 bundleName 属性
      // 从应用配置中自动获取 bundleName
      const bundleName = this.context.applicationInfo.name;
      const holder: contact.Holder = {
        bundleName: bundleName
      };

      // 使用回调方式获取联系人数据
      contact.queryContacts(holder, (err: BusinessError, data: contact.Contact[]) => {
        if (err) {
          hilog.error(this.DOMAIN, this.TAG, `加载通讯录失败: ${err.code} - ${err.message}`);
          promptAction.showToast({
            message: '加载失败，请检查通讯录权限',
            duration: 2000
          });
          this.isLoading = false;
          return;
        }

        // 转换为 ImportContactItem 格式
        this.systemContacts = data.map((item: contact.Contact) => {
          const phoneNumber = item.phoneNumbers && item.phoneNumbers.length > 0
            ? item.phoneNumbers[0].phoneNumber
            : '';

          return {
            id: item.id !== undefined ? item.id.toString() : '',
            name: item.name?.givenName && item.name?.familyName
              ? `${item.name.givenName} ${item.name.familyName}`
              : (item.name?.givenName || item.name?.familyName || '未知联系人'),
            phone: phoneNumber,
            isImported: false
          } as ImportContactItem;
        });

        // 检查哪些联系人已经被导入到 Telegram
        this.checkImportedContacts();

        hilog.info(this.DOMAIN, this.TAG, `成功加载 ${this.systemContacts.length} 个联系人`);

        if (this.systemContacts.length === 0) {
          promptAction.showToast({
            message: '系统通讯录为空',
            duration: 2000
          });
        }

        this.isLoading = false;
      });
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `加载通讯录失败: ${JSON.stringify(error)}`);
      promptAction.showToast({
        message: '加载失败，请检查通讯录权限',
        duration: 2000
      });
      this.isLoading = false;
    }
  }

  /**
   * 检查哪些联系人已经被导入到 Telegram
   * 通过电话号码匹配
   */
  private async checkImportedContacts(): Promise<void> {
    try {
      const telegramContacts = await this.contactService.getContacts();

      // 构建电话号码到联系人ID的映射
      const phoneToTelegramId: Map<string, number> = new Map();
      telegramContacts.forEach(tc => {
        if (tc.phone) {
          // 标准化电话号码（移除空格、+86等）
          const normalizedPhone = tc.phone.replace(/\s+/g, '').replace(/^\+86/, '');
          phoneToTelegramId.set(normalizedPhone, tc.userId);
        }
      });

      // 标记已导入的联系人
      this.systemContacts = this.systemContacts.map(sc => {
        const normalizedPhone = sc.phone.replace(/\s+/g, '').replace(/^\+86/, '');
        const isImported = phoneToTelegramId.has(normalizedPhone);

        if (isImported) {
          sc.isImported = true;
          sc.userId = phoneToTelegramId.get(normalizedPhone);
        }

        return sc;
      });

      hilog.info(this.DOMAIN, this.TAG, `已检查导入状态，${this.systemContacts.filter(c => c.isImported).length} 个已导入`);
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `检查导入状态失败: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 切换选择
   */
  private toggleSelection(contactId: string): void {
    if (this.selectedContacts.has(contactId)) {
      this.selectedContacts.delete(contactId);
    } else {
      this.selectedContacts.add(contactId);
    }

    // 更新全选状态
    const notImported = this.systemContacts.filter(c => !c.isImported);
    this.selectAll = this.selectedContacts.size === notImported.length && notImported.length > 0;
  }

  /**
   * 全选/取消全选
   */
  private toggleSelectAll(): void {
    const notImported = this.systemContacts.filter(c => !c.isImported);

    if (this.selectAll) {
      // 取消全选
      this.selectedContacts.clear();
    } else {
      // 全选
      notImported.forEach(c => this.selectedContacts.add(c.id));
    }

    this.selectAll = !this.selectAll;
  }

  /**
   * 导入选中的联系人
   */
  private async importSelectedContacts(): Promise<void> {
    if (this.selectedContacts.size === 0) {
      promptAction.showToast({
        message: '请选择要导入的联系人',
        duration: 2000
      });
      return;
    }

    this.isImporting = true;
    let successCount = 0;
    let failCount = 0;

    try {
      const contactsToImport = this.systemContacts.filter(c =>
        this.selectedContacts.has(c.id) && !c.isImported
      );

      hilog.info(this.DOMAIN, this.TAG, `开始导入 ${contactsToImport.length} 个联系人`);

      // 批量导入联系人
      for (const item of contactsToImport) {
        try {
          // 解析姓名
          const nameParts = item.name.split(/\s+/);
          const firstName = nameParts[0] || '';
          const lastName = nameParts.slice(1).join(' ');

          // 构建联系人数据 - ArkTS: 使用显式变量避免结构类型错误
          const importStatus: UserStatus = { type: 'offline', wasOnline: 0 };
          const importPhone = item.phone.replace(/\s+/g, '');
          const importFullName = `${firstName} ${lastName}`.trim();
          const importSectionKey = firstName.charAt(0).toUpperCase();
          const importNow = Date.now();

          const contactToImport: Contact = {
            id: 0,
            userId: 0,
            firstName: firstName,
            lastName: lastName,
            phone: importPhone,
            usernames: [],
            isVerified: false,
            isPremium: false,
            isBot: false,
            status: importStatus,
            avatarPath: '',
            fullName: importFullName,
            phones: [],
            emails: [],
            syncSource: 'tdlib',
            lastUpdated: importNow,
            syncStatus: SyncStatus.SYNCED,
            isFavorite: false,
            displayOrder: 0,
            sectionKey: importSectionKey
          } as Contact;

          // 调用ContactService添加联系人
          await this.contactService.addContact(contactToImport);

          // 更新状态
          const index = this.systemContacts.findIndex(c => c.id === item.id);
          if (index !== -1) {
            this.systemContacts[index].isImported = true;
          }

          successCount++;
          hilog.info(this.DOMAIN, this.TAG, `成功导入联系人: ${item.name}`);
        } catch (error) {
          failCount++;
          hilog.error(this.DOMAIN, this.TAG, `导入联系人失败: ${item.name}, 错误: ${JSON.stringify(error)}`);
        }
      }

      // 清空选择
      this.selectedContacts.clear();
      this.selectAll = false;

      // 显示结果
      if (successCount > 0) {
        let message = `成功导入 ${successCount} 个联系人`;
        if (failCount > 0) {
          message += `，失败 ${failCount} 个`;
        }
        promptAction.showToast({
          message: message,
          duration: 3000
        });
      } else {
        promptAction.showToast({
          message: `导入失败 ${failCount} 个联系人`,
          duration: 2000
        });
      }

      hilog.info(this.DOMAIN, this.TAG, `导入完成: 成功 ${successCount}, 失败 ${failCount}`);
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `导入联系人失败: ${JSON.stringify(error)}`);
      promptAction.showToast({
        message: '导入失败，请重试',
        duration: 2000
      });
    } finally {
      this.isImporting = false;
    }
  }

  /**
   * 获取未导入的联系人数量
   */
  private getNotImportedCount(): number {
    return this.systemContacts.filter(c => !c.isImported).length;
  }

  /**
   * 构建联系人列表项
   */
  @Builder
  buildContactItem(contact: ImportContactItem) {
    Row() {
      // 选择框
      Checkbox({ name: contact.id, group: 'contacts' })
        .select(this.selectedContacts.has(contact.id))
        .enabled(!contact.isImported)
        .onChange((value: boolean) => {
          this.toggleSelection(contact.id);
        })

      // 头像
      if (contact.avatar) {
        Image(contact.avatar)
          .width(48)
          .height(48)
          .borderRadius(24)
          .margin({ left: 12 })
      } else {
        Circle()
          .width(48)
          .height(48)
          .fill('#E0E0E0')
          .margin({ left: 12 })
      }

      // 联系人信息
      Column() {
        Text(contact.name)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)

        Text(contact.phone)
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      // 状态标签
      if (contact.isImported) {
        Text('已导入')
          .fontSize(12)
          .fontColor('#4CAF50')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#E8F5E9')
          .borderRadius(4)
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
  }

  /**
   * 构建空状态
   */
  @Builder
  buildEmptyState() {
    Column() {
      Image('/common/media/empty_contacts_icon.svg')
        .width(120)
        .height(120)
        .fillColor('#E0E0E0')
        .margin({ bottom: 16 })

      Text('通讯录为空')
        .fontSize(16)
        .fontColor('#999999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 构建无权限状态
   */
  @Builder
  buildNoPermissionState() {
    Column() {
      Image('/common/media/permission_icon.svg')
        .width(120)
        .height(120)
        .fillColor('#E0E0E0')
        .margin({ bottom: 16 })

      Text('需要通讯录权限')
        .fontSize(16)
        .fontColor('#333333')
        .margin({ bottom: 8 })

      Text('需要访问通讯录以导入联系人')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ bottom: 24 })

      Button('授权')
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#6200EE')
        .height(44)
        .padding({ left: 32, right: 32 })
        .onClick(() => {
          this.requestPermission();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image('/common/media/chevron_back.svg')
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back()
          })
        
        Text('导入联系人')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        // 占位
        Row()
          .width(24)
          .height(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)
      
      // 工具栏
      if (this.systemContacts.length > 0) {
        Row() {
          Text(`共 ${this.systemContacts.length} 个联系人`)
            .fontSize(14)
            .fontColor('#999999')
            .layoutWeight(1)
          
          if (this.getNotImportedCount() > 0) {
            Row() {
              Checkbox()
                .select(this.selectAll)
                .onChange((value: boolean) => {
                  this.toggleSelectAll();
                })
              
              Text('全选')
                .fontSize(14)
                .fontColor('#333333')
                .margin({ left: 4 })
            }
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor('#F5F5F5')
      }
      
      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#6200EE')
          
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      } else if (!this.hasPermission) {
        // 无权限状态
        this.buildNoPermissionState()
      } else if (this.systemContacts.length === 0) {
        // 空状态
        this.buildEmptyState()
      } else {
        // 联系人列表
        List() {
          ForEach(this.systemContacts, (contact: ImportContactItem) => {
            ListItem() {
              this.buildContactItem(contact)
            }
          }, (contact: ImportContactItem) => contact.id)
        }
        .layoutWeight(1)
        .width('100%')
        .divider({
          strokeWidth: 0.5,
          color: '#E0E0E0',
          startMargin: 16,
          endMargin: 16
        })
        .backgroundColor('#F5F5F5')
      }
      
      // 底部操作栏
      if (this.selectedContacts.size > 0) {
        Row() {
          Text(`已选择 ${this.selectedContacts.size} 个联系人`)
            .fontSize(14)
            .fontColor('#333333')
            .layoutWeight(1)
          
          Button('导入')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor('#6200EE')
            .height(44)
            .padding({ left: 24, right: 24 })
            .enabled(!this.isImporting)
            .onClick(() => {
              this.importSelectedContacts();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor(Color.White)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
