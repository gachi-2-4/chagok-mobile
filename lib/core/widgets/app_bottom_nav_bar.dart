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
          // 탭마다 같은 너비를 주어, "마이페이지"처럼 긴 이름도 화면 너비와
          // 관계없이 한 줄에 들어가게 합니다. 누르는 영역도 탭 너비 전체입니다.
          child: Row(
            children: [
              for (final (index, item) in items.indexed)
                Expanded(
                  child: _NavTab(
                    item: item,
                    isActive: index == currentIndex,
                    onTap: () => onTap(index),
                  ),
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

  final AppBottomNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: double.infinity,
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
              _NavIcon(item: item, isActive: isActive),
              const SizedBox(height: AppSpacing.xs),
              // 글자를 크게 키워 탭보다 길어지면 줄을 바꾸지 않고 줄여서 맞춥니다.
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  maxLines: 1,
                  style: isActive
                      ? AppTypography.label.copyWith(
                          color: AppColors.navActive,
                          fontWeight: FontWeight.w700,
                        )
                      : AppTypography.label,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 탭 아이콘. 선택된 탭은 선택용 아이콘을, 없으면 같은 아이콘을 강조 색으로 칠합니다.
class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.item, required this.isActive});

  final AppBottomNavItem item;
  final bool isActive;

  static const _iconSize = 22.0;

  @override
  Widget build(BuildContext context) {
    final activeIconAsset = item.activeIconAsset;
    return switch ((isActive, activeIconAsset)) {
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
  }
}
