import 'package:chagok_mobile/core/network/auth_tokens.dart';
import 'package:chagok_mobile/core/network/secure_token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const first = AuthTokens(accessToken: 'access-1', refreshToken: 'refresh-1');
  const second = AuthTokens(accessToken: 'access-2', refreshToken: 'refresh-2');

  /// 앱을 껐다 켠 것처럼, 같은 기기 저장소를 새로 읽는 저장소를 만듭니다.
  SecureTokenStorage reopen() => SecureTokenStorage();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('SecureTokenStorage', () {
    test('저장하면 앱을 다시 열어도 같은 토큰을 읽는다', () async {
      await SecureTokenStorage().save(first);

      final tokens = await reopen().read();

      expect(tokens?.accessToken, 'access-1');
      expect(tokens?.refreshToken, 'refresh-1');
    });

    test('자동 로그인을 끄고 저장하면 지금은 읽히지만 앱을 다시 열면 없다', () async {
      final storage = SecureTokenStorage();

      await storage.save(first, remember: false);

      expect((await storage.read())?.refreshToken, 'refresh-1');
      expect(await reopen().read(), isNull);
    });

    test('자동 로그인을 끄고 저장한 뒤 재발급하면 새 토큰도 기기에 남기지 않는다', () async {
      final storage = SecureTokenStorage();
      await storage.save(first, remember: false);

      await storage.replaceIf(expected: first, next: second);

      expect((await storage.read())?.refreshToken, 'refresh-2');
      expect(await reopen().read(), isNull);
    });

    test('지우면 앱을 다시 열어도 토큰이 없다', () async {
      final storage = SecureTokenStorage();
      await storage.save(first);

      await storage.clear();

      expect(await storage.read(), isNull);
      expect(await reopen().read(), isNull);
    });

    test('같은 세션이면 재발급 토큰으로 바꾸고 기기에도 남긴다', () async {
      final storage = SecureTokenStorage();
      await storage.save(first);

      final isReplaced = await storage.replaceIf(expected: first, next: second);

      expect(isReplaced, isTrue);
      expect((await reopen().read())?.refreshToken, 'refresh-2');
    });

    test('그사이 다른 세션으로 바뀌었으면 바꾸지 않고 false를 돌려준다', () async {
      final storage = SecureTokenStorage();
      await storage.save(second);

      final isReplaced = await storage.replaceIf(expected: first, next: first);

      expect(isReplaced, isFalse);
      expect((await storage.read())?.refreshToken, 'refresh-2');
    });

    test('재발급에 실패해 null로 바꾸면 기기에서도 지운다', () async {
      final storage = SecureTokenStorage();
      await storage.save(first);

      await storage.replaceIf(expected: first);

      expect(await reopen().read(), isNull);
    });

    test('기기에 토큰 하나만 남아 있으면 로그인하지 않은 것으로 본다', () async {
      FlutterSecureStorage.setMockInitialValues({
        'chagok.accessToken': 'access-1',
      });

      expect(await SecureTokenStorage().read(), isNull);
    });

    test('저장과 바꾸기를 동시에 부르면 부른 순서대로 처리한다', () async {
      final storage = SecureTokenStorage();

      final saving = storage.save(first);
      final replacing = storage.replaceIf(expected: first, next: second);
      await saving;

      expect(await replacing, isTrue);
      expect((await storage.read())?.refreshToken, 'refresh-2');
    });
  });
}
