import 'package:chagok_mobile/features/document/presentation/document_edit_screen.dart';
import 'package:chagok_mobile/features/document/presentation/payment_reminder_screen.dart';
import 'package:chagok_mobile/features/home/presentation/home_screen.dart';
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

  // 서류 상세 (D01~D02)
  static const documentEditPattern = '/documents/:id/edit';
  static const paymentReminderPattern = '/documents/:id/reminder';
  static String documentEdit(String id) => '/documents/$id/edit';
  static String paymentReminder(String id) => '/documents/$id/reminder';

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
        path: AppRoute.documentEditPattern,
        builder: (context, state) =>
            DocumentEditScreen(documentId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: AppRoute.paymentReminderPattern,
        builder: (context, state) =>
            PaymentReminderScreen(documentId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: AppRoute.upload,
        builder: (context, state) => const UploadSourceScreen(),
      ),
      GoRoute(
        path: AppRoute.uploadConfirm,
        builder: (context, state) => const UploadConfirmScreen(),
      ),
      GoRoute(
        path: AppRoute.uploadRetake,
        builder: (context, state) => const UploadRetakeScreen(),
      ),
      GoRoute(
        path: AppRoute.uploadReview,
        builder: (context, state) => const UploadReviewScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
