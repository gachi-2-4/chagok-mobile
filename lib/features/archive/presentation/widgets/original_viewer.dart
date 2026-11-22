import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/archive/data/summary_row.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/document_stripe_painter.dart';
import 'package:flutter/material.dart';

/// 07 · 서류 원본을 쪽마다 옆으로 넘겨 보는 자리.
///
/// 아직 원본 이미지를 받지 않아, 빗금 위에 서류 이름과 읽어 낸 항목을 적은 예시
/// 종이를 그립니다. 왼쪽 위에 "원본" 표, 오른쪽 위에 AI 정리본으로 바꾸는 버튼,
/// 아래에 "1 / 4" 쪽 위치를 둡니다.
class OriginalViewer extends StatefulWidget {
  const OriginalViewer({
    required this.title,
    required this.pageCount,
    required this.onOpenSummary,
    this.facts = const [],
    super.key,
  });

  /// 서류 이름. 예시 종이 맨 위에 적습니다.
  final String title;

  /// 예시 종이에 적을 항목. AI 정리본 표의 줄입니다.
  final List<SummaryRow> facts;

  /// 원본 쪽수.
  final int pageCount;

  /// "AI 정리본 열기"를 눌렀을 때 동작.
  final VoidCallback onOpenSummary;

  @override
  State<OriginalViewer> createState() => _OriginalViewerState();
}

class _OriginalViewerState extends State<OriginalViewer> {
  // 지금 보는 쪽은 이 자리에서만 쓰는 작은 화면 상태라 Notifier 대신 State에 둡니다.
  var _page = 0;

  /// 원본 자리의 너비 대 높이.
  static const _aspectRatio = 0.87;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Stack(
          children: [
            PageView.builder(
              itemCount: widget.pageCount,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, index) => _OriginalPage(
                title: widget.title,
                // 항목은 첫 쪽에만 적고, 다음 쪽은 본문 자리만 그립니다.
                facts: index == 0 ? widget.facts : const [],
              ),
            ),
            const Positioned(
              left: AppSpacing.md,
              top: AppSpacing.md,
              child: _OriginalChip(),
            ),
            Positioned(
              right: AppSpacing.md,
              top: AppSpacing.md,
              child: _OpenSummaryButton(onTap: widget.onOpenSummary),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.md,
              child: Center(
                child: _PagePosition(page: _page + 1, total: widget.pageCount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 원본 한 쪽. 원본 이미지가 생기기 전까지 빗금 위에 예시 종이를 그립니다.
class _OriginalPage extends StatelessWidget {
  const _OriginalPage({required this.title, required this.facts});

  final String title;
  final List<SummaryRow> facts;

  /// 원본 자리에 대한 예시 종이의 너비·높이 비율. 위·아래 알약을 가리지 않습니다.
  static const _paperWidthFactor = 0.78;
  static const _paperHeightFactor = 0.7;

  /// 종이에 적는 항목 수. 넘치면 뒤는 줄입니다.
  static const _maxFacts = 4;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const DocumentStripePainter(
        fill: AppColors.documentOriginal,
        stripe: AppColors.boxBodyGray,
      ),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: _paperWidthFactor,
          heightFactor: _paperHeightFactor,
          child: _SamplePaper(
            title: title,
            facts: facts.take(_maxFacts).toList(),
          ),
        ),
      ),
    );
  }
}

/// 서류 이름, 항목, 본문 자리 줄을 적은 흰 종이.
class _SamplePaper extends StatelessWidget {
  const _SamplePaper({required this.title, required this.facts});

  final String title;
  final List<SummaryRow> facts;

  /// 제목 아래 구분선의 두께.
  static const _dividerHeight = 1.0;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.small),
        // 글자를 크게 키워 종이를 넘쳐도 오류 없이 아래를 자르도록 스크롤 안에 둡니다.
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.listTitle,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: _dividerHeight, color: AppColors.divider),
              for (final fact in facts) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${fact.label}  ${fact.value}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.small.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const _PlaceholderLines(),
              const SizedBox(height: AppSpacing.md),
              Text(
                ArchiveStrings.originalSampleNotice,
                textAlign: TextAlign.center,
                style: AppTypography.small.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 예시 종이에서 본문 글자 자리를 나타내는 회색 줄들.
class _PlaceholderLines extends StatelessWidget {
  const _PlaceholderLines();

  /// 줄의 두께와 줄 수, 마지막 줄의 길이 비율.
  static const _lineHeight = 6.0;
  static const _lineCount = 6;
  static const _lastLineFactor = 0.6;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var line = 0; line < _lineCount; line++) ...[
          const SizedBox(height: AppSpacing.sm),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: line == _lineCount - 1 ? _lastLineFactor : 1,
            child: Container(
              height: _lineHeight,
              decoration: BoxDecoration(
                color: AppColors.softFill,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 왼쪽 위의 "원본" 표.
class _OriginalChip extends StatelessWidget {
  const _OriginalChip();

  @override
  Widget build(BuildContext context) {
    return _Pill(
      fill: AppColors.softFill,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.image_outlined,
            size: AppIcons.smallSize,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            ArchiveStrings.tabOriginal,
            style: AppTypography.tag.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// 오른쪽 위의 "AI 정리본 열기" 버튼.
class _OpenSummaryButton extends StatelessWidget {
  const _OpenSummaryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 원본 자리 전체와 합쳐지지 않고 따로 고르고 누를 수 있게 노드를 나눕니다.
    return Semantics(
      container: true,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: _Pill(
          fill: AppColors.primary,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.autorenew_rounded,
                size: AppIcons.smallSize,
                color: AppColors.onPrimary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                ArchiveStrings.openSummaryAction,
                style: AppTypography.tag.copyWith(color: AppColors.onPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 아래 가운데의 "1 / 4" 쪽 위치.
class _PagePosition extends StatelessWidget {
  const _PagePosition({required this.page, required this.total});

  final int page;
  final int total;

  @override
  Widget build(BuildContext context) {
    return _Pill(
      fill: AppColors.textPrimary,
      child: Text(
        ArchiveStrings.pagePosition(page, total),
        style: AppTypography.tag.copyWith(color: AppColors.onPrimary),
      ),
    );
  }
}

/// 원본 위에 겹쳐 그리는 작은 알약.
class _Pill extends StatelessWidget {
  const _Pill({required this.fill, required this.child});

  final Color fill;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: child,
      ),
    );
  }
}
