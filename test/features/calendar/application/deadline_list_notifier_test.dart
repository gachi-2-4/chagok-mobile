import 'dart:async';

import 'package:chagok_mobile/features/calendar/application/calendar_clock.dart';
import 'package:chagok_mobile/features/calendar/application/deadline_list_notifier.dart';
import 'package:chagok_mobile/features/calendar/data/calendar_repository.dart';
import 'package:chagok_mobile/features/calendar/data/deadline.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_calendar_repository.dart';

void main() {
  late FakeCalendarRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeCalendarRepository(
      deadlines: [
        Deadline(
          id: 'later',
          title: '늦은 기한',
          dueDate: DateTime(2026, 12, 28),
          tags: const ['집'],
        ),
        Deadline(
          id: 'soon',
          title: '이른 기한',
          dueDate: DateTime(2026, 11, 20),
          tags: const ['병원'],
        ),
      ],
    );
    container = ProviderContainer(
      overrides: [
        calendarRepositoryProvider.overrideWithValue(repository),
        calendarClockProvider.overrideWithValue(() => DateTime(2026, 11, 12)),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
  });

  group('DeadlineListNotifier', () {
    test('불러오면 기한을 날짜순으로 돌려준다', () async {
      final deadlines = await container.read(deadlineListProvider.future);

      expect(deadlines.map((deadline) => deadline.id), ['soon', 'later']);
    });

    test('기한을 등록하면 저장하고 목록에도 등록됨으로 바꾼다', () async {
      await container.read(deadlineListProvider.future);

      final isSaved = await container
          .read(deadlineListProvider.notifier)
          .setRegistered('soon', isRegistered: true);

      expect(isSaved, isTrue);
      expect(repository.saved, [('soon', true)]);
      final soon = container.read(deadlineListProvider).value?.first;
      expect(soon?.isRegistered, isTrue);
    });

    test('저장하지 못하면 false를 돌려주고 목록은 그대로 둔다', () async {
      repository.saveError = Exception('network');
      await container.read(deadlineListProvider.future);

      final isSaved = await container
          .read(deadlineListProvider.notifier)
          .setRegistered('soon', isRegistered: true);

      expect(isSaved, isFalse);
      final state = container.read(deadlineListProvider);
      expect(state.hasError, isFalse);
      expect(state.value?.first.isRegistered, isFalse);
    });

    test('불러오지 못하면 에러 상태가 된다', () async {
      repository.fetchError = Exception('network');
      container.listen(deadlineListProvider, (_, _) {});

      await expectLater(
        container.read(deadlineListProvider.future),
        throwsException,
      );

      expect(container.read(deadlineListProvider).hasError, isTrue);
    });

    test('저장하는 사이 목록을 다시 불러오면 다시 불러온 목록에 등록을 반영한다', () async {
      container.listen(deadlineListProvider, (_, _) {});
      await container.read(deadlineListProvider.future);
      repository.saveGate = Completer<void>();
      final saving = container
          .read(deadlineListProvider.notifier)
          .setRegistered('later', isRegistered: true);

      repository.deadlines = [
        ...repository.deadlines,
        Deadline(
          id: 'new',
          title: '새 기한',
          dueDate: DateTime(2026, 11, 30),
          tags: const ['세금'],
        ),
      ];
      container.invalidate(deadlineListProvider);
      await container.read(deadlineListProvider.future);
      repository.saveGate?.complete();
      await saving;

      final deadlines = container.read(deadlineListProvider).value ?? [];
      expect(deadlines.map((deadline) => deadline.id), [
        'soon',
        'new',
        'later',
      ]);
      expect(deadlines.last.isRegistered, isTrue);
    });
  });
}
