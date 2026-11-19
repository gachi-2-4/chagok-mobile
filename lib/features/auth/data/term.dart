/// 가입할 때 동의받는 약관.
enum Term {
  service(title: '서비스 이용약관', isRequired: true),
  privacy(title: '개인정보 수집·이용', isRequired: true),
  marketing(title: '마케팅 수신', isRequired: false);

  const Term({required this.title, required this.isRequired});

  final String title;

  /// 동의해야 가입할 수 있는 약관이면 true.
  final bool isRequired;
}
