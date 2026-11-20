import 'package:chagok_mobile/features/home/data/box_category.dart';
import 'package:chagok_mobile/features/home/data/recent_box.dart';
import 'package:chagok_mobile/features/home/presentation/widgets/recent_box_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final now = DateTime(2026, 11, 18, 10);

  group('RecentBoxCard', () {
    testWidgets('글자를 2배로 키우면 D-DAY 표를 줄여 상자 몸통 안에 맞춘다', (tester) async {
      await tester.pumpApp(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              // 390pt 화면에서 보관함 두 개가 나란히 놓일 때의 너비.
              width: 164,
              child: RecentBoxCard(
                box: RecentBox(
                  id: 'housing',
                  name: '집 · 임대',
                  category: BoxCategory.housing,
                  documentCount: 3,
                  lastOpenedAt: now,
                  nextDueDate: DateTime(2026, 11, 18),
                ),
                now: now,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('D-DAY'), findsOneWidget);
    });
  });
}
