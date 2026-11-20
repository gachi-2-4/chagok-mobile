/// 서류에서 읽어 낸 조건 하나. 예: 월 임대료 500,000원
class ExtractedField {
  const ExtractedField({required this.label, this.value, this.originalLabel});

  /// 정리한 이름. 예: "월 임대료"
  final String label;

  /// 읽어 낸 값. 확실히 읽지 못했으면 null.
  final String? value;

  /// 원본 서류에 쓰인 이름이 [label]과 다르면 그 이름. 예: "월세"
  final String? originalLabel;

  /// 값을 확실히 읽지 못했으면 true.
  bool get isUncertain => value == null;
}
