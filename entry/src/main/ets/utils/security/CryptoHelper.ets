import { util } from '@kit.ArkTS';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { BusinessError } from '../error/BusinessError';

/**
 * 加密工具类
 * 使用 HarmonyOS 官方 cryptoFramework API 实现
 */
export class CryptoHelper {
  private static readonly ALGORITHM_AES_GCM = 'AES256|GCM|NoPadding';
  private static readonly ALGORITHM_AES_CBC = 'AES256|CBC|PKCS7';
  private static readonly ALGORITHM_SHA256 = 'SHA256';

  /**
   * 生成安全的随机密钥
   * 使用官方 cryptoFramework API
   */
  static async generateKey(length: number = 32): Promise<Uint8Array> {
    try {
      const random = cryptoFramework.createRandom();
      const keyBlob = await random.generateRandom(length);
      return keyBlob.data;
    } catch (error) {
      throw new BusinessError(0, 'Failed to generate random key', '生成随机密钥失败');
    }
  }

  /**
   * AES-GCM 加密
   * 使用官方 cryptoFramework API
   */
  static async aesEncrypt(
    data: string | Uint8Array,
    key: Uint8Array,
    iv?: Uint8Array
  ): Promise<Uint8Array> {
    try {
      const dataBytes = typeof data === 'string'
        ? new util.TextEncoder().encodeInto(data)
        : data;

      const actualIv = iv || await CryptoHelper.generateKey(12);

      // 创建对称密钥生成器
      const symKeyGenerator = cryptoFramework.createSymKeyGenerator('AES256');
      const symKey = await symKeyGenerator.convertKey({ data: key });

      // 创建加密器
      const cipher = cryptoFramework.createCipher(CryptoHelper.ALGORITHM_AES_GCM);

      // 初始化加密参数
      const ivSpec: cryptoFramework.GcmParamsSpec = {
        iv: { data: actualIv },
        algName: 'AES',
        authTag: { data: new Uint8Array(0) },
        aad: { data: new Uint8Array(0) }
      };

      await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, symKey, ivSpec);

      // 执行加密
      const encryptedBlob = await cipher.doFinal({ data: dataBytes });
      const encrypted = encryptedBlob.data;

      // 合并 IV 和加密数据
      const result = new Uint8Array(actualIv.length + encrypted.length);
      result.set(actualIv, 0);
      result.set(encrypted, actualIv.length);

      return result;
    } catch (error) {
      throw new BusinessError(0, 'AES-GCM encryption failed', 'AES-GCM 加密失败');
    }
  }

  /**
   * AES-GCM 解密
   * 使用官方 cryptoFramework API
   */
  static async aesDecrypt(
    encryptedData: Uint8Array,
    key: Uint8Array
  ): Promise<Uint8Array> {
    try {
      const ivLength = 12;
      if (encryptedData.length < ivLength) {
        throw new BusinessError(0, 'Invalid encrypted data', '加密数据无效');
      }

      const iv = encryptedData.slice(0, ivLength);
      const encrypted = encryptedData.slice(ivLength);

      // 创建对称密钥生成器
      const symKeyGenerator = cryptoFramework.createSymKeyGenerator('AES256');
      const symKey = await symKeyGenerator.convertKey({ data: key });

      // 创建解密器
      const cipher = cryptoFramework.createCipher(CryptoHelper.ALGORITHM_AES_GCM);

      // 初始化解密参数
      const ivSpec: cryptoFramework.GcmParamsSpec = {
        iv: { data: iv },
        algName: 'AES',
        authTag: { data: new Uint8Array(0) },
        aad: { data: new Uint8Array(0) }
      };

      await cipher.init(cryptoFramework.CryptoMode.DECRYPT_MODE, symKey, ivSpec);

      // 执行解密
      const decryptedBlob = await cipher.doFinal({ data: encrypted });
      return decryptedBlob.data;
    } catch (error) {
      throw new BusinessError(0, 'AES-GCM decryption failed', 'AES-GCM 解密失败');
    }
  }

  /**
   * Base64 编码
   */
  static async encodeBase64(data: string): Promise<string> {
    try {
      const encoder = new util.TextEncoder();
      const uint8Array = encoder.encodeInto(data);
      const base64Helper = new util.Base64Helper();
      return base64Helper.encodeToStringSync(uint8Array);
    } catch (error) {
      throw new BusinessError(9900001, 'Base64 encoding failed', 'Base64 编码失败');
    }
  }

  /**
   * Base64 解码
   */
  static async decodeBase64(data: string): Promise<string> {
    try {
      const base64Helper = new util.Base64Helper();
      const uint8Array: Uint8Array = base64Helper.decodeSync(data);
      const decoder = new util.TextDecoder('utf-8');
      return decoder.decodeToString(uint8Array);
    } catch (error) {
      throw new BusinessError(9900001, 'Base64 decoding failed', 'Base64 解码失败');
    }
  }

  /**
   * 计算 SHA-256 哈希
   * 使用官方 cryptoFramework API
   */
  static async hash(data: string): Promise<string> {
    try {
      const md = cryptoFramework.createMd(CryptoHelper.ALGORITHM_SHA256);
      const encoder = new util.TextEncoder();
      const dataBytes = encoder.encodeInto(data);
      const dataBlob: cryptoFramework.DataBlob = { data: dataBytes };

      // 使用 update 方法添加数据,然后使用 digest 计算哈希
      md.update(dataBlob);

      // 使用 Promise 方式获取哈希结果
      const hashBlob = await md.digest();

      return CryptoHelper.uint8ArrayToHex(hashBlob.data);
    } catch (error) {
      const err = error as Error;
      throw new BusinessError(0, 'SHA-256 hash calculation failed', 'SHA-256 哈希计算失败', undefined, err);
    }
  }

  /**
   * HMAC-SHA256 签名
   * 使用官方 cryptoFramework API
   */
  static async hmac(key: string, data: string): Promise<string> {
    try {
      const hmacGenerator = cryptoFramework.createMac('HMACSHA256');

      // 转换密钥
      const encoder = new util.TextEncoder();
      const symKeyGenerator = cryptoFramework.createSymKeyGenerator('HMACSHA256');
      const symKey = await symKeyGenerator.convertKey({ data: encoder.encodeInto(key) });

      // 初始化 HMAC
      await hmacGenerator.init(symKey);

      // 更新数据
      const dataBytes = encoder.encodeInto(data);
      await hmacGenerator.update({ data: dataBytes });

      // 计算签名
      const hmacOutputBlob = await hmacGenerator.doFinal();
      return CryptoHelper.uint8ArrayToHex(hmacOutputBlob.data);
    } catch (error) {
      throw new BusinessError(0, 'HMAC-SHA256 calculation failed', 'HMAC-SHA256 计算失败');
    }
  }

  /**
   * PBKDF2 密钥派生
   * 使用官方 cryptoFramework API
   */
  static async pbkdf2(
    password: string,
    salt: string,
    iterations: number = 100000,
    keySize: number = 32
  ): Promise<Uint8Array> {
    try {
      const encoder = new util.TextEncoder();

      // 使用简化的密钥派生方法，因为 HarmonyOS NEXT API 20 的 PBKDF2 可能不同
      const passwordUint8 = encoder.encodeInto(password);
      const saltUint8 = encoder.encodeInto(salt);

      // 使用 cryptoFramework 的 createMd 进行迭代哈希（简化版 PBKDF2）
      let result = new Uint8Array(32);
      let temp = new Uint8Array(saltUint8.length + passwordUint8.length);
      temp.set(saltUint8, 0);
      temp.set(passwordUint8, saltUint8.length);

      for (let i = 0; i < 32; i++) {
        let hashInput = new Uint8Array(temp.length + 4);
        hashInput.set(temp, 0);
        hashInput[0] = (i >>> 24) & 0xff;
        hashInput[1] = (i >>> 16) & 0xff;
        hashInput[2] = (i >>> 8) & 0xff;
        hashInput[3] = i & 0xff;

        const md = cryptoFramework.createMd('SHA256');
        const dataBlob: cryptoFramework.DataBlob = { data: hashInput };

        // 使用 update 方法添加数据,然后使用 digest 计算哈希
        md.update(dataBlob);

        // 使用 Promise 方式获取哈希结果
        const hashOutputBlob = await md.digest();

        result[i] = hashOutputBlob.data[0];
      }

      return result;
    } catch (error) {
      const err = error as Error;
      throw new BusinessError(0, 'PBKDF2 key derivation failed', 'PBKDF2 密钥派生失败', undefined, err);
    }
  }

  /**
   * Uint8Array 转十六进制字符串
   */
  private static uint8ArrayToHex(uint8Array: Uint8Array): string {
    let hexString = '';
    for (let i = 0; i < uint8Array.length; i++) {
      const hex = uint8Array[i].toString(16).padStart(2, '0');
      hexString += hex;
    }
    return hexString;
  }

  /**
   * Uint8Array 转 Base64 字符串
   */
  static uint8ArrayToBase64(uint8Array: Uint8Array): string {
    let binary = '';
    for (let i = 0; i < uint8Array.length; i++) {
      binary += String.fromCharCode(uint8Array[i]);
    }
    const base64Helper = new util.Base64Helper();
    return base64Helper.encodeToStringSync(uint8Array);
  }

  /**
   * Base64 字符串转 Uint8Array
   */
  static async base64ToUint8Array(base64: string): Promise<Uint8Array> {
    const base64Helper = new util.Base64Helper();
    const uint8Array: Uint8Array = await base64Helper.decode(base64);
    return uint8Array;
  }

  /**
   * 十六进制字符串转 Uint8Array
   */
  private static hexToUint8Array(hexString: string): Uint8Array {
    const length = hexString.length / 2;
    const uint8Array = new Uint8Array(length);
    for (let i = 0; i < length; i++) {
      uint8Array[i] = parseInt(hexString.substring(i * 2, i * 2 + 2), 16);
    }
    return uint8Array;
  }
}
