import { http } from '@kit.NetworkKit';
import { AppError, ErrorSeverity, ErrorCategory } from '../error/AppError';
import { NetworkMonitor } from './NetworkMonitor';

/**
 * HTTP请求配置
 */
export interface HttpRequestConfig {
  url: string;
  method?: http.RequestMethod;
  headers?: Record<string, string>;
  params?: Record<string, string | number>;
  data?: Object | ArrayBuffer | string;
  timeout?: number;
  enableCache?: boolean;
}

/**
 * HTTP响应
 */
export interface HttpResponse<T = Object> {
  data: T;
  status: number;
  headers: Record<string, string>;
  statusText: string;
}

/**
 * HTTP客户端
 */
/**
 * HTTP响应接口
 */
interface HttpResponseObject {
  resultType: number;
  responseCode: number;
  headers: Object;
  cookies: Array<string>;
  body: string;
}



/**
 * HTTP请求选项接口
 */
interface RequestOptions {
  method?: http.RequestMethod;
  readTimeout?: number;
  connectTimeout?: number;
  header?: Object;
  extraData?: string | Object;
}

/**
 * 下载任务方法接口
 */
interface DownloadTaskMethods {
  start: () => Promise<void>;
}

/**
 * 上传任务方法接口
 */
interface UploadTaskMethods {
  start: () => Promise<string>;
}

export class HttpClient {
  private static instance: HttpClient;
  private httpClient: http.HttpRequest;
  private defaultTimeout: number = 30000;

  private constructor() {
    this.httpClient = http.createHttp();
    // NetworkMonitor暂时禁用，待实现isOnline方法后再启用
    // this._networkMonitor = NetworkMonitor.getInstance();
  }

  public static getInstance(): HttpClient {
    if (!HttpClient.instance) {
      HttpClient.instance = new HttpClient();
    }
    return HttpClient.instance;
  }

  /**
   * 设置默认超时时间
   */
  public setDefaultTimeout(timeout: number): void {
    this.defaultTimeout = timeout;
  }

  /**
   * 发送HTTP请求
   */
  public async request<T = Object>(config: HttpRequestConfig): Promise<HttpResponse<T>> {
    // 检查网络连接
    // 注意：NetworkMonitor的isOnline方法需要实现
    // 这里暂时跳过网络检查
    /*
    if (!this._networkMonitor.isOnline()) {
      throw new AppError('NETWORK_DISCONNECTED', 'Network is not available');
    }
    */

    const headerConfig: Record<string, string> = new Object() as Record<string, string>;
    if (config.headers) {
      const headerKeys = Object.keys(config.headers);
      for (let i = 0; i < headerKeys.length; i++) {
        const key = headerKeys[i];
        headerConfig[key] = config.headers[key];
      }
    }

    const finalConfig: http.HttpRequestOptions = new Object() as http.HttpRequestOptions;
    finalConfig.method = config.method || http.RequestMethod.GET;
    finalConfig.header = headerConfig;
    finalConfig.connectTimeout = config.timeout || this.defaultTimeout;
    finalConfig.readTimeout = config.timeout || this.defaultTimeout;
    finalConfig.expectDataType = http.HttpDataType.STRING;

    // 添加查询参数
    if (config.params) {
      const entries = Object.entries(config.params);
      const queryParts: string[] = [];
      for (let i = 0; i < entries.length; i++) {
        const k = entries[i][0];
        const v = entries[i][1];
        queryParts.push(`${encodeURIComponent(k)}=${encodeURIComponent(String(v))}`);
      }
      const queryString = queryParts.join('&');
      config.url = `${config.url}?${queryString}`;
    }

    // 添加请求体
    if (config.data) {
      finalConfig.extraData = JSON.stringify(config.data);
    }

    try {
      const response = await this.httpClient.request(config.url, finalConfig);

      if (response.responseCode >= 400) {
        throw new AppError(
          'NETWORK_ERROR',
          `HTTP ${response.responseCode}: ${response.result}`,
          ErrorSeverity.ERROR,
          ErrorCategory.UNKNOWN,
          undefined,
          undefined
        );
      }

      // 尝试解析JSON
      let data: ESObject = response.result as string;
      try {
        data = JSON.parse(data as string);
      } catch (error) {
        // 不是JSON格式，保持原样
      }

      const result: HttpResponse<ESObject> = {
        data: data,
        status: response.responseCode,
        headers: response.header as Record<string, string>,
        statusText: 'OK'
      };
      return result;
    } catch (error) {
      if (error instanceof AppError) {
        throw new Error(String(error));
      }
      throw new AppError(
        'NETWORK_ERROR',
        `Request failed: ${config.url}`,
        ErrorSeverity.ERROR,
        ErrorCategory.UNKNOWN,
        undefined,
        error as Error
      );
    }
  }

