import 'package:flutter/material.dart';

/// 앱 테마.
///
/// 색상·글자 스타일은 위젯에서 하드코딩하지 않고 `Theme.of(context)`로 가져옵니다.
/// 디자인 시스템이 정해지면 이 파일에서 색상과 텍스트 스타일을 확장합니다.
abstract final class AppTheme {
  // TODO: 디자인 시스템이 정해지면 브랜드 색상으로 교체
  static const _seedColor = Colors.indigo;

  static ThemeData get light =>
      ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: _seedColor));

  static ThemeData get dark => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
  );
}
