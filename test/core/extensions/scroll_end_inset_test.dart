import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/extensions/scroll_end_inset.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScrollEndInset', () {
    Future<double> insetWith(
      WidgetTester tester, {
      required double bottomPadding,
      double? gap,
    }) async {
      late double inset;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.only(bottom: bottomPadding)),
          child: Builder(
            builder: (context) {
              inset = gap == null
                  ? context.scrollEndInset()
                  : context.scrollEndInset(gap: gap);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      return inset;
    }

    testWidgets('아래 안전 영역이 없으면 기본 여백만 돌려준다', (tester) async {
      final inset = await insetWith(tester, bottomPadding: 0);

      expect(inset, AppSpacing.scrollEnd);
    });

    testWidgets('홈 인디케이터가 있으면 그 높이를 기본 여백에 더한다', (tester) async {
      final inset = await insetWith(tester, bottomPadding: 34);

      expect(inset, AppSpacing.scrollEnd + 34);
    });

    testWidgets('여백을 넘기면 그 여백에 안전 영역을 더한다', (tester) async {
      final inset = await insetWith(
        tester,
        bottomPadding: 34,
        gap: AppSpacing.floatingButtonClearance,
      );

      expect(inset, AppSpacing.floatingButtonClearance + 34);
    });
  });
}
