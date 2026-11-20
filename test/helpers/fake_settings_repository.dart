import 'dart:async';

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

  /// 값을 넣으면 [fetchSettings]가 이 예외를 던집니다.
  Exception? loadError;

  /// 값을 넣으면 [fetchSettings]가 이것이 끝날 때까지 기다립니다.
  Completer<void>? loadGate;

  /// true면 [saveSettings]가 [pendingSaves]에 붙잡혀, 테스트가 끝낼 때까지 기다립니다.
  bool holdSaves = false;

  /// 붙잡힌 저장 요청. 요청 순서대로 쌓입니다.
  final pendingSaves = <Completer<void>>[];

  @override
  Future<AppSettings> fetchSettings() async {
    await loadGate?.future;
    if (loadError case final error?) throw error;
    return stored;
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    saveCount++;
    if (holdSaves) {
      final pending = Completer<void>();
      pendingSaves.add(pending);
      await pending.future;
    }
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
