import 'package:chagok_mobile/features/document/data/document_detail.dart';

/// 서류 내용 수정 화면(D01)의 입력값.
class DocumentEditForm {
  const DocumentEditForm({
    required this.original,
    required this.documentType,
    required this.monthlyRentText,
    required this.paymentDay,
    required this.contractEndDate,
    required this.penaltyText,
    this.isSaving = false,
    this.hasSaveFailed = false,
  });

  /// 저장된 서류 내용으로 입력값을 채웁니다.
  factory DocumentEditForm.from(DocumentDetail detail) {
    return DocumentEditForm(
      original: detail,
      documentType: detail.documentType,
      monthlyRentText: detail.monthlyRent?.toString() ?? '',
      paymentDay: detail.paymentDay,
      contractEndDate: detail.contractEndDate,
      penaltyText: detail.earlyTerminationPenalty ?? '',
    );
  }

  /// 수정하기 전 서류 내용.
  final DocumentDetail original;

  /// 문서 종류. 예: "임대차계약서"
  final String documentType;

  /// 월 임대료 입력값. 숫자 사이 쉼표는 무시합니다.
  final String monthlyRentText;

  /// 매월 납부일(1~31). 고르지 않았으면 null.
  final int? paymentDay;

  /// 계약 종료일. 고르지 않았으면 null.
  final DateTime? contractEndDate;

  /// 중도 해지 위약금 입력값.
  final String penaltyText;

  /// 저장하는 중이면 true.
  final bool isSaving;

  /// 마지막으로 저장하려다 실패했으면 true.
  final bool hasSaveFailed;

  /// 월 임대료를 숫자로 바꾼 값. 비었거나 숫자가 아니면 null.
  int? get monthlyRent => int.tryParse(monthlyRentText.replaceAll(',', ''));

  /// 월 임대료 칸에 숫자가 아닌 값이 있으면 true.
  bool get hasInvalidMonthlyRent =>
      monthlyRentText.trim().isNotEmpty && monthlyRent == null;

  /// 월 임대료가 올바르고 저장하는 중이 아니면 true.
  bool get canSave => !hasInvalidMonthlyRent && !isSaving;

  /// 입력값으로 만든 새 서류 내용.
  DocumentDetail toDetail() {
    final penalty = penaltyText.trim();
    return DocumentDetail(
      id: original.id,
      boxName: original.boxName,
      documentType: documentType,
      monthlyRent: monthlyRent,
      paymentDay: paymentDay,
      contractEndDate: contractEndDate,
      earlyTerminationPenalty: penalty.isEmpty ? null : penalty,
    );
  }

  /// 넘긴 값만 바꾼 새 입력값을 돌려줍니다. 수정 전 내용은 그대로 둡니다.
  DocumentEditForm copyWith({
    String? documentType,
    String? monthlyRentText,
    int? paymentDay,
    DateTime? contractEndDate,
    String? penaltyText,
    bool? isSaving,
    bool? hasSaveFailed,
  }) {
    return DocumentEditForm(
      original: original,
      documentType: documentType ?? this.documentType,
      monthlyRentText: monthlyRentText ?? this.monthlyRentText,
      paymentDay: paymentDay ?? this.paymentDay,
      contractEndDate: contractEndDate ?? this.contractEndDate,
      penaltyText: penaltyText ?? this.penaltyText,
      isSaving: isSaving ?? this.isSaving,
      hasSaveFailed: hasSaveFailed ?? this.hasSaveFailed,
    );
  }
}
