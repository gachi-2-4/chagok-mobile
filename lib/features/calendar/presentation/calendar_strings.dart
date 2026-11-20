/// 캘린더 화면에 보이는 문구.
abstract final class CalendarStrings {
  static const title = '캘린더';
  static const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
  static const previousMonth = '이전 달';
  static const nextMonth = '다음 달';
  static const legendRegistered = '기한 자동 등록됨';
  static const legendPending = '미추가 기한';
  static const upcoming = '다가오는 기한';
  static const viewAll = '전체 보기';
  static const noUpcoming = '다가오는 기한이 없어요.';
  static const noDeadlineOnDate = '이날은 기한이 없어요.';
  static const loadFailed = '기한을 불러오지 못했어요.';
  static const retry = '다시 시도';
  static const updateFailed = '캘린더에 반영하지 못했어요. 다시 시도해 주세요.';

  /// 연도 고르기 칸. 예: 2026 → "2026년"
  static String year(int year) => '$year년';

  /// 월 고르기 칸. 예: 11 → "11월"
  static String month(int month) => '$month월';

  /// 고른 날짜 제목. 예: "11월 25일"
  static String date(DateTime date) => '${date.month}월 ${date.day}일';

  /// 남은 날. 예: 8 → "D-8", 0 → "D-DAY", 지난 9일 → "D+9"
  static String dDay(int days) => switch (days) {
    0 => 'D-DAY',
    < 0 => 'D+${-days}',
    _ => 'D-$days',
  };

  /// 기한 아래 줄. 예: "11월 20일 · 병원 · 보험"
  static String deadlineMeta(DateTime date, List<String> tags) =>
      [CalendarStrings.date(date), ...tags].join(' · ');

  /// 날짜 칸을 화면 읽기 프로그램이 읽는 이름. 예: "11월 25일, 미추가 기한 있음"
  static String daySemantics(DateTime date, {required bool? isRegistered}) =>
      switch (isRegistered) {
        null => CalendarStrings.date(date),
        true => '${CalendarStrings.date(date)}, 등록한 기한 있음',
        false => '${CalendarStrings.date(date)}, 미추가 기한 있음',
      };

  /// 등록 버튼을 화면 읽기 프로그램이 읽는 이름.
  static String registerSemantics(String title, {required bool isRegistered}) =>
      isRegistered ? '$title, 캘린더에서 빼기' : '$title, 캘린더에 추가';
}
