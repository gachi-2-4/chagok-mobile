/// 찾는 서류가 어느 보관함에도 없을 때 던지는 예외.
class BoxDocumentNotFoundException implements Exception {
  const BoxDocumentNotFoundException(this.documentId);

  /// 찾지 못한 서류 id.
  final String documentId;

  @override
  String toString() => 'BoxDocumentNotFoundException: $documentId';
}
