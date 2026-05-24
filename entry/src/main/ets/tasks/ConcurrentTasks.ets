/**
 * TaskPool 并发任务函数库
 * 所有函数标记为 @Concurrent，在独立线程中执行
 * 
 * 包含:
 * 1. 图片处理任务
 * 2. JSON 解析任务
 * 3. 数据压缩任务
 * 4. 加密解密任务
 */
import { taskpool } from '@kit.ArkTS';
// import { image } from '@kit.MultimediaImage';
import { util } from '@kit.ArkTS';

/**
 * 图片压缩任务
 * @param imageData 原始图片数据
 * @param quality 压缩质量 (0-100)
 * @param maxSize 最大边长（像素），<=0 表示不缩放
 * @returns 压缩后的图片数据
 */
// @Concurrent
// export function compressImageTask(
//   imageData: ArrayBuffer,
//   quality: number,
//   maxSize: number = 0
// ): ArrayBuffer {
//   try {
//     // 创建图片源
//     const source = image.createImageSource(imageData);
//     
//     // 获取图片信息
//     const info = source.getImageInfo();
//     
//     // 计算目标尺寸
//     let targetWidth = info.width;
//     let targetHeight = info.height;
//     
//     if (maxSize > 0) {
//       const scale = Math.min(maxSize / info.width, maxSize / info.height);
//       if (scale < 1) {
//         targetWidth = Math.floor(info.width * scale);
//         targetHeight = Math.floor(info.height * scale);
//       }
//     }
//     
//     // 压缩图片
//     const packOption: image.PackOption = {
//       format: 'image/png',
//       quality: quality,
//       size: {
//         width: targetWidth,
//         height: targetHeight
//       }
//     };
//     
//     const compressedData = source.getPackedBytes(packOption);
//     
//     // 释放资源
//     source.close();
//     
//     return compressedData;
//   } catch (error) {
//     console.error('compressImageTask error:', JSON.stringify(error));
//     throw error;
//   }
// }

/**
 * 图片缩放任务
 * @param imageData 原始图片数据
 * @param targetWidth 目标宽度
 * @param targetHeight 目标高度
 * @returns 缩放后的图片数据
 */
// @Concurrent
// export function resizeImageTask(
//   imageData: ArrayBuffer,
//   targetWidth: number,
//   targetHeight: number
// ): ArrayBuffer {
//   try {
//     const source = image.createImageSource(imageData);
//     
//     const packOption: image.PackOption = {
//       format: 'image/png',
//       quality: 90,
//       size: {
//         width: targetWidth,
//         height: targetHeight
//       }
//     };
//     
//     const resizedData = source.getPackedBytes(packOption);
//     source.close();
//     
//     return resizedData;
//   } catch (error) {
//     console.error('resizeImageTask error:', JSON.stringify(error));
//     throw error;
//   }
// }

/**
 * 生成缩略图任务
 * @param imageData 原始图片数据
 * @param thumbnailSize 缩略图边长（默认 150px）
 * @returns 缩略图数据
 */
// @Concurrent
// export function generateThumbnailTask(
//   imageData: ArrayBuffer,
//   thumbnailSize: number = 150
// ): ArrayBuffer {
//   try {
//     const source = image.createImageSource(imageData);
//     const info = source.getImageInfo();
//     
//     // 保持宽高比裁剪
//     const minSize = Math.min(info.width, info.height);
//     const cropX = Math.floor((info.width - minSize) / 2);
//     const cropY = Math.floor((info.height - minSize) / 2);
//     
//     const packOption: image.PackOption = {
//       format: 'image/png',
//       quality: 80,
//       size: {
//         width: thumbnailSize,
//         height: thumbnailSize
//       },
//       rect: {
//         x: cropX,
//         y: cropY,
//         width: minSize,
//         height: minSize
//       }
//     };
//     
//     const thumbnailData = source.getPackedBytes(packOption);
//     source.close();
//     
//     return thumbnailData;
//   } catch (error) {
//     console.error('generateThumbnailTask error:', JSON.stringify(error));
//     throw error;
//   }
// }

/**
 * JSON 解析任务
 * @param jsonString JSON 字符串
 * @returns 解析后的对象
 */
