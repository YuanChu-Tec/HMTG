// ProfilePage.ets
import { LoadingIndicator, Avatar } from '../ui_kit';
import { router, promptAction, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ProfilePageViewModel } from '../viewmodels/ProfilePageViewModel';
import { ErrorHandler } from '../utils/error/ErrorHandler';
import { MainTopBar } from '../ui_kit/components/MainTopBar';

const TAG = 'ProfilePage';
const DOMAIN = 0x0001;
const BOTTOM_PADDING = 80;

@Entry
@ComponentV2
export struct ProfilePage {
  @Local viewModel: ProfilePageViewModel = new ProfilePageViewModel();
  @Local topSafeHeight: number = 0;

  // ==================== 辅助方法 ====================
  private getAvatarColor(title: string): string {
    const colors = ['#FF6B35', '#007AFF', '#4CAF50', '#FFA500', '#9C27B0', '#FA2A2D', '#00BCD4', '#E91E63', '#8BC34A', '#FF5722', '#3F51B5', '#009688'];
    let hash = 0;
    for (let i = 0; i < title.length; i++) hash = title.charCodeAt(i) + ((hash << 5) - hash);
    return colors[Math.abs(hash) % colors.length];
  }

  aboutToAppear(): void {
    hilog.info(DOMAIN, TAG, '⭐ ProfilePage aboutToAppear called');
    this.loadSafeAreaHeight();
    this.viewModel.loadUserInfo();
    hilog.info(DOMAIN, TAG, '⭐ ProfilePage loadUserInfo() completed');
  }

  /**
   * 动态获取状态栏高度，用于根容器 padding 避让
   */
  private loadSafeAreaHeight(): void {
    try {
      const win = window.getLastWindow(getContext(this));
      win.then((windowClass: window.Window) => {
        const avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        if (avoidArea && avoidArea.topRect) {
          this.topSafeHeight = px2vp(avoidArea.topRect.height);
        }
      }).catch(() => {
        this.topSafeHeight = 24;
      });
    } catch (e) {
      this.topSafeHeight = 24;
    }
  }

  aboutToDisappear(): void {
    this.viewModel.cleanup();
  }

  private editInfoPlaceholder(): void {
    // 触发编辑模式
    this.viewModel.toggleEditMode();
  }

