import 'package:chagok_mobile/features/settings/data/app_settings.dart';
import 'package:chagok_mobile/features/settings/data/settings_repository.dart';
import 'package:chagok_mobile/features/settings/data/user_profile.dart';

/// 메모리에 설정을 두고 호출 횟수를 세는 가짜 [SettingsRepository].
class FakeSettingsRepository implements SettingsRepository {
  AppSettings stored = const AppSettings();
  int saveCount = 0;
  int logOutCount = 0;
  int deleteCount = 0;

  /// 값을 넣으면 [saveSettings]·[logOut]·[deleteAccount]가 이 예외를 던집니다.
  Exception? error;

  @override
  Future<AppSettings> fetchSettings() async => stored;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    saveCount++;
    if (error case final error?) throw error;
    stored = settings;
  }

  @override
  Future<UserProfile> fetchProfile() async =>
      const UserProfile(name: '김차곡', phoneNumber: '01011112222');

  @override
  Future<void> logOut() async {
    logOutCount++;
    if (error case final error?) throw error;
  }

  @override
  Future<void> deleteAccount() async {
    deleteCount++;
    if (error case final error?) throw error;
    stored = const AppSettings();
  }
}
