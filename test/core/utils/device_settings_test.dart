import 'package:chagok_mobile/core/utils/device_settings.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// 기기 설정 플러그인이 네이티브로 보내는 채널.
  const channel = MethodChannel('com.spencerccf.app_settings/methods');
  late List<MethodCall> calls;

  setUp(() {
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
  });

  group('DeviceSettings', () {
    test('알림 설정을 열면 이 앱의 알림 설정 화면을 요청한다', () async {
      await const DeviceSettings().openNotificationSettings();

      expect(calls.single.method, 'openSettings');
      expect(calls.single.arguments, containsPair('type', 'notification'));
    });

    test('앱 설정을 열면 이 앱의 설정 화면을 요청한다', () async {
      await const DeviceSettings().openAppSettings();

      expect(calls.single.method, 'openSettings');
      expect(calls.single.arguments, containsPair('type', 'settings'));
    });
  });
}
