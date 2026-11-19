/// 서류 첫 페이지를 간단히 글로 보여 주는 미리 보기.
class DocumentPreview {
  const DocumentPreview({
    required this.title,
    required this.section,
    required this.lines,
  });

  /// 예: "주택 임대차계약서"
  final String title;

  /// 예: "제1조 보증금 및 월 임대료"
  final String section;

  /// 예: ["월 임대료　500,000원", "납부일　매월 25일"]
  final List<String> lines;
}
