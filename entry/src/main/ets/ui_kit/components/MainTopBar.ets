/**
 * TopBar - 通用顶部栏组件
 *
 * 设计说明：
 * - 提供简洁的页面顶部导航栏
 * - 左侧显示标题，右侧支持可配置的图标列表
 * - 使用 SymbolGlyph 显示系统图标
 * - 内置常用图标，通过名称选择
 *
 * ⭐ 安全区避让原则：
 * - 默认不含状态栏避让（immersiveTopPadding=0），由父页面处理
 * - 沉浸模式下传入 immersiveTopPadding=topSafeHeight，顶部栏延伸到状态栏后方
 *
 * 使用示例：
 * ```
 * import { MainTopBar } from '../ui_kit';
 *
 * MainTopBar({ title: '聊天', icons: [...] })
 * ```
 */

/**
 * TopBar 内置图标名称
 */
export type TopBarIconName = 'search' | 'more' | 'list' | 'trash' | 'close' | 'mute' | 'unmute' | 'pin' | 'qrcode';

/**
 * TopBar 图标配置项
 */
export interface TopBarIconItem {
  /** 图标名称（使用内置图标） */
  name: TopBarIconName;
  /** 图标点击回调 */
  action: () => void;
}

@ComponentV2
export struct MainTopBar {
  /** 标题文本 */
  @Param title: ResourceStr = '';
  /** 是否显示标题 */
  @Param showTitle: boolean = true;
  /** 左侧图标（可选） */
  @Param leftIcon: TopBarIconItem | null = null;
  /** 右侧图标列表 */
  @Param icons: TopBarIconItem[] = [];
  /** 图标间距 */
  @Param iconSpacing: number = 26;
  /** 图标大小 */
  @Param iconSize: number = 24;
  /** 图标颜色 */
  @Param iconColor: ResourceColor = '#000000';
  /** 沉浸式顶部padding（= topSafeHeight），使毛玻璃延伸到状态栏后方 */
  @Param immersiveTopPadding: number = 0;
  /** 内部内容区域高度（不含沉浸顶部padding） */
  private readonly contentHeight: number = 56;

  /**
   * 根据图标名称获取 Symbol 资源
   */
  private getSymbolByName(name: TopBarIconName): Resource {
    switch (name) {
      case 'search':
        return $r('sys.symbol.magnifyingglass');
      case 'more':
        return $r('sys.symbol.dot_grid_2x2');
      case 'list':
        return $r('sys.symbol.list_bullet');
      case 'trash':
        return $r('sys.symbol.trash');
      case 'close':
        return $r('sys.symbol.xmark');
      case 'mute':
        return $r('sys.symbol.speaker_wave_3_slash');
      case 'unmute':
        return $r('sys.symbol.speaker_wave_3');
      case 'pin':
        return $r('sys.symbol.pin');
      case 'qrcode':
        return $r('sys.symbol.qrcode');
      default:
        return $r('sys.symbol.exclamationmark');
    }
  }

  build() {
    Row() {
      // 左侧图标
      if (this.leftIcon) {
        SymbolGlyph(this.getSymbolByName(this.leftIcon.name))
          .fontSize(this.iconSize)
          .fontColor([this.iconColor])
          .onClick(() => this.leftIcon!.action())
          .margin({ right: this.iconSpacing })
      }

      // 标题
      if (this.showTitle) {
        Text(this.title)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .layoutWeight(1)
      }

      // 右侧图标列表
      ForEach(this.icons, (icon: TopBarIconItem, index: number) => {
        SymbolGlyph(this.getSymbolByName(icon.name))
          .fontSize(this.iconSize)
          .fontColor([this.iconColor])
          .onClick(() => icon.action())
          .margin({ right: index < this.icons.length - 1 ? this.iconSpacing : 0 })
      }, (icon: TopBarIconItem, index: number): string => `icon_${index}`)
    }
    .width('100%')
    .height(this.contentHeight + this.immersiveTopPadding)
    .padding({
      left: 16,
      right: 16,
      top: this.immersiveTopPadding + 8,
      bottom: 8
    })
    .backgroundColor('#CCFFFFFF')
    .backgroundBlurStyle(BlurStyle.Thin)
    .alignItems(VerticalAlign.Center)
  }
}