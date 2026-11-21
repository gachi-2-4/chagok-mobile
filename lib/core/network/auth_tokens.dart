import 'package:chagok_mobile/core/network/json_map.dart';

/// 로그인하면 받는 토큰 한 쌍.
class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  /// 로그인·회원가입·토큰 재발급 응답에서 토큰만 꺼냅니다.
  factory AuthTokens.fromJson(JsonMap json) {
    return AuthTokens(
      accessToken: json.string('accessToken'),
      refreshToken: json.string('refreshToken'),
    );
  }

  /// API를 부를 때 `Authorization: Bearer`에 넣는 토큰. 1시간 유효합니다.
  final String accessToken;

  /// [accessToken]이 만료되면 새 토큰을 받는 데 쓰는 토큰.
  final String refreshToken;
}
