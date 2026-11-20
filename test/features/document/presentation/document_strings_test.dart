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

    test('월 임대료가 없으면 이름만, 있으면 금액과 원을 붙여 보여 준다', () {
      expect(DocumentStrings.rentSummary(null), '월 임대료');
      expect(DocumentStrings.rentSummary(500000), '월 임대료 500,000원');
    });

    test('보관함과 문서 종류를 넣으면 빗금으로 이어 보여 준다', () {
      expect(
        DocumentStrings.documentPath('집 · 임대', '임대차계약서'),
        '집 · 임대 / 임대차계약서',
      );
    });

    test('납부일을 넣으면 "매월 n일"로 보여 준다', () {
      expect(DocumentStrings.monthlyDay(25), '매월 25일');
    });

    test('날짜를 넣으면 앞자리 0 없이 점으로 이어 보여 준다', () {
      expect(DocumentStrings.date(DateTime(2027, 1, 2)), '2027.1.2');
    });

    test('다음 알림 안내를 만들면 다음 알림과 기기 알림 안내를 두 줄로 묶는다', () {
      expect(
        DocumentStrings.nextAlertNotice(DateTime(2026, 11, 24, 9)),
        '다음 알림: 11월 24일 오전 9:00\n${DocumentStrings.deviceNotice}',
      );
    });

    test('다음 알림 시각을 넣으면 날짜와 시각을 한 줄로 보여 준다', () {
      expect(
        DocumentStrings.nextAlert(DateTime(2026, 11, 24, 9)),
        '다음 알림: 11월 24일 오전 9:00',
      );
    });
  });
}
