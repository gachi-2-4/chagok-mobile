import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:chagok_mobile/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

  FilledButton loginButton(WidgetTester tester) {
    return tester.widget<FilledButton>(
      find.descendant(
        of: find.widgetWithText(AppButton, '로그인'),
        matching: find.byType(FilledButton),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('입력하기 전에는 로그인 버튼이 비활성화된다', (tester) async {
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

    testWidgets('로그인이 실패하면 오류 문구를 보여 준다', (tester) async {
      final repository = FakeAuthRepository(
        error: const AuthException('전화번호 또는 비밀번호가 맞지 않아요.'),
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
}
