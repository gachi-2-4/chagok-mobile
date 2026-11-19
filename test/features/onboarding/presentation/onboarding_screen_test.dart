import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpOnboardingScreen(WidgetTester tester) {
    return tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const OnboardingScreen(),
        ),
      ),
    );
  }

  group('OnboardingScreen', () {
    testWidgets('선택지를 고르고 다음을 누르면 지역 단계를 보여 준다', (tester) async {
      await pumpOnboardingScreen(tester);

      await tester.tap(find.text('내국인'));
      await tester.pump();
      await tester.tap(find.text('다음'));
      await tester.pump();

      expect(find.text('어느 지역에 사시나요?'), findsOneWidget);
    });

    testWidgets('상단 뒤로 가기를 누르면 이전 단계로 돌아간다', (tester) async {
      await pumpOnboardingScreen(tester);
      await tester.tap(find.text('외국인'));
      await tester.pump();
      await tester.tap(find.text('다음'));
      await tester.pump();

      await tester.tap(find.bySemanticsLabel('뒤로 가기'));
      await tester.pump();

      expect(find.text('내국인이신가요?'), findsOneWidget);
    });
  });
}
