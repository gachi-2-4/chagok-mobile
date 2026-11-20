import 'package:chagok_mobile/features/notification/application/notification_clock.dart';
import 'package:chagok_mobile/features/notification/data/app_notification.dart';
import 'package:chagok_mobile/features/notification/data/notification_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 받은 알림 목록(최근 것부터).
final notificationListProvider =
    AsyncNotifierProvider<NotificationListNotifier, List<AppNotification>>(
      NotificationListNotifier.new,
    );

/// 알림을 불러오고 읽음·완료 표시를 합니다.
///
/// 표시를 저장하지 못해도 목록은 그대로 두고 false를 돌려줍니다. 화면은 안내만
/// 띄우고 목록은 계속 보여 줘야 하므로 에러 상태로 바꾸지 않습니다.
class NotificationListNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    final now = ref.watch(notificationClockProvider)();
    final notifications = await ref
        .watch(notificationRepositoryProvider)
        .fetchAll(now);
    return [...notifications]..sort((a, b) => b.sentAt.compareTo(a.sentAt));
  }

  /// 알림 [id]를 읽음으로 표시합니다. 이미 읽었으면 저장하지 않습니다.
  Future<bool> markRead(String id) async {
    final target = state.value
        ?.where((notification) => notification.id == id)
        .firstOrNull;
    if (target == null) return false;
    if (target.isRead) return true;
    return _save(
      () => ref.read(notificationRepositoryProvider).markRead([id]),
      (notification) => notification.id == id
          ? notification.copyWith(isRead: true)
          : notification,
    );
  }

  /// 읽지 않은 알림을 모두 읽음으로 표시합니다.
  Future<bool> markAllRead() async {
    final unreadIds = [
      for (final notification in state.value ?? const <AppNotification>[])
        if (!notification.isRead) notification.id,
    ];
    if (unreadIds.isEmpty) return true;
    return _save(
      () => ref.read(notificationRepositoryProvider).markRead(unreadIds),
      (notification) => unreadIds.contains(notification.id)
          ? notification.copyWith(isRead: true)
          : notification,
    );
  }

  /// 알림 [id]의 할 일을 마쳤다고 표시합니다. 읽음으로도 표시합니다.
  Future<bool> markDone(String id) {
    return _save(
      () => ref.read(notificationRepositoryProvider).markDone(id),
      (notification) => notification.id == id
          ? notification.copyWith(isRead: true, isDone: true)
          : notification,
    );
  }

  /// [save]가 끝나면 지금 목록의 알림을 [update]로 바꿉니다. 저장했으면 true.
  Future<bool> _save(
    Future<void> Function() save,
    AppNotification Function(AppNotification notification) update,
  ) async {
    if (state.value == null) return false;
    try {
      await save();
    } catch (error, stackTrace) {
      debugPrint('알림 표시를 저장하지 못했습니다: $error\n$stackTrace');
      return false;
    }
    if (!ref.mounted) return true;
    // 저장하는 사이 목록을 다시 불러왔을 수 있으므로 지금 목록에 반영합니다.
    final latest = state.value;
    if (latest != null) {
      state = AsyncData([
        for (final notification in latest) update(notification),
      ]);
    }
    return true;
  }
}
