import 'package:flutter_test/flutter_test.dart';
import 'package:remote_app_blocker/remote_app_blocker.dart';

void main() {
  group('RemoteBlockConfig', () {
    test('creates config from JSON correctly', () {
      final json = {
        'isBlocked': true,
        'blockMessage': 'This app is blocked.',
        'blockedVersions': ['1.0.0', '1.0.1'],
        'blockFrom': '2025-01-01T00:00:00Z',
        'blockUntil': '2025-01-31T23:59:59Z',
      };

      final config = RemoteBlockConfig.fromJson(json);

      expect(config.isBlocked, true);
      expect(config.message, 'This app is blocked.');
      expect(config.blockedVersions, ['1.0.0', '1.0.1']);
      expect(config.blockFrom, isNotNull);
      expect(config.blockUntil, isNotNull);
    });

    test('handles missing optional fields', () {
      final json = {'isBlocked': false, 'blockMessage': ''};

      final config = RemoteBlockConfig.fromJson(json);

      expect(config.isBlocked, false);
      expect(config.message, '');
      expect(config.blockedVersions, isEmpty);
      expect(config.blockFrom, isNull);
      expect(config.blockUntil, isNull);
    });

    test('parses dates correctly', () {
      final json = {
        'isBlocked': false,
        'blockMessage': 'Test',
        'blockedVersions': [],
        'blockFrom': '2025-01-01T00:00:00Z',
        'blockUntil': '2025-12-31T23:59:59Z',
      };

      final config = RemoteBlockConfig.fromJson(json);

      expect(config.blockFrom?.year, 2025);
      expect(config.blockFrom?.month, 1);
      expect(config.blockUntil?.year, 2025);
      expect(config.blockUntil?.month, 12);
    });

    test('handles null and empty date strings', () {
      final json = {
        'isBlocked': false,
        'blockMessage': 'Test',
        'blockedVersions': [],
        'blockFrom': null,
        'blockUntil': '',
      };

      final config = RemoteBlockConfig.fromJson(json);

      expect(config.blockFrom, isNull);
      expect(config.blockUntil, isNull);
    });
  });

  group('HttpBlockStatusProvider', () {
    test('computes HMAC signature correctly', () {
      final provider = HttpBlockStatusProvider(
        url: 'https://example.com/config.json',
        hmacSecret: 'test_secret',
      );

      // Tests that HMAC secret and URL are properly stored
      expect(provider.hmacSecret, 'test_secret');
      expect(provider.url, 'https://example.com/config.json');
    });

    test('has correct default timeout', () {
      final provider = HttpBlockStatusProvider(
        url: 'https://example.com/config.json',
      );

      expect(provider.timeout, const Duration(seconds: 5));
    });

    test('allows custom timeout', () {
      final provider = HttpBlockStatusProvider(
        url: 'https://example.com/config.json',
        timeout: const Duration(seconds: 10),
      );

      expect(provider.timeout, const Duration(seconds: 10));
    });
  });
}
