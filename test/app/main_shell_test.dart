import 'dart:async';

import 'package:chagok_mobile/app/app.dart';
import 'package:chagok_mobile/app/app_strings.dart';
import 'package:chagok_mobile/core/widgets/app_bottom_nav_bar.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_screen.dart';
import 'package:chagok_mobile/features/calendar/presentation/calendar_screen.dart';
import 'package:chagok_mobile/features/chat/data/chat_repository.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_attach_screen.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_list_screen.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_room_screen.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_strings.dart';
import 'package:chagok_mobile/features/home/presentation/home_screen.dart';
import 'package:chagok_mobile/features/settings/data/settings_repository.dart';
import 'package:chagok_mobile/features/settings/presentation/settings_screen.dart';
import 'package:chagok_mobile/features/settings/presentation/settings_strings.dart';
import 'package:chagok_mobile/features/settings/presentation/text_size_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_chat_repository.dart';
import '../helpers/fake_settings_repository.dart';

void main() {
  const question = '월세는 언제 내나요?';

  Future<FakeChatRepository> pumpChagokApp(WidgetTester tester) async {
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
        overrides: [
          chatRepositoryProvider.overrideWithValue(repository),
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
        ],
        child: const ChagokApp(),
      ),
    );
    await tester.pumpAndSettle();
    return repository;
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

  group('MainShell', () {
    testWidgets('앱을 실행하면 홈 탭이 선택된 바텀바가 보인다', (tester) async {
      await pumpChagokApp(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(currentTab(tester), 2);
    });

    testWidgets('채팅 탭을 누르면 대화 목록과 바텀바가 보인다', (tester) async {
      await pumpChagokApp(tester);

      await tapTab(tester, AppStrings.chatTab);

      expect(find.byType(ChatListScreen), findsOneWidget);
      expect(currentTab(tester), 1);
    });

    testWidgets('대화방에 들어가면 바텀바가 그대로 남아 있다', (tester) async {
      await pumpChagokApp(tester);
      await tapTab(tester, AppStrings.chatTab);

      await openThread(tester);

      expect(find.byType(ChatRoomScreen), findsOneWidget);
      expect(find.byType(AppBottomNavBar), findsOneWidget);
      expect(currentTab(tester), 1);
    });

    testWidgets('서류 추가 화면으로 가면 바텀바가 그대로 남아 있다', (tester) async {
      await pumpChagokApp(tester);
      await tapTab(tester, AppStrings.chatTab);
      await openThread(tester);

      await tester.tap(find.textContaining('변경'));
      await tester.pumpAndSettle();

      expect(find.byType(ChatAttachScreen), findsOneWidget);
      expect(find.byType(AppBottomNavBar), findsOneWidget);
    });

    testWidgets('다른 탭에 다녀오면 보던 대화방이 그대로 남아 있다', (tester) async {
      await pumpChagokApp(tester);
      await tapTab(tester, AppStrings.chatTab);
      await openThread(tester);

      await tapTab(tester, AppStrings.homeTab);
      await tapTab(tester, AppStrings.chatTab);

      expect(find.byType(ChatRoomScreen), findsOneWidget);
    });

    testWidgets('지금 탭을 다시 누르면 그 탭의 첫 화면으로 돌아간다', (tester) async {
      await pumpChagokApp(tester);
      await tapTab(tester, AppStrings.chatTab);
      await openThread(tester);

      await tapTab(tester, AppStrings.chatTab);

      expect(find.byType(ChatRoomScreen), findsNothing);
      expect(find.byType(ChatListScreen), findsOneWidget);
    });

    testWidgets('보관함 탭을 누르면 보관함 화면과 바텀바가 보인다', (tester) async {
      await pumpChagokApp(tester);

      await tapTab(tester, AppStrings.archiveTab);

      expect(find.byType(ArchiveScreen), findsOneWidget);
      expect(currentTab(tester), 0);
    });

    testWidgets('캘린더 탭을 누르면 캘린더 화면과 바텀바가 보인다', (tester) async {
      await pumpChagokApp(tester);

      await tapTab(tester, AppStrings.calendarTab);

      expect(find.byType(CalendarScreen), findsOneWidget);
      expect(currentTab(tester), 3);
    });

    testWidgets('설정 탭을 누르면 설정 화면과 바텀바가 보인다', (tester) async {
      await pumpChagokApp(tester);

      await tapTab(tester, AppStrings.settingsTab);

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(currentTab(tester), 4);
    });

    testWidgets('설정에서 글자 크기 화면으로 가면 바텀바가 그대로 남아 있다', (tester) async {
      await pumpChagokApp(tester);
      await tapTab(tester, AppStrings.settingsTab);

      await tester.tap(find.text(SettingsStrings.textSize));
      await tester.pumpAndSettle();

      expect(find.byType(TextSizeScreen), findsOneWidget);
      expect(find.byType(AppBottomNavBar), findsOneWidget);
      expect(currentTab(tester), 4);
    });

    testWidgets('새 대화를 만드는 중에 다른 탭으로 가면 다 만들어져도 대화방으로 이동하지 않는다', (
      tester,
    ) async {
      final repository = await pumpChagokApp(tester);
      await tapTab(tester, AppStrings.chatTab);
      repository.createGate = Completer<void>();
      await tester.tap(find.text(ChatStrings.newChat));
      await tester.pump();

      await tapTab(tester, AppStrings.homeTab);
      repository.createGate?.complete();
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      await tapTab(tester, AppStrings.chatTab);
      expect(find.byType(ChatRoomScreen), findsNothing);
      expect(find.byType(ChatListScreen), findsOneWidget);
    });
  });
}
