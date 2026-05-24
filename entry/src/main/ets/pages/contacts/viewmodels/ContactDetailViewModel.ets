import { Contact } from '../../../models/TDLibData';
import { CoreService } from '../../../services/business/CoreService';
import { AppError } from '../../../utils';
import { router } from '@kit.ArkUI';

/**
 * 联系人详情ViewModel
 */
@Observed
export class ContactDetailViewModel {
  private static instance: ContactDetailViewModel;
  private contactService: ContactService;
  private _contact: Contact | null = null;
  private _isLoading: boolean = false;

  private constructor() {
    this.contactService = CoreService.getInstance();
  }

  public static getInstance(): ContactDetailViewModel {
    if (!ContactDetailViewModel.instance) {
      ContactDetailViewModel.instance = new ContactDetailViewModel();
    }
    return ContactDetailViewModel.instance;
  }

  @Track
  get contact(): Contact | null {
    return this._contact;
  }

  @Track
  get isLoading(): boolean {
    return this._isLoading;
  }

  /**
   * 加载联系人详情
   */
  public async loadContact(contactId: number): Promise<void> {
    this._isLoading = true;
    try {
      this._contact = await this.contactService.getContactById(contactId);
    } catch (error) {
      this._contact = null;
    } finally {
      this._isLoading = false;
    }
  }

  /**
   * 更新联系人信息
   */
  public async updateContact(contact: Contact): Promise<boolean> {
    try {
      await this.contactService.updateContact(contact);
      this._contact = contact;
      return true;
    } catch (error) {
      return false;
    }
  }

  /**
   * 删除联系人
   */
  public async deleteContact(): Promise<boolean> {
    if (!this._contact) {
      return false;
    }

    try {
      await this.contactService.deleteContact(this._contact.id);
      this._contact = null;
      return true;
    } catch (error) {
      return false;
    }
  }

  /**
   * 获取在线状态文本
   */
  getOnlineStatusText(status: OnlineStatus, lastSeen?: number): string {
    switch (status) {
      case OnlineStatus.ONLINE:
        return '在线';
      case OnlineStatus.RECENTLY:
        return '最近在线';
      case OnlineStatus.WEEK_AGO:
        return '一周前在线';
      case OnlineStatus.MONTH_AGO:
        return '一月前在线';
      case OnlineStatus.LONG_TIME_AGO:
        return '很久以前在线';
      case OnlineStatus.EXACT_TIME:
        if (lastSeen) {
          return this.formatLastSeen(lastSeen);
        }
        return '离线';
      default:
        return '离线';
    }
  }

  /**
   * 格式化最后在线时间
   */
  private formatLastSeen(timestamp: number): string {
    const now = Date.now();
    const diff = now - timestamp;

    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (minutes < 1) {
      return '刚刚';
    } else if (minutes < 60) {
      return `${minutes}分钟前在线`;
    } else if (hours < 24) {
      return `${hours}小时前在线`;
    } else if (days < 7) {
      return `${days}天前在线`;
    } else {
      const date = new Date(timestamp);
      return `${date.getMonth() + 1}月${date.getDate()}日`;
    }
  }

  /**
   * 获取联系人全名
   */
  getContactFullName(contact: Contact): string {
    if (contact.lastName) {
      return `${contact.firstName} ${contact.lastName}`;
    }
    return contact.firstName;
  }

  /**
   * 开始聊天
   */
  public async startChat(): Promise<void> {
    if (!this._contact) {
      return;
    }

    // 导航到聊天详情页面，使用 contactId 跳转到聊天
    try {
      // 注意：实际使用 userId 作为 chatId，因为私聊的 chatId 等于对方 userId
      await router.pushUrl({
        url: 'feature-chat/pages/ChatDetailPage',
        params: {
          chatId: this._contact.userId,
          chatType: 'private'
        }
      });
    } catch (error) {
      console.error('跳转聊天页面失败:', error);
    }
  }
}
