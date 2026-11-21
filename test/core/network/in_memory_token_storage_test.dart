import 'package:chagok_mobile/core/network/auth_tokens.dart';
import 'package:chagok_mobile/core/network/in_memory_token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const first = AuthTokens(accessToken: 'a-1', refreshToken: 'r-1');
  const renewed = AuthTokens(accessToken: 'a-2', refreshToken: 'r-2');
  const other = AuthTokens(accessToken: 'b-1', refreshToken: 'other');

  late InMemoryTokenStorage storage;

  setUp(() => storage = InMemoryTokenStorage());

  group('InMemoryTokenStorage.replaceIf', () {
    test('같은 세션이면 새 토큰으로 바꾸고 true를 돌려준다', () async {
      await storage.save(first);

      final isReplaced = await storage.replaceIf(
        expected: first,
        next: renewed,
      );

      expect(isReplaced, isTrue);
      expect((await storage.read())?.refreshToken, 'r-2');
    });

    test('세션이 바뀌었으면 그대로 두고 false를 돌려준다', () async {
      await storage.save(other);

      final isReplaced = await storage.replaceIf(
        expected: first,
        next: renewed,
      );

      expect(isReplaced, isFalse);
      expect((await storage.read())?.refreshToken, 'other');
    });

    test('같은 세션이고 새 토큰이 없으면 지운다', () async {
      await storage.save(first);

      await storage.replaceIf(expected: first);

      expect(await storage.read(), isNull);
    });
  });
}
