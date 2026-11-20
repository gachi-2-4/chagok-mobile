import 'dart:async';

import 'package:chagok_mobile/features/auth/application/password_reset_notifier.dart';
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
    // 화면이 보고 있는 것처럼 구독해 두어 autoDispose로 사라지지 않게 합니다.
    container.listen(passwordResetProvider, (_, _) {});
  });

  PasswordResetNotifier notifier() =>
      container.read(passwordResetProvider.notifier);

  /// [phoneNumber]로 인증번호를 받고 새 비밀번호까지 채웁니다.
  Future<void> prepareReset(String phoneNumber) async {
    notifier().updatePhoneNumber(phoneNumber);
    await notifier().requestVerificationCode();
    notifier()
      ..updateNewPassword('chagok12!')
      ..updateNewPasswordConfirm('chagok12!');
  }

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

    test('새 비밀번호가 규칙에 맞지 않으면 바꿀 수 없다', () {
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

    test('인증하지 않았으면 새 비밀번호를 저장하지 않는다', () async {
      await prepareReset('010-1111-1111');

      final isReset = await notifier().reset();

      expect(container.read(passwordResetProvider).canReset, isFalse);
      expect(isReset, isFalse);
      expect(repository.resets, isEmpty);
    });

    test('인증번호를 요청하는 중에 전화번호를 바꾸면 요청한 번호를 인증할 번호로 남긴다', () async {
      repository.sendGate = Completer<void>();
      notifier().updatePhoneNumber('010-1111-1111');
      final requesting = notifier().requestVerificationCode();

      notifier().updatePhoneNumber('010-2222-2222');
      repository.sendGate?.complete();
      await requesting;

      expect(container.read(passwordResetProvider).codeSentTo, '01011111111');
    });

    test('비밀번호 찾기를 벗어나 아무도 보지 않으면 입력값을 비운다', () async {
      final scoped = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(scoped.dispose);
      final subscription = scoped.listen(passwordResetProvider, (_, _) {});
      scoped
          .read(passwordResetProvider.notifier)
          .updatePhoneNumber('01011111111');

      subscription.close();
      await scoped.pump();

      expect(scoped.read(passwordResetProvider).phoneNumber, isEmpty);
    });

    test('인증한 뒤 새 비밀번호를 저장하면 전화번호·인증 증명과 함께 저장소에 넘긴다', () async {
      await prepareReset('010-1111-1111');
      notifier().markVerified(FakeAuthRepository.tokenFor('01011111111'));

      final isReset = await notifier().reset();

      expect(isReset, isTrue);
      expect(repository.resets.single, {
        'phoneNumber': '01011111111',
        'newPassword': 'chagok12!',
        'verificationToken': FakeAuthRepository.tokenFor('01011111111'),
      });
    });

    test('저장이 실패하면 실패 이유를 상태에 담는다', () async {
      await prepareReset('01011111111');
      notifier().markVerified(FakeAuthRepository.tokenFor('01011111111'));
      repository.error = const AuthException(AuthFailure.notRegistered);

      final isReset = await notifier().reset();

      expect(isReset, isFalse);
      expect(
        container.read(passwordResetProvider).failure,
        AuthFailure.notRegistered,
      );
    });
  });
}
