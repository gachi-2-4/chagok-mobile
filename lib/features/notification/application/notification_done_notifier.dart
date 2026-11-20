import 'package:chagok_mobile/features/notification/application/notification_list_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 완료 표시를 저장하고 있는 알림 id.
final notificationDoneProvider =
    NotifierProvider<NotificationDoneNotifier, Set<String>>(
      NotificationDoneNotifier.new,
    );

/// 알림 완료 표시를 한 번만 저장합니다.
///
/// 저장이 끝나기 전에 다시 누르면 같은 요청을 또 보내고 화면을 두 번 닫을 수
/// 있으므로, 저장 중인 알림을 기억해 두고 그동안은 아무것도 하지 않습니다.
class NotificationDoneNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  /// 알림 [id]를 완료로 표시합니다.
  ///
  /// 저장했으면 true, 실패하면 false, 이미 저장하고 있으면 null을 돌려줍니다.
  Future<bool?> markDone(String id) async {
    if (state.contains(id)) return null;
    state = {...state, id};
    try {
      return await ref.read(notificationListProvider.notifier).markDone(id);
    } finally {
      if (ref.mounted) state = {...state}..remove(id);
    }
  }
}
