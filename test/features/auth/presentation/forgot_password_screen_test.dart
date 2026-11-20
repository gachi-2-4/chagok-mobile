import 'dart:async';

import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:chagok_mobile/features/auth/presentation/auth_strings.dart';
import 'package:chagok_mobile/features/auth/presentation/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  group('ForgotPasswordScreen', () {
    testWidgets('인증번호를 요청하는 중이면 전화번호를 고칠 수 없다', (tester) async {
      final repository = FakeAuthRepository()..sendGate = Completer<void>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ForgotPasswordScreen(),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '01011111111');
      await tester.pump();

      await tester.tap(find.text(AuthStrings.sendCode));
      await tester.pump();

      expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
    });
  });
}
