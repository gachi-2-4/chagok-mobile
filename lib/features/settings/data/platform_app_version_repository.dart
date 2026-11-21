import 'package:chagok_mobile/features/settings/data/app_version_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 빌드할 때 `pubspec.yaml`의 `version`으로 정해진 버전을 기기에서 읽습니다.
class PlatformAppVersionRepository implements AppVersionRepository {
  @override
  Future<String> fetchVersion() async =>
      (await PackageInfo.fromPlatform()).version;
}
