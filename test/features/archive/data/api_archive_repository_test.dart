import 'package:chagok_mobile/features/archive/data/api_archive_repository.dart';
import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_document_not_found_exception.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:chagok_mobile/features/archive/data/box_not_found_exception.dart';
import 'package:chagok_mobile/features/archive/data/document_importance.dart';
import 'package:chagok_mobile/features/archive/data/sample_summary_lists.dart';
import 'package:chagok_mobile/features/archive/data/summary_section.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_api_server.dart';

void main() {
  final today = DateTime(2026, 11, 12);
  const box = {
    'boxId': 1,
    'name': '집 · 임대',
    'color': 'PEACH',
    'icon': 'RECEIPT',
    'documentCount': 3,
    'nearestDeadline': {'date': '2026-11-25', 'dDay': 13},
  };
  const document = {
    'documentId': 520,
    'title': '전세 임대차 계약서',
    'box': {'boxId': 1, 'name': '집 · 임대'},
    'priority': {'level': 'HIGH'},
    'nextDeadline': {'date': '2026-12-28'},
    'pageCount': 3,
  };

  late FakeApiServer server;
  late ApiArchiveRepository repository;

  setUp(() {
    server = FakeApiServer();
    repository = ApiArchiveRepository(client: server.client);
  });

  group('ApiArchiveRepository.fetchBoxes', () {
    test('박스 목록을 받으면 색·아이콘·가장 가까운 기한을 보관함으로 바꾼다', () async {
      server.onJson('GET', '/boxes', {
        'content': [box],
      });

      final boxes = await repository.fetchBoxes(today);

      expect(boxes.single.color, BoxColor.peach);
      expect(boxes.single.icon, BoxIcon.tax);
      expect(boxes.single.nextDueDate, DateTime(2026, 11, 25));
    });
  });

  group('ApiArchiveRepository.fetchBox', () {
    test('없는 박스면 BoxNotFoundException을 던진다', () async {
      server.on('GET', '/boxes/9', (_) => errorResponse(404, 'BOX_NOT_FOUND'));

      final request = repository.fetchBox('9', today);

      await expectLater(request, throwsA(isA<BoxNotFoundException>()));
    });
  });

  group('ApiArchiveRepository.fetchDocuments', () {
    test('박스의 서류를 불러오면 담은 순서로 요청해 중요도와 기한을 붙인다', () async {
      server.onJson('GET', '/documents', {
        'content': [document],
        'hasNext': false,
      });

      final documents = await repository.fetchDocuments('1', today);

      expect(server.requests.single.url.queryParameters, {
        'boxId': '1',
        'sort': 'OLDEST',
        'page': '0',
        'size': '50',
      });
      expect(documents.single.importance, DocumentImportance.high);
      expect(documents.single.dueDate, DateTime(2026, 12, 28));
    });

    test('분석 중이라 중요도가 없으면 낮음으로 둔다', () async {
      server.onJson('GET', '/documents', {
        'content': [
          {...document, 'priority': null},
        ],
        'hasNext': false,
      });

      final documents = await repository.fetchDocuments('1', today);

      expect(documents.single.importance, DocumentImportance.low);
    });
  });

  group('ApiArchiveRepository.searchDocuments', () {
    test('검색하면 검색어를 앞뒤 공백 없이 보내고 보관함 이름을 붙인다', () async {
      server.onJson('GET', '/documents', {
        'content': [document],
        'hasNext': false,
      });

      final results = await repository.searchDocuments(' 계약 ', today);

      expect(server.requests.single.url.queryParameters['keyword'], '계약');
      expect(results.single.boxName, '집 · 임대');
    });
  });

  group('ApiArchiveRepository.fetchDocumentOverview', () {
    Map<String, Object?> detail({Map<String, Object?>? summaryCard}) => {
      ...document,
      'summary': '분석 요약',
      'summaryCard': summaryCard,
      'fields': [
        {'key': 'deposit', 'value': 230000000, 'valueType': 'AMOUNT'},
        {'key': 'contractEndDate', 'value': '2027-02-28', 'valueType': 'DATE'},
        {'key': 'note', 'label': '특약', 'value': '반려동물 가능', 'valueType': 'TEXT'},
      ],
      'deadlines': [
        {'type': 'EXPIRY', 'date': '2027-02-28'},
        {'type': 'PAYMENT', 'date': '2026-11-25'},
        {'type': 'PAYMENT', 'date': '2026-10-25'},
      ],
    };

    setUp(() => server.onJson('GET', '/boxes/1', box));

    test('서류를 가져오면 비용·가장 가까운 기한·만기와 박스 아이콘을 함께 돌려준다', () async {
      server.onJson('GET', '/documents/520', detail());

      final overview = await repository.fetchDocumentOverview('520', today);

      expect(overview.document.title, '전세 임대차 계약서');
      expect(overview.document.importance, DocumentImportance.high);
      expect(overview.cost?.label, '보증금');
      expect(overview.cost?.amount, 230000000);
      expect(overview.document.dueDate, DateTime(2026, 11, 25));
      expect(overview.dueLabel, '납부');
      expect(overview.periodEnd, DateTime(2027, 2, 28));
      expect(overview.box.icon, BoxIcon.tax);
    });

    test('항목이 있으면 금액·날짜를 보기 좋게 바꿔 정리본 표로 돌려준다', () async {
      server.onJson('GET', '/documents/520', detail());

      final overview = await repository.fetchDocumentOverview('520', today);

      final table = overview.summary.sections.whereType<SummaryTable>().single;
      expect(table.rows.map((row) => (row.label, row.value)), [
        ('보증금', '230,000,000원'),
        ('계약 종료일', '2027.02.28'),
        ('특약', '반려동물 가능'),
      ]);
    });

    test('응답에 특약·체크 목록이 없으면 서류 종류별 예시 목록을 붙인다', () async {
      server.onJson('GET', '/documents/520', {
        ...detail(),
        'docType': 'LEASE_CONTRACT',
      });

      final overview = await repository.fetchDocumentOverview('520', today);

      final lists = overview.summary.sections.whereType<SummaryList>();
      expect(lists.map((list) => list.title), [specialTermsTitle, checksTitle]);
    });

    test('쉬운말 요약 카드가 있으면 한 줄 요약으로 쓴다', () async {
      server.onJson(
        'GET',
        '/documents/520',
        detail(summaryCard: {'oneLineSummary': '보증금 2억 3천만 원, 2년 계약이에요.'}),
      );

      final overview = await repository.fetchDocumentOverview('520', today);

      expect(overview.summary.oneLine, '보증금 2억 3천만 원, 2년 계약이에요.');
    });

    test('요약 카드가 아직 없으면 분석 요약을 한 줄 요약으로 쓴다', () async {
      server.onJson('GET', '/documents/520', detail());

      final overview = await repository.fetchDocumentOverview('520', today);

      expect(overview.summary.oneLine, '분석 요약');
    });

    test('없는 서류면 BoxDocumentNotFoundException을 던진다', () async {
      server.on(
        'GET',
        '/documents/1',
        (_) => errorResponse(404, 'DOCUMENT_NOT_FOUND'),
      );

      final request = repository.fetchDocumentOverview('1', today);

      await expectLater(request, throwsA(isA<BoxDocumentNotFoundException>()));
    });
  });

  group('ApiArchiveRepository.createBox', () {
    test('박스를 만들면 이름·색·아이콘을 서버 값으로 보낸다', () async {
      server.onJson('POST', '/boxes', {
        ...box,
        'boxId': 6,
        'name': '반려동물',
      }, status: 201);

      final created = await repository.createBox(
        name: ' 반려동물 ',
        color: BoxColor.green,
        icon: BoxIcon.pet,
      );

      expect(server.lastBody('POST', '/boxes'), {
        'name': '반려동물',
        'color': 'GREEN',
        'icon': 'PET',
      });
      expect(created.id, '6');
    });
  });
}
