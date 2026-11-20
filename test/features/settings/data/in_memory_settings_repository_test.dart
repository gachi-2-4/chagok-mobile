import 'package:chagok_mobile/features/settings/data/app_settings.dart';
import 'package:chagok_mobile/features/settings/data/in_memory_settings_repository.dart';
import 'package:chagok_mobile/features/settings/data/text_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemorySettingsRepository', () {
    test('설정을 저장하고 불러오면 저장한 설정을 돌려준다', () async {
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
