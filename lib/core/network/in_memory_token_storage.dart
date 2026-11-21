import 'package:chagok_mobile/core/network/auth_tokens.dart';
import 'package:chagok_mobile/core/network/token_storage.dart';

/// 앱을 끄면 사라지는 메모리 토큰 저장소.
class InMemoryTokenStorage implements TokenStorage {
  AuthTokens? _tokens;

  @override
  Future<AuthTokens?> read() async => _tokens;

  @override
  Future<void> save(AuthTokens tokens) async => _tokens = tokens;

  @override
  Future<void> clear() async => _tokens = null;

  /// 비교와 바꾸기 사이에 기다림이 없어, 한 번에 끝나므로 다른 저장이 끼어들 수 없습니다.
  @override
  Future<bool> replaceIf({
    required AuthTokens expected,
    AuthTokens? next,
  }) async {
    if (_tokens?.refreshToken != expected.refreshToken) return false;
    _tokens = next;
    return true;
  }
}
