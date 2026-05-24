/**
 * QRCodeGenerator
 * 二维码生成工具类
 *
 * 支持两种生成方式：
 * 1. 优先使用 HarmonyOS 官方 ScanKit API (@kit.ScanKit)
 * 2. 降级使用 @ohos/zxing 三方库
 */

import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * QR 码纠错级别
 */
export enum QRErrorCorrectionLevel {
  L = 0, // 7% 纠错率
  M = 1, // 15% 纠错率
  Q = 2, // 25% 纠错率
  H = 3 // 30% 纠错率
}

const TAG = 'QRCodeGenerator';
const DOMAIN = 0x0001;

/**
 * QRCodeGenerator 类
 * 支持双模式生成二维码（ScanKit 优先，zxing 降级）
 */

/**
 * BitMatrix 接口（来自 zxing 库）
 */
interface BitMatrix {
  get(x: number, y: number): boolean;
}

/**
 * ScanKit CreateOptions 接口
 */
interface ScanKitCreateOptions {
  scanType: number;
  height: number;
  width: number;
}

export class QRCodeGenerator {
  private static readonly DEFAULT_SIZE = 300;
  private static useScanKit: boolean = true;

  /**
   * 检测 ScanKit 是否可用
   */
  private static async checkScanKitAvailable(): Promise<boolean> {
    try {
      // 尝试动态导入 ScanKit
      const scanKit = await import('@kit.ScanKit');
      return scanKit !== undefined && scanKit !== null;
    } catch (error) {
      hilog.warn(DOMAIN, TAG, 'ScanKit 不可用，将使用 zxing 降级方案');
      return false;
    }
  }

  /**
   * 使用 ScanKit 生成二维码
   */
  private static async generateWithScanKit(
    content: string,
    size: number
  ): Promise<image.PixelMap | null> {
    try {
      // 动态导入 ScanKit
      const scanKit = await import('@kit.ScanKit');
      
      // 构建 CreateOptions
      const options: ScanKitCreateOptions = {
        scanType: 0, // QR_CODE 类型
        height: size,
        width: size
      };

      hilog.debug(DOMAIN, TAG, `[ScanKit] 生成二维码: content="${content}", size=${size}`);

      // 调用 ScanKit 生成二维码
      const pixelMap = await scanKit.generateBarcode.createBarcode(content, options);

      if (pixelMap) {
        hilog.info(DOMAIN, TAG, '[ScanKit] 二维码生成成功');
        return pixelMap;
      } else {
        hilog.error(DOMAIN, TAG, '[ScanKit] 二维码生成失败：返回的 PixelMap 为空');
        return null;
      }
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(DOMAIN, TAG, `[ScanKit] 生成二维码失败: code=${err.code}, message=${err.message}`);
      return null;
    }
  }

  /**
   * 使用 zxing 生成二维码
   */
  private static async generateWithZxing(
    content: string,
    size: number,
    errorCorrectionLevel: QRErrorCorrectionLevel
  ): Promise<image.PixelMap | null> {
    try {
      // 导入 zxing 库
      const zxing = await import('@ohos/zxing');
      const QRCodeWriter = zxing.QRCodeWriter;
      const BarcodeFormat = zxing.BarcodeFormat;
      const EncodeHintType = zxing.EncodeHintType;

      hilog.debug(DOMAIN, TAG, `[zxing] 生成二维码: content="${content}", size=${size}, ec=${errorCorrectionLevel}`);

      // 创建二维码写入器
      const writer = new QRCodeWriter();

      // 设置编码提示
      const hints: Map<number, number | QRErrorCorrectionLevel> = new Map();
      hints.set(EncodeHintType.MARGIN, 1); // 边距
      hints.set(EncodeHintType.ERROR_CORRECTION, errorCorrectionLevel);

      // 生成二维码矩阵
      const bitMatrix = writer.encode(content, BarcodeFormat.QR_CODE, size, size, hints);

      // 转换为 PixelMap
      const pixelMap = await QRCodeGenerator.bitMatrixToPixelMap(bitMatrix as BitMatrix, size);

      if (pixelMap) {
        hilog.info(DOMAIN, TAG, '[zxing] 二维码生成成功');
        return pixelMap;
      } else {
        hilog.error(DOMAIN, TAG, '[zxing] 二维码生成失败：PixelMap 转换失败');
        return null;
      }
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(DOMAIN, TAG, `[zxing] 生成二维码失败: code=${err.code}, message=${err.message}`);
      return null;
    }
  }

