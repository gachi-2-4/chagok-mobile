import 'package:chagok_mobile/features/auth/application/sign_up_notifier.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
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
  });

  SignUpNotifier notifier() => container.read(signUpProvider.notifier);

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

    test('필수 약관에만 동의해도 가입을 마칠 수 있다', () {
      notifier()
        ..toggleTerm(Term.service)
        ..toggleTerm(Term.privacy);

      final form = container.read(signUpProvider);
      expect(form.canComplete, isTrue);
      expect(form.hasAgreedToAll, isFalse);
    });

    test('필수 약관 하나라도 빠지면 가입을 마칠 수 없다', () {
      notifier().toggleTerm(Term.service);

      expect(container.read(signUpProvider).canComplete, isFalse);
    });

    test('가입을 마치면 다듬은 값과 마케팅 동의 여부를 저장소에 넘긴다', () async {
      fillValidForm();
      notifier().toggleAllTerms();

      final isCompleted = await notifier().complete();

      expect(isCompleted, isTrue);
      expect(repository.signUps.single, {
        'phoneNumber': '01066453576',
        'name': '김차곡',
        'birthDate': '19950321',
        'password': 'chagok12!',
        'agreedToMarketing': true,
      });
    });

    test('가입이 실패하면 오류 문구를 상태에 담는다', () async {
      repository.error = const AuthException('이미 가입한 전화번호예요.');
      fillValidForm();
      notifier().toggleAllTerms();

      final isCompleted = await notifier().complete();

      final form = container.read(signUpProvider);
      expect(isCompleted, isFalse);
      expect(form.errorMessage, '이미 가입한 전화번호예요.');
      expect(form.isSubmitting, isFalse);
    });
  });
}
