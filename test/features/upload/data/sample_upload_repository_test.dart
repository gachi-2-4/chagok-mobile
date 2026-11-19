import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/sample_upload_repository.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SampleUploadRepository', () {
    test('PDF를 고르면 3페이지, 사진을 고르면 1페이지로 돌려준다', () async {
      final repository = SampleUploadRepository();

      final pdf = await repository.pick(UploadSource.pdf);
      final photo = await repository.pick(UploadSource.album);

      expect(pdf?.pageCount, 3);
      expect(photo?.pageCount, 1);
    });

    test('카메라 사진을 분석하면 처음에만 흐리다고 알린다', () async {
      final repository = SampleUploadRepository();
      final photo = await repository.pick(UploadSource.camera);

      final first = await repository.analyze(photo!);
      final second = await repository.analyze(photo);

      expect(first, isA<AnalysisUnclear>());
      expect(second, isA<AnalysisSucceeded>());
    });
  });
}
