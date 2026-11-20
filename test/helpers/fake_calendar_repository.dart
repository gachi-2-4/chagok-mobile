import 'dart:async';

import 'package:chagok_mobile/features/calendar/data/calendar_repository.dart';
import 'package:chagok_mobile/features/calendar/data/deadline.dart';

/// 정해 둔 기한을 돌려주고, 등록 요청을 기록하는 가짜 [CalendarRepository].
class FakeCalendarRepository implements CalendarRepository {
  FakeCalendarRepository({List<Deadline>? deadlines})
    : deadlines = deadlines ?? [];

  /// [fetchDeadlines]가 돌려줄 기한.
  List<Deadline> deadlines;

  /// 값을 넣으면 [fetchDeadlines]가 이 예외를 던집니다.
  Exception? fetchError;

  /// 값을 넣으면 [setRegistered]가 이 예외를 던집니다.
  Exception? saveError;

  /// 값을 넣으면 [setRegistered]가 이것이 끝날 때까지 기다립니다.
  Completer<void>? saveGate;

  /// [setRegistered]로 받은 (id, 등록 여부).
  final saved = <(String, bool)>[];

  @override
  Future<List<Deadline>> fetchDeadlines(DateTime today) async {
    if (fetchError case final error?) throw error;
    return deadlines;
  }

  @override
  Future<void> setRegistered({
    required String id,
    required bool isRegistered,
  }) async {
    await saveGate?.future;
    if (saveError case final error?) throw error;
    saved.add((id, isRegistered));
  }
}
