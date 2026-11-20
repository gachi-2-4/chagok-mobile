import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/core/utils/app_text_scaler.dart';
import 'package:chagok_mobile/features/settings/data/app_settings.dart';
import 'package:chagok_mobile/features/settings/data/settings_repository.dart';
import 'package:chagok_mobile/features/settings/data/text_size.dart';
import 'package:chagok_mobile/features/settings/presentation/settings_strings.dart';
import 'package:chagok_mobile/features/settings/presentation/text_size_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_settings_repository.dart';

void main() {
  group('TextSizeScreen', () {
    testWidgets('크기를 고르면 미리 보기는 기기 배율에 고른 배율만 곱해 보여 준다', (tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repository = FakeSettingsRepository()
        ..stored = const AppSettings(textSize: TextSize.large);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            theme: AppTheme.light,
            // 앱처럼 기기 배율(2) 위에 저장한 배율(크게)을 곱해 둡니다.
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: AppTextScaler(
                  const TextScaler.linear(2),
                  TextSize.large.scale,
                ),
              ),
              child: child ?? const SizedBox.shrink(),
            ),
            home: const TextSizeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.text(SettingsStrings.textSizeLabel(TextSize.extraLarge)),
      );
      await tester.pumpAndSettle();

      final preview = tester.element(find.text(SettingsStrings.previewText));
      expect(
        MediaQuery.textScalerOf(preview).scale(10),
        moreOrLessEquals(10 * 2 * TextSize.extraLarge.scale),
      );
    });
  });
}
