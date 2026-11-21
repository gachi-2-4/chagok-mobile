/// AI 정리본 표의 한 줄. 예: 임대인 · 김○○
class SummaryRow {
  const SummaryRow({required this.label, required this.value});

  /// 예: "보증금"
  final String label;

  /// 예: "230,000,000원"
  final String value;
}
