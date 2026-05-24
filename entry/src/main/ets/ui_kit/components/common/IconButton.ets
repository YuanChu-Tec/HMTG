/**
 * 图标按钮组件 - 供 P3 模块使用
 */
@Component
export struct IconButton {
  icon: ResourceStr = '';
  buttonSize: number = 40;
  bgColor: ResourceColor = '#E0E0E0';
  iconColor: ResourceColor = '#666666';
  iconSize: number = 24;
  onButtonClick?: () => void;

  build() {
    Button() {
      Image(this.icon)
        .width(this.iconSize)
        .height(this.iconSize)
        .fillColor(this.iconColor)
    }
    .width(this.buttonSize)
    .height(this.buttonSize)
    .backgroundColor(this.bgColor)
    .borderRadius(this.buttonSize / 2)
    .type(ButtonType.Normal)
    .onClick(() => {
      if (this.onButtonClick) {
        this.onButtonClick();
      }
    })
  }
}
