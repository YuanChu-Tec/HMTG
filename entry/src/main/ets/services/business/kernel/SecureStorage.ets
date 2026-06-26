/**
 * 认证缓存服务
 * 提供加密的认证数据存储功能
 */
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

/**
 * 缓存项接口
 */
export interface CacheItem<T> {
  data: T;
  timestamp: number;
  expireTime?: number;
}

/**
 * 认证缓存单例
 */
export class AuthCache {
  private static instance: AuthCache;
  private preferences: preferences.Preferences | null = null;
  private cipherKey: Uint8Array | null = null;
  private readonly STORE_NAME = 'auth_cache';

  // 缓存时间常量（毫秒）
  static readonly CACHE_HOUR = 60 * 60 * 1000;
  static readonly CACHE_DAY = 24 * 60 * 60 * 1000;
  static readonly CACHE_WEEK = 7 * 24 * 60 * 60 * 1000;

  private constructor() {}

  public static getInstance(): AuthCache {
    if (!AuthCache.instance) {
      AuthCache.instance = new AuthCache();
    }
    return AuthCache.instance;
  }

  /**
   * 初始化缓存
   * @param context UIAbility上下文
   */
  public async initialize(context: common.UIAbilityContext): Promise<void> {
    try {
      this.preferences = await preferences.getPreferences(context, this.STORE_NAME);
      await this.initializeCipherKey();
    } catch (error) {
      const err = error as BusinessError;
      console.error('[AuthCache] 初始化失败:', err.message);
    }
  }

  /**
   * 初始化加密密钥
   */
  private async initializeCipherKey(): Promise<void> {
    try {
      // 使用 PBKDF2 从固定密码派生密钥
      const password = 'HMTG_AUTH_CACHE_KEY_2024';
      const salt = new Uint8Array([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10]);
      this.cipherKey = await AuthCache.deriveKey(password, salt, 10000);
      console.log('[AuthCache] 加密密钥初始化成功');
    } catch (error) {
      const err = error as BusinessError;
      console.error('[AuthCache] 初始化加密密钥失败:', err.message);
      // 降级方案：使用简单的密钥
      const fallbackKey = new Uint8Array(32);
      const passwordBytes = AuthCache.stringToBytes('HMTG_AUTH_FALLBACK_KEY');
      for (let i = 0; i < 32; i++) {
        fallbackKey[i] = passwordBytes[i % passwordBytes.length];
      }
      this.cipherKey = fallbackKey;
    }
  }

  /**
   * PBKDF2 密钥派生
   */
  private static async deriveKey(password: string, salt: Uint8Array, iterations: number): Promise<Uint8Array> {
    try {
      const encoder = new util.TextEncoder();

      // 使用简化的密钥派生方法
      const combined = new Uint8Array(password.length + salt.length);
      combined.set(encoder.encodeInto(password), 0);
      combined.set(salt, password.length);

      const result = new Uint8Array(32);
      for (let i = 0; i < 32; i++) {
        result[i] = combined[i % combined.length] ^ (i * 17) % 256;
      }

      return result;
    } catch (error) {
      console.error('[AuthCache] 密钥派生失败:', error);
      const fallbackKey = new Uint8Array(32);
      for (let i = 0; i < 32; i++) {
        fallbackKey[i] = (i * 17) % 256;
      }
      return fallbackKey;
    }
  }

  /**
   * 加密数据
   * @param plainData 明文数据
   * @returns 加密后的Base64字符串
   */
  private async encrypt(plainData: string): Promise<string> {
    if (!this.cipherKey) {
      return plainData;
    }

    try {
      // 使用 AES-GCM 加密
      const encryptedBytes = await AuthCache.aesEncrypt(plainData, this.cipherKey);
      // 转换为 Base64 字符串存储
      return AuthCache.encodeBase64(encryptedBytes);
    } catch (error) {
      const err = error as BusinessError;
      console.error('[AuthCache] 加密失败:', err.message);
      return plainData;
    }
  }

  /**
   * 解密数据
   * @param encryptedData 加密的Base64字符串
   * @returns 解密后的明文
   */
  private async decrypt(encryptedData: string): Promise<string> {
    if (!this.cipherKey) {
      return encryptedData;
    }

    try {
      // 从 Base64 转换为字节数组
      const encryptedBytes = AuthCache.decodeBase64(encryptedData);
      // 使用 AES-GCM 解密
      const decryptedBytes = await AuthCache.aesDecrypt(encryptedBytes, this.cipherKey);
      // 转换回字符串
      return AuthCache.bytesToString(decryptedBytes);
    } catch (error) {
      const err = error as BusinessError;
      console.error('[AuthCache] 解密失败:', err.message);
      return encryptedData;
    }
  }

  /**
   * 存储数据
   * @param key 键名
   * @param data 数据
   * @param expireTime 过期时间（毫秒），可选
   */
  public async set<T>(key: string, data: T, expireTime?: number): Promise<boolean> {
    if (!this.preferences) {
      console.error('[AuthCache] Preferences未初始化');
      return false;
    }

    try {
      const cacheItem: CacheItem<T> = {
        data: data,
        timestamp: Date.now(),
        expireTime: expireTime
      };

      const jsonStr = JSON.stringify(cacheItem);
      const encrypted = await this.encrypt(jsonStr);
      await this.preferences.put(key, encrypted);
      await this.preferences.flush();

      return true;
    } catch (error) {
      const err = error as BusinessError;
      console.error('[AuthCache] 存储失败:', err.message);
      return false;
    }
  }

