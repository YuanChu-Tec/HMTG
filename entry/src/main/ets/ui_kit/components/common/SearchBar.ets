/**
 * 搜索栏组件
 */
@ComponentV2
export struct SearchBar {

  onCancel?: () => void = undefined;
  onValueChange?: (value: string) => void = undefined;
  placeholder: string = '';
  value: string = '';

  @Local private searchValue: string = '';

  aboutToAppear(): void {
    this.searchValue = this.value;
  }

  build() {
    Row() {
      // 搜索图标
      Image($r('app.media.ic_search'))
        .width(20)
        .height(20)
        .fillColor('#999999')
        .margin({ right: 8 })

      // 输入框
      TextInput({ placeholder: this.placeholder, text: this.searchValue })
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .fontSize(16)
        .fontColor('#333333')
        .placeholderColor('#CCCCCC')
        .border({ width: 0 })
        .onChange((value: string) => {
          this.searchValue = value;
          if (this.onValueChange) {
            this.onValueChange(value);
          }
        })

      // 清除按钮
      if (this.searchValue.length > 0) {
        Image($r('app.media.ic_close'))
          .width(20)
          .height(20)
          .fillColor('#999999')
          .margin({ left: 8 })
          .onClick(() => {
            this.searchValue = '';
            if (this.onValueChange) {
              this.onValueChange('');
            }
          })
      }

      // 取消按钮
      Text('取消')
        .fontSize(16)
        .fontColor('#2481cc')
        .margin({ left: 8 })
        .onClick(() => {
          if (this.onCancel) {
            this.onCancel();
          }
        })
    }
    .width('100%')
    .height(40)
    .padding({ left: 12, right: 12 })
    .backgroundColor('#F5F5F5')
    .borderRadius(20)
  }
}
