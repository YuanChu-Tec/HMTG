import { AppError, ErrorSeverity, ErrorCategory } from '../error/AppError';
import { DynamicModuleLoader } from './DynamicModuleLoader';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'ModuleDependencyResolver';
const DOMAIN = 0x0001;

/**
 * 依赖图
 */
interface DependencyGraph {
  nodes: Map<string, Set<string>>;
}

/**
 * 模块依赖解析器
 */
export class ModuleDependencyResolver {
  private static instance: ModuleDependencyResolver;
  private moduleLoader: DynamicModuleLoader;
  private dependencyGraph: DependencyGraph;

  private constructor() {
    this.dependencyGraph = new Object() as DependencyGraph;
    this.dependencyGraph.nodes = new Map();
    this.moduleLoader = DynamicModuleLoader.getInstance();
  }

  public static getInstance(): ModuleDependencyResolver {
    if (!ModuleDependencyResolver.instance) {
      ModuleDependencyResolver.instance = new ModuleDependencyResolver();
    }
    return ModuleDependencyResolver.instance;
  }

  /**
   * 注册模块依赖关系
   */
  public registerDependencies(moduleName: string, dependencies: string[]): void {
    this.dependencyGraph.nodes.set(moduleName, new Set(dependencies));
    hilog.info(DOMAIN, TAG, `Registered dependencies for ${moduleName}: ${dependencies.join(', ')}`);
  }

  /**
   * 解析模块加载顺序（拓扑排序）
   */
  public resolveLoadOrder(moduleNames: string[]): string[] {
    const visited = new Set<string>();
    const visiting = new Set<string>();
    const order: string[] = [];

    const visit = (moduleName: string): void => {
      if (visited.has(moduleName)) {
        return;
      }

      if (visiting.has(moduleName)) {
        throw new AppError(
          'OPERATION_FAILED',
          `Circular dependency detected: ${moduleName}`,
          ErrorSeverity.ERROR,
          ErrorCategory.UNKNOWN,
          undefined,
          undefined
        );
      }

      visiting.add(moduleName);

      const dependencies = this.dependencyGraph.nodes.get(moduleName);
      if (dependencies) {
        dependencies.forEach(dep => {
          visit(dep);
        });
      }

      visiting.delete(moduleName);
      visited.add(moduleName);
      order.push(moduleName);
    };

    moduleNames.forEach(name => visit(name));
    
    hilog.info(DOMAIN, TAG, `Resolved load order: ${order.join(' -> ')}`);
    
    return order;
  }

  /**
   * 加载模块及其所有依赖
   */
  public async loadWithDependencies(
    moduleName: string,
    modulePath: string,
    dependencyMap: Map<string, string>
  ): Promise<Object | undefined> {
    // 注册所有依赖
    dependencyMap.forEach((depPath: string) => {
      this.registerDependencies(moduleName, [depPath]);
    });

    // 解析加载顺序
    const allModules = [moduleName, ...Array.from(dependencyMap.keys())];
    const loadOrder = this.resolveLoadOrder(allModules);

    // 按顺序加载所有模块
    const loadedModules = new Map<string, Object>();
    for (const name of loadOrder) {
      if (name === moduleName) {
        const result = await this.moduleLoader.loadModule(name, modulePath);
        if (result) {
          loadedModules.set(name, result);
        }
      } else {
        const depPath = dependencyMap.get(name);
        if (depPath) {
          const result = await this.moduleLoader.loadModule(name, depPath);
          if (result) {
            loadedModules.set(name, result);
          }
        }
      }
    }

    return loadedModules.get(moduleName);
  }

  /**
   * 检查循环依赖
   */
  public checkCircularDependency(): string[] | null {
    const visited = new Set<string>();
    const visiting = new Set<string>();
    const cycles: string[] = [];

    const findCycle = (moduleName: string, path: string[]): boolean => {
      if (visited.has(moduleName)) {
        return false;
      }

      if (visiting.has(moduleName)) {
        const cycleIndex = path.indexOf(moduleName);
        cycles.push(...path.slice(cycleIndex).concat(moduleName));
        return true;
      }

      visiting.add(moduleName);

      const dependencies = this.dependencyGraph.nodes.get(moduleName);
      if (dependencies) {
        for (const dep of dependencies) {
          if (findCycle(dep, [...path, moduleName])) {
            return true;
          }
        }
      }

      visiting.delete(moduleName);
      visited.add(moduleName);
      return false;
    };

    for (const moduleName of this.dependencyGraph.nodes.keys()) {
      if (findCycle(moduleName, [])) {
        return cycles;
      }
    }

    return null;
  }

  /**
   * 获取模块的所有依赖（包括传递依赖）
   */
  public getAllDependencies(moduleName: string): Set<string> {
    const dependencies = new Set<string>();

    const collect = (name: string): void => {
      const deps = this.dependencyGraph.nodes.get(name);
      if (deps) {
        deps.forEach(dep => {
          if (!dependencies.has(dep)) {
            dependencies.add(dep);
            collect(dep);
          }
        });
      }
    };

    collect(moduleName);
    return dependencies;
  }

  /**
   * 获取依赖此模块的所有模块
   */
  public getDependents(moduleName: string): Set<string> {
    const dependents = new Set<string>();

    for (const entry of this.dependencyGraph.nodes.entries()) {
      const name: string = entry[0] as string;
      const deps: Set<string> = entry[1];
      if (deps.has(moduleName)) {
        dependents.add(name);
      }
    }

    return dependents;
  }

  /**
   * 清除依赖关系
   */
  public clearDependencies(moduleName?: string): void {
    if (moduleName) {
      this.dependencyGraph.nodes.delete(moduleName);
    } else {
      this.dependencyGraph.nodes.clear();
    }
  }

  /**
   * 获取依赖图信息
   */
  public getDependencyGraphInfo(): Map<string, string[]> {
    const info: Map<string, string[]> = new Map();

    this.dependencyGraph.nodes.forEach((deps, name) => {
      info.set(name, Array.from(deps));
    });

    return info;
  }
}
