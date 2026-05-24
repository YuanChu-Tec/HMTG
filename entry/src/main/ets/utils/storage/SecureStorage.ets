import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { AppError, ErrorSeverity, ErrorCategory, ErrorContext } from '../error/AppError';
import { ErrorCode } from '../error/ErrorCode';
import { util } from '@kit.ArkTS';

/**
 * 安全存储 - 加密存储敏感数据
 * 使用 HarmonyOS cryptoFramework 进行 AES-256-GCM 加密
 */
export class SecureStorage {
  private static instance: SecureStorage;
  private preferences?: preferences.Preferences;
  private encryptionKey?: cryptoFramework.SymKey;
  private encryptionKeyData?: Uint8Array;
  private readonly STORE_NAME = 'secure_storage';

  private constructor() {}

  public static getInstance(): SecureStorage {
    if (!SecureStorage.instance) {
      SecureStorage.instance = new SecureStorage();
    }
    return SecureStorage.instance;
  }

  /**
   * 初始化安全存储
   */
  public async initialize(context: common.UIAbilityContext, encryptionKey?: Uint8Array): Promise<void> {
    try {
      this.preferences = await preferences.getPreferences(context, this.STORE_NAME);

      // 生成或使用提供的加密密钥
      if (encryptionKey) {
        this.encryptionKeyData = encryptionKey;
      } else {
        this.encryptionKeyData = await this.generateKey();
      }

      // 创建对称密钥对象
      const symKeyGenerator = cryptoFramework.createSymKeyGenerator('AES256');
      this.encryptionKey = await symKeyGenerator.convertKey({ data: this.encryptionKeyData! });
    } catch (error) {
      const err = new AppError(
        String(ErrorCode.STORAGE_ERROR),
        'Failed to initialize secure storage',
        ErrorSeverity.ERROR,
        undefined,
        undefined,
        error as Error
      );
      throw new Error(String(err));
    }
  }

  /**
   * 存储加密数据
   * 使用 AES-256-GCM 加密
   */
  public async put(key: string, value: string): Promise<void> {
    if (!this.preferences || !this.encryptionKey) {
      throw new AppError(String(ErrorCode.STORAGE_NOT_AVAILABLE), 'Secure storage not initialized');
    }

    try {
      // 使用 AES-GCM 加密数据
      const encryptedData = await this.encryptWithAES_GCM(value);

      // 存储 Base64 编码的加密数据
      await this.preferences.put(key, encryptedData);
      await this.preferences.flush();
    } catch (error) {
      throw new AppError(
        String(ErrorCode.STORAGE_ERROR),
        `Failed to put secure value for key: ${key}`,
        ErrorSeverity.ERROR,
        ErrorCategory.UNKNOWN,
        undefined,
        error as Error
      );
    }
  }

  /**
   * 获取解密数据
   * 使用 AES-256-GCM 解密
   */
  public async get(key: string, defaultValue?: string): Promise<string | undefined> {
    if (!this.preferences || !this.encryptionKey) {
      throw new AppError(String(ErrorCode.STORAGE_NOT_AVAILABLE), 'Secure storage not initialized');
    }

    try {
      const encryptedData = await this.preferences.get(key, '') as string;
      if (!encryptedData) {
        return defaultValue;
      }

      // 解密数据
      return await this.decryptWithAES_GCM(encryptedData);
    } catch (error) {
      throw new AppError(
        String(ErrorCode.STORAGE_ERROR),
        `Failed to get secure value for key: ${key}`,
        ErrorSeverity.ERROR,
        ErrorCategory.UNKNOWN,
        undefined,
        error as Error
      );
    }
  }

  /**
   * 删除数据
   */
  public async delete(key: string): Promise<void> {
    if (!this.preferences) {
      const err = new AppError(
        String(ErrorCode.STORAGE_NOT_AVAILABLE),
        'Secure storage not initialized',
        ErrorSeverity.ERROR,
        ErrorCategory.UNKNOWN
      );
      throw new Error(String(err));
    }

    try {
      await this.preferences.delete(key);
      await this.preferences.flush();
    } catch (error) {
      const err = new AppError(
        String(ErrorCode.STORAGE_ERROR),
        `Failed to delete secure value for key: ${key}`,
        ErrorSeverity.ERROR,
        ErrorCategory.UNKNOWN,
        undefined,
        error as Error
      );
      throw new Error(String(err));
    }
  }

  /**
   * 检查键是否存在
   */
  public async has(key: string): Promise<boolean> {
    if (!this.preferences) {
      return false;
    }

    try {
      return await this.preferences.has(key);
    } catch (error) {
      return false;
    }
  }

