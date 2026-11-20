import 'package:chagok_mobile/features/document/data/payment_reminder.dart';

/// 납부일 알림 날짜 계산.
abstract final class ReminderSchedule {
  /// [now] 뒤로 가장 먼저 울릴 알림 시각. 미리 알림을 고르지 않았으면 null.
  ///
  /// 매월 반복을 끄면 오늘(당일 포함) 이후 첫 납부일 하나만 보고, 그 납부일의
  /// 알림이 모두 지났으면 null을 돌려줍니다.
  static DateTime? nextAlert(PaymentReminder reminder, DateTime now) {
    if (reminder.advanceDays.isEmpty) return null;

    if (!reminder.isMonthly) {
      final today = DateTime(now.year, now.month, now.day);
      var dueDate = paymentDate(now.year, now.month, reminder);
      if (dueDate.isBefore(today)) {
        dueDate = paymentDate(now.year, now.month + 1, reminder);
      }
      return _alertsAfter(reminder, dueDate, now).firstOrNull;
    }

    // 이번 달부터 차례로 보며, 가장 늦은 미리 알림(7일 전)도 넘어가지 않게
    // 두 달 뒤까지 확인합니다.
    for (var offset = 0; offset <= 2; offset++) {
      final dueDate = paymentDate(now.year, now.month + offset, reminder);
      final alerts = _alertsAfter(reminder, dueDate, now);
      if (alerts.isNotEmpty) return alerts.first;
    }
    return null;
  }

  /// [dueDate] 납부일의 알림 가운데 [now] 뒤에 울릴 것을 이른 순서로 돌려줍니다.
  static List<DateTime> _alertsAfter(
    PaymentReminder reminder,
    DateTime dueDate,
    DateTime now,
  ) {
    final hour = reminder.minuteOfDay ~/ 60;
    final minute = reminder.minuteOfDay % 60;
    return [
      for (final days in reminder.advanceDays)
        DateTime(dueDate.year, dueDate.month, dueDate.day - days, hour, minute),
    ].where((alert) => alert.isAfter(now)).toList()..sort();
  }

  /// [year]년 [month]월의 납부일. 그달에 없는 날(31일 등)은 마지막 날로 맞춥니다.
  static DateTime paymentDate(int year, int month, PaymentReminder reminder) {
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = reminder.paymentDay > lastDay ? lastDay : reminder.paymentDay;
    return DateTime(year, month, day);
  }
}
