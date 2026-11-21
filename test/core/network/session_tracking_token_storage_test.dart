import 'package:chagok_mobile/core/network/auth_tokens.dart';
import 'package:chagok_mobile/core/network/in_memory_token_storage.dart';
import 'package:chagok_mobile/core/network/session_tracking_token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const first = AuthTokens(accessToken: 'access-1', refreshToken: 'refresh-1');
  const second = AuthTokens(accessToken: 'access-2', refreshToken: 'refresh-2');

  late List<bool> changes;
  late SessionTrackingTokenStorage storage;

  setUp(() {
    changes = [];
    storage = SessionTrackingTokenStorage(
      InMemoryTokenStorage(),
      onChanged: ({required isSignedIn}) => changes.add(isSignedIn),
    );
  });

  group('SessionTrackingTokenStorage', () {
    test('토큰을 저장하면 로그인했다고 알린다', () async {
      await storage.save(first);

      expect(changes, [true]);
      expect((await storage.read())?.refreshToken, 'refresh-1');
    });

    test('토큰을 지우면 로그아웃했다고 알린다', () async {
      await storage.save(first);

      await storage.clear();

      expect(changes, [true, false]);
    });

    test('재발급에 실패해 토큰을 지우면 로그아웃했다고 알린다', () async {
      await storage.save(first);

      await storage.replaceIf(expected: first);

      expect(changes, [true, false]);
    });

    test('재발급 토큰으로 바꾸면 로그인 상태가 그대로라 알리지 않는다', () async {
      await storage.save(first);

      await storage.replaceIf(expected: first, next: second);

      expect(changes, [true]);
    });

    test('다른 세션이라 바꾸지 않았으면 알리지 않는다', () async {
      await storage.save(second);

      await storage.replaceIf(expected: first);

      expect(changes, [true]);
    });
  });
}
