// library/utils/src/main/ets/module/ModuleStateMachine.ets
import { DynamicModuleManager } from './DynamicModuleManager';

export type ModuleState = 'loading' | 'loaded' | 'unloading' | 'updating' | 'updated' | 'error';

export class ModuleStateMachine {
  private static instance: ModuleStateMachine;
  private stateTransitions: Map<ModuleState, ModuleState[]> = new Map();
  
  private constructor() {
    this.initializeTransitions();
  }
  
  static getInstance(): ModuleStateMachine {
    if (!ModuleStateMachine.instance) {
      ModuleStateMachine.instance = new ModuleStateMachine();
    }
    return ModuleStateMachine.instance;
  }
  
  private initializeTransitions(): void {
    this.stateTransitions.set('loading', ['loaded', 'error']);
    this.stateTransitions.set('loaded', ['unloading', 'updating']);
    this.stateTransitions.set('unloading', ['loaded']);
    this.stateTransitions.set('updating', ['updated', 'error']);
    this.stateTransitions.set('updated', ['loaded']);
    this.stateTransitions.set('error', ['loading', 'unloading']);
  }
  
  isValidTransition(currentState: ModuleState, nextState: ModuleState): boolean {
    const validTransitions = this.stateTransitions.get(currentState) || [];
    return validTransitions.includes(nextState);
  }
  
  async transitionModuleState(
    moduleName: string, 
    targetState: ModuleState
  ): Promise<boolean> {
    const currentState = DynamicModuleManager.getInstance().getModuleState(moduleName);
    
    if (!currentState) {
      console.error(`模块 ${moduleName} 当前状态未知`);
      return false;
    }
    
    if (!this.isValidTransition(currentState, targetState)) {
      console.error(`无效的状态转换: ${currentState} -> ${targetState}`);
      return false;
    }
    
    try {
      switch (targetState) {
        case 'loading':
          await DynamicModuleManager.getInstance().loadModule(moduleName);
          break;
        case 'unloading':
          DynamicModuleManager.getInstance().unloadModule(moduleName);
          break;
        case 'updating':
          await DynamicModuleManager.getInstance().updateModule(moduleName, 'latest');
          break;
        default:
          DynamicModuleManager.getInstance().updateModuleState(moduleName, targetState);
      }
      
      return true;
    } catch (error) {
      console.error(`状态转换失败: ${error}`);
      DynamicModuleManager.getInstance().updateModuleState(moduleName, 'error');
      return false;
    }
  }
  
  getAvailableTransitions(currentState: ModuleState): ModuleState[] {
    return this.stateTransitions.get(currentState) || [];
  }
}