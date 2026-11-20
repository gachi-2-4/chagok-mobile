import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/features/calendar/application/calendar_clock.dart';
import 'package:chagok_mobile/features/calendar/data/calendar_repository.dart';
import 'package:chagok_mobile/features/calendar/data/deadline.dart';
import 'package:chagok_mobile/features/calendar/presentation/calendar_screen.dart';
import 'package:chagok_mobile/features/calendar/presentation/calendar_strings.dart';
import 'package:chagok_mobile/features/home/application/home_clock.dart';
import 'package:chagok_mobile/features/home/application/home_today_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_calendar_repository.dart';

void main() {
  late FakeCalendarRepository repository;
  late DateTime now;

  Deadline deadline(
    String id,
    String title,
    DateTime dueDate, {
    bool isRegistered = false,
  }) {
    return Deadline(
      id: id,
      title: title,
      dueDate: dueDate,
      tags: const ['집', '임대'],
      isRegistered: isRegistered,
    );
  }

  Future<void> pumpCalendar(WidgetTester tester, {double textScale = 1}) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarRepositoryProvider.overrideWithValue(repository),
          calendarClockProvider.overrideWithValue(() => now),
          homeClockProvider.overrideWithValue(() => now),
        ],
        retry: (_, _) => null,
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child ?? const SizedBox.shrink(),
          ),
          home: const CalendarScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    now = DateTime(2026, 11, 12, 9);
    repository = FakeCalendarRepository(
      deadlines: [
        deadline('past', '지난 기한', DateTime(2026, 11, 3)),
        deadline('claim', '실손보험 청구 안내', DateTime(2026, 11, 20)),
        deadline('fee', '11월 관리비 고지서', DateTime(2026, 11, 25)),
        deadline(
          'jeonse',
          '전세 임대차 계약서',
          DateTime(2026, 12, 28),
          isRegistered: true,
        ),
      ],
    );
  });

  Finder dayCell(int day) => find.bySemanticsLabel(RegExp('^11월 $day일'));

  group('CalendarScreen', () {
    testWidgets('불러오면 지난 기한을 빼고 다가오는 기한을 D-n과 함께 보여 준다', (tester) async {
      await pumpCalendar(tester);

      expect(find.text(CalendarStrings.upcoming), findsOneWidget);
      expect(find.text('지난 기한'), findsNothing);
      expect(find.text('D-8'), findsOneWidget);
      expect(find.text('11월 20일 · 집 · 임대'), findsOneWidget);
      expect(find.text('D-46'), findsOneWidget);
    });

    testWidgets('날짜를 누르면 그날 기한만 보여 주고 제목을 그 날짜로 바꾼다', (tester) async {
      await pumpCalendar(tester);

      await tester.tap(dayCell(25));
      await tester.pumpAndSettle();

      expect(find.text('11월 25일'), findsOneWidget);
      expect(find.text('11월 관리비 고지서'), findsOneWidget);
      expect(find.text('실손보험 청구 안내'), findsNothing);
    });

    testWidgets('날짜를 고른 뒤 전체 보기를 누르면 다가오는 기한을 다시 모두 보여 준다', (tester) async {
      await pumpCalendar(tester);
      await tester.tap(dayCell(25));
      await tester.pumpAndSettle();

      await tester.tap(find.text(CalendarStrings.viewAll));
      await tester.pumpAndSettle();

      expect(find.text(CalendarStrings.upcoming), findsOneWidget);
      expect(find.text('실손보험 청구 안내'), findsOneWidget);
    });

    testWidgets('기한이 없는 날을 누르면 기한이 없다고 알려 준다', (tester) async {
      await pumpCalendar(tester);

      await tester.tap(dayCell(13));
      await tester.pumpAndSettle();

      expect(find.text(CalendarStrings.noDeadlineOnDate), findsOneWidget);
    });

    testWidgets('기한이 있는 날은 화면 읽기 프로그램에 미추가 기한이 있다고 알린다', (tester) async {
      await pumpCalendar(tester);

      expect(find.bySemanticsLabel('11월 20일, 미추가 기한 있음'), findsOneWidget);
      expect(find.bySemanticsLabel('11월 21일'), findsOneWidget);
    });

    testWidgets('등록 버튼을 누르면 저장하고 버튼을 등록됨으로 바꾼다', (tester) async {
      await pumpCalendar(tester);

      await tester.tap(find.bySemanticsLabel('실손보험 청구 안내, 캘린더에 추가'));
      await tester.pumpAndSettle();

      expect(repository.saved, [('claim', true)]);
      expect(find.bySemanticsLabel('실손보험 청구 안내, 캘린더에서 빼기'), findsOneWidget);
      expect(find.bySemanticsLabel('11월 20일, 등록한 기한 있음'), findsOneWidget);
    });

    testWidgets('등록하지 못하면 다시 시도하라고 알리고 버튼은 그대로 둔다', (tester) async {
      repository.saveError = Exception('network');
      await pumpCalendar(tester);

      await tester.tap(find.bySemanticsLabel('실손보험 청구 안내, 캘린더에 추가'));
      await tester.pumpAndSettle();

      expect(find.text(CalendarStrings.updateFailed), findsOneWidget);
      expect(find.bySemanticsLabel('실손보험 청구 안내, 캘린더에 추가'), findsOneWidget);
    });

    testWidgets('다음 달 버튼을 누르면 다음 달 달력을 보여 준다', (tester) async {
      await pumpCalendar(tester);

      await tester.tap(find.bySemanticsLabel(CalendarStrings.nextMonth));
      await tester.pumpAndSettle();

      expect(find.text('12월'), findsOneWidget);
      expect(find.bySemanticsLabel('12월 28일, 등록한 기한 있음'), findsOneWidget);
    });

    testWidgets('월을 눌러 목록에서 고르면 그 달 달력을 보여 준다', (tester) async {
      await pumpCalendar(tester);

      await tester.tap(find.text('11월'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('3월').last);
      await tester.pumpAndSettle();

      expect(find.text('3월'), findsOneWidget);
      expect(find.bySemanticsLabel('3월 31일'), findsOneWidget);
    });

    testWidgets('불러오지 못하면 실패 안내를 보여 주고 다시 시도하면 다시 불러온다', (tester) async {
      repository.fetchError = Exception('network');
      await pumpCalendar(tester);
      expect(find.text(CalendarStrings.loadFailed), findsOneWidget);

      repository.fetchError = null;
      await tester.tap(find.text(CalendarStrings.retry));
      await tester.pumpAndSettle();

      expect(find.text('실손보험 청구 안내'), findsOneWidget);
    });

    testWidgets('글자를 2배로 키우면 달력과 목록이 넘치지 않는다', (tester) async {
      await pumpCalendar(tester, textScale: 2);

      expect(tester.takeException(), isNull);
    });

    testWidgets('화면 읽기 프로그램으로 등록 버튼을 누르면 기한을 등록한다', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpCalendar(tester);

      tester.semantics.tap(find.semantics.byLabel('실손보험 청구 안내, 캘린더에 추가'));
      await tester.pumpAndSettle();

      expect(repository.saved, [('claim', true)]);
      semantics.dispose();
    });

    testWidgets('화면 읽기 프로그램으로 날짜 칸을 누르면 그날 기한을 보여 준다', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpCalendar(tester);

      tester.semantics.tap(find.semantics.byLabel('11월 25일, 미추가 기한 있음'));
      await tester.pumpAndSettle();

      expect(find.text('11월 25일'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('화면 읽기 프로그램으로 다음 달 버튼을 누르면 다음 달로 넘긴다', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpCalendar(tester);

      tester.semantics.tap(find.semantics.byLabel(CalendarStrings.nextMonth));
      await tester.pumpAndSettle();

      expect(find.text('12월'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('지난 기한이 있는 날을 고르면 D+n으로 지난 날 수를 보여 준다', (tester) async {
      await pumpCalendar(tester);

      await tester.tap(dayCell(3));
      await tester.pumpAndSettle();

      expect(find.text('지난 기한'), findsOneWidget);
      expect(find.text('D+9'), findsOneWidget);
    });

    testWidgets('화면을 연 채로 자정이 지나면 오늘 표시와 D-n을 다음 날 기준으로 바꾼다', (tester) async {
      await pumpCalendar(tester);
      expect(find.text('D-8'), findsOneWidget);

      now = DateTime(2026, 11, 13, 0, 1);
      ProviderScope.containerOf(tester.element(find.byType(CalendarScreen)))
          .read(homeTodayProvider.notifier)
          .refresh();
      await tester.pumpAndSettle();

      expect(find.text('D-7'), findsOneWidget);
      expect(find.text('D-8'), findsNothing);
    });
  });
}
