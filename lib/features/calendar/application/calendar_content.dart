import 'package:chagok_mobile/features/calendar/application/calendar_dates.dart';
import 'package:chagok_mobile/features/calendar/application/calendar_day.dart';
import 'package:chagok_mobile/features/calendar/application/calendar_view.dart';
import 'package:chagok_mobile/features/calendar/application/calendar_view_notifier.dart';
import 'package:chagok_mobile/features/calendar/application/deadline_item.dart';
import 'package:chagok_mobile/features/calendar/application/deadline_list_notifier.dart';
import 'package:chagok_mobile/features/calendar/data/deadline.dart';
import 'package:chagok_mobile/features/home/application/home_today_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 캘린더 화면이 그대로 그릴 값. 기한 목록·보기 상태·오늘에서 계산합니다.
///
/// 오늘은 홈의 기준 날짜([homeTodayProvider])를 따릅니다.
final calendarContentProvider = Provider<AsyncValue<CalendarContent>>((ref) {
  final view = ref.watch(calendarViewProvider);
  // 홈 탭의 기준 날짜(오늘 0시)를 씁니다. 자정이 지나거나 앱으로 돌아오면 바뀌어
  // 오늘 표시와 남은 날을 다시 계산합니다. 하단 탭은 홈 탭을 계속 살려 둡니다.
  final today = ref.watch(homeTodayProvider);
  return ref
      .watch(deadlineListProvider)
      .whenData(
        (deadlines) =>
            CalendarContent.of(deadlines: deadlines, view: view, today: today),
      );
});

/// 캘린더 화면이 보여 줄 달·날짜 표시와 기한 목록.
class CalendarContent {
  /// [weeks]와 [items]는 복사해서 바꿀 수 없는 목록으로 보관합니다.
  CalendarContent({
    required this.month,
    required this.today,
    required List<List<CalendarDay?>> weeks,
    required List<DeadlineItem> items,
    this.selectedDate,
  }) : weeks = List.unmodifiable(weeks.map(List<CalendarDay?>.unmodifiable)),
       items = List.unmodifiable(items);

  /// [deadlines]를 [view]와 [today]에 맞춰 거르고 계산합니다.
  ///
  /// 날짜를 골랐으면 그날 기한을, 아니면 오늘 이후 기한을 날짜순으로 담습니다.
  factory CalendarContent.of({
    required List<Deadline> deadlines,
    required CalendarView view,
    required DateTime today,
  }) {
    final selectedDate = view.selectedDate;
    final marks = CalendarDates.markedDaysOf(deadlines, view.month);
    final cells = [
      for (final date in CalendarDates.cellsOf(view.month))
        date == null
            ? null
            : CalendarDay(
                date: date,
                isToday: CalendarDates.isSameDay(date, today),
                isSelected:
                    selectedDate != null &&
                    CalendarDates.isSameDay(date, selectedDate),
                isRegistered: marks[date.day],
              ),
    ];
    final shown = selectedDate == null
        ? CalendarDates.upcoming(deadlines, today)
        : CalendarDates.on(deadlines, selectedDate);
    return CalendarContent(
      month: view.month,
      today: today,
      selectedDate: selectedDate,
      weeks: [
        for (
          var start = 0;
          start < cells.length;
          start += CalendarDates.daysInWeek
        )
          cells.sublist(start, start + CalendarDates.daysInWeek),
      ],
      items: [
        for (final deadline in shown)
          DeadlineItem(
            deadline: deadline,
            daysLeft: CalendarDates.daysUntil(today, deadline.dueDate),
          ),
      ],
    );
  }

  /// 보고 있는 달(1일 0시).
  final DateTime month;

  /// 오늘(0시).
  final DateTime today;

  /// 고른 날짜(0시). 고르지 않았으면 null.
  final DateTime? selectedDate;

  /// 달력 칸을 주 단위로 나눈 것. 첫 주·마지막 주의 빈칸은 null입니다.
  final List<List<CalendarDay?>> weeks;

  /// 목록에 보여 줄 기한.
  final List<DeadlineItem> items;
}
