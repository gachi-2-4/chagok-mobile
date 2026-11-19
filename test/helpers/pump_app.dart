import 'package:chagok_mobile/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension PumpApp on WidgetTester {
  /// 앱 테마를 입힌 화면 안에 [child]를 띄웁니다.
  Future<void> pumpApp(Widget child) {
    return pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: child),
      ),
    );
  }
}
