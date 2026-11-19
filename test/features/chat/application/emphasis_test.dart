import 'package:chagok_mobile/features/chat/application/emphasis.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('splitEmphasis', () {
    test('강조 표시가 없으면 글 전체를 보통 글자 하나로 돌려준다', () {
      final parts = splitEmphasis('안녕하세요');

      expect(parts, [(text: '안녕하세요', isBold: false)]);
    });

    test('** 사이에 글자가 있으면 그 글자만 굵게 나눈다', () {
      final parts = splitEmphasis('매월 **25일**까지');

      expect(parts, [
        (text: '매월 ', isBold: false),
        (text: '25일', isBold: true),
        (text: '까지', isBold: false),
      ]);
    });

    test('강조가 여러 번 나오면 모두 나눈다', () {
      final parts = splitEmphasis('**25일**까지 **500,000원**');

      expect(parts, [
        (text: '25일', isBold: true),
        (text: '까지 ', isBold: false),
        (text: '500,000원', isBold: true),
      ]);
    });

    test('**의 짝이 맞지 않으면 글자 그대로 둔다', () {
      final parts = splitEmphasis('별표 **하나만');

      expect(parts, [(text: '별표 **하나만', isBold: false)]);
    });

    test('빈 글이면 빈 목록을 돌려준다', () {
      expect(splitEmphasis(''), isEmpty);
    });
  });
}
