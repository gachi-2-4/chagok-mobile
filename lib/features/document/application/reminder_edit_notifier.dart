import 'package:chagok_mobile/features/document/application/reminder_edit_state.dart';
import 'package:chagok_mobile/features/document/data/document_repository.dart';
import 'package:chagok_mobile/features/document/data/payment_reminder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 서류 하나의 납부일 알림 입력값. 화면을 벗어나면 버립니다.
final reminderEditProvider = AsyncNotifierProvider.autoDispose
    .family<ReminderEditNotifier, ReminderEditState, String>(
      ReminderEditNotifier.new,
    );

/// 납부일 알림을 불러와 고치고 등록합니다.
///
/// 아직 건 알림이 없으면 서류의 납부일로 기본 알림(오전 9시, 당일·1일 전)을
/// 채워 둡니다.
class ReminderEditNotifier extends AsyncNotifier<ReminderEditState> {
  ReminderEditNotifier(this.documentId);

  final String documentId;

  /// 서류에 납부일이 없을 때 쓰는 날.
  static const _fallbackPaymentDay = 1;

  @override
  Future<ReminderEditState> build() async {
    final repository = ref.watch(documentRepositoryProvider);
    final detail = await repository.fetchDetail(documentId);
    final reminder =
        await repository.fetchReminder(documentId) ??
        PaymentReminder(
          documentId: documentId,
          paymentDay: detail.paymentDay ?? _fallbackPaymentDay,
        );
    return ReminderEditState(detail: detail, reminder: reminder);
  }

  /// 매월 납부일을 바꿉니다. [value]는 1~31입니다.
  void setPaymentDay(int value) {
    RangeError.checkValueInInterval(value, 1, 31, 'value');
    _update((reminder) => reminder.copyWith(paymentDay: value));
  }

  /// 알림 시각을 바꿉니다. [hour]는 0~23, [minute]는 0~59입니다.
  void setTime({required int hour, required int minute}) {
    RangeError.checkValueInInterval(hour, 0, 23, 'hour');
    RangeError.checkValueInInterval(minute, 0, 59, 'minute');
    _update((reminder) => reminder.copyWith(minuteOfDay: hour * 60 + minute));
  }

  /// 미리 알림 하나를 켜거나 끕니다. [days]는 0(당일), 1, 3, 7 중 하나입니다.
  void toggleAdvanceDay(int days) {
    _update((reminder) {
      final selected = {...reminder.advanceDays};
      if (!selected.remove(days)) selected.add(days);
      return reminder.copyWith(advanceDays: selected);
    });
  }

  /// 매월 반복 여부를 바꿉니다.
  void setMonthly({required bool isMonthly}) =>
      _update((reminder) => reminder.copyWith(isMonthly: isMonthly));

  /// 알림을 등록합니다. 등록했으면 true.
  ///
  /// 등록하지 못하면 고친 알림은 그대로 두고 [ReminderEditState.hasSaveFailed]를 켭니다.
  Future<bool> save() async {
    final current = state.value;
    if (current == null || !current.canSave) return false;
    state = AsyncData(current.copyWith(isSaving: true, hasSaveFailed: false));
    try {
      await ref.read(documentRepositoryProvider).saveReminder(current.reminder);
      if (ref.mounted) {
        state = AsyncData(current.copyWith(hasSaveFailed: false));
      }
      return true;
    } catch (error, stackTrace) {
      debugPrint('납부일 알림을 등록하지 못했습니다: $error\n$stackTrace');
      if (ref.mounted) state = AsyncData(current.copyWith(hasSaveFailed: true));
      return false;
    }
  }

  void _update(PaymentReminder Function(PaymentReminder reminder) change) {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(reminder: change(current.reminder)));
    }
  }
}
