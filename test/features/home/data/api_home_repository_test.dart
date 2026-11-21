import 'package:chagok_mobile/features/home/data/api_home_repository.dart';
import 'package:chagok_mobile/features/home/data/box_category.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_api_server.dart';

void main() {
  late FakeApiServer server;
  late ApiHomeRepository repository;

  setUp(() {
    server = FakeApiServer();
    repository = ApiHomeRepository(client: server.client);
    server.onJson('GET', '/home', {
      'today': '2026-11-18',
      'weekCalendar': [
        {'date': '2026-11-15', 'deadlines': <Object>[]},
        {
          'date': '2026-11-20',
          'deadlines': [
            {'deadlineId': 75, 'label': '통신 서비스 요금 납부일', 'dDay': 2},
          ],
        },
      ],
      'nextDeadline': {
        'deadlineId': 75,
        'label': '통신 서비스 요금 납부일',
        'date': '2026-11-20',
      },
      'recentBoxes': [
        {
          'boxId': 1,
          'name': '집 · 임대',
          'icon': 'HOME',
          'documentCount': 3,
          'lastOpenedAt': '2026-11-18T09:10:00+09:00',
          'nearestDeadline': {'date': '2026-12-01'},
        },
        {
          'boxId': 4,
          'name': '병원 · 보험',
          'icon': 'HEART',
          'documentCount': 2,
          'lastOpenedAt': '2026-11-17T20:00:00+09:00',
          'nearestDeadline': null,
        },
      ],
      'recentNotifications': [
        {
          'notificationId': 3010,
          'title': '임대차계약서 만기가 30일 남았어요',
          'document': {'boxName': '집 · 임대'},
          'isRead': false,
          'sentAt': '2026-11-18T09:00:00+09:00',
        },
      ],
      'unreadCount': 1,
    });
  });

  group('ApiHomeRepository', () {
    test('이번 주 기한과 다음 기한이 같으면 일정을 한 번만 넣는다', () async {
      final summary = await repository.fetchSummary(DateTime(2026, 11, 18));

      expect(summary.schedules.map((item) => item.date), [
        DateTime(2026, 11, 20),
      ]);
    });

    test('최근 박스를 받으면 아이콘으로 보관함 종류를 고른다', () async {
      final summary = await repository.fetchSummary(DateTime(2026, 11, 18));

      expect(summary.recentBoxes.map((box) => box.category), [
        BoxCategory.housing,
        BoxCategory.other,
      ]);
      expect(summary.recentBoxes.first.nextDueDate, DateTime(2026, 12));
    });

    test('최근 알림에 연결 서류가 있으면 그 보관함 이름을 붙인다', () async {
      final summary = await repository.fetchSummary(DateTime(2026, 11, 18));

      expect(summary.recentAlerts.single.boxName, '집 · 임대');
      expect(summary.hasUnreadAlert, isTrue);
    });
  });
}
