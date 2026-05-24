/**
 * 来电页面
 * @module feature-calls.pages
 */

import { router } from '@kit.ArkUI';
import { CallSession, CallState, CallDirection, CallType } from '../../models';
import { ICallService } from '../../services/business/calls/ICallService';
import { CallServiceImpl } from '../../services/business/calls/CallServiceImpl';

/**
 * 来电页面组件
 */
@Entry
@ComponentV2
struct IncomingCallPage {
  @Local callInfo: CallSession = {
    id: '',
    type: CallType.VOICE,
    state: CallState.RINGING,
    direction: CallDirection.INCOMING,
    peerId: 0,
    peerName: '',
    startTime: Date.now(),
    duration: 0,
    isMuted: false,
    isVideoEnabled: false,
    isSpeakerEnabled: false
  };

  private callService: ICallService | null = null;

  aboutToAppear(): void {
    // 获取路由参数
    const params = router.getParams() as Record<string, Object>;
    if (params && params.callInfo) {
      this.callInfo = params.callInfo as CallSession;
    }

    // 初始化服务
    this.initializeService();
  }

  private initializeService(): void {
    // 从单例获取 CallService
    this.callService = CallServiceImpl.getInstance();
  }

  /**
   * 接听通话
   */
  private async acceptCall(): Promise<void> {
    try {
      if (this.callService) {
        await this.callService.acceptCall(this.callInfo.id);
        // 跳转到通话中页面
        router.pushUrl({
          url: '@bundle:com.YuanChu.HMTG/feature-calls/ets/pages/ActiveCallPage',
          params: { callId: this.callInfo.id }
        });
      }
    } catch (error) {
      console.error('接听通话失败:', error);
    }
  }

  /**
   * 拒绝通话
   */
  private async rejectCall(): Promise<void> {
    try {
      if (this.callService) {
        await this.callService.rejectCall(this.callInfo.id);
      }
      router.back();
    } catch (error) {
      console.error('拒绝通话失败:', error);
    }
  }

  build() {
    Column() {
      // 顶部状态栏占位
      Column()
        .height(50)
        .width('100%')
        .backgroundColor(Color.Transparent)

      // 主内容区
      Column() {
        // 头像
        Image(this.callInfo.peerAvatar || $r('app.media.default_avatar'))
          .width(120)
          .height(120)
          .borderRadius(60)
          .objectFit(ImageFit.Cover)

        // 用户名
        Text(this.callInfo.peerName)
          .fontSize(24)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 24 })

        // 通话类型
        Text(this.callInfo.type === 'video' ? '视频通话' : '语音通话')
          .fontSize(16)
          .fontColor(Color.White)
          .opacity(0.8)
          .margin({ top: 8 })

        // 来电动画
        Text('正在呼叫...')
          .fontSize(14)
          .fontColor(Color.White)
          .opacity(0.6)
          .margin({ top: 32 })
          .animation({
            duration: 1000,
            curve: Curve.EaseInOut,
            iterations: -1
          })
      }
      .layoutWeight(1)
      .width('100%')
      .justifyContent(FlexAlign.Center)

      // 底部操作区
      Row() {
        // 拒绝按钮
        Column() {
          Column() {
            Image($r('app.media.icon_hangup'))
              .width(32)
              .height(32)
              .fillColor(Color.White)
          }
          .width(64)
          .height(64)
          .borderRadius(32)
          .backgroundColor('#FF3B30')
          .justifyContent(FlexAlign.Center)

          Text('拒绝')
            .fontSize(14)
            .fontColor(Color.White)
            .margin({ top: 8 })
        }
        .onClick(() => {
          this.rejectCall();
        })

        Blank()

        // 接听按钮
        Column() {
          Column() {
            Image($r('app.media.icon_call'))
              .width(32)
              .height(32)
              .fillColor(Color.White)
          }
          .width(64)
          .height(64)
          .borderRadius(32)
          .backgroundColor('#34C759')
          .justifyContent(FlexAlign.Center)

          Text('接听')
            .fontSize(14)
            .fontColor(Color.White)
            .margin({ top: 8 })
        }
        .onClick(() => {
          this.acceptCall();
        })
      }
      .width('100%')
      .padding({ left: 40, right: 40, bottom: 48 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0, 0, 0, 0.8)')
  }
}
