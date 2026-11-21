import 'package:chagok_mobile/app/app.dart';
import 'package:chagok_mobile/app/app_strings.dart';
import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/features/archive/presentation/box_detail_screen.dart';
import 'package:chagok_mobile/features/archive/presentation/document_overview_screen.dart';
import 'package:chagok_mobile/features/auth/presentation/login_screen.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_strings.dart';
import 'package:chagok_mobile/features/settings/presentation/settings_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 여러 기능에 걸친 화면 연결을 예시 저장소로 띄운 앱에서 확인합니다.
void main() {
  /// 앱을 띄우고 [location]으로 간 뒤 라우터를 돌려줍니다.
  Future<void> pumpAppAt(WidgetTester tester, String location) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // 위젯 트리와 함께 정리되도록 ProviderScope를 씁니다. 홈·보관함의 자정
    // Timer가 testWidgets의 Timer 검사 전에 함께 취소됩니다.
    await tester.pumpWidget(const ProviderScope(child: ChagokApp()));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ChagokApp)),
    );
    container.read(routerProvider).go(location);
    await tester.pumpAndSettle();
  }

  group('화면 연결', () {
    testWidgets('홈에서 최근 연 보관함을 누르면 그 보관함 상세로 간다', (tester) async {
      await pumpAppAt(tester, AppRoute.home);

      await tester.ensureVisible(find.text('집 · 임대').first);
      await tester.tap(find.text('집 · 임대').first);
      await tester.pumpAndSettle();

      expect(find.byType(BoxDetailScreen), findsOneWidget);
      expect(find.text(AppStrings.archiveTab), findsOneWidget);
    });

    testWidgets('설정에서 로그아웃하면 로그인 화면으로 간다', (tester) async {
      await pumpAppAt(tester, AppRoute.settings);

      await tester.ensureVisible(find.text(SettingsStrings.logOut));
      await tester.tap(find.text(SettingsStrings.logOut));
      await tester.pumpAndSettle();
      await tester.tap(find.text('예'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('채팅 답변의 원본 보기를 누르면 대화 서류의 원본을 연다', (tester) async {
      await pumpAppAt(tester, AppRoute.chat);
      await tester.tap(find.text('월세는 언제 내야 하나요?').first);
      await tester.pumpAndSettle();

      final viewOriginal = find.text(ChatStrings.viewOriginal).first;
      await tester.ensureVisible(viewOriginal);
      await tester.tap(viewOriginal);
      await tester.pumpAndSettle();

      expect(find.byType(DocumentOverviewScreen), findsOneWidget);
      expect(find.text('전세 임대차 계약서'), findsWidgets);
    });
  });
}
