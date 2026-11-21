import 'package:chagok_mobile/features/settings/data/platform_app_version_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlatformAppVersionRepository', () {
    test('버전을 읽으면 빌드에 정해진 버전 이름을 돌려준다', () async {
      PackageInfo.setMockInitialValues(
        appName: '차곡',
        packageName: 'com.example.chagok',
        version: '1.4.0',
        buildNumber: '12',
        buildSignature: '',
      );

      expect(await PlatformAppVersionRepository().fetchVersion(), '1.4.0');
    });
  });
}
