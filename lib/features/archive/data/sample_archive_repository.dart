import 'package:chagok_mobile/features/archive/data/archive_box.dart';
import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_document.dart';
import 'package:chagok_mobile/features/archive/data/box_document_not_found_exception.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:chagok_mobile/features/archive/data/box_not_found_exception.dart';
import 'package:chagok_mobile/features/archive/data/document_importance.dart';
import 'package:chagok_mobile/features/archive/data/document_search_result.dart';

/// 백엔드가 정해지기 전까지 화면을 확인하려고 쓰는 예시 보관함.
///
/// 검색은 메모리에 둔 본문에서 찾고, 쉬운 말 번역은 미리 적어 둔 설명을 돌려줍니다.
///
/// 기한은 "처음 가져온 날부터 며칠 뒤"로 적어 두어, 언제 앱을 열어도 비슷하게
/// 보입니다. 기준 날은 처음 가져올 때 한 번만 정해, 앱을 켜 둔 채 날짜가 바뀌면
/// 실제 기한처럼 D-n이 하루씩 줄어듭니다. 새로 만든 보관함은 앱을 끄기 전까지
/// 메모리에 남습니다.
class SampleArchiveRepository implements ArchiveRepository {
  final _boxes = <_SampleBox>[
    const _SampleBox(
      id: 'housing',
      name: '집 · 임대',
      color: BoxColor.peach,
      icon: BoxIcon.home,
      documents: [
        // 서류 내용 수정 화면의 예시 서류와 같은 id를 써서 눌러 열 수 있게 합니다.
        _SampleDocument(
          id: 'lease',
          content: '임대인과 임차인은 아래 부동산에 대하여 전세 계약을 맺는다. 보증금은 2억 원으로 하며 계약 기간은 2년이다. 임차인은 계약이 끝나기 1개월 전까지 갱신 여부를 알려야 한다.',
          plainLanguage: '집주인에게 보증금 2억 원을 맡기고 2년 동안 사는 계약이에요. 계약이 끝나기 한 달 전까지 계속 살지 집주인에게 알려 주세요. 알리지 않으면 같은 조건으로 계약이 이어질 수 있어요.',
          title: '전세 임대차 계약서',
          importance: DocumentImportance.high,
          pageCount: 4,
          dueInDays: 46,
        ),
        _SampleDocument(
          id: 'maintenance-fee',
          content: '11월분 관리비 청구 내역. 일반관리비, 청소비, 승강기 유지비, 수선유지비, 세대 전기료와 수도료를 포함한다. 납부 기한 경과 시 연체료가 부과된다.',
          plainLanguage: '11월 한 달 동안 아파트를 쓰면서 나온 관리비예요. 청소·엘리베이터·전기·수도 요금이 모두 들어 있어요. 날짜 안에 내지 않으면 돈을 더 내야 해요.',
          title: '11월 관리비 고지서',
          importance: DocumentImportance.medium,
          dueInDays: 13,
        ),
        _SampleDocument(
          id: 'move-in-report',
          content: '전입신고가 처리되었음을 확인한다. 신고인의 새 주소지로 주민등록이 이전되었으며 확정일자가 부여되었다.',
          plainLanguage: '새 집 주소로 이사했다고 나라에 알린 것이 끝났다는 확인서예요. 확정일자도 받아서, 나중에 보증금을 돌려받을 권리가 지켜져요.',
          title: '전입신고 확인서',
          importance: DocumentImportance.low,
        ),
      ],
    ),
    const _SampleBox(
      id: 'car',
      name: '자동차',
      color: BoxColor.green,
      icon: BoxIcon.car,
      documents: [
        _SampleDocument(
          id: 'car-insurance',
          content: '피보험자동차에 대한 대인배상, 대물배상, 자기신체사고, 자기차량손해를 보장한다. 보험기간 중 사고 발생 시 지체 없이 보험회사에 알려야 한다.',
          plainLanguage: '차 사고가 났을 때 다친 사람, 부서진 물건, 내 몸, 내 차를 보험으로 처리해 준다는 증서예요. 사고가 나면 바로 보험회사에 연락해 주세요.',
          title: '자동차 보험 증권',
          importance: DocumentImportance.medium,
          pageCount: 2,
        ),
        _SampleDocument(
          id: 'car-registration',
          content: '자동차의 차명, 차대번호, 최초등록일, 소유자 정보를 기재한다. 소유자 변경 시 15일 이내에 이전등록을 신청해야 한다.',
          plainLanguage:
              '이 차가 누구 것인지 나라에 등록했다는 증명서예요. 차를 팔거나 사면 15일 안에 주인 이름을 바꿔야 해요.',
          title: '자동차 등록증',
          importance: DocumentImportance.low,
        ),
      ],
    ),
    const _SampleBox(
      id: 'tax',
      name: '세금',
      color: BoxColor.gray,
      icon: BoxIcon.tax,
      documents: [
        _SampleDocument(
          id: 'income-tax',
          content: '종합소득세 확정신고서. 사업소득과 근로소득을 합산하여 과세표준을 계산하며 신고 기한 내 납부하지 않으면 가산세가 부과된다.',
          plainLanguage:
              '작년에 번 돈을 모두 합쳐서 세금을 계산한 서류예요. 정해진 날까지 내지 않으면 세금을 더 내야 해요.',
          title: '종합소득세 신고서',
          importance: DocumentImportance.high,
          pageCount: 3,
          dueInDays: 19,
        ),
        _SampleDocument(
          id: 'property-tax',
          content:
              '주택분 재산세 고지서. 과세기준일 현재 주택 소유자에게 부과하며 납부 기한은 7월과 9월로 나누어 정한다.',
          plainLanguage: '집을 가진 사람이 내는 세금 안내서예요. 7월과 9월, 두 번에 나눠서 내요.',
          title: '재산세 고지서',
          importance: DocumentImportance.medium,
        ),
      ],
    ),
    const _SampleBox(
      id: 'health',
      name: '병원 · 보험',
      color: BoxColor.green,
      icon: BoxIcon.health,
      documents: [
        _SampleDocument(
          id: 'medical-claim',
          content: '실손의료보험 보험금 청구 안내. 진료비 영수증과 진료비 세부내역서를 제출하면 본인부담금 중 보장 대상 금액을 지급한다.',
          plainLanguage: '병원비를 보험으로 돌려받는 방법을 알려 주는 안내서예요. 병원 영수증과 진료비 세부내역서를 보험회사에 내면 낸 돈의 일부를 돌려받을 수 있어요.',
          title: '실손보험 청구 안내',
          importance: DocumentImportance.high,
          dueInDays: 8,
        ),
        _SampleDocument(
          id: 'health-checkup',
          content:
              '국가건강검진 결과 통보서. 혈압, 혈당, 콜레스테롤 수치와 판정 결과 및 생활습관 개선 권고 사항을 포함한다.',
          plainLanguage:
              '건강검진에서 잰 혈압·혈당·콜레스테롤 결과예요. 어떤 생활 습관을 바꾸면 좋은지도 적혀 있어요.',
          title: '건강검진 결과지',
          importance: DocumentImportance.low,
          pageCount: 6,
        ),
      ],
    ),
    const _SampleBox(
      id: 'telecom',
      name: '통신 · 구독',
      color: BoxColor.peach,
      icon: BoxIcon.telecom,
      documents: [
        _SampleDocument(
          id: 'telecom-bill',
          content: '이동통신 서비스 이용요금 명세서. 기본료, 부가서비스 이용료, 단말기 할부금과 할인 내역을 포함하며 자동이체로 출금된다.',
          plainLanguage: '휴대폰 요금이 얼마 나왔는지 보여 주는 명세서예요. 기본 요금, 부가 서비스, 휴대폰 할부금이 들어 있고 통장에서 자동으로 빠져나가요.',
          title: '통신 요금 명세서',
          importance: DocumentImportance.medium,
        ),
      ],
    ),
  ];

