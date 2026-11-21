import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/features/archive/application/archive_clock.dart';
import 'package:chagok_mobile/features/archive/data/archive_box.dart';
import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_document.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:chagok_mobile/features/archive/data/document_importance.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:chagok_mobile/features/archive/presentation/document_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_archive_repository.dart';

void main() {
  late FakeArchiveRepository repository;

  Future<void> pumpSearch(WidgetTester tester) async {
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
        ],
        retry: (_, _) => null,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const DocumentSearchScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    repository = FakeArchiveRepository(
      boxes: [
        const ArchiveBox(
          id: 'housing',
          name: '집 · 임대',
          color: BoxColor.peach,
          icon: BoxIcon.home,
          documentCount: 1,
        ),
        const ArchiveBox(
          id: 'tax',
          name: '세금',
          color: BoxColor.gray,
          icon: BoxIcon.tax,
          documentCount: 1,
        ),
      ],
      documents: {
        'housing': [
          const BoxDocument(
            id: 'fee',
            title: '11월 관리비 고지서',
            importance: DocumentImportance.medium,
            pageCount: 1,
          ),
        ],
        'tax': [
          const BoxDocument(
            id: 'property-tax',
            title: '재산세 고지서',
            importance: DocumentImportance.medium,
            pageCount: 1,
          ),
        ],
      },
    );
  });

  group('DocumentSearchScreen', () {
    testWidgets('처음 열면 검색 안내를 보여 준다', (tester) async {
      await pumpSearch(tester);

      expect(find.text(ArchiveStrings.searchGuide), findsOneWidget);
    });

    testWidgets('검색어를 적으면 맞는 서류를 보관함 이름과 함께 보여 준다', (tester) async {
      await pumpSearch(tester);

      await tester.enterText(find.byType(TextField), '고지서');
      await tester.pumpAndSettle();

      expect(find.text('서류 2건'), findsOneWidget);
      expect(find.text('11월 관리비 고지서'), findsOneWidget);
      expect(find.text('집 · 임대'), findsOneWidget);
      expect(find.text('재산세 고지서'), findsOneWidget);
      expect(find.text('세금'), findsOneWidget);
    });

    testWidgets('맞는 서류가 없으면 없다는 안내를 보여 준다', (tester) async {
      await pumpSearch(tester);

      await tester.enterText(find.byType(TextField), '비행기표');
      await tester.pumpAndSettle();

      expect(find.text(ArchiveStrings.noSearchResult('비행기표')), findsOneWidget);
    });

    testWidgets('찾지 못하면 안내와 다시 시도 버튼을 보여 준다', (tester) async {
      repository.searchError = Exception('네트워크 오류');
      await pumpSearch(tester);

      await tester.enterText(find.byType(TextField), '고지서');
      await tester.pumpAndSettle();

      expect(find.text(ArchiveStrings.searchFailed), findsOneWidget);
      expect(find.text(ArchiveStrings.retry), findsOneWidget);
    });
  });
}
