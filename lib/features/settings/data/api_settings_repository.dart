import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_exception.dart';
import 'package:chagok_mobile/core/network/api_formats.dart';
import 'package:chagok_mobile/core/network/json_map.dart';
import 'package:chagok_mobile/core/network/token_storage.dart';
import 'package:chagok_mobile/features/settings/data/app_settings.dart';
import 'package:chagok_mobile/features/settings/data/settings_repository.dart';
import 'package:chagok_mobile/features/settings/data/text_size.dart';
import 'package:chagok_mobile/features/settings/data/user_profile.dart';
import 'package:flutter/foundation.dart';

/// 차곡 API 서버의 USER·NOTIFICATION API로 설정과 계정을 다루는 [SettingsRepository].
///
/// 설정 하나가 서버에서는 세 곳에 나뉘어 있습니다.
/// - 글자 크기: `PATCH /user/me/preferences`
/// - 납부일 알림·기본 알림 시각: `PATCH /notifications/settings`
/// - 마케팅 수신: `POST /user/me/consents` (동의 이력을 남겨야 해서)
///
/// 그래서 마지막으로 불러오거나 저장한 설정과 비교해 바뀐 곳만 보냅니다.
class ApiSettingsRepository implements SettingsRepository {
  ApiSettingsRepository({
    required this._client,
    required this._tokenStorage,
    required this._deviceId,
  });

  final ApiClient _client;
  final TokenStorage _tokenStorage;

  /// 로그아웃할 때 이 기기의 푸시 토큰을 지우도록 넘기는 기기 ID.
  final String _deviceId;

  /// 서버에 있다고 알고 있는 설정. 아직 모르면 null이고, 그때는 모두 보냅니다.
  AppSettings? _synced;

  @override
  Future<AppSettings> fetchSettings() async {
    final [me, notification] = await Future.wait([
      _client.get('/user/me'),
      _client.get('/notifications/settings'),
    ]);
    final settings = AppSettings(
      textSize: _textSizeOf(me.stringOrNull('fontSize')),
      isPaymentReminderOn: notification.boolean(
        'deadlineAlertEnabled',
        fallback: true,
      ),
      isMarketingOn: notification.boolean('marketingAgreed'),
      reminderMinuteOfDay: switch (notification.stringOrNull(
        'defaultAlertTime',
      )) {
        final time? => parseApiTime(time),
        null => AppSettings.defaultReminderMinuteOfDay,
      },
    );
    _synced = settings;
    return settings;
  }

  /// 바뀐 곳만 서버에 보냅니다.
  ///
  /// 일부만 저장하고 실패하면 서버에 무엇이 남았는지 알 수 없으므로, 다음 저장 때
  /// 모두 다시 보내도록 기준을 비웁니다.
  @override
  Future<void> saveSettings(AppSettings settings) async {
    try {
      await _sendChanges(settings);
    } catch (_) {
      _synced = null;
      rethrow;
    }
    _synced = settings;
  }

  Future<void> _sendChanges(AppSettings settings) async {
    final synced = _synced;
    if (synced == null || synced.textSize != settings.textSize) {
      await _client.patch(
        '/user/me/preferences',
        body: {'fontSize': _textSizeCode(settings.textSize)},
      );
    }
    if (synced == null ||
        synced.isPaymentReminderOn != settings.isPaymentReminderOn ||
        synced.reminderMinuteOfDay != settings.reminderMinuteOfDay) {
      await _client.patch(
        '/notifications/settings',
        body: {
          'deadlineAlertEnabled': settings.isPaymentReminderOn,
          'defaultAlertTime': formatApiTime(settings.reminderMinuteOfDay),
        },
      );
    }
    if (synced == null || synced.isMarketingOn != settings.isMarketingOn) {
      await _client.post(
        '/user/me/consents',
        body: {'marketing': settings.isMarketingOn},
      );
    }
  }

  @override
  Future<UserProfile> fetchProfile() async {
    final json = await _client.get('/user/me');
    return UserProfile(
      name: json.stringOrNull('name') ?? '',
      // 카카오·구글 계정은 전화번호를 받지 못했으면 null입니다.
      phoneNumber: json.stringOrNull('phoneNumber') ?? '',
    );
  }

  /// 이 기기에서 로그아웃합니다.
  ///
  /// 서버에 알리지 못해도 이 기기의 토큰은 지우고 로그아웃을 마친 것으로 봅니다.
  /// 토큰이 없으면 이 기기로는 계정에 들어갈 수 없고, 화면도 로그아웃한 상태와
  /// 맞아야 하기 때문입니다. 서버의 Refresh Token은 기한이 지나면 사라집니다.
  @override
  Future<void> logOut() async {
    final tokens = await _tokenStorage.read();
    try {
      if (tokens != null) {
        // Access Token이 만료돼도 로그아웃할 수 있게, 서버는 Refresh Token으로 확인합니다.
        await _client.post(
          '/auth/logout',
          body: {'refreshToken': tokens.refreshToken, 'deviceId': _deviceId},
          isAuthenticated: false,
        );
      }
    } on ApiException catch (error) {
      debugPrint('서버에 로그아웃을 알리지 못했습니다: $error');
    } finally {
      await _clearSession();
    }
  }

  @override
  Future<void> deleteAccount() async {
    await _client.delete('/user/me');
    await _clearSession();
  }

  Future<void> _clearSession() async {
    _synced = null;
    await _tokenStorage.clear();
  }

  TextSize _textSizeOf(String? code) => switch (code) {
    'LARGE' => TextSize.large,
    'EXTRA_LARGE' => TextSize.extraLarge,
    _ => TextSize.normal,
  };

  String _textSizeCode(TextSize size) => switch (size) {
    TextSize.normal => 'NORMAL',
    TextSize.large => 'LARGE',
    TextSize.extraLarge => 'EXTRA_LARGE',
  };
}
