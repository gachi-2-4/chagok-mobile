import 'package:chagok_mobile/app/app.dart';
import 'package:chagok_mobile/app/main_shell.dart';
import 'package:chagok_mobile/core/widgets/app_bottom_nav_bar.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/home/presentation/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChagokApp', () {
    testWidgets('앱을 실행하면 하단 탭 바와 함께 홈 화면이 보인다', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: ChagokApp()));
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.widgetWithText(AppTopBar, '차곡'), findsOneWidget);
      expect(find.byType(AppBottomNavBar), findsOneWidget);
    });

    testWidgets('하단 탭을 누르면 그 탭 화면으로 바뀐다', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: ChagokApp()));
      await tester.pump();

      // 아직 준비 중인 보관함 탭으로 확인합니다. 다른 탭은 실제 화면이 붙어 있습니다.
      final archiveTab = MainShell.tabs[0].label;
      await tester.tap(find.text(archiveTab));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppTopBar, archiveTab), findsOneWidget);
    });
  });
}
