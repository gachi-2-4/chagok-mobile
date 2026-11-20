import 'package:chagok_mobile/features/auth/application/login_form.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginForm', () {
    test('전화번호 형식이 맞고 비밀번호를 넣으면 canSubmit이 true다', () {
      const form = LoginForm(phoneNumber: '010-1111-1111', password: 'secret');

      expect(form.canSubmit, isTrue);
    });

    test('보내는 중이면 입력이 맞아도 canSubmit이 false다', () {
      const form = LoginForm(
        phoneNumber: '01011111111',
        password: 'secret',
        isSubmitting: true,
      );

      expect(form.canSubmit, isFalse);
    });

    test('하이픈이 섞인 전화번호를 넣으면 숫자만 남긴 번호를 돌려준다', () {
      const form = LoginForm(phoneNumber: '010-1111-2222');

      expect(form.normalizedPhoneNumber, '01011112222');
    });

    test('copyWith에 null을 돌려주는 함수를 넘기면 실패 이유를 지운다', () {
      const form = LoginForm(failure: AuthFailure.wrongCredentials);

      expect(form.copyWith(failure: () => null).failure, isNull);
      expect(
        form.copyWith(password: 'x').failure,
        AuthFailure.wrongCredentials,
      );
    });
  });
}
