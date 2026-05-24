/**
 * 通话参与者页面
 * @module feature-calls.pages
 */

import { router } from '@kit.ArkUI';
import { GroupCallInfo, CallParticipant } from '../../models';
import { CallServiceImpl } from '../../services/business/calls/CallServiceImpl';

/**
 * 通话参与者页面组件
 */
@Entry
@ComponentV2
struct CallParticipantsPage {
  @Local groupCallInfo: GroupCallInfo | null = null;
  @Local participants: CallParticipant[] = [];

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    const callId = params?.callId as string;

    if (callId) {
      this.loadParticipants(callId);
    }
  }

  private loadParticipants(callId: string): void {
    const callService = CallServiceImpl.getInstance();
    const currentCall = callService.getCurrentCall();

    if (currentCall && currentCall.id === callId) {
      // 从当前通话信息构建参与者列表
      this.participants = [{
        userId: currentCall.peerId,
        userName: currentCall.peerName,
        userAvatar: currentCall.peerAvatar,
        isSpeaking: false,
        isMuted: currentCall.isMuted,
        isVideoEnabled: currentCall.isVideoEnabled,
        isHandRaised: false,
        audioLevel: 0
      }];

      // 从群组通话信息获取参与者（如果有）
      if (this.groupCallInfo && this.groupCallInfo.participants) {
        this.participants = this.groupCallInfo.participants;
      }
    }
  }

  @Builder
  ParticipantItem(participant: CallParticipant) {
    Row() {
      Image(participant.userAvatar || $r('app.media.default_avatar'))
        .width(48)
        .height(48)
        .borderRadius(24)
        .objectFit(ImageFit.Cover)
        .margin({ right: 12 })

      Column() {
        Text(participant.userName)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)

        Row() {
          if (participant.isSpeaking) {
            Row() {
              Circle()
                .width(8)
                .height(8)
                .fill('#34C759')
                .margin({ right: 4 })
              Text('正在说话')
                .fontSize(12)
                .fontColor('#34C759')
            }
            .margin({ right: 8 })
          }

          if (participant.isMuted) {
            Row() {
              Image($r('app.media.ic_mute'))
                .width(12)
                .height(12)
                .fillColor('#8E8E93')
                .margin({ right: 4 })
              Text('已静音')
                .fontSize(12)
                .fontColor('#8E8E93')
            }
          }

          if (participant.isHandRaised) {
            Row() {
              Image($r('app.media.icon_warning'))
                .width(12)
                .height(12)
                .fillColor('#FF9500')
                .margin({ right: 4 })
              Text('举手')
                .fontSize(12)
                .fontColor('#FF9500')
            }
          }
        }
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 音量指示器
      if (participant.audioLevel > 0) {
        Column() {
          ForEach([0, 1, 2, 3, 4], (index: number) => {
            Row()
              .width(4)
              .height(12)
              .backgroundColor(index < participant.audioLevel / 20 ? '#34C759' : 'rgba(255, 255, 255, 0.2)')
              .borderRadius(2)
              .margin({ top: 2 })
          })
        }
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(255, 255, 255, 0.05)')
    .borderRadius(8)
    .margin({ bottom: 8 })
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

        Text('通话参与者')
          .fontSize(18)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 24 })

        if (this.groupCallInfo) {
          Text(`${this.groupCallInfo.participantCount}人`)
            .fontSize(14)
            .fontColor('rgba(255, 255, 255, 0.7)')
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 50, bottom: 16 })

      // 参与者列表
      if (this.participants.length > 0) {
        List() {
          ForEach(this.participants, (participant: CallParticipant) => {
            ListItem() {
              this.ParticipantItem(participant)
            }
          }, (participant: CallParticipant) => participant.userId.toString())
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      } else {
        Column() {
          Text('暂无参与者')
            .fontSize(16)
            .fontColor('#8E8E93')
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}
