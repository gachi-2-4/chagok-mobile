import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/widgets/app_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppChip', () {
    testWidgets('누르면 onTap이 호출된다', (tester) async {
      var tapCount = 0;
      await tester.pumpApp(
        AppChip(label: '위약금이 있나요?', onTap: () => tapCount++),
      );

      await tester.tap(find.text('위약금이 있나요?'));

      expect(tapCount, 1);
    });

    testWidgets('선택되면 초록 배경으로 보인다', (tester) async {
      await tester.pumpApp(const AppChip(label: '전체', isSelected: true));

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(AppChip),
          matching: find.byType(Material),
        ),
      );

      expect(material.color, AppColors.chipSelectedFill);
    });

    testWidgets('라벨이 한 줄이면 디자인 높이 37을 따른다', (tester) async {
      await tester.pumpApp(
        const Align(
          alignment: Alignment.topLeft,
          child: AppChip(label: '전체'),
        ),
      );

      expect(tester.getSize(find.byType(AppChip)).height, AppChip.minHeight);
    });

    testWidgets('라벨이 길어 여러 줄이 되면 높이가 늘어난다', (tester) async {
      await tester.pumpApp(
        const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 120,
            child: AppChip(label: '계약 기간이 끝나기 전에 나가면 위약금이 있나요?'),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(AppChip)).height,
        greaterThan(AppChip.minHeight),
      );
    });
  });
}
