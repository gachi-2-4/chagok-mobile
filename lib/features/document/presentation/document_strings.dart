/// 서류 상세 화면에 보이는 문구.
///
/// 다국어를 도입할 때 옮기기 쉽도록 한곳에 모읍니다.
abstract final class DocumentStrings {
  static const loadFailed = '서류를 불러오지 못했어요.';
  static const retry = '다시 시도';

  // D01 내용 수정
  static const editTitle = '서류 내용 수정';
  static const editDescription = '원본과 다르게 읽힌 부분을 바로잡아 주세요.';
  static const documentType = '문서 종류';
  static const monthlyRent = '월 임대료';
  static const won = '원';
  static const invalidMonthlyRent = '숫자만 입력해 주세요.';
  static const paymentDay = '납부일';
  static const contractEndDate = '계약 종료일';
  static const contractEndDateHint = '날짜 선택';
  static const penalty = '중도 해지 위약금';
  static const penaltyHint = '원본 확인 후 입력';
  static const editNote = '수정한 값은 요약과 비교 결과에 반영돼요.';
  static const saveEdit = '수정 내용 저장';
  static const viewOriginal = '원본 확인하기';
  static const saved = '수정한 내용을 저장했어요.';
  static const saveFailed = '저장하지 못했어요. 잠시 후 다시 시도해 주세요.';

  // D02 납부일 알림
  static const reminderTitle = '납부일을 알려 드릴게요';
  static const reminderTime = '알림 시간';
  static const advance = '미리 알림';
  static const monthlyRepeat = '매월 반복';
  static const deviceNotice = '기기 알림이 허용되어 있어야 받을 수 있어요.';
  static const noAdvanceSelected = '미리 알림을 하나 이상 골라 주세요.';
  static const register = '알림 등록하기';
  static const registered = '납부일 알림을 등록했어요.';
  static const registerFailed = '알림을 등록하지 못했어요. 잠시 후 다시 시도해 주세요.';

  /// 예: 500000 → "500,000"
  static String amount(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
      buffer.write(digits[index]);
    }
    return buffer.toString();
  }

  /// 예: "월 임대료 500,000원"
  static String rentSummary(int? value) =>
      value == null ? monthlyRent : '$monthlyRent ${amount(value)}$won';

  /// 예: "집 · 임대 / 임대차계약서"
  static String documentPath(String boxName, String documentType) =>
      '$boxName / $documentType';

  /// 예: 25 → "매월 25일"
  static String monthlyDay(int day) => '매월 $day일';

  /// 예: 2027-01-02 → "2027.1.2"
  static String date(DateTime value) =>
      '${value.year}.${value.month}.${value.day}';

  /// 예: 540 → "오전 9:00", 870 → "오후 2:30"
  static String time(int minuteOfDay) {
    final hour = minuteOfDay ~/ 60;
    final minute = (minuteOfDay % 60).toString().padLeft(2, '0');
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = switch (hour % 12) {
      0 => 12,
      final value => value,
    };
    return '$period $displayHour:$minute';
  }

  /// 예: 0 → "당일", 3 → "3일 전"
  static String advanceDay(int days) => days == 0 ? '당일' : '$days일 전';

  /// 예: "다음 알림: 11월 24일 오전 9:00"
  static String nextAlert(DateTime value) =>
      '다음 알림: ${value.month}월 ${value.day}일 '
      '${time(value.hour * 60 + value.minute)}';

  /// 다음 알림 시각과 기기 알림 안내를 두 줄로 묶은 문구.
  static String nextAlertNotice(DateTime value) =>
      '${nextAlert(value)}\n$deviceNotice';
}
