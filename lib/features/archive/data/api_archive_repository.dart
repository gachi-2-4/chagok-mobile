import 'package:chagok_mobile/core/constants/document_type_names.dart';
import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_exception.dart';
import 'package:chagok_mobile/core/network/api_formats.dart';
import 'package:chagok_mobile/core/network/json_map.dart';
import 'package:chagok_mobile/features/archive/data/archive_box.dart';
import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_document.dart';
import 'package:chagok_mobile/features/archive/data/box_document_not_found_exception.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:chagok_mobile/features/archive/data/box_not_found_exception.dart';
import 'package:chagok_mobile/features/archive/data/document_cost.dart';
import 'package:chagok_mobile/features/archive/data/document_importance.dart';
import 'package:chagok_mobile/features/archive/data/document_overview.dart';
import 'package:chagok_mobile/features/archive/data/document_search_result.dart';
import 'package:chagok_mobile/features/archive/data/document_summary.dart';
import 'package:chagok_mobile/features/archive/data/sample_summary_lists.dart';
import 'package:chagok_mobile/features/archive/data/summary_row.dart';
import 'package:chagok_mobile/features/archive/data/summary_section.dart';

/// 차곡 API 서버의 박스·서류 API로 보관함을 다루는 [ArchiveRepository].
///
/// 서버가 오늘(KST) 기준으로 기한을 계산하므로 `today`는 쓰지 않습니다.
class ApiArchiveRepository implements ArchiveRepository {
  ApiArchiveRepository({required this._client});

  final ApiClient _client;

  @override
  Future<List<ArchiveBox>> fetchBoxes(DateTime today) async {
    final json = await _client.get('/boxes');
    return [for (final box in json.maps('content')) _boxOf(box)];
  }

  @override
  Future<ArchiveBox> fetchBox(String boxId, DateTime today) async {
    try {
      return _boxOf(await _client.get('/boxes/${apiId(boxId)}'));
    } on ApiException catch (error) {
      if (error.isNotFound) throw BoxNotFoundException(boxId);
      rethrow;
    }
  }

  @override
  Future<List<BoxDocument>> fetchDocuments(String boxId, DateTime today) async {
    try {
      final documents = await _client.getAllPages(
        '/documents',
        query: {'boxId': apiId(boxId), 'sort': 'OLDEST'},
      );
      return [for (final document in documents) _documentOf(document)];
    } on ApiException catch (error) {
      if (error.isNotFound) throw BoxNotFoundException(boxId);
      rethrow;
    }
  }

  @override
  Future<List<DocumentSearchResult>> searchDocuments(
    String query,
    DateTime today,
  ) async {
    // 서버는 이름·요약·항목 값·원문에서 찾고, `50만` 같은 금액도 맞춰 봅니다.
    final documents = await _client.getAllPages(
      '/documents',
      query: {'keyword': query.trim(), 'sort': 'OLDEST'},
    );
    return [
      for (final document in documents)
        DocumentSearchResult(
          document: _documentOf(document),
          boxName: document.mapOrNull('box')?.stringOrNull('name') ?? '',
        ),
    ];
  }

