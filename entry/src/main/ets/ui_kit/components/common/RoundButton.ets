/**
 * 圆角按钮组件
 * 多功能圆角按钮，支持多种样式和状态
 */

@Component

export struct RoundButton {
  // 点击处理（使用别名避免与内置onClick冲突）
  buttonOnClick?: () => void = undefined;

  // 组件属性
  text: string = '';
  icon?: ResourceStr = undefined;
  @Prop componentSize: 'small' | 'medium' | 'large' = 'medium';
  @Prop buttonType: 'primary' | 'secondary' | 'danger' | 'text' = 'primary';
  @Prop bgColor?: ResourceColor = undefined;
  @Prop textFontColor?: ResourceColor = undefined;
  @Prop borderRadiusValue?: number = undefined;
  @Prop fullWidth: boolean = false;
  @Prop disabled: boolean = false;
  @Prop loading: boolean = false;

  @State private isPressed: boolean = false;

  /**
   * 获取按钮高度
   */
  private getHeight(): number {
    const heightMap: Record<string, number> = {
      'small': 36,
      'medium': 48,
      'large': 56
    };
    const result = heightMap[this.componentSize];
    return result !== undefined ? result : 48;
  }

  /**
   * 获取按钮字体大小
   */
  private getFontSize(): number {
    const fontSizeMap: Record<string, number> = {
      'small': 14,
      'medium': 16,
      'large': 18
    };
    const result = fontSizeMap[this.componentSize];
    return result !== undefined ? result : 16;
  }

  /**
   * 获取按钮背景色
   */
  private getBackgroundColor(): ResourceColor {
    if (this.disabled) {
      return '#CCCCCC';
    }

    if (this.bgColor) {
      return this.bgColor;
    }

    if (this.buttonType === 'primary') {
      return this.isPressed ? '#2874D6' : '#3390F0';
    } else if (this.buttonType === 'secondary') {
      return this.isPressed ? '#E0E0E0' : '#F5F5F5';
    } else if (this.buttonType === 'danger') {
      return this.isPressed ? '#D63031' : '#FF6B6B';
    }
    return Color.Transparent;
  }

  /**
   * 获取按钮文字颜色
   */
  private getFontColor(): ResourceColor {
    if (this.disabled) {
      return '#999999';
    }

    if (this.textFontColor) {
      return this.textFontColor;
    }

    const colorMap: Record<string, ResourceColor> = {
      'primary': '#FFFFFF',
      'secondary': '#333333',
      'danger': '#FFFFFF',
      'text': '#3390F0'
    };

    return colorMap[this.buttonType] ?? '#FFFFFF';
  }
  /**
   * 处理点击
   */
  private handleClick(): void {
    if (this.disabled || this.loading) {
      return;
    }

    if (this.buttonOnClick) {
      this.buttonOnClick();
    }
  }

  build() {
    Button() {
      Row() {
        if (this.loading) {
          this.buildLoadingSpinner();
        } else if (this.icon) {
          Image(this.icon)
            .width(this.getFontSize() + 2)
            .height(this.getFontSize() + 2)
            .fillColor(this.getFontColor())
            .margin({ right: 8 })
        }

        Text(this.text)
          .fontSize(this.getFontSize())
          .fontColor(this.getFontColor())
          .fontWeight(FontWeight.Medium)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .type(ButtonType.Normal)
    .width(this.fullWidth ? '100%' : 'auto')
    .height(this.getHeight())
    .backgroundColor(this.getBackgroundColor())
    .borderRadius(this.borderRadiusValue !== undefined ? this.borderRadiusValue : (this.componentSize === 'small' ? 8 : 12))
    .padding({ left: (this.icon !== undefined || this.loading) ? 16 : 20, right: 16 })
    .enabled(!this.disabled && !this.loading)
    .onClick(() => {
      this.handleClick();
    })
    .stateEffect(true)
    .animation({
      duration: 150,
      curve: Curve.EaseInOut
    })
  }

  /**
   * 构建加载动画
   */
  @Builder
  private buildLoadingSpinner(): void {
    Circle({ width: this.getFontSize(), height: this.getFontSize() })
      .fill(Color.Transparent)
      .stroke(this.getFontColor())
      .strokeWidth(2)
      .strokeDashArray([4, 4])
      .animation({
        duration: 1000,
        iterations: -1,
        curve: Curve.Linear
      })
  }
}
