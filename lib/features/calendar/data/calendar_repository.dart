import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_config.dart';
import 'package:chagok_mobile/core/network/session_notifier.dart';
import 'package:chagok_mobile/features/calendar/data/api_calendar_repository.dart';
import 'package:chagok_mobile/features/calendar/data/deadline.dart';
import 'package:chagok_mobile/features/calendar/data/sample_calendar_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 서류 기한을 가져오고, 기기 캘린더 등록 여부를 저장하는 창구.
abstract interface class CalendarRepository {
  // TODO: 캘린더에서 1년 밖의 달로 넘기면 그 달 기한을 다시 불러오도록 바꿉니다.
  /// [today] 기준으로 보관한 서류의 기한을 가져옵니다.
  ///
  /// 적어도 [today]가 든 달의 1일부터 1년 안의 기한은 모두 담아야 합니다. 서버는 한 번에
  /// 1년까지만 주므로, 그 밖의 달로 넘기면 기한이 보이지 않을 수 있습니다.
  Future<List<Deadline>> fetchDeadlines(DateTime today);

  /// 기한 [id]를 기기 캘린더에 등록하거나([isRegistered]가 true) 뺍니다.
  Future<void> setRegistered({required String id, required bool isRegistered});
}

/// 앱 전역 [CalendarRepository].
///
/// API 서버 주소가 있으면 서버의 기한·기한 알림을, 없으면 예시 기한을 씁니다.
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  if (!ref.watch(isApiEnabledProvider)) return SampleCalendarRepository();
  // 계정이 바뀌면 앞 계정의 데이터를 버리고 다시 불러오게 합니다.
  ref.watch(isSignedInProvider);
  return ApiCalendarRepository(client: ref.watch(apiClientProvider));
});
