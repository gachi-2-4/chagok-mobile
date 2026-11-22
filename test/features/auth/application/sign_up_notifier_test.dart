import 'dart:async';

import 'package:chagok_mobile/features/auth/application/sign_up_notifier.dart';
import 'package:chagok_mobile/features/auth/data/auth_exception.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:chagok_mobile/features/auth/data/sent_verification_code.dart';
import 'package:chagok_mobile/features/auth/data/term.dart';
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
    container.listen(signUpProvider, (_, _) {});
  });

  SignUpNotifier notifier() => container.read(signUpProvider.notifier);

  /// 인증번호를 받고 인증까지 마친 상태로 만듭니다.
  Future<void> verifyPhone() async {
    await notifier().requestVerificationCode();
    notifier().markVerified(FakeAuthRepository.tokenFor('01066453576'));
  }

  void fillValidForm() {
    notifier()
      ..updatePhoneNumber('010-6645-3576')
      ..updateName(' 김차곡 ')
      ..updateBirthDate('1995.03.21')
      ..updatePassword('chagok12!')
      ..updatePasswordConfirm('chagok12!');
  }

  group('SignUpNotifier', () {
    test('모든 칸을 바르게 채우면 인증번호를 받을 수 있다', () {
      fillValidForm();

      expect(container.read(signUpProvider).canRequestCode, isTrue);
    });

    test('비밀번호 확인이 다르면 불일치로 표시하고 인증번호를 받을 수 없다', () {
      fillValidForm();

      notifier().updatePasswordConfirm('chagok12?');

      final form = container.read(signUpProvider);
      expect(form.hasPasswordMismatch, isTrue);
      expect(form.canRequestCode, isFalse);
    });

    test('인증번호를 요청하면 숫자만 남긴 전화번호로 보낸다', () async {
      fillValidForm();

      final isSent = await notifier().requestVerificationCode();

      expect(isSent, isTrue);
      expect(repository.sentCodes, ['01066453576']);
    });

    test('입력이 모자라면 인증번호를 보내지 않는다', () async {
      notifier().updatePhoneNumber('01066453576');

      final isSent = await notifier().requestVerificationCode();

      expect(isSent, isFalse);
      expect(repository.sentCodes, isEmpty);
    });

    test('전체 동의를 누르면 모든 약관에 동의하고, 다시 누르면 모두 해제한다', () {
      notifier().toggleAllTerms();
      expect(container.read(signUpProvider).agreedTerms, Term.values.toSet());

      notifier().toggleAllTerms();
      expect(container.read(signUpProvider).agreedTerms, isEmpty);
    });

    test('인증번호를 요청하면 요청한 번호를 인증할 번호로 남긴다', () async {
      fillValidForm();

      await notifier().requestVerificationCode();

      expect(container.read(signUpProvider).codeSentTo, '01066453576');
    });

    test('인증번호를 요청하면 보낸 결과를 남긴다', () async {
      const sent = SentVerificationCode(resendAvailableIn: 60, code: '482913');
      repository.sentResult = sent;
      fillValidForm();

      await notifier().requestVerificationCode();

      expect(container.read(signUpProvider).sentCode, sent);
    });

    test('인증번호를 요청하는 중에 전화번호를 바꾸면 요청한 번호를 인증할 번호로 남긴다', () async {
      repository.sendGate = Completer<void>();
      fillValidForm();
      final requesting = notifier().requestVerificationCode();

      notifier().updatePhoneNumber('010-9999-9999');
      repository.sendGate?.complete();
      await requesting;

      expect(container.read(signUpProvider).codeSentTo, '01066453576');
      expect(container.read(signUpProvider).isVerified, isFalse);
    });

    test('인증을 마친 뒤 전화번호를 바꾸면 인증을 다시 해야 한다', () async {
      fillValidForm();
      await verifyPhone();

      notifier().updatePhoneNumber('010-9999-9999');

      expect(container.read(signUpProvider).isVerified, isFalse);
    });

    test('가입 흐름을 벗어나 아무도 보지 않으면 입력값을 비운다', () async {
      final scoped = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(scoped.dispose);
      final subscription = scoped.listen(signUpProvider, (_, _) {});
      scoped.read(signUpProvider.notifier).updatePhoneNumber('01066453576');

      subscription.close();
      await scoped.pump();

      expect(scoped.read(signUpProvider).phoneNumber, isEmpty);
    });

    test('인증하지 않았으면 약관에 모두 동의해도 가입을 마칠 수 없다', () async {
      fillValidForm();
      notifier().toggleAllTerms();

      final isCompleted = await notifier().complete();

      expect(container.read(signUpProvider).canComplete, isFalse);
      expect(isCompleted, isFalse);
      expect(repository.signUps, isEmpty);
    });

    test('가입 정보를 채우지 않았으면 인증 증명이 있어도 가입을 마칠 수 없다', () async {
      notifier()
        ..markVerified('token')
        ..toggleAllTerms();

      final isCompleted = await notifier().complete();

      expect(isCompleted, isFalse);
      expect(repository.signUps, isEmpty);
    });

    test('필수 약관에만 동의하면 가입을 마칠 수 있다', () async {
      fillValidForm();
      await verifyPhone();
      notifier()
        ..toggleTerm(Term.service)
        ..toggleTerm(Term.privacy);

      final form = container.read(signUpProvider);
      expect(form.canComplete, isTrue);
      expect(form.hasAgreedToAll, isFalse);
    });

    test('필수 약관 하나라도 빠지면 가입을 마칠 수 없다', () async {
      fillValidForm();
      await verifyPhone();
      notifier().toggleTerm(Term.service);

      expect(container.read(signUpProvider).canComplete, isFalse);
    });

    test('가입을 마치면 다듬은 값과 마케팅 동의 여부, 인증 증명을 저장소에 넘긴다', () async {
      fillValidForm();
      await verifyPhone();
      notifier().toggleAllTerms();

      final isCompleted = await notifier().complete();

      expect(isCompleted, isTrue);
      expect(repository.signUps.single, {
        'phoneNumber': '01066453576',
        'name': '김차곡',
        'birthDate': '19950321',
        'password': 'chagok12!',
        'agreedToMarketing': true,
        'verificationToken': FakeAuthRepository.tokenFor('01066453576'),
      });
    });

    test('가입이 실패하면 실패 이유를 상태에 담는다', () async {
      fillValidForm();
      await verifyPhone();
      repository.error = const AuthException(AuthFailure.alreadyRegistered);
      notifier().toggleAllTerms();

      final isCompleted = await notifier().complete();

      final form = container.read(signUpProvider);
      expect(isCompleted, isFalse);
      expect(form.failure, AuthFailure.alreadyRegistered);
      expect(form.isSubmitting, isFalse);
    });

    test('AuthException이 아닌 예외가 나면 unknown으로 남기고 보내는 중 상태를 푼다', () async {
      fillValidForm();
      await verifyPhone();
      repository.error = Exception('network');
      notifier().toggleAllTerms();

      final isCompleted = await notifier().complete();

      final form = container.read(signUpProvider);
      expect(isCompleted, isFalse);
      expect(form.failure, AuthFailure.unknown);
      expect(form.isSubmitting, isFalse);
    });
  });
}
