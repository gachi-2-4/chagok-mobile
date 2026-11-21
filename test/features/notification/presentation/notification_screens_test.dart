import 'dart:async';

import 'package:chagok_mobile/app/app.dart';
import 'package:chagok_mobile/core/widgets/app_bottom_nav_bar.dart';
import 'package:chagok_mobile/features/archive/presentation/document_overview_screen.dart';
import 'package:chagok_mobile/features/home/application/home_clock.dart';
import 'package:chagok_mobile/features/home/application/home_today_notifier.dart';
import 'package:chagok_mobile/features/home/data/home_repository.dart';
import 'package:chagok_mobile/features/home/presentation/home_strings.dart';
import 'package:chagok_mobile/features/notification/application/notification_clock.dart';
import 'package:chagok_mobile/features/notification/application/notification_filter.dart';
import 'package:chagok_mobile/features/notification/data/app_notification.dart';
import 'package:chagok_mobile/features/notification/data/notification_kind.dart';
import 'package:chagok_mobile/features/notification/data/notification_repository.dart';
import 'package:chagok_mobile/features/notification/presentation/notification_detail_screen.dart';
import 'package:chagok_mobile/features/notification/presentation/notification_list_screen.dart';
import 'package:chagok_mobile/features/notification/presentation/notification_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_home_repository.dart';
import '../../../helpers/fake_notification_repository.dart';
import '../../../helpers/sample_notifications.dart';

