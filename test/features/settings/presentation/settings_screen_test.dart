import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/features/settings/data/settings_repository.dart';
import 'package:chagok_mobile/features/settings/presentation/settings_screen.dart';
import 'package:chagok_mobile/features/settings/presentation/settings_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_settings_repository.dart';

void main() {
  late FakeSettingsRepository repository;

  Future<void> pumpSettingsScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    repository = FakeSettingsRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(theme: AppTheme.light, home: const SettingsScreen()),
      ),
    );
    await tester.pump();
  }

  group('SettingsScreen', () {
    testWidgets('설정을 불러오면 프로필과 현재 글자 크기를 보여 준다', (tester) async {
      await pumpSettingsScreen(tester);

      expect(find.text('김차곡'), findsOneWidget);
      expect(find.text('010-1111-2222'), findsOneWidget);
      expect(find.text('보통'), findsOneWidget);
    });

    testWidgets('회원 탈퇴를 누르면 확인 창을 띄우고, 아니요를 누르면 탈퇴하지 않는다', (tester) async {
      await pumpSettingsScreen(tester);

      await tester.tap(find.text('회원 탈퇴'));
      await tester.pumpAndSettle();
      expect(find.text('정말 탈퇴하시겠어요?'), findsOneWidget);

      await tester.tap(find.text('아니요'));
      await tester.pumpAndSettle();

      expect(repository.deleteCount, 0);
    });

    testWidgets('로그아웃하지 못하면 실패 안내를 보여 준다', (tester) async {
      await pumpSettingsScreen(tester);
      repository.error = Exception('network');

      await tester.tap(find.text(SettingsStrings.logOut));
      await tester.pumpAndSettle();
      await tester.tap(find.text('예'));
      await tester.pumpAndSettle();

      expect(find.text(SettingsStrings.logOutFailed), findsOneWidget);
    });
  });
}
