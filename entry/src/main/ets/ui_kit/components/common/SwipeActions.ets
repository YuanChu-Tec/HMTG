import { ThemeManager } from '../../themes/ThemeManager';

/**
 * 滑动操作项
 */
export interface SwipeAction {
  text: string;
  icon?: string;
  backgroundColor: string;
  textColor?: string;
  onClick: () => void;
}

/**
 * 滑动操作容器
 */
@ComponentV2
export struct SwipeActions {

  leftActions: SwipeAction[] = [];
  rightActions: SwipeAction[] = [];

  @BuilderParam content: () => void;

  @Local isOpen: boolean = false;
  @Local swipeOffset: number = 0;

  /**
   * 获取主题
   */
  private getTheme(): Object {
    return ThemeManager.getInstance().getCurrentTheme();
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 背景操作按钮
      Row() {
        // 左侧操作
        if (this.leftActions.length > 0) {
          Row() {
            ForEach(this.leftActions, (action: SwipeAction) => {
              Button(action.text)
                .height('100%')
                .backgroundColor(action.backgroundColor)
                .fontColor(action.textColor || '#ffffff')
                .onClick(() => {
                  action.onClick();
                  this.isOpen = false;
                  this.swipeOffset = 0;
                })
            })
          }
          .layoutWeight(1)
        }

        // 右侧操作
        if (this.rightActions.length > 0) {
          Row() {
            ForEach(this.rightActions, (action: SwipeAction) => {
              Button(action.text)
                .height('100%')
                .backgroundColor(action.backgroundColor)
                .fontColor(action.textColor || '#ffffff')
                .onClick(() => {
                  action.onClick();
                  this.isOpen = false;
                  this.swipeOffset = 0;
                })
            })
          }
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .position({ x: this.swipeOffset })
      .zIndex(0)

      // 内容区域
      Row() {
        this.content()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')
      .zIndex(1)
      .translate({ x: this.swipeOffset })
      .gesture(
        PanGesture()
          .onActionUpdate((event) => {
            this.swipeOffset = event.offsetX;
          })
          .onActionEnd(() => {
            // 根据滑动方向和距离决定是否打开
            const threshold = 100;
            if (this.swipeOffset > threshold) {
              this.swipeOffset = 150; // 打开左侧操作
              this.isOpen = true;
            } else if (this.swipeOffset < -threshold) {
              this.swipeOffset = -150; // 打开右侧操作
              this.isOpen = true;
            } else {
              this.swipeOffset = 0; // 关闭
              this.isOpen = false;
            }
          })
      )
    }
    .clip(true)
  }
}
