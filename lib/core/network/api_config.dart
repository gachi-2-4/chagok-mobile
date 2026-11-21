import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 차곡 API 서버 주소. 예: `https://api.chagok.app`
///
/// 빌드할 때 `--dart-define=API_BASE_URL=<주소>`로 넘깁니다. 넘기지 않으면 빈 값이고,
/// 그때 각 기능은 서버 대신 예시·메모리 저장소를 씁니다. 서버 없이도 화면을
/// 만들고 테스트할 수 있게 하기 위해서입니다.
final apiBaseUrlProvider = Provider<String>(
  (ref) => const String.fromEnvironment('API_BASE_URL'),
);

/// [apiBaseUrlProvider]가 `http://` 주소여도 요청을 보낼지 여부.
///
/// HTTPS가 아직 없는 테스트 서버에 붙일 때 `--dart-define=ALLOW_INSECURE_HTTP=true`로
/// 켭니다. 토큰·비밀번호가 암호화되지 않고 오가므로 release 빌드에서는 켜도 false입니다.
final isInsecureHttpAllowedProvider = Provider<bool>(
  (ref) => !kReleaseMode && const bool.fromEnvironment('ALLOW_INSECURE_HTTP'),
);

/// 서버 API를 쓸지 여부. [apiBaseUrlProvider]가 비어 있지 않으면 true.
final isApiEnabledProvider = Provider<bool>(
  (ref) => ref.watch(apiBaseUrlProvider).isNotEmpty,
);
