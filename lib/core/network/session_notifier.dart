import 'dart:async';

import 'package:chagok_mobile/core/network/api_config.dart';
import 'package:chagok_mobile/core/network/session_status.dart';
import 'package:chagok_mobile/core/network/token_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:chagok_mobile/core/network/session_status.dart';

/// 앱의 로그인 상태. 라우터가 보고 시작 화면·로그인 화면·홈 중 갈 곳을 정합니다.
final sessionProvider = NotifierProvider<SessionNotifier, SessionStatus>(
  SessionNotifier.new,
);

/// 지금 로그인해 있는지.
///
/// 내 계정 데이터를 다루는 저장소 Provider가 지켜봅니다. 로그인하거나 로그아웃하면
/// 저장소가 새로 만들어지고 그 데이터를 쓰는 Notifier도 다시 불러옵니다. 그래야 로그인 전에
/// 실패한 결과나 앞 계정의 데이터가 다음 로그인 뒤에 남지 않습니다.
final isSignedInProvider = Provider<bool>(
  (ref) => ref.watch(sessionProvider) == SessionStatus.signedIn,
);

/// 로그인해야 앱을 쓸 수 있는지. 서버를 쓸 때만 true입니다.
///
/// 서버 없이 예시 데이터로 돌릴 때는 로그인 없이 홈부터 열어 화면을 바로 볼 수 있게 합니다.
final requiresLoginProvider = Provider<bool>(
  (ref) => ref.watch(isApiEnabledProvider),
);

/// 앱을 열 때 기기에 저장한 토큰으로 로그인 상태를 정하고, 그 뒤로는 토큰 저장소가
/// 알려 주는 대로 바꿉니다. 토큰이 남아 있으면 로그인 없이 바로 들어갑니다(자동 로그인).
class SessionNotifier extends Notifier<SessionStatus> {
  @override
  SessionStatus build() {
    unawaited(_restore());
    return SessionStatus.checking;
  }

  /// 토큰을 저장하거나 지웠을 때 부릅니다.
  void update({required bool isSignedIn}) {
    state = isSignedIn ? SessionStatus.signedIn : SessionStatus.signedOut;
  }

  Future<void> _restore() async {
    var isSignedIn = false;
    try {
      isSignedIn = await ref.read(tokenStorageProvider).read() != null;
    } catch (error, stackTrace) {
      // 기기 저장소를 읽지 못하면 다시 로그인하게 합니다.
      debugPrint('저장한 로그인 정보를 읽지 못했습니다: $error\n$stackTrace');
    }
    // 확인하는 사이 로그인·로그아웃으로 이미 정해졌으면 덮어쓰지 않습니다.
    if (!ref.mounted || state != SessionStatus.checking) return;
    update(isSignedIn: isSignedIn);
  }
}
