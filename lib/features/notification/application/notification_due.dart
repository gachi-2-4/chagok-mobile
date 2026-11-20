import 'package:chagok_mobile/features/notification/data/app_notification.dart';
import 'package:chagok_mobile/features/notification/data/notification_kind.dart';

/// 알림의 남은 날을 계산하는 함수 모음.
abstract final class NotificationDue {
  /// 목록에 D-n 표로 보여 줄 남은 날. 보여 주지 않으면 null.
  ///
  /// 아직 완료하지 않은 납부 알림만, 납부일이 지나지 않았을 때 보여 줍니다.
  static int? daysLeft(AppNotification notification, DateTime today) {
    final dueDate = notification.dueDate;
    if (notification.kind != NotificationKind.payment ||
        notification.isDone ||
        dueDate == null) {
      return null;
    }
    // UTC로 바꿔 서머타임과 상관없이 하루를 24시간으로 셉니다.
    final from = DateTime.utc(today.year, today.month, today.day);
    final to = DateTime.utc(dueDate.year, dueDate.month, dueDate.day);
    final days = to.difference(from).inDays;
    return days < 0 ? null : days;
  }

  /// 아직 읽지 않은 알림 수.
  static int unreadCount(List<AppNotification> notifications) =>
      notifications.where((notification) => !notification.isRead).length;
}
