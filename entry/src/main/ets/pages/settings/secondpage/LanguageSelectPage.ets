// file: LanguageSelectPage.ets - 语言选择页面，支持应用内切换语言

import { router } from '@kit.ArkUI';
import { i18n } from '../../../utils';
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { ImmersiveContainer } from '../../../components/common/ImmersiveContainer';
import { ImmersiveMode, ThemeMode as ImmersiveThemeMode } from '../../../utils/utils/ImmersiveUtils';

/**
 * 语言选项
 */
interface LanguageOption {
  code: string;          // 语言代码，如 'zh_CN'
  name: string;          // 语言显示名称
  nativeName: string;    // 语言本地化名称
  flag: string;          // 语言图标 emoji
}

/**
 * 语言选择页面
 * 允许用户在应用内切换显示语言
 */
@Entry
@Component
struct LanguageSelectPage {
  @State currentLocale: string = 'zh_CN';
  @State languages: LanguageOption[] = [
    {
      code: 'zh_CN',
      name: '简体中文',
      nativeName: '简体中文',
      flag: '🇨🇳'
    },
    {
      code: 'zh_Hant',
      name: '繁體中文',
      nativeName: '繁體中文',
      flag: '🇹🇼'
    },
    {
      code: 'en_US',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸'
    },
    {
      code: 'ru_RU',
      name: 'Русский',
      nativeName: 'Русский',
      flag: '🇷🇺'
    }
  ];

  private dataPreferences: preferences.Preferences | null = null;

  async aboutToAppear() {
    // 加载当前语言设置
    await this.loadSavedLocale();
  }

  /**
   * 初始化 Preferences
   */
  private async initPreferences(): Promise<void> {
    try {
      const context = getContext(this);
      this.dataPreferences = await preferences.getPreferences(context, 'hmtg_settings');
    } catch (error) {
      const err = error as BusinessError;
      console.error(`Failed to init preferences. Code: ${err.code}, message: ${err.message}`);
    }
  }

  /**
   * 从存储加载保存的语言
   */
  private async loadSavedLocale(): Promise<void> {
    try {
      if (!this.dataPreferences) {
        await this.initPreferences();
      }
      if (this.dataPreferences) {
        this.currentLocale = await this.dataPreferences.get('app_language', 'zh_CN') as string;
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error(`Failed to load saved locale. Code: ${err.code}, message: ${err.message}`);
      this.currentLocale = 'zh_CN';
    }
  }

  /**
   * 保存语言设置
   */
  private async saveLocale(locale: string): Promise<void> {
    try {
      if (!this.dataPreferences) {
        await this.initPreferences();
      }
      if (this.dataPreferences) {
        await this.dataPreferences.put('app_language', locale);
        await this.dataPreferences.flush();
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error(`Failed to save locale. Code: ${err.code}, message: ${err.message}`);
    }
  }

  /**
   * 切换语言
   */
  private async changeLanguage(locale: string): Promise<void> {
    try {
      // 保存语言设置
      await this.saveLocale(locale);
      
      // 切换应用语言
      i18n.setLocale(locale);
      
      // 更新当前语言状态
      this.currentLocale = locale;
      
      // 延迟返回以显示效果
      setTimeout(() => {
        router.back();
      }, 300);
    } catch (error) {
      console.error('Failed to change language:', error);
    }
  }

  /**
   * 构建语言选项
   */
  @Builder
  buildLanguageItem(language: LanguageOption) {
    Row() {
      // 语言图标
      Text(language.flag)
        .fontSize(28)
        .margin({ right: 16 })

      // 语言信息
      Column({ space: 4 }) {
        Text(language.name)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(language.code === this.currentLocale ? FontWeight.Medium : FontWeight.Normal)

        Text(language.nativeName)
          .fontSize(14)
          .fontColor('#999999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 选中图标
      if (language.code === this.currentLocale) {
        Text('✓')
          .fontSize(20)
          .fontColor('#007DFF')
      } else {
        Text('')
          .fontSize(20)
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .borderRadius(8)
    .onClick(() => {
      if (language.code !== this.currentLocale) {
        this.changeLanguage(language.code);
      }
    })
  }

  build() {
    Column() {
      ImmersiveContainer({
        mode: ImmersiveMode.COMPONENT_TOP,
        theme: ImmersiveThemeMode.AUTO,
        excludeTop: false,
        excludeBottom: true,
      }) {
        // 顶部导航栏
        Row() {
          Text('')
            .width(40)

          Text($r('app.string.language_settings_title'))
            .fontSize(18)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Text('×')
            .width(40)
            .fontSize(24)
            .fontColor('#333333')
            .textAlign(TextAlign.Center)
            .onClick(() => {
              router.back();
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 0, right: 0 })
        .backgroundColor('#FFFFFF')

        // 语言列表
        Column({ space: 8 }) {
          ForEach(this.languages, (language: LanguageOption) => {
            this.buildLanguageItem(language)
          }, (language: LanguageOption) => language.code)
        }
        .width('100%')
        .padding({ top: 16, left: 16, right: 16 })
        .layoutWeight(1)
        
        // 底部提示
        Column() {
          Text($r('app.string.language_settings_desc'))
            .fontSize(14)
            .fontColor('#999999')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ bottom: 24 })
        .backgroundColor('#F5F5F5')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
