import { AppError, ErrorSeverity, ErrorCategory } from '../error/AppError';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'DynamicModuleLoader';
const DOMAIN = 0x0001;

/**
 * 模块加载状态
 */
export enum ModuleLoadStatus {
  IDLE = 'idle',
  LOADING = 'loading',
  LOADED = 'loaded',
  FAILED = 'failed'
}

/**
 * 模块信息
 */
export interface ModuleInfo {
  name: string;
  version: string;
  status: ModuleLoadStatus;
  module?: Object;
  error?: Error;
  dependencies?: string[];
}

/**
 * 动态模块加载器
 */
/**
 * 模块配置接口
 */
export interface ModuleConfig {
  name: string;
  path: string;
}

// Event interface definitions
interface ESModule {
  default?: Object;
}


export class DynamicModuleLoader {
  private static instance: DynamicModuleLoader;
  private modules: Map<string, ModuleInfo> = new Map();
  private loadCallbacks: Map<string, Set<Function>> = new Map();
  private maxConcurrentLoads: number = 3;
  private currentLoads: number = 0;

  private constructor() {}

  public static getInstance(): DynamicModuleLoader {
    if (!DynamicModuleLoader.instance) {
      DynamicModuleLoader.instance = new DynamicModuleLoader();
    }
    return DynamicModuleLoader.instance;
  }

  /**
   * 加载模块
   */
  public async loadModule(name: string, modulePath: string): Promise<Object> {
    // 检查是否已加载
    const existingModule = this.modules.get(name);
    if (existingModule && existingModule.status === ModuleLoadStatus.LOADED) {
      if (existingModule.module) {
        return existingModule.module;
      }
      return new Object();
    }

    // 检查是否正在加载
    if (existingModule && existingModule.status === ModuleLoadStatus.LOADING) {
      return new Promise<Object>((resolve, reject) => {
        this.addLoadCallback(name, resolve, reject);
      });
    }

    // 检查并发加载限制
    if (this.currentLoads >= this.maxConcurrentLoads) {
      await this.waitForLoadSlot();
    }

    // 开始加载
    this.currentLoads++;
    const moduleInfo: ModuleInfo = new Object() as ModuleInfo;
    moduleInfo.name = name;
    moduleInfo.version = '1.0.0';
    moduleInfo.status = ModuleLoadStatus.LOADING;
    this.modules.set(name, moduleInfo);

    try {
      hilog.info(DOMAIN, TAG, `Loading module: ${name} from ${modulePath}`);

      // 动态导入模块
      const module: ESModule = await import(modulePath);
      const defaultModule = module.default;
      let moduleObj: Record<string, Object>;
      if (defaultModule !== undefined && defaultModule !== null) {
        moduleObj = defaultModule as Record<string, Object>;
      } else {
        moduleObj = {};
      }

      moduleInfo.status = ModuleLoadStatus.LOADED;
      moduleInfo.module = moduleObj;

      hilog.info(DOMAIN, TAG, `Module loaded successfully: ${name}`);

      // 触发回调
      this.triggerLoadCallbacks(name, moduleObj, null);

      return moduleObj;
    } catch (error) {
      moduleInfo.status = ModuleLoadStatus.FAILED;
      moduleInfo.error = error as Error;

      hilog.error(DOMAIN, TAG, `Failed to load module: ${name}, error: ${error}`);

      // 触发回调
      this.triggerLoadCallbacks(name, null, error as Error);

      throw new AppError(
        'OPERATION_FAILED',
        `Failed to load module: ${name}`,
        ErrorSeverity.ERROR,
        ErrorCategory.UNKNOWN,
        undefined,
        error as Error
      );
    } finally {
      this.currentLoads--;
    }
  }

  /**
   * 批量加载模块
   */
  public async loadModules(modules: ModuleConfig[]): Promise<Record<string, Object>> {
    const result: Record<string, Object> = {};
    for (let i = 0; i < modules.length; i++) {
      const config = modules[i];
      const module = await this.loadModule(config.name, config.path);
      result[config.name] = module;
    }

    return result;
  }

  /**
   * 卸载模块
   */
  public unloadModule(name: string): void {
    const moduleInfo = this.modules.get(name);
    if (!moduleInfo) {
      return;
    }

    // 清理模块引用
    moduleInfo.module = undefined;
    moduleInfo.status = ModuleLoadStatus.IDLE;
    moduleInfo.error = undefined;
    
    // 清理回调
    this.loadCallbacks.delete(name);
    
    hilog.info(DOMAIN, TAG, `Module unloaded: ${name}`);
  }

  /**
   * 获取模块信息
   */
  public getModuleInfo(name: string): ModuleInfo | undefined {
    return this.modules.get(name);
  }

  /**
   * 获取所有模块信息
   */
  public getAllModuleInfo(): Map<string, ModuleInfo> {
    return new Map(this.modules);
  }

  /**
   * 检查模块是否已加载
   */
  public isModuleLoaded(name: string): boolean {
    const moduleInfo = this.modules.get(name);
    return moduleInfo?.status === ModuleLoadStatus.LOADED;
  }

  /**
   * 添加加载回调
   */
  private addLoadCallback(name: string, resolve: Function, reject: Function): void {
    if (!this.loadCallbacks.has(name)) {
      this.loadCallbacks.set(name, new Set<Function>());
    }
    this.loadCallbacks.get(name)?.add((module: Object | null, error: Error | null) => {
      if (error) {
        reject(error);
      } else {
        resolve(module);
      }
    });
  }

  /**
   * 触发加载回调
   */
  private triggerLoadCallbacks(name: string, module: Object | null, error: Error | null): void {
    const callbacks = this.loadCallbacks.get(name);
    if (!callbacks) {
      return;
    }

    callbacks.forEach(callback => {
      try {
        callback(module, error);
      } catch (err) {
        hilog.error(DOMAIN, TAG, `Callback error: ${err}`);
      }
    });

    this.loadCallbacks.delete(name);
  }

  /**
   * 等待加载槽位
   */
  private async waitForLoadSlot(): Promise<void> {
    return new Promise(resolve => {
      const check = () => {
        if (this.currentLoads < this.maxConcurrentLoads) {
          resolve();
        } else {
          setTimeout(check, 100);
        }
      };
      check();
    });
  }

  /**
   * 设置最大并发加载数
   */
  public setMaxConcurrentLoads(max: number): void {
    this.maxConcurrentLoads = Math.max(1, max);
  }

  /**
   * 清除所有模块
   */
  public clearAll(): void {
    this.modules.clear();
    this.loadCallbacks.clear();
  }
}
