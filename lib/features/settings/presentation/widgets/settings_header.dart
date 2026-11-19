import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

/// 좌우 여백이 있는 제목·설명. 목록이 꽉 찬 설정 화면 위에 씁니다.
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({required this.title, this.description, super.key});

  final String title;
  final String? description;

  /// Figma `h2.title:wrap`, `p.desc:wrap` 여백.
  static const _top = 8.0;
  static const _bottom = 16.0;

  @override
  Widget build(BuildContext context) {
    final description = this.description;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        _top,
        AppSpacing.screenHorizontal,
        _bottom,
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
