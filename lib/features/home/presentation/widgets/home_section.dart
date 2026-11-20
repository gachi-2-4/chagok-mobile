import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
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

  /// 구역 제목. 예: "미니 캘린더"
  final String title;

  /// 제목 오른쪽 링크 글자. 비우면 링크를 그리지 않습니다.
  final String? linkLabel;
  final VoidCallback? onLinkTap;

  /// 제목 아래 내용.
  final Widget child;

  static const _linkMinHeight = 20.0;

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
                  minimumSize: const Size(0, _linkMinHeight),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                child: Text(linkLabel),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sectionTitleGap),
        child,
      ],
    );
  }
}
