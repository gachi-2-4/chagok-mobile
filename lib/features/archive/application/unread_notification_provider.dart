import 'package:chagok_mobile/features/notification/application/notification_list_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 읽지 않은 알림이 하나라도 있으면 true. 보관함 상단 종에 점을 찍습니다.
///
/// 처음 불러오는 중이거나 처음부터 불러오지 못했으면 false입니다. 이미 불러온 뒤
/// 다시 불러오는 동안·실패했을 때는 점이 깜빡이지 않도록 마지막 목록으로 판단합니다.
/// 홈의 알림 점도 다시 불러오는 동안 이전 내용을 보여 줍니다.
final hasUnreadNotificationProvider = Provider<bool>((ref) {
  final notifications = ref.watch(notificationListProvider).value ?? const [];
  return notifications.any((notification) => !notification.isRead);
});
