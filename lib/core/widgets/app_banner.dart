import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

/// 화면 중간에 짧은 안내를 보여 주는 띠.
///
/// - [AppBanner.new]: 초록. 예: "연결된 서류 · 임대차계약서", "확인 필요 · …"
/// - [AppBanner.neutral]: 베이지. 예: 비밀번호 재설정 안내
class AppBanner extends StatelessWidget {
  const AppBanner({required this.child, super.key}) : _color = AppColors.green;

  const AppBanner.neutral({required this.child, super.key})
    : _color = AppColors.neutralBanner;

  final Widget child;
  final Color _color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(AppRadius.banner),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.bannerPaddingHorizontal,
          vertical: AppSpacing.bannerPaddingVertical,
        ),
        child: DefaultTextStyle.merge(
          style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
          child: child,
        ),
      ),
    );
  }
}
