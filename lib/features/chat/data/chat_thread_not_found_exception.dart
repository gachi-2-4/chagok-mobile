/// 대화를 찾지 못했을 때 던지는 예외.
class ChatThreadNotFoundException implements Exception {
  const ChatThreadNotFoundException(this.id);

  /// 찾으려던 대화 id.
  final String id;

  @override
  String toString() => 'ChatThreadNotFoundException: $id';
}
