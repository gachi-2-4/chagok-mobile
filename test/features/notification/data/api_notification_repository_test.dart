import 'package:chagok_mobile/features/notification/data/api_notification_repository.dart';
import 'package:chagok_mobile/features/notification/data/notification_kind.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_api_server.dart';

void main() {
  late FakeApiServer server;
  late ApiNotificationRepository repository;

  /// [type]·기한 종류 [deadlineType]인 알림 하나.
  Map<String, Object?> notification(
    int id,
    String type, {
    String? deadlineType,
  }) => {
    'notificationId': id,
    'type': type,
    'title': '알림 $id',
    'message': '내용',
    'deadline': deadlineType == null
        ? null
        : {'type': deadlineType, 'date': '2026-11-25', 'amount': 500000},
    'document': {'title': '임대차계약서', 'boxName': '집 · 임대'},
    'isRead': false,
    'isCompleted': false,
    'sentAt': '2026-11-24T09:00:00+09:00',
  };

  setUp(() {
    server = FakeApiServer();
    repository = ApiNotificationRepository(client: server.client);
  });

  group('ApiNotificationRepository.fetchAll', () {
    test('알림을 받으면 알림 종류와 기한 종류로 알림 종류를 고른다', () async {
      server.onJson('GET', '/notifications', {
        'content': [
          notification(1, 'DEADLINE_DUE', deadlineType: 'PAYMENT'),
          notification(2, 'DEADLINE_DUE', deadlineType: 'ACTION'),
          notification(3, 'ANALYSIS_COMPLETED'),
        ],
        'hasNext': false,
      });

      final notifications = await repository.fetchAll(DateTime(2026, 11, 24));

      expect(notifications.map((item) => item.kind), [
        NotificationKind.payment,
        NotificationKind.expiry,
        NotificationKind.notice,
      ]);
    });

    test('기한 알림이면 납부일·금액·연결 서류를 붙인다', () async {
      server.onJson('GET', '/notifications', {
        'content': [notification(1, 'DEADLINE_DUE', deadlineType: 'PAYMENT')],
        'hasNext': false,
      });

      final notifications = await repository.fetchAll(DateTime(2026, 11, 24));

      expect(notifications.single.dueDate, DateTime(2026, 11, 25));
      expect(notifications.single.amount, 500000);
      expect(notifications.single.documentName, '임대차계약서');
    });
  });

  group('ApiNotificationRepository.markRead', () {
    test('여러 알림을 읽으면 알림마다 읽음으로 바꾼다', () async {
      server
        ..onJson('PATCH', '/notifications/1', {})
        ..onJson('PATCH', '/notifications/2', {});

      await repository.markRead(['1', '2']);

      expect(server.lastBody('PATCH', '/notifications/1'), {'isRead': true});
      expect(server.requestsTo('PATCH', '/notifications/2'), hasLength(1));
    });
  });

  group('ApiNotificationRepository.markDone', () {
    test('완료로 표시하면 isCompleted를 보낸다', () async {
      server.onJson('PATCH', '/notifications/3', {});

      await repository.markDone('3');

      expect(server.lastBody('PATCH', '/notifications/3'), {
        'isCompleted': true,
      });
    });
  });
}
