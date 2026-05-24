/**
 * 通话中页面
 * @module feature-calls.pages
 */

import { router } from '@kit.ArkUI';
import { CallSession } from '../../models';
import { ICallService } from '../../services/business/calls/ICallService';
import { CallServiceImpl } from '../../services/business/calls/CallServiceImpl';

/**
 * 通话中页面组件
 */
@Entry
@ComponentV2
struct ActiveCallPage {
  @Local callInfo: CallSession | null = null;
  @Local callDuration: number = 0;
  @Local isMuted: boolean = false;
  @Local isSpeakerEnabled: boolean = false;
  @Local isVideoEnabled: boolean = false;

  private timerId: number = -1;
  private callService: ICallService | null = null;

  aboutToAppear(): void {
    // 获取路由参数
    const params = router.getParams() as Record<string, Object>;
    const callId = params?.callId as string;

    if (callId) {
      this.loadCallInfo(callId);
      this.startTimer();
    }

    // 初始化服务
    this.initializeService();
  }

  aboutToDisappear(): void {
    this.stopTimer();
  }

  private initializeService(): void {
    // 从单例获取 CallService
    this.callService = CallServiceImpl.getInstance();
  }

  private loadCallInfo(callId: string): void {
    // 从服务获取通话信息
    if (this.callService) {
      this.callInfo = this.callService.getCurrentCall();
      if (this.callInfo) {
        this.isMuted = this.callInfo.isMuted;
        this.isSpeakerEnabled = this.callInfo.isSpeakerEnabled;
        this.isVideoEnabled = this.callInfo.isVideoEnabled;
      }
    }
  }

  private startTimer(): void {
    this.timerId = setInterval(() => {
      this.callDuration++;
    }, 1000);
  }

