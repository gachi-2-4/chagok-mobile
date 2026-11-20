import 'package:chagok_mobile/features/home/application/schedule_calendar.dart';
import 'package:chagok_mobile/features/home/data/schedule_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScheduleCalendar.weekOf', () {
    // 서머타임이 있는 시간대(예: TZ=America/New_York)에서 돌리면 하루 어긋남을 잡습니다.
    test('서머타임이 시작되는 주를 넘기면 일요일 0시부터 돌려준다', () {
      final week = ScheduleCalendar.weekOf(DateTime(2026, 3, 11));

      expect(week.first, DateTime(2026, 3, 8));
    });

    test('수요일을 넘기면 그 주를 일요일부터 토요일까지 돌려준다', () {
      final week = ScheduleCalendar.weekOf(DateTime(2026, 11, 18, 15, 30));

      expect(week.first, DateTime(2026, 11, 15));
      expect(week.last, DateTime(2026, 11, 21));
      expect(week, hasLength(7));
    });

    test('일요일이면 그날부터 시작한다', () {
      final week = ScheduleCalendar.weekOf(DateTime(2026, 11, 15));

      expect(week.first, DateTime(2026, 11, 15));
    });

    test('주 중간에 달이 바뀌면 다음 달 날짜로 이어서 센다', () {
      final week = ScheduleCalendar.weekOf(DateTime(2026, 12, 2));

      expect(week.first, DateTime(2026, 11, 29));
      expect(week.last, DateTime(2026, 12, 5));
    });
  });

  group('ScheduleCalendar.daysUntil', () {
    test('시각이 달라도 같은 날짜면 날짜 차이만 센다', () {
      final days = ScheduleCalendar.daysUntil(
        DateTime(2026, 11, 18, 23, 59),
        DateTime(2026, 11, 20, 1),
      );

      expect(days, 2);
    });

    test('지난 날이면 음수를 돌려준다', () {
      expect(
        ScheduleCalendar.daysUntil(
          DateTime(2026, 11, 18),
          DateTime(2026, 11, 15),
        ),
        -3,
      );
    });
  });

  group('ScheduleCalendar.nextSchedule', () {
    final schedules = [
      ScheduleItem(date: DateTime(2026, 11, 30), title: '관리비'),
      ScheduleItem(date: DateTime(2026, 11, 15), title: '지난 일정'),
      ScheduleItem(date: DateTime(2026, 11, 20), title: '통신 요금'),
    ];

    test('지난 일정과 앞으로 일정이 섞여 있으면 오늘 이후 가장 가까운 일정을 돌려준다', () {
      final next = ScheduleCalendar.nextSchedule(
        schedules,
        DateTime(2026, 11, 18),
      );

      expect(next?.title, '통신 요금');
    });

    test('오늘 일정이 있으면 그 일정도 포함한다', () {
      final next = ScheduleCalendar.nextSchedule(
        schedules,
        DateTime(2026, 11, 20, 18),
      );

      expect(next?.title, '통신 요금');
    });

    test('남은 일정이 없으면 null을 돌려준다', () {
      expect(
        ScheduleCalendar.nextSchedule(schedules, DateTime(2026, 12, 2)),
        isNull,
      );
    });
  });

  group('ScheduleCalendar.hasScheduleOn', () {
    test('그날 일정이 있으면 true를 돌려준다', () {
      final schedules = [
        ScheduleItem(date: DateTime(2026, 11, 20), title: '통신 요금'),
      ];

      expect(
        ScheduleCalendar.hasScheduleOn(schedules, DateTime(2026, 11, 20)),
        isTrue,
      );
      expect(
        ScheduleCalendar.hasScheduleOn(schedules, DateTime(2026, 11, 21)),
        isFalse,
      );
    });
  });
}
