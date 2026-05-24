import { AppTheme, ThemeType } from './AppTheme';
import { ThemeTokenFactory } from './ThemeTokens';

/**
 * 深色主题
 */
export class DarkTheme extends AppTheme {
  constructor() {
    super(ThemeType.DARK, ThemeTokenFactory.createDarkTokens());
  }
}
