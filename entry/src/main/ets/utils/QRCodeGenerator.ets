/**
 * QRCodeGenerator
 * 二维码生成工具类
 * 使用 @ohos/zxing 库生成二维码
 */

import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'QRCodeGenerator';
const DOMAIN = 0x0001;

export class QRCodeGenerator {
  private static readonly DEFAULT_SIZE = 300;

  /**
   * 生成二维码图片
   * @param content 二维码内容
   * @param size 二维码尺寸（像素），默认 300
   * @returns PixelMap 对象，失败返回 null
   */
  public static async generateQRCode(
    content: string,
    size: number = QRCodeGenerator.DEFAULT_SIZE
  ): Promise<image.PixelMap | null> {
    hilog.debug(DOMAIN, TAG, `[generateQRCode] 开始生成二维码, content.length=${content.length}, size=${size}`);
    
    if (!content || content.length === 0) {
      hilog.error(DOMAIN, TAG, '二维码内容不能为空');
      return null;
    }

    try {
      // 导入 zxing 库
      const zxing = await import('@ohos/zxing');
      
      if (!zxing || !zxing.QRCodeWriter) {
        hilog.error(DOMAIN, TAG, '[zxing] zxing 库导入失败或缺少必要的 API');
        return null;
      }
      
      const QRCodeWriter = zxing.QRCodeWriter;
      const BarcodeFormat = zxing.BarcodeFormat;

      hilog.debug(DOMAIN, TAG, `[zxing] 生成二维码: content="${content.substring(0, 30)}..."`);

      // 创建二维码写入器
      const writer = new QRCodeWriter();

      // 设置编码提示（必需参数）
      const hints = new Map<number, Object>();

      // 生成二维码矩阵
      const bitMatrix = writer.encode(content, BarcodeFormat.QR_CODE, size, size, hints);

      // 获取矩阵大小
      const matrixWidth = bitMatrix.getWidth();
      const matrixHeight = bitMatrix.getHeight();
      const actualSize = Math.min(matrixWidth, matrixHeight);
      
      hilog.debug(DOMAIN, TAG, `[zxing] 矩阵大小: ${matrixWidth}x${matrixHeight}`);

      // 创建像素数据缓冲区
      const bufferSize = actualSize * actualSize * 4;
      const buffer = new ArrayBuffer(bufferSize);
      const data = new Uint8Array(buffer);

      // 填充像素数据
      for (let y = 0; y < actualSize; y++) {
        for (let x = 0; x < actualSize; x++) {
          const index = (y * actualSize + x) * 4;
          const isBlack = bitMatrix.get(x, y);

          // 设置 RGBA 值
          if (isBlack) {
            data[index] = 0;     // R
            data[index + 1] = 0; // G
            data[index + 2] = 0; // B
            data[index + 3] = 255; // A
          } else {
            data[index] = 255;   // R
            data[index + 1] = 255; // G
            data[index + 2] = 255; // B
            data[index + 3] = 255; // A
          }
        }
      }

      // 创建 PixelMap
      const opts: image.InitializationOptions = {
        size: { width: actualSize, height: actualSize },
        pixelFormat: image.PixelMapFormat.RGBA_8888,
        editable: true
      };

      const pixelMap = await image.createPixelMap(buffer, opts);
      
      hilog.info(DOMAIN, TAG, '[zxing] 二维码生成成功');
      return pixelMap;
      
    } catch (error) {
      hilog.error(DOMAIN, TAG, `[zxing] 生成二维码失败: ${JSON.stringify(error)}`);
      return null;
    }
  }
}