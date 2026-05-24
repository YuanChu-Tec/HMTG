/**
 * 手机号输入组件（Nekogram 式：区号与号码均为手动输入）
 * 区号仅允许 + 与数字，最大长度（含 +）如 +353
 */

const COUNTRY_CODE_MAX_LEN = 5;

// 硬编码样式常量（Auth 模块不使用主题系统）
const COLOR_TEXT_PRIMARY = '#000000';
const COLOR_TEXT_TERTIARY = '#9DA3A8';
const COLOR_BACKGROUND_SECONDARY = '#F5F5F5';

const SPACING_SM = 8;
const SPACING_MD = 12;

const RADIUS_MD = 12;

const FONT_SIZE_BODY_L = 16;

@Component
export struct PhoneInputComponent {
  @Link phoneNumber: string;
  @Link countryCode: string;
  @Prop placeholder: Resource = $r('app.string.auth_country_code_placeholder');
  @Prop countryCodePlaceholder: Resource = $r('app.string.auth_country_code_placeholder'); // 区号占位符
  @Prop maxLength: number = 15;
  onPhoneChange?: (phone: string) => void;
  onCountryCodeChange?: (code: string) => void;
  /** 规范化区号：只保留 + 与数字，保证以 + 开头（E.164），如 +86、+1 */
  private normalizeCountryCode(raw: string): string {
    const s = raw.trim();
    let result = '+';
    for (let i = 0; i < s.length; i++) {
      const c = s.charAt(i);
      if (c >= '0' && c <= '9') {
        result = result + c;
      }
    }
    if (result.length === 1) {
      return '';
    }
    if (result.length > COUNTRY_CODE_MAX_LEN) {
      result = result.substring(0, COUNTRY_CODE_MAX_LEN);
    }
    return result;
  }

  build() {
    Row() {
      TextInput({
        placeholder: this.countryCodePlaceholder,
        text: this.countryCode
      })
        .width(72)
        .fontSize(FONT_SIZE_BODY_L)
        .fontColor(COLOR_TEXT_PRIMARY)
        .placeholderColor(COLOR_TEXT_TERTIARY)
        .maxLength(COUNTRY_CODE_MAX_LEN)
        .type(InputType.Normal)
        .onChange((value: string) => {
          const normalized = this.normalizeCountryCode(value);
          this.countryCode = normalized;
          this.onCountryCodeChange?.(normalized);
        })

      Divider()
        .vertical(true)
        .height(24)
        .margin({ left: SPACING_SM, right: SPACING_SM })

      TextInput({ placeholder: this.placeholder, text: this.phoneNumber })
        .fontSize(FONT_SIZE_BODY_L)
        .fontColor(COLOR_TEXT_PRIMARY)
        .placeholderColor(COLOR_TEXT_TERTIARY)
        .maxLength(this.maxLength)
        .type(InputType.Number)
        .layoutWeight(1)
        .onChange((value: string) => {
          this.phoneNumber = value;
          this.onPhoneChange?.(value);
        })
    }
    .width('100%')
    .height(56)
    .backgroundColor(COLOR_BACKGROUND_SECONDARY)
    .borderRadius(RADIUS_MD)
    .padding({ left: SPACING_SM, right: SPACING_MD })
  }
}
