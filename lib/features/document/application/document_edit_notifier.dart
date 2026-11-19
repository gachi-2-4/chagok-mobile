import 'package:chagok_mobile/features/document/application/document_edit_form.dart';
import 'package:chagok_mobile/features/document/data/document_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  void updateDocumentType(String value) =>
      _update((form) => form.copyWith(documentType: value));

  void updateMonthlyRent(String value) =>
      _update((form) => form.copyWith(monthlyRentText: value));

  void updatePaymentDay(int value) {
    RangeError.checkValueInInterval(value, 1, 31, 'value');
    _update((form) => form.copyWith(paymentDay: value));
  }

  void updateContractEndDate(DateTime value) =>
      _update((form) => form.copyWith(contractEndDate: value));

  void updatePenalty(String value) =>
      _update((form) => form.copyWith(penaltyText: value));

  /// 고친 내용을 저장합니다. 저장했으면 true.
  Future<bool> save() async {
    final form = state.value;
    if (form == null || !form.canSave) return false;
    state = AsyncData(form.copyWith(isSaving: true));
    await ref.read(documentRepositoryProvider).updateDetail(form.toDetail());
    if (ref.mounted) state = AsyncData(form);
    return true;
  }

  void _update(DocumentEditForm Function(DocumentEditForm form) change) {
    final form = state.value;
    if (form != null) state = AsyncData(change(form));
  }
}
