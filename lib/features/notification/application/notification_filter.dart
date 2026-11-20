import 'package:chagok_mobile/features/notification/data/app_notification.dart';

/// 알림 목록 위 탭. 어떤 알림을 보여 줄지 정합니다.
enum NotificationFilter {
  /// 모든 알림.
  all,

  /// 아직 읽지 않은 알림.
  unread,

  /// 할 일을 마쳤다고 표시한 알림.
  done;

  /// [notifications] 가운데 이 탭에 보일 알림만 순서대로 돌려줍니다.
  List<AppNotification> apply(List<AppNotification> notifications) {
    return [
      for (final notification in notifications)
        if (switch (this) {
          all => true,
          unread => !notification.isRead,
          done => notification.isDone,
        })
          notification,
    ];
  }
}
