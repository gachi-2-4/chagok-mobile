import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

/// 점(•)으로 시작하는 목록 한 줄.
///
/// Figma `Setting/BulletRow` 컴포넌트에 해당합니다. 예: 탈퇴 시 삭제 항목
class AppBulletRow extends StatelessWidget {
  const AppBulletRow({required this.text, super.key});

  /// 한 줄일 때의 높이. 안내가 길어지면 내용에 맞게 늘어납니다.
  static const minHeight = 44.0;

  final String text;

  static const _bulletSize = 6.0;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.bullet,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(dimension: _bulletSize),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(text, style: AppTypography.option)),
          ],
        ),
      ),
    );
  }
}
