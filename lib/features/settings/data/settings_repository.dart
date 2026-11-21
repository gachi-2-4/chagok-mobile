import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_config.dart';
import 'package:chagok_mobile/core/network/device_id.dart';
import 'package:chagok_mobile/core/network/token_storage.dart';
import 'package:chagok_mobile/features/settings/data/api_settings_repository.dart';
import 'package:chagok_mobile/features/settings/data/app_settings.dart';
import 'package:chagok_mobile/features/settings/data/in_memory_settings_repository.dart';
import 'package:chagok_mobile/features/settings/data/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 설정과 내 계정 정보를 다루는 창구.
abstract interface class SettingsRepository {
  /// 저장한 앱 설정. 저장한 적이 없으면 기본값.
  Future<AppSettings> fetchSettings();

  /// [settings]를 저장합니다.
  Future<void> saveSettings(AppSettings settings);

  /// 로그인한 사용자 정보.
  Future<UserProfile> fetchProfile();

  /// 로그아웃합니다.
  Future<void> logOut();

  /// 계정과 보관한 서류를 모두 지웁니다.
  Future<void> deleteAccount();
}

/// 앱 전역 [SettingsRepository].
///
/// API 서버 주소가 있으면 서버에, 없으면 메모리에 설정을 둡니다.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  if (!ref.watch(isApiEnabledProvider)) return InMemorySettingsRepository();
  return ApiSettingsRepository(
    client: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
    deviceId: ref.watch(deviceIdProvider),
  );
});
