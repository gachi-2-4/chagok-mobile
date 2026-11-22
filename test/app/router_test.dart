import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/app/splash_screen.dart';
import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/core/network/auth_tokens.dart';
import 'package:chagok_mobile/core/network/in_memory_token_storage.dart';
import 'package:chagok_mobile/core/network/session_notifier.dart';
import 'package:chagok_mobile/core/network/token_storage.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:chagok_mobile/features/auth/data/social_login_result.dart';
import 'package:chagok_mobile/features/auth/presentation/social_terms_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/fake_auth_repository.dart';

void main() {
  /// 앱 라우터를 띄우고 [location]으로 바로 간 뒤 실제로 열린 경로를 돌려줍니다.
  Future<String> goDirectly(WidgetTester tester, String location) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
    );
    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );

    router.go(location);
    await tester.pumpAndSettle();
    final path = router.routerDelegate.currentConfiguration.uri.path;

    // 홈 화면이 건 자정 Timer가 남지 않도록 testWidgets의 Timer 검사 전에
    // 화면과 컨테이너를 정리합니다.
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    return path;
  }

  group('routerProvider', () {
    testWidgets('인증번호를 받지 않고 가입 인증 화면으로 바로 가면 가입 정보 입력으로 돌려보낸다', (
      tester,
    ) async {
      expect(
        await goDirectly(tester, AppRoute.signUpVerification),
        AppRoute.signUp,
      );
    });

    testWidgets('인증하지 않고 약관 화면으로 바로 가면 가입 정보 입력으로 돌려보낸다', (tester) async {
      expect(await goDirectly(tester, AppRoute.signUpTerms), AppRoute.signUp);
    });

    testWidgets('인증번호를 받지 않고 비밀번호 찾기 인증 화면으로 바로 가면 번호 입력으로 돌려보낸다', (
      tester,
    ) async {
      expect(
        await goDirectly(tester, AppRoute.passwordResetVerification),
        AppRoute.forgotPassword,
      );
    });

    testWidgets('인증하지 않고 새 비밀번호 화면으로 바로 가면 번호 입력으로 돌려보낸다', (tester) async {
      expect(
        await goDirectly(tester, AppRoute.resetPassword),
        AppRoute.forgotPassword,
      );
    });
  });

  group('로그인 확인', () {
    const tokens = AuthTokens(accessToken: 'access', refreshToken: 'refresh');

    /// 로그인이 필요한 앱을 [store]의 토큰으로 띄웁니다. 처음 주소는 홈입니다.
    Future<(ProviderContainer, GoRouter)> pumpGate(
      WidgetTester tester,
      TokenStorage store, {
      bool requiresLogin = true,
      bool settles = true,
      AuthRepository? repository,
    }) async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            repository ?? FakeAuthRepository(),
          ),
          requiresLoginProvider.overrideWithValue(requiresLogin),
          tokenStoreProvider.overrideWithValue(store),
        ],
      );
      final router = container.read(routerProvider);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      // 시작 화면의 돌아가는 표시는 멈추지 않으므로, 확인 중인 화면을 볼 때는 한 번만 그립니다.
      await (settles ? tester.pumpAndSettle() : tester.pump());
      return (container, router);
    }

    /// 홈 화면이 건 자정 Timer가 남지 않도록 testWidgets의 Timer 검사 전에
    /// 화면과 컨테이너를 정리합니다.
    Future<void> closeApp(WidgetTester tester) async {
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    }

    String pathOf(GoRouter router) =>
        router.routerDelegate.currentConfiguration.uri.path;

    testWidgets('저장한 토큰이 없으면 앱을 열 때 로그인 화면으로 간다', (tester) async {
      final (_, router) = await pumpGate(tester, InMemoryTokenStorage());

      expect(pathOf(router), AppRoute.login);
      await closeApp(tester);
    });

    testWidgets('저장한 토큰이 있으면 로그인 없이 홈으로 간다', (tester) async {
      final store = InMemoryTokenStorage();
      await store.save(tokens);

      final (_, router) = await pumpGate(tester, store);

      expect(pathOf(router), AppRoute.home);
      await closeApp(tester);
    });

    testWidgets('토큰을 확인하는 동안 시작 화면을 보여 주고 끝나면 가려던 곳으로 간다', (tester) async {
      final store = _GatedTokenStorage();
      await store.save(tokens);
      final (_, router) = await pumpGate(tester, store, settles: false);
      router.go(AppRoute.calendar);
      await tester.pump();

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(pathOf(router), AppRoute.splash);

      store.gate.complete();
      await tester.pumpAndSettle();

      expect(pathOf(router), AppRoute.calendar);
      await closeApp(tester);
    });

    testWidgets('로그아웃 상태로 보관함 주소에 가면 로그인 화면으로 보낸다', (tester) async {
      final (_, router) = await pumpGate(tester, InMemoryTokenStorage());

      router.go(AppRoute.archive);
      await tester.pumpAndSettle();

      expect(pathOf(router), AppRoute.login);
      await closeApp(tester);
    });

    testWidgets('로그아웃 상태여도 회원가입 화면은 열린다', (tester) async {
      final (_, router) = await pumpGate(tester, InMemoryTokenStorage());

      router.go(AppRoute.signUp);
      await tester.pumpAndSettle();

      expect(pathOf(router), AppRoute.signUp);
      await closeApp(tester);
    });

    testWidgets('로그인 상태로 로그인 화면에 가면 홈으로 보낸다', (tester) async {
      final store = InMemoryTokenStorage();
      await store.save(tokens);
      final (_, router) = await pumpGate(tester, store);

      router.go(AppRoute.login);
      await tester.pumpAndSettle();

      expect(pathOf(router), AppRoute.home);
      await closeApp(tester);
    });

    testWidgets('로그인해 토큰을 저장하면 로그인 화면에서 홈으로 간다', (tester) async {
      final (container, router) = await pumpGate(
        tester,
        InMemoryTokenStorage(),
      );
      expect(pathOf(router), AppRoute.login);

      await container.read(tokenStorageProvider).save(tokens);
      await tester.pumpAndSettle();

      expect(pathOf(router), AppRoute.home);
      await closeApp(tester);
    });

    testWidgets('카카오로 처음 로그인해 토큰을 저장하면 홈이 아니라 약관 동의로 간다', (tester) async {
      final repository = _TokenSavingAuthRepository()
        ..kakaoResult = const SocialLoginResult(
          isNewUser: true,
          isConsentRequired: true,
          isOnboardingCompleted: false,
        );
      final (container, router) = await pumpGate(
        tester,
        InMemoryTokenStorage(),
        repository: repository,
      );
      repository.tokenStorage = container.read(tokenStorageProvider);

      await tester.tap(find.text('kakao 로그인'));
      await tester.pumpAndSettle();

      expect(pathOf(router), AppRoute.socialTerms);
      expect(find.byType(SocialTermsScreen), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('로그아웃·재발급 실패로 토큰이 지워지면 로그인 화면으로 간다', (tester) async {
      final store = InMemoryTokenStorage();
      await store.save(tokens);
      final (container, router) = await pumpGate(tester, store);

      await container.read(tokenStorageProvider).clear();
      await tester.pumpAndSettle();

      expect(pathOf(router), AppRoute.login);
      await closeApp(tester);
    });

    testWidgets('서버 없이 돌려 로그인이 필요 없으면 토큰 없이도 홈을 연다', (tester) async {
      final (_, router) = await pumpGate(
        tester,
        InMemoryTokenStorage(),
        requiresLogin: false,
      );

      expect(pathOf(router), AppRoute.home);
      await closeApp(tester);
    });
  });
}

/// 실제 저장소처럼 카카오 로그인 중에 토큰을 저장하는 가짜 저장소.
///
/// 토큰을 저장하면 로그인 상태가 바뀌어 라우터가 다시 갈 곳을 정하므로,
/// 그때 로그인 화면이 홈으로 밀려나지 않는지 보려고 씁니다.
class _TokenSavingAuthRepository extends FakeAuthRepository {
  TokenStorage? tokenStorage;

  @override
  Future<SocialLoginResult?> logInWithKakao({
    required bool keepSignedIn,
  }) async {
    await tokenStorage?.save(
      const AuthTokens(accessToken: 'access', refreshToken: 'refresh'),
    );
    return super.logInWithKakao(keepSignedIn: keepSignedIn);
  }
}

/// [read]가 [gate]가 끝날 때까지 기다리는 저장소. 시작 화면을 확인하려고 씁니다.
class _GatedTokenStorage extends InMemoryTokenStorage {
  final gate = Completer<void>();

  @override
  Future<AuthTokens?> read() async {
    await gate.future;
    return super.read();
  }
}
