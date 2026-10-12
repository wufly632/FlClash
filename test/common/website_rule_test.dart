import 'package:fl_clash/common/website_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes domains and extracts only the URL hostname', () {
    for (final input in [
      'example.com',
      ' EXAMPLE.com. ',
      'https://EXAMPLE.com:8443/path?q=value#section',
      'example.com/path',
      '//example.com/path',
    ]) {
      expect(websiteRuleDomain(input), 'example.com', reason: input);
    }
    expect(websiteRuleDomain('www.example.com'), 'www.example.com');
    expect(websiteRuleDomain('xn--fiqs8s.example'), 'xn--fiqs8s.example');
  });

  test('rejects malformed domains, IPs, wildcards and rule injection', () {
    for (final input in [
      '',
      'localhost',
      '*.example.com',
      '.example.com',
      'example..com',
      '-example.com',
      'example-.com',
      'exa_mple.com',
      'example.com,REJECT',
      'example.com\nother.com',
      'https://user:password@example.com',
      'ftp://example.com',
      'https://',
      'https://example.com:65536',
      'https://example.com:abc',
      '127.0.0.1',
      'https://[::1]/',
      '999.999.999.999',
      '中文.example',
      '${'a' * 64}.com',
    ]) {
      expect(websiteRuleDomain(input), isNull, reason: input);
    }
  });
}
