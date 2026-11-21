import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 서류 원본 자리에 바탕을 칠하고 비스듬한 빗금을 긋습니다.
///
/// 원본 이미지가 아직 없을 때 자리를 표시합니다. 보관함의 서류 카드와
/// 서류 상세의 원본 보기에서 함께 씁니다.
class DocumentStripePainter extends CustomPainter {
  const DocumentStripePainter({
    this.fill = AppColors.softFill,
    this.stripe = AppColors.documentStripe,
  });

  /// 바탕 색.
  final Color fill;

  /// 빗금 색.
  final Color stripe;

  static const _stripeWidth = 9.0;

  /// 한 빗금의 시작에서 다음 빗금의 시작까지 거리. 빗금과 바탕이 같은 너비입니다.
  static const _stripePeriod = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = fill);
    final paint = Paint()
      ..color = stripe
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
  bool shouldRepaint(DocumentStripePainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.stripe != stripe;
}
