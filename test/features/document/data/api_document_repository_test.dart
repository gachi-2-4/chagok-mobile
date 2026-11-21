import 'package:chagok_mobile/features/document/data/api_document_repository.dart';
import 'package:chagok_mobile/features/document/data/document_detail.dart';
import 'package:chagok_mobile/features/document/data/document_not_found_exception.dart';
import 'package:chagok_mobile/features/document/data/payment_reminder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_api_server.dart';

void main() {
  /// 월세 납부 기한이 있는 임대차계약서. [reminder]가 null이면 기한 알림이 없습니다.
  Map<String, Object?> lease({Map<String, Object?>? reminder}) => {
    'documentId': 501,
    'box': {'boxId': 1, 'name': '집 · 임대'},
    'docType': 'LEASE_CONTRACT',
    'fields': [
      {'key': 'monthlyRent', 'value': 500000, 'valueType': 'AMOUNT'},
      {'key': 'contractEndDate', 'value': '2027-11-24', 'valueType': 'DATE'},
      {'key': 'earlyTerminationFee', 'value': '월세의 10%', 'valueType': 'TEXT'},
    ],
    'paymentSchedules': [
      {'key': 'monthlyRent', 'dayOfMonth': 25},
    ],
    'deadlines': [
      {
        'deadlineId': 72,
        'type': 'EXPIRY',
        'date': '2027-11-24',
        'recurrence': null,
        'reminder': null,
      },
      {
        'deadlineId': 70,
        'type': 'PAYMENT',
        'date': '2026-11-25',
        'recurrence': 'MONTHLY',
        'reminder': reminder,
      },
    ],
  };

  late FakeApiServer server;
  late ApiDocumentRepository repository;

  setUp(() {
    server = FakeApiServer();
    repository = ApiDocumentRepository(client: server.client);
    server
      ..onJson('GET', '/documents/501', lease())
      ..onJson('PATCH', '/documents/501/fields', lease())
      ..onJson('POST', '/reminders', {'reminderId': 33}, status: 201);
  });

  const detail = DocumentDetail(
    id: '501',
    boxName: '집 · 임대',
    documentType: '임대차계약서',
    monthlyRent: 550000,
    paymentDay: 25,
    earlyTerminationPenalty: '월세의 20%',
  );

  group('ApiDocumentRepository.fetchDetail', () {
    test('서류를 불러오면 항목과 매월 납부일을 서류 내용으로 바꾼다', () async {
      final fetched = await repository.fetchDetail('501');

      expect(fetched.documentType, '임대차계약서');
      expect(fetched.monthlyRent, 500000);
      expect(fetched.paymentDay, 25);
      expect(fetched.contractEndDate, DateTime(2027, 11, 24));
      expect(fetched.earlyTerminationPenalty, '월세의 10%');
    });

    test('없는 서류면 DocumentNotFoundException을 던진다', () async {
      server.on(
        'GET',
        '/documents/9',
        (_) => errorResponse(404, 'DOCUMENT_NOT_FOUND'),
      );

      final request = repository.fetchDetail('9');

      await expectLater(request, throwsA(isA<DocumentNotFoundException>()));
    });
  });

  group('ApiDocumentRepository.updateDetail', () {
    test('내용을 고치면 서류에 있는 항목과 납부일만 보낸다', () async {
      await repository.updateDetail(detail);

      expect(server.lastBody('PATCH', '/documents/501/fields'), {
        'fields': [
          {'key': 'monthlyRent', 'value': 550000},
          {'key': 'contractEndDate', 'value': null},
          {'key': 'earlyTerminationFee', 'value': '월세의 20%'},
        ],
        'paymentSchedules': [
          {'key': 'monthlyRent', 'dayOfMonth': 25},
        ],
      });
    });

    test('서류 종류를 바꾸면 종류만 따로 보낸다', () async {
      await repository.updateDetail(
        const DocumentDetail(
          id: '501',
          boxName: '집 · 임대',
          documentType: '고지서·청구서',
        ),
      );

      expect(server.lastBody('PATCH', '/documents/501/fields'), {
        'docType': 'BILL',
      });
    });
  });

  group('ApiDocumentRepository.fetchReminder', () {
    test('매월 납부 기한에 알림이 있으면 납부일 알림으로 바꾼다', () async {
      server.onJson(
        'GET',
        '/documents/501',
        lease(
          reminder: {
            'reminderId': 33,
            'alertTime': '08:00',
            'advanceDays': [1, 3],
          },
        ),
      );

      final reminder = await repository.fetchReminder('501');

      expect(reminder?.paymentDay, 25);
      expect(reminder?.minuteOfDay, 8 * 60);
      expect(reminder?.advanceDays, {1, 3});
      expect(reminder?.isMonthly, isTrue);
    });

    test('알림을 다음 한 번만 받게 저장했으면 매월 반복을 끈 알림으로 돌려준다', () async {
      server.onJson(
        'GET',
        '/documents/501',
        lease(
          reminder: {
            'reminderId': 33,
            'alertTime': '09:00',
            'advanceDays': [1],
            'repeatMonthly': false,
          },
        ),
      );

      final reminder = await repository.fetchReminder('501');

      expect(reminder?.isMonthly, isFalse);
    });

    test('납부 기한에 알림이 없으면 null을 돌려준다', () async {
      expect(await repository.fetchReminder('501'), isNull);
    });
  });

  group('ApiDocumentRepository.saveReminder', () {
    final reminder = PaymentReminder(
      documentId: '501',
      paymentDay: 25,
      advanceDays: {3, 0},
    );

    test('알림이 없으면 납부 기한에 새 알림을 켠다', () async {
      await repository.saveReminder(reminder);

      expect(server.lastBody('POST', '/reminders'), {
        'deadlineId': 70,
        'alertTime': '09:00',
        'advanceDays': [0, 3],
        'repeatMonthly': true,
      });
    });

    test('알림이 있으면 그 알림을 고친다', () async {
      server
        ..onJson(
          'GET',
          '/documents/501',
          lease(
            reminder: {
              'reminderId': 33,
              'alertTime': '09:00',
              'advanceDays': [1, 0],
            },
          ),
        )
        ..onJson('PATCH', '/reminders/33', {'reminderId': 33});

      await repository.saveReminder(reminder);

      expect(server.requestsTo('PATCH', '/reminders/33'), hasLength(1));
      expect(server.requestsTo('POST', '/reminders'), isEmpty);
    });

    test('납부일을 바꾸면 서류의 매월 납부일도 고친다', () async {
      await repository.saveReminder(reminder.copyWith(paymentDay: 5));

      expect(server.lastBody('PATCH', '/documents/501/fields'), {
        'paymentSchedules': [
          {'key': 'monthlyRent', 'dayOfMonth': 5},
        ],
      });
    });

    test('납부일을 고친 응답에 기한이 없으면 서류를 다시 불러와 알림을 저장한다', () async {
      server.onJson('PATCH', '/documents/501/fields', {'documentId': 501});

      await repository.saveReminder(reminder.copyWith(paymentDay: 5));

      expect(server.requestsTo('GET', '/documents/501'), hasLength(2));
      expect(server.requestsTo('POST', '/reminders'), hasLength(1));
    });

    test('납부 기한이 없는 서류면 StateError를 던진다', () async {
      server.onJson('GET', '/documents/501', {
        ...lease(),
        'paymentSchedules': <Object>[],
        'deadlines': <Object>[],
      });

      await expectLater(repository.saveReminder(reminder), throwsStateError);
    });
  });
}
