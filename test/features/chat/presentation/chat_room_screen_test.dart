import 'dart:async';

import 'package:chagok_mobile/core/widgets/app_chip.dart';
import 'package:chagok_mobile/features/chat/data/chat_no_document_exception.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_room_screen.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_chat_repository.dart';
import '../../../helpers/pump_chat_screen.dart';

void main() {
  const threadId = 'thread-1';
  const question = '위약금이 있나요?';
  late FakeChatRepository repository;

  setUp(() {
    repository = FakeChatRepository(
      threads: [buildThread(id: threadId, document: leaseDocument)],
    );
  });

  Future<void> sendQuestion(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.tap(find.byTooltip(ChatStrings.send));
    await tester.pumpAndSettle();
  }

  group('ChatRoomScreen', () {
    testWidgets('대화를 불러오는 중이면 로딩 표시를 보여 준다', (tester) async {
      repository.loadGate = Completer<void>();

      await tester.pumpChatScreen(
        const ChatRoomScreen(threadId: threadId),
        repository,
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      repository.loadGate?.complete();
    });

    testWidgets('대화를 불러오지 못하면 안내와 다시 시도 버튼을 보여 준다', (tester) async {
      await tester.pumpChatScreen(
        const ChatRoomScreen(threadId: 'missing'),
        repository,
      );
      await tester.pumpAndSettle();

      expect(find.text(ChatStrings.loadFailed), findsOneWidget);
      expect(find.text(ChatStrings.retry), findsOneWidget);
    });

    testWidgets('대화를 불러오면 연결된 서류와 추천 질문을 보여 준다', (tester) async {
      await tester.pumpChatScreen(
        const ChatRoomScreen(threadId: threadId),
        repository,
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining(ChatStrings.linkedDocument(leaseDocument.name)),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(AppChip, '${leaseDocument.name}에 대해 물어보기'),
        findsOneWidget,
      );
    });

    testWidgets('질문을 입력해 보내면 질문과 답 말풍선이 보인다', (tester) async {
      await tester.pumpChatScreen(
        const ChatRoomScreen(threadId: threadId),
        repository,
      );
      await tester.pumpAndSettle();

      await sendQuestion(tester, question);

      expect(find.text(question), findsOneWidget);
      expect(find.text('답: $question'), findsOneWidget);
    });

    testWidgets('추천 질문을 누르면 그 질문을 보낸다', (tester) async {
      await tester.pumpChatScreen(
        const ChatRoomScreen(threadId: threadId),
        repository,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('${leaseDocument.name}에 대해 물어보기'));
      await tester.pumpAndSettle();

      expect(repository.sentMessages.single.text, '임대차계약서에 대해 물어보기');
    });

    testWidgets('답을 받지 못하면 실패 안내와 다시 보내기 버튼을 보여 준다', (tester) async {
      await tester.pumpChatScreen(
        const ChatRoomScreen(threadId: threadId),
        repository,
      );
      await tester.pumpAndSettle();
      repository.sendError = Exception('network');

      await sendQuestion(tester, question);

      expect(find.text(ChatStrings.sendFailed), findsOneWidget);
      expect(find.text(ChatStrings.resend), findsOneWidget);
    });

    testWidgets('다시 보내기를 누르면 실패한 질문을 다시 보낸다', (tester) async {
      await tester.pumpChatScreen(
        const ChatRoomScreen(threadId: threadId),
        repository,
      );
      await tester.pumpAndSettle();
      repository.sendError = Exception('network');
      await sendQuestion(tester, question);

      repository.sendError = null;
      await tester.tap(find.text(ChatStrings.resend));
      await tester.pumpAndSettle();

      expect(find.text('답: $question'), findsOneWidget);
      expect(find.text(ChatStrings.sendFailed), findsNothing);
    });

    testWidgets('질문을 보내면 답을 받을 때까지 서류 추가 버튼과 서류 띠를 누를 수 없다', (tester) async {
      await tester.pumpChatScreen(
        const ChatRoomScreen(threadId: threadId),
        repository,
      );
      await tester.pumpAndSettle();
      repository.sendGate = Completer<void>();

      await tester.enterText(find.byType(TextField), question);
      await tester.tap(find.byTooltip(ChatStrings.send));
      await tester.pump();

      final addButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byTooltip(ChatStrings.addDocument),
          matching: find.byType(IconButton),
        ),
      );
      final banner = tester.widget<GestureDetector>(
        find
            .ancestor(
              of: find.text(ChatStrings.documentBanner(leaseDocument.name)),
              matching: find.byType(GestureDetector),
            )
            .first,
      );
      expect(addButton.onPressed, isNull);
      expect(banner.onTap, isNull);
      repository.sendGate?.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('질문을 보내면 답을 받을 때까지 서류 추가 아이콘을 흐리게 그린다', (tester) async {
      await tester.pumpChatScreen(
        const ChatRoomScreen(threadId: threadId),
        repository,
      );
      await tester.pumpAndSettle();
      Color? addIconColor() => IconTheme.of(
        tester.element(
          find.descendant(
            of: find.byTooltip(ChatStrings.addDocument),
            matching: find.byType(Icon),
          ),
        ),
      ).color;
      final enabledColor = addIconColor();
      repository.sendGate = Completer<void>();

      await tester.enterText(find.byType(TextField), question);
      await tester.tap(find.byTooltip(ChatStrings.send));
      await tester.pump();

      // 버튼은 색을 AnimatedTheme으로 바꾸므로 애니메이션이 끝날 때까지 기다립니다.
      await tester.pump(kThemeChangeDuration);

      // 다른 색으로 바뀌기만 해서는 안 되고, 같은 색이 더 투명해져야 흐려진 것입니다.
      final waitingColor = addIconColor();
      expect(enabledColor, isNotNull);
      expect(waitingColor, isNotNull);
      expect(waitingColor?.a, lessThan(enabledColor?.a ?? 0));
      repository.sendGate?.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('답을 받지 못하면 보낸 질문 말풍선을 남긴다', (tester) async {
      await tester.pumpChatScreen(
        const ChatRoomScreen(threadId: threadId),
        repository,
      );
      await tester.pumpAndSettle();
      repository.sendError = Exception('network');

      await sendQuestion(tester, question);

      expect(find.text(question), findsOneWidget);
      expect(find.text(ChatStrings.sendFailed), findsOneWidget);
    });

    testWidgets('대화에 서류가 없어 답을 받지 못하면 서류를 추가하라고 안내한다', (tester) async {
      await tester.pumpChatScreen(
        const ChatRoomScreen(threadId: threadId),
        repository,
      );
      await tester.pumpAndSettle();
      repository.sendError = const ChatNoDocumentException(threadId);

      await sendQuestion(tester, question);

      expect(find.text(ChatStrings.sendNeedsDocument), findsOneWidget);
      expect(
        find.widgetWithText(AppChip, ChatStrings.addDocument),
        findsOneWidget,
      );
      expect(find.text(ChatStrings.resend), findsNothing);
    });
  });
}
