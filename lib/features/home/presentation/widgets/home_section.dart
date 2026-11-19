import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

/// 홈의 한 구역. 제목과 "전체 보기 ›" 같은 링크, 그 아래 내용.
class HomeSection extends StatelessWidget {
  const HomeSection({
    required this.title,
    required this.child,
    this.linkLabel,
    this.onLinkTap,
    super.key,
  });

  final String title;
  final String? linkLabel;
  final VoidCallback? onLinkTap;
  final Widget child;

  /// 제목 줄과 내용 사이 간격.
  static const _gap = 10.0;

  @override
  Widget build(BuildContext context) {
    final linkLabel = this.linkLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: AppTypography.cardTitle)),
            if (linkLabel != null)
              TextButton(
                onPressed: onLinkTap,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  textStyle: AppTypography.label,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 20),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                child: Text(linkLabel),
              ),
          ],
        ),
        const SizedBox(height: _gap),
        child,
      ],
    );
  }
}
