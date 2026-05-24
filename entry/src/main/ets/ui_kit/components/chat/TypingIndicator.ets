import { ThemeManager } from '../../themes/ThemeManager';

/**
 * 正在输入指示器组件
 */
@ComponentV2

export struct TypingIndicator {
  @Param text: string = '';

  /**
   * 获取次要文本颜色
   */
  private getTextSecondaryColor(): string {
    return '#999999';
  }

  /**
   * 获取背景颜色
   */
  private getBackgroundColor(): string {
    return '#F5F5F5';
  }

  build() {
    Row({ space: 8 }) {
      // 动画点
      Row({ space: 4 }) {
        ForEach([0, 1, 2], (idx: number) => {
          Circle({ width: 6, height: 6 })
            .fill('#999999')
            .borderRadius(3)
            .animation({
              duration: 800,
              curve: Curve.EaseInOut,
              iterations: -1,
              playMode: PlayMode.Alternate,
              delay: idx * 150
            })
        })
      }
      .padding(8)

      if (this.text) {
        Text(this.text)
          .fontSize(13)
          .fontColor(this.getTextSecondaryColor())
      }
    }
    .padding(12)
    .backgroundColor(this.getBackgroundColor())
    .borderRadius(16)
  }
}

/**
 * 动画点组件
 */
@ComponentV2
struct Dot {
  @Param dotWidth: number = 6;
  @Param dotHeight: number = 6;
  @Param dotBackgroundColor: string = '#999999';

  @Local scaleValue: number = 1;

  aboutToAppear(): void {
    setInterval(() => {
      this.scaleValue = this.scaleValue === 1 ? 1.5 : 1;
    }, 400);
  }

  build() {
    Row()
      .width(this.dotWidth)
      .height(this.dotHeight)
      .backgroundColor(this.dotBackgroundColor)
      .borderRadius(this.dotWidth / 2)
      .scale({ x: this.scaleValue, y: this.scaleValue })
  }
}
