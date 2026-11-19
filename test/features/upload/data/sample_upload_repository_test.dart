import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/extracted_field.dart';
import 'package:chagok_mobile/features/upload/data/sample_upload_repository.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SampleUploadRepository', () {
    test('PDF는 3페이지, 사진은 1페이지로 돌려준다', () async {
      final repository = SampleUploadRepository();

      final pdf = await repository.pick(UploadSource.pdf);
      final photo = await repository.pick(UploadSource.album);

      expect(pdf?.pageCount, 3);
      expect(photo?.pageCount, 1);
    });

    test('카메라 사진은 처음 분석에서만 흐리다고 알린다', () async {
      final repository = SampleUploadRepository();
      final photo = await repository.pick(UploadSource.camera);

      final first = await repository.analyze(photo!);
      final second = await repository.analyze(photo);

      expect(first, isA<AnalysisUnclear>());
      expect(second, isA<AnalysisSucceeded>());
    });
  });

  group('AnalysisSucceeded', () {
    const result = AnalysisSucceeded(
      documentType: '임대차계약서',
      pageCount: 1,
      fields: [
        ExtractedField(label: '월 임대료', value: '500,000원', originalLabel: '월세'),
        ExtractedField(label: '중도 해지 위약금'),
      ],
    );

    test('값을 읽지 못한 조건을 골라낸다', () {
      expect(result.uncertainFields.map((field) => field.label), ['중도 해지 위약금']);
    });

    test('원본과 다른 이름으로 정리한 조건을 골라낸다', () {
      expect(result.renamedFields.map((field) => field.originalLabel), ['월세']);
    });
  });
}
