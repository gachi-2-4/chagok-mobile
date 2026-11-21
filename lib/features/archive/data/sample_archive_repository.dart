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
import 'package:chagok_mobile/features/archive/data/summary_row.dart';
import 'package:chagok_mobile/features/archive/data/summary_section.dart';

/// 백엔드가 정해지기 전까지 화면을 확인하려고 쓰는 예시 보관함.
///
/// 검색은 메모리에 둔 본문에서 찾고, AI 정리본은 미리 적어 둔 내용을 돌려줍니다.
///
/// 기한은 "처음 가져온 날부터 며칠 뒤"로 적어 두어, 언제 앱을 열어도 비슷하게
/// 보입니다. 기준 날은 처음 가져올 때 한 번만 정해, 앱을 켜 둔 채 날짜가 바뀌면
/// 실제 기한처럼 D-n이 하루씩 줄어듭니다. 새로 만든 보관함은 앱을 끄기 전까지
/// 메모리에 남습니다.
class SampleArchiveRepository implements ArchiveRepository {
  final _boxes = <_SampleBox>[
    _SampleBox(
      id: 'housing',
      name: '집 · 임대',
      color: BoxColor.peach,
      icon: BoxIcon.home,
      documents: [
        // 서류 내용 수정 화면의 예시 서류와 같은 id를 써서 눌러 열 수 있게 합니다.
        _SampleDocument(
          id: 'lease',
          title: '전세 임대차 계약서',
          content:
              '임대인과 임차인은 아래 부동산에 대하여 전세 계약을 맺는다. '
              '보증금은 2억 3천만 원으로 하며 계약 기간은 2025년 3월 1일부터 2년이다. '
              '임차인은 만기 6개월 전부터 2개월 전까지 갱신 여부를 통지한다. '
              '반려동물은 임대인의 사전 동의를 받아 기를 수 있다.',
          importance: DocumentImportance.high,
          pageCount: 4,
          dueInDays: 46,
          dueLabel: '갱신 통보',
          periodEndInDays: 108,
          cost: const DocumentCost(label: '보증금', amount: 230000000),
          summary: DocumentSummary(
            oneLine:
                '보증금 2억 3천만 원, 2025.03.01부터 2년 계약. '
                '만기 2개월 전까지 갱신 여부를 집주인에게 알려야 해요.',
            sections: [
              SummaryTable(
                title: '계약 개요',
                rows: const [
                  SummaryRow(label: '임대인', value: '김○○'),
                  SummaryRow(label: '임차인', value: '이지수'),
                  SummaryRow(label: '소재지', value: '마포구 성산동 ○○빌라 302호'),
                  SummaryRow(label: '보증금', value: '230,000,000원'),
                  // 만기일은 아래 카드에 처음 가져온 날 기준으로 보이므로,
                  // 날짜가 어긋나지 않도록 여기에는 기간만 적습니다.
                  SummaryRow(label: '계약기간', value: '2년'),
                ],
              ),
              SummaryList(
                title: '주요 특약',
                items: const [
                  '만기 6개월~2개월 전 갱신 여부 통지',
                  '반려동물은 사전 동의 후 가능',
                  '원상복구는 임차인 과실 손상에 한함',
                ],
              ),
              SummaryList(
                title: '체크',
                items: const ['확정일자 받음 (2025.02.20)', '전입신고 완료'],
              ),
            ],
          ),
        ),
        _SampleDocument(
          id: 'maintenance-fee',
          title: '11월 관리비 고지서',
          content:
              '11월분 관리비 청구 내역. 일반관리비, 청소비, 승강기 유지비, '
              '수선유지비, 세대 전기료와 수도료를 포함한다. '
              '납부 기한 경과 시 연체료가 부과된다.',
          importance: DocumentImportance.medium,
          dueInDays: 13,
          dueLabel: '납부',
          cost: const DocumentCost(label: '관리비', amount: 187400),
          summary: DocumentSummary(
            oneLine: '11월 관리비는 187,400원이에요. 기한이 지나면 연체료가 붙어요.',
            sections: [
              SummaryTable(
                title: '청구 내역',
                rows: const [
                  SummaryRow(label: '일반관리비', value: '62,000원'),
                  SummaryRow(label: '청소·승강기', value: '31,500원'),
                  SummaryRow(label: '전기·수도', value: '93,900원'),
                ],
              ),
              SummaryList(title: '체크', items: const ['자동이체 미신청']),
            ],
          ),
        ),
        _SampleDocument(
          id: 'move-in-report',
          title: '전입신고 확인서',
          content:
              '전입신고가 처리되었음을 확인한다. 신고인의 새 주소지로 '
              '주민등록이 이전되었으며 확정일자가 부여되었다.',
          importance: DocumentImportance.low,
          summary: DocumentSummary(
            oneLine: '새 집 주소로 전입신고를 마쳤고 확정일자도 받았어요.',
            sections: [
              SummaryTable(
                title: '신고 내용',
                rows: const [
                  SummaryRow(label: '신고일', value: '2025.02.20'),
                  SummaryRow(label: '새 주소', value: '마포구 성산동 ○○빌라 302호'),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
    _SampleBox(
      id: 'car',
      name: '자동차',
      color: BoxColor.green,
      icon: BoxIcon.car,
      documents: [
        _SampleDocument(
          id: 'car-insurance',
          title: '자동차 보험 증권',
          content:
              '피보험자동차에 대한 대인배상, 대물배상, 자기신체사고, '
              '자기차량손해를 보장한다. 보험기간 중 사고 발생 시 '
              '지체 없이 보험회사에 알려야 한다.',
          importance: DocumentImportance.medium,
          pageCount: 2,
          cost: const DocumentCost(label: '보험료', amount: 820000),
          summary: DocumentSummary(
            oneLine: '사고가 나면 다친 사람·물건·내 차를 보험으로 처리해 줘요.',
            sections: [
              SummaryList(
                title: '보장 내용',
                items: const ['대인배상', '대물배상', '자기신체사고', '자기차량손해'],
              ),
              SummaryList(title: '체크', items: const ['사고가 나면 바로 보험회사에 연락']),
            ],
          ),
        ),
        _SampleDocument(
          id: 'car-registration',
          title: '자동차 등록증',
          content:
              '자동차의 차명, 차대번호, 최초등록일, 소유자 정보를 기재한다. '
              '소유자 변경 시 15일 이내에 이전등록을 신청해야 한다.',
          importance: DocumentImportance.low,
          summary: DocumentSummary(
            oneLine: '이 차가 누구 것인지 등록한 증명서예요. 차를 팔면 15일 안에 이름을 바꿔요.',
            sections: [
              SummaryList(title: '체크', items: const ['소유자 변경 시 15일 안에 이전등록']),
            ],
          ),
        ),
      ],
    ),
    _SampleBox(
      id: 'tax',
      name: '세금',
      color: BoxColor.gray,
      icon: BoxIcon.tax,
      documents: [
        _SampleDocument(
          id: 'income-tax',
          title: '종합소득세 신고서',
          content:
              '종합소득세 확정신고서. 사업소득과 근로소득을 합산하여 과세표준을 '
              '계산하며 신고 기한 내 납부하지 않으면 가산세가 부과된다.',
          importance: DocumentImportance.high,
          pageCount: 3,
          dueInDays: 19,
          dueLabel: '납부',
          cost: const DocumentCost(label: '납부할 세금', amount: 1240000),
          summary: DocumentSummary(
            oneLine: '작년에 번 돈을 합쳐 계산한 세금이에요. 기한을 넘기면 가산세가 붙어요.',
            sections: [
              SummaryTable(
                title: '소득 내역',
                rows: const [
                  SummaryRow(label: '근로소득', value: '38,000,000원'),
                  SummaryRow(label: '사업소득', value: '12,500,000원'),
                ],
              ),
            ],
          ),
        ),
        _SampleDocument(
          id: 'property-tax',
          title: '재산세 고지서',
          content:
              '주택분 재산세 고지서. 과세기준일 현재 주택 소유자에게 부과하며 '
              '납부 기한은 7월과 9월로 나누어 정한다.',
          importance: DocumentImportance.medium,
          cost: const DocumentCost(label: '재산세', amount: 214000),
          summary: DocumentSummary(
            oneLine: '집을 가진 사람이 내는 세금이에요. 7월과 9월에 나눠서 내요.',
            sections: [
              SummaryList(title: '체크', items: const ['7월·9월 두 번에 나눠 납부']),
            ],
          ),
        ),
      ],
    ),
    _SampleBox(
      id: 'health',
      name: '병원 · 보험',
      color: BoxColor.green,
      icon: BoxIcon.health,
      documents: [
        _SampleDocument(
          id: 'medical-claim',
          title: '실손보험 청구 안내',
          content:
              '실손의료보험 보험금 청구 안내. 진료비 영수증과 진료비 '
              '세부내역서를 제출하면 본인부담금 중 보장 대상 금액을 지급한다.',
          importance: DocumentImportance.high,
          dueInDays: 8,
          dueLabel: '청구 마감',
          summary: DocumentSummary(
            oneLine: '병원 영수증과 세부내역서를 내면 병원비 일부를 돌려받아요.',
            sections: [
              SummaryList(
                title: '준비할 서류',
                items: const ['진료비 영수증', '진료비 세부내역서'],
              ),
            ],
          ),
        ),
        _SampleDocument(
          id: 'health-checkup',
          title: '건강검진 결과지',
          content:
              '국가건강검진 결과 통보서. 혈압, 혈당, 콜레스테롤 수치와 판정 결과 '
              '및 생활습관 개선 권고 사항을 포함한다.',
          importance: DocumentImportance.low,
          pageCount: 6,
          summary: DocumentSummary(
            oneLine: '혈압·혈당·콜레스테롤 모두 정상 범위예요.',
            sections: [
              SummaryTable(
                title: '검사 결과',
                rows: const [
                  SummaryRow(label: '혈압', value: '118/76 정상'),
                  SummaryRow(label: '공복 혈당', value: '92 정상'),
                  SummaryRow(label: '총콜레스테롤', value: '185 정상'),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
    _SampleBox(
      id: 'telecom',
      name: '통신 · 구독',
      color: BoxColor.peach,
      icon: BoxIcon.telecom,
      documents: [
        _SampleDocument(
          id: 'telecom-bill',
          title: '통신 요금 명세서',
          content:
              '이동통신 서비스 이용요금 명세서. 기본료, 부가서비스 이용료, '
              '단말기 할부금과 할인 내역을 포함하며 자동이체로 출금된다.',
          importance: DocumentImportance.medium,
          cost: const DocumentCost(label: '이번 달 요금', amount: 59400),
          summary: DocumentSummary(
            oneLine: '이번 달 휴대폰 요금은 59,400원이고 통장에서 자동으로 빠져나가요.',
            sections: [
              SummaryTable(
                title: '요금 내역',
                rows: const [
                  SummaryRow(label: '기본료', value: '49,000원'),
                  SummaryRow(label: '단말기 할부', value: '15,400원'),
                  SummaryRow(label: '할인', value: '-5,000원'),
                ],
              ),
            ],
          ),
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
  Future<DocumentOverview> fetchDocumentOverview(
    String documentId,
    DateTime today,
  ) async {
    final anchor = _anchorFor(today);
    for (final box in _boxes) {
      for (final document in box.documents) {
        if (document.id == documentId) {
          return document.toOverview(anchor, box.toArchiveBox(anchor, today));
        }
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
    required this.importance,
    required this.summary,
    this.pageCount = 1,
    this.dueInDays,
    this.dueLabel,
    this.periodEndInDays,
    this.cost,
  });

  final String id;
  final String title;

  /// 원본에서 읽어 낸 본문. 검색할 때 씁니다.
  final String content;
  final DocumentImportance importance;

  /// AI가 정리했다고 가정한 AI 정리본.
  final DocumentSummary summary;
  final int pageCount;

  /// 기준 날부터 기한까지의 날 수. 기한이 없으면 null.
  final int? dueInDays;

  /// 기한이 무슨 날인지. 예: "갱신 통보"
  final String? dueLabel;

  /// 기준 날부터 계약·이용 기간이 끝나는 날까지의 날 수. 없으면 null.
  final int? periodEndInDays;
  final DocumentCost? cost;

  /// 기한 날짜. 서머타임 경계에서 어긋나지 않도록 달력 날짜로 셉니다.
  DateTime? dueDateFrom(DateTime anchor) => _dayFrom(anchor, dueInDays);

  BoxDocument toBoxDocument(DateTime anchor) => BoxDocument(
    id: id,
    title: title,
    importance: importance,
    pageCount: pageCount,
    dueDate: dueDateFrom(anchor),
  );

  DocumentOverview toOverview(DateTime anchor, ArchiveBox box) =>
      DocumentOverview(
        document: toBoxDocument(anchor),
        box: box,
        summary: summary,
        cost: cost,
        dueLabel: dueLabel,
        periodEnd: _dayFrom(anchor, periodEndInDays),
      );

  static DateTime? _dayFrom(DateTime anchor, int? days) {
    if (days == null) return null;
    return DateTime(anchor.year, anchor.month, anchor.day + days);
  }
}
