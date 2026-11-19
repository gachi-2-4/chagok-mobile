import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTypography', () {
    test('테마의 글자 스타일은 Figtree로 그리고 한글은 Noto Sans KR로 그린다', () {
      final textTheme = AppTheme.light.textTheme;
      final styles = [
        textTheme.headlineSmall,
        textTheme.titleLarge,
        textTheme.bodyLarge,
        textTheme.bodyMedium,
        textTheme.labelLarge,
      ];

      for (final style in styles) {
        expect(style?.fontFamily, AppTypography.fontFamily);
        expect(style?.fontFamilyFallback, AppTypography.fontFamilyFallback);
      }
    });

    test('로고 스타일은 Jua로 그린다', () {
      expect(AppTypography.logo.fontFamily, 'Jua');
    });
  });
}
