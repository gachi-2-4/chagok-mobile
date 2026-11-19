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

  final String documentType;

  /// 월 임대료 입력값. 숫자 사이 쉼표는 무시합니다.
  final String monthlyRentText;
  final int? paymentDay;
  final DateTime? contractEndDate;
  final String penaltyText;
  final bool isSaving;

  /// 월 임대료를 숫자로 바꾼 값. 비었거나 숫자가 아니면 null.
  int? get monthlyRent => int.tryParse(monthlyRentText.replaceAll(',', ''));

  /// 월 임대료 칸에 숫자가 아닌 값이 있으면 true.
  bool get hasInvalidMonthlyRent =>
      monthlyRentText.trim().isNotEmpty && monthlyRent == null;

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

  DocumentEditForm copyWith({
    String? documentType,
    String? monthlyRentText,
    int? paymentDay,
    DateTime? contractEndDate,
    String? penaltyText,
    bool? isSaving,
  }) {
    return DocumentEditForm(
      original: original,
      documentType: documentType ?? this.documentType,
      monthlyRentText: monthlyRentText ?? this.monthlyRentText,
      paymentDay: paymentDay ?? this.paymentDay,
      contractEndDate: contractEndDate ?? this.contractEndDate,
      penaltyText: penaltyText ?? this.penaltyText,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
