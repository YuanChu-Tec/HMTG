// ContactListViewModel.ets
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { EventBus } from '../utils/event/EventBus';
import { CoreService } from '../services/business/CoreService';
import { Contact, SyncStatus, Usernames, UserStatus, UserStatusOnline } from '../models/TDLibData';
import { ErrorHandler } from '../utils/error/ErrorHandler';
import { FileDownloadService } from '../services/business/FileDownloadService';
import { FileType, DownloadPriority } from '../models/TDLibData';

const TAG = 'ContactListViewModel';
const DOMAIN = 0x0001;
const SORT_DEBOUNCE_DELAY = 100;

/**
 * UI 层联系人项数据（响应式）
 */
@ObservedV2
export class ContactItemDisplay {
  @Trace id: number = 0;
  @Trace fullName: string = '';
  @Trace avatarPath: string = '';
  @Trace statusText: string = '';
  @Trace statusColor: string = '#8E8E93';
  @Trace isBot: boolean = false;
}

@ObservedV2
export class ContactListViewModel {
  private static instance: ContactListViewModel;
  // 响应式数据
  contactItems: ContactItemDisplay[] = [];
  isLoading: boolean = true;

  // 内部数据
  private contacts: Contact[] = [];
  private contactMap: Map<number, Contact> = new Map();
  private sortDebounceTimer: number = -1;

  // 服务依赖
  private contactService: CoreService = CoreService.getInstance();
  private eventBus: EventBus = EventBus.getInstance();
  private fileDownloadService: FileDownloadService | null = null;
  
  // 头像下载状态跟踪：userId -> fileId
  private avatarDownloadQueue: Map<number, number> = new Map();

  private constructor() {
    this.registerTDLibEventListeners();

    // 监听 ContactService 的就绪事件
    this.eventBus.on('contactServiceReady', () => {
      hilog.info(DOMAIN, TAG, 'Received contactServiceReady event, reloading contacts...');
      this.loadContactsFromNetwork();
    });
  }

  /**
   * 初始化 FileDownloadService（必须在获取 context 后调用）
   */
  public initializeFileDownloadService(context: common.Context): void {
    if (!this.fileDownloadService) {
      this.fileDownloadService = FileDownloadService.getInstance(context);
      hilog.info(DOMAIN, TAG, 'FileDownloadService initialized');
    }
  }

  public static getInstance(): ContactListViewModel {
    if (!ContactListViewModel.instance) {
      ContactListViewModel.instance = new ContactListViewModel();
    }
    return ContactListViewModel.instance;
  }

  // ==================== 初始化 & 数据加载 ====================
  public async init(): Promise<void> {
    this.isLoading = true;
    hilog.info(DOMAIN, TAG, '⭐ ContactListViewModel init() started');
    try {
      // 1. 优先从 CoreService 缓存加载（即时显示）
      const cachedContacts = this.contactService.getCachedContacts();
      hilog.info(DOMAIN, TAG, `⭐ Cached contacts count: ${cachedContacts.length}`);
      if (cachedContacts.length > 0) {
        hilog.info(DOMAIN, TAG, `Loaded ${cachedContacts.length} contacts from cache`);
        this.contacts = cachedContacts;
        this.contactMap.clear();
        for (const contact of this.contacts) {
          this.contactMap.set(contact.id, contact);
        }
        this.sortAndRefresh();
      }

      // 2. 如果缓存为空或未初始化，异步从网络加载
      if (!this.contactService.isContactsInitialized() || cachedContacts.length === 0) {
        hilog.info(DOMAIN, TAG, 'Cache empty or not initialized, loading from network...');
        await this.loadContactsFromNetwork();
      } else {
        // 3. 后台刷新网络数据（静默更新）
        hilog.info(DOMAIN, TAG, 'Background refreshing from network...');
        this.loadContactsFromNetwork().catch((err: Error) => {
          hilog.warn(DOMAIN, TAG, `Background refresh failed: ${err.message}`);
        });
      }

      hilog.info(DOMAIN, TAG, `Init completed with ${this.contacts.length} contacts`);
    } catch (error) {
      ErrorHandler.getInstance().handle(error);
    } finally {
      this.isLoading = false;
    }
  }

  private async loadContactsFromNetwork(): Promise<void> {
    try {
      const tdlibContacts = await this.contactService.getContacts();
      hilog.info(DOMAIN, TAG, `Got ${tdlibContacts.length} contacts from service`);
      this.contacts = tdlibContacts;
      this.contactMap.clear();
      for (const contact of this.contacts) {
        this.contactMap.set(contact.id, contact);
      }
      this.sortAndRefresh();
    } catch (error) {
      hilog.error(DOMAIN, TAG, `loadContactsFromNetwork failed: ${error}`);
    }
  }

