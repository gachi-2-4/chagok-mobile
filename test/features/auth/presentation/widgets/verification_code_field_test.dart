import 'package:chagok_mobile/features/auth/presentation/widgets/verification_code_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpField(
    WidgetTester tester, {
    required double width,
    ValueChanged<String>? onChanged,
  }) {
    return tester.pumpApp(
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          child: VerificationCodeField(
            length: 6,
            code: '',
            onChanged: onChanged ?? (_) {},
            semanticLabel: '인증번호 6자리',
          ),
        ),
      ),
    );
  }

  Size firstCellSize(WidgetTester tester) => tester.getSize(
    find
        .descendant(of: find.byType(Row), matching: find.byType(Container))
        .first,
  );

  group('VerificationCodeField', () {
    testWidgets('320pt 화면의 너비 268에 두면 칸을 줄여 넘치지 않는다', (tester) async {
      await pumpField(tester, width: 268);

      expect(tester.takeException(), isNull);
      expect(firstCellSize(tester).width, lessThan(46));
    });

    testWidgets('360pt 화면의 너비 308에 두면 칸 너비 46을 그대로 쓴다', (tester) async {
      await pumpField(tester, width: 308);

      expect(firstCellSize(tester).width, 46);
    });

    testWidgets('복사한 인증번호를 붙여넣으면 입력값으로 받는다', (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async => switch (call.method) {
          'Clipboard.getData' => {'text': '123456'},
          'Clipboard.hasStrings' => {'value': true},
          _ => null,
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      String? received;
      await pumpField(
        tester,
        width: 308,
        onChanged: (value) => received = value,
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      expect(received, '123456');
    });
  });
}
