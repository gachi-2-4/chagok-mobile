import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 차곡 API 서버 주소. 예: `https://api.chagok.app`
///
/// 빌드할 때 `--dart-define=API_BASE_URL=<주소>`로 넘깁니다. 넘기지 않으면 빈 값이고,
/// 그때 각 기능은 서버 대신 예시·메모리 저장소를 씁니다. 서버 없이도 화면을
/// 만들고 테스트할 수 있게 하기 위해서입니다.
final apiBaseUrlProvider = Provider<String>(
  (ref) => const String.fromEnvironment('API_BASE_URL'),
);

/// 서버 API를 쓸지 여부. [apiBaseUrlProvider]가 비어 있지 않으면 true.
final isApiEnabledProvider = Provider<bool>(
  (ref) => ref.watch(apiBaseUrlProvider).isNotEmpty,
);
