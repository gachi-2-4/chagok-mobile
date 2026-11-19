import 'package:chagok_mobile/app/app.dart';
import 'package:chagok_mobile/core/widgets/app_bottom_nav_bar.dart';
import 'package:chagok_mobile/features/chat/data/chat_repository.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_attach_screen.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_list_screen.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_room_screen.dart';
import 'package:chagok_mobile/features/home/presentation/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_chat_repository.dart';

void main() {
  const question = '월세는 언제 내나요?';

  Future<void> pumpChagokApp(WidgetTester tester) async {
    final repository = FakeChatRepository(
      threads: [
        buildThread(
          id: 'thread-1',
          question: question,
          document: leaseDocument,
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [chatRepositoryProvider.overrideWithValue(repository)],
        child: const ChagokApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  int currentTab(WidgetTester tester) =>
      tester.widget<AppBottomNavBar>(find.byType(AppBottomNavBar)).currentIndex;

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(AppBottomNavBar),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openThread(WidgetTester tester) async {
    await tester.tap(find.text(question).first);
    await tester.pumpAndSettle();
  }

  group('AppShell', () {
    testWidgets('앱을 실행하면 홈 탭이 선택된 바텀바가 보인다', (tester) async {
      await pumpChagokApp(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(currentTab(tester), 2);
    });

    testWidgets('채팅 탭을 누르면 대화 목록과 바텀바가 보인다', (tester) async {
      await pumpChagokApp(tester);

      await tapTab(tester, '채팅');

      expect(find.byType(ChatListScreen), findsOneWidget);
      expect(currentTab(tester), 1);
    });

    testWidgets('대화방에 들어가도 바텀바가 남아 있다', (tester) async {
      await pumpChagokApp(tester);
      await tapTab(tester, '채팅');

      await openThread(tester);

      expect(find.byType(ChatRoomScreen), findsOneWidget);
      expect(find.byType(AppBottomNavBar), findsOneWidget);
      expect(currentTab(tester), 1);
    });

    testWidgets('서류 추가 화면에서도 바텀바가 남아 있다', (tester) async {
      await pumpChagokApp(tester);
      await tapTab(tester, '채팅');
      await openThread(tester);

      await tester.tap(find.textContaining('변경'));
      await tester.pumpAndSettle();

      expect(find.byType(ChatAttachScreen), findsOneWidget);
      expect(find.byType(AppBottomNavBar), findsOneWidget);
    });

    testWidgets('다른 탭에 다녀와도 보던 대화방이 그대로 남아 있다', (tester) async {
      await pumpChagokApp(tester);
      await tapTab(tester, '채팅');
      await openThread(tester);

      await tapTab(tester, '홈');
      await tapTab(tester, '채팅');

      expect(find.byType(ChatRoomScreen), findsOneWidget);
    });

    testWidgets('지금 탭을 다시 누르면 그 탭의 첫 화면으로 돌아간다', (tester) async {
      await pumpChagokApp(tester);
      await tapTab(tester, '채팅');
      await openThread(tester);

      await tapTab(tester, '채팅');

      expect(find.byType(ChatRoomScreen), findsNothing);
      expect(find.byType(ChatListScreen), findsOneWidget);
    });

    testWidgets('아직 없는 탭을 누르면 준비 중 안내를 띄우고 탭은 그대로 둔다', (tester) async {
      await pumpChagokApp(tester);

      await tapTab(tester, '보관함');

      expect(find.text('곧 지원할 예정이에요.'), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(currentTab(tester), 2);
    });
  });
}
