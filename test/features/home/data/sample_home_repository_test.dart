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

    // 서머타임이 있는 시간대(예: TZ=America/New_York)에서 돌리면 하루 어긋남을 잡습니다.
    test('서머타임이 끝나는 날 불러오면 예시 일정은 달력상 정확히 며칠 뒤·앞이다', () async {
      final summary = await SampleHomeRepository().fetchSummary(
        DateTime(2026, 11, 1, 10),
      );

      expect(summary.schedules.map((item) => item.date), [
        DateTime(2026, 11, 3),
        DateTime(2026, 11, 14),
        DateTime(2026, 10, 29),
      ]);
      expect(summary.recentBoxes.first.nextDueDate, DateTime(2026, 11, 14));
    });
  });
}
