import 'package:chagok_mobile/features/home/presentation/home_screen.dart';
import 'package:chagok_mobile/features/upload/application/upload_notifier.dart';
import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_confirm_screen.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_retake_screen.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_review_screen.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_source_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 앱의 모든 경로.
///
/// 경로 문자열은 직접 쓰지 않고 이 상수를 참조합니다.
/// 예: `context.go(AppRoute.home)`
abstract final class AppRoute {
  static const home = '/';

  // 서류 올리기 (U01~U04)
  static const upload = '/upload';
  static const uploadConfirm = '/upload/confirm';
  static const uploadRetake = '/upload/retake';
  static const uploadReview = '/upload/review';
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
        path: AppRoute.upload,
        builder: (context, state) => const UploadSourceScreen(),
      ),
      // 고른 파일·분석 결과 없이 주소로 바로 들어오면(앱을 다시 연 경우 등)
      // 빈 화면에 갇히지 않도록 서류 올리기 첫 화면으로 돌려보냅니다.
      GoRoute(
        path: AppRoute.uploadConfirm,
        redirect: (context, state) =>
            ref.read(uploadProvider).document == null ? AppRoute.upload : null,
        builder: (context, state) => const UploadConfirmScreen(),
      ),
      GoRoute(
        path: AppRoute.uploadRetake,
        builder: (context, state) => const UploadRetakeScreen(),
      ),
      GoRoute(
        path: AppRoute.uploadReview,
        redirect: (context, state) =>
            ref.read(uploadProvider).result is AnalysisSucceeded
            ? null
            : AppRoute.upload,
        builder: (context, state) => const UploadReviewScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
