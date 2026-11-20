import 'package:chagok_mobile/features/home/data/home_summary.dart';
import 'package:chagok_mobile/features/home/data/recent_alert.dart';
import 'package:chagok_mobile/features/home/data/schedule_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeSummary 목록', () {
    test('생성자에 넘긴 목록을 나중에 바꾸면 요약은 그대로다', () {
      final alerts = <RecentAlert>[];
      final summary = HomeSummary(
        schedules: [],
        recentBoxes: [],
        recentAlerts: alerts,
      );

      alerts.add(
        RecentAlert(
          id: 'id',
          title: '알림',
          boxName: '집',
          createdAt: DateTime(2026),
          isRead: false,
        ),
      );

      expect(summary.recentAlerts, isEmpty);
      expect(summary.hasUnreadAlert, isFalse);
    });

    test('요약의 목록에 항목을 더하려 하면 UnsupportedError가 난다', () {
      final summary = HomeSummary(
        schedules: [],
        recentBoxes: [],
        recentAlerts: [],
      );

      expect(() => summary.schedules.add(_schedule), throwsUnsupportedError);
    });
  });

  group('HomeSummary.hasUnreadAlert', () {
    RecentAlert alert({required bool isRead}) => RecentAlert(
      id: 'id',
      title: '알림',
      boxName: '집',
      createdAt: DateTime(2026),
      isRead: isRead,
    );

    test('읽지 않은 알림이 있으면 true다', () {
      final summary = HomeSummary(
        schedules: const [],
        recentBoxes: const [],
        recentAlerts: [alert(isRead: true), alert(isRead: false)],
      );

      expect(summary.hasUnreadAlert, isTrue);
    });

    test('알림을 모두 읽었으면 false다', () {
      final summary = HomeSummary(
        schedules: const [],
        recentBoxes: const [],
        recentAlerts: [alert(isRead: true)],
      );

      expect(summary.hasUnreadAlert, isFalse);
    });
  });
}

final _schedule = ScheduleItem(date: DateTime(2026), title: '일정');
