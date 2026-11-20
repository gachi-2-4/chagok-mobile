import 'dart:async';

import 'package:chagok_mobile/features/notification/data/app_notification.dart';
import 'package:chagok_mobile/features/notification/data/notification_repository.dart';

/// 정해 둔 알림을 돌려주고, 읽음·완료 요청을 기록하는 가짜 [NotificationRepository].
class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository({List<AppNotification>? notifications})
    : notifications = notifications ?? [];

  /// [fetchAll]이 돌려줄 알림.
  List<AppNotification> notifications;

  /// 값을 넣으면 [fetchAll]이 이 예외를 던집니다.
  Exception? fetchError;

  /// 값을 넣으면 [markRead]·[markDone]이 이 예외를 던집니다.
  Exception? saveError;

  /// 값을 넣으면 [markRead]·[markDone]이 이것이 끝날 때까지 기다립니다.
  Completer<void>? saveGate;

  /// [markRead]로 받은 id 목록.
  final readRequests = <List<String>>[];

  /// [markDone]으로 받은 id.
  final doneRequests = <String>[];

  @override
  Future<List<AppNotification>> fetchAll(DateTime now) async {
    if (fetchError case final error?) throw error;
    return notifications;
  }

  @override
  Future<void> markRead(List<String> ids) async {
    await saveGate?.future;
    if (saveError case final error?) throw error;
    readRequests.add(ids);
  }

  @override
  Future<void> markDone(String id) async {
    await saveGate?.future;
    if (saveError case final error?) throw error;
    doneRequests.add(id);
  }
}
