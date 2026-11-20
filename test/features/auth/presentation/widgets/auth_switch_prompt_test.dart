import 'package:chagok_mobile/features/auth/presentation/auth_strings.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/auth_switch_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('AuthSwitchPrompt', () {
    testWidgets('글자를 2배로 키우면 안내와 버튼이 줄을 바꿔 넘치지 않고 버튼을 누를 수 있다', (tester) async {
      var isTapped = false;
      await tester.pumpApp(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 260,
              child: AuthSwitchPrompt(
                message: AuthStrings.hasAccount,
                actionLabel: AuthStrings.goToLogin,
                onTap: () => isTapped = true,
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.text(AuthStrings.goToLogin));

      expect(isTapped, isTrue);
    });
  });
}
