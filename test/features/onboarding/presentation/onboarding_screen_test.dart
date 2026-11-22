import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/features/onboarding/data/onboarding_repository.dart';
import 'package:chagok_mobile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:chagok_mobile/features/onboarding/presentation/onboarding_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/fake_onboarding_repository.dart';

void main() {
  Future<void> pumpOnboardingScreen(
    WidgetTester tester, {
    FakeOnboardingRepository? repository,
  }) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (repository != null)
            onboardingRepositoryProvider.overrideWithValue(repository),
        ],
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

    testWidgets('마지막 단계에서 답을 저장하지 못하면 실패 안내를 보여 준다', (tester) async {
      final repository = FakeOnboardingRepository()
        ..saveError = Exception('network');
      await pumpOnboardingScreen(tester, repository: repository);
      for (final label in ['내국인', null, '월세', '해당 없음']) {
        if (label == null) {
          await tester.enterText(find.byType(TextField), '서울시 마포구');
        } else {
          await tester.tap(find.text(label));
        }
        await tester.pump();
        await tester.tap(find.text(label == '해당 없음' ? '완료' : '다음'));
        await tester.pump();
      }

      expect(find.text(OnboardingStrings.submitFailed), findsOneWidget);
    });

    testWidgets('주소를 입력하고 후보를 누르면 그 주소로 채운다', (tester) async {
      await pumpOnboardingScreen(tester);
      await tester.tap(find.text('내국인'));
      await tester.pump();
      await tester.tap(find.text('다음'));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '마포');
      await tester.pump();
      await tester.tap(find.text('서울특별시 마포구'));
      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller?.text, '서울특별시 마포구');
      expect(
        find.bySemanticsLabel(OnboardingStrings.addressSuggestions),
        findsNothing,
      );
    });

    /// 이전 화면 없이 /onboarding으로 바로 연 앱을 띄웁니다.
    Future<void> pumpDirectOnboarding(WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: AppRoute.onboarding,
        routes: [
          GoRoute(
            path: AppRoute.home,
            builder: (context, state) => const Text('홈 화면'),
          ),
          GoRoute(
            path: AppRoute.onboarding,
            builder: (context, state) => const OnboardingScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('이전 화면 없이 바로 열린 첫 단계에서 뒤로 가기를 누르면 홈으로 간다', (tester) async {
      await pumpDirectOnboarding(tester);

      await tester.tap(find.bySemanticsLabel('뒤로 가기'));
      await tester.pumpAndSettle();

      expect(find.text('홈 화면'), findsOneWidget);
    });

    testWidgets('이전 화면 없이 바로 열린 첫 단계에서 기기 뒤로 가기를 누르면 앱을 닫지 않고 홈으로 간다', (
      tester,
    ) async {
      await pumpDirectOnboarding(tester);

      final isHandled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(isHandled, isTrue);
      expect(find.text('홈 화면'), findsOneWidget);
    });
  });
}
