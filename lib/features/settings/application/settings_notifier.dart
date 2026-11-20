import 'dart:async';

import 'package:chagok_mobile/features/settings/data/app_settings.dart';
import 'package:chagok_mobile/features/settings/data/settings_repository.dart';
import 'package:chagok_mobile/features/settings/data/text_size.dart';
import 'package:chagok_mobile/features/settings/data/user_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 설정. 글자 크기처럼 앱 전체에서 읽습니다.
final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

/// 설정 화면 위에 보이는 내 정보.
final userProfileProvider = FutureProvider<UserProfile>((ref) {
  return ref.watch(settingsRepositoryProvider).fetchProfile();
});

/// 앱 설정을 불러오고, 바꿀 때마다 저장합니다.
class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() {
    return ref.watch(settingsRepositoryProvider).fetchSettings();
  }

  /// 앱 글자 크기를 바꾸고 저장합니다. 저장했으면 true.
  Future<bool> setTextSize(TextSize value) =>
      _update((settings) => settings.copyWith(textSize: value));

  /// 납부일 알림을 켜거나 끄고 저장합니다. 저장했으면 true.
  Future<bool> setPaymentReminder({required bool isOn}) =>
      _update((settings) => settings.copyWith(isPaymentReminderOn: isOn));

  /// 마케팅 수신을 켜거나 끄고 저장합니다. 저장했으면 true.
  Future<bool> setMarketing({required bool isOn}) =>
      _update((settings) => settings.copyWith(isMarketingOn: isOn));

  /// 알림 시각을 바꿉니다. [hour]는 0~23, [minute]는 0~59입니다.
  Future<bool> setReminderTime({required int hour, required int minute}) {
    RangeError.checkValueInInterval(hour, 0, 23, 'hour');
    RangeError.checkValueInInterval(minute, 0, 59, 'minute');
    return _update(
      (settings) => settings.copyWith(reminderMinuteOfDay: hour * 60 + minute),
    );
  }

  /// 로그아웃합니다. 로그아웃했으면 true, 실패하면 false.
  Future<bool> logOut() async {
    try {
      await ref.read(settingsRepositoryProvider).logOut();
      return true;
    } catch (error, stackTrace) {
      debugPrint('로그아웃하지 못했습니다: $error\n$stackTrace');
      return false;
    }
  }

  /// 계정을 지우고 설정을 처음으로 돌립니다. 지웠으면 true, 실패하면 false.
  Future<bool> deleteAccount() async {
    try {
      await ref.read(settingsRepositoryProvider).deleteAccount();
    } catch (error, stackTrace) {
      debugPrint('회원 탈퇴하지 못했습니다: $error\n$stackTrace');
      return false;
    }
    if (ref.mounted) ref.invalidateSelf();
    return true;
  }

  /// 마지막으로 시작한 저장. 다음 저장은 이것이 끝난 뒤 시작합니다.
  Future<void> _lastSave = Future.value();

  /// 설정을 바로 바꿔 보여 주고 저장합니다. 저장했으면 true.
  ///
  /// 저장은 요청한 순서대로 하나씩 합니다. 늦게 끝난 앞선 저장이 최신 설정을
  /// 덮어쓰지 않도록, 끝났을 때 더 최근 요청이 있으면 상태는 그 요청에 맡깁니다.
  Future<bool> _update(
    AppSettings Function(AppSettings settings) change,
  ) async {
    final current = state.value;
    if (current == null) return false;
    final next = change(current);
    state = AsyncData(next);

    final previous = _lastSave;
    final done = Completer<void>();
    _lastSave = done.future;
    try {
      await previous;
      final result = await AsyncValue.guard(() async {
        await ref.read(settingsRepositoryProvider).saveSettings(next);
        return next;
      });
      final isLatest = identical(_lastSave, done.future);
      if (ref.mounted && isLatest) state = result;
      return !result.hasError;
    } finally {
      done.complete();
    }
  }
}
