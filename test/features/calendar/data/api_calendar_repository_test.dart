import 'package:chagok_mobile/features/calendar/data/api_calendar_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_api_server.dart';

void main() {
  late FakeApiServer server;
  late ApiCalendarRepository repository;

  setUp(() {
    server = FakeApiServer();
    repository = ApiCalendarRepository(client: server.client);
    server.onJson('GET', '/deadlines', {
      'content': [
        {
          'deadlineId': 75,
          'date': '2026-11-25',
          'label': '관리비 납부',
          'document': {'documentId': 540, 'title': '11월 관리비 고지서'},
          'box': {'boxId': 1, 'name': '집 · 임대'},
          'reminderId': null,
        },
        {
          'deadlineId': 71,
          'date': '2026-12-28',
          'label': '갱신 통보 마감',
          'document': null,
          'box': null,
          'reminderId': 31,
        },
      ],
    });
  });

  group('ApiCalendarRepository.fetchDeadlines', () {
    test('기한을 불러오면 이번 달 1일부터 1년 동안의 기한을 요청한다', () async {
      await repository.fetchDeadlines(DateTime(2026, 11, 18));

      expect(server.requests.single.url.queryParameters, {
        'from': '2026-11-01',
        'to': '2027-10-31',
      });
    });

    test('서류와 박스가 있으면 서류 이름을 제목으로, 박스 이름을 꼬리표로 쓴다', () async {
      final deadlines = await repository.fetchDeadlines(DateTime(2026, 11, 18));

      expect(deadlines.first.title, '11월 관리비 고지서');
      expect(deadlines.first.tags, ['집', '임대']);
    });

    test('서류가 없으면 기한 이름을 제목으로 쓴다', () async {
      final deadlines = await repository.fetchDeadlines(DateTime(2026, 11, 18));

      expect(deadlines.last.title, '갱신 통보 마감');
      expect(deadlines.last.tags, isEmpty);
    });

    test('기한 알림이 있으면 등록한 기한으로 표시한다', () async {
      final deadlines = await repository.fetchDeadlines(DateTime(2026, 11, 18));

      expect(deadlines.map((deadline) => deadline.isRegistered), [false, true]);
    });
  });

  group('ApiCalendarRepository.setRegistered', () {
    test('등록하면 그 기한의 알림을 기본값으로 켠다', () async {
      server.onJson('POST', '/reminders', {'reminderId': 40}, status: 201);

      await repository.setRegistered(id: '75', isRegistered: true);

      expect(server.lastBody('POST', '/reminders'), {'deadlineId': 75});
    });

    test('등록을 빼면 불러온 기한의 알림을 끈다', () async {
      server.on('DELETE', '/reminders/31', (_) => emptyResponse());
      await repository.fetchDeadlines(DateTime(2026, 11, 18));

      await repository.setRegistered(id: '71', isRegistered: false);

      expect(server.requestsTo('DELETE', '/reminders/31'), hasLength(1));
    });

    test('알림을 모르는 기한의 등록을 빼면 StateError를 던진다', () async {
      final request = repository.setRegistered(id: '99', isRegistered: false);

      await expectLater(request, throwsStateError);
    });
  });
}
