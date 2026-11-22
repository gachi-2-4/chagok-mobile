import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 저장소 루트의 `.env`를 읽어 실행 설정을 돌려줍니다.
///
/// `main`에서 앱을 띄우기 전에 한 번 불러 [appEnvProvider]에 넣습니다.
/// 파일이 없거나 비어 있으면 빈 값을 돌려줘 서버 없이 예시 데이터로 돌게 합니다.
Future<Map<String, String>> loadAppEnv() async {
  await dotenv.load(isOptional: true);
  return Map.unmodifiable(dotenv.env);
}

/// `.env`에서 읽은 실행 설정.
///
/// 기본값은 빈 값이라 테스트는 `.env`와 상관없이 예시 저장소로 돕니다.
/// 실제 값은 `main`에서 [loadAppEnv]로 읽어 override합니다.
final appEnvProvider = Provider<Map<String, String>>((ref) => const {});

/// 차곡 API 서버 주소. 예: `https://api.chagok.app`
///
/// `.env`의 `API_BASE_URL`에 적습니다. 비어 있으면 각 기능은 서버 대신
/// 예시·메모리 저장소를 씁니다. 서버 없이도 화면을 만들고 테스트할 수 있게
/// 하기 위해서입니다.
final apiBaseUrlProvider = Provider<String>(
  (ref) => ref.watch(appEnvProvider)['API_BASE_URL']?.trim() ?? '',
);

/// [apiBaseUrlProvider]가 `http://` 주소여도 요청을 보낼지 여부.
///
/// HTTPS가 아직 없는 테스트 서버에 붙일 때 `.env`의 `ALLOW_INSECURE_HTTP=true`로
/// 켭니다. 대회 심사용 release APK도 HTTP 서버에 붙어야 해서 release 빌드에서도
/// 켤 수 있습니다. 토큰·비밀번호가 암호화되지 않고 오가므로 서버에 HTTPS가 생기면
/// `.env`에서 끕니다. 켜도 [apiBaseUrlProvider]의 호스트로만 HTTP를 보냅니다.
final isInsecureHttpAllowedProvider = Provider<bool>(
  (ref) => ref.watch(appEnvProvider)['ALLOW_INSECURE_HTTP'] == 'true',
);

/// 서버 API를 쓸지 여부. [apiBaseUrlProvider]가 비어 있지 않으면 true.
final isApiEnabledProvider = Provider<bool>(
  (ref) => ref.watch(apiBaseUrlProvider).isNotEmpty,
);
