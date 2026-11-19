import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:chagok_mobile/features/auth/presentation/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  Future<void> pumpSignUpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const SignUpScreen()),
      ),
    );
  }

  Future<void> enterPasswords(
    WidgetTester tester, {
    required String password,
    required String confirm,
  }) async {
    await tester.enterText(find.byType(TextField).at(3), password);
    await tester.enterText(find.byType(TextField).at(4), confirm);
    await tester.pump();
  }

  group('SignUpScreen', () {
    testWidgets('비밀번호 확인이 다르면 불일치 문구를 보여 준다', (tester) async {
      await pumpSignUpScreen(tester);

      await enterPasswords(tester, password: 'chagok12!', confirm: 'chagok1');

      expect(find.text('비밀번호가 다릅니다.'), findsOneWidget);
    });

    testWidgets('비밀번호 확인이 같으면 불일치 문구를 숨긴다', (tester) async {
      await pumpSignUpScreen(tester);

      await enterPasswords(tester, password: 'chagok12!', confirm: 'chagok12!');

      expect(find.text('비밀번호가 다릅니다.'), findsNothing);
    });

    testWidgets('비밀번호 보기 버튼을 누르면 입력 내용을 보여 준다', (tester) async {
      await pumpSignUpScreen(tester);

      await tester.tap(find.bySemanticsLabel('비밀번호 보기').first);
      await tester.pump();

      final passwordField = tester.widget<TextField>(
        find.byType(TextField).at(3),
      );
      expect(passwordField.obscureText, isFalse);
    });
  });
}
