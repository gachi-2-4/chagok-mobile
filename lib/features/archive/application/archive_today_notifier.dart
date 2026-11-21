import 'dart:async';

import 'package:chagok_mobile/features/archive/application/archive_clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 보관함 D-n의 기준 날짜(오늘 0시). 자정이 지나거나 앱으로 돌아오면 바뀝니다.
final archiveTodayProvider = NotifierProvider<ArchiveTodayNotifier, DateTime>(
  ArchiveTodayNotifier.new,
);

/// 오늘 날짜를 들고 있다가, 자정이 지나면 다음 날로 바꿉니다.
///
/// 시각을 돌려주는 함수만 watch하면 시간이 흘러도 다시 계산되지 않아 D-n이
/// 어제 기준으로 남으므로, 다음 자정에 맞춰 [Timer]를 걸어 둡니다.
class ArchiveTodayNotifier extends Notifier<DateTime> {
  Timer? _midnightTimer;

  @override
  DateTime build() {
    ref.onDispose(() => _midnightTimer?.cancel());
    final now = ref.watch(archiveClockProvider)();
    _scheduleMidnight(now);
    return _dateOf(now);
  }

  /// 날짜가 바뀌었으면 새 날짜로 바꿉니다. 앱으로 돌아왔을 때도 부릅니다.
  void refresh() {
    final now = ref.read(archiveClockProvider)();
    final today = _dateOf(now);
    if (today != state) state = today;
    _scheduleMidnight(now);
  }

  void _scheduleMidnight(DateTime now) {
    _midnightTimer?.cancel();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(nextMidnight.difference(now), refresh);
  }

  static DateTime _dateOf(DateTime time) =>
      DateTime(time.year, time.month, time.day);
}
