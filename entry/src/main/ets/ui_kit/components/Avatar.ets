/**
 * 头像组件
 * 支持图片、文字、在线状态等多种展示方式
 */

@ComponentV2
export struct Avatar {

  @Param source: ResourceStr = '';
  @Monitor('source')
  onSourceChange(): void {
    // source 变化时重置加载失败状态，尝试重新加载新图片
    this.imageLoadFailed = false;
  }
  @Param name: string = '';
  @Param avatarSize: number = 40;
  @Param fontSize: number = 18;
  @Param avatarBackgroundColor: ResourceColor = '#E0E0E0';
  @Param fontColor: ResourceColor = '#FFFFFF';
  @Param radius: number = -1;
  @Param isOnline: boolean = false;
  @Param avatarOnClick?: () => void = undefined;

  // 图片加载状态：true 表示加载失败
  @Local imageLoadFailed: boolean = false;


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

  private getImageSource(): string {
    if (!this.source || typeof this.source !== 'string' || this.source.length === 0) {
      return '';
    }
    if (this.source.startsWith('file://')) {
      return this.source;
    }
    return 'file://' + this.source;
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.source && typeof this.source === 'string' && this.source.length > 0 && !this.imageLoadFailed) {
        Image(this.getImageSource())
          .width(this.avatarSize)
          .height(this.avatarSize)
          .borderRadius(this.getBorderRadius())
          .objectFit(ImageFit.Cover)
          .onError(() => {
            this.imageLoadFailed = true;
          })
          .onClick(() => {
            if (this.avatarOnClick) {
              this.avatarOnClick();
            }
          })
      } else {
        // 首字母头像：使用 Circle + Text 组合
        Circle()
          .width(this.avatarSize)
          .height(this.avatarSize)
          .fill(this.avatarBackgroundColor)
        Text(this.getInitial())
          .fontSize(this.fontSize)
          .fontColor(this.fontColor)
          .fontWeight(FontWeight.Medium)
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
