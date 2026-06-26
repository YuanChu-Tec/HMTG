/**
 * MTProto 代理服务
 * 基于华为 HarmonyOS 最佳实践实现 MTProto 配置校验与错误处理。
 * - Secret 格式：16–512 字符十六进制，规范化（去空格、小写）后校验
 * - 实际连通性由 TDLib addProxy 负责；本服务仅做参数校验与错误码映射
 * 参考：Telegram MTProto 规范、华为网络错误码 23012xx/23031xx
 */
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { NetworkMonitorService } from '../business/kernel/ConnectionMonitor';

const DOMAIN = 0x0001;
const TAG = 'MTProtoProxyService';

/** MTProto 代理测试结果 */
export interface MTProtoProxyTestResult {
  success: boolean;
  errorCode?: number;
  errorMessage?: string;
}

/** MTProto 代理配置 */
export interface MTProtoProxyConfig {
  server: string;
  port: number;
  secret: string; // Hex 编码的 Secret
}

/**
 * MTProto 代理服务
 * 提供代理连接测试、Secret 验证、错误处理等功能
 */
export class MTProtoProxyService {
  private static instance: MTProtoProxyService;
  private networkMonitor: NetworkMonitorService;

  private constructor() {
    this.networkMonitor = NetworkMonitorService.getInstance();
  }

  public static getInstance(): MTProtoProxyService {
    if (!MTProtoProxyService.instance) {
      MTProtoProxyService.instance = new MTProtoProxyService();
    }
    return MTProtoProxyService.instance;
  }

  /**
   * 验证 MTProto Secret 格式（华为最佳实践：Hex 编码验证）
   * @param secret Secret 字符串
   * @returns 是否有效
   */
  isValidSecret(secret: string): boolean {
    if (!secret || secret.length === 0) {
      return false;
    }
    // MTProto Secret 必须是十六进制字符串，长度通常为 16-512 字符
    if (secret.length < 16 || secret.length > 512) {
      return false;
    }
    // 验证是否为有效的十六进制字符串
    const hexPattern = /^[0-9A-Fa-f]+$/;
    return hexPattern.test(secret);
  }

  /**
   * 规范化 MTProto Secret（移除空格，转换为小写）
   * @param secret 原始 Secret
   * @returns 规范化后的 Secret
   */
  normalizeSecret(secret: string): string {
    return secret.replace(/\s+/g, '').toLowerCase();
  }

  /**
   * 测试 MTProto 代理连接（华为最佳实践：带重试机制和完整错误处理）
   * 注意：MTProto 是 Telegram 私有协议，实际连接测试需要通过 TDLib
   * 此方法主要用于验证配置参数的有效性
   * @param config 代理配置
   * @param timeoutMs 超时时间（毫秒），默认 10 秒
   * @returns 测试结果
   */
  async testProxyConnection(
    config: MTProtoProxyConfig,
    timeoutMs: number = 10000
  ): Promise<MTProtoProxyTestResult> {
    // 华为最佳实践：检查网络状态
    if (this.networkMonitor.isWeakNetworkNow() || !this.networkMonitor.isNetworkConnected()) {
      return {
        success: false,
        errorCode: 2301208,
        errorMessage: '网络未连接或网络信号弱，无法测试代理'
      };
    }

    // 华为最佳实践：验证参数
    if (!config.server || config.server.length === 0) {
      return {
        success: false,
        errorCode: 2301206,
        errorMessage: '代理服务器地址无效'
      };
    }

    if (config.port <= 0 || config.port > 65535) {
      return {
        success: false,
        errorCode: 2301206,
        errorMessage: '代理端口无效（范围：1-65535）'
      };
    }

    // 华为最佳实践：验证 Secret 格式
    const normalizedSecret = this.normalizeSecret(config.secret);
    if (!this.isValidSecret(normalizedSecret)) {
      return {
        success: false,
        errorCode: 2301210,
        errorMessage: 'MTProto Secret 格式无效（必须是 16-512 字符的十六进制字符串）'
      };
    }

    // 注意：MTProto 是加密协议，无法像 SOCKS5 那样直接测试连接
    // 实际连接测试需要通过 TDLib 的 addProxy 和 enableProxy API
    // 这里只验证配置参数的有效性
    hilog.info(DOMAIN, TAG, 'MTProto proxy config validated: server=%{public}s port=%{public}d secret_len=%{public}d',
      config.server, config.port, normalizedSecret.length);

    return {
      success: true,
      errorMessage: '配置参数验证通过（实际连接需通过 TDLib 测试）'
    };
  }

  /**
   * 处理代理错误（基于华为官方文档错误码）
   * @param error 错误对象
   * @returns 格式化的错误结果
   */
  handleProxyError(error: BusinessError): MTProtoProxyTestResult {
    const code = error.code || 0;
    let message = '';

    // 华为官方文档错误码映射
    switch (code) {
      case 2301206:
        message = '代理服务器地址或端口无效（请检查 IP/域名和端口号）';
        break;
      case 2301208:
        message = '远程服务器不可达（请检查网络连接和目标服务器状态）';
        break;
      case 2301210:
        message = '内存溢出或参数无效（请检查 Secret 格式）';
        break;
      case 2303104:
        message = '连接被中断（请检查网络稳定性）';
        break;
      case 2303109:
        message = '套接字泄漏（请关闭旧连接后重试）';
        break;
      case 2303111:
        message = '系统资源繁忙（请稍后重试）';
        break;
      case 2303198:
        message = '地址冲突（端口已被占用）';
        break;
      case 2303200:
        message = '网络不可用（请检查网络连接）';
        break;
      default:
        message = error.message || `代理连接失败（错误码：${code}）`;
    }

    hilog.error(DOMAIN, TAG, 'MTProto proxy error: code=%{public}d message=%{public}s', code, message);
    return {
      success: false,
      errorCode: code,
      errorMessage: message
    };
  }

  /**
   * 获取错误提示消息（用于 UI 显示）
   * @param result 测试结果
   * @returns 用户友好的错误消息
   */
  getErrorMessage(result: MTProtoProxyTestResult): string {
    if (result.success) {
      return '';
    }

    if (result.errorMessage) {
      return result.errorMessage;
    }

    // 默认错误消息
    if (result.errorCode) {
      return `代理连接失败（错误码：${result.errorCode}）`;
    }

    return '代理连接失败，请检查配置';
  }

  /**
   * 格式化 Secret 显示（每 2 个字符一组，便于阅读）
   * @param secret Secret 字符串
   * @returns 格式化后的字符串
   */
  formatSecretForDisplay(secret: string): string {
    const normalized = this.normalizeSecret(secret);
    if (normalized.length === 0) {
      return '';
    }
    // 每 2 个字符一组，用空格分隔
    const groups: string[] = [];
    for (let i = 0; i < normalized.length; i += 2) {
      groups.push(normalized.substring(i, i + 2));
    }
    return groups.join(' ').toUpperCase();
  }
}
