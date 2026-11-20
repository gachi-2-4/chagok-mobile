/// 대화에 연결할 수 있는, 보관함에 담긴 서류.
class ChatDocument {
  const ChatDocument({
    required this.id,
    required this.name,
    required this.fileName,
  });

  final String id;

  /// 예: "임대차계약서"
  final String name;

  /// 예: "11월 관리비 고지서.pdf"
  final String fileName;
}
