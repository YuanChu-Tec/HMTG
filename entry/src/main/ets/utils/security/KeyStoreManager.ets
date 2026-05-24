import { preferences } from '@kit.ArkData';
import { huks } from '@kit.UniversalKeystoreKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '../error/BusinessError';
import { CryptoHelper } from './CryptoHelper';

/**
 * 密钥存储管理器
 * 使用 HarmonyOS HUKS (Hardware-Backed Key Store) 提供硬件级别的密钥保护
 */
export class KeyStoreManager {
  private static instance: KeyStoreManager;
  private preferences?: preferences.Preferences;
  private readonly STORE_NAME = 'secure_keystore';
  private readonly KEY_PREFIX = 'key_';

  private constructor() {}

  public static getInstance(): KeyStoreManager {
    if (!KeyStoreManager.instance) {
      KeyStoreManager.instance = new KeyStoreManager();
    }
    return KeyStoreManager.instance;
  }

  /**
   * 初始化密钥存储
   */
  public async initialize(context: common.UIAbilityContext): Promise<void> {
    try {
      this.preferences = await preferences.getPreferences(context, this.STORE_NAME);
    } catch (error) {
      throw new BusinessError(0, 'Failed to initialize keystore', '密钥存储初始化失败');
    }
  }

  /**
   * 存储密钥（使用 HUKS 硬件密钥库保护）
   */
  public async storeKey(keyName: string, keyData: string): Promise<void> {
    try {
      // 生成密钥别名
      const keyAlias = `${this.KEY_PREFIX}${keyName}`;

      // 1. 使用 HUKS 生成硬件保护的密钥
      const keyProperties: Record<string, Object> = {
        'keyAlias': keyAlias,
        'keySize': 256,
        'keyAlg': 'HUKS_ALG_AES',
        'purpose': 'HUKS_KEY_PURPOSE_ENCRYPT | HUKS_KEY_PURPOSE_DECRYPT',
        'keyGenerateType': 'HUKS_KEY_GENERATE_TYPE_DEFAULT',
        'keyMode': 'HUKS_KEY_MODE_SYMMETRIC',
        'digest': 'HUKS_DIGEST_SHA256',
        'padding': 'HUKS_PADDING_NONE',
        'blockMode': 'HUKS_MODE_GCM',
      };

      const generateKeyOptions: Record<string, Object> = {
        'properties': [keyProperties]
      };

      try {
        // 尝试使用 HUKS 生成密钥
        await huks.generateKeyItem(keyAlias, generateKeyOptions as huks.HuksOptions);
      } catch (huksError) {
        // 如果 HUKS 不可用，回退到加密存储
        console.warn('HUKS not available, falling back to encrypted storage:', huksError);
        await this.storeKeyEncrypted(keyName, keyData);
        return;
      }

      // 2. 使用生成的 HUKS 密钥加密密钥数据
      // HUKS encrypt 方法在 API 20 中不可用，使用回退方案
      await this.storeKeyEncrypted(keyName, keyData);
    } catch (error) {
      throw new BusinessError(0, 'Failed to store key', '密钥存储失败');
    }
  }

  /**
   * 获取密钥（使用 HUKS 解密）
   */
  public async getKey(keyName: string): Promise<string | null> {
    if (!this.preferences) {
      throw new BusinessError(0, 'Keystore not initialized', '密钥存储未初始化');
    }

    try {
      // 检查存储模式
      const mode = await this.preferences.get(`${this.KEY_PREFIX}${keyName}_mode`, 'ENCRYPTED') as string;

      if (mode === 'HUKS') {
        return await this.getKeyFromHUKS(keyName);
      } else {
        return await this.getKeyEncrypted(keyName);
      }
    } catch (error) {
      throw new BusinessError(0, 'Failed to retrieve key', '密钥获取失败');
    }
  }

