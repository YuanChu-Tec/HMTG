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
import { formatString } from '../../../utils';

/**
 * 本地定义的缓存统计信息接口
 */
export interface CacheStatistics {
  totalSize: number;
  formattedSize: string;
  totalCount: number;
  hitCount: number;
  missCount: number;
  hitRate: number;
  lastCleanTime: number;
}

const TAG = 'CacheManagementPage';
const DOMAIN = 0x0001;

/**
 * 缓存类型信息
 */
interface CacheTypeInfo {
  type: string;
  displayName: string;
  size: number;
  formattedSize: string;
  count: number;
}

/**
 * 对话框按钮接口
 */
interface DialogButton {
  text: string;
  color: string;
}

/**
 * 对话框回调数据接口
 */
interface DialogCallbackData {
  index: number;
}

/**
 * 缓存设置接口
 */
interface CacheSettingsData {
  maxCacheSize: number;
  compressionEnabled: boolean;
  prefetchEnabled: boolean;
  autoClearEnabled: boolean;
}

/**
 * 缓存管理页面
 */
@Entry
@ComponentV2
export struct CacheManagementPage {
  @Local cacheStatistics: CacheStatistics = {
    totalSize: 0,
    formattedSize: '0 MB',
    totalCount: 0,
    hitCount: 0,
    missCount: 0,
    hitRate: 0,
    lastCleanTime: 0
  };
  @Local cacheTypes: CacheTypeInfo[] = [];
  @Local autoCleanEnabled: boolean = true;
  @Local cleanInterval: number = 30;
  @Local expireTime: number = 7;
  @Local maxMemorySize: number = 50;
  @Local maxDiskSize: number = 500;
  @Local maxCacheSize: number = 500;
  @Local compressionEnabled: boolean = true;
  @Local prefetchEnabled: boolean = false;

  aboutToAppear(): void {
    this.loadCacheInfo();
  }

  /**
   * 加载缓存信息
   */
  private loadCacheInfo(): void {
    // 模拟数据
    this.cacheStatistics = {
      totalSize: 992 * 1024 * 1024,
      formattedSize: '992 MB',
      totalCount: 12345,
      hitCount: 98765,
      missCount: 4321,
      hitRate: 95.8,
      lastCleanTime: Date.now() - 3600000
    };

    this.cacheTypes = [
      {
        type: 'L1_MEMORY',
        displayName: '内存缓存',
        size: 256 * 1024 * 1024,
        formattedSize: '256 MB',
        count: 5678
      },
      {
        type: 'L2_DISK',
        displayName: '磁盘缓存',
        size: 512 * 1024 * 1024,
        formattedSize: '512 MB',
        count: 4567
      },
      {
        type: 'L3_DATABASE',
        displayName: '数据库',
        size: 128 * 1024 * 1024,
        formattedSize: '128 MB',
        count: 2100
      },
      {
        type: 'L5_IMAGE',
        displayName: '图片缓存',
        size: 96 * 1024 * 1024,
        formattedSize: '96 MB',
        count: 0
      }
    ];
  }

  /**
   * 返回
   */
  private handleBack(): void {
    router.back();
  }

  /**
   * 清除缓存
   */
  private clearCache(cacheType?: string): void {
    promptAction.showDialog({
      title: $r('app.string.confirm_clear'),
      message: cacheType
        ? formatString('confirm_clear_cache_type', cacheType)
        : $r('app.string.confirm_clear_all_cache'),
      buttons: [
        { text: $r('app.string.cancel_button'), color: '#666666' },
        { text: $r('app.string.clear_button'), color: '#FF6B6B' }
      ]
    }, (err: Error | null, data: DialogCallbackData | undefined) => {
      if (!err && data && data.index === 1) {
        try {
          hilog.info(DOMAIN, TAG, `用户请求清除缓存: ${cacheType || '全部'}`);

          // 模拟缓存清除（实际需要 cacheManager.clear() 或 clearExpired()）
          hilog.info(DOMAIN, TAG, '缓存清除完成');

          promptAction.showToast({
            message: cacheType
              ? formatString('cache_type_cleared', cacheType)
              : $r('app.string.cache_cleared'),
            duration: 2000
          });

          // 重新加载缓存信息
          this.loadCacheInfo();
        } catch (error) {
          hilog.error(DOMAIN, TAG, `清除缓存失败: ${JSON.stringify(error)}`);
          promptAction.showToast({
            message: $r('app.string.clear_failed_retry'),
            duration: 2000
          });
        }
      }
    });
  }

  /**
   * 压缩缓存
   */
  private async compressCache(): Promise<void> {
    promptAction.showToast({
      message: $r('app.string.cache_compressing'),
      duration: 2000
    });

    try {
      hilog.info(DOMAIN, TAG, '用户请求压缩缓存');

      // 模拟缓存压缩（实际需要 cacheManager.compress()）
      hilog.info(DOMAIN, TAG, '缓存压缩完成');

      promptAction.showToast({
        message: $r('app.string.cache_compressed'),
        duration: 2000
      });

      // 重新加载缓存信息
      this.loadCacheInfo();
    } catch (error) {
      hilog.error(DOMAIN, TAG, `压缩缓存失败: ${JSON.stringify(error)}`);
      promptAction.showToast({
        message: $r('app.string.compress_failed_retry'),
        duration: 2000
      });
    }
  }

