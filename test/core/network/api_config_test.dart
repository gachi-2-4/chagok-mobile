import 'package:chagok_mobile/core/network/api_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isInsecureHttpAllowedProvider', () {
    test('ALLOW_INSECURE_HTTP를 넘기지 않으면 HTTP를 허용하지 않는다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final isAllowed = container.read(isInsecureHttpAllowedProvider);

      expect(isAllowed, isFalse);
    });
  });
}
