/**
 * Telegram风格按钮组件
 */
@ComponentV2
export struct TelegramButton {

  disabled: Object = new Object() as Object;
  onClick?: () => void = undefined;
  text: Object = new Object() as Object;
  type: Object = new Object() as Object;

  
  @Local clickEffect: boolean = false;
  
  private onClick: () => void = () => {};
  
  build() {
    Button(this.text)
      .backgroundColor(this.getBackgroundColor())
      .fontColor(this.getFontColor())
      .borderRadius(8)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .opacity(this.disabled ? 0.6 : 1)
      .enabled(!this.disabled)
      .onClick(() => {
        this.clickEffect = true;
        setTimeout(() => {
          this.clickEffect = false;
          this.onClick();
        }, 100);
      })
  }
  
  private getBackgroundColor(): Color {
    switch (this.type) {
      case 'primary': return '#3390EC';
      case 'secondary': return '#F0F0F0';
      case 'danger': return '#FF3B30';
      default: return '#3390EC';
    }
  }
  
  private getFontColor(): Color {
    switch (this.type) {
      case 'primary': return Color.White;
      case 'secondary': return '#000000';
      case 'danger': return Color.White;
      default: return Color.White;
    }
  }
}