/// 보관한 서류 하나에서 읽어 낸 주요 조건.
class DocumentDetail {
  const DocumentDetail({
    required this.id,
    required this.boxName,
    required this.documentType,
    this.monthlyRent,
    this.paymentDay,
    this.contractEndDate,
    this.earlyTerminationPenalty,
  });

  final String id;

  /// 서류가 담긴 보관함 이름. 예: "집 · 임대"
  final String boxName;

  /// 예: "임대차계약서"
  final String documentType;

  /// 월 임대료(원).
  final int? monthlyRent;

  /// 매월 납부일(1~31).
  final int? paymentDay;

  final DateTime? contractEndDate;

  /// 중도 해지 위약금. 원본 문구 그대로 둡니다.
  final String? earlyTerminationPenalty;
}
