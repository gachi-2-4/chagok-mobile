import 'package:chagok_mobile/app/app.dart';
import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/widgets/app_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 하단 탭 화면의 마지막 항목이 바텀바에 가리거나 붙지 않는지 확인합니다.
///
/// 가장 작은 폰(320×568)에 홈 인디케이터(34)를 두고, 기기 글자를 최대(2.0)로 키운
/// 가장 빡빡한 경우만 봅니다.
void main() {
  const tabs = [
    AppRoute.archive,
    AppRoute.chat,
    AppRoute.home,
    AppRoute.calendar,
    AppRoute.settings,
  ];
  const homeIndicator = 34.0;

  for (final route in tabs) {
    testWidgets('$route 탭을 끝까지 내리면 마지막 항목이 바텀바 위에 여백을 두고 보인다', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(bottom: homeIndicator);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(const ProviderScope(child: ChagokApp()));
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ChagokApp)),
      );
      container.read(routerProvider).go(route);
      // 불러오는 표시가 돌아가 pumpAndSettle은 끝나지 않으므로 정해진 만큼만 그립니다.
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      final list = find.byWidgetPredicate(
        (widget) =>
            widget is ListView && widget.scrollDirection == Axis.vertical,
      );
      final scrollable = find
          .descendant(of: list.first, matching: find.byType(Scrollable))
          .first;
      final position = tester.state<ScrollableState>(scrollable).position;
      position.jumpTo(position.maxScrollExtent);
      await tester.pump();

      final listBottom = tester.getRect(scrollable).bottom;
      final barTop = tester.getRect(find.byType(AppBottomNavBar)).top;
      final endPadding =
          tester
              .widget<ListView>(list.first)
              .padding
              ?.resolve(TextDirection.ltr) ??
          EdgeInsets.zero;
      // 홈·보관함이 건 자정 Timer가 남지 않도록 testWidgets의 Timer 검사 전에 정리합니다.
      await tester.pumpWidget(const SizedBox.shrink());

      expect(listBottom, lessThanOrEqualTo(barTop));
      expect(endPadding.bottom, greaterThanOrEqualTo(AppSpacing.scrollEnd));
    });
  }
}
