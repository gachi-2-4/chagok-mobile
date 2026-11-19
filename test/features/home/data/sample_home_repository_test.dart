import 'package:chagok_mobile/features/home/data/sample_home_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SampleHomeRepository', () {
    test('홈 내용을 불러오면 알림과 보관함을 최근 순서로 돌려준다', () async {
      final now = DateTime(2026, 11, 18, 10);

      final summary = await SampleHomeRepository().fetchSummary(now);

      final alertTimes = summary.recentAlerts.map((alert) => alert.createdAt);
      expect(
        alertTimes,
        orderedEquals(alertTimes.toList()..sort((a, b) => b.compareTo(a))),
      );
      final boxTimes = summary.recentBoxes.map((box) => box.lastOpenedAt);
      expect(
        boxTimes,
        orderedEquals(boxTimes.toList()..sort((a, b) => b.compareTo(a))),
      );
    });
  });
}
