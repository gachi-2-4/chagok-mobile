/// 대화에 연결한 서류가 없어 질문에 답할 수 없을 때 던지는 예외.
///
/// 다시 보내도 같은 결과이므로, 화면은 다시 보내기 대신 서류를 연결하도록 안내합니다.
class ChatNoDocumentException implements Exception {
  const ChatNoDocumentException(this.threadId);

  /// 질문을 보내려던 대화 id.
  final String threadId;

  @override
  String toString() => 'ChatNoDocumentException: $threadId';
}
