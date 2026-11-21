/// API 명세의 날짜·시각 형식을 앱의 [DateTime]·분 값과 바꿉니다.
///
/// 명세: 일시 `2026-11-24T09:00:00+09:00`, 날짜 `2026-11-25`, 시각 `09:00`.
library;

/// 날짜를 `YYYY-MM-DD`로 바꿉니다. 시각은 버립니다.
String formatApiDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-$month-$day';
}

/// `YYYY-MM-DD`를 그날 0시(기기 시간대)로 바꿉니다.
///
/// 형식이 다르면 [FormatException]을 던집니다.
DateTime parseApiDate(String value) {
  final match = _date.firstMatch(value);
  if (match == null) throw FormatException('날짜 형식이 아닙니다: $value');
  return DateTime(
    int.parse(match.group(1) ?? ''),
    int.parse(match.group(2) ?? ''),
    int.parse(match.group(3) ?? ''),
  );
}

/// ISO-8601 일시를 기기 시간대의 [DateTime]으로 바꿉니다.
DateTime parseApiDateTime(String value) => DateTime.parse(value).toLocal();

/// 자정부터 지난 분(0~1439)을 `HH:mm`으로 바꿉니다.
String formatApiTime(int minuteOfDay) {
  final hour = (minuteOfDay ~/ 60).toString().padLeft(2, '0');
  final minute = (minuteOfDay % 60).toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// `HH:mm`을 자정부터 지난 분으로 바꿉니다.
///
/// 형식이 다르거나 범위를 벗어나면 [FormatException]을 던집니다.
int parseApiTime(String value) {
  final match = _time.firstMatch(value);
  final hour = int.tryParse(match?.group(1) ?? '');
  final minute = int.tryParse(match?.group(2) ?? '');
  if (hour == null || minute == null || hour > 23 || minute > 59) {
    throw FormatException('시각 형식이 아닙니다: $value');
  }
  return hour * 60 + minute;
}

final _date = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
final _time = RegExp(r'^(\d{2}):(\d{2})$');
