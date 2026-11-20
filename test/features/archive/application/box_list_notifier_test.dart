import 'package:chagok_mobile/features/archive/application/archive_clock.dart';
import 'package:chagok_mobile/features/archive/application/archive_today_notifier.dart';
import 'package:chagok_mobile/features/archive/application/box_list_notifier.dart';
import 'package:chagok_mobile/features/archive/data/archive_box.dart';
import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_archive_repository.dart';

void main() {
  late FakeArchiveRepository repository;
  late ProviderContainer container;
  late DateTime now;

  ArchiveBox box(String id, {DateTime? nextDueDate}) => ArchiveBox(
    id: id,
    name: id,
    color: BoxColor.peach,
    icon: BoxIcon.home,
    documentCount: 1,
    nextDueDate: nextDueDate,
  );

  setUp(() {
    now = DateTime(2026, 11, 20, 9);
    repository = FakeArchiveRepository(
      boxes: [
        box('soon', nextDueDate: DateTime(2026, 12, 3)),
        box('none'),
        box('past', nextDueDate: DateTime(2026, 11, 2)),
      ],
    );
    container = ProviderContainer(
      overrides: [
        archiveRepositoryProvider.overrideWithValue(repository),
        archiveClockProvider.overrideWithValue(() => now),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
  });

  group('BoxListNotifier', () {
    test('불러오면 보관함을 저장소 순서대로 돌려준다', () async {
      final items = await container.read(boxListProvider.future);

      expect(items.map((item) => item.box.id), ['soon', 'none', 'past']);
    });

    test('불러오면 가장 가까운 기한까지 남은 날을 센다', () async {
      final items = await container.read(boxListProvider.future);

      expect(items.map((item) => item.daysLeft), [13, null, null]);
    });

    test('날짜가 바뀌면 D-n을 새 날짜 기준으로 다시 센다', () async {
      final subscription = container.listen(boxListProvider, (_, _) {});
      addTearDown(subscription.close);
      await container.read(boxListProvider.future);

      now = DateTime(2026, 11, 21, 0, 1);
      container.read(archiveTodayProvider.notifier).refresh();

      final items = await container.read(boxListProvider.future);
      expect(items.first.daysLeft, 12);
    });

    test('저장소가 실패하면 에러 상태가 된다', () async {
      repository.fetchError = Exception('네트워크 오류');

      await expectLater(
        container.read(boxListProvider.future),
        throwsA(isA<Exception>()),
      );
      expect(container.read(boxListProvider).hasError, isTrue);
    });
  });
}
