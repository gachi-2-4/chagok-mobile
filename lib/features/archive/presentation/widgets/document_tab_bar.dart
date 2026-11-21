import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:chagok_mobile/features/archive/presentation/document_tab.dart';
import 'package:flutter/material.dart';

/// 서류 상세 위의 "원본 / AI 정리본" 탭. 고른 탭은 밝은 알약으로 띄웁니다.
class DocumentTabBar extends StatelessWidget {
  const DocumentTabBar({
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final DocumentTab selected;
  final ValueChanged<DocumentTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.segmentFill,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.segmentInset),
        child: Row(
          children: [
            for (final tab in DocumentTab.values)
              Expanded(
                child: _TabButton(
                  tab: tab,
                  isSelected: tab == selected,
                  onTap: () => onSelect(tab),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final DocumentTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  static const _minHeight = 40.0;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (tab) {
      DocumentTab.original => (
        Icons.image_outlined,
        ArchiveStrings.tabOriginal,
      ),
      DocumentTab.summary => (
        Icons.auto_awesome_outlined,
        ArchiveStrings.tabSummary,
      ),
    };
    final color = isSelected ? AppColors.textPrimary : AppColors.textSecondary;

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: _minHeight),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.softFill : AppColors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppIcons.smallSize, color: color),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.fieldLabel.copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
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
