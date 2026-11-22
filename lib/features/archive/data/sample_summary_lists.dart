import 'package:chagok_mobile/features/archive/data/summary_section.dart';

/// 서버가 아직 주지 않는 AI 정리본의 목록 구역(주요 특약·체크)을 서류 종류별 예시로 만듭니다.
///
/// 서류 상세 응답(`GET /documents/{id}`)에는 특약·체크 목록이 없어, 서버가 줄 때까지
/// 서류 종류(`docType`)에 맞는 예시를 붙입니다. 특약은 실제 서류에서 읽은 내용이
/// 아니므로 구역 이름에 "(예시)"를 붙이고, 체크는 그 종류의 서류에서 확인할 일입니다.
/// 모르는 종류면 기타(`ETC`)의 예시를 씁니다.
List<SummaryList> sampleSummaryListsOf(String? docType) {
  final (specialTerms, checks) = switch (docType) {
    'LEASE_CONTRACT' => (
      const [
        '만기 6개월~2개월 전 갱신 여부 통지',
        '반려동물은 임대인 사전 동의 후 가능',
        '원상복구는 임차인 과실 손상에 한함',
      ],
      const ['확정일자 받기', '전입신고 하기', '전세보증금 반환보증 가입 여부 확인'],
    ),
    'EMPLOYMENT_CONTRACT' => (
      const ['수습 기간 3개월, 급여는 90% 지급', '연장 근로는 미리 합의한 뒤 진행'],
      const ['근로계약서 사본 받기', '4대 보험 가입 확인', '시급이 최저임금 이상인지 확인'],
    ),
    'SERVICE_CONTRACT' => (
      const ['약정 기간 안에 해지하면 위약금 발생', '약정이 끝나면 같은 조건으로 자동 연장'],
      const ['중도 해지 위약금 확인', '자동 연장 여부 확인'],
    ),
    'BILL' => (
      const <String>[],
      const ['납부 기한 확인', '자동이체 신청 여부 확인', '연체료 기준 확인'],
    ),
    'NOTICE' => (const <String>[], const ['안내된 기한 안에 할 일 확인', '문의처 확인']),
    'ADVERTISEMENT' => (const <String>[], const ['광고한 조건이 실제 계약 조건과 같은지 확인']),
    _ => (const <String>[], const ['중요한 날짜와 금액 확인', '원본 서류 따로 보관']),
  };
  return [
    if (specialTerms.isNotEmpty)
      SummaryList(title: specialTermsTitle, items: specialTerms),
    SummaryList(title: checksTitle, items: checks),
  ];
}

/// 예시 특약 구역의 이름.
const specialTermsTitle = '주요 특약 (예시)';

/// 체크 구역의 이름.
const checksTitle = '체크';
