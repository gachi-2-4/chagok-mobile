import 'package:chagok_mobile/features/chat/data/chat_message.dart';
import 'package:chagok_mobile/features/chat/data/chat_repository.dart';
import 'package:chagok_mobile/features/chat/data/sample_chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 19, 15);
  late SampleChatRepository repository;

  setUp(() {
    repository = SampleChatRepository(() => now);
  });

  group('SampleChatRepository.fetchThreads', () {
    test('예시 대화를 최근 순서대로 돌려준다', () async {
      final threads = await repository.fetchThreads();

      expect(threads, hasLength(4));
      final times = threads.map((thread) => thread.updatedAt).toList();
      for (var i = 1; i < times.length; i++) {
        expect(times[i - 1].isAfter(times[i]), isTrue);
      }
    });

    test('아직 질문하지 않은 새 대화는 목록에 넣지 않는다', () async {
      final created = await repository.createThread();

      final threads = await repository.fetchThreads();

      expect(threads.map((thread) => thread.id), isNot(contains(created.id)));
    });
  });

  group('SampleChatRepository.fetchThread', () {
    test('없는 id면 ChatThreadNotFoundException을 던진다', () {
      expect(
        repository.fetchThread('missing'),
        throwsA(isA<ChatThreadNotFoundException>()),
      );
    });
  });

  group('SampleChatRepository.createThread', () {
    test('인사말 하나가 담긴 새 대화를 지금 시각으로 만든다', () async {
      final thread = await repository.createThread();

      expect(thread.updatedAt, now);
      expect(thread.messages, hasLength(1));
      expect(thread.messages.single.role, ChatRole.assistant);
      expect(thread.messages.single.text, SampleChatRepository.greeting);
    });

    test('만들 때마다 다른 id를 준다', () async {
      final first = await repository.createThread();
      final second = await repository.createThread();

      expect(first.id, isNot(second.id));
    });
  });

  group('SampleChatRepository.sendMessage', () {
    test('질문과 답을 차례로 붙이고 시각을 갱신한다', () async {
      final thread = await repository.createThread();

      final updated = await repository.sendMessage(
        threadId: thread.id,
        text: '위약금이 있나요?',
      );

      expect(updated.messages, hasLength(3));
      expect(updated.messages[1].role, ChatRole.user);
      expect(updated.messages[1].text, '위약금이 있나요?');
      expect(updated.messages[2].role, ChatRole.assistant);
      expect(updated.updatedAt, now);
    });

    test('질문 낱말에 맞는 답과 근거를 준다', () async {
      final thread = await repository.createThread();

      final updated = await repository.sendMessage(
        threadId: thread.id,
        text: '위약금이 있나요?',
      );

      final answer = updated.messages.last;
      expect(answer.text, contains('**남은 기간 월세의 10%**'));
      expect(answer.source, '계약서 2페이지, 특약 사항');
    });

    test('맞는 답이 없으면 근거 없이 다시 물어봐 달라고 한다', () async {
      final thread = await repository.createThread();

      final updated = await repository.sendMessage(
        threadId: thread.id,
        text: '안녕?',
      );

      final answer = updated.messages.last;
      expect(answer.text, contains('찾지 못했어요'));
      expect(answer.source, isNull);
    });

    test('보낸 대화는 다시 불러와도 바뀐 내용이 남아 있다', () async {
      final thread = await repository.createThread();
      await repository.sendMessage(threadId: thread.id, text: '위약금이 있나요?');

      final fetched = await repository.fetchThread(thread.id);

      expect(fetched.title, '위약금이 있나요?');
    });
  });

  group('SampleChatRepository.linkDocument', () {
    test('고른 서류를 대화에 연결한다', () async {
      final thread = await repository.createThread();

      final updated = await repository.linkDocument(
        threadId: thread.id,
        documentId: 'maintenance',
      );

      expect(updated.document?.id, 'maintenance');
      final fetched = await repository.fetchThread(thread.id);
      expect(fetched.document?.id, 'maintenance');
    });
  });

  group('SampleChatRepository.suggestedQuestions', () {
    test('관리비 고지서면 관리비 질문을 먼저 준다', () async {
      final documents = await repository.fetchDocuments();
      final maintenance = documents.firstWhere(
        (document) => document.id == 'maintenance',
      );

      final questions = repository.suggestedQuestions(maintenance);

      expect(questions.first, '관리비가 왜 달라졌나요?');
    });

    test('서류가 없으면 기본 질문을 준다', () {
      final questions = repository.suggestedQuestions(null);

      expect(questions, ['언제까지 내야 하나요?', '위약금이 있나요?']);
    });
  });
}
