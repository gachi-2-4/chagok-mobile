import 'package:chagok_mobile/features/settings/data/app_settings.dart';
import 'package:chagok_mobile/features/settings/data/settings_repository.dart';
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

  group('InMemorySettingsRepository', () {
    test('저장한 설정을 다시 불러온다', () async {
      final repository = InMemorySettingsRepository();

      await repository.saveSettings(
        const AppSettings(textSize: TextSize.large),
      );

      expect((await repository.fetchSettings()).textSize, TextSize.large);
    });

    test('탈퇴하면 설정을 처음으로 돌린다', () async {
      final repository = InMemorySettingsRepository();
      await repository.saveSettings(
        const AppSettings(textSize: TextSize.large),
      );

      await repository.deleteAccount();

      expect((await repository.fetchSettings()).textSize, TextSize.normal);
    });
  });
}
