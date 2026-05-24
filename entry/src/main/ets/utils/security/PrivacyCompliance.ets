import { ErrorContext } from '../error/AppError';

/**
 * 隐私合规工具类
 */
export class PrivacyCompliance {
  private static consentMap: Map<string, boolean> = new Map();
  private static readonly CONSENT_TYPES: Map<string, string> = new Map([
    ['ANALYTICS', 'analytics_consent'],
    ['MARKETING', 'marketing_consent'],
    ['PERSONALIZATION', 'personalization_consent'],
    ['DATA_SHARING', 'data_sharing_consent']
  ]);

  /**
   * 检查用户是否已同意指定类型的隐私政策
   */
  public static hasConsent(consentType: string): boolean {
    const consent = PrivacyCompliance.consentMap.get(consentType);
    return consent ? consent : false;
  }

  /**
   * 设置用户同意状态
   */
  public static setConsent(consentType: string, agreed: boolean): void {
    PrivacyCompliance.consentMap.set(consentType, agreed);
  }

  /**
   * 检查分析数据收集同意
   */
  public static hasAnalyticsConsent(): boolean {
    const consentType = PrivacyCompliance.CONSENT_TYPES.get('ANALYTICS');
    if (!consentType) {
      return false;
    }
    return PrivacyCompliance.hasConsent(consentType);
  }

  /**
   * 设置分析数据收集同意
   */
  public static setAnalyticsConsent(agreed: boolean): void {
    const consentType = PrivacyCompliance.CONSENT_TYPES.get('ANALYTICS');
    if (consentType) {
      PrivacyCompliance.setConsent(consentType, agreed);
    }
  }

  /**
   * 检查营销数据收集同意
   */
  public static hasMarketingConsent(): boolean {
    const consentType = PrivacyCompliance.CONSENT_TYPES.get('MARKETING');
    if (!consentType) {
      return false;
    }
    return PrivacyCompliance.hasConsent(consentType);
  }

  /**
   * 设置营销数据收集同意
   */
  public static setMarketingConsent(agreed: boolean): void {
    const consentType = PrivacyCompliance.CONSENT_TYPES.get('MARKETING');
    if (consentType) {
      PrivacyCompliance.setConsent(consentType, agreed);
    }
  }

  /**
   * 检查个性化数据收集同意
   */
  public static hasPersonalizationConsent(): boolean {
    const consentType = PrivacyCompliance.CONSENT_TYPES.get('PERSONALIZATION');
    if (!consentType) {
      return false;
    }
    return PrivacyCompliance.hasConsent(consentType);
  }

  /**
   * 设置个性化数据收集同意
   */
  public static setPersonalizationConsent(agreed: boolean): void {
    const consentType = PrivacyCompliance.CONSENT_TYPES.get('PERSONALIZATION');
    if (consentType) {
      PrivacyCompliance.setConsent(consentType, agreed);
    }
  }

  /**
   * 检查数据共享同意
   */
  public static hasDataSharingConsent(): boolean {
    const consentType = PrivacyCompliance.CONSENT_TYPES.get('DATA_SHARING');
    if (!consentType) {
      return false;
    }
    return PrivacyCompliance.hasConsent(consentType);
  }

  /**
   * 设置数据共享同意
   */
  public static setDataSharingConsent(agreed: boolean): void {
    const consentType = PrivacyCompliance.CONSENT_TYPES.get('DATA_SHARING');
    if (consentType) {
      PrivacyCompliance.setConsent(consentType, agreed);
    }
  }

  /**
   * 检查是否必须获取同意（GDPR要求）
   */
  public static needsConsent(): boolean {
    return !PrivacyCompliance.hasAnalyticsConsent() ||
           !PrivacyCompliance.hasMarketingConsent() ||
           !PrivacyCompliance.hasPersonalizationConsent();
  }

  /**
   * 获取所有同意状态
   */
  public static getAllConsents(): ErrorContext {
    const resultData: Map<string, Object> = new Map();
    resultData.set('analytics', PrivacyCompliance.hasAnalyticsConsent());
    resultData.set('marketing', PrivacyCompliance.hasMarketingConsent());
    resultData.set('personalization', PrivacyCompliance.hasPersonalizationConsent());
    resultData.set('dataSharing', PrivacyCompliance.hasDataSharingConsent());
    return ErrorContext.fromMap(resultData);
  }

  /**
   * 重置所有同意状态
   */
  public static resetAllConsents(): void {
    PrivacyCompliance.consentMap.clear();
  }
}
