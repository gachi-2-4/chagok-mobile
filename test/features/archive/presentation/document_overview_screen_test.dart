import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/features/archive/application/archive_clock.dart';
import 'package:chagok_mobile/features/archive/data/archive_box.dart';
import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_document.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:chagok_mobile/features/archive/data/document_cost.dart';
import 'package:chagok_mobile/features/archive/data/document_importance.dart';
import 'package:chagok_mobile/features/archive/data/document_overview.dart';
import 'package:chagok_mobile/features/archive/data/document_summary.dart';
import 'package:chagok_mobile/features/archive/data/summary_row.dart';
import 'package:chagok_mobile/features/archive/data/summary_section.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:chagok_mobile/features/archive/presentation/box_detail_screen.dart';
import 'package:chagok_mobile/features/archive/presentation/document_overview_screen.dart';
import 'package:chagok_mobile/features/archive/presentation/document_tab.dart';
import 'package:chagok_mobile/features/document/presentation/document_edit_screen.dart';
import 'package:chagok_mobile/features/document/presentation/document_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/fake_archive_repository.dart';

void main() {
  late FakeArchiveRepository repository;

  const housing = ArchiveBox(
    id: 'housing',
    name: '집 · 임대',
    color: BoxColor.peach,
    icon: BoxIcon.home,
    documentCount: 2,
  );
  final lease = BoxDocument(
    id: 'lease',
    title: '전세 임대차 계약서',
    importance: DocumentImportance.high,
    pageCount: 4,
    dueDate: DateTime(2027, 1, 5),
  );
  const moveIn = BoxDocument(
    id: 'move-in',
    title: '전입신고 확인서',
    importance: DocumentImportance.low,
    pageCount: 1,
  );
  const reminderScreenText = '납부일 알림 화면';

  /// 서류 상세와 그 앞뒤 화면만 둔 라우터로 [initialLocation]부터 엽니다.
  Future<void> pumpRouter(
    WidgetTester tester, {
    String initialLocation = '/documents/lease',
  }) async {
    tester.view.physicalSize = const Size(402, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const BoxDetailScreen(boxId: 'housing'),
        ),
        GoRoute(
          path: AppRoute.documentPattern,
          builder: (context, state) => DocumentOverviewScreen(
            documentId: state.pathParameters['id'] ?? '',
            initialTab: DocumentTab.fromQuery(state.uri.queryParameters['tab']),
          ),
        ),
        GoRoute(
          path: AppRoute.documentEditPattern,
          builder: (context, state) =>
              DocumentEditScreen(documentId: state.pathParameters['id'] ?? ''),
        ),
        GoRoute(
          path: AppRoute.paymentReminderPattern,
          builder: (context, state) =>
              const Scaffold(body: Text(reminderScreenText)),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          archiveRepositoryProvider.overrideWithValue(repository),
          archiveClockProvider.overrideWithValue(
            () => DateTime(2026, 11, 20, 9),
          ),
        ],
        retry: (_, _) => null,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    repository = FakeArchiveRepository(
      boxes: [housing],
      documents: {
        'housing': [lease, moveIn],
      },
      overviews: {
        'lease': DocumentOverview(
          document: lease,
          box: housing,
          cost: const DocumentCost(label: '보증금', amount: 230000000),
          dueLabel: '갱신 통보',
          periodEnd: DateTime(2027, 2, 28),
          summary: DocumentSummary(
            oneLine: '보증금 2억 3천만 원, 2년 계약이에요.',
            sections: [
              SummaryTable(
                title: '계약 개요',
                rows: const [SummaryRow(label: '임대인', value: '김○○')],
              ),
              SummaryList(title: '주요 특약', items: const ['반려동물은 사전 동의 후 가능']),
            ],
          ),
        ),
        'move-in': DocumentOverview(
          document: moveIn,
          box: housing,
          summary: DocumentSummary(oneLine: '전입신고를 마쳤어요.', sections: const []),
        ),
      },
    );
  });

  group('DocumentOverviewScreen', () {
    testWidgets('열면 원본 탭과 보관함·중요도·비용·D-day를 보여 준다', (tester) async {
      await pumpRouter(tester);

      expect(find.text('집 · 임대'), findsOneWidget);
      expect(find.text(ArchiveStrings.pagePosition(1, 4)), findsOneWidget);
      expect(find.text(ArchiveStrings.openSummaryAction), findsOneWidget);
      expect(find.text('높음'), findsOneWidget);
      expect(find.text('보증금 230,000,000원'), findsOneWidget);
      expect(find.text('D-46'), findsOneWidget);
      expect(find.text('~2027.02.28 · 갱신 통보 1.5까지'), findsOneWidget);
      expect(find.text(ArchiveStrings.deadlineRegistered), findsOneWidget);
    });

    testWidgets('원본을 옆으로 넘기면 쪽 위치가 바뀐다', (tester) async {
      await pumpRouter(tester);

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text(ArchiveStrings.pagePosition(2, 4)), findsOneWidget);
    });

    testWidgets('AI 정리본 탭을 누르면 한 줄 요약과 표·목록을 보여 준다', (tester) async {
      await pumpRouter(tester);

      await tester.tap(find.text(ArchiveStrings.tabSummary));
      await tester.pumpAndSettle();

      expect(find.text('보증금 2억 3천만 원, 2년 계약이에요.'), findsOneWidget);
      expect(find.text('계약 개요'), findsOneWidget);
      expect(find.text('김○○'), findsOneWidget);
      expect(find.text('반려동물은 사전 동의 후 가능'), findsOneWidget);
      expect(find.byType(PageView), findsNothing);
    });

    testWidgets('AI 정리본 열기와 원본 보기를 누르면 탭을 오간다', (tester) async {
      await pumpRouter(tester);

      await tester.tap(find.text(ArchiveStrings.openSummaryAction));
      await tester.pumpAndSettle();
      expect(find.text(ArchiveStrings.oneLineSummary), findsOneWidget);

      await tester.tap(find.text(ArchiveStrings.viewOriginal));
      await tester.pumpAndSettle();
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('AI 정리본 탭으로 열면 처음부터 AI 정리본을 보여 준다', (tester) async {
      await pumpRouter(tester, initialLocation: '/documents/lease?tab=summary');

      expect(find.text(ArchiveStrings.oneLineSummary), findsOneWidget);
    });

    testWidgets('비용·기한이 없는 서류면 중요도만 보여 주고 기한 버튼을 두지 않는다', (tester) async {
      await pumpRouter(tester, initialLocation: '/documents/move-in');

      expect(find.text('낮음'), findsOneWidget);
      expect(find.text(ArchiveStrings.costLabel), findsNothing);
      expect(find.text(ArchiveStrings.dDayLabel), findsNothing);
      expect(find.text(ArchiveStrings.deadlineRegistered), findsNothing);
    });

    testWidgets('기한 자동 등록됨을 누르면 납부일 알림 화면으로 간다', (tester) async {
      await pumpRouter(tester);

      await tester.tap(find.text(ArchiveStrings.deadlineRegistered));
      await tester.pumpAndSettle();

      expect(find.text(reminderScreenText), findsOneWidget);
    });

    testWidgets('더보기에서 내용 수정을 고르고 원본 확인하기를 누르면 원본 탭으로 돌아온다', (tester) async {
      await pumpRouter(tester, initialLocation: '/documents/lease?tab=summary');

      await tester.tap(find.byTooltip(ArchiveStrings.moreActions));
      await tester.pumpAndSettle();
      await tester.tap(find.text(ArchiveStrings.editContent));
      await tester.pumpAndSettle();
      expect(find.byType(DocumentEditScreen), findsOneWidget);

      await tester.ensureVisible(find.text(DocumentStrings.viewOriginal));
      await tester.tap(find.text(DocumentStrings.viewOriginal));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentEditScreen), findsNothing);
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('없는 서류를 열면 찾을 수 없다는 안내만 보여 준다', (tester) async {
      await pumpRouter(tester, initialLocation: '/documents/missing');

      expect(find.text(ArchiveStrings.documentNotFound), findsOneWidget);
      expect(find.text(ArchiveStrings.retry), findsNothing);
    });

    testWidgets('불러오지 못하면 다시 시도로 다시 불러온다', (tester) async {
      repository.overviewError = Exception('네트워크 오류');
      await pumpRouter(tester);
      expect(find.text(ArchiveStrings.documentLoadFailed), findsOneWidget);
      repository.overviewError = null;

      await tester.tap(find.text(ArchiveStrings.retry));
      await tester.pumpAndSettle();

      expect(find.text('D-46'), findsOneWidget);
    });

    testWidgets('보관함에서 서류 카드를 누르면 원본 탭으로 연다', (tester) async {
      await pumpRouter(tester, initialLocation: '/');

      await tester.tap(find.text('전세 임대차 계약서'));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentOverviewScreen), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('보관함에서 서류의 AI 정리본 보기를 누르면 AI 정리본 탭으로 연다', (tester) async {
      await pumpRouter(tester, initialLocation: '/');

      await tester.tap(find.bySemanticsLabel(ArchiveStrings.openSummary).first);
      await tester.pumpAndSettle();

      expect(find.byType(DocumentOverviewScreen), findsOneWidget);
      expect(find.text(ArchiveStrings.oneLineSummary), findsOneWidget);
    });
  });
}
