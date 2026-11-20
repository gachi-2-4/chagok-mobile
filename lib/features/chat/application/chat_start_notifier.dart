import 'package:chagok_mobile/features/chat/data/chat_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "새 대화 시작"의 진행 상태.
///
/// 시작하는 중이면 [AsyncLoading], 실패했으면 [AsyncError], 그 밖에는 [AsyncData]입니다.
final chatStartProvider =
    NotifierProvider.autoDispose<ChatStartNotifier, AsyncValue<void>>(
      ChatStartNotifier.new,
    );

/// 새 대화를 엽니다. 실패해도 예외를 던지지 않고 에러 상태로 남깁니다.
class ChatStartNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// 새 대화를 열고 그 id를 돌려줍니다.
  ///
  /// 이미 시작하는 중이거나 실패하면 null을 돌려줍니다.
  Future<String?> start() async {
    if (state.isLoading) return null;
    // 시작하는 중에 화면을 떠나도 상태를 정리할 수 있도록 provider를 살려 둡니다.
    final keepAlive = ref.keepAlive();
    state = const AsyncLoading();
    try {
      final thread = await ref.read(chatRepositoryProvider).createThread();
      if (ref.mounted) state = const AsyncData(null);
      return thread.id;
    } catch (error, stackTrace) {
      debugPrint('새 대화를 시작하지 못했습니다: $error\n$stackTrace');
      if (ref.mounted) state = AsyncError(error, stackTrace);
      return null;
    } finally {
      keepAlive.close();
    }
  }
}
