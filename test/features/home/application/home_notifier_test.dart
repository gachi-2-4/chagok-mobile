import 'package:chagok_mobile/features/home/application/home_clock.dart';
import 'package:chagok_mobile/features/home/application/home_notifier.dart';
import 'package:chagok_mobile/features/home/data/home_repository.dart';
import 'package:chagok_mobile/features/home/data/home_summary.dart';
import 'package:chagok_mobile/features/home/data/schedule_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeHomeRepository implements HomeRepository {
  final requestedTimes = <DateTime>[];
  String title = '처음';

  @override
  Future<HomeSummary> fetchSummary(DateTime now) async {
    requestedTimes.add(now);
    return HomeSummary(
      schedules: [ScheduleItem(date: now, title: title)],
      recentBoxes: const [],
      recentAlerts: const [],
    );
  }
}

void main() {
  final now = DateTime(2026, 11, 18, 10);
  late FakeHomeRepository repository;
  late ProviderContainer container;

  setUp(() {
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
    test('지금 시각 기준으로 홈 내용을 불러온다', () async {
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
  });
}
