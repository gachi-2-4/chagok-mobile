import 'package:chagok_mobile/features/document/application/reminder_schedule.dart';
import 'package:chagok_mobile/features/document/data/payment_reminder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReminderSchedule.nextAlert', () {
    const reminder = PaymentReminder(documentId: 'lease', paymentDay: 25);

    test('이번 달 납부일 하루 전 오전 9시가 가장 먼저 울린다', () {
      final next = ReminderSchedule.nextAlert(
        reminder,
        DateTime(2026, 11, 18, 10),
      );

      expect(next, DateTime(2026, 11, 24, 9));
    });

    test('하루 전 알림이 지났으면 당일 알림을 돌려준다', () {
      final next = ReminderSchedule.nextAlert(
        reminder,
        DateTime(2026, 11, 24, 10),
      );

      expect(next, DateTime(2026, 11, 25, 9));
    });

    test('이번 달 알림이 모두 지났으면 다음 달로 넘어간다', () {
      final next = ReminderSchedule.nextAlert(
        reminder,
        DateTime(2026, 11, 25, 10),
      );

      expect(next, DateTime(2026, 12, 24, 9));
    });

    test('미리 알림을 고르지 않았으면 null을 돌려준다', () {
      final next = ReminderSchedule.nextAlert(
        reminder.copyWith(advanceDays: {}),
        DateTime(2026, 11, 18),
      );

      expect(next, isNull);
    });

    test('7일 전 알림은 달을 거슬러 올라가도 계산한다', () {
      const early = PaymentReminder(
        documentId: 'lease',
        paymentDay: 3,
        advanceDays: {7},
      );

      final next = ReminderSchedule.nextAlert(early, DateTime(2026, 11, 20));

      expect(next, DateTime(2026, 11, 26, 9));
    });
  });

  group('ReminderSchedule.paymentDate', () {
    test('그달에 없는 날은 마지막 날로 맞춘다', () {
      const reminder = PaymentReminder(documentId: 'lease', paymentDay: 31);

      expect(
        ReminderSchedule.paymentDate(2026, 2, reminder),
        DateTime(2026, 2, 28),
      );
    });
  });
}
