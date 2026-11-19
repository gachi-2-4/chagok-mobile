import 'package:chagok_mobile/features/home/application/home_clock.dart';
import 'package:chagok_mobile/features/home/data/home_repository.dart';
import 'package:chagok_mobile/features/home/data/home_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 홈 화면 내용.
final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeSummary>(
  HomeNotifier.new,
);

/// 홈 화면 내용을 불러오고, 당겨서 새로 고칠 때 다시 불러옵니다.
class HomeNotifier extends AsyncNotifier<HomeSummary> {
  @override
  Future<HomeSummary> build() {
    final now = ref.watch(homeClockProvider)();
    return ref.watch(homeRepositoryProvider).fetchSummary(now);
  }

  Future<void> refresh() async {
    final now = ref.read(homeClockProvider)();
    state = await AsyncValue.guard(
      () => ref.read(homeRepositoryProvider).fetchSummary(now),
    );
  }
}
