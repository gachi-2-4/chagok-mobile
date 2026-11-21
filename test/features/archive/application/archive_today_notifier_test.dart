import 'package:chagok_mobile/features/archive/application/archive_clock.dart';
import 'package:chagok_mobile/features/archive/application/archive_today_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DateTime now;
  late ProviderContainer container;

  setUp(() {
    now = DateTime(2026, 11, 21, 23, 59);
    container = ProviderContainer(
      overrides: [archiveClockProvider.overrideWithValue(() => now)],
    );
    addTearDown(container.dispose);
    container.listen(archiveTodayProvider, (_, _) {});
  });

  group('ArchiveTodayNotifier', () {
    test('처음 읽으면 오늘 날짜 0시를 돌려준다', () {
      expect(container.read(archiveTodayProvider), DateTime(2026, 11, 21));
    });

    test('날짜가 바뀐 뒤 refresh를 부르면 새 날짜로 바꾼다', () {
      now = DateTime(2026, 11, 22, 8);

      container.read(archiveTodayProvider.notifier).refresh();

      expect(container.read(archiveTodayProvider), DateTime(2026, 11, 22));
    });

    // testWidgets 안에서는 Timer가 가짜 시간으로 흐르므로 pump로 자정을 넘깁니다.
    testWidgets('자정이 지나면 저절로 다음 날로 바뀐다', (tester) async {
      final container = ProviderContainer(
        overrides: [archiveClockProvider.overrideWithValue(() => now)],
      );
      var isDisposed = false;
      void disposeOnce() {
        if (isDisposed) return;
        isDisposed = true;
        container.dispose();
      }

      // 검증이 실패해도 정리되도록 tearDown에도 등록합니다.
      addTearDown(disposeOnce);
      container.listen(archiveTodayProvider, (_, _) {});

      try {
        now = DateTime(2026, 11, 22, 0, 0, 1);
        await tester.pump(const Duration(minutes: 1, seconds: 1));

        expect(container.read(archiveTodayProvider), DateTime(2026, 11, 22));
      } finally {
        // 다음 자정 Timer가 다시 걸리므로, testWidgets의 남은 Timer 검사보다
        // 먼저 정리해 Timer를 취소합니다.
        disposeOnce();
      }
    });
  });
}
