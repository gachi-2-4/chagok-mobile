import 'package:chagok_mobile/features/upload/data/document_preview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DocumentPreview', () {
    test('생성자에 넘긴 목록을 나중에 바꾸면 미리 보기 줄은 그대로다', () {
      final original = ['월 임대료　500,000원'];
      final preview = DocumentPreview(
        title: '주택 임대차계약서',
        section: '제1조',
        lines: original,
      );

      original.add('납부일　매월 25일');

      expect(preview.lines, ['월 임대료　500,000원']);
    });

    test('lines에 줄을 더하려 하면 UnsupportedError가 난다', () {
      final preview = DocumentPreview(title: '제목', section: '조항', lines: []);

      expect(() => preview.lines.add('줄'), throwsUnsupportedError);
    });
  });
}
