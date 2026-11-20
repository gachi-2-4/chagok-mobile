/// 서류 첫 페이지를 간단히 글로 보여 주는 미리 보기.
class DocumentPreview {
  /// [lines]는 복사해서 바꿀 수 없는 목록으로 보관합니다.
  /// 넘긴 목록을 나중에 고쳐도 이 미리 보기는 바뀌지 않습니다.
  DocumentPreview({
    required this.title,
    required this.section,
    required List<String> lines,
  }) : lines = List.unmodifiable(lines);

  /// 예: "주택 임대차계약서"
  final String title;

  /// 예: "제1조 보증금 및 월 임대료"
  final String section;

  /// 예: ["월 임대료　500,000원", "납부일　매월 25일"]. 바꿀 수 없습니다.
  final List<String> lines;
}
