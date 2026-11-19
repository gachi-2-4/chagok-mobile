import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 앱에 넣은 폰트의 라이선스 파일. 키는 라이선스 화면에 보일 폰트 이름입니다.
const fontLicenseAssets = {
  'Figtree': 'assets/fonts/OFL-Figtree.txt',
  'Jua': 'assets/fonts/OFL-Jua.txt',
  'Noto Sans KR': 'assets/fonts/OFL-NotoSansKR.txt',
};

/// 앱에 넣은 폰트의 라이선스(OFL)를 라이선스 화면(`showLicensePage`)에 등록합니다.
///
/// OFL은 폰트를 배포할 때 라이선스를 함께 제공하도록 요구합니다.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final MapEntry(key: fontName, value: path)
        in fontLicenseAssets.entries) {
      yield LicenseEntryWithLineBreaks([
        fontName,
      ], await rootBundle.loadString(path));
    }
  });
}
