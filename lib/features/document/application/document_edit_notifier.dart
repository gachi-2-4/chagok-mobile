import 'package:chagok_mobile/features/document/application/document_edit_form.dart';
import 'package:chagok_mobile/features/document/data/document_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 고를 수 있는 서류 종류. 예: "임대차계약서"
final documentTypesProvider = Provider<List<String>>((ref) {
  return ref.watch(documentRepositoryProvider).documentTypes;
});

/// 서류 하나의 내용 수정 입력값. 화면을 벗어나면 버립니다.
final documentEditProvider = AsyncNotifierProvider.autoDispose
    .family<DocumentEditNotifier, DocumentEditForm, String>(
      DocumentEditNotifier.new,
    );

/// 서류 내용을 불러와 고치고 저장합니다.
class DocumentEditNotifier extends AsyncNotifier<DocumentEditForm> {
  DocumentEditNotifier(this.documentId);

  final String documentId;

  @override
  Future<DocumentEditForm> build() async {
    final detail = await ref
        .watch(documentRepositoryProvider)
        .fetchDetail(documentId);
    return DocumentEditForm.from(detail);
  }

  /// 문서 종류를 바꿉니다.
  void updateDocumentType(String value) =>
      _update((form) => form.copyWith(documentType: value));

  /// 월 임대료 입력값을 바꿉니다.
  void updateMonthlyRent(String value) =>
      _update((form) => form.copyWith(monthlyRentText: value));

  /// 매월 납부일을 바꿉니다. [value]는 1~31입니다.
  void updatePaymentDay(int value) {
    RangeError.checkValueInInterval(value, 1, 31, 'value');
    _update((form) => form.copyWith(paymentDay: value));
  }

  /// 계약 종료일을 바꿉니다.
  void updateContractEndDate(DateTime value) =>
      _update((form) => form.copyWith(contractEndDate: value));

  /// 중도 해지 위약금 입력값을 바꿉니다.
  void updatePenalty(String value) =>
      _update((form) => form.copyWith(penaltyText: value));

  /// 고친 내용을 저장합니다. 저장했으면 true.
  ///
  /// 저장하지 못하면 고친 내용은 그대로 두고 [DocumentEditForm.hasSaveFailed]를 켭니다.
  Future<bool> save() async {
    final form = state.value;
    if (form == null || !form.canSave) return false;
    state = AsyncData(form.copyWith(isSaving: true, hasSaveFailed: false));
    try {
      await ref.read(documentRepositoryProvider).updateDetail(form.toDetail());
      if (ref.mounted) state = AsyncData(form.copyWith(hasSaveFailed: false));
      return true;
    } catch (error, stackTrace) {
      debugPrint('서류 내용을 저장하지 못했습니다: $error\n$stackTrace');
      if (ref.mounted) state = AsyncData(form.copyWith(hasSaveFailed: true));
      return false;
    }
  }

  void _update(DocumentEditForm Function(DocumentEditForm form) change) {
    final form = state.value;
    if (form != null) state = AsyncData(change(form));
  }
}
