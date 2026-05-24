// file: SessionEncryption.ets - 会话加密模块
// 提供会话级别的加密解密功能，保护敏感会话数据
// 基于 HarmonyOS CryptoKit 实现

import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { preferences } from '@kit.ArkData';
import { util } from '@kit.ArkTS';

/**
 * 加密算法类型
 */
export enum EncryptionAlgorithm {
  /** AES-GCM（推荐） */
  AES_GCM = 'AES_GCM',
  /** AES-CBC */
  AES_CBC = 'AES_CBC',
  /** ChaCha20-Poly1305 */
  CHACHA20_POLY1305 = 'CHACHA20_POLY1305',
}

/**
 * 加密配置
 */
export interface EncryptionConfig {
  /** 加密算法 */
  algorithm?: EncryptionAlgorithm;
  /** 密钥长度（位） */
  keySize?: number;
  /** IV 长度（字节） */
  ivSize?: number;
  /** 是否使用固定 IV（仅用于测试） */
  fixedIv?: boolean;
}

/**
 * 加密结果
 */
export interface EncryptionResult {
  /** 加密后的数据（Base64 编码） */
  ciphertext: string;
  /** 初始化向量（Base64 编码） */
  iv: string;
  /** 认证标签（Base64 编码，仅 GCM 模式） */
  tag?: string;
  /** 加密时间戳 */
  timestamp: number;
}

/**
 * AES-GCM 加密输出
 */
export interface AesGcmOutput {
  ciphertext: Uint8Array;
  tag: Uint8Array;
}

/**
 * 会话加密模块
 * 单例模式，提供会话数据的加密解密功能
 */
export class SessionEncryption {
  private static instance: SessionEncryption;
  private encryptionPreferences: preferences.Preferences | null = null;
  private keyCache: Map<string, cryptoFramework.SymKey> = new Map();

  private static readonly TAG = 'SessionEncryption';
  private static readonly DOMAIN = 0x0005;
  private static readonly DEFAULT_ALGORITHM = EncryptionAlgorithm.AES_GCM;
  private static readonly DEFAULT_KEY_SIZE = 256; // 256 位密钥
  private static readonly DEFAULT_IV_SIZE = 16; // 12 字节 IV（GCM 推荐）
  private static readonly TAG_SIZE = 16; // 16 字节认证标签

