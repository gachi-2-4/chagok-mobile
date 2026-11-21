import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_bottom_nav_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 화면 맨 아래의 탭 이동 바.
///
/// Figma `div.nav`에 해당합니다. 예: 보관함 · 채팅 · 홈 · 캘린더 · 마이페이지
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.navBackground,
        border: Border(top: BorderSide(color: AppColors.navBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          // 위아래 여백은 탭을 누르는 영역에 넣기 위해 각 탭(_NavTab) 안에 둡니다.
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.navBarPaddingHorizontal,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final (index, item) in items.indexed)
                _NavTab(
                  item: item,
                  isActive: index == currentIndex,
                  onTap: () => onTap(index),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  static const _width = 54.0;
  static const _iconSize = 22.0;

  final AppBottomNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeIconAsset = item.activeIconAsset;
    final icon = switch ((isActive, activeIconAsset)) {
      (true, final String asset) => SvgPicture.asset(
        asset,
        width: _iconSize,
        height: _iconSize,
      ),
      (true, null) => SvgPicture.asset(
        item.iconAsset,
        width: _iconSize,
        height: _iconSize,
        colorFilter: const ColorFilter.mode(
          AppColors.navActive,
          BlendMode.srcIn,
        ),
      ),
      (false, _) => SvgPicture.asset(
        item.iconAsset,
        width: _iconSize,
        height: _iconSize,
      ),
    };

    return Semantics(
      button: true,
      selected: isActive,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: _width,
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          padding: const EdgeInsets.only(
            top: AppSpacing.navBarPaddingTop,
            bottom: AppSpacing.navBarPaddingBottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.label,
                style: isActive
                    ? AppTypography.label.copyWith(
                        color: AppColors.navActive,
                        fontWeight: FontWeight.w700,
                      )
                    : AppTypography.label,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
