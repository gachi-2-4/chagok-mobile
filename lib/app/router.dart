import 'package:chagok_mobile/app/main_shell.dart';
import 'package:chagok_mobile/app/tab_placeholder_screen.dart';
import 'package:chagok_mobile/features/home/presentation/home_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 앱의 모든 경로.
///
/// 경로 문자열은 직접 쓰지 않고 이 상수를 참조합니다.
/// 예: `context.go(AppRoute.home)`
abstract final class AppRoute {
  // 하단 탭
  static const archive = '/archive';
  static const chat = '/chat';
  static const home = '/';
  static const calendar = '/calendar';
  static const settings = '/settings';
}

/// 앱 전역 [GoRouter].
///
/// Provider로 두어 나중에 로그인 상태 등에 따른 redirect를
/// 다른 Provider를 읽어서 처리할 수 있게 합니다.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoute.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        // 순서는 MainShell.tabs와 같아야 합니다.
        branches: [
          _tab(
            AppRoute.archive,
            (_) => const TabPlaceholderScreen(title: '보관함'),
          ),
          _tab(AppRoute.chat, (_) => const TabPlaceholderScreen(title: '채팅')),
          _tab(AppRoute.home, (_) => const HomeScreen()),
          _tab(
            AppRoute.calendar,
            (_) => const TabPlaceholderScreen(title: '캘린더'),
          ),
          _tab(
            AppRoute.settings,
            (_) => const TabPlaceholderScreen(title: '설정'),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// 첫 화면이 [builder]인 탭 하나.
StatefulShellBranch _tab(
  String path,
  Widget Function(GoRouterState state) builder,
) {
  return StatefulShellBranch(
    routes: [GoRoute(path: path, builder: (context, state) => builder(state))],
  );
}
