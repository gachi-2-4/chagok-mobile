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
import 'package:chagok_mobile/features/archive/data/document_importance.dart';
import 'package:chagok_mobile/features/archive/data/document_search_result.dart';

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

  /// 서류 상세의 AI 쉬운말 요약 카드 한 줄 요약을 돌려줍니다.
  ///
  /// 요약 카드는 분석이 끝난 뒤 따로 만들어 잠깐 없을 수 있어, 그때는 AI 문서 분석 요약을 씁니다.
  @override
  Future<String> translateToPlainLanguage(String documentId) async {
    try {
      final json = await _client.get('/documents/${apiId(documentId)}');
      return json.mapOrNull('summaryCard')?.stringOrNull('oneLineSummary') ??
          json.stringOrNull('summary') ??
          '';
    } on ApiException catch (error) {
      if (error.isNotFound) throw BoxDocumentNotFoundException(documentId);
      rethrow;
    }
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
      // 분석 중인 서류는 중요도가 아직 없어 낮음으로 둡니다.
      importance: switch (json.mapOrNull('priority')?.stringOrNull('level')) {
        'HIGH' => DocumentImportance.high,
        'MEDIUM' => DocumentImportance.medium,
        _ => DocumentImportance.low,
      },
      pageCount: json.integerOrNull('pageCount') ?? 1,
      dueDate: _dateOf(json.mapOrNull('nextDeadline')),
    );
  }

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
