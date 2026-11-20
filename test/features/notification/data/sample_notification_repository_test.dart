import 'package:chagok_mobile/features/notification/data/sample_notification_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SampleNotificationRepository', () {
    test('불러오면 월세 납부일을 오늘 기준 달력상 다음 날로 둔다', () async {
      final notifications = await SampleNotificationRepository().fetchAll(
        DateTime(2026, 10, 31, 22),
      );

      final rent = notifications.firstWhere(
        (notification) => notification.id == 'rent-due',
      );
      expect(rent.dueDate, DateTime(2026, 11));
      expect(rent.message, contains('11월 1일까지'));
    });

    test('읽음으로 표시하면 다시 불러올 때 읽음으로 돌려준다', () async {
      final repository = SampleNotificationRepository();
      final now = DateTime(2026, 11, 18);

      await repository.markRead(['rent-due']);
      final reloaded = await repository.fetchAll(now);

      expect(
        reloaded
            .firstWhere((notification) => notification.id == 'rent-due')
            .isRead,
        isTrue,
      );
    });

    test('완료로 표시하면 다시 불러올 때 완료이자 읽음으로 돌려준다', () async {
      final repository = SampleNotificationRepository();
      final now = DateTime(2026, 11, 18);

      await repository.markDone('rent-due');
      final rent = (await repository.fetchAll(now))
          .firstWhere((notification) => notification.id == 'rent-due');

      expect(rent.isDone, isTrue);
      expect(rent.isRead, isTrue);
    });
  });
}
