import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

/// 눌러서 고르거나 바로 질문할 때 쓰는 작은 알약 버튼.
///
/// 예: 추천 질문 "위약금이 있나요?", 검색 필터
class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    this.isSelected = false,
    this.onTap,
    super.key,
  });

  static const height = 37.0;

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fill = isSelected ? AppColors.chipSelectedFill : AppColors.chipFill;
    final border = isSelected
        ? AppColors.chipSelectedBorder
        : AppColors.chipBorder;
    final textStyle = isSelected
        ? AppTypography.label.copyWith(
            color: AppColors.chipSelectedText,
            fontWeight: FontWeight.w600,
          )
        : AppTypography.label;

    return Semantics(
      button: onTap != null,
      selected: isSelected,
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          side: BorderSide(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: Center(
                widthFactor: 1,
                child: Text(label, style: textStyle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
