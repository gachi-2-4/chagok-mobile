import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:flutter/material.dart';

/// 홈의 미니 캘린더·최근 알림을 담는 카드. 입력창과 같은 색을 씁니다.
class HomeCard extends StatelessWidget {
  const HomeCard({required this.child, required this.padding, super.key});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
