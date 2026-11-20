import 'package:chagok_mobile/core/utils/app_text_scaler.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTextScaler', () {
    test('기기 배율과 앱 배율이 있으면 둘을 곱해 글자 크기를 키운다', () {
      const scaler = AppTextScaler(TextScaler.linear(2), 1.5);

      expect(scaler.scale(10), 30);
    });

    test('기기 배율과 앱 배율이 같으면 같은 배율로 본다', () {
      expect(
        const AppTextScaler(TextScaler.linear(2), 1.5),
        const AppTextScaler(TextScaler.linear(2), 1.5),
      );
      expect(
        const AppTextScaler(TextScaler.linear(2), 1.5),
        isNot(const AppTextScaler(TextScaler.linear(2), 1)),
      );
    });
  });
}
