import 'dart:async';

import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_card.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_attach_screen.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_chat_repository.dart';
import '../../../helpers/pump_chat_screen.dart';

void main() {
  const threadId = 'thread-1';
  late FakeChatRepository repository;

  setUp(() {
    repository = FakeChatRepository(threads: [buildThread(id: threadId)]);
  });

  AppButton attachButton(WidgetTester tester) => tester.widget<AppButton>(
    find.widgetWithText(AppButton, ChatStrings.attach),
  );

  Future<void> pickDocument(WidgetTester tester, String fileName) async {
    await tester.tap(find.text(ChatStrings.pickFromBox));
    await tester.pumpAndSettle();
    await tester.tap(find.text(fileName));
    await tester.pumpAndSettle();
  }

  group('ChatAttachScreen', () {
    testWidgets('서류를 불러오는 중이면 로딩 표시를 보여 준다', (tester) async {
      repository.loadGate = Completer<void>();

      await tester.pumpChatScreen(
        const ChatAttachScreen(threadId: threadId),
        repository,
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      repository.loadGate?.complete();
    });

    testWidgets('서류를 불러오지 못하면 안내와 다시 시도 버튼을 보여 준다', (tester) async {
      repository.loadError = Exception('network');

      await tester.pumpChatScreen(
        const ChatAttachScreen(threadId: threadId),
        repository,
      );
      await tester.pumpAndSettle();

      expect(find.text(ChatStrings.documentsLoadFailed), findsOneWidget);
      expect(find.text(ChatStrings.retry), findsOneWidget);
    });

    testWidgets('서류를 고르지 않았으면 추가 버튼을 누를 수 없다', (tester) async {
      await tester.pumpChatScreen(
        const ChatAttachScreen(threadId: threadId),
        repository,
      );
      await tester.pumpAndSettle();

      expect(attachButton(tester).onPressed, isNull);
    });

    testWidgets('보관함에서 서류를 고르면 고른 서류와 추가 버튼이 켜진다', (tester) async {
      await tester.pumpChatScreen(
        const ChatAttachScreen(threadId: threadId),
        repository,
      );
      await tester.pumpAndSettle();

      await pickDocument(tester, leaseDocument.fileName);

      expect(
        find.text(ChatStrings.selected(leaseDocument.fileName)),
        findsOneWidget,
      );
      expect(attachButton(tester).onPressed, isNotNull);
    });

    testWidgets('추가 버튼을 누르면 고른 서류를 대화에 연결한다', (tester) async {
      await tester.pumpChatScreen(
        const ChatAttachScreen(threadId: threadId),
        repository,
      );
      await tester.pumpAndSettle();
      await pickDocument(tester, leaseDocument.fileName);

      await tester.tap(find.text(ChatStrings.attach));
      await tester.pumpAndSettle();

      expect(repository.linkedDocuments.single.documentId, leaseDocument.id);
    });

    testWidgets('연결하지 못하면 실패 안내를 보여 준다', (tester) async {
      await tester.pumpChatScreen(
        const ChatAttachScreen(threadId: threadId),
        repository,
      );
      await tester.pumpAndSettle();
      await pickDocument(tester, leaseDocument.fileName);
      repository.linkError = Exception('network');

      await tester.tap(find.text(ChatStrings.attach));
      await tester.pumpAndSettle();

      expect(find.text(ChatStrings.attachFailed), findsOneWidget);
    });

    testWidgets('연결에 실패한 뒤에도 고른 서류가 남아 있고 다시 누르면 연결한다', (tester) async {
      await tester.pumpChatScreen(
        const ChatAttachScreen(threadId: threadId),
        repository,
      );
      await tester.pumpAndSettle();
      await pickDocument(tester, leaseDocument.fileName);
      repository.linkError = Exception('network');
      await tester.tap(find.text(ChatStrings.attach));
      await tester.pumpAndSettle();

      repository.linkError = null;
      await tester.tap(find.text(ChatStrings.attach));
      await tester.pumpAndSettle();

      expect(
        find.text(ChatStrings.selected(leaseDocument.fileName)),
        findsOneWidget,
      );
      expect(find.text(ChatStrings.attachFailed), findsNothing);
      expect(repository.linkedDocuments, hasLength(2));
    });

    testWidgets('추가 버튼을 누르면 연결이 끝날 때까지 보관함 카드를 누를 수 없다', (tester) async {
      await tester.pumpChatScreen(
        const ChatAttachScreen(threadId: threadId),
        repository,
      );
      await tester.pumpAndSettle();
      await pickDocument(tester, leaseDocument.fileName);
      repository.linkGate = Completer<void>();

      await tester.tap(find.text(ChatStrings.attach));
      await tester.pump();

      final card = tester.widget<AppCard>(
        find.ancestor(
          of: find.text(ChatStrings.pickFromBox),
          matching: find.byType(AppCard),
        ),
      );
      expect(card.onTap, isNull);
      repository.linkGate?.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('보관한 서류가 없으면 보관함에서 선택을 눌렀을 때 서류를 먼저 올리라고 안내한다', (tester) async {
      repository = FakeChatRepository(
        threads: [buildThread(id: threadId)],
        documents: const [],
      );
      await tester.pumpChatScreen(
        const ChatAttachScreen(threadId: threadId),
        repository,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(ChatStrings.pickFromBox));
      await tester.pumpAndSettle();

      expect(find.text(ChatStrings.noDocumentsInBox), findsOneWidget);
    });

    testWidgets('보관한 서류가 없으면 안내 시트를 화면 너비만큼 띄운다', (tester) async {
      // 시트 최대 너비(640)보다 좁은 휴대폰 화면에서 확인합니다.
      tester.view
        ..physicalSize = const Size(1179, 2556)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      repository = FakeChatRepository(
        threads: [buildThread(id: threadId)],
        documents: const [],
      );
      await tester.pumpChatScreen(
        const ChatAttachScreen(threadId: threadId),
        repository,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(ChatStrings.pickFromBox));
      await tester.pumpAndSettle();

      final sheet = tester.getSize(
        find
            .descendant(
              of: find.byType(BottomSheet),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(sheet.width, 393);
    });
  });
}
