import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppButton', () {
    testWidgets('primary 버튼을 누르면 onPressed가 호출된다', (tester) async {
      var pressedCount = 0;
      await tester.pumpApp(
        AppButton.primary(label: '다음', onPressed: () => pressedCount++),
      );

      await tester.tap(find.text('다음'));

      expect(pressedCount, 1);
    });

    testWidgets('secondary 버튼을 누르면 onPressed가 호출된다', (tester) async {
      var pressedCount = 0;
      await tester.pumpApp(
        AppButton.secondary(label: '나중에 할게요', onPressed: () => pressedCount++),
      );

      await tester.tap(find.text('나중에 할게요'));

      expect(pressedCount, 1);
    });

    testWidgets('onPressed가 null이면 비활성화된다', (tester) async {
      await tester.pumpApp(
        const AppButton.primary(label: '다음', onPressed: null),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));

      expect(button.enabled, isFalse);
    });

    testWidgets('높이는 디자인 값 51을 따른다', (tester) async {
      await tester.pumpApp(AppButton.primary(label: '다음', onPressed: () {}));

      expect(tester.getSize(find.byType(FilledButton)).height, 51);
    });
  });
}
