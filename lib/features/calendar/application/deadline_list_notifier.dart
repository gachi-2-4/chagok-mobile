import 'package:chagok_mobile/features/calendar/application/calendar_clock.dart';
import 'package:chagok_mobile/features/calendar/data/calendar_repository.dart';
import 'package:chagok_mobile/features/calendar/data/deadline.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 보관한 서류의 기한 목록(날짜순).
final deadlineListProvider =
    AsyncNotifierProvider<DeadlineListNotifier, List<Deadline>>(
      DeadlineListNotifier.new,
    );

/// 기한을 불러오고, 기기 캘린더 등록 여부를 바꿉니다.
class DeadlineListNotifier extends AsyncNotifier<List<Deadline>> {
  @override
  Future<List<Deadline>> build() async {
    final today = ref.watch(calendarClockProvider)();
    final deadlines = await ref
        .watch(calendarRepositoryProvider)
        .fetchDeadlines(today);
    return [...deadlines]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// 기한 [id]를 기기 캘린더에 등록하거나 뺍니다. 바꿨으면 true.
  ///
  /// 저장하지 못하면 목록은 그대로 두고 false를 돌려줍니다. 화면은 안내만 띄우고
  /// 목록은 계속 보여 줘야 하므로 에러 상태로 바꾸지 않습니다.
  Future<bool> setRegistered(String id, {required bool isRegistered}) async {
    if (state.value == null) return false;
    try {
      await ref
          .read(calendarRepositoryProvider)
          .setRegistered(id: id, isRegistered: isRegistered);
    } catch (error, stackTrace) {
      debugPrint('기한 등록을 바꾸지 못했습니다: $error\n$stackTrace');
      return false;
    }
    if (!ref.mounted) return true;
    // 저장하는 사이 목록을 다시 불러왔을 수 있으므로 지금 목록에 반영합니다.
    final latest = state.value;
    if (latest != null) {
      state = AsyncData([
        for (final deadline in latest)
          deadline.id == id
              ? deadline.copyWith(isRegistered: isRegistered)
              : deadline,
      ]);
    }
    return true;
  }
}