  private static readonly SESSION_KEY_PREFIX = 'session_key_';
  private static readonly SESSION_IV_PREFIX = 'session_iv_';

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): SessionEncryption {
    if (!SessionEncryption.instance) {
      SessionEncryption.instance = new SessionEncryption();
    }
    return SessionEncryption.instance;
  }

  /**
   * 初始化服务
   */
  public async initialize(context: Context): Promise<void> {
    try {
      const dataPreferences = await preferences.getPreferences(context, 'session_encryption');
      this.encryptionPreferences = dataPreferences;
      hilog.info(SessionEncryption.DOMAIN, SessionEncryption.TAG, 'SessionEncryption initialized');
    } catch (error) {
      hilog.error(SessionEncryption.DOMAIN, SessionEncryption.TAG, 'Failed to initialize SessionEncryption');
      throw new Error(String(error));
    }
  }

  /**
   * 创建新的会话密钥
   */
  public async createSessionKey(sessionId: string, config?: EncryptionConfig): Promise<string> {
    try {
      const keySize = config?.keySize || SessionEncryption.DEFAULT_KEY_SIZE;
      const keyData = await this.generateRandomKey(keySize);
      const key = await this.importAesKey(keyData);

      // 缓存密钥
      this.keyCache.set(sessionId, key);

      // 持久化密钥（加密存储）
      if (this.encryptionPreferences) {
        const encryptedKey = await this.encryptForStorage(keyData);
        await this.encryptionPreferences.put(
          SessionEncryption.SESSION_KEY_PREFIX + sessionId,
          encryptedKey
        );
        await this.encryptionPreferences.flush();
      }

      hilog.info(SessionEncryption.DOMAIN, SessionEncryption.TAG, `Session key created for session: ${sessionId}`);
      return sessionId;
    } catch (error) {
      hilog.error(SessionEncryption.DOMAIN, SessionEncryption.TAG, 'Failed to create session key');
      throw new Error(String(error));
    }
  }

  /**
   * 加密会话数据
   */
  public async encryptData(
    sessionId: string,
    plaintext: string,
    config?: EncryptionConfig
  ): Promise<EncryptionResult> {
    try {
      const algorithm = config?.algorithm || SessionEncryption.DEFAULT_ALGORITHM;
      const ivSize = config?.ivSize || SessionEncryption.DEFAULT_IV_SIZE;

      // 获取或加载密钥
      const key = await this.getSessionKey(sessionId);
      if (!key) {
        throw new Error(`Session key not found for session: ${sessionId}`);
      }

      // 生成 IV
      const iv = await this.generateRandomIv(ivSize);

      let ciphertext: Uint8Array;
      let tag: Uint8Array | undefined;

      if (algorithm === EncryptionAlgorithm.AES_GCM) {
        // AES-GCM 加密
        const result = await this.encryptAES_GCM(key, plaintext, iv);
        ciphertext = result.ciphertext;
        tag = result.tag;
      } else if (algorithm === EncryptionAlgorithm.AES_CBC) {
        // AES-CBC 加密
        ciphertext = await this.encryptAES_CBC(key, plaintext, iv);
      } else {
        throw new Error(`Unsupported algorithm: ${algorithm}`);
      }

      const encryptionResult: EncryptionResult = {
        ciphertext: this.base64Encode(ciphertext),
        iv: this.base64Encode(iv),
        tag: tag ? this.base64Encode(tag) : undefined,
        timestamp: Date.now(),
      };

      hilog.info(SessionEncryption.DOMAIN, SessionEncryption.TAG, `Data encrypted for session: ${sessionId}`);
      return encryptionResult;
    } catch (error) {
      hilog.error(SessionEncryption.DOMAIN, SessionEncryption.TAG, 'Failed to encrypt data');
      throw new Error(String(error));
    }
  }

  /**
   * 解密会话数据
   */
  public async decryptData(
    sessionId: string,
    ciphertext: string,
    iv: string,
    tag?: string,
    config?: EncryptionConfig
  ): Promise<string> {
    try {
      const algorithm = config?.algorithm || SessionEncryption.DEFAULT_ALGORITHM;

      // 获取或加载密钥
      const key = await this.getSessionKey(sessionId);
      if (!key) {
        throw new Error(`Session key not found for session: ${sessionId}`);
      }

      // 解码 Base64
      const ciphertextData = this.base64Decode(ciphertext);
      const ivData = this.base64Decode(iv);

      let plaintext: string;

      if (algorithm === EncryptionAlgorithm.AES_GCM) {
        if (!tag) {
          throw new Error('Tag is required for AES-GCM decryption');
        }
        const tagData = this.base64Decode(tag);
        plaintext = await this.decryptAES_GCM(key, ciphertextData, ivData, tagData);
      } else if (algorithm === EncryptionAlgorithm.AES_CBC) {
        plaintext = await this.decryptAES_CBC(key, ciphertextData, ivData);
      } else {
        throw new Error(`Unsupported algorithm: ${algorithm}`);
      }

      hilog.info(SessionEncryption.DOMAIN, SessionEncryption.TAG, `Data decrypted for session: ${sessionId}`);
      return plaintext;
    } catch (error) {
      hilog.error(SessionEncryption.DOMAIN, SessionEncryption.TAG, 'Failed to decrypt data');
      throw new Error(String(error));
    }
  }

  /**
   * 删除会话密钥
   */
  public async deleteSessionKey(sessionId: string): Promise<void> {
    try {
      // 清除缓存
      this.keyCache.delete(sessionId);

      // 删除持久化密钥
      if (this.encryptionPreferences) {
        await this.encryptionPreferences.delete(SessionEncryption.SESSION_KEY_PREFIX + sessionId);
        await this.encryptionPreferences.delete(SessionEncryption.SESSION_IV_PREFIX + sessionId);
        await this.encryptionPreferences.flush();
      }

      hilog.info(SessionEncryption.DOMAIN, SessionEncryption.TAG, `Session key deleted for session: ${sessionId}`);
    } catch (error) {
      hilog.error(SessionEncryption.DOMAIN, SessionEncryption.TAG, 'Failed to delete session key');
      throw new Error(String(error));
    }
  }

  /**
   * 清除所有会话密钥
   */
  public async clearAllSessionKeys(): Promise<void> {
    try {
      // 清除缓存
      this.keyCache.clear();

      // 删除所有持久化密钥
      if (this.encryptionPreferences) {
        const keys = await this.encryptionPreferences.getAll();
        const keyNames = Object.keys(keys);
        for (let i = 0; i < keyNames.length; i++) {
          const key = keyNames[i];
          if (key.startsWith(SessionEncryption.SESSION_KEY_PREFIX) ||
            key.startsWith(SessionEncryption.SESSION_IV_PREFIX)) {
            await this.encryptionPreferences.delete(key);
          }
        }
        await this.encryptionPreferences.flush();
      }

      hilog.info(SessionEncryption.DOMAIN, SessionEncryption.TAG, 'All session keys cleared');
    } catch (error) {
      hilog.error(SessionEncryption.DOMAIN, SessionEncryption.TAG, 'Failed to clear all session keys');
      throw new Error(String(error));
    }
  }

  /**
   * 生成随机密钥
   */
  private async generateRandomKey(size: number): Promise<Uint8Array> {
    const keySizeInBytes = size / 8;
    const random = cryptoFramework.createRandom();
    const keyDataBlob = await random.generateRandom(keySizeInBytes);
    return keyDataBlob.data;
  }

  /**
   * 生成随机 IV
   */
  private async generateRandomIv(size: number): Promise<Uint8Array> {
    const random = cryptoFramework.createRandom();
    const ivBlob = await random.generateRandom(size);
    return ivBlob.data;
  }

  /**
   * 导入 AES 密钥
   */
  private async importAesKey(keyData: Uint8Array): Promise<cryptoFramework.SymKey> {
    const symKeyGenerator = cryptoFramework.createSymKeyGenerator('AES256');
    const result = await symKeyGenerator.convertKey({ data: keyData });
    return result;
  }

  /**
   * 获取会话密钥
   */
  private async getSessionKey(sessionId: string): Promise<cryptoFramework.SymKey | null> {
    // 先检查缓存
    if (this.keyCache.has(sessionId)) {
      return this.keyCache.get(sessionId) || null;
    }

    // 从持久化存储加载
    if (this.encryptionPreferences) {
      try {
        const encryptedKey = await this.encryptionPreferences.get(
          SessionEncryption.SESSION_KEY_PREFIX + sessionId,
          ''
        ) as string;

        if (encryptedKey) {
          const keyData = await this.decryptFromStorage(encryptedKey);
          const key = await this.importAesKey(keyData);
          this.keyCache.set(sessionId, key);
          return key;
        }
      } catch (error) {
        hilog.warn(SessionEncryption.DOMAIN, SessionEncryption.TAG, 'Failed to load session key from storage');
      }
    }

    return null;
  }

  /**
   * AES-GCM 加密
   */
  private async encryptAES_GCM(
    key: cryptoFramework.SymKey,
    plaintext: string,
    iv: Uint8Array
  ): Promise<AesGcmOutput> {
    const cipher = cryptoFramework.createCipher('AES256|GCM|NoPadding');

    // 创建 GCM 参数规范
    const ivSpec: cryptoFramework.GcmParamsSpec = {
      iv: { data: iv },
      algName: 'AES',
      authTag: { data: new Uint8Array(0) },
      aad: { data: new Uint8Array(0) }
    };

    await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, key, ivSpec);
    const textEncoder = new util.TextEncoder();
    const ciphertextBlob = await cipher.doFinal({ data: textEncoder.encodeInto(plaintext) });
    const ciphertext = ciphertextBlob.data;

    // 分离密文和认证标签
    const tagStart = ciphertext.length - SessionEncryption.TAG_SIZE;
    const ciphertextWithoutTag = ciphertext.subarray(0, tagStart);
    const tag = ciphertext.subarray(tagStart);

    const result: AesGcmOutput = {
      ciphertext: ciphertextWithoutTag,
      tag: tag
    };
    return result;
  }

  /**
   * AES-GCM 解密
   */
  private async decryptAES_GCM(
    key: cryptoFramework.SymKey,
    ciphertext: Uint8Array,
    iv: Uint8Array,
    tag: Uint8Array
  ): Promise<string> {
    const decoder = cryptoFramework.createCipher('AES256|GCM|NoPadding');

    // 创建 GCM 参数规范 - 使用传入的 tag
    const ivSpec: cryptoFramework.GcmParamsSpec = {
      iv: { data: iv },
      algName: 'AES',
      authTag: { data: tag },
      aad: { data: new Uint8Array(0) }
    };

    await decoder.init(cryptoFramework.CryptoMode.DECRYPT_MODE, key, ivSpec);

    // 组合密文和认证标签
    const ciphertextWithTag = new Uint8Array(ciphertext.length + tag.length);
    ciphertextWithTag.set(ciphertext);
    ciphertextWithTag.set(tag, ciphertext.length);

    const plaintextBlob = await decoder.doFinal({ data: ciphertextWithTag });
    const textDecoder = new util.TextDecoder();
    return textDecoder.decodeToString(plaintextBlob.data);
  }

  /**
   * AES-CBC 加密
   */
  private async encryptAES_CBC(
    key: cryptoFramework.SymKey,
    plaintext: string,
    iv: Uint8Array
  ): Promise<Uint8Array> {
    const cipher = cryptoFramework.createCipher('AES256|CBC|PKCS7');

    // 创建 CBC 参数规范 - 使用 GcmParamsSpec（包含 iv 字段）
    const ivSpec: cryptoFramework.GcmParamsSpec = {
      iv: { data: iv },
      algName: 'AES',
      authTag: { data: new Uint8Array(0) },
      aad: { data: new Uint8Array(0) }
    };

    await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, key, ivSpec);
    const textEncoder = new util.TextEncoder();
    const resultBlob = await cipher.doFinal({ data: textEncoder.encodeInto(plaintext) });
    return resultBlob.data;
  }

  /**
   * AES-CBC 解密
   */
  private async decryptAES_CBC(
    key: cryptoFramework.SymKey,
    ciphertext: Uint8Array,
    iv: Uint8Array
  ): Promise<string> {
    const decoder = cryptoFramework.createCipher('AES256|CBC|PKCS7');

    // 创建 CBC 参数规范 - 使用 GcmParamsSpec（包含 iv 字段）
    const ivSpec: cryptoFramework.GcmParamsSpec = {
      iv: { data: iv },
      algName: 'AES',
      authTag: { data: new Uint8Array(0) },
      aad: { data: new Uint8Array(0) }
    };

    await decoder.init(cryptoFramework.CryptoMode.DECRYPT_MODE, key, ivSpec);
    const plaintextBlob = await decoder.doFinal({ data: ciphertext });
    const textDecoder = new util.TextDecoder();
    return textDecoder.decodeToString(plaintextBlob.data);
  }

  /**
   * 加密数据用于持久化存储
   */
  private async encryptForStorage(data: Uint8Array): Promise<string> {
    // 使用设备主密钥加密
    const masterKey = await this.getDeviceMasterKey();
    const iv = await this.generateRandomIv(16);
    const key = await this.importAesKey(masterKey);

    const cipher = cryptoFramework.createCipher('AES256|GCM|NoPadding');

    const ivSpec: cryptoFramework.GcmParamsSpec = {
      iv: { data: iv },
      algName: 'AES',
      authTag: { data: new Uint8Array(0) },
      aad: { data: new Uint8Array(0) }
    };

    await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, key, ivSpec);
    const ciphertextBlob = await cipher.doFinal({ data: data });
    const ciphertext = ciphertextBlob.data;

    const tagStart = ciphertext.length - SessionEncryption.TAG_SIZE;
    const ciphertextWithoutTag = ciphertext.subarray(0, tagStart);
    const tag = ciphertext.subarray(tagStart);

    return `${this.base64Encode(ciphertextWithoutTag)}:${this.base64Encode(iv)}:${this.base64Encode(tag)}`;
  }

  /**
   * 从持久化存储解密数据
   */
  private async decryptFromStorage(encrypted: string): Promise<Uint8Array> {
    const parts = encrypted.split(':');
    if (parts.length < 3) {
      throw new Error('Invalid encrypted data format');
    }
    const ciphertextBase64 = parts[0];
    const ivBase64 = parts[1];
    const tagBase64 = parts[2];

    const masterKey = await this.getDeviceMasterKey();
    const key = await this.importAesKey(masterKey);

    const ciphertext = this.base64Decode(ciphertextBase64);
    const iv = this.base64Decode(ivBase64);
    const tag = this.base64Decode(tagBase64);

    const decoder = cryptoFramework.createCipher('AES256|GCM|NoPadding');

    const ivSpec: cryptoFramework.GcmParamsSpec = {
      iv: { data: iv },
      algName: 'AES',
      authTag: { data: tag },
      aad: { data: new Uint8Array(0) }
    };

    await decoder.init(cryptoFramework.CryptoMode.DECRYPT_MODE, key, ivSpec);

    const ciphertextWithTag = new Uint8Array(ciphertext.length + tag.length);
    ciphertextWithTag.set(ciphertext);
    ciphertextWithTag.set(tag, ciphertext.length);

    const resultBlob = await decoder.doFinal({ data: ciphertextWithTag });
    return resultBlob.data;
  }

  /**
   * 获取设备主密钥
   */
  private async getDeviceMasterKey(): Promise<Uint8Array> {
    const DEVICE_MASTER_KEY_NAME = 'hmtg_device_master_key';

    // 先尝试从安全存储加载
    if (this.encryptionPreferences) {
      try {
        const storedKey = await this.encryptionPreferences.get(DEVICE_MASTER_KEY_NAME, '') as string;
        if (storedKey) {
          const keyBytes = this.base64Decode(storedKey);
          if (keyBytes.length === 32) {
            hilog.info(SessionEncryption.DOMAIN, SessionEncryption.TAG, 'Device master key loaded from storage');
            return keyBytes;
          }
        }
      } catch (error) {
        hilog.warn(SessionEncryption.DOMAIN, SessionEncryption.TAG, 'Failed to load device master key, generating new one');
      }
    }

    // 生成新的随机密钥
    const random = cryptoFramework.createRandom();
    const newKeyBlob = await random.generateRandom(32);
    const newKey = newKeyBlob.data;

    // 持久化密钥（使用 Base64 编码）
    if (this.encryptionPreferences) {
      try {
        await this.encryptionPreferences.put(DEVICE_MASTER_KEY_NAME, this.base64Encode(newKey));
        await this.encryptionPreferences.flush();
        hilog.info(SessionEncryption.DOMAIN, SessionEncryption.TAG, 'New device master key generated and stored');
      } catch (error) {
        hilog.warn(SessionEncryption.DOMAIN, SessionEncryption.TAG, 'Failed to store device master key');
      }
    }

    return newKey;
  }

  /**
   * Base64 编码
   */
  private base64Encode(data: Uint8Array): string {
    const base64Helper = new util.Base64Helper();
    return base64Helper.encodeToStringSync(data);
  }

  /**
   * Base64 解码
   */
  private base64Decode(base64: string): Uint8Array {
    const base64Helper = new util.Base64Helper();
    return base64Helper.decodeSync(base64);
  }
}

// 导出单例实例
export const sessionEncryption = SessionEncryption.getInstance();
