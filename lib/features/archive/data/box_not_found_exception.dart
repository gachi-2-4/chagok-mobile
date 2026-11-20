/// 찾는 보관함이 없을 때 던지는 예외.
class BoxNotFoundException implements Exception {
  const BoxNotFoundException(this.boxId);

  /// 찾지 못한 보관함 id.
  final String boxId;

  @override
  String toString() => 'BoxNotFoundException: $boxId';
}