  /// 서류 상세(07·08)에 보여 줄 내용을 `GET /documents/{id}`에서 만듭니다.
  ///
  /// - 한 줄 요약은 AI 쉬운말 요약 카드를 쓰고, 카드가 아직 없으면 분석 요약을 씁니다.
  /// - 정리본 표는 서류에서 읽어 낸 항목(`fields`)으로 만듭니다. 특약·체크 같은
  ///   목록은 응답에 없어 서류 종류별 예시를 붙입니다(`sampleSummaryListsOf`).
  /// - 비용은 첫 금액 항목, D-day는 가장 가까운 기한, 기간 끝은 만기(`EXPIRY`)입니다.
  /// - 응답의 박스에는 이름만 있어 아이콘·색은 `GET /boxes/{id}`로 가져옵니다.
  @override
  Future<DocumentOverview> fetchDocumentOverview(
    String documentId,
    DateTime today,
  ) async {
    final JsonMap json;
    try {
      json = await _client.get('/documents/${apiId(documentId)}');
    } on ApiException catch (error) {
      if (error.isNotFound) throw BoxDocumentNotFoundException(documentId);
      rethrow;
    }
    final fields = json.maps('fields');
    final deadlines = [
      for (final deadline in json.maps('deadlines'))
        (
          type: deadline.stringOrNull('type'),
          date: parseApiDate(deadline.string('date')),
        ),
    ];
    final todayDate = DateTime(today.year, today.month, today.day);
    final upcoming =
        deadlines
            .where((deadline) => !deadline.date.isBefore(todayDate))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    final next = upcoming.firstOrNull;
    final amountField = fields
        .where((field) => field.stringOrNull('valueType') == 'AMOUNT')
        .firstOrNull;
    final amount = amountField?.integerOrNull('value');
    final boxId = json.mapOrNull('box')?.idOrNull('boxId');

    return DocumentOverview(
      document: BoxDocument(
        id: json.id('documentId'),
        title:
            json.stringOrNull('title') ??
            documentTypeNameOf(json.stringOrNull('docType')),
        importance: _importanceOf(json),
        pageCount: json.integerOrNull('pageCount') ?? 1,
        dueDate: next?.date,
      ),
      box: boxId == null ? _unknownBox(json) : await fetchBox(boxId, today),
      summary: DocumentSummary(
        oneLine:
            json.mapOrNull('summaryCard')?.stringOrNull('oneLineSummary') ??
            json.stringOrNull('summary') ??
            '',
        sections: [
          if (fields.isNotEmpty)
            SummaryTable(
              title: _fieldsTitle,
              rows: [
                for (final field in fields)
                  if (_valueOf(field) case final value?)
                    SummaryRow(label: _fieldLabelOf(field), value: value),
              ],
            ),
          // TODO: 서버가 특약·체크 목록을 주면 예시 대신 응답 값을 씁니다.
          ...sampleSummaryListsOf(json.stringOrNull('docType')),
        ],
      ),
      cost: switch ((amountField, amount)) {
        (final field?, final amount?) => DocumentCost(
          label: _fieldLabelOf(field),
          amount: amount,
        ),
        _ => null,
      },
      dueLabel: _deadlineLabels[next?.type],
      periodEnd: deadlines
          .where((deadline) => deadline.type == 'EXPIRY')
          .firstOrNull
          ?.date,
    );
  }

  @override
  Future<ArchiveBox> createBox({
    required String name,
    required BoxColor color,
    required BoxIcon icon,
  }) async {
    final json = await _client.post(
      '/boxes',
      body: {
        'name': name.trim(),
        'color': _colorCodes[color],
        'icon': _iconCodes[icon],
      },
    );
    return _boxOf(json);
  }

  ArchiveBox _boxOf(JsonMap json) {
    return ArchiveBox(
      id: json.id('boxId'),
      name: json.string('name'),
      color: _byCode(_colorCodes, json.stringOrNull('color')) ?? BoxColor.gray,
      icon: _byCode(_iconCodes, json.stringOrNull('icon')) ?? BoxIcon.package,
      documentCount: json.integerOrNull('documentCount') ?? 0,
      nextDueDate: _dateOf(json.mapOrNull('nearestDeadline')),
    );
  }

  BoxDocument _documentOf(JsonMap json) {
    return BoxDocument(
      id: json.id('documentId'),
      title: json.string('title'),
      importance: _importanceOf(json),
      pageCount: json.integerOrNull('pageCount') ?? 1,
      dueDate: _dateOf(json.mapOrNull('nextDeadline')),
    );
  }

