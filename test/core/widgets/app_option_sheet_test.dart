import 'package:chagok_mobile/core/widgets/app_option_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('showAppOptionSheet', () {
    Future<Future<int?>> openSheet(WidgetTester tester) async {
      late Future<int?> result;
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => result = showAppOptionSheet(
              context,
              options: const [1, 2, 3],
              labelOf: (option) => '$option월',
              selected: 2,
            ),
            child: const Text('열기'),
          ),
        ),
      );
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('항목을 누르면 그 값을 돌려준다', (tester) async {
      final result = await openSheet(tester);

      await tester.tap(find.text('3월'));
      await tester.pumpAndSettle();

      expect(await result, 3);
    });

    testWidgets('고른 값이 있으면 그 항목에 체크 표시를 한다', (tester) async {
      await openSheet(tester);

      final selectedRow = find.ancestor(
        of: find.text('2월'),
        matching: find.byType(ListTile),
      );
      expect(
        find.descendant(
          of: selectedRow,
          matching: find.byIcon(Icons.check_rounded),
        ),
        findsOneWidget,
      );
    });
  });
}
