/**
 * 徽章组件
 * 显示数字或状态标识的小徽章
 */

@Component

export struct BadgeEx {
  text?: ResourceStr = undefined;
  count: number = 0;
  maxCount: number = 99;
  dot: boolean = false;
  showZero: boolean = true;
  type: string = 'primary';
  @Prop badgeSize: string = 'medium';
  @Prop badgeBackgroundColor?: string = undefined;
  @Prop badgeFontColor: string = '#FFFFFF';

  /**
   * 获取显示文本
   */
  private getDisplayText(): string {
    if (this.text) {
      return String(this.text);
    }

    if (!this.showZero && this.count === 0) {
      return '';
    }

    return this.count > this.maxCount ? `${this.maxCount}+` : String(this.count);
  }

  /**
   * 获取徽章尺寸
   */
  private getBadgeSize(): number {
    return this.badgeSize === 'small' ? 18 : 20;
  }

  /**
   * 获取徽章背景色
   */
  private getBadgeColor(): string {
    if (this.badgeBackgroundColor) {
      return this.badgeBackgroundColor;
    }

    const colorMap: Record<string, string> = {
      'primary': '#3390F0',
      'danger': '#FF6B6B',
      'success': '#52C41A',
      'warning': '#FAAD14'
    };

    return colorMap[this.type] ?? '#3390F0';
  }

  build() {
    if (this.dot) {
      // 圆点徽章
      Circle({ width: 8, height: 8 })
        .fill(this.getBadgeColor())
    } else {
      if (this.getDisplayText()) {
        // 文本/数字徽章
        Text(this.getDisplayText())
          .fontSize(this.badgeSize === 'small' ? 10 : 11)
          .fontColor(this.badgeFontColor)
          .fontWeight(FontWeight.Medium)
          .minFontSize(8)
          .maxFontSize(11)
          .padding({ left: 6, right: 6, top: 1, bottom: 1 })
          .backgroundColor(this.getBadgeColor())
          .borderRadius(10)
      }
    }
  }
}
