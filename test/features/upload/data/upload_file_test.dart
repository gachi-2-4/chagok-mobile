import 'dart:typed_data';

import 'package:chagok_mobile/features/upload/data/upload_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UploadFile', () {
    test('넘긴 바이트를 나중에 고치면 파일 내용은 바뀌지 않는다', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final file = UploadFile(fileName: '서류.jpg', bytes: bytes);

      bytes[0] = 9;

      expect(file.bytes, [1, 2, 3]);
    });

    test('파일 내용을 고치려 하면 UnsupportedError를 던진다', () {
      final file = UploadFile(fileName: '서류.jpg', bytes: Uint8List(1));

      expect(() => file.bytes[0] = 1, throwsUnsupportedError);
    });
  });
}