  // 분석 중인 서류는 중요도가 아직 없어 낮음으로 둡니다.
  DocumentImportance _importanceOf(JsonMap json) =>
      switch (json.mapOrNull('priority')?.stringOrNull('level')) {
        'HIGH' => DocumentImportance.high,
        'MEDIUM' => DocumentImportance.medium,
        _ => DocumentImportance.low,
      };

  /// 응답에 박스 id가 없을 때 이름만으로 만든 박스. 아이콘·색은 기본값입니다.
  ArchiveBox _unknownBox(JsonMap json) => ArchiveBox(
    id: '',
    name: json.mapOrNull('box')?.stringOrNull('name') ?? '',
    color: BoxColor.gray,
    icon: BoxIcon.package,
    documentCount: 0,
  );

  /// 항목 값을 화면에 보일 글자로 바꿉니다. 값이 없으면 null.
  String? _valueOf(JsonMap field) {
    return switch (field.stringOrNull('valueType')) {
      'AMOUNT' => switch (field.integerOrNull('value')) {
        final amount? => '${_withCommas(amount)}원',
        null => null,
      },
      'DATE' => switch (field.stringOrNull('value')) {
        final value? => _dotDate(parseApiDate(value)),
        null => null,
      },
      _ =>
        field.stringOrNull('value') ?? field.integerOrNull('value')?.toString(),
    };
  }

  /// 항목 이름. 서버가 이름(`label`)을 주면 그대로, 아니면 아는 키의 이름을 씁니다.
  String _fieldLabelOf(JsonMap field) {
    final key = field.stringOrNull('key') ?? '';
    return field.stringOrNull('label') ?? _fieldLabels[key] ?? key;
  }

  static String _withCommas(int amount) => amount.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );

  static String _dotDate(DateTime date) =>
      '${date.year}.${date.month.toString().padLeft(2, '0')}.'
      '${date.day.toString().padLeft(2, '0')}';

  /// AI 정리본에서 서류 항목 표의 이름.
  static const _fieldsTitle = '주요 항목';

  /// 서류 항목 키의 화면 이름. 서버가 이름을 주지 않을 때 씁니다.
  static const _fieldLabels = {
    'deposit': '보증금',
    'monthlyRent': '월 임대료',
    'contractStartDate': '계약 시작일',
    'contractEndDate': '계약 종료일',
    'earlyTerminationFee': '중도 해지 위약금',
  };

  /// 기한 종류의 화면 이름. 예: "납부 12.3까지"
  static const _deadlineLabels = {'PAYMENT': '납부', 'EXPIRY': '만기'};

  DateTime? _dateOf(JsonMap? deadline) => switch (deadline) {
    final deadline? => parseApiDate(deadline.string('date')),
    null => null,
  };

  T? _byCode<T>(Map<T, String> codes, String? code) {
    for (final MapEntry(:key, :value) in codes.entries) {
      if (value == code) return key;
    }
    return null;
  }

  static const _colorCodes = {
    BoxColor.peach: 'PEACH',
    BoxColor.green: 'GREEN',
    BoxColor.gray: 'GRAY',
  };

  /// 새 박스 만들기(05)의 아이콘 12개와 서버 아이콘 키.
  ///
  /// 명세의 키 이름은 디자인 에셋에 맞춰 확정 전입니다. 여행·생활·택배는 명세에 같은
  /// 뜻의 키가 없어 가장 가까운 키(기타·경조사·쇼핑)에 맞춰 두었습니다.
  static const _iconCodes = {
    BoxIcon.home: 'HOME',
    BoxIcon.car: 'CAR',
    BoxIcon.tax: 'RECEIPT',
    BoxIcon.health: 'HEART',
    BoxIcon.telecom: 'WIFI',
    BoxIcon.work: 'BRIEFCASE',
    BoxIcon.education: 'BOOK',
    BoxIcon.pet: 'PET',
    BoxIcon.travel: 'ETC',
    BoxIcon.life: 'GIFT',
    BoxIcon.bank: 'CARD',
    BoxIcon.package: 'CART',
  };
}
