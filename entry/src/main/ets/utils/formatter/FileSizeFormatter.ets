/**
 * 文件大小格式化工具类
 */
export class FileSizeFormatter {
  private static readonly UNITS: string[] = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB'];
  private static readonly UNIT_THRESHOLD: number = 1024;

  /**
   * 格式化文件大小
   */
  static format(bytes: number, decimals: number = 2): string {
    if (bytes === 0) {
      return '0 B';
    }

    const unitIndex = Math.floor(Math.log(bytes) / Math.log(FileSizeFormatter.UNIT_THRESHOLD));
    const size = bytes / Math.pow(FileSizeFormatter.UNIT_THRESHOLD, unitIndex);
    const unit = FileSizeFormatter.UNITS[unitIndex];

    return `${size.toFixed(decimals)} ${unit}`;
  }

  /**
   * 格式化比特率（如：Mbps）
   */
  static formatBitRate(bits: number, decimals: number = 2): string {
    if (bits === 0) {
      return '0 bps';
    }

    const units: string[] = ['bps', 'Kbps', 'Mbps', 'Gbps', 'Tbps'];
    const unitIndex = Math.floor(Math.log(bits) / Math.log(FileSizeFormatter.UNIT_THRESHOLD));
    const size = bits / Math.pow(FileSizeFormatter.UNIT_THRESHOLD, unitIndex);
    const unit = units[unitIndex];

    return `${size.toFixed(decimals)} ${unit}`;
  }

  /**
   * 解析文件大小字符串（如："1.5 MB" -> 1572864）
   */
  static parse(sizeStr: string): number {
    const match = sizeStr.match(/^([\d.]+)\s*(\w+)$/);
    if (!match) {
      return 0;
    }

    const size = parseFloat(match[1]);
    const unit = match[2].toUpperCase();
    const unitIndex = FileSizeFormatter.UNITS.indexOf(unit);

    if (unitIndex === -1) {
      return 0;
    }

    return size * Math.pow(FileSizeFormatter.UNIT_THRESHOLD, unitIndex);
  }

  /**
   * 计算传输时间
   */
  static calculateTransferTime(
    bytes: number,
    speedBitsPerSecond: number
  ): string {
    if (speedBitsPerSecond === 0) {
      return '∞';
    }

    const seconds = (bytes * 8) / speedBitsPerSecond;
    return FileSizeFormatter.formatDuration(seconds);
  }

  /**
   * 格式化持续时间
   */
  static formatDuration(seconds: number): string {
    if (seconds < 60) {
      return `${Math.round(seconds)}s`;
    } else if (seconds < 3600) {
      const minutes = Math.floor(seconds / 60);
      const remainingSeconds = Math.round(seconds % 60);
      return remainingSeconds > 0 ? `${minutes}m ${remainingSeconds}s` : `${minutes}m`;
    } else if (seconds < 86400) {
      const hours = Math.floor(seconds / 3600);
      const remainingMinutes = Math.floor((seconds % 3600) / 60);
      return remainingMinutes > 0 ? `${hours}h ${remainingMinutes}m` : `${hours}h`;
    } else {
      const days = Math.floor(seconds / 86400);
      const remainingHours = Math.floor((seconds % 86400) / 3600);
      return remainingHours > 0 ? `${days}d ${remainingHours}h` : `${days}d`;
    }
  }
}
