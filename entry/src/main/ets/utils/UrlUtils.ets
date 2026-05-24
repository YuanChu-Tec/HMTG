/**
 * URL 工具类
 * 提供外部链接打开功能
 */
import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class UrlUtils {
  private static readonly TAG: string = 'UrlUtils';
  private static readonly DOMAIN: number = 0x0001;
  private static context: common.UIAbilityContext | null = null;

  /**
   * 初始化
   * @param context UIAbility上下文
   */
  public static initialize(context: common.UIAbilityContext): void {
    UrlUtils.context = context;
    hilog.info(UrlUtils.DOMAIN, UrlUtils.TAG, 'UrlUtils initialized');
  }

  /**
   * 打开外部链接（浏览器）
   * @param url 要打开的URL
   * @returns 是否成功打开
   */
  public static async openExternalUrl(url: string): Promise<boolean> {
    if (!UrlUtils.context) {
      hilog.error(UrlUtils.DOMAIN, UrlUtils.TAG, 'Context not initialized');
      return false;
    }

    try {
      // 验证URL格式
      if (!UrlUtils.isValidUrl(url)) {
        hilog.error(UrlUtils.DOMAIN, UrlUtils.TAG, `Invalid URL: ${url}`);
        return false;
      }

      // 构造 Want 对象，使用浏览器打开
      const want: Want = {
        action: 'ohos.want.action.viewData',
        entities: ['entity.system.browsable'],
        uri: url,
        type: 'text/html'
      };

      // 使用隐式 Intent 打开链接
      await UrlUtils.context.startAbility(want);
      hilog.info(UrlUtils.DOMAIN, UrlUtils.TAG, `Opened external URL: ${url}`);
      return true;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(UrlUtils.DOMAIN, UrlUtils.TAG, `Open external URL failed: ${err.message}, code: ${err.code}`);
      return false;
    }
  }

  /**
   * 在应用内打开链接
   * @param url 要打开的URL
   * @returns 是否成功打开
   */
  public static async openInternalUrl(url: string): Promise<boolean> {
    if (!UrlUtils.context) {
      hilog.error(UrlUtils.DOMAIN, UrlUtils.TAG, 'Context not initialized');
      return false;
    }

    try {
      // 验证URL格式
      if (!UrlUtils.isValidUrl(url)) {
        hilog.error(UrlUtils.DOMAIN, UrlUtils.TAG, `Invalid URL: ${url}`);
        return false;
      }

      // 这里可以实现应用内 WebView 打开链接
      // 暂时使用浏览器打开
      return await UrlUtils.openExternalUrl(url);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(UrlUtils.DOMAIN, UrlUtils.TAG, `Open internal URL failed: ${err.message}`);
      return false;
    }
  }

  /**
   * 验证URL格式
   * @param url 要验证的URL
   * @returns 是否为有效URL
   */
  private static isValidUrl(url: string): boolean {
    if (!url || url.length === 0) {
      return false;
    }

    try {
      // 基本URL验证
      const urlPattern = /^https?:\/\/.+/i;
      if (!urlPattern.test(url)) {
        return false;
      }

      // 简单验证：检查是否有有效的域名
      const match = url.match(/^https?:\/\/([^\/]+)/);
      if (!match || !match[1]) {
        return false;
      }

      // 检查协议
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        return false;
      }

      return true;
    } catch {
      return false;
    }
  }

  /**
   * 构造 Telegram 链接
   * @param username Telegram 用户名
   * @returns 完整的 Telegram 链接
   */
  public static buildTelegramLink(username: string): string {
    // 移除 @ 符号
    const cleanUsername = username.startsWith('@') ? username.substring(1) : username;
    return `https://t.me/${cleanUsername}`;
  }

  /**
   * 构造 Telegram 邀请链接
   * @param inviteCode 邀请码
   * @returns 完整的 Telegram 邀请链接
   */
  public static buildTelegramInviteLink(inviteCode: string): string {
    return `https://t.me/+${inviteCode}`;
  }

  /**
   * 构造 Telegram 加入群组链接
   * @param inviteCode 邀请码
   * @returns 完整的 Telegram 群组链接
   */
  public static buildTelegramJoinLink(inviteCode: string): string {
    return `https://t.me/joinchat/${inviteCode}`;
  }

  /**
   * 从链接中提取用户名
   * @param url Telegram 链接
   * @returns 用户名，如果不是 Telegram 链接则返回 null
   */
  public static extractUsernameFromUrl(url: string): string | null {
    try {
      const urlPattern = /^https?:\/\/t\.me\/([a-zA-Z0-9_]+)/i;
      const match = url.match(urlPattern);
      return match ? match[1] : null;
    } catch {
      return null;
    }
  }

  /**
   * 检查链接是否为 Telegram 链接
   * @param url 要检查的URL
   * @returns 是否为 Telegram 链接
   */
  public static isTelegramUrl(url: string): boolean {
    const telegramDomainPattern = /^https?:\/\/(t\.me|telegram\.org|telegram\.me)/i;
    return telegramDomainPattern.test(url);
  }

  /**
   * 获取显示的URL（缩短长URL）
   * @param url 原始URL
   * @param maxLength 最大长度
   * @returns 缩短后的URL
   */
  public static getDisplayUrl(url: string, maxLength: number = 40): string {
    if (url.length <= maxLength) {
      return url;
    }

    return url.substring(0, maxLength - 3) + '...';
  }
}