  var _createdCount = 0;

  /// 예시 기한을 셀 기준 날. 처음 가져올 때 그날 0시로 정하고 바꾸지 않습니다.
  DateTime? _anchor;

  DateTime _anchorFor(DateTime today) =>
      _anchor ??= DateTime(today.year, today.month, today.day);

  @override
  Future<List<ArchiveBox>> fetchBoxes(DateTime today) async {
    final anchor = _anchorFor(today);
    return [for (final box in _boxes) box.toArchiveBox(anchor, today)];
  }

  @override
  Future<ArchiveBox> fetchBox(String boxId, DateTime today) async {
    return _find(boxId).toArchiveBox(_anchorFor(today), today);
  }

  @override
  Future<List<BoxDocument>> fetchDocuments(String boxId, DateTime today) async {
    return [
      for (final document in _find(boxId).documents)
        document.toBoxDocument(_anchorFor(today)),
    ];
  }

  @override
  Future<List<DocumentSearchResult>> searchDocuments(
    String query,
    DateTime today,
  ) async {
    final keyword = _normalize(query);
    if (keyword.isEmpty) return [];
    return [
      for (final box in _boxes)
        for (final document in box.documents)
          if (_normalize(document.title).contains(keyword) ||
              _normalize(document.content).contains(keyword))
            DocumentSearchResult(
              document: document.toBoxDocument(_anchorFor(today)),
              boxName: box.name,
            ),
    ];
  }

