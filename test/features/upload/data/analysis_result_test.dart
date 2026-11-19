import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/extracted_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalysisSucceeded', () {
    const result = AnalysisSucceeded(
      documentType: '임대차계약서',
      pageCount: 1,
      fields: [
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
  });
}
