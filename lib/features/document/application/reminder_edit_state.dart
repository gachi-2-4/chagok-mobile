import 'package:chagok_mobile/features/document/data/document_detail.dart';
import 'package:chagok_mobile/features/document/data/payment_reminder.dart';

/// 납부일 알림 화면(D02)의 상태.
class ReminderEditState {
  const ReminderEditState({
    required this.detail,
    required this.reminder,
    this.isSaving = false,
    this.hasSaveFailed = false,
  });

  /// 알림을 거는 서류.
  final DocumentDetail detail;

  /// 고치고 있는 알림.
  final PaymentReminder reminder;

  /// 등록하는 중이면 true.
  final bool isSaving;

  /// 마지막으로 등록하려다 실패했으면 true.
  final bool hasSaveFailed;

  /// 미리 알림을 하나 이상 골라야 등록할 수 있습니다.
  bool get canSave => reminder.advanceDays.isNotEmpty && !isSaving;

  /// 넘긴 값만 바꾼 새 상태를 돌려줍니다. 서류는 그대로 둡니다.
  ReminderEditState copyWith({
    PaymentReminder? reminder,
    bool? isSaving,
    bool? hasSaveFailed,
  }) {
    return ReminderEditState(
      detail: detail,
      reminder: reminder ?? this.reminder,
      isSaving: isSaving ?? this.isSaving,
      hasSaveFailed: hasSaveFailed ?? this.hasSaveFailed,
    );
  }
}
