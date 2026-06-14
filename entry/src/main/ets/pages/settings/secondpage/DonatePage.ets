/**
 * 捐助页
 *
 */
import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { RoutePaths } from '../../../utils/navigation/NavigationHelper';
import { ImmersiveContainer } from '../../../components/common/ImmersiveContainer';
import { ImmersiveMode, ThemeMode as ImmersiveThemeMode } from '../../../utils/utils/ImmersiveUtils';

@Entry
@Component
export struct DonatePage {
  private getContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext;
  }

  private openUrl(url: string): void {
    this.getContext().startAbility({
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: url
    }).catch((err: Error) => {
      console.error('openUrl failed:', err);
    });
  }

  build() {
    Column() {
      ImmersiveContainer({
        mode: ImmersiveMode.COMPONENT_TOP,
        theme: ImmersiveThemeMode.AUTO,
        excludeTop: false,
        excludeBottom: true,
      }) {
        this.BuildHeader();
        Scroll() {
          Column() {
            Text($r('app.string.thanks_for_support'))
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ top: 24 })
            Text($r('app.string.donate_description'))
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 8 })
              .textAlign(TextAlign.Center)

            // 支付宝捐助二维码
            Column() {
              Text($r('app.string.recommend_alipay'))
                .fontSize(16)
                .fontColor('#333333')
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 16 })
              Image($r('app.media.donate_alipay'))
                .width(220)
                .height(220)
                .objectFit(ImageFit.Contain)
                .borderRadius(8)
            }
            .width('100%')
            .margin({ top: 24 })

            // 微信支付捐助二维码
            Column() {
              Text($r('app.string.wechat_pay'))
                .fontSize(16)
                .fontColor('#333333')
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 16 })
              Image($r('app.media.donate_wechat'))
                .width(220)
                .height(220)
                .objectFit(ImageFit.Contain)
                .borderRadius(8)
            }
            .width('100%')
            .margin({ top: 24 })

            Column() {
              this.LinkRow($r('app.string.about_title'), '');
            }
            .width('100%')
            .padding(16)
            .margin({ top: 24 })
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  LinkRow(title: Resource, url: string) {
    Row() {
      Text(title)
        .fontSize(16)
        .fontColor('#007AFF')
        .layoutWeight(1)
      Image($r('app.media.startIcon'))
        .width(20)
        .height(20)
        .fillColor('#666666')
    }
    .width('100%')
    .padding(16)
    .onClick(() => {
      if (url.length > 0) {
        this.openUrl(url);
      } else {
        router.pushUrl({ url: RoutePaths.SETTINGS_ABOUT });
      }
    })
  }

  @Builder
  BuildHeader() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        Text('←')
          .width(24)
          .height(24)
          .fontSize(24)
          .fontColor('#333333')
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .onClick(() => router.back())
      Text($r('app.string.donate_title'))
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
    }
    .width('100%')
    .height(56)
    .padding({ left: 12, right: 16 })
    .backgroundColor('#FFFFFF')
  }
}
