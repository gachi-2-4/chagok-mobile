import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/features/settings/application/settings_notifier.dart';
import 'package:chagok_mobile/features/settings/data/settings_repository.dart';
import 'package:chagok_mobile/features/settings/presentation/notification_settings_screen.dart';
import 'package:chagok_mobile/features/settings/presentation/settings_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_settings_repository.dart';

void main() {
  group('NotificationSettingsScreen', () {
    testWidgets('시각 선택 창이 열린 사이 설정 줄이 사라지면 고른 시각을 저장하지 않고 넘어간다', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repository = FakeSettingsRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
          retry: (_, _) => null,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const NotificationSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(SettingsStrings.reminderTime));
      await tester.pumpAndSettle();

      // 선택 창이 열린 사이 설정을 다시 불러오다 실패해 시각 줄이 사라집니다.
      repository.loadError = Exception('network');
      ProviderScope.containerOf(
        tester.element(find.byType(NotificationSettingsScreen)),
      ).invalidate(settingsProvider);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(repository.saveCount, 0);
    });
  });
}
