import { ThemeManager } from '../../themes/ThemeManager';

/**
 * 消息气泡方向
 */
export type BubbleDirection = 'left' | 'right';

/**
 * 消息气泡类型
 */
export type BubbleType = 'text' | 'image' | 'video' | 'file' | 'audio' | 'sticker' | 'system';

/**
 * 圆角值类
 */
class BorderRadiusValues {
  topLeft: number = 0;
  topRight: number = 0;
  bottomLeft: number = 0;
  bottomRight: number = 0;
}

/**
 * 消息气泡组件
 */
@ComponentV2
export struct MessageBubble {
  bubbleDirection: BubbleDirection = 'left';
  bubbleType: BubbleType = 'text';
  text: string = '';
  timestamp: string = '';
  isSending: boolean = false;
  isRead: boolean = false;
  isFailed: boolean = false;

  @BuilderParam content: () => void;

  /**
   * 组件复用前调用
   */
  aboutToReuse(_params: Record<string, Object>): void {
    // 组件复用时需要重置状态
  }

  /**
   * 获取主题
   */
  private getTheme(): Object {
    return ThemeManager.getInstance().getCurrentTheme();
  }

  /**
   * 获取背景色
   */
  private getBackgroundColor(): string {
    const theme = this.getTheme() as AppTheme;
    if (this.bubbleDirection === 'right') {
      return theme.tokens.colors.primary;
    }
    return theme.tokens.colors.surface;
  }

  /**
   * 获取文字颜色
   */
  private getTextColor(): string {
    if (this.bubbleDirection === 'right') {
      return '#ffffff';
    }
    const theme = this.getTheme() as AppTheme;
    return theme.tokens.colors.text;
  }

  /**
   * 获取圆角
   */
  private getBorderRadiusValues(): BorderRadiusValues {
    const baseRadius = 12;
    if (this.bubbleDirection === 'right') {
      const radiusValues = new BorderRadiusValues();
      radiusValues.topLeft = baseRadius;
      radiusValues.topRight = 4;
      radiusValues.bottomLeft = baseRadius;
      radiusValues.bottomRight = 4;
      return radiusValues;
    }
    const radiusValues = new BorderRadiusValues();
    radiusValues.topLeft = 4;
    radiusValues.topRight = baseRadius;
    radiusValues.bottomLeft = baseRadius;
    radiusValues.bottomRight = baseRadius;
    return radiusValues;
  }

  /**
   * 获取时间标记图标
   */
  private getStatusIcon(): string {
    if (this.isFailed) {
      return '❌';
    } else if (this.isSending) {
      return '⏳';
    } else if (this.isRead) {
      return '✅✅';
    } else {
      return '✅';
    }
  }

  build() {
    Row() {
      if (this.bubbleDirection === 'left') {
        Blank()
      }

      Column({ space: 6 }) {
        // 消息内容
        if (this.content) {
          this.content()
        } else if (this.text) {
          Text(this.text)
            .fontSize(15)
            .fontColor(this.getTextColor())
            .lineHeight(22)
        }

        // 时间和状态
        Row({ space: 4 }) {
          if (this.timestamp) {
            Text(this.timestamp)
              .fontSize(11)
              .fontColor(this.bubbleDirection === 'right' ? 'rgba(255,255,255,0.7)' : 'rgba(0,0,0,0.5)')
          }

          if (this.bubbleDirection === 'right') {
            Text(this.getStatusIcon())
              .fontSize(12)
          }
        }
      }
      .padding(12)
      .backgroundColor(this.getBackgroundColor())
      .borderRadius({
        topLeft: this.getBorderRadiusValues().topLeft,
        topRight: this.getBorderRadiusValues().topRight,
        bottomLeft: this.getBorderRadiusValues().bottomLeft,
        bottomRight: this.getBorderRadiusValues().bottomRight
      })
      .shadow({
        radius: 2,
        color: 'rgba(0,0,0,0.1)',
        offsetY: 1
      })

      if (this.bubbleDirection === 'right') {
        Blank()
      }
    }
    .width('100%')
    .justifyContent(this.bubbleDirection === 'left' ? FlexAlign.Start : FlexAlign.End)
  }
}

// 主题接口定义
interface AppTheme {
  tokens: ThemeTokens;
}

interface ThemeTokens {
  colors: ColorTokens;
}

interface ColorTokens {
  primary: string;
  surface: string;
  text: string;
}
