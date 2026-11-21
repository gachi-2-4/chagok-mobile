import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_box_illustration.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:flutter/material.dart';

/// 보관함 목록 끝의 "새 박스" 칸. 점선 상자 안에 +를 그립니다.
///
/// 옆의 상자와 줄이 맞도록 상자 그림과 같은 높이로 그립니다.
class NewBoxCard extends StatelessWidget {
  const NewBoxCard({required this.onTap, super.key});

  final VoidCallback onTap;

  static const _plusSize = 28.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: AppBoxIllustration.height,
              child: CustomPaint(
                painter: _DashedBorderPainter(),
                child: Center(
                  child: Icon(
                    Icons.add_rounded,
                    size: _plusSize,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.boxLabelGap),
            const Text(
              ArchiveStrings.newBox,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.boxName,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              ArchiveStrings.newBoxExamples,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.listSubtitle.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 둥근 사각형 점선 테두리.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  static const _strokeWidth = 1.5;
  static const _dashLength = 6.0;
  static const _gapLength = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.chipBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    const inset = _strokeWidth / 2;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            inset,
            inset,
            size.width - _strokeWidth,
            size.height - _strokeWidth,
          ),
          const Radius.circular(AppRadius.paper),
        ),
      );

    for (final metric in outline.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + _dashLength),
          paint,
        );
        distance += _dashLength + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}
