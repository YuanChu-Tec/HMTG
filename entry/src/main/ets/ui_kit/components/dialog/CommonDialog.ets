/*
 * Copyright (c) 2026 HMTG Project
 * Licensed under the Apache License, Version 2.0 (the "License")
 * you may not use this file except in compliance with the License
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * CommonDialog - 通用对话框组件
 *
 * 功能特性：
 * 1. 标准对话框布局(标题、内容、按钮)
 * 2. 支持自定义内容和按钮
 * 3. 动画打开/关闭效果
 * 4. 点击遮罩关闭选项
 * 5. 支持双按钮确认/取消
 */

/**
 * DialogButton - 对话框按钮配置
 */
export interface DialogButton {
  text: string;
  action: () => void;
  primary?: boolean; // 是否为主要按钮
  disabled?: boolean; // 是否禁用
}

/**
 * DialogOptions - 对话框配置选项
 */
export interface DialogOptions {
  title?: ResourceStr;
  content?: CustomBuilder;
  message?: ResourceStr;
  buttons?: DialogButton[];
  showMask?: boolean; // 是否显示遮罩
  maskClosable?: boolean; // 点击遮罩是否关闭
  showClose?: boolean; // 是否显示关闭按钮
}

@ComponentV2
export struct CommonDialog {

  @Param options: DialogOptions = {
    title: undefined,
    content: undefined,
    message: undefined,
    buttons: [],
    showMask: true,
    maskClosable: true,
    showClose: true
  };
  @Param visible: boolean = false;

  @Local dialogHeight: number = 0;

  private maskHeight: string = '100%';
  private maskColor: string = 'rgba(0, 0, 0, 0.5)';

  aboutToAppear(): void {
    const opts = this.options;
    if (!opts) {
      return;
    }
    if (opts.showMask === undefined) {
      opts.showMask = true;
    }
    if (opts.maskClosable === undefined) {
      opts.maskClosable = true;
    }
    if (opts.showClose === undefined) {
      opts.showClose = true;
    }
  }

  /**
   * 处理遮罩点击
   */
  private handleMaskClick(): void {
    const opts = this.options;
    if (opts && opts.maskClosable) {
      this.handleClose();
    }
  }

  /**
   * 处理关闭
   */
  private handleClose(): void {
    // 触发关闭事件
    // 父组件需要绑定 @visible-change 事件
  }

  /**
   * 处理按钮点击
   */
  private handleButtonClick(action: () => void): void {
    action();
    this.handleClose();
  }

  /**
   * 构建标题区域
   */
  @Builder
  private buildTitle() {
    if (this.options && this.options.title) {
      Row() {
        Text(this.options.title)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
          .layoutWeight(1)

        if (this.options.showClose) {
          Image($r('sys.media.ohos_ic_public_cancel'))
            .width(24)
            .height(24)
            .fillColor('#182431')
            .onClick(() => {
              this.handleClose();
            })
        }
      }
      .width('100%')
      .padding({ left: 24, right: 16, top: 20, bottom: 16 })
      .borderRadius({ topLeft: 24, topRight: 24 })
    }
  }

  /**
   * 构建内容区域
   */
  @Builder
  private buildContent() {
    if (this.options && this.options.content) {
      // 自定义内容由父组件通过 BuilderParam 传入，这里使用占位
      Column() {
        Text('Custom Content Area')
          .fontSize(14)
          .fontColor('#666666')
      }
      .padding({ left: 24, right: 24, bottom: 20 })
    } else if (this.options && this.options.message) {
      // 文本消息
      Text(this.options.message)
        .fontSize(16)
        .fontColor('#182431')
        .lineHeight(24)
        .width('100%')
        .padding({ left: 24, right: 24, bottom: 20 })
    }
  }

  /**
   * 构建按钮区域
   */
  @Builder
  private buildButtons() {
    if (this.options && this.options.buttons && this.options.buttons.length > 0) {
      Row() {
        if (this.options.buttons.length === 1) {
          // 单按钮居中
          Button(this.options.buttons[0].text)
            .width(200)
            .height(40)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.options.buttons[0].primary ? '#007DFF' : '#F1F3F5')
            .fontColor(this.options.buttons[0].primary ? '#FFFFFF' : '#182431')
            .borderRadius(20)
            .enabled(this.options.buttons[0] ? !this.options.buttons[0].disabled : true)
            .opacity(this.options.buttons[0] && this.options.buttons[0].disabled ? 0.4 : 1)
            .onClick(() => {
              if (this.options.buttons && this.options.buttons[0]) {
                this.handleButtonClick(this.options.buttons[0].action);
              }
            })
        } else if (this.options.buttons.length === 2) {
          // 双按钮
          Button(this.options.buttons[0].text)
            .layoutWeight(1)
            .height(40)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#F1F3F5')
            .fontColor('#182431')
            .borderRadius(20)
            .margin({ right: 8 })
            .onClick(() => {
              if (this.options.buttons && this.options.buttons[0]) {
                this.handleButtonClick(this.options.buttons[0].action);
              }
            })

          Button(this.options.buttons[1].text)
            .layoutWeight(1)
            .height(40)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.options.buttons[1].primary ? '#007DFF' : '#F1F3F5')
            .fontColor(this.options.buttons[1].primary ? '#FFFFFF' : '#182431')
            .borderRadius(20)
            .margin({ left: 8 })
            .onClick(() => {
              if (this.options.buttons && this.options.buttons[1]) {
                this.handleButtonClick(this.options.buttons[1].action);
              }
            })
        } else {
          // 多按钮 - 垂直排列
          Column({ space: 12 }) {
            ForEach(this.options.buttons, (button: DialogButton) => {
              Button(button.text)
                .width('100%')
                .height(40)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .backgroundColor(button.primary ? '#007DFF' : '#F1F3F5')
                .fontColor(button.primary ? '#FFFFFF' : '#182431')
                .borderRadius(20)
                .onClick(() => {
                  this.handleButtonClick(button.action);
                })
            }, (button: DialogButton, index: number) => `${index}_${button.text}`)
          }
          .width('100%')
          .padding({ left: 24, right: 24, bottom: 20 })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
  }

  /**
   * 构建对话框主体
   */
  @Builder
  private buildDialogContent() {
    Column() {
      this.buildTitle()
      this.buildContent()
      this.buildButtons()
    }
    .width('85%')
    .constraintSize({ maxWidth: 400 })
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .shadow({
      radius: 16,
      color: 'rgba(0, 0, 0, 0.12)',
      offsetX: 0,
      offsetY: 4
    })
    .animation({
      duration: 300,
      curve: Curve.FastOutSlowIn
    })
  }

  build() {
    if (this.visible) {
      Stack({ alignContent: Alignment.Center }) {
        // 遮罩层
        if (this.options && this.options.showMask) {
          Column()
            .width('100%')
            .height(this.maskHeight)
            .backgroundColor(this.maskColor)
            .onClick(() => {
              this.handleMaskClick();
            })
        }

        // 对话框内容
        this.buildDialogContent()
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(9999)
    }
  }
}
