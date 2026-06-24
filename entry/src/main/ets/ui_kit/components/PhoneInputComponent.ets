/**
 * 手机号输入组件（完整参考 Telegram LoginActivity PhoneView）
 * 实现所有核心逻辑：区号匹配、数字转移、光标控制、格式化显示
 */

import { CountryCodeHelper, CountryInfo } from '../../utils/CountryCodeHelper';

const COUNTRY_STATE_EMPTY = 0;
const COUNTRY_STATE_NOT_SET_OR_VALID = 1;
const COUNTRY_STATE_INVALID = 2;

const COLOR_TEXT_PRIMARY = '#000000';
const COLOR_TEXT_TERTIARY = '#9DA3A8';
const COLOR_BACKGROUND = '#FFFFFF';
const COLOR_DIVIDER = '#E0E0E0';
const COLOR_BORDER_FOCUS = '#0088CC';
const COLOR_BORDER_NORMAL = '#E0E0E0';

const SPACING_SM = 8;
const SPACING_MD = 16;
const SPACING_XS = 4;

const RADIUS_MD = 12;

const FONT_SIZE_BODY = 16;
const INPUT_HEIGHT = 56;
const INNER_INPUT_HEIGHT = 36;

@ComponentV2
export struct PhoneInputComponent {
  @Param placeholder: Resource = $r('app.string.enter_phone_placeholder');
  @Param countryCodePlaceholder: Resource = $r('app.string.auth_country_code_placeholder');
  @Param maxLength: number = 15;
  @Param countryCode: string = '';
  @Param phoneNumber: string = '';
  @Event onPhoneChange?: (phone: string) => void;
  @Event onCountryCodeChange?: (code: string) => void;
  @Event onCountryClick?: () => void;
  @Event onCountryMatched?: (country: CountryInfo) => void;
  
  @Local inputCountryCode: string = '';
  @Local inputPhoneNumber: string = '';
  @Local isFocused: boolean = false;
  @Local currentCountry: CountryInfo | null = null;
  @Local ignoreTextChange: boolean = false;
  @Local ignoreOnPhoneChange: boolean = false;
  @Local ignoreOnPhoneChangePaste: boolean = false;
  @Local phonePlaceholder: string = '';
  @Local codeInputFocused: boolean = false;
  @Local phoneInputFocused: boolean = false;
  @Local countryState: number = COUNTRY_STATE_EMPTY;
  
  @Local characterAction: number = -1;
  @Local actionPosition: number = 0;

  aboutToAppear(): void {
    this.inputCountryCode = this.countryCode;
    this.inputPhoneNumber = this.phoneNumber;
    if (this.inputCountryCode) {
      this.updateCountryInfo(this.inputCountryCode);
    }
    // 初始化时触发回调，确保 LoginPage 的 countryCode 被正确设置
    if (this.onCountryCodeChange) {
      this.onCountryCodeChange(this.inputCountryCode.length > 0 ? '+' + this.inputCountryCode : '');
    }
  }

  private getPhonePlaceholder(): string {
    // 不再显示格式占位符，直接显示空
    return '';
  }

  private updateCountryInfo(code: string): void {
    const countries = CountryCodeHelper.findCountriesByCode(code);
    if (countries.length > 0) {
      this.currentCountry = countries[0];
      this.phonePlaceholder = this.getPhonePlaceholder();
      this.countryState = COUNTRY_STATE_NOT_SET_OR_VALID;
      if (this.onCountryMatched) {
        this.onCountryMatched(this.currentCountry);
      }
    } else {
      this.currentCountry = null;
      this.phonePlaceholder = '';
      this.countryState = COUNTRY_STATE_INVALID;
    }
  }

  private formatPhoneNumber(countryCode: string, phone: string): string {
    // 直接返回纯数字，不再格式化显示
    return phone;
  }

