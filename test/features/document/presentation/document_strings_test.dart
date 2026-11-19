import 'package:chagok_mobile/features/document/presentation/document_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DocumentStrings', () {
    test('금액을 넣으면 세 자리마다 쉼표로 끊는다', () {
      expect(DocumentStrings.amount(500000), '500,000');
      expect(DocumentStrings.amount(1234567), '1,234,567');
      expect(DocumentStrings.amount(999), '999');
    });

    test('알림 시각을 넣으면 오전·오후 12시간제로 보여 준다', () {
      expect(DocumentStrings.time(9 * 60), '오전 9:00');
      expect(DocumentStrings.time(14 * 60 + 5), '오후 2:05');
      expect(DocumentStrings.time(0), '오전 12:00');
    });

    test('미리 알림이 0일이면 "당일"로 보여 준다', () {
      expect(DocumentStrings.advanceDay(0), '당일');
      expect(DocumentStrings.advanceDay(3), '3일 전');
    });

    test('다음 알림 시각을 넣으면 날짜와 시각을 한 줄로 보여 준다', () {
      expect(
        DocumentStrings.nextAlert(DateTime(2026, 11, 24, 9)),
        '다음 알림: 11월 24일 오전 9:00',
      );
    });
  });
}
