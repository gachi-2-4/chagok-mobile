import 'package:chagok_mobile/core/widgets/app_toggle.dart';
import 'package:chagok_mobile/core/widgets/app_toggle_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppToggle', () {
    testWidgets('꺼진 스위치를 누르면 true로 바꾸라고 알린다', (tester) async {
      bool? changedValue;
      await tester.pumpApp(
        AppToggle(value: false, onChanged: (value) => changedValue = value),
      );

      await tester.tap(find.byType(AppToggle));

      expect(changedValue, isTrue);
    });

    testWidgets('켜진 스위치를 누르면 false로 바꾸라고 알린다', (tester) async {
      bool? changedValue;
      await tester.pumpApp(
        AppToggle(value: true, onChanged: (value) => changedValue = value),
      );

      await tester.tap(find.byType(AppToggle));

      expect(changedValue, isFalse);
    });

    testWidgets('크기는 디자인 값 46x28을 따른다', (tester) async {
      await tester.pumpApp(AppToggle(value: true, onChanged: (_) {}));

      expect(tester.getSize(find.byType(AppToggle)), const Size(46, 28));
    });
  });

  group('AppToggleRow', () {
    testWidgets('행의 글자를 눌러도 스위치 값을 바꾸라고 알린다', (tester) async {
      bool? changedValue;
      await tester.pumpApp(
        AppToggleRow(
          title: '납부일 알림',
          subtitle: '납부일 전에 미리 알려 드려요.',
          value: false,
          onChanged: (value) => changedValue = value,
        ),
      );

      await tester.tap(find.text('납부일 알림'));

      expect(changedValue, isTrue);
    });
  });
}
