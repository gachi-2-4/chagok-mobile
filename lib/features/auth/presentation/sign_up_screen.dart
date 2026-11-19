import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_page_header.dart';
import 'package:chagok_mobile/core/widgets/app_text_field.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/auth/application/sign_up_notifier.dart';
import 'package:chagok_mobile/features/auth/presentation/auth_strings.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/auth_form_layout.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/auth_switch_prompt.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/form_message.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A01 · 회원가입 정보 입력 화면.
class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  /// 제목 묶음과 입력창 묶음 사이 간격.
  static const _headerGap = 18.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(signUpProvider);
    final notifier = ref.read(signUpProvider.notifier);
    final errorMessage = form.errorMessage;

    Future<void> requestCode() async {
      final isSent = await notifier.requestVerificationCode();
      if (!isSent || !context.mounted) return;
      await context.push(AppRoute.signUpVerification);
    }

    return AuthFormLayout(
      appBar: const AppTopBar(title: AuthStrings.signUpBarTitle),
      body: [
        const AppPageHeader(
          title: AuthStrings.signUpTitle,
          description: AuthStrings.signUpDescription,
        ),
        const SizedBox(height: _headerGap),
        AppTextField(
          label: AuthStrings.phoneLabel,
          hintText: AuthStrings.phoneHint,
          onChanged: notifier.updatePhoneNumber,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.stack),
        AppTextField(
          label: AuthStrings.nameLabel,
          hintText: AuthStrings.nameHint,
          onChanged: notifier.updateName,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.stack),
        AppTextField(
          label: AuthStrings.birthDateLabel,
          hintText: AuthStrings.birthDateHint,
          onChanged: notifier.updateBirthDate,
          keyboardType: TextInputType.datetime,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.stack),
        PasswordField(
          label: AuthStrings.passwordLabel,
          hintText: AuthStrings.passwordHint,
          onChanged: notifier.updatePassword,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.stack),
        FormMessage(
          AuthStrings.passwordRule,
          isError: form.password.isNotEmpty && !form.isPasswordValid,
        ),
        const SizedBox(height: AppSpacing.stack),
        PasswordField(
          label: AuthStrings.passwordConfirmLabel,
          hintText: AuthStrings.passwordConfirmHint,
          onChanged: notifier.updatePasswordConfirm,
          textInputAction: TextInputAction.done,
        ),
        if (form.hasPasswordMismatch) ...[
          const SizedBox(height: AppSpacing.stack),
          const FormMessage(AuthStrings.passwordMismatch, isError: true),
        ],
        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.stack),
          FormMessage(errorMessage, isError: true),
        ],
      ],
      actions: [
        AuthSwitchPrompt(
          message: AuthStrings.hasAccount,
          actionLabel: AuthStrings.goToLogin,
          onTap: () => context.go(AppRoute.login),
        ),
        AppButton.primary(
          label: AuthStrings.requestCode,
          onPressed: form.canRequestCode ? requestCode : null,
        ),
      ],
    );
  }
}
