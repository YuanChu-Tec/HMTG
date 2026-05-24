/*
 * Copyright (c) 2026 HMTG Project
 * Licensed under the Apache License, Version 2.0 (the "License")
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * BottomSheet - 底部面板组件
 * 
 * 功能特性：
 * 1. 从底部滑出的面板
 * 2. 支持列表选项和自定义内容
 * 3. 手势交互(下拉关闭)
 * 4. 动画效果
 * 5. 支持标题栏和操作按钮
 */

/**
 * SheetItem - 底部面板列表项
 */
export interface SheetItem {
  text: ResourceStr;
  icon?: ResourceStr;
  action: () => void;
  disabled?: boolean;
  danger?: boolean; // 危险操作(红色)
  divider?: boolean; // 是否显示分割线
}

/**
 * BottomSheetOptions - 底部面板配置选项
 */
export interface BottomSheetOptions {
  title?: ResourceStr;
  items?: SheetItem[];
  content?: CustomBuilder; // 自定义内容
  showClose?: boolean;
  height?: string | number; // 面板高度
  maxHeight?: string | number; // 最大高度
  onDismiss?: () => void; // 关闭回调
}

@ComponentV2
export struct BottomSheet {

  @Param options: BottomSheetOptions = {
    title: undefined,
    items: [],
    content: undefined,
    showClose: true,
    height: 'auto',
    maxHeight: '70%',
    onDismiss: undefined
  };
  @Param visible: boolean = false;

  @Local sheetOffset: string = '100%';
  @Local maskOpacity: number = 0;

  private maxOffset: string = '100%';
  private minOffset: string = '0%';
  private dragStartY: number = 0;

  aboutToAppear(): void {
    const opts = this.options;
    if (opts && opts.showClose === undefined) {
      opts.showClose = true;
    }
  }

  aboutToUpdate(): void {
    if (this.visible && this.sheetOffset !== '0%') {
      this.sheetOffset = '0%';
      this.maskOpacity = 1;
    } else if (!this.visible && this.sheetOffset !== this.maxOffset) {
      this.sheetOffset = '100%';
      this.maskOpacity = 0;
    }
  }

  /**
   * 处理关闭
   */
  private handleDismiss(): void {
    this.sheetOffset = this.maxOffset;
    this.maskOpacity = 0;

    const opts = this.options;
    setTimeout(() => {
      if (opts && opts.onDismiss) {
        opts.onDismiss();
      }
    }, 300);
  }

  /**
   * 处理拖拽开始
   */
  private handleDragStart(event: TouchEvent): void {
    this.dragStartY = event.touches[0].screenY;
  }

  /**
   * 处理拖拽移动
   */
  private handleDragMove(event: TouchEvent): void {
    const currentY = event.touches[0].screenY;
    const deltaY = currentY - this.dragStartY;

    if (deltaY > 0) {
      // 向下拖拽
      const offsetPercent = Math.min(100, Math.max(0, (deltaY / 500) * 100));
      this.sheetOffset = `${offsetPercent}%`;
      this.maskOpacity = 1 - offsetPercent / 100;
    }
  }

  /**
   * 处理拖拽结束
   */
  private handleDragEnd(): void {
    const offsetStr = this.sheetOffset as string;
    const offsetPercent = offsetStr ? parseInt(offsetStr) : 0;

    // 如果拖拽超过30%，则关闭
    if (offsetPercent > 30) {
      this.handleDismiss();
    } else {
      // 否则回弹到原位
      this.sheetOffset = '0%';
      this.maskOpacity = 1;
    }
  }

  /**
   * 处理列表项点击
   */
  private handleItemClick(item: SheetItem): void {
    if (!item.disabled) {
      item.action();
      this.handleDismiss();
    }
  }

