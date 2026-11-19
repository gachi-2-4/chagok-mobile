import 'package:chagok_mobile/features/auth/application/login_notifier.dart';
import 'package:chagok_mobile/features/auth/data/auth_exception.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
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
    test('처음 읽으면 자동 로그인이 켜져 있다', () {
      expect(container.read(loginProvider).keepSignedIn, isTrue);
    });

    test('전화번호와 비밀번호를 모두 넣으면 로그인할 수 있다', () {
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

    test('로그인이 실패하면 실패 이유를 상태에 담는다', () async {
      repository.error = const AuthException(AuthFailure.wrongCredentials);
      notifier()
        ..updatePhoneNumber('01011111111')
        ..updatePassword('wrong');

      final isLoggedIn = await notifier().logIn();

      expect(isLoggedIn, isFalse);
      expect(
        container.read(loginProvider).failure,
        AuthFailure.wrongCredentials,
      );
    });

    test('실패한 뒤 입력을 고치면 실패 이유를 지운다', () async {
      repository.error = const AuthException(AuthFailure.wrongCredentials);
      notifier()
        ..updatePhoneNumber('01011111111')
        ..updatePassword('wrong');
      await notifier().logIn();

      notifier().updatePassword('right');

      expect(container.read(loginProvider).failure, isNull);
    });

    test('AuthException이 아닌 예외가 나면 unknown으로 남기고 로그인 중 상태를 푼다', () async {
      repository.error = Exception('network');
      notifier()
        ..updatePhoneNumber('01011111111')
        ..updatePassword('secret');

      final isLoggedIn = await notifier().logIn();

      final form = container.read(loginProvider);
      expect(isLoggedIn, isFalse);
      expect(form.failure, AuthFailure.unknown);
      expect(form.isSubmitting, isFalse);
    });
  });
}
