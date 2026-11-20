import 'package:chagok_mobile/features/calendar/data/deadline.dart';

/// 달력 칸과 기한을 계산하는 순수 함수 모음.
///
/// 날짜는 모두 달력 날짜(0시)로 다룹니다. Duration으로 빼고 더하면 서머타임
/// 경계에서 하루가 어긋나므로 연·월·일로 셉니다.
abstract final class CalendarDates {
  /// 일주일의 날 수. 달력은 일요일부터 시작합니다.
  static const daysInWeek = 7;

  /// 한 해의 달 수.
  static const monthsInYear = 12;

  /// 연도 고르기에서 보여 줄 해. 지난해부터 2년 뒤까지입니다.
  static List<int> selectableYears(DateTime today) => [
    for (var year = today.year - 1; year <= today.year + 2; year++) year,
  ];

  /// 월 고르기에서 보여 줄 달. 1월부터 12월까지입니다.
  static List<int> get selectableMonths => [
    for (var month = 1; month <= monthsInYear; month++) month,
  ];

  /// [time]의 시각을 버리고 그날 0시를 돌려줍니다.
  static DateTime dateOnly(DateTime time) =>
      DateTime(time.year, time.month, time.day);

  /// [a]와 [b]가 같은 날이면 true.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// [month]가 속한 달의 달력 칸. 첫 주의 빈칸은 null이고, 칸 수는 7의 배수입니다.
  static List<DateTime?> cellsOf(DateTime month) {
    final first = DateTime(month.year, month.month);
    final dayCount = DateTime(month.year, month.month + 1, 0).day;
    // DateTime.weekday: 월요일 1 ~ 일요일 7
    final leading = first.weekday % daysInWeek;
    final cells = <DateTime?>[
      for (var i = 0; i < leading; i++) null,
      for (var day = 1; day <= dayCount; day++)
        DateTime(month.year, month.month, day),
    ];
    while (cells.length % daysInWeek != 0) {
      cells.add(null);
    }
    return cells;
  }

  /// [today]에서 [date]까지 남은 날 수. 지났으면 음수입니다.
  static int daysUntil(DateTime today, DateTime date) {
    // UTC로 바꿔 서머타임과 상관없이 하루를 24시간으로 셉니다.
    final from = DateTime.utc(today.year, today.month, today.day);
    final to = DateTime.utc(date.year, date.month, date.day);
    return to.difference(from).inDays;
  }

  /// [today]를 포함해 그 뒤에 오는 기한을 날짜순으로 돌려줍니다.
  static List<Deadline> upcoming(List<Deadline> deadlines, DateTime today) {
    return [
      for (final deadline in deadlines)
        if (daysUntil(today, deadline.dueDate) >= 0) deadline,
    ]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// [date]가 기한인 것만 돌려줍니다.
  static List<Deadline> on(List<Deadline> deadlines, DateTime date) {
    return [
      for (final deadline in deadlines)
        if (isSameDay(deadline.dueDate, date)) deadline,
    ];
  }

  /// [month]에서 기한이 있는 날과 그날 기한을 모두 등록했는지 여부.
  ///
  /// 한 날에 등록하지 않은 기한이 하나라도 있으면 false로, 미추가로 보여 줍니다.
  static Map<int, bool> markedDaysOf(List<Deadline> deadlines, DateTime month) {
    final marks = <int, bool>{};
    for (final deadline in deadlines) {
      final date = deadline.dueDate;
      if (date.year != month.year || date.month != month.month) continue;
      marks[date.day] = (marks[date.day] ?? true) && deadline.isRegistered;
    }
    return marks;
  }
}
