import { fileIo } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '../error/BusinessError';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'FileHelper';
const DOMAIN = 0x0001;

/**
 * 文件信息
 */
export interface FileInfo {
  path: string;
  name: string;
  size: number;
  isDirectory: boolean;
  lastModified: number;
}

/**
 * 文件助手
 */
export class FileHelper {
  /**
   * 检查文件是否存在
   */
  static async exists(filePath: string): Promise<boolean> {
    try {
      const stat = await fileIo.stat(filePath);
      return !!stat;
    } catch (error) {
      return false;
    }
  }

  /**
   * 获取文件信息
   */
  static async getFileInfo(filePath: string): Promise<FileInfo> {
    try {
      const stat = await fileIo.stat(filePath);

      const pathParts = filePath.split('/');
      const fileName = pathParts[pathParts.length - 1];

      const fileInfo: FileInfo = {
        path: filePath,
        name: fileName,
        size: stat.size,
        isDirectory: stat.isDirectory(),
        lastModified: stat.mtime
      };
      return fileInfo;
    } catch (error) {
      throw new BusinessError(0, `Failed to get file info: ${filePath}`, '获取文件信息失败');
    }
  }

  /**
   * 读取文件内容
   */
  static async readFile(filePath: string): Promise<string> {
    try {
      const file = await fileIo.open(filePath, fileIo.OpenMode.READ_ONLY);
      const buffer = new ArrayBuffer(4096);
      const readResult = await fileIo.read(file.fd, buffer, { offset: 0, length: 4096 });
      await fileIo.close(file);

      const decoder = new util.TextDecoder('utf-8');
      interface ReadResultObj {
        readLen?: number;
      }
      const readResultObj = readResult as ReadResultObj;
      const readLen = readResultObj.readLen || 0;
      return decoder.decodeToString(new Uint8Array(buffer, 0, readLen));
    } catch (error) {
      throw new BusinessError(0, `Failed to read file: ${filePath}`, '读取文件失败');
    }
  }

  /**
   * 写入文件内容
   */
  static async writeFile(filePath: string, content: string): Promise<void> {
    try {
      const file = await fileIo.open(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
      const encoder = new util.TextEncoder();
      const writeBuffer = encoder.encodeInto(content);
      await fileIo.write(file.fd, writeBuffer, { offset: 0 });
      await fileIo.close(file);

      hilog.info(DOMAIN, TAG, `File written: ${filePath}`);
    } catch (error) {
      throw new BusinessError(0, `Failed to write file: ${filePath}`, '写入文件失败');
    }
  }

  /**
   * 删除文件
   */
  static async deleteFile(filePath: string): Promise<void> {
    try {
      await fileIo.unlink(filePath);
      hilog.info(DOMAIN, TAG, `File deleted: ${filePath}`);
    } catch (error) {
      throw new BusinessError(0, `Failed to delete file: ${filePath}`, '删除文件失败');
    }
  }

  /**
   * 创建目录
   */
  static async createDirectory(dirPath: string): Promise<void> {
    try {
      await fileIo.mkdir(dirPath);
      hilog.info(DOMAIN, TAG, `Directory created: ${dirPath}`);
    } catch (error) {
      throw new BusinessError(0, `Failed to create directory: ${dirPath}`, '创建目录失败');
    }
  }

  /**
   * 递归创建目录
   */
  static async createDirectories(dirPath: string): Promise<void> {
    const parts = dirPath.split('/');
    let currentPath = '';

    for (const part of parts) {
      if (!part) continue;
      currentPath += '/' + part;
      
      if (!(await FileHelper.exists(currentPath))) {
        await FileHelper.createDirectory(currentPath);
      }
    }
  }

  /**
   * 列出目录内容
   */
  static async listDirectory(dirPath: string): Promise<FileInfo[]> {
    try {
      const files = await fileIo.listFile(dirPath);
      const fileInfoList: FileInfo[] = [];

      for (const fileName of files) {
        const filePath = dirPath.endsWith('/') ? dirPath + fileName : dirPath + '/' + fileName;
        const info = await FileHelper.getFileInfo(filePath);
        fileInfoList.push(info);
      }

      return fileInfoList;
    } catch (error) {
      throw new BusinessError(0, `Failed to list directory: ${dirPath}`, '列出目录内容失败');
    }
  }

  /**
   * 复制文件
   */
  static async copyFile(srcPath: string, destPath: string): Promise<void> {
    try {
      await fileIo.copyFile(srcPath, destPath);
      hilog.info(DOMAIN, TAG, `File copied: ${srcPath} -> ${destPath}`);
    } catch (error) {
      throw new BusinessError(0, `Failed to copy file: ${srcPath}`, '复制文件失败');
    }
  }

  /**
   * 移动/重命名文件
   */
  static async moveFile(srcPath: string, destPath: string): Promise<void> {
    try {
      await fileIo.rename(srcPath, destPath);
      hilog.info(DOMAIN, TAG, `File moved: ${srcPath} -> ${destPath}`);
    } catch (error) {
      throw new BusinessError(0, `Failed to move file: ${srcPath}`, '移动文件失败');
    }
  }

  /**
   * 获取文件MIME类型
   */
  static getMimeType(filePath: string): string {
    const ext = filePath.split('.').pop()?.toLowerCase() || '';

    const mimeTypes = new Map<string, string>([
      ['jpg', 'image/jpeg'],
      ['jpeg', 'image/jpeg'],
      ['png', 'image/png'],
      ['gif', 'image/gif'],
      ['webp', 'image/webp'],
      ['mp4', 'video/mp4'],
      ['mov', 'video/quicktime'],
      ['avi', 'video/x-msvideo'],
      ['mp3', 'audio/mpeg'],
      ['wav', 'audio/wav'],
      ['pdf', 'application/pdf'],
      ['doc', 'application/msword'],
      ['docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'],
      ['xls', 'application/vnd.ms-excel'],
      ['xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
      ['txt', 'text/plain'],
      ['json', 'application/json'],
      ['xml', 'application/xml'],
      ['zip', 'application/zip'],
      ['rar', 'application/x-rar-compressed']
    ]);

    const mimeType = mimeTypes.get(ext);
    return mimeType || 'application/octet-stream';
  }

  /**
   * 清空目录
   */
  static async clearDirectory(dirPath: string): Promise<void> {
    try {
      const files = await fileIo.listFile(dirPath);
      
      for (const fileName of files) {
        const filePath = dirPath.endsWith('/') ? dirPath + fileName : dirPath + '/' + fileName;
        const info = await FileHelper.getFileInfo(filePath);

        if (info.isDirectory) {
          await FileHelper.clearDirectory(filePath);
          await fileIo.rmdir(filePath);
        } else {
          await FileHelper.deleteFile(filePath);
        }
      }
      
      hilog.info(DOMAIN, TAG, `Directory cleared: ${dirPath}`);
    } catch (error) {
      throw new BusinessError(0, `Failed to clear directory: ${dirPath}`, '清空目录失败');
    }
  }
}
