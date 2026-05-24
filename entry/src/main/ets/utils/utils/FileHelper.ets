/**
 * 文件处理工具类
 */
export class FileHelper {
  /**
   * 获取文件扩展名
   */
  static getFileExtension(fileName: string): string {
    const lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex === -1) {
      return '';
    }
    return fileName.substring(lastDotIndex + 1).toLowerCase();
  }

  /**
   * 获取文件名(不含扩展名)
   */
  static getFileNameWithoutExtension(fileName: string): string {
    const lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex === -1) {
      return fileName;
    }
    return fileName.substring(0, lastDotIndex);
  }

  /**
   * 格式化文件大小
   */
  static formatFileSize(bytes: number): string {
    if (bytes === 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    const k = 1024;
    const i = Math.floor(Math.log(bytes) / Math.log(k));

    const size = bytes / Math.pow(k, i);
    const unit = units[i];

    return `${size.toFixed(1)} ${unit}`;
  }

  /**
   * 检查是否为图片文件
   */
  static isImageFile(fileName: string): boolean {
    const ext = FileHelper.getFileExtension(fileName);
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'];
    return imageExtensions.includes(ext);
  }

  /**
   * 检查是否为视频文件
   */
  static isVideoFile(fileName: string): boolean {
    const ext = FileHelper.getFileExtension(fileName);
    const videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm', 'flv'];
    return videoExtensions.includes(ext);
  }

  /**
   * 检查是否为音频文件
   */
  static isAudioFile(fileName: string): boolean {
    const ext = FileHelper.getFileExtension(fileName);
    const audioExtensions = ['mp3', 'wav', 'ogg', 'm4a', 'flac', 'aac'];
    return audioExtensions.includes(ext);
  }

  /**
   * 检查是否为PDF文件
   */
  static isPdfFile(fileName: string): boolean {
    return FileHelper.getFileExtension(fileName) === 'pdf';
  }

  /**
   * 检查是否为压缩文件
   */
  static isArchiveFile(fileName: string): boolean {
    const ext = FileHelper.getFileExtension(fileName);
    const archiveExtensions = ['zip', 'rar', '7z', 'tar', 'gz'];
    return archiveExtensions.includes(ext);
  }

  /**
   * 根据文件类型获取图标
   */
  static getFileIcon(fileName: string): string {
    const ext = FileHelper.getFileExtension(fileName);

    if (ext === 'pdf') return 'ic_PDF';
    if (FileHelper.isImageFile(fileName)) return 'ic_image';
    if (FileHelper.isVideoFile(fileName)) return 'ic_video';
    if (FileHelper.isAudioFile(fileName)) return 'ic_audio';

    const docExtensions = ['doc', 'docx', 'txt', 'rtf'];
    if (docExtensions.includes(ext)) return 'ic_file_doc';

    const archiveExtensions = ['zip', 'rar', '7z'];
    if (archiveExtensions.includes(ext)) return 'ic_file_zip';

    return 'ic_file';
  }

  /**
   * 验证文件名
   */
  static isValidFileName(fileName: string): boolean {
    // 不允许的字符
    const invalidChars = /[<>:"/\\|?*]/g;
    if (invalidChars.test(fileName)) {
      return false;
    }

    // 保留文件名
    const reservedNames = ['CON', 'PRN', 'AUX', 'NUL',
                      'COM1', 'COM2', 'COM3', 'COM4',
                      'COM5', 'COM6', 'COM7', 'COM8', 'COM9',
                      'LPT1', 'LPT2', 'LPT3', 'LPT4',
                      'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9'];
    const nameWithoutExt = FileHelper.getFileNameWithoutExtension(fileName).toUpperCase();
    if (reservedNames.includes(nameWithoutExt)) {
      return false;
    }

    return true;
  }

  /**
   * 生成唯一文件名
   */
  static generateUniqueFileName(baseName: string, existingFiles: string[]): string {
    let fileName = baseName;
    let counter = 1;

    while (existingFiles.includes(fileName)) {
      const nameWithoutExt = FileHelper.getFileNameWithoutExtension(baseName);
      const ext = FileHelper.getFileExtension(baseName);
      fileName = ext ? `${nameWithoutExt}_${counter}.${ext}` : `${nameWithoutExt}_${counter}`;
      counter++;
    }

    return fileName;
  }

  /**
   * 获取MIME类型
   */
  static getMimeType(fileName: string): string {
    const ext = FileHelper.getFileExtension(fileName);

    const mimeMap: Record<string, string> = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'pdf': 'application/pdf',
      'mp3': 'audio/mpeg',
      'mp4': 'video/mp4',
      'zip': 'application/zip',
      'txt': 'text/plain'
    };

    const mimeType = mimeMap[ext];
    return mimeType || 'application/octet-stream';
  }
}
