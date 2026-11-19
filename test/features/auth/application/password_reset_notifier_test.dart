import 'package:chagok_mobile/features/auth/application/password_reset_notifier.dart';
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
  });

  PasswordResetNotifier notifier() =>
      container.read(passwordResetProvider.notifier);

  group('PasswordResetNotifier', () {
    test('올바른 전화번호를 넣으면 인증번호를 보낸다', () async {
      notifier().updatePhoneNumber('010-1111-1111');

      final isSent = await notifier().requestVerificationCode();

      expect(isSent, isTrue);
      expect(repository.sentCodes, ['01011111111']);
    });

    test('전화번호 형식이 틀리면 인증번호를 보내지 않는다', () async {
      notifier().updatePhoneNumber('1234');

      final isSent = await notifier().requestVerificationCode();

      expect(isSent, isFalse);
      expect(repository.sentCodes, isEmpty);
    });

    test('규칙에 맞지 않는 새 비밀번호로는 바꿀 수 없다', () {
      notifier()
        ..updateNewPassword('short')
        ..updateNewPasswordConfirm('short');

      final form = container.read(passwordResetProvider);
      expect(form.isNewPasswordValid, isFalse);
      expect(form.canReset, isFalse);
    });

    test('확인 칸이 다르면 불일치로 표시한다', () {
      notifier()
        ..updateNewPassword('chagok12!')
        ..updateNewPasswordConfirm('chagok12');

      expect(container.read(passwordResetProvider).hasPasswordMismatch, isTrue);
    });

    test('새 비밀번호를 저장하면 전화번호와 함께 저장소에 넘긴다', () async {
      notifier()
        ..updatePhoneNumber('010-1111-1111')
        ..updateNewPassword('chagok12!')
        ..updateNewPasswordConfirm('chagok12!');

      final isReset = await notifier().reset();

      expect(isReset, isTrue);
      expect(repository.resets.single, {
        'phoneNumber': '01011111111',
        'newPassword': 'chagok12!',
      });
    });

    test('저장이 실패하면 오류 문구를 상태에 담는다', () async {
      repository.error = const AuthException('가입하지 않은 전화번호예요.');
      notifier()
        ..updatePhoneNumber('01011111111')
        ..updateNewPassword('chagok12!')
        ..updateNewPasswordConfirm('chagok12!');

      final isReset = await notifier().reset();

      expect(isReset, isFalse);
      expect(
        container.read(passwordResetProvider).errorMessage,
        '가입하지 않은 전화번호예요.',
      );
    });
  });
}
