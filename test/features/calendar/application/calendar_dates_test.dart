import 'package:chagok_mobile/features/calendar/application/calendar_dates.dart';
import 'package:chagok_mobile/features/calendar/data/deadline.dart';
import 'package:flutter_test/flutter_test.dart';

Deadline _deadline(String id, DateTime dueDate, {bool isRegistered = false}) {
  return Deadline(
    id: id,
    title: id,
    dueDate: dueDate,
    tags: const ['집'],
    isRegistered: isRegistered,
  );
}

void main() {
  group('CalendarDates.cellsOf', () {
    test('2026년 11월을 넣으면 일요일에 시작해 빈칸 없이 1일부터 30일까지 채운다', () {
      final cells = CalendarDates.cellsOf(DateTime(2026, 11));

      expect(cells.first, DateTime(2026, 11));
      expect(cells.whereType<DateTime>().last, DateTime(2026, 11, 30));
      expect(cells.length % CalendarDates.daysInWeek, 0);
    });

    test('수요일에 시작하는 달을 넣으면 앞에 빈칸 3개를 둔다', () {
      final cells = CalendarDates.cellsOf(DateTime(2026, 4));

      expect(cells.take(3), everyElement(isNull));
      expect(cells[3], DateTime(2026, 4));
    });
  });

  group('CalendarDates.selectableYears', () {
    test('오늘을 넣으면 지난해부터 2년 뒤까지 돌려준다', () {
      expect(CalendarDates.selectableYears(DateTime(2026, 11, 12)), [
        2025,
        2026,
        2027,
        2028,
      ]);
    });
  });

  group('CalendarDates.selectableMonths', () {
    test('읽으면 1월부터 12월까지 돌려준다', () {
      expect(CalendarDates.selectableMonths, [
        for (var month = 1; month <= 12; month++) month,
      ]);
    });
  });

  group('CalendarDates.daysUntil', () {
    test('8일 뒤 날짜를 넣으면 8을 돌려준다', () {
      expect(
        CalendarDates.daysUntil(
          DateTime(2026, 11, 12, 18),
          DateTime(2026, 11, 20),
        ),
        8,
      );
    });

    test('지난 날짜를 넣으면 음수를 돌려준다', () {
      expect(
        CalendarDates.daysUntil(DateTime(2026, 11, 12), DateTime(2026, 11, 10)),
        -2,
      );
    });

    test('서머타임이 끝나는 날을 사이에 두면 달력상 날 수를 돌려준다', () {
      expect(
        CalendarDates.daysUntil(DateTime(2026, 10, 31), DateTime(2026, 11, 2)),
        2,
      );
    });
  });

  group('CalendarDates.upcoming', () {
    test('지난 기한과 오늘 기한이 섞여 있으면 지난 것만 빼고 날짜순으로 돌려준다', () {
      final today = DateTime(2026, 11, 12);
      final deadlines = [
        _deadline('later', DateTime(2026, 12)),
        _deadline('past', DateTime(2026, 11, 11)),
        _deadline('today', DateTime(2026, 11, 12)),
      ];

      final upcoming = CalendarDates.upcoming(deadlines, today);

      expect(upcoming.map((deadline) => deadline.id), ['today', 'later']);
    });
  });

  group('CalendarDates.on', () {
    test('날짜를 넣으면 그날 기한만 돌려준다', () {
      final deadlines = [
        _deadline('a', DateTime(2026, 11, 25)),
        _deadline('b', DateTime(2026, 11, 26)),
      ];

      final onDate = CalendarDates.on(deadlines, DateTime(2026, 11, 25, 9));

      expect(onDate.map((deadline) => deadline.id), ['a']);
    });
  });

  group('CalendarDates.markedDaysOf', () {
    test('여러 달 기한을 넣으면 그달 기한이 있는 날과 모두 등록했는지만 돌려준다', () {
      final deadlines = [
        _deadline('a', DateTime(2026, 11, 20), isRegistered: true),
        _deadline('b', DateTime(2026, 11, 25), isRegistered: true),
        _deadline('c', DateTime(2026, 11, 25)),
        _deadline('d', DateTime(2026, 12, 28), isRegistered: true),
      ];

      final marks = CalendarDates.markedDaysOf(deadlines, DateTime(2026, 11));

      expect(marks, {20: true, 25: false});
    });
  });
}
