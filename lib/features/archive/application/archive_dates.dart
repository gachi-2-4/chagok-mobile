/// 보관함의 D-n 계산을 모은 함수.
abstract final class ArchiveDates {
  /// [from]에서 [to]까지 남은 날 수. 같은 날이면 0, 지났으면 음수.
  static int daysUntil(DateTime from, DateTime to) {
    // 일광 절약 시간에도 하루가 24시간이 되도록 UTC로 셉니다.
    final start = DateTime.utc(from.year, from.month, from.day);
    final end = DateTime.utc(to.year, to.month, to.day);
    return end.difference(start).inDays;
  }

  /// [today]부터 [dueDate]까지 남은 날 수. 기한이 없거나 지났으면 null.
  ///
  /// 지난 기한은 D-n 표를 그리지 않으므로 null로 돌려줍니다.
  static int? daysLeft(DateTime? dueDate, DateTime today) {
    if (dueDate == null) return null;
    final days = daysUntil(today, dueDate);
    return days >= 0 ? days : null;
  }
}
