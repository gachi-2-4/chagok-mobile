/// 앱 글자 크기 단계.
enum TextSize {
  normal(scale: 1),
  large(scale: 1.15),
  extraLarge(scale: 1.3);

  const TextSize({required this.scale});

  /// 기본 글자 크기에 곱하는 배율.
  final double scale;
}

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

  final TextSize textSize;

  /// 관리비·공과금 납부일 알림.
  final bool isPaymentReminderOn;

  /// 이벤트·새 소식 수신.
  final bool isMarketingOn;

  /// 알림을 보낼 시각. 자정부터 지난 분(0~1439)입니다.
  final int reminderMinuteOfDay;

  /// 알림을 하나라도 받고 있으면 true.
  bool get hasAnyNotificationOn => isPaymentReminderOn || isMarketingOn;

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

  Map<String, Object> toJson() {
    return {
      'textSize': textSize.name,
      'isPaymentReminderOn': isPaymentReminderOn,
      'isMarketingOn': isMarketingOn,
      'reminderMinuteOfDay': reminderMinuteOfDay,
    };
  }

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