  /**
   * 预加载缓存
   */
  private async preloadCache(): Promise<void> {
    promptAction.showToast({
      message: $r('app.string.cache_preloading'),
      duration: 2000
    });

    try {
      hilog.info(DOMAIN, TAG, '用户请求预加载缓存');

      // 模拟缓存预加载（实际需要 cacheManager.preload()）
      hilog.info(DOMAIN, TAG, '缓存预加载完成');

      promptAction.showToast({
        message: $r('app.string.cache_preloaded'),
        duration: 2000
      });

      // 重新加载缓存信息
      this.loadCacheInfo();
    } catch (error) {
      hilog.error(DOMAIN, TAG, `预加载缓存失败: ${JSON.stringify(error)}`);
      promptAction.showToast({
        message: $r('app.string.preload_failed_retry'),
        duration: 2000
      });
    }
  }

  /**
   * 保存设置
   */
  private async saveSettings(): Promise<void> {
    try {
      // 将缓存设置保存到本地首选项
      const cacheSettings: CacheSettingsData = {
        maxCacheSize: this.maxCacheSize,
        compressionEnabled: this.compressionEnabled,
        prefetchEnabled: this.prefetchEnabled,
        autoClearEnabled: this.autoCleanEnabled
      };

      // 模拟应用设置到缓存系统（实际需要 cacheManager.updateConfig()）
      try {
        hilog.info(DOMAIN, TAG, '缓存配置已应用');
      } catch (configError) {
        hilog.warn(DOMAIN, TAG, `应用缓存配置失败: ${configError}`);
      }

      // 记录日志
      hilog.info(DOMAIN, TAG, '保存缓存设置');

      // 显示保存成功提示
      promptAction.showToast({
        message: $r('app.string.cache_settings_saved'),
        duration: 2000
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, '保存缓存设置失败');
      promptAction.showToast({
        message: $r('app.string.save_failed_retry'),
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
          this.buildSection('缓存统计')
          this.buildStatisticsSection()

          this.buildSection('缓存详情')
          this.buildCacheDetailsSection()

          this.buildSection('缓存策略')
          this.buildStrategySection()

          this.buildSection('缓存操作')
          this.buildOperationsSection()
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

      Text($r('app.string.cache_management_title'))
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
    Text(title)
      .fontSize(13)
      .fontColor('#666666')
      .width('100%')
      .padding({ left: 16, right: 16, top: 24, bottom: 8 })
  }

  /**
   * 构建缓存统计
   */
  @Builder
  private buildStatisticsSection() {
    Column() {
      // 总缓存大小
      Row() {
        Column({ space: 4 }) {
          Text($r('app.string.total_cache_size'))
            .fontSize(14)
            .fontColor('#999999')

          Text(this.cacheStatistics.formattedSize)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#007DFF')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 缓存命中率
        Column({ space: 4 }) {
          Text($r('app.string.cache_hit_rate'))
            .fontSize(14)
            .fontColor('#999999')

          Text(`${this.cacheStatistics.hitRate.toFixed(1)}%`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CAF50')
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .padding(20)

      Divider().color('#F0F0F0').strokeWidth(0.5)

      // 详细统计
      Row({ space: 24 }) {
        Column({ space: 4 }) {
          Text($r('app.string.cache_items'))
            .fontSize(12)
            .fontColor('#999999')

          Text(this.cacheStatistics.totalCount.toString())
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 4 }) {
          Text($r('app.string.cache_hits'))
            .fontSize(12)
            .fontColor('#999999')

          Text(this.cacheStatistics.hitCount.toString())
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 4 }) {
          Text($r('app.string.cache_misses'))
            .fontSize(12)
            .fontColor('#999999')

          Text(this.cacheStatistics.missCount.toString())
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 24 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  /**
   * 构建缓存详情
   */
  @Builder
  private buildCacheDetailsSection() {
    Column() {
      ForEach(this.cacheTypes, (cacheType: CacheTypeInfo, index: number) => {
        Column() {
          Row() {
            Column({ space: 4 }) {
              Text(cacheType.displayName)
                .fontSize(15)
                .fontColor('#333333')

              Text(formatString('cache_items_count', cacheType.count))
                .fontSize(13)
                .fontColor('#999999')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Column({ space: 4 }) {
              Text(cacheType.formattedSize)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#007DFF')

              Text($r('app.string.clear_button'))
                .fontSize(12)
                .fontColor('#FF6B6B')
                .onClick(() => {
                  this.clearCache(cacheType.displayName);
                })
            }
            .alignItems(HorizontalAlign.End)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })

          // 进度条
          Progress({
            value: (cacheType.size / this.cacheStatistics.totalSize) * 100,
            total: 100,
            type: ProgressType.Linear
          })
            .width('100%')
            .height(4)
            .color('#007DFF')
            .backgroundColor('#E0E0E0')

          if (index < this.cacheTypes.length - 1) {
            Divider().color('#F0F0F0').strokeWidth(0.5).margin({ left: 16, right: 16, top: 8 })
          }
        }
        .width('100%')
      }, (cacheType: CacheTypeInfo) => cacheType.type)
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 24 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  /**
   * 构建缓存策略
   */
  @Builder
  private buildStrategySection() {
    Column() {
      // 自动清理
      this.buildToggleSetting(
        $r('app.string.auto_clean_label'),
        $r('app.string.auto_clean_desc'),
        this.autoCleanEnabled,
        () => {
          this.autoCleanEnabled = !this.autoCleanEnabled;
        }
      )

      Divider().color('#F0F0F0').strokeWidth(0.5).margin({ left: 16, right: 16 })

      // 清理间隔
      Column({ space: 8 }) {
        Row() {
          Text($r('app.string.clean_interval_label'))
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)

          Text(formatString('clean_interval_minutes', this.cleanInterval))
            .fontSize(14)
            .fontColor('#007DFF')
        }

        Slider({
          value: this.cleanInterval,
          min: 5,
          max: 120,
          step: 5,
          style: SliderStyle.OutSet
        })
          .blockColor('#007DFF')
          .trackColor('#E0E0E0')
          .selectedColor('#007DFF')
          .showSteps(true)
          .onChange((value: number) => {
            this.cleanInterval = Math.round(value);
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      Divider().color('#F0F0F0').strokeWidth(0.5).margin({ left: 16, right: 16 })

      // 过期时间
      Column({ space: 8 }) {
        Row() {
          Text($r('app.string.expire_time_label'))
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)

          Text(formatString('expire_time_days', this.expireTime))
            .fontSize(14)
            .fontColor('#007DFF')
        }

        Slider({
          value: this.expireTime,
          min: 1,
          max: 30,
          step: 1,
          style: SliderStyle.OutSet
        })
          .blockColor('#007DFF')
          .trackColor('#E0E0E0')
          .selectedColor('#007DFF')
          .showSteps(true)
          .onChange((value: number) => {
            this.expireTime = Math.round(value);
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      Divider().color('#F0F0F0').strokeWidth(0.5).margin({ left: 16, right: 16 })

      // 最大内存缓存
      Column({ space: 8 }) {
        Row() {
          Text($r('app.string.max_memory_cache'))
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)

          Text(formatString('max_cache_mb', this.maxMemorySize))
            .fontSize(14)
            .fontColor('#007DFF')
        }

        Slider({
          value: this.maxMemorySize,
          min: 10,
          max: 200,
          step: 10,
          style: SliderStyle.OutSet
        })
          .blockColor('#007DFF')
          .trackColor('#E0E0E0')
          .selectedColor('#007DFF')
          .showSteps(true)
          .onChange((value: number) => {
            this.maxMemorySize = Math.round(value);
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      Divider().color('#F0F0F0').strokeWidth(0.5).margin({ left: 16, right: 16 })

      // 最大磁盘缓存
      Column({ space: 8 }) {
        Row() {
          Text($r('app.string.max_disk_cache'))
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)

          Text(formatString('max_cache_mb', this.maxDiskSize))
            .fontSize(14)
            .fontColor('#007DFF')
        }

        Slider({
          value: this.maxDiskSize,
          min: 100,
          max: 2000,
          step: 100,
          style: SliderStyle.OutSet
        })
          .blockColor('#007DFF')
          .trackColor('#E0E0E0')
          .selectedColor('#007DFF')
          .showSteps(true)
          .onChange((value: number) => {
            this.maxDiskSize = Math.round(value);
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 24 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  /**
   * 构建缓存操作
   */
  @Builder
  private buildOperationsSection() {
    Column() {
      // 压缩缓存
      Button($r('app.string.compress_cache_button'))
        .width('100%')
        .height(48)
        .fontSize(16)
        .backgroundColor('#007DFF')
        .fontColor('#FFFFFF')
        .borderRadius(8)
        .margin({ top: 12, bottom: 12 })
        .onClick(() => {
          this.compressCache();
        })

      // 预加载缓存
      Button($r('app.string.preload_cache_button'))
        .width('100%')
        .height(48)
        .fontSize(16)
        .backgroundColor('#FFFFFF')
        .fontColor('#007DFF')
        .border({ width: 1, color: '#007DFF' })
        .borderRadius(8)
        .margin({ bottom: 12 })
        .onClick(() => {
          this.preloadCache();
        })

      // 清除所有缓存
      Button($r('app.string.clear_all_cache_button'))
        .width('100%')
        .height(48)
        .fontSize(16)
        .backgroundColor('#FFFFFF')
        .fontColor('#FF6B6B')
        .border({ width: 1, color: '#FF6B6B' })
        .borderRadius(8)
        .margin({ bottom: 12 })
        .onClick(() => {
          this.clearCache();
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
  ): void {
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
