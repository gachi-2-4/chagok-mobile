import 'package:chagok_mobile/features/notification/application/notification_list_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 읽지 않은 알림이 하나라도 있으면 true. 보관함 상단 종에 점을 찍습니다.
///
/// 알림을 불러오는 중이거나 불러오지 못했으면 점을 찍지 않도록 false입니다.
final hasUnreadNotificationProvider = Provider<bool>((ref) {
  final notifications = ref.watch(notificationListProvider).value ?? const [];
  return notifications.any((notification) => !notification.isRead);
});
