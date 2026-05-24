import { ThemeManager } from '../../themes/ThemeManager';

/**
 * 菜单项
 */
export interface MenuItem {
  id: string;
  icon: string;
  text: string;
  color?: string;
  destructive?: boolean;
  onClick: () => void;
}

/**
 * 菜单位置
 */
interface MenuPosition {
  x: number | string;
  y: number | string;
}

/**
 * 消息长按菜单组件
 */
@ComponentV2

export struct MessageMenu {
  @Param visible: boolean = false;
  @Param items: MenuItem[] = [];
  @Param menuPosition: MenuPosition = { x: '0', y: '0' };

  /**
   * 获取文本颜色
   */
  private getTextColor(): string {
    return '#333333';
  }

  /**
   * 获取错误颜色
   */
  private getErrorColor(): string {
    return '#F44336';
  }

  /**
   * 获取背景颜色
   */
  private getBackgroundColor(): string {
    return '#FFFFFF';
  }

  /**
   * 处理菜单项点击
   */
  private handleItemClick(item: MenuItem): void {
    item.onClick();
  }

  build() {
    if (this.visible) {
      Stack({ alignContent: Alignment.TopStart }) {
        // 遮罩层
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.3)')
          .onClick(() => {
            // 点击遮罩关闭菜单
          })

        // 菜单容器
        Column({ space: 0 }) {
          ForEach(this.items, (item: MenuItem) => {
            Row({ space: 12 }) {
              Text(item.icon)
                .fontSize(20)
                .fontColor(item.color || this.getTextColor())

              Text(item.text)
                .fontSize(15)
                .fontColor(item.destructive ? this.getErrorColor() : this.getTextColor())
                .layoutWeight(1)

              Blank()
            }
            .width('100%')
            .height(48)
            .padding({ left: 16, right: 16 })
            .backgroundColor(item.destructive ? 'rgba(244, 67, 54, 0.1)' : 'transparent')
            .onClick(() => {
              this.handleItemClick(item);
            })
          })
        }
        .width(200)
        .backgroundColor(this.getBackgroundColor())
        .borderRadius(8)
        .shadow({
          radius: 8,
          color: 'rgba(0,0,0,0.2)',
          offsetY: 4
        })
        .position({ x: this.menuPosition.x, y: this.menuPosition.y })
      }
      .width('100%')
      .height('100%')
      .zIndex(9999)
    }
  }
}
