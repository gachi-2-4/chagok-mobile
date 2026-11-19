import 'package:chagok_mobile/features/auth/application/password_reset_form.dart';
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

    test('새 비밀번호가 규칙에 맞고 확인 칸과 같으면 바꿀 수 있다', () {
      const form = PasswordResetForm(
        newPassword: validPassword,
        newPasswordConfirm: validPassword,
      );

      expect(form.canReset, isTrue);
    });
  });
}
