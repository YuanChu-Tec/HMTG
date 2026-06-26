/**
 * 设置页面（Telegram 2026 风格）
 * 应用设置主页
 * 完整集成项目已有功能：
 * - ThemeService: 主题切换、系统监听、颜色管理
 * - TdApi: 用户信息获取、退出登录
 * - ErrorHandler: 统一错误处理
 * - LogService: 日志记录
 * - RoundButton: 设置项交互按钮
 * - expandSafeArea: 沉浸式显示
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { router, promptAction, window } from '@kit.ArkUI';
import { ThemeService } from '../services/business/theme/ChatThemeController';
import { ErrorHandler } from '../utils/error/ErrorHandler';
import { LogService } from '../utils/log/LogService';
import { Avatar } from '../ui_kit';
import { I18n } from '../utils/i18n/I18n';
import { preferences } from '@kit.ArkData';
import { SettingsViewModel } from '../viewmodels/SettingsViewModel';
import { MainTopBar } from '../ui_kit/components/MainTopBar';

const TAG = 'SettingsPage';
const DOMAIN = 0x0001;

/**
 * 设置项接口
 */
interface SettingItem {
  title: string;              // 主标题
  subtitle?: string;          // 副标题（可选）
  icon?: ResourceStr;         // 左侧图标（可选）
  onClick: () => void;        // 点击回调
}

/**
 * 设置分组接口
 */
interface SettingGroup {
  title?: string;             // 分组标题（如“帮助”）
  items: SettingItem[];
}

@Entry
@ComponentV2
export struct SettingsPage {
  @Local viewModel: SettingsViewModel = new SettingsViewModel();
  @Local currentLanguage: string = '简体中文（beta）';
  @Local topSafeHeight: number = 0;

  private themeService: ThemeService = ThemeService.getInstance();

  /**
   * 辅助方法：根据名称生成头像颜色
   */
  private getAvatarColor(title: string): string {
    const colors = ['#FF6B35', '#007AFF', '#4CAF50', '#FFA500', '#9C27B0', '#FA2A2D', '#00BCD4', '#E91E63', '#8BC34A', '#FF5722', '#3F51B5', '#009688'];
    let hash = 0;
    for (let i = 0; i < title.length; i++) hash = title.charCodeAt(i) + ((hash << 5) - hash);
    return colors[Math.abs(hash) % colors.length];
  }

