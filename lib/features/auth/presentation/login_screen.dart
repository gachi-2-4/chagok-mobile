import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_text_field.dart';
import 'package:chagok_mobile/features/auth/application/login_notifier.dart';
import 'package:chagok_mobile/features/auth/presentation/auth_strings.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/auth_form_layout.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/auth_switch_prompt.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/check_label.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/form_message.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/password_field.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/social_login_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// L01 · 전화번호와 비밀번호로 로그인하는 화면.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  /// Figma 로고 이미지 크기.
  static const _logoWidth = 137.0;
  static const _logoHeight = 80.0;

  /// 로고와 입력창 사이 간격.
  static const _logoGap = 20.0;

  /// 입력창과 "자동 로그인" 줄 사이 간격.
  static const _optionsGap = 8.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);
    final errorMessage = form.errorMessage;

    Future<void> logIn() async {
      final isLoggedIn = await notifier.logIn();
      if (!isLoggedIn || !context.mounted) return;
      context.go(AppRoute.home);
    }

    void showComingSoon() {
      // TODO: 간편 로그인 SDK를 붙이면 연결합니다.
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AuthStrings.comingSoon)));
    }

    return AuthFormLayout(
      body: [
        Center(
          child: Semantics(
            label: AuthStrings.logoLabel,
            image: true,
            child: Image.asset(
              'assets/images/logo.png',
              width: _logoWidth,
              height: _logoHeight,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
        ),
        const SizedBox(height: _logoGap),
        AppTextField(
          label: AuthStrings.phoneLabel,
          hintText: AuthStrings.phoneHint,
          onChanged: notifier.updatePhoneNumber,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.stack),
        PasswordField(
          label: AuthStrings.passwordLabel,
          hintText: AuthStrings.passwordHint,
          onChanged: notifier.updatePassword,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: _optionsGap),
        Row(
          children: [
            CheckLabel(
              label: AuthStrings.keepSignedIn,
              isChecked: form.keepSignedIn,
              onTap: notifier.toggleKeepSignedIn,
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push(AppRoute.forgotPassword),
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
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          FormMessage(errorMessage, isError: true),
        ],
      ],
      actions: [
        AuthSwitchPrompt(
          message: AuthStrings.noAccount,
          actionLabel: AuthStrings.goToSignUp,
          onTap: () => context.push(AppRoute.signUp),
        ),
        AppButton.primary(
          label: AuthStrings.logIn,
          onPressed: form.canSubmit ? logIn : null,
        ),
        const SizedBox(height: AppSpacing.buttonGap),
        const _DividerLabel(label: AuthStrings.socialLogin),
        const SizedBox(height: AppSpacing.buttonGap),
        SocialLoginButton(
          provider: SocialLoginProvider.kakao,
          onPressed: showComingSoon,
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
