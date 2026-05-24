/**
 * DataCrypto - 数据加密工具
 * 使用 HarmonyOS 官方 cryptoFramework 进行 AES-256-GCM 加密
 * @module feature-privacy.utils
 */

import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { BusinessError } from '@ohos.base';

/**
 * 加密结果
 */
export interface EncryptResult {
  cipherText: Uint8Array;
  iv: Uint8Array;
  authTag: Uint8Array;
}

/**
 * Base64 编码结果
 */
export interface Base64Result {
  cipherTextBase64: string;
  ivBase64: string;
  authTagBase64: string;
}

/**
 * 字符串编码工具类（替代 TextEncoder/TextDecoder）
 */
class StringEncoder {
  /**
   * 将字符串转换为 Uint8Array（UTF-8编码）
   */
  public encode(input: string): Uint8Array {
    const utf8: number[] = [];
    for (let i = 0; i < input.length; i++) {
      let charCode = input.charCodeAt(i);
      if (charCode < 0x80) {
        utf8.push(charCode);
      } else if (charCode < 0x800) {
        utf8.push(0xc0 | (charCode >> 6));
        utf8.push(0x80 | (charCode & 0x3f));
      } else if (charCode < 0xd800 || charCode >= 0xe000) {
        utf8.push(0xe0 | (charCode >> 12));
        utf8.push(0x80 | ((charCode >> 6) & 0x3f));
        utf8.push(0x80 | (charCode & 0x3f));
      } else {
        i++;
        charCode = 0x10000 + (((charCode & 0x3ff) << 10) | (input.charCodeAt(i) & 0x3ff));
        utf8.push(0xf0 | (charCode >> 18));
        utf8.push(0x80 | ((charCode >> 12) & 0x3f));
        utf8.push(0x80 | ((charCode >> 6) & 0x3f));
        utf8.push(0x80 | (charCode & 0x3f));
      }
    }
    return new Uint8Array(utf8);
  }
}

/**
 * 字符串解码工具类
 */
class StringDecoder {
  /**
   * 将 Uint8Array 转换为字符串（UTF-8解码）
   */
  public decode(input: Uint8Array): string {
    let result = '';
    let i = 0;
    while (i < input.length) {
      const byte1 = input[i++];
      if (byte1 < 0x80) {
        result += String.fromCharCode(byte1);
      } else if (byte1 >= 0xc0 && byte1 < 0xe0) {
        const byte2 = input[i++];
        result += String.fromCharCode(((byte1 & 0x1f) << 6) | (byte2 & 0x3f));
      } else if (byte1 >= 0xe0 && byte1 < 0xf0) {
        const byte2 = input[i++];
        const byte3 = input[i++];
        result += String.fromCharCode(((byte1 & 0x0f) << 12) | ((byte2 & 0x3f) << 6) | (byte3 & 0x3f));
      } else {
        const byte2 = input[i++];
        const byte3 = input[i++];
        const byte4 = input[i++];
        const codepoint = ((byte1 & 0x07) << 18) | ((byte2 & 0x3f) << 12) | ((byte3 & 0x3f) << 6) | (byte4 & 0x3f);
        result += String.fromCodePoint(codepoint);
      }
    }
    return result;
  }
}

// 创建编码器和解码器实例
const stringEncoder = new StringEncoder();
const stringDecoder = new StringDecoder();

/**
 * Base64编码工具
 */
function base64Encode(input: Uint8Array): string {
  const base64Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  let result = '';
  const bytes = input;

  for (let i = 0; i < bytes.length; i += 3) {
    const byte1 = bytes[i];
    const byte2 = i + 1 < bytes.length ? bytes[i + 1] : 0;
    const byte3 = i + 2 < bytes.length ? bytes[i + 2] : 0;

    const triplet = (byte1 << 16) | (byte2 << 8) | byte3;

    result += base64Chars.charAt((triplet >> 18) & 0x3f);
    result += base64Chars.charAt((triplet >> 12) & 0x3f);
    result += i + 1 < bytes.length ? base64Chars.charAt((triplet >> 6) & 0x3f) : '=';
    result += i + 2 < bytes.length ? base64Chars.charAt(triplet & 0x3f) : '=';
  }

  return result;
}

/**
 * Base64解码工具
 */
function base64Decode(input: string): Uint8Array {
  const base64Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  const lookup = new Uint8Array(256);
  for (let i = 0; i < base64Chars.length; i++) {
    lookup[base64Chars.charCodeAt(i)] = i;
  }

  // 移除填充
  let len = input.length;
  if (input.charAt(len - 1) === '=') len--;
  if (input.charAt(len - 1) === '=') len--;

  const bytes = new Uint8Array((len * 3) / 4);
  let p = 0;
  let encoded1 = 0;
  let encoded2 = 0;
  let encoded3 = 0;
  let encoded4 = 0;

  for (let i = 0; i < input.length; i++) {
    if (input.charAt(i) === '=') break;
    const encoded = lookup[input.charCodeAt(i)];
    if (encoded === 0) continue;

    switch (i % 4) {
      case 0:
        encoded1 = encoded;
        break;
      case 1:
        encoded2 = encoded;
        break;
      case 2:
        bytes[p++] = (encoded1 << 2) | ((encoded2 >> 4) & 0x3f);
        break;
      case 3:
        bytes[p++] = ((encoded2 & 0x0f) << 4) | ((encoded3 >> 2) & 0x3f);
        bytes[p++] = ((encoded3 & 0x03) << 6) | (encoded & 0x3f);
        break;
    }
    encoded3 = encoded4;
    encoded4 = encoded;
  }

  return bytes;
}

