import 'package:chagok_mobile/features/notification/application/notification_filter.dart';
import 'package:chagok_mobile/features/notification/application/notification_filter_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationFilterNotifier', () {
    test('처음 읽으면 전체 탭을 돌려준다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(notificationFilterProvider),
        NotificationFilter.all,
      );
    });

    test('탭을 고르면 그 탭으로 바꾼다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(notificationFilterProvider.notifier)
          .select(NotificationFilter.done);

      expect(
        container.read(notificationFilterProvider),
        NotificationFilter.done,
      );
    });
  });
}
