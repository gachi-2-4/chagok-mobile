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

  /// 고른 서류 id. 아직 고르지 않았으면 null.
  final String? selectedId;

  /// 서류를 대화에 연결하는 중이면 true.
  final bool isSaving;

  /// 마지막으로 서류를 연결하려다 실패했으면 true.
  final bool hasAttachFailed;

  /// [selectedId]에 맞는 서류. 고르지 않았거나 목록에 없으면 null.
  ChatDocument? get selected {
    for (final document in documents) {
      if (document.id == selectedId) return document;
    }
    return null;
  }

  /// 서류를 골랐고 연결하는 중이 아니면 true.
  bool get canAttach => selected != null && !isSaving;

  /// 넘긴 값만 바꾼 새 상태를 돌려줍니다. 서류 목록은 그대로 둡니다.
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
