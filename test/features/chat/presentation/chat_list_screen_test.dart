import 'dart:async';

import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_list_screen.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_chat_repository.dart';
import '../../../helpers/pump_chat_screen.dart';

void main() {
  late FakeChatRepository repository;

  setUp(() {
    final now = DateTime.now();
    repository = FakeChatRepository(
      threads: [
        buildThread(
          id: 'today',
          question: '월세는 언제 내나요?',
          document: leaseDocument,
          updatedAt: now,
        ),
        buildThread(
          id: 'earlier',
          question: '관리비가 왜 올랐나요?',
          document: maintenanceDocument,
          updatedAt: now.subtract(const Duration(days: 3)),
        ),
      ],
    );
  });

  group('ChatListScreen', () {
    testWidgets('목록을 불러오는 중이면 로딩 표시를 보여 준다', (tester) async {
      repository.loadGate = Completer<void>();

      await tester.pumpChatScreen(const ChatListScreen(), repository);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      repository.loadGate?.complete();
    });

    testWidgets('대화가 있으면 오늘과 이전 대화로 나눠 보여 준다', (tester) async {
      await tester.pumpChatScreen(const ChatListScreen(), repository);
      await tester.pumpAndSettle();

      expect(find.text(ChatStrings.today), findsOneWidget);
      expect(find.text(ChatStrings.earlier), findsOneWidget);
      expect(find.text('월세는 언제 내나요?'), findsOneWidget);
      expect(find.text('관리비가 왜 올랐나요?'), findsOneWidget);
    });

    testWidgets('대화가 없으면 빈 목록 안내를 보여 준다', (tester) async {
      await tester.pumpChatScreen(const ChatListScreen(), FakeChatRepository());
      await tester.pumpAndSettle();

      expect(find.text(ChatStrings.empty), findsOneWidget);
    });

    testWidgets('검색어를 입력하면 맞는 대화만 보여 준다', (tester) async {
      await tester.pumpChatScreen(const ChatListScreen(), repository);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '관리비');
      await tester.pumpAndSettle();

      expect(find.text('관리비가 왜 올랐나요?'), findsOneWidget);
      expect(find.text('월세는 언제 내나요?'), findsNothing);
    });

    testWidgets('검색어에 맞는 대화가 없으면 결과 없음 안내를 보여 준다', (tester) async {
      await tester.pumpChatScreen(const ChatListScreen(), repository);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '보험');
      await tester.pumpAndSettle();

      expect(find.text(ChatStrings.noResult), findsOneWidget);
    });

    testWidgets('목록을 불러오지 못하면 안내와 다시 시도 버튼을 보여 준다', (tester) async {
      repository.loadError = Exception('network');

      await tester.pumpChatScreen(const ChatListScreen(), repository);
      await tester.pumpAndSettle();

      expect(find.text(ChatStrings.listLoadFailed), findsOneWidget);
      expect(find.text(ChatStrings.retry), findsOneWidget);
    });

    testWidgets('다시 시도를 누르면 목록을 다시 불러온다', (tester) async {
      repository.loadError = Exception('network');
      await tester.pumpChatScreen(const ChatListScreen(), repository);
      await tester.pumpAndSettle();

      repository.loadError = null;
      await tester.tap(find.text(ChatStrings.retry));
      await tester.pumpAndSettle();

      expect(find.text('월세는 언제 내나요?'), findsOneWidget);
    });

    testWidgets('새 대화를 시작하지 못하면 실패 안내를 보여 준다', (tester) async {
      await tester.pumpChatScreen(const ChatListScreen(), repository);
      await tester.pumpAndSettle();
      repository.createError = Exception('network');

      await tester.tap(find.text(ChatStrings.newChat));
      await tester.pumpAndSettle();

      expect(find.text(ChatStrings.newChatFailed), findsOneWidget);
    });

    testWidgets('새 대화 시작을 누르면 시작이 끝날 때까지 버튼을 누를 수 없다', (tester) async {
      await tester.pumpChatScreen(const ChatListScreen(), repository);
      await tester.pumpAndSettle();
      repository.createGate = Completer<void>();

      await tester.tap(find.text(ChatStrings.newChat));
      await tester.pump();

      final button = tester.widget<AppButton>(
        find.widgetWithText(AppButton, ChatStrings.newChat),
      );
      expect(button.onPressed, isNull);
      // 시작이 끝나면 대화방으로 이동하는데, 이 테스트에는 라우터가 없어 실패로 끝냅니다.
      repository.createError = Exception('stop');
      repository.createGate?.complete();
      await tester.pumpAndSettle();
    });
  });
}
