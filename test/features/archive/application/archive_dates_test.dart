import 'package:chagok_mobile/features/archive/application/archive_dates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 11, 20, 23, 30);

  group('ArchiveDates.daysUntil', () {
    test('시각이 다른 두 날을 세면 날짜 차이만 돌려준다', () {
      expect(ArchiveDates.daysUntil(today, DateTime(2026, 11, 21, 0, 10)), 1);
    });

    test('지난 날짜면 음수를 돌려준다', () {
      expect(ArchiveDates.daysUntil(today, DateTime(2026, 11, 18)), -2);
    });
  });

  group('ArchiveDates.daysLeft', () {
    test('기한이 없으면 null을 돌려준다', () {
      expect(ArchiveDates.daysLeft(null, today), isNull);
    });

    test('기한이 오늘이면 0을 돌려준다', () {
      expect(ArchiveDates.daysLeft(DateTime(2026, 11, 20), today), 0);
    });

    test('기한이 지났으면 null을 돌려준다', () {
      expect(ArchiveDates.daysLeft(DateTime(2026, 11, 19), today), isNull);
    });
  });
}
