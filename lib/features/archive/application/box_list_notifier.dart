import 'package:chagok_mobile/features/archive/application/archive_box_item.dart';
import 'package:chagok_mobile/features/archive/application/archive_clock.dart';
import 'package:chagok_mobile/features/archive/application/archive_dates.dart';
import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 내 보관함 목록(만든 순서대로).
final boxListProvider =
    AsyncNotifierProvider<BoxListNotifier, List<ArchiveBoxItem>>(
      BoxListNotifier.new,
    );

/// 보관함 목록을 불러옵니다. 보관함을 새로 만들면 다시 불러옵니다.
class BoxListNotifier extends AsyncNotifier<List<ArchiveBoxItem>> {
  @override
  Future<List<ArchiveBoxItem>> build() async {
    final now = ref.watch(archiveClockProvider)();
    final boxes = await ref.watch(archiveRepositoryProvider).fetchBoxes(now);
    return [
      for (final box in boxes)
        ArchiveBoxItem(
          box: box,
          daysLeft: ArchiveDates.daysLeft(box.nextDueDate, now),
        ),
    ];
  }
}
