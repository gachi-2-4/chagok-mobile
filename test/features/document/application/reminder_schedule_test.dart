import 'package:chagok_mobile/features/document/application/reminder_schedule.dart';
import 'package:chagok_mobile/features/document/data/payment_reminder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReminderSchedule.nextAlert', () {
    final reminder = PaymentReminder(documentId: 'lease', paymentDay: 25);

    test('이번 달 납부일이 아직 오지 않았으면 하루 전 오전 9시가 가장 먼저 울린다', () {
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

    test('7일 전 알림이 지난달로 넘어가면 지난달 날짜로 계산한다', () {
      final early = PaymentReminder(
        documentId: 'lease',
        paymentDay: 3,
        advanceDays: {7},
      );

      final next = ReminderSchedule.nextAlert(early, DateTime(2026, 11, 20));

      expect(next, DateTime(2026, 11, 26, 9));
    });
  });

  group('ReminderSchedule.nextAlert (매월 반복 끔)', () {
    final once = PaymentReminder(
      documentId: 'lease',
      paymentDay: 25,
      isMonthly: false,
    );

    test('반복을 끄면 다음 납부일의 알림이 남았을 때 그 알림을 돌려준다', () {
      final next = ReminderSchedule.nextAlert(once, DateTime(2026, 11, 18, 10));

      expect(next, DateTime(2026, 11, 24, 9));
    });

    test('반복을 끄고 다음 납부일의 알림이 모두 지났으면 다음 달을 찾지 않고 null을 돌려준다', () {
      final weekBefore = once.copyWith(advanceDays: {7});

      final next = ReminderSchedule.nextAlert(
        weekBefore,
        DateTime(2026, 11, 20),
      );

      expect(next, isNull);
    });

    test('반복을 끄고 이번 달 납부일이 지났으면 다음 달 납부일 하나만 본다', () {
      final next = ReminderSchedule.nextAlert(once, DateTime(2026, 11, 26));

      expect(next, DateTime(2026, 12, 24, 9));
    });
  });

  group('ReminderSchedule.paymentDate', () {
    test('그달에 없는 날이면 그달 마지막 날로 맞춘다', () {
      final reminder = PaymentReminder(documentId: 'lease', paymentDay: 31);

      expect(
        ReminderSchedule.paymentDate(2026, 2, reminder),
        DateTime(2026, 2, 28),
      );
    });
  });
}
