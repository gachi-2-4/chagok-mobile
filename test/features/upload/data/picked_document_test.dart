import 'dart:typed_data';

import 'package:chagok_mobile/features/upload/data/document_preview.dart';
import 'package:chagok_mobile/features/upload/data/picked_document.dart';
import 'package:chagok_mobile/features/upload/data/upload_file.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PickedDocument', () {
    test('넘긴 파일 목록을 나중에 고치면 서류의 파일은 바뀌지 않는다', () {
      final files = [UploadFile(fileName: '1.jpg', bytes: Uint8List(1))];
      final document = PickedDocument(
        fileName: '1.jpg',
        source: UploadSource.album,
        pageCount: 1,
        preview: DocumentPreview(title: '제목', section: '조항', lines: []),
        files: files,
      );

      files.add(UploadFile(fileName: '2.jpg', bytes: Uint8List(1)));

      expect(document.files.map((file) => file.fileName), ['1.jpg']);
    });
  });
}
