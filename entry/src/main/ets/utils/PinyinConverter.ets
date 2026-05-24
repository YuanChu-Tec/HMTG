/**
 * 中文拼音转换工具
 * 使用 @ohos/pinyin4js 三方库实现
 * @module feature-contacts.utils
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { pinyin4js } from '@ohos/pinyin4js';

const TAG = 'PinyinConverter';
const DOMAIN = 0x0001;

/**
 * 中文拼音转换器
 * 基于 @ohos/pinyin4js 库，提供完整的汉字到拼音转换功能
 */
export class PinyinConverter {
  private static instance: PinyinConverter;

  static getInstance(): PinyinConverter {
    if (!PinyinConverter.instance) {
      PinyinConverter.instance = new PinyinConverter();
    }
    return PinyinConverter.instance;
  }

  /**
   * 将汉字转换为拼音
   * @param char 单个汉字或字符串
   * @param tone 是否包含声调（默认不包含）
   * @returns 拼音，如果是非汉字返回原字符
   */
  charToPinyin(char: string, tone: boolean = false): string {
    try {
      const toneType: number = tone ? pinyin4js.WITH_TONE_MARK : pinyin4js.WITHOUT_TONE;
      const pinyin: string = pinyin4js.convertToPinyinString(char, '', toneType);

      return pinyin || char;
    } catch (error) {
      hilog.warn(DOMAIN, TAG, `拼音转换失败: ${char}, 错误: ${error}`);
      return char;
    }
  }

  /**
   * 将汉字字符串转换为拼音
   * @param text 汉字字符串
   * @param tone 是否包含声调
   * @returns 拼音字符串
   */
  textToPinyin(text: string, tone: boolean = false): string {
    try {
      const toneType: number = tone ? pinyin4js.WITH_TONE_MARK : pinyin4js.WITHOUT_TONE;
      const pinyin: string = pinyin4js.convertToPinyinString(text, ' ', toneType);

      return pinyin || text;
    } catch (error) {
      hilog.warn(DOMAIN, TAG, `拼音转换失败: ${text}, 错误: ${error}`);
      return text;
    }
  }

  /**
   * 获取汉字的首字母
   * @param char 单个汉字或字符串
   * @returns 拼音首字母大写，非汉字返回 #
   */
  getFirstLetter(char: string): string {
    try {
      const result: string = pinyin4js.convertToPinyinString(char, '', pinyin4js.FIRST_LETTER);

      // 去除所有非字母字符，只保留首字母
      const firstLetter: string = result.replace(/[^a-zA-Z]/g, '');

      return firstLetter.length > 0 ? firstLetter[0].toUpperCase() : '#';
    } catch (error) {
      hilog.warn(DOMAIN, TAG, `获取首字母失败: ${char}, 错误: ${error}`);
      return '#';
    }
  }

  /**
   * 获取字符串的首字母（用于排序）
   * @param text 汉字或英文字符串
   * @returns 首字母大写
   */
  getTextFirstLetter(text: string): string {
    if (!text || text.length === 0) {
      return '#';
    }

    const firstChar = text.trim()[0];

    // 如果是英文字母
    if (/^[a-zA-Z]$/.test(firstChar)) {
      return firstChar.toUpperCase();
    }

    // 如果是汉字，使用 pinyin4js 获取首字母
    try {
      const result: string = pinyin4js.convertToPinyinString(firstChar, '', pinyin4js.FIRST_LETTER);
      const firstLetter: string = result.replace(/[^a-zA-Z]/g, '');

      return firstLetter.length > 0 ? firstLetter[0].toUpperCase() : '#';
    } catch (error) {
      hilog.warn(DOMAIN, TAG, `获取首字母失败: ${firstChar}, 错误: ${error}`);
      return '#';
    }
  }

  /**
   * 获取字符串的拼音（用于排序）
   * @param text 文本
   * @returns 拼音字符串（小写）
   */
  getPinyinForSort(text: string): string {
    try {
      const pinyin: string = pinyin4js.convertToPinyinString(text, ' ', pinyin4js.WITHOUT_TONE);

      return pinyin ? pinyin.toLowerCase() : text.toLowerCase();
    } catch (error) {
      hilog.warn(DOMAIN, TAG, `获取拼音失败: ${text}, 错误: ${error}`);
      return text.toLowerCase();
    }
  }

  /**
   * 获取带声调的拼音
   * @param text 文本
   * @returns 带声调的拼音
   */
  getPinyinWithTone(text: string): string {
    return this.textToPinyin(text, true);
  }

  /**
   * 检查是否是中文字符
   * @param char 字符
   * @returns 是否是汉字
   */
  isChineseChar(char: string): boolean {
    return /^[\u4e00-\u9fa5]$/.test(char);
  }

  /**
   * 批量获取拼音（优化性能）
   * @param texts 文本数组
   * @param tone 是否包含声调
   * @returns 拼音数组
   */
  batchGetPinyin(texts: string[], tone: boolean = false): string[] {
    return texts.map(text => this.textToPinyin(text, tone));
  }

  /**
   * 批量获取首字母（优化性能）
   * @param texts 文本数组
   * @returns 首字母数组
   */
  batchGetFirstLetter(texts: string[]): string[] {
    return texts.map(text => this.getTextFirstLetter(text));
  }
}

/**
 * 导出单例
 */
export const pinyinConverter = PinyinConverter.getInstance();
