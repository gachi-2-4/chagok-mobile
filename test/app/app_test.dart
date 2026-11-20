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

      await tester.tap(find.text(MainShell.tabs[4].label));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppTopBar, '설정'), findsOneWidget);
    });
  });
}
