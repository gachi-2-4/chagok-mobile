import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/features/calendar/presentation/widgets/due_tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Color? fillOf(WidgetTester tester) {
    final container = tester.widget<Container>(find.byType(Container).first);
    return (container.decoration as BoxDecoration?)?.color;
  }

  group('DueTag', () {
    testWidgets('2주 안으로 남으면 강조색으로 보여 준다', (tester) async {
      await tester.pumpApp(const DueTag(days: 14));

      expect(fillOf(tester), AppColors.peach);
    });

    testWidgets('2주보다 많이 남으면 차분한 색으로 보여 준다', (tester) async {
      await tester.pumpApp(const DueTag(days: 15));

      expect(fillOf(tester), AppColors.calendarControl);
    });

    testWidgets('기한이 지났으면 D+n으로 보여 주고 강조색을 쓰지 않는다', (tester) async {
      await tester.pumpApp(const DueTag(days: -9));

      expect(find.text('D+9'), findsOneWidget);
      expect(fillOf(tester), AppColors.calendarControl);
    });
  });
}
