import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/archive/application/box_document_item.dart';
import 'package:chagok_mobile/features/archive/data/document_importance.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/document_stripe_painter.dart';
import 'package:flutter/material.dart';

/// 보관함 상세(06)·서류 검색의 서류 하나.
///
/// 원본 자리 아래에 이름과 중요도·D-n 표를 둡니다. 원본 자리 오른쪽 아래의
/// 초록 버튼을 누르면 서류 상세의 AI 정리본 탭을 엽니다.
class BoxDocumentCard extends StatelessWidget {
  const BoxDocumentCard({
    required this.item,
    required this.onTap,
    required this.onOpenSummary,
    super.key,
  });

  final BoxDocumentItem item;

  /// 서류를 눌렀을 때 동작.
  final VoidCallback onTap;

  /// AI 정리본 보기 버튼을 눌렀을 때 동작.
  final VoidCallback onOpenSummary;

  /// 서류 원본 자리의 너비 대 높이. A4 세로에 가깝게 그립니다.
  static const _thumbnailAspectRatio = 3 / 4;

  @override
  Widget build(BuildContext context) {
    final document = item.document;
    final daysLeft = item.daysLeft;
    final boxName = item.boxName;

    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: _thumbnailAspectRatio,
              child: _Thumbnail(
                pageCount: document.pageCount,
                onOpenSummary: onOpenSummary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              document.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.documentCardTitle,
            ),
            if (boxName != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                boxName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.listSubtitle.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _ImportanceTag(importance: document.importance),
                if (daysLeft != null)
                  _Tag(
                    label: ArchiveStrings.dDay(daysLeft),
                    fill: AppColors.boxTag,
                    textColor: AppColors.logo,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 빗금을 그은 서류 원본 자리. 여러 장이면 왼쪽 위에 쪽수를 둡니다.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.pageCount, required this.onOpenSummary});

  final int pageCount;
  final VoidCallback onOpenSummary;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.paper),
      child: CustomPaint(
        painter: const DocumentStripePainter(),
        child: Stack(
          children: [
            Center(
              child: Text(
                ArchiveStrings.documentOriginal,
                style: AppTypography.small.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            if (pageCount > 1)
              Positioned(
                left: AppSpacing.sm,
                top: AppSpacing.sm,
                child: _Tag(
                  label: ArchiveStrings.pageCount(pageCount),
                  fill: AppColors.textPrimary,
                  textColor: AppColors.onPrimary,
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: _SummaryButton(onTap: onOpenSummary),
            ),
          ],
        ),
      ),
    );
  }
}

/// 서류 상세의 AI 정리본 탭을 여는 초록 동그라미 버튼.
///
/// 그림은 작게 그리고, 손가락으로 누르기 쉽도록 누르는 영역은 넓게 둡니다.
class _SummaryButton extends StatelessWidget {
  const _SummaryButton({required this.onTap});

  final VoidCallback onTap;

  static const _tapSize = 40.0;
  static const _circleSize = 24.0;
  static const _iconSize = 14.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // 서류 카드 전체도 버튼이라, 따로 읽히고 눌리도록 노드를 나눕니다.
      container: true,
      button: true,
      label: ArchiveStrings.openSummary,
      child: Tooltip(
        message: ArchiveStrings.openSummary,
        excludeFromSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: const SizedBox.square(
            dimension: _tapSize,
            child: Center(
              child: SizedBox.square(
                dimension: _circleSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.boxLidGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome_outlined,
                    size: _iconSize,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 중요도 표. 높을수록 눈에 띄는 색을 씁니다.
class _ImportanceTag extends StatelessWidget {
  const _ImportanceTag({required this.importance});

  final DocumentImportance importance;

  @override
  Widget build(BuildContext context) {
    final (fill, textColor) = switch (importance) {
      DocumentImportance.high => (AppColors.peach, AppColors.brand),
      DocumentImportance.medium => (
        AppColors.green,
        AppColors.chipSelectedText,
      ),
      DocumentImportance.low => (
        AppColors.calendarControl,
        AppColors.secondaryButtonText,
      ),
    };
    return _Tag(
      label: ArchiveStrings.importance(importance),
      fill: fill,
      textColor: textColor,
    );
  }
}

/// 작은 알약 모양 표. 예: "중요 높음", "D-46", "4장"
class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.fill,
    required this.textColor,
  });

  final String label;
  final Color fill;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pillPaddingHorizontal,
          vertical: AppSpacing.tagPaddingVertical,
        ),
        child: Text(label, style: AppTypography.tag.copyWith(color: textColor)),
      ),
    );
  }
}
