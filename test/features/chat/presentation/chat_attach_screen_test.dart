import 'dart:async';

import 'package:chagok_mobile/core/widgets/app_button.dart';
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
  });
}
