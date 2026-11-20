import 'dart:async';

import 'package:chagok_mobile/features/notification/application/notification_clock.dart';
import 'package:chagok_mobile/features/notification/application/notification_done_notifier.dart';
import 'package:chagok_mobile/features/notification/application/notification_list_notifier.dart';
import 'package:chagok_mobile/features/notification/data/notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_notification_repository.dart';
import '../../../helpers/sample_notifications.dart';

void main() {
  late FakeNotificationRepository repository;
  late ProviderContainer container;

  setUp(() async {
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
    );
    addTearDown(container.dispose);
    container.listen(notificationListProvider, (_, _) {});
    await container.read(notificationListProvider.future);
  });

  NotificationDoneNotifier notifier() =>
      container.read(notificationDoneProvider.notifier);

  group('NotificationDoneNotifier', () {
    test('완료로 표시하면 저장하고 true를 돌려준다', () async {
      final isSaved = await notifier().markDone('rent');

      expect(isSaved, isTrue);
      expect(repository.doneRequests, ['rent']);
    });

    test('저장하는 사이 같은 알림을 다시 표시하면 null을 돌려주고 한 번만 저장한다', () async {
      repository.saveGate = Completer<void>();
      final first = notifier().markDone('rent');

      final second = await notifier().markDone('rent');
      expect(container.read(notificationDoneProvider), {'rent'});
      repository.saveGate?.complete();
      await first;

      expect(second, isNull);
      expect(repository.doneRequests, ['rent']);
    });

    test('저장이 끝나면 저장 중 표시를 지워 다시 표시할 수 있게 한다', () async {
      repository.saveError = Exception('network');

      final isSaved = await notifier().markDone('rent');

      expect(isSaved, isFalse);
      expect(container.read(notificationDoneProvider), isEmpty);
    });
  });
}
