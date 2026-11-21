import 'package:chagok_mobile/features/settings/data/app_version_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 설치된 앱 버전. 설정의 "앱 버전" 줄에 보여 줍니다.
final appVersionProvider = AsyncNotifierProvider<AppVersionNotifier, String>(
  AppVersionNotifier.new,
);

/// 앱 버전을 한 번 읽어 둡니다. 앱을 쓰는 동안 버전은 바뀌지 않습니다.
class AppVersionNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() =>
      ref.watch(appVersionRepositoryProvider).fetchVersion();
}
