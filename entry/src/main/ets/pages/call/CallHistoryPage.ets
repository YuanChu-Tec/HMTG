/**
 * 通话记录页面
 * @module feature-calls.pages
 */

import { router } from '@kit.ArkUI';
import { CallRecord, CallType, CallDirection } from '../../models';
import { CallServiceImpl } from '../../services/business/calls/CallServiceImpl';

/**
 * 通话记录页面组件
 */
@Entry
@ComponentV2
struct CallHistoryPage {
  @Local callHistory: CallRecord[] = [];
  @Local isLoading: boolean = true;

  private callService: CallServiceImpl = CallServiceImpl.getInstance();

  aboutToAppear(): void {
    this.loadCallHistory();
  }

  /**
   * 加载通话记录
   */
  private async loadCallHistory(): Promise<void> {
    try {
      this.callHistory = await this.callService.getCallHistory(50);
      this.isLoading = false;
    } catch (error) {
      console.error('加载通话记录失败:', error);
      this.isLoading = false;
    }
  }

  /**
   * 清除通话记录
   */
  private async clearHistory(): Promise<void> {
    try {
      await this.callService.clearCallHistory();
      this.callHistory = [];
    } catch (error) {
      console.error('清除通话记录失败:', error);
    }
  }

  /**
   * 格式化日期
   */
  private formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const callDate = new Date(date.getFullYear(), date.getMonth(), date.getDate());

    if (callDate.getTime() === today.getTime()) {
      return `今天 ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
    } else if (callDate.getTime() === today.getTime() - 86400000) {
      return `昨天 ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
    } else {
      return `${date.getMonth() + 1}月${date.getDate()}日 ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
    }
  }

  /**
   * 格式化时长
   */
  private formatDuration(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }

  /**
   * 获取通话类型图标
   */
  private getCallTypeIcon(record: CallRecord): Resource {
    if (record.callType === CallType.VIDEO) {
      return $r('app.media.icon_video_call');
    }
    return $r('app.media.icon_voice_call');
  }

  /**
   * 获取通话类型颜色
   */
  private getCallTypeColor(record: CallRecord): string {
    if (record.isMissed) {
      return '#FF3B30';
    }
    return '#8E8E93';
  }

  /**
   * 显示通话详情
   */
  private showCallDetails(record: CallRecord): void {
    // 使用系统对话框显示通话详情
    AlertDialog.show({
      title: '通话详情',
      message: this.buildDetailsMessage(record),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '拨打电话',
        action: () => {
          // 导航到拨号或联系人页面
          this.callBack(record.peerId);
        }
      },
      secondaryButton: {
        value: '关闭',
        action: () => {}
      }
    });
  }

  /**
   * 构建详情消息内容
   */
  private buildDetailsMessage(record: CallRecord): string {
    const typeStr = record.callType === CallType.VIDEO ? '视频通话' : '语音通话';
    const directionStr = record.direction === CallDirection.OUTGOING ? '拨出' : '接听';
    const durationStr = record.duration > 0 ? `${Math.floor(record.duration / 60)}分${record.duration % 60}秒` : '0秒';
    const dateStr = this.formatDate(record.startTime);

    return `联系人: ${record.peerName}\n类型: ${typeStr}\n方向: ${directionStr}\n时长: ${durationStr}\n时间: ${dateStr}`;
  }

  /**
   * 回拨电话
   */
  private async callBack(peerId: number): Promise<void> {
    try {
      // 导航到联系人页面或发起通话
      await router.pushUrl({
        url: 'pages/ContactDetailPage',
        params: { userId: peerId }
      });
    } catch (error) {
      console.error('Failed to navigate:', error);
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

        Text('通话记录')
          .fontSize(18)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('清空')
          .fontSize(16)
          .fontColor('#FF3B30')
          .onClick(() => {
            this.clearHistory();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#1C1C1E')

      // 通话记录列表
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color('#8E8E93')
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#000000')
      } else if (this.callHistory.length === 0) {
        Column() {
          Text('暂无通话记录')
            .fontSize(16)
            .fontColor('#8E8E93')
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#000000')
      } else {
        List() {
          ForEach(this.callHistory, (record: CallRecord) => {
            ListItem() {
              Row() {
                // 头像
                Image(record.peerAvatar || $r('app.media.default_avatar'))
                  .width(48)
                  .height(48)
                  .borderRadius(24)
                  .objectFit(ImageFit.Cover)
                  .margin({ right: 12 })

                // 信息
                Column() {
                  Row() {
                    Text(record.peerName)
                      .fontSize(16)
                      .fontColor(record.isMissed ? '#FF3B30' : Color.White)
                      .fontWeight(FontWeight.Medium)
                      .layoutWeight(1)

                    Text(this.formatDate(record.startTime))
                      .fontSize(14)
                      .fontColor('#8E8E93')
                  }
                  .width('100%')

                  Row() {
                    Image(this.getCallTypeIcon(record))
                      .width(16)
                      .height(16)
                      .fillColor(this.getCallTypeColor(record))
                      .margin({ right: 4 })

                    if (record.isMissed) {
                      Text('未接听')
                        .fontSize(14)
                        .fontColor('#FF3B30')
                    } else if (record.direction === CallDirection.OUTGOING) {
                      Text(`拨出 ${this.formatDuration(record.duration)}`)
                        .fontSize(14)
                        .fontColor('#8E8E93')
                    } else {
                      Text(`接听 ${this.formatDuration(record.duration)}`)
                        .fontSize(14)
                        .fontColor('#8E8E93')
                    }

                    Blank()

                    // 信息图标
                    Image($r('app.media.icon_info'))
                      .width(20)
                      .height(20)
                      .fillColor('#007AFF')
                  }
                  .width('100%')
                  .margin({ top: 4 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            }
            .width('100%')
            .onClick(() => {
              // 显示通话详情对话框
              this.showCallDetails(record);
            })
          }, (record: CallRecord) => record.id)
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor('#000000')
        .divider({
          strokeWidth: 1,
          color: '#1C1C1E'
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}