/**
 * 数据加密工具类
 * 使用官方 cryptoFramework API 实现 AES-GCM 加密
 */
export class DataCrypto {
  private static instance: DataCrypto;
  private key: cryptoFramework.SymKey | null = null;
  private keyData: Uint8Array | null = null;
  private base64Cache: Map<string, string> = new Map();
  private readonly MAX_CACHE_SIZE = 100;

  // 静态 Base64 字符表，避免重复创建
  private static readonly BASE64_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  private static readonly BASE64_LOOKUP = ((): Uint8Array => {
    const lookup = new Uint8Array(256);
    const chars = DataCrypto.BASE64_CHARS;
    for (let i = 0; i < chars.length; i++) {
      lookup[chars.charCodeAt(i)] = i;
    }
    return lookup;
  })();

  private constructor() {}

  public static getInstance(): DataCrypto {
    if (!DataCrypto.instance) {
      DataCrypto.instance = new DataCrypto();
    }
    return DataCrypto.instance;
  }

  /**
   * 初始化加密组件（生成密钥）
   * 使用官方 cryptoFramework API
   */
  public async initialize(): Promise<void> {
    try {
      // 使用官方 API 生成安全的随机密钥
      const random = cryptoFramework.createRandom();
      const keyBlob = await random.generateRandom(32);
      this.keyData = keyBlob.data;

      // 创建对称密钥对象
      const symKeyGenerator = cryptoFramework.createSymKeyGenerator('AES256');
      const keyDataBlob: cryptoFramework.DataBlob = { data: this.keyData };
      this.key = await symKeyGenerator.convertKey(keyDataBlob);

      console.info('DataCrypto initialized successfully');
    } catch (error) {
      const err = error as BusinessError;
      console.error('DataCrypto initialization failed:', err.message);
      throw new Error(String(error));
    }
  }

