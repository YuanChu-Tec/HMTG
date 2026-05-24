/**
 * 群组通话页面
 * @module feature-calls.pages
 */

import { router } from '@kit.ArkUI';
import { GroupCallInfo, CallParticipant, CallType, CallState, CallDirection, GroupCallInfoImpl, GroupCallInfoParams } from '../../models';
import { ICallService } from '../../services/business/calls/ICallService';
import { CallServiceImpl } from '../../services/business/calls/CallServiceImpl';

/**
 * 群组通话页面组件
 */
@Entry
@ComponentV2
struct GroupCallPage {
  @Local groupCallInfo: GroupCallInfo | null = null;
  @Local callDuration: number = 0;
  @Local isMuted: boolean = false;
  @Local isSpeakerEnabled: boolean = false;
  @Local isVideoEnabled: boolean = false;

  private timerId: number = -1;
  private callService: ICallService | null = null;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    const callId = params?.callId as string;

    if (callId) {
      this.loadGroupCallInfo(callId);
      this.startTimer();
    }

    this.initializeService();
  }

  aboutToDisappear(): void {
    this.stopTimer();
  }

  private initializeService(): void {
    // 从单例获取 CallService
    this.callService = CallServiceImpl.getInstance();
  }

  private async loadGroupCallInfo(callId: string): Promise<void> {
    try {
      if (this.callService) {
        const currentCall = this.callService.getCurrentCall();
        if (currentCall && currentCall.id === callId) {
          // 使用实现类创建群组通话信息
          const params: GroupCallInfoParams = {
            id: currentCall.id,
            type: CallType.GROUP_VOICE,
            state: CallState.CONNECTED,
            direction: CallDirection.OUTGOING,
            peerId: currentCall.peerId,
            peerName: currentCall.peerName,
            peerAvatar: currentCall.peerAvatar,
            startTime: currentCall.startTime,
            duration: 0,
            isMuted: currentCall.isMuted,
            isVideoEnabled: currentCall.isVideoEnabled,
            isSpeakerEnabled: currentCall.isSpeakerEnabled,
            participantCount: 1,
            participants: []
          };
          
          const groupCallInfo = new GroupCallInfoImpl(params);
          this.groupCallInfo = groupCallInfo;
          this.isMuted = currentCall.isMuted;
          this.isSpeakerEnabled = currentCall.isSpeakerEnabled;
          this.isVideoEnabled = currentCall.isVideoEnabled;
        }
      }
    } catch (error) {
      console.error('Failed to load group call info:', error);
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

  private formatDuration(seconds: number): string {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;

    if (hours > 0) {
      return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    }
    return `${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  private async endCall(): Promise<void> {
    try {
      if (this.callService && this.groupCallInfo) {
        await this.callService.endCall(this.groupCallInfo.id);
      }
      router.back();
    } catch (error) {
      console.error('挂断通话失败:', error);
    }
  }

  private async toggleMute(): Promise<void> {
    try {
      if (this.callService && this.groupCallInfo) {
        this.isMuted = !this.isMuted;
        await this.callService.toggleMute(this.groupCallInfo.id, this.isMuted);
      }
    } catch (error) {
      console.error('切换静音失败:', error);
    }
  }

  @Builder
  ParticipantView(participant: CallParticipant) {
    Stack() {
      Image(participant.userAvatar || $r('app.media.default_avatar'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .borderRadius(8)

      // 正在说话指示器
      if (participant.isSpeaking) {
        Row() {
          Circle()
            .width(12)
            .height(12)
            .fill($r('app.color.call_speaking_indicator'))
            .margin({ right: 4 })

          Text('正在说话')
            .fontSize(10)
            .fontColor(Color.White)
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor('rgba(52, 199, 89, 0.9)')
        .borderRadius(12)
        .position({ x: 8, y: 8 })
      }

      // 静音指示器
      if (participant.isMuted) {
        Image($r('app.media.icon_mute'))
          .width(16)
          .height(16)
          .fillColor(Color.White)
          .position({ x: 8, y: 8 })
      }

      // 用户名称
      Text(participant.userName)
        .fontSize(12)
        .fontColor(Color.White)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .padding({ left: 6, right: 6, top: 3, bottom: 3 })
        .backgroundColor('rgba(0, 0, 0, 0.6)')
        .borderRadius(4)
        .position({ x: 8, y: '70%' })
    }
    .width('100%')
    .height('100%')
    .borderRadius(8)
    .backgroundColor('#1C1C1E')
  }

  build() {
    Column() {
      // 顶部信息栏
      Column() {
        Text('群组通话')
          .fontSize(18)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)

        Row() {
          Text(this.formatDuration(this.callDuration))
            .fontSize(14)
            .fontColor('rgba(255, 255, 255, 0.8)')
            .margin({ right: 16 })

          if (this.groupCallInfo) {
            Text(`${this.groupCallInfo.participantCount}人`)
              .fontSize(14)
              .fontColor('rgba(255, 255, 255, 0.8)')
          }
        }
        .margin({ top: 4 })
      }
      .width('100%')
      .padding({ top: 50, bottom: 16 })

      // 参与者网格
      if (this.groupCallInfo && this.groupCallInfo.participants.length > 0) {
        Grid() {
          ForEach(this.groupCallInfo.participants, (participant: CallParticipant) => {
            GridItem() {
              this.ParticipantView(participant)
            }
          }, (participant: CallParticipant) => participant.userId.toString())
        }
        .columnsTemplate('1fr 1fr')
        .rowsGap(8)
        .columnsGap(8)
        .width('100%')
        .height(0)
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      } else {
        Column() {
          Text('等待参与者加入...')
            .fontSize(16)
            .fontColor('#8E8E93')
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }

      // 底部控制栏
      Column() {
        Row() {
          // 静音按钮
          Column() {
            Image(this.isMuted ? $r('app.media.icon_mute') : $r('app.media.icon_mic'))
              .width(24)
              .height(24)
              .fillColor(Color.White)
            Text('静音')
              .fontSize(12)
              .fontColor(Color.White)
              .margin({ top: 4 })
          }
          .onClick(() => this.toggleMute())

          // 扬声器按钮
          Column() {
            Image($r('app.media.icon_speaker'))
              .width(24)
              .height(24)
              .fillColor(Color.White)
            Text('扬声器')
              .fontSize(12)
              .fontColor(Color.White)
              .margin({ top: 4 })
          }
          .margin({ left: 24 })

          // 挂断按钮
          Column() {
            Column() {
              Image($r('app.media.icon_hangup'))
                .width(32)
                .height(32)
                .fillColor(Color.White)
            }
            .width(72)
            .height(72)
            .borderRadius(36)
            .backgroundColor('#FF3B30')
            .justifyContent(FlexAlign.Center)

            Text('挂断')
              .fontSize(12)
              .fontColor(Color.White)
              .margin({ top: 4 })
          }
          .margin({ left: 40 })
          .onClick(() => this.endCall())
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 48 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}
