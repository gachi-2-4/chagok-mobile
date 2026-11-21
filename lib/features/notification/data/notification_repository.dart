import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_config.dart';
import 'package:chagok_mobile/features/notification/data/api_notification_repository.dart';
import 'package:chagok_mobile/features/notification/data/app_notification.dart';
import 'package:chagok_mobile/features/notification/data/sample_notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 알림을 가져오고 읽음·완료 표시를 저장하는 창구.
abstract interface class NotificationRepository {
  /// [now] 기준으로 받은 알림을 모두 가져옵니다.
  Future<List<AppNotification>> fetchAll(DateTime now);

  /// [ids] 알림을 읽음으로 표시합니다.
  Future<void> markRead(List<String> ids);

  /// 알림 [id]의 할 일을 마쳤다고 표시합니다. 읽음으로도 표시합니다.
  Future<void> markDone(String id);
}

/// 앱 전역 [NotificationRepository].
///
/// API 서버 주소가 있으면 서버의 알림을, 없으면 예시 알림을 씁니다.
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  if (!ref.watch(isApiEnabledProvider)) return SampleNotificationRepository();
  return ApiNotificationRepository(client: ref.watch(apiClientProvider));
});
