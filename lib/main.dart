import 'package:chagok_mobile/app/app.dart';
import 'package:chagok_mobile/app/font_licenses.dart';
import 'package:chagok_mobile/core/network/api_config.dart';
import 'package:chagok_mobile/features/auth/data/sdk_kakao_login_client.dart';
import 'package:chagok_mobile/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();
  await _initializeFirebase();
  final appEnv = await loadAppEnv();
  await initializeKakaoSdk(appEnv['KAKAO_NATIVE_APP_KEY']?.trim() ?? '');
  runApp(
    ProviderScope(
      overrides: [appEnvProvider.overrideWithValue(appEnv)],
      child: const ChagokApp(),
    ),
  );
}

/// Firebase에는 Android·iOS 앱만 등록했으므로 웹·데스크톱에서는 초기화를 건너뜁니다.
///
/// 다른 플랫폼에서 `DefaultFirebaseOptions.currentPlatform`을 부르면 예외가 나서
/// 앱이 뜨지 않기 때문입니다.
Future<void> _initializeFirebase() async {
  final isFirebasePlatform =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  if (!isFirebasePlatform) {
    return;
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
