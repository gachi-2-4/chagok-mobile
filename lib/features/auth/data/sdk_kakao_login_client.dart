import 'package:chagok_mobile/features/auth/data/kakao_login_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

/// 카카오 SDK를 [nativeAppKey]로 준비합니다. 앱을 띄우기 전에 한 번 부릅니다.
///
/// 카카오 로그인은 Android·iOS 앱에만 붙였으므로 다른 플랫폼과, 키가 없을 때는
/// 건너뜁니다. 이때 카카오 로그인을 누르면 [SdkKakaoLoginClient.logIn]이 실패합니다.
Future<void> initializeKakaoSdk(String nativeAppKey) async {
  final isSupportedPlatform =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  if (!isSupportedPlatform || nativeAppKey.isEmpty) return;
  await KakaoSdk.init(nativeAppKey: nativeAppKey);
  SdkKakaoLoginClient._isInitialized = true;
}

/// 카카오 SDK로 로그인하는 [KakaoLoginClient].
///
/// 카카오톡이 깔려 있으면 카카오톡으로, 없거나 카카오톡 로그인이 안 되면
/// 카카오계정(웹)으로 로그인합니다.
class SdkKakaoLoginClient implements KakaoLoginClient {
  /// [initializeKakaoSdk]를 마쳤는지. SDK가 준비되지 않았으면 로그인하지 않습니다.
  static bool _isInitialized = false;

  @override
  Future<String?> logIn() async {
    if (!_isInitialized) {
      throw StateError(
        '카카오 SDK가 준비되지 않았습니다. .env의 KAKAO_NATIVE_APP_KEY를 확인하세요.',
      );
    }
    try {
      if (await isKakaoTalkInstalled()) {
        try {
          return (await UserApi.instance.loginWithKakaoTalk()).accessToken;
        } on Exception catch (error) {
          // 카카오톡에서 사용자가 취소했으면 계정 로그인을 다시 띄우지 않습니다.
          if (isKakaoLoginCancelled(error)) return null;
          debugPrint('카카오톡으로 로그인하지 못해 카카오계정으로 다시 시도합니다: $error');
        }
      }
      return (await UserApi.instance.loginWithKakaoAccount()).accessToken;
    } on Exception catch (error) {
      if (isKakaoLoginCancelled(error)) return null;
      rethrow;
    }
  }
}

/// 카카오 로그인에서 사용자가 취소해서 난 [error]면 true.
///
/// SDK는 취소를 여러 모양으로 알려 줍니다. Android에서 카카오톡이나 카카오계정
/// 로그인 창을 닫으면 SDK 예외로 바꾸지 않은 `PlatformException(CANCELED)`가 옵니다.
bool isKakaoLoginCancelled(Exception error) => switch (error) {
  KakaoClientException(reason: ClientErrorCause.cancelled) => true,
  KakaoAuthException(error: AuthErrorCause.accessDenied) => true,
  PlatformException(code: 'CANCELED') => true,
  _ => false,
};
