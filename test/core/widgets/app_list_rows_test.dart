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

    testWidgets('값이 짧으면 화살표 바로 왼쪽, 행의 오른쪽 끝에 붙는다', (tester) async {
      await tester.pumpApp(
        AppListRow(title: '글자 크기', value: '보통', onTap: () {}),
      );

      final rowRight = tester.getTopRight(find.byType(AppListRow)).dx;
      final valueRight = tester.getTopRight(find.text('보통')).dx;

      // 오른쪽 여백(20) + 화살표(20) + 간격(8) 만큼만 떨어져 있어야 합니다.
      expect(rowRight - valueRight, moreOrLessEquals(48));
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

  group('목록 행 높이', () {
    const longText = '보관한 서류와 알림 설정, 대화 기록이 모두 삭제된다는 것을 확인했어요. ';

    Future<double> rowHeight(WidgetTester tester, Widget row) async {
      await tester.pumpApp(Align(alignment: Alignment.topCenter, child: row));
      return tester.getSize(find.byWidget(row)).height;
    }

    testWidgets('글자가 한 줄이면 디자인 높이를 따른다', (tester) async {
      expect(
        await rowHeight(tester, const AppListRow(title: '글자 크기')),
        AppListRow.minHeight,
      );
      expect(
        await rowHeight(
          tester,
          AppSelectRow(label: '보통', isSelected: true, onTap: () {}),
        ),
        AppSelectRow.minHeight,
      );
      expect(
        await rowHeight(
          tester,
          AppCheckRow(label: '동의해요', isChecked: false, onChanged: (_) {}),
        ),
        AppCheckRow.minHeight,
      );
    });

    testWidgets('글자가 길어 여러 줄이 되면 높이가 늘어난다', (tester) async {
      expect(
        await rowHeight(tester, AppListRow(title: longText * 3)),
        greaterThan(AppListRow.minHeight),
      );
      expect(
        await rowHeight(tester, AppListRow(title: '알림', value: longText * 3)),
        greaterThan(AppListRow.minHeight),
      );
      expect(
        await rowHeight(
          tester,
          AppSelectRow(label: longText * 3, isSelected: true, onTap: () {}),
        ),
        greaterThan(AppSelectRow.minHeight),
      );
      expect(
        await rowHeight(
          tester,
          AppCheckRow(label: longText * 3, isChecked: false, onChanged: (_) {}),
        ),
        greaterThan(AppCheckRow.minHeight),
      );
    });
  });
}
