/// 가입할 때 동의받는 약관. 화면에 보이는 이름은 `AuthStrings.term`에 있습니다.
enum Term {
  /// 서비스 이용약관.
  service(isRequired: true),

  /// 개인정보 수집·이용.
  privacy(isRequired: true),

  /// 마케팅 수신.
  marketing(isRequired: false);

  const Term({required this.isRequired});

  /// 동의해야 가입할 수 있는 약관이면 true.
  final bool isRequired;
}