  async aboutToAppear(): Promise<void> {
    hilog.info(DOMAIN, TAG, '⭐ SettingsPage aboutToAppear called');
    this.loadSafeAreaHeight();
    await this.viewModel.initialize();
    await this.loadCurrentLanguage();
    hilog.info(DOMAIN, TAG, '⭐ SettingsPage initialization completed');
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

  onPageShow(): void {
    this.loadCurrentLanguage();
  }

  /**
   * 加载当前语言设置
   */
  private async loadCurrentLanguage(): Promise<void> {
    try {
      // 从 I18n 获取当前语言
      const i18nInstance = I18n.getInstance();
      const locale = i18nInstance.getLocale();
      
      // 尝试从 preferences 读取应用语言设置
      let appLanguage = locale;
      try {
        const context = getContext(this);
        const dataPreferences = await preferences.getPreferences(context, 'app_settings');
        appLanguage = await dataPreferences.get('app_language', locale) as string;
      } catch (error) {
        LogService.getInstance().warn(DOMAIN, TAG, `Failed to read language preference: ${error}`);
      }
      
      // 根据语言代码获取显示名称
      this.currentLanguage = this.getLanguageDisplayName(appLanguage);
      
      LogService.getInstance().debug(DOMAIN, TAG, `Current language loaded: ${appLanguage} -> ${this.currentLanguage}`);
    } catch (error) {
      LogService.getInstance().error(DOMAIN, TAG, `Failed to load current language: ${error}`);
      this.currentLanguage = '简体中文（beta）';
    }
  }

  /**
   * 根据语言代码获取显示名称
   */
  private getLanguageDisplayName(locale: string): string {
    const languageMap: Record<string, string> = {
      'zh_CN': '简体中文',
      'zh_Hant': '繁體中文',
      'en_US': 'English',
      'ru_RU': 'Русский',
      'ar_SA': 'العربية',
      'de_DE': 'Deutsch',
      'es_ES': 'Español',
      'fr_FR': 'Français',
      'it_IT': 'Italiano',
      'ja_JP': '日本語',
      'ko_KR': '한국어',
      'pt_BR': 'Português',
      'tr_TR': 'Türkçe'
    };
    
    const displayName = languageMap[locale];
    return displayName ? `${displayName}（beta）` : `${locale}（beta）`;
  }



  /**
   * 构建设置分组列表
   */
  private getSettingGroups(): SettingGroup[] {
    return [
      // 第一组：账号到语言
      {
        items: [
          { title: '账号', subtitle: '账号，用户名，个人简介', onClick: () => this.openAccountSettings() },
          { title: '聊天设置', subtitle: '壁纸、深色模式、动画效果', onClick: () => this.openChatSettings() },
          { title: '隐私与安全', subtitle: '最后上线时间、登录设备、通行密钥', onClick: () => this.openPrivacySettings() },
          { title: '通知', subtitle: '声音、通话、标记', onClick: () => this.openNotificationSettings() },
          { title: '数据和储存', subtitle: '媒体下载设置', onClick: () => this.openDataSettings() },
          { title: '聊天文件夹', subtitle: '将聊天分类到文件夹中', onClick: () => this.openChatFolders() },
          { title: '设备', subtitle: '管理已连接的设备', onClick: () => this.openDevices() },
          { title: '省电', subtitle: '低电量时降低功耗', onClick: () => this.openPowerSaving() },
          { title: '语言', subtitle: this.currentLanguage, onClick: () => this.openLanguageSettings() },
        ]
      },
      // 第二组：Telegram 高级版等
      {
        items: [
          { title: 'Telegram 高级版', onClick: () => this.openPremium() },
          { title: 'Telegram 星星', onClick: () => this.openStars() },
          { title: 'Telegram 企业版', onClick: () => this.openBusiness() },
          { title: '发送礼物', onClick: () => this.openGifts() },
        ]
      },
      // 第三组：帮助（带分组标题）
      {
        title: '帮助',
        items: [
          { title: '向我们提问', onClick: () => this.openHelp() },
          { title: 'Telegram常见问题', onClick: () => this.openFaq() },
          { title: 'Telegram功能', onClick: () => this.openFeatures() },
          { title: '隐私政策', onClick: () => this.openPrivacyPolicy() },
        ]
      },
      // 👇 新增第四组：捐赠
      {
        items: [
          { title: '捐赠',subtitle: '您的捐赠将帮助我们持续改进', onClick: () => this.openDonation() },
        ]
      }
    ];
  }

  // 各设置项跳转方法（具体实现可根据项目情况调整）
  private async openAccountSettings(): Promise<void> {
    // TODO: AccountSettingsPage 尚未创建
    promptAction.showToast({ message: '页面开发中', duration: 1500 });
  }
  
  private async openChatSettings(): Promise<void> {
    await this.navigateTo('pages/settings/ChatSettingsPage');
  }
  
  private async openPrivacySettings(): Promise<void> {
    await this.navigateTo('pages/settings/PrivacySettingsPage');
  }
  
  private async openNotificationSettings(): Promise<void> {
    await this.navigateTo('pages/settings/NotificationSettingsPage');
  }
  
  private async openDataSettings(): Promise<void> {
    // TODO: DataSettingsPage 尚未创建
    promptAction.showToast({ message: '页面开发中', duration: 1500 });
  }
  
  private async openChatFolders(): Promise<void> {
    // TODO: ChatFoldersPage 尚未创建
    promptAction.showToast({ message: '页面开发中', duration: 1500 });
  }
  
  private async openDevices(): Promise<void> {
    // TODO: DevicesPage 尚未创建
    promptAction.showToast({ message: '页面开发中', duration: 1500 });
  }
  
  private async openPowerSaving(): Promise<void> {
    // TODO: PowerSavingPage 尚未创建
    promptAction.showToast({ message: '页面开发中', duration: 1500 });
  }
  
  private async openLanguageSettings(): Promise<void> {
    await this.navigateTo('pages/settings/LanguageSelectPage');
  }
  private async openPremium(): Promise<void> {
    promptAction.showToast({ message: 'Telegram 高级版', duration: 1500 });
  }
  private async openStars(): Promise<void> {
    promptAction.showToast({ message: 'Telegram 星星', duration: 1500 });
  }
  private async openBusiness(): Promise<void> {
    promptAction.showToast({ message: 'Telegram 企业版', duration: 1500 });
  }
  private async openGifts(): Promise<void> {
    promptAction.showToast({ message: '发送礼物', duration: 1500 });
  }
  private async openHelp(): Promise<void> {
    promptAction.showToast({ message: '向我们提问', duration: 1500 });
  }
  private async openFaq(): Promise<void> {
    promptAction.showToast({ message: 'Telegram常见问题', duration: 1500 });
  }
  private async openFeatures(): Promise<void> {
    promptAction.showToast({ message: 'Telegram功能', duration: 1500 });
  }
  private async openPrivacyPolicy(): Promise<void> {
    promptAction.showToast({ message: '隐私政策', duration: 1500 });
  }
  private async openDonation(): Promise<void> {
    await this.navigateTo('pages/settings/DonatePage');
  }

  private async navigateTo(url: string): Promise<void> {
    try {
      LogService.getInstance().debug(DOMAIN, TAG, `Navigating to: ${url}`);
      await router.pushUrl({ url });
    } catch (error) {
      LogService.getInstance().warn(DOMAIN, TAG, `Navigation failed to ${url}: ${error}`);
      ErrorHandler.getInstance().handle(error);
      promptAction.showToast({ message: '页面开发中', duration: 1500 });
    }
  }


  // ==================== UI 构建 ====================

  @Builder
  private buildUserCard() {
    Column() {
      Avatar({
        source: this.viewModel.userInfo?.avatarPath ?? '',
        name: this.viewModel.userInfo?.fullName || '用户',
        avatarSize: 80,
        fontSize: 32,
        avatarBackgroundColor: this.getAvatarColor(this.viewModel.userInfo?.fullName || '用户'),
        radius: 40
      })
        .margin({ bottom: 12 })

      Text(this.viewModel.userInfo?.fullName || '用户')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#000000')
        .margin({ bottom: 4 })

      Row() {
        Text(this.viewModel.userInfo?.phoneNumber || '')
          .fontSize(14)
          .fontColor('#8E8E93')
        if (this.viewModel.userInfo?.username) {
          Text(' · ')
            .fontSize(14)
            .fontColor('#8E8E93')
          Text(this.viewModel.userInfo.username)
            .fontSize(14)
            .fontColor('#8E8E93')
        }
      }
      .margin({ bottom: 16 })
    }
    .width('100%')
    .padding({ top: 24, bottom: 16 })
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildSettingItem(item: SettingItem) {
    Row() {
      // 左侧占位（Telegram 设置页通常无图标，但可预留）
      if (item.icon) {
        Image(item.icon)
          .width(24)
          .height(24)
          .margin({ right: 16 })
      } else {
        // 无图标时留出空白保持对齐
        Row().width(24).height(24).margin({ right: 16 })
      }

      // 文字区域
      Column({ space: 4 }) {
        Text(item.title)
          .fontSize(17)
          .fontColor('#000000')
          .fontWeight(FontWeight.Normal)
        if (item.subtitle) {
          Text(item.subtitle)
            .fontSize(13)
            .fontColor('#8E8E93')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 右箭头
      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(16)
        .height(16)
        .fillColor('#C7C7CC')
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .onClick(() => item.onClick())
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private buildGroup(group: SettingGroup, groupIndex: number) {
    Column() {
      // 分组标题
      if (group.title) {
        Text(group.title)
          .fontSize(13)
          .fontColor('#8E8E93')
          .padding({ left: 16, top: 12, bottom: 6 })
          .alignSelf(ItemAlign.Start)
      }

      // 分组内的设置项
      ForEach(group.items, (item: SettingItem, idx: number) => {
        this.buildSettingItem(item)
        if (idx < group.items.length - 1) {
          Divider()
            .color('#E5E5EA')
            .strokeWidth(0.5)
            .margin({ left: 16 })
        }
      }, (item: SettingItem, idx: number) => `${groupIndex}_${idx}`)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ left: 16, right: 16, bottom: 12 })
  }

  @Builder
  private buildVersionFooter() {
    Column() {
      Text(this.viewModel.appVersion || 'Telegram HarmonyOS 客户端')
        .fontSize(12)
        .fontColor('#8E8E93')
        .textAlign(TextAlign.Center)
        .padding({ top: 20, bottom: 30 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        // ⭐ 内容区：全尺寸铺满 Stack，滚动到顶部栏后方实现沉浸模糊效果
        Scroll() {
          Column() {
            // 用户信息卡片
            this.buildUserCard()

            // 设置分组列表
            ForEach(this.getSettingGroups(), (group: SettingGroup, index: number) => {
              this.buildGroup(group, index)
            }, (group: SettingGroup, index: number) => `${index}`)

            // 版本信息
            this.buildVersionFooter()
          }
          .width('100%')
          .padding({ bottom: 16 })
        }
        .padding({ top: 56 + this.topSafeHeight, bottom: 70 })
        .backgroundColor('#F5F5F5')
        .scrollBar(BarState.Auto)
        .width('100%')
        .height('100%')

        // ⭐ 顶部栏：浮层叠加在内容上方，毛玻璃效果模糊列表内容
        MainTopBar({
          title: '设置',
          immersiveTopPadding: this.topSafeHeight
        })
      }
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}