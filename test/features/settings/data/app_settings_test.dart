import 'package:chagok_mobile/features/settings/data/app_settings.dart';
import 'package:chagok_mobile/features/settings/data/text_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSettings', () {
    test('JSON으로 바꿨다가 되돌리면 같은 값이 된다', () {
      const settings = AppSettings(
        textSize: TextSize.extraLarge,
        isPaymentReminderOn: false,
        isMarketingOn: true,
        reminderMinuteOfDay: 20 * 60,
      );

      final restored = AppSettings.fromJson(settings.toJson());

      expect(restored.toJson(), settings.toJson());
    });

    test('값이 없거나 모르는 값이면 기본값을 쓴다', () {
      final restored = AppSettings.fromJson(const {'textSize': 'huge'});

      expect(restored.toJson(), const AppSettings().toJson());
    });

    test('알림이 모두 꺼져 있으면 hasAnyNotificationOn이 false다', () {
      const settings = AppSettings(isPaymentReminderOn: false);

      expect(settings.hasAnyNotificationOn, isFalse);
    });
  });
}