  private onCodeFieldChange(value: string): void {
    if (this.ignoreTextChange) {
      return;
    }
    
    this.ignoreTextChange = true;
    
    try {
      const text = value.replace(/\D/g, '');
      
      if (text.length === 0) {
        this.inputCountryCode = '';
        // 参考 Telegram：清空区号时不清空手机号，只清空 hint
        this.currentCountry = null;
        this.phonePlaceholder = '';
        this.countryState = COUNTRY_STATE_EMPTY;
        if (this.onCountryCodeChange) {
          this.onCountryCodeChange('');
        }
        return;
      }
      
      let matchedCountry: CountryInfo | null = null;
      let ok = false;
      let textToSet: string | null = null;
      
      if (text.length > 4) {
        for (let a = 4; a >= 1; a--) {
          const sub = text.substring(0, a);
          const list = CountryCodeHelper.findCountriesByCode(sub);
          
          if (list.length > 0) {
            matchedCountry = list[0];
            ok = true;
            textToSet = text.substring(a) + this.inputPhoneNumber.replace(/\s/g, '');
            this.inputCountryCode = sub;
            break;
          }
        }
        
        if (!ok) {
          textToSet = text.substring(1) + this.inputPhoneNumber.replace(/\s/g, '');
          this.inputCountryCode = text.substring(0, 1);
        }
      } else {
        this.inputCountryCode = text;
      }
      
      let lastMatchedCountry: CountryInfo | null = null;
      let matchedCountries = 0;
      
      const allCountries = CountryCodeHelper.getAllCountries();
      for (const c of allCountries) {
        if (c.code.startsWith(this.inputCountryCode)) {
          matchedCountries++;
          if (c.code === this.inputCountryCode) {
            if (lastMatchedCountry != null && lastMatchedCountry.code === c.code) {
              matchedCountries--;
            }
            lastMatchedCountry = c;
          }
        }
      }
      
      if (matchedCountries === 1 && lastMatchedCountry != null && textToSet == null) {
        const countryCodeLen = lastMatchedCountry.code.length;
        if (this.inputCountryCode.length > countryCodeLen) {
          textToSet = this.inputCountryCode.substring(countryCodeLen) + this.inputPhoneNumber.replace(/\s/g, '');
          this.inputCountryCode = lastMatchedCountry.code;
        }
      }
      
      const list = CountryCodeHelper.findCountriesByCode(this.inputCountryCode);
      if (list.length > 0) {
        matchedCountry = list[0];
      }
      
      if (matchedCountry != null) {
        this.currentCountry = matchedCountry;
        this.phonePlaceholder = this.getPhonePlaceholder();
        this.countryState = COUNTRY_STATE_NOT_SET_OR_VALID;
        if (this.onCountryMatched) {
          this.onCountryMatched(matchedCountry);
        }
      } else {
        this.currentCountry = null;
        this.phonePlaceholder = '';
        this.countryState = COUNTRY_STATE_INVALID;
      }
      
      if (textToSet != null && textToSet.length > 0) {
        this.inputPhoneNumber = textToSet;
        if (this.onPhoneChange) {
          this.onPhoneChange(textToSet);
        }
        // 自动聚焦到手机号输入框（参考 Telegram phoneField.requestFocus）
        setTimeout(() => {
          focusControl.requestFocus('phoneInput');
        }, 50);
      }
      
      if (this.onCountryCodeChange) {
        this.onCountryCodeChange('+' + this.inputCountryCode);
      }
    } finally {
      this.ignoreTextChange = false;
    }
  }

  private onPhoneFieldChange(value: string): void {
    if (this.ignoreOnPhoneChange) {
      return;
    }
    
    // 去除所有非数字字符（包括空格、下划线等），只保留数字
    let digitsOnly = '';
    for (let i = 0; i < value.length; i++) {
      const ch = value.charAt(i);
      if (ch >= '0' && ch <= '9') {
        digitsOnly += ch;
      }
    }
    
    // 粘贴处理：只在输入长度突变（一次性增加超过2个字符）时触发
    // 参考 Telegram ENABLE_PASTED_TEXT_PROCESSING
    const prevLength = this.inputPhoneNumber.length;
    const isPasted = digitsOnly.length > prevLength + 2;
    
    if (digitsOnly.length > 0 && !this.ignoreOnPhoneChangePaste && isPasted) {
      this.ignoreOnPhoneChangePaste = true;
      try {
        for (let i = Math.min(3, digitsOnly.length); i >= 1; i--) {
          const code = digitsOnly.substring(0, i);
          const list = CountryCodeHelper.findCountriesByCode(code);
          
          if (list.length > 0) {
            const country = list[0];
            const pattern = country.pattern || '';
            
            // 计算 pattern 中 X 的数量（手机号位数）
            let patternDigits = 0;
            for (let j = 0; j < pattern.length; j++) {
              if (pattern.charAt(j) === 'X') {
                patternDigits++;
              }
            }
            
            if (patternDigits === digitsOnly.length - i) {
              this.inputCountryCode = code;
              this.currentCountry = country;
              this.phonePlaceholder = this.getPhonePlaceholder();
              this.countryState = COUNTRY_STATE_NOT_SET_OR_VALID;
              
              const newPhone = digitsOnly.substring(i);
              this.inputPhoneNumber = newPhone;
              
              if (this.onCountryCodeChange) {
                this.onCountryCodeChange('+' + code);
              }
              if (this.onPhoneChange) {
                this.onPhoneChange(newPhone);
              }
              if (this.onCountryMatched) {
                this.onCountryMatched(country);
              }
              return;
            }
          }
        }
      } finally {
        this.ignoreOnPhoneChangePaste = false;
      }
    }
    
    if (!this.ignoreOnPhoneChange) {
      this.inputPhoneNumber = digitsOnly;
      if (this.onPhoneChange) {
        this.onPhoneChange(digitsOnly);
      }
    }
  }

