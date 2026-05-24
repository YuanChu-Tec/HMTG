import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 请求队列接口
 */
interface QueuedRequest {
  id: number;
  action: () => Promise<Object>;
  retries: number;
  maxRetries: number;
  onFail: ((error: Object) => void) | undefined;
  onSuccess: ((result: Object) => void) | undefined;
}

/**
 * 请求选项接口
 */
interface RequestOptions {
  maxRetries: number | undefined;
  onFail: ((error: Object) => void) | undefined;
  onSuccess: ((result: Object) => void) | undefined;
}

/**
 * 请求队列管理器
 * 管理需要重试的请求
 */
export class RequestQueue {
  private static instance: RequestQueue;
  private queue: QueuedRequest[] = [];
  private isProcessing: boolean = false;
  private nextId: number = 0;

  private static readonly TAG = 'RequestQueue';
  private static readonly DOMAIN = 0x0001;
  private static readonly RETRY_DELAY = 1000; // 1秒后重试

  private constructor() {}

  public static getInstance(): RequestQueue {
    if (!RequestQueue.instance) {
      RequestQueue.instance = new RequestQueue();
    }
    return RequestQueue.instance;
  }

  /**
   * 添加请求到队列
   */
  public enqueue(
    action: () => Promise<Object>,
    options: RequestOptions
  ): number {
    const maxRetriesVal = options.maxRetries || 3;
    const request: QueuedRequest = {
      id: ++this.nextId,
      action: action,
      retries: 0,
      maxRetries: maxRetriesVal,
      onFail: options.onFail,
      onSuccess: options.onSuccess
    };

    this.queue.push(request);
    hilog.debug(RequestQueue.DOMAIN, RequestQueue.TAG,
      `Request ${request.id} enqueued, queue size: ${this.queue.length}`);

    this.processQueue();

    return request.id;
  }

  /**
   * 移除请求
   */
  public dequeue(requestId: number): void {
    this.queue = this.queue.filter(req => req.id !== requestId);
    hilog.debug(RequestQueue.DOMAIN, RequestQueue.TAG,
      `Request ${requestId} dequeued, queue size: ${this.queue.length}`);
  }

  /**
   * 清空队列
   */
  public clear(): void {
    this.queue = [];
    this.isProcessing = false;
    hilog.info(RequestQueue.DOMAIN, RequestQueue.TAG, 'Request queue cleared');
  }

  /**
   * 获取队列大小
   */
  public getQueueSize(): number {
    return this.queue.length;
  }

  /**
   * 处理队列
   */
  private async processQueue(): Promise<void> {
    if (this.isProcessing || this.queue.length === 0) {
      return;
    }

    this.isProcessing = true;

    while (this.queue.length > 0) {
      const request = this.queue[0];
      await this.executeRequest(request);
      
      // 成功后移除
      if (request.retries >= request.maxRetries) {
        this.queue.shift();
      }
    }

    this.isProcessing = false;
  }

  /**
   * 执行单个请求
   */
  private async executeRequest(request: QueuedRequest): Promise<void> {
    try {
      hilog.debug(RequestQueue.DOMAIN, RequestQueue.TAG,
        `Executing request ${request.id}, attempt ${request.retries + 1}`);

      const result = await request.action();
      
      // 成功回调
      if (request.onSuccess) {
        request.onSuccess(result);
      }

      hilog.info(RequestQueue.DOMAIN, RequestQueue.TAG,
        `Request ${request.id} succeeded`);
    } catch (error) {
      request.retries++;
      
      hilog.error(RequestQueue.DOMAIN, RequestQueue.TAG,
        `Request ${request.id} failed, retry ${request.retries}/${request.maxRetries}: ${error}`);

      // 超过最大重试次数
      if (request.retries >= request.maxRetries) {
        if (request.onFail) {
          request.onFail(error);
        }
        hilog.error(RequestQueue.DOMAIN, RequestQueue.TAG,
          `Request ${request.id} failed after ${request.maxRetries} retries`);
      } else {
        // 延迟后重试
        await this.delay(RequestQueue.RETRY_DELAY);
        // 将请求移到队列末尾重新处理
        this.queue.shift();
        this.queue.push(request);
        await this.processQueue();
      }
    }
  }

  /**
   * 延迟函数
   */
  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
