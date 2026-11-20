import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/calendar/presentation/calendar_strings.dart';
import 'package:flutter/material.dart';

/// 기한 목록 왼쪽의 "D-8" 표. 2주 안으로 다가오면 눈에 띄는 색으로 바꿉니다.
class DueTag extends StatelessWidget {
  const DueTag({required this.days, super.key});

  /// 남은 날 수.
  final int days;

  /// 이 날 수 안으로 남으면 눈에 띄는 색으로 보여 줍니다.
  static const urgentDays = 14;

  static const _minWidth = 52.0;
  static const _height = 33.0;

  @override
  Widget build(BuildContext context) {
    final isUrgent = days <= urgentDays;

    return Container(
      constraints: const BoxConstraints(
        minWidth: _minWidth,
        minHeight: _height,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isUrgent ? AppColors.peach : AppColors.calendarControl,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        CalendarStrings.dDay(days),
        style: AppTypography.dueTag.copyWith(
          color: isUrgent ? AppColors.brand : AppColors.secondaryButtonText,
        ),
      ),
    );
  }
}
