import 'package:chagok_mobile/features/home/application/schedule_calendar.dart';

/// 홈 화면에 보이는 문구.
///
/// 다국어를 도입할 때 옮기기 쉽도록 한곳에 모읍니다.
abstract final class HomeStrings {
  static const notifications = '알림';
  static const comingSoon = '곧 지원할 예정이에요.';
  static const loadFailed = '홈 내용을 불러오지 못했어요.';
  static const retry = '다시 시도';

  static const miniCalendar = '미니 캘린더';
  static const recentBoxes = '최근 연 보관함';
  static const recentAlerts = '최근 알림';
  static const viewAll = '전체 보기 ›';
  static const noUpcomingSchedule = '다가오는 일정이 없어요.';
  static const noRecentBoxes = '아직 연 보관함이 없어요.';
  static const noRecentAlerts = '새 알림이 없어요.';

  /// 요일 이름. DateTime.weekday % 7 순서(일요일 0)입니다.
  static const weekdays = ['일', '월', '화', '수', '목', '금', '토'];

  /// 예: "2026년 11월 ›"
  static String monthLink(DateTime month) => '${month.year}년 ${month.month}월 ›';

  /// 남은 날. 예: 2 → "D-2", 0 → "D-DAY"
  static String dDay(int days) => days == 0 ? 'D-DAY' : 'D-$days';

  /// 예: "통신 서비스 요금 납부일 · 11.20"
  static String scheduleLine(String title, DateTime date) =>
      '$title · ${date.month}.${date.day}';

  /// 예: "서류 3건 · 오늘 열람"
  static String boxDetail(int documentCount, DateTime openedAt, DateTime now) =>
      '서류 $documentCount건 · ${_dayLabel(openedAt, now)} 열람';

  /// 예: "집 · 임대 · 방금"
  static String alertMeta(String boxName, DateTime createdAt, DateTime now) =>
      '$boxName · ${relativeTime(createdAt, now)}';

  /// 지금으로부터 얼마나 지났는지. 예: "방금", "2시간 전", "어제", "11.3"
  static String relativeTime(DateTime time, DateTime now) {
    final elapsed = now.difference(time);
    if (elapsed.inMinutes < 1) return '방금';
    if (elapsed.inHours < 1) return '${elapsed.inMinutes}분 전';
    final days = ScheduleCalendar.daysUntil(time, now);
    if (days == 0) return '${elapsed.inHours}시간 전';
    if (days == 1) return '어제';
    if (days < 7) return '$days일 전';
    return '${time.month}.${time.day}';
  }

  static String _dayLabel(DateTime time, DateTime now) {
    return switch (ScheduleCalendar.daysUntil(time, now)) {
      0 => '오늘',
      1 => '어제',
      final days when days < 7 => '$days일 전',
      _ => '${time.month}.${time.day}',
    };
  }
}
