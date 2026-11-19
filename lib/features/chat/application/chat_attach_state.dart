import 'package:chagok_mobile/features/chat/data/chat_document.dart';

/// 대화에 서류 추가 화면(H02)의 상태.
class ChatAttachState {
  const ChatAttachState({
    required this.documents,
    this.selectedId,
    this.isSaving = false,
    this.hasAttachFailed = false,
  });

  /// 고를 수 있는 서류.
  final List<ChatDocument> documents;
  final String? selectedId;
  final bool isSaving;

  /// 마지막으로 서류를 연결하려다 실패했으면 true.
  final bool hasAttachFailed;

  ChatDocument? get selected {
    for (final document in documents) {
      if (document.id == selectedId) return document;
    }
    return null;
  }

  bool get canAttach => selected != null && !isSaving;

  ChatAttachState copyWith({
    String? selectedId,
    bool? isSaving,
    bool? hasAttachFailed,
  }) {
    return ChatAttachState(
      documents: documents,
      selectedId: selectedId ?? this.selectedId,
      isSaving: isSaving ?? this.isSaving,
      hasAttachFailed: hasAttachFailed ?? this.hasAttachFailed,
    );
  }
}
