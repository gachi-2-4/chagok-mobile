import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/calendar/application/calendar_day.dart';
import 'package:chagok_mobile/features/calendar/presentation/calendar_strings.dart';
import 'package:flutter/material.dart';

/// 한 달 달력 카드. 연·월 고르기, 이전·다음 달 버튼, 날짜 칸, 범례를 보여 줍니다.
class MonthCalendarCard extends StatelessWidget {
  const MonthCalendarCard({
    required this.month,
    required this.weeks,
    required this.onSelect,
    required this.onPrevious,
    required this.onNext,
    required this.onPickYear,
    required this.onPickMonth,
    super.key,
  });

  /// 보여 줄 달(1일 0시).
  final DateTime month;

  /// 주 단위로 나눈 날짜 칸. 빈칸은 null입니다.
  final List<List<CalendarDay?>> weeks;

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
            for (final week in weeks)
              Row(
                children: [
                  for (final day in week)
                    Expanded(
                      child: day == null
                          ? const SizedBox(height: _DayCell.height)
                          : _DayCell(day: day, onTap: () => onSelect(day.date)),
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
      // 아래 InkWell은 의미 트리에서 빠지므로, 화면 읽기 프로그램의 탭도 여기서 받습니다.
      onTap: onTap,
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

/// 날짜 칸 하나. 날짜 동그라미 아래에 기한 점을 찍습니다.
class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.onTap});

  final CalendarDay day;
  final VoidCallback onTap;

  /// 칸 높이.
  static const height = 44.0;
  static const _dotSize = 5.0;

  @override
  Widget build(BuildContext context) {
    final dotColor = switch (day.isRegistered) {
      null => AppColors.transparent,
      true => AppColors.primary,
      false => AppColors.calendarDotMuted,
    };

    return Semantics(
      button: true,
      selected: day.isSelected,
      label: CalendarStrings.daySemantics(
        day.date,
        isRegistered: day.isRegistered,
      ),
      excludeSemantics: true,
      // 아래 InkWell은 의미 트리에서 빠지므로, 화면 읽기 프로그램의 탭도 여기서 받습니다.
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DayCircle(day: day),
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

/// 날짜 숫자 동그라미. 오늘은 테두리 원, 고른 날은 꽉 찬 원입니다.
class _DayCircle extends StatelessWidget {
  const _DayCircle({required this.day});

  final CalendarDay day;

  static const _size = 32.0;
  static const _ringWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    final isBold = day.isToday || day.isSelected || day.isRegistered != null;

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: day.isSelected ? AppColors.textPrimary : null,
        border: day.isToday && !day.isSelected
            ? Border.all(color: AppColors.primary, width: _ringWidth)
            : null,
      ),
      // 글자를 키워도 원 안에 들어가도록 줄입니다.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '${day.date.day}',
          style: AppTypography.calendarDate.copyWith(
            fontWeight: isBold ? FontWeight.w700 : null,
            color: day.isSelected ? AppColors.calendarSurface : null,
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