@Concurrent
export function parseJSONTask(jsonString: string): object {
  try {
    const parsed: object = JSON.parse(jsonString);
    return parsed;
  } catch (error) {
    console.error('parseJSONTask error:', JSON.stringify(error));
    throw new Error(`ParseJSONTask failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

/**
 * JSON 序列化任务
 * @param obj 要序列化的对象
 * @returns JSON 字符串
 */
@Concurrent
export function stringifyJSONTask(obj: Record<string, Object>): string {
  try {
    return JSON.stringify(obj);
  } catch (error) {
    console.error('stringifyJSONTask error:', JSON.stringify(error));
    throw new Error(`StringifyJSONTask failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

/**
 * 大数据排序任务
 * @param arrayData 要排序的数组
 * @param compareFn 比较函数（序列化形式）
 * @returns 排序后的数组
 */
@Concurrent
export function sortArrayTask<T>(arrayData: T[], ascending: boolean = true): T[] {
  try {
    // 深拷贝避免修改原数据
    const arr: T[] = JSON.parse(JSON.stringify(arrayData)) as T[];
    
    // 简单排序（假设元素可比较）
    arr.sort((a: T, b: T): number => {
      if (ascending) {
        return a > b ? 1 : (a < b ? -1 : 0);
      } else {
        return a < b ? 1 : (a > b ? -1 : 0);
      }
    });
    
    return arr;
  } catch (error) {
    console.error('sortArrayTask error:', JSON.stringify(error));
    throw new Error(`SortArrayTask failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

/**
 * 数据过滤任务
 * @param arrayData 原始数组
 * @param filterFnStr 过滤函数字符串（简化版）
 * @returns 过滤后的数组
 */
@Concurrent
export function filterArrayTask<T>(arrayData: T[], condition: string): T[] {
  try {
    // 简单的条件过滤（支持基本类型）
    switch (condition) {
      case 'nonNull':
        return arrayData.filter((item: T): boolean => item !== null && item !== undefined);
      case 'notEmpty':
        return arrayData.filter((item: T): boolean => {
          if (typeof item === 'string') return item.length > 0;
          if (Array.isArray(item)) return item.length > 0;
          if (typeof item === 'object' && item !== null) return Object.keys(item as object).length > 0;
          return true;
        });
      default:
        return arrayData;
    }
  } catch (error) {
    console.error('filterArrayTask error:', JSON.stringify(error));
    throw new Error(`FilterArrayTask failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

/**
 * 批量数据转换任务（返回联合类型）
 * @param arrayData 原始数组
 * @param transformType 转换类型
 * @returns 转换后的数组
 */
@Concurrent
export function transformArrayTask<T>(
  arrayData: T[],
  transformType: string
): Array<string | number> {
  try {
    switch (transformType) {
      case 'toString': {
        const toStringResult: string[] = arrayData.map((item: T): string => String(item));
        return toStringResult;
      }
      case 'toNumber': {
        const toNumberResult: number[] = arrayData.map((item: T): number => Number(item));
        return toNumberResult;
      }
      case 'toLowerCase': {
        // 使用工厂函数进行类型转换
        const result: string[] = arrayData.map((item: T): string => {
          const itemStr = String(item);
          return itemStr.toLowerCase();
        });
        return result;
      }
      default:
        return [];
    }
  } catch (error) {
    console.error('transformArrayTask error:', JSON.stringify(error));
    throw new Error(`TransformArrayTask failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

/**
 * 计算哈希值任务（用于文件校验）
 * @param data 数据
 * @returns 简易哈希值
 */
@Concurrent
export function calculateHashTask(data: ArrayBuffer | string): number {
  try {
    let str: string;
    
    if (data instanceof ArrayBuffer) {
      // ArrayBuffer 转字符串
      const bytes = new Uint8Array(data);
      str = Array.from(bytes).map(b => String.fromCharCode(b)).join('');
    } else {
      str = data;
    }
    
    // 简易哈希算法（DJ Bernstein hash）
    let hash = 5381;
    for (let i = 0; i < str.length; i++) {
      hash = ((hash << 5) + hash) + str.charCodeAt(i);
      hash = hash & hash; // Convert to 32bit integer
    }
    
    return hash >>> 0; // 确保为正数
  } catch (error) {
    console.error('calculateHashTask error:', JSON.stringify(error));
    throw new Error(`CalculateHashTask failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

/**
 * 数据分片任务
 * @param data 完整数据
 * @param chunkSize 每片大小
 * @returns 分片后的数组
 */
@Concurrent
export function chunkDataTask(data: ArrayBuffer, chunkSize: number): ArrayBuffer[] {
  try {
    const chunks: ArrayBuffer[] = [];
    const bytes = new Uint8Array(data);
    
    let offset = 0;
    while (offset < bytes.length) {
      const end = Math.min(offset + chunkSize, bytes.length);
      const chunkLength = end - offset;
      const chunk = new ArrayBuffer(chunkLength);
      const chunkView = new Uint8Array(chunk);
      for (let i = 0; i < chunkLength; i++) {
        chunkView[i] = bytes[offset + i];
      }
      chunks.push(chunk);
      offset = end;
    }
    
    return chunks;
  } catch (error) {
    console.error('chunkDataTask error:', JSON.stringify(error));
    throw new Error(`ChunkDataTask failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

/**
 * 合并数据分片任务
 * @param chunks 分片数组
 * @returns 合并后的完整数据
 */
@Concurrent
export function mergeChunksTask(chunks: ArrayBuffer[]): ArrayBuffer {
  try {
    const totalLength = chunks.reduce((sum, chunk) => sum + chunk.byteLength, 0);
    const merged = new Uint8Array(totalLength);
    
    let offset = 0;
    for (const chunk of chunks) {
      const view = new Uint8Array(chunk);
      merged.set(view, offset);
      offset += view.length;
    }
    
    return merged.buffer;
  } catch (error) {
    console.error('mergeChunksTask error:', JSON.stringify(error));
    throw new Error(`MergeChunksTask failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}
