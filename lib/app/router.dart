import 'package:chagok_mobile/features/chat/presentation/chat_attach_screen.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_list_screen.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_room_screen.dart';
import 'package:chagok_mobile/features/home/presentation/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 앱의 모든 경로.
///
/// 경로 문자열은 직접 쓰지 않고 이 상수를 참조합니다.
/// 예: `context.go(AppRoute.home)`
abstract final class AppRoute {
  static const home = '/';

  // 채팅 (H01~H03)
  static const chat = '/chat';
  static const chatRoomPattern = '/chat/:id';
  static const chatAttachPattern = '/chat/:id/documents';
  static String chatRoom(String id) => '/chat/$id';
  static String chatAttach(String id) => '/chat/$id/documents';
}

/// 앱 전역 [GoRouter].
///
/// Provider로 두어 나중에 로그인 상태 등에 따른 redirect를
/// 다른 Provider를 읽어서 처리할 수 있게 합니다.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoute.home,
    routes: [
      GoRoute(
        path: AppRoute.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoute.chat,
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: AppRoute.chatRoomPattern,
        builder: (context, state) =>
            ChatRoomScreen(threadId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: AppRoute.chatAttachPattern,
        builder: (context, state) =>
            ChatAttachScreen(threadId: state.pathParameters['id'] ?? ''),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
