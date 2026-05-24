/**
 * 头像图片组件
 * 支持异步加载、占位图、错误回退等特性
 */

import { image } from '@kit.ImageKit';

@ComponentV2

export struct AvatarImage {
  @Param imageUrl: string = '';
  @Param displayName: string = '';
  @Param avatarBgColor: string = '';
  @Param avatarSize: number = 48;
  @Param showOnlineStatus: boolean = false;
  @Param isOnline: boolean = false;

  @Local loaded: boolean = false;
  @Local loading: boolean = false;
  @Local error: boolean = false;

  aboutToAppear(): void {
    if (this.imageUrl) {
      this.loadImage();
    }
  }

  /**
   * 组件复用前调用
   */
  aboutToReuse(_params: Record<string, Object>): void {
    // 重置加载状态
    this.loaded = false;
    this.loading = false;
    this.error = false;

    // 重新加载图片
    if (this.imageUrl) {
      this.loadImage();
    }
  }

  /**
   * 异步加载图片
   */
  private async loadImage(): Promise<void> {
    if (!this.imageUrl || this.loading || this.loaded) {
      return;
    }

    this.loading = true;
    this.error = false;

    try {
      // 预加载图片
      const imageSource = image.createImageSource(this.imageUrl);
      if (imageSource) {
        this.loaded = true;
      }
    } catch (err) {
      console.error('Avatar load failed:', err);
      this.error = true;
    } finally {
      this.loading = false;
    }
  }

  /**
   * 获取首字母
   */
  private getInitialLetter(): string {
    if (!this.displayName) {
      return '?';
    }
    return this.displayName.charAt(0).toUpperCase();
  }

  /**
   * 获取头像背景色
   */
  private getAvatarBackgroundColor(): string {
    if (this.avatarBgColor) {
      return this.avatarBgColor;
    }
    return '#E1F0FF';
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      // 头像区域
      Stack() {
        if (this.imageUrl && this.loaded && !this.error) {
          // 已加载的图片
          Image(this.imageUrl)
            .width(this.avatarSize)
            .height(this.avatarSize)
            .borderRadius(this.avatarSize / 2)
            .objectFit(ImageFit.Cover)
            .onError(() => {
              this.error = true;
              this.loaded = false;
            })
        } else if (this.loading) {
          // 加载中骨架屏
          Column()
            .width(this.avatarSize)
            .height(this.avatarSize)
            .borderRadius(this.avatarSize / 2)
            .backgroundColor('#E5E5E5')
            .opacity(0.5)
        } else {
          // 占位文字
          Text(this.getInitialLetter())
            .fontSize(this.avatarSize * 0.4)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
      }
      .width(this.avatarSize)
      .height(this.avatarSize)
      .borderRadius(this.avatarSize / 2)
      .backgroundColor(this.getAvatarBackgroundColor())
      .border({ width: 1, color: 'rgba(0,0,0,0.1)' })

      // 在线状态点
      if (this.showOnlineStatus && this.isOnline) {
        Circle()
          .width(12)
          .height(12)
          .fill('#4caf50')
          .stroke('#FFFFFF')
          .strokeWidth(2)
          .margin({ bottom: 0, right: 0 })
      }
    }
  }
}