  @override
  Future<String> translateToPlainLanguage(String documentId) async {
    for (final box in _boxes) {
      for (final document in box.documents) {
        if (document.id == documentId) return document.plainLanguage;
      }
    }
    throw BoxDocumentNotFoundException(documentId);
  }

  @override
  Future<ArchiveBox> createBox({
    required String name,
    required BoxColor color,
    required BoxIcon icon,
  }) async {
    _createdCount++;
    final box = _SampleBox(
      id: 'new-box-$_createdCount',
      name: name,
      color: color,
      icon: icon,
      documents: const [],
    );
    _boxes.add(box);
    // 빈 보관함이라 기한이 없으므로 기준 날짜는 결과에 영향을 주지 않습니다.
    return box.toArchiveBox(DateTime(0), DateTime(0));
  }

  /// "임대차계약서"로 "임대차 계약서"도 찾도록 공백을 빼고 소문자로 바꿉니다.
  static String _normalize(String text) =>
      text.replaceAll(RegExp(r'\s+'), '').toLowerCase();

  _SampleBox _find(String boxId) {
    for (final box in _boxes) {
      if (box.id == boxId) return box;
    }
    throw BoxNotFoundException(boxId);
  }
}

class _SampleBox {
  const _SampleBox({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.documents,
  });

  final String id;
  final String name;
  final BoxColor color;
  final BoxIcon icon;
  final List<_SampleDocument> documents;

  /// [anchor]부터 센 기한 중 [today] 이후 가장 가까운 것을 담아 돌려줍니다.
  ArchiveBox toArchiveBox(DateTime anchor, DateTime today) {
    final todayDate = DateTime(today.year, today.month, today.day);
    final upcoming = [
      for (final document in documents)
        if (document.dueDateFrom(anchor) case final dueDate?
            when !dueDate.isBefore(todayDate))
          dueDate,
    ]..sort();

    return ArchiveBox(
      id: id,
      name: name,
      color: color,
      icon: icon,
      documentCount: documents.length,
      nextDueDate: upcoming.firstOrNull,
    );
  }
}

class _SampleDocument {
  const _SampleDocument({
    required this.id,
    required this.title,
    required this.content,
    required this.plainLanguage,
    required this.importance,
    this.pageCount = 1,
    this.dueInDays,
  });

  final String id;
  final String title;

  /// 원본에서 읽어 낸 본문. 검색할 때 씁니다.
  final String content;

  /// AI가 쉬운 말로 바꿨다고 가정한 설명.
  final String plainLanguage;
  final DocumentImportance importance;
  final int pageCount;

  /// 기준 날부터 기한까지의 날 수. 기한이 없으면 null.
  final int? dueInDays;

  /// 기한 날짜. 서머타임 경계에서 어긋나지 않도록 달력 날짜로 셉니다.
  DateTime? dueDateFrom(DateTime anchor) {
    final dueInDays = this.dueInDays;
    if (dueInDays == null) return null;
    return DateTime(anchor.year, anchor.month, anchor.day + dueInDays);
  }

  BoxDocument toBoxDocument(DateTime anchor) => BoxDocument(
    id: id,
    title: title,
    importance: importance,
    pageCount: pageCount,
    dueDate: dueDateFrom(anchor),
  );
}
