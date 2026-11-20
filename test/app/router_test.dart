import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';

void main() {
  /// 앱 라우터를 띄우고 [location]으로 바로 간 뒤 실제로 열린 경로를 돌려줍니다.
  Future<String> goDirectly(WidgetTester tester, String location) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );

    router.go(location);
    await tester.pumpAndSettle();

    return router.routerDelegate.currentConfiguration.uri.path;
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
}