  /**
   * 清除所有数据
   */
  public async clear(): Promise<void> {
    if (!this.preferences) {
      throw new AppError(
        String(ErrorCode.STORAGE_NOT_AVAILABLE),
        'Secure storage not initialized'
      );
    }

    try {
      await this.preferences.clear();
      await this.preferences.flush();
    } catch (error) {
      throw new AppError(
        String(ErrorCode.STORAGE_ERROR),
        'Failed to clear secure storage',
        undefined,
        undefined
      );
    }
  }

  /**
   * 使用 AES-256-GCM 加密数据
   */
  private async encryptWithAES_GCM(plaintext: string): Promise<string> {
    try {
      const cipher = cryptoFramework.createCipher('AES256|GCM|NoPadding');

      // 生成随机 IV
      const random = cryptoFramework.createRandom();
      const ivBlob = await random.generateRandom(12);

      // 初始化加密参数
      const ivSpec: cryptoFramework.GcmParamsSpec = {
        iv: { data: ivBlob.data },
        algName: 'AES',
        authTag: { data: new Uint8Array(0) },
        aad: { data: new Uint8Array(0) }
      };

      await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, this.encryptionKey!, ivSpec);

      // 执行加密
      const encryptedBlob = await cipher.doFinal({ data: new util.TextEncoder().encodeInto(plaintext) });
      const encrypted = encryptedBlob.data;

      // 分离密文和认证标签
      const authTagSize = 16;
      const ciphertext = encrypted.subarray(0, encrypted.length - authTagSize);
      const authTag = encrypted.subarray(encrypted.length - authTagSize);

      // 组合 IV、密文和认证标签
      const combined = new Uint8Array(ivBlob.data.length + ciphertext.length + authTag.length);
      combined.set(ivBlob.data, 0);
      combined.set(ciphertext, ivBlob.data.length);
      combined.set(authTag, ivBlob.data.length + ciphertext.length);

      // 返回 Base64 编码
      return this.uint8ArrayToBase64(combined);
    } catch (error) {
      throw new Error(`AES-GCM encryption failed: ${error}`);
    }
  }

  /**
   * 使用 AES-256-GCM 解密数据
   */
  private async decryptWithAES_GCM(encryptedBase64: string): Promise<string> {
    try {
      // 解码 Base64
      const combined = this.base64ToUint8Array(encryptedBase64);

      // 提取 IV、密文和认证标签
      const ivLength = 12;
      const authTagSize = 16;

      if (combined.length < ivLength + authTagSize) {
        throw new Error('Invalid encrypted data');
      }

      const iv = combined.subarray(0, ivLength);
      const ciphertextWithTag = combined.subarray(ivLength);
      const ciphertext = ciphertextWithTag.subarray(0, ciphertextWithTag.length - authTagSize);
      const authTag = ciphertextWithTag.subarray(ciphertextWithTag.length - authTagSize);

      // 组合密文和认证标签
      const ciphertextWithTagCombined = new Uint8Array(ciphertext.length + authTag.length);
      ciphertextWithTagCombined.set(ciphertext);
      ciphertextWithTagCombined.set(authTag, ciphertext.length);

      // 初始化解密参数
      const cipher = cryptoFramework.createCipher('AES256|GCM|NoPadding');

      const ivSpec: cryptoFramework.GcmParamsSpec = {
        iv: { data: iv },
        algName: 'AES',
        authTag: { data: authTag },
        aad: { data: new Uint8Array(0) }
      };

      await cipher.init(cryptoFramework.CryptoMode.DECRYPT_MODE, this.encryptionKey!, ivSpec);

      // 执行解密
      const decryptedBlob = await cipher.doFinal({ data: ciphertextWithTagCombined });
      const decrypted = decryptedBlob.data;

      const decoder = new util.TextDecoder('utf-8');
      return decoder.decodeToString(decrypted);
    } catch (error) {
      throw new Error(`AES-GCM decryption failed: ${error}`);
    }
  }

  /**
   * 生成安全的随机密钥
   * 使用官方 cryptoFramework API
   */
  private async generateKey(): Promise<Uint8Array> {
    try {
      const random = cryptoFramework.createRandom();
      const keyBlob = await random.generateRandom(32);
      return keyBlob.data;
    } catch (error) {
      throw new Error(`Failed to generate encryption key: ${String(error)}`);
    }
  }

  /**
   * Uint8Array 转 Base64 字符串
   */
  private uint8ArrayToBase64(uint8Array: Uint8Array): string {
    const base64Helper = new util.Base64Helper();
    return base64Helper.encodeToStringSync(uint8Array);
  }

  /**
   * Base64 字符串转 Uint8Array
   */
  private base64ToUint8Array(base64: string): Uint8Array {
    const base64Helper = new util.Base64Helper();
    return base64Helper.decodeSync(base64);
  }
}
