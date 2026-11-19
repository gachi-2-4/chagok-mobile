import 'package:chagok_mobile/features/document/application/reminder_edit_state.dart';
import 'package:chagok_mobile/features/document/data/document_detail.dart';
import 'package:chagok_mobile/features/document/data/payment_reminder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const detail = DocumentDetail(
    id: 'lease',
    boxName: '집 · 임대',
    documentType: '임대차계약서',
  );
  const reminder = PaymentReminder(documentId: 'lease', paymentDay: 25);

  group('ReminderEditState', () {
    test('미리 알림을 하나 이상 골랐으면 등록할 수 있다', () {
      const state = ReminderEditState(detail: detail, reminder: reminder);

      expect(state.canSave, isTrue);
    });

    test('미리 알림을 모두 껐으면 등록할 수 없다', () {
      final state = ReminderEditState(
        detail: detail,
        reminder: reminder.copyWith(advanceDays: {}),
      );

      expect(state.canSave, isFalse);
    });

    test('등록하는 중이면 등록할 수 없다', () {
      const state = ReminderEditState(
        detail: detail,
        reminder: reminder,
        isSaving: true,
      );

      expect(state.canSave, isFalse);
    });
  });

  group('PaymentReminder.copyWith', () {
    test('일부 값을 넘기면 그 값만 바꾸고 서류 id는 그대로 둔다', () {
      final updated = reminder.copyWith(isMonthly: false);

      expect(updated.documentId, 'lease');
      expect(updated.paymentDay, 25);
      expect(updated.isMonthly, isFalse);
    });
  });
}
