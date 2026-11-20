/// 서류를 찾지 못했을 때 던지는 예외.
class DocumentNotFoundException implements Exception {
  const DocumentNotFoundException(this.id);

  /// 찾으려던 서류 id.
  final String id;

  @override
  String toString() => 'DocumentNotFoundException: $id';
}