  private async loadContacts(): Promise<void> {
    try {
      const tdlibContacts = await this.contactService.getContacts();
      this.contacts = tdlibContacts;
      this.contactMap.clear();
      for (const contact of this.contacts) {
        this.contactMap.set(contact.id, contact);
      }
      this.sortAndRefresh();
    } catch (error) {
      hilog.error(DOMAIN, TAG, `loadContacts failed: ${error}`);
    }
  }

  /**
   * ⭐ 刷新联系人列表（用于页面重新显示时）
   */
  public refreshContacts(): void {
    hilog.info(DOMAIN, TAG, '🔄 refreshContacts called');
    // 从缓存获取最新联系人
    const cachedContacts = this.contactService.getCachedContacts();
    if (cachedContacts.length > 0) {
      this.contacts = cachedContacts;
      this.contactMap.clear();
      for (const contact of this.contacts) {
        this.contactMap.set(contact.id, contact);
      }
      this.sortAndRefresh();
      hilog.info(DOMAIN, TAG, `✅ refreshContacts completed: ${cachedContacts.length} contacts`);
    } else {
      hilog.warn(DOMAIN, TAG, '⚠️ No cached contacts, triggering network load');
      // 如果缓存为空，触发网络加载
      this.loadContactsFromNetwork().catch((err: Error) => {
        hilog.warn(DOMAIN, TAG, `Network refresh failed: ${err.message}`);
      });
    }
  }

  private mergeContacts(dbContacts: Contact[], tdlibContacts: Object[]): Contact[] {
    const map = new Map<number, Contact>();
    for (const legacy of tdlibContacts) {
      const obj = legacy as Record<string, Object>;
      const username = obj['username'] as string;
      const usernamesObj: Usernames | undefined = username ? {
        _: 'usernames',
        active_usernames: [username],
        disabled_usernames: [],
        editable_username: username,
        collectible_usernames: []
      } : undefined;
      
      const contact: Contact = {
        id: (obj['id'] as number) || (obj['userId'] as number) || 0,
        userId: (obj['userId'] as number) || (obj['id'] as number) || 0,
        firstName: (obj['firstName'] as string) || '',
        lastName: (obj['lastName'] as string) || '',
        phone: (obj['phone'] as string) || '',
        usernames: usernamesObj,
        avatarPath: (obj['avatar'] as string) || '',
        isVerified: (obj['isVerified'] as boolean) || false,
        isBot: (obj['isBot'] as boolean) || false,
        mutualChats: (obj['mutualChats'] as number) || 0,
        fullName: `${(obj['firstName'] as string) || ''} ${(obj['lastName'] as string) || ''}`.trim(),
        status: { _: 'userStatusEmpty' },
        isPremium: false,
        phones: [],
        emails: [],
        syncSource: 'tdlib',
        lastUpdated: Date.now(),
        syncStatus: SyncStatus.SYNCED,
        isFavorite: false,
        displayOrder: 0,
        sectionKey: ((obj['firstName'] as string) || '').charAt(0).toUpperCase()
      };
      map.set(contact.id, contact);
    }
    for (const contact of dbContacts) {
      if (!map.has(contact.id)) {
        map.set(contact.id, contact);
      }
    }
    return Array.from(map.values());
  }

  public async searchContacts(keyword: string): Promise<void> {
    if (!keyword.trim()) {
      await this.loadContacts();
      return;
    }
    try {
      const result = await this.contactService.searchContacts(keyword);
      const allContacts: Contact[] = [];
      if (result.contacts) {
        const contacts: Contact[] = result.contacts;
        for (const c of contacts) {
          allContacts.push(c);
        }
      }
      if (result.globalContacts) {
        const globalContacts: Contact[] = result.globalContacts;
        for (const c of globalContacts) {
          allContacts.push(c);
        }
      }
      this.contacts = allContacts;
      this.contactMap.clear();
      for (const contact of this.contacts) {
        this.contactMap.set(contact.id, contact);
      }
      this.sortAndRefresh();
    } catch (error) {
      hilog.error(DOMAIN, TAG, `searchContacts failed: ${error}`);
    }
  }

  public clearSearch(): void {
    this.loadContacts();
  }

  private sortAndRefresh(): void {
    if (this.sortDebounceTimer !== -1) clearTimeout(this.sortDebounceTimer);
    this.sortDebounceTimer = setTimeout(() => {
      this.contacts.sort((a: Contact, b: Contact) => a.fullName.localeCompare(b.fullName));
      this.updateUIItems();
      this.sortDebounceTimer = -1;
    }, SORT_DEBOUNCE_DELAY);
  }

