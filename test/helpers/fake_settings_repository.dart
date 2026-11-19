import 'package:chagok_mobile/features/settings/data/app_settings.dart';
import 'package:chagok_mobile/features/settings/data/settings_repository.dart';
import 'package:chagok_mobile/features/settings/data/user_profile.dart';

/// 메모리에 설정을 두고 호출 횟수를 세는 가짜 [SettingsRepository].
class FakeSettingsRepository implements SettingsRepository {
  AppSettings stored = const AppSettings();
  int saveCount = 0;
  int logOutCount = 0;
  int deleteCount = 0;

  @override
  Future<AppSettings> fetchSettings() async => stored;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    saveCount++;
    stored = settings;
  }

  @override
  Future<UserProfile> fetchProfile() async =>
      const UserProfile(name: '김차곡', phoneNumber: '01011112222');

  @override
  Future<void> logOut() async => logOutCount++;

  @override
  Future<void> deleteAccount() async {
    deleteCount++;
    stored = const AppSettings();
  }
}
