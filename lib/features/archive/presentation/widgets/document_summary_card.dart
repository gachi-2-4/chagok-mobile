import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/archive/data/document_summary.dart';
import 'package:chagok_mobile/features/archive/data/summary_row.dart';
import 'package:chagok_mobile/features/archive/data/summary_section.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:flutter/material.dart';

/// 08 · AI가 서류를 읽고 정리한 AI 정리본 카드.
///
/// 한 줄 요약, 서류 이름, 그리고 표·점 목록으로 된 구역을 차례로 보여 줍니다.
class DocumentSummaryCard extends StatelessWidget {
  const DocumentSummaryCard({
    required this.title,
    required this.summary,
    required this.onViewOriginal,
    super.key,
  });

  /// 서류 이름. 예: "전세 임대차 계약서"
  final String title;
  final DocumentSummary summary;

  /// "원본 보기"를 눌렀을 때 동작.
  final VoidCallback onViewOriginal;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.softFill,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SummaryHeader(onViewOriginal: onViewOriginal),
            const SizedBox(height: AppSpacing.md),
            _OneLineSummary(text: summary.oneLine),
            const SizedBox(height: AppSpacing.block),
            Text(title, style: AppTypography.sheetTitle),
            for (final section in summary.sections) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(section.title, style: AppTypography.eyebrow),
              const SizedBox(height: AppSpacing.sm),
              switch (section) {
                SummaryTable(:final rows) => _SummaryTableView(rows: rows),
                SummaryList(:final items) => _SummaryListView(items: items),
              },
            ],
          ],
        ),
      ),
    );
  }
}

/// "AI 정리본" 표와 "원본 보기" 버튼.
class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.onViewOriginal});

  final VoidCallback onViewOriginal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome_outlined,
                  size: AppIcons.smallSize,
                  color: AppColors.chipSelectedText,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  ArchiveStrings.tabSummary,
                  style: AppTypography.tag.copyWith(
                    color: AppColors.chipSelectedText,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onViewOriginal,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            textStyle: AppTypography.caption,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          ),
          icon: const Icon(Icons.autorenew_rounded, size: AppIcons.smallSize),
          label: const Text(ArchiveStrings.viewOriginal),
        ),
      ],
    );
  }
}

/// 연두색 바탕의 한 줄 요약.
class _OneLineSummary extends StatelessWidget {
  const _OneLineSummary({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.summaryFill,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              ArchiveStrings.oneLineSummary,
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(text, style: AppTypography.chatBubble),
          ],
        ),
      ),
    );
  }
}

/// 이름·값 표. 줄 사이에 옅은 구분선을 긋습니다.
class _SummaryTableView extends StatelessWidget {
  const _SummaryTableView({required this.rows});

  final List<SummaryRow> rows;

  static const _dividerHeight = 1.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (index, row) in rows.indexed) ...[
          if (index > 0)
            const Divider(
              height: _dividerHeight,
              color: AppColors.noticeDivider,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: AppSpacing.summaryLabelWidth,
                  child: Text(row.label, style: AppTypography.listSubtitle),
                ),
                Expanded(
                  child: Text(
                    row.value,
                    style: AppTypography.fieldLabel.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// 초록 점으로 시작하는 목록.
class _SummaryListView extends StatelessWidget {
  const _SummaryListView({required this.items});

  final List<String> items;

  static const _dotSize = 5.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.bulletTop),
                  child: SizedBox.square(
                    dimension: _dotSize,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.boxLidGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    item,
                    style: AppTypography.listSubtitle.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
