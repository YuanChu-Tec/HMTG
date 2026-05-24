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
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * ProgressDialog - 进度对话框组件
 * 
 * 功能特性：
 * 1. 显示操作进度的对话框
 * 2. 支持百分比进度显示
 * 3. 支持取消操作
 * 4. 进度动画效果
 * 5. 可自定义进度文本
 */

/**
 * ProgressOptions - 进度对话框配置选项
 */
export interface ProgressOptions {
  title?: ResourceStr;
  message?: ResourceStr;
  progress?: number; // 进度值 0-100
  showProgress?: boolean; // 是否显示进度条
  showPercentage?: boolean; // 是否显示百分比
  cancellable?: boolean; // 是否可取消
  onCancel?: () => void; // 取消回调
}

@ComponentV2
export struct ProgressDialog {

  options: ProgressOptions = {};
  visible: boolean = false;

  @Local currentProgress: number = 0;
  @Local animatedProgress: number = 0;

  private targetProgress: number = 0;
  private animationTimer: number = -1;

  aboutToAppear(): void {
    if (this.options.showProgress === undefined) {
      this.options.showProgress = true;
    }
    if (this.options.showPercentage === undefined) {
      this.options.showPercentage = true;
    }
    if (this.options.cancellable === undefined) {
      this.options.cancellable = true;
    }
  }

  aboutToUpdate(): void {
    if (this.options.progress !== undefined && this.options.progress !== this.targetProgress) {
      this.targetProgress = this.options.progress;
      this.animateProgress();
    }
  }

  /**
   * 进度动画
   */
  private animateProgress(): void {
    const step = (this.targetProgress - this.currentProgress) / 20;
    let count = 0;

    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer);
    }

    this.animationTimer = setInterval(() => {
      count++;
      this.currentProgress += step;

      if (count >= 20) {
        this.currentProgress = this.targetProgress;
        if (this.animationTimer !== -1) {
          clearInterval(this.animationTimer);
          this.animationTimer = -1;
        }
      }
    }, 16); // 60fps
  }

  aboutToDisappear(): void {
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer);
      this.animationTimer = -1;
    }
  }

  /**
   * 处理取消
   */
  private handleCancel(): void {
    if (this.options.onCancel) {
      this.options.onCancel();
    }
  }

  /**
   * 构建旋转加载指示器
   */
  @Builder
  private buildLoadingIndicator() {
    Stack() {
      Progress({ value: 0, type: ProgressType.Ring })
        .width(48)
        .height(48)
        .color('#007DFF')
        .style({ strokeWidth: 4 })

      Progress({ value: this.options.progress || 0, type: ProgressType.Ring })
        .width(48)
        .height(48)
        .color('#007DFF')
        .style({ strokeWidth: 4 })
        .animation({
          iterations: -1,
          playMode: PlayMode.Alternate
        })
    }
    .width(48)
    .height(48)
  }

  /**
   * 构建进度条
   */
  @Builder
  private buildProgressBar() {
    Column({ space: 8 }) {
      Progress({
        value: Math.max(0, Math.min(100, this.currentProgress || 0)),
        type: ProgressType.Linear
      })
        .width('100%')
        .height(8)
        .color('#007DFF')
        .backgroundColor('#F1F3F5')
        .borderRadius(4)

      if (this.options.showPercentage) {
        Row() {
          Text(`${Math.round(this.currentProgress || 0)}%`)
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
      }
    }
    .width('100%')
  }

  /**
   * 构建标题
   */
  @Builder
  private buildTitle() {
    if (this.options.title) {
      Text(this.options.title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ left: 24, right: 24, top: 24 })
    }
  }

  /**
   * 构建消息内容
   */
  @Builder
  private buildMessage() {
    Column({ space: 16 }) {
      // 加载指示器
      if (!this.options.showProgress) {
        this.buildLoadingIndicator()
      }

      // 进度条
      if (this.options.showProgress) {
        this.buildProgressBar()
      }

      // 消息文本
      if (this.options.message) {
        Text(this.options.message)
          .fontSize(14)
          .fontColor('#666666')
          .lineHeight(20)
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .padding({ left: 24, right: 24, bottom: 24 })
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 构建取消按钮
   */
  @Builder
  private buildCancelButton() {
    if (this.options.cancellable) {
      Button('取消')
        .width(120)
        .height(40)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#F1F3F5')
        .fontColor('#182431')
        .borderRadius(20)
        .margin({ bottom: 20 })
        .onClick(() => {
          this.handleCancel();
        })
    }
  }

  /**
   * 构建对话框主体
   */
  @Builder
  private buildDialogContent() {
    Column() {
      this.buildTitle()
      this.buildMessage()
      this.buildCancelButton()
    }
    .width('85%')
    .constraintSize({ maxWidth: 320 })
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
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .animation({
            duration: 200,
            curve: Curve.FastOutSlowIn
          })

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
