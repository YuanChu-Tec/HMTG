

/**
 * 锁定码解锁页（参考 Nekogram PasscodeActivity）
 */
import { router, promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { PasscodeHelper } from '../../services/system/PasscodeHelper';
import { ThemeTokenFactory } from '../../ui_kit/themes/ThemeTokens';
import { RoutePaths } from '../../utils/navigation/NavigationHelper';
import { ImmersiveContainer } from '../../components/common/ImmersiveContainer';
import { ImmersiveMode, ThemeMode } from '../../utils/utils/ImmersiveUtils';

// 获取浅色主题 Token
const theme = ThemeTokenFactory.createLightTokens();

// 从主题系统获取颜色
const TEXT_SECONDARY = theme.colors.textSecondary;
const BACKGROUND = theme.colors.background;
const BACKGROUND_SECONDARY = theme.colors.surface;
const TEXT_PRIMARY = theme.colors.text;
const TELEGRAM_BLUE = theme.colors.telegramBlue;

@Entry
@Component
struct PasscodeUnlockPage {
  @State private passcode: string = '';

  async aboutToAppear(): Promise<void> {
    const ctx = getContext(this) as common.UIAbilityContext;
    await PasscodeHelper.init(ctx);
    const has = await PasscodeHelper.hasPasscode();
    if (!has) {
      router.replaceUrl({ url: RoutePaths.MAIN });
    }
  }

  private async handleUnlock(): Promise<void> {
    if (this.passcode.length < 4) {
      promptAction.showToast({ message: $r('app.string.passcode_too_short'), duration: 2000 });
      return;
    }
    const ok = await PasscodeHelper.checkPasscode(this.passcode);
    if (ok) {
      router.replaceUrl({ url: RoutePaths.MAIN });
    } else {
      this.passcode = '';
      promptAction.showToast({ message: $r('app.string.passcode_incorrect'), duration: 2000 });
    }
  }

  build() {
    Column() {
      ImmersiveContainer({
        mode: ImmersiveMode.COMPONENT_TOP,
        theme: ThemeMode.AUTO,
        excludeBottom: true
      }) {
        Column() {
          Text($r('app.string.enter_passcode_title'))
            .fontSize(theme.typography.h3.fontSize)
            .fontWeight(FontWeight.Bold)
            .fontColor(TEXT_PRIMARY)
            .margin({ top: theme.spacing.xxl })

          TextInput({ placeholder: $r('app.string.enter_passcode_placeholder'), text: $$this.passcode })
            .width('80%')
            .height(48)
            .fontSize(theme.typography.body1.fontSize)
            .margin({ top: theme.spacing.xl })
            .type(InputType.Password)
            .maxLength(8)
            .onSubmit(() => this.handleUnlock())

          Button($r('app.string.unlock_button'))
            .width(150)
            .height(48)
            .fontSize(theme.typography.body1.fontSize)
            .fontColor(Color.White)
            .backgroundColor(TELEGRAM_BLUE)
            .margin({ top: theme.spacing.xl })
            .onClick(() => this.handleUnlock())
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BACKGROUND)
  }
}
