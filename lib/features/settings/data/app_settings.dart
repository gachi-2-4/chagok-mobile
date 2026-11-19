import 'package:chagok_mobile/features/settings/data/text_size.dart';

/// 사용자가 고른 앱 설정.
class AppSettings {
  const AppSettings({
    this.textSize = TextSize.normal,
    this.isPaymentReminderOn = true,
    this.isMarketingOn = false,
    this.reminderMinuteOfDay = defaultReminderMinuteOfDay,
  });

  /// 기본 알림 시각: 오전 9시.
  static const defaultReminderMinuteOfDay = 9 * 60;

  /// 앱 글자 크기.
  final TextSize textSize;

  /// 관리비·공과금 납부일 알림.
  final bool isPaymentReminderOn;

  /// 이벤트·새 소식 수신.
  final bool isMarketingOn;

  /// 알림을 보낼 시각. 자정부터 지난 분(0~1439)입니다.
  final int reminderMinuteOfDay;

  /// 알림을 하나라도 받고 있으면 true.
  bool get hasAnyNotificationOn => isPaymentReminderOn || isMarketingOn;

  /// 넘긴 값만 바꾼 새 설정을 돌려줍니다.
  AppSettings copyWith({
    TextSize? textSize,
    bool? isPaymentReminderOn,
    bool? isMarketingOn,
    int? reminderMinuteOfDay,
  }) {
    return AppSettings(
      textSize: textSize ?? this.textSize,
      isPaymentReminderOn: isPaymentReminderOn ?? this.isPaymentReminderOn,
      isMarketingOn: isMarketingOn ?? this.isMarketingOn,
      reminderMinuteOfDay: reminderMinuteOfDay ?? this.reminderMinuteOfDay,
    );
  }

  /// 저장할 때 쓰는 JSON.
  Map<String, Object> toJson() {
    return {
      'textSize': textSize.name,
      'isPaymentReminderOn': isPaymentReminderOn,
      'isMarketingOn': isMarketingOn,
      'reminderMinuteOfDay': reminderMinuteOfDay,
    };
  }

  /// 저장해 둔 JSON에서 설정을 되살립니다. 없거나 모르는 값은 기본값을 씁니다.
  factory AppSettings.fromJson(Map<String, Object?> json) {
    const defaults = AppSettings();
    return AppSettings(
      textSize: TextSize.values.firstWhere(
        (size) => size.name == json['textSize'],
        orElse: () => defaults.textSize,
      ),
      isPaymentReminderOn:
          json['isPaymentReminderOn'] as bool? ?? defaults.isPaymentReminderOn,
      isMarketingOn: json['isMarketingOn'] as bool? ?? defaults.isMarketingOn,
      reminderMinuteOfDay:
          json['reminderMinuteOfDay'] as int? ?? defaults.reminderMinuteOfDay,
    );
  }
}
