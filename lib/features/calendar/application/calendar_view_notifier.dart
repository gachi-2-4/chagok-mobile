import 'package:chagok_mobile/features/calendar/application/calendar_clock.dart';
import 'package:chagok_mobile/features/calendar/application/calendar_dates.dart';
import 'package:chagok_mobile/features/calendar/application/calendar_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 캘린더 화면에서 보고 있는 달과 고른 날짜.
final calendarViewProvider =
    NotifierProvider<CalendarViewNotifier, CalendarView>(
      CalendarViewNotifier.new,
    );

/// 달을 넘기고 날짜를 고릅니다. 처음에는 이번 달을 보여 줍니다.
class CalendarViewNotifier extends Notifier<CalendarView> {
  @override
  CalendarView build() {
    final today = ref.watch(calendarClockProvider)();
    return CalendarView(month: DateTime(today.year, today.month));
  }

  /// 이전 달로 넘기고, 고른 날짜를 지웁니다.
  void showPreviousMonth() =>
      _showMonth(state.month.year, state.month.month - 1);

  /// 다음 달로 넘기고, 고른 날짜를 지웁니다.
  void showNextMonth() => _showMonth(state.month.year, state.month.month + 1);

  /// [year]년 [month]월로 넘기고, 고른 날짜를 지웁니다.
  void showMonth({required int year, required int month}) =>
      _showMonth(year, month);

  /// [date]를 고릅니다. 이미 고른 날짜를 다시 누르면 고르기를 풉니다.
  void select(DateTime date) {
    final day = CalendarDates.dateOnly(date);
    final selected = state.selectedDate;
    final isSame = selected != null && CalendarDates.isSameDay(selected, day);
    state = state.copyWith(selectedDate: () => isSame ? null : day);
  }

  /// 고른 날짜를 지워 다가오는 기한을 모두 보여 줍니다.
  void clearSelection() => state = state.copyWith(selectedDate: () => null);

  void _showMonth(int year, int month) {
    // DateTime이 13월·0월을 다음·이전 해로 넘겨 줍니다.
    state = CalendarView(month: DateTime(year, month));
  }
}
