import 'dart:async';

import 'package:chagok_mobile/features/chat/data/chat_document.dart';
import 'package:chagok_mobile/features/chat/data/chat_message.dart';
import 'package:chagok_mobile/features/chat/data/chat_repository.dart';
import 'package:chagok_mobile/features/chat/data/chat_role.dart';
import 'package:chagok_mobile/features/chat/data/chat_thread.dart';
import 'package:chagok_mobile/features/chat/data/chat_thread_not_found_exception.dart';

/// 테스트에서 쓰는 고정 시각.
final fakeNow = DateTime(2026, 11, 19, 10);

const leaseDocument = ChatDocument(
  id: 'lease',
  name: '임대차계약서',
  fileName: '임대차계약서.pdf',
);

const maintenanceDocument = ChatDocument(
  id: 'maintenance',
  name: '11월 관리비 고지서',
  fileName: '11월 관리비 고지서.pdf',
);

/// [question]을 물어본 대화를 만듭니다. [question]이 없으면 인사말만 담깁니다.
ChatThread buildThread({
  required String id,
  String? question,
  ChatDocument? document,
  DateTime? updatedAt,
}) {
  final at = updatedAt ?? fakeNow;
  return ChatThread(
    id: id,
    document: document,
    updatedAt: at,
    messages: [
      ChatMessage(role: ChatRole.assistant, text: '안녕하세요', sentAt: at),
      if (question != null)
        ChatMessage(role: ChatRole.user, text: question, sentAt: at),
    ],
  );
}

/// 메모리에 대화를 두고, 호출 기록을 남기는 [ChatRepository].
class FakeChatRepository implements ChatRepository {
  FakeChatRepository({
    List<ChatThread> threads = const [],
    this.documents = const [leaseDocument, maintenanceDocument],
  }) : threads = {for (final thread in threads) thread.id: thread};

  final Map<String, ChatThread> threads;
  final List<ChatDocument> documents;

  int fetchThreadsCount = 0;
  final sentMessages = <({String threadId, String text})>[];
  final linkedDocuments = <({String threadId, String documentId})>[];

  /// 값을 넣으면 대화·서류를 불러오는 함수가 이것이 끝날 때까지 기다립니다.
  Completer<void>? loadGate;

  /// 값을 넣으면 대화 목록·서류 목록을 불러올 때 이 예외를 던집니다.
  Exception? loadError;

  /// 값을 넣으면 [sendMessage]가 이것이 끝날 때까지 기다립니다.
  Completer<void>? sendGate;

  /// 값을 넣으면 [linkDocument]가 이것이 끝날 때까지 기다립니다.
  Completer<void>? linkGate;

  /// 값을 넣으면 [sendMessage]가 이 예외를 던집니다.
  Exception? sendError;

  /// 값을 넣으면 [linkDocument]가 이 예외를 던집니다.
  Exception? linkError;

  var _nextId = 0;

  @override
  Future<List<ChatThread>> fetchThreads() async {
    fetchThreadsCount++;
    await loadGate?.future;
    if (loadError case final error?) throw error;
    return threads.values.toList();
  }

  @override
  Future<ChatThread> fetchThread(String id) async {
    await loadGate?.future;
    return threads[id] ?? (throw ChatThreadNotFoundException(id));
  }

  @override
  Future<ChatThread> createThread() async {
    final thread = buildThread(id: 'new-${_nextId++}');
    threads[thread.id] = thread;
    return thread;
  }

  @override
  Future<ChatThread> sendMessage({
    required String threadId,
    required String text,
  }) async {
    sentMessages.add((threadId: threadId, text: text));
    await sendGate?.future;
    if (sendError case final error?) throw error;
    final thread = await fetchThread(threadId);
    final updated = thread.copyWith(
      messages: [
        ...thread.messages,
        ChatMessage(role: ChatRole.user, text: text, sentAt: fakeNow),
        ChatMessage(
          role: ChatRole.assistant,
          text: '답: $text',
          sentAt: fakeNow,
        ),
      ],
    );
    threads[threadId] = updated;
    return updated;
  }

  @override
  Future<List<ChatDocument>> fetchDocuments() async {
    await loadGate?.future;
    if (loadError case final error?) throw error;
    return documents;
  }

  @override
  Future<ChatThread> linkDocument({
    required String threadId,
    required String documentId,
  }) async {
    linkedDocuments.add((threadId: threadId, documentId: documentId));
    await linkGate?.future;
    if (linkError case final error?) throw error;
    final thread = await fetchThread(threadId);
    final document = documents.firstWhere(
      (document) => document.id == documentId,
    );
    final updated = thread.copyWith(document: document);
    threads[threadId] = updated;
    return updated;
  }

  @override
  List<String> suggestedQuestions(ChatDocument? document) {
    return [if (document != null) '${document.name}에 대해 물어보기'];
  }
}