  /**
   * 加密数据
   * @param data 明文数据
   * @param authTagLen 认证标签长度（字节），默认 16 字节
   * @returns 加密结果，包含密文、IV 和认证标签
   */
  public async encryptData(data: Uint8Array, authTagLen: number = 16): Promise<EncryptResult> {
    if (!this.key) {
      throw new Error('DataCrypto not initialized');
    }

    try {
      // 使用官方 API 进行 AES-GCM 加密
      const cipher = cryptoFramework.createCipher('AES256|GCM|NoPadding');

      // 生成随机 IV
      const random = cryptoFramework.createRandom();
      const ivBlob = await random.generateRandom(12);
      const iv = ivBlob.data;

      // 初始化加密参数 - 使用 DataBlob 格式
      const ivSpec: cryptoFramework.GcmParamsSpec = {
        iv: { data: iv },
        authTag: { data: new Uint8Array(authTagLen) },
        aad: { data: new Uint8Array(0) },
        algName: 'AES/GCM/NoPadding'
      };

      await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, this.key, ivSpec);

      // 执行加密
      const input: cryptoFramework.DataBlob = { data: data };
      const encrypted = await cipher.doFinal(input);

      // 分离密文和认证标签
      const ciphertext = encrypted.data.subarray(0, encrypted.data.length - authTagLen);
      const authTag = encrypted.data.subarray(encrypted.data.length - authTagLen);

      return {
        cipherText: ciphertext,
        iv: iv,
        authTag: authTag
      };
    } catch (error) {
      const err = error as BusinessError;
      console.error('Failed to encrypt data:', err.message);
      throw new Error(String(error));
    }
  }

  /**
   * 解密数据
   * @param cipherText 密文数据
   * @param iv 初始化向量
   * @param authTag 认证标签
   * @returns 明文数据
   */
  public async decryptData(cipherText: Uint8Array, iv: Uint8Array, authTag: Uint8Array): Promise<Uint8Array> {
    if (!this.key) {
      throw new Error('DataCrypto not initialized');
    }

    try {
      // 使用官方 API 进行 AES-GCM 解密
      const cipher = cryptoFramework.createCipher('AES256|GCM|NoPadding');

      // 初始化解密参数 - 使用 DataBlob 格式
      const ivSpec: cryptoFramework.GcmParamsSpec = {
        iv: { data: iv },
        authTag: { data: authTag },
        aad: { data: new Uint8Array(0) },
        algName: 'AES/GCM/NoPadding'
      };

      await cipher.init(cryptoFramework.CryptoMode.DECRYPT_MODE, this.key, ivSpec);

      // 组合密文和认证标签
      const ciphertextWithTag = new Uint8Array(cipherText.length + authTag.length);
      ciphertextWithTag.set(cipherText);
      ciphertextWithTag.set(authTag, cipherText.length);

      // 执行解密
      const input: cryptoFramework.DataBlob = { data: ciphertextWithTag };
      const decrypted = await cipher.doFinal(input);

      return decrypted.data;
    } catch (error) {
      const err = error as BusinessError;
      console.error('Failed to decrypt data:', err.message);
      throw new Error(String(error));
    }
  }

  /**
   * Uint8Array 转 Base64 字符串（带缓存优化）
   */
  private uint8ArrayToBase64(uint8Array: Uint8Array): string {
    // 检查缓存
    const cacheKey = uint8Array.toString();
    const cached = this.base64Cache.get(cacheKey);
    if (cached !== undefined) {
      return cached;
    }

    const chars = DataCrypto.BASE64_CHARS;
    let result = '';
    let i = 0;
    const len = uint8Array.length;

    // 批量处理，减少循环次数
    while (i < len) {
      const a = uint8Array[i++];
      const b = i < len ? uint8Array[i++] : 0;
      const c = i < len ? uint8Array[i++] : 0;

      const bitmap = (a << 16) | (b << 8) | c;
      result += chars.charAt(bitmap >> 18);
      result += chars.charAt((bitmap >> 12) & 0x3F);
      result += i < len ? chars.charAt((bitmap >> 6) & 0x3F) : '=';
      result += i < len ? chars.charAt(bitmap & 0x3F) : '=';
    }

    // 缓存结果（限制缓存大小）
    if (this.base64Cache.size < this.MAX_CACHE_SIZE) {
      this.base64Cache.set(cacheKey, result);
    }

    return result;
  }

  /**
   * Base64 字符串转 Uint8Array（使用预计算的查找表）
   */
  private base64ToUint8Array(base64: string): Uint8Array {
    const base64Length = base64.length;
    const padding = base64.endsWith('==') ? 2 : base64.endsWith('=') ? 1 : 0;
    const length = (base64Length * 3) / 4 - padding;
    const result = new Uint8Array(length);
    const lookup = DataCrypto.BASE64_LOOKUP;

    let i = 0;
    let buffer = 0;
    let bits = 0;

    for (let j = 0; j < base64Length; j++) {
      if (base64[j] === '=') break;
      buffer = (buffer << 6) | lookup[base64.charCodeAt(j)];
      bits += 6;

      if (bits >= 8) {
        result[i++] = (buffer >> (bits - 8)) & 0xFF;
        bits -= 8;
      }
    }

    return result;
  }

  /**
   * 加密字符串数据
   * @param plainText 明文字符串
   * @returns 加密结果的 Base64 编码
   */
  public async encryptString(plainText: string): Promise<Base64Result> {
    // 将字符串转换为 Uint8Array
    const data = stringEncoder.encode(plainText);

    const result = await this.encryptData(data);

    return {
      cipherTextBase64: this.uint8ArrayToBase64(result.cipherText),
      ivBase64: this.uint8ArrayToBase64(result.iv),
      authTagBase64: this.uint8ArrayToBase64(result.authTag)
    };
  }

  /**
   * 解密字符串数据
   * @param cipherTextBase64 Base64 编码的密文
   * @param ivBase64 Base64 编码的 IV
   * @param authTagBase64 Base64 编码的认证标签
   * @returns 解密后的明文字符串
   */
  public async decryptString(cipherTextBase64: string, ivBase64: string, authTagBase64: string): Promise<string> {
    // Base64 解码
    const cipherText = this.base64ToUint8Array(cipherTextBase64);
    const iv = this.base64ToUint8Array(ivBase64);
    const authTag = this.base64ToUint8Array(authTagBase64);

    const decryptedData = await this.decryptData(cipherText, iv, authTag);

    // 将 Uint8Array 转换为字符串
    return stringDecoder.decode(decryptedData);
  }

  /**
   * 生成随机密钥
   */
  public async generateRandomKey(): Promise<Base64Result> {
    if (!this.keyData) {
      throw new Error('DataCrypto not initialized');
    }

    try {
      // 生成新的随机 IV
      const random = cryptoFramework.createRandom();
      const ivBlob = await random.generateRandom(12);

      return {
        cipherTextBase64: this.uint8ArrayToBase64(this.keyData),
        ivBase64: this.uint8ArrayToBase64(ivBlob.data),
        authTagBase64: ''
      };
    } catch (error) {
      const err = error as BusinessError;
      console.error('Failed to generate random key:', err.message);
      throw new Error(String(error));
    }
  }

  /**
   * 获取密钥的 Base64 表示
   */
  public async getKeyBase64(): Promise<string> {
    if (!this.keyData) {
      throw new Error('DataCrypto not initialized');
    }

    return this.uint8ArrayToBase64(this.keyData);
  }

  /**
   * 释放资源
   */
  public async release(): Promise<void> {
    try {
      this.key = null;
      this.keyData = null;
      this.base64Cache.clear();
      console.info('DataCrypto released successfully');
    } catch (error) {
      const err = error as BusinessError;
      console.error('Failed to release DataCrypto:', err.message);
    }
  }
}
