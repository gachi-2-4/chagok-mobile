import 'package:chagok_mobile/app/font_licenses.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('registerFontLicenses', () {
    test('등록하면 앱에 넣은 폰트마다 OFL 라이선스가 라이선스 목록에 들어간다', () async {
      registerFontLicenses();

      final licenses = await LicenseRegistry.licenses.toList();

      for (final fontName in fontLicenseAssets.keys) {
        final entry = licenses.firstWhere(
          (license) => license.packages.contains(fontName),
        );
        final text = entry.paragraphs.map((p) => p.text).join('\n');
        expect(text, contains('SIL Open Font License'));
      }
    });
  });
}
