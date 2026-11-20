import 'package:chagok_mobile/features/calendar/data/sample_calendar_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SampleCalendarRepository', () {
    test('불러오면 오늘 기준 달력상 정확히 며칠 뒤 기한을 돌려준다', () async {
      final deadlines = await SampleCalendarRepository().fetchDeadlines(
        DateTime(2026, 10, 30, 10),
      );

      expect(deadlines.first.dueDate, DateTime(2026, 11, 7));
    });

    test('기한을 등록하면 다시 불러올 때 등록됨으로 돌려준다', () async {
      final repository = SampleCalendarRepository();
      final today = DateTime(2026, 11, 12);
      final first = (await repository.fetchDeadlines(today)).first;

      await repository.setRegistered(id: first.id, isRegistered: true);
      final reloaded = await repository.fetchDeadlines(today);

      expect(
        reloaded.firstWhere((deadline) => deadline.id == first.id).isRegistered,
        isTrue,
      );
    });

    test('등록을 빼면 다시 불러올 때 미등록으로 돌려준다', () async {
      final repository = SampleCalendarRepository();
      final today = DateTime(2026, 11, 12);
      final registered = (await repository.fetchDeadlines(today))
          .firstWhere((deadline) => deadline.isRegistered);

      await repository.setRegistered(id: registered.id, isRegistered: false);
      final reloaded = await repository.fetchDeadlines(today);

      expect(
        reloaded
            .firstWhere((deadline) => deadline.id == registered.id)
            .isRegistered,
        isFalse,
      );
    });
  });
}
