import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_formats.dart';
import 'package:chagok_mobile/core/network/json_map.dart';
import 'package:chagok_mobile/features/calendar/data/calendar_repository.dart';
import 'package:chagok_mobile/features/calendar/data/deadline.dart';

/// 차곡 API 서버의 기한 목록 조회·기한 알림 API로 캘린더 기한을 다루는 [CalendarRepository].
///
/// 캘린더의 "등록" 표시는 서버의 기한 알림입니다. 등록하면 기한 알림을 기본값으로
/// 켜고(`POST /reminders`), 빼면 그 알림을 끕니다(`DELETE /reminders/{id}`).
class ApiCalendarRepository implements CalendarRepository {
  ApiCalendarRepository({required this._client});

  final ApiClient _client;

  /// 기한 ID별 기한 알림 ID. 알림을 끌 때 씁니다.
  final _reminderIds = <String, String>{};

  @override
  Future<List<Deadline>> fetchDeadlines(DateTime today) async {
    // 서버는 한 번에 1년까지 줍니다. 이번 달 달력도 그려야 하므로 이번 달 1일부터 받습니다.
    final from = DateTime(today.year, today.month);
    final to = DateTime(from.year + 1, from.month, from.day - 1);
    final json = await _client.get(
      '/deadlines',
      query: {'from': formatApiDate(from), 'to': formatApiDate(to)},
    );
    return [for (final item in json.maps('content')) _deadlineOf(item)];
  }

  @override
  Future<void> setRegistered({
    required String id,
    required bool isRegistered,
  }) async {
    if (isRegistered) {
      final json = await _client.post(
        '/reminders',
        body: {'deadlineId': apiId(id)},
      );
      _reminderIds[id] = json.id('reminderId');
      return;
    }
    final reminderId =
        _reminderIds[id] ?? (throw StateError('기한 $id에 등록된 알림을 모릅니다'));
    await _client.delete('/reminders/$reminderId');
    _reminderIds.remove(id);
  }

  Deadline _deadlineOf(JsonMap json) {
    // 매월 반복 기한은 회차마다 한 줄씩 오고 deadlineId가 같습니다. 알림은 기한마다
    // 하나라서, 같은 기한의 회차는 같은 id로 두어 등록 표시를 함께 바꿉니다.
    final id = json.id('deadlineId');
    final reminderId = json.idOrNull('reminderId');
    if (reminderId != null) _reminderIds[id] = reminderId;
    final box = json.mapOrNull('box');
    return Deadline(
      id: id,
      title:
          json.mapOrNull('document')?.stringOrNull('title') ??
          json.string('label'),
      dueDate: parseApiDate(json.string('date')),
      // 박스 이름 "집 · 임대"를 ["집", "임대"]로 나눠 꼬리표로 씁니다.
      tags: [
        for (final tag in (box?.stringOrNull('name') ?? '').split('·'))
          if (tag.trim().isNotEmpty) tag.trim(),
      ],
      isRegistered: reminderId != null,
    );
  }
}
