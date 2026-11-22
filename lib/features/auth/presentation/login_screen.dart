import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_text_field.dart';
import 'package:chagok_mobile/features/auth/application/login_form.dart';
import 'package:chagok_mobile/features/auth/application/login_notifier.dart';
import 'package:chagok_mobile/features/auth/application/social_login_step.dart';
import 'package:chagok_mobile/features/auth/presentation/auth_strings.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/auth_form_layout.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/auth_switch_prompt.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/check_label.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/form_message.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/password_field.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/social_login_button.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/social_login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// L01 · 전화번호와 비밀번호로 로그인하는 화면.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(loginProvider);

    Future<void> logIn() async {
      final isLoggedIn = await ref.read(loginProvider.notifier).logIn();
      if (!isLoggedIn || !context.mounted) return;
      context.go(AppRoute.home);
    }

    Future<void> logInWithKakao() async {
      // 로그인하면 로그인 상태가 바뀌어 라우터가 이 화면을 치울 수 있으므로,
      // 이동은 미리 잡아 둔 라우터로 합니다.
      final router = GoRouter.of(context);
      final step = await ref.read(loginProvider.notifier).logInWithKakao();
      if (step == null) return;
      router.go(switch (step) {
        SocialLoginStep.terms => AppRoute.socialTerms,
        SocialLoginStep.onboarding => AppRoute.onboarding,
        SocialLoginStep.home => AppRoute.home,
      });
    }

    void showComingSoon() {
      // TODO: 구글 로그인 SDK를 붙이면 연결합니다.
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AuthStrings.comingSoon)));
    }

    return AuthFormLayout(
      body: [_LoginFields(form: form)],
      actions: [
        AuthSwitchPrompt(
          message: AuthStrings.noAccount,
          actionLabel: AuthStrings.goToSignUp,
          onTap: () => unawaited(context.push(AppRoute.signUp)),
        ),
        AppButton.primary(
          label: AuthStrings.logIn,
          onPressed: form.canSubmit ? () => unawaited(logIn()) : null,
        ),
        const SizedBox(height: AppSpacing.buttonGap),
        const _DividerLabel(label: AuthStrings.socialLogin),
        const SizedBox(height: AppSpacing.buttonGap),
        SocialLoginButton(
          provider: SocialLoginProvider.kakao,
          onPressed: () => unawaited(logInWithKakao()),
        ),
        const SizedBox(height: AppSpacing.buttonGap),
        SocialLoginButton(
          provider: SocialLoginProvider.google,
          onPressed: showComingSoon,
        ),
      ],
    );
  }
}

/// 로고, 전화번호·비밀번호 입력, 자동 로그인·비밀번호 찾기, 실패 안내.
class _LoginFields extends ConsumerWidget {
  const _LoginFields({required this.form});

  final LoginForm form;

  /// Figma 로고 이미지 크기.
  static const _logoWidth = 137.0;
  static const _logoHeight = 80.0;
  static const _logoAsset = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LoginNotifier notifier() => ref.read(loginProvider.notifier);
    final failure = form.failure;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Semantics(
            label: AuthStrings.logoLabel,
            image: true,
            child: Image.asset(
              _logoAsset,
              width: _logoWidth,
              height: _logoHeight,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppTextField(
          label: AuthStrings.phoneLabel,
          hintText: AuthStrings.phoneHint,
          onChanged: (value) => notifier().updatePhoneNumber(value),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.stack),
        PasswordField(
          label: AuthStrings.passwordLabel,
          hintText: AuthStrings.passwordHint,
          onChanged: (value) => notifier().updatePassword(value),
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: AppSpacing.sm),
        _LoginOptions(keepSignedIn: form.keepSignedIn),
        if (failure != null) ...[
          const SizedBox(height: AppSpacing.sm),
          FormMessage(text: AuthStrings.failure(failure), isError: true),
        ],
      ],
    );
  }
}

/// "자동 로그인" 체크와 "비밀번호 찾기" 링크 한 줄.
class _LoginOptions extends ConsumerWidget {
  const _LoginOptions({required this.keepSignedIn});

  final bool keepSignedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 글자를 크게 키워 한 줄에 들어가지 않으면 비밀번호 찾기를 아랫줄로 내립니다.
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        CheckLabel(
          label: AuthStrings.keepSignedIn,
          isChecked: keepSignedIn,
          onTap: () => ref.read(loginProvider.notifier).toggleKeepSignedIn(),
        ),
        TextButton(
          onPressed: () => unawaited(context.push(AppRoute.forgotPassword)),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            textStyle: AppTypography.body,
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, kMinInteractiveDimension),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(AuthStrings.findPassword),
        ),
      ],
    );
  }
}

/// 양쪽에 선이 있는 가운데 글자. 예: "── 간편 로그인 ──"
class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(label, style: AppTypography.caption),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}
