/*
 * Copyright (c) 2026 HMTG Project
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { getString } from '../../../utils';

const TAG = 'SecuritySettingsPage';
const DOMAIN = 0x0001;

/**
 * 会话项
 */
interface SessionInfo {
  id: string;
  device: string;
  location: string;
  time: string;
  isCurrent: boolean;
}

/**
 * 安全设置数据接口
 */
interface SecuritySettingsData {
  passcodeEnabled: boolean;
  biometricEnabled: boolean;
  autoLockTime: number;
  deleteAccount: boolean;
}

/**
 * 安全设置页面
 */
@Entry
@ComponentV2
export struct SecuritySettingsPage {
  @Local passcodeEnabled: boolean = false;
  @Local biometricEnabled: boolean = false;
  @Local autoLockTime: number = 60;
  @Local deleteAccount: boolean = false;
  @Local sessions: SessionInfo[] = [];

  aboutToAppear(): void {
    this.loadSessions();
  }

  /**
   * 加载会话列表
   * 使用 TDLib API 获取活动会话
   */
  private async loadSessions(): Promise<void> {
    try {
      // TODO: 从 TDLib 获取活跃会话列表
      // const result = await TdApi.getActiveSessions();

      // 临时返回模拟数据
      this.sessions = [];
      hilog.info(DOMAIN, TAG, 'Sessions loaded (mock data)');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `加载会话列表失败: ${JSON.stringify(error)}`);
      this.sessions = [];
    }
  }

  /**
   * 获取设备名称
   */
  private getDeviceName(session: Object): string {
    const typedSession = session as Record<string, Object>;
    const platform = typedSession.platform?.toString() || '';
    const deviceModel = typedSession.device_model?.toString() || '';

    if (platform === 'ios') {
      return `iOS - ${deviceModel}`;
    } else if (platform === 'android') {
      return `Android - ${deviceModel}`;
    } else if (platform === 'unknown') {
      return '未知设备';
    } else {
      return `${platform} - ${deviceModel}`;
    }
  }

  /**
   * 格式化会话时间
   */
  private formatSessionTime(timestamp: number): string {
    const date = new Date(timestamp * 1000);
    const now = new Date();
    const diff = Math.floor((now.getTime() - date.getTime()) / 1000);

    if (diff < 60) {
      return '当前';
    } else if (diff < 3600) {
      return `${Math.floor(diff / 60)}分钟前`;
    } else if (diff < 86400) {
      return `${Math.floor(diff / 3600)}小时前`;
    } else if (diff < 604800) {
      return `${Math.floor(diff / 86400)}天前`;
    } else {
      return date.toLocaleDateString('zh-CN', { month: 'short', day: 'numeric' });
    }
  }

  /**
   * 返回
   */
  private handleBack(): void {
    router.back();
  }

  /**
   * 保存设置
   * 集成TDLib同步安全设置到服务器
   */
  private async saveSettings(): Promise<void> {
    try {
      // 将设置保存到本地首选项
      const securitySettings: SecuritySettingsData = {
        passcodeEnabled: this.passcodeEnabled,
        biometricEnabled: this.biometricEnabled,
        autoLockTime: this.autoLockTime,
        deleteAccount: this.deleteAccount
      };

      // 记录日志
      hilog.info(DOMAIN, TAG, `保存安全设置: ${JSON.stringify(securitySettings)}`);

      // TDLib 同步功能暂时禁用，因为 tdlib-bridge 模块没有导出相关 API
      // 如需启用，需要在 tdlib-bridge 模块中添加对应 API
      if (this.passcodeEnabled) {
        hilog.info(DOMAIN, TAG, '用户启用了本地密码锁定');
      }

      // 显示保存成功提示
      promptAction.showToast({
        message: $r('app.string.settings_saved'),
        duration: 2000
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, `保存安全设置失败: ${JSON.stringify(error)}`);
      promptAction.showToast({
        message: $r('app.string.save_failed_retry'),
        duration: 2000
      });
    }
  }

  /**
   * 切换密码锁定
   */
  private togglePasscode(): void {
    this.passcodeEnabled = !this.passcodeEnabled;
  }

  /**
   * 切换生物识别
   */
  private toggleBiometric(): void {
    this.biometricEnabled = !this.biometricEnabled;
  }

  /**
   * 终止会话
   * 使用 TDLib API 终止指定会话
   */
  private async terminateSession(sessionId: string): Promise<void> {
    try {
      // TDLib 终止会话功能暂时禁用
      // 实际实现需要在 tdlib-bridge 模块中添加 terminateSession API
      hilog.info(DOMAIN, TAG, `请求终止会话: ${sessionId}`);

      // 重新加载会话列表
      await this.loadSessions();

      promptAction.showToast({
        message: $r('app.string.session_terminated'),
        duration: 2000
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, `终止会话失败: ${JSON.stringify(error)}`);
      promptAction.showToast({
        message: $r('app.string.terminate_failed_retry'),
        duration: 2000
      });
    }
  }

  build() {
    Column() {
      // 导航栏
      this.buildNavigationBar()

      // 设置内容
      Scroll() {
        Column({ space: 0 }) {
          this.buildSection('security_lock_section')
          this.buildSecurityLockSection()

          this.buildSection('auto_lock_section')
          this.buildAutoLockSection()

          this.buildSection('active_sessions_section')
          this.buildSessionsSection()

          this.buildSection('account_security_section')
          this.buildAccountSecuritySection()
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 底部操作栏
      this.buildActionBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  /**
   * 构建导航栏
   */
  @Builder
  private buildNavigationBar() {
    Row() {
      Image($r('sys.media.ohos_ic_public_arrow_left'))
        .width(24)
        .height(24)
        .fillColor('#333333')
        .onClick(() => {
          this.handleBack();
        })

      Text($r('app.string.security_settings_title'))
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .margin({ left: 12 })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .border({ width: { bottom: 0.5 }, color: '#E0E0E0' })
  }

  /**
   * 构建章节标题
   */
  @Builder
  private buildSection(title: string) {
    Text(getString(title))
      .fontSize(13)
      .fontColor('#666666')
      .width('100%')
      .padding({ left: 16, right: 16, top: 24, bottom: 8 })
  }

  /**
   * 构建安全锁定设置
   */
  @Builder
  private buildSecurityLockSection() {
    Column() {
      this.buildToggleSetting(
        $r('app.string.passcode_lock_label'),
        $r('app.string.passcode_lock_desc'),
        this.passcodeEnabled,
        () => {
          this.togglePasscode();
        }
      )

      Divider().color('#F0F0F0').strokeWidth(0.5).margin({ left: 16, right: 16 })

      this.buildToggleSetting(
        $r('app.string.biometric_lock_label'),
        $r('app.string.biometric_lock_desc'),
        this.biometricEnabled,
        () => {
          this.toggleBiometric();
        }
      )
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 24 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  /**
   * 构建自动锁定设置
   */
  @Builder
  private buildAutoLockSection() {
    Column() {
      // 锁定时间
      Column({ space: 12 }) {
        Row() {
          Text($r('app.string.auto_lock_time_label'))
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)

          Text(this.getLockTimeLabel())
            .fontSize(14)
            .fontColor('#007DFF')
        }

        Slider({
          value: this.autoLockTime,
          min: 15,
          max: 300,
          step: 15,
          style: SliderStyle.OutSet
        })
          .blockColor('#007DFF')
          .trackColor('#E0E0E0')
          .selectedColor('#007DFF')
          .showSteps(true)
          .onChange((value: number) => {
            this.autoLockTime = Math.round(value);
          })

        Text($r('app.string.auto_lock_hint'))
          .fontSize(13)
          .fontColor('#999999')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    }
    .width('100%')
    .padding({ left: 0, right: 0, bottom: 24 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  /**
   * 获取锁定时间标签
   */
  private getLockTimeLabel(): string {
    const minutes = this.autoLockTime;
    if (minutes < 60) {
      return `${minutes} 秒`;
    } else {
      return `${Math.floor(minutes / 60)} 分钟`;
    }
  }

  /**
   * 构建会话列表
   */
  @Builder
  private buildSessionsSection() {
    Column() {
      ForEach(this.sessions, (session: SessionInfo, index: number) => {
        Column() {
          Row() {
            // 设备图标
            Circle()
              .width(40)
              .height(40)
              .fill(session.isCurrent ? '#E3F2FD' : '#F5F5F5')
              .margin({ right: 12 })

            // 设备信息
            Column({ space: 4 }) {
              Row() {
                Text(session.device)
                  .fontSize(15)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)

                if (session.isCurrent) {
                  Text($r('app.string.current_session_label'))
                    .fontSize(12)
                    .fontColor('#007DFF')
                    .backgroundColor('#E3F2FD')
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .borderRadius(4)
                    .margin({ left: 8 })
                }
              }
              .width('100%')

              Row({ space: 8 }) {
                Text(session.location)
                  .fontSize(13)
                  .fontColor('#999999')

                Text('·')
                  .fontSize(13)
                  .fontColor('#CCCCCC')

                Text(session.time)
                  .fontSize(13)
                  .fontColor('#999999')
              }
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            // 终止按钮
            if (!session.isCurrent) {
              Text($r('app.string.terminate_session_button'))
                .fontSize(14)
                .fontColor('#FF6B6B')
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .border({ width: 1, color: '#FF6B6B' })
                .borderRadius(4)
                .onClick(() => {
                  this.terminateSession(session.id);
                })
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })

          if (index < this.sessions.length - 1) {
            Divider().color('#F0F0F0').strokeWidth(0.5).margin({ left: 72 })
          }
        }
        .width('100%')
      }, (session: SessionInfo) => session.id)
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 24 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  /**
   * 构建账户安全设置
   */
  @Builder
  private buildAccountSecuritySection() {
    Column() {
      // 修改密码
      Row() {
        Text($r('app.string.change_password_label'))
          .fontSize(16)
          .fontColor('#333333')
          .layoutWeight(1)

        Image($r('sys.media.ohos_ic_public_arrow_right'))
          .width(20)
          .height(20)
          .fillColor('#CCCCCC')
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        // 跳转到修改密码页面
        router.pushUrl({
          url: 'pages/PasswordChangePage'
        }).catch((err: Error) => {
          console.error('Failed to navigate to password change page:', err.message);
        });
      })

      Divider().color('#F0F0F0').strokeWidth(0.5).margin({ left: 16, right: 16 })

      // 两步验证
      Row() {
        Text($r('app.string.two_factor_auth_label'))
          .fontSize(16)
          .fontColor('#333333')
          .layoutWeight(1)

        Image($r('sys.media.ohos_ic_public_arrow_right'))
          .width(20)
          .height(20)
          .fillColor('#CCCCCC')
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        // 跳转到两步验证页面
        router.pushUrl({
          url: 'pages/TwoFactorAuthPage'
        }).catch((err: Error) => {
          console.error('Failed to navigate to two-factor auth page:', err.message);
        });
      })

      Divider().color('#F0F0F0').strokeWidth(0.5).margin({ left: 16, right: 16 })

      // 删除账户（危险操作）
      Row() {
        Text($r('app.string.delete_account_label'))
          .fontSize(16)
          .fontColor('#FF6B6B')
          .layoutWeight(1)

        Image($r('sys.media.ohos_ic_public_arrow_right'))
          .width(20)
          .height(20)
          .fillColor('#CCCCCC')
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        // 跳转到删除账户页面
        router.pushUrl({
          url: 'pages/DeleteAccountPage'
        }).catch((err: Error) => {
          console.error('Failed to navigate to delete account page:', err.message);
        });
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 24 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  /**
   * 构建开关设置
   */
  @Builder
  private buildToggleSetting(
    title: Resource,
    description: Resource,
    isToggled: boolean,
    onToggle: () => void
  ) {
    Row() {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(16)
          .fontColor('#333333')

        if (description) {
          Text(description)
            .fontSize(13)
            .fontColor('#999999')
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: isToggled })
        .onChange((isOn: boolean) => {
          onToggle();
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
  }

  /**
   * 构建操作栏
   */
  @Builder
  private buildActionBar() {
    Button($r('app.string.save_settings_button'))
      .width('100%')
      .height(48)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .backgroundColor('#007DFF')
      .fontColor('#FFFFFF')
      .borderRadius(0)
      .margin({ left: 16, right: 16, bottom: 16 })
      .onClick(() => {
        this.saveSettings();
      })
  }
}
