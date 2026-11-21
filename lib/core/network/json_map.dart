/// 서버가 주고받는 JSON 객체.
typedef JsonMap = Map<String, Object?>;

/// [JsonMap]에서 타입을 확인하며 값을 꺼냅니다.
///
/// 값이 없거나 타입이 다르면 [FormatException]을 던져, 서버 응답이 명세와 다를 때
/// 엉뚱한 값으로 화면을 그리지 않고 바로 알 수 있게 합니다. `...OrNull`은
/// 값이 null이거나 없을 때 null을 돌려줍니다.
extension JsonMapReader on JsonMap {
  /// 문자열 값.
  String string(String key) => stringOrNull(key) ?? (throw _missing(key));

  /// 문자열 값. 없으면 null.
  String? stringOrNull(String key) => _read<String>(key);

  /// 정수 값. 서버의 숫자는 정수·실수 모두 받습니다.
  int integer(String key) => integerOrNull(key) ?? (throw _missing(key));

  /// 정수 값. 없으면 null.
  int? integerOrNull(String key) => _read<num>(key)?.toInt();

  /// 참·거짓 값. 없으면 [fallback].
  bool boolean(String key, {bool fallback = false}) =>
      _read<bool>(key) ?? fallback;

  /// 객체 값.
  JsonMap map(String key) => mapOrNull(key) ?? (throw _missing(key));

  /// 객체 값. 없으면 null.
  JsonMap? mapOrNull(String key) => _read<JsonMap>(key);

  /// 객체 목록. 없으면 빈 목록.
  List<JsonMap> maps(String key) => [
    for (final item in _read<List<Object?>>(key) ?? const <Object?>[])
      asJsonMap(item),
  ];

  /// 문자열 목록. 없으면 빈 목록.
  List<String> strings(String key) => [
    for (final item in _read<List<Object?>>(key) ?? const <Object?>[])
      if (item is String) item else throw FormatException('$key: $item'),
  ];

  /// 정수 목록. 없으면 빈 목록.
  List<int> integers(String key) => [
    for (final item in _read<List<Object?>>(key) ?? const <Object?>[])
      if (item is num) item.toInt() else throw FormatException('$key: $item'),
  ];

  /// 숫자 ID를 문자열로 꺼냅니다. 서버 ID는 숫자이고 앱 모델의 id는 문자열입니다.
  String id(String key) => integer(key).toString();

  /// 숫자 ID를 문자열로 꺼냅니다. 없으면 null.
  String? idOrNull(String key) => integerOrNull(key)?.toString();

  T? _read<T>(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value case final T typed) return typed;
    throw FormatException('$key: $T 값이 아닙니다 ($value)');
  }

  FormatException _missing(String key) => FormatException('$key: 값이 없습니다');
}

/// [value]가 JSON 객체이면 [JsonMap]으로 돌려주고, 아니면 [FormatException]을 던집니다.
JsonMap asJsonMap(Object? value) {
  if (value is Map<String, Object?>) return value;
  throw FormatException('JSON 객체가 아닙니다: $value');
}

/// 서버의 숫자 ID. 앱 모델의 문자열 id를 서버로 보낼 때 씁니다.
///
/// 숫자가 아니면 [FormatException]을 던집니다.
int apiId(String id) => int.parse(id);
