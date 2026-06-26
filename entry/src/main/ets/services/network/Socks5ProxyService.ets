/**
 * Socks5 代理服务
 * 基于华为 HarmonyOS NetworkKit 实现 Socks5 代理连接测试和错误处理。
 * 华为最佳实践：
 * - 连接超时：明确设置超时（默认 10s，中等优先级场景）
 * - 智能重试：针对 2303111/2303104/2303200 等可重试错误，指数退避（1s/2s/3s）
 * - 参数校验：服务器地址、端口 1–65535、用户名/密码长度 ≤255
 * - 资源释放：finally 中关闭 Socket，避免泄漏
 * 参考：@kit.NetworkKit socket.ProxyOptions、HarmonyOS 网络请求优化实战
 */
import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { NetworkMonitorService } from '../business/kernel/ConnectionMonitor';

const DOMAIN = 0x0001;
const TAG = 'Socks5ProxyService';

/** 代理测试结果 */
export interface ProxyTestResult {
  success: boolean;
  errorCode?: number;
  errorMessage?: string;
}

/** Socks5 代理配置 */
export interface Socks5ProxyConfig {
  server: string;
  port: number;
  username?: string;
  password?: string;
}

/**
 * Socks5 代理服务
 * 提供代理连接测试、错误处理等功能
 */
export class Socks5ProxyService {
  private static instance: Socks5ProxyService;
  private networkMonitor: NetworkMonitorService;

  private constructor() {
    this.networkMonitor = NetworkMonitorService.getInstance();
  }

  public static getInstance(): Socks5ProxyService {
    if (!Socks5ProxyService.instance) {
      Socks5ProxyService.instance = new Socks5ProxyService();
    }
    return Socks5ProxyService.instance;
  }

  /**
   * 测试 Socks5 代理连接（华为最佳实践：带重试机制和完整错误处理）
   * @param config 代理配置
   * @param timeoutMs 超时时间（毫秒），默认 10 秒
   * @param maxRetries 最大重试次数（默认 3，针对可重试错误）
   * @returns 测试结果
   */
  async testProxyConnection(
    config: Socks5ProxyConfig,
    timeoutMs: number = 10000,
    maxRetries: number = 3
  ): Promise<ProxyTestResult> {
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

    // 华为最佳实践：验证用户名和密码长度（避免 2301212 错误）
    if (config.username && config.username.length > 255) {
      return {
        success: false,
        errorCode: 2301212,
        errorMessage: '用户名长度超过 255 字符'
      };
    }
    if (config.password && config.password.length > 255) {
      return {
        success: false,
        errorCode: 2301212,
        errorMessage: '密码长度超过 255 字符'
      };
    }

    let udp: socket.UDPSocket | undefined;
    let timeoutId: number = -1;

    try {
      // 1. 创建 UDP Socket 实例
      udp = socket.constructUDPSocketInstance();

      // 2. 绑定本地端口（华为文档要求：必需前置操作）
      await udp.bind({ address: '0.0.0.0', port: 0 }); // 端口 0 表示系统自动分配
      hilog.info(DOMAIN, TAG, 'Socket bound successfully');

      // 3. 配置代理服务器参数
      const proxyOptions: socket.ProxyOptions = {
        type: 1, // Socks5 代理类型标识
        address: {
          address: config.server,
          port: config.port
        }
      };

      // 华为最佳实践：匿名代理时移除用户名和密码字段
      if (config.username && config.username.length > 0) {
        proxyOptions.username = config.username;
      }
      if (config.password && config.password.length > 0) {
        proxyOptions.password = config.password;
      }

      // 4. 设置超时
      const timeoutPromise = new Promise<ProxyTestResult>((resolve) => {
        timeoutId = setTimeout(() => {
          resolve({
            success: false,
            errorCode: 2301210,
            errorMessage: '代理连接超时'
          });
        }, timeoutMs);
      });

      // 5. 通过代理发送测试数据（带重试机制）
      let retryCount = 0;
      let lastError: ProxyTestResult | undefined;

      while (retryCount <= maxRetries) {
        try {
          const sendOptions: socket.UDPSendOptions = {
            data: new Uint8Array([0x00, 0x01, 0x02, 0x03]), // 测试数据
            address: {
              address: '8.8.8.8', // Google DNS，用于测试连通性
              port: 53
            },
            proxy: proxyOptions
          };

          // 华为最佳实践：设置超时控制
          const sendPromise = (async (): Promise<ProxyTestResult> => {
            try {
              await udp.send(sendOptions);
              hilog.info(DOMAIN, TAG, 'Proxy test data sent successfully');
              return { success: true };
            } catch (error) {
              const err = error as BusinessError;
              return this.handleProxyError(err);
            }
          })();

          // 等待结果或超时
          const result = await Promise.race([sendPromise, timeoutPromise]);

          // 清理超时定时器
          if (timeoutId !== -1) {
            clearTimeout(timeoutId);
            timeoutId = -1;
          }

          // 成功或不可重试的错误直接返回
          if (result.success || !result.errorCode || !this.isRetryableError(result.errorCode)) {
            return result;
          }

          // 可重试的错误，记录并继续重试
          lastError = result;
          if (retryCount < maxRetries) {
            const delayMs = 1000 * (retryCount + 1); // 指数退避：1s, 2s, 3s
            hilog.warn(DOMAIN, TAG, 'Proxy test failed (retryable), retrying after %{public}d ms (attempt %{public}d/%{public}d)',
              delayMs, retryCount + 1, maxRetries);
            await new Promise<void>((resolve) => setTimeout(resolve, delayMs));
            retryCount++;

            // 重新设置超时定时器
            timeoutId = setTimeout(() => {
              // 超时处理在 Promise.race 中处理
            }, timeoutMs);
            continue;
          }

          // 重试次数用尽
          return result;
        } catch (error) {
          const err = error as BusinessError;
          lastError = this.handleProxyError(err);

          // 不可重试的错误直接返回
          if (!lastError.errorCode || !this.isRetryableError(lastError.errorCode)) {
            if (timeoutId !== -1) {
              clearTimeout(timeoutId);
              timeoutId = -1;
            }
            return lastError;
          }

          // 可重试的错误
          if (retryCount < maxRetries) {
            const delayMs = 1000 * (retryCount + 1);
            hilog.warn(DOMAIN, TAG, 'Proxy test exception (retryable), retrying after %{public}d ms (attempt %{public}d/%{public}d)',
              delayMs, retryCount + 1, maxRetries);
            await new Promise<void>((resolve) => setTimeout(resolve, delayMs));
            retryCount++;
            continue;
          }

          // 重试次数用尽
          if (timeoutId !== -1) {
            clearTimeout(timeoutId);
            timeoutId = -1;
          }
          return lastError;
        }
      }

      // 清理超时定时器
      if (timeoutId !== -1) {
        clearTimeout(timeoutId);
        timeoutId = -1;
      }

      // 返回最后一次错误
      return lastError || {
        success: false,
        errorCode: 2301210,
        errorMessage: '代理连接失败（重试次数用尽）'
      };
    } catch (error) {
      const err = error as BusinessError;
      return this.handleProxyError(err);
    } finally {
      // 华为最佳实践：资源释放
      if (timeoutId !== -1) {
        clearTimeout(timeoutId);
      }
      if (udp) {
        try {
          udp.close((closeErr: BusinessError) => {
            if (closeErr) {
              hilog.warn(DOMAIN, TAG, 'Failed to close socket: %{public}d', closeErr.code);
            } else {
              hilog.info(DOMAIN, TAG, 'Socket closed successfully');
            }
          });
        } catch (e) {
          hilog.warn(DOMAIN, TAG, 'Error closing socket: %{public}s', JSON.stringify(e));
        }
      }
    }
  }

