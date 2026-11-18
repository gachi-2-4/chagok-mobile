import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

/// 목록을 묶는 작은 구역 제목. 예: "앱 설정", "알림 받기"
///
/// Figma `Setting/SectionHeader` 컴포넌트에 해당합니다.
class AppListSectionHeader extends StatelessWidget {
  const AppListSectionHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        18,
        AppSpacing.screenHorizontal,
        6,
      ),
      child: Text(
        title,
        style: AppTypography.listSubtitle.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
