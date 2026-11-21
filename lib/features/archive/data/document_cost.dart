/// 서류에 적힌 대표 금액. 예: 보증금 230,000,000원
class DocumentCost {
  const DocumentCost({required this.label, required this.amount});

  /// 금액의 이름. 예: "보증금", "관리비"
  final String label;

  /// 금액(원).
  final int amount;
}
