import 'package:chagok_mobile/features/home/data/home_summary.dart';
import 'package:chagok_mobile/features/home/data/recent_alert.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