  private updateUIItems(): void {
    const items: ContactItemDisplay[] = [];
    for (const contact of this.contacts) {
      const display = new ContactItemDisplay();
      display.id = contact.id;
      display.fullName = contact.fullName;
      // ⭐ 处理头像路径，确保格式正确
      let avatarPath = contact.avatarPath || '';
      const originalPath = avatarPath;
      if (avatarPath && !avatarPath.startsWith('file://') && avatarPath.startsWith('/')) {
        avatarPath = 'file://' + avatarPath;
      }
      display.avatarPath = avatarPath;
      hilog.info(DOMAIN, TAG, `Contact ${contact.id} (${contact.fullName}) avatar: "${originalPath}" -> "${avatarPath}"`);
      display.statusText = this.getStatusText(contact);
      display.statusColor = this.getStatusColor(contact);
      display.isBot = contact.isBot;
      items.push(display);
      
      // ⭐ 如果头像为空且有 avatarFileId，触发异步下载
      if (!avatarPath && contact.avatarFileId && contact.avatarFileId > 0) {
        this.triggerAvatarDownload(contact.avatarFileId, contact.id);
      }
    }
    this.contactItems = items;
    // 派发更新事件，通知 UI 层同步
    const payload: Record<string, number> = {};
    payload['count'] = items.length;
    this.eventBus.emit('contactListUpdated', payload);
  }
  
  /**
   * ⭐ 触发头像异步下载
   */
  private triggerAvatarDownload(fileId: number, userId: number): void {
    // 检查 FileDownloadService 是否已初始化
    if (!this.fileDownloadService) {
      hilog.warn(DOMAIN, TAG, `FileDownloadService not initialized, skipping avatar download for user ${userId}`);
      return;
    }

    // 避免重复下载
    if (this.avatarDownloadQueue.has(userId)) {
      return;
    }

    this.avatarDownloadQueue.set(userId, fileId);
    hilog.info(DOMAIN, TAG, `Triggering avatar download for user ${userId}, fileId: ${fileId}`);

    this.fileDownloadService.downloadFile(
      fileId,
      FileType.PROFILE_PHOTO,
      DownloadPriority.NORMAL
    ).then((path: string) => {
      hilog.info(DOMAIN, TAG, `✅ Avatar downloaded for user ${userId}: ${path}`);
      // 更新联系人头像路径
      const contact = this.contactMap.get(userId);
      if (contact) {
        contact.avatarPath = path;
        this.updateUIItems();
      }
      this.avatarDownloadQueue.delete(userId);
    }).catch((err: Error) => {
      hilog.warn(DOMAIN, TAG, `⚠️ Avatar download failed for user ${userId}: ${err.message}`);
      this.avatarDownloadQueue.delete(userId);
    });
  }

  private getStatusText(contact: Contact): string {
    if (contact.phone && !contact.status) return contact.phone;
    if (!contact.status) return '离线';
    const statusType = contact.status._;
    if (statusType === 'userStatusOnline') return '在线';
    if (statusType === 'userStatusOffline') return '离线';
    if (statusType === 'userStatusRecently') return '最近上线';
    if (statusType === 'userStatusLastWeek') return '上周上线';
    if (statusType === 'userStatusLastMonth') return '上月上线';
    return '离线';
  }

  private getStatusColor(contact: Contact): string {
    if (!contact.status) return '#8E8E93';
    const statusType = contact.status._;
    if (statusType === 'userStatusOnline') return '#4CAF50';
    return '#8E8E93';
  }

  /**
   * 获取用户状态类型的辅助函数
   */
  // getUserStatusType 方法已移除，直接使用 status._

  // ==================== CoreService 领域事件处理 ====================
  private handleCoreUserUpdate = (data?: Object): void => {
    if (!data) return;
    const userId = (data as Record<string, Object>)['userId'] as number;
    if (!userId) return;
    
    // 刷新该联系人的信息
    const contact = this.contactMap.get(userId);
    if (contact) {
      hilog.info(DOMAIN, TAG, `core:userUpdated for contact ${userId}`);
      // 重新加载联系人信息
      this.refreshContact(userId);
    }
  };

  private handleCoreUserStatus = (data?: Object): void => {
    if (!data) return;
    const userId = (data as Record<string, Object>)['userId'] as number;
    const status = (data as Record<string, Object>)['status'] as Record<string, Object> | undefined;
    if (!userId || !status) return;
    
    // 更新联系人在线状态
    const contact = this.contactMap.get(userId);
    if (contact) {
      const statusType = status['@type'] as string;
      hilog.debug(DOMAIN, TAG, `core:userStatusUpdated for contact ${userId}: ${statusType}`);
      // 更新状态并刷新 UI
      this.updateContactStatus(userId, status);
    }
  };

