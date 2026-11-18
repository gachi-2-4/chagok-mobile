import 'package:chagok_mobile/app/app.dart';
import 'package:chagok_mobile/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChagokApp', () {
    testWidgets('앱을 실행하면 홈 화면이 보인다', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: ChagokApp()));

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.widgetWithText(AppBar, '차곡'), findsOneWidget);
    });
  });
}
