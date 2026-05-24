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
import { common, Want } from '@kit.AbilityKit';
import { pasteboard } from '@kit.BasicServicesKit';
import { ImmersiveContainer } from '../../../components/common/ImmersiveContainer';
import { ImmersiveMode, ThemeMode as ImmersiveThemeMode } from '../../../utils/utils/ImmersiveUtils';

const TAG = 'AboutPage';
const DOMAIN = 0x0001;

/**
 * 最新版本信息接口
 */
interface LatestVersionInfo {
  version: string;
  releaseDate: string;
  changelog: string;
  downloadUrl: string;
}

/**
 * 关于页面
 */
@Entry
@Component
export struct AboutPage {
  private appVersion: string = '1.0.0';
  private buildNumber: string = '100';
  private tdlibVersion: string = '1.8.15';

  /**
   * 返回
   */
  private handleBack(): void {
    router.back();
  }

  /**
   * 复制版本信息
   */
  private async copyVersionInfo(): Promise<void> {
    const versionInfo = `HMTG for HarmonyOS\n版本: ${this.appVersion} (${this.buildNumber})\nTDLib: ${this.tdlibVersion}`;

    // 复制到剪贴板
    try {
      const systemPasteboard = pasteboard.getSystemPasteboard();
      const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, versionInfo);
      systemPasteboard.setData(pasteData);

      promptAction.showToast({
        message: '版本信息已复制',
        duration: 2000
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, '复制到剪贴板失败: ${error}');
      promptAction.showToast({
        message: '复制失败',
        duration: 2000
      });
    }
  }

  /**
   * 打开隐私政策
   */
  private async openPrivacyPolicy(): Promise<void> {
    await router.pushUrl({
      url: 'feature-settings/pages/PrivacyPolicyPage'
    });
  }

  /**
   * 打开服务条款
   */
  private async openTermsOfService(): Promise<void> {
    await router.pushUrl({
      url: 'feature-settings/pages/TermsOfServicePage'
    });
  }

  /**
   * 打开源代码
   */
  private async openSourceCode(): Promise<void> {
    try {
      const sourceCodeUrl = 'https://github.com/your-org/hmtg-harmonyos';

      // 显示提示
      promptAction.showToast({
        message: '正在打开源代码仓库...',
        duration: 1500
      });

      // 使用Want对象启动浏览器打开链接
      const context = getContext(this) as common.UIAbilityContext;
      const want: Want = {
        action: 'ohos.want.action.viewData',
        entities: ['entity.system.browsable'],
        uri: sourceCodeUrl
      };

      await context.startAbility(want);
      hilog.info(DOMAIN, TAG, `成功打开链接: ${sourceCodeUrl}`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `打开源代码链接失败: ${JSON.stringify(error)}`);
      promptAction.showToast({
        message: '打开失败，请手动访问',
        duration: 2000
      });
    }
  }

  /**
   * 检查更新
   */
  private async checkUpdate(): Promise<void> {
    try {
      // 显示检查中的提示
      promptAction.showToast({
        message: '正在检查更新...',
        duration: 1500
      });

      // 模拟版本检查API调用
      // 实际实现时，应该调用后端API检查最新版本
      const latestVersion = await this.checkLatestVersion();

      if (latestVersion) {
        if (this.isNewerVersion(latestVersion.version, this.appVersion)) {
          // 有新版本，显示更新对话框
          await promptAction.showDialog({
            title: '发现新版本',
            message: `最新版本: ${latestVersion.version}
发布日期: ${latestVersion.releaseDate}

更新内容:
${latestVersion.changelog}`,
            buttons: [
              { text: '稍后', color: '#666666' },
              { text: '立即更新', color: '#007DFF' }
            ]
          }).then((result) => {
            if (result.index === 1) {
              this.downloadUpdate(latestVersion.downloadUrl);
            }
          });
        } else {
          // 已是最新版本
          promptAction.showToast({
            message: '当前已是最新版本',
            duration: 2000
          });
        }
      } else {
        promptAction.showToast({
          message: '检查更新失败，请稍后重试',
          duration: 2000
        });
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `检查更新失败: ${JSON.stringify(error)}`);
      promptAction.showToast({
        message: '检查更新失败',
        duration: 2000
      });
    }
  }

