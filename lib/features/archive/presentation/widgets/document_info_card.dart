import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/features/archive/application/document_overview_item.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/importance_meter.dart';
import 'package:flutter/material.dart';

/// 서류 상세 아래의 정보 카드. 이름, 중요도, 비용, D-day를 보여 줍니다.
///
/// 비용이나 기한이 없는 서류(09)는 그 줄을 그리지 않습니다. 기한이 있으면
/// "기한 자동 등록됨" 버튼을 두고, 누르면 납부일 알림 화면으로 갑니다.
class DocumentInfoCard extends StatelessWidget {
  const DocumentInfoCard({
    required this.item,
    required this.onDeadlineTap,
    super.key,
  });

  final DocumentOverviewItem item;

  /// "기한 자동 등록됨"을 눌렀을 때 동작.
  final VoidCallback onDeadlineTap;

  @override
  Widget build(BuildContext context) {
    final overview = item.overview;
    final document = overview.document;
    final cost = overview.cost;
    final daysLeft = item.daysLeft;
    final dueDate = document.dueDate;

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
            Text(document.title, style: AppTypography.sheetTitle),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(
              label: ArchiveStrings.importanceLabel,
              value: ImportanceMeter(importance: document.importance),
            ),
            if (cost != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _InfoRow(
                label: ArchiveStrings.costLabel,
                value: Text(
                  ArchiveStrings.cost(cost.label, cost.amount),
                  style: AppTypography.documentCardTitle,
                ),
              ),
            ],
            if (daysLeft != null && dueDate != null)
              _DueBlock(
                daysLeft: daysLeft,
                dueDate: dueDate,
                dueLabel: overview.dueLabel,
                periodEnd: overview.periodEnd,
                onDeadlineTap: onDeadlineTap,
              ),
          ],
        ),
      ),
    );
  }
}

/// 구분선 아래의 D-day, 기간·기한 한 줄, "기한 자동 등록됨" 버튼.
class _DueBlock extends StatelessWidget {
  const _DueBlock({
    required this.daysLeft,
    required this.dueDate,
    required this.dueLabel,
    required this.periodEnd,
    required this.onDeadlineTap,
  });

  final int daysLeft;
  final DateTime dueDate;
  final String? dueLabel;
  final DateTime? periodEnd;
  final VoidCallback onDeadlineTap;

  static const _dividerHeight = 1.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Divider(
            height: _dividerHeight,
            color: AppColors.noticeDivider,
          ),
        ),
        _InfoRow(
          label: ArchiveStrings.dDayLabel,
          value: Text(
            ArchiveStrings.dDay(daysLeft),
            style: AppTypography.dDayLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          ArchiveStrings.dueLine(
            dueDate: dueDate,
            dueLabel: dueLabel,
            periodEnd: periodEnd,
          ),
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton.primary(
          label: ArchiveStrings.deadlineRegistered,
          icon: Icons.event_available_outlined,
          onPressed: onDeadlineTap,
        ),
      ],
    );
  }
}

/// 왼쪽 이름과 오른쪽 값으로 이루어진 한 줄.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTypography.listSubtitle),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(fit: BoxFit.scaleDown, child: value),
          ),
        ),
      ],
    );
  }
}
