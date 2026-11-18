import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 목록 구역 사이를 나누는 두꺼운 띠.
///
/// Figma `Setting/Band` 컴포넌트에 해당합니다.
class AppSectionBand extends StatelessWidget {
  const AppSectionBand({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.sectionBand,
      child: SizedBox(height: 8, width: double.infinity),
    );
  }
}
