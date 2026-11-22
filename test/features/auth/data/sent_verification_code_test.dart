import 'package:chagok_mobile/features/auth/data/sent_verification_code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SentVerificationCode.fromJson', () {
    test('서버 응답을 넣으면 유효 시간·다시 받기 대기 시간·인증번호를 읽는다', () {
      final sent = SentVerificationCode.fromJson({
        'phoneNumber': '01041845036',
        'expiresIn': 180,
        'resendAvailableIn': 60,
        'code': '482913',
      });

      expect(sent.expiresIn, 180);
      expect(sent.resendAvailableIn, 60);
      expect(sent.code, '482913');
    });

    test('값이 없는 응답을 넣으면 기본 유효 시간과 대기 시간 0으로 읽는다', () {
      final sent = SentVerificationCode.fromJson({});

      expect(sent.expiresIn, SentVerificationCode.defaultExpiresIn);
      expect(sent.resendAvailableIn, 0);
      expect(sent.code, isNull);
    });

    test('숫자 자리에 문자열이 오면 FormatException을 던진다', () {
      expect(
        () => SentVerificationCode.fromJson({'expiresIn': '180'}),
        throwsFormatException,
      );
    });
  });
}
