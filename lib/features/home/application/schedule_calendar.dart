import 'package:chagok_mobile/features/home/data/schedule_item.dart';

/// 미니 캘린더 계산을 모은 함수.
abstract final class ScheduleCalendar {
  /// [day]가 들어 있는 주의 일요일부터 토요일까지 7일. 시각은 버립니다.
  static List<DateTime> weekOf(DateTime day) {
    // DateTime.weekday: 월요일 1 ~ 일요일 7
    // 시간을 빼면(subtract) 서머타임 경계에서 하루 어긋나므로 날짜로 셉니다.
    final sunday = DateTime(day.year, day.month, day.day - day.weekday % 7);
    return [
      for (var offset = 0; offset < DateTime.daysPerWeek; offset++)
        DateTime(sunday.year, sunday.month, sunday.day + offset),
    ];
  }

  /// [from]에서 [to]까지 남은 날 수. 같은 날이면 0, 지났으면 음수.
  static int daysUntil(DateTime from, DateTime to) {
    // 일광 절약 시간에도 하루가 24시간이 되도록 UTC로 셉니다.
    final start = DateTime.utc(from.year, from.month, from.day);
    final end = DateTime.utc(to.year, to.month, to.day);
    return end.difference(start).inDays;
  }

  /// [today]를 포함해 그 뒤로 가장 가까운 일정. 없으면 null.
  static ScheduleItem? nextSchedule(
    List<ScheduleItem> schedules,
    DateTime today,
  ) {
    final upcoming =
        schedules.where((item) => daysUntil(today, item.date) >= 0).toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  /// [day]에 일정이 하나라도 있으면 true.
  static bool hasScheduleOn(List<ScheduleItem> schedules, DateTime day) {
    return schedules.any((item) => daysUntil(day, item.date) == 0);
  }

  /// [time]의 시각을 버리고 그날 0시를 돌려줍니다.
  static DateTime dateOnly(DateTime time) =>
      DateTime(time.year, time.month, time.day);
}
