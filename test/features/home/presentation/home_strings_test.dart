import 'package:chagok_mobile/features/home/presentation/home_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 18, 10);

  group('HomeStrings.relativeTime', () {
    test('1분이 안 됐으면 "방금"이다', () {
      expect(
        HomeStrings.relativeTime(
          now.subtract(const Duration(seconds: 30)),
          now,
        ),
        '방금',
      );
    });

    test('1시간이 안 됐으면 분으로 센다', () {
      expect(
        HomeStrings.relativeTime(now.subtract(const Duration(minutes: 5)), now),
        '5분 전',
      );
    });

    test('같은 날이면 시간으로 센다', () {
      expect(
        HomeStrings.relativeTime(now.subtract(const Duration(hours: 2)), now),
        '2시간 전',
      );
    });

    test('전날이면 "어제"다', () {
      expect(HomeStrings.relativeTime(DateTime(2026, 11, 17, 23), now), '어제');
    });

    test('일주일이 넘으면 날짜로 보여 준다', () {
      expect(HomeStrings.relativeTime(DateTime(2026, 11, 3), now), '11.3');
    });
  });

  group('HomeStrings.boxDetail', () {
    test('오늘 연 보관함이면 "오늘 열람"으로 보여 준다', () {
      expect(
        HomeStrings.boxDetail(3, DateTime(2026, 11, 18, 8), now),
        '서류 3건 · 오늘 열람',
      );
    });

    test('어제 연 보관함이면 "어제 열람"으로 보여 준다', () {
      expect(
        HomeStrings.boxDetail(1, DateTime(2026, 11, 17), now),
        '서류 1건 · 어제 열람',
      );
    });
  });

  group('HomeStrings.dDay', () {
    test('남은 날이 0이면 D-DAY다', () {
      expect(HomeStrings.dDay(0), 'D-DAY');
      expect(HomeStrings.dDay(13), 'D-13');
    });
  });
}
