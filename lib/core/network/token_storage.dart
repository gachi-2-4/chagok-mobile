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
}

/// 앱 전역 [TokenStorage].
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  // TODO: 자동 로그인(앱을 다시 열어도 로그인 유지)을 붙일 때 기기 보안 저장소로 바꿉니다.
  return InMemoryTokenStorage();
});
