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

  /// 앱 글자 크기를 바꾸고 저장합니다.
  Future<void> setTextSize(TextSize value) =>
      _update((settings) => settings.copyWith(textSize: value));

  /// 납부일 알림을 켜거나 끄고 저장합니다.
  Future<void> setPaymentReminder({required bool isOn}) =>
      _update((settings) => settings.copyWith(isPaymentReminderOn: isOn));

  /// 마케팅 수신을 켜거나 끄고 저장합니다.
  Future<void> setMarketing({required bool isOn}) =>
      _update((settings) => settings.copyWith(isMarketingOn: isOn));

  /// 알림 시각을 바꿉니다. [hour]는 0~23, [minute]는 0~59입니다.
  Future<void> setReminderTime({required int hour, required int minute}) {
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

  Future<void> _update(
    AppSettings Function(AppSettings settings) change,
  ) async {
    final current = state.value;
    if (current == null) return;
    final next = change(current);
    state = AsyncData(next);
    state = await AsyncValue.guard(() async {
      await ref.read(settingsRepositoryProvider).saveSettings(next);
      return next;
    });
  }
}
