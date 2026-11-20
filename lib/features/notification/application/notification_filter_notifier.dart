import 'package:chagok_mobile/features/notification/application/notification_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 알림 목록에서 고른 탭. 목록과 상세 화면이 함께 씁니다.
final notificationFilterProvider =
    NotifierProvider<NotificationFilterNotifier, NotificationFilter>(
      NotificationFilterNotifier.new,
    );

/// 알림 탭을 고릅니다. 처음에는 "전체"입니다.
class NotificationFilterNotifier extends Notifier<NotificationFilter> {
  @override
  NotificationFilter build() => NotificationFilter.all;

  /// [filter] 탭을 고릅니다.
  void select(NotificationFilter filter) => state = filter;
}
