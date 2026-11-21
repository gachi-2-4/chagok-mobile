import 'package:chagok_mobile/core/network/auth_tokens.dart';
import 'package:chagok_mobile/core/network/token_storage.dart';

/// 토큰이 생기거나 사라졌음을 알리는 함수.
typedef SessionChanged = void Function({required bool isSignedIn});

/// 다른 [TokenStorage]를 감싸, 토큰을 저장·삭제할 때마다 [onChanged]로 알립니다.
///
/// 로그인(저장)·로그아웃(삭제)·재발급 실패(삭제)가 어디서 일어나든 세션 상태가
/// 한 곳에서 바뀌도록 하려고 씁니다.
class SessionTrackingTokenStorage implements TokenStorage {
  SessionTrackingTokenStorage(this._inner, {required this.onChanged});

  final TokenStorage _inner;

  /// 토큰을 저장하면 `isSignedIn: true`, 지우면 false로 부릅니다.
  final SessionChanged onChanged;

  @override
  Future<AuthTokens?> read() => _inner.read();

  @override
  Future<void> save(AuthTokens tokens, {bool remember = true}) async {
    await _inner.save(tokens, remember: remember);
    onChanged(isSignedIn: true);
  }

  @override
  Future<void> clear() async {
    await _inner.clear();
    onChanged(isSignedIn: false);
  }

  @override
  Future<bool> replaceIf({
    required AuthTokens expected,
    AuthTokens? next,
  }) async {
    final isReplaced = await _inner.replaceIf(expected: expected, next: next);
    // 재발급에 실패해 토큰을 지웠으면 다시 로그인해야 합니다.
    if (isReplaced && next == null) onChanged(isSignedIn: false);
    return isReplaced;
  }
}
