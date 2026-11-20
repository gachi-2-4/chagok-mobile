import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/features/archive/application/archive_clock.dart';
import 'package:chagok_mobile/features/archive/data/archive_box.dart';
import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_screen.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:chagok_mobile/features/notification/data/notification_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_archive_repository.dart';
import '../../../helpers/fake_notification_repository.dart';

void main() {
  late FakeArchiveRepository repository;

  Future<void> pumpArchive(WidgetTester tester) async {
    tester.view.physicalSize = const Size(402, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          archiveRepositoryProvider.overrideWithValue(repository),
          archiveClockProvider.overrideWithValue(
            () => DateTime(2026, 11, 20, 9),
          ),
          notificationRepositoryProvider.overrideWithValue(
            FakeNotificationRepository(),
          ),
        ],
        retry: (_, _) => null,
        child: MaterialApp(theme: AppTheme.light, home: const ArchiveScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    repository = FakeArchiveRepository(
      boxes: [
        ArchiveBox(
          id: 'housing',
          name: '집 · 임대',
          color: BoxColor.peach,
          icon: BoxIcon.home,
          documentCount: 3,
          nextDueDate: DateTime(2026, 12, 3),
        ),
        const ArchiveBox(
          id: 'car',
          name: '자동차',
          color: BoxColor.green,
          icon: BoxIcon.car,
          documentCount: 2,
        ),
      ],
    );
  });

  group('ArchiveScreen', () {
    testWidgets('불러오면 보관함 이름·서류 수·D-n과 새 박스 칸을 보여 준다', (tester) async {
      await pumpArchive(tester);

      expect(find.text(ArchiveStrings.title), findsOneWidget);
      expect(find.text('집 · 임대'), findsOneWidget);
      expect(find.text('서류 3건'), findsOneWidget);
      expect(find.text('D-13'), findsOneWidget);
      expect(find.text('자동차'), findsOneWidget);
      expect(find.text(ArchiveStrings.newBox), findsOneWidget);
    });

    testWidgets('불러오지 못하면 안내와 다시 시도 버튼을 보여 준다', (tester) async {
      repository.fetchError = Exception('네트워크 오류');

      await pumpArchive(tester);

      expect(find.text(ArchiveStrings.loadFailed), findsOneWidget);
      expect(find.text(ArchiveStrings.retry), findsOneWidget);
    });

    testWidgets('다시 시도를 누르면 보관함을 다시 불러온다', (tester) async {
      repository.fetchError = Exception('네트워크 오류');
      await pumpArchive(tester);
      repository.fetchError = null;

      await tester.tap(find.text(ArchiveStrings.retry));
      await tester.pumpAndSettle();

      expect(find.text('집 · 임대'), findsOneWidget);
    });

    testWidgets('새 박스 칸을 누르면 새 박스 만들기 시트를 연다', (tester) async {
      await pumpArchive(tester);

      await tester.tap(find.text(ArchiveStrings.newBox));
      await tester.pumpAndSettle();

      expect(find.text(ArchiveStrings.newBoxTitle), findsOneWidget);
    });

    testWidgets('시트에 이름을 적지 않으면 만들기 버튼이 꺼져 있다', (tester) async {
      await pumpArchive(tester);
      await tester.tap(find.text(ArchiveStrings.newBox));
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, ArchiveStrings.create),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('시트에서 이름·색·아이콘을 골라 만들면 시트를 닫고 목록에 더한다', (tester) async {
      await pumpArchive(tester);
      await tester.tap(find.text(ArchiveStrings.newBox));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '반려동물');
      await tester.tap(
        find.bySemanticsLabel(ArchiveStrings.colorName(BoxColor.green)),
      );
      await tester.tap(
        find.bySemanticsLabel(ArchiveStrings.iconName(BoxIcon.pet)),
      );
      await tester.pump();
      await tester.tap(find.text(ArchiveStrings.create));
      await tester.pumpAndSettle();

      expect(repository.created, [('반려동물', BoxColor.green, BoxIcon.pet)]);
      expect(find.text(ArchiveStrings.newBoxTitle), findsNothing);
      expect(find.text('반려동물'), findsOneWidget);
    });

    testWidgets('만들지 못하면 시트를 닫지 않고 실패 안내를 보여 준다', (tester) async {
      repository.createError = Exception('네트워크 오류');
      await pumpArchive(tester);
      await tester.tap(find.text(ArchiveStrings.newBox));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '반려동물');
      await tester.pump();
      await tester.tap(find.text(ArchiveStrings.create));
      await tester.pumpAndSettle();

      expect(find.text(ArchiveStrings.newBoxTitle), findsOneWidget);
      expect(find.text(ArchiveStrings.createFailed), findsOneWidget);
    });

    testWidgets('취소를 누르면 만들지 않고 시트를 닫는다', (tester) async {
      await pumpArchive(tester);
      await tester.tap(find.text(ArchiveStrings.newBox));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '반려동물');
      await tester.tap(find.text(ArchiveStrings.cancel));
      await tester.pumpAndSettle();

      expect(find.text(ArchiveStrings.newBoxTitle), findsNothing);
      expect(repository.created, isEmpty);
    });
  });
}
