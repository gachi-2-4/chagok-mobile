import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/auth_form_layout.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/auth_switch_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpLayout(
    WidgetTester tester, {
    required double height,
    VoidCallback? onNext,
  }) async {
    tester.view.physicalSize = Size(390, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AuthFormLayout(
          body: const [Text('본문')],
          actions: [
            AuthSwitchPrompt(message: '안내', actionLabel: '이동', onTap: () {}),
            AppButton.primary(label: '다음', onPressed: onNext ?? () {}),
          ],
        ),
      ),
    );
  }

  group('AuthFormLayout', () {
    testWidgets('높이가 모자라면 본문과 버튼을 함께 스크롤해 버튼을 누를 수 있다', (tester) async {
      var isTapped = false;
      await pumpLayout(tester, height: 120, onNext: () => isTapped = true);
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(Scrollable), const Offset(0, -300));
      await tester.pump();
      await tester.tap(find.text('다음'));

      expect(isTapped, isTrue);
    });

    testWidgets('높이가 넉넉하면 버튼 영역을 화면 아래에 붙인다', (tester) async {
      await pumpLayout(tester, height: 800);

      expect(
        tester.getRect(find.byType(AppButton)).bottom,
        800 - AppSpacing.actionsBottom,
      );
    });
  });
}
