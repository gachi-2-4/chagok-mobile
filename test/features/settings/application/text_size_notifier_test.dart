import 'package:chagok_mobile/features/settings/application/settings_notifier.dart';
import 'package:chagok_mobile/features/settings/application/text_size_notifier.dart';
import 'package:chagok_mobile/features/settings/data/app_settings.dart';
import 'package:chagok_mobile/features/settings/data/settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_settings_repository.dart';

void main() {
  late FakeSettingsRepository repository;
  late ProviderContainer container;

  setUp(() async {
    repository = FakeSettingsRepository()
      ..stored = const AppSettings(textSize: TextSize.large);
    container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    await container.read(settingsProvider.future);
    container.listen(textSizeDraftProvider, (_, _) {});
  });

  group('TextSizeDraftNotifier', () {
    test('저장된 글자 크기에서 시작한다', () {
      expect(container.read(textSizeDraftProvider), TextSize.large);
    });

    test('고르기만 하면 앱 설정은 바뀌지 않는다', () async {
      container.read(textSizeDraftProvider.notifier).select(TextSize.normal);

      expect(container.read(textSizeDraftProvider), TextSize.normal);
      expect(
        (await container.read(settingsProvider.future)).textSize,
        TextSize.large,
      );
    });

    test('저장하면 고른 크기를 앱 설정에 반영한다', () async {
      container
          .read(textSizeDraftProvider.notifier)
          .select(TextSize.extraLarge);

      await container.read(textSizeDraftProvider.notifier).save();

      expect(repository.stored.textSize, TextSize.extraLarge);
    });
  });
}
