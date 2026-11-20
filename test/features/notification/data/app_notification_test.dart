import 'package:chagok_mobile/features/notification/data/app_notification.dart';
import 'package:chagok_mobile/features/notification/data/notification_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppNotification', () {
    test('읽음·완료만 바꾸면 나머지 값은 그대로 둔다', () {
      final notification = AppNotification(
        id: 'rent',
        kind: NotificationKind.payment,
        title: '월세',
        sentAt: DateTime(2026, 11, 18, 9),
        amount: 500000,
        documentName: '임대차계약서',
      );

      final done = notification.copyWith(isRead: true, isDone: true);

      expect(done.isRead, isTrue);
      expect(done.isDone, isTrue);
      expect(done.amount, 500000);
      expect(done.documentName, '임대차계약서');
      expect(done.sentAt, DateTime(2026, 11, 18, 9));
    });
  });
}
