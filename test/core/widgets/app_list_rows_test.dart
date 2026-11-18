import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/widgets/app_check_row.dart';
import 'package:chagok_mobile/core/widgets/app_list_row.dart';
import 'package:chagok_mobile/core/widgets/app_select_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppListRow', () {
    testWidgets('제목과 현재 값을 보여 주고, 누르면 onTap이 호출된다', (tester) async {
      var tapCount = 0;
      await tester.pumpApp(
        AppListRow(title: '글자 크기', value: '보통', onTap: () => tapCount++),
      );

      await tester.tap(find.text('글자 크기'));

      expect(find.text('보통'), findsOneWidget);
      expect(tapCount, 1);
    });

    testWidgets('isDestructive가 true면 제목이 빨갛게 보인다', (tester) async {
      await tester.pumpApp(
        const AppListRow(title: '회원 탈퇴', isDestructive: true),
      );

      final title = tester.widget<Text>(find.text('회원 탈퇴'));

      expect(title.style?.color, AppColors.danger);
    });
  });

  group('AppSelectRow', () {
    testWidgets('누르면 onTap이 호출된다', (tester) async {
      var tapCount = 0;
      await tester.pumpApp(
        AppSelectRow(label: '크게', isSelected: false, onTap: () => tapCount++),
      );

      await tester.tap(find.text('크게'));

      expect(tapCount, 1);
    });

    testWidgets('선택되면 글자가 굵게 보인다', (tester) async {
      await tester.pumpApp(
        AppSelectRow(label: '크게', isSelected: true, onTap: () {}),
      );

      final label = tester.widget<Text>(find.text('크게'));

      expect(label.style?.fontWeight, FontWeight.w700);
    });
  });

  group('AppCheckRow', () {
    testWidgets('체크되지 않은 행을 누르면 true로 바꾸라고 알린다', (tester) async {
      bool? changedValue;
      await tester.pumpApp(
        AppCheckRow(
          label: '삭제 내용을 확인했어요',
          isChecked: false,
          onChanged: (value) => changedValue = value,
        ),
      );

      await tester.tap(find.text('삭제 내용을 확인했어요'));

      expect(changedValue, isTrue);
    });
  });
}