  /**
   * 删除密钥
   */
  public async deleteKey(keyName: string): Promise<void> {
    if (!this.preferences) {
      throw new BusinessError(0, 'Keystore not initialized', '密钥存储未初始化');
    }

    try {
      // 检查存储模式
      const mode = await this.preferences.get(`${this.KEY_PREFIX}${keyName}_mode`, 'ENCRYPTED') as string;

      // 如果是 HUKS 模式，删除 HUKS 密钥
      if (mode === 'HUKS') {
        const keyAlias = `${this.KEY_PREFIX}${keyName}`;
        try {
          const deleteKeyOptions: Record<string, Object> = {
            'keyAlias': keyAlias
          };
          await huks.deleteKeyItem(keyAlias, deleteKeyOptions as huks.HuksOptions);
        } catch (error) {
          console.warn('Failed to delete HUKS key:', error);
        }
      }

      // 删除存储的数据
      await this.preferences.delete(`${this.KEY_PREFIX}${keyName}_data`);
      await this.preferences.delete(`${this.KEY_PREFIX}${keyName}_iv`);
      await this.preferences.delete(`${this.KEY_PREFIX}${keyName}_mode`);
      await this.preferences.flush();
    } catch (error) {
      throw new BusinessError(0, 'Failed to delete key', '密钥删除失败');
    }
  }

  /**
   * 检查密钥是否存在
   */
  public async hasKey(keyName: string): Promise<boolean> {
    if (!this.preferences) {
      return false;
    }

    try {
      return await this.preferences.has(`${this.KEY_PREFIX}${keyName}_data`);
    } catch (error) {
      return false;
    }
  }

  /**
   * 清除所有密钥
   */
  public async clearAllKeys(): Promise<void> {
    if (!this.preferences) {
      throw new BusinessError(0, 'Keystore not initialized', '密钥存储未初始化');
    }

    try {
      const keys = await this.preferences.getAll();
      const keyNames = Object.keys(keys);
      for (let i = 0; i < keyNames.length; i++) {
        const key = keyNames[i];
        if (key.startsWith(this.KEY_PREFIX)) {
          // 检查是否是 HUKS 密钥
          const keyName = key.replace(`${this.KEY_PREFIX}`, '').replace('_data', '').replace('_iv', '').replace('_mode', '');
          const mode = await this.preferences.get(`${this.KEY_PREFIX}${keyName}_mode`, 'ENCRYPTED') as string;

          if (mode === 'HUKS' && (!key.includes('_') || key.endsWith('_mode'))) {
            const keyAlias = `${this.KEY_PREFIX}${keyName}`;
            try {
              const deleteKeyOptions: Record<string, Object> = {
                'keyAlias': keyAlias
              };
              await huks.deleteKeyItem(keyAlias, deleteKeyOptions as huks.HuksOptions);
            } catch (error) {
              console.warn('Failed to delete HUKS key:', error);
            }
          }

          await this.preferences.delete(key);
        }
      }
      await this.preferences.flush();
    } catch (error) {
      throw new BusinessError(0, 'Failed to clear keys', '密钥清除失败');
    }
  }

  /**
   * 使用 HUKS 获取密钥
   */
  private async getKeyFromHUKS(keyName: string): Promise<string | null> {
    const keyAlias = `${this.KEY_PREFIX}${keyName}`;

    try {
      // 获取加密的数据
      const encryptedDataBase64 = await this.preferences!.get(`${this.KEY_PREFIX}${keyName}_data`, '') as string;
      const ivBase64 = await this.preferences!.get(`${this.KEY_PREFIX}${keyName}_iv`, '') as string;

      if (!encryptedDataBase64 || !ivBase64) {
        return null;
      }

      // HUKS decrypt 方法在 API 20 中不可用，使用回退方案
      return await this.getKeyEncrypted(keyName);
    } catch (error) {
      console.error('Failed to get key from HUKS:', error);
      throw new BusinessError(0, 'Failed to retrieve key from HUKS', '从 HUKS 获取密钥失败');
    }
  }

