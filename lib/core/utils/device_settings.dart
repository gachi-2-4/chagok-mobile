// 설정 기능의 AppSettings 모델과 이름이 겹쳐 패키지에 접두어를 붙입니다.
import 'package:app_settings/app_settings.dart' as plugin;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 기기 설정 앱의 이 앱 화면을 엽니다.
///
/// 앱 안에서 바꿀 수 없는 권한(알림, 카메라)을 사용자가 직접 켜도록 안내할 때 씁니다.
/// 테스트에서 바꿔 끼울 수 있게 [deviceSettingsProvider]로 둡니다.
class DeviceSettings {
  const DeviceSettings();

  /// 이 앱의 알림 설정을 엽니다. 알림 설정을 바로 열 수 없는 기기는 앱 설정을 엽니다.
  Future<void> openNotificationSettings() => plugin.AppSettings.openAppSettings(
    type: plugin.AppSettingsType.notification,
  );

  /// 이 앱의 설정(카메라 권한 등)을 엽니다.
  Future<void> openAppSettings() => plugin.AppSettings.openAppSettings();
}

/// 앱 전역 [DeviceSettings].
final deviceSettingsProvider = Provider<DeviceSettings>(
  (ref) => const DeviceSettings(),
);
