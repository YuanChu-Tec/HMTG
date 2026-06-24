/**
 * 加载指示器组件
 * 提供多种样式的加载动画
 */

@Component
export struct LoadingIndicator {
  color: ResourceColor = '#3390F0';
  indicatorSize: number = 40;
  text?: string = undefined;
  type: 'spinner' | 'dots' | 'pulse' = 'spinner';


  build() {
    Column() {
      if (this.type === 'spinner') {
        this.buildSpinner();
      } else if (this.type === 'dots') {
        this.buildDots();
      } else if (this.type === 'pulse') {
        this.buildPulse();
      }

      if (this.text !== undefined) {
        Text(this.text)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ top: 12 })
      }
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 构建旋转加载器
   */
  @Builder
  private buildSpinner(): void {
    Circle({ width: this.indicatorSize, height: this.indicatorSize })
      .fill(Color.Transparent)
      .stroke(this.color)
      .strokeWidth(3)
      .strokeDashArray([8, 8])
      .animation({
        duration: 1000,
        iterations: -1,
        curve: Curve.Linear
      })
  }

  /**
   * 构建圆点加载器
   */
  @Builder
  private buildDots(): void {
    Row({ space: 8 }) {
      ForEach([1, 2, 3], (index: number) => {
        Circle({ width: 10, height: 10 })
          .fill(this.color)
          .animation({
            duration: 1200,
            iterations: -1,
            curve: Curve.EaseInOut
          })
          .scale({
            x: 0.5,
            y: 0.5
          })
      }, (index: number) => index.toString())
    }
  }

  /**
   * 构建脉冲加载器
   */
  @Builder
  private buildPulse(): void {
    Circle({ width: this.indicatorSize, height: this.indicatorSize })
      .fill(this.color)
      .opacity(0.6)
      .animation({
        duration: 1500,
        iterations: -1,
        curve: Curve.EaseInOut
      })
      .scale({
        x: 0.8,
        y: 0.8
      })
  }
}
