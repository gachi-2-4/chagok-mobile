import 'package:chagok_mobile/features/notification/application/notification_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/sample_notifications.dart';

void main() {
  group('NotificationFilter.apply', () {
    test('전체 탭이면 모든 알림을 순서대로 돌려준다', () {
      final shown = NotificationFilter.all.apply(sampleNotifications());

      expect(shown.map((notification) => notification.id), [
        'old',
        'rent',
        'paid',
      ]);
    });

    test('읽지 않음 탭이면 읽지 않은 알림만 돌려준다', () {
      final shown = NotificationFilter.unread.apply(sampleNotifications());

      expect(shown.map((notification) => notification.id), ['rent']);
    });

    test('완료 탭이면 완료로 표시한 알림만 돌려준다', () {
      final shown = NotificationFilter.done.apply(sampleNotifications());

      expect(shown.map((notification) => notification.id), ['paid']);
    });
  });
}
