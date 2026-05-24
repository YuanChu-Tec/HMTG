/**
 * 拨号页面
 * @module feature-calls.pages
 */

import { router } from '@kit.ArkUI';
import { CallSession, CallState, CallDirection, CallType } from '../../models';
import { CallServiceImpl } from '../../services/business/calls/CallServiceImpl';
import { ICallService } from '../../services/business/calls/ICallService';

/**
 * 拨号页面组件
 */
@Entry
@ComponentV2
struct OutgoingCallPage {
  @Local callInfo: CallSession | null = null;
  @Local peerName: string = 'Unknown';
  @Local peerAvatar: string = '';
  @Local isLoading: boolean = true;

  private userId: number = 0;
  private callType: CallType = CallType.VOICE;
  private callService: CallServiceImpl = CallServiceImpl.getInstance();
  private timer?: number;

  aboutToAppear(): void {
    // 获取路由参数
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      this.userId = (params.userId as number) || 0;
      this.callType = (params.callType as CallType) || CallType.VOICE;
      this.peerName = (params.peerName as string) || 'Unknown';
      this.peerAvatar = (params.peerAvatar as string) || '';
    }

    // 发起通话
    this.initiateCall();
  }

  aboutToDisappear(): void {
    if (this.timer) {
      clearInterval(this.timer);
    }
  }

  /**
   * 发起通话
   */
  private async initiateCall(): Promise<void> {
    try {
      if (this.callType === CallType.VIDEO) {
        this.callInfo = await this.callService.makeVideoCall(this.userId);
      } else {
        this.callInfo = await this.callService.makeVoiceCall(this.userId);
      }

      // 更新用户信息
      if (this.callInfo) {
        this.callInfo.peerName = this.peerName;
        this.callInfo.peerAvatar = this.peerAvatar;
      }

      this.isLoading = false;

      // 监听通话状态变化,如果被接听则跳转到通话中页面
      this.startCallMonitoring();
    } catch (error) {
      console.error('发起通话失败:', error);
      this.isLoading = false;
      router.back();
    }
  }

  /**
   * 开始监听通话状态
   */
  private startCallMonitoring(): void {
    this.callService.onCallStateChanged((callInfo: CallSession) => {
      if (callInfo.state === CallState.CONNECTED || callInfo.state === CallState.RINGING) {
        // 跳转到通话中页面
        router.replaceUrl({
          url: '@bundle:com.YuanChu.HMTG/feature-calls/ets/pages/ActiveCallPage',
          params: { callId: callInfo.id }
        });
      }
    });
  }

  /**
   * 挂断通话
   */
  private async hangupCall(): Promise<void> {
    try {
      if (this.callInfo) {
        await this.callService.endCall(this.callInfo.id);
      }
      router.back();
    } catch (error) {
      console.error('挂断通话失败:', error);
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
        if (this.isLoading) {
          // 加载中
          LoadingProgress()
            .width(48)
            .height(48)
            .color(Color.White)

          Text('正在发起通话...')
            .fontSize(16)
            .fontColor(Color.White)
            .margin({ top: 16 })
        } else if (this.callInfo) {
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

          // 拨号动画
          Text('正在呼叫...')
            .fontSize(14)
            .fontColor(Color.White)
            .opacity(0.6)
            .margin({ top: 32 })
        }
      }
      .layoutWeight(1)
      .width('100%')
      .justifyContent(FlexAlign.Center)

      // 底部操作区
      Row() {
        // 挂断按钮
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

          Text('取消')
            .fontSize(14)
            .fontColor(Color.White)
            .margin({ top: 8 })
        }
        .onClick(() => {
          this.hangupCall();
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ bottom: 48 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0, 0, 0, 0.8)')
  }
}
