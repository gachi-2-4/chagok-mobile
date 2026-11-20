/// 달력의 날짜 칸 하나. 칸이 그릴 표시를 모두 계산해 둡니다.
class CalendarDay {
  const CalendarDay({
    required this.date,
    this.isToday = false,
    this.isSelected = false,
    this.isRegistered,
  });

  /// 칸의 날짜(0시).
  final DateTime date;

  /// 오늘이면 true.
  final bool isToday;

  /// 고른 날짜면 true.
  final bool isSelected;

  /// 그날 기한을 모두 등록했으면 true, 아직 남았으면 false, 기한이 없으면 null.
  final bool? isRegistered;
}
