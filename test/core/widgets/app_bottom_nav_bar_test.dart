import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/widgets/app_bottom_nav_bar.dart';
import 'package:chagok_mobile/core/widgets/app_bottom_nav_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

const _items = [
  AppBottomNavItem(
    label: '보관함',
    iconAsset: AppIcons.navBox,
    activeIconAsset: AppIcons.navBoxActive,
  ),
  AppBottomNavItem(label: '채팅', iconAsset: AppIcons.navChat),
  AppBottomNavItem(
    label: '홈',
    iconAsset: AppIcons.navHome,
    activeIconAsset: AppIcons.navHomeActive,
  ),
];

void main() {
  group('AppBottomNavBar', () {
    testWidgets('탭을 누르면 그 탭의 순서를 알린다', (tester) async {
      int? tappedIndex;
      await tester.pumpApp(
        AppBottomNavBar(
          items: _items,
          currentIndex: 0,
          onTap: (index) => tappedIndex = index,
        ),
      );

      await tester.tap(find.text('홈'));

      expect(tappedIndex, 2);
    });

    testWidgets('선택된 탭의 라벨은 강조 색으로 보인다', (tester) async {
      await tester.pumpApp(
        AppBottomNavBar(items: _items, currentIndex: 1, onTap: (_) {}),
      );

      final activeLabel = tester.widget<Text>(find.text('채팅'));
      final inactiveLabel = tester.widget<Text>(find.text('홈'));

      expect(activeLabel.style?.color, AppColors.navActive);
      expect(inactiveLabel.style?.color, AppColors.textPrimary);
    });

    testWidgets('탭의 위쪽 여백을 눌러도 그 탭의 순서를 알린다', (tester) async {
      int? tappedIndex;
      await tester.pumpApp(
        Align(
          alignment: Alignment.bottomCenter,
          child: AppBottomNavBar(
            items: _items,
            currentIndex: 0,
            onTap: (index) => tappedIndex = index,
          ),
        ),
      );
      final barTop = tester.getRect(find.byType(AppBottomNavBar)).top;
      final homeCenterX = tester.getCenter(find.text('홈')).dx;

      await tester.tapAt(Offset(homeCenterX, barTop + 3));

      expect(tappedIndex, 2);
    });
  });
}
