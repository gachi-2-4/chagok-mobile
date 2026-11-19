import 'package:chagok_mobile/features/chat/data/chat_document.dart';
import 'package:chagok_mobile/features/chat/data/chat_message.dart';
import 'package:chagok_mobile/features/chat/data/chat_repository.dart';
import 'package:chagok_mobile/features/chat/data/chat_role.dart';
import 'package:chagok_mobile/features/chat/data/chat_thread.dart';
import 'package:chagok_mobile/features/chat/data/chat_thread_not_found_exception.dart';

/// 답변 API가 정해지기 전까지 화면 흐름을 확인하려고 쓰는 저장소.
///
/// 질문에 들어 있는 낱말로 정해 둔 예시 답을 고릅니다.
class SampleChatRepository implements ChatRepository {
  /// [_now]는 지금 시각을 돌려주는 함수입니다. 예시 대화 날짜를 만들 때 씁니다.
  SampleChatRepository(this._now) {
    _seed();
  }

  final DateTime Function() _now;
  final _threads = <String, ChatThread>{};
  var _nextId = 0;

  /// 새 대화를 열 때 차곡이 먼저 건네는 인사말.
  static const greeting = '안녕하세요! 이 서류에서 궁금한 내용을 쉽게 설명해\n드릴게요.';

  static const _documents = [
    ChatDocument(id: 'lease', name: '임대차계약서', fileName: '임대차계약서.pdf'),
    ChatDocument(
      id: 'maintenance',
      name: '11월 관리비 고지서',
      fileName: '11월 관리비 고지서.pdf',
    ),
    ChatDocument(id: 'telecom', name: '통신 서비스 계약서', fileName: '통신 서비스 계약서.pdf'),
    ChatDocument(id: 'car', name: '자동차 보험 계약서', fileName: '자동차 보험 계약서.pdf'),
  ];

  void _seed() {
    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    void add(String documentId, String question, DateTime at) {
      final id = 'thread-${_nextId++}';
      final document = _documents.firstWhere(
        (document) => document.id == documentId,
      );
      _threads[id] = ChatThread(
        id: id,
        document: document,
        updatedAt: at,
        messages: [
          ChatMessage(role: ChatRole.assistant, text: greeting, sentAt: at),
          ChatMessage(role: ChatRole.user, text: question, sentAt: at),
          _answer(question, document, at),
        ],
      );
    }

    add(
      'lease',
      '월세는 언제 내야 하나요?',
      today.add(const Duration(hours: 9, minutes: 41)),
    );
    add(
      'maintenance',
      '관리비가 왜 달라졌나요?',
      today.add(const Duration(hours: 9, minutes: 20)),
    );
    add('telecom', '약정 기간이 얼마나 남았나요?', today.subtract(const Duration(days: 4)));
    add('car', '보험료 납부일이 궁금해요', today.subtract(const Duration(days: 6)));
  }

  @override
  Future<List<ChatThread>> fetchThreads() async {
    return _threads.values.where((thread) => thread.title != null).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<ChatThread> fetchThread(String id) async {
    return _threads[id] ?? (throw ChatThreadNotFoundException(id));
  }

  @override
  Future<ChatThread> createThread() async {
    final now = _now();
    final thread = ChatThread(
      id: 'thread-${_nextId++}',
      document: _documents.first,
      updatedAt: now,
      messages: [
        ChatMessage(role: ChatRole.assistant, text: greeting, sentAt: now),
      ],
    );
    _threads[thread.id] = thread;
    return thread;
  }

  @override
  Future<ChatThread> sendMessage({
    required String threadId,
    required String text,
  }) async {
    final thread = await fetchThread(threadId);
    final now = _now();
    final updated = thread.copyWith(
      updatedAt: now,
      messages: [
        ...thread.messages,
        ChatMessage(role: ChatRole.user, text: text, sentAt: now),
        _answer(text, thread.document, now),
      ],
    );
    _threads[threadId] = updated;
    return updated;
  }

  @override
  Future<List<ChatDocument>> fetchDocuments() async => _documents;

  @override
  Future<ChatThread> linkDocument({
    required String threadId,
    required String documentId,
  }) async {
    final thread = await fetchThread(threadId);
    final document = _documents.firstWhere(
      (document) => document.id == documentId,
    );
    final updated = thread.copyWith(document: document);
    _threads[threadId] = updated;
    return updated;
  }

  @override
  List<String> suggestedQuestions(ChatDocument? document) {
    return switch (document?.id) {
      'maintenance' => const ['관리비가 왜 달라졌나요?', '언제까지 내야 하나요?'],
      _ => const ['언제까지 내야 하나요?', '위약금이 있나요?'],
    };
  }

  ChatMessage _answer(String question, ChatDocument? document, DateTime at) {
    if (document == null) {
      return ChatMessage(
        role: ChatRole.assistant,
        text: '먼저 대화에 서류를 추가해 주세요.',
        sentAt: at,
      );
    }
    final (text, source) = switch (question) {
      _ when question.contains('위약금') => (
        '계약 기간 안에 해지하면 **남은 기간 월세의 10%**를 내야 해요.',
        '계약서 2페이지, 특약 사항',
      ),
      _ when question.contains('관리비') => (
        '지난달보다 **난방비가 12,000원** 늘었어요.',
        '고지서 1페이지, 항목별 금액',
      ),
      _ when question.contains('약정') => (
        '약정은 **2027년 3월**까지, 넉 달 남았어요.',
        '계약서 1페이지, 약정 기간',
      ),
      _ when question.contains('언제') || question.contains('납부') => (
        '매월 **25일**까지 **500,000원**을 내면 돼요.',
        '계약서 1페이지, 납부 조건',
      ),
      _ => ('${document.name}에서 관련 내용을 찾지 못했어요. 다른 말로 물어봐 주세요.', null),
    };
    return ChatMessage(
      role: ChatRole.assistant,
      text: text,
      sentAt: at,
      source: source,
    );
  }
}
