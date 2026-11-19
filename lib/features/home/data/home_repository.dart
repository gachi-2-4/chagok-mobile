import 'package:chagok_mobile/features/home/data/home_summary.dart';
import 'package:chagok_mobile/features/home/data/sample_home_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 홈 화면에 필요한 내용을 모아 가져오는 창구.
abstract interface class HomeRepository {
  /// [now] 기준의 일정, 최근 보관함, 최근 알림을 가져옵니다.
  Future<HomeSummary> fetchSummary(DateTime now);
}

/// 앱 전역 [HomeRepository].
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  // TODO: 보관함·알림·캘린더 기능이 생기면 그 Provider를 모아 만듭니다.
  return SampleHomeRepository();
});
