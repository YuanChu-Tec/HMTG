import { BusinessError } from '../error/BusinessError';
import { http } from '@kit.NetworkKit';
import { FileHelper } from './FileHelper';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { fileIo } from '@kit.CoreFileKit';

const TAG = 'FileDownloader';
const DOMAIN = 0x0001;

/**
 * 下载进度
 */
export interface DownloadProgress {
  bytesReceived: number;
  bytesTotal: number;
  percentage: number;
  speed: number; // bytes per second
}

/**
 * 下载配置
 */
export interface DownloadConfig {
  url: string;
  savePath: string;
  timeout?: number;
  onProgress?: (progress: DownloadProgress) => void;
  onCompleted?: (filePath: string) => void;
  onError?: (error: Error) => void;
}

/**
 * 文件下载器
 */
export class FileDownloader {
  private static downloads: Map<string, http.HttpRequest> = new Map();

  /**
   * 下载文件
   */
  static async download(config: DownloadConfig): Promise<string> {
    const httpClient = http.createHttp();
    FileDownloader.downloads.set(config.url, httpClient);

    const startTime = Date.now();
    let lastUpdateTime = startTime;
    let lastBytesReceived = 0;

    try {
      hilog.info(DOMAIN, TAG, `Starting download: ${config.url}`);

      const response = await httpClient.request(config.url, {
        method: http.RequestMethod.GET,
        header: new Object(),
        connectTimeout: config.timeout || 30000,
        readTimeout: config.timeout || 30000,
        expectDataType: http.HttpDataType.ARRAY_BUFFER
      });

      if (response.responseCode !== 200) {
        throw new BusinessError(0, `Download failed with status ${response.responseCode}`, '下载失败');
      }

      // 保存文件
      const savePath = config.savePath;
      const dirPath = savePath.substring(0, savePath.lastIndexOf('/'));

      if (!(await FileHelper.exists(dirPath))) {
        await FileHelper.createDirectories(dirPath);
      }

      // 直接写入二进制数据到文件
      const file = await fileIo.open(savePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
      const result = response.result as ArrayBuffer;
      let arrayBuffer: ArrayBuffer;
      if (result instanceof ArrayBuffer) {
        arrayBuffer = result;
      } else {
        // 如果不是 ArrayBuffer，尝试转换
        arrayBuffer = new ArrayBuffer(0);
      }
      await fileIo.write(file.fd, arrayBuffer);
      await fileIo.close(file.fd);

      const duration = (Date.now() - startTime) / 1000;
      const speed = ArrayBuffer.isView(arrayBuffer) ? arrayBuffer.byteLength : (arrayBuffer as ArrayBuffer).byteLength / duration;

      hilog.info(DOMAIN, TAG, `Download completed: ${config.url}, size: ${result.byteLength} bytes, duration: ${duration.toFixed(2)}s, speed: ${speed.toFixed(2)} bytes/s`);

      // 触发完成回调
      config.onCompleted?.(savePath);

      return savePath;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Download failed: ${config.url}, error: ${error}`);
      config.onError?.(error as Error);
      throw new Error(String(error));
    } finally {
      httpClient.destroy();
      FileDownloader.downloads.delete(config.url);
    }
  }

  /**
   * 取消下载
   */
  static cancel(url: string): void {
    const httpClient = FileDownloader.downloads.get(url);
    if (httpClient) {
      httpClient.destroy();
      FileDownloader.downloads.delete(url);
      hilog.info(DOMAIN, TAG, `Download cancelled: ${url}`);
    }
  }

  /**
   * 批量下载
   */
  static async batchDownload(configs: DownloadConfig[]): Promise<Map<string, string>> {
    const results = new Map<string, string>();
    const promises: Promise<void>[] = [];

    for (const config of configs) {
      const promise = async () => {
        try {
          const filePath = await FileDownloader.download(config);
          results.set(config.url, filePath);
        } catch (error) {
          hilog.error(DOMAIN, TAG, `Batch download failed: ${config.url}, error: ${error}`);
        }
      };
      promises.push(promise());
    }

    await Promise.all(promises);
    return results;
  }

  /**
   * 检查下载是否在进行中
   */
  static isDownloading(url: string): boolean {
    return FileDownloader.downloads.has(url);
  }

  /**
   * 取消所有下载
   */
  static cancelAll(): void {
    const iterator = FileDownloader.downloads.keys();
    let key = iterator.next();
    while (!key.done) {
      const url = key.value;
      const httpClient = FileDownloader.downloads.get(url);
      if (httpClient) {
        httpClient.destroy();
        hilog.info(DOMAIN, TAG, `Download cancelled: ${url}`);
      }
      key = iterator.next();
    }
    FileDownloader.downloads.clear();
  }
}
