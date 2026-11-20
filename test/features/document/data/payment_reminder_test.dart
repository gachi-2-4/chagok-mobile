import 'package:chagok_mobile/features/document/data/payment_reminder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaymentReminder.advanceDays', () {
    test('생성자에 넘긴 집합을 나중에 바꾸면 알림의 미리 알림은 그대로다', () {
      final days = {0, 1};
      final reminder = PaymentReminder(
        documentId: 'lease',
        paymentDay: 25,
        advanceDays: days,
      );

      days.clear();

      expect(reminder.advanceDays, {0, 1});
    });

    test('copyWith에 넘긴 집합을 나중에 바꾸면 새 알림의 미리 알림은 그대로다', () {
      final days = {3};
      final reminder = PaymentReminder(
        documentId: 'lease',
        paymentDay: 25,
      ).copyWith(advanceDays: days);

      days.add(7);

      expect(reminder.advanceDays, {3});
    });

    test('advanceDays에 날을 더하려 하면 UnsupportedError가 난다', () {
      final reminder = PaymentReminder(documentId: 'lease', paymentDay: 25);

      expect(() => reminder.advanceDays.add(7), throwsUnsupportedError);
    });
  });
}
