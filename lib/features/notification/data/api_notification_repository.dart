import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_formats.dart';
import 'package:chagok_mobile/core/network/json_map.dart';
import 'package:chagok_mobile/features/notification/data/app_notification.dart';
import 'package:chagok_mobile/features/notification/data/notification_kind.dart';
import 'package:chagok_mobile/features/notification/data/notification_repository.dart';

/// 차곡 API 서버의 알림 API로 알림을 다루는 [NotificationRepository].
///
/// 서버는 오늘 기준으로 남은 날을 계산하고 90일이 지난 알림은 지우므로 `now`는 쓰지 않습니다.
class ApiNotificationRepository implements NotificationRepository {
  ApiNotificationRepository({required this._client});

  final ApiClient _client;

  @override
  Future<List<AppNotification>> fetchAll(DateTime now) async {
    final items = await _client.getAllPages(
      '/notifications',
      query: {'filter': 'ALL'},
    );
    return [for (final item in items) _notificationOf(item)];
  }

  @override
  Future<void> markRead(List<String> ids) async {
    await Future.wait([
      for (final id in ids)
        _client.patch('/notifications/${apiId(id)}', body: {'isRead': true}),
    ]);
  }

  /// 완료로 표시합니다. 서버는 완료하면 읽음으로도 바꿉니다.
  @override
  Future<void> markDone(String id) async {
    await _client.patch(
      '/notifications/${apiId(id)}',
      body: {'isCompleted': true},
    );
  }

  AppNotification _notificationOf(JsonMap json) {
    final deadline = json.mapOrNull('deadline');
    final document = json.mapOrNull('document');
    return AppNotification(
      id: json.id('notificationId'),
      kind: switch ((
        json.stringOrNull('type'),
        deadline?.stringOrNull('type'),
      )) {
        ('DEADLINE_DUE', 'PAYMENT') => NotificationKind.payment,
        ('DEADLINE_DUE', 'EXPIRY' || 'ACTION') => NotificationKind.expiry,
        _ => NotificationKind.notice,
      },
      title: json.string('title'),
      sentAt: parseApiDateTime(json.string('sentAt')),
      isRead: json.boolean('isRead'),
      isDone: json.boolean('isCompleted'),
      message: json.stringOrNull('message'),
      boxName: document?.stringOrNull('boxName'),
      dueDate: switch (deadline?.stringOrNull('date')) {
        final date? => parseApiDate(date),
        null => null,
      },
      amount: deadline?.integerOrNull('amount'),
      documentName: document?.stringOrNull('title'),
      documentId: document?.idOrNull('documentId'),
    );
  }
}
