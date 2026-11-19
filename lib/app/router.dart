import 'package:chagok_mobile/features/auth/presentation/forgot_password_screen.dart';
import 'package:chagok_mobile/features/auth/presentation/login_screen.dart';
import 'package:chagok_mobile/features/auth/presentation/phone_verification_screen.dart';
import 'package:chagok_mobile/features/auth/presentation/reset_password_screen.dart';
import 'package:chagok_mobile/features/auth/presentation/sign_up_screen.dart';
import 'package:chagok_mobile/features/auth/presentation/terms_agreement_screen.dart';
import 'package:chagok_mobile/features/auth/presentation/verification_purpose.dart';
import 'package:chagok_mobile/features/home/presentation/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 앱의 모든 경로.
///
/// 경로 문자열은 직접 쓰지 않고 이 상수를 참조합니다.
/// 예: `context.go(AppRoute.home)`
abstract final class AppRoute {
  static const home = '/';

  // 회원가입 (A01~A03)
  static const signUp = '/sign-up';
  static const signUpVerification = '/sign-up/verification';
  static const signUpTerms = '/sign-up/terms';

  // 로그인 (L01~L04)
  static const login = '/login';
  static const forgotPassword = '/login/forgot-password';
  static const passwordResetVerification =
      '/login/forgot-password/verification';
  static const resetPassword = '/login/reset-password';
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
      ..._authRoutes,
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

final _authRoutes = [
  GoRoute(
    path: AppRoute.signUp,
    builder: (context, state) => const SignUpScreen(),
  ),
  GoRoute(
    path: AppRoute.signUpVerification,
    builder: (context, state) =>
        const PhoneVerificationScreen(purpose: VerificationPurpose.signUp),
  ),
  GoRoute(
    path: AppRoute.signUpTerms,
    builder: (context, state) => const TermsAgreementScreen(),
  ),
  GoRoute(
    path: AppRoute.login,
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: AppRoute.forgotPassword,
    builder: (context, state) => const ForgotPasswordScreen(),
  ),
  GoRoute(
    path: AppRoute.passwordResetVerification,
    builder: (context, state) => const PhoneVerificationScreen(
      purpose: VerificationPurpose.passwordReset,
    ),
  ),
  GoRoute(
    path: AppRoute.resetPassword,
    builder: (context, state) => const ResetPasswordScreen(),
  ),
];