  private handleCoreAvatarDownloaded = (data?: Object): void => {
    if (!data) return;
    const fileId = (data as Record<string, Object>)['fileId'] as number;
    const path = (data as Record<string, Object>)['path'] as string;
    
    if (!fileId || !path) return;
    
    hilog.info(DOMAIN, TAG, `core:avatarDownloaded: fileId=${fileId}, path=${path}`);
    
    // 查找需要更新头像的联系人
    let needsRefresh = false;
    for (const contact of this.contacts) {
      if (contact.avatarFileId === fileId || this.avatarDownloadQueue.get(contact.id) === fileId) {
        contact.avatarPath = path;
        hilog.info(DOMAIN, TAG, `Updated avatar for contact ${contact.id} (${contact.fullName}): ${path}`);
        needsRefresh = true;
      }
    }
    
    if (needsRefresh) {
      this.updateUIItems();
    }
  };

  /**
   * 刷新指定联系人信息
   */
  private async refreshContact(userId: number): Promise<void> {
    try {
      const contactResult = await this.contactService.getContactById(userId);
      if (contactResult) {
        // ArkTS: 使用 Object 类型转换避免结构类型错误
        this.contactMap.set(userId, contactResult as Object as Contact);
        this.updateUIItems();
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to refresh contact ${userId}: ${error}`);
    }
  }

  /**
   * 更新联系人在线状态
   */
  private updateContactStatus(userId: number, status: Record<string, Object>): void {
    const contact = this.contactMap.get(userId);
    if (contact) {
      // 更新状态（简化处理，实际应根据 status 对象完整更新）
      this.updateUIItems();
    }
  }

  private handleCoreNewContact = (data?: Object): void => {
    if (!data) return;
    const userId = (data as Record<string, Object>)['userId'] as number;
    if (userId) {
      hilog.info(DOMAIN, TAG, `core:newContact for user ${userId}`);
      // 重新加载联系人列表
      this.loadContacts();
    }
  };

  private handleCoreUserFullInfo = (data?: Object): void => {
    if (!data) return;
    const userId = (data as Record<string, Object>)['userId'] as number;
    if (userId) {
      hilog.info(DOMAIN, TAG, `core:userFullInfoUpdated for user ${userId}`);
      // 刷新该联系人
      this.refreshContact(userId);
    }
  };

  private handleCoreContactsUpdate = (data?: Object): void => {
    hilog.info(DOMAIN, TAG, 'core:contactsUpdated received, reloading...');
    this.loadContacts();
  };

  private registerTDLibEventListeners(): void {
    // ⭐ 使用 CoreService 领域事件替代 TDLib 原始事件
    this.eventBus.on('core:userUpdated', this.handleCoreUserUpdate);
    this.eventBus.on('core:userStatusUpdated', this.handleCoreUserStatus);
    this.eventBus.on('core:avatarDownloaded', this.handleCoreAvatarDownloaded);
    // ⭐ 使用 CoreService 领域事件替代 TDLib 原始事件
    this.eventBus.on('core:newContact', this.handleCoreNewContact);
    this.eventBus.on('core:userFullInfoUpdated', this.handleCoreUserFullInfo);
    this.eventBus.on('core:contactsUpdated', this.handleCoreContactsUpdate);
  }

  private unregisterEventListeners(): void {
    this.eventBus.off('core:userUpdated', this.handleCoreUserUpdate);
    this.eventBus.off('core:userStatusUpdated', this.handleCoreUserStatus);
    this.eventBus.off('core:avatarDownloaded', this.handleCoreAvatarDownloaded);
    this.eventBus.off('core:newContact', this.handleCoreNewContact);
    this.eventBus.off('core:userFullInfoUpdated', this.handleCoreUserFullInfo);
    this.eventBus.off('core:contactsUpdated', this.handleCoreContactsUpdate);
  }

  // ==================== 业务操作 ====================
  public async addContact(): Promise<void> {
    // 跳转由 Page 处理，这里只是占位
  }

  public async inviteFriend(): Promise<void> {
    // 跳转由 Page 处理
  }

  public getContactById(id: number): Contact | undefined {
    return this.contactMap.get(id);
  }

  public cleanup(): void {
    this.unregisterEventListeners();
    this.contacts = [];
    this.contactMap.clear();
    this.contactItems = [];
    this.isLoading = false;
    if (this.sortDebounceTimer !== -1) clearTimeout(this.sortDebounceTimer);
  }
}