/// [AppBottomNavBar]의 탭 하나.
class AppBottomNavItem {
  const AppBottomNavItem({
    required this.label,
    required this.iconAsset,
    this.activeIconAsset,
  });

  final String label;

  /// 선택되지 않았을 때의 SVG 경로. `AppIcons`의 값을 씁니다.
  final String iconAsset;

  /// 선택됐을 때의 SVG 경로. 비우면 [iconAsset]을 강조 색으로 칠해서 씁니다.
  final String? activeIconAsset;
}