  /**
   * 检查最新版本 (模拟实现)
   */
  private async checkLatestVersion(): Promise<LatestVersionInfo | null> {
    try {
      // 模拟网络请求延迟
      await new Promise<void>(resolve => setTimeout(resolve, 1500));

      // 实际实现时，应该调用真实的版本检查API
      // const response = await http.get('https://api.hmtg.com/version');
      // return JSON.parse(response.data);

      // 模拟返回：当前无新版本
      return {
        version: '1.0.0',
        releaseDate: '2026-02-17',
        changelog: '1. 性能优化\n2. Bug修复\n3. 新增功能',
        downloadUrl: 'https://download.hmtg.com/latest.apk'
      };
    } catch (error) {
      hilog.error(DOMAIN, TAG, `获取版本信息失败: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 比较版本号
   */
  private isNewerVersion(latest: string, current: string): boolean {
    const latestParts = latest.split('.').map(Number);
    const currentParts = current.split('.').map(Number);

    for (let i = 0; i < Math.max(latestParts.length, currentParts.length); i++) {
      const latestPart = latestParts[i] || 0;
      const currentPart = currentParts[i] || 0;

      if (latestPart > currentPart) {
        return true;
      } else if (latestPart < currentPart) {
        return false;
      }
    }

    return false;
  }

  /**
   * 下载更新 (占位实现)
   */
  private async downloadUpdate(downloadUrl: string): Promise<void> {
    try {
      promptAction.showToast({
        message: '开始下载更新...',
        duration: 2000
      });

      // 实际实现时，应该使用下载管理器下载更新包
      // const downloadTask = await DownloadManager.download(downloadUrl);
      // await DownloadManager.install(downloadTask.path);

      hilog.info(DOMAIN, TAG, `下载更新: ${downloadUrl}`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `下载更新失败: ${JSON.stringify(error)}`);
      promptAction.showToast({
        message: '下载失败，请稍后重试',
        duration: 2000
      });
    }
  }

  build() {
    Column() {
      ImmersiveContainer({
        mode: ImmersiveMode.COMPONENT_TOP,
        theme: ImmersiveThemeMode.AUTO,
        excludeTop: false,
        excludeBottom: true,
      }) {
        this.buildNavigationBar();
        Scroll() {
          Column({ space: 0 }) {
            // Logo 和版本信息
            this.buildAppInfoSection()

            // 功能特性
            this.buildFeaturesSection()

            // 链接和资源
            this.buildLinksSection()

            // 其他信息
            this.buildOtherSection()
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

      Text($r('app.string.about_title'))
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
   * 构建应用信息部分
   */
  @Builder
  private buildAppInfoSection() {
    Column({ space: 24 }) {
      // Logo - using placeholder circle
      Circle()
        .width(100)
        .height(100)
        .fill('#007DFF')

      // 应用名称
      Text($r('app.string.app_name_display'))
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')

      // 版本信息
      Column({ space: 8 }) {
        Text(`${$r('app.string.version_label')} ${this.appVersion}`)
          .fontSize(18)
          .fontColor('#666666')

        Text(`${$r('app.string.build_label')} ${this.buildNumber}`)
          .fontSize(14)
          .fontColor('#999999')

        Text(`TDLib ${this.tdlibVersion}`)
          .fontSize(14)
          .fontColor('#999999')
      }
      .margin({ top: 8 })

      // 复制版本信息按钮
      Button($r('app.string.copy_version_info'))
        .fontSize(14)
        .fontColor('#007DFF')
        .backgroundColor('#E3F2FD')
        .borderRadius(20)
        .padding({ left: 20, right: 20, top: 8, bottom: 8 })
        .margin({ top: 8 })
        .onClick(() => {
          this.copyVersionInfo();
        })
    }
    .width('100%')
    .padding({ top: 48, bottom: 32 })
    .backgroundColor('#FFFFFF')
    .borderRadius({ bottomLeft: 0, bottomRight: 0, topLeft: 12, topRight: 12 })
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 构建功能特性部分
   */
  @Builder
  private buildFeaturesSection() {
    Column({ space: 0 }) {
      Text($r('app.string.main_features'))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .width('100%')
        .padding({ left: 16, right: 16, top: 24, bottom: 16 })

      // 功能列表
      Column({ space: 0 }) {
        this.buildFeatureItem(
          $r('app.string.feature_chat'),
          $r('app.string.feature_chat_desc')
        )
        Divider().color('#F0F0F0').strokeWidth(0.5).margin({ left: 16, right: 16 })
        this.buildFeatureItem(
          $r('app.string.feature_groups'),
          $r('app.string.feature_groups_desc')
        )
        Divider().color('#F0F0F0').strokeWidth(0.5).margin({ left: 16, right: 16 })
        this.buildFeatureItem(
          $r('app.string.feature_channels'),
          $r('app.string.feature_channels_desc')
        )
        Divider().color('#F0F0F0').strokeWidth(0.5).margin({ left: 16, right: 16 })
        this.buildFeatureItem(
          $r('app.string.feature_files'),
          $r('app.string.feature_files_desc')
        )
        Divider().color('#F0F0F0').strokeWidth(0.5).margin({ left: 16, right: 16 })
        this.buildFeatureItem(
          $r('app.string.feature_privacy'),
          $r('app.string.feature_privacy_desc')
        )
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 24 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 16 })
  }

  /**
   * 构建功能项
   */
  @Builder
  private buildFeatureItem(title: Resource, description: Resource) {
    Row() {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(15)
          .fontColor('#333333')

        Text(description)
          .fontSize(13)
          .fontColor('#999999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 0, right: 16, top: 12, bottom: 12 })
  }

  /**
   * 构建链接和资源部分
   */
  @Builder
  private buildLinksSection() {
    Column({ space: 0 }) {
      Text($r('app.string.links_resources'))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .width('100%')
        .padding({ left: 16, right: 16, top: 24, bottom: 16 })

      // 链接列表
      Column({ space: 0 }) {
        this.buildLinkItem($r('app.string.privacy_policy'), () => {
          this.openPrivacyPolicy();
        })
        Divider().color('#F0F0F0').strokeWidth(0.5).margin({ left: 16, right: 16 })
        this.buildLinkItem($r('app.string.terms_of_service'), () => {
          this.openTermsOfService();
        })
        Divider().color('#F0F0F0').strokeWidth(0.5).margin({ left: 16, right: 16 })
        this.buildLinkItem($r('app.string.open_source'), () => {
          this.openSourceCode();
        })
        Divider().color('#F0F0F0').strokeWidth(0.5).margin({ left: 16, right: 16 })
        this.buildLinkItem($r('app.string.check_update'), () => {
          this.checkUpdate();
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 24 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 16 })
  }

  /**
   * 构建链接项
   */
  @Builder
  private buildLinkItem(title: Resource, onClick: () => void) {
    Row() {
      Text(title)
        .fontSize(15)
        .fontColor('#333333')
        .layoutWeight(1)

      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(20)
        .height(20)
        .fillColor('#CCCCCC')
    }
    .width('100%')
    .height(48)
    .padding({ left: 0, right: 16 })
    .onClick(onClick)
  }

  /**
   * 构建其他信息部分
   */
  @Builder
  private buildOtherSection() {
    Column({ space: 16 }) {
      // 版权信息
      Text('Copyright © 2026 HMTG Project')
        .fontSize(12)
        .fontColor('#999999')

      // 基于信息
      Text($r('app.string.based_on_telegram'))
        .fontSize(12)
        .fontColor('#CCCCCC')

      // 鸣谢
      Text($r('app.string.thanks_telegram'))
        .fontSize(12)
        .fontColor('#CCCCCC')

      // 开源许可
      Text($r('app.string.apache_license'))
        .fontSize(12)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .padding({ top: 32, bottom: 32 })
    .alignItems(HorizontalAlign.Center)

    // 底部 Logo - using placeholder circle
    Circle()
      .width(40)
      .height(40)
      .fill('#24A1C2')
      .opacity(0.3)
      .margin({ top: 16 })
  }
}