  /**
   * 将 BitMatrix 转换为 PixelMap
   */
  private static async bitMatrixToPixelMap(bitMatrix: BitMatrix, size: number): Promise<image.PixelMap | null> {
    try {
      // 创建像素数据缓冲区
      const bufferSize = size * size * 4;
      const buffer = new ArrayBuffer(bufferSize);
      const data = new Uint8Array(buffer);

      // 填充像素数据
      for (let y = 0; y < size; y++) {
        for (let x = 0; x < size; x++) {
          const index = (y * size + x) * 4;
          const isBlack = bitMatrix.get(x, y);

          // 设置 RGBA 值
          if (isBlack) {
            data[index] = 0; // R
            data[index + 1] = 0; // G
            data[index + 2] = 0; // B
            data[index + 3] = 255; // A
          } else {
            data[index] = 255; // R
            data[index + 1] = 255; // G
            data[index + 2] = 255; // B
            data[index + 3] = 255; // A
          }
        }
      }

      // 创建 PixelMap
      const opts: image.InitializationOptions = {
        size: { width: size, height: size },
        pixelFormat: image.PixelMapFormat.RGBA_8888,
        editable: true
      };

      const pixelMap = await image.createPixelMap(buffer, opts);

      return pixelMap;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `BitMatrix 转换失败: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * 生成二维码图片
   * 优先使用 ScanKit，失败时降级到 zxing
   * @param content 二维码内容
   * @param size 二维码尺寸（像素），默认 300
   * @param errorCorrectionLevel 纠错级别，默认为 M (15%)
   * @returns PixelMap 对象，失败返回 null
   */
  public static async generateQRCode(
    content: string,
    size: number = QRCodeGenerator.DEFAULT_SIZE,
    errorCorrectionLevel: QRErrorCorrectionLevel = QRErrorCorrectionLevel.M
  ): Promise<image.PixelMap | null> {
    if (!content || content.length === 0) {
      hilog.error(DOMAIN, TAG, '二维码内容不能为空');
      return null;
    }

    // 首次调用时检测 ScanKit 可用性
    if (QRCodeGenerator.useScanKit) {
      const scanKitAvailable = await QRCodeGenerator.checkScanKitAvailable();
      QRCodeGenerator.useScanKit = scanKitAvailable;
    }

    // 优先使用 ScanKit
    if (QRCodeGenerator.useScanKit) {
      const pixelMap = await QRCodeGenerator.generateWithScanKit(content, size);
      if (pixelMap) {
        return pixelMap;
      }
      // ScanKit 失败，降级到 zxing
      hilog.warn(DOMAIN, TAG, 'ScanKit 生成失败，降级到 zxing');
    }

    // 使用 zxing 降级方案
    return QRCodeGenerator.generateWithZxing(content, size, errorCorrectionLevel);
  }

  /**
   * 生成二维码字符串（用于调试，显示文本表示）
   * 注意：此方法仅用于调试，实际应用应使用 generateQRCode() 获取 PixelMap
   * @param content 二维码内容
   * @returns 二维码字符串表示
   */
  public static async generateQRCodeString(content: string): Promise<string> {
    const pixelMap = await QRCodeGenerator.generateQRCode(content, 200);
    if (pixelMap) {
      return `[QR Code for: ${content}, size=200x200]`;
    }
    return '[QR Code Generation Failed]';
  }
}
