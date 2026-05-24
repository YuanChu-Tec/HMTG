/**
 * 锁定码助手（参考 Nekogram PasscodeHelper）
 */
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

const PREF_NAME = 'hmtg_passcode';
const KEY_HASH = 'passcode_hash';

export class PasscodeHelper {
  private static prefs: preferences.Preferences | null = null;
  private static ctx: common.UIAbilityContext | null = null;

  static async init(context?: common.UIAbilityContext): Promise<void> {
    if (context) {
      PasscodeHelper.ctx = context;
    }
    if (PasscodeHelper.prefs) return;
    if (!PasscodeHelper.ctx) return;
    try {
      PasscodeHelper.prefs = await preferences.getPreferences(PasscodeHelper.ctx, PREF_NAME);
    } catch (_) {}
  }

  static async hasPasscode(): Promise<boolean> {
    if (!PasscodeHelper.prefs) return false;
    try {
      const hash = await PasscodeHelper.prefs.get(KEY_HASH, '') as string;
      return hash.length > 0;
    } catch (_) {
      return false;
    }
  }

  static async checkPasscode(code: string): Promise<boolean> {
    if (!PasscodeHelper.prefs) return false;
    try {
      const stored = await PasscodeHelper.prefs.get(KEY_HASH, '') as string;
      return stored === PasscodeHelper.simpleHash(code);
    } catch (_) {
      return false;
    }
  }

  static async setPasscode(code: string): Promise<void> {
    if (!PasscodeHelper.prefs) return;
    await PasscodeHelper.prefs.put(KEY_HASH, PasscodeHelper.simpleHash(code));
    await PasscodeHelper.prefs.flush();
  }

  static async removePasscode(): Promise<void> {
    if (!PasscodeHelper.prefs) return;
    await PasscodeHelper.prefs.delete(KEY_HASH);
    await PasscodeHelper.prefs.flush();
  }

  private static simpleHash(s: string): string {
    let h = 0;
    for (let i = 0; i < s.length; i++) {
      h = ((h << 5) - h) + s.charCodeAt(i);
      h = h & h;
    }
    return String(h);
  }
}
