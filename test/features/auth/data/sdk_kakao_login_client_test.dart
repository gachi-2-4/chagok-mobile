import 'package:chagok_mobile/features/auth/data/sdk_kakao_login_client.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() {
  group('isKakaoLoginCancelled', () {
    test('카카오계정 로그인 창을 닫아 CANCELED가 오면 취소로 본다', () {
      final error = PlatformException(
        code: 'CANCELED',
        message: 'User canceled login.',
      );

      expect(isKakaoLoginCancelled(error), isTrue);
    });

    test('SDK가 취소 이유로 알려 주면 취소로 본다', () {
      final error = KakaoClientException(ClientErrorCause.cancelled, '취소');

      expect(isKakaoLoginCancelled(error), isTrue);
    });

    test('다른 코드의 PlatformException이면 취소로 보지 않는다', () {
      final error = PlatformException(code: 'ERROR', message: 'failed');

      expect(isKakaoLoginCancelled(error), isFalse);
    });

    test('취소가 아닌 SDK 오류면 취소로 보지 않는다', () {
      final error = KakaoClientException(ClientErrorCause.unknown, '알 수 없음');

      expect(isKakaoLoginCancelled(error), isFalse);
    });
  });
}
