import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/term.dart';
import 'package:chagok_mobile/features/auth/presentation/auth_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthStrings.failure', () {
    test('실패 이유를 넣으면 이유마다 서로 다른 안내를 돌려준다', () {
      final messages = AuthFailure.values.map(AuthStrings.failure).toSet();

      expect(messages, hasLength(AuthFailure.values.length));
    });
  });

  group('AuthStrings.termLabel', () {
    test('필수 약관이면 "(필수)"를 붙인다', () {
      expect(AuthStrings.termLabel(Term.service), '서비스 이용약관 (필수)');
    });

    test('선택 약관이면 "(선택)"을 붙인다', () {
      expect(AuthStrings.termLabel(Term.marketing), '마케팅 수신 (선택)');
    });
  });
}
