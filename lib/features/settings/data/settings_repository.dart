import 'package:chagok_mobile/features/settings/data/app_settings.dart';
import 'package:chagok_mobile/features/settings/data/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 설정과 내 계정 정보를 다루는 창구.
abstract interface class SettingsRepository {
  Future<AppSettings> fetchSettings();

  Future<void> saveSettings(AppSettings settings);

  Future<UserProfile> fetchProfile();

  Future<void> logOut();

  /// 계정과 보관한 서류를 모두 지웁니다.
  Future<void> deleteAccount();
}

/// 백엔드가 정해지기 전까지 쓰는 메모리 저장소. 앱을 끄면 처음으로 돌아갑니다.
class InMemorySettingsRepository implements SettingsRepository {
  Map<String, Object> _settings = const AppSettings().toJson();

  @override
  Future<AppSettings> fetchSettings() async => AppSettings.fromJson(_settings);

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings.toJson();
  }

  @override
  Future<UserProfile> fetchProfile() async {
    return const UserProfile(name: '차곡 사용자', phoneNumber: '01041845036');
  }

  @override
  Future<void> logOut() async {}

  @override
  Future<void> deleteAccount() async {
    _settings = const AppSettings().toJson();
  }
}

/// 앱 전역 [SettingsRepository].
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  // TODO: 백엔드·로컬 저장소가 정해지면 실제 구현으로 바꿉니다.
  return InMemorySettingsRepository();
});
