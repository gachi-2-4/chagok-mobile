/// 납부일·만기일처럼 날짜가 정해진 일정 하나.
class ScheduleItem {
  const ScheduleItem({required this.date, required this.title});

  /// 일정 날짜. 시각은 쓰지 않습니다.
  final DateTime date;

  /// 예: "통신 서비스 요금 납부일"
  final String title;
}
