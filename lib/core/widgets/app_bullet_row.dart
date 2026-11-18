import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

/// 점(•)으로 시작하는 목록 한 줄.
///
/// Figma `Setting/BulletRow` 컴포넌트에 해당합니다. 예: 탈퇴 시 삭제 항목
class AppBulletRow extends StatelessWidget {
  const AppBulletRow({required this.text, super.key});

  static const height = 44.0;

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Row(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.bullet,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(dimension: 6),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: AppTypography.option)),
          ],
        ),
      ),
    );
  }
}
