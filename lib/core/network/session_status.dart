/// 로그인 상태.
enum SessionStatus {
  /// 앱을 막 열어 기기에 저장한 토큰을 확인하는 중. 시작 화면을 보여 줍니다.
  checking,

  /// 토큰이 있어 서버 API를 부를 수 있습니다.
  signedIn,

  /// 토큰이 없어 로그인해야 합니다.
  signedOut,
}