  /**
   * 处理代理错误（基于华为官方文档错误码，包含完整错误码映射）
   * @param error 错误对象
   * @returns 格式化的错误结果
   */
  private handleProxyError(error: BusinessError): ProxyTestResult {
    const code = error.code || 0;
    let message = '';

    // 华为官方文档错误码映射（完整版）
    switch (code) {
      case 2301206:
        message = '代理服务器地址或端口无效（请检查 IP/域名和端口号）';
        break;
      case 2301207:
        message = '代理认证凭据错误（用户名或密码不正确）';
        break;
      case 2301208:
        message = '远程服务器不可达（请检查网络连接和目标服务器状态）';
        break;
      case 2301209:
        message = '代理不支持客户端认证方式（请移除用户名和密码，使用匿名代理）';
        break;
      case 2301210:
        message = '内存溢出或参数无效（请重建 Socket 连接）';
        break;
      case 2301212:
        message = '用户名或密码长度超过 255 字符（请缩短凭证长度）';
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
      case 2303191:
        message = '协议不匹配（UDP 不能用于 SOCK_STREAM）';
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

    hilog.error(DOMAIN, TAG, 'Proxy error: code=%{public}d message=%{public}s', code, message);
    return {
      success: false,
      errorCode: code,
      errorMessage: message
    };
  }

  /**
   * 判断错误是否可重试（华为最佳实践：针对特定错误码重试）
   * @param errorCode 错误码
   * @returns 是否可重试
   */
  private isRetryableError(errorCode: number): boolean {
    // 可重试的错误码：系统资源繁忙、连接中断、网络不可用
    return errorCode === 2303111 || errorCode === 2303104 || errorCode === 2303200;
  }

  /**
   * 获取错误提示消息（用于 UI 显示）
   * @param result 测试结果
   * @returns 用户友好的错误消息
   */
  getErrorMessage(result: ProxyTestResult): string {
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
}
