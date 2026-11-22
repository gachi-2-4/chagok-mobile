import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_exception.dart';
import 'package:chagok_mobile/core/network/api_formats.dart';
import 'package:chagok_mobile/core/network/json_map.dart';
import 'package:chagok_mobile/features/chat/data/chat_document.dart';
import 'package:chagok_mobile/features/chat/data/chat_message.dart';
import 'package:chagok_mobile/features/chat/data/chat_no_document_exception.dart';
import 'package:chagok_mobile/features/chat/data/chat_repository.dart';
import 'package:chagok_mobile/features/chat/data/chat_role.dart';
import 'package:chagok_mobile/features/chat/data/chat_thread.dart';
import 'package:chagok_mobile/features/chat/data/chat_thread_not_found_exception.dart';

/// 차곡 API 서버의 CHAT API로 서류 대화를 다루는 [ChatRepository].
///
/// - 서버는 첫 안내(`greeting`)를 메시지로 저장하지 않으므로, 대화의 맨 앞에
///   차곡의 말풍선으로 붙여 돌려줍니다.
/// - 질문 칩은 서버가 대화를 열 때마다 내 보관함 서류 종류로 골라 줍니다.
///   [suggestedQuestions]는 마지막으로 연 대화의 칩을 돌려줍니다.
class ApiChatRepository implements ChatRepository {
  ApiChatRepository({required this._client, required this._now});

  final ApiClient _client;

  /// 첫 안내 말풍선의 시각을 정할 때 쓰는 시계. 대화에 메시지가 없을 때 씁니다.
  final DateTime Function() _now;

  /// 한 번에 받을 메시지 수. 서버 기본값(30)보다 넉넉히 받아 요청 수를 줄입니다.
  static const _messagePageSize = 50;

  /// 대화에 연결한 서류가 없어 답할 수 없다는 서버 에러 코드(409).
  static const _noLinkedDocumentCode = 'NO_LINKED_DOCUMENT';

  List<String> _suggestions = const [];

  /// 지난 대화 목록. 목록 API는 제목(첫 질문)만 주므로 대화마다 그 질문 하나만 담습니다.
  @override
  Future<List<ChatThread>> fetchThreads() async {
    final items = await _client.getAllPages('/chats');
    return [
      for (final item in items)
        ChatThread(
          id: item.id('chatId'),
          messages: [
            if (item.stringOrNull('title') case final title?)
              ChatMessage(
                role: ChatRole.user,
                text: title,
                sentAt: parseApiDateTime(item.string('lastMessageAt')),
              ),
          ],
          updatedAt: parseApiDateTime(item.string('lastMessageAt')),
          document: _documentOf(item.maps('documents').firstOrNull),
        ),
    ];
  }

  /// 대화를 메시지 전부와 함께 불러옵니다.
  ///
  /// 서버는 최신 메시지부터 쪽으로 나눠 주므로, 더 오래된 메시지가 남아 있으면
  /// 받은 것 중 가장 오래된 메시지 ID를 `beforeMessageId`로 보내 앞쪽을 이어 받습니다.
  /// 대화 길이에는 제한을 두지 않고, 더 오래된 메시지가 오지 않으면 멈춥니다.
  @override
  Future<ChatThread> fetchThread(String id) async {
    final JsonMap json;
    try {
      json = await _fetchMessages(id);
    } on ApiException catch (error) {
      if (error.isNotFound) throw ChatThreadNotFoundException(id);
      rethrow;
    } on FormatException {
      throw ChatThreadNotFoundException(id);
    }
    _suggestions = _suggestionsOf(json);
    var received = json.maps('messages');
    var hasMore = json.boolean('hasMore');
    while (hasMore) {
      final oldest = received.firstOrNull?.integerOrNull('messageId');
      if (oldest == null) break;
      final page = await _fetchMessages(id, beforeMessageId: oldest);
      // 받은 것보다 오래된 메시지만 붙입니다. 서버가 같은 쪽을 되풀이해 더 오래된
      // 메시지가 오지 않으면, 쪽수와 관계없이 끝없이 부르지 않도록 여기서 멈춥니다.
      final older = [
        for (final message in page.maps('messages'))
          if ((message.integerOrNull('messageId') ?? oldest) < oldest) message,
      ];
      if (older.isEmpty) break;
      received = [...older, ...received];
      hasMore = page.boolean('hasMore');
    }
    final messages = [for (final message in received) _messageOf(message)];
    final greetingAt = messages.firstOrNull?.sentAt ?? _now();
    return ChatThread(
      id: json.id('chatId'),
      messages: [?_greetingOf(json, greetingAt), ...messages],
      updatedAt: messages.lastOrNull?.sentAt ?? greetingAt,
      document: _documentOf(json.maps('documents').firstOrNull),
    );
  }

