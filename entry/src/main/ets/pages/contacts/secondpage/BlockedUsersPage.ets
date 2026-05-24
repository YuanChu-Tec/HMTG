import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction } from '@kit.ArkUI';
import { router } from '@kit.ArkUI';
import { TDLibClient } from '../../../services/core';
import { TdApiFactory } from '../../../services/api/factory/TdApiFactory';

/**
 * 拉黑用户信息接口
 */
export interface BlockedUserInfo {
  id: number;
  userId: number;
  firstName: string;
  lastName?: string;
  username?: string;
  avatar?: string;
  blockedTime: number;
}

/**
 * 拉黑用户列表页面
 * 显示所有被拉黑的用户，支持解除拉黑
 */
@Entry
@ComponentV2
struct BlockedUsersPage {
  @Local blockedUsers: BlockedUserInfo[] = [];
  @Local isLoading: boolean = true;
  @Local showUnblockDialog: boolean = false;
  @Local selectedUser: BlockedUserInfo | null = null;

  private readonly TAG = 'BlockedUsersPage';
  private readonly DOMAIN = 0x0001;
  private tdClient: TDLibClient | null = null;

  aboutToAppear(): void {
    // 初始化 TDLib 客户端
    const factory = TdApiFactory.getInstance();
    this.tdClient = factory.getTdClient();
    this.loadBlockedUsers();
  }

  /**
   * 加载拉黑用户列表
   */
  private async loadBlockedUsers(): Promise<void> {
    if (!this.tdClient) {
      hilog.error(this.DOMAIN, this.TAG, 'TDLib client not initialized');
      promptAction.showToast({
        message: '服务未初始化，请重试',
        duration: 2000
      });
      this.isLoading = false;
      return;
    }

    this.isLoading = true;
    try {
      // 使用 TDLib 的 getBlockedUsers API 获取被屏蔽的用户列表
      const params: Record<string, Object> = {
        '@type': 'getBlockedUsers',
        'offset': 0,
        'limit': 100
      };
      const result = await this.tdClient.execute<Record<string, Object>>(params);

      if (result && (result as Record<string, Object>)['user_ids']) {
        const userIds: number[] = (result as Record<string, Object>)['user_ids'] as number[];
        const blockedUsersList: BlockedUserInfo[] = [];

        // 遍历 user_ids 获取用户详细信息
        for (const userId of userIds) {
          try {
            const userParams: Record<string, Object> = {
              '@type': 'getUser',
              'user_id': userId
            };
            const userResult = await this.tdClient.execute<Record<string, Object>>(userParams);

            if (userResult) {
              const userObj = userResult as Record<string, Object>;
              blockedUsersList.push({
                id: userId,
                userId: userId,
                firstName: (userObj['first_name'] as string) || '',
                lastName: (userObj['last_name'] as string) || '',
                username: (userObj['username'] as string) || '',
                avatar: '',
                blockedTime: Date.now()
              });
            }
          } catch (error) {
            hilog.warn(this.DOMAIN, this.TAG, `获取用户信息失败 userId=${userId}: ${JSON.stringify(error)}`);
          }
        }

        this.blockedUsers = blockedUsersList;
      }
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `加载拉黑用户列表失败: ${JSON.stringify(error)}`);
      promptAction.showToast({
        message: '加载失败，请重试',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 解除拉黑用户
   */
  private async unblockUser(): Promise<void> {
    if (!this.selectedUser) {
      return;
    }

    if (!this.tdClient) {
      hilog.error(this.DOMAIN, this.TAG, 'TDLib client not initialized');
      promptAction.showToast({
        message: '服务未初始化，请重试',
        duration: 2000
      });
      this.showUnblockDialog = false;
      this.selectedUser = null;
      return;
    }

    try {
      const params: Record<string, Object> = {
        '@type': 'unblockUser',
        'user_id': this.selectedUser.userId,
        'only_if_none': false
      };
      await this.tdClient.execute<Record<string, Object>>(params);

      // 从列表中移除
      this.blockedUsers = this.blockedUsers.filter(
        user => user.userId !== this.selectedUser?.userId
      );

      promptAction.showToast({
        message: '已解除拉黑',
        duration: 2000
      });
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `解除拉黑失败: ${JSON.stringify(error)}`);
      promptAction.showToast({
        message: '操作失败，请重试',
        duration: 2000
      });
    }

    this.showUnblockDialog = false;
    this.selectedUser = null;
  }

  /**
   * 显示解除拉黑确认对话框
   */
  private showUnblockConfirm(user: BlockedUserInfo): void {
    this.selectedUser = user;
    this.showUnblockDialog = true;
  }

  /**
   * 导航到用户详情页
   */
  private navigateToUserDetail(userId: number): void {
    router.pushUrl({
      url: 'pages/ContactDetailPage',
      params: { contactId: userId }
    });
  }

  /**
   * 构建头部
   */
  @Builder
  buildHeader() {
    Row() {
      Text('<')
        .fontSize(24)
        .fontColor('#333333')
        .onClick(() => {
          router.back();
        });

      Text('已拉黑')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .margin({ left: 16 });
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .border({ width: { bottom: 0.5 }, color: '#E0E0E0' });
  }

  /**
   * 构建拉黑用户列表项
   */
  @Builder
  buildUserItem(user: BlockedUserInfo) {
    Row({ space: 12 }) {
      // 头像
      Column() {
        if (user.avatar) {
          Image(user.avatar)
            .width(48)
            .height(48)
            .borderRadius(24);
        } else {
          Column()
            .width(48)
            .height(48)
            .borderRadius(24)
            .backgroundColor('#E0E0E0');
        }
      }
      .width(48)
      .height(48)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center);

      // 用户信息
      Column({ space: 4 }) {
        Text(`${user.firstName} ${user.lastName || ''}`.trim() || user.username || 'Unknown')
          .fontSize(16)
          .fontColor('#333333');

        if (user.username) {
          Text(`@${user.username}`)
            .fontSize(14)
            .fontColor('#666666');
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      // 解除拉黑按钮
      Text('解除')
        .fontSize(14)
        .fontColor('#FF5252')
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .borderRadius(4)
        .border({ width: 1, color: '#FF5252' })
        .onClick(() => this.showUnblockConfirm(user));
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .onClick(() => this.navigateToUserDetail(user.userId));
  }

  build() {
    Column() {
      // 头部
      this.buildHeader();

      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999999');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else if (this.blockedUsers.length === 0) {
        Column() {
          Text('暂无拉黑用户')
            .fontSize(16)
            .fontColor('#999999');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else {
        List() {
          ForEach(this.blockedUsers, (user: BlockedUserInfo) => {
            ListItem() {
              this.buildUserItem(user);
            }
          });
        }
        .width('100%')
        .layoutWeight(1)
        .divider({
          strokeWidth: 0.5,
          color: '#E0E0E0',
          startMargin: 76,
          endMargin: 0
        });
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }
}
