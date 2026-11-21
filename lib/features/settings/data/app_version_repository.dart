import 'package:chagok_mobile/features/settings/data/platform_app_version_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 설치된 앱의 버전을 읽는 창구.
abstract interface class AppVersionRepository {
  /// 앱 버전. 예: "1.0.0"
  Future<String> fetchVersion();
}

/// 앱 전역 [AppVersionRepository].
final appVersionRepositoryProvider = Provider<AppVersionRepository>(
  (ref) => PlatformAppVersionRepository(),
);