  Future<JsonMap> _fetchMessages(String id, {int? beforeMessageId}) {
    return _client.get(
      '/chats/${apiId(id)}/messages',
      query: {'size': _messagePageSize, 'beforeMessageId': beforeMessageId},
    );
  }

  @override
  Future<ChatThread> createThread() async {
    final json = await _client.post('/chats', body: const <String, Object?>{});
    _suggestions = _suggestionsOf(json);
    final createdAt = parseApiDateTime(json.string('createdAt'));
    return ChatThread(
      id: json.id('chatId'),
      messages: [?_greetingOf(json, createdAt)],
      updatedAt: createdAt,
      document: _documentOf(json.maps('documents').firstOrNull),
    );
  }

  /// 질문을 보내고, 저장된 질문·답이 들어간 대화를 다시 불러와 돌려줍니다.
  ///
  /// 대화에 연결한 서류가 없으면 [ChatNoDocumentException]을 던집니다.
  @override
  Future<ChatThread> sendMessage({
    required String threadId,
    required String text,
  }) async {
    try {
      await _client.post(
        '/chats/${apiId(threadId)}/messages',
        body: {'content': text},
      );
    } on ApiException catch (error) {
      if (error.code == _noLinkedDocumentCode) {
        throw ChatNoDocumentException(threadId);
      }
      rethrow;
    }
    return fetchThread(threadId);
  }

  /// 대화에 넣을 수 있는 내 보관함 서류. 최근에 올린 순서입니다.
  @override
  Future<List<ChatDocument>> fetchDocuments() async {
    final documents = await _client.getAllPages(
      '/documents',
      query: {'sort': 'RECENT'},
    );
    return [for (final document in documents) ?_documentOf(document)];
  }

  /// 대화의 서류를 [documentId] 하나로 바꿉니다. 서버는 보낸 목록으로 통째로 바꿉니다.
  @override
  Future<ChatThread> linkDocument({
    required String threadId,
    required String documentId,
  }) async {
    await _client.put(
      '/chats/${apiId(threadId)}/documents',
      body: {
        'documentIds': [apiId(documentId)],
        'boxIds': const <int>[],
      },
    );
    return fetchThread(threadId);
  }

  @override
  List<String> suggestedQuestions(ChatDocument? document) => _suggestions;

  ChatMessage? _greetingOf(JsonMap json, DateTime sentAt) {
    final greeting = json.stringOrNull('greeting');
    if (greeting == null || greeting.isEmpty) return null;
    return ChatMessage(
      role: ChatRole.assistant,
      text: greeting,
      sentAt: sentAt,
    );
  }

  List<String> _suggestionsOf(JsonMap json) => [
    for (final suggestion in json.maps('suggestions'))
      suggestion.string('text'),
  ];

  ChatMessage _messageOf(JsonMap json) {
    final citations = [
      for (final citation in json.maps('citations'))
        ?citation.stringOrNull('label'),
    ];
    return ChatMessage(
      role: json.stringOrNull('role') == 'USER'
          ? ChatRole.user
          : ChatRole.assistant,
      text: json.string('content'),
      sentAt: parseApiDateTime(json.string('createdAt')),
      source: citations.isEmpty ? null : citations.join(', '),
    );
  }

  /// 서류 목록·대화 서류 항목에서 [ChatDocument]를 만듭니다. 없으면 null.
  ChatDocument? _documentOf(JsonMap? json) {
    if (json == null) return null;
    final title = json.string('title');
    return ChatDocument(
      id: json.id('documentId'),
      name: title,
      // 서류 목록은 원본 파일 이름을 주지 않아 서류 이름을 씁니다.
      fileName: json.stringOrNull('originalFileName') ?? title,
    );
  }
}
