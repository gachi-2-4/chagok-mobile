import 'dart:async';

import 'package:chagok_mobile/features/home/data/home_repository.dart';
import 'package:chagok_mobile/features/home/data/home_summary.dart';
import 'package:chagok_mobile/features/home/data/recent_alert.dart';
import 'package:chagok_mobile/features/home/data/schedule_item.dart';

/// 요청한 시각을 기록하고, 정해 둔 홈 내용을 돌려주는 [HomeRepository].
class FakeHomeRepository implements HomeRepository {
  final requestedTimes = <DateTime>[];

  /// 돌려줄 일정 하나의 제목.
  String title = '처음';

  /// 돌려줄 최근 알림.
  List<RecentAlert> alerts = const [];

  /// 값을 넣으면 [fetchSummary]가 이것이 끝날 때까지 기다립니다.
  Completer<void>? gate;

  /// 값을 넣으면 [fetchSummary]가 이 예외를 던집니다.
  Exception? error;

  @override
  Future<HomeSummary> fetchSummary(DateTime now) async {
    requestedTimes.add(now);
    await gate?.future;
    if (error case final error?) throw error;
    return HomeSummary(
      schedules: [ScheduleItem(date: now, title: title)],
      recentBoxes: const [],
      recentAlerts: alerts,
    );
  }
}
