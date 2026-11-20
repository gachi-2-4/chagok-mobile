import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:flutter/material.dart';

/// "서류 이름·내용 검색 ›" 알약 모양 버튼. 누르면 검색 화면으로 갑니다.
class ArchiveSearchButton extends StatelessWidget {
  const ArchiveSearchButton({required this.onTap, super.key});

  final VoidCallback onTap;

  static const _minHeight = 36.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.chipPaddingHorizontal,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: AppIcons.smallSize,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    ArchiveStrings.search,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: AppIcons.smallSize,
                  color: AppColors.chevron,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
