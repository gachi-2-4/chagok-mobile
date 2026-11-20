import 'package:chagok_mobile/features/archive/application/archive_box_item.dart';
import 'package:chagok_mobile/features/archive/application/archive_dates.dart';
import 'package:chagok_mobile/features/archive/application/archive_today_notifier.dart';
import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 내 보관함 목록(만든 순서대로).
final boxListProvider =
    AsyncNotifierProvider<BoxListNotifier, List<ArchiveBoxItem>>(
      BoxListNotifier.new,
    );

/// 보관함 목록을 불러오고 새 보관함을 만듭니다. 날짜가 바뀌면 다시 불러옵니다.
///
/// 새 보관함은 시트가 아니라 여기서 만듭니다. 이 Provider는 화면을 벗어나도
/// 남으므로, 만드는 사이 시트를 닫아도 끝까지 저장하고 목록을 다시 불러옵니다.
class BoxListNotifier extends AsyncNotifier<List<ArchiveBoxItem>> {
  @override
  Future<List<ArchiveBoxItem>> build() async {
    // 날짜가 바뀌면 D-n 기준이 달라지므로 다시 불러옵니다.
    final today = ref.watch(archiveTodayProvider);
    final boxes = await ref.watch(archiveRepositoryProvider).fetchBoxes(today);
    return [
      for (final box in boxes)
        ArchiveBoxItem(
          box: box,
          daysLeft: ArchiveDates.daysLeft(box.nextDueDate, today),
        ),
    ];
  }

  /// 보관함을 만들고 목록을 다시 불러옵니다.
  ///
  /// 저장소가 실패하면 그 예외를 그대로 던집니다. 목록은 바꾸지 않습니다.
  Future<void> create({
    required String name,
    required BoxColor color,
    required BoxIcon icon,
  }) async {
    await ref
        .read(archiveRepositoryProvider)
        .createBox(name: name, color: color, icon: icon);
    ref.invalidateSelf();
  }
}
