/// 서류 하나에 건 납부일 알림.
class PaymentReminder {
  const PaymentReminder({
    required this.documentId,
    required this.paymentDay,
    this.minuteOfDay = 9 * 60,
    this.advanceDays = const {0, 1},
    this.isMonthly = true,
  });

  /// 미리 알림으로 고를 수 있는 날 수. 0은 당일입니다.
  static const advanceDayOptions = [0, 1, 3, 7];

  /// 알림을 건 서류 id.
  final String documentId;

  /// 매월 납부일(1~31). 그달에 없는 날이면 그달 마지막 날로 봅니다.
  final int paymentDay;

  /// 알림 시각. 자정부터 지난 분(0~1439)입니다.
  final int minuteOfDay;

  /// 납부일 며칠 전에 알릴지. 예: {0, 1} → 당일과 하루 전
  final Set<int> advanceDays;

  /// 매월 반복할지 여부. 끄면 다음 납부일 한 번만 알립니다.
  final bool isMonthly;

  /// 넘긴 값만 바꾼 새 알림을 돌려줍니다. 서류는 바꿀 수 없습니다.
  PaymentReminder copyWith({
    int? paymentDay,
    int? minuteOfDay,
    Set<int>? advanceDays,
    bool? isMonthly,
  }) {
    return PaymentReminder(
      documentId: documentId,
      paymentDay: paymentDay ?? this.paymentDay,
      minuteOfDay: minuteOfDay ?? this.minuteOfDay,
      advanceDays: advanceDays ?? this.advanceDays,
      isMonthly: isMonthly ?? this.isMonthly,
    );
  }
}
