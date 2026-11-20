import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/features/archive/application/archive_clock.dart';
import 'package:chagok_mobile/features/archive/data/archive_box.dart';
import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_document.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:chagok_mobile/features/archive/data/document_importance.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:chagok_mobile/features/archive/presentation/box_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_archive_repository.dart';

void main() {
  late FakeArchiveRepository repository;

  Future<void> pumpDetail(
    WidgetTester tester, {
    String boxId = 'housing',
  }) async {
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
          home: BoxDetailScreen(boxId: boxId),
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
          documentCount: 2,
        ),
        const ArchiveBox(
          id: 'empty',
          name: '반려동물',
          color: BoxColor.green,
          icon: BoxIcon.pet,
          documentCount: 0,
        ),
      ],
      documents: {
        'housing': [
          BoxDocument(
            id: 'lease',
            title: '전세 임대차 계약서',
            importance: DocumentImportance.high,
            pageCount: 4,
            dueDate: DateTime(2027, 1, 5),
          ),
          const BoxDocument(
            id: 'move-in',
            title: '전입신고 확인서',
            importance: DocumentImportance.low,
            pageCount: 1,
          ),
        ],
      },
      plainLanguages: {'lease': '집주인에게 보증금을 맡기고 2년 동안 사는 계약이에요.'},
    );
  });

  Finder translateButton() =>
      find.bySemanticsLabel(ArchiveStrings.translate).first;

  group('BoxDetailScreen', () {
    testWidgets('불러오면 보관함 이름과 서류의 중요도·D-n·쪽수를 보여 준다', (tester) async {
      await pumpDetail(tester);

      expect(find.text('집 · 임대'), findsOneWidget);
      expect(find.text('서류 2건'), findsOneWidget);
      expect(find.text('전세 임대차 계약서'), findsOneWidget);
      expect(find.text('중요 높음'), findsOneWidget);
      expect(find.text('D-46'), findsOneWidget);
      expect(find.text('4장'), findsOneWidget);
      expect(find.text('중요 낮음'), findsOneWidget);
    });

    testWidgets('한 장짜리 서류면 쪽수 표를 그리지 않는다', (tester) async {
      await pumpDetail(tester);

      expect(find.text('1장'), findsNothing);
    });

    testWidgets('서류가 없으면 빈 보관함 안내를 보여 준다', (tester) async {
      await pumpDetail(tester, boxId: 'empty');

      expect(find.text(ArchiveStrings.emptyBox), findsOneWidget);
    });

    testWidgets('없는 보관함을 열면 찾을 수 없다는 안내만 보여 준다', (tester) async {
      await pumpDetail(tester, boxId: 'missing');

      expect(find.text(ArchiveStrings.boxNotFound), findsOneWidget);
      expect(find.text(ArchiveStrings.retry), findsNothing);
    });

    testWidgets('쉬운 말로 번역을 누르면 쉬운 말 설명과 AI 안내를 띄운다', (tester) async {
      await pumpDetail(tester);

      await tester.tap(translateButton());
      await tester.pumpAndSettle();

      expect(find.text(ArchiveStrings.plainLanguageTitle), findsOneWidget);
      expect(find.text('집주인에게 보증금을 맡기고 2년 동안 사는 계약이에요.'), findsOneWidget);
      expect(find.text(ArchiveStrings.aiNotice), findsOneWidget);
    });

    testWidgets('쉬운 말로 바꾸지 못하면 다시 시도로 다시 불러온다', (tester) async {
      repository.translateError = Exception('네트워크 오류');
      await pumpDetail(tester);
      await tester.tap(translateButton());
      await tester.pumpAndSettle();
      expect(find.text(ArchiveStrings.translateFailed), findsOneWidget);
      repository.translateError = null;

      await tester.tap(find.text(ArchiveStrings.retry));
      await tester.pumpAndSettle();

      expect(find.text('집주인에게 보증금을 맡기고 2년 동안 사는 계약이에요.'), findsOneWidget);
    });

    testWidgets('설명 시트에서 닫기를 누르면 시트를 닫는다', (tester) async {
      await pumpDetail(tester);
      await tester.tap(translateButton());
      await tester.pumpAndSettle();

      await tester.tap(find.text(ArchiveStrings.close));
      await tester.pumpAndSettle();

      expect(find.text(ArchiveStrings.plainLanguageTitle), findsNothing);
    });

    testWidgets('불러오지 못하면 안내와 다시 시도 버튼을 보여 준다', (tester) async {
      repository.fetchError = Exception('네트워크 오류');

      await pumpDetail(tester);

      expect(find.text(ArchiveStrings.loadFailed), findsOneWidget);
      expect(find.text(ArchiveStrings.retry), findsOneWidget);
    });
  });
}
