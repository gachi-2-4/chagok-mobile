import 'package:chagok_mobile/features/auth/application/phone_verification_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneVerificationState', () {
    test('6자리를 모두 넣었고 시간이 남았으면 확인할 수 있다', () {
      const state = PhoneVerificationState(
        remainingSeconds: 10,
        code: '123456',
      );

      expect(state.canVerify, isTrue);
    });

    test('남은 시간이 0이면 만료로 보고 확인할 수 없다', () {
      const state = PhoneVerificationState(remainingSeconds: 0, code: '123456');

      expect(state.isExpired, isTrue);
      expect(state.canVerify, isFalse);
    });

    test('확인하는 중이면 확인할 수 없다', () {
      const state = PhoneVerificationState(
        remainingSeconds: 10,
        code: '123456',
        isSubmitting: true,
      );

      expect(state.canVerify, isFalse);
    });

    test('다시 받기 대기 시간이 남았으면 다시 받을 수 없다', () {
      const state = PhoneVerificationState(
        remainingSeconds: 10,
        resendRemainingSeconds: 1,
      );

      expect(state.canResend, isFalse);
    });

    test('다시 받기 대기 시간이 지났으면 다시 받을 수 있다', () {
      const state = PhoneVerificationState(remainingSeconds: 10);

      expect(state.canResend, isTrue);
    });

    test('확인하는 중이면 다시 받을 수 없다', () {
      const state = PhoneVerificationState(
        remainingSeconds: 10,
        isSubmitting: true,
      );

      expect(state.canResend, isFalse);
    });
  });
}