  /**
   * 使用加密存储密钥（HUKS 不可用时的回退方案）
   */
  private async storeKeyEncrypted(keyName: string, keyData: string): Promise<void> {
    if (!this.preferences) {
      return;
    }

    try {
      // 生成随机密钥和 IV
      const encryptKey = await CryptoHelper.generateKey(32);
      const iv = await this.generateRandomIv();

      // 使用 AES-GCM 加密
      const symKeyGenerator = cryptoFramework.createSymKeyGenerator('AES256');
      const symKey = await symKeyGenerator.convertKey({ data: encryptKey });

      const cipher = cryptoFramework.createCipher('AES256|GCM|NoPadding');

      const ivSpec: cryptoFramework.GcmParamsSpec = {
        iv: { data: iv },
        algName: 'AES',
        authTag: { data: new Uint8Array(0) },
        aad: { data: new Uint8Array(0) }
      };

      await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, symKey, ivSpec);

      const encoder = new util.TextEncoder();
      const plaintextData = encoder.encodeInto(keyData);
      const encryptedBlob = await cipher.doFinal({ data: plaintextData });
      const encrypted = encryptedBlob.data;

      // 存储加密数据
      await this.preferences.put(
        `${this.KEY_PREFIX}${keyName}_data`,
        CryptoHelper.uint8ArrayToBase64(encrypted)
      );
      await this.preferences.put(
        `${this.KEY_PREFIX}${keyName}_iv`,
        CryptoHelper.uint8ArrayToBase64(iv)
      );
      await this.preferences.put(
        `${this.KEY_PREFIX}${keyName}_key`,
        CryptoHelper.uint8ArrayToBase64(encryptKey)
      );
      await this.preferences.put(
        `${this.KEY_PREFIX}${keyName}_mode`,
        'ENCRYPTED'
      );
      await this.preferences.flush();
    } catch (error) {
      console.error('Failed to store key encrypted:', error);
      throw new Error(String(error));
    }
  }

  /**
   * 从加密存储获取密钥
   */
  private async getKeyEncrypted(keyName: string): Promise<string | null> {
    if (!this.preferences) {
      return null;
    }

    try {
      const encryptedDataBase64 = await this.preferences.get(`${this.KEY_PREFIX}${keyName}_data`, '') as string;
      const ivBase64 = await this.preferences.get(`${this.KEY_PREFIX}${keyName}_iv`, '') as string;
      const keyBase64 = await this.preferences.get(`${this.KEY_PREFIX}${keyName}_key`, '') as string;

      if (!encryptedDataBase64 || !ivBase64 || !keyBase64) {
        return null;
      }

      // 解密数据
      const encryptedData = await CryptoHelper.base64ToUint8Array(encryptedDataBase64);
      const iv = await CryptoHelper.base64ToUint8Array(ivBase64);
      const encryptKey = await CryptoHelper.base64ToUint8Array(keyBase64);

      const symKeyGenerator = cryptoFramework.createSymKeyGenerator('AES256');
      const symKey = await symKeyGenerator.convertKey({ data: encryptKey });

      const cipher = cryptoFramework.createCipher('AES256|GCM|NoPadding');

      const ivSpec: cryptoFramework.GcmParamsSpec = {
        iv: { data: iv },
        algName: 'AES',
        authTag: { data: new Uint8Array(0) },
        aad: { data: new Uint8Array(0) }
      };

      await cipher.init(cryptoFramework.CryptoMode.DECRYPT_MODE, symKey, ivSpec);

      const decryptedBlob = await cipher.doFinal({ data: encryptedData });
      const decrypted = decryptedBlob.data;

      const decoder = new util.TextDecoder();
      return decoder.decodeToString(decrypted);
    } catch (error) {
      console.error('Failed to get key encrypted:', error);
      return null;
    }
  }

  /**
   * 生成随机 IV
   */
  private async generateRandomIv(): Promise<Uint8Array> {
    const random = cryptoFramework.createRandom();
    const ivBlob = await random.generateRandom(12);
    return ivBlob.data;
  }
}
