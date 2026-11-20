import 'package:chagok_mobile/features/home/application/home_clock.dart';
import 'package:chagok_mobile/features/home/application/home_notifier.dart';
import 'package:chagok_mobile/features/home/application/home_today_notifier.dart';
import 'package:chagok_mobile/features/home/data/home_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_home_repository.dart';

void main() {
  var now = DateTime(2026, 11, 18, 10);
  late FakeHomeRepository repository;
  late ProviderContainer container;

  setUp(() {
    now = DateTime(2026, 11, 18, 10);
    repository = FakeHomeRepository();
    container = ProviderContainer(
      overrides: [
        homeRepositoryProvider.overrideWithValue(repository),
        homeClockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);
  });

  group('HomeNotifier', () {
    test('처음 읽으면 지금 시각 기준으로 홈 내용을 불러온다', () async {
      final summary = await container.read(homeProvider.future);

      expect(repository.requestedTimes, [now]);
      expect(summary.schedules.single.title, '처음');
    });

    test('새로 고치면 다시 불러온 내용으로 바꾼다', () async {
      await container.read(homeProvider.future);
      repository.title = '새로 고침';

      await container.read(homeProvider.notifier).refresh();

      final summary = container.read(homeProvider).value;
      expect(summary?.schedules.single.title, '새로 고침');
    });

    test('날짜가 바뀌면 새 날짜 기준으로 홈 내용을 다시 불러온다', () async {
      container.listen(homeProvider, (_, _) {});
      await container.read(homeProvider.future);
      now = DateTime(2026, 11, 19, 7);

      container.read(homeTodayProvider.notifier).refresh();
      await container.read(homeProvider.future);

      expect(repository.requestedTimes.last, DateTime(2026, 11, 19, 7));
    });
  });
}