  private handlePhoneBackspace(): void {
    if (this.inputPhoneNumber.length === 0 && this.inputCountryCode.length > 0) {
      const code = this.inputCountryCode.substring(0, this.inputCountryCode.length - 1);
      this.inputCountryCode = code;
      if (this.onCountryCodeChange) {
        this.onCountryCodeChange(code.length > 0 ? '+' + code : '');
      }
      if (code.length === 0) {
        this.currentCountry = null;
        this.phonePlaceholder = '';
        this.countryState = COUNTRY_STATE_EMPTY;
      } else {
        this.updateCountryInfo(code);
      }
      // 聚焦到区号输入框（参考 Telegram codeField.requestFocus）
      setTimeout(() => {
        focusControl.requestFocus('codeInput');
      }, 50);
    }
  }

  build() {
    Row() {
      Text('+')
        .fontSize(FONT_SIZE_BODY)
        .fontColor(COLOR_TEXT_PRIMARY)
        .fontWeight(FontWeight.Normal)
        .margin({ left: SPACING_MD, right: SPACING_XS })
        .height(INNER_INPUT_HEIGHT)
        .align(Alignment.Center);

      TextInput({
        placeholder: this.inputCountryCode.length > 0 ? this.countryCodePlaceholder : '',
        text: this.inputCountryCode
      })
        .id('codeInput')
        .width(55)
        .height(INNER_INPUT_HEIGHT)
        .fontSize(FONT_SIZE_BODY)
        .fontColor(COLOR_TEXT_PRIMARY)
        .placeholderColor(COLOR_TEXT_TERTIARY)
        .maxLength(5)
        .type(InputType.Number)
        .defaultFocus(true)
        .backgroundColor(Color.Transparent)
        .onChange((value: string) => {
          this.onCodeFieldChange(value);
        })
        .onClick(() => {
          if (this.onCountryClick) {
            this.onCountryClick();
          }
        })
        .onFocus(() => {
          this.isFocused = true;
          this.codeInputFocused = true;
          this.phoneInputFocused = false;
        })
        .onBlur(() => {
          this.isFocused = this.phoneInputFocused;
          this.codeInputFocused = false;
        })

      Stack() {
        Divider()
          .vertical(true)
          .height(24)
          .backgroundColor(COLOR_DIVIDER)
      }
      .margin({ left: SPACING_MD, right: SPACING_MD })

      TextInput({ 
        placeholder: this.phonePlaceholder || this.placeholder, 
        text: this.formatPhoneNumber('+' + this.inputCountryCode, this.inputPhoneNumber) 
      })
        .id('phoneInput')
        .fontSize(FONT_SIZE_BODY)
        .fontColor(COLOR_TEXT_PRIMARY)
        .placeholderColor(COLOR_TEXT_TERTIARY)
        .maxLength(this.maxLength + 5)
        .type(InputType.Number)
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .onChange((value: string) => {
          this.onPhoneFieldChange(value);
        })
        .onFocus(() => {
          this.isFocused = true;
          this.phoneInputFocused = true;
          this.codeInputFocused = false;
        })
        .onBlur(() => {
          this.isFocused = this.codeInputFocused;
          this.phoneInputFocused = false;
        })
        .onKeyEvent((event: KeyEvent) => {
          // keyCode 67 = DEL/Backspace
          if (event.keyCode === 67 && event.type === KeyType.Down) {
            // 检查手机号是否已空（去除空格和下划线）
            const phoneDigits = this.inputPhoneNumber.replace(/\s|_/g, '');
            if (phoneDigits.length === 0 && this.inputCountryCode.length > 0) {
              this.handlePhoneBackspace();
              return true;
            }
          }
          return false;
        })
    }
    .width('100%')
    .height(INPUT_HEIGHT)
    .backgroundColor(COLOR_BACKGROUND)
    .borderRadius(RADIUS_MD)
    .padding({ right: SPACING_MD })
    .border({
      width: 1,
      color: this.isFocused ? COLOR_BORDER_FOCUS : COLOR_BORDER_NORMAL
    })
    .animation({
      duration: 200,
      curve: Curve.EaseInOut
    })
  }
}