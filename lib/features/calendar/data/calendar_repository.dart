import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_config.dart';
import 'package:chagok_mobile/features/calendar/data/api_calendar_repository.dart';
import 'package:chagok_mobile/features/calendar/data/deadline.dart';
import 'package:chagok_mobile/features/calendar/data/sample_calendar_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 서류 기한을 가져오고, 기기 캘린더 등록 여부를 저장하는 창구.
abstract interface class CalendarRepository {
  /// [today] 기준으로 보관한 서류의 기한을 모두 가져옵니다.
  Future<List<Deadline>> fetchDeadlines(DateTime today);

  /// 기한 [id]를 기기 캘린더에 등록하거나([isRegistered]가 true) 뺍니다.
  Future<void> setRegistered({required String id, required bool isRegistered});
}

/// 앱 전역 [CalendarRepository].
///
/// API 서버 주소가 있으면 서버의 기한·기한 알림을, 없으면 예시 기한을 씁니다.
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  if (!ref.watch(isApiEnabledProvider)) return SampleCalendarRepository();
  return ApiCalendarRepository(client: ref.watch(apiClientProvider));
});
