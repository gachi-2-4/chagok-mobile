import 'package:chagok_mobile/features/calendar/application/calendar_clock.dart';
import 'package:chagok_mobile/features/calendar/application/calendar_content.dart';
import 'package:chagok_mobile/features/calendar/application/calendar_day.dart';
import 'package:chagok_mobile/features/calendar/application/calendar_view.dart';
import 'package:chagok_mobile/features/calendar/application/calendar_view_notifier.dart';
import 'package:chagok_mobile/features/calendar/application/deadline_list_notifier.dart';
import 'package:chagok_mobile/features/calendar/data/calendar_repository.dart';
import 'package:chagok_mobile/features/calendar/data/deadline.dart';
import 'package:chagok_mobile/features/home/application/home_clock.dart';
import 'package:chagok_mobile/features/home/application/home_today_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_calendar_repository.dart';

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
  final today = DateTime(2026, 11, 12);
  final deadlines = [
    _deadline('past', DateTime(2026, 11, 3)),
    _deadline('soon', DateTime(2026, 11, 20)),
    _deadline('later', DateTime(2026, 12, 28), isRegistered: true),
  ];

  group('CalendarContent.of', () {
    test('날짜를 고르지 않았으면 오늘 이후 기한을 남은 날과 함께 담는다', () {
      final content = CalendarContent.of(
        deadlines: deadlines,
        view: CalendarView(month: DateTime(2026, 11)),
        today: today,
      );

      expect(content.items.map((item) => (item.deadline.id, item.daysLeft)), [
        ('soon', 8),
        ('later', 46),
      ]);
    });

    test('지난 날짜를 고르면 그날 기한을 음수 남은 날과 함께 담는다', () {
      final content = CalendarContent.of(
        deadlines: deadlines,
        view: CalendarView(
          month: DateTime(2026, 11),
          selectedDate: DateTime(2026, 11, 3),
        ),
        today: today,
      );

      expect(content.items.single.daysLeft, -9);
      expect(content.selectedDate, DateTime(2026, 11, 3));
    });

    test('다른 달을 보면 그달 칸에만 기한 표시를 하고 주 단위로 나눈다', () {
      final content = CalendarContent.of(
        deadlines: deadlines,
        view: CalendarView(month: DateTime(2026, 12)),
        today: today,
      );

      final days = content.weeks
          .expand((week) => week)
          .whereType<CalendarDay>();
      expect(content.weeks.every((week) => week.length == 7), isTrue);
      expect(days.firstWhere((day) => day.date.day == 28).isRegistered, isTrue);
      expect(days.where((day) => day.isRegistered != null), hasLength(1));
      expect(days.any((day) => day.isToday), isFalse);
    });

    test('이번 달을 보면 오늘과 고른 날짜 칸을 표시한다', () {
      final content = CalendarContent.of(
        deadlines: deadlines,
        view: CalendarView(
          month: DateTime(2026, 11),
          selectedDate: DateTime(2026, 11, 20),
        ),
        today: today,
      );

      final days = content.weeks
          .expand((week) => week)
          .whereType<CalendarDay>();
      expect(
        days.singleWhere((day) => day.isToday).date,
        DateTime(2026, 11, 12),
      );
      expect(
        days.singleWhere((day) => day.isSelected).date,
        DateTime(2026, 11, 20),
      );
      expect(
        days.firstWhere((day) => day.date.day == 20).isRegistered,
        isFalse,
      );
    });
  });

  group('calendarContentProvider', () {
    test('날짜를 고르면 기한 목록을 그날 것으로 다시 계산한다', () async {
      final now = DateTime(2026, 11, 12, 9);
      final container = ProviderContainer(
        overrides: [
          calendarRepositoryProvider.overrideWithValue(
            FakeCalendarRepository(deadlines: deadlines),
          ),
          calendarClockProvider.overrideWithValue(() => now),
          homeClockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);
      container.listen(calendarContentProvider, (_, _) {});
      await container.read(deadlineListProvider.future);

      container
          .read(calendarViewProvider.notifier)
          .select(DateTime(2026, 11, 20));

      final content = container.read(calendarContentProvider).value;
      expect(content?.items.map((item) => item.deadline.id), ['soon']);
      expect(content?.today, DateTime(2026, 11, 12));
    });

    test('홈의 기준 날짜가 다음 날로 바뀌면 오늘과 남은 날을 다시 계산한다', () async {
      var now = DateTime(2026, 11, 12, 23, 59);
      final container = ProviderContainer(
        overrides: [
          calendarRepositoryProvider.overrideWithValue(
            FakeCalendarRepository(deadlines: deadlines),
          ),
          calendarClockProvider.overrideWithValue(() => now),
          homeClockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);
      container.listen(calendarContentProvider, (_, _) {});
      await container.read(deadlineListProvider.future);

      now = DateTime(2026, 11, 13, 0, 1);
      container.read(homeTodayProvider.notifier).refresh();

      final content = container.read(calendarContentProvider).value;
      expect(content?.today, DateTime(2026, 11, 13));
      expect(content?.items.first.daysLeft, 7);
    });
  });
}
