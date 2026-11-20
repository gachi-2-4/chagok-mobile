/// 가입·로그인 입력값을 검사하고 다듬는 함수 모음.
abstract final class AuthValidators {
  /// 비밀번호 최소 길이.
  static const minPasswordLength = 8;

  static final _digit = RegExp(r'\d');
  // 한글 같은 영숫자 밖 글자를 특수문자로 세지 않도록 ASCII 문장부호·기호만 셉니다.
  static final _specialCharacter = RegExp(r'[!-/:-@\[-`{-~]');
  static final _nonDigit = RegExp(r'\D');
  static final _mobileNumber = RegExp(r'^01\d{8,9}$');

  /// 8자 이상이고 숫자와 특수문자를 하나 이상 포함하면 true.
  static bool isValidPassword(String password) {
    return password.length >= minPasswordLength &&
        _digit.hasMatch(password) &&
        _specialCharacter.hasMatch(password);
  }

  /// 숫자만 남깁니다. 예: "010-1234-5678" → "01012345678"
  static String digitsOnly(String input) {
    return input.replaceAll(_nonDigit, '');
  }

  /// 01로 시작하는 10~11자리 휴대폰 번호면 true. 하이픈은 무시합니다.
  static bool isValidPhoneNumber(String input) {
    return _mobileNumber.hasMatch(digitsOnly(input));
  }

  /// 숫자 8자리(YYYYMMDD)로 된 실제 날짜면 true. 점·하이픈은 무시합니다.
  static bool isValidBirthDate(String input) {
    final digits = digitsOnly(input);
    if (digits.length != 8) return false;
    final year = int.parse(digits.substring(0, 4));
    final month = int.parse(digits.substring(4, 6));
    final day = int.parse(digits.substring(6));
    final date = DateTime(year, month, day);
    return year >= 1900 &&
        date.year == year &&
        date.month == month &&
        date.day == day;
  }

  /// 가운데 자리를 가린 전화번호. 예: "01066453576" → "010-****-3576"
  static String maskPhoneNumber(String input) {
    final digits = digitsOnly(input);
    if (digits.length < 7) return digits;
    final head = digits.substring(0, 3);
    final tail = digits.substring(digits.length - 4);
    return '$head-****-$tail';
  }
}
