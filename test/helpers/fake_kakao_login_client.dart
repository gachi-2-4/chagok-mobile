import 'package:chagok_mobile/features/auth/data/kakao_login_client.dart';

/// 카카오 SDK 없이 정해 둔 카카오 토큰을 돌려주는 가짜 [KakaoLoginClient].
class FakeKakaoLoginClient implements KakaoLoginClient {
  FakeKakaoLoginClient({this.accessToken = 'kakao-token', this.error});

  /// [logIn]이 돌려줄 토큰. null이면 사용자가 취소한 것으로 봅니다.
  String? accessToken;

  /// 값이 있으면 [logIn]에서 이 예외를 던집니다.
  Exception? error;

  /// [logIn]을 부른 횟수.
  int logInCount = 0;

  @override
  Future<String?> logIn() async {
    logInCount++;
    if (error case final error?) throw error;
    return accessToken;
  }
}
