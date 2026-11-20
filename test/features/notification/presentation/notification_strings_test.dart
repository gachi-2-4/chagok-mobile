import 'package:chagok_mobile/features/notification/data/app_notification.dart';
import 'package:chagok_mobile/features/notification/data/notification_kind.dart';
import 'package:chagok_mobile/features/notification/presentation/notification_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationStrings.sentAt', () {
    test('시각이 있으면 날짜 뒤에 오전·오후 시각을 붙인다', () {
      expect(
        NotificationStrings.sentAt(DateTime(2026, 11, 18, 9)),
        '2026-11-18 · 오전 9:00',
      );
      expect(
        NotificationStrings.sentAt(DateTime(2026, 11, 18, 12, 5)),
        '2026-11-18 · 오후 12:05',
      );
    });

    test('0시면 날짜만 보여 준다', () {
      expect(NotificationStrings.sentAt(DateTime(2026, 1, 6)), '2026-01-06');
    });
  });

  group('NotificationStrings.won', () {
    test('금액을 넣으면 세 자리마다 쉼표를 넣고 원을 붙인다', () {
      expect(NotificationStrings.won(500000), '500,000원');
      expect(NotificationStrings.won(1234567), '1,234,567원');
      expect(NotificationStrings.won(900), '900원');
    });
  });

  group('NotificationStrings.detailTitle', () {
    test('납부 알림이면 [납부] 말머리를 붙인다', () {
      final notification = AppNotification(
        id: 'rent',
        kind: NotificationKind.payment,
        title: '내일은 월세 납부일이에요',
        sentAt: DateTime(2026, 11, 18, 9),
      );

      expect(
        NotificationStrings.detailTitle(notification),
        '[납부] 내일은 월세 납부일이에요',
      );
    });
  });

  group('NotificationStrings.detailMeta', () {
    test('보관함이 있으면 보낸 날짜 뒤에 보관함을 붙인다', () {
      final notification = AppNotification(
        id: 'rent',
        kind: NotificationKind.payment,
        title: '월세',
        sentAt: DateTime(2026, 11, 18, 9),
        boxName: '집 · 임대',
      );

      expect(
        NotificationStrings.detailMeta(notification),
        '2026-11-18 · 오전 9:00 · 집 · 임대',
      );
    });

    test('보관함이 없으면 보낸 날짜만 보여 준다', () {
      final notification = AppNotification(
        id: 'notice',
        kind: NotificationKind.notice,
        title: '안내',
        sentAt: DateTime(2026, 11, 18),
      );

      expect(NotificationStrings.detailMeta(notification), '2026-11-18');
    });
  });
}
