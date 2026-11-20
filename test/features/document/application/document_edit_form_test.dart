import 'package:chagok_mobile/features/document/application/document_edit_form.dart';
import 'package:chagok_mobile/features/document/data/document_detail.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final detail = DocumentDetail(
    id: 'lease',
    boxName: '집 · 임대',
    documentType: '임대차계약서',
    monthlyRent: 500000,
    paymentDay: 25,
    contractEndDate: DateTime(2027, 1, 2),
    earlyTerminationPenalty: '월세의 10%',
  );

  group('DocumentEditForm', () {
    test('저장된 내용으로 만들면 입력값이 그 내용으로 채워진다', () {
      final form = DocumentEditForm.from(detail);

      expect(form.monthlyRentText, '500000');
      expect(form.penaltyText, '월세의 10%');
    });

    test('월 임대료 칸이 비어 있으면 잘못된 값으로 보지 않고 null로 읽는다', () {
      final form = DocumentEditForm.from(detail).copyWith(monthlyRentText: '');

      expect(form.monthlyRent, isNull);
      expect(form.hasInvalidMonthlyRent, isFalse);
      expect(form.canSave, isTrue);
    });

    test('입력값으로 서류를 만들면 공백뿐인 위약금은 null로 둔다', () {
      final form = DocumentEditForm.from(detail)
          .copyWith(monthlyRentText: '550,000', penaltyText: '  ');

      final updated = form.toDetail();

      expect(updated.id, 'lease');
      expect(updated.monthlyRent, 550000);
      expect(updated.earlyTerminationPenalty, isNull);
    });

    test('저장하는 중이면 저장할 수 없다', () {
      final form = DocumentEditForm.from(detail).copyWith(isSaving: true);

      expect(form.canSave, isFalse);
    });
  });
}
