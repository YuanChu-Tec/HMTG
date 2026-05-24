/**
 * NavigationHelper - 导航辅助工具
 * 封装路由和提示API，便于统一维护和升级
 * @module feature-privacy.utils
 */

import { router, promptAction } from '@kit.ArkUI';

/**
 * 导航选项（未来可用于替换RouterOptions）
 */
export interface NavigationOptions {
  url: string;
  params?: Record<string, Object>;
}

/**
 * Toast 选项（未来可用于替换 ShowToastOptions）
 */
export interface ToastOptions {
  message: string;
  duration?: number;
  bottom?: string | number;
}

/**
 * 返回选项
 */
export interface BackOptions {
  url?: string;
}

/**
 * 导航辅助类
 */
export class NavigationHelper {
  /**
   * 导航到指定页面
   * @param options 导航选项
   */
  static async navigateTo(options: NavigationOptions): Promise<void> {
    try {
      await router.pushUrl({
        url: options.url,
        params: options.params
      });
    } catch (error) {
      console.error('Navigation failed:', error);
      throw new Error(String(error));
    }
  }

  /**
   * 返回上一页
   * @param options 导航选项
   */
  static navigateBack(options?: BackOptions): void {
    try {
      router.back();
    } catch (error) {
      console.error('Navigation back failed:', error);
      throw new Error(String(error));
    }
  }

  /**
   * 显示Toast提示
   * @param options Toast选项
   */
  static showToast(options: ToastOptions): void {
    try {
      promptAction.showToast({
        message: options.message,
        duration: options.duration || 2000,
        bottom: options.bottom
      });
    } catch (error) {
      console.error('Show toast failed:', error);
      throw new Error(String(error));
    }
  }

  /**
   * 显示确认对话框
   * @param title 对话框标题
   * @param message 对话框内容
   * @param confirmText 确认按钮文本
   * @param cancelText 取消按钮文本
   * @returns Promise<boolean> 用户是否确认
   */
  static async showConfirmDialog(
    title: string,
    message: string,
    confirmText: string = '确定',
    cancelText: string = '取消'
  ): Promise<boolean> {
    return new Promise((resolve) => {
      promptAction.showDialog({
        title: title,
        message: message,
        buttons: [
          { text: cancelText, color: '#999999' },
          { text: confirmText, color: '#007AFF' }
        ]
      }, (err, data) => {
        if (data && data.index === 1) {
          resolve(true);
        } else {
          resolve(false);
        }
      });
    });
  }

  /**
   * 显示警告对话框
   * @param title 对话框标题
   * @param message 对话框内容
   * @param confirmText 确认按钮文本
   * @returns Promise<boolean> 用户是否确认
   */
  static async showAlertDialog(
    title: string,
    message: string,
    confirmText: string = '确定'
  ): Promise<boolean> {
    return new Promise((resolve) => {
      promptAction.showDialog({
        title: title,
        message: message,
        buttons: [
          { text: confirmText, color: '#FF3B30' }
        ]
      }, (err, data) => {
        resolve(true);
      });
    });
  }

  /**
   * 获取页面参数
   * @returns 页面参数对象
   */
  static getPageParams(): Record<string, Object> {
    try {
      return router.getParams() as Record<string, Object>;
    } catch (error) {
      console.error('Get page params failed:', error);
      return {};
    }
  }
}
