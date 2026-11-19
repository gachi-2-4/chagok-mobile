import 'package:chagok_mobile/features/auth/application/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthValidators.isValidPassword', () {
    test('8자 이상에 숫자와 특수문자가 있으면 통과한다', () {
      expect(AuthValidators.isValidPassword('chagok12!'), isTrue);
    });

    test('8자보다 짧으면 통과하지 못한다', () {
      expect(AuthValidators.isValidPassword('ab1!'), isFalse);
    });

    test('숫자가 없으면 통과하지 못한다', () {
      expect(AuthValidators.isValidPassword('chagok!!'), isFalse);
    });

    test('특수문자가 없으면 통과하지 못한다', () {
      expect(AuthValidators.isValidPassword('chagok123'), isFalse);
    });
  });

  group('AuthValidators.isValidPhoneNumber', () {
    test('하이픈이 있어도 휴대폰 번호면 통과한다', () {
      expect(AuthValidators.isValidPhoneNumber('010-1234-5678'), isTrue);
    });

    test('10자리 휴대폰 번호를 넣으면 통과한다', () {
      expect(AuthValidators.isValidPhoneNumber('0111234567'), isTrue);
    });

    test('01로 시작하지 않으면 통과하지 못한다', () {
      expect(AuthValidators.isValidPhoneNumber('02-123-4567'), isFalse);
    });

    test('자릿수가 모자라면 통과하지 못한다', () {
      expect(AuthValidators.isValidPhoneNumber('010123'), isFalse);
    });
  });

  group('AuthValidators.isValidBirthDate', () {
    test('점으로 구분한 실제 날짜면 통과한다', () {
      expect(AuthValidators.isValidBirthDate('1995.03.21'), isTrue);
    });

    test('없는 날짜면 통과하지 못한다', () {
      expect(AuthValidators.isValidBirthDate('2023.02.30'), isFalse);
    });

    test('8자리가 아니면 통과하지 못한다', () {
      expect(AuthValidators.isValidBirthDate('950321'), isFalse);
    });
  });

  group('AuthValidators.maskPhoneNumber', () {
    test('전화번호를 넣으면 가운데 자리를 별표로 가린다', () {
      expect(AuthValidators.maskPhoneNumber('01066453576'), '010-****-3576');
    });

    test('하이픈이 있으면 빼고 같은 형식으로 가린다', () {
      expect(AuthValidators.maskPhoneNumber('010-6645-3576'), '010-****-3576');
    });
  });

  group('AuthValidators.digitsOnly', () {
    test('숫자가 아닌 글자가 섞여 있으면 모두 뺀다', () {
      expect(AuthValidators.digitsOnly('010-1234 5678'), '01012345678');
    });
  });
}
