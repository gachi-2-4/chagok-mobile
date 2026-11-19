import 'package:flutter/painting.dart';

/// 차곡 디자인 시스템의 그림자 토큰.
abstract final class AppShadows {
  /// 스위치 손잡이 그림자.
  static const toggleKnob = [
    BoxShadow(color: Color(0x26000000), offset: Offset(0, 1), blurRadius: 3),
  ];

  /// 확인 대화상자 그림자.
  static const dialog = [
    BoxShadow(color: Color(0x2E000000), offset: Offset(0, 8), blurRadius: 24),
  ];
}
