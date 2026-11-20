import 'package:chagok_mobile/features/settings/data/app_settings.dart';
import 'package:chagok_mobile/features/settings/data/settings_repository.dart';
import 'package:chagok_mobile/features/settings/data/user_profile.dart';

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
