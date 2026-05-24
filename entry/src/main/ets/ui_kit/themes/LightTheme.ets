import { AppTheme, ThemeType } from './AppTheme';
import { ThemeTokenFactory } from './ThemeTokens';

/**
 * 浅色主题
 */
export class LightTheme extends AppTheme {
  constructor() {
    super(ThemeType.LIGHT, ThemeTokenFactory.createLightTokens());
  }
}