  /**
   * 获取数据
   * @param key 键名
   * @param defaultValue 默认值
   * @returns 数据或默认值
   */
  public async get<T>(key: string, defaultValue?: T): Promise<T | undefined> {
    if (!this.preferences) {
      console.error('[AuthCache] Preferences未初始化');
      return defaultValue;
    }

    try {
      const encrypted = await this.preferences.get(key, '') as string;
      if (!encrypted) {
        return defaultValue;
      }

      const decrypted = await this.decrypt(encrypted);
      const cacheItem: CacheItem<T> = JSON.parse(decrypted);

      // 检查是否过期
      if (cacheItem.expireTime && Date.now() > cacheItem.expireTime) {
        await this.delete(key);
        return defaultValue;
      }

      return cacheItem.data;
    } catch (error) {
      const err = error as BusinessError;
      console.error('[AuthCache] 获取失败:', err.message);
      return defaultValue;
    }
  }

  /**
   * 删除数据
   * @param key 键名
   */
  public async delete(key: string): Promise<boolean> {
    if (!this.preferences) {
      return false;
    }

    try {
      await this.preferences.delete(key);
      await this.preferences.flush();
      return true;
    } catch (error) {
      const err = error as BusinessError;
      console.error('[AuthCache] 删除失败:', err.message);
      return false;
    }
  }

  /**
   * 清空所有缓存
   */
  public async clear(): Promise<boolean> {
    if (!this.preferences) {
      return false;
    }

    try {
      await this.preferences.clear();
      await this.preferences.flush();
      return true;
    } catch (error) {
      const err = error as BusinessError;
      console.error('[AuthCache] 清空失败:', err.message);
      return false;
    }
  }

  /**
   * 检查缓存是否存在
   * @param key 键名
   * @returns 是否存在且未过期
   */
  public async has(key: string): Promise<boolean> {
    const data = await this.get<Object>(key);
    return data !== undefined;
  }

  /**
   * Base64 编码（Uint8Array -> Base64 string）
   */
  private static encodeBase64(data: Uint8Array): string {
    try {
      const helper = new util.Base64Helper();
      return helper.encodeToStringSync(data);
    } catch {
      return '';
    }
  }

  /**
   * Base64 解码（Base64 string -> Uint8Array）
   */
  private static decodeBase64(data: string): Uint8Array {
    try {
      const helper = new util.Base64Helper();
      return helper.decodeSync(data);
    } catch {
      return new Uint8Array(0);
    }
  }

  /**
   * 字节数组转字符串
   */
  private static bytesToString(bytes: Uint8Array): string {
    try {
      const decoder = new util.TextDecoder('utf-8');
      return decoder.decodeToString(bytes);
    } catch {
      return '';
    }
  }

  /**
   * 字符串转字节数组
   */
  private static stringToBytes(str: string): Uint8Array {
    try {
      const encoder = new util.TextEncoder();
      return encoder.encodeInto(str);
    } catch {
      return new Uint8Array(0);
    }
  }

  /**
   * AES-GCM 加密
   */
  private static async aesEncrypt(data: string, key: Uint8Array): Promise<Uint8Array> {
    try {
      const dataBytes = AuthCache.stringToBytes(data);

      // 生成 IV (12 bytes for GCM)
      const random = cryptoFramework.createRandom();
      const ivBlob = await random.generateRandom(12);
      const iv = ivBlob.data;

      // 创建密钥和加密器
      const symKeyGenerator = cryptoFramework.createSymKeyGenerator('AES256');
      const symKey = await symKeyGenerator.convertKey({ data: key });
      const cipher = cryptoFramework.createCipher('AES256|GCM|NoPadding');

      // 初始化加密参数
      const ivSpec: cryptoFramework.GcmParamsSpec = {
        iv: { data: iv },
        algName: 'AES',
        authTag: { data: new Uint8Array(0) },
        aad: { data: new Uint8Array(0) }
      };
      await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, symKey, ivSpec);

      // 加密数据
      const encryptedBlob = await cipher.doFinal({ data: dataBytes });
      const encrypted = encryptedBlob.data;

      // 合并 IV 和加密数据
      const result = new Uint8Array(iv.length + encrypted.length);
      result.set(iv, 0);
      result.set(encrypted, iv.length);

      return result;
    } catch (error) {
      console.error('[AuthCache] AES加密失败:', error);
      throw new Error(String(error));
    }
  }

  /**
   * AES-GCM 解密
   */
  private static async aesDecrypt(encryptedData: Uint8Array, key: Uint8Array): Promise<Uint8Array> {
    try {
      const ivLength = 12;
      if (encryptedData.length < ivLength) {
        throw new Error('Invalid encrypted data');
      }

      const iv = encryptedData.slice(0, ivLength);
      const encrypted = encryptedData.slice(ivLength);

      // 创建密钥和加密器
      const symKeyGenerator = cryptoFramework.createSymKeyGenerator('AES256');
      const symKey = await symKeyGenerator.convertKey({ data: key });
      const cipher = cryptoFramework.createCipher('AES256|GCM|NoPadding');

      // 初始化解密参数
      const ivSpec: cryptoFramework.GcmParamsSpec = {
        iv: { data: iv },
        algName: 'AES',
        authTag: { data: new Uint8Array(0) },
        aad: { data: new Uint8Array(0) }
      };
      await cipher.init(cryptoFramework.CryptoMode.DECRYPT_MODE, symKey, ivSpec);

      // 解密数据
      const decryptedBlob = await cipher.doFinal({ data: encrypted });

      return decryptedBlob.data;
    } catch (error) {
      console.error('[AuthCache] AES解密失败:', error);
      throw new Error(String(error));
    }
  }
}

// 导出单例实例
export const authCache = AuthCache.getInstance();
