import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/features/auth/data/auth_exception.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:chagok_mobile/features/auth/data/social_login_result.dart';
import 'package:chagok_mobile/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  Future<void> pumpLoginScreen(
    WidgetTester tester,
    FakeAuthRepository repository,
  ) {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    return tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(theme: AppTheme.light, home: const LoginScreen()),
      ),
    );
  }

  /// 간편 로그인 뒤 이동을 보려고 로그인 화면과 이어지는 화면만 둔 라우터로 띄웁니다.
  Future<void> pumpLoginFlow(
    WidgetTester tester,
    FakeAuthRepository repository,
  ) {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: AppRoute.login,
      routes: [
        GoRoute(
          path: AppRoute.login,
          builder: (context, state) => const LoginScreen(),
        ),
        for (final path in [
          AppRoute.socialTerms,
          AppRoute.onboarding,
          AppRoute.home,
        ])
          GoRoute(path: path, builder: (context, state) => Text(path)),
      ],
    );
    addTearDown(router.dispose);
    return tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
  }

  FilledButton loginButton(WidgetTester tester) {
    return tester.widget<FilledButton>(
      find.descendant(
        of: find.widgetWithText(AppButton, '로그인'),
        matching: find.byType(FilledButton),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('아무것도 입력하지 않았으면 로그인 버튼이 비활성화된다', (tester) async {
      await pumpLoginScreen(tester, FakeAuthRepository());

      expect(loginButton(tester).onPressed, isNull);
    });

    testWidgets('전화번호와 비밀번호를 넣으면 로그인 버튼이 활성화된다', (tester) async {
      await pumpLoginScreen(tester, FakeAuthRepository());

      await tester.enterText(find.byType(TextField).at(0), '01011111111');
      await tester.enterText(find.byType(TextField).at(1), 'secret');
      await tester.pump();

      expect(loginButton(tester).onPressed, isNotNull);
    });

    testWidgets('로그인이 실패하면 실패 이유에 맞는 안내를 보여 준다', (tester) async {
      final repository = FakeAuthRepository(
        error: const AuthException(AuthFailure.wrongCredentials),
      );
      await pumpLoginScreen(tester, repository);

      await tester.enterText(find.byType(TextField).at(0), '01011111111');
      await tester.enterText(find.byType(TextField).at(1), 'wrong');
      await tester.pump();
      await tester.tap(find.widgetWithText(AppButton, '로그인'));
      await tester.pump();

      expect(find.text('전화번호 또는 비밀번호가 맞지 않아요.'), findsOneWidget);
    });
  });

  group('LoginScreen 카카오 로그인', () {
    testWidgets('처음 들어온 사용자면 약관 동의 화면으로 간다', (tester) async {
      final repository = FakeAuthRepository()
        ..kakaoResult = const SocialLoginResult(
          isNewUser: true,
          isConsentRequired: true,
          isOnboardingCompleted: false,
        );
      await pumpLoginFlow(tester, repository);

      await tester.tap(find.text('kakao 로그인'));
      await tester.pumpAndSettle();

      expect(find.text(AppRoute.socialTerms), findsOneWidget);
    });

    testWidgets('약관 동의와 설문을 마친 사용자면 홈으로 간다', (tester) async {
      await pumpLoginFlow(tester, FakeAuthRepository());

      await tester.tap(find.text('kakao 로그인'));
      await tester.pumpAndSettle();

      expect(find.text(AppRoute.home), findsOneWidget);
    });

    testWidgets('전화번호 계정이 이미 있으면 전화번호로 로그인하라고 안내한다', (tester) async {
      final repository = FakeAuthRepository(
        error: const AuthException(AuthFailure.phoneAccountExists),
      );
      await pumpLoginFlow(tester, repository);

      await tester.tap(find.text('kakao 로그인'));
      await tester.pumpAndSettle();

      expect(find.text('이 전화번호로 가입한 계정이 있어요. 전화번호로 로그인해 주세요.'), findsOneWidget);
    });
  });
}
