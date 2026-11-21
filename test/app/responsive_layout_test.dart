import 'package:chagok_mobile/app/app.dart';
import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/features/upload/application/upload_notifier.dart';
import 'package:chagok_mobile/features/upload/data/sample_upload_repository.dart';
import 'package:chagok_mobile/features/upload/data/upload_repository.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 화면 크기와 글자 크기가 달라도 어느 화면도 넘치지 않는지 확인합니다.
///
/// 넘치기 쉬운 경우만 고릅니다. 가장 작은 폰(320×568)에 앱 "아주 크게"(1.3)와
/// 기기 글자 최대(2.0), 그리고 태블릿과 가로 화면입니다.
void main() {
  const cases = [
    ('가장 작은 폰에 글자를 아주 크게 키우면', Size(320, 568), 1.3),
    ('가장 작은 폰에 기기 글자를 최대로 키우면', Size(320, 568), 2.0),
    ('태블릿에서 열면', Size(820, 1180), 1.0),
    ('폰을 가로로 돌리면', Size(844, 390), 1.0),
  ];

  /// 서버 없이 예시 데이터로 바로 열 수 있는 화면.
  const routes = [
    AppRoute.home,
    AppRoute.archive,
    '/archive/housing',
    AppRoute.archiveSearch,
    '/documents/lease',
    '/documents/lease?tab=summary',
    '/documents/move-in-report',
    '/documents/lease/edit',
    '/documents/lease/reminder',
    AppRoute.upload,
    AppRoute.chat,
    '/chat/thread-0',
    '/chat/thread-0/documents',
    AppRoute.notifications,
    '/notifications/rent-due',
    AppRoute.calendar,
    AppRoute.settings,
    AppRoute.textSizeSettings,
    AppRoute.notificationSettings,
    AppRoute.login,
    AppRoute.signUp,
    AppRoute.forgotPassword,
    AppRoute.onboarding,
  ];

  for (final (situation, size, textScale) in cases) {
    testWidgets('$situation 모든 화면이 넘치지 않는다', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      // 넘침은 화면마다 따로 모아, 어느 화면에서 넘쳤는지 함께 보여 줍니다.
      final overflows = <String>[];
      var screen = '';
      final reportError = FlutterError.onError;
      FlutterError.onError = (details) {
        overflows.add(
          '$screen: ${details.exceptionAsString().split('\n').first}',
        );
      };
      addTearDown(() => FlutterError.onError = reportError);

      // 기기 스캐너·파일 선택기 대신 예시 서류를 바로 돌려줘 U02·U04까지 열어 봅니다.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uploadRepositoryProvider.overrideWithValue(
              SampleUploadRepository(),
            ),
          ],
          child: const ChagokApp(),
        ),
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ChagokApp)),
      );
      final router = container.read(routerProvider);

      // 불러오는 표시가 돌아가 pumpAndSettle은 끝나지 않으므로 정해진 만큼만 그립니다.
      Future<void> settle() async {
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      // 화면 아래쪽은 스크롤해야 그려지므로 끝까지 내려 봅니다.
      Future<void> scrollToEnd() async {
        for (var i = 0; i < 8; i++) {
          final scrollable = find.byWidgetPredicate(
            (widget) =>
                widget is Scrollable &&
                widget.axisDirection == AxisDirection.down,
          );
          if (scrollable.evaluate().isEmpty) return;
          await tester.drag(
            scrollable.first,
            Offset(0, -size.height * 0.6),
            warnIfMissed: false,
          );
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      Future<void> open(String name, Future<void> Function() go) async {
        screen = name;
        await go();
        await settle();
        await scrollToEnd();
      }

      for (final route in routes) {
        await open(route, () async => router.go(route));
      }
      await open(AppRoute.uploadConfirm, () async {
        await container.read(uploadProvider.notifier).pick(UploadSource.pdf);
        router.go(AppRoute.uploadConfirm);
      });
      await open(AppRoute.uploadReview, () async {
        await container.read(uploadProvider.notifier).analyze();
        router.go(AppRoute.uploadReview);
      });
      await open('새 박스 시트', () async {
        router.go(AppRoute.archive);
        await settle();
        await tester.tap(find.text('새 박스'), warnIfMissed: false);
      });

      // 홈·보관함이 건 자정 Timer가 남지 않도록 testWidgets의 Timer 검사 전에 정리합니다.
      await tester.pumpWidget(const SizedBox.shrink());
      FlutterError.onError = reportError;
      expect(overflows, isEmpty);
    });
  }
}
