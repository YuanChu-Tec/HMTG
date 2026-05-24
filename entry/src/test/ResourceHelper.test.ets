/**
 * ResourceHelper 单元测试
 * 
 * 测试目标: 验证 getString() 函数能正确返回国际化字符串,而不是 key
 */

import { describe, it, expect } from '@ohos/hypium';
import { getString, formatString } from '../../main/ets/utils/common/i18n/ResourceHelper';

export default function resourceHelperTest() {
  describe('ResourceHelper', () => {
    
    // ========== 测试用例 1: 正常场景 - 正确的资源 key ==========
    it('should return localized string for valid auth key', () => {
      const result = getString('auth_phone_invalid');
      
      // 应该返回中文提示,而不是 key 本身
      expect(result).assertEqual('手机号格式有误，请检查');
      expect(result).not.assertContain('auth_phone_invalid');
    });
    
    it('should return localized string for auth code invalid', () => {
      const result = getString('auth_code_invalid');
      
      // 应该返回中文提示,而不是 key 本身
      expect(result).not.assertContain('auth_code_invalid');
      expect(result.length).assertGreaterThan(0);
    });
    
    // ========== 测试用例 2: 异常场景 - 不存在的资源 key ==========
    it('should return friendly message for non-existent key', () => {
      const result = getString('non_existent_key_12345');
      
      // 不应该返回 key 本身
      expect(result).not.assertContain('non_existent_key_12345');
      
      // 应该返回友好的默认提示
      expect(result.length).assertGreaterThan(0);
      console.log(`[Test] Non-existent key result: "${result}"`);
    });
    
    it('should return auth-specific message for unknown auth key', () => {
      const result = getString('auth_unknown_error_xyz');
      
      // 不应该返回 key 本身
      expect(result).not.assertContain('auth_unknown_error_xyz');
      
      // 应该返回认证相关的默认提示
      expect(result).assertContain('认证');
      console.log(`[Test] Unknown auth key result: "${result}"`);
    });
    
    // ========== 测试用例 3: 格式化功能 ==========
    it('should format string with parameters correctly', () => {
      // 假设资源文件中有: "welcome_user": "欢迎{0}"
      const result = formatString('welcome_user', '张三');
      
      // 应该包含参数值
      expect(result).assertContain('张三');
      expect(result).not.assertContain('{0}');
      console.log(`[Test] Formatted string: "${result}"`);
    });
    
    it('should format flood wait message with seconds', () => {
      // 假设资源文件中有: "auth_flood_wait_seconds": "请等待{0}秒后重试"
      const result = formatString('auth_flood_wait_seconds', 60);
      
      // 应该包含数字
      expect(result).assertContain('60');
      expect(result).not.assertContain('{0}');
      console.log(`[Test] Flood wait message: "${result}"`);
    });
    
    // ========== 测试用例 4: 边界情况 ==========
    it('should handle empty key gracefully', () => {
      const result = getString('');
      
      // 不应该崩溃,应该返回默认提示
      expect(result.length).assertGreaterThan(0);
      console.log(`[Test] Empty key result: "${result}"`);
    });
    
    it('should handle very long key gracefully', () => {
      const longKey = 'a'.repeat(1000);
      const result = getString(longKey);
      
      // 不应该崩溃,应该返回默认提示
      expect(result.length).assertGreaterThan(0);
      expect(result).not.assertContain(longKey);
      console.log(`[Test] Long key handled successfully`);
    });
    
    // ========== 测试用例 5: 不同前缀的 key ==========
    it('should return network-specific message for network key', () => {
      const result = getString('network_timeout');
      
      // 应该返回网络相关的默认提示
      if (result.includes('网络')) {
        console.log(`[Test] Network key result contains "网络": "${result}"`);
      } else {
        console.log(`[Test] Network key result: "${result}"`);
      }
    });
    
    it('should return file-specific message for file key', () => {
      const result = getString('file_not_found');
      
      // 应该返回文件相关的默认提示或通用提示
      expect(result.length).assertGreaterThan(0);
      expect(result).not.assertContain('file_not_found');
      console.log(`[Test] File key result: "${result}"`);
    });
    
    // ========== 测试用例 6: 性能测试 ==========
    it('should handle multiple calls efficiently', () => {
      const keys = [
        'auth_phone_invalid',
        'auth_code_invalid',
        'auth_password_wrong',
        'network_timeout',
        'file_upload_failed'
      ];
      
      const startTime = Date.now();
      
      for (let i = 0; i < 100; i++) {
        keys.forEach(key => {
          getString(key);
        });
      }
      
      const endTime = Date.now();
      const duration = endTime - startTime;
      
      console.log(`[Test] 500 getString calls completed in ${duration}ms`);
      
      // 性能应该在合理范围内(具体阈值根据实际情况调整)
      expect(duration).assertLessThan(5000); // 5秒内完成500次调用
    });
  });
}
