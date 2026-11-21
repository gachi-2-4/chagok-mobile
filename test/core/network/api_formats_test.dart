import 'package:chagok_mobile/core/network/api_formats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatApiDate', () {
    test('날짜를 넘기면 YYYY-MM-DD로 바꾼다', () {
      expect(formatApiDate(DateTime(2026, 3, 5, 14, 30)), '2026-03-05');
    });
  });

  group('parseApiDate', () {
    test('YYYY-MM-DD를 넘기면 그날 0시로 바꾼다', () {
      expect(parseApiDate('2026-11-25'), DateTime(2026, 11, 25));
    });

    test('형식이 다르면 FormatException을 던진다', () {
      expect(() => parseApiDate('2026/11/25'), throwsFormatException);
    });
  });

  group('parseApiDateTime', () {
    test('시간대가 붙은 일시를 넘기면 같은 순간의 기기 시각으로 바꾼다', () {
      final parsed = parseApiDateTime('2026-11-24T09:00:00+09:00');

      expect(parsed.toUtc(), DateTime.utc(2026, 11, 24));
    });
  });

  group('formatApiTime', () {
    test('자정부터 지난 분을 넘기면 HH:mm으로 바꾼다', () {
      expect(formatApiTime(9 * 60 + 5), '09:05');
    });
  });

  group('parseApiTime', () {
    test('HH:mm을 넘기면 자정부터 지난 분으로 바꾼다', () {
      expect(parseApiTime('21:30'), 21 * 60 + 30);
    });

    test('범위를 벗어나면 FormatException을 던진다', () {
      expect(() => parseApiTime('24:00'), throwsFormatException);
    });
  });
}
