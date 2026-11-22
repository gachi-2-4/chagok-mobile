import 'package:chagok_mobile/features/auth/data/sdk_kakao_login_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 카카오에 로그인해 카카오 액세스 토큰을 받는 창구.
///
/// 카카오 SDK를 Repository 안으로 숨기고, 테스트에서 가짜로 바꾸려고 둡니다.
abstract interface class KakaoLoginClient {
  /// 카카오 로그인을 띄우고 카카오 액세스 토큰을 돌려줍니다.
  ///
  /// 사용자가 로그인을 취소하면 null입니다. 그 밖의 실패는 예외로 던집니다.
  Future<String?> logIn();
}

/// 앱 전역 [KakaoLoginClient].
final kakaoLoginClientProvider = Provider<KakaoLoginClient>(
  (ref) => SdkKakaoLoginClient(),
);
