import 'package:chagok_mobile/features/calendar/application/calendar_clock.dart';
import 'package:chagok_mobile/features/calendar/application/calendar_view_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        calendarClockProvider.overrideWithValue(
          () => DateTime(2026, 11, 12, 9),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  CalendarViewNotifier notifier() =>
      container.read(calendarViewProvider.notifier);

  group('CalendarViewNotifier', () {
    test('처음 읽으면 이번 달을 고른 날짜 없이 보여 준다', () {
      final view = container.read(calendarViewProvider);

      expect(view.month, DateTime(2026, 11));
      expect(view.selectedDate, isNull);
    });

    test('날짜를 고르면 그날 0시를 고른 날짜로 둔다', () {
      notifier().select(DateTime(2026, 11, 25, 15));

      expect(
        container.read(calendarViewProvider).selectedDate,
        DateTime(2026, 11, 25),
      );
    });

    test('고른 날짜를 다시 누르면 고르기를 푼다', () {
      notifier()
        ..select(DateTime(2026, 11, 25))
        ..select(DateTime(2026, 11, 25));

      expect(container.read(calendarViewProvider).selectedDate, isNull);
    });

    test('전체 보기를 누르면 고른 날짜를 지운다', () {
      notifier()
        ..select(DateTime(2026, 11, 25))
        ..clearSelection();

      expect(container.read(calendarViewProvider).selectedDate, isNull);
    });

    test('12월에서 다음 달로 넘기면 다음 해 1월을 보여 주고 고른 날짜를 지운다', () {
      notifier()
        ..showMonth(year: 2026, month: 12)
        ..select(DateTime(2026, 12, 3))
        ..showNextMonth();

      final view = container.read(calendarViewProvider);
      expect(view.month, DateTime(2027));
      expect(view.selectedDate, isNull);
    });

    test('1월에서 이전 달로 넘기면 전해 12월을 보여 준다', () {
      notifier()
        ..showMonth(year: 2027, month: 1)
        ..showPreviousMonth();

      expect(container.read(calendarViewProvider).month, DateTime(2026, 12));
    });
  });
}
