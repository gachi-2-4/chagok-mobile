import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

/// 좌우 여백이 있는 제목·설명. 목록이 꽉 찬 설정 화면 위에 씁니다.
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({required this.title, this.description, super.key});

  /// 큰 제목.
  final String title;

  /// 제목 아래 설명. 비우면 그리지 않습니다.
  final String? description;

  @override
  Widget build(BuildContext context) {
    final description = this.description;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTypography.pageTitle),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(description, style: AppTypography.pageDescription),
          ],
        ],
      ),
    );
  }
}
