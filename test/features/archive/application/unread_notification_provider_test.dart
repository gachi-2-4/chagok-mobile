import 'package:chagok_mobile/features/archive/application/unread_notification_provider.dart';
import 'package:chagok_mobile/features/notification/application/notification_clock.dart';
import 'package:chagok_mobile/features/notification/application/notification_list_notifier.dart';
import 'package:chagok_mobile/features/notification/data/notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_notification_repository.dart';
import '../../../helpers/sample_notifications.dart';

void main() {
  late FakeNotificationRepository repository;

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        notificationRepositoryProvider.overrideWithValue(repository),
        notificationClockProvider.overrideWithValue(
          () => DateTime(2026, 11, 18, 10),
        ),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    return container;
  }

  group('hasUnreadNotificationProvider', () {
    test('읽지 않은 알림이 있으면 true를 돌려준다', () async {
      repository = FakeNotificationRepository(
        notifications: sampleNotifications(),
      );
      final container = createContainer();

      await container.read(notificationListProvider.future);

      expect(container.read(hasUnreadNotificationProvider), isTrue);
    });

    test('알림을 모두 읽었으면 false를 돌려준다', () async {
      repository = FakeNotificationRepository(
        notifications: [
          for (final notification in sampleNotifications())
            notification.copyWith(isRead: true),
        ],
      );
      final container = createContainer();

      await container.read(notificationListProvider.future);

      expect(container.read(hasUnreadNotificationProvider), isFalse);
    });

    test('알림을 불러오지 못하면 false를 돌려준다', () async {
      repository = FakeNotificationRepository()
        ..fetchError = Exception('네트워크 오류');
      final container = createContainer();

      await expectLater(
        container.read(notificationListProvider.future),
        throwsA(isA<Exception>()),
      );

      expect(container.read(hasUnreadNotificationProvider), isFalse);
    });
  });
}
