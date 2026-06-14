/**
 * 国家代码助手类（参考 Telegram CountrySelectActivity）
 * 提供国家代码与国家名称的映射关系，支持根据区号自动匹配国家
 */

/**
 * 国家信息接口
 */
export interface CountryInfo {
  name: string;           // 国家名称（中文）
  nameEn: string;         // 国家名称（英文）
  code: string;           // 国际区号（不含+号）
  iso: string;            // ISO 3166-1 alpha-2 代码
  flag: string;           // emoji 国旗
  pattern: string;        // 手机号格式模式（参考 Telegram countries.txt）
}

/**
 * 国家代码映射表（按区号索引）
 */
const countryCodeMap: Map<string, CountryInfo[]> = new Map();

/**
 * 所有国家列表（参考 Telegram countries.txt）
 * 格式：区号;ISO码;国家名称;手机号格式模式
 */
const allCountries: CountryInfo[] = [
  // 中国
  { name: '中国', nameEn: 'China', code: '86', iso: 'CN', flag: '🇨🇳', pattern: 'XXX XXXX XXXX' },
  // 美国/加拿大
  { name: '美国', nameEn: 'United States', code: '1', iso: 'US', flag: '🇺🇸', pattern: 'XXX XXX XXXX' },
  { name: '加拿大', nameEn: 'Canada', code: '1', iso: 'CA', flag: '🇨🇦', pattern: 'XXX XXX XXXX' },
  // 俄罗斯
  { name: '俄罗斯', nameEn: 'Russia', code: '7', iso: 'RU', flag: '🇷🇺', pattern: 'XXX XXX XXXX' },
  // 英国
  { name: '英国', nameEn: 'United Kingdom', code: '44', iso: 'GB', flag: '🇬🇧', pattern: 'XXXX XXXXXX' },
  // 法国
  { name: '法国', nameEn: 'France', code: '33', iso: 'FR', flag: '🇫🇷', pattern: 'X XX XX XX XX' },
  // 德国
  { name: '德国', nameEn: 'Germany', code: '49', iso: 'DE', flag: '🇩🇪', pattern: 'XXX XXXXXXX' },
  // 日本
  { name: '日本', nameEn: 'Japan', code: '81', iso: 'JP', flag: '🇯🇵', pattern: 'XX XXXX XXXX' },
  // 韩国
  { name: '韩国', nameEn: 'South Korea', code: '82', iso: 'KR', flag: '🇰🇷', pattern: 'XX XXXX XXXX' },
  // 澳大利亚
  { name: '澳大利亚', nameEn: 'Australia', code: '61', iso: 'AU', flag: '🇦🇺', pattern: 'XXX XXX XXX' },
  // 印度
  { name: '印度', nameEn: 'India', code: '91', iso: 'IN', flag: '🇮🇳', pattern: 'XXXXX XXXXX' },
  // 巴西
  { name: '巴西', nameEn: 'Brazil', code: '55', iso: 'BR', flag: '🇧🇷', pattern: 'XX XXXXX XXXX' },
  // 墨西哥
  { name: '墨西哥', nameEn: 'Mexico', code: '52', iso: 'MX', flag: '🇲🇽', pattern: 'XX XXXX XXXX' },
  // 意大利
  { name: '意大利', nameEn: 'Italy', code: '39', iso: 'IT', flag: '🇮🇹', pattern: 'XXX XXX XXXX' },
  // 西班牙
  { name: '西班牙', nameEn: 'Spain', code: '34', iso: 'ES', flag: '🇪🇸', pattern: 'XXX XXX XXX' },
  // 荷兰
  { name: '荷兰', nameEn: 'Netherlands', code: '31', iso: 'NL', flag: '🇳🇱', pattern: 'X XX XX XX XX' },
  // 比利时
  { name: '比利时', nameEn: 'Belgium', code: '32', iso: 'BE', flag: '🇧🇪', pattern: 'XXX XX XX XX' },
  // 奥地利
  { name: '奥地利', nameEn: 'Austria', code: '43', iso: 'AT', flag: '🇦🇹', pattern: 'XXX XXXXXXX' },
  // 瑞士
  { name: '瑞士', nameEn: 'Switzerland', code: '41', iso: 'CH', flag: '🇨🇭', pattern: 'XX XXX XX XX' },
  // 瑞典
  { name: '瑞典', nameEn: 'Sweden', code: '46', iso: 'SE', flag: '🇸🇪', pattern: 'XX XXX XXXX' },
  // 挪威
  { name: '挪威', nameEn: 'Norway', code: '47', iso: 'NO', flag: '🇳🇴', pattern: 'XXXX XXXX' },
  // 丹麦
  { name: '丹麦', nameEn: 'Denmark', code: '45', iso: 'DK', flag: '🇩🇰', pattern: 'XX XX XX XX' },
  // 芬兰
  { name: '芬兰', nameEn: 'Finland', code: '358', iso: 'FI', flag: '🇫🇮', pattern: 'XX XXX XXXX' },
  // 波兰
  { name: '波兰', nameEn: 'Poland', code: '48', iso: 'PL', flag: '🇵🇱', pattern: 'XXX XXX XXX' },
  // 捷克
  { name: '捷克', nameEn: 'Czech Republic', code: '420', iso: 'CZ', flag: '🇨🇿', pattern: 'XXX XXX XXX' },
  // 希腊
  { name: '希腊', nameEn: 'Greece', code: '30', iso: 'GR', flag: '🇬🇷', pattern: 'XXX XXX XXXX' },
  // 葡萄牙
  { name: '葡萄牙', nameEn: 'Portugal', code: '351', iso: 'PT', flag: '🇵🇹', pattern: 'XX XXX XXXX' },
  // 爱尔兰
  { name: '爱尔兰', nameEn: 'Ireland', code: '353', iso: 'IE', flag: '🇮🇪', pattern: 'XX XXX XXXX' },
  // 匈牙利
  { name: '匈牙利', nameEn: 'Hungary', code: '36', iso: 'HU', flag: '🇭🇺', pattern: 'XX XXX XXXX' },
  // 罗马尼亚
  { name: '罗马尼亚', nameEn: 'Romania', code: '40', iso: 'RO', flag: '🇷🇴', pattern: 'XXX XXX XXX' },
  // 保加利亚
  { name: '保加利亚', nameEn: 'Bulgaria', code: '359', iso: 'BG', flag: '🇧🇬', pattern: 'XX XXX XXXX' },
  // 克罗地亚
  { name: '克罗地亚', nameEn: 'Croatia', code: '385', iso: 'HR', flag: '🇭🇷', pattern: 'XX XXX XXXX' },
  // 塞尔维亚
  { name: '塞尔维亚', nameEn: 'Serbia', code: '381', iso: 'RS', flag: '🇷🇸', pattern: 'XX XXX XXXX' },
  // 土耳其
  { name: '土耳其', nameEn: 'Turkey', code: '90', iso: 'TR', flag: '🇹🇷', pattern: 'XXX XXX XXXX' },
  // 以色列
  { name: '以色列', nameEn: 'Israel', code: '972', iso: 'IL', flag: '🇮🇱', pattern: 'XX XXX XXXX' },
  // 沙特阿拉伯
  { name: '沙特阿拉伯', nameEn: 'Saudi Arabia', code: '966', iso: 'SA', flag: '🇸🇦', pattern: 'XX XXX XXXX' },
  // 阿联酋
  { name: '阿联酋', nameEn: 'United Arab Emirates', code: '971', iso: 'AE', flag: '🇦🇪', pattern: 'XX XXX XXXX' },
  // 新加坡
  { name: '新加坡', nameEn: 'Singapore', code: '65', iso: 'SG', flag: '🇸🇬', pattern: 'XXXX XXXX' },
  // 马来西亚
  { name: '马来西亚', nameEn: 'Malaysia', code: '60', iso: 'MY', flag: '🇲🇾', pattern: 'XX XXXX XXXX' },
  // 泰国
  { name: '泰国', nameEn: 'Thailand', code: '66', iso: 'TH', flag: '🇹🇭', pattern: 'XX XXX XXXX' },
  // 越南
  { name: '越南', nameEn: 'Vietnam', code: '84', iso: 'VN', flag: '🇻🇳', pattern: 'XX XXX XXXX' },
  // 菲律宾
  { name: '菲律宾', nameEn: 'Philippines', code: '63', iso: 'PH', flag: '🇵🇭', pattern: 'XXX XXX XXXX' },
  // 印度尼西亚
  { name: '印度尼西亚', nameEn: 'Indonesia', code: '62', iso: 'ID', flag: '🇮🇩', pattern: 'XXX XXXX XXXX' },
  // 新西兰
  { name: '新西兰', nameEn: 'New Zealand', code: '64', iso: 'NZ', flag: '🇳🇿', pattern: 'XX XXX XXXX' },
  // 南非
  { name: '南非', nameEn: 'South Africa', code: '27', iso: 'ZA', flag: '🇿🇦', pattern: 'XX XXX XXXX' },
  // 尼日利亚
  { name: '尼日利亚', nameEn: 'Nigeria', code: '234', iso: 'NG', flag: '🇳🇬', pattern: 'XX XXXX XXXX' },
  // 埃及
  { name: '埃及', nameEn: 'Egypt', code: '20', iso: 'EG', flag: '🇪🇬', pattern: 'XX XXXX XXXX' },
  // 阿根廷
  { name: '阿根廷', nameEn: 'Argentina', code: '54', iso: 'AR', flag: '🇦🇷', pattern: 'XX XXXX XXXX' },
  // 智利
  { name: '智利', nameEn: 'Chile', code: '56', iso: 'CL', flag: '🇨🇱', pattern: 'X XXXX XXXX' },
  // 哥伦比亚
  { name: '哥伦比亚', nameEn: 'Colombia', code: '57', iso: 'CO', flag: '🇨🇴', pattern: 'XXX XXX XXXX' },
  // 委内瑞拉
  { name: '委内瑞拉', nameEn: 'Venezuela', code: '58', iso: 'VE', flag: '🇻🇪', pattern: 'XXX XXX XXXX' },
  // 秘鲁
  { name: '秘鲁', nameEn: 'Peru', code: '51', iso: 'PE', flag: '🇵🇪', pattern: 'X XXX XXXX' },
  // 乌拉圭
  { name: '乌拉圭', nameEn: 'Uruguay', code: '598', iso: 'UY', flag: '🇺🇾', pattern: 'X XXX XXXX' },
  // 巴拉圭
  { name: '巴拉圭', nameEn: 'Paraguay', code: '595', iso: 'PY', flag: '🇵🇾', pattern: 'XXX XXX XXX' },
  // 玻利维亚
  { name: '玻利维亚', nameEn: 'Bolivia', code: '591', iso: 'BO', flag: '🇧🇴', pattern: 'X XXX XXXX' },
  // 厄瓜多尔
  { name: '厄瓜多尔', nameEn: 'Ecuador', code: '593', iso: 'EC', flag: '🇪🇨', pattern: 'XX XXX XXXX' },
  // 哥斯达黎加
  { name: '哥斯达黎加', nameEn: 'Costa Rica', code: '506', iso: 'CR', flag: '🇨🇷', pattern: 'XXXX XXXX' },
  // 巴拿马
  { name: '巴拿马', nameEn: 'Panama', code: '507', iso: 'PA', flag: '🇵🇦', pattern: 'XXXX XXXX' },
  // 古巴
  { name: '古巴', nameEn: 'Cuba', code: '53', iso: 'CU', flag: '🇨🇺', pattern: 'X XXX XXXX' },
  // 多米尼加
  { name: '多米尼加', nameEn: 'Dominican Republic', code: '1', iso: 'DO', flag: '🇩🇴', pattern: 'XXX XXX XXXX' },
  // 波多黎各
  { name: '波多黎各', nameEn: 'Puerto Rico', code: '1', iso: 'PR', flag: '🇵🇷', pattern: 'XXX XXX XXXX' },
  // 牙买加
  { name: '牙买加', nameEn: 'Jamaica', code: '1', iso: 'JM', flag: '🇯🇲', pattern: 'XXX XXXX' },
  // 开曼群岛
  { name: '开曼群岛', nameEn: 'Cayman Islands', code: '1', iso: 'KY', flag: '🇰🇾', pattern: 'XXX XXXX' },
  // 百慕大
  { name: '百慕大', nameEn: 'Bermuda', code: '1', iso: 'BM', flag: '🇧🇲', pattern: 'XXX XXXX' },
  // 巴哈马
  { name: '巴哈马', nameEn: 'Bahamas', code: '1', iso: 'BS', flag: '🇧🇸', pattern: 'XXX XXXX' },
  // 巴巴多斯
  { name: '巴巴多斯', nameEn: 'Barbados', code: '1', iso: 'BB', flag: '🇧🇧', pattern: 'XXX XXXX' },
  // 格林纳达
  { name: '格林纳达', nameEn: 'Grenada', code: '1', iso: 'GD', flag: '🇬🇩', pattern: 'XXX XXXX' },
  // 圣卢西亚
  { name: '圣卢西亚', nameEn: 'Saint Lucia', code: '1', iso: 'LC', flag: '🇱🇨', pattern: 'XXX XXXX' },
  // 安提瓜和巴布达
  { name: '安提瓜和巴布达', nameEn: 'Antigua and Barbuda', code: '1', iso: 'AG', flag: '🇦🇬', pattern: 'XXX XXXX' },
  // 圣基茨和尼维斯
  { name: '圣基茨和尼维斯', nameEn: 'Saint Kitts and Nevis', code: '1', iso: 'KN', flag: '🇰🇳', pattern: 'XXX XXXX' },
  // 多米尼克
  { name: '多米尼克', nameEn: 'Dominica', code: '1', iso: 'DM', flag: '🇩🇲', pattern: 'XXX XXXX' },
  // 特立尼达和多巴哥
  { name: '特立尼达和多巴哥', nameEn: 'Trinidad and Tobago', code: '1', iso: 'TT', flag: '🇹🇹', pattern: 'XXX XXXX' },
  // 圣文森特和格林纳丁斯
  { name: '圣文森特和格林纳丁斯', nameEn: 'Saint Vincent and the Grenadines', code: '1', iso: 'VC', flag: '🇻🇨', pattern: 'XXX XXXX' },
  // 伯利兹
  { name: '伯利兹', nameEn: 'Belize', code: '501', iso: 'BZ', flag: '🇧🇿', pattern: 'XXX XXXX' },
  // 危地马拉
  { name: '危地马拉', nameEn: 'Guatemala', code: '502', iso: 'GT', flag: '🇬🇹', pattern: 'X XXX XXXX' },
  // 洪都拉斯
  { name: '洪都拉斯', nameEn: 'Honduras', code: '504', iso: 'HN', flag: '🇭🇳', pattern: 'XXXX XXXX' },
  // 萨尔瓦多
  { name: '萨尔瓦多', nameEn: 'El Salvador', code: '503', iso: 'SV', flag: '🇸🇻', pattern: 'XXXX XXXX' },
  // 尼加拉瓜
  { name: '尼加拉瓜', nameEn: 'Nicaragua', code: '505', iso: 'NI', flag: '🇳🇮', pattern: 'XXXX XXXX' },
  // 海地
  { name: '海地', nameEn: 'Haiti', code: '509', iso: 'HT', flag: '🇭🇹', pattern: 'XXX XX XX XX' },
  // 美属维尔京群岛
  { name: '美属维尔京群岛', nameEn: 'US Virgin Islands', code: '1', iso: 'VI', flag: '🇻🇮', pattern: 'XXX XXX XXXX' },
  // 英属维尔京群岛
  { name: '英属维尔京群岛', nameEn: 'British Virgin Islands', code: '1', iso: 'VG', flag: '🇻🇬', pattern: 'XXX XXXX' },
  // 特克斯和凯科斯群岛
  { name: '特克斯和凯科斯群岛', nameEn: 'Turks and Caicos Islands', code: '1', iso: 'TC', flag: '🇹🇨', pattern: 'XXX XXXX' },
  // 安圭拉
  { name: '安圭拉', nameEn: 'Anguilla', code: '1', iso: 'AI', flag: '🇦🇮', pattern: 'XXX XXXX' },
  // 蒙特塞拉特
  { name: '蒙特塞拉特', nameEn: 'Montserrat', code: '1', iso: 'MS', flag: '🇲🇸', pattern: 'XXX XXXX' },
  // 瓜德罗普
  { name: '瓜德罗普', nameEn: 'Guadeloupe', code: '590', iso: 'GP', flag: '🇬🇵', pattern: 'XXX XX XX XX' },
  // 马提尼克
  { name: '马提尼克', nameEn: 'Martinique', code: '596', iso: 'MQ', flag: '🇲🇶', pattern: 'XXX XX XX XX' },
  // 法属圭亚那
  { name: '法属圭亚那', nameEn: 'French Guiana', code: '594', iso: 'GF', flag: '🇬🇫', pattern: 'XXX XX XX XX' },
  // 苏里南
  { name: '苏里南', nameEn: 'Suriname', code: '597', iso: 'SR', flag: '🇸🇷', pattern: 'XXX XXXX' },
  // 圭亚那
  { name: '圭亚那', nameEn: 'Guyana', code: '592', iso: 'GY', flag: '🇬🇾', pattern: 'XXX XXXX' },
  // 欧洲其他国家
  { name: '乌克兰', nameEn: 'Ukraine', code: '380', iso: 'UA', flag: '🇺🇦', pattern: 'XX XXX XXXX' },
  { name: '白俄罗斯', nameEn: 'Belarus', code: '375', iso: 'BY', flag: '🇧🇾', pattern: 'XX XXX XXXX' },
  { name: '摩尔多瓦', nameEn: 'Moldova', code: '373', iso: 'MD', flag: '🇲🇩', pattern: 'XX XXX XXX' },
  { name: '立陶宛', nameEn: 'Lithuania', code: '370', iso: 'LT', flag: '🇱🇹', pattern: 'XXX XXXXX' },
  { name: '拉脱维亚', nameEn: 'Latvia', code: '371', iso: 'LV', flag: '🇱🇻', pattern: 'XX XXX XXX' },
  { name: '爱沙尼亚', nameEn: 'Estonia', code: '372', iso: 'EE', flag: '🇪🇪', pattern: 'X XXX XXXX' },
  { name: '格鲁吉亚', nameEn: 'Georgia', code: '995', iso: 'GE', flag: '🇬🇪', pattern: 'XXX XXX XXX' },
  { name: '亚美尼亚', nameEn: 'Armenia', code: '374', iso: 'AM', flag: '🇦🇲', pattern: 'XX XXX XXX' },
  { name: '阿塞拜疆', nameEn: 'Azerbaijan', code: '994', iso: 'AZ', flag: '🇦🇿', pattern: 'XX XXX XXXX' },
  { name: '哈萨克斯坦', nameEn: 'Kazakhstan', code: '7', iso: 'KZ', flag: '🇰🇿', pattern: 'XXX XXX XXXX' },
  { name: '乌兹别克斯坦', nameEn: 'Uzbekistan', code: '998', iso: 'UZ', flag: '🇺🇿', pattern: 'XX XXXXXXX' },
  { name: '吉尔吉斯斯坦', nameEn: 'Kyrgyzstan', code: '996', iso: 'KG', flag: '🇰🇬', pattern: 'XXX XXXXXX' },
  { name: '塔吉克斯坦', nameEn: 'Tajikistan', code: '992', iso: 'TJ', flag: '🇹🇯', pattern: 'XX XXX XXXX' },
  { name: '土库曼斯坦', nameEn: 'Turkmenistan', code: '993', iso: 'TM', flag: '🇹🇲', pattern: 'XX XXXXXX' },
  { name: '蒙古', nameEn: 'Mongolia', code: '976', iso: 'MN', flag: '🇲🇳', pattern: 'XX XX XXXX' },
  { name: '朝鲜', nameEn: 'North Korea', code: '850', iso: 'KP', flag: '🇰🇵', pattern: 'XXX XXX XXXX' },
  { name: '香港', nameEn: 'Hong Kong', code: '852', iso: 'HK', flag: '🇭🇰', pattern: 'X XXX XXXX' },
  { name: '澳门', nameEn: 'Macao', code: '853', iso: 'MO', flag: '🇲🇴', pattern: 'XXXX XXXX' },
  { name: '台湾', nameEn: 'Taiwan', code: '886', iso: 'TW', flag: '🇹🇼', pattern: 'XXX XXX XXX' },
  { name: '柬埔寨', nameEn: 'Cambodia', code: '855', iso: 'KH', flag: '🇰🇭', pattern: 'XX XXX XXXX' },
  { name: '老挝', nameEn: 'Laos', code: '856', iso: 'LA', flag: '🇱🇦', pattern: 'XX XX XXX XXX' },
  { name: '缅甸', nameEn: 'Myanmar', code: '95', iso: 'MM', flag: '🇲🇲', pattern: 'X XXX XXXX' },
  { name: '文莱', nameEn: 'Brunei', code: '673', iso: 'BN', flag: '🇧🇳', pattern: 'XXX XXXX' },
  { name: '东帝汶', nameEn: 'Timor-Leste', code: '670', iso: 'TL', flag: '🇹🇱', pattern: 'XXX XXXXX' },
  { name: '巴基斯坦', nameEn: 'Pakistan', code: '92', iso: 'PK', flag: '🇵🇰', pattern: 'XXX XXXXXXX' },
  { name: '孟加拉国', nameEn: 'Bangladesh', code: '880', iso: 'BD', flag: '🇧🇩', pattern: 'XX XXXX XXXX' },
  { name: '斯里兰卡', nameEn: 'Sri Lanka', code: '94', iso: 'LK', flag: '🇱🇰', pattern: 'XX XXX XXXX' },
  { name: '尼泊尔', nameEn: 'Nepal', code: '977', iso: 'NP', flag: '🇳🇵', pattern: 'XX XXXX XXXX' },
  { name: '不丹', nameEn: 'Bhutan', code: '975', iso: 'BT', flag: '🇧🇹', pattern: 'XX XXX XXX' },
  { name: '马尔代夫', nameEn: 'Maldives', code: '960', iso: 'MV', flag: '🇲🇻', pattern: 'XXX XXXX' },
  { name: '阿富汗', nameEn: 'Afghanistan', code: '93', iso: 'AF', flag: '🇦🇫', pattern: 'XX XXX XXXX' },
  { name: '伊朗', nameEn: 'Iran', code: '98', iso: 'IR', flag: '🇮🇷', pattern: 'XXX XXX XXXX' },
  { name: '伊拉克', nameEn: 'Iraq', code: '964', iso: 'IQ', flag: '🇮🇶', pattern: 'XXX XXX XXXX' },
  { name: '科威特', nameEn: 'Kuwait', code: '965', iso: 'KW', flag: '🇰🇼', pattern: 'XXXX XXXX' },
  { name: '巴林', nameEn: 'Bahrain', code: '973', iso: 'BH', flag: '🇧🇭', pattern: 'XXXX XXXX' },
  { name: '卡塔尔', nameEn: 'Qatar', code: '974', iso: 'QA', flag: '🇶🇦', pattern: 'XX XXX XXX' },
  { name: '阿曼', nameEn: 'Oman', code: '968', iso: 'OM', flag: '🇴🇲', pattern: 'XXXX XXXX' },
  { name: '也门', nameEn: 'Yemen', code: '967', iso: 'YE', flag: '🇾🇪', pattern: 'XXX XXX XXX' },
  { name: '叙利亚', nameEn: 'Syria', code: '963', iso: 'SY', flag: '🇸🇾', pattern: 'XXX XXX XXX' },
  { name: '黎巴嫩', nameEn: 'Lebanon', code: '961', iso: 'LB', flag: '🇱🇧', pattern: 'XX XXX XXX' },
  { name: '约旦', nameEn: 'Jordan', code: '962', iso: 'JO', flag: '🇯🇴', pattern: 'X XXXX XXXX' },
  { name: '巴勒斯坦', nameEn: 'Palestine', code: '970', iso: 'PS', flag: '🇵🇸', pattern: 'XXX XX XXXX' },
  { name: '利比亚', nameEn: 'Libya', code: '218', iso: 'LY', flag: '🇱🇾', pattern: 'XX X XXXX' },
  { name: '突尼斯', nameEn: 'Tunisia', code: '216', iso: 'TN', flag: '🇹🇳', pattern: 'XX XXX XXX' },
  { name: '阿尔及利亚', nameEn: 'Algeria', code: '213', iso: 'DZ', flag: '🇩🇿', pattern: 'XXX XX XX XX' },
  { name: '摩洛哥', nameEn: 'Morocco', code: '212', iso: 'MA', flag: '🇲🇦', pattern: 'XX XX XX XX XX' },
  { name: '西撒哈拉', nameEn: 'Western Sahara', code: '212', iso: 'EH', flag: '🇪🇭', pattern: 'XX XX XX XX XX' },
  { name: '毛里塔尼亚', nameEn: 'Mauritania', code: '222', iso: 'MR', flag: '🇲🇷', pattern: 'XX XX XX XX' },
  { name: '塞内加尔', nameEn: 'Senegal', code: '221', iso: 'SN', flag: '🇸🇳', pattern: 'XX XXX XX XX' },
  { name: '冈比亚', nameEn: 'Gambia', code: '220', iso: 'GM', flag: '🇬🇲', pattern: 'XXX XXXX' },
  { name: '几内亚比绍', nameEn: 'Guinea-Bissau', code: '245', iso: 'GW', flag: '🇬🇼', pattern: 'X XXX XXXX' },
  { name: '几内亚', nameEn: 'Guinea', code: '224', iso: 'GN', flag: '🇬🇳', pattern: 'XXX XX XX XX' },
  { name: '塞拉利昂', nameEn: 'Sierra Leone', code: '232', iso: 'SL', flag: '🇸🇱', pattern: 'XX XXX XXX' },
  { name: '利比里亚', nameEn: 'Liberia', code: '231', iso: 'LR', flag: '🇱🇷', pattern: 'XX XXX XXXX' },
  { name: '科特迪瓦', nameEn: 'Cote d\'Ivoire', code: '225', iso: 'CI', flag: '🇨🇮', pattern: 'XX XX XX XX XX' },
  { name: '布基纳法索', nameEn: 'Burkina Faso', code: '226', iso: 'BF', flag: '🇧🇫', pattern: 'XX XX XX XX' },
  { name: '尼日尔', nameEn: 'Niger', code: '227', iso: 'NE', flag: '🇳🇪', pattern: 'XX XX XX XX' },
  { name: '乍得', nameEn: 'Chad', code: '235', iso: 'TD', flag: '🇹🇩', pattern: 'XX XX XX XX' },
  { name: '喀麦隆', nameEn: 'Cameroon', code: '237', iso: 'CM', flag: '🇨🇲', pattern: 'XXXX XXXX' },
  { name: '中非', nameEn: 'Central African Republic', code: '236', iso: 'CF', flag: '🇨🇫', pattern: 'XX XX XX XX' },
  { name: '圣多美和普林西比', nameEn: 'Sao Tome and Principe', code: '239', iso: 'ST', flag: '🇸🇹', pattern: 'XX XXXXX' },
  { name: '赤道几内亚', nameEn: 'Equatorial Guinea', code: '240', iso: 'GQ', flag: '🇬🇶', pattern: 'XX XXX XXX' },
  { name: '加蓬', nameEn: 'Gabon', code: '241', iso: 'GA', flag: '🇬🇦', pattern: 'X XX XX XX' },
  { name: '刚果共和国', nameEn: 'Republic of the Congo', code: '242', iso: 'CG', flag: '🇨🇬', pattern: 'XX XXX XXXX' },
  { name: '刚果民主共和国', nameEn: 'Democratic Republic of the Congo', code: '243', iso: 'CD', flag: '🇨🇩', pattern: 'XX XXX XXXX' },
  { name: '安哥拉', nameEn: 'Angola', code: '244', iso: 'AO', flag: '🇦🇴', pattern: 'XXX XXX XXX' },
  { name: '赞比亚', nameEn: 'Zambia', code: '260', iso: 'ZM', flag: '🇿🇲', pattern: 'XX XXX XXXX' },
  { name: '马拉维', nameEn: 'Malawi', code: '265', iso: 'MW', flag: '🇲🇼', pattern: 'XXX XXX XXX' },
  { name: '莫桑比克', nameEn: 'Mozambique', code: '258', iso: 'MZ', flag: '🇲🇿', pattern: 'XX XXX XXXX' },
  { name: '马达加斯加', nameEn: 'Madagascar', code: '261', iso: 'MG', flag: '🇲🇬', pattern: 'XX XX XXX XX' },
  { name: '科摩罗', nameEn: 'Comoros', code: '269', iso: 'KM', flag: '🇰🇲', pattern: 'XX XXXXX' },
  { name: '塞舌尔', nameEn: 'Seychelles', code: '248', iso: 'SC', flag: '🇸🇨', pattern: 'X XX XX XX' },
  { name: '毛里求斯', nameEn: 'Mauritius', code: '230', iso: 'MU', flag: '🇲🇺', pattern: 'XXXX XXXX' },
  { name: '留尼汪', nameEn: 'Reunion', code: '262', iso: 'RE', flag: '🇷🇪', pattern: 'XXX XX XX XX' },
  { name: '纳米比亚', nameEn: 'Namibia', code: '264', iso: 'NA', flag: '🇳🇦', pattern: 'XX XXX XXXX' },
  { name: '博茨瓦纳', nameEn: 'Botswana', code: '267', iso: 'BW', flag: '🇧🇼', pattern: 'XX XXX XXX' },
  { name: '津巴布韦', nameEn: 'Zimbabwe', code: '263', iso: 'ZW', flag: '🇿🇼', pattern: 'XX XXX XXXX' },
  { name: '斯威士兰', nameEn: 'Eswatini', code: '268', iso: 'SZ', flag: '🇸🇿', pattern: 'XXXX XXXX' },
  { name: '莱索托', nameEn: 'Lesotho', code: '266', iso: 'LS', flag: '🇱🇸', pattern: 'X XXX XXXX' },
  { name: '肯尼亚', nameEn: 'Kenya', code: '254', iso: 'KE', flag: '🇰🇪', pattern: 'XXX XXX XXX' },
  { name: '乌干达', nameEn: 'Uganda', code: '256', iso: 'UG', flag: '🇺🇬', pattern: 'XXX XXX XXX' },
  { name: '坦桑尼亚', nameEn: 'Tanzania', code: '255', iso: 'TZ', flag: '🇹🇿', pattern: 'XX XXX XXXX' },
  { name: '布隆迪', nameEn: 'Burundi', code: '257', iso: 'BI', flag: '🇧🇮', pattern: 'XX XXX XXX' },
  { name: '卢旺达', nameEn: 'Rwanda', code: '250', iso: 'RW', flag: '🇷🇼', pattern: 'XXX XXX XXX' },
  { name: '埃塞俄比亚', nameEn: 'Ethiopia', code: '251', iso: 'ET', flag: '🇪🇹', pattern: 'XX XXX XXXX' },
  { name: '厄立特里亚', nameEn: 'Eritrea', code: '291', iso: 'ER', flag: '🇪🇷', pattern: 'X XXX XXX' },
  { name: '吉布提', nameEn: 'Djibouti', code: '253', iso: 'DJ', flag: '🇩🇯', pattern: 'XX XX XX XX' },
  { name: '索马里', nameEn: 'Somalia', code: '252', iso: 'SO', flag: '🇸🇴', pattern: 'X XXXXXX' },
  // 大洋洲
  { name: '巴布亚新几内亚', nameEn: 'Papua New Guinea', code: '675', iso: 'PG', flag: '🇵🇬', pattern: 'XXX XXXXX' },
  { name: '所罗门群岛', nameEn: 'Solomon Islands', code: '677', iso: 'SB', flag: '🇸🇧', pattern: 'XXX XXXX' },
  { name: '瓦努阿图', nameEn: 'Vanuatu', code: '678', iso: 'VU', flag: '🇻🇺', pattern: 'X XXXX' },
  { name: '斐济', nameEn: 'Fiji', code: '679', iso: 'FJ', flag: '🇫🇯', pattern: 'X XXX XXXX' },
  { name: '萨摩亚', nameEn: 'Samoa', code: '685', iso: 'WS', flag: '🇼🇸', pattern: 'XX XXXX' },
  { name: '汤加', nameEn: 'Tonga', code: '676', iso: 'TO', flag: '🇹🇴', pattern: 'XXX XXXX' },
  { name: '基里巴斯', nameEn: 'Kiribati', code: '686', iso: 'KI', flag: '🇰🇮', pattern: 'X XXXX' },
  { name: '图瓦卢', nameEn: 'Tuvalu', code: '688', iso: 'TV', flag: '🇹🇻', pattern: 'X XXXX' },
  { name: '瑙鲁', nameEn: 'Nauru', code: '674', iso: 'NR', flag: '🇳🇷', pattern: 'X XXXX' },
  { name: '马绍尔群岛', nameEn: 'Marshall Islands', code: '692', iso: 'MH', flag: '🇲🇭', pattern: 'X XXXX' },
  { name: '密克罗尼西亚', nameEn: 'Micronesia', code: '691', iso: 'FM', flag: '🇫🇲', pattern: 'X XXXX' },
  { name: '帕劳', nameEn: 'Palau', code: '680', iso: 'PW', flag: '🇵🇼', pattern: 'X XXXX' },
  { name: '关岛', nameEn: 'Guam', code: '1', iso: 'GU', flag: '🇬🇺', pattern: 'XXX XXX XXXX' },
  { name: '美属萨摩亚', nameEn: 'American Samoa', code: '1', iso: 'AS', flag: '🇦🇸', pattern: 'XXX XXXX' },
  { name: '北马里亚纳群岛', nameEn: 'Northern Mariana Islands', code: '1', iso: 'MP', flag: '🇲🇵', pattern: 'XXX XXXX' },
  { name: '库克群岛', nameEn: 'Cook Islands', code: '682', iso: 'CK', flag: '🇨🇰', pattern: 'X XXXX' },
  { name: '纽埃', nameEn: 'Niue', code: '683', iso: 'NU', flag: '🇳🇺', pattern: 'X XXXX' },
  { name: '托克劳', nameEn: 'Tokelau', code: '690', iso: 'TK', flag: '🇹🇰', pattern: 'X XXXX' },
  { name: '法属波利尼西亚', nameEn: 'French Polynesia', code: '689', iso: 'PF', flag: '🇵🇫', pattern: 'X XXXX' },
  { name: '新喀里多尼亚', nameEn: 'New Caledonia', code: '687', iso: 'NC', flag: '🇳🇨', pattern: 'X XXXX' },
  { name: '瓦利斯和富图纳', nameEn: 'Wallis and Futuna', code: '681', iso: 'WF', flag: '🇼🇫', pattern: 'X XXXX' },
];

