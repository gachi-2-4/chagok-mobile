import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/widgets/app_bottom_nav_bar.dart';
import 'package:chagok_mobile/core/widgets/app_bottom_nav_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 하단 탭 바를 두르는 앱의 기본 틀.
///
/// 탭마다 화면 기록은 `router.dart`의 [StatefulShellRoute]가 따로 관리하고,
/// 이 위젯은 바텀바를 그리고 탭 이동만 맡습니다.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  /// 바텀바의 탭 순서. [_Tab.branch]는 `router.dart`의 branch 순서이고,
  /// 아직 화면이 없는 탭은 null입니다.
  static const _tabs = [
    _Tab(
      AppBottomNavItem(
        label: _ShellStrings.box,
        iconAsset: AppIcons.navBox,
        activeIconAsset: AppIcons.navBoxActive,
      ),
    ),
    _Tab(
      AppBottomNavItem(label: _ShellStrings.chat, iconAsset: AppIcons.navChat),
      branch: 1,
    ),
    _Tab(
      AppBottomNavItem(
        label: _ShellStrings.home,
        iconAsset: AppIcons.navHome,
        activeIconAsset: AppIcons.navHomeActive,
      ),
      branch: 0,
    ),
    _Tab(
      AppBottomNavItem(
        label: _ShellStrings.calendar,
        iconAsset: AppIcons.navCalendar,
        activeIconAsset: AppIcons.navCalendarActive,
      ),
    ),
    _Tab(
      AppBottomNavItem(
        label: _ShellStrings.settings,
        iconAsset: AppIcons.navSettings,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentBranch = navigationShell.currentIndex;

    void onTap(int index) {
      final branch = _tabs[index].branch;
      if (branch == null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text(_ShellStrings.comingSoon)),
          );
        return;
      }
      // 지금 탭을 다시 누르면 그 탭의 첫 화면으로 돌아갑니다.
      navigationShell.goBranch(
        branch,
        initialLocation: branch == currentBranch,
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        items: [for (final tab in _tabs) tab.item],
        currentIndex: _tabs.indexWhere((tab) => tab.branch == currentBranch),
        onTap: onTap,
      ),
    );
  }
}

class _Tab {
  const _Tab(this.item, {this.branch});

  final AppBottomNavItem item;
  final int? branch;
}

/// 바텀바에 보이는 문구.
abstract final class _ShellStrings {
  static const box = '보관함';
  static const chat = '채팅';
  static const home = '홈';
  static const calendar = '캘린더';
  static const settings = '설정';
  static const comingSoon = '곧 지원할 예정이에요.';
}
