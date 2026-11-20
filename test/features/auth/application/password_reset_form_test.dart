import 'package:chagok_mobile/features/auth/application/password_reset_form.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const validPassword = 'chagok12!';

  group('PasswordResetForm', () {
    test('전화번호 형식이 맞으면 인증번호를 요청할 수 있다', () {
      const form = PasswordResetForm(phoneNumber: '01011111111');

      expect(form.canRequestCode, isTrue);
    });

    test('확인 칸을 채웠는데 새 비밀번호와 다르면 hasPasswordMismatch가 true다', () {
      const form = PasswordResetForm(
        newPassword: validPassword,
        newPasswordConfirm: 'other12!',
      );

      expect(form.hasPasswordMismatch, isTrue);
      expect(form.canReset, isFalse);
    });

    test('확인 칸이 비어 있으면 hasPasswordMismatch가 false다', () {
      const form = PasswordResetForm(newPassword: validPassword);

      expect(form.hasPasswordMismatch, isFalse);
    });

    test('인증을 마치고 새 비밀번호가 규칙에 맞고 확인 칸과 같으면 바꿀 수 있다', () {
      const form = PasswordResetForm(
        phoneNumber: '010-1111-1111',
        codeSentTo: '01011111111',
        verificationToken: 'token',
        newPassword: validPassword,
        newPasswordConfirm: validPassword,
      );

      expect(form.canReset, isTrue);
    });

    test('새 비밀번호를 바르게 넣어도 인증하지 않았으면 바꿀 수 없다', () {
      const form = PasswordResetForm(
        phoneNumber: '01011111111',
        newPassword: validPassword,
        newPasswordConfirm: validPassword,
      );

      expect(form.canReset, isFalse);
    });

    test('인증한 번호와 지금 입력한 번호가 다르면 인증하지 않은 것으로 본다', () {
      const form = PasswordResetForm(
        phoneNumber: '01022222222',
        codeSentTo: '01011111111',
        verificationToken: 'token',
      );

      expect(form.isVerified, isFalse);
    });

    test('copyWith에 실패를 넘기지 않으면 그대로 두고 null을 돌려주는 함수를 넘기면 지운다', () {
      const form = PasswordResetForm(failure: AuthFailure.unknown);

      expect(form.copyWith(newPassword: 'a').failure, AuthFailure.unknown);
      expect(form.copyWith(failure: () => null).failure, isNull);
    });
  });
}