// 初始化国家代码映射表
function initCountryCodeMap(): void {
  for (const country of allCountries) {
    const existing = countryCodeMap.get(country.code);
    if (existing) {
      existing.push(country);
    } else {
      countryCodeMap.set(country.code, [country]);
    }
  }
}

// 初始化
initCountryCodeMap();

/**
 * 国家代码助手类
 */
export class CountryCodeHelper {
  /**
   * 根据区号查找国家列表
   * @param code - 区号（可以带+号或不带）
   * @returns 匹配的国家列表
   */
  static findCountriesByCode(code: string): CountryInfo[] {
    const cleanCode = code.replace('+', '').replace(/\s/g, '');
    return countryCodeMap.get(cleanCode) || [];
  }

  /**
   * 根据输入的数字序列智能匹配国家代码
   * 参考 Telegram PhoneView 的实现逻辑
   * @param input - 用户输入的数字序列
   * @returns 匹配结果
   */
  static matchCountryByInput(input: string): CountryMatchResult {
    const cleaned = input.replace(/\D/g, '');
    
    if (cleaned.length === 0) {
      return {
        matched: false,
        country: null,
        code: '',
        remainingDigits: ''
      };
    }

    // 从最长可能的代码开始匹配（最多4位）
    const maxLen = Math.min(cleaned.length, 4);
    for (let len = maxLen; len >= 1; len--) {
      const prefix = cleaned.substring(0, len);
      const countries = countryCodeMap.get(prefix);
      
      if (countries && countries.length > 0) {
        // 优先选择第一个匹配的国家（通常是最常用的）
        const country = countries[0];
        return {
          matched: true,
          country: country,
          code: '+' + prefix,
          remainingDigits: cleaned.substring(len)
        };
      }
    }

    // 如果没有匹配到完整的国家代码，尝试前缀匹配
    for (let len = maxLen; len >= 1; len--) {
      const prefix = cleaned.substring(0, len);
      // 检查是否有国家代码以该前缀开头
      let foundCountry: CountryInfo | null = null;
      countryCodeMap.forEach((countries: CountryInfo[], countryCode: string) => {
        if (countryCode.startsWith(prefix) && foundCountry === null) {
          foundCountry = countries[0];
        }
      });
      if (foundCountry) {
        return {
          matched: false,
          country: foundCountry,
          code: '+' + prefix,
          remainingDigits: cleaned.substring(len)
        };
      }
    }

    return {
      matched: false,
      country: null,
      code: '+' + cleaned.substring(0, 1),
      remainingDigits: cleaned.substring(1)
    };
  }

