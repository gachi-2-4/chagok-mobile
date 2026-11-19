import 'package:chagok_mobile/core/widgets/app_bullet_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppBulletRow', () {
    testWidgets('안내가 한 줄이면 디자인 높이 44를 따른다', (tester) async {
      await tester.pumpApp(
        const Align(
          alignment: Alignment.topCenter,
          child: AppBulletRow(text: '보관한 서류'),
        ),
      );

      expect(
        tester.getSize(find.byType(AppBulletRow)).height,
        AppBulletRow.minHeight,
      );
    });

    testWidgets('안내가 길어 여러 줄이 되면 높이가 늘어난다', (tester) async {
      await tester.pumpApp(
        Align(
          alignment: Alignment.topCenter,
          child: AppBulletRow(text: '보관한 서류와 알림 설정, 대화 기록이 모두 삭제됩니다. ' * 5),
        ),
      );

      expect(
        tester.getSize(find.byType(AppBulletRow)).height,
        greaterThan(AppBulletRow.minHeight),
      );
    });
  });
}
