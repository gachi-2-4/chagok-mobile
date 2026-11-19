import 'package:chagok_mobile/features/document/data/document_detail.dart';
import 'package:chagok_mobile/features/document/data/payment_reminder.dart';

/// 납부일 알림 화면(D02)의 상태.
class ReminderEditState {
  const ReminderEditState({
    required this.detail,
    required this.reminder,
    this.isSaving = false,
  });

  /// 알림을 거는 서류.
  final DocumentDetail detail;
  final PaymentReminder reminder;
  final bool isSaving;

  /// 미리 알림을 하나 이상 골라야 등록할 수 있습니다.
  bool get canSave => reminder.advanceDays.isNotEmpty && !isSaving;

  ReminderEditState copyWith({PaymentReminder? reminder, bool? isSaving}) {
    return ReminderEditState(
      detail: detail,
      reminder: reminder ?? this.reminder,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