  /**
   * 获取所有国家列表
   */
  static getAllCountries(): CountryInfo[] {
    return [...allCountries];
  }

  /**
   * 根据ISO代码获取国家信息
   */
  static getCountryByIso(iso: string): CountryInfo | null {
    return allCountries.find(c => c.iso.toLowerCase() === iso.toLowerCase()) || null;
  }

  /**
   * 获取默认国家（中国）
   */
  static getDefaultCountry(): CountryInfo {
    return allCountries.find(c => c.iso === 'CN')!;
  }

  /**
   * 获取区号格式的完整号码
   */
  static formatPhoneNumber(countryCode: string, phoneNumber: string): string {
    const code = countryCode.replace('+', '');
    let formatted = phoneNumber.replace(/\D/g, '');
    
    // 根据常见国家代码应用格式
    switch (code) {
      case '86': // 中国
        if (formatted.length >= 3) {
          formatted = formatted.substring(0, 3) + ' ' + formatted.substring(3);
        }
        if (formatted.length >= 8) {
          formatted = formatted.substring(0, 8) + ' ' + formatted.substring(8);
        }
        break;
      case '1': // 美国/加拿大
        if (formatted.length >= 3) {
          formatted = formatted.substring(0, 3) + ' ' + formatted.substring(3);
        }
        if (formatted.length >= 7) {
          formatted = formatted.substring(0, 7) + ' ' + formatted.substring(7);
        }
        break;
      case '44': // 英国
        if (formatted.length >= 5) {
          formatted = formatted.substring(0, 5) + ' ' + formatted.substring(5);
        }
        break;
      case '33': // 法国
      case '49': // 德国
        if (formatted.length >= 2) {
          formatted = formatted.substring(0, 2) + ' ' + formatted.substring(2);
        }
        if (formatted.length >= 6) {
          formatted = formatted.substring(0, 6) + ' ' + formatted.substring(6);
        }
        break;
      default:
        // 默认：每4位添加空格
        formatted = formatted.replace(/(\d{4})/g, '$1 ').trim();
    }
    
    return formatted;
  }
}

/**
 * 国家匹配结果接口
 */
export interface CountryMatchResult {
  matched: boolean;        // 是否完全匹配到国家代码
  country: CountryInfo | null;  // 匹配到的国家信息
  code: string;            // 匹配到的区号（带+号）
  remainingDigits: string; // 区号之外的剩余数字（应转移到手机号输入框）
}
