// storage_cache/src/main/ets/com/cache/image/ImageKnifeManager.ets
import { ImageKnifeGlobal, RequestOption, ImageKnifeData } from '@ohos/imageknife';
import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { CacheLogger } from '../utils/Logger';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'ImageKnifeManager';

export class ImageKnifeManager {
  private static instance: ImageKnifeManager;
  private context: common.UIAbilityContext | null = null;
  private imageKnifeGlobal: ImageKnifeGlobal | null = null;
  private diskCacheDir: string = ''; // 用于存储磁盘缓存目录

  private constructor(context: common.UIAbilityContext) {
    this.context = context;
    this.initImageKnife();
  }

  public static getInstance(context?: common.UIAbilityContext): ImageKnifeManager {
    if (!ImageKnifeManager.instance && context) {
      ImageKnifeManager.instance = new ImageKnifeManager(context);
    }
    return ImageKnifeManager.instance;
  }

  private initImageKnife(): void {
    if (!this.context) {
      return;
    }
    try {
      this.imageKnifeGlobal = ImageKnifeGlobal.getInstance();
      if (!this.imageKnifeGlobal.getImageKnife()) {
        CacheLogger.warn(TAG, 'ImageKnife instance not found, initializing...');
      }
      // 获取磁盘缓存目录，注意：这里的路径需要与 ImageKnife 实际使用的缓存路径保持一致
      if (this.context) {
        // 推荐从 ImageKnife 的配置中获取，如果没有则使用默认缓存目录
        this.diskCacheDir = `${this.context.cacheDir}/image_knife_cache`;
      }
      CacheLogger.info(TAG, `ImageKnife manager initialized. Disk cache dir: ${this.diskCacheDir}`);
    } catch (err) {
      CacheLogger.error(TAG, `ImageKnife initialization failed: ${JSON.stringify(err)}`);
    }
  }

  async loadImage(url: string): Promise<image.PixelMap | null> {
    if (!this.imageKnifeGlobal) {
      CacheLogger.error(TAG, 'ImageKnifeGlobal is not initialized.');
      return null;
    }
    CacheLogger.debug(TAG, `Loading image: ${url}`);

    return new Promise((resolve) => {
      const request = new RequestOption();
      // 配置请求，使用链式调用
      request.load(url)
        .addListener({
          callback: (err: BusinessError | string | null, data: ImageKnifeData) => {
            if (err) {
              CacheLogger.error(TAG, `Image load failed: ${url}, error: ${JSON.stringify(err)}`);
              resolve(null);
              return false;
            }
            if (data && data.isPixelMap() && data.drawPixelMap) {
              CacheLogger.debug(TAG, `Image load success: ${url}`);
              resolve(data.drawPixelMap.imagePixelMap);
              return false;
            }
            CacheLogger.warn(TAG, `Image load data invalid: ${url}`);
            resolve(null);
            return false;
          }
        });
      // 发起请求
      try {
        const imageKnife = this.imageKnifeGlobal?.getImageKnife();
        if (imageKnife) {
          imageKnife.call(request);
        } else {
          CacheLogger.error(TAG, 'ImageKnife instance is null, cannot load image.');
          resolve(null);
        }
      } catch (err) {
        CacheLogger.error(TAG, `ImageKnife call failed: ${url}, ${JSON.stringify(err)}`);
        resolve(null);
      }
    });
  }

  async preloadImage(url: string): Promise<void> {
    if (!this.imageKnifeGlobal) {
      CacheLogger.error(TAG, 'ImageKnifeGlobal is not initialized.');
      return;
    }
    CacheLogger.debug(TAG, `Preloading image: ${url}`);
    this.loadImage(url).catch((err: Error) => {
      CacheLogger.error(TAG, `Preload failed for ${url}: ${err}`);
    });
  }

  isImageCached(url: string): boolean {
    CacheLogger.debug(TAG, `Check cache for: ${url} (not implemented directly, returning false)`);
    return false;
  }

  clearMemoryCache(): void {
    if (this.imageKnifeGlobal) {
      const imageKnife = this.imageKnifeGlobal.getImageKnife();
      if (imageKnife && typeof imageKnife.removeMemoryCache === 'function') {
        imageKnife.removeMemoryCache('all');
        CacheLogger.info(TAG, 'Memory cache cleared.');
      } else {
        CacheLogger.warn(TAG, 'removeMemoryCache method not found on ImageKnife instance.');
      }
    } else {
      CacheLogger.warn(TAG, 'ImageKnifeGlobal not initialized, cannot clear memory cache.');
    }
  }

  // ✅ 修正点：手动实现磁盘缓存清除功能
  async clearDiskCache(): Promise<void> {
    if (!this.diskCacheDir) {
      CacheLogger.warn(TAG, 'Disk cache directory not set, cannot clear disk cache.');
      return;
    }

    CacheLogger.info(TAG, `Clearing disk cache directory: ${this.diskCacheDir}`);
    try {
      if (fs.accessSync(this.diskCacheDir)) {
        // 删除整个目录并重建
        fs.rmdirSync(this.diskCacheDir);
        fs.mkdirSync(this.diskCacheDir);
        CacheLogger.info(TAG, 'Disk cache cleared successfully.');
      } else {
        CacheLogger.info(TAG, 'Disk cache directory does not exist, nothing to clear.');
      }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : String(err);
      CacheLogger.error(TAG, `Failed to clear disk cache: ${errorMessage}`);
      throw new Error(`Failed to clear disk cache: ${errorMessage}`);
    }
  }

  // ==================== 缓存信息查询 API ====================

  /**
   * 获取磁盘缓存目录路径
   */
  getDiskCacheDir(): string {
    return this.diskCacheDir;
  }

  /**
   * 获取磁盘缓存大小（字节）
   */
  async getDiskCacheSize(): Promise<number> {
    return this.calculateDirSize(this.diskCacheDir);
  }

  /**
   * 计算目录大小
   */
  private calculateDirSize(dirPath: string): number {
    try {
      if (!fs.accessSync(dirPath)) {
        return 0;
      }

      const files = fs.listFileSync(dirPath);
      let totalSize = 0;

      for (const fileName of files) {
        const filePath = `${dirPath}/${fileName}`;
        try {
          const stat = fs.statSync(filePath);
          if (stat.isDirectory()) {
            totalSize += this.calculateDirSize(filePath);
          } else {
            totalSize += stat.size;
          }
        } catch {
          // 忽略单个文件错误
        }
      }

      return totalSize;
    } catch (error) {
      CacheLogger.warn(TAG, `Failed to calculate dir size: ${dirPath}, ${error}`);
      return 0;
    }
  }
}