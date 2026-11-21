import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/document_stripe_painter.dart';
import 'package:flutter/material.dart';

/// 07 · 서류 원본을 쪽마다 옆으로 넘겨 보는 자리.
///
/// 아직 원본 이미지를 받지 않아 빗금 자리로 그립니다. 왼쪽 위에 "원본" 표,
/// 오른쪽 위에 AI 정리본으로 바꾸는 버튼, 아래에 "1 / 4" 쪽 위치를 둡니다.
class OriginalViewer extends StatefulWidget {
  const OriginalViewer({
    required this.title,
    required this.pageCount,
    required this.onOpenSummary,
    super.key,
  });

  /// 서류 이름. 원본 자리 가운데에 적습니다.
  final String title;

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
              itemBuilder: (context, index) =>
                  _OriginalPage(title: widget.title),
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

/// 원본 한 쪽. 이미지가 생기기 전까지 빗금 위에 서류 이름을 적습니다.
class _OriginalPage extends StatelessWidget {
  const _OriginalPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const DocumentStripePainter(
        fill: AppColors.documentOriginal,
        stripe: AppColors.boxBodyGray,
      ),
      child: Center(
        child: Text(
          '${ArchiveStrings.documentImage}\n$title',
          textAlign: TextAlign.center,
          style: AppTypography.small.copyWith(color: AppColors.textTertiary),
        ),
      ),
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
