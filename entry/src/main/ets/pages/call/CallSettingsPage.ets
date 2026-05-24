/**
 * 通话设置页面
 * @module feature-calls.pages
 */

import { router } from '@kit.ArkUI';
import { CallSettings } from '../../models';
import { CallServiceImpl } from '../../services/business/calls/CallServiceImpl';

/**
 * 通话设置页面组件
 */
@Entry
@ComponentV2
struct CallSettingsPage {
  @Local enableVideo: boolean = true;
  @Local enableSpeaker: boolean = false;
  @Local enableNoiseCancellation: boolean = true;
  @Local enableEchoCancellation: boolean = true;
  @Local videoQuality: 'low' | 'medium' | 'high' | 'auto' = 'auto';
  @Local audioBitrate: number = 64;
  @Local videoBitrate: number = 1000;

  private callService: CallServiceImpl = CallServiceImpl.getInstance();

  aboutToAppear(): void {
    this.loadSettings();
  }

  /**
   * 加载设置
   */
  private loadSettings(): void {
    try {
      const settings = this.callService.getCallSettings();
      this.enableVideo = settings.enableVideo;
      this.enableSpeaker = settings.enableSpeaker;
      this.enableNoiseCancellation = settings.enableNoiseCancellation;
      this.enableEchoCancellation = settings.enableEchoCancellation;
      this.videoQuality = settings.videoQuality;
      this.audioBitrate = settings.audioBitrate;
      this.videoBitrate = settings.videoBitrate;
    } catch (error) {
      console.error('加载设置失败:', error);
    }
  }

  /**
   * 保存设置
   */
  private async saveSettings(): Promise<void> {
    try {
      const settings: CallSettings = {
        enableVideo: this.enableVideo,
        enableSpeaker: this.enableSpeaker,
        enableNoiseCancellation: this.enableNoiseCancellation,
        enableEchoCancellation: this.enableEchoCancellation,
        videoQuality: this.videoQuality,
        audioBitrate: this.audioBitrate,
        videoBitrate: this.videoBitrate
      };

      await this.callService.updateCallSettings(settings);
      router.back();
    } catch (error) {
      console.error('保存设置失败:', error);
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.icon_back'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
          .onClick(() => {
            router.back();
          })

        Text('通话设置')
          .fontSize(18)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('保存')
          .fontSize(16)
          .fontColor('#007AFF')
          .onClick(() => {
            this.saveSettings();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#1C1C1E')

      // 设置列表
      Column() {
        // 视频设置
        Text('视频')
          .fontSize(14)
          .fontColor('#8E8E93')
          .width('100%')
          .padding({ left: 16, top: 16, bottom: 8 })

        Row() {
          Text('启用视频')
            .fontSize(16)
            .fontColor(Color.White)
            .layoutWeight(1)

          Toggle({ type: ToggleType.Switch, isOn: this.enableVideo })
            .selectedColor('#007AFF')
            .onChange((isOn: boolean) => {
              this.enableVideo = isOn;
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor('#2C2C2E')

        Row() {
          Text('视频质量')
            .fontSize(16)
            .fontColor(Color.White)
            .layoutWeight(1)

          Text(this.videoQuality)
            .fontSize(16)
            .fontColor('#8E8E93')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor('#2C2C2E')

        Row() {
          Text('视频码率')
            .fontSize(16)
            .fontColor(Color.White)
            .layoutWeight(1)

          Text(`${this.videoBitrate} kbps`)
            .fontSize(16)
            .fontColor('#8E8E93')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor('#2C2C2E')

        // 音频设置
        Text('音频')
          .fontSize(14)
          .fontColor('#8E8E93')
          .width('100%')
          .padding({ left: 16, top: 24, bottom: 8 })

        Row() {
          Text('默认启用扬声器')
            .fontSize(16)
            .fontColor(Color.White)
            .layoutWeight(1)

          Toggle({ type: ToggleType.Switch, isOn: this.enableSpeaker })
            .selectedColor('#007AFF')
            .onChange((isOn: boolean) => {
              this.enableSpeaker = isOn;
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor('#2C2C2E')

        Row() {
          Text('噪音消除')
            .fontSize(16)
            .fontColor(Color.White)
            .layoutWeight(1)

          Toggle({ type: ToggleType.Switch, isOn: this.enableNoiseCancellation })
            .selectedColor('#007AFF')
            .onChange((isOn: boolean) => {
              this.enableNoiseCancellation = isOn;
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor('#2C2C2E')

        Row() {
          Text('回声消除')
            .fontSize(16)
            .fontColor(Color.White)
            .layoutWeight(1)

          Toggle({ type: ToggleType.Switch, isOn: this.enableEchoCancellation })
            .selectedColor('#007AFF')
            .onChange((isOn: boolean) => {
              this.enableEchoCancellation = isOn;
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor('#2C2C2E')

        Row() {
          Text('音频码率')
            .fontSize(16)
            .fontColor(Color.White)
            .layoutWeight(1)

          Text(`${this.audioBitrate} kbps`)
            .fontSize(16)
            .fontColor('#8E8E93')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor('#2C2C2E')
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#000000')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}
