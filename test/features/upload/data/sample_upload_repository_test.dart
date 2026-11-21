import 'dart:typed_data';

import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/picked_document.dart';
import 'package:chagok_mobile/features/upload/data/sample_upload_repository.dart';
import 'package:chagok_mobile/features/upload/data/upload_file.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SampleUploadRepository', () {
    test('기기 선택 함수를 넘기면 그 함수로 서류를 고르고 흐림 안내 없이 분석한다', () async {
      final picked = PickedDocument(
        fileName: 'scan-1.jpg',
        source: UploadSource.camera,
        pageCount: 1,
        files: [UploadFile(fileName: 'scan-1.jpg', bytes: Uint8List(3))],
      );
      final repository = SampleUploadRepository(pick: (_) async => picked);

      final document = await repository.pick(UploadSource.camera);
      final result = await repository.analyze(picked, boxId: 'housing');

      expect(document, same(picked));
      expect(result, isA<AnalysisSucceeded>());
    });

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

      final first = await repository.analyze(photo!, boxId: 'housing');
      final second = await repository.analyze(photo, boxId: 'housing');

      expect(first, isA<AnalysisUnclear>());
      expect(second, isA<AnalysisSucceeded>());
    });
  });
}
