/**
 * 头像组件
 * 支持图片、文字、在线状态等多种展示方式
 */

@ComponentV2
export struct Avatar {

  @Param source: ResourceStr = '';
  @Param name: string = '';
  @Param avatarSize: number = 40;
  @Param fontSize: number = 18;
  @Param avatarBackgroundColor: ResourceColor = '#E0E0E0';
  @Param fontColor: ResourceColor = '#FFFFFF';
  @Param radius: number = -1;
  @Param isOnline: boolean = false;
  @Param avatarOnClick?: () => void = undefined;


  /**
   * 获取背景色
   */
  private getBackgroundColor(): ResourceColor {
    // 如果有图片源，不显示背景
    const sourceStr = this.source as string;
    if (this.source && typeof this.source === 'string' && sourceStr.length > 0) {
      return Color.Transparent;
    }

    return this.avatarBackgroundColor;
  }

  /**
   * 获取首字母
   */
  private getInitial(): string {
    if (this.name.length === 0) {
      return '?';
    }
    return this.name.charAt(0).toUpperCase();
  }

  /**
   * 获取边框圆角
   */
  private getBorderRadius(): number {
    if (this.radius === -1) {
      return this.avatarSize / 2;
    }
    return this.radius;
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      // 头像主体
      if (this.source && typeof this.source === 'string' && this.source.length > 0) {
        Image(this.source)
          .width(this.avatarSize)
          .height(this.avatarSize)
          .borderRadius(this.getBorderRadius())
          .objectFit(ImageFit.Cover)
          .onClick(() => {
            if (this.avatarOnClick) {
              this.avatarOnClick();
            }
          })
      } else {
        // 首字母头像
        Text(this.getInitial())
          .width(this.avatarSize)
          .height(this.avatarSize)
          .fontSize(this.fontSize)
          .fontColor(this.fontColor)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.getBackgroundColor())
          .borderRadius(this.getBorderRadius())
          .onClick(() => {
            if (this.avatarOnClick) {
              this.avatarOnClick();
            }
          })
      }

      // 在线状态指示器
      if (this.isOnline) {
        Circle({ width: 12, height: 12 })
          .fill('#52C41A')
          .position({ x: this.avatarSize - 12, y: this.avatarSize - 12 })
          .border({ width: 2, color: '#FFFFFF' })
      }
    }
    .width(this.avatarSize)
    .height(this.avatarSize)
  }
}
