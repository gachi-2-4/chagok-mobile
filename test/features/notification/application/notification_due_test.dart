import 'package:chagok_mobile/features/notification/application/notification_due.dart';
import 'package:chagok_mobile/features/notification/data/app_notification.dart';
import 'package:chagok_mobile/features/notification/data/notification_kind.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/sample_notifications.dart';

AppNotification _payment({DateTime? dueDate, bool isDone = false}) {
  return AppNotification(
    id: 'rent',
    kind: NotificationKind.payment,
    title: '월세',
    sentAt: DateTime(2026, 11, 18, 9),
    dueDate: dueDate,
    isDone: isDone,
  );
}

void main() {
  final today = DateTime(2026, 11, 18, 22);

  group('NotificationDue.daysLeft', () {
    test('완료하지 않은 납부 알림이면 납부일까지 남은 날을 돌려준다', () {
      expect(
        NotificationDue.daysLeft(
          _payment(dueDate: DateTime(2026, 11, 19)),
          today,
        ),
        1,
      );
    });

    test('납부일이 오늘이면 0을 돌려준다', () {
      expect(
        NotificationDue.daysLeft(
          _payment(dueDate: DateTime(2026, 11, 18)),
          today,
        ),
        0,
      );
    });

    test('납부일이 지났으면 null을 돌려준다', () {
      expect(
        NotificationDue.daysLeft(
          _payment(dueDate: DateTime(2026, 11, 17)),
          today,
        ),
        isNull,
      );
    });

    test('완료로 표시한 알림이면 null을 돌려준다', () {
      expect(
        NotificationDue.daysLeft(
          _payment(dueDate: DateTime(2026, 11, 19), isDone: true),
          today,
        ),
        isNull,
      );
    });

    test('납부 알림이 아니면 날짜가 있어도 null을 돌려준다', () {
      final expiry = AppNotification(
        id: 'lease',
        kind: NotificationKind.expiry,
        title: '만기',
        sentAt: DateTime(2026, 11, 16),
        dueDate: DateTime(2026, 12, 16),
      );

      expect(NotificationDue.daysLeft(expiry, today), isNull);
    });

    test('서머타임이 끝나는 날을 사이에 두면 달력상 날 수를 돌려준다', () {
      expect(
        NotificationDue.daysLeft(
          _payment(dueDate: DateTime(2026, 11, 2)),
          DateTime(2026, 10, 31, 23),
        ),
        2,
      );
    });
  });

  group('NotificationDue.unreadCount', () {
    test('알림 목록을 넣으면 읽지 않은 알림 수를 돌려준다', () {
      expect(NotificationDue.unreadCount(sampleNotifications()), 1);
    });
  });
}
