import 'package:chagok_mobile/core/network/json_map.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JsonMapReader', () {
    test('숫자 ID를 꺼내면 문자열로 돌려준다', () {
      const JsonMap json = {'boxId': 6};

      expect(json.id('boxId'), '6');
    });

    test('정수를 꺼낼 때 실수 값이면 정수로 바꾼다', () {
      const JsonMap json = {'amount': 500000.0};

      expect(json.integer('amount'), 500000);
    });

    test('꼭 있어야 하는 값이 null이면 FormatException을 던진다', () {
      const JsonMap json = {'title': null};

      expect(() => json.string('title'), throwsFormatException);
    });

    test('타입이 다르면 FormatException을 던진다', () {
      const JsonMap json = {'title': 3};

      expect(() => json.stringOrNull('title'), throwsFormatException);
    });

    test('목록이 없으면 빈 목록을 돌려준다', () {
      const JsonMap json = {};

      expect(json.maps('content'), isEmpty);
    });

    test('참·거짓 값이 없으면 fallback을 돌려준다', () {
      const JsonMap json = {};

      expect(json.boolean('isRead', fallback: true), isTrue);
    });
  });

  group('apiId', () {
    test('숫자가 아닌 id를 넘기면 FormatException을 던진다', () {
      expect(() => apiId('housing'), throwsFormatException);
    });
  });
}
