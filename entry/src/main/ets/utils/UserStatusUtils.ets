import { LogService } from './log/LogService';

const TAG = 'UserStatusUtils';
const DOMAIN = 0x0001;

/**
 * TDLib 用户在线状态类型
 */
export type UserStatusType = 
  | 'userStatusOnline'      // 当前在线
  | 'userStatusOffline'     // 离线(有时间戳)
  | 'userStatusRecently'    // 最近在线(1-3天)
  | 'userStatusLastWeek'    // 上周在线
  | 'userStatusLastMonth'   // 上月在线
  | 'userStatusEmpty';      // 状态未知

/**
 * 用户状态信息接口
 */
export interface UserStatusInfo {
  statusText: string;  // 显示文本
  isOnline: boolean;   // 是否在线
  color: string;       // 颜色值
}

/**
 * 用户状态工具类 - 统一管理在线状态的解析和显示
 */
export class UserStatusUtils {
  private static instance: UserStatusUtils;
  
  // 颜色常量
  private static readonly ONLINE_COLOR = '#007AFF';   // 蓝色
  private static readonly OFFLINE_COLOR = '#8E8E93';  // 灰色
  
  private constructor() {}
  
  /**
   * 获取单例实例
   */
  static getInstance(): UserStatusUtils {
    if (!UserStatusUtils.instance) {
      UserStatusUtils.instance = new UserStatusUtils();
    }
    return UserStatusUtils.instance;
  }
  
  /**
   * 从 TDLib user.status 对象提取状态信息
   * @param statusObj TDLib user.status 对象
   * @returns 用户状态信息
   */
  extractStatusInfo(statusObj?: Object): UserStatusInfo {
    if (!statusObj) {
      return this.createOfflineStatus('离线');
    }
    
    const record = statusObj as Record<string, Object>;
    const statusType = record['@type'] as string;
    LogService.getInstance().debug(DOMAIN, TAG, `User status type: ${statusType}`);
    
    switch (statusType) {
      case 'userStatusOnline':
        return this.createOnlineStatus('在线');
        
      case 'userStatusOffline':
        return this.parseOfflineStatus(record);
        
      case 'userStatusRecently':
        return this.createOfflineStatus('最近在线');
        
      case 'userStatusLastWeek':
        return this.createOfflineStatus('上周在线');
        
      case 'userStatusLastMonth':
        return this.createOfflineStatus('上月在线');
        
      default:
        return this.createOfflineStatus('离线');
    }
  }
  
  /**
   * 解析离线状态(包含时间戳)
   */
  private parseOfflineStatus(statusObj: Record<string, Object>): UserStatusInfo {
    const wasOnlineVal = statusObj['was_online'];
    
    if (wasOnlineVal !== undefined && wasOnlineVal !== null) {
      const wasOnline = Number(wasOnlineVal);
      const diff = Math.floor((Date.now() - wasOnline) / 60000); // 分钟
      
      let statusText: string;
      
      if (diff < 5) {
        statusText = '最近在线';
      } else if (diff < 60) {
        statusText = `${diff}分钟前在线`;
      } else {
        const hours = Math.floor(diff / 60);
        if (hours < 24) {
          statusText = `${hours}小时前在线`;
        } else {
          const days = Math.floor(hours / 24);
          if (days < 7) {
            statusText = '上周在线';
          } else {
            statusText = '上月在线';
          }
        }
      }
      
      return this.createOfflineStatus(statusText);
    }
    
    return this.createOfflineStatus('离线');
  }
  
  /**
   * 创建在线状态
   */
  private createOnlineStatus(text: string): UserStatusInfo {
    return {
      statusText: text,
      isOnline: true,
      color: UserStatusUtils.ONLINE_COLOR
    };
  }
  
  /**
   * 创建离线状态
   */
  private createOfflineStatus(text: string): UserStatusInfo {
    return {
      statusText: text,
      isOnline: false,
      color: UserStatusUtils.OFFLINE_COLOR
    };
  }
  
  /**
   * 获取状态文本
   * @param statusObj TDLib user.status 对象
   * @returns 状态文本
   */
  getStatusText(statusObj?: Object): string {
    return this.extractStatusInfo(statusObj).statusText;
  }
  
  /**
   * 判断是否在线
   * @param statusObj TDLib user.status 对象
   * @returns 是否在线
   */
  isOnline(statusObj?: Object): boolean {
    return this.extractStatusInfo(statusObj).isOnline;
  }
  
  /**
   * 获取状态颜色
   * @param statusObj TDLib user.status 对象
   * @returns 颜色值
   */
  getStatusColor(statusObj?: Object): string {
    return this.extractStatusInfo(statusObj).color;
  }
}
