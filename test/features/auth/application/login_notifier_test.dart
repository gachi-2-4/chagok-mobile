import 'package:chagok_mobile/features/auth/application/login_notifier.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(loginProvider, (_, _) {});
  });

  LoginNotifier notifier() => container.read(loginProvider.notifier);

  group('LoginNotifier', () {
    test('처음에는 자동 로그인이 켜져 있다', () {
      expect(container.read(loginProvider).keepSignedIn, isTrue);
    });

    test('전화번호와 비밀번호를 넣어야 로그인할 수 있다', () {
      notifier().updatePhoneNumber('010-1111-1111');
      expect(container.read(loginProvider).canSubmit, isFalse);

      notifier().updatePassword('secret');
      expect(container.read(loginProvider).canSubmit, isTrue);
    });

    test('로그인하면 숫자만 남긴 전화번호와 자동 로그인 여부를 넘긴다', () async {
      notifier()
        ..updatePhoneNumber('010-1111-1111')
        ..updatePassword('secret')
        ..toggleKeepSignedIn();

      final isLoggedIn = await notifier().logIn();

      expect(isLoggedIn, isTrue);
      expect(repository.logIns.single, {
        'phoneNumber': '01011111111',
        'password': 'secret',
        'keepSignedIn': false,
      });
    });

    test('로그인이 실패하면 오류 문구를 상태에 담는다', () async {
      repository.error = const AuthException('전화번호 또는 비밀번호가 맞지 않아요.');
      notifier()
        ..updatePhoneNumber('01011111111')
        ..updatePassword('wrong');

      final isLoggedIn = await notifier().logIn();

      expect(isLoggedIn, isFalse);
      expect(
        container.read(loginProvider).errorMessage,
        '전화번호 또는 비밀번호가 맞지 않아요.',
      );
    });

    test('실패한 뒤 입력을 고치면 오류 문구를 지운다', () async {
      repository.error = const AuthException('실패');
      notifier()
        ..updatePhoneNumber('01011111111')
        ..updatePassword('wrong');
      await notifier().logIn();

      notifier().updatePassword('right');

      expect(container.read(loginProvider).errorMessage, isNull);
    });
  });
}
