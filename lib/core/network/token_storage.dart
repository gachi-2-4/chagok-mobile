import 'package:chagok_mobile/core/network/auth_tokens.dart';
import 'package:chagok_mobile/core/network/in_memory_token_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 로그인 토큰을 저장하고 꺼내는 창구.
abstract interface class TokenStorage {
  /// 저장한 토큰. 로그인하지 않았으면 null.
  Future<AuthTokens?> read();

  /// [tokens]를 저장합니다. 앞서 저장한 토큰은 덮어씁니다.
  Future<void> save(AuthTokens tokens);

  /// 저장한 토큰을 지웁니다. 로그아웃·탈퇴·재발급 실패 때 부릅니다.
  Future<void> clear();

  /// 저장한 토큰이 [expected]와 같은 세션(같은 Refresh Token)일 때만 [next]로 바꿉니다.
  /// [next]가 null이면 지웁니다. 바꿨으면 true, 세션이 이미 바뀌어 그대로 뒀으면 false.
  ///
  /// 토큰 재발급이 그사이 로그인·로그아웃한 다른 세션을 덮어쓰지 않게 하려고 씁니다.
  /// 구현은 비교와 바꾸기 사이에 다른 [save]·[clear]가 끼어들지 않게 해야 합니다.
  /// 기기 저장소처럼 읽고 쓰기를 기다려야 하는 구현은 잠금으로 직렬화합니다.
  Future<bool> replaceIf({required AuthTokens expected, AuthTokens? next});
}

/// 앱 전역 [TokenStorage].
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  // TODO: 자동 로그인(앱을 다시 열어도 로그인 유지)을 붙일 때 기기 보안 저장소로 바꿉니다.
  return InMemoryTokenStorage();
});
