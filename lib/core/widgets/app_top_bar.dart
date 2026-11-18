import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 뒤로 가기 · 가운데 제목 · 더보기로 이루어진 화면 상단 바.
///
/// Figma `div.bar` 컴포넌트에 해당합니다.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    required this.title,
    this.showBackButton = true,
    this.onBack,
    this.onMore,
    super.key,
  });

  static const height = 54.0;
  static const _sideSlotWidth = 24.0;

  /// 가운데에 보이는 제목. 예: "차곡", "회원가입"
  final String title;

  /// 왼쪽 뒤로 가기 버튼을 보일지 여부.
  final bool showBackButton;

  /// 뒤로 가기를 눌렀을 때 동작. 비우면 `Navigator.maybePop`을 호출합니다.
  final VoidCallback? onBack;

  /// 오른쪽 더보기(···)를 눌렀을 때 동작. 비우면 더보기를 숨깁니다.
  final VoidCallback? onMore;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Row(
            children: [
              SizedBox(
                width: _sideSlotWidth,
                child: showBackButton
                    ? _TapTarget(
                        semanticLabel: '뒤로 가기',
                        onTap: onBack ?? () => Navigator.maybePop(context),
                        child: SvgPicture.asset(
                          AppIcons.back,
                          width: 24,
                          height: 24,
                        ),
                      )
                    : null,
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.topBarTitle,
                ),
              ),
              SizedBox(
                width: _sideSlotWidth,
                child: onMore == null
                    ? null
                    : _TapTarget(
                        semanticLabel: '더보기',
                        onTap: onMore,
                        child: const Text(
                          '···',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 작은 아이콘에도 손가락으로 누르기 쉬운 영역을 주는 래퍼.
class _TapTarget extends StatelessWidget {
  const _TapTarget({
    required this.semanticLabel,
    required this.onTap,
    required this.child,
  });

  final String semanticLabel;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: AppTopBar.height,
          child: Center(child: child),
        ),
      ),
    );
  }
}