void main() {
  late FakeNotificationRepository repository;
  late DateTime now;

  /// 앱을 띄우고 홈의 종 버튼으로 알림 목록을 엽니다.
  Future<void> openNotifications(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // 위젯 트리와 함께 정리되도록 ProviderScope를 씁니다. 홈 화면의 자정 Timer
    // 같은 것이 testWidgets의 Timer 검사 전에 함께 취소됩니다.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(repository),
          notificationClockProvider.overrideWithValue(() => now),
          homeClockProvider.overrideWithValue(() => now),
          homeRepositoryProvider.overrideWithValue(FakeHomeRepository()),
        ],
        retry: (_, _) => null,
        child: const ChagokApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.bySemanticsLabel(RegExp('^${HomeStrings.notifications}')),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  setUp(() {
    now = DateTime(2026, 11, 18, 10);
    repository = FakeNotificationRepository(
      notifications: sampleNotifications(),
    );
  });

  group('NotificationListScreen', () {
    testWidgets('홈의 종 버튼을 누르면 바텀바가 있는 알림 목록을 연다', (tester) async {
      await openNotifications(tester);

      expect(find.byType(NotificationListScreen), findsOneWidget);
      expect(find.byType(AppBottomNavBar), findsOneWidget);
    });

    testWidgets('목록을 열면 최근 알림부터 보여 주고 새 알림 수와 D-n을 보여 준다', (tester) async {
      await openNotifications(tester);

      expect(find.text(NotificationStrings.newCount(1)), findsOneWidget);
      expect(find.text('D-1'), findsOneWidget);
      expect(find.text('2026-11-18 · 오전 9:00'), findsOneWidget);
      final rentTop = tester.getTopLeft(find.text('내일은 월세 납부일이에요')).dy;
      final oldTop = tester.getTopLeft(find.text('임대차계약서 만기가 30일 남았어요')).dy;
      expect(rentTop, lessThan(oldTop));
    });

    testWidgets('읽지 않음 탭을 누르면 읽지 않은 알림만 보여 준다', (tester) async {
      await openNotifications(tester);

      await tapText(
        tester,
        NotificationStrings.filter(NotificationFilter.unread),
      );

      expect(find.text('내일은 월세 납부일이에요'), findsOneWidget);
      expect(find.text('관리비 납부 완료'), findsNothing);
    });

    testWidgets('완료 탭을 누르면 완료로 표시한 알림만 보여 준다', (tester) async {
      await openNotifications(tester);

      await tapText(
        tester,
        NotificationStrings.filter(NotificationFilter.done),
      );

      expect(find.text('관리비 납부 완료'), findsOneWidget);
      expect(find.text('내일은 월세 납부일이에요'), findsNothing);
    });

    testWidgets('모두 읽음을 누르면 저장하고 새 알림 수를 0으로 바꾼다', (tester) async {
      await openNotifications(tester);

      await tapText(tester, NotificationStrings.markAllRead);

      expect(repository.readRequests, [
        ['rent'],
      ]);
      expect(find.text(NotificationStrings.newCount(0)), findsOneWidget);
    });

    testWidgets('알림을 누르면 읽음으로 표시하고 바텀바 없는 상세 화면을 연다', (tester) async {
      await openNotifications(tester);

      await tapText(tester, '내일은 월세 납부일이에요');

      expect(find.byType(NotificationDetailScreen), findsOneWidget);
      expect(find.text('[납부] 내일은 월세 납부일이에요'), findsOneWidget);
      expect(find.text('500,000원'), findsOneWidget);
      expect(find.byType(AppBottomNavBar), findsNothing);
      expect(repository.readRequests, [
        ['rent'],
      ]);
    });

    testWidgets('불러오지 못하면 실패 안내를 보여 주고 다시 시도하면 다시 불러온다', (tester) async {
      repository.fetchError = Exception('network');
      await openNotifications(tester);
      expect(find.text(NotificationStrings.loadFailed), findsOneWidget);

      repository.fetchError = null;
      await tapText(tester, NotificationStrings.retry);

      expect(find.text('내일은 월세 납부일이에요'), findsOneWidget);
    });
    testWidgets('글자를 2배로 키우면 목록과 상세가 넘치지 않는다', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openNotifications(tester);
      expect(tester.takeException(), isNull);

      await tapText(tester, '내일은 월세 납부일이에요');

      expect(tester.takeException(), isNull);
    });
  });

  group('NotificationDetailScreen', () {
    testWidgets('납부 완료로 표시하면 목록으로 돌아가 완료 탭에서 그 알림을 볼 수 있다', (tester) async {
      await openNotifications(tester);
      await tapText(tester, '내일은 월세 납부일이에요');

      await tapText(tester, NotificationStrings.markDone);
      expect(find.byType(NotificationDetailScreen), findsNothing);
      expect(find.byType(NotificationListScreen), findsOneWidget);

      await tapText(
        tester,
        NotificationStrings.filter(NotificationFilter.done),
      );

      expect(repository.doneRequests, ['rent']);
      expect(find.text('내일은 월세 납부일이에요'), findsOneWidget);
    });

    testWidgets('완료하지 못하면 다시 시도하라고 알리고 상세 화면에 남는다', (tester) async {
      await openNotifications(tester);
      await tapText(tester, '내일은 월세 납부일이에요');
      repository.saveError = Exception('network');

      await tapText(tester, NotificationStrings.markDone);

      expect(find.text(NotificationStrings.saveFailed), findsOneWidget);
      expect(find.byType(NotificationDetailScreen), findsOneWidget);
    });

    testWidgets('상세의 탭을 누르면 그 탭을 고른 채 목록으로 돌아간다', (tester) async {
      await openNotifications(tester);
      await tapText(tester, '내일은 월세 납부일이에요');

      await tapText(
        tester,
        NotificationStrings.filter(NotificationFilter.done),
      );

      expect(find.byType(NotificationDetailScreen), findsNothing);
      expect(find.text('관리비 납부 완료'), findsOneWidget);
      expect(find.text('내일은 월세 납부일이에요'), findsNothing);
    });

    testWidgets('완료한 납부 알림을 열면 완료 버튼과 납부 안내를 숨긴다', (tester) async {
      await openNotifications(tester);

      await tapText(tester, '관리비 납부 완료');

      expect(find.text(NotificationStrings.markDone), findsNothing);
      expect(find.text(NotificationStrings.paymentGuide), findsNothing);
    });

    testWidgets('연결된 서류 보기를 누르면 그 서류 상세를 연다', (tester) async {
      await openNotifications(tester);
      await tapText(tester, '내일은 월세 납부일이에요');

      await tapText(tester, NotificationStrings.viewDocument);

      expect(find.byType(DocumentOverviewScreen), findsOneWidget);
    });

    testWidgets('서류 id가 없는 알림이면 서류 보기 버튼을 두지 않는다', (tester) async {
      repository.notifications = [
        for (final notification in sampleNotifications())
          AppNotification(
            id: notification.id,
            kind: notification.kind,
            title: notification.title,
            sentAt: notification.sentAt,
            isRead: notification.isRead,
            boxName: notification.boxName,
            documentName: notification.documentName,
          ),
      ];
      await openNotifications(tester);
      await tapText(tester, '내일은 월세 납부일이에요');

      expect(find.text(NotificationStrings.viewDocument), findsNothing);
    });

    testWidgets('완료를 저장하는 사이 버튼을 다시 누르면 한 번만 저장하고 목록으로 한 번만 돌아간다', (
      tester,
    ) async {
      await openNotifications(tester);
      await tapText(tester, '내일은 월세 납부일이에요');
      repository.saveGate = Completer<void>();

      await tester.tap(find.text(NotificationStrings.markDone));
      await tester.pump();
      await tester.tap(
        find.text(NotificationStrings.markDone),
        warnIfMissed: false,
      );
      await tester.pump();
      repository.saveGate?.complete();
      await tester.pumpAndSettle();

      expect(repository.doneRequests, ['rent']);
      expect(find.byType(NotificationListScreen), findsOneWidget);
    });

    testWidgets('보관함 이름이 길어도 글자를 2배로 키우면 연결 서류 줄이 넘치지 않는다', (tester) async {
      repository.notifications = [
        for (final notification in sampleNotifications())
          notification.id == 'rent'
              ? AppNotification(
                  id: 'rent',
                  kind: NotificationKind.payment,
                  title: notification.title,
                  sentAt: notification.sentAt,
                  boxName: '우리 가족이 함께 사는 집 · 전세 임대 계약',
                  dueDate: notification.dueDate,
                  amount: notification.amount,
                  documentName: '주택 임대차 표준 계약서',
                )
              : notification,
      ];
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openNotifications(tester);

      await tapText(tester, '내일은 월세 납부일이에요');

      expect(tester.takeException(), isNull);
    });
  });

  group('날짜·읽음 처리', () {
    testWidgets('목록을 연 채로 자정이 지나면 납부 알림의 D-1을 D-DAY로 바꾼다', (tester) async {
      await openNotifications(tester);
      expect(find.text('D-1'), findsOneWidget);

      now = DateTime(2026, 11, 19, 0, 1);
      ProviderScope.containerOf(
        tester.element(find.byType(NotificationListScreen)),
      ).read(homeTodayProvider.notifier).refresh();
      await tester.pumpAndSettle();

      expect(find.text('D-DAY'), findsOneWidget);
    });

    testWidgets('알림을 읽음으로 저장하지 못하면 상세는 열고 다시 시도하라고 알린다', (tester) async {
      await openNotifications(tester);
      repository.saveError = Exception('network');

      await tapText(tester, '내일은 월세 납부일이에요');

      expect(find.byType(NotificationDetailScreen), findsOneWidget);
      expect(find.text(NotificationStrings.saveFailed), findsOneWidget);
    });
  });
}
