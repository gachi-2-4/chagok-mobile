import 'package:chagok_mobile/core/utils/device_settings.dart';

/// 기기 설정을 실제로 열지 않고, 연 화면을 기록하는 가짜 [DeviceSettings].
class FakeDeviceSettings implements DeviceSettings {
  /// 연 설정 화면. `notification` 또는 `app`.
  final opened = <String>[];

  @override
  Future<void> openNotificationSettings() async => opened.add('notification');

  @override
  Future<void> openAppSettings() async => opened.add('app');
}
