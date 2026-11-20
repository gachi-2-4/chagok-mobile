import 'package:chagok_mobile/app/app_strings.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/widgets/app_bottom_nav_bar.dart';
import 'package:chagok_mobile/core/widgets/app_bottom_nav_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 하단 탭 바로 보관함 · 채팅 · 홈 · 캘린더 · 설정을 오가는 바깥 틀.
///
/// 탭마다 화면 쌓임을 따로 기억하도록 [StatefulNavigationShell]을 씁니다.
/// 탭 순서는 `router.dart`의 탭 경로 순서와 같아야 합니다.
class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  /// `router.dart`의 [StatefulShellRoute]가 넘겨주는 탭 화면 묶음.
  final StatefulNavigationShell navigationShell;

  /// 하단 탭 바의 탭. 순서는 `router.dart`의 branch 순서와 같습니다.
  static const tabs = [
    AppBottomNavItem(
      label: AppStrings.archiveTab,
      iconAsset: AppIcons.navBox,
      activeIconAsset: AppIcons.navBoxActive,
    ),
    AppBottomNavItem(label: AppStrings.chatTab, iconAsset: AppIcons.navChat),
    AppBottomNavItem(
      label: AppStrings.homeTab,
      iconAsset: AppIcons.navHome,
      activeIconAsset: AppIcons.navHomeActive,
    ),
    AppBottomNavItem(
      label: AppStrings.calendarTab,
      iconAsset: AppIcons.navCalendar,
      activeIconAsset: AppIcons.navCalendarActive,
    ),
    AppBottomNavItem(
      label: AppStrings.settingsTab,
      iconAsset: AppIcons.navSettings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        items: tabs,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          // 지금 탭을 다시 누르면 그 탭의 첫 화면으로 돌아갑니다.
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
