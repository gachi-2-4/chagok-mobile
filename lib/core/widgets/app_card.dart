import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';

enum _AppCardTone {
  neutral(AppColors.surface, AppColors.surfaceBorder),
  green(AppColors.green, AppColors.greenBorder),
  peach(AppColors.peach, AppColors.peachBorder);

  const _AppCardTone(this.fill, this.border);

  final Color fill;
  final Color border;
}

/// 내용을 묶어 보여 주는 둥근 카드.
///
/// - [AppCard.new]: 기본 밝은 카드. 예: 비교 표, 글자 크기 미리 보기
/// - [AppCard.green]: 초록 강조. 예: "앨범에서 선택"
/// - [AppCard.peach]: 주황 강조. 예: "이번 달 초과 추정액"
class AppCard extends StatelessWidget {
  const AppCard({required this.child, this.onTap, super.key})
    : _tone = _AppCardTone.neutral;

  const AppCard.green({required this.child, this.onTap, super.key})
    : _tone = _AppCardTone.green;

  const AppCard.peach({required this.child, this.onTap, super.key})
    : _tone = _AppCardTone.peach;

  final Widget child;
  final VoidCallback? onTap;
  final _AppCardTone _tone;

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(AppRadius.card));

    return Material(
      color: _tone.fill,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: _tone.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: child,
        ),
      ),
    );
  }
}
