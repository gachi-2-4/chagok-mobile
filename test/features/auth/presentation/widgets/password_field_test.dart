import 'package:chagok_mobile/features/auth/presentation/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('PasswordField', () {
    testWidgets('Tab으로 보기 버튼에 가서 Enter를 누르면 입력 내용을 보여 준다', (tester) async {
      await tester.pumpApp(PasswordField(label: '비밀번호', onChanged: (_) {}));
      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(
        tester.widget<TextField>(find.byType(TextField)).obscureText,
        isFalse,
      );
    });
  });
}
