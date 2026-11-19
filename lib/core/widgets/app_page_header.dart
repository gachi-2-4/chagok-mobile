import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

/// 화면 본문 맨 위의 큰 제목과 설명.
///
/// 예: "처음 만나는 차곡" / "내 서류를 쉽고 안전하게 정리해요."
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({required this.title, this.description, super.key});

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final description = this.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTypography.pageTitle),
        if (description != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(description, style: AppTypography.pageDescription),
        ],
      ],
    );
  }
}