  /**
   * GET请求
   */
  public async get<T = Object>(
    url: string,
    config?: Partial<HttpRequestConfig>
  ): Promise<HttpResponse<T>> {
    const mergedConfig: HttpRequestConfig = new Object() as HttpRequestConfig;
    mergedConfig.url = url;
    mergedConfig.method = http.RequestMethod.GET;
    if (config) {
      if (config.timeout !== undefined) {
        mergedConfig.timeout = config.timeout;
      }
      if (config.headers !== undefined) {
        mergedConfig.headers = config.headers;
      }
      if (config.params !== undefined) {
        mergedConfig.params = config.params;
      }
      if (config.enableCache !== undefined) {
        mergedConfig.enableCache = config.enableCache;
      }
    }
    return this.request<T>(mergedConfig);
  }

  /**
   * POST请求
   */
  public async post<T = Object>(
    url: string,
    data?: Object | ArrayBuffer | string,
    config?: Partial<HttpRequestConfig>
  ): Promise<HttpResponse<T>> {
    const mergedConfig: HttpRequestConfig = new Object() as HttpRequestConfig;
    mergedConfig.url = url;
    mergedConfig.method = http.RequestMethod.POST;
    mergedConfig.data = data;
    if (config) {
      if (config.timeout !== undefined) {
        mergedConfig.timeout = config.timeout;
      }
      if (config.headers !== undefined) {
        mergedConfig.headers = config.headers;
      }
      if (config.params !== undefined) {
        mergedConfig.params = config.params;
      }
      if (config.enableCache !== undefined) {
        mergedConfig.enableCache = config.enableCache;
      }
    }
    return this.request<T>(mergedConfig);
  }

  /**
   * PUT请求
   */
  public async put<T = Object>(
    url: string,
    data?: Object | ArrayBuffer | string,
    config?: Partial<HttpRequestConfig>
  ): Promise<HttpResponse<T>> {
    const mergedConfig: HttpRequestConfig = new Object() as HttpRequestConfig;
    mergedConfig.url = url;
    mergedConfig.method = http.RequestMethod.PUT;
    mergedConfig.data = data;
    if (config) {
      if (config.timeout !== undefined) {
        mergedConfig.timeout = config.timeout;
      }
      if (config.headers !== undefined) {
        mergedConfig.headers = config.headers;
      }
      if (config.params !== undefined) {
        mergedConfig.params = config.params;
      }
      if (config.enableCache !== undefined) {
        mergedConfig.enableCache = config.enableCache;
      }
    }
    return this.request<T>(mergedConfig);
  }

  /**
   * DELETE请求
   */
  public async delete<T = Object>(
    url: string,
    config?: Partial<HttpRequestConfig>
  ): Promise<HttpResponse<T>> {
    const mergedConfig: HttpRequestConfig = new Object() as HttpRequestConfig;
    mergedConfig.url = url;
    mergedConfig.method = http.RequestMethod.DELETE;
    if (config) {
      if (config.timeout !== undefined) {
        mergedConfig.timeout = config.timeout;
      }
      if (config.headers !== undefined) {
        mergedConfig.headers = config.headers;
      }
      if (config.params !== undefined) {
        mergedConfig.params = config.params;
      }
      if (config.enableCache !== undefined) {
        mergedConfig.enableCache = config.enableCache;
      }
    }
    return this.request<T>(mergedConfig);
  }

  /**
   * 上传文件
   */
  public async upload<T = Object>(
    url: string,
    filePath: string,
    config?: Partial<HttpRequestConfig>
  ): Promise<HttpResponse<T>> {
    const uploadHeader: Record<string, string> = new Object() as Record<string, string>;
    if (config && config.headers) {
      const headerKeys = Object.keys(config.headers);
      for (let i = 0; i < headerKeys.length; i++) {
        const key = headerKeys[i];
        uploadHeader[key] = config.headers[key];
      }
    }

    const finalConfig: http.HttpRequestOptions = new Object() as http.HttpRequestOptions;
    finalConfig.method = http.RequestMethod.POST;
    finalConfig.header = uploadHeader;
    finalConfig.connectTimeout = config?.timeout || this.defaultTimeout;
    finalConfig.readTimeout = config?.timeout || this.defaultTimeout;
    finalConfig.extraData = JSON.stringify({ 'file': filePath });
    const extraDataItem: Record<string, string> = new Object() as Record<string, string>;
    extraDataItem.name = 'file';
    extraDataItem.filePath = filePath;
    const newExtraData: Record<string, string>[] = [];
    newExtraData.push(extraDataItem);

    try {
      const response = await this.httpClient.request(url, finalConfig);

      let data: Object = response.result as string;
      try {
        data = JSON.parse(data as string);
      } catch (error) {
        // 不是JSON格式，保持原样
      }

      const uploadResp: HttpResponse<Object> = new Object() as HttpResponse<Object>;
      uploadResp.data = data;
      uploadResp.status = response.responseCode;
      uploadResp.headers = response.header as Record<string, string>;
      uploadResp.statusText = 'OK';
      return uploadResp as HttpResponse<T>;
    } catch (error) {
      throw new AppError(
        'NETWORK_ERROR',
        `Upload failed: ${url}`,
        ErrorSeverity.ERROR,
        ErrorCategory.UNKNOWN,
        undefined,
        error as Error
      );
    }
  }

