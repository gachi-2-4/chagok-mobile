/// 캘린더 화면에서 보고 있는 달과 고른 날짜.
class CalendarView {
  const CalendarView({required this.month, this.selectedDate});

  /// 보고 있는 달(그달 1일 0시).
  final DateTime month;

  /// 고른 날짜(0시). 고르지 않았으면 null이고, 다가오는 기한을 모두 보여 줍니다.
  final DateTime? selectedDate;

  /// 넘긴 값만 바꾼 새 상태를 돌려줍니다.
  ///
  /// [selectedDate]는 null로도 바꿀 수 있게 함수로 받습니다. 넘기지 않으면 앞선
  /// 값을 그대로 두고, `() => null`을 넘기면 지웁니다.
  CalendarView copyWith({DateTime? month, DateTime? Function()? selectedDate}) {
    return CalendarView(
      month: month ?? this.month,
      selectedDate: selectedDate == null ? this.selectedDate : selectedDate(),
    );
  }
}
