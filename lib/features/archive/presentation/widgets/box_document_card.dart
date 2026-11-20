import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/archive/application/box_document_item.dart';
import 'package:chagok_mobile/features/archive/data/document_importance.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:flutter/material.dart';

/// 보관함 상세(06)·서류 검색의 서류 하나.
///
/// 원본 자리 아래에 이름과 중요도·D-n 표를 둡니다. 원본 자리 오른쪽 아래의
/// 초록 버튼을 누르면 AI가 서류를 쉬운 말로 바꿔 줍니다.
class BoxDocumentCard extends StatelessWidget {
  const BoxDocumentCard({
    required this.item,
    required this.onTap,
    required this.onTranslate,
    super.key,
  });

  final BoxDocumentItem item;

  /// 서류를 눌렀을 때 동작.
  final VoidCallback onTap;

  /// 쉬운 말로 번역 버튼을 눌렀을 때 동작.
  final VoidCallback onTranslate;

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
                onTranslate: onTranslate,
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
  const _Thumbnail({required this.pageCount, required this.onTranslate});

  final int pageCount;
  final VoidCallback onTranslate;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.paper),
      child: CustomPaint(
        painter: const _StripePainter(),
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
              child: _TranslateButton(onTap: onTranslate),
            ),
          ],
        ),
      ),
    );
  }
}

/// AI로 서류를 쉬운 말로 바꿔 주는 초록 동그라미 버튼.
///
/// 그림은 작게 그리고, 손가락으로 누르기 쉽도록 누르는 영역은 넓게 둡니다.
class _TranslateButton extends StatelessWidget {
  const _TranslateButton({required this.onTap});

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
      label: ArchiveStrings.translate,
      child: Tooltip(
        message: ArchiveStrings.translate,
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

/// 서류 원본 자리 바탕의 비스듬한 빗금.
class _StripePainter extends CustomPainter {
  const _StripePainter();

  static const _stripeWidth = 9.0;

  /// 한 빗금의 시작에서 다음 빗금의 시작까지 거리. 빗금과 바탕이 같은 너비입니다.
  static const _stripePeriod = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.softFill);
    final paint = Paint()
      ..color = AppColors.documentStripe
      ..strokeWidth = _stripeWidth;
    // 왼쪽 아래에서 오른쪽 위로 긋습니다. 모서리까지 덮도록 높이만큼 더 긋습니다.
    for (var x = -size.height; x < size.width; x += _stripePeriod) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StripePainter oldDelegate) => false;
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
