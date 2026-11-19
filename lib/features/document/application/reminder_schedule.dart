import 'package:chagok_mobile/features/document/data/payment_reminder.dart';

/// 납부일 알림 날짜 계산.
abstract final class ReminderSchedule {
  /// [now] 뒤로 가장 먼저 울릴 알림 시각. 미리 알림을 고르지 않았으면 null.
  static DateTime? nextAlert(PaymentReminder reminder, DateTime now) {
    if (reminder.advanceDays.isEmpty) return null;
    final hour = reminder.minuteOfDay ~/ 60;
    final minute = reminder.minuteOfDay % 60;

    // 이번 달부터 차례로 보며, 가장 늦은 미리 알림(7일 전)도 넘어가지 않게
    // 두 달 뒤까지 확인합니다.
    for (var offset = 0; offset <= 2; offset++) {
      final dueDate = paymentDate(now.year, now.month + offset, reminder);
      final alerts = [
        for (final days in reminder.advanceDays)
          DateTime(
            dueDate.year,
            dueDate.month,
            dueDate.day - days,
            hour,
            minute,
          ),
      ].where((alert) => alert.isAfter(now)).toList()..sort();
      if (alerts.isNotEmpty) return alerts.first;
    }
    return null;
  }

  /// [year]년 [month]월의 납부일. 그달에 없는 날(31일 등)은 마지막 날로 맞춥니다.
  static DateTime paymentDate(int year, int month, PaymentReminder reminder) {
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = reminder.paymentDay > lastDay ? lastDay : reminder.paymentDay;
    return DateTime(year, month, day);
  }
}
