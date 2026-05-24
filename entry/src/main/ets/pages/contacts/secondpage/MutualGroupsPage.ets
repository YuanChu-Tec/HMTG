/**
 * 共同群组页面
 * @module feature-contacts.pages
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { CoreService } from '../../../services/business/CoreService';

/**
 * 共同群组项
 */
interface MutualGroupItem {
  id: number;
  title: string;
  memberCount: number;
  photoPath?: string;
}

/**
 * 共同群组列表页面
 */
@Entry
@ComponentV2
struct MutualGroupsPage {
  @Local userId: number = 0;
  @Local userName: string = '';
  @Local groups: MutualGroupItem[] = [];
  @Local isLoading: boolean = true;
  @Local errorMessage: string = '';

  private readonly TAG = 'MutualGroupsPage';
  private readonly DOMAIN = 0x0001;
  private contactService: CoreService = CoreService.getInstance();

  /**
   * 提取照片路径
   */
  private extractPhotoPath(photo: Record<string, Object> | undefined): string | undefined {
    if (!photo) {
      return undefined;
    }
    const small = photo['small'] as Record<string, Object> | undefined;
    if (small) {
      return small['path'] as string | undefined;
    }
    return undefined;
  }

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    this.userId = params['userId'] as number || 0;
    this.userName = params['userName'] as string || '';

    if (this.userId === 0) {
      this.errorMessage = '用户ID无效';
      this.isLoading = false;
      promptAction.showToast({
        message: '参数错误',
        duration: 2000
      });
      setTimeout(() => {
        router.back();
      }, 1500);
    } else {
      this.loadMutualGroups();
    }
  }

  /**
   * 加载共同群组
   */
  private async loadMutualGroups(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      const groupChats = await this.contactService.getMutualGroups(this.userId, 0, 100);

      this.groups = groupChats.map((chat: Object) => {
        const chatRecord = chat as Record<string, Object>;
        const type = chatRecord['type'] as Record<string, Object> || {};
        const memberCount = type['member_count'] as number || 0;

        return {
          id: chatRecord['id'] as number,
          title: (chatRecord['title'] as string) || '未命名群组',
          memberCount: memberCount,
          photoPath: this.extractPhotoPath(chatRecord['photo'] as Record<string, Object> | undefined)
        } as MutualGroupItem;
      });

      hilog.info(this.DOMAIN, this.TAG, `加载了 ${this.groups.length} 个共同群组`);
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `加载共同群组失败: ${JSON.stringify(error)}`);
      this.errorMessage = '加载失败，请重试';
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 进入群组聊天
   */
  private async openGroupChat(groupId: number): Promise<void> {
    try {
      await router.pushUrl({
        url: 'feature-chat/pages/ChatDetailPage',
        params: {
          chatId: groupId,
          chatType: 'group'
        }
      });
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, `打开群组聊天失败: ${JSON.stringify(error)}`);
      promptAction.showToast({
        message: '打开失败',
        duration: 2000
      });
    }
  }

  /**
   * 构建群组列表项
   */
  @Builder
  buildGroupItem(group: MutualGroupItem) {
    Row() {
      // 群组头像
      if (group.photoPath) {
        Image(group.photoPath)
          .width(48)
          .height(48)
          .borderRadius(24)
          .objectFit(ImageFit.Cover)
      } else {
        Circle()
          .width(48)
          .height(48)
          .fill('#E0E0E0')
          .margin({ left: 0 })

        Text('群')
          .fontSize(18)
          .fontColor('#999999')
          .position({ x: 24, y: 12 })
      }

      // 群组信息
      Column() {
        Text(group.title)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`${group.memberCount} 名成员`)
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      // 箭头图标
      Image('/common/media/chevron_right.svg')
        .width(20)
        .height(20)
        .fillColor('#CCCCCC')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .onClick(() => {
      this.openGroupChat(group.id);
    })
  }

  /**
   * 构建空状态
   */
  @Builder
  buildEmptyState() {
    Column() {
      Image('/common/media/empty_groups_icon.svg')
        .width(120)
        .height(120)
        .fillColor('#E0E0E0')
        .margin({ bottom: 16 })

      Text('没有共同群组')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ bottom: 8 })

      Text(`你和 ${this.userName} 还没有加入相同的群组`)
        .fontSize(14)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 构建错误状态
   */
  @Builder
  buildErrorState() {
    Column() {
      Image('/common/media/error_icon.svg')
        .width(120)
        .height(120)
        .fillColor('#E0E0E0')
        .margin({ bottom: 16 })

      Text(this.errorMessage)
        .fontSize(16)
        .fontColor('#999999')
        .margin({ bottom: 24 })

      Button('重试')
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#6200EE')
        .height(44)
        .padding({ left: 32, right: 32 })
        .onClick(() => {
          this.loadMutualGroups();
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
            router.back();
          })

        Text('共同群组')
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

      // 内容区域
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
      } else if (this.errorMessage) {
        // 错误状态
        this.buildErrorState()
      } else if (this.groups.length === 0) {
        // 空状态
        this.buildEmptyState()
      } else {
        // 群组列表
        List() {
          ForEach(this.groups, (group: MutualGroupItem) => {
            ListItem() {
              this.buildGroupItem(group)
            }
          }, (group: MutualGroupItem) => group.id.toString())
        }
        .layoutWeight(1)
        .width('100%')
        .divider({
          strokeWidth: 0.5,
          color: '#E0E0E0',
          startMargin: 76,
          endMargin: 16
        })
        .backgroundColor('#F5F5F5')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
