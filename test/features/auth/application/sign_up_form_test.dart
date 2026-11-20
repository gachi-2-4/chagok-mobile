import 'package:chagok_mobile/features/auth/application/sign_up_form.dart';
import 'package:chagok_mobile/features/auth/data/term.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const validForm = SignUpForm(
    phoneNumber: '01011111111',
    name: '김차곡',
    birthDate: '1995.03.21',
    password: 'chagok12!',
    passwordConfirm: 'chagok12!',
  );

  group('SignUpForm', () {
    test('정보를 모두 맞게 넣으면 인증번호를 요청할 수 있다', () {
      expect(validForm.canRequestCode, isTrue);
    });

    test('이름이 공백뿐이면 인증번호를 요청할 수 없다', () {
      expect(validForm.copyWith(name: '  ').canRequestCode, isFalse);
    });

    test('인증을 마치고 필수 약관에 모두 동의하면 가입을 마칠 수 있다', () {
      final form = validForm.copyWith(
        codeSentTo: () => '01011111111',
        verificationToken: () => 'token',
        agreedTerms: {Term.service, Term.privacy},
      );

      expect(form.canComplete, isTrue);
      expect(form.hasAgreedToAll, isFalse);
    });

    test('인증을 마쳤어도 필수 약관 하나라도 빠지면 가입을 마칠 수 없다', () {
      // 인증을 마친 상태로 두어, 약관 조건만으로 막히는지 봅니다.
      final form = validForm.copyWith(
        codeSentTo: () => '01011111111',
        verificationToken: () => 'token',
        agreedTerms: {Term.service, Term.marketing},
      );

      expect(form.canComplete, isFalse);
    });

    test('인증하지 않았으면 필수 약관에 모두 동의해도 가입을 마칠 수 없다', () {
      final form = validForm.copyWith(agreedTerms: Term.values.toSet());

      expect(form.canComplete, isFalse);
    });

    test('모든 약관에 동의하면 hasAgreedToAll이 true다', () {
      final form = validForm.copyWith(agreedTerms: Term.values.toSet());

      expect(form.hasAgreedToAll, isTrue);
    });
  });
}
