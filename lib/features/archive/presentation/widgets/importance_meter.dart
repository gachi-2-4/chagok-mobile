import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/archive/data/document_importance.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:flutter/material.dart';

/// 중요도를 세 칸 막대와 "높음·보통·낮음"으로 보여 줍니다.
///
/// 높을수록 칸을 더 많이 채우고 눈에 띄는 색을 씁니다.
class ImportanceMeter extends StatelessWidget {
  const ImportanceMeter({required this.importance, super.key});

  final DocumentImportance importance;

  static const _segmentCount = 3;
  static const _segmentWidth = 14.0;
  static const _segmentHeight = 6.0;

  @override
  Widget build(BuildContext context) {
    final (filled, color) = switch (importance) {
      DocumentImportance.high => (3, AppColors.primary),
      DocumentImportance.medium => (2, AppColors.boxLidGreen),
      DocumentImportance.low => (1, AppColors.boxLidGray),
    };

    return Semantics(
      label:
          '${ArchiveStrings.importanceLabel} '
          '${ArchiveStrings.importanceLevel(importance)}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < _segmentCount; index++) ...[
            if (index > 0) const SizedBox(width: AppSpacing.meterGap),
            Container(
              width: _segmentWidth,
              height: _segmentHeight,
              decoration: BoxDecoration(
                color: index < filled ? color : AppColors.boxBodyGray,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ],
          const SizedBox(width: AppSpacing.sm),
          Text(
            ArchiveStrings.importanceLevel(importance),
            style: AppTypography.fieldLabel.copyWith(
              color: importance == DocumentImportance.high
                  ? AppColors.brand
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