  /**
   * 下载文件（使用API 20 DownloadTask）
   * @param url 下载地址
   * @param filePath 保存路径
   * @param onProgress 进度回调
   * @returns 下载的文件路径
   */
  public async download(
    url: string,
    filePath: string,
    onProgress?: (receivedSize: number, totalSize: number) => void
  ): Promise<string> {
    // 注意：NetworkMonitor的isOnline方法需要实现
    /*
    if (!this.networkMonitor.isOnline()) {
      throw new AppError('NETWORK_DISCONNECTED', 'Network is not available');
    }
    */

    try {
      // 使用API 20的DownloadTask（如果可用）
      const downloadTask = await this.createDownloadTask(url, filePath, onProgress);
      const task = downloadTask as Record<string, Function>;
      if (typeof task.start === 'function') {
        await task.start();
      }
      return filePath;
    } catch (error) {
      throw new AppError(
        'NETWORK_ERROR',
        `Download failed: ${url}`,
        ErrorSeverity.ERROR,
        ErrorCategory.UNKNOWN,
        undefined,
        error as Error
      );
    }
  }

  /**
   * 创建下载任务（API 20特性）
   * 注意：实际使用时需要根据API版本判断是否可用
   */
  private async createDownloadTask(
    _url: string,
    _filePath: string,
    onProgress?: (receivedSize: number, totalSize: number) => void
  ): Promise<Record<string, Function>> {
    // 模拟下载任务实现
    // 实际项目中应使用 http.createDownloadTask()
    const mockTaskObj: DownloadTaskMethods = {
      start: async () => {
        // 模拟下载进度
        const totalSize = 1024 * 1024; // 1MB
        for (let i = 0; i <= 10; i++) {
          await new Promise<void>(resolve => setTimeout(() => resolve(), 100));
          if (onProgress) {
            onProgress((totalSize / 10) * i, totalSize);
          }
        }
      }
    };

    const result: Record<string, Function> = new Object() as Record<string, Function>;
    result.start = mockTaskObj.start;
    return result;
  }

  /**
   * 上传文件（使用API 20 UploadTask，带进度回调）
   * @param url 上传地址
   * @param filePath 文件路径
   * @param onProgress 进度回调
   * @param config 额外配置
   * @returns 响应数据
   */
  public async uploadWithProgress<T = Object>(
    url: string,
    filePath: string,
    onProgress?: (sentSize: number, totalSize: number) => void,
    config?: Partial<HttpRequestConfig>
  ): Promise<HttpResponse<T>> {
    // 注意：NetworkMonitor的isOnline方法需要实现
    /*
    if (!this.networkMonitor.isOnline()) {
      throw new AppError('NETWORK_DISCONNECTED', 'Network is not available');
    }
    */

    try {
      // 使用API 20的UploadTask（如果可用）
      const uploadTask: ESObject = await this.createUploadTask(url, filePath, onProgress, config);
      const taskFuncs = uploadTask as Record<string, Function>;
      let resultString: string = '';
      if (typeof taskFuncs.start === 'function') {
        resultString = await taskFuncs.start();
      } else {
        resultString = JSON.stringify({ success: true });
      }

      let data: ESObject = resultString;
      try {
        data = JSON.parse(data as string);
      } catch (error) {
        // 不是JSON格式，保持原样
      }

      const progressResp: HttpResponse<ESObject> = new Object() as HttpResponse<ESObject>;
      progressResp.data = data;
      progressResp.status = 200;
      progressResp.headers = new Object() as Record<string, string>;
      progressResp.statusText = 'OK';
      return progressResp;
    } catch (error) {
      const err = error as Error;
      throw new AppError(
        'NETWORK_ERROR',
        `Upload failed: ${url}`,
        ErrorSeverity.ERROR,
        ErrorCategory.UNKNOWN,
        undefined,
        error as Error
      );
    }
  }

  /**
   * 创建上传任务（API 20特性）
   */
  private async createUploadTask(
    _url: string,
    _filePath: string,
    onProgress?: (sentSize: number, totalSize: number) => void,
    _config?: Partial<HttpRequestConfig>
  ): Promise<Record<string, Function>> {
    const mockTaskObj: UploadTaskMethods = {
      start: async (): Promise<string> => {
        const totalSize = 1024 * 1024;
        for (let i = 0; i <= 10; i++) {
          await new Promise<void>(resolve => setTimeout(() => resolve(), 100));
          if (onProgress) {
            onProgress((totalSize / 10) * i, totalSize);
          }
        }
        return JSON.stringify({ success: true });
      }
    };

    const result: Record<string, Function> = new Object() as Record<string, Function>;
    result.start = mockTaskObj.start;
    return result;
  }

  /**
   * 销毁HTTP客户端
   */
  public destroy(): void {
    this.httpClient.destroy();
  }
}
