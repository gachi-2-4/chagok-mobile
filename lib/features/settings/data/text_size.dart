/// 앱 글자 크기 단계.
enum TextSize {
  /// 보통. 기기 글자 크기 그대로.
  normal(scale: 1),

  /// 크게.
  large(scale: 1.15),

  /// 아주 크게.
  extraLarge(scale: 1.3);

  const TextSize({required this.scale});

  /// 기본 글자 크기에 곱하는 배율.
  final double scale;
}
