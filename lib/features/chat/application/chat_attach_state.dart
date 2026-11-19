import 'package:chagok_mobile/features/chat/data/chat_document.dart';

/// 대화에 서류 추가 화면(H02)의 상태.
class ChatAttachState {
  const ChatAttachState({
    required this.documents,
    this.selectedId,
    this.isSaving = false,
  });

  /// 고를 수 있는 서류.
  final List<ChatDocument> documents;
  final String? selectedId;
  final bool isSaving;

  ChatDocument? get selected {
    for (final document in documents) {
      if (document.id == selectedId) return document;
    }
    return null;
  }

  bool get canAttach => selected != null && !isSaving;

  ChatAttachState copyWith({String? selectedId, bool? isSaving}) {
    return ChatAttachState(
      documents: documents,
      selectedId: selectedId ?? this.selectedId,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