  // ==================== UI 构建 ====================
  @Builder
  private buildTopArea() {
    Column() {
      Avatar({
        source: this.viewModel.userInfo?.profilePhoto ?? '',
        name: `${this.viewModel.userInfo?.firstName || ''} ${this.viewModel.userInfo?.lastName || ''}`.trim() || '用户',
        avatarSize: 80,
        fontSize: 40,
        avatarBackgroundColor: this.getAvatarColor(`${this.viewModel.userInfo?.firstName || ''} ${this.viewModel.userInfo?.lastName || ''}`.trim() || '用户'),
        radius: 40
      })
        .margin({ top: 12, bottom: 12 })

      Text(`${this.viewModel.userInfo?.firstName || ''} ${this.viewModel.userInfo?.lastName || ''}`.trim())
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor('#000000')
        .margin({ bottom: 4 })

      Text(this.viewModel.userInfo?.statusText || '离线')
        .fontSize(14)
        .fontColor(this.viewModel.userInfo?.isOnline ? '#007AFF' : '#8E8E93')
        .margin({ bottom: 20 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildActionButtons() {
    Row({ space: 12 }) {
      Column() {
        this.buildActionButton('设置照片', $r('sys.media.ohos_ic_public_camera'), () => this.viewModel.changeAvatar())
      }
      .layoutWeight(1)
      .padding({ top: 12, bottom: 12 })
      .backgroundColor(Color.White)
      .borderRadius(12)

      Column() {
        this.buildActionButton('编辑信息', $r('sys.media.ohos_ic_public_edit'), () => this.editInfoPlaceholder())
      }
      .layoutWeight(1)
      .padding({ top: 12, bottom: 12 })
      .backgroundColor(Color.White)
      .borderRadius(12)
      .onClick(() => this.editInfoPlaceholder())
    }
    .width('92%')
    .margin({ left: 16, right: 16, bottom: 16 })
  }

  @Builder
  private buildActionButton(title: string, icon: ResourceStr | string, onClick: () => void) {
    Column() {
      if (typeof icon === 'string' && icon.length === 1) {
        Text(icon)
          .width(24)
          .height(24)
          .fontSize(20)
          .margin({ bottom: 6 })
      } else {
        Image(icon as ResourceStr)
          .width(24)
          .height(24)
          .fillColor('#007AFF')
          .margin({ bottom: 6 })
      }
      Text(title)
        .fontSize(12)
        .fontColor('#8E8E93')
    }
    .onClick(onClick)
  }

  @Builder
  private buildInfoRow(label: string, value: string, showCopy?: boolean, onCopy?: () => void) {
    if (value) {
      Row() {
        Text(label)
          .fontSize(16)
          .fontColor('#8E8E93')
          .width(80)
        Text(value)
          .fontSize(16)
          .fontColor('#000000')
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        if (showCopy) {
          Image($r('sys.media.ohos_ic_public_copy'))
            .width(20)
            .height(20)
            .fillColor('#8E8E93')
            .onClick(onCopy)
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
    }
  }

  @Builder
  private buildInfoList() {
    Column() {
      if (this.viewModel.userInfo?.phoneNumber) {
        this.buildInfoRow('手机', this.viewModel.userInfo.phoneNumber, true, () =>
        this.viewModel.copyText(this.viewModel.userInfo!.phoneNumber, $r('app.string.username_copied')))
        Divider().color('#E5E5EA').strokeWidth(0.5).margin({ left: 16 })
      } else {
        this.buildInfoRow('手机', '未知')
        Divider().color('#E5E5EA').strokeWidth(0.5).margin({ left: 16 })
      }

      if (this.viewModel.userInfo?.bio) {
        this.buildInfoRow('个人简介', this.viewModel.userInfo.bio)
        Divider().color('#E5E5EA').strokeWidth(0.5).margin({ left: 16 })
      } else {
        this.buildInfoRow('个人简介', '未知')
        Divider().color('#E5E5EA').strokeWidth(0.5).margin({ left: 16 })
      }

      if (this.viewModel.userInfo?.username) {
        this.buildInfoRow('用户名', `@${this.viewModel.userInfo.username}`, true, () =>
        this.viewModel.copyText(`@${this.viewModel.userInfo!.username}`, $r('app.string.username_copied')))
        Divider().color('#E5E5EA').strokeWidth(0.5).margin({ left: 16 })
      } else {
        this.buildInfoRow('用户名', '未知')
        Divider().color('#E5E5EA').strokeWidth(0.5).margin({ left: 16 })
      }

      if (this.viewModel.userInfo?.birthday) {
        this.buildInfoRow('生日', this.viewModel.userInfo.birthday)
      } else {
        this.buildInfoRow('生日', '未知')
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16, bottom: 12 })
  }

  @Builder
  private buildTabs() {
    Tabs({ barPosition: BarPosition.Start, index: this.viewModel.currentTabIndex }) {
      TabContent() {
        this.buildStoryContent('动态')
      }
      .tabBar(this.buildTabBarItem('动态', 0))

      TabContent() {
        this.buildStoryContent('已归档的动态')
      }
      .tabBar(this.buildTabBarItem('已归档的动态', 1))
    }
    .barHeight(44)
    .animationDuration(300)
    .onChange((index: number) => { this.viewModel.currentTabIndex = index })
    .width('100%')
    .backgroundColor(Color.White)
  }

  @Builder
  private buildTabBarItem(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(this.viewModel.currentTabIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.viewModel.currentTabIndex === index ? '#007AFF' : '#8E8E93')
      Divider()
        .height(2)
        .width('50%')
        .backgroundColor(this.viewModel.currentTabIndex === index ? '#007AFF' : Color.Transparent)
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  private buildStoryContent(type: string) {
    Column() {
      Text('📝')
        .width(80)
        .height(80)
        .fontSize(50)
        .opacity(0.3)
        .margin({ top: 60, bottom: 16 })
      Text('暂无贴文')
        .fontSize(16)
        .fontColor('#8E8E93')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildEditForm() {
    Column() {
      Column() {
        Row() {
          Text('名字')
            .fontSize(16)
            .fontColor('#8E8E93')
            .width(80)
          TextInput({ text: this.viewModel.editFirstName, placeholder: '名字' })
            .fontSize(16)
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .border({ width: 0 })
            .onChange(v => this.viewModel.editFirstName = v)
        }
        .padding(16)
        Divider().color('#E5E5EA').strokeWidth(0.5).margin({ left: 16 })

        Row() {
          Text('姓氏')
            .fontSize(16)
            .fontColor('#8E8E93')
            .width(80)
          TextInput({ text: this.viewModel.editLastName, placeholder: '姓氏' })
            .fontSize(16)
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .border({ width: 0 })
            .onChange(v => this.viewModel.editLastName = v)
        }
        .padding(16)
        Divider().color('#E5E5EA').strokeWidth(0.5).margin({ left: 16 })

        Column() {
          Text('个人简介')
            .fontSize(16)
            .fontColor('#8E8E93')
            .width('100%')
            .margin({ bottom: 8 })
          TextArea({ text: this.viewModel.editBio, placeholder: '个人简介' })
            .fontSize(16)
            .backgroundColor(Color.Transparent)
            .border({ width: 0 })
            .onChange(v => this.viewModel.editBio = v)
            .maxLines(5)
        }
        .padding(16)
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ bottom: 24 })

      Button('保存')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#007AFF')
        .borderRadius(12)
        .onClick(() => this.viewModel.saveProfile())
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  @Builder
  private buildQRCodeModal() {
    Column() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => this.viewModel.closeQRCode())
      Column() {
        Text('扫码关注')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 24 })
        if (this.viewModel.qrCodePixelMap) {
          Image(this.viewModel.qrCodePixelMap)
            .width(300)
            .height(300)
            .borderRadius(12)
            .margin({ bottom: 16 })
        }
        Text(this.viewModel.qrContent)
          .fontSize(14)
          .fontColor('#8E8E93')
          .maxLines(1)
          .margin({ bottom: 24 })
        Button('关闭')
          .width(120)
          .height(40)
          .backgroundColor('#007AFF')
          .borderRadius(20)
          .onClick(() => this.viewModel.closeQRCode())
      }
      .width(320)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .padding(24)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        // ⭐ 内容区：全尺寸铺满 Stack，滚动到顶部栏后方实现沉浸模糊效果
        if (this.viewModel.isLoading) {
          Column() {
            LoadingIndicator({ indicatorSize: 40, color: '#007AFF' })
            Text('加载中...').fontSize(14).fontColor('#8E8E93').margin({ top: 16 })
          }
          .width('100%')
          .height('100%')
          .padding({ top: 56 + this.topSafeHeight })
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column() {
              this.buildTopArea()
              this.buildActionButtons()
              this.buildInfoList()
              this.buildTabs()
            }
            .width('100%')
            .padding({ bottom: BOTTOM_PADDING })
          }
          .width('100%')
          .height('100%')
          .padding({ top: 56 + this.topSafeHeight })
          .backgroundColor('#F5F5F5')
          .scrollBar(BarState.Auto)
        }

        // ⭐ 顶部栏：浮层叠加在内容上方，毛玻璃效果模糊列表内容
        MainTopBar({
          title: '个人主页',
          icons: [
            { name: 'more', action: () => this.openSettingsPage() }
          ],
          immersiveTopPadding: this.topSafeHeight
        })

        // ⭐ 编辑弹窗覆盖层
        if (this.viewModel.isEditing) {
          Stack({ alignContent: Alignment.Center }) {
            Column() {
              this.buildEditForm()
            }
            .width('90%')
            .backgroundColor(Color.White)
            .borderRadius(16)
            .shadow({ radius: 10, color: 'rgba(0,0,0,0.2)', offsetY: 4 })
          }
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => this.viewModel.toggleEditMode())
        }

        // ⭐ 二维码弹窗覆盖层
        if (this.viewModel.showQRCode) {
          this.buildQRCodeModal()
        }
      }
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  /**
   * 打开设置页面（由 MainTopBar more 图标触发）
   */
  private openSettingsPage(): void {
    router.pushUrl({ url: 'pages/settings/SettingsPage' })
      .catch((e: Error) => ErrorHandler.getInstance().handle(e));
  }
}