  /**
   * 构建标题栏
   */
  @Builder
  private buildHeader() {
    Column() {
      // 拖拽指示器
      Row() {
        Row()
          .width(36)
          .height(4)
          .backgroundColor('#D1D1D1')
          .borderRadius(2)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 12, bottom: 8 })

      // 标题和关闭按钮
      if (this.options && this.options.title) {
        Row() {
          Text(this.options.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')
            .layoutWeight(1)

          if (this.options.showClose) {
            Image($r('sys.media.ohos_ic_public_cancel'))
              .width(24)
              .height(24)
              .fillColor('#182431')
              .onClick(() => {
                this.handleDismiss();
              })
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 12 })
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  /**
   * 构建列表项
   */
  @Builder
  private buildSheetItem(item: SheetItem, index: number) {
    Row() {
      if (item.icon) {
        Image(item.icon)
          .width(24)
          .height(24)
          .fillColor(item.danger ? '#FA2A2D' : '#182431')
          .margin({ right: 12 })
      }

      Text(item.text)
        .fontSize(16)
        .fontColor(item.disabled ? '#CCCCCC' : (item.danger ? '#FA2A2D' : '#182431'))
        .layoutWeight(1)

      if (item.disabled) {
        Text('>')
          .fontSize(16)
          .fontColor('#CCCCCC')
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(item.disabled ? '#F5F5F5' : '#FFFFFF')
    .borderRadius(12)
    .opacity(item.disabled ? 0.5 : 1)
    .onClick(() => {
      this.handleItemClick(item);
    })

    // 分割线
    if (item.divider && index < (this.options.items?.length || 0) - 1) {
      Row()
        .width('100%')
        .height(1)
        .backgroundColor('#F5F5F5')
        .margin({ left: 48 })
    }
  }

  /**
   * 构建列表内容
   */
  @Builder
  private buildListContent() {
    if (this.options.items && this.options.items.length > 0) {
      Column({ space: 0 }) {
        ForEach(this.options.items, (item: SheetItem, index: number) => {
          this.buildSheetItem(item, index);
        }, (item: SheetItem, index: number) => `item_${index}_${item.text}`)
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 8, bottom: 8 })
    }
  }

  /**
   * 构建自定义内容
   */
  @Builder
  private buildCustomContent() {
    if (this.options && this.options.content) {
      // 自定义内容由父组件通过 BuilderParam 传入
    }
  }

  /**
   * 构建面板主体
   */
  @Builder
  private buildSheetContent() {
    Column() {
      this.buildHeader()
      if (this.options && this.options.content) {
        this.buildCustomContent()
      } else {
        this.buildListContent()
      }
    }
    .width('100%')
    .height(this.options?.height || 'auto')
    .constraintSize({ maxHeight: this.options?.maxHeight || '70%' })
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 20, topRight: 20 })
    .shadow({
      radius: 16,
      color: 'rgba(0, 0, 0, 0.12)',
      offsetX: 0,
      offsetY: -4
    })
    .translate({ y: this.sheetOffset })
    .animation({
      duration: 300,
      curve: Curve.FastOutSlowIn
    })
  }

  build() {
    if (this.visible) {
      Stack({ alignContent: Alignment.Bottom }) {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .opacity(this.maskOpacity)
          .onClick(() => {
            this.handleDismiss();
          })
          .animation({
            duration: 300,
            curve: Curve.FastOutSlowIn
          })

        // 底部面板
        Column() {
          this.buildSheetContent()
        }
        .width('100%')
        .padding({ bottom: 0 })
        .gesture(
          PanGesture({ direction: PanDirection.Down })
            .onActionStart((event: GestureEvent) => {
              // 初始化拖动起始位置
              const offsetX = event.offsetX;
              const offsetY = event.offsetY;
              this.dragStartY = offsetY;
            })
            .onActionUpdate((event: GestureEvent) => {
              // 计算拖动偏移量
              const offsetY = event.offsetY;
              const deltaY = offsetY - this.dragStartY;

              if (deltaY > 0) {
                const offsetPercent = Math.min(100, Math.max(0, (deltaY / 500) * 100));
                this.sheetOffset = `${offsetPercent}%`;
                this.maskOpacity = 1 - offsetPercent / 100;
              }
            })
            .onActionEnd(() => {
              this.handleDragEnd();
            })
        )
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(9999)
    }
  }
}
