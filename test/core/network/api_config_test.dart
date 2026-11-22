import 'package:chagok_mobile/core/network/api_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer _containerWith(Map<String, String> env) {
  final container = ProviderContainer(
    overrides: [appEnvProvider.overrideWithValue(env)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('apiBaseUrlProvider', () {
    test('.env 값이 없으면 빈 주소를 돌려준다', () {
      final container = _containerWith(const {});

      final baseUrl = container.read(apiBaseUrlProvider);

      expect(baseUrl, isEmpty);
    });

    test('API_BASE_URL이 있으면 앞뒤 공백을 지운 주소를 돌려준다', () {
      final container = _containerWith(const {
        'API_BASE_URL': ' https://api.example.com ',
      });

      final baseUrl = container.read(apiBaseUrlProvider);

      expect(baseUrl, 'https://api.example.com');
    });
  });

  group('isApiEnabledProvider', () {
    test('API_BASE_URL이 비어 있으면 서버를 쓰지 않는다', () {
      final container = _containerWith(const {'API_BASE_URL': ''});

      final isEnabled = container.read(isApiEnabledProvider);

      expect(isEnabled, isFalse);
    });

    test('API_BASE_URL이 있으면 서버를 쓴다', () {
      final container = _containerWith(const {
        'API_BASE_URL': 'https://api.example.com',
      });

      final isEnabled = container.read(isApiEnabledProvider);

      expect(isEnabled, isTrue);
    });
  });

  group('isInsecureHttpAllowedProvider', () {
    test('ALLOW_INSECURE_HTTP가 없으면 HTTP를 허용하지 않는다', () {
      final container = _containerWith(const {});

      final isAllowed = container.read(isInsecureHttpAllowedProvider);

      expect(isAllowed, isFalse);
    });

    test('ALLOW_INSECURE_HTTP가 true면 HTTP를 허용한다', () {
      final container = _containerWith(const {'ALLOW_INSECURE_HTTP': 'true'});

      final isAllowed = container.read(isInsecureHttpAllowedProvider);

      expect(isAllowed, isTrue);
    });
  });
}
