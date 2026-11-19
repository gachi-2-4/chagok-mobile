/// 계정 요청이 실패한 이유. 화면에서 이유에 맞는 안내를 고릅니다.
enum AuthFailure {
  /// 이미 가입한 전화번호로 다시 가입하려 함.
  alreadyRegistered,

  /// 전화번호 또는 비밀번호가 맞지 않음.
  wrongCredentials,

  /// 가입하지 않은 전화번호.
  notRegistered,

  /// 입력한 인증번호가 보낸 번호와 다름.
  codeMismatch,

  /// 네트워크 오류 등 그 밖의 이유.
  unknown,
}
