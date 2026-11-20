import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/extracted_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalysisSucceeded', () {
    final result = AnalysisSucceeded(
      documentType: '임대차계약서',
      pageCount: 1,
      fields: const [
        ExtractedField(label: '월 임대료', value: '500,000원', originalLabel: '월세'),
        ExtractedField(label: '중도 해지 위약금'),
      ],
    );

    test('값을 읽지 못한 조건이 있으면 그 조건만 골라낸다', () {
      expect(result.uncertainFields.map((field) => field.label), ['중도 해지 위약금']);
    });

    test('원본과 다른 이름으로 정리한 조건이 있으면 그 조건만 골라낸다', () {
      expect(result.renamedFields.map((field) => field.originalLabel), ['월세']);
    });

    test('생성자에 넘긴 목록을 나중에 바꾸면 분석 결과의 조건은 그대로다', () {
      final original = [const ExtractedField(label: '납부일', value: '매월 25일')];
      final succeeded = AnalysisSucceeded(
        documentType: '임대차계약서',
        pageCount: 1,
        fields: original,
      );

      original.add(const ExtractedField(label: '위약금'));

      expect(succeeded.fields, hasLength(1));
      expect(succeeded.uncertainFields, isEmpty);
    });

    test('fields에 조건을 더하려 하면 UnsupportedError가 난다', () {
      expect(
        () => result.fields.add(const ExtractedField(label: '위약금')),
        throwsUnsupportedError,
      );
    });
  });
}
