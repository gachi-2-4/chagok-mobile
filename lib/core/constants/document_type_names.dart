/// AI 문서 분석의 서류 종류(`docType`)와 화면에 보이는 이름.
///
/// 순서는 서류 종류를 고르는 목록의 순서입니다. 업로드·서류 수정 기능이 함께 씁니다.
const documentTypeNames = {
  'LEASE_CONTRACT': '임대차계약서',
  'EMPLOYMENT_CONTRACT': '근로계약서',
  'SERVICE_CONTRACT': '용역·서비스 계약',
  'BILL': '고지서·청구서',
  'NOTICE': '공지·안내문',
  'ADVERTISEMENT': '광고·홍보물',
  'ETC': '기타',
};

/// [docType]의 화면 이름. 모르는 값이거나 null이면 "기타".
String documentTypeNameOf(String? docType) =>
    documentTypeNames[docType] ?? documentTypeNames['ETC'] ?? '';
