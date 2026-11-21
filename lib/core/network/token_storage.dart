import 'package:chagok_mobile/core/network/api_config.dart';
import 'package:chagok_mobile/core/network/auth_tokens.dart';
import 'package:chagok_mobile/core/network/in_memory_token_storage.dart';
import 'package:chagok_mobile/core/network/secure_token_storage.dart';
import 'package:chagok_mobile/core/network/session_notifier.dart';
import 'package:chagok_mobile/core/network/session_tracking_token_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 로그인 토큰을 저장하고 꺼내는 창구.
abstract interface class TokenStorage {
  /// 저장한 토큰. 로그인하지 않았으면 null.
  Future<AuthTokens?> read();

  /// [tokens]를 저장합니다. 앞서 저장한 토큰은 덮어씁니다.
  ///
  /// [remember]가 false면 앱을 끄면 사라지도록 기기에 남기지 않습니다.
  /// 로그인할 때 "자동 로그인"을 끈 경우입니다. 재발급한 토큰도 같은 방식으로 둡니다.
  Future<void> save(AuthTokens tokens, {bool remember = true});

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

/// 토큰을 실제로 담는 저장소. 서버를 쓰면 기기 보안 저장소, 아니면 메모리입니다.
///
/// 테스트에서 미리 토큰을 넣어 둔 저장소로 바꿔 끼울 수 있게 따로 둡니다.
final tokenStoreProvider = Provider<TokenStorage>((ref) {
  if (!ref.watch(isApiEnabledProvider)) return InMemoryTokenStorage();
  return SecureTokenStorage();
});

/// 앱 전역 [TokenStorage].
///
/// 토큰을 저장하거나 지울 때마다 [sessionProvider]에 알려, 로그인·로그아웃·
/// 재발급 실패가 곧바로 화면 이동(로그인 화면 ↔ 홈)으로 이어지게 합니다.
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SessionTrackingTokenStorage(
    ref.watch(tokenStoreProvider),
    onChanged: ({required isSignedIn}) =>
        ref.read(sessionProvider.notifier).update(isSignedIn: isSignedIn),
  );
});
