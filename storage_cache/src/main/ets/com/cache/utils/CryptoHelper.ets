import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer } from '@kit.ArkTS';

export class CryptoHelper {
  private static instance: CryptoHelper;
  private static readonly KEY_STR = 'your-32-byte-secret-key-for-aes256!!'; // 实际应从安全存储获取
  private static readonly IV_LENGTH = 12;

  private constructor() {}

  static getInstance(): CryptoHelper {
    if (!CryptoHelper.instance) {
      CryptoHelper.instance = new CryptoHelper();
    }
    return CryptoHelper.instance;
  }

  private async getSymKey(): Promise<cryptoFramework.SymKey> {
    const generator = cryptoFramework.createSymKeyGenerator('AES256');
    const keyData = new Uint8Array(buffer.from(CryptoHelper.KEY_STR, 'utf-8').buffer);
    return await generator.convertKey({ data: keyData });
  }

  async encrypt(plainText: string): Promise<string> {
    const symKey = await this.getSymKey();
    const cipher = cryptoFramework.createCipher('AES256|GCM|PKCS7');
    const random = cryptoFramework.createRandom();
    const ivBlob = random.generateRandomSync(CryptoHelper.IV_LENGTH);
    const iv = new Uint8Array(ivBlob.data);
    const algParams: cryptoFramework.GcmParamsSpec = {
      iv: { data: iv }, aad: { data: new Uint8Array(0) },
      authTag: { data: new Uint8Array(16) }, algName: 'GcmParamsSpec'
    };
    await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, symKey, algParams);
    const plainData = new Uint8Array(buffer.from(plainText, 'utf-8').buffer);
    const encrypted = await cipher.doFinal({ data: plainData });
    const tag = new Uint8Array(algParams.authTag!.data);
    const result = this.concatUint8Arrays(iv, encrypted.data, tag);
    return buffer.from(result.buffer).toString('base64');
  }

  async decrypt(encryptedBase64: string): Promise<string> {
    const full = new Uint8Array(buffer.from(encryptedBase64, 'base64').buffer);
    const iv = full.slice(0, CryptoHelper.IV_LENGTH);
    const tag = full.slice(full.length - 16);
    const ciphertext = full.slice(CryptoHelper.IV_LENGTH, full.length - 16);
    const symKey = await this.getSymKey();
    const cipher = cryptoFramework.createCipher('AES256|GCM|PKCS7');
    const algParams: cryptoFramework.GcmParamsSpec = {
      iv: { data: iv }, aad: { data: new Uint8Array(0) },
      authTag: { data: tag }, algName: 'GcmParamsSpec'
    };
    await cipher.init(cryptoFramework.CryptoMode.DECRYPT_MODE, symKey, algParams);
    const decrypted = await cipher.doFinal({ data: ciphertext });
    return buffer.from(decrypted.data.buffer).toString('utf-8');
  }

  private concatUint8Arrays(...arrays: Uint8Array[]): Uint8Array {
    let total = 0;
    for (const a of arrays) total += a.length;
    const result = new Uint8Array(total);
    let offset = 0;
    for (const a of arrays) {
      result.set(a, offset);
      offset += a.length;
    }
    return result;
  }
}