  private stopTimer(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  /**
   * 格式化通话时长
   */
  private formatDuration(seconds: number): string {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;

    if (hours > 0) {
      return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    }
    return `${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  /**
   * 挂断通话
   */
  private async endCall(): Promise<void> {
    try {
      if (this.callService && this.callInfo) {
        await this.callService.endCall(this.callInfo.id);
      }
      router.back();
    } catch (error) {
      console.error('挂断通话失败:', error);
    }
  }

  /**
   * 切换静音
   */
  private async toggleMute(): Promise<void> {
    try {
      if (this.callService && this.callInfo) {
        this.isMuted = !this.isMuted;
        await this.callService.toggleMute(this.callInfo.id, this.isMuted);
      }
    } catch (error) {
      console.error('切换静音失败:', error);
    }
  }

  /**
   * 切换扬声器
   */
  private async toggleSpeaker(): Promise<void> {
    try {
      if (this.callService) {
        this.isSpeakerEnabled = !this.isSpeakerEnabled;
        await this.callService.toggleSpeaker(this.isSpeakerEnabled);
      }
    } catch (error) {
      console.error('切换扬声器失败:', error);
    }
  }

  /**
   * 切换摄像头
   */
  private async toggleVideo(): Promise<void> {
    try {
      if (this.callService && this.callInfo) {
        this.isVideoEnabled = !this.isVideoEnabled;
        await this.callService.toggleVideo(this.callInfo.id, this.isVideoEnabled);
      }
    } catch (error) {
      console.error('切换摄像头失败:', error);
    }
  }

  /**
   * 切换摄像头方向
   */
  private async switchCamera(): Promise<void> {
    try {
      if (this.callService) {
        await this.callService.switchCamera();
      }
    } catch (error) {
      console.error('切换摄像头方向失败:', error);
    }
  }

  @Builder
  CallControlButton(icon: ResourceStr, label: string, isActive: boolean, onClick: () => void) {
    Column() {
      Column() {
        Image(icon)
          .width(24)
          .height(24)
          .fillColor(isActive ? '#007AFF' : Color.White)
      }
      .width(56)
      .height(56)
      .borderRadius(28)
      .backgroundColor(isActive ? 'rgba(255, 255, 255, 0.2)' : 'rgba(255, 255, 255, 0.1)')
      .justifyContent(FlexAlign.Center)

      Text(label)
        .fontSize(12)
        .fontColor(Color.White)
        .margin({ top: 4 })
    }
    .onClick(onClick)
  }

  build() {
    Stack() {
      // 背景视频流（视频通话）
      if (this.isVideoEnabled && this.callInfo?.type === 'video') {
        // 远程视频流渲染（通过 Native WebRTC Surface 集成）
        // 实际视频流由 feature-calls/src/main/cpp/ 层的 WebRTC 模块处理
        // 此处为占位，视频流通过 Native 组件渲染
        Column() {
          Text('远程视频流')
            .fontSize(14)
            .fontColor(Color.White)
            .opacity(0.5)
        }
          .width('100%')
          .height('100%')
          .backgroundColor(Color.Black)
          .justifyContent(FlexAlign.Center)
      } else {
        // 语音通话背景
        Image(this.callInfo?.peerAvatar || $r('app.media.default_avatar'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .blur(50)
      }

      // 遮罩层
      Column() {
        // 顶部信息
        Column() {
          Text(this.callInfo?.peerName || 'Unknown')
            .fontSize(24)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)

          Text(this.formatDuration(this.callDuration))
            .fontSize(16)
            .fontColor(Color.White)
            .opacity(0.8)
            .margin({ top: 8 })
        }
        .width('100%')
        .padding({ top: 50 })

        // 主内容区
        Column() {
          if (this.callInfo?.type === 'voice') {
            // 语音通话显示头像
            Image(this.callInfo?.peerAvatar || $r('app.media.default_avatar'))
              .width(120)
              .height(120)
              .borderRadius(60)
              .objectFit(ImageFit.Cover)
          } else {
            // 视频通话显示本地预览
            // 本地视频流预览（通过 Native WebRTC Surface 集成）
            // 实际预览由 Native 组件渲染
            Column() {
              Text('本地预览')
                .fontSize(10)
                .fontColor(Color.White)
                .opacity(0.5)
            }
              .width(120)
              .height(160)
              .borderRadius(12)
              .backgroundColor('rgba(0, 0, 0, 0.5)')
              .justifyContent(FlexAlign.Center)
          }
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)

        // 底部控制区
        Column() {
          Row() {
            this.CallControlButton(
              $r('app.media.ic_mute'),
              this.isMuted ? '已静音' : '静音',
              this.isMuted,
              () => this.toggleMute()
            )

            this.CallControlButton(
              $r('app.media.icon_tools'),
              this.isSpeakerEnabled ? '扬声器' : '免提',
              this.isSpeakerEnabled,
              () => this.toggleSpeaker()
            )

            // 挂断按钮
            Column() {
              Column() {
                Image($r('app.media.icon_remove'))
                  .width(32)
                  .height(32)
                  .fillColor(Color.White)
              }
              .width(72)
              .height(72)
              .borderRadius(36)
              .backgroundColor('#FF3B30')
              .justifyContent(FlexAlign.Center)
            }
            .onClick(() => this.endCall())

            if (this.callInfo?.type === 'video') {
              this.CallControlButton(
                $r('app.media.ic_edit'),
                '翻转',
                false,
                () => this.switchCamera()
              )

              this.CallControlButton(
                $r('app.media.ic_none_message'),
                this.isVideoEnabled ? '关闭视频' : '开启视频',
                !this.isVideoEnabled,
                () => this.toggleVideo()
              )
            } else {
              this.CallControlButton(
                $r('app.media.icon_view'),
                '视频',
                false,
                () => this.toggleVideo()
              )
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
          .padding({ left: 20, right: 20, bottom: 48 })
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [['rgba(0,0,0,0.6)', 0.0], ['rgba(0,0,0,0.8)', 1.0]]
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}
