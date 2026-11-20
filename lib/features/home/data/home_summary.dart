import 'package:chagok_mobile/features/home/data/recent_alert.dart';
import 'package:chagok_mobile/features/home/data/recent_box.dart';
import 'package:chagok_mobile/features/home/data/schedule_item.dart';

/// 홈 화면에 모아 보여 줄 내용.
class HomeSummary {
  /// 세 목록은 복사해서 바꿀 수 없는 목록으로 보관합니다.
  /// 넘긴 목록을 나중에 고쳐도 이 요약(과 [hasUnreadAlert])은 바뀌지 않습니다.
  HomeSummary({
    required List<ScheduleItem> schedules,
    required List<RecentBox> recentBoxes,
    required List<RecentAlert> recentAlerts,
  }) : schedules = List.unmodifiable(schedules),
       recentBoxes = List.unmodifiable(recentBoxes),
       recentAlerts = List.unmodifiable(recentAlerts);

  /// 이번 주와 그 뒤의 일정.
  final List<ScheduleItem> schedules;

  /// 최근에 연 순서대로 정렬된 보관함.
  final List<RecentBox> recentBoxes;

  /// 최근에 생긴 순서대로 정렬된 알림.
  final List<RecentAlert> recentAlerts;

  /// 읽지 않은 알림이 하나라도 있으면 true. 상단 종에 점을 찍습니다.
  bool get hasUnreadAlert => recentAlerts.any((alert) => !alert.isRead);
}
