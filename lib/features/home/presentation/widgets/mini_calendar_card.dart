import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/home/application/schedule_calendar.dart';
import 'package:chagok_mobile/features/home/data/schedule_item.dart';
import 'package:chagok_mobile/features/home/presentation/home_strings.dart';
import 'package:chagok_mobile/features/home/presentation/widgets/home_card.dart';
import 'package:flutter/material.dart';

/// 이번 주 7일과 가장 가까운 일정을 보여 주는 카드.
///
/// Figma `card.calendar`에 해당합니다. 오늘은 진한 동그라미, 일정이 있는
/// 날은 숫자 아래 점으로 표시합니다.
class MiniCalendarCard extends StatelessWidget {
  const MiniCalendarCard({
    required this.today,
    required this.schedules,
    super.key,
  });

  final DateTime today;
  final List<ScheduleItem> schedules;

  static const _padding = 18.0;

  @override
  Widget build(BuildContext context) {
    final week = ScheduleCalendar.weekOf(today);
    final next = ScheduleCalendar.nextSchedule(schedules, today);

    return HomeCard(
      padding: const EdgeInsets.all(_padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final day in week)
                _DayCell(
                  day: day,
                  isToday: ScheduleCalendar.daysUntil(today, day) == 0,
                  hasSchedule: ScheduleCalendar.hasScheduleOn(schedules, day),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(
            height: 1,
            color: AppColors.textPrimary.withValues(alpha: 0.1),
          ),
          const SizedBox(height: AppSpacing.md),
          if (next == null)
            const Text(
              HomeStrings.noUpcomingSchedule,
              style: AppTypography.listSubtitle,
            )
          else
            _UpcomingRow(
              days: ScheduleCalendar.daysUntil(today, next.date),
              label: HomeStrings.scheduleLine(next.title, next.date),
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.hasSchedule,
  });

  final DateTime day;
  final bool isToday;
  final bool hasSchedule;

  static const _circleSize = 32.0;
  static const _dotSize = 5.0;
  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    final isSunday = day.weekday == DateTime.sunday;
    const weekdayStyle = TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: AppTypography.fontFamilyFallback,
      fontSize: 11,
      height: 13.2 / 11,
    );
    const dayStyle = TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: AppTypography.fontFamilyFallback,
      fontSize: 15,
      height: 18 / 15,
    );

    return SizedBox(
      width: _circleSize,
      child: Column(
        children: [
          Text(
            HomeStrings.weekdays[day.weekday % 7],
            style: weekdayStyle.copyWith(
              color: isSunday ? AppColors.navActive : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: _gap),
          Container(
            width: _circleSize,
            height: _circleSize,
            alignment: Alignment.center,
            decoration: isToday
                ? const BoxDecoration(
                    color: AppColors.textPrimary,
                    shape: BoxShape.circle,
                  )
                : null,
            child: Text(
              '${day.day}',
              style: dayStyle.copyWith(
                color: isToday ? AppColors.surface : AppColors.textPrimary,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: _gap),
          Container(
            width: _dotSize,
            height: _dotSize,
            decoration: BoxDecoration(
              color: hasSchedule ? AppColors.navActive : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

/// "D-2  통신 서비스 요금 납부일 · 11.20"
class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.days, required this.label});

  final int days;
  final String label;

  static const _pillRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.peach,
            borderRadius: BorderRadius.circular(_pillRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: AppSpacing.xs,
            ),
            child: Text(
              HomeStrings.dDay(days),
              style: AppTypography.label.copyWith(
                fontSize: 11,
                height: 13.2 / 11,
                fontWeight: FontWeight.w700,
                color: AppColors.brand,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.fieldLabel.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
