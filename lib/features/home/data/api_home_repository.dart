import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_formats.dart';
import 'package:chagok_mobile/core/network/json_map.dart';
import 'package:chagok_mobile/features/home/data/box_category.dart';
import 'package:chagok_mobile/features/home/data/home_repository.dart';
import 'package:chagok_mobile/features/home/data/home_summary.dart';
import 'package:chagok_mobile/features/home/data/recent_alert.dart';
import 'package:chagok_mobile/features/home/data/recent_box.dart';
import 'package:chagok_mobile/features/home/data/schedule_item.dart';

/// 차곡 API 서버의 메인 화면 조회(`GET /home`)로 홈 화면 내용을 가져오는 [HomeRepository].
///
/// 날짜 기준은 서버의 오늘(KST)이라 [fetchSummary]의 `now`는 쓰지 않습니다.
class ApiHomeRepository implements HomeRepository {
  ApiHomeRepository({required this._client});

  final ApiClient _client;

  @override
  Future<HomeSummary> fetchSummary(DateTime now) async {
    final json = await _client.get('/home');
    return HomeSummary(
      schedules: _schedulesOf(json),
      recentBoxes: [for (final box in json.maps('recentBoxes')) _boxOf(box)],
      recentAlerts: [
        for (final alert in json.maps('recentNotifications')) _alertOf(alert),
      ],
    );
  }

  /// 이번 주 일정과, 이번 주 밖이면 가장 가까운 다음 기한까지.
  List<ScheduleItem> _schedulesOf(JsonMap json) {
    final schedules = <ScheduleItem>[];
    final seen = <String>{};
    void add(String deadlineId, String date, String title) {
      // 매월 반복 기한은 회차마다 날짜가 달라, 기한 ID와 날짜를 함께 봅니다.
      if (seen.add('$deadlineId@$date')) {
        schedules.add(ScheduleItem(date: parseApiDate(date), title: title));
      }
    }

    for (final day in json.maps('weekCalendar')) {
      for (final deadline in day.maps('deadlines')) {
        add(
          deadline.id('deadlineId'),
          day.string('date'),
          deadline.string('label'),
        );
      }
    }
    if (json.mapOrNull('nextDeadline') case final next?) {
      add(next.id('deadlineId'), next.string('date'), next.string('label'));
    }
    return schedules..sort((a, b) => a.date.compareTo(b.date));
  }

  RecentBox _boxOf(JsonMap json) {
    return RecentBox(
      id: json.id('boxId'),
      name: json.string('name'),
      category: switch (json.stringOrNull('icon')) {
        'HOME' => BoxCategory.housing,
        'WIFI' => BoxCategory.telecom,
        'CAR' => BoxCategory.car,
        _ => BoxCategory.other,
      },
      documentCount: json.integerOrNull('documentCount') ?? 0,
      lastOpenedAt: parseApiDateTime(json.string('lastOpenedAt')),
      nextDueDate: switch (json.mapOrNull('nearestDeadline')) {
        final deadline? => parseApiDate(deadline.string('date')),
        null => null,
      },
    );
  }

  RecentAlert _alertOf(JsonMap json) {
    return RecentAlert(
      id: json.id('notificationId'),
      title: json.string('title'),
      // 연결 서류가 지워졌으면 document가 null입니다.
      boxName: json.mapOrNull('document')?.stringOrNull('boxName') ?? '',
      createdAt: parseApiDateTime(json.string('sentAt')),
      isRead: json.boolean('isRead'),
    );
  }
}
