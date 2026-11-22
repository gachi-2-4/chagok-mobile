import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_config.dart';
import 'package:chagok_mobile/core/network/session_notifier.dart';
import 'package:chagok_mobile/features/home/data/api_home_repository.dart';
import 'package:chagok_mobile/features/home/data/home_summary.dart';
import 'package:chagok_mobile/features/home/data/sample_home_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 홈 화면에 필요한 내용을 모아 가져오는 창구.
abstract interface class HomeRepository {
  /// [now] 기준의 일정, 최근 보관함, 최근 알림을 가져옵니다.
  Future<HomeSummary> fetchSummary(DateTime now);
}

/// 앱 전역 [HomeRepository].
///
/// API 서버 주소가 있으면 서버의 메인 화면 조회를, 없으면 예시 내용을 씁니다.
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  if (!ref.watch(isApiEnabledProvider)) return SampleHomeRepository();
  // 계정이 바뀌면 앞 계정의 데이터를 버리고 다시 불러오게 합니다.
  ref.watch(isSignedInProvider);
  return ApiHomeRepository(client: ref.watch(apiClientProvider));
});
