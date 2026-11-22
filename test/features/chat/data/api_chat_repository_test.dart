import 'package:chagok_mobile/core/network/api_exception.dart';
import 'package:chagok_mobile/features/chat/data/api_chat_repository.dart';
import 'package:chagok_mobile/features/chat/data/chat_no_document_exception.dart';
import 'package:chagok_mobile/features/chat/data/chat_role.dart';
import 'package:chagok_mobile/features/chat/data/chat_thread_not_found_exception.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_api_server.dart';

void main() {
  final now = DateTime(2026, 11, 18, 10);
  const room = {
    'chatId': 12,
    'documents': [
      {'documentId': 501, 'title': '임대차계약서', 'linkStatus': 'LINKED'},
    ],
    'greeting': '안녕하세요! 궁금한 내용을 물어보세요.',
    'suggestions': [
      {'text': '보증금 언제 돌려받아?', 'category': 'AMOUNT'},
    ],
    'messages': [
      {
        'messageId': 901,
        'role': 'USER',
        'content': '월세는 언제 내야 하나요?',
        'createdAt': '2026-11-18T09:41:00+09:00',
      },
      {
        'messageId': 902,
        'role': 'ASSISTANT',
        'content': '매월 25일까지 500,000원을 내면 돼요.',
        'citations': [
          {'label': '계약서 1페이지'},
        ],
        'createdAt': '2026-11-18T09:41:03+09:00',
      },
    ],
    'hasMore': false,
  };

  late FakeApiServer server;
  late ApiChatRepository repository;

  setUp(() {
    server = FakeApiServer();
    repository = ApiChatRepository(client: server.client, now: () => now);
    server.onJson('GET', '/chats/12/messages', room);
  });

  group('ApiChatRepository.fetchThread', () {
    test('대화를 열면 첫 안내를 맨 앞 말풍선으로 붙인다', () async {
      final thread = await repository.fetchThread('12');

      expect(thread.messages.map((message) => message.role), [
        ChatRole.assistant,
        ChatRole.user,
        ChatRole.assistant,
      ]);
      expect(thread.title, '월세는 언제 내야 하나요?');
    });

    test('답에 근거가 있으면 근거 이름을 출처로 붙인다', () async {
      final thread = await repository.fetchThread('12');

      expect(thread.messages.last.source, '계약서 1페이지');
    });

    test('대화를 열면 그 대화의 질문 칩을 돌려준다', () async {
      final thread = await repository.fetchThread('12');

      expect(repository.suggestedQuestions(thread.document), ['보증금 언제 돌려받아?']);
    });

    test('더 오래된 메시지가 남아 있으면 앞쪽을 이어 받아 시간순으로 합친다', () async {
      Map<String, Object?> message(int id) => {
        'messageId': id,
        'role': 'USER',
        'content': '질문 $id',
        'createdAt': '2026-11-18T09:4$id:00+09:00',
      };
      server.on('GET', '/chats/12/messages', (request) {
        final before = request.url.queryParameters['beforeMessageId'];
        return jsonResponse({
          ...room,
          'messages': before == null
              ? [message(3), message(4)]
              : [message(1), message(2)],
          'hasMore': before == null,
        });
      });

      final thread = await repository.fetchThread('12');

      expect(thread.messages.skip(1).map((message) => message.text), [
        '질문 1',
        '질문 2',
        '질문 3',
        '질문 4',
      ]);
      expect(server.requests.last.url.queryParameters['beforeMessageId'], '3');
    });

    test('메시지가 20쪽을 넘으면 끝까지 이어 받는다', () async {
      // 메시지 ID 1~30을 한 쪽에 하나씩, 최신부터 줍니다.
      server.on('GET', '/chats/12/messages', (request) {
        final before = int.tryParse(
          request.url.queryParameters['beforeMessageId'] ?? '',
        );
        final id = (before ?? 31) - 1;
        return jsonResponse({
          ...room,
          'messages': [
            {
              'messageId': id,
              'role': 'USER',
              'content': '질문 $id',
              'createdAt': '2026-11-18T09:00:00+09:00',
            },
          ],
          'hasMore': id > 1,
        });
      });

      final thread = await repository.fetchThread('12');

      expect(thread.messages.skip(1).map((message) => message.text), [
        for (var id = 1; id <= 30; id++) '질문 $id',
      ]);
    });

    test('더 오래된 메시지가 오지 않으면 이어 받기를 멈춘다', () async {
      server.onJson('GET', '/chats/12/messages', {...room, 'hasMore': true});

      final thread = await repository.fetchThread('12');

      expect(server.requestsTo('GET', '/chats/12/messages'), hasLength(2));
      expect(thread.messages, hasLength(3));
    });

    test('없는 대화면 ChatThreadNotFoundException을 던진다', () async {
      server.on(
        'GET',
        '/chats/9/messages',
        (_) => errorResponse(404, 'CHAT_NOT_FOUND'),
      );

      final request = repository.fetchThread('9');

      await expectLater(request, throwsA(isA<ChatThreadNotFoundException>()));
    });
  });

  group('ApiChatRepository.createThread', () {
    test('새 대화를 만들면 첫 안내만 담긴 대화를 돌려준다', () async {
      server.onJson('POST', '/chats', {
        'chatId': 13,
        'documents': <Object>[],
        'greeting': '안녕하세요!',
        'suggestions': <Object>[],
        'createdAt': '2026-11-18T09:40:00+09:00',
      }, status: 201);

      final thread = await repository.createThread();

      expect(thread.id, '13');
      expect(thread.messages.single.text, '안녕하세요!');
      expect(thread.document, isNull);
    });
  });

  group('ApiChatRepository.sendMessage', () {
    test('질문을 보내면 저장된 대화를 다시 불러온다', () async {
      server.onJson('POST', '/chats/12/messages', {}, status: 201);

      final thread = await repository.sendMessage(
        threadId: '12',
        text: '월세는 언제 내야 하나요?',
      );

      expect(server.lastBody('POST', '/chats/12/messages'), {
        'content': '월세는 언제 내야 하나요?',
      });
      expect(thread.messages, hasLength(3));
    });

    test('대화에 서류가 없다는 응답을 받으면 ChatNoDocumentException을 던진다', () async {
      server.on(
        'POST',
        '/chats/12/messages',
        (_) => errorResponse(409, 'NO_LINKED_DOCUMENT', '물어볼 서류가 없어요.'),
      );

      await expectLater(
        repository.sendMessage(threadId: '12', text: '위약금이 있나요?'),
        throwsA(isA<ChatNoDocumentException>()),
      );
    });

    test('다른 실패 응답을 받으면 ApiException을 그대로 던진다', () async {
      server.on(
        'POST',
        '/chats/12/messages',
        (_) => errorResponse(500, 'INTERNAL_SERVER_ERROR'),
      );

      await expectLater(
        repository.sendMessage(threadId: '12', text: '위약금이 있나요?'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('ApiChatRepository.linkDocument', () {
    test('서류를 연결하면 대화의 서류를 고른 서류 하나로 바꾼다', () async {
      server.onJson('PUT', '/chats/12/documents', {});

      await repository.linkDocument(threadId: '12', documentId: '540');

      expect(server.lastBody('PUT', '/chats/12/documents'), {
        'documentIds': [540],
        'boxIds': <Object>[],
      });
    });
  });

  group('ApiChatRepository.fetchThreads', () {
    test('지난 대화 목록을 받으면 제목을 첫 질문으로 담는다', () async {
      server.onJson('GET', '/chats', {
        'content': [
          {
            'chatId': 12,
            'title': '월세는 언제 내야 하나요?',
            'documents': [
              {'documentId': 501, 'title': '임대차계약서', 'deleted': false},
            ],
            'lastMessageAt': '2026-11-18T09:41:00+09:00',
          },
        ],
        'hasNext': false,
      });

      final threads = await repository.fetchThreads();

      expect(threads.single.title, '월세는 언제 내야 하나요?');
      expect(threads.single.document?.name, '임대차계약서');
    });
  });
}
