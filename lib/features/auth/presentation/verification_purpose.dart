/// 전화번호 인증을 어떤 흐름에서 하는지.
enum VerificationPurpose {
  /// 회원가입(A02). 인증하면 약관 동의로 갑니다.
  signUp,

  /// 비밀번호 찾기(L04). 인증하면 새 비밀번호 만들기로 갑니다.
  passwordReset,
}
