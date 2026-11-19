import 'package:chagok_mobile/features/home/presentation/home_screen.dart';
import 'package:chagok_mobile/features/settings/presentation/notification_settings_screen.dart';
import 'package:chagok_mobile/features/settings/presentation/settings_screen.dart';
import 'package:chagok_mobile/features/settings/presentation/text_size_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 앱의 모든 경로.
///
/// 경로 문자열은 직접 쓰지 않고 이 상수를 참조합니다.
/// 예: `context.go(AppRoute.home)`
abstract final class AppRoute {
  static const home = '/';

  // 설정 (S01~S05)
  static const settings = '/settings';
  static const textSizeSettings = '/settings/text-size';
  static const notificationSettings = '/settings/notifications';
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
        path: AppRoute.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoute.textSizeSettings,
        builder: (context, state) => const TextSizeScreen(),
      ),
      GoRoute(
        path: AppRoute.notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
