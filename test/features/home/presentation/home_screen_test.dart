import 'dart:async';

import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/features/home/application/home_clock.dart';
import 'package:chagok_mobile/features/home/data/home_repository.dart';
import 'package:chagok_mobile/features/home/data/recent_alert.dart';
import 'package:chagok_mobile/features/home/presentation/home_screen.dart';
import 'package:chagok_mobile/features/home/presentation/home_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_home_repository.dart';

void main() {
  final now = DateTime(2026, 11, 18, 10);
  late FakeHomeRepository repository;

  setUp(() {
    repository = FakeHomeRepository();
  });

  Future<void> pumpHomeScreen(WidgetTester tester) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeRepositoryProvider.overrideWithValue(repository),
          homeClockProvider.overrideWithValue(() => now),
        ],
        retry: (_, _) => null,
        child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      ),
    );
  }

  RecentAlert alert({required bool isRead}) => RecentAlert(
    id: 'id',
    title: '관리비 납부일이 다가와요',
    boxName: '집 · 임대',
    createdAt: now,
    isRead: isRead,
  );

  group('HomeScreen', () {
    testWidgets('홈 내용을 불러오는 중이면 로딩 표시를 보여 준다', (tester) async {
      repository.gate = Completer<void>();

      await pumpHomeScreen(tester);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      repository.gate?.complete();
    });

    testWidgets('홈 내용을 불러오지 못하면 안내와 다시 시도 버튼을 보여 준다', (tester) async {
      repository.error = Exception('network');

      await pumpHomeScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text(HomeStrings.loadFailed), findsOneWidget);
      expect(find.text(HomeStrings.retry), findsOneWidget);
    });

    testWidgets('다시 시도를 누르면 홈 내용을 다시 불러온다', (tester) async {
      repository.error = Exception('network');
      await pumpHomeScreen(tester);
      await tester.pumpAndSettle();

      repository.error = null;
      await tester.tap(find.text(HomeStrings.retry));
      await tester.pumpAndSettle();

      expect(find.text(HomeStrings.miniCalendar), findsOneWidget);
    });

    testWidgets('홈 내용을 불러오면 미니 캘린더·보관함·알림 구역을 보여 준다', (tester) async {
      repository.alerts = [alert(isRead: false)];

      await pumpHomeScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text(HomeStrings.miniCalendar), findsOneWidget);
      expect(find.text(HomeStrings.recentBoxes), findsOneWidget);
      expect(find.text('관리비 납부일이 다가와요'), findsOneWidget);
    });
  });
}
