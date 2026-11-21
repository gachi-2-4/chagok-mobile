import 'dart:async';
import 'dart:typed_data';

import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/api_upload_repository.dart';
import 'package:chagok_mobile/features/upload/data/document_preview.dart';
import 'package:chagok_mobile/features/upload/data/picked_document.dart';
import 'package:chagok_mobile/features/upload/data/upload_file.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_api_server.dart';

void main() {
  final document = PickedDocument(
    fileName: '임대차계약서.pdf',
    source: UploadSource.pdf,
    pageCount: 3,
    preview: DocumentPreview(title: '제목', section: '조항', lines: []),
    files: [
      UploadFile(fileName: '임대차계약서.pdf', bytes: Uint8List.fromList([1, 2, 3])),
    ],
  );
  const analyzed = {
    'documentId': 520,
    'status': 'REVIEW_REQUIRED',
    'docType': 'LEASE_CONTRACT',
    'pageCount': 3,
    'fields': [
      {
        'key': 'monthlyRent',
        'label': '월 임대료',
        'originalLabel': '월세',
        'value': 500000,
        'valueType': 'AMOUNT',
        'needsReview': false,
      },
      {
        'key': 'contractEndDate',
        'label': '계약 종료일',
        'originalLabel': '계약 종료일',
        'value': '2027-01-02',
        'valueType': 'DATE',
        'needsReview': false,
      },
      {
        'key': 'earlyTerminationPenalty',
        'label': '중도 해지 위약금',
        'value': '잔여 기간 월세의 10%',
        'valueType': 'TEXT',
        'needsReview': true,
      },
    ],
  };

  late FakeApiServer server;
  late ApiUploadRepository repository;
  late List<Duration> waits;

  /// 가짜 시계. 기다리면 그만큼 흐릅니다.
  late DateTime clock;

  setUp(() {
    server = FakeApiServer();
    waits = [];
    clock = DateTime(2026, 11, 18, 9);
    repository = ApiUploadRepository(
      client: server.client,
      pick: (_) async => document,
      pollTimeout: const Duration(seconds: 6),
      wait: (duration) async {
        waits.add(duration);
        clock = clock.add(duration);
      },
      now: () => clock,
    );
    server.onJson('POST', '/documents', {
      'documentId': 520,
      'status': 'ANALYZING',
    }, status: 202);
  });

  /// 처음 [analyzingCount]번은 분석 중이고 그 뒤에는 [done]을 돌려줍니다.
  void analyzeAfter(int analyzingCount, Map<String, Object?> done) {
    var count = 0;
    server.on('GET', '/documents/520', (_) {
      return jsonResponse(
        count++ < analyzingCount ? {'status': 'ANALYZING'} : done,
      );
    });
  }

  group('ApiUploadRepository.analyze', () {
    test('분석하면 파일을 고른 보관함으로 올리고 분석이 끝날 때까지 조회한다', () async {
      analyzeAfter(2, analyzed);

      final result = await repository.analyze(document, boxId: '1');

      final upload = server.requestsTo('POST', '/documents').single;
      expect(upload.headers['content-type'], startsWith('multipart/form-data'));
      expect(upload.body, contains('name="boxId"\r\n\r\n1'));
      expect(waits, hasLength(2));
      expect(result, isA<AnalysisSucceeded>());
    });

    test('항목 값을 확인 화면 형식으로 바꾸고 원본 이름이 다르면 남긴다', () async {
      analyzeAfter(0, analyzed);

      final result = await repository.analyze(document, boxId: '1');

      final fields = (result as AnalysisSucceeded).fields;
      expect(fields.map((field) => field.value), [
        '500,000원',
        '2027.1.2',
        null,
      ]);
      expect(fields.map((field) => field.originalLabel), ['월세', null, null]);
      expect(result.documentId, '520');
    });

    test('글자를 읽지 못했으면 AnalysisUnclear를 돌려준다', () async {
      analyzeAfter(0, {
        'status': 'FAILED',
        'failReason': 'TEXT_NOT_RECOGNIZED',
      });

      final result = await repository.analyze(document, boxId: '1');

      expect(result, isA<AnalysisUnclear>());
    });

    test('분석이 끝나지 않으면 TimeoutException을 던진다', () async {
      analyzeAfter(100, analyzed);

      final request = repository.analyze(document, boxId: '1');

      await expectLater(request, throwsA(isA<TimeoutException>()));
    });

    test('조회가 느리면 조회에 걸린 시간도 제한 시간에 넣어 TimeoutException을 던진다', () async {
      server.on('GET', '/documents/520', (_) {
        clock = clock.add(const Duration(seconds: 10));
        return jsonResponse({'status': 'ANALYZING'});
      });

      final request = repository.analyze(document, boxId: '1');

      await expectLater(request, throwsA(isA<TimeoutException>()));
      expect(server.requestsTo('GET', '/documents/520'), hasLength(1));
    });

    test('기다리다 실패한 뒤 같은 파일로 다시 분석하면 다시 올리지 않고 이어서 기다린다', () async {
      analyzeAfter(100, analyzed);
      await expectLater(
        repository.analyze(document, boxId: '1'),
        throwsA(isA<TimeoutException>()),
      );
      analyzeAfter(0, analyzed);

      final result = await repository.analyze(document, boxId: '1');

      expect(result, isA<AnalysisSucceeded>());
      expect(server.requestsTo('POST', '/documents'), hasLength(1));
    });

    test('분석 결과를 받은 뒤 같은 파일로 다시 분석하면 새로 올린다', () async {
      analyzeAfter(0, {
        'status': 'FAILED',
        'failReason': 'TEXT_NOT_RECOGNIZED',
      });
      await repository.analyze(document, boxId: '1');

      await repository.analyze(document, boxId: '1');

      expect(server.requestsTo('POST', '/documents'), hasLength(2));
    });

    test('올릴 파일 내용이 없으면 StateError를 던진다', () async {
      final empty = PickedDocument(
        fileName: '예시.pdf',
        source: UploadSource.pdf,
        pageCount: 1,
        preview: DocumentPreview(title: '제목', section: '조항', lines: []),
      );

      await expectLater(
        repository.analyze(empty, boxId: '1'),
        throwsStateError,
      );
      expect(server.requests, isEmpty);
    });
  });

  group('ApiUploadRepository.save', () {
    setUp(() {
      server
        ..onJson('POST', '/documents/520/confirm', {'status': 'CONFIRMED'})
        ..onJson('PATCH', '/documents/520', {});
      analyzeAfter(0, analyzed);
    });

    test('옮긴 뒤 확인이 실패하고 처음 보관함으로 다시 저장하면 다시 옮긴다', () async {
      final result = await repository.analyze(document, boxId: '1');
      server.on(
        'POST',
        '/documents/520/confirm',
        (_) => errorResponse(500, 'INTERNAL_SERVER_ERROR'),
      );
      await expectLater(
        repository.save(
          document: document,
          result: result as AnalysisSucceeded,
          boxId: '3',
        ),
        throwsA(isA<Exception>()),
      );
      server.onJson('POST', '/documents/520/confirm', {'status': 'CONFIRMED'});

      await repository.save(document: document, result: result, boxId: '1');

      expect(server.lastBody('PATCH', '/documents/520'), {'boxId': 1});
    });

    test('같은 보관함이면 확인만 보낸다', () async {
      final result = await repository.analyze(document, boxId: '1');

      await repository.save(
        document: document,
        result: result as AnalysisSucceeded,
        boxId: '1',
      );

      expect(server.requestsTo('POST', '/documents/520/confirm'), hasLength(1));
      expect(server.requestsTo('PATCH', '/documents/520'), isEmpty);
    });

    test('올린 뒤 보관함을 바꿨으면 옮기고 확인한다', () async {
      final result = await repository.analyze(document, boxId: '1');

      await repository.save(
        document: document,
        result: result as AnalysisSucceeded,
        boxId: '3',
      );

      expect(server.lastBody('PATCH', '/documents/520'), {'boxId': 3});
      expect(server.requestsTo('POST', '/documents/520/confirm'), hasLength(1));
    });
  });
}
