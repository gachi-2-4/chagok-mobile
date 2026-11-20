import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/calendar/application/calendar_dates.dart';
import 'package:chagok_mobile/features/calendar/presentation/calendar_strings.dart';
import 'package:flutter/material.dart';

/// 한 달 달력 카드. 연·월 고르기, 이전·다음 달 버튼, 날짜 칸, 범례를 보여 줍니다.
class MonthCalendarCard extends StatelessWidget {
  const MonthCalendarCard({
    required this.month,
    required this.today,
    required this.marks,
    required this.onSelect,
    required this.onPrevious,
    required this.onNext,
    required this.onPickYear,
    required this.onPickMonth,
    this.selectedDate,
    super.key,
  });

  /// 보여 줄 달(1일 0시).
  final DateTime month;

  /// 오늘(0시). 테두리 원으로 표시합니다.
  final DateTime today;

  /// 기한이 있는 날과 그날 기한을 모두 등록했는지 여부. 칸 아래 점 색을 정합니다.
  final Map<int, bool> marks;

  /// 고른 날짜. 꽉 찬 원으로 표시합니다.
  final DateTime? selectedDate;

  /// 날짜 칸을 눌렀을 때.
  final ValueChanged<DateTime> onSelect;

  /// 이전 달 버튼을 눌렀을 때.
  final VoidCallback onPrevious;

  /// 다음 달 버튼을 눌렀을 때.
  final VoidCallback onNext;

  /// 연도를 눌렀을 때.
  final VoidCallback onPickYear;

  /// 월을 눌렀을 때.
  final VoidCallback onPickMonth;

  @override
  Widget build(BuildContext context) {
    final cells = CalendarDates.cellsOf(month);
    final selectedDate = this.selectedDate;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.calendarSurface,
        borderRadius: BorderRadius.circular(AppRadius.calendar),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MonthHeader(
              month: month,
              onPrevious: onPrevious,
              onNext: onNext,
              onPickYear: onPickYear,
              onPickMonth: onPickMonth,
            ),
            const SizedBox(height: AppSpacing.md),
            const _WeekdayRow(),
            for (
              var start = 0;
              start < cells.length;
              start += CalendarDates.daysInWeek
            )
              Row(
                children: [
                  for (final date in cells.sublist(
                    start,
                    start + CalendarDates.daysInWeek,
                  ))
                    Expanded(
                      child: date == null
                          ? const SizedBox(height: _DayCell.height)
                          : _DayCell(
                              date: date,
                              isToday: CalendarDates.isSameDay(date, today),
                              isSelected:
                                  selectedDate != null &&
                                  CalendarDates.isSameDay(date, selectedDate),
                              isRegistered: marks[date.day],
                              onTap: () => onSelect(date),
                            ),
                    ),
                ],
              ),
            const SizedBox(height: AppSpacing.sm),
            const _Legend(),
          ],
        ),
      ),
    );
  }
}

/// "2026년⌄ 11월⌄"와 이전·다음 달 버튼 한 줄.
class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
    required this.onPickYear,
    required this.onPickMonth,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPickYear;
  final VoidCallback onPickMonth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 글자를 키워 자리가 모자라면 연·월을 줄여 버튼 자리를 남깁니다.
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                _PickerLabel(
                  label: CalendarStrings.year(month.year),
                  onTap: onPickYear,
                ),
                const SizedBox(width: AppSpacing.xs),
                _PickerLabel(
                  label: CalendarStrings.month(month.month),
                  onTap: onPickMonth,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _RoundButton(
          icon: Icons.chevron_left_rounded,
          semanticLabel: CalendarStrings.previousMonth,
          onTap: onPrevious,
        ),
        const SizedBox(width: AppSpacing.sm),
        _RoundButton(
          icon: Icons.chevron_right_rounded,
          semanticLabel: CalendarStrings.nextMonth,
          onTap: onNext,
        ),
      ],
    );
  }
}

/// 눌러서 고를 수 있는 연·월 글자. 오른쪽에 펼침 표시를 붙입니다.
class _PickerLabel extends StatelessWidget {
  const _PickerLabel({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTypography.calendarMonth),
            const Icon(
              Icons.expand_more_rounded,
              size: AppIcons.smallSize,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

/// 이전·다음 달로 넘기는 동그란 버튼.
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  static const _size = 34.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: AppColors.calendarControl,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: _size,
            child: Icon(
              icon,
              size: AppIcons.mediumSize,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// 일~토 요일 이름 한 줄.
class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final weekday in CalendarStrings.weekdays)
          Expanded(
            child: Text(
              weekday,
              textAlign: TextAlign.center,
              style: AppTypography.calendarWeekday,
            ),
          ),
      ],
    );
  }
}

/// 날짜 칸 하나. 오늘은 테두리 원, 고른 날은 꽉 찬 원, 기한이 있으면 아래에 점을 찍습니다.
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.isRegistered,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;

  /// 그날 기한을 모두 등록했으면 true, 아직 남았으면 false, 기한이 없으면 null.
  final bool? isRegistered;
  final VoidCallback onTap;

  /// 칸 높이.
  static const height = 44.0;
  static const _circleSize = 32.0;
  static const _ringWidth = 2.0;
  static const _dotSize = 5.0;

  @override
  Widget build(BuildContext context) {
    final isRegistered = this.isRegistered;
    final isBold = isToday || isSelected || isRegistered != null;
    final dotColor = switch (isRegistered) {
      null => AppColors.transparent,
      true => AppColors.primary,
      false => AppColors.calendarDotMuted,
    };

    return Semantics(
      button: true,
      selected: isSelected,
      label: CalendarStrings.daySemantics(date, isRegistered: isRegistered),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: _circleSize,
                height: _circleSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.textPrimary : null,
                  border: isToday && !isSelected
                      ? Border.all(color: AppColors.primary, width: _ringWidth)
                      : null,
                ),
                // 글자를 키워도 원 안에 들어가도록 줄입니다.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${date.day}',
                    style: AppTypography.calendarDate.copyWith(
                      fontWeight: isBold ? FontWeight.w700 : null,
                      color: isSelected ? AppColors.calendarSurface : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Container(
                width: _dotSize,
                height: _dotSize,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "● 기한 자동 등록됨  ● 미추가 기한" 범례.
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Wrap(
        spacing: AppSpacing.sm,
        children: [
          _LegendItem(
            color: AppColors.primary,
            label: CalendarStrings.legendRegistered,
          ),
          _LegendItem(
            color: AppColors.calendarDotMuted,
            label: CalendarStrings.legendPending,
          ),
        ],
      ),
    );
  }
}

/// 범례 한 칸. 색 점과 설명.
class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  static const _dotSize = 7.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _dotSize,
          height: _dotSize,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
