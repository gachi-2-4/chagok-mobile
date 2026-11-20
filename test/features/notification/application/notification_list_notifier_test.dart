import 'dart:async';

import 'package:chagok_mobile/features/notification/application/notification_clock.dart';
import 'package:chagok_mobile/features/notification/application/notification_list_notifier.dart';
import 'package:chagok_mobile/features/notification/data/app_notification.dart';
import 'package:chagok_mobile/features/notification/data/notification_kind.dart';
import 'package:chagok_mobile/features/notification/data/notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_notification_repository.dart';
import '../../../helpers/sample_notifications.dart';

void main() {
  late FakeNotificationRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeNotificationRepository(
      notifications: sampleNotifications(),
    );
    container = ProviderContainer(
      overrides: [
        notificationRepositoryProvider.overrideWithValue(repository),
        notificationClockProvider.overrideWithValue(
          () => DateTime(2026, 11, 18, 10),
        ),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    container.listen(notificationListProvider, (_, _) {});
  });

  NotificationListNotifier notifier() =>
      container.read(notificationListProvider.notifier);

  List<AppNotification> current() =>
      container.read(notificationListProvider).value ?? [];

  AppNotification byId(String id) =>
      current().firstWhere((notification) => notification.id == id);

  group('NotificationListNotifier', () {
    test('불러오면 최근에 받은 알림부터 돌려준다', () async {
      final notifications = await container.read(
        notificationListProvider.future,
      );

      expect(notifications.map((notification) => notification.id), [
        'rent',
        'paid',
        'old',
      ]);
    });

    test('읽지 않은 알림을 읽으면 저장하고 읽음으로 바꾼다', () async {
      await container.read(notificationListProvider.future);

      final isSaved = await notifier().markRead('rent');

      expect(isSaved, isTrue);
      expect(repository.readRequests, [
        ['rent'],
      ]);
      expect(byId('rent').isRead, isTrue);
    });

    test('이미 읽은 알림을 읽으면 저장하지 않는다', () async {
      await container.read(notificationListProvider.future);

      await notifier().markRead('old');

      expect(repository.readRequests, isEmpty);
    });

    test('모두 읽음을 누르면 읽지 않은 알림만 모아 한 번에 저장한다', () async {
      repository.notifications = [
        ...sampleNotifications(),
        AppNotification(
          id: 'new',
          kind: NotificationKind.notice,
          title: '새 안내',
          sentAt: DateTime(2026, 11, 18, 8),
        ),
      ];
      container.invalidate(notificationListProvider);
      await container.read(notificationListProvider.future);

      await notifier().markAllRead();

      expect(repository.readRequests.single, unorderedEquals(['rent', 'new']));
      expect(current().every((notification) => notification.isRead), isTrue);
    });

    test('완료로 표시하면 저장하고 완료이자 읽음으로 바꾼다', () async {
      await container.read(notificationListProvider.future);

      final isSaved = await notifier().markDone('rent');

      expect(isSaved, isTrue);
      expect(repository.doneRequests, ['rent']);
      expect(byId('rent').isDone, isTrue);
      expect(byId('rent').isRead, isTrue);
    });

    test('저장하지 못하면 false를 돌려주고 목록은 그대로 둔다', () async {
      repository.saveError = Exception('network');
      await container.read(notificationListProvider.future);

      final isSaved = await notifier().markDone('rent');

      expect(isSaved, isFalse);
      expect(container.read(notificationListProvider).hasError, isFalse);
      expect(byId('rent').isDone, isFalse);
    });

    test('불러오지 못하면 에러 상태가 된다', () async {
      repository.fetchError = Exception('network');
      container.invalidate(notificationListProvider);

      await expectLater(
        container.read(notificationListProvider.future),
        throwsException,
      );

      expect(container.read(notificationListProvider).hasError, isTrue);
    });

    test('저장하는 사이 목록을 다시 불러오면 다시 불러온 목록에 표시를 반영한다', () async {
      await container.read(notificationListProvider.future);
      repository.saveGate = Completer<void>();
      final saving = notifier().markDone('rent');

      container.invalidate(notificationListProvider);
      await container.read(notificationListProvider.future);
      repository.saveGate?.complete();
      await saving;

      expect(byId('rent').isDone, isTrue);
    });
  });
}